CREATE PROCEDURE [dbo].[uspARProcessPayments] 
	 @PaymentEntries				PaymentIntegrationStagingTable					READONLY	
	,@UserId						INT
	,@GroupingOption				INT								= 0	
																	-- 0 = [intId] - A Payment will be created for each record in @PaymentEntries												
																	-- 1 = [intEntityCustomerId]
																	-- 2 = [intEntityCustomerId], [intLocationId]
																	-- 3 = [intEntityCustomerId], [intLocationId], [intCurrencyId]
																	-- 4 = [intEntityCustomerId], [intLocationId], [intCurrencyId], [dtmDatePaid]
																	-- 5 = [intEntityCustomerId], [intLocationId], [intCurrencyId], [dtmDatePaid], [intPaymentMethodId]
																	-- 6 = [intEntityCustomerId], [intLocationId], [intCurrencyId], [dtmDatePaid], [intPaymentMethodId], [strPaymentInfo]
																	-- 7 = [intEntityCustomerId], [intLocationId], [intCurrencyId], [dtmDatePaid], [intPaymentMethodId], [strPaymentInfo], [strNotes]
	,@RaiseError					BIT								= 0
	,@ErrorMessage					NVARCHAR(250)					= NULL			OUTPUT
	,@LogId							INT								= NULL			OUTPUT
AS

BEGIN

SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS OFF

DECLARE @CurrentErrorMessage	NVARCHAR(250)
		,@ZeroDecimal			NUMERIC(18, 6)
		,@DateNow				DATETIME
		
SET @ZeroDecimal = 0.000000
SET @DateNow = CAST(GETDATE() AS DATE)

DECLARE @SourceColumn AS NVARCHAR (500)
		,@SourceTable AS NVARCHAR (500)	
		
IF ISNULL(@RaiseError,0) = 0
	BEGIN TRANSACTION

BEGIN TRY
	IF OBJECT_ID('tempdb..#TempPaymentEntries') IS NOT NULL DROP TABLE #TempPaymentEntries	
	SELECT * INTO #TempPaymentEntries FROM @PaymentEntries 	
	
	IF OBJECT_ID('tempdb..#EntriesForProcessing') IS NOT NULL DROP TABLE #EntriesForProcessing	
	CREATE TABLE #EntriesForProcessing(
		 [intId]						INT												NOT NULL
		,[intEntityCustomerId]			INT												NULL
		,[intLocationId]				INT												NULL
		,[intCurrencyId]				INT												NULL
		,[dtmDatePaid]					DATETIME										NULL				
		,[intPaymentMethodId]			INT												NULL		
		,[strPaymentInfo]				NVARCHAR (50)	COLLATE Latin1_General_CI_AS	NULL
		,[strNotes]						NVARCHAR (250)	COLLATE Latin1_General_CI_AS	NULL		
		,[ysnProcessed]					BIT												NULL		
		,[ysnForInsert]					BIT												NULL
		,[ysnForUpdate]					BIT												NULL
		,[ysnRecap]						BIT												NULL
		,[ysnPost]						BIT												NULL
	)

	DECLARE  @QueryString AS VARCHAR(MAX)
			,@Columns AS VARCHAR(MAX)
			
	SET @Columns =	(CASE 
						WHEN @GroupingOption = 0 THEN '[intId]'
						WHEN @GroupingOption = 1 THEN '[intEntityCustomerId]'
						WHEN @GroupingOption = 2 THEN '[intEntityCustomerId], [intLocationId]'
						WHEN @GroupingOption = 3 THEN '[intEntityCustomerId], [intLocationId], [intCurrencyId]'
						WHEN @GroupingOption = 4 THEN '[intEntityCustomerId], [intLocationId], [intCurrencyId], [dtmDatePaid]'
						WHEN @GroupingOption = 5 THEN '[intEntityCustomerId], [intLocationId], [intCurrencyId], [dtmDatePaid], [intPaymentMethodId]'
						WHEN @GroupingOption = 6 THEN '[intEntityCustomerId], [intLocationId], [intCurrencyId], [dtmDatePaid], [intPaymentMethodId], [strPaymentInfo]'		
						WHEN @GroupingOption = 7 THEN '[intEntityCustomerId], [intLocationId], [intCurrencyId], [dtmDatePaid], [intPaymentMethodId], [strPaymentInfo], [strNotes]'						
					END)
					
				
	IF @GroupingOption > 0
		SET @QueryString = 'INSERT INTO #EntriesForProcessing([intId], ' +  @Columns + ', [ysnForInsert]) SELECT MIN([intId]), ' + @Columns + ', 1 FROM #TempPaymentEntries WHERE ISNULL([intPaymentId],0) = 0 GROUP BY ' + @Columns
	ELSE
		SET @QueryString = 'INSERT INTO #EntriesForProcessing(' +  @Columns + ', [ysnForInsert]) SELECT ' + @Columns + ', 1 FROM #TempPaymentEntries WHERE ISNULL([intPaymentId],0) = 0 GROUP BY ' + @Columns

	EXECUTE(@QueryString);

	IF @GroupingOption > 0
		SET @QueryString = 'INSERT INTO #EntriesForProcessing([intId], [intPaymentId], [intPaymentDetailId], ' + @Columns + ', [ysnForUpdate]) SELECT DISTINCT [intId], [intPaymentId], [intPaymentDetailId], ' + @Columns + ', 1 FROM #TempPaymentEntries WHERE ISNULL([intPaymentId],0) <> 0 GROUP BY [intId], [intPaymentId], [intPaymentDetailId],' + @Columns
	ELSE
		SET @QueryString = 'INSERT INTO #EntriesForProcessing([intId], [intPaymentId], [intPaymentDetailId], [ysnForUpdate]) SELECT DISTINCT [intId], [intPaymentId], [intPaymentDetailId], 1 FROM #TempPaymentEntries WHERE ISNULL([intPaymentId],0) <> 0 GROUP BY [intId], [intPaymentId], [intPaymentDetailId]'

	EXECUTE(@QueryString);

	IF OBJECT_ID('tempdb..#TempPaymentEntries') IS NOT NULL DROP TABLE #TempPaymentEntries	
END TRY
BEGIN CATCH
	IF ISNULL(@RaiseError,0) = 0
		ROLLBACK TRANSACTION
	SET @ErrorMessage = ERROR_MESSAGE();
	IF ISNULL(@RaiseError,0) = 1
		RAISERROR(@ErrorMessage, 16, 1);
	RETURN 0;
END CATCH

DECLARE @IntegrationLogId INT
BEGIN TRY
		EXEC [dbo].[uspARInsertPaymentIntegrationLog]
			 @EntityId						= @UserId
			,@GroupingOption				= @GroupingOption
			,@ErrorMessage					= ''
			,@BatchIdForNewPost				= ''
			,@PostedNewCount				= 0
			,@BatchIdForNewPostRecap		= ''
			,@RecapNewCount					= 0
			,@BatchIdForExistingPost		= ''
			,@PostedExistingCount			= 0
			,@BatchIdForExistingRecap		= ''
			,@RecapPostExistingCount		= 0
			,@BatchIdForExistingUnPost		= ''
			,@UnPostedExistingCount			= 0
			,@BatchIdForExistingUnPostRecap	= ''
			,@RecapUnPostedExistingCount	= 0
			,@NewIntegrationLogId			= @IntegrationLogId	OUTPUT


		SET @LogId = @IntegrationLogId
	
END TRY
BEGIN CATCH
	IF ISNULL(@RaiseError,0) = 0
		ROLLBACK TRANSACTION
	SET @ErrorMessage = ERROR_MESSAGE();
	IF ISNULL(@RaiseError,0) = 1
		RAISERROR(@ErrorMessage, 16, 1);
	RETURN 0;
END CATCH

--BEGIN TRY
--IF EXISTS(SELECT TOP 1 NULL FROM #EntriesForProcessing WITH (NOLOCK) WHERE ISNULL([ysnForInsert],0) = 1)
--BEGIN
--	DECLARE @PaymentsForInsert	PaymentIntegrationStagingTable			
--	INSERT INTO @PaymentsForInsert(
--		 [intId]
--		,[strSourceTransaction]
--		,[intSourceId]
--		,[strSourceId]
--		,[intPaymentId]
--		,[intEntityCustomerId]
--		,[intLocationId]
--		,[intCurrencyId]
--		,[dtmDatePaid]
--		,[intPaymentMethodId]
--		,[strPaymentInfo]
--		,[strNotes]
--		,[intAccountId]
--		,[intBankAccountId]
--		,[intWriteOffAccountId]
--		,[strPaymentMethod]
--		,[dblAmountPaid]
--		,[strRecordNumber]
--		,[ysnApplytoBudget]
--		,[ysnApplyOnAccount]
--		,[ysnInvoicePrepayment]
--		,[ysnImportedFromOrigin]
--		,[ysnImportedAsPosted]
--		,[ysnAllowPrepayment]
--		,[ysnPost]
--		,[ysnRecap]
--		,[intEntityId]
--		,[intPaymentDetailId]
--		,[intInvoiceId]
--		,[intBillId]
--		,[strTransactionNumber]
--		,[intTermId]
--		,[ysnApplyTermDiscount]
--		,[dblDiscount]
--		,[dblDiscountAvailable]
--		,[dblInterest]
--		,[dblPayment]
--		,[strInvoiceReportNumber]
--		,[intCurrencyExchangeRateTypeId]
--		,[intCurrencyExchangeRateId]
--		,[dblCurrencyExchangeRate]
--		,[ysnAllowOverpayment]
--	)								
--	SELECT		 	
--		 [intId]							= IE.[intId]
--		,[strSourceTransaction]				= IE.[strSourceTransaction]
--		,[intSourceId]						= IE.[intSourceId]
--		,[strSourceId]						= IE.[strSourceId]
--		,[intPaymentId]						= IE.[intPaymentId]
--		,[intEntityCustomerId]				= IE.[intEntityCustomerId]
--		,[intLocationId]					= IE.[intLocationId]
--		,[intCurrencyId]					= IE.[intCurrencyId]
--		,[dtmDatePaid]						= CAST(ISNULL(IE.[dtmDatePaid], @DateNow) AS DATE)
--		,[intPaymentMethodId]				= IE.[intPaymentMethodId]
--		,[strPaymentInfo]					= IE.[strPaymentInfo]
--		,[strNotes]							= IE.[strNotes]
--		,[intAccountId]						= IE.[intAccountId]
--		,[intBankAccountId]					= IE.[intBankAccountId]
--		,[intWriteOffAccountId]				= IE.[intWriteOffAccountId]
--		,[strPaymentMethod]					= IE.[strPaymentMethod]
--		,[dblAmountPaid]					= IE.[dblAmountPaid]
--		,[strRecordNumber]					= IE.[strRecordNumber]
--		,[ysnApplytoBudget]					= IE.[ysnApplytoBudget]
--		,[ysnApplyOnAccount]				= IE.[ysnApplyOnAccount]
--		,[ysnInvoicePrepayment]				= IE.[ysnInvoicePrepayment]
--		,[ysnImportedFromOrigin]			= IE.[ysnImportedFromOrigin]
--		,[ysnImportedAsPosted]				= IE.[ysnImportedAsPosted]
--		,[ysnAllowPrepayment]				= IE.[ysnAllowPrepayment]
--		,[ysnPost]							= IE.[ysnPost]
--		,[ysnRecap]							= IE.[ysnRecap]
--		,[intEntityId]						= IE.[intEntityId]
--		,[intPaymentDetailId]				= IE.[intPaymentDetailId]
--		,[intInvoiceId]						= (CASE WHEN @GroupingOption = 0 THEN IE.[intInvoiceId] ELSE NULL END)
--		,[intBillId]						= (CASE WHEN @GroupingOption = 0 THEN IE.[intBillId] ELSE NULL END)
--		,[strTransactionNumber]				= (CASE WHEN @GroupingOption = 0 THEN IE.[strTransactionNumber] ELSE NULL END)
--		,[intTermId]						= (CASE WHEN @GroupingOption = 0 THEN IE.[intTermId] ELSE NULL END)
--		,[ysnApplyTermDiscount]				= (CASE WHEN @GroupingOption = 0 THEN IE.[ysnApplyTermDiscount] ELSE NULL END)
--		,[dblDiscount]						= (CASE WHEN @GroupingOption = 0 THEN IE.[dblDiscount] ELSE NULL END)				
--		,[dblDiscountAvailable]				= (CASE WHEN @GroupingOption = 0 THEN IE.[dblDiscountAvailable] ELSE NULL END)				
--		,[dblInterest]						= (CASE WHEN @GroupingOption = 0 THEN IE.[dblInterest] ELSE NULL END)				
--		,[dblPayment]						= (CASE WHEN @GroupingOption = 0 THEN IE.[dblPayment] ELSE NULL END)				
--		,[strInvoiceReportNumber]			= (CASE WHEN @GroupingOption = 0 THEN IE.[strInvoiceReportNumber] ELSE NULL END)				
--		,[intCurrencyExchangeRateTypeId]	= (CASE WHEN @GroupingOption = 0 THEN IE.[intCurrencyExchangeRateTypeId] ELSE NULL END)				
--		,[intCurrencyExchangeRateId]		= (CASE WHEN @GroupingOption = 0 THEN IE.[intCurrencyExchangeRateId] ELSE NULL END)				
--		,[dblCurrencyExchangeRate]			= (CASE WHEN @GroupingOption = 0 THEN IE.[dblCurrencyExchangeRate] ELSE NULL END)				
--		,[ysnAllowOverpayment]				= (CASE WHEN @GroupingOption = 0 THEN IE.[ysnAllowOverpayment] ELSE NULL END)				
--	FROM
--		@PaymentEntries IE
--	INNER JOIN
--		#EntriesForProcessing EFP WITH (NOLOCK)
--			ON IE.[intId] = EFP.[intId]
--	WHERE
--		ISNULL(EFP.[ysnForInsert],0) = 1
--	ORDER BY
--		[intId]
			
--	BEGIN TRY		
--		EXEC [dbo].[uspARCreateCustomerPayments]
--			 	 @PaymentEntries	= @PaymentsForInsert
--				,@IntegrationLogId	= @IntegrationLogId
--				,@GroupingOption	= @GroupingOption
--				,@UserId			= @UserId
--				,@RaiseError		= @RaiseError
--				,@ErrorMessage		= @CurrentErrorMessage
			
	
--		IF LEN(ISNULL(@CurrentErrorMessage,'')) > 0
--			BEGIN
--				IF ISNULL(@RaiseError,0) = 0
--					ROLLBACK TRANSACTION
--				SET @ErrorMessage = @CurrentErrorMessage;
--				IF ISNULL(@RaiseError,0) = 1
--					RAISERROR(@ErrorMessage, 16, 1);
--				RETURN 0;
--			END
--	END TRY
--	BEGIN CATCH
--		IF ISNULL(@RaiseError,0) = 0
--			ROLLBACK TRANSACTION
--		SET @ErrorMessage = ERROR_MESSAGE();
--		IF ISNULL(@RaiseError,0) = 1
--			RAISERROR(@ErrorMessage, 16, 1);
--		RETURN 0;
--	END CATCH	   
			
--	IF (EXISTS(SELECT TOP 1 NULL FROM tblARInvoiceIntegrationLogDetail WITH (NOLOCK) WHERE [intIntegrationLogId] = @IntegrationLogId AND ISNULL([ysnSuccess],0) = 1 AND ISNULL([ysnHeader],0) = 1  AND ISNULL([ysnInsert], 0) = 1) AND @GroupingOption > 0)
--	BEGIN

--		UPDATE EFP
--		SET EFP.[intInvoiceId] = IL.[intInvoiceId]
--		FROM
--			#EntriesForProcessing EFP
--		INNER JOIN
--			(SELECT [intId], [intInvoiceId], [ysnSuccess], [ysnHeader] FROM tblARInvoiceIntegrationLogDetail WITH (NOLOCK) WHERE [intIntegrationLogId] = @IntegrationLogId) IL
--				ON EFP.[intId] = IL.[intId]
--				AND ISNULL(IL.[ysnHeader], 0) = 1
--				AND ISNULL(IL.[ysnSuccess], 0) = 1		
			
		
--		DECLARE @LineItems PaymentIntegrationStagingTable
--		INSERT INTO @LineItems
--			([intId]
--			,[strTransactionType]
--			,[strType]
--			,[strSourceTransaction]
--			,[strSourceId]
--			,[intInvoiceId]
--			,[intEntityCustomerId]
--			,[intEntityContactId]
--			,[intCompanyLocationId]
--			,[intAccountId]
--			,[intCurrencyId]
--			,[intTermId]
--			,[intPeriodsToAccrue]
--			,[dtmDate]
--			,[dtmDueDate]
--			,[dtmShipDate]
--			,[dtmPostDate]
--			,[intEntitySalespersonId]
--			,[intFreightTermId]
--			,[intShipViaId]
--			,[intPaymentMethodId]
--			,[strInvoiceOriginId]
--			,[ysnUseOriginIdAsInvoiceNumber]
--			,[strPONumber]
--			,[strBOLNumber]
--			,[strDeliverPickup]
--			,[strComments]
--			,[intShipToLocationId]
--			,[intBillToLocationId]
--			,[ysnForgiven]
--			,[ysnCalculated]
--			,[ysnSplitted]
--			,[intPaymentId]
--			,[intSplitId]
--			,[intLoadDistributionHeaderId]
--			,[strActualCostId]
--			,[intShipmentId]
--			,[intTransactionId]
--			,[intMeterReadingId]
--			,[intContractHeaderId]
--			,[intLoadId]
--			,[intOriginalInvoiceId]
--			,[intEntityId]
--			,[intTruckDriverId]
--			,[intTruckDriverReferenceId]
--			,[ysnResetDetails]
--			,[ysnRecap]
--			,[ysnPost]
--			,[ysnUpdateAvailableDiscount]
--			,[ysnInsertDetail]
--			,[intInvoiceDetailId]
--			,[intItemId]
--			,[intPrepayTypeId]
--			,[ysnRestricted]
--			,[ysnInventory]
--			,[strDocumentNumber]
--			,[strItemDescription]
--			,[intOrderUOMId]
--			,[dblQtyOrdered]
--			,[intItemUOMId]
--			,[dblQtyShipped]
--			,[dblDiscount]
--			,[dblItemTermDiscount]
--			,[strItemTermDiscountBy]
--			,[dblItemWeight]
--			,[intItemWeightUOMId]
--			,[dblPrice]
--			,[strPricing]
--			,[strVFDDocumentNumber]
--			,[ysnRefreshPrice]
--			,[strMaintenanceType]
--			,[strFrequency]
--			,[intMaintenanceAccountId]
--			,[dtmMaintenanceDate]
--			,[dblMaintenanceAmount]
--			,[intLicenseAccountId]
--			,[dblLicenseAmount]
--			,[intTaxGroupId]
--			,[intStorageLocationId]
--			,[intCompanyLocationSubLocationId]
--			,[ysnRecomputeTax]
--			,[intSCInvoiceId]
--			,[strSCInvoiceNumber]
--			,[intSCBudgetId]
--			,[strSCBudgetDescription]
--			,[intInventoryShipmentItemId]
--			,[intInventoryShipmentChargeId]
--			,[strShipmentNumber]
--			,[intRecipeItemId]
--			,[intRecipeId]
--			,[intSubLocationId]
--			,[intCostTypeId]
--			,[intMarginById]
--			,[intCommentTypeId]
--			,[dblMargin]
--			,[dblRecipeQuantity]
--			,[intSalesOrderDetailId]
--			,[strSalesOrderNumber]
--			,[intContractDetailId]
--			,[intShipmentPurchaseSalesContractId]
--			,[dblShipmentGrossWt]
--			,[dblShipmentTareWt]
--			,[dblShipmentNetWt]
--			,[intTicketId]
--			,[intTicketHoursWorkedId]
--			,[intDocumentMaintenanceId]
--			,[intCustomerStorageId]
--			,[intSiteDetailId]
--			,[intLoadDetailId]
--			,[intLotId]
--			,[intOriginalInvoiceDetailId]
--			,[intSiteId]
--			,[strBillingBy]
--			,[dblPercentFull]
--			,[dblNewMeterReading]
--			,[dblPreviousMeterReading]
--			,[dblConversionFactor]
--			,[intPerformerId]
--			,[ysnLeaseBilling]
--			,[ysnVirtualMeterReading]
--			,[ysnClearDetailTaxes]
--			,[intTempDetailIdForTaxes]
--			,[intCurrencyExchangeRateTypeId]
--			,[intCurrencyExchangeRateId]
--			,[dblCurrencyExchangeRate]
--			,[intSubCurrencyId]
--			,[dblSubCurrencyRate]
--			,[ysnBlended]
--			,[strImportFormat]
--			,[dblCOGSAmount]
--			,[intConversionAccountId]
--			,[intSalesAccountId]
--			,[intStorageScheduleTypeId]
--			,[intDestinationGradeId]
--			,[intDestinationWeightId])
--		SELECT
--			 [intId]								= ITG.[intId]
--			,[strTransactionType]					= ARI.[strTransactionType]
--			,[strType]								= ARI.[strType]
--			,[strSourceTransaction]					= ITG.[strSourceTransaction]
--			,[strSourceId]							= ITG.[strSourceId]
--			,[intInvoiceId]							= ARI.[intInvoiceId]
--			,[intEntityCustomerId]					= ARI.[intEntityCustomerId]
--			,[intEntityContactId]					= ARI.[intEntityContactId]
--			,[intCompanyLocationId]					= ARI.[intCompanyLocationId]
--			,[intAccountId]							= ARI.[intAccountId]
--			,[intCurrencyId]						= ARI.[intCurrencyId]
--			,[intTermId]							= ARI.[intTermId]
--			,[intPeriodsToAccrue]					= ARI.[intPeriodsToAccrue]
--			,[dtmDate]								= ARI.[dtmDate]
--			,[dtmDueDate]							= ARI.[dtmDueDate]
--			,[dtmShipDate]							= ARI.[dtmShipDate]
--			,[dtmPostDate]							= ARI.[dtmPostDate]
--			,[intEntitySalespersonId]				= ARI.[intEntitySalespersonId]
--			,[intFreightTermId]						= ARI.[intFreightTermId]
--			,[intShipViaId]							= ARI.[intShipViaId]
--			,[intPaymentMethodId]					= ARI.[intPaymentMethodId]
--			,[strInvoiceOriginId]					= ARI.[strInvoiceOriginId]
--			,[ysnUseOriginIdAsInvoiceNumber]		= ITG.[ysnUseOriginIdAsInvoiceNumber]
--			,[strPONumber]							= ARI.[strPONumber]
--			,[strBOLNumber]							= ARI.[strBOLNumber]
--			,[strDeliverPickup]						= ARI.[strDeliverPickup]
--			,[strComments]							= ARI.[strComments]
--			,[intShipToLocationId]					= ARI.[intShipToLocationId]
--			,[intBillToLocationId]					= ARI.[intBillToLocationId]
--			,[ysnForgiven]							= ARI.[ysnForgiven]
--			,[ysnCalculated]						= ARI.[ysnCalculated]
--			,[ysnSplitted]							= ARI.[ysnSplitted]
--			,[intPaymentId]							= ARI.[intPaymentId]
--			,[intSplitId]							= ARI.[intSplitId]
--			,[intLoadDistributionHeaderId]			= ARI.[intLoadDistributionHeaderId]
--			,[strActualCostId]						= ARI.[strActualCostId]
--			,[intShipmentId]						= ARI.[intShipmentId]
--			,[intTransactionId]						= ARI.[intTransactionId]
--			,[intMeterReadingId]					= ARI.[intMeterReadingId]
--			,[intContractHeaderId]					= ARI.[intContractHeaderId]
--			,[intLoadId]							= ARI.[intLoadId]
--			,[intOriginalInvoiceId]					= ARI.[intOriginalInvoiceId]
--			,[intEntityId]							= ARI.[intEntityId]
--			,[intTruckDriverId]						= ARI.[intTruckDriverId]
--			,[intTruckDriverReferenceId]			= ARI.[intTruckDriverReferenceId]
--			,[ysnResetDetails]						= ITG.[ysnResetDetails]
--			,[ysnRecap]								= ITG.[ysnRecap]
--			,[ysnPost]								= ITG.[ysnPost]
--			,[ysnUpdateAvailableDiscount]			= ITG.[ysnUpdateAvailableDiscount]
--			,[ysnInsertDetail]						= ITG.[ysnInsertDetail]
--			,[intInvoiceDetailId]					= ITG.[intInvoiceDetailId]
--			,[intItemId]							= ITG.[intItemId]
--			,[intPrepayTypeId]						= ITG.[intPrepayTypeId]
--			,[ysnRestricted]						= ITG.[ysnRestricted]
--			,[ysnInventory]							= ITG.[ysnInventory]
--			,[strDocumentNumber]					= ITG.[strDocumentNumber]
--			,[strItemDescription]					= ITG.[strItemDescription]
--			,[intOrderUOMId]						= ITG.[intOrderUOMId]
--			,[dblQtyOrdered]						= ITG.[dblQtyOrdered]
--			,[intItemUOMId]							= ITG.[intItemUOMId]
--			,[dblQtyShipped]						= ITG.[dblQtyShipped]
--			,[dblDiscount]							= ITG.[dblDiscount]
--			,[dblItemTermDiscount]					= ITG.[dblItemTermDiscount]
--			,[strItemTermDiscountBy]				= ITG.[strItemTermDiscountBy]
--			,[dblItemWeight]						= ITG.[dblItemWeight]
--			,[intItemWeightUOMId]					= ITG.[intItemWeightUOMId]
--			,[dblPrice]								= ITG.[dblPrice]
--			,[strPricing]							= ITG.[strPricing]
--			,[strVFDDocumentNumber]					= ITG.[strVFDDocumentNumber]
--			,[ysnRefreshPrice]						= ITG.[ysnRefreshPrice]
--			,[strMaintenanceType]					= ITG.[strMaintenanceType]
--			,[strFrequency]							= ITG.[strFrequency]
--			,[intMaintenanceAccountId]				= ITG.[intMaintenanceAccountId]
--			,[dtmMaintenanceDate]					= ITG.[dtmMaintenanceDate]
--			,[dblMaintenanceAmount]					= ITG.[dblMaintenanceAmount]
--			,[intLicenseAccountId]					= ITG.[intLicenseAccountId]
--			,[dblLicenseAmount]						= ITG.[dblLicenseAmount]
--			,[intTaxGroupId]						= ITG.[intTaxGroupId]
--			,[intStorageLocationId]					= ITG.[intStorageLocationId]
--			,[intCompanyLocationSubLocationId]		= ITG.[intCompanyLocationSubLocationId]
--			,[ysnRecomputeTax]						= ITG.[ysnRecomputeTax]
--			,[intSCInvoiceId]						= ITG.[intSCInvoiceId]
--			,[strSCInvoiceNumber]					= ITG.[strSCInvoiceNumber]
--			,[intSCBudgetId]						= ITG.[intSCBudgetId]
--			,[strSCBudgetDescription]				= ITG.[strSCBudgetDescription]
--			,[intInventoryShipmentItemId]			= ITG.[intInventoryShipmentItemId]
--			,[intInventoryShipmentChargeId]			= ITG.[intInventoryShipmentChargeId]
--			,[strShipmentNumber]					= ITG.[strShipmentNumber]
--			,[intRecipeItemId]						= ITG.[intRecipeItemId]
--			,[intRecipeId]							= ITG.[intRecipeId]
--			,[intSubLocationId]						= ITG.[intSubLocationId]
--			,[intCostTypeId]						= ITG.[intCostTypeId]
--			,[intMarginById]						= ITG.[intMarginById]
--			,[intCommentTypeId]						= ITG.[intCommentTypeId]
--			,[dblMargin]							= ITG.[dblMargin]
--			,[dblRecipeQuantity]					= ITG.[dblRecipeQuantity]
--			,[intSalesOrderDetailId]				= ITG.[intSalesOrderDetailId]
--			,[strSalesOrderNumber]					= ITG.[strSalesOrderNumber]
--			,[intContractDetailId]					= ITG.[intContractDetailId]
--			,[intShipmentPurchaseSalesContractId]	= ITG.[intShipmentPurchaseSalesContractId]
--			,[dblShipmentGrossWt]					= ITG.[dblShipmentGrossWt]
--			,[dblShipmentTareWt]					= ITG.[dblShipmentTareWt]
--			,[dblShipmentNetWt]						= ITG.[dblShipmentNetWt]
--			,[intTicketId]							= ITG.[intTicketId]
--			,[intTicketHoursWorkedId]				= ITG.[intTicketHoursWorkedId]
--			,[intDocumentMaintenanceId]				= ITG.[intDocumentMaintenanceId]
--			,[intCustomerStorageId]					= ITG.[intCustomerStorageId]
--			,[intSiteDetailId]						= ITG.[intSiteDetailId]
--			,[intLoadDetailId]						= ITG.[intLoadDetailId]
--			,[intLotId]								= ITG.[intLotId]
--			,[intOriginalInvoiceDetailId]			= ITG.[intOriginalInvoiceDetailId]
--			,[intSiteId]							= ITG.[intSiteId]
--			,[strBillingBy]							= ITG.[strBillingBy]
--			,[dblPercentFull]						= ITG.[dblPercentFull]
--			,[dblNewMeterReading]					= ITG.[dblNewMeterReading]
--			,[dblPreviousMeterReading]				= ITG.[dblPreviousMeterReading]
--			,[dblConversionFactor]					= ITG.[dblConversionFactor]
--			,[intPerformerId]						= ITG.[intPerformerId]
--			,[ysnLeaseBilling]						= ITG.[ysnLeaseBilling]
--			,[ysnVirtualMeterReading]				= ITG.[ysnVirtualMeterReading]
--			,[ysnClearDetailTaxes]					= ITG.[ysnClearDetailTaxes]
--			,[intTempDetailIdForTaxes]				= ITG.[intTempDetailIdForTaxes]
--			,[intCurrencyExchangeRateTypeId]		= ITG.[intCurrencyExchangeRateTypeId]
--			,[intCurrencyExchangeRateId]			= ITG.[intCurrencyExchangeRateId]
--			,[dblCurrencyExchangeRate]				= ITG.[dblCurrencyExchangeRate]
--			,[intSubCurrencyId]						= ITG.[intSubCurrencyId]
--			,[dblSubCurrencyRate]					= ITG.[dblSubCurrencyRate]
--			,[ysnBlended]							= ITG.[ysnBlended]
--			,[strImportFormat]						= ITG.[strImportFormat]
--			,[dblCOGSAmount]						= ITG.[dblCOGSAmount]
--			,[intConversionAccountId]				= ITG.[intConversionAccountId]
--			,[intSalesAccountId]					= ITG.[intSalesAccountId]
--			,[intStorageScheduleTypeId]				= ITG.[intStorageScheduleTypeId]
--			,[intDestinationGradeId]				= ITG.[intDestinationGradeId]
--			,[intDestinationWeightId]				= ITG.[intDestinationWeightId]
--		FROM
--			@PaymentEntries ITG
--		INNER JOIN
--			#EntriesForProcessing EFP WITH (NOLOCK)
--				ON (ISNULL(ITG.[intId], 0) = ISNULL(EFP.[intId], 0) OR @GroupingOption > 0)
--				AND (ISNULL(ITG.[intEntityCustomerId], 0) = ISNULL(EFP.[intEntityCustomerId], 0) OR (EFP.[intEntityCustomerId] IS NULL AND @GroupingOption < 1))
--				AND (ISNULL(ITG.[intSourceId], 0) = ISNULL(EFP.[intSourceId], 0) OR (EFP.[intSourceId] IS NULL AND (@GroupingOption < 2 OR ITG.[strSourceTransaction] IN ('Sale OffSite','Settle Storage','Process Grain Storage','Transfer Storage','Load/Shipment Schedules','Credit Card Reconciliation', 'CF Invoice'))))
--				AND (ISNULL(ITG.[intCompanyLocationId], 0) = ISNULL(EFP.[intCompanyLocationId], 0) OR (EFP.[intCompanyLocationId] IS NULL AND @GroupingOption < 3))
--				AND (ISNULL(ITG.[intCurrencyId],0) = ISNULL(EFP.[intCurrencyId],0) OR (EFP.[intCurrencyId] IS NULL AND @GroupingOption < 4))
--				AND (CAST(ISNULL(ITG.[dtmDate], @DateNow) AS DATE) = CAST(ISNULL(EFP.[dtmDate], @DateNow) AS DATE) OR (EFP.[dtmDate] IS NULL AND @GroupingOption < 5))
--				AND (ISNULL(ITG.[intTermId],0) = ISNULL(EFP.[intTermId],0) OR (EFP.[intTermId] IS NULL AND @GroupingOption < 6))        
--				AND (ISNULL(ITG.[intShipViaId],0) = ISNULL(EFP.[intShipViaId],0) OR (EFP.[intShipViaId] IS NULL AND @GroupingOption < 7))
--				AND (ISNULL(ITG.[intEntitySalespersonId],0) = ISNULL(EFP.[intEntitySalespersonId],0) OR (EFP.[intEntitySalespersonId] IS NULL AND @GroupingOption < 8))
--				AND (ISNULL(ITG.[strPONumber],'') = ISNULL(EFP.[strPONumber],'') OR (EFP.[strPONumber] IS NULL AND @GroupingOption < 9))        
--				AND (ISNULL(ITG.[strBOLNumber],'') = ISNULL(EFP.[strBOLNumber],'') OR (EFP.[strBOLNumber] IS NULL AND @GroupingOption < 10))    
--				AND (ISNULL(ITG.[strComments],'') = ISNULL(EFP.[strComments],'') OR (EFP.[strComments] IS NULL AND @GroupingOption < 11))
--				AND (ISNULL(ITG.[intAccountId],0) = ISNULL(EFP.[intAccountId],0) OR (EFP.[intAccountId] IS NULL AND @GroupingOption < 12))
--				AND (ISNULL(ITG.[intFreightTermId],0) = ISNULL(EFP.[intFreightTermId],0) OR (EFP.[intFreightTermId] IS NULL AND @GroupingOption < 13))
--				AND (ISNULL(ITG.[intPaymentMethodId],0) = ISNULL(EFP.[intPaymentMethodId],0) OR (EFP.[intPaymentMethodId] IS NULL AND @GroupingOption < 14))            
--				AND (ISNULL(ITG.[strInvoiceOriginId],'') = ISNULL(EFP.[strInvoiceOriginId],'') OR (EFP.[strInvoiceOriginId] IS NULL AND @GroupingOption < 15))
--		INNER JOIN
--			(SELECT
--				 [strTransactionType]
--				,[strType]
--				,[intInvoiceId]
--				,[intEntityCustomerId]
--				,[intEntityContactId]
--				,[intCompanyLocationId]
--				,[intAccountId]
--				,[intCurrencyId]
--				,[intTermId]
--				,[intPeriodsToAccrue]
--				,[dtmDate]
--				,[dtmDueDate]
--				,[dtmShipDate]
--				,[dtmPostDate]
--				,[intEntitySalespersonId]
--				,[intFreightTermId]
--				,[intShipViaId]
--				,[intPaymentMethodId]
--				,[strInvoiceOriginId]
--				,[strPONumber]
--				,[strBOLNumber]
--				,[strDeliverPickup]
--				,[strComments]
--				,[intShipToLocationId]
--				,[intBillToLocationId]
--				,[ysnForgiven]
--				,[ysnCalculated]
--				,[ysnSplitted]
--				,[intPaymentId]
--				,[intSplitId]
--				,[intLoadDistributionHeaderId]
--				,[strActualCostId]
--				,[intShipmentId]
--				,[intTransactionId]
--				,[intMeterReadingId]
--				,[intContractHeaderId]
--				,[intLoadId]
--				,[intOriginalInvoiceId]
--				,[intEntityId]
--				,[intTruckDriverId]
--				,[intTruckDriverReferenceId]
--			 FROM tblARInvoice WITH (NOLOCK)) ARI
--				ON EFP.[intInvoiceId] = ARI.[intInvoiceId] 
--			 WHERE
--				ISNULL(EFP.[ysnForInsert],0) = 1


--		EXEC [dbo].[uspARAddItemToInvoices]
--			 @PaymentEntries	= @LineItems
--			,@IntegrationLogId	= @IntegrationLogId
--			,@UserId			= @UserId
--			,@RaiseError		= @RaiseError
--			,@ErrorMessage		= @CurrentErrorMessage	OUTPUT

--		IF LEN(ISNULL(@CurrentErrorMessage,'')) > 0
--			BEGIN
--				IF ISNULL(@RaiseError,0) = 0
--					ROLLBACK TRANSACTION
--				SET @ErrorMessage = @CurrentErrorMessage;
--				IF ISNULL(@RaiseError,0) = 1
--					RAISERROR(@ErrorMessage, 16, 1);
--				RETURN 0;
--			END

--		DELETE FROM @TaxDetails
--		INSERT INTO @TaxDetails
--			([intId]
--			,[intDetailId]
--			,[intDetailTaxId]
--			,[intTaxGroupId]
--			,[intTaxCodeId]
--			,[intTaxClassId]
--			,[strTaxableByOtherTaxes]
--			,[strCalculationMethod]
--			,[dblRate]
--			,[intTaxAccountId]
--			,[dblTax]
--			,[dblAdjustedTax]
--			,[ysnTaxAdjusted]
--			,[ysnSeparateOnInvoice]
--			,[ysnCheckoffTax]
--			,[ysnTaxExempt]
--			,[strNotes]
--			,[intTempDetailIdForTaxes]
--			,[dblCurrencyExchangeRate]
--			,[ysnClearExisting]
--			,[strTransactionType]
--			,[strType]
--			,[strSourceTransaction]
--			,[intSourceId]
--			,[strSourceId]
--			,[intHeaderId]
--			,[dtmDate])
--		SELECT
--			 [intId]						= ARIILD.[intId]
--			,[intDetailId]					= ARIILD.[intInvoiceDetailId]
--			,[intDetailTaxId]				= LITE.[intDetailTaxId]
--			,[intTaxGroupId]				= LITE.[intTaxGroupId]
--			,[intTaxCodeId]					= LITE.[intTaxCodeId]
--			,[intTaxClassId]				= LITE.[intTaxClassId]
--			,[strTaxableByOtherTaxes]		= LITE.[strTaxableByOtherTaxes]
--			,[strCalculationMethod]			= LITE.[strCalculationMethod]
--			,[dblRate]						= LITE.[dblRate]
--			,[intTaxAccountId]				= LITE.[intTaxAccountId]
--			,[dblTax]						= LITE.[dblTax]
--			,[dblAdjustedTax]				= LITE.[dblAdjustedTax]
--			,[ysnTaxAdjusted]				= LITE.[ysnTaxAdjusted]
--			,[ysnSeparateOnInvoice]			= LITE.[ysnSeparateOnInvoice]
--			,[ysnCheckoffTax]				= LITE.[ysnCheckoffTax]
--			,[ysnTaxExempt]					= LITE.[ysnTaxExempt]
--			,[strNotes]						= LITE.[strNotes]
--			,[intTempDetailIdForTaxes]		= LITE.[intTempDetailIdForTaxes]
--			,[dblCurrencyExchangeRate]		= ISNULL(IFI.[dblCurrencyExchangeRate], 1.000000)
--			,[ysnClearExisting]				= IFI.[ysnClearDetailTaxes]
--			,[strTransactionType]			= ARIILD.[strTransactionType]
--			,[strType]						= ARIILD.[strType]
--			,[strSourceTransaction]			= ARIILD.[strSourceTransaction]
--			,[intSourceId]					= ARIILD.[intSourceId]
--			,[strSourceId]					= ARIILD.[strSourceId]
--			,[intHeaderId]					= ARIILD.[intInvoiceId]
--			,[dtmDate]						= ISNULL(IFI.[dtmDate], @DateNow)
--		FROM
--			@LineItemTaxEntries  LITE
--		INNER JOIN
--			(SELECT [intInvoiceId], [intInvoiceDetailId], [intTemporaryDetailIdForTax], [ysnHeader], [ysnSuccess], [intId], [strTransactionType], [strType], [strSourceTransaction], [intIntegrationLogId], [intSourceId], [strSourceId], [ysnInsert] FROM tblARInvoiceIntegrationLogDetail WITH (NOLOCK)) ARIILD
--				ON LITE.[intTempDetailIdForTaxes] = ARIILD.[intTemporaryDetailIdForTax]
--				AND ISNULL(ARIILD.[ysnHeader], 0) = 0
--				AND ISNULL(ARIILD.[ysnSuccess], 0) = 1
--				AND ISNULL(ARIILD.[intInvoiceDetailId], 0) <> 0
--				AND ISNULL(ARIILD.[ysnInsert], 0) = 1
--		INNER JOIN
--			(SELECT [intId], [ysnClearDetailTaxes], [dtmDate], [dblCurrencyExchangeRate] FROM @PaymentsForInsert) IFI
--				ON IFI. [intId] = ARIILD.[intId]
--		WHERE
--			ARIILD.[intIntegrationLogId] = @IntegrationLogId


--		EXEC	[dbo].[uspARProcessTaxDetailsForLineItems]
--					 @TaxDetails			= @TaxDetails
--					,@IntegrationLogId		= @IntegrationLogId
--					,@UserId				= @UserId
--					,@ReComputeInvoices		= 0
--					,@RaiseError			= @RaiseError
--					,@ErrorMessage			= @CurrentErrorMessage OUTPUT

--		IF LEN(ISNULL(@CurrentErrorMessage,'')) > 0
--			BEGIN
--				IF ISNULL(@RaiseError,0) = 0
--					ROLLBACK TRANSACTION
--				SET @ErrorMessage = @CurrentErrorMessage;
--				IF ISNULL(@RaiseError,0) = 1
--					RAISERROR(@ErrorMessage, 16, 1);
--				RETURN 0;
--			END		
--	END	

--	DECLARE @InsertedInvoiceIds InvoiceId	
--	DELETE FROM @InsertedInvoiceIds

--	INSERT INTO @InsertedInvoiceIds(
--		 [intHeaderId]
--		,[ysnUpdateAvailableDiscountOnly]
--		,[intDetailId]
--		,[ysnForDelete]
--		,[ysnFromPosting]
--		,[ysnPost]
--		,[ysnAccrueLicense]
--		,[strTransactionType]
--		,[strSourceTransaction]
--		,[ysnProcessed])
--	SELECT
--		 [intHeaderId]						= ARIILD.[intInvoiceId]
--		,[ysnUpdateAvailableDiscountOnly]	= IFI.[ysnUpdateAvailableDiscount]
--		,[intDetailId]						= NULL
--		,[ysnForDelete]						= 0
--		,[ysnFromPosting]					= 0
--		,[ysnPost]							= ARIILD.[ysnPost]
--		,[ysnAccrueLicense]					= ARIILD.[ysnAccrueLicense]
--		,[strTransactionType]				= ARIILD.[strTransactionType]
--		,[strSourceTransaction]				= IFI.[strSourceTransaction]
--		,[ysnProcessed]						= 0
--		FROM
--		(SELECT [intInvoiceId], [ysnHeader], [ysnSuccess], [intId], [intIntegrationLogId], [strTransactionType], [ysnPost], [ysnAccrueLicense] FROM tblARInvoiceIntegrationLogDetail WITH (NOLOCK)) ARIILD
--		INNER JOIN
--		(SELECT [intId], [ysnUpdateAvailableDiscount], [strSourceTransaction] FROM @PaymentsForInsert) IFI
--			ON IFI. [intId] = ARIILD.[intId] 
--	WHERE
--			ISNULL(ARIILD.[ysnHeader], 0) = 1
--			AND ISNULL(ARIILD.[ysnSuccess], 0) = 1
--			AND ISNULL(ARIILD.[intInvoiceId], 0) <> 0


--	EXEC	[dbo].[uspARUpdateInvoicesIntegrations]
--				 @InvoiceIds			= @InsertedInvoiceIds
--				,@UserId				= @UserId

--	EXEC [dbo].[uspARReComputeInvoicesAmounts] @InvoiceIds = @InsertedInvoiceIds
		
--END

--END TRY
--BEGIN CATCH
--	IF ISNULL(@RaiseError,0) = 0
--		ROLLBACK TRANSACTION
--	SET @ErrorMessage = ERROR_MESSAGE();
--	IF ISNULL(@RaiseError,0) = 1
--		RAISERROR(@ErrorMessage, 16, 1);
--	RETURN 0;
--END CATCH

IF ISNULL(@RaiseError,0) = 0
	COMMIT TRANSACTION 
	
RETURN 1;

END