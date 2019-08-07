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

	-- VALIDATION
	uspMBPostMeterReadingValidation

	DECLARE @UserEntityId INT
	DECLARE @DefaultCurrency INT
	DECLARE @ynsValid BIT = NULL
	SET @UserEntityId = ISNULL((SELECT [intEntityId] FROM tblSMUserSecurity WHERE [intEntityId] = @UserId), @UserId)
	SELECT @DefaultCurrency = ISNULL(intDefaultCurrencyId, 1) FROM tblSMCompanyPreference

	EXEC [dbo].[uspMBPostMeterReadingValidation]
		@intMeterReadingId = @TransactionId
		,@Post = @Post
		,@ynsValid = @ynsValid OUTPUT

	DECLARE @EntriesForInvoice AS InvoiceIntegrationStagingTable

	IF ((SELECT ISNULL(MA.intCompanyLocationId, 0) FROM tblMBMeterReading MR INNER JOIN tblMBMeterAccount MA ON MA.intMeterAccountId = MR.intMeterAccountId where intMeterReadingId = @TransactionId) = 0)
    BEGIN
		RAISERROR('Company Location is required!', 16, 1)
		RETURN
    END

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
	SELECT
		[strType]								= 'Meter Billing'
		,[strSourceTransaction]					= 'Meter Billing'
		,[intSourceId]							= MRDetail.intMeterReadingId
		,[strSourceId]							= MRDetail.strTransactionId
		,[intInvoiceId]							= @InvoiceId --NULL Value will create new invoice
		,[intEntityCustomerId]					= MRDetail.intEntityCustomerId
		,[intCompanyLocationId]					= MRDetail.intCompanyLocationId
		,[intCurrencyId]						= @DefaultCurrency
		,[intTermId]							= MADetail.intTermId
		,[dtmDate]								= MRDetail.dtmTransaction
		,[dtmDueDate]							= NULL
		,[dtmShipDate]							= MRDetail.dtmTransaction
		,[intEntitySalespersonId]				= Customer.intSalespersonId
		,[intFreightTermId]						= NULL 
		,[intShipViaId]							= NULL 
		,[intPaymentMethodId]					= NULL
		,[strPONumber]							= NULL
		,[strBOLNumber]							= ''
		,[strComments]							= MRDetail.strInvoiceComment
		,[intShipToLocationId]					= MRDetail.intEntityLocationId
		,[intBillToLocationId]					= NULL
		,[ysnTemplate]							= 0
		,[ysnForgiven]							= 0
		,[ysnCalculated]						= 0  --0 OS
		,[ysnSplitted]							= 0
		,[intPaymentId]							= NULL
		,[intSplitId]							= NULL
		,[intLoadDistributionHeaderId]			= NULL
		,[strActualCostId]						= ''
		,[intShipmentId]						= NULL
		,[intTransactionId]						= NULL
		,[intEntityId]							= @UserEntityId
		,[ysnResetDetails]						= 1
		,[ysnPost]								= @Post
		,[intInvoiceDetailId]					= NULL
		,[intItemId]							= MRDetail.intItemId
		,[ysnInventory]							= 1
		,[strItemDescription]					= MRDetail.strItemDescription
		,[intItemUOMId]							= MRDetail.intItemUOMId
		,[dblQtyOrdered]						= 0
		,[dblQtyShipped]						= SUM(MRDetail.dblQuantitySold)
		,[dblDiscount]							= 0
		,[dblPrice]								= MIN(MRDetail.dblNetPrice)
		,[ysnRefreshPrice]						= 0
		,[strMaintenanceType]					= ''
		,[strFrequency]							= ''
		,[dtmMaintenanceDate]					= NULL
		,[dblMaintenanceAmount]					= NULL
		,[dblLicenseAmount]						= NULL
		,[intTaxGroupId]						= EntityLocation.intTaxGroupId
		,[ysnRecomputeTax]						= 1
		,[intSCInvoiceId]						= NULL
		,[strSCInvoiceNumber]					= ''
		,[intInventoryShipmentItemId]			= NULL
		,[strShipmentNumber]					= ''
		,[intSalesOrderDetailId]				= NULL
		,[strSalesOrderNumber]					= ''
		,[intContractHeaderId]					= NULL
		,[intContractDetailId]					= NULL
		,[intShipmentPurchaseSalesContractId]	= NULL
		,[intTicketId]							= NULL
		,[intTicketHoursWorkedId]				= NULL
		,[intSiteId]							= NULL
		,[strBillingBy]							= ''
		,[dblPercentFull]						= NULL
		,[dblNewMeterReading]					= NULL
		,[dblPreviousMeterReading]				= NULL
		,[dblConversionFactor]					= NULL
		,[intPerformerId]						= NULL
		,[ysnLeaseBilling]						= NULL
		,[ysnVirtualMeterReading]				= NULL
		,[ysnClearDetailTaxes]					= 1
		,[intTempDetailIdForTaxes]				= @TransactionId
		,[intMeterReadingId]					= @TransactionId
		,[ysnUseOriginIdAsInvoiceNumber]		= 1
		,[strInvoiceOriginId]					= MRDetail.strTransactionId
	FROM vyuMBGetMeterReadingDetail MRDetail
	LEFT JOIN vyuMBGetMeterAccountDetail MADetail ON MADetail.intMeterAccountDetailId = MRDetail.intMeterAccountDetailId
	LEFT JOIN vyuARCustomer Customer ON Customer.[intEntityId] = MRDetail.intEntityCustomerId
	LEFT JOIN tblEMEntityLocation EntityLocation ON EntityLocation.intEntityLocationId = MRDetail.intEntityLocationId AND MRDetail.intEntityCustomerId = EntityLocation.intEntityId
	WHERE MRDetail.intMeterReadingId = @TransactionId
	AND MRDetail.dblCurrentReading > 0
	GROUP BY MRDetail.intMeterReadingId
		, MRDetail.strTransactionId
		, MRDetail.intEntityCustomerId
		, MRDetail.intEntityLocationId
		, MRDetail.intCompanyLocationId
		, MRDetail.intItemId
		, MRDetail.strItemDescription
		, MRDetail.intItemUOMId
		, MADetail.intTermId
		, MRDetail.dtmTransaction
		, Customer.intSalespersonId
		, MRDetail.strInvoiceComment
		, EntityLocation.intTaxGroupId

	EXEC [dbo].[uspARProcessInvoices]
		@InvoiceEntries	= @EntriesForInvoice
		,@UserId			= @UserId
		,@GroupingOption	= 11
		,@RaiseError		= 1
		,@ErrorMessage		= @ErrorMessage OUTPUT
		,@CreatedIvoices	= @CreatedInvoices OUTPUT
		,@UpdatedIvoices	= @UpdatedInvoices OUTPUT

	IF (@ErrorMessage IS NULL)
		BEGIN
			COMMIT TRANSACTION
		END
	ELSE
		BEGIN
			ROLLBACK TRANSACTION
		END

	IF (@ErrorMessage IS NULL)
	BEGIN

		IF (@CreatedInvoices IS NOT NULL)
		BEGIN
			UPDATE tblMBMeterReading 
			SET intInvoiceId = @CreatedInvoices
			WHERE intMeterReadingId = @TransactionId
		END	

		UPDATE tblMBMeterReading
		SET ysnPosted = @Post
			, dtmPostedDate = GETDATE()
		WHERE intMeterReadingId = @TransactionId

		IF (@Post = 1)
		BEGIN
			UPDATE tblMBMeterAccountDetail
			SET tblMBMeterAccountDetail.dblLastMeterReading = MRDetail.dblCurrentReading
				, tblMBMeterAccountDetail.dblLastTotalSalesDollar = MRDetail.dblCurrentDollars
			FROM tblMBMeterAccountDetail MADetail
			LEFT JOIN tblMBMeterReadingDetail MRDetail ON MRDetail.intMeterAccountDetailId = MADetail.intMeterAccountDetailId
			WHERE MRDetail.intMeterReadingId = @TransactionId
		END
		ELSE IF (@Post = 0)
		BEGIN
			DECLARE @transactionDate DATETIME
				, @meterAccountId INT
			SELECT @transactionDate = dtmTransaction
				, @meterAccountId = intMeterAccountId
			FROM tblMBMeterReading
			WHERE intMeterReadingId = @TransactionId

			-- UPDATE tblMBMeterAccountDetail A SET A.dblLastMeterReading = ISNULL(MRD.dblLastMeterReading, 0),
			-- MRD.dblLastMeterReading, dblLastTotalSalesDollar = ISNULL(MRD.dblLastReading, 0) 
			-- FROM tblMBMeterReadingDetail MRD
			-- INNER JOIN tblMBMeterReading MR ON MR.intMeterReadingId = MRD.intMeterReadingId
			-- WHERE A.intMeterAccountDetailId = MRD.intMeterAccountDetailId
			-- AND MR.intMeterReadingId = @TransactionId

			DECLARE @CursorTran AS CURSOR

			SET @CursorTran = CURSOR FOR
			SELECT A.intMeterAccountDetailId
			FROM tblMBMeterAccountDetail A
			WHERE A.intMeterAccountId = @meterAccountId

			DECLARE @intMeterAccountDetailId INT = NULL

			OPEN @CursorTran
			FETCH NEXT FROM @CursorTran INTO @intMeterAccountDetailId
        	WHILE @@FETCH_STATUS = 0
			BEGIN

				DECLARE @dblCurrentReading NUMERIC(18,6) = NULL,
					@dblCurrentDollar NUMERIC(18,6) = NULL

				SELECT TOP 1 @dblCurrentReading = MRD.dblCurrentReading, @dblCurrentDollar = MRD.dblCurrentDollars FROM tblMBMeterReadingDetail MRD
				INNER JOIN tblMBMeterReading MR ON MR.intMeterReadingId = MRD.intMeterReadingId
			 	WHERE MRD.intMeterAccountDetailId = @intMeterAccountDetailId
				AND MR.dtmTransaction <= @transactionDate
				AND MR.intMeterReadingId < @TransactionId
				ORDER BY MR.intMeterReadingId DESC

				UPDATE tblMBMeterAccountDetail SET dblLastMeterReading = ISNULL(@dblCurrentReading, 0), dblLastTotalSalesDollar = ISNULL(@dblCurrentDollar, 0)
				WHERE intMeterAccountDetailId = @intMeterAccountDetailId


				FETCH NEXT FROM @CursorTran INTO @intMeterAccountDetailId
			END
			CLOSE @CursorTran
			DEALLOCATE @CursorTran
		
		END
	END

END TRY
BEGIN CATCH
		
	ROLLBACK TRANSACTION
	SET @ErrorMessage = ERROR_MESSAGE()
		--SET @ErrorMessage = ERROR_MESSAGE()
	SET @ErrorSeverity = ERROR_SEVERITY()
	SET @ErrorState = ERROR_STATE()
	SET @ErrorNumber   = ERROR_NUMBER()
		
	RAISERROR (@ErrorMessage , @ErrorSeverity, @ErrorState ,@ErrorNumber)
END CATCH