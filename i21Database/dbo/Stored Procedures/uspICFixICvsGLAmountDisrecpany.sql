CREATE PROCEDURE uspICFixICvsGLAmountDisrecpany
	@dtmTargetOpenDate AS DATETIME 
	,@strType AS NVARCHAR(500) = 'Inventory Adjustment - Quantity Change' -- 'Inventory Auto Variance on Negatively Sold or Used Stock'	
	,@intMonth AS INT = NULL 
	,@intYear AS INT = NULL 
AS

DECLARE 
	@icAmount AS NUMERIC(18,6)
	,@glAmount AS NUMERIC(18,6)
	,@strTransactionId AS NVARCHAR(50)
	,@strBatchId AS NVARCHAR(50)
	,@dtmDate AS DATETIME
	,@dblDiff AS NUMERIC(18,6)
	,@intInventoryTransactionId AS INT
 
DECLARE	@GLEntries AS RecapTableType 

DECLARE @discrepancyList AS TABLE (
	strTransactionId NVARCHAR(50)
	,dtmDate DATETIME
	,dblICAmount NUMERIC(18, 6) NULL
	,dblGLAmount NUMERIC(18, 6) NULL
	,dblDiff NUMERIC(18, 6) NULL
)

-- Get the list of discrepancy
INSERT INTO @discrepancyList (
	strTransactionId
	,dtmDate
	,dblICAmount
	,dblGLAmount
	,dblDiff
)
SELECT 
	ic.strTransactionId
	,ic.dtmDate
	,ic.[ic amount]
	,gl.[gl amount]
	,[diff] = isnull(gl.[gl amount], 0) - isnull(ic.[ic amount], 0)
FROM 
	(

	SELECT	--'IC Only'
			t.strTransactionId
			,t.dtmDate
			,[ic amount] = SUM (ROUND(dbo.fnMultiply(t.dblQty, t.dblCost) + t.dblValue, 2))
	FROM	tblICInventoryTransaction t INNER JOIN tblICInventoryTransactionType ty
				ON t.intTransactionTypeId = ty.intTransactionTypeId
	WHERE	
			(MONTH(t.dtmDate) = @intMonth OR @intMonth IS NULL)
			AND (YEAR(t.dtmDate) = @intYear OR @intYear IS NULL) 
			AND ty.strName = @strType
			AND t.ysnIsUnposted = 0 
	GROUP BY t.strTransactionId, ty.strName, t.dtmDate
	) ic
	OUTER APPLY (
		SELECT 
			--'GL Only'
			[gl amount] = SUM(ROUND(dblDebit - dblCredit,2))	
		FROM	tblGLDetail gd INNER JOIN tblGLAccount ga
					ON gd.intAccountId = ga.intAccountId
				INNER JOIN tblGLAccountSegmentMapping gs
					ON gs.intAccountId = ga.intAccountId
				INNER JOIN tblGLAccountSegment gm
					ON gm.intAccountSegmentId = gs.intAccountSegmentId
				INNER JOIN tblGLAccountCategory ac 
					ON ac.intAccountCategoryId = gm.intAccountCategoryId 
		WHERE 
			(MONTH(gd.dtmDate) = @intMonth OR @intMonth IS NULL)
			AND (YEAR(gd.dtmDate) = @intYear OR @intYear IS NULL) 
			AND gd.strTransactionType = @strType
			AND ac.strAccountCategory IN ('Inventory', 'Inventory In-Transit')
			AND gd.ysnIsUnposted = 0 
			AND gm.intAccountStructureId = 1
			AND gd.strTransactionId = ic.strTransactionId
	) gl 
where
	ic.[ic amount] <> isnull(gl.[gl amount], 0) 

-- If the list is empty, exit the sp immediately. 
IF NOT EXISTS (SELECT TOP 1 1 FROM @discrepancyList)
	RETURN 0;

DECLARE loopDiscrepancy CURSOR LOCAL FAST_FORWARD
FOR 
SELECT 
	strTransactionId
	,dtmDate
	,dblDiff
FROM 
	@discrepancyList

OPEN loopDiscrepancy;

FETCH NEXT FROM loopDiscrepancy INTO 
	@strTransactionId
	,@dtmDate
	,@dblDiff
;

-----------------------------------------------------------------------------------------------------------------------------
-- Start of the loop
-----------------------------------------------------------------------------------------------------------------------------
WHILE @@FETCH_STATUS = 0
BEGIN 
	SET @strBatchId = NULL 
	SET @intInventoryTransactionId = NULL 
	DELETE FROM @GLEntries
	
	-- Get the IC transaction id
	SELECT TOP 1
		@intInventoryTransactionId = t.intInventoryTransactionId
		,@strBatchId = t.strBatchId 
	FROM	
		tblICInventoryTransaction t INNER JOIN tblICInventoryTransactionType ty
			ON t.intTransactionTypeId = ty.intTransactionTypeId
	WHERE	
		t.strTransactionId = @strTransactionId
		AND ty.strName = @strType
		AND t.ysnIsUnposted = 0 

	-- Check if the fiscal year period is open
	IF dbo.isOpenAccountingDate(@dtmDate) = 1
	BEGIN 
		-- When FYP is open, update the existing GL Entries and match it with the value from IC. 
		UPDATE gd
		SET 
			gd.dblDebit = CASE WHEN gd.dblDebit <> 0 THEN gd.dblDebit - @dblDiff ELSE gd.dblDebit END 
			,gd.dblCredit = CASE WHEN gd.dblCredit <> 0 THEN gd.dblCredit - @dblDiff ELSE gd.dblCredit END 
		FROM
			tblGLDetail gd
		WHERE	
			gd.strTransactionId = @strTransactionId
			AND gd.strBatchId = @strBatchId
			AND gd.intJournalLineNo = @intInventoryTransactionId
	END 

	-- FYP is closed. 
	ELSE 
	BEGIN 
		INSERT INTO @GLEntries (
			[dtmDate] 
			,[strBatchId]
			,[intAccountId]
			,[dblDebit]
			,[dblCredit]
			,[dblDebitUnit]
			,[dblCreditUnit]
			,[strDescription]
			,[strCode]
			,[strReference]
			,[intCurrencyId]
			,[dblExchangeRate]
			,[dtmDateEntered]
			,[dtmTransactionDate]
			,[strJournalLineDescription]
			,[intJournalLineNo]
			,[ysnIsUnposted]
			,[intUserId]
			,[intEntityId]
			,[strTransactionId]
			,[intTransactionId]
			,[strTransactionType]
			,[strTransactionForm]
			,[strModuleName]
			,[intConcurrencyId]
			,[dblDebitForeign]	
			,[dblDebitReport]	
			,[dblCreditForeign]	
			,[dblCreditReport]	
			,[dblReportingRate]	
			,[dblForeignRate]
			,[strRateType]		
		)

		SELECT 
			[dtmDate] = @dtmTargetOpenDate
			,[strBatchId] = gd.strBatchId
			,[intAccountId] = gd.intAccountId
			,[dblDebit] = CASE WHEN gd.dblDebit <> 0 THEN -@dblDiff ELSE 0 END 
			,[dblCredit] = CASE WHEN gd.dblCredit <> 0 THEN -@dblDiff ELSE 0 END 
			,[dblDebitUnit] = 0
			,[dblCreditUnit] = 0 
			,[strDescription] = 'Previous year inventory account out of balance correction'
			,[strCode] = gd.strCode
			,[strReference] = gd.strReference
			,[intCurrencyId] = gd.intCurrencyId
			,[dblExchangeRate] = gd.dblExchangeRate
			,[dtmDateEntered] = GETDATE()
			,[dtmTransactionDate] = @dtmTargetOpenDate --gd.dtmTransactionDate
			,[strJournalLineDescription] = 'Previous year inventory account out of balance correction'
			,[intJournalLineNo] = gd.intJournalLineNo
			,[ysnIsUnposted] = 0 
			,[intUserId] = gd.intUserId
			,[intEntityId] = gd.intEntityId
			,[strTransactionId] = gd.strTransactionId
			,[intTransactionId] = gd.intTransactionId
			,[strTransactionType] = gd.strTransactionType
			,[strTransactionForm] = gd.strTransactionForm
			,[strModuleName] = gd.strModuleName
			,[intConcurrencyId] = 1
			,[dblDebitForeign] = 0
			,[dblDebitReport] = 0
			,[dblCreditForeign]	= 0
			,[dblCreditReport] = 0
			,[dblReportingRate]	= gd.dblReportingRate
			,[dblForeignRate] = gd.dblForeignRate
			,[strRateType] = ''
		FROM
			tblGLDetail gd
		WHERE	
			gd.strTransactionId = @strTransactionId
			AND gd.strBatchId = @strBatchId
			AND gd.intJournalLineNo = @intInventoryTransactionId

		EXEC dbo.uspGLBookEntries @GLEntries, 1
	END 

	FETCH NEXT FROM loopDiscrepancy INTO 
		@strTransactionId
		,@dtmDate
		,@dblDiff
	;
END
;
-----------------------------------------------------------------------------------------------------------------------------
-- End of the loop
-----------------------------------------------------------------------------------------------------------------------------
