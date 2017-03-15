------------------------------------------------------------------------------------------------------------------------------------
-- Open the fiscal year periods
------------------------------------------------------------------------------------------------------------------------------------
SELECT	* 
INTO	tblGLFiscalYearPeriodOriginal
FROM	tblGLFiscalYearPeriod

UPDATE tblGLFiscalYearPeriod
SET ysnOpen = 1

GO

IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpRegenerateGLEntries')) 
	DROP TABLE #tmpRegenerateGLEntries
GO

DECLARE @GLEntries AS RecapTableType 
		,@strBatchId AS NVARCHAR(50)
		,@intTransactionId AS INT
		,@strTransactionId AS NVARCHAR(50)
		,@intUserId AS INT 
		,@ysnPost AS BIT

SELECT	DISTINCT 
		InvTrans.strBatchId
		,InvTrans.intTransactionId
		,InvTrans.strTransactionId
		,InvTrans.intCreatedUserId
		,InvTrans.ysnIsUnposted
INTO	#tmpRegenerateGLEntries
FROM	dbo.tblICInventoryTransaction InvTrans LEFT JOIN dbo.tblGLDetail GL
			ON GL.intJournalLineNo = InvTrans.intInventoryTransactionId 
			AND GL.intTransactionId = InvTrans.intTransactionId
			AND GL.strTransactionId = InvTrans.strTransactionId
WHERE	GL.intGLDetailId IS NULL 	

WHILE EXISTS (SELECT TOP 1 1 FROM #tmpRegenerateGLEntries)
BEGIN 
	SELECT TOP 1 
			@strBatchId = strBatchId
			,@intTransactionId = intTransactionId
			,@strTransactionId = strTransactionId
			,@intUserId = intCreatedUserId
			,@ysnPost = CASE WHEN ysnIsUnposted = 1 THEN 0 ELSE 1 END
	FROM	#tmpRegenerateGLEntries

	PRINT 'Fixing GL Entries in ' + @strTransactionId

	-- Call the post routine 
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
	-----------------------------------------
	-- Generate the g/l entries
	-----------------------------------------
	EXEC [dbo].[uspICCreateGLEntries]
		@strBatchId = @strBatchId
		,@AccountCategory_ContraInventory = 'Inventory Adjustment'
		,@intUserId = @intUserId
		,@strGLDescription = NULL 

	EXEC dbo.uspGLBookEntries @GLEntries, @ysnPost 

	DELETE FROM #tmpRegenerateGLEntries
	WHERE	@strBatchId = strBatchId
			AND @intTransactionId = intTransactionId
			AND @strTransactionId = strTransactionId
END

GO

------------------------------------------------------------------------------------------------------------------------------------
-- Re-close the fiscal year periods
------------------------------------------------------------------------------------------------------------------------------------
UPDATE FYPeriod
SET ysnOpen = FYPeriodOriginal.ysnOpen
FROM	tblGLFiscalYearPeriod FYPeriod INNER JOIN tblGLFiscalYearPeriodOriginal FYPeriodOriginal
			ON FYPeriod.intGLFiscalYearPeriodId = FYPeriodOriginal.intGLFiscalYearPeriodId

DROP TABLE tblGLFiscalYearPeriodOriginal

GO