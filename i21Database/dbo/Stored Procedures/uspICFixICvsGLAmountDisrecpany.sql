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
	,@strPreviousTransactionId AS NVARCHAR(50)
 
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
	,[diff] = ISNULL(ic.[ic amount], 0) - ISNULL(gl.[gl amount], 0)
		--CASE 
		--	WHEN SIGN(ISNULL(ic.[ic amount], 0)) = 1 THEN ISNULL(ic.[ic amount], 0) - ISNULL(gl.[gl amount], 0)
		--	ELSE -(ISNULL(ic.[ic amount], 0) - ISNULL(gl.[gl amount], 0))
		--END
FROM 
	(

	SELECT	--'IC Only'
			t.strTransactionId
			,t.strBatchId
			,t.intInventoryTransactionId
			,t.dtmDate
			,[ic amount] = SUM (ROUND(dbo.fnMultiply(t.dblQty, t.dblCost) + t.dblValue, 2))
	FROM	tblICInventoryTransaction t 
			CROSS APPLY (
				SELECT DISTINCT
					t2.strTransactionId
				FROM 
					tblICInventoryTransaction t2 INNER JOIN tblICInventoryTransactionType ty
						ON t2.intTransactionTypeId = ty.intTransactionTypeId
				WHERE 
					ty.strName = @strType
					AND t.strTransactionId = t2.strTransactionId
			) trans 
	WHERE	
			(MONTH(t.dtmDate) = @intMonth OR @intMonth IS NULL)
			AND (YEAR(t.dtmDate) = @intYear OR @intYear IS NULL) 			
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
		FROM	
			tblGLDetail gd INNER JOIN tblGLAccount ga
				ON gd.intAccountId = ga.intAccountId
			INNER JOIN tblGLAccountSegmentMapping gs
				ON gs.intAccountId = ga.intAccountId
			INNER JOIN tblGLAccountSegment gm
				ON gm.intAccountSegmentId = gs.intAccountSegmentId
			INNER JOIN tblGLAccountCategory ac 
				ON ac.intAccountCategoryId = gm.intAccountCategoryId 
			CROSS APPLY (
				SELECT DISTINCT 
					gd2.strTransactionId
				FROM 
					tblGLDetail gd2
				WHERE 
					gd2.strTransactionType = @strType
					AND gd.strTransactionId = gd2.strTransactionId
			) trans 
		WHERE 
			(MONTH(gd.dtmDate) = @intMonth OR @intMonth IS NULL)
			AND (YEAR(gd.dtmDate) = @intYear OR @intYear IS NULL) 			
			AND ac.strAccountCategory IN ('Inventory', 'Inventory In-Transit')
			AND gd.ysnIsUnposted = 0 
			AND gm.intAccountStructureId = 1
			AND gd.strTransactionId = ic.strTransactionId
			AND gd.strBatchId = ic.strBatchId
			AND gd.intJournalLineNo = ic.intInventoryTransactionId			
	) gl 
where
	ic.[ic amount] <> isnull(gl.[gl amount], 0) 
order by 
	ic.strTransactionId

select 'debug @discrepancyList', * from @discrepancyList 

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
	--PRINT 'Transaction Id: ' + @strTransactionId

	-- Check if the fiscal year period is open
	IF dbo.isOpenAccountingDate(@dtmDate) = 1
	BEGIN 
		--print 'fyp is open'
		-- When FYP is open, update the existing GL Entries and match it with the value from IC. 
		UPDATE gd
		SET 
			gd.dblDebit = --gd.dblDebit + @dblDiff
				CASE 
					WHEN gd.dblDebit <> 0 THEN gd.dblDebit + Debit.[Value] - Credit.[Value]
					ELSE gd.dblDebit
				END
			,gd.dblCredit =  
				CASE 
					WHEN gd.dblCredit <> 0 THEN gd.dblCredit + Credit.[Value] - Debit.[Value]
					ELSE gd.dblCredit
				END
		FROM
			tblGLDetail gd
			INNER JOIN (
				SELECT TOP 1 
					gd.intGLDetailId
				FROM 
					tblGLDetail gd INNER JOIN tblGLAccount ga
						ON gd.intAccountId = ga.intAccountId
					INNER JOIN tblGLAccountSegmentMapping gs
						ON gs.intAccountId = ga.intAccountId
					INNER JOIN tblGLAccountSegment gm
						ON gm.intAccountSegmentId = gs.intAccountSegmentId
					INNER JOIN tblGLAccountCategory ac 
						ON ac.intAccountCategoryId = gm.intAccountCategoryId
				WHERE
					gd.strTransactionId = @strTransactionId
					AND gd.strBatchId = @strBatchId
					AND gd.intJournalLineNo = @intInventoryTransactionId
					--AND	gd.dblDebit <> 0 
					AND ac.strAccountCategory IN ('Inventory', 'Inventory In-Transit')
					AND gm.intAccountStructureId = 1
			) topGd
				ON gd.intGLDetailId = topGd.intGLDetailId
			CROSS APPLY dbo.fnGetDebit(@dblDiff) Debit
			CROSS APPLY dbo.fnGetCredit(@dblDiff) Credit

		UPDATE gd
		SET 
			gd.dblCredit = -- gd.dblCredit + @dblDiff
				CASE 
					WHEN gd.dblCredit <> 0 THEN gd.dblCredit + Credit.[Value] - Debit.[Value]
					ELSE gd.dblCredit
				END
			,gd.dblDebit =  
				CASE 
					WHEN gd.dblDebit <> 0 THEN gd.dblDebit + Debit.[Value] - Credit.[Value]
					ELSE gd.dblDebit
				END
		FROM
			tblGLDetail gd
			INNER JOIN (
				SELECT TOP 1 
					gd.intGLDetailId
				FROM 
					tblGLDetail gd INNER JOIN tblGLAccount ga
						ON gd.intAccountId = ga.intAccountId
					INNER JOIN tblGLAccountSegmentMapping gs
						ON gs.intAccountId = ga.intAccountId
					INNER JOIN tblGLAccountSegment gm
						ON gm.intAccountSegmentId = gs.intAccountSegmentId
					INNER JOIN tblGLAccountCategory ac 
						ON ac.intAccountCategoryId = gm.intAccountCategoryId
				WHERE
					gd.strTransactionId = @strTransactionId
					AND gd.strBatchId = @strBatchId
					AND gd.intJournalLineNo = @intInventoryTransactionId
					--AND gd.dblCredit <> 0 
					AND ac.strAccountCategory NOT IN ('Inventory', 'Inventory In-Transit')
					AND gm.intAccountStructureId = 1

			) topGd
				ON gd.intGLDetailId = topGd.intGLDetailId		
			CROSS APPLY dbo.fnGetDebit(@dblDiff) Debit
			CROSS APPLY dbo.fnGetCredit(@dblDiff) Credit
						
	END 

	-- FYP is closed. 
	ELSE 
	BEGIN
		IF @strPreviousTransactionId <> @strTransactionId
		BEGIN 
			--PRINT 'different transaction'
			
			--IF @strTransactionId = 'SI-2197' -- DEBUG
			--BEGIN 
			--	select 'discrepancy @GLEntries', * from @GLEntries
			--END 

			IF EXISTS (SELECT TOP 1 1 FROM @GLEntries)
			BEGIN
				EXEC dbo.uspGLBookEntries @GLEntries, 1				
			END

			DELETE FROM @GLEntries
		END 

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
			INNER JOIN (
				SELECT TOP 1 
					gd.intGLDetailId
				FROM 
					tblGLDetail gd INNER JOIN tblGLAccount ga
						ON gd.intAccountId = ga.intAccountId
					INNER JOIN tblGLAccountSegmentMapping gs
						ON gs.intAccountId = ga.intAccountId
					INNER JOIN tblGLAccountSegment gm
						ON gm.intAccountSegmentId = gs.intAccountSegmentId
					INNER JOIN tblGLAccountCategory ac 
						ON ac.intAccountCategoryId = gm.intAccountCategoryId 
				WHERE
					gd.strTransactionId = @strTransactionId
					AND gd.strBatchId = @strBatchId
					AND gd.intJournalLineNo = @intInventoryTransactionId
					--AND gd.dblDebit <> 0
					AND ac.strAccountCategory IN ('Inventory', 'Inventory In-Transit')
					AND gm.intAccountStructureId = 1
			) topGd
				ON gd.intGLDetailId = topGd.intGLDetailId
			CROSS APPLY dbo.fnGetDebit(@dblDiff) Debit
			CROSS APPLY dbo.fnGetCredit(@dblDiff) Credit
			
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
			INNER JOIN (
				SELECT TOP 1 
					gd.intGLDetailId
				FROM 
					tblGLDetail gd INNER JOIN tblGLAccount ga
						ON gd.intAccountId = ga.intAccountId
					INNER JOIN tblGLAccountSegmentMapping gs
						ON gs.intAccountId = ga.intAccountId
					INNER JOIN tblGLAccountSegment gm
						ON gm.intAccountSegmentId = gs.intAccountSegmentId
					INNER JOIN tblGLAccountCategory ac 
						ON ac.intAccountCategoryId = gm.intAccountCategoryId 
				WHERE
					gd.strTransactionId = @strTransactionId
					AND gd.strBatchId = @strBatchId
					AND gd.intJournalLineNo = @intInventoryTransactionId
					--AND gd.dblCredit <> 0
					AND ac.strAccountCategory NOT IN ('Inventory', 'Inventory In-Transit')
					AND gm.intAccountStructureId = 1
			) topGd
				ON gd.intGLDetailId = topGd.intGLDetailId
			CROSS APPLY dbo.fnGetDebit(@dblDiff) Debit
			CROSS APPLY dbo.fnGetCredit(@dblDiff) Credit
	END 

	SET @strPreviousTransactionId = @strTransactionId

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

IF EXISTS (SELECT TOP 1 1 FROM @GLEntries)
BEGIN
	--PRINT 'Last GL Book Entries'
	EXEC dbo.uspGLBookEntries @GLEntries, 1
END