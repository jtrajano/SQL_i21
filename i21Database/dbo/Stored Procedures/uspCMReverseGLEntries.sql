
--=====================================================================================================================================
-- 	CREATE THE STORED PROCEDURE AFTER DELETING IT
---------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE uspCMReverseGLEntries
	@strTransactionId	NVARCHAR(40) = NULL
	,@strCode			NVARCHAR(10) = NULL
	,@dtmDateReverse	DATETIME = NULL 
	,@intUserId			INT = NULL 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

--=====================================================================================================================================
-- 	DECLARATION 
---------------------------------------------------------------------------------------------------------------------------------------

DECLARE 
	-- Local variables 
	@strBatchId AS NVARCHAR(40)

--=====================================================================================================================================
-- 	INITIALIZATION 
---------------------------------------------------------------------------------------------------------------------------------------

-- Retrieve the GL Batch Id in tblGLDetail for the transaction to Unpost/Reverse. 
SELECT	@strBatchId = MAX(strBatchId)
FROM	tblGLDetail
WHERE	strTransactionId = @strTransactionId
		AND ysnIsUnposted = 0
		AND strCode = ISNULL(@strCode, strCode)


--=====================================================================================================================================
-- 	VALIDATION 
---------------------------------------------------------------------------------------------------------------------------------------

-- None

--=====================================================================================================================================
-- 	REVERSE THE G/L ENTRIES
---------------------------------------------------------------------------------------------------------------------------------------

INSERT INTO #tmpGLDetail (
		[strTransactionId]
		,[dtmDate]
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
		,[ysnIsUnposted]
		,[intConcurrencyId]
		,[intUserId]
		,[strTransactionType]
		,[strTransactionForm]
		,[strModuleName]
		,[intEntityId]
)
SELECT	[strTransactionId]
		-- If date is provided, use date reverse as the date for unposting the transaction.
		,dtmDate = ISNULL(@dtmDateReverse, [dtmDate]) 
		,[strBatchId]
		,[intAccountId]
		,[dblDebit] = [dblCredit]		-- (Debit -> Credit)
		,[dblCredit] = [dblDebit]		-- (Debit <- Credit)
		,[dblDebitUnit] = [dblCreditUnit]	-- (Debit Unit -> Credit Unit)
		,[dblCreditUnit] = [dblDebitUnit]	-- (Debit Unit <- Credit Unit)
		,[strDescription]
		,[strCode]
		,[strReference]
		,[intCurrencyId]
		,[dblExchangeRate]
		,dtmDateEntered = GETDATE()
		,[dtmTransactionDate]
		,[strJournalLineDescription]
		,ysnIsUnposted = 1
		,[intConcurrencyId]
		,intUserId = @intUserId
		,[strTransactionType]
		,[strTransactionForm]
		,[strModuleName]
		,[intEntityId]
FROM	tblGLDetail 
WHERE	strBatchId = @strBatchId
ORDER BY intGLDetailId

--=====================================================================================================================================
-- 	UPDATE THE Is Unposted Flag IN THE tblGLDetail TABLE. 
---------------------------------------------------------------------------------------------------------------------------------------
UPDATE	tblGLDetail
SET		ysnIsUnposted = 1
WHERE	strTransactionId = @strTransactionId

--=====================================================================================================================================
-- 	EXIT ROUTINES
---------------------------------------------------------------------------------------------------------------------------------------

Exit_ReverseGLEntries:
-- Clean up. Remove any disposable temporary tables here.
-- None