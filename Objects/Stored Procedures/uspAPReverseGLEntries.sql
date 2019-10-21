CREATE PROCEDURE [dbo].[uspAPReverseGLEntries]
		@transactionIds		NVARCHAR(MAX)
		,@transactionType	NVARCHAR(50)
		,@dtmDateReverse	DATETIME = NULL 
		,@intUserId			INT
		,@setUnposted		BIT = 1
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

--=====================================================================================================================================
-- 	DECLARATION 
---------------------------------------------------------------------------------------------------------------------------------------
-- Local variables 
CREATE TABLE #tmpTransacions (
	[intTransactionId] [int] PRIMARY KEY,
	UNIQUE (intTransactionId)
);
INSERT INTO #tmpTransacions SELECT [intID] AS intTransactionId FROM [dbo].fnGetRowsFromDelimitedValues(@transactionIds)

DECLARE @strBatchId AS NVARCHAR(40)
EXEC uspSMGetStartingNumber 3, @strBatchId OUT

DECLARE @GLEntries AS RecapTableType
--=====================================================================================================================================
-- 	INITIALIZATION 
---------------------------------------------------------------------------------------------------------------------------------------

--Retrieve the transaction ids

--=====================================================================================================================================
-- 	REVERSE THE G/L ENTRIES
---------------------------------------------------------------------------------------------------------------------------------------

INSERT INTO @GLEntries(
		[strTransactionId]
		,[intTransactionId]
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
		,[intTransactionId]
		,dtmDate = ISNULL(@dtmDateReverse, [dtmDate]) -- If date is provided, use date reverse as the date for unposting the transaction.
		,@strBatchId--[strBatchId]
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
WHERE	intTransactionId IN (SELECT intTransactionId FROM #tmpTransacions)
AND strTransactionType = @transactionType
ORDER BY intGLDetailId

EXEC uspGLBookEntries @GLEntries, 0

--=====================================================================================================================================
-- 	UPDATE THE Is Unposted Flag IN THE tblGLDetail TABLE. 
---------------------------------------------------------------------------------------------------------------------------------------
IF @setUnposted = 1
BEGIN
	UPDATE	tblGLDetail
	SET		ysnIsUnposted = 1
	WHERE	intTransactionId IN (SELECT intTransactionId FROM #tmpTransacions)
	AND strTransactionType = @transactionType
END