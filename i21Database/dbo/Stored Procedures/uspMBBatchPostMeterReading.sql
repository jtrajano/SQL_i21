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
	
	--DECLARE @UserEntityId INT = NULL
	DECLARE @intCurrency INT = NULL
	DECLARE @tmpRecord TABLE (intId INT NOT NULL, strMessage NVARCHAR(MAX))
	--SET @UserEntityId = ISNULL((SELECT [intEntityId] FROM tblSMUserSecurity WHERE [intEntityId] = @UserId), @UserId)
	SELECT @intCurrency = ISNULL(intDefaultCurrencyId, 1) FROM tblSMCompanyPreference


	INSERT INTO @tmpRecord (intId)
	SELECT DISTINCT intMeterReadingId FROM vyuMBGetMeterReading WHERE ysnPosted = 0

	IF @TransactionId != 'ALL'
	BEGIN
		DELETE FROM @tmpRecord WHERE intId NOT IN (SELECT Item FROM [fnSplitStringWithTrim](@TransactionId,',') )
	END

	DECLARE @intRecordKey INT
	DECLARE @EntriesForInvoice AS InvoiceIntegrationStagingTable

	SET @SuccessfulCount = 0

	DECLARE @intId INT = NULL
	--DECLARE @strMessage NVARCHAR(MAX) = NULL
	DECLARE @CursorTran AS CURSOR

	SET @CursorTran = CURSOR FOR
	SELECT intId FROM @tmpRecord

	OPEN @CursorTran
	FETCH NEXT FROM @CursorTran INTO @intId
	WHILE @@FETCH_STATUS = 0
	BEGIN
		
		DECLARE @ynsValid BIT = 1
		--DECLARE @strMeterReadingError NVARCHAR(MAX) = NULL
		
		EXEC [dbo].[uspMBPostMeterReadingValidation]
			@intMeterReadingId = @intId
			,@Post = @Post
			,@ysnRaiseError = 0
			,@ynsValid = @ynsValid OUTPUT
			--,@strError = @strMessage OUTPUT

		IF(@ynsValid = 1)
		BEGIN 
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
				,[intInvoiceId]							= NULL --NULL Value will create new invoice
				,[intEntityCustomerId]					= MRDetail.intEntityCustomerId
				,[intCompanyLocationId]					= MRDetail.intCompanyLocationId
				,[intCurrencyId]						= @intCurrency
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
				,[intEntityId]							= @UserId
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
				,[intTempDetailIdForTaxes]				= @intId
				,[intMeterReadingId]					= @intId
				,[ysnUseOriginIdAsInvoiceNumber]		= 1
				,[strInvoiceOriginId]					= MRDetail.strTransactionId
			FROM vyuMBGetMeterReadingDetail MRDetail
			LEFT JOIN vyuMBGetMeterAccountDetail MADetail ON MADetail.intMeterAccountDetailId = MRDetail.intMeterAccountDetailId
			LEFT JOIN vyuARCustomer Customer ON Customer.[intEntityId] = MRDetail.intEntityCustomerId
			LEFT JOIN tblEMEntityLocation EntityLocation ON EntityLocation.intEntityLocationId = MRDetail.intEntityLocationId AND MRDetail.intEntityCustomerId = EntityLocation.intEntityId
			WHERE MRDetail.intMeterReadingId = @intId
			AND MRDetail.dblQuantitySold > 0
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
		END
		--ELSE
		--BEGIN
		--	UPDATE @tmpRecord SET strMessage = @strMessage WHERE intId = @intId
		--END

		FETCH NEXT FROM @CursorTran INTO @intId
	END

	BEGIN TRANSACTION

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

	DECLARE @InvoiceId INT
	
	IF (@ErrorMessage IS NULL)
	BEGIN
		IF (@CreatedInvoices IS NOT NULL)
		BEGIN
			SELECT * INTO #tmpCreatedInvoice
			FROM [fnSplitStringWithTrim](@CreatedInvoices,',') 

			SELECT @SuccessfulCount = @SuccessfulCount + COUNT(*) 
			FROM #tmpCreatedInvoice

			WHILE (EXISTS(SELECT TOP 1 1 FROM #tmpCreatedInvoice ))
			BEGIN
				SELECT TOP 1 @InvoiceId = CAST(Item AS INT) FROM #tmpCreatedInvoice
				
				UPDATE tblMBMeterReading 
					SET ysnPosted = (CASE WHEN @Recap = 1 THEN 0 ELSE 1 END)
						, intInvoiceId = @InvoiceId
						, dtmPostedDate = GETDATE()
				WHERE intMeterReadingId = (SELECT intMeterReadingId
											FROM tblARInvoice 
											WHERE intInvoiceId = @InvoiceId)

				UPDATE tblMBMeterAccountDetail
				SET tblMBMeterAccountDetail.dblLastMeterReading = MRDetail.dblCurrentReading
					, tblMBMeterAccountDetail.dblLastTotalSalesDollar = MRDetail.dblCurrentDollars
				FROM tblMBMeterAccountDetail MADetail
				LEFT JOIN tblMBMeterReadingDetail MRDetail ON MRDetail.intMeterAccountDetailId = MADetail.intMeterAccountDetailId
				WHERE MRDetail.intMeterReadingId = (SELECT intMeterReadingId
														FROM tblARInvoice 
														WHERE intInvoiceId = @InvoiceId)

				DELETE FROM #tmpCreatedInvoice WHERE Item = @InvoiceId
			END
			DROP TABLE #tmpCreatedInvoice
		END

		IF(@UpdatedInvoices IS NOT NULL)
		BEGIN
			SELECT * INTO #tmpUpdatedInvoice
			FROM [fnSplitStringWithTrim](@UpdatedInvoices,',') 

			SELECT @SuccessfulCount = @SuccessfulCount + COUNT(*) 
			FROM #tmpUpdatedInvoice

			WHILE (EXISTS(SELECT TOP 1 1 FROM #tmpUpdatedInvoice ))
			BEGIN
				SELECT TOP 1 @InvoiceId = CAST(Item AS INT) FROM #tmpUpdatedInvoice
				
				UPDATE tblMBMeterReading 
					SET ysnPosted = (CASE WHEN @Recap = 1 THEN 0 ELSE 1 END)
						, intInvoiceId = @InvoiceId
						, dtmPostedDate = GETDATE()
				WHERE intMeterReadingId = (SELECT intMeterReadingId
											FROM tblARInvoice 
											WHERE intInvoiceId = @InvoiceId)

				UPDATE tblMBMeterAccountDetail
				SET tblMBMeterAccountDetail.dblLastMeterReading = MRDetail.dblCurrentReading
					, tblMBMeterAccountDetail.dblLastTotalSalesDollar = MRDetail.dblCurrentDollars
				FROM tblMBMeterAccountDetail MADetail
				LEFT JOIN tblMBMeterReadingDetail MRDetail ON MRDetail.intMeterAccountDetailId = MADetail.intMeterAccountDetailId
				WHERE MRDetail.intMeterReadingId = (SELECT intMeterReadingId
														FROM tblARInvoice 
														WHERE intInvoiceId = @InvoiceId)
				
				DELETE FROM #tmpUpdatedInvoice WHERE Item = @InvoiceId
			END
			DROP TABLE #tmpUpdatedInvoice
		END

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