CREATE PROCEDURE [dbo].[uspARInsertInvoiceIntegrationLog]	
     @EntityId						INT
	,@GroupingOption				INT				= 0
	,@ErrorMessage					NVARCHAR(500)	= ''
	,@BatchIdForNewPost				NVARCHAR(50)	= ''
	,@PostedNewCount				INT				= 0
	,@BatchIdForNewPostRecap		NVARCHAR(50)	= ''
	,@RecapNewCount					INT				= 0
	,@BatchIdForExistingPost		NVARCHAR(50)	= ''
	,@PostedExistingCount			INT				= 0
	,@BatchIdForExistingRecap		NVARCHAR(50)	= ''
	,@RecapPostExistingCount		INT				= 0
	,@BatchIdForExistingUnPost		NVARCHAR(50)	= ''
	,@UnPostedExistingCount			INT				= 0
	,@BatchIdForExistingUnPostRecap	NVARCHAR(50)	= ''
	,@RecapUnPostedExistingCount	INT				= 0
	,@RaiseError					BIT				= 0
	,@TranErrorMessage				NVARCHAR(250)	= NULL	OUTPUT
	,@NewIntegrationLogId			INT				= NULL	OUTPUT
AS
BEGIN
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET ANSI_WARNINGS OFF

IF @RaiseError = 1
	SET XACT_ABORT ON

DECLARE  @InitTranCount			INT
		,@Savepoint				NVARCHAR(32)

SET @InitTranCount = @@TRANCOUNT
SET @Savepoint = SUBSTRING(('ARInsertInvoiceIntegrationLog' + CONVERT(VARCHAR, @InitTranCount)), 1, 32)


BEGIN TRY
	INSERT INTO [tblARInvoiceIntegrationLog]
		([dtmDate]
		,[intEntityId]
		,[intGroupingOption]
		,[strErrorMessage]
		,[strBatchIdForNewPost]
		,[intPostedNewCount]
		,[strBatchIdForNewPostRecap]
		,[intRecapNewCount]
		,[strBatchIdForExistingPost]
		,[intPostedExistingCount]
		,[strBatchIdForExistingRecap]
		,[intRecapPostExistingCount]
		,[strBatchIdForExistingUnPost]
		,[intUnPostedExistingCount]
		,[strBatchIdForExistingUnPostRecap]
		,[intRecapUnPostedExistingCount]
		,[intConcurrencyId])
	SELECT 
		 [dtmDate]							= GETDATE()
		,[intEntityId]						= @EntityId
		,[intGroupingOption]				= @GroupingOption
		,[strErrorMessage]					= @ErrorMessage
		,[strBatchIdForNewPost]				= @BatchIdForNewPost
		,[intPostedNewCount]				= @PostedNewCount
		,[strBatchIdForNewPostRecap]		= @BatchIdForNewPostRecap
		,[intRecapNewCount]					= @RecapNewCount
		,[strBatchIdForExistingPost]		= @BatchIdForExistingPost
		,[intPostedExistingCount]			= @PostedExistingCount
		,[strBatchIdForExistingRecap]		= @BatchIdForExistingRecap
		,[intRecapPostExistingCount]		= @RecapPostExistingCount
		,[strBatchIdForExistingUnPost]		= @BatchIdForExistingUnPost
		,[intUnPostedExistingCount]			= @UnPostedExistingCount
		,[strBatchIdForExistingUnPostRecap]	= @BatchIdForExistingUnPostRecap
		,[intRecapUnPostedExistingCount]	= @RecapUnPostedExistingCount
		,[intConcurrencyId]					= 1

	SET @NewIntegrationLogId = SCOPE_IDENTITY()
END TRY
BEGIN CATCH
	IF ISNULL(@RaiseError,0) = 0
	BEGIN
		IF @InitTranCount = 0
			IF (XACT_STATE()) <> 0
				ROLLBACK TRANSACTION
		ELSE
			IF (XACT_STATE()) <> 0
				ROLLBACK TRANSACTION @Savepoint
	END

	SET @TranErrorMessage = ERROR_MESSAGE();
	IF ISNULL(@RaiseError,0) = 1
		RAISERROR(@TranErrorMessage, 16, 1);
	RETURN 0;
END CATCH

IF ISNULL(@RaiseError,0) = 0
BEGIN

	IF @InitTranCount = 0
		BEGIN
			IF (XACT_STATE()) = -1
				ROLLBACK TRANSACTION
			IF (XACT_STATE()) = 1
				COMMIT TRANSACTION
		END		
	ELSE
		BEGIN
			IF (XACT_STATE()) = -1
				ROLLBACK TRANSACTION  @Savepoint
		END	
END
	
RETURN 1
END
