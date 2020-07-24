CREATE PROCEDURE [dbo].[uspMBPostMeterReading]
	 @TransactionId		INT
	,@UserId			INT	
	,@Post				BIT	= NULL
	,@Recap				BIT	= NULL
	,@InvoiceId			INT	= NULL
	,@ErrorMessage		NVARCHAR(MAX) OUTPUT
	,@CreatedInvoices	NVARCHAR(MAX)  = NULL OUTPUT
	,@UpdatedInvoices	NVARCHAR(MAX)  = NULL OUTPUT
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

	--DECLARE @UserEntityId INT
	DECLARE @DefaultCurrency INT

	--SET @UserEntityId = ISNULL((SELECT [intEntityId] FROM tblSMUserSecurity WHERE [intEntityId] = @UserId), @UserId)
	SELECT @DefaultCurrency = ISNULL(intDefaultCurrencyId, 1) FROM tblSMCompanyPreference

	EXEC [dbo].[uspMBPostMeterReadingValidation]
		@intMeterReadingId = @TransactionId
		,@Post = @Post

	DECLARE @EntriesForInvoice AS InvoiceIntegrationStagingTable

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
		@intMeterReadingId = @TransactionId
		,@intUserEntityId  = @UserId 
		,@intCurrency = @DefaultCurrency
		,@Post = @Post
		,@intInvoiceId = @InvoiceId

	-- Validate the Price
	IF EXISTS(SELECT TOP 1 1 FROM @EntriesForInvoice WHERE dblPrice < 0)
	BEGIN
		RAISERROR('Negative price is not allowed',16, 1)
	END

	EXEC [dbo].[uspARProcessInvoices]
		@InvoiceEntries	= @EntriesForInvoice
		,@UserId			= @UserId
		,@GroupingOption	= 11
		,@RaiseError		= 1
		,@ErrorMessage		= @ErrorMessage OUTPUT
		,@CreatedIvoices	= @CreatedInvoices OUTPUT
		,@UpdatedIvoices	= @UpdatedInvoices OUTPUT

	IF (ISNULL(@ErrorMessage, '')  = '')
	BEGIN
		-- UPDATE METER READING INFO
		DECLARE @intCreatedInvoiceId INT = NULL
		IF(@CreatedInvoices IS NOT NULL)
		BEGIN
			SET @intCreatedInvoiceId = CONVERT(INT,@CreatedInvoices)
		END
		ELSE IF(@UpdatedInvoices IS NOT NULL)
		BEGIN
			SET @intCreatedInvoiceId = CONVERT(INT,@UpdatedInvoices)
		END

		EXEC [dbo].[uspMBUpdateMeterReadingInfo]
			 @intMeterReadingId = @TransactionId
			,@intUserId = @UserId
			,@ysnPost = @Post
			,@intInvoiceId = @intCreatedInvoiceId


		-- DELETE INVOICE WHEN ALL LINE ITEMS ARE ZERO QTY
		IF NOT EXISTS(SELECT TOP 1 1 FROM @EntriesForInvoice)
		BEGIN			
			--UPDATE tblMBMeterReading SET intInvoiceId = NULL WHERE intMeterReadingId = @TransactionId
			EXEC [dbo].[uspARDeleteInvoice] 
				@InvoiceId = @InvoiceId,
				@UserId = @UserId
		END


		IF(@@TRANCOUNT > 0)
		BEGIN
			COMMIT TRANSACTION
		END

	END
	ELSE
	BEGIN
		RAISERROR(@ErrorMessage,16, 1)
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