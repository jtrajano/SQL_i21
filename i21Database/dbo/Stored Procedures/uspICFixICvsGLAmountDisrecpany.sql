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
	,[ic amount] = round(dbo.fnMultiply(ic.dblQty, ic.dblCost) + ic.dblValue, 2)
	,gl.[gl amount]
	,[diff] = round(dbo.fnMultiply(ic.dblQty, ic.dblCost) + ic.dblValue, 2) - ISNULL(gl.[gl amount], 0)
FROM	
	tblICInventoryTransaction ic INNER JOIN tblICInventoryTransactionType ty
		ON ic.intTransactionTypeId = ty.intTransactionTypeId
	OUTER APPLY (
		SELECT 
			--'GL Only'
			[gl amount] = ISNULL(SUM(ROUND(dblDebit - dblCredit, 2)), 0) 
		FROM	
			tblGLDetail gd INNER JOIN tblGLAccount ga
				ON gd.intAccountId = ga.intAccountId
			INNER JOIN tblGLAccountSegmentMapping gs
				ON gs.intAccountId = ga.intAccountId
			INNER JOIN tblGLAccountSegment gm
				ON gm.intAccountSegmentId = gs.intAccountSegmentId
			INNER JOIN tblGLAccountCategory ac 
				ON ac.intAccountCategoryId = gm.intAccountCategoryId 
			INNER JOIN tblGLAccountStructure gst
				ON gm.intAccountStructureId = gst.intAccountStructureId

		WHERE 
			gd.strTransactionId = ic.strTransactionId
			AND gd.strBatchId = ic.strBatchId
			AND gd.intJournalLineNo = ic.intInventoryTransactionId
			AND gd.ysnIsUnposted = 0 

			AND ac.strAccountCategory IN ('Inventory', 'Inventory In-Transit')			
			and gst.strType = 'Primary'
	) gl 
WHERE	
	ty.strName = @strType
	AND ic.ysnIsUnposted = 0 
	AND	round(dbo.fnMultiply(ic.dblQty, ic.dblCost) + ic.dblValue, 2) <> isnull(gl.[gl amount], 0) 
ORDER BY 
	ic.intInventoryTransactionId

--select 'debug @discrepancyList', * from @discrepancyList 

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
	PRINT 'Transaction Id: ' + @strTransactionId

	-- Check if the fiscal year period is open
	IF dbo.isOpenAccountingDate(@dtmDate) = 1
	BEGIN 
		print 'fyp is open'
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
			PRINT 'different transaction'
			IF EXISTS (SELECT TOP 1 1 FROM @GLEntries)
			BEGIN
				--select 'debug discrepancy fix 1', * from @GLEntries
				EXEC dbo.uspGLBookEntries @GLEntries, 1				
			END

			DELETE FROM @GLEntries
		END 

		print 'fyp is closed' 
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
	PRINT 'Last GL Book Entries'
	--select 'debug discrepancy fix 2', * from @GLEntries
	EXEC dbo.uspGLBookEntries @GLEntries, 1
END