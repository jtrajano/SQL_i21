CREATE PROCEDURE [dbo].[uspCMInsertGainLossBankTransfer]
@intDefaultCurrencyId INT,
@strDescription nvarchar(300),
@intBankTransferTypeId INT,
@intGLAccountIdTo INT,
@intRealizedGainAccountId INT = NULL

AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @strErrorMessage NVARCHAR(100)

	IF @intRealizedGainAccountId is NULL
	BEGIN
		SELECT TOP 1 @intRealizedGainAccountId= intCashManagementRealizedId FROM tblSMMultiCurrency
		IF @intRealizedGainAccountId is NULL
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
			,[dblDebit]				= Debit.GainLoss
			,[dblCredit]			= Credit.GainLoss
			,[dblDebitForeign]		= Debit.GainLoss
			,[dblCreditForeign]		= Credit.GainLoss
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
				SELECT dblGainLossFrom *-1 gainLoss, strReferenceFrom FROM tblCMBankTransfer WHERE strTransactionId = A.strTransactionId AND dblGainLossFrom <> 0
			)BankFrom
			CROSS APPLY (
				SELECT TOP 1 strDescription FROM tblGLAccount WHERE intAccountId = @intRealizedGainAccountId
			)GL
			CROSS APPLY (SELECT case when BankFrom.gainLoss < 0 then BankFrom.gainLoss * -1  else 0 end GainLoss ) Debit
			CROSS APPLY (SELECT case when BankFrom.gainLoss >= 0 then BankFrom.gainLoss  else 0 end GainLoss) Credit
			UNION
			SELECT	TOP 1
			 [strTransactionId]		= A.strTransactionId
			,[intTransactionId]		= A.intTransactionId
			,[dtmDate]				= A.dtmDate
			,[strBatchId]			= A.strBatchId
			,[intAccountId]			= @intRealizedGainAccountId
			,[dblDebit]				= case when BankTo.intBankTransactionTypeId = 5 THEN Debit.GainLoss ELSE Credit.GainLoss END
			,[dblCredit]			= case when BankTo.intBankTransactionTypeId = 5 THEN Credit.GainLoss ELSE Debit.GainLoss END
			,[dblDebitForeign]		= case when BankTo.intBankTransactionTypeId = 5 THEN Debit.GainLoss ELSE Credit.GainLoss END
			,[dblCreditForeign]		= case when BankTo.intBankTransactionTypeId = 5 THEN Credit.GainLoss ELSE Debit.GainLoss END
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
				SELECT dblGainLossTo gainLoss, strReferenceTo, intBankTransactionTypeId FROM tblCMBankTransfer WHERE strTransactionId = A.strTransactionId AND dblGainLossTo <> 0
			)BankTo
			CROSS APPLY (
				SELECT TOP 1 strDescription FROM tblGLAccount WHERE intAccountId = @intRealizedGainAccountId
			)GL
			CROSS APPLY (SELECT case when BankTo.gainLoss < 0 then BankTo.gainLoss * -1  else 0 end GainLoss ) Debit
			CROSS APPLY (SELECT case when BankTo.gainLoss >= 0 then BankTo.gainLoss  else 0 end GainLoss) Credit	
	END
	GOTO _end
	_raiserror:
	RAISERROR(@strErrorMessage,16,1 )
	_end:
END
GO