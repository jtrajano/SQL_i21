CREATE PROCEDURE [dbo].[uspCMInsertGainLossBankTransfer]
@intDefaultCurrencyId INT,
@strDescription nvarchar(300),
@intBankTransferTypeId INT,
@intGLAccountIdTo INT,
@strTransactionId NVARCHAR(40),
@intRealizedGainAccountId INT = NULL

AS
BEGIN
	SET NOCOUNT ON;
 DECLARE @strErrorMessage NVARCHAR(100)  

IF EXISTS (
    SELECT 1 FROM tblCMBankTransfer
    WHERE @intDefaultCurrencyId = intCurrencyIdAmountFrom AND @intDefaultCurrencyId = intCurrencyIdAmountTo 
    AND strTransactionId =@strTransactionId)
RETURN -- EXIT WHEN CURRENCIES ARE FUNCTIONAL

	IF @intRealizedGainAccountId is NULL
	BEGIN
		SELECT TOP 1 @intRealizedGainAccountId= intCashManagementRealizedId FROM tblSMMultiCurrency
		IF ISNULL(@intRealizedGainAccountId,0) = 0
		BEGIN
			RAISERROR ('Cash Management Realized Gain/Loss account was not set in Company Configuration- Multicurrency screen.',11,1)
			GOTO _end
		END
	END

	DECLARE @gainLoss DECIMAL(18,6),@gainLossForeign DECIMAL(18,6)
	SELECT @gainLoss= sum(dblDebit - dblCredit) FROM #tmpGLDetail -- WHERE intTransactionId = @intTransactionId
	SELECT @gainLossForeign= sum(dblDebitForeign - dblCreditForeign) FROM #tmpGLDetail -- WHERE intTransactionId = @intTransactionId
	IF @gainLoss <> 0
	BEGIN
			INSERT INTO #tmpGLDetail (
			[strTransactionId]
			,[intTransactionId]
			,[dtmDate]
			,[strBatchId]
			,[intAccountId]
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
			,[intAccountId]			= @intRealizedGainAccountId
			,[dblDebit]				= case when BankFrom.gainLoss < 0 then BankFrom.gainLoss * -1  else 0 end
			,[dblCredit]			= case when BankFrom.gainLoss >= 0 then BankFrom.gainLoss  else 0 end--   A.dblAmount * ISNULL(A.dblRate,1)
			,[dblDebitForeign]		= case when BankFrom.gainLoss < 0 then BankFrom.gainLoss * -1  else 0 end
			,[dblCreditForeign]		= case when BankFrom.gainLoss >= 0 then BankFrom.gainLoss  else 0 end
			,[dblDebitUnit]			= 0
			,[dblCreditUnit]		= 0
			,[strDescription]		= @strDescription --'Gain / Loss on Multicurrency Bank Transfer'
			,[strCode]				= A.strCode
			,[strReference]			= BankFrom.strReferenceFrom
			,[intCurrencyId]		= @intDefaultCurrencyId
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
			CROSS APPLY(
				SELECT dblGainLossFrom * case when @intBankTransferTypeId <> 5 THEN -1 ELSE 1 END
				
				gainLoss, strReferenceFrom FROM tblCMBankTransfer WHERE strTransactionId = A.strTransactionId AND dblGainLossFrom <> 0
			)BankFrom
			CROSS APPLY (
				SELECT TOP 1 strDescription FROM tblGLAccount WHERE intAccountId = @intRealizedGainAccountId
			)GL
			UNION
			SELECT	TOP 1
			 [strTransactionId]		= A.strTransactionId
			,[intTransactionId]		= A.intTransactionId
			,[dtmDate]				= A.dtmDate
			,[strBatchId]			= A.strBatchId
			,[intAccountId]			= @intRealizedGainAccountId
			,[dblDebit]				= case when BankTo.gainLoss < 0 then BankTo.gainLoss * -1  else 0 end
			,[dblCredit]			= case when BankTo.gainLoss >= 0 then BankTo.gainLoss  else 0 end--   A.dblAmount * ISNULL(A.dblRate,1)
			,[dblDebitForeign]		= case when BankTo.gainLoss < 0 then BankTo.gainLoss * -1  else 0 end
			,[dblCreditForeign]		= case when BankTo.gainLoss >= 0 then BankTo.gainLoss  else 0 end
			,[dblDebitUnit]			= 0
			,[dblCreditUnit]		= 0
			,[strDescription]		= @strDescription --'Gain / Loss on Multicurrency Bank Transfer'
			,[strCode]				= A.strCode
			,[strReference]			= BankTo.strReferenceTo
			,[intCurrencyId]		= @intDefaultCurrencyId
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
			CROSS APPLY(
				SELECT dblGainLossTo * CASE WHEN @intBankTransferTypeId <> 5 THEN 1 ELSE -1 END gainLoss, strReferenceTo FROM tblCMBankTransfer WHERE strTransactionId = A.strTransactionId AND dblGainLossTo <> 0
			)BankTo
			CROSS APPLY (
				SELECT TOP 1 strDescription FROM tblGLAccount WHERE intAccountId = @intRealizedGainAccountId
			)GL
	END
	GOTO _end
	_raiserror:
	RAISERROR(@strErrorMessage,16,1 )
	_end:
END
GO