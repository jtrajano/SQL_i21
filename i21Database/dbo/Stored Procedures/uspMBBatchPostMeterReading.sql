CREATE PROCEDURE [dbo].[uspMBBatchPostMeterReading]
	@TransactionId		NVARCHAR(MAX)
	, @UserId				INT
	, @Post					BIT
	, @Recap				BIT
	, @BatchId				NVARCHAR(MAX)
	, @SuccessfulCount		INT				= 0		OUTPUT
	, @ErrorMessage			NVARCHAR(250)	= NULL	OUTPUT
	, @CreatedInvoices		NVARCHAR(MAX)	= NULL	OUTPUT
	, @UpdatedInvoices		NVARCHAR(MAX)	= NULL	OUTPUT

AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ErrorSeverity INT
DECLARE @ErrorState INT
DECLARE @ErrorNumber INT

BEGIN TRY

	BEGIN TRANSACTION

	DECLARE @intCurrency INT = NULL
	DECLARE @tmpRecord TABLE (intId INT NOT NULL, strMessage NVARCHAR(MAX))
	SELECT @intCurrency = ISNULL(intDefaultCurrencyId, 1) FROM tblSMCompanyPreference

	INSERT INTO @tmpRecord (intId)
	SELECT DISTINCT intMeterReadingId FROM vyuMBGetMeterReading WHERE ysnPosted = 0

	IF @TransactionId != 'ALL'
	BEGIN
		DELETE FROM @tmpRecord WHERE intId NOT IN (SELECT CONVERT(INT,Item) FROM [fnSplitStringWithTrim](@TransactionId,',') )
	END

	DECLARE @intRecordKey INT
	DECLARE @EntriesForInvoice AS InvoiceIntegrationStagingTable

	SET @SuccessfulCount = 0

	DECLARE @intId INT = NULL
	DECLARE @CursorTran AS CURSOR

	SET @CursorTran = CURSOR FOR
	SELECT intId FROM @tmpRecord

	OPEN @CursorTran
	FETCH NEXT FROM @CursorTran INTO @intId
	WHILE @@FETCH_STATUS = 0
	BEGIN
		
		DECLARE @ynsValid BIT = 1
		DECLARE @strMeterReadingError NVARCHAR(MAX) = NULL
		DECLARE @intMeterReadingInvoiceId INT = NULL
		
		EXEC [dbo].[uspMBPostMeterReadingValidation]
			@intMeterReadingId = @intId
			,@Post = @Post
			,@ysnRaiseError = 0
			,@ynsValid = @ynsValid OUTPUT
			,@strError = @strMeterReadingError OUTPUT

		IF(@ynsValid = 1)
		BEGIN

			SELECT @intMeterReadingInvoiceId = intInvoiceId FROM tblMBMeterReading WHERE intMeterReadingId = @intId

			INSERT INTO @EntriesForInvoice(
				[strType]
				,[strSourceTransaction]
				,[intSourceId]
				,[strSourceId]
				,[intInvoiceId]
				,[intEntityCustomerId]
				,[intCompanyLocationId]
				,[intCurrencyId]
				,[intTermId]
				,[dtmDate]
				,[dtmDueDate]
				,[dtmShipDate]
				,[intEntitySalespersonId]
				,[intFreightTermId]
				,[intShipViaId]
				,[intPaymentMethodId]
				,[strPONumber]
				,[strBOLNumber]
				,[strComments]
				,[intShipToLocationId]
				,[intBillToLocationId]
				,[ysnTemplate]
				,[ysnForgiven]
				,[ysnCalculated]
				,[ysnSplitted]
				,[intPaymentId]
				,[intSplitId]
				,[intLoadDistributionHeaderId]
				,[strActualCostId]
				,[intShipmentId]
				,[intTransactionId]
				,[intEntityId]
				,[ysnResetDetails]
				,[ysnPost]
				,[intInvoiceDetailId]
				,[intItemId]
				,[ysnInventory]
				,[strItemDescription]
				,[intItemUOMId]
				,[dblQtyOrdered]
				,[dblQtyShipped]
				,[dblDiscount]
				,[dblPrice]
				,[ysnRefreshPrice]
				,[strMaintenanceType]
				,[strFrequency]
				,[dtmMaintenanceDate]
				,[dblMaintenanceAmount]
				,[dblLicenseAmount]
				,[intTaxGroupId]
				,[ysnRecomputeTax]
				,[intSCInvoiceId]
				,[strSCInvoiceNumber]
				,[intInventoryShipmentItemId]
				,[strShipmentNumber]
				,[intSalesOrderDetailId]
				,[strSalesOrderNumber]
				,[intContractHeaderId]
				,[intContractDetailId]
				,[intShipmentPurchaseSalesContractId]
				,[intTicketId]
				,[intTicketHoursWorkedId]
				,[intSiteId]
				,[strBillingBy]
				,[dblPercentFull]
				,[dblNewMeterReading]
				,[dblPreviousMeterReading]
				,[dblConversionFactor]
				,[intPerformerId]
				,[ysnLeaseBilling]
				,[ysnVirtualMeterReading]
				,[ysnClearDetailTaxes]					
				,[intTempDetailIdForTaxes]
				,[intMeterReadingId]
				,[ysnUseOriginIdAsInvoiceNumber]
				,[strInvoiceOriginId]
			)
			EXEC [dbo].[uspMBCreateInvoice] 
				@intMeterReadingId = @intId
				,@intUserEntityId  = @UserId 
				,@intCurrency = @intCurrency
				,@Post = @Post
				,@intInvoiceId = @intMeterReadingInvoiceId
		END
		ELSE
		BEGIN
			DECLARE @strTransactionId NVARCHAR(30) = NULL
			SELECT @strTransactionId = strTransactionId FROM tblMBMeterReading WHERE intMeterReadingId = @intId

			-- Add to Batch Post Log for invalid Meter Reading
			INSERT INTO tblMBPostResult (strBatchId, intTransactionId, strTransactionId, strDescription, dtmDate, strTransactionType, intUserId)
			VALUES(@BatchId, @intId, @strTransactionId, @strMeterReadingError, GETDATE(), 'Meter Reading', @UserId)
		END		

		FETCH NEXT FROM @CursorTran INTO @intId
	END
	CLOSE @CursorTran
	DEALLOCATE @CursorTran


	EXEC [dbo].[uspARProcessInvoices]
		@InvoiceEntries	= @EntriesForInvoice
		,@UserId					= @UserId
		,@GroupingOption			= 11
		,@RaiseError				= 1
		,@ErrorMessage				= @ErrorMessage OUTPUT
		,@CreatedIvoices			= @CreatedInvoices OUTPUT
		,@UpdatedIvoices			= @UpdatedInvoices OUTPUT
		,@BatchIdForNewPost			= @BatchId OUTPUT
		,@BatchIdForExistingPost	= @BatchId OUTPUT
		,@BatchIdForNewPostRecap	= @BatchId OUTPUT
		,@BatchIdForExistingRecap	= @BatchId OUTPUT


	IF (@ErrorMessage IS NULL)
	BEGIN

		DECLARE @intInvoiceId int = NULL
		DECLARE @tblInvoice TABLE (strInvoiceId NVARCHAR(50) NOT NULL)

		IF (@CreatedInvoices IS NOT NULL)
		BEGIN
			INSERT INTO @tblInvoice (strInvoiceId)
			SELECT Item FROM [fnSplitStringWithTrim](@CreatedInvoices,',') 
		END

		IF(@UpdatedInvoices IS NOT NULL)
		BEGIN
			INSERT INTO @tblInvoice (strInvoiceId)
			SELECT Item FROM [fnSplitStringWithTrim](@UpdatedInvoices,',') 
		END

		DECLARE @CursorCreatedInvoice AS CURSOR
		SET @CursorCreatedInvoice = CURSOR FOR
		SELECT CONVERT(INT,strInvoiceId) FROM @tblInvoice

		SELECT @SuccessfulCount = @SuccessfulCount + COUNT(*) 
		FROM @tblInvoice

		OPEN @CursorCreatedInvoice
		FETCH NEXT FROM @CursorCreatedInvoice INTO @intInvoiceId
		WHILE @@FETCH_STATUS = 0
		BEGIN

			DECLARE @intMeterReadingId INT = NULL

			SELECT @intMeterReadingId = MR.intMeterReadingId  FROM tblARInvoice I
			INNER JOIN tblMBMeterReading MR ON MR.strTransactionId = I.strInvoiceNumber
			WHERE I.intInvoiceId = @intInvoiceId

			EXEC [dbo].[uspMBUpdateMeterReadingInfo]
				@intMeterReadingId = @intMeterReadingId
				,@intUserId = @UserId
				,@ysnPost = @Post
				,@intInvoiceId = @intInvoiceId
	
			FETCH NEXT FROM @CursorCreatedInvoice INTO @intInvoiceId	
		END
		CLOSE @CursorCreatedInvoice
		DEALLOCATE @CursorCreatedInvoice

		COMMIT TRANSACTION
	END
	ELSE
	BEGIN
		IF(@@TRANCOUNT > 0)
		BEGIN
			ROLLBACK TRANSACTION
		END
	END

END TRY
BEGIN CATCH
		
	IF(@@TRANCOUNT > 0)
	BEGIN
		ROLLBACK TRANSACTION
	END
	
	SET @ErrorMessage = ERROR_MESSAGE()
		--SET @ErrorMessage = ERROR_MESSAGE()
	SET @ErrorSeverity = ERROR_SEVERITY()
	SET @ErrorState = ERROR_STATE()
	SET @ErrorNumber   = ERROR_NUMBER()
		
	RAISERROR (@ErrorMessage , @ErrorSeverity, @ErrorState ,@ErrorNumber)
END CATCH