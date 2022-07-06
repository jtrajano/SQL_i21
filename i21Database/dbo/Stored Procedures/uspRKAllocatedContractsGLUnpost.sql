CREATE PROCEDURE [dbo].[uspRKAllocatedContractsGLUnpost]  
	@intAllocatedContractsGainOrLossHeaderId INT
	,@intUserId INT
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY
	DECLARE @GLEntries AS RecapTableType
	DECLARE @batchId NVARCHAR(100)
	DECLARE @strBatchId NVARCHAR(100)
	DECLARE @ErrMsg NVARCHAR(Max)


BEGIN TRANSACTION
	IF (@batchId IS NULL)
	BEGIN
		EXEC uspSMGetStartingNumber 3, @batchId OUT
	END

	SET @strBatchId = @batchId

	INSERT INTO @GLEntries (
		 [dtmDate]
		,[strBatchId]
		,[intAccountId]
		,[dblDebit]
		,[dblCredit]
		,[dblDebitUnit]
		,[dblCreditUnit]
		,[strDescription]
		,[intCurrencyId]
		,[dtmTransactionDate]
		,[strTransactionId]
		,[intTransactionId]
		,[strTransactionType]
		,[strTransactionForm]
		,[strModuleName]
		,[intConcurrencyId]
		,[dblExchangeRate]
		,[dtmDateEntered]
		,[ysnIsUnposted]
		,[strCode]
		,[strReference]  
		,[intEntityId]
		,[intUserId]      
		,[intSourceLocationId]
		,[intSourceUOMId]
		)
	SELECT [dtmPostDate]
		,@batchId
		,[intAccountId]
		,[dblCredit] as [dblDebit]
		,[dblDebit] as [dblCredit]
		,[dblCreditUnit] as [dblDebitUnit]
		,[dblDebitUnit] as [dblCreditUnit]
		,[strAccountDescription]
		,[intCurrencyId]
		,[dtmTransactionDate]
		,[strTransactionId]
		,[intTransactionId]
		,'Allocated Contracts Gain or Loss' --[strTransactionType]
		,[strTransactionForm]
		,[strModuleName]
		,[intConcurrencyId]
		,[dblExchangeRate]
		,GETDATE() --[dtmDateEntered]
		,[ysnIsUnposted]
		,[strCode]
		,[strReference]  
		,[intEntityId]
		,[intUserId]  
		,[intSourceLocationId]
		,[intSourceUOMId]
	FROM tblRKAllocatedContractsPostRecap
	WHERE intAllocatedContractsGainOrLossHeaderId = @intAllocatedContractsGainOrLossHeaderId

	EXEC dbo.uspGLBookEntries @GLEntries,0 --@ysnPost


	DECLARE @strOldBatchId NVARCHAR(50),
			@strOldReversalBatchId NVARCHAR(50)

	SELECT @strOldBatchId = strBatchId, @strOldReversalBatchId = strReversalBatchId FROM tblRKAllocatedContractsPostRecap WHERE intAllocatedContractsGainOrLossHeaderId = @intAllocatedContractsGainOrLossHeaderId


	--Upost reversal transaction
	
	DECLARE @ReverseGLEntries AS RecapTableType,
			@strReversalBatchId AS NVARCHAR(100)
	EXEC uspSMGetStartingNumber 3, @strReversalBatchId OUT

	INSERT INTO @ReverseGLEntries (
		 [dtmDate]
		,[strBatchId]
		,[intAccountId]
		,[dblDebit]
		,[dblCredit]
		,[dblDebitUnit]
		,[dblCreditUnit]
		,[strDescription]
		,[intCurrencyId]
		,[dtmTransactionDate]
		,[strTransactionId]
		,[intTransactionId]
		,[strTransactionType]
		,[strTransactionForm]
		,[strModuleName]
		,[intConcurrencyId]
		,[dblExchangeRate]
		,[dtmDateEntered]
		,[ysnIsUnposted]
		,[strCode]
		,[strReference]  
		,[intEntityId]
		,[intUserId]      
		,[intSourceLocationId]
		,[intSourceUOMId]
		)
	SELECT [dtmDate]
		,@strReversalBatchId
		,[intAccountId]
		,[dblCredit] 
		,[dblDebit]
		,[dblCreditUnit]
		,[dblDebitUnit]
		,[strDescription]
		,[intCurrencyId]
		,[dtmTransactionDate]
		,[strTransactionId]
		,[intTransactionId]
		,[strTransactionType]
		,[strTransactionForm]
		,[strModuleName]
		,[intConcurrencyId]
		,[dblExchangeRate]
		,GETDATE() --[dtmDateEntered]
		,1
		,[strCode]
		,[strReference]  
		,[intEntityId]
		,[intUserId]  
		,[intSourceLocationId]
		,[intSourceUOMId]
	FROM tblGLDetail
	WHERE strBatchId = @strOldReversalBatchId

	EXEC dbo.uspGLBookEntries @ReverseGLEntries,0


	UPDATE	tblGLDetail SET	ysnIsUnposted = 1 WHERE	strBatchId IN( @strOldBatchId ,@strOldReversalBatchId)
	UPDATE tblRKAllocatedContractsPostRecap SET ysnIsUnposted=0,strBatchId=null WHERE intAllocatedContractsGainOrLossHeaderId = @intAllocatedContractsGainOrLossHeaderId
	UPDATE tblRKAllocatedContractsGainOrLossHeader SET ysnPosted=0,dtmPostDate=null,strBatchId=null,dtmUnpostDate=getdate() WHERE intAllocatedContractsGainOrLossHeaderId = @intAllocatedContractsGainOrLossHeaderId


	EXEC uspSMAuditLog 
		   @keyValue = @intAllocatedContractsGainOrLossHeaderId       -- Primary Key Value of the Match Derivatives. 
		   ,@screenName = 'RiskManagement.view.AllocatedContractsGainOrLoss'        -- Screen Namespace
		   ,@entityId = @intUserId     -- Entity Id.
		   ,@actionType = 'Unposted'       -- Action Type
		   ,@changeDescription = ''     -- Description
		   ,@fromValue = ''          -- Previous Value
		   ,@toValue = ''           -- New Value

	COMMIT TRAN	
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	IF XACT_STATE() != 0
		ROLLBACK TRANSACTION
	IF @ErrMsg != ''
	BEGIN
		RAISERROR (
				@ErrMsg
				,16
				,1
				,'WITH NOWAIT'
				)
	END
END CATCH

