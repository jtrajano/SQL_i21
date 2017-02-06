CREATE PROCEDURE uspGLPostRecapOld
	@RecapTable RecapTableType READONLY 
	,@intTransactionId AS INT
	,@strTransactionId AS NVARCHAR(50)
	,@strCode AS NVARCHAR(50)
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
--SET ANSI_WARNINGS OFF

-- DELETE OLD RECAP DATA (IF IT EXISTS)
DELETE	FROM tblGLDetailRecap 
WHERE	strTransactionId = @strTransactionId
		AND intTransactionId = @intTransactionId

IF NOT EXISTS (SELECT TOP 1 1 FROM @RecapTable)
BEGIN 
	-- G/L entries are expected. Cannot continue because it is missing.
	RAISERROR(50032, 11, 1)
	GOTO _Exit
END

-- INSERT THE RECAP DATA. 
-- THE RECAP DATA WILL BE STORED IN A PERMANENT TABLE SO THAT WE CAN QUERY IT LATER USING A BUFFERED STORE. 
INSERT INTO tblGLDetailRecap (
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
)
-- RETRIEVE THE DATA FROM THE TABLE VARIABLE. 
SELECT	[dtmDate]
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
FROM	@RecapTable

_Exit: 