CREATE PROCEDURE [dbo].[uspCMInsertGainLossBankTransfer]
@strDescription nvarchar(300)
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @intAccountsPayableRealizedId INT
	SELECT TOP 1 @intAccountsPayableRealizedId= intAccountsPayableRealizedId FROM tblSMMultiCurrency
	IF @intAccountsPayableRealizedId is NULL
	BEGIN
		RAISERROR ('Accounts Payable Realized Gain/Loss account was not set in Company Configuration screen.',11,1)
		RETURN
	END
	DECLARE @gainLoss DECIMAL(18,6)
	SELECT @gainLoss= sum(dblDebit - dblCredit) FROM #tmpGLDetail -- WHERE intTransactionId = @intTransactionId
	INSERT INTO #tmpGLDetail (
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
	SELECT	TOP 1
			 [strTransactionId]		= A.strTransactionId
			,[intTransactionId]		= A.intTransactionId
			,[dtmDate]				= A.dtmDate
			,[strBatchId]			= A.strBatchId
			,[intAccountId]			= @intAccountsPayableRealizedId
			,[dblDebit]				= case when @gainLoss < 0 then @gainLoss * -1  else 0 end
			,[dblCredit]			= case when @gainLoss >= 0 then @gainLoss  else 0 end--   A.dblAmount * ISNULL(A.dblRate,1)
			,[dblDebitUnit]			= 0
			,[dblCreditUnit]		= 0
			,[strDescription]		= @strDescription --'Gain / Loss on Multicurrency Bank Transfer'
			,[strCode]				= A.strCode
			,[strReference]			= A.strReference
			,[intCurrencyId]		= A.intCurrencyId
			,[dblExchangeRate]		= 1
			,[dtmDateEntered]		= GETDATE()
			,[dtmTransactionDate]	= A.dtmDate
			,[strJournalLineDescription] = GL.strDescription
			,[ysnIsUnposted]		= 0 
			,[intConcurrencyId]		= 1
			,[intUserId]			= A.[intUserId]
			,[strTransactionType]	= A.[strTransactionType]
			,[strTransactionForm]	= A.[strTransactionForm]
			,[strModuleName]		= A.[strModuleName]
			,[intEntityId]			= A.intEntityId
	FROM	#tmpGLDetail A
	CROSS APPLY (
		SELECT TOP 1 strDescription FROM tblGLAccount WHERE intAccountId = @intAccountsPayableRealizedId
	)GL
END
GO

