
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
SELECT	@strBatchId = MAX(strBatchID)
FROM	tblGLDetail
WHERE	strTransactionID = @strTransactionId
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
		,[strAccountGroup]
		,[dblDebit]
		,[dblCredit]
		,[dblDebitUnit]
		,[dblCreditUnit]
		,[strDescription]
		,[strCode]
		,[strReference]
		,[strJobId]
		,[intCurrencyId]
		,[dblExchangeRate]
		,[dtmDateEntered]
		,[dtmTransactionDate]
		,[strProductId]
		,[strWarehouseId]
		,[strNum]
		,[strCompanyName]
		,[strBillInvoiceNumber]
		,[strJournalLineDescription]
		,[ysnIsUnposted]
		,[intConcurrencyId]
		,[intUserId]
		,[strTransactionForm]
		,[strModuleName]
		,[strUOMCode]
)
SELECT	[strTransactionID]
		,dtmDate			= ISNULL(@dtmDateReverse, [dtmDate]) -- If date is provided, use date reverse as the date for unposting the transaction.
		,[strBatchID]
		,[intAccountID]
		,[strAccountGroup]
		,dblDebit			= [dblCredit]		-- (Debit -> Credit)
		,dblCredit			= [dblDebit]		-- (Debit <- Credit)
		,dblDebitUnit		= [dblCreditUnit]	-- (Debit Unit -> Credit Unit)
		,dblCreditUnit		= [dblDebitUnit]	-- (Debit Unit <- Credit Unit)
		,[strDescription]
		,[strCode]
		,[strReference]
		,[strJobID]
		,[intCurrencyID]
		,[dblExchangeRate]
		,dtmDateEntered		= GETDATE()
		,[dtmTransactionDate]
		,[strProductID]
		,[strWarehouseID]
		,[strNum]
		,[strCompanyName]
		,[strBillInvoiceNumber]
		,[strJournalLineDescription]
		,ysnIsUnposted		= 1
		,[intConcurrencyId]
		,[intUserID]		= @intUserId
		,[strTransactionForm]
		,[strModuleName]
		,[strUOMCode]
FROM	tblGLDetail 
WHERE	strBatchID = @strBatchId
ORDER BY intGLDetailID

--=====================================================================================================================================
-- 	UPDATE THE Is Unposted Flag IN THE tblGLDetail TABLE. 
---------------------------------------------------------------------------------------------------------------------------------------
UPDATE	tblGLDetail
SET		ysnIsUnposted = 1
WHERE	strTransactionID = @strTransactionId

--=====================================================================================================================================
-- 	EXIT ROUTINES
---------------------------------------------------------------------------------------------------------------------------------------

Exit_ReverseGLEntries:
-- Clean up. Remove any disposable temporary tables here.
-- None