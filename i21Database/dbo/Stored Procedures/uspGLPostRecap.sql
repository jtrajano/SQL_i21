CREATE PROCEDURE [dbo].[uspGLPostRecap]
	@RecapTable RecapTableType READONLY 
	,@intEntityUserSecurityId AS INT = NULL
	,@ysnBatch BIT = 0
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
--SET ANSI_WARNINGS OFF

DECLARE @strTransactionId NVARCHAR(50), @strBatchId NVARCHAR(50)
SELECT TOP 1 @strBatchId = strBatchId, @strTransactionId = strTransactionId FROM @RecapTable 

IF (@ysnBatch = 0)
BEGIN
	DELETE FROM tblGLPostRecap WHERE strBatchId IN (SELECT strBatchId FROM @RecapTable)
	DELETE FROM tblGLPostRecap WHERE strTransactionId IN (SELECT strTransactionId FROM @RecapTable)
	DELETE FROM tblGLPostRecap WHERE dtmDateEntered < convert(nvarchar(20), GETDATE(), 101)
END

IF NOT EXISTS (SELECT TOP 1 1 FROM @RecapTable)
BEGIN 
	-- G/L entries are expected. Cannot continue because it is missing.
	RAISERROR('G/L entries are expected. Cannot continue because it is missing.', 11, 1)
	GOTO _Exit
END


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
		,[intCurrencyExchangeRateTypeId]
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
		,[intCurrencyId] = udtRecap.intCurrencyId
		,[intCurrencyExchangeRateTypeId] = udtRecap.[intCurrencyExchangeRateTypeId]
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
		,[strRateType] =  Rate.strCurrencyExchangeRateType
		,[intConcurrencyId] = 1
FROM	@RecapTable udtRecap INNER JOIN tblGLAccount gl
			ON udtRecap.intAccountId = gl.intAccountId
		LEFT JOIN tblSMCurrencyExchangeRateType Rate on udtRecap.intCurrencyExchangeRateTypeId = Rate.intCurrencyExchangeRateTypeId
		INNER JOIN tblGLAccountGroup gg
			ON gg.intAccountGroupId = gl.intAccountGroupId


_Exit: 