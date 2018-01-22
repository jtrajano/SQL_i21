CREATE PROC [dbo].[uspRKM2MGLPost] 
		@intM2MInquiryId INT
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

DECLARE @intCommodityId int
DECLARE @dtmCurrenctGLPostDate DATETIME
DECLARE @dtmPreviousGLPostDate DATETIME
DECLARE @dtmGLReverseDate DATETIME
DECLARE @dtmPrviousGLReverseDate DATETIME
SELECT @intCommodityId = intCommodityId,@dtmCurrenctGLPostDate=dtmGLPostDate,@dtmGLReverseDate=dtmGLReverseDate FROM tblRKM2MInquiry where intM2MInquiryId=@intM2MInquiryId
SELECT TOP 1 @dtmPreviousGLPostDate=dtmGLPostDate,@dtmPrviousGLReverseDate=dtmGLReverseDate  FROM tblRKM2MInquiry where ysnPost=1 and intCommodityId=@intCommodityId order by dtmGLPostDate desc

IF (@dtmGLReverseDate IS NULL)
BEGIN
RAISERROR('Please save the record before posting.',16,1)
END
SELECT @dtmCurrenctGLPostDate, @dtmPrviousGLReverseDate
IF (@dtmCurrenctGLPostDate >= @dtmPrviousGLReverseDate)
BEGIN

RAISERROR('Current date cannot lessthan the previous post date',16,1)
END


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
	SELECT [dtmDate]
		,@batchId
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
		,'RK'
		,[strReference]  
		,[intEntityId]
		,[intUserId]  
		,[intSourceLocationId]
		,[intSourceUOMId]
	FROM tblRKM2MPostRecap
	WHERE intM2MInquiryId = @intM2MInquiryId

	EXEC dbo.uspGLBookEntries @GLEntries,1 --@ysnPost

	UPDATE tblRKM2MPostRecap SET ysnIsUnposted=1,strBatchId=@strBatchId WHERE intM2MInquiryId = @intM2MInquiryId
	UPDATE tblRKM2MInquiry SET ysnPost=1,dtmPostedDateTime=getdate(),strBatchId=@batchId WHERE intM2MInquiryId = @intM2MInquiryId

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