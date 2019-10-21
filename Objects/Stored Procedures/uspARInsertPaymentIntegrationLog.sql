CREATE PROCEDURE [dbo].[uspARInsertPaymentIntegrationLog]
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
	,@NewIntegrationLogId			INT				= 0	OUTPUT
AS
BEGIN
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF


	INSERT INTO [tblARPaymentIntegrationLog]
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
	
RETURN 1
END
