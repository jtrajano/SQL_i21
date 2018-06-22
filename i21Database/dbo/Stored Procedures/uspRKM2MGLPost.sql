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

IF (convert(datetime,@dtmCurrenctGLPostDate) <= convert(datetime,@dtmPrviousGLReverseDate))
BEGIN
RAISERROR('Current date cannot lessthan the previous post date',16,1)
END

IF EXISTS(SELECT 1 FROM tblRKCompanyPreference WHERE ISNULL(intUnrealizedGainOnBasisId,0) = 0)
RAISERROR('Unrealized Gain On Basis cannot be blank. Please set up the default account(s) in Company Configuration Risk Management tab.',16,1)
IF EXISTS(SELECT * FROM tblRKCompanyPreference WHERE ISNULL(intUnrealizedGainOnFuturesId,0) = 0)
RAISERROR('Unrealized Gain On Futures cannot be blank. Please set up the default account(s) in Company Configuration Risk Management tab.',16,1)
IF EXISTS(SELECT * FROM tblRKCompanyPreference WHERE ISNULL(intUnrealizedGainOnCashId,0) = 0)
RAISERROR('Unrealized Gain On Cash cannot be blank. Please set up the default account(s) in Company Configuration Risk Management tab.',16,1)
IF EXISTS(SELECT * FROM tblRKCompanyPreference WHERE ISNULL(intUnrealizedGainOnRatioId,0) = 0)
RAISERROR('Unrealized Gain On Ratio cannot be blank. Please set up the default account(s) in Company Configuration Risk Management tab.',16,1)
IF EXISTS(SELECT * FROM tblRKCompanyPreference WHERE ISNULL(intUnrealizedLossOnBasisId,0) = 0)
RAISERROR('Unrealized Loss On Basis cannot be blank. Please set up the default account(s) in Company Configuration Risk Management tab.',16,1)
IF EXISTS(SELECT * FROM tblRKCompanyPreference WHERE ISNULL(intUnrealizedLossOnFuturesId,0) = 0)
RAISERROR('Unrealized Loss On Futures cannot be blank. Please set up the default account(s) in Company Configuration Risk Management tab.',16,1)
IF EXISTS(SELECT * FROM tblRKCompanyPreference WHERE ISNULL(intUnrealizedLossOnCashId,0) = 0)
RAISERROR('Unrealized Loss On Cash cannot be blank. Please set up the default account(s) in Company Configuration Risk Management tab.',16,1)
IF EXISTS(SELECT * FROM tblRKCompanyPreference WHERE ISNULL(intUnrealizedLossOnRatioId,0) = 0)
RAISERROR('Unrealized Loss On Ratio cannot be blank. Please set up the default account(s) in Company Configuration Risk Management tab.',16,1)
IF EXISTS(SELECT * FROM tblRKCompanyPreference WHERE ISNULL(intUnrealizedGainOnInventoryBasisIOSId,0) = 0)
RAISERROR('Unrealized Gain On Inventory Basis IOS cannot be blank. Please set up the default account(s) in Company Configuration Risk Management tab.',16,1)
IF EXISTS(SELECT * FROM tblRKCompanyPreference WHERE ISNULL(intUnrealizedGainOnInventoryFuturesIOSId,0) = 0)
RAISERROR('Unrealized Gain On Inventory Futures IOS cannot be blank. Please set up the default account(s) in Company Configuration Risk Management tab.',16,1)
IF EXISTS(SELECT * FROM tblRKCompanyPreference WHERE ISNULL(intUnrealizedGainOnInventoryCashIOSId,0) = 0)
RAISERROR('Unrealized Gain On Inventory Cash IOS cannot be blank. Please set up the default account(s) in Company Configuration Risk Management tab.',16,1)
IF EXISTS(SELECT * FROM tblRKCompanyPreference WHERE ISNULL(intUnrealizedGainOnInventoryRatioIOSId,0) = 0)
RAISERROR('Unrealized Gain On Inventory Ratio IOS cannot be blank. Please set up the default account(s) in Company Configuration Risk Management tab.',16,1)
IF EXISTS(SELECT * FROM tblRKCompanyPreference WHERE ISNULL(intUnrealizedLossOnInventoryBasisIOSId,0) = 0)
RAISERROR('Unrealized Loss On Inventory Basis IOS cannot be blank. Please set up the default account(s) in Company Configuration Risk Management tab.',16,1)
IF EXISTS(SELECT * FROM tblRKCompanyPreference WHERE ISNULL(intUnrealizedLossOnInventoryFuturesIOSId,0) = 0)
RAISERROR('Unrealized Loss On Inventory Futures IOS cannot be blank. Please set up the default account(s) in Company Configuration Risk Management tab.',16,1)
IF EXISTS(SELECT * FROM tblRKCompanyPreference WHERE ISNULL(intUnrealizedLossOnInventoryCashIOSId,0) = 0)
RAISERROR('Unrealized Loss On Inventory Cash IOS cannot be blank. Please set up the default account(s) in Company Configuration Risk Management tab.',16,1)
IF EXISTS(SELECT * FROM tblRKCompanyPreference WHERE ISNULL(intUnrealizedLossOnInventoryRatioIOSId,0) = 0)
RAISERROR('Unrealized Loss On Inventory Ratio IOS cannot be blank. Please set up the default account(s) in Company Configuration Risk Management tab.',16,1)
IF EXISTS(SELECT * FROM tblRKCompanyPreference WHERE ISNULL(intUnrealizedGainOnInventoryIntransitIOSId,0) = 0)
RAISERROR('Unrealized Gain On Inventory Intransit IOS cannot be blank. Please set up the default account(s) in Company Configuration Risk Management tab.',16,1)
IF EXISTS(SELECT * FROM tblRKCompanyPreference WHERE ISNULL(intUnrealizedLossOnInventoryIntransitIOSId,0) = 0)
RAISERROR('Unrealized Gain On Inventory Intransit cannot IOS be blank. Please set up the default account(s) in Company Configuration Risk Management tab.',16,1)

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
	UPDATE tblRKM2MInquiry SET ysnPost=1,dtmPostedDateTime=getdate(),strBatchId=@batchId,dtmUnpostedDateTime=null WHERE intM2MInquiryId = @intM2MInquiryId

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