CREATE PROCEDURE uspICFixICvsGLAmountDisrecpany
	@dtmTargetOpenDate AS DATETIME 
	,@strType AS NVARCHAR(500) 
	,@intMonth AS INT = NULL 
	,@intYear AS INT = NULL 
AS

DECLARE 
	@icAmount AS NUMERIC(18,6)
	,@glAmount AS NUMERIC(18,6)
	,@strTransactionId AS NVARCHAR(50)
	,@strBatchId AS NVARCHAR(50)
	,@intInventoryTransactionId AS INT
	,@dtmDate AS DATETIME 
	,@dblDiff AS NUMERIC(18,6)
 
DECLARE	@GLEntries AS RecapTableType 

DECLARE @discrepancyList AS TABLE (
	strTransactionId NVARCHAR(50)
	,strBatchId NVARCHAR(50)
	,intInventoryTransactionId INT
	,dtmDate DATETIME
	,dblICAmount NUMERIC(18, 6) NULL
	,dblGLAmount NUMERIC(18, 6) NULL
	,dblDiff NUMERIC(18, 6) NULL
)

-- Get the list of discrepancy
INSERT INTO @discrepancyList (
	strTransactionId
	,strBatchId
	,intInventoryTransactionId
	,dtmDate
	,dblICAmount
	,dblGLAmount
	,dblDiff
)
SELECT 
	ic.strTransactionId
	,ic.strBatchId
	,ic.intInventoryTransactionId
	,ic.dtmDate
	,ic.[ic amount]
	,gl.[gl amount]
	,[diff] = 
		CASE 
			WHEN SIGN(ISNULL(ic.[ic amount], 0)) = 1 THEN ISNULL(ic.[ic amount], 0) - ISNULL(gl.[gl amount], 0)
			ELSE -(ISNULL(ic.[ic amount], 0) - ISNULL(gl.[gl amount], 0))
		END
FROM 
	(

	SELECT	--'IC Only'
			t.strTransactionId
			,t.strBatchId
			,t.intInventoryTransactionId
			,t.dtmDate
			,[ic amount] = SUM (ROUND(dbo.fnMultiply(t.dblQty, t.dblCost) + t.dblValue, 2))
	FROM	tblICInventoryTransaction t INNER JOIN tblICInventoryTransactionType ty
				ON t.intTransactionTypeId = ty.intTransactionTypeId
	WHERE	
			(MONTH(t.dtmDate) = @intMonth OR @intMonth IS NULL)
			AND (YEAR(t.dtmDate) = @intYear OR @intYear IS NULL) 
			AND ty.strName = @strType
			AND t.ysnIsUnposted = 0 
	GROUP BY 
			t.strTransactionId
			,t.strBatchId
			,t.intInventoryTransactionId
			,t.dtmDate
	) ic
	OUTER APPLY (
		SELECT 
			--'GL Only'
			[gl amount] = SUM(ROUND(dblDebit - dblCredit, 2))	
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
			--AND dbo.fnDateEquals(gd.dtmDate, ic.dtmDate) = 1
			AND ac.strAccountCategory IN ('Inventory', 'Inventory In-Transit')
			AND gd.ysnIsUnposted = 0 
			AND gm.intAccountStructureId = 1
			AND gd.strTransactionId = ic.strTransactionId
			AND gd.strBatchId = ic.strBatchId
			AND gd.intJournalLineNo = ic.intInventoryTransactionId
			
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
	,strBatchId
	,intInventoryTransactionId
	,dtmDate
	,dblDiff
FROM 
	@discrepancyList

OPEN loopDiscrepancy;

FETCH NEXT FROM loopDiscrepancy INTO 
	@strTransactionId
	,@strBatchId
	,@intInventoryTransactionId
	,@dtmDate
	,@dblDiff
;

-----------------------------------------------------------------------------------------------------------------------------
-- Start of the loop
-----------------------------------------------------------------------------------------------------------------------------
WHILE @@FETCH_STATUS = 0
BEGIN 
	DELETE FROM @GLEntries

	-- Check if the fiscal year period is open
	IF dbo.isOpenAccountingDate(@dtmDate) = 1
	BEGIN 
		--print 'fyp is open'
		-- When FYP is open, update the existing GL Entries and match it with the value from IC. 
		UPDATE gd
		SET 
			gd.dblDebit = gd.dblDebit + @dblDiff
		FROM
			tblGLDetail gd
			--CROSS APPLY dbo.fnGetDebit(@dblDiff) Debit
		WHERE	
			gd.strTransactionId = @strTransactionId
			AND gd.strBatchId = @strBatchId
			AND gd.intJournalLineNo = @intInventoryTransactionId
			AND gd.dblDebit <> 0 

		UPDATE gd
		SET 
			gd.dblCredit = gd.dblCredit + @dblDiff
		FROM
			tblGLDetail gd
			--CROSS APPLY dbo.fnGetCredit(@dblDiff) Credit
		WHERE	
			gd.strTransactionId = @strTransactionId
			AND gd.strBatchId = @strBatchId
			AND gd.intJournalLineNo = @intInventoryTransactionId
			AND gd.dblCredit <> 0 
	END 

	-- FYP is closed. 
	ELSE 
	BEGIN
		--print 'fyp is closed' 
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
			,[dblDebit] = Debit.[Value] 
			,[dblCredit] = Credit.[Value] 
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
			CROSS APPLY dbo.fnGetDebit(@dblDiff) Debit
			CROSS APPLY dbo.fnGetCredit(@dblDiff) Credit
		WHERE	
			gd.strTransactionId = @strTransactionId
			AND gd.strBatchId = @strBatchId
			AND gd.intJournalLineNo = @intInventoryTransactionId
			AND gd.dblDebit <> 0
		UNION ALL
		SELECT 
			[dtmDate] = @dtmTargetOpenDate
			,[strBatchId] = gd.strBatchId
			,[intAccountId] = gd.intAccountId
			,[dblDebit] = Credit.[Value] 
			,[dblCredit] = Debit.[Value] 
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
			CROSS APPLY dbo.fnGetDebit(@dblDiff) Debit
			CROSS APPLY dbo.fnGetCredit(@dblDiff) Credit
		WHERE	
			gd.strTransactionId = @strTransactionId
			AND gd.strBatchId = @strBatchId
			AND gd.intJournalLineNo = @intInventoryTransactionId
			AND gd.dblCredit <> 0

		EXEC dbo.uspGLBookEntries @GLEntries, 1
	END 

	FETCH NEXT FROM loopDiscrepancy INTO 
		@strTransactionId
		,@strBatchId
		,@intInventoryTransactionId
		,@dtmDate
		,@dblDiff
	;
END
;
-----------------------------------------------------------------------------------------------------------------------------
-- End of the loop
-----------------------------------------------------------------------------------------------------------------------------
