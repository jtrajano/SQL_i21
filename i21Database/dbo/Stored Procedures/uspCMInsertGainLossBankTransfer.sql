﻿CREATE PROCEDURE [dbo].[uspCMInsertGainLossBankTransfer]
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
			,[dblDebit]				= case when @gainLoss < 0 then @gainLoss * -1  else 0 end
			,[dblCredit]			= case when @gainLoss >= 0 then @gainLoss  else 0 end--   A.dblAmount * ISNULL(A.dblRate,1)
			,[dblDebitForeign]		= 0
			,[dblCreditForeign]		= 0
			,[dblDebitUnit]			= 0
			,[dblCreditUnit]		= 0
			,[strDescription]		= @strDescription --'Gain / Loss on Multicurrency Bank Transfer'
			,[strCode]				= A.strCode
			,[strReference]			= A.strReference
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

