CREATE PROCEDURE uspGLPostRecap
	@RecapTable RecapTableType READONLY 
	,@intEntityUserSecurityId AS INT = NULL 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
--SET ANSI_WARNINGS OFF

DECLARE @intTransactionId INT , @strTransactionId NVARCHAR(50)
SELECT TOP 1 @intTransactionId = intTransactionId, 
	@strTransactionId = strTransactionId FROM @RecapTable 
-- DELETE OLD RECAP DATA (IF IT EXISTS)
DELETE	FROM tblGLPostRecap 
WHERE	strTransactionId = @strTransactionId
		AND intTransactionId = @intTransactionId

-- DELETE Results 1 DAYS OLDER	
DELETE	FROM tblGLPostRecap 
WHERE	dbo.fnDateLessThan(dtmDateEntered, GETDATE()) = 1
		AND intEntityId = @intEntityUserSecurityId;

IF NOT EXISTS (SELECT TOP 1 1 FROM @RecapTable)
BEGIN 
	-- G/L entries are expected. Cannot continue because it is missing.
	RAISERROR(50032, 11, 1)
	GOTO _Exit
END

-- INSERT THE RECAP DATA. 
-- THE RECAP DATA WILL BE STORED IN A PERMANENT TABLE SO THAT WE CAN QUERY IT LATER USING A BUFFERED STORE. 
INSERT INTO tblGLPostRecap (
		[dtmDate]
		,[strBatchId]
		,[intAccountId]
		,[strAccountId]
		,[strAccountGroup]
		,[dblDebit]
		,[dblCredit]
		,[dblDebitForeign]
		,[dblCreditForeign]
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
		,[strRateType]
		,[intConcurrencyId]
)
-- RETRIEVE THE DATA FROM THE TABLE VARIABLE. 
SELECT	[dtmDate]
		,[strBatchId]
		,[intAccountId] = gl.intAccountId
		,[strAccountId] = gl.strAccountId
		,[strAccountGroup] = gg.strAccountGroup
		,[dblDebit]				= CASE	WHEN [dblCredit] < 0 THEN ABS([dblCredit])
										WHEN [dblDebit] < 0 THEN 0
										ELSE [dblDebit] END 
		,[dblCredit]			= CASE	WHEN [dblDebit] < 0 THEN ABS([dblDebit])
										WHEN [dblCredit] < 0 THEN 0
										ELSE [dblCredit] END	
		,[dblDebitForeign]		= CASE	WHEN [dblCreditForeign] < 0 THEN ABS([dblCreditForeign])
										WHEN [dblDebitForeign] < 0 THEN 0
										ELSE [dblDebitForeign] END 
								
		,[dblCreditForeign]		= CASE	WHEN [dblDebitForeign] < 0 THEN ABS([dblDebitForeign])
										WHEN [dblCreditForeign] < 0 THEN 0
										ELSE [dblCreditForeign] END
		,[dblDebitUnit]			= ISNULL(udtRecap.[dblDebitUnit], 0)
		,[dblCreditUnit]		= ISNULL(udtRecap.[dblCreditUnit], 0)
		,[strDescription] = udtRecap.strDescription
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
		,[strRateType]
		,[intConcurrencyId] = 1
FROM	@RecapTable udtRecap INNER JOIN tblGLAccount gl
			ON udtRecap.intAccountId = gl.intAccountId
		INNER JOIN tblGLAccountGroup gg
			ON gg.intAccountGroupId = gl.intAccountGroupId


_Exit: 