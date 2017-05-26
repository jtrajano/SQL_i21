CREATE PROCEDURE [dbo].[uspARProcessInvoicesByBatch]
	 @InvoiceEntries				InvoiceStagingTable								READONLY	
	,@LineItemTaxEntries			LineItemTaxDetailStagingTable					READONLY
	,@UserId						INT
	,@GroupingOption				INT								= 0	
																	-- 0  = [intId] - An Invoice will be created for each record in @InvoiceEntries
																	-- 1  = [intEntityCustomerId]
																	-- 2  = [intEntityCustomerId], [intSourceId]
																	-- 3  = [intEntityCustomerId], [intSourceId], [intCompanyLocationId]
																	-- 4  = [intEntityCustomerId], [intSourceId], [intCompanyLocationId], [intCurrencyId]
																	-- 5  = [intEntityCustomerId], [intSourceId], [intCompanyLocationId], [intCurrencyId], [dtmDate]
																	-- 6  = [intEntityCustomerId], [intSourceId], [intCompanyLocationId], [intCurrencyId], [dtmDate], [intTermId]
																	-- 7  = [intEntityCustomerId], [intSourceId], [intCompanyLocationId], [intCurrencyId], [dtmDate], [intTermId], [intShipViaId]
																	-- 8  = [intEntityCustomerId], [intSourceId], [intCompanyLocationId], [intCurrencyId], [dtmDate], [intTermId], [intShipViaId], [intEntitySalespersonId]
																	-- 9  = [intEntityCustomerId], [intSourceId], [intCompanyLocationId], [intCurrencyId], [dtmDate], [intTermId], [intShipViaId], [intEntitySalespersonId], [strPONumber]
																	-- 10 = [intEntityCustomerId], [intSourceId], [intCompanyLocationId], [intCurrencyId], [dtmDate], [intTermId], [intShipViaId], [intEntitySalespersonId], [strPONumber], [strBOLNumber]
																	-- 11 = [intEntityCustomerId], [intSourceId], [intCompanyLocationId], [intCurrencyId], [dtmDate], [intTermId], [intShipViaId], [intEntitySalespersonId], [strPONumber], [strBOLNumber], [strComments]
																	-- 12 = [intEntityCustomerId], [intSourceId], [intCompanyLocationId], [intCurrencyId], [dtmDate], [intTermId], [intShipViaId], [intEntitySalespersonId], [strPONumber], [strBOLNumber], [strComments], [intAccountId]
																	-- 13 = [intEntityCustomerId], [intSourceId], [intCompanyLocationId], [intCurrencyId], [dtmDate], [intTermId], [intShipViaId], [intEntitySalespersonId], [strPONumber], [strBOLNumber], [strComments], [intAccountId], [intFreightTermId]
																	-- 14 = [intEntityCustomerId], [intSourceId], [intCompanyLocationId], [intCurrencyId], [dtmDate], [intTermId], [intShipViaId], [intEntitySalespersonId], [strPONumber], [strBOLNumber], [strComments], [intAccountId], [intFreightTermId], [intPaymentMethodId]
																	-- 15 = [intEntityCustomerId], [intSourceId], [intCompanyLocationId], [intCurrencyId], [dtmDate], [intTermId], [intShipViaId], [intEntitySalespersonId], [strPONumber], [strBOLNumber], [strComments], [intAccountId], [intFreightTermId], [intPaymentMethodId], [strInvoiceOriginId]
	,@RaiseError					BIT								= 0
	,@ErrorMessage					NVARCHAR(250)					= NULL			OUTPUT
	,@LogId							INT								= 0				OUTPUT
	
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
	IF OBJECT_ID('tempdb..#TempInvoiceEntries') IS NOT NULL DROP TABLE #TempInvoiceEntries	
	SELECT * INTO #TempInvoiceEntries FROM @InvoiceEntries 
	WHERE 
		(ISNULL([intSourceId],0) <> 0 AND [strSourceTransaction] NOT IN ('Sale OffSite','Settle Storage','Process Grain Storage','Transfer Storage','Load/Shipment Schedules','Credit Card Reconciliation')) 
		OR
		(ISNULL([intSourceId],0) = 0 AND [strSourceTransaction] IN ('Sale OffSite','Settle Storage','Process Grain Storage','Transfer Storage','Load/Shipment Schedules','Credit Card Reconciliation', 'CF Invoice', 'Direct')) 


	IF OBJECT_ID('tempdb..#EntriesForProcessing') IS NOT NULL DROP TABLE #EntriesForProcessing	
	CREATE TABLE #EntriesForProcessing(
		 [intId]						INT												NOT NULL
		,[intSourceId]					INT												NULL
		,[intEntityCustomerId]			INT												NULL
		,[dtmDate]						DATETIME										NULL
		,[intCurrencyId]				INT												NULL
		,[intCompanyLocationId]			INT												NULL
		,[intTermId]					INT												NULL
		,[intEntitySalespersonId]		INT												NULL
		,[intShipViaId]					INT												NULL
		,[strPONumber]					NVARCHAR (25)	COLLATE Latin1_General_CI_AS	NULL
		,[strBOLNumber]					NVARCHAR (50)	COLLATE Latin1_General_CI_AS	NULL
		,[strComments]					NVARCHAR (500)  COLLATE Latin1_General_CI_AS	NULL
		,[intAccountId]					INT												NULL
		,[intFreightTermId]				INT												NULL
		,[intPaymentMethodId]			INT												NULL
		,[strInvoiceOriginId]			NVARCHAR (25)	COLLATE Latin1_General_CI_AS	NULL
		,[strInvoiceNumber]				NVARCHAR (50)	COLLATE Latin1_General_CI_AS	NULL
		,[intInvoiceId]					INT												NULL
		,[intInvoiceDetailId]			INT												NULL
		,[ysnProcessed]					BIT												NULL
		,[ysnRecomputed]				BIT												NULL
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
						WHEN @GroupingOption = 2 THEN '[intEntityCustomerId], [intSourceId]'
						WHEN @GroupingOption = 3 THEN '[intEntityCustomerId], [intSourceId], [intCompanyLocationId]'
						WHEN @GroupingOption = 4 THEN '[intEntityCustomerId], [intSourceId], [intCompanyLocationId], [intCurrencyId]'
						WHEN @GroupingOption = 5 THEN '[intEntityCustomerId], [intSourceId], [intCompanyLocationId], [intCurrencyId], [dtmDate]'
						WHEN @GroupingOption = 6 THEN '[intEntityCustomerId], [intSourceId], [intCompanyLocationId], [intCurrencyId], [dtmDate], [intTermId]'
						WHEN @GroupingOption = 7 THEN '[intEntityCustomerId], [intSourceId], [intCompanyLocationId], [intCurrencyId], [dtmDate], [intTermId], [intShipViaId]'
						WHEN @GroupingOption = 8 THEN '[intEntityCustomerId], [intSourceId], [intCompanyLocationId], [intCurrencyId], [dtmDate], [intTermId], [intShipViaId], [intEntitySalespersonId]'
						WHEN @GroupingOption = 9 THEN '[intEntityCustomerId], [intSourceId], [intCompanyLocationId], [intCurrencyId], [dtmDate], [intTermId], [intShipViaId], [intEntitySalespersonId], [strPONumber]'
						WHEN @GroupingOption =10 THEN '[intEntityCustomerId], [intSourceId], [intCompanyLocationId], [intCurrencyId], [dtmDate], [intTermId], [intShipViaId], [intEntitySalespersonId], [strPONumber], [strBOLNumber]'
						WHEN @GroupingOption =11 THEN '[intEntityCustomerId], [intSourceId], [intCompanyLocationId], [intCurrencyId], [dtmDate], [intTermId], [intShipViaId], [intEntitySalespersonId], [strPONumber], [strBOLNumber], [strComments]'
						WHEN @GroupingOption =12 THEN '[intEntityCustomerId], [intSourceId], [intCompanyLocationId], [intCurrencyId], [dtmDate], [intTermId], [intShipViaId], [intEntitySalespersonId], [strPONumber], [strBOLNumber], [strComments], [intAccountId]'
						WHEN @GroupingOption =13 THEN '[intEntityCustomerId], [intSourceId], [intCompanyLocationId], [intCurrencyId], [dtmDate], [intTermId], [intShipViaId], [intEntitySalespersonId], [strPONumber], [strBOLNumber], [strComments], [intAccountId], [intFreightTermId]'
						WHEN @GroupingOption =14 THEN '[intEntityCustomerId], [intSourceId], [intCompanyLocationId], [intCurrencyId], [dtmDate], [intTermId], [intShipViaId], [intEntitySalespersonId], [strPONumber], [strBOLNumber], [strComments], [intAccountId], [intFreightTermId], [intPaymentMethodId]'
						WHEN @GroupingOption =15 THEN '[intEntityCustomerId], [intSourceId], [intCompanyLocationId], [intCurrencyId], [dtmDate], [intTermId], [intShipViaId], [intEntitySalespersonId], [strPONumber], [strBOLNumber], [strComments], [intAccountId], [intFreightTermId], [intPaymentMethodId], [strInvoiceOriginId]'
					END)
					
				
	IF @GroupingOption > 0
		SET @QueryString = 'INSERT INTO #EntriesForProcessing([intId], ' +  @Columns + ', [ysnForInsert]) SELECT MIN([intId]), ' + @Columns + ', 1 FROM #TempInvoiceEntries WHERE ISNULL([intInvoiceId],0) = 0 GROUP BY ' + @Columns
	ELSE
		SET @QueryString = 'INSERT INTO #EntriesForProcessing(' +  @Columns + ', [ysnForInsert]) SELECT ' + @Columns + ', 1 FROM #TempInvoiceEntries WHERE ISNULL([intInvoiceId],0) = 0 GROUP BY ' + @Columns

	EXECUTE(@QueryString);

	IF @GroupingOption > 0
		SET @QueryString = 'INSERT INTO #EntriesForProcessing([intId], [intInvoiceId], [intInvoiceDetailId], ' + @Columns + ', [ysnForUpdate]) SELECT DISTINCT [intId], [intInvoiceId], [intInvoiceDetailId], ' + @Columns + ', 1 FROM #TempInvoiceEntries WHERE ISNULL([intInvoiceId],0) <> 0 GROUP BY [intId], [intInvoiceId], [intInvoiceDetailId],' + @Columns
	ELSE
		SET @QueryString = 'INSERT INTO #EntriesForProcessing([intId], [intInvoiceId], [intInvoiceDetailId], [ysnForUpdate]) SELECT DISTINCT [intId], [intInvoiceId], [intInvoiceDetailId], 1 FROM #TempInvoiceEntries WHERE ISNULL([intInvoiceId],0) <> 0 GROUP BY [intId], [intInvoiceId], [intInvoiceDetailId]'

	EXECUTE(@QueryString);

	IF OBJECT_ID('tempdb..#TempInvoiceEntries') IS NOT NULL DROP TABLE #TempInvoiceEntries	
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
		EXEC [dbo].[uspARInsertInvoiceIntegrationLog]
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
	
DECLARE @TaxDetails AS LineItemTaxDetailStagingTable

BEGIN TRY
IF EXISTS(SELECT TOP 1 NULL FROM #EntriesForProcessing WITH (NOLOCK) WHERE ISNULL([ysnForInsert],0) = 1)
BEGIN
	DECLARE @NewSourceId INT = 0
	
	DECLARE @InvoicesForInsert	InvoiceStagingTable
	
					
	INSERT INTO @InvoicesForInsert(
		 [intId]
		,[strTransactionType]
		,[strType]
		,[strSourceTransaction]
		,[intSourceId]
		,[intPeriodsToAccrue]
		,[strSourceId]
		,[intInvoiceId]
		,[intEntityCustomerId]
		,[intCompanyLocationId]
		,[intAccountId]
		,[intCurrencyId]
		,[intTermId]
		,[dtmDate]
		,[dtmDueDate]
		,[dtmShipDate]
		,[dtmPostDate]
		,[intEntitySalespersonId]
		,[intFreightTermId]
		,[intShipViaId]
		,[intPaymentMethodId]
		,[strInvoiceOriginId]
		,[ysnUseOriginIdAsInvoiceNumber]
		,[strPONumber]
		,[strBOLNumber]
		,[strDeliverPickup]
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
		,[intMeterReadingId]
		,[intContractHeaderId]
		,[intLoadId]
		,[intOriginalInvoiceId]
		,[intEntityId]
		,[intTruckDriverId]
		,[intTruckDriverReferenceId]
		,[ysnResetDetails]
		,[ysnRecap]
		,[ysnPost]
		,[ysnUpdateAvailableDiscount]
		,[strImportFormat]
		,[intInvoiceDetailId]
		,[intItemId]
		,[intPrepayTypeId]
		,[dblPrepayRate]
		,[ysnInventory]
		,[strDocumentNumber]
		,[strItemDescription]
		,[intOrderUOMId]
		,[dblQtyOrdered]
		,[intItemUOMId]
		,[dblQtyShipped]
		,[dblDiscount]
		,[dblItemTermDiscount]
		,[strItemTermDiscountBy]
		,[dblPrice]
		,[strPricing]
		,[strVFDDocumentNumber]
		,[ysnRefreshPrice]
		,[strMaintenanceType]
		,[strFrequency]
		,[dtmMaintenanceDate]
		,[dblMaintenanceAmount]
		,[dblLicenseAmount]
		,[intTaxGroupId]
		,[intStorageLocationId]
		,[intCompanyLocationSubLocationId]
		,[ysnRecomputeTax]
		,[intSCInvoiceId]
		,[strSCInvoiceNumber]
		,[intInventoryShipmentItemId]
		,[intInventoryShipmentChargeId]
		,[strShipmentNumber]
		,[intRecipeItemId]
		,[intRecipeId]
		,[intSubLocationId]
		,[intCostTypeId]
		,[intMarginById]
		,[intCommentTypeId]
		,[dblMargin]
		,[dblRecipeQuantity]
		,[intSalesOrderDetailId]
		,[strSalesOrderNumber]
		,[intContractDetailId]
		,[intShipmentPurchaseSalesContractId]
		,[intItemWeightUOMId]
		,[dblItemWeight]
		,[dblShipmentGrossWt]
		,[dblShipmentTareWt]
		,[dblShipmentNetWt]
		,[intTicketId]
		,[intTicketHoursWorkedId]
		,[intCustomerStorageId]
		,[intSiteDetailId]
		,[intLoadDetailId]
		,[intLotId]
		,[intOriginalInvoiceDetailId]
		,[intSiteId]
		,[strBillingBy]
		,[dblPercentFull]
		,[dblNewMeterReading]
		,[dblPreviousMeterReading]
		,[dblConversionFactor]
		,[intPerformerId]
		,[ysnLeaseBilling]
		,[ysnVirtualMeterReading]
		,[intCurrencyExchangeRateTypeId]
		,[intCurrencyExchangeRateId]
		,[dblCurrencyExchangeRate]
		,[intSubCurrencyId]
		,[dblSubCurrencyRate]
		,[ysnBlended]
		,[intConversionAccountId]
		,[intSalesAccountId]
		,[intStorageScheduleTypeId]
		,[intDestinationGradeId]
		,[intDestinationWeightId]
	)								
	SELECT		 	
		 [intId]							= IE.[intId]
		,[strTransactionType]				= IE.[strTransactionType]
		,[strType]							= IE.[strType]
		,[strSourceTransaction]				= IE.[strSourceTransaction]
		,[intSourceId]						= IE.[intSourceId] -- dbo.[fnARValidateInvoiceSourceId]([strSourceTransaction], [intSourceId])
		,[intPeriodsToAccrue]				= IE.[intPeriodsToAccrue] 
		,[strSourceId]						= IE.[strSourceId]
		,[intInvoiceId]						= IE.[intInvoiceId]
		,[intEntityCustomerId]				= IE.[intEntityCustomerId]
		,[intCompanyLocationId]				= IE.[intCompanyLocationId]
		,[intAccountId]						= IE.[intAccountId]
		,[intCurrencyId]					= IE.[intCurrencyId]
		,[intTermId]						= IE.[intTermId]
		,[dtmDate]							= CAST(ISNULL(IE.[dtmDate], @DateNow) AS DATE)
		,[dtmDueDate]						= IE.[dtmDueDate]
		,[dtmShipDate]						= CAST(ISNULL(IE.[dtmShipDate], @DateNow) AS DATE)
		,[dtmPostDate]						= IE.[dtmPostDate]
		,[intEntitySalespersonId]			= IE.[intEntitySalespersonId]
		,[intFreightTermId]					= IE.[intFreightTermId]
		,[intShipViaId]						= IE.[intShipViaId]
		,[intPaymentMethodId]				= IE.[intPaymentMethodId]
		,[strInvoiceOriginId]				= IE.[strInvoiceOriginId]
		,[ysnUseOriginIdAsInvoiceNumber]	= IE.[ysnUseOriginIdAsInvoiceNumber]
		,[strPONumber]						= IE.[strPONumber]
		,[strBOLNumber]						= IE.[strBOLNumber]
		,[strDeliverPickup]					= IE.[strDeliverPickup]
		,[strComments]						= IE.[strComments]
		,[intShipToLocationId]				= IE.[intShipToLocationId]
		,[intBillToLocationId]				= IE.[intBillToLocationId]
		,[ysnTemplate]						= IE.[ysnTemplate]
		,[ysnForgiven]						= IE.[ysnForgiven]
		,[ysnCalculated]					= IE.[ysnCalculated]
		,[ysnSplitted]						= IE.[ysnSplitted]
		,[intPaymentId]						= IE.[intPaymentId]
		,[intSplitId]						= IE.[intSplitId]
		,[intLoadDistributionHeaderId]		= IE.[intLoadDistributionHeaderId]
		,[strActualCostId]					= IE.[strActualCostId]
		,[intShipmentId]					= IE.[intShipmentId]
		,[intTransactionId] 				= IE.[intTransactionId]
		,[intMeterReadingId]				= IE.[intMeterReadingId]
		,[intContractHeaderId]				= IE.[intContractHeaderId]
		,[intLoadId]						= IE.[intLoadId]
		,[intOriginalInvoiceId]				= IE.[intOriginalInvoiceId]
		,[intEntityId]						= IE.[intEntityId]
		,[intTruckDriverId]					= IE.[intTruckDriverId]
		,[intTruckDriverReferenceId]		= IE.[intTruckDriverReferenceId]
		,[ysnResetDetails]					= IE.[ysnResetDetails]
		,[ysnRecap]							= IE.[ysnRecap]
		,[ysnPost]							= IE.[ysnPost]
		,[ysnUpdateAvailableDiscount]		= IE.[ysnUpdateAvailableDiscount]
		,[strImportFormat]					= IE.[strImportFormat]

		,[intInvoiceDetailId]				= IE.[intInvoiceDetailId]
		,[intItemId]						= (CASE WHEN @GroupingOption = 0 THEN IE.[intItemId] ELSE NULL END) 
		,[intPrepayTypeId] 					= (CASE WHEN @GroupingOption = 0 THEN IE.[intPrepayTypeId] ELSE NULL END) 
		,[dblPrepayRate] 					= (CASE WHEN @GroupingOption = 0 THEN IE.[dblPrepayRate] ELSE NULL END) 
		,[ysnInventory]						= (CASE WHEN @GroupingOption = 0 THEN IE.[ysnInventory] ELSE NULL END)
		,[strDocumentNumber]				= (CASE WHEN @GroupingOption = 0 THEN ISNULL(IE.[strDocumentNumber], IE.[strSourceId]) ELSE NULL END)
		,[strItemDescription]				= (CASE WHEN @GroupingOption = 0 THEN IE.[strItemDescription] ELSE NULL END)
		,[intOrderUOMId]					= (CASE WHEN @GroupingOption = 0 THEN IE.[intOrderUOMId] ELSE NULL END)
		,[dblQtyOrdered]					= (CASE WHEN @GroupingOption = 0 THEN IE.[dblQtyOrdered] ELSE NULL END)
		,[intItemUOMId]						= (CASE WHEN @GroupingOption = 0 THEN IE.[intItemUOMId] ELSE NULL END)
		,[dblQtyShipped]					= (CASE WHEN @GroupingOption = 0 THEN IE.[dblQtyShipped] ELSE NULL END)
		,[dblDiscount]						= (CASE WHEN @GroupingOption = 0 THEN IE.[dblDiscount] ELSE NULL END)
		,[dblItemTermDiscount]				= (CASE WHEN @GroupingOption = 0 THEN IE.[dblItemTermDiscount] ELSE NULL END)
		,[strItemTermDiscountBy]			= (CASE WHEN @GroupingOption = 0 THEN IE.[strItemTermDiscountBy] ELSE NULL END)
		,[dblPrice]							= (CASE WHEN @GroupingOption = 0 THEN IE.[dblPrice] ELSE NULL END)
		,[strPricing]						= (CASE WHEN @GroupingOption = 0 THEN IE.[strPricing] ELSE NULL END)
		,[strVFDDocumentNumber]				= (CASE WHEN @GroupingOption = 0 THEN IE.[strVFDDocumentNumber] ELSE NULL END)
		,[ysnRefreshPrice]					= (CASE WHEN @GroupingOption = 0 THEN IE.[ysnRefreshPrice] ELSE 0 END)
		,[strMaintenanceType]				= (CASE WHEN @GroupingOption = 0 THEN IE.[strMaintenanceType] ELSE NULL END)
		,[strFrequency]						= (CASE WHEN @GroupingOption = 0 THEN IE.[strFrequency] ELSE NULL END)
		,[dtmMaintenanceDate]				= (CASE WHEN @GroupingOption = 0 THEN IE.[dtmMaintenanceDate] ELSE NULL END)
		,[dblMaintenanceAmount]				= (CASE WHEN @GroupingOption = 0 THEN IE.[dblMaintenanceAmount] ELSE NULL END)
		,[dblLicenseAmount]					= (CASE WHEN @GroupingOption = 0 THEN IE.[dblLicenseAmount] ELSE NULL END)
		,[intTaxGroupId]					= (CASE WHEN @GroupingOption = 0 THEN IE.[intTaxGroupId] ELSE NULL END)
		,[intStorageLocationId]				= (CASE WHEN @GroupingOption = 0 THEN IE.[intStorageLocationId] ELSE NULL END)
		,[intCompanyLocationSubLocationId]	= (CASE WHEN @GroupingOption = 0 THEN IE.[intCompanyLocationSubLocationId] ELSE NULL END)
		,[ysnRecomputeTax]					= (CASE WHEN @GroupingOption = 0 THEN IE.[ysnRecomputeTax] ELSE 0 END)
		,[intSCInvoiceId]					= (CASE WHEN @GroupingOption = 0 THEN IE.[intSCInvoiceId] ELSE NULL END)
		,[strSCInvoiceNumber]				= (CASE WHEN @GroupingOption = 0 THEN IE.[strSCInvoiceNumber] ELSE NULL END)
		,[intInventoryShipmentItemId]		= (CASE WHEN @GroupingOption = 0 THEN IE.[intInventoryShipmentItemId] ELSE NULL END)
		,[intInventoryShipmentChargeId]		= (CASE WHEN @GroupingOption = 0 THEN IE.[intInventoryShipmentChargeId] ELSE NULL END)
		,[strShipmentNumber]				= (CASE WHEN @GroupingOption = 0 THEN IE.[strShipmentNumber] ELSE NULL END)
		,[intRecipeItemId]					= (CASE WHEN @GroupingOption = 0 THEN IE.[intRecipeItemId] ELSE NULL END)
		,[intRecipeId]						= (CASE WHEN @GroupingOption = 0 THEN IE.[intRecipeId] ELSE NULL END)
		,[intSubLocationId]					= (CASE WHEN @GroupingOption = 0 THEN IE.[intSubLocationId] ELSE NULL END)
		,[intCostTypeId]					= (CASE WHEN @GroupingOption = 0 THEN IE.[intCostTypeId] ELSE NULL END)
		,[intMarginById]					= (CASE WHEN @GroupingOption = 0 THEN IE.[intMarginById] ELSE NULL END)
		,[intCommentTypeId]					= (CASE WHEN @GroupingOption = 0 THEN IE.[intCommentTypeId] ELSE NULL END)
		,[dblMargin]						= (CASE WHEN @GroupingOption = 0 THEN IE.[dblMargin] ELSE NULL END)
		,[dblRecipeQuantity]				= (CASE WHEN @GroupingOption = 0 THEN IE.[dblRecipeQuantity] ELSE NULL END)
		,[intSalesOrderDetailId]			= (CASE WHEN @GroupingOption = 0 THEN IE.[intSalesOrderDetailId] ELSE NULL END)
		,[strSalesOrderNumber]				= (CASE WHEN @GroupingOption = 0 THEN IE.[strSalesOrderNumber] ELSE NULL END)		
		,[intContractDetailId]				= (CASE WHEN @GroupingOption = 0 THEN IE.[intContractDetailId] ELSE NULL END)
		,[intShipmentPurchaseSalesContractId] = (CASE WHEN @GroupingOption = 0 THEN IE.[intShipmentPurchaseSalesContractId] ELSE NULL END)
		,[intItemWeightUOMId]				= (CASE WHEN @GroupingOption = 0 THEN IE.[intItemWeightUOMId] ELSE NULL END)
		,[dblItemWeight]					= (CASE WHEN @GroupingOption = 0 THEN IE.[dblItemWeight] ELSE NULL END)
		,[dblShipmentGrossWt]				= (CASE WHEN @GroupingOption = 0 THEN IE.[dblShipmentGrossWt] ELSE NULL END)
		,[dblShipmentTareWt]				= (CASE WHEN @GroupingOption = 0 THEN IE.[dblShipmentTareWt] ELSE NULL END)
		,[dblShipmentNetWt]					= (CASE WHEN @GroupingOption = 0 THEN IE.[dblShipmentNetWt] ELSE NULL END)
		,[intTicketId]						= (CASE WHEN @GroupingOption = 0 THEN IE.[intTicketId] ELSE NULL END)
		,[intTicketHoursWorkedId]			= (CASE WHEN @GroupingOption = 0 THEN IE.[intTicketHoursWorkedId] ELSE NULL END)
		,[intCustomerStorageId]				= (CASE WHEN @GroupingOption = 0 THEN IE.[intCustomerStorageId] ELSE NULL END)
		,[intSiteDetailId]					= (CASE WHEN @GroupingOption = 0 THEN IE.[intSiteDetailId] ELSE NULL END)
		,[intLoadDetailId]					= (CASE WHEN @GroupingOption = 0 THEN IE.[intLoadDetailId] ELSE NULL END)
		,[intLotId]							= (CASE WHEN @GroupingOption = 0 THEN IE.[intLotId] ELSE NULL END)
		,[intOriginalInvoiceDetailId]		= (CASE WHEN @GroupingOption = 0 THEN IE.[intOriginalInvoiceDetailId] ELSE NULL END)
		,[intSiteId]						= (CASE WHEN @GroupingOption = 0 THEN IE.[intSiteId] ELSE NULL END)
		,[strBillingBy]						= (CASE WHEN @GroupingOption = 0 THEN IE.[strBillingBy] ELSE NULL END)
		,[dblPercentFull]					= (CASE WHEN @GroupingOption = 0 THEN IE.[dblPercentFull] ELSE NULL END)
		,[dblNewMeterReading]				= (CASE WHEN @GroupingOption = 0 THEN IE.[dblNewMeterReading] ELSE NULL END)
		,[dblPreviousMeterReading]			= (CASE WHEN @GroupingOption = 0 THEN IE.[dblPreviousMeterReading] ELSE NULL END)
		,[dblConversionFactor]				= (CASE WHEN @GroupingOption = 0 THEN IE.[dblConversionFactor] ELSE NULL END)
		,[intPerformerId]					= (CASE WHEN @GroupingOption = 0 THEN IE.[intPerformerId] ELSE NULL END)
		,[ysnLeaseBilling]					= (CASE WHEN @GroupingOption = 0 THEN IE.[ysnLeaseBilling] ELSE NULL END)
		,[ysnVirtualMeterReading]			= (CASE WHEN @GroupingOption = 0 THEN IE.[ysnVirtualMeterReading] ELSE NULL END)
		,[intCurrencyExchangeRateTypeId]	= (CASE WHEN @GroupingOption = 0 THEN IE.[intCurrencyExchangeRateTypeId] ELSE NULL END)
		,[intCurrencyExchangeRateId]		= (CASE WHEN @GroupingOption = 0 THEN IE.[intCurrencyExchangeRateId] ELSE NULL END)
		,[dblCurrencyExchangeRate]			= (CASE WHEN @GroupingOption = 0 THEN IE.[dblCurrencyExchangeRate] ELSE 1 END)
		,[intSubCurrencyId]					= (CASE WHEN @GroupingOption = 0 THEN IE.[intSubCurrencyId] ELSE NULL END)
		,[dblSubCurrencyRate]				= (CASE WHEN @GroupingOption = 0 THEN IE.[dblSubCurrencyRate] ELSE 1 END)
		,[ysnBlended]						= (CASE WHEN @GroupingOption = 0 THEN IE.[ysnBlended] ELSE 0 END)
		,[intConversionAccountId]			= (CASE WHEN @GroupingOption = 0 THEN IE.[intConversionAccountId] ELSE NULL END)
		,[intSalesAccountId]				= (CASE WHEN @GroupingOption = 0 THEN IE.[intSalesAccountId] ELSE NULL END)
		,[intStorageScheduleTypeId]			= (CASE WHEN @GroupingOption = 0 THEN IE.[intStorageScheduleTypeId] ELSE NULL END)
		,[intDestinationGradeId]			= (CASE WHEN @GroupingOption = 0 THEN IE.[intDestinationGradeId] ELSE NULL END)
		,[intDestinationWeightId]			= (CASE WHEN @GroupingOption = 0 THEN IE.[intDestinationWeightId] ELSE NULL END)
	FROM
		@InvoiceEntries IE
	INNER JOIN
		#EntriesForProcessing EFP WITH (NOLOCK)
			ON IE.[intId] = EFP.[intId]
	WHERE
		ISNULL(EFP.[ysnForInsert],0) = 1
	ORDER BY
		[intId]

			
	BEGIN TRY		
		EXEC [dbo].[uspARCreateCustomerInvoices]
			 	 @InvoiceEntries	= @InvoicesForInsert
				,@IntegrationLogId	= @IntegrationLogId
				,@GroupingOption	= @GroupingOption
				,@UserId			= @UserId
				,@RaiseError		= @RaiseError
				,@ErrorMessage		= @CurrentErrorMessage
			
	
		IF LEN(ISNULL(@CurrentErrorMessage,'')) > 0
			BEGIN
				IF ISNULL(@RaiseError,0) = 0
					ROLLBACK TRANSACTION
				SET @ErrorMessage = @CurrentErrorMessage;
				IF ISNULL(@RaiseError,0) = 1
					RAISERROR(@ErrorMessage, 16, 1);
				RETURN 0;
			END
	END TRY
	BEGIN CATCH
		IF ISNULL(@RaiseError,0) = 0
			ROLLBACK TRANSACTION
		SET @ErrorMessage = ERROR_MESSAGE();
		IF ISNULL(@RaiseError,0) = 1
			RAISERROR(@ErrorMessage, 16, 1);
		RETURN 0;
	END CATCH	   
			
	IF (EXISTS(SELECT TOP 1 NULL FROM tblARInvoiceIntegrationLogDetail WITH (NOLOCK) WHERE [intIntegrationLogId] = @IntegrationLogId AND ISNULL([ysnSuccess],0) = 1 AND ISNULL([ysnHeader],0) = 1 ) AND @GroupingOption > 0)
	BEGIN

		UPDATE EFP
		SET EFP.[intInvoiceId] = IL.[intInvoiceId]
		FROM
			#EntriesForProcessing EFP
		INNER JOIN
			(SELECT [intId], [intInvoiceId], [ysnSuccess], [ysnHeader] FROM tblARInvoiceIntegrationLogDetail WITH (NOLOCK)) IL
				ON EFP.[intId] = IL.[intId]
				AND ISNULL(IL.[ysnHeader], 0) = 1
				AND ISNULL(IL.[ysnSuccess], 0) = 1		
			
		
		DECLARE @LineItems InvoiceStagingTable
		INSERT INTO @LineItems
			([intId]
			,[strTransactionType]
			,[strType]
			,[strSourceTransaction]
			,[strSourceId]
			,[intInvoiceId]
			,[intEntityCustomerId]
			,[intEntityContactId]
			,[intCompanyLocationId]
			,[intAccountId]
			,[intCurrencyId]
			,[intTermId]
			,[intPeriodsToAccrue]
			,[dtmDate]
			,[dtmDueDate]
			,[dtmShipDate]
			,[dtmPostDate]
			,[intEntitySalespersonId]
			,[intFreightTermId]
			,[intShipViaId]
			,[intPaymentMethodId]
			,[strInvoiceOriginId]
			,[ysnUseOriginIdAsInvoiceNumber]
			,[strPONumber]
			,[strBOLNumber]
			,[strDeliverPickup]
			,[strComments]
			,[intShipToLocationId]
			,[intBillToLocationId]
			,[ysnForgiven]
			,[ysnCalculated]
			,[ysnSplitted]
			,[intPaymentId]
			,[intSplitId]
			,[intLoadDistributionHeaderId]
			,[strActualCostId]
			,[intShipmentId]
			,[intTransactionId]
			,[intMeterReadingId]
			,[intContractHeaderId]
			,[intLoadId]
			,[intOriginalInvoiceId]
			,[intEntityId]
			,[intTruckDriverId]
			,[intTruckDriverReferenceId]
			,[ysnResetDetails]
			,[ysnRecap]
			,[ysnPost]
			,[ysnUpdateAvailableDiscount]
			,[ysnInsertDetail]
			,[intInvoiceDetailId]
			,[intItemId]
			,[intPrepayTypeId]
			,[ysnRestricted]
			,[ysnInventory]
			,[strDocumentNumber]
			,[strItemDescription]
			,[intOrderUOMId]
			,[dblQtyOrdered]
			,[intItemUOMId]
			,[dblQtyShipped]
			,[dblDiscount]
			,[dblItemTermDiscount]
			,[strItemTermDiscountBy]
			,[dblItemWeight]
			,[intItemWeightUOMId]
			,[dblPrice]
			,[strPricing]
			,[strVFDDocumentNumber]
			,[ysnRefreshPrice]
			,[strMaintenanceType]
			,[strFrequency]
			,[intMaintenanceAccountId]
			,[dtmMaintenanceDate]
			,[dblMaintenanceAmount]
			,[intLicenseAccountId]
			,[dblLicenseAmount]
			,[intTaxGroupId]
			,[intStorageLocationId]
			,[intCompanyLocationSubLocationId]
			,[ysnRecomputeTax]
			,[intSCInvoiceId]
			,[strSCInvoiceNumber]
			,[intSCBudgetId]
			,[strSCBudgetDescription]
			,[intInventoryShipmentItemId]
			,[intInventoryShipmentChargeId]
			,[strShipmentNumber]
			,[intRecipeItemId]
			,[intRecipeId]
			,[intSubLocationId]
			,[intCostTypeId]
			,[intMarginById]
			,[intCommentTypeId]
			,[dblMargin]
			,[dblRecipeQuantity]
			,[intSalesOrderDetailId]
			,[strSalesOrderNumber]
			,[intContractDetailId]
			,[intShipmentPurchaseSalesContractId]
			,[dblShipmentGrossWt]
			,[dblShipmentTareWt]
			,[dblShipmentNetWt]
			,[intTicketId]
			,[intTicketHoursWorkedId]
			,[intDocumentMaintenanceId]
			,[intCustomerStorageId]
			,[intSiteDetailId]
			,[intLoadDetailId]
			,[intLotId]
			,[intOriginalInvoiceDetailId]
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
			,[intCurrencyExchangeRateTypeId]
			,[intCurrencyExchangeRateId]
			,[dblCurrencyExchangeRate]
			,[intSubCurrencyId]
			,[dblSubCurrencyRate]
			,[ysnBlended]
			,[strImportFormat]
			,[dblCOGSAmount]
			,[intConversionAccountId]
			,[intSalesAccountId]
			,[intStorageScheduleTypeId]
			,[intDestinationGradeId]
			,[intDestinationWeightId])
		SELECT
			 [intId]								= ITG.[intId]
			,[strTransactionType]					= ARI.[strTransactionType]
			,[strType]								= ARI.[strType]
			,[strSourceTransaction]					= ITG.[strSourceTransaction]
			,[strSourceId]							= ITG.[strSourceId]
			,[intInvoiceId]							= ARI.[intInvoiceId]
			,[intEntityCustomerId]					= ARI.[intEntityCustomerId]
			,[intEntityContactId]					= ARI.[intEntityContactId]
			,[intCompanyLocationId]					= ARI.[intCompanyLocationId]
			,[intAccountId]							= ARI.[intAccountId]
			,[intCurrencyId]						= ARI.[intCurrencyId]
			,[intTermId]							= ARI.[intTermId]
			,[intPeriodsToAccrue]					= ARI.[intPeriodsToAccrue]
			,[dtmDate]								= ARI.[dtmDate]
			,[dtmDueDate]							= ARI.[dtmDueDate]
			,[dtmShipDate]							= ARI.[dtmShipDate]
			,[dtmPostDate]							= ARI.[dtmPostDate]
			,[intEntitySalespersonId]				= ARI.[intEntitySalespersonId]
			,[intFreightTermId]						= ARI.[intFreightTermId]
			,[intShipViaId]							= ARI.[intShipViaId]
			,[intPaymentMethodId]					= ARI.[intPaymentMethodId]
			,[strInvoiceOriginId]					= ARI.[strInvoiceOriginId]
			,[ysnUseOriginIdAsInvoiceNumber]		= ITG.[ysnUseOriginIdAsInvoiceNumber]
			,[strPONumber]							= ARI.[strPONumber]
			,[strBOLNumber]							= ARI.[strBOLNumber]
			,[strDeliverPickup]						= ARI.[strDeliverPickup]
			,[strComments]							= ARI.[strComments]
			,[intShipToLocationId]					= ARI.[intShipToLocationId]
			,[intBillToLocationId]					= ARI.[intBillToLocationId]
			,[ysnForgiven]							= ARI.[ysnForgiven]
			,[ysnCalculated]						= ARI.[ysnCalculated]
			,[ysnSplitted]							= ARI.[ysnSplitted]
			,[intPaymentId]							= ARI.[intPaymentId]
			,[intSplitId]							= ARI.[intSplitId]
			,[intLoadDistributionHeaderId]			= ARI.[intLoadDistributionHeaderId]
			,[strActualCostId]						= ARI.[strActualCostId]
			,[intShipmentId]						= ARI.[intShipmentId]
			,[intTransactionId]						= ARI.[intTransactionId]
			,[intMeterReadingId]					= ARI.[intMeterReadingId]
			,[intContractHeaderId]					= ARI.[intContractHeaderId]
			,[intLoadId]							= ARI.[intLoadId]
			,[intOriginalInvoiceId]					= ARI.[intOriginalInvoiceId]
			,[intEntityId]							= ARI.[intEntityId]
			,[intTruckDriverId]						= ARI.[intTruckDriverId]
			,[intTruckDriverReferenceId]			= ARI.[intTruckDriverReferenceId]
			,[ysnResetDetails]						= ITG.[ysnResetDetails]
			,[ysnRecap]								= ITG.[ysnRecap]
			,[ysnPost]								= ITG.[ysnPost]
			,[ysnUpdateAvailableDiscount]			= ITG.[ysnUpdateAvailableDiscount]
			,[ysnInsertDetail]						= ITG.[ysnInsertDetail]
			,[intInvoiceDetailId]					= ITG.[intInvoiceDetailId]
			,[intItemId]							= ITG.[intItemId]
			,[intPrepayTypeId]						= ITG.[intPrepayTypeId]
			,[ysnRestricted]						= ITG.[ysnRestricted]
			,[ysnInventory]							= ITG.[ysnInventory]
			,[strDocumentNumber]					= ITG.[strDocumentNumber]
			,[strItemDescription]					= ITG.[strItemDescription]
			,[intOrderUOMId]						= ITG.[intOrderUOMId]
			,[dblQtyOrdered]						= ITG.[dblQtyOrdered]
			,[intItemUOMId]							= ITG.[intItemUOMId]
			,[dblQtyShipped]						= ITG.[dblQtyShipped]
			,[dblDiscount]							= ITG.[dblDiscount]
			,[dblItemTermDiscount]					= ITG.[dblItemTermDiscount]
			,[strItemTermDiscountBy]				= ITG.[strItemTermDiscountBy]
			,[dblItemWeight]						= ITG.[dblItemWeight]
			,[intItemWeightUOMId]					= ITG.[intItemWeightUOMId]
			,[dblPrice]								= ITG.[dblPrice]
			,[strPricing]							= ITG.[strPricing]
			,[strVFDDocumentNumber]					= ITG.[strVFDDocumentNumber]
			,[ysnRefreshPrice]						= ITG.[ysnRefreshPrice]
			,[strMaintenanceType]					= ITG.[strMaintenanceType]
			,[strFrequency]							= ITG.[strFrequency]
			,[intMaintenanceAccountId]				= ITG.[intMaintenanceAccountId]
			,[dtmMaintenanceDate]					= ITG.[dtmMaintenanceDate]
			,[dblMaintenanceAmount]					= ITG.[dblMaintenanceAmount]
			,[intLicenseAccountId]					= ITG.[intLicenseAccountId]
			,[dblLicenseAmount]						= ITG.[dblLicenseAmount]
			,[intTaxGroupId]						= ITG.[intTaxGroupId]
			,[intStorageLocationId]					= ITG.[intStorageLocationId]
			,[intCompanyLocationSubLocationId]		= ITG.[intCompanyLocationSubLocationId]
			,[ysnRecomputeTax]						= ITG.[ysnRecomputeTax]
			,[intSCInvoiceId]						= ITG.[intSCInvoiceId]
			,[strSCInvoiceNumber]					= ITG.[strSCInvoiceNumber]
			,[intSCBudgetId]						= ITG.[intSCBudgetId]
			,[strSCBudgetDescription]				= ITG.[strSCBudgetDescription]
			,[intInventoryShipmentItemId]			= ITG.[intInventoryShipmentItemId]
			,[intInventoryShipmentChargeId]			= ITG.[intInventoryShipmentChargeId]
			,[strShipmentNumber]					= ITG.[strShipmentNumber]
			,[intRecipeItemId]						= ITG.[intRecipeItemId]
			,[intRecipeId]							= ITG.[intRecipeId]
			,[intSubLocationId]						= ITG.[intSubLocationId]
			,[intCostTypeId]						= ITG.[intCostTypeId]
			,[intMarginById]						= ITG.[intMarginById]
			,[intCommentTypeId]						= ITG.[intCommentTypeId]
			,[dblMargin]							= ITG.[dblMargin]
			,[dblRecipeQuantity]					= ITG.[dblRecipeQuantity]
			,[intSalesOrderDetailId]				= ITG.[intSalesOrderDetailId]
			,[strSalesOrderNumber]					= ITG.[strSalesOrderNumber]
			,[intContractDetailId]					= ITG.[intContractDetailId]
			,[intShipmentPurchaseSalesContractId]	= ITG.[intShipmentPurchaseSalesContractId]
			,[dblShipmentGrossWt]					= ITG.[dblShipmentGrossWt]
			,[dblShipmentTareWt]					= ITG.[dblShipmentTareWt]
			,[dblShipmentNetWt]						= ITG.[dblShipmentNetWt]
			,[intTicketId]							= ITG.[intTicketId]
			,[intTicketHoursWorkedId]				= ITG.[intTicketHoursWorkedId]
			,[intDocumentMaintenanceId]				= ITG.[intDocumentMaintenanceId]
			,[intCustomerStorageId]					= ITG.[intCustomerStorageId]
			,[intSiteDetailId]						= ITG.[intSiteDetailId]
			,[intLoadDetailId]						= ITG.[intLoadDetailId]
			,[intLotId]								= ITG.[intLotId]
			,[intOriginalInvoiceDetailId]			= ITG.[intOriginalInvoiceDetailId]
			,[intSiteId]							= ITG.[intSiteId]
			,[strBillingBy]							= ITG.[strBillingBy]
			,[dblPercentFull]						= ITG.[dblPercentFull]
			,[dblNewMeterReading]					= ITG.[dblNewMeterReading]
			,[dblPreviousMeterReading]				= ITG.[dblPreviousMeterReading]
			,[dblConversionFactor]					= ITG.[dblConversionFactor]
			,[intPerformerId]						= ITG.[intPerformerId]
			,[ysnLeaseBilling]						= ITG.[ysnLeaseBilling]
			,[ysnVirtualMeterReading]				= ITG.[ysnVirtualMeterReading]
			,[ysnClearDetailTaxes]					= ITG.[ysnClearDetailTaxes]
			,[intTempDetailIdForTaxes]				= ITG.[intTempDetailIdForTaxes]
			,[intCurrencyExchangeRateTypeId]		= ITG.[intCurrencyExchangeRateTypeId]
			,[intCurrencyExchangeRateId]			= ITG.[intCurrencyExchangeRateId]
			,[dblCurrencyExchangeRate]				= ITG.[dblCurrencyExchangeRate]
			,[intSubCurrencyId]						= ITG.[intSubCurrencyId]
			,[dblSubCurrencyRate]					= ITG.[dblSubCurrencyRate]
			,[ysnBlended]							= ITG.[ysnBlended]
			,[strImportFormat]						= ITG.[strImportFormat]
			,[dblCOGSAmount]						= ITG.[dblCOGSAmount]
			,[intConversionAccountId]				= ITG.[intConversionAccountId]
			,[intSalesAccountId]					= ITG.[intSalesAccountId]
			,[intStorageScheduleTypeId]				= ITG.[intStorageScheduleTypeId]
			,[intDestinationGradeId]				= ITG.[intDestinationGradeId]
			,[intDestinationWeightId]				= ITG.[intDestinationWeightId]
		FROM
			@InvoiceEntries ITG
		INNER JOIN
			#EntriesForProcessing EFP WITH (NOLOCK)
				ON (ISNULL(ITG.[intId], 0) = ISNULL(EFP.[intId], 0) OR @GroupingOption > 0)
				AND (ISNULL(ITG.[intEntityCustomerId], 0) = ISNULL(EFP.[intEntityCustomerId], 0) OR (EFP.[intEntityCustomerId] IS NULL AND @GroupingOption < 1))
				AND (ISNULL(ITG.[intSourceId], 0) = ISNULL(EFP.[intSourceId], 0) OR (EFP.[intSourceId] IS NULL AND (@GroupingOption < 2 OR ITG.[strSourceTransaction] IN ('Sale OffSite','Settle Storage','Process Grain Storage','Transfer Storage','Load/Shipment Schedules','Credit Card Reconciliation', 'CF Invoice'))))
				AND (ISNULL(ITG.[intCompanyLocationId], 0) = ISNULL(EFP.[intCompanyLocationId], 0) OR (EFP.[intCompanyLocationId] IS NULL AND @GroupingOption < 3))
				AND (ISNULL(ITG.[intCurrencyId],0) = ISNULL(EFP.[intCurrencyId],0) OR (EFP.[intCurrencyId] IS NULL AND @GroupingOption < 4))
				AND (CAST(ISNULL(ITG.[dtmDate], @DateNow) AS DATE) = CAST(ISNULL(EFP.[dtmDate], @DateNow) AS DATE) OR (EFP.[dtmDate] IS NULL AND @GroupingOption < 5))
				AND (ISNULL(ITG.[intTermId],0) = ISNULL(EFP.[intTermId],0) OR (EFP.[intTermId] IS NULL AND @GroupingOption < 6))        
				AND (ISNULL(ITG.[intShipViaId],0) = ISNULL(EFP.[intShipViaId],0) OR (EFP.[intShipViaId] IS NULL AND @GroupingOption < 7))
				AND (ISNULL(ITG.[intEntitySalespersonId],0) = ISNULL(EFP.[intEntitySalespersonId],0) OR (EFP.[intEntitySalespersonId] IS NULL AND @GroupingOption < 8))
				AND (ISNULL(ITG.[strPONumber],'') = ISNULL(EFP.[strPONumber],'') OR (EFP.[strPONumber] IS NULL AND @GroupingOption < 9))        
				AND (ISNULL(ITG.[strBOLNumber],'') = ISNULL(EFP.[strBOLNumber],'') OR (EFP.[strBOLNumber] IS NULL AND @GroupingOption < 10))    
				AND (ISNULL(ITG.[strComments],'') = ISNULL(EFP.[strComments],'') OR (EFP.[strComments] IS NULL AND @GroupingOption < 11))
				AND (ISNULL(ITG.[intAccountId],0) = ISNULL(EFP.[intAccountId],0) OR (EFP.[intAccountId] IS NULL AND @GroupingOption < 12))
				AND (ISNULL(ITG.[intFreightTermId],0) = ISNULL(EFP.[intFreightTermId],0) OR (EFP.[intFreightTermId] IS NULL AND @GroupingOption < 13))
				AND (ISNULL(ITG.[intPaymentMethodId],0) = ISNULL(EFP.[intPaymentMethodId],0) OR (EFP.[intPaymentMethodId] IS NULL AND @GroupingOption < 14))            
				AND (ISNULL(ITG.[strInvoiceOriginId],'') = ISNULL(EFP.[strInvoiceOriginId],'') OR (EFP.[strInvoiceOriginId] IS NULL AND @GroupingOption < 15))
		INNER JOIN
			(SELECT
				 [strTransactionType]
				,[strType]
				,[intInvoiceId]
				,[intEntityCustomerId]
				,[intEntityContactId]
				,[intCompanyLocationId]
				,[intAccountId]
				,[intCurrencyId]
				,[intTermId]
				,[intPeriodsToAccrue]
				,[dtmDate]
				,[dtmDueDate]
				,[dtmShipDate]
				,[dtmPostDate]
				,[intEntitySalespersonId]
				,[intFreightTermId]
				,[intShipViaId]
				,[intPaymentMethodId]
				,[strInvoiceOriginId]
				,[strPONumber]
				,[strBOLNumber]
				,[strDeliverPickup]
				,[strComments]
				,[intShipToLocationId]
				,[intBillToLocationId]
				,[ysnForgiven]
				,[ysnCalculated]
				,[ysnSplitted]
				,[intPaymentId]
				,[intSplitId]
				,[intLoadDistributionHeaderId]
				,[strActualCostId]
				,[intShipmentId]
				,[intTransactionId]
				,[intMeterReadingId]
				,[intContractHeaderId]
				,[intLoadId]
				,[intOriginalInvoiceId]
				,[intEntityId]
				,[intTruckDriverId]
				,[intTruckDriverReferenceId]
			 FROM tblARInvoice WITH (NOLOCK)) ARI
				ON EFP.[intInvoiceId] = ARI.[intInvoiceId] 
			 WHERE
				ISNULL(EFP.[ysnForInsert],0) = 1


		EXEC [dbo].[uspARAddItemToInvoices]
			 @InvoiceEntries	= @LineItems
			,@IntegrationLogId	= @IntegrationLogId
			,@UserId			= @UserId
			,@RaiseError		= @RaiseError
			,@ErrorMessage		= @CurrentErrorMessage	OUTPUT

		IF LEN(ISNULL(@CurrentErrorMessage,'')) > 0
			BEGIN
				IF ISNULL(@RaiseError,0) = 0
					ROLLBACK TRANSACTION
				SET @ErrorMessage = @CurrentErrorMessage;
				IF ISNULL(@RaiseError,0) = 1
					RAISERROR(@ErrorMessage, 16, 1);
				RETURN 0;
			END

		DELETE FROM @TaxDetails
		INSERT INTO @TaxDetails
			([intId]
			,[intDetailId]
			,[intDetailTaxId]
			,[intTaxGroupId]
			,[intTaxCodeId]
			,[intTaxClassId]
			,[strTaxableByOtherTaxes]
			,[strCalculationMethod]
			,[dblRate]
			,[intTaxAccountId]
			,[dblTax]
			,[dblAdjustedTax]
			,[ysnTaxAdjusted]
			,[ysnSeparateOnInvoice]
			,[ysnCheckoffTax]
			,[ysnTaxExempt]
			,[strNotes]
			,[intTempDetailIdForTaxes]
			,[dblCurrencyExchangeRate]
			,[ysnClearExisting]
			,[strTransactionType]
			,[strType]
			,[strSourceTransaction]
			,[intSourceId]
			,[strSourceId]
			,[intHeaderId]
			,[dtmDate])
		SELECT
			 [intId]						= ARIILD.[intId]
			,[intDetailId]					= ARIILD.[intInvoiceDetailId]
			,[intDetailTaxId]				= LITE.[intDetailTaxId]
			,[intTaxGroupId]				= LITE.[intTaxGroupId]
			,[intTaxCodeId]					= LITE.[intTaxCodeId]
			,[intTaxClassId]				= LITE.[intTaxClassId]
			,[strTaxableByOtherTaxes]		= LITE.[strTaxableByOtherTaxes]
			,[strCalculationMethod]			= LITE.[strCalculationMethod]
			,[dblRate]						= LITE.[dblRate]
			,[intTaxAccountId]				= LITE.[intTaxAccountId]
			,[dblTax]						= LITE.[dblTax]
			,[dblAdjustedTax]				= LITE.[dblAdjustedTax]
			,[ysnTaxAdjusted]				= LITE.[ysnTaxAdjusted]
			,[ysnSeparateOnInvoice]			= LITE.[ysnSeparateOnInvoice]
			,[ysnCheckoffTax]				= LITE.[ysnCheckoffTax]
			,[ysnTaxExempt]					= LITE.[ysnTaxExempt]
			,[strNotes]						= LITE.[strNotes]
			,[intTempDetailIdForTaxes]		= LITE.[intTempDetailIdForTaxes]
			,[dblCurrencyExchangeRate]		= ISNULL(IFI.[dblCurrencyExchangeRate], 1.000000)
			,[ysnClearExisting]				= IFI.[ysnClearDetailTaxes]
			,[strTransactionType]			= ARIILD.[strTransactionType]
			,[strType]						= ARIILD.[strType]
			,[strSourceTransaction]			= ARIILD.[strSourceTransaction]
			,[intSourceId]					= ARIILD.[intSourceId]
			,[strSourceId]					= ARIILD.[strSourceId]
			,[intHeaderId]					= ARIILD.[intInvoiceId]
			,[dtmDate]						= ISNULL(IFI.[dtmDate], @DateNow)
		FROM
			@LineItemTaxEntries  LITE
		INNER JOIN
			(SELECT [intInvoiceId], [intInvoiceDetailId], [intTemporaryDetailIdForTax], [ysnHeader], [ysnSuccess], [intId], [strTransactionType], [strType], [strSourceTransaction], [intIntegrationLogId], [intSourceId], [strSourceId] FROM tblARInvoiceIntegrationLogDetail WITH (NOLOCK)) ARIILD
				ON LITE.[intTempDetailIdForTaxes] = ARIILD.[intTemporaryDetailIdForTax]
				AND ISNULL(ARIILD.[ysnHeader], 0) = 0
				AND ISNULL(ARIILD.[ysnSuccess], 0) = 1
				AND ISNULL(ARIILD.[intInvoiceDetailId], 0) <> 0
		INNER JOIN
			(SELECT [intId], [ysnClearDetailTaxes], [dtmDate], [dblCurrencyExchangeRate] FROM @InvoicesForInsert) IFI
				ON IFI. [intId] = ARIILD.[intId]
		WHERE
			ARIILD.[intIntegrationLogId] = @IntegrationLogId


		EXEC	[dbo].[uspARProcessTaxDetailsForLineItems]
					 @TaxDetails			= @TaxDetails
					,@IntegrationLogId		= @IntegrationLogId
					,@UserId				= @UserId
					,@ReComputeInvoices		= 0
					,@RaiseError			= @RaiseError
					,@ErrorMessage			= @CurrentErrorMessage OUTPUT

		IF LEN(ISNULL(@CurrentErrorMessage,'')) > 0
			BEGIN
				IF ISNULL(@RaiseError,0) = 0
					ROLLBACK TRANSACTION
				SET @ErrorMessage = @CurrentErrorMessage;
				IF ISNULL(@RaiseError,0) = 1
					RAISERROR(@ErrorMessage, 16, 1);
				RETURN 0;
			END		
	END	

	DECLARE @InvoiceIds InvoiceId	
	DELETE FROM @InvoiceIds

	INSERT INTO @InvoiceIds(
			[intHeaderId]
		,[ysnUpdateAvailableDiscountOnly]
		,[intDetailId])
	SELECT 
			[intHeaderId]						= ARIILD.[intInvoiceId]
		,[ysnUpdateAvailableDiscountOnly]	= IFI.[ysnUpdateAvailableDiscount]
		,[intDetailId]						= NULL
		FROM
		(SELECT [intInvoiceId], [ysnHeader], [ysnSuccess], [intId], [intIntegrationLogId] FROM tblARInvoiceIntegrationLogDetail WITH (NOLOCK)) ARIILD
		INNER JOIN
		(SELECT [intId], [ysnUpdateAvailableDiscount] FROM @InvoicesForInsert) IFI
			ON IFI. [intId] = ARIILD.[intId] 
	WHERE
			ISNULL(ARIILD.[ysnHeader], 0) = 1
			AND ISNULL(ARIILD.[ysnSuccess], 0) = 1
			AND ISNULL(ARIILD.[intInvoiceId], 0) <> 0


	EXEC	[dbo].[uspARUpdateInvoicesIntegrations]
				@InvoiceIds	= @InvoiceIds
				,@UserId		= @UserId


	EXEC [dbo].[uspARReComputeInvoicesAmounts] @InvoiceIds = @InvoiceIds
		
END

END TRY
BEGIN CATCH
	IF ISNULL(@RaiseError,0) = 0
		ROLLBACK TRANSACTION
	SET @ErrorMessage = ERROR_MESSAGE();
	IF ISNULL(@RaiseError,0) = 1
		RAISERROR(@ErrorMessage, 16, 1);
	RETURN 0;
END CATCH

--DECLARE	@successfulCount INT
--		,@invalidCount INT
--		,@success BIT
--		,@batchIdUsed NVARCHAR(40)
--		,@recapId NVARCHAR(250)

--DECLARE @TempInvoiceIdTable AS TABLE ([intInvoiceId] INT)

----UnPosting posted Invoices for update
--BEGIN TRY
--	DECLARE @IdsForUnPosting VARCHAR(MAX)
--	DELETE FROM @TempInvoiceIdTable
--	INSERT INTO @TempInvoiceIdTable
--	SELECT DISTINCT
--		EFP.[intInvoiceId]
--	FROM
--		#EntriesForProcessing EFP
--	INNER JOIN
--		@InvoiceEntries IE
--			ON EFP.[intInvoiceId] = IE.[intInvoiceId] 
--	WHERE
--		ISNULL(EFP.[ysnForUpdate],0) = 1
--		AND ISNULL(EFP.[ysnProcessed],0) = 0
--		AND ISNULL(EFP.[intInvoiceId],0) <> 0
--		AND EFP.[ysnPost] IS NOT NULL AND EFP.[ysnPost] = 0
--		AND ISNULL(IE.[ysnUpdateAvailableDiscount], 0) = 0

--	SELECT
--		@IdsForUnPosting = COALESCE(@IdsForUnPosting + ',' ,'') + CAST([intInvoiceId] AS NVARCHAR(250))
--	FROM
--		@TempInvoiceIdTable
	
		
--	IF LEN(RTRIM(LTRIM(@IdsForUnPosting))) > 0
--		EXEC [dbo].[uspARPostInvoice]
--			@batchId			= NULL,
--			@post				= 0,
--			@recap				= 0,
--			@param				= @IdsForUnPosting,
--			@userId				= @UserId,
--			@beginDate			= NULL,
--			@endDate			= NULL,
--			@beginTransaction	= NULL,
--			@endTransaction		= NULL,
--			@exclude			= NULL,
--			@successfulCount	= @successfulCount OUTPUT,
--			@invalidCount		= @invalidCount OUTPUT,
--			@success			= @success OUTPUT,
--			@batchIdUsed		= @batchIdUsed OUTPUT,
--			@recapId			= @recapId OUTPUT,
--			@transType			= N'all',
--			@raiseError			= @RaiseError

--END TRY
--BEGIN CATCH
--	IF ISNULL(@RaiseError,0) = 0
--		ROLLBACK TRANSACTION
--	SET @ErrorMessage = ERROR_MESSAGE();
--	IF ISNULL(@RaiseError,0) = 1
--		RAISERROR(@ErrorMessage, 16, 1);
--	RETURN 0;
--END CATCH


----UPDATE
--BEGIN TRY
--	WHILE EXISTS(SELECT NULL FROM #EntriesForProcessing WHERE ISNULL([ysnForUpdate],0) = 1 AND ISNULL([ysnProcessed],0) = 0 AND ISNULL([intInvoiceId],0) <> 0)
--	BEGIN
			
--		DECLARE @ExistingInvoiceId INT		
--		SELECT @ExistingInvoiceId = [intInvoiceId] FROM #EntriesForProcessing WHERE ISNULL([ysnForUpdate],0) = 1 AND ISNULL([ysnProcessed],0) = 0 AND ISNULL([intInvoiceId],0) <> 0 ORDER BY [intId]
									
--		SELECT TOP 1
--			 @TransactionType				= [strTransactionType]
--			,@Type							= [strType]		 	
--			,@SourceTransaction				= [strSourceTransaction]
--			,@SourceId						= [intSourceId]
--			,@PeriodsToAccrue 				= [intPeriodsToAccrue]
--			,@SourceNumber					= [strSourceId]
--			,@InvoiceId						= [intInvoiceId]
--			,@EntityCustomerId				= [intEntityCustomerId]
--			,@CompanyLocationId				= [intCompanyLocationId]
--			,@AccountId						= [intAccountId] 
--			,@CurrencyId					= ISNULL([intCurrencyId], [dbo].[fnARGetCustomerDefaultCurrency]([intEntityCustomerId]))
--			,@TermId						= [intTermId]
--			,@Date							= CAST([dtmDate] AS DATE)
--			,@DueDate						= [dtmDueDate]
--			,@ShipDate						= [dtmShipDate]
--			,@PostDate						= [dtmPostDate]
--			,@EntitySalespersonId			= [intEntitySalespersonId]
--			,@FreightTermId					= [intFreightTermId]
--			,@ShipViaId						= [intShipViaId]
--			,@PaymentMethodId				= [intPaymentMethodId]
--			,@InvoiceOriginId				= [strInvoiceOriginId]
--			,@PONumber						= [strPONumber]
--			,@BOLNumber						= [strBOLNumber]
--			,@DeliverPickup					= [strDeliverPickup]
--			,@Comment						= [strComments]
--			,@ShipToLocationId				= [intShipToLocationId]
--			,@BillToLocationId				= [intBillToLocationId]
--			,@Template						= [ysnTemplate]
--			,@Forgiven						= [ysnForgiven]
--			,@Calculated					= [ysnCalculated]
--			,@Splitted						= [ysnSplitted]
--			,@PaymentId						= [intPaymentId]
--			,@SplitId						= [intSplitId]			
--			,@LoadDistributionHeaderId		= [intLoadDistributionHeaderId]
--			,@ActualCostId					= [strActualCostId]
--			,@ShipmentId					= [intShipmentId]
--			,@TransactionId 				= [intTransactionId]
--			,@MeterReadingId				= [intMeterReadingId]
--			,@ContractHeaderId				= [intContractHeaderId] 
--			,@LoadId						= [intLoadId] 
--			,@OriginalInvoiceId				= [intOriginalInvoiceId]
--			,@EntityId						= [intEntityId]
--			,@TruckDriverId					= [intTruckDriverId]
--			,@TruckDriverReferenceId		= [intTruckDriverReferenceId]
--			,@ResetDetails					= [ysnResetDetails]
--			,@Recap							= [ysnRecap] 
--			,@Post							= [ysnPost]
--			,@UpdateAvailableDiscount		= [ysnUpdateAvailableDiscount]
--		FROM
--			@InvoiceEntries
--		WHERE
--			ISNULL([intInvoiceId],0) = @ExistingInvoiceId
--		ORDER BY
--			[intId]

--		BEGIN TRY
--			IF ISNULL(@SourceTransaction,'') = 'Transport Load'
--				BEGIN
--					SET @SourceColumn = 'intLoadDistributionHeaderId'
--					SET @SourceTable = 'tblTRLoadDistributionHeader'
--				END
--			IF ISNULL(@SourceTransaction,'') = 'Inbound Shipment'
--				BEGIN
--					SET @SourceColumn = 'intShipmentId'
--					SET @SourceTable = 'tblLGShipment'
--				END
--			IF ISNULL(@SourceTransaction,'') = 'Card Fueling Transaction' OR ISNULL(@SourceTransaction,'') = 'CF Tran'
--				BEGIN
--					SET @SourceColumn = 'intTransactionId'
--					SET @SourceTable = 'tblCFTransaction'
--				END
--			IF ISNULL(@SourceTransaction, '') = 'Meter Billing'
--					BEGIN
--						SET @SourceColumn = 'intMeterReadingId'
--						SET @SourceTable = 'tblMBMeterReading' 
--					END
--			IF ISNULL(@SourceTransaction,'') = 'Provisional'
--				BEGIN
--					SET @SourceColumn = 'intInvoiceId'
--					SET @SourceTable = 'tblARInvoice'
--				END

--			IF ISNULL(@SourceTransaction,'') = 'Inventory Shipment'
--					BEGIN
--						SET @SourceColumn = 'intInventoryShipmentId'
--						SET @SourceTable = 'tblICInventoryShipment'
--					END

--			IF ISNULL(@SourceTransaction,'') = 'Sales Contract'
--					BEGIN
--						SET @SourceColumn = 'intContractHeaderId'
--						SET @SourceTable = 'tblCTContractHeader'
--					END	

--			IF ISNULL(@SourceTransaction,'') = 'Load Schedule'
--					BEGIN
--						SET @SourceColumn = 'intLoadId'
--						SET @SourceTable = 'tblLGLoad'
--					END

--			IF ISNULL(@SourceTransaction,'') IN ('Transport Load', 'Inbound Shipment', 'Card Fueling Transaction', 'CF Tran', 'Meter Billing', 'Provisional', 'Inventory Shipment', 'Sales Contract', 'Load Schedule')
--				BEGIN
--					EXECUTE('IF NOT EXISTS(SELECT NULL FROM ' + @SourceTable + ' WHERE ' + @SourceColumn + ' = ' + @SourceId + ') RAISERROR(''' + @SourceTransaction + ' does not exists!'', 16, 1);');
--				END
--		END TRY
--		BEGIN CATCH
--			IF ISNULL(@RaiseError,0) = 0
--				ROLLBACK TRANSACTION
--			SET @ErrorMessage = ERROR_MESSAGE();
--			IF ISNULL(@RaiseError,0) = 1
--				RAISERROR(@ErrorMessage, 16, 1);
--			RETURN 0;
--		END CATCH

--		SET @NewSourceId = dbo.[fnARValidateInvoiceSourceId](@SourceTransaction, @SourceId)
			
--		UPDATE
--			[tblARInvoice]
--		SET 
--			 [strTransactionType]		= CASE WHEN ISNULL(@TransactionType, '') NOT IN ('Invoice', 'Credit Memo', 'Debit Memo', 'Cash', 'Cash Refund', 'Overpayment', 'Customer Prepayment') THEN [tblARInvoice].[strTransactionType] ELSE @TransactionType END
--			,[strType]					= CASE WHEN ISNULL(@Type, '') NOT IN ('Meter Billing', 'Standard', 'Software', 'Tank Delivery', 'Provisional', 'Service Charge', 'Transport Delivery', 'Store', 'Card Fueling') THEN [tblARInvoice].[strType] ELSE @Type END
--			,[intEntityCustomerId]		= @EntityCustomerId
--			,[intCompanyLocationId]		= @CompanyLocationId
--			--,[intAccountId]				= @AccountId 
--			,[intCurrencyId]			= @CurrencyId
--			,[intTermId]				= ISNULL(@TermId, C.[intTermsId])
--			,[intSourceId] 				= @NewSourceId
--			,[intPeriodsToAccrue] 		= ISNULL(@PeriodsToAccrue,1)
--			,[dtmDate]					= @Date
--			,[dtmDueDate]				= ISNULL(@DueDate, (CAST(dbo.fnGetDueDateBasedOnTerm(@Date, ISNULL(ISNULL(@TermId, C.[intTermsId]),0)) AS DATE)))
--			,[dtmShipDate]				= @ShipDate
--			,[dtmPostDate]				= @PostDate
--			,[dblInvoiceSubtotal]		= @ZeroDecimal
--			,[dblShipping]				= @ZeroDecimal
--			,[dblTax]					= @ZeroDecimal
--			,[dblInvoiceTotal]			= @ZeroDecimal
--			,[dblDiscount]				= @ZeroDecimal
--			,[dblAmountDue]				= @ZeroDecimal
--			,[dblPayment]				= @ZeroDecimal
--			,[intEntitySalespersonId]	= ISNULL(@EntitySalespersonId, C.[intSalespersonId])
--			,[intFreightTermId]			= @FreightTermId
--			,[intShipViaId]				= ISNULL(@ShipViaId, EL.[intShipViaId])
--			,[intPaymentMethodId]		= (SELECT intPaymentMethodID FROM tblSMPaymentMethod WHERE intPaymentMethodID = @PaymentMethodId)
--			,[strInvoiceOriginId]		= @InvoiceOriginId
--			,[strPONumber]				= @PONumber
--			,[strBOLNumber]				= @BOLNumber
--			,[strDeliverPickup]			= @DeliverPickup
--			,[strComments]				= @Comment
--			,[intShipToLocationId]		= ISNULL(@ShipToLocationId, ISNULL(SL1.[intEntityLocationId], EL.[intEntityLocationId]))
--			,[strShipToLocationName]	= ISNULL(SL.[strLocationName], ISNULL(SL1.[strLocationName], EL.[strLocationName]))
--			,[strShipToAddress]			= ISNULL(SL.[strAddress], ISNULL(SL1.[strAddress], EL.[strAddress]))
--			,[strShipToCity]			= ISNULL(SL.[strCity], ISNULL(SL1.[strCity], EL.[strCity]))
--			,[strShipToState]			= ISNULL(SL.[strState], ISNULL(SL1.[strState], EL.[strState]))
--			,[strShipToZipCode]			= ISNULL(SL.[strZipCode], ISNULL(SL1.[strZipCode], EL.[strZipCode]))
--			,[strShipToCountry]			= ISNULL(SL.[strCountry], ISNULL(SL1.[strCountry], EL.[strCountry]))
--			,[intBillToLocationId]		= ISNULL(@BillToLocationId, ISNULL(BL1.[intEntityLocationId], EL.[intEntityLocationId]))
--			,[strBillToLocationName]	= ISNULL(BL.[strLocationName], ISNULL(BL1.[strLocationName], EL.[strLocationName]))
--			,[strBillToAddress]			= ISNULL(BL.[strAddress], ISNULL(BL1.[strAddress], EL.[strAddress]))
--			,[strBillToCity]			= ISNULL(BL.[strCity], ISNULL(BL1.[strCity], EL.[strCity]))
--			,[strBillToState]			= ISNULL(BL.[strState], ISNULL(BL1.[strState], EL.[strState]))
--			,[strBillToZipCode]			= ISNULL(BL.[strZipCode], ISNULL(BL1.[strZipCode], EL.[strZipCode]))
--			,[strBillToCountry]			= ISNULL(BL.[strCountry], ISNULL(BL1.[strCountry], EL.[strCountry]))
--			,[ysnRecurring]				= ISNULL(@Template,0)
--			,[ysnForgiven]				= ISNULL(@Forgiven,0)
--			,[ysnCalculated]			= ISNULL(@Calculated,0)
--			,[ysnSplitted]				= ISNULL(@Splitted,0)
--			,[intPaymentId]				= @PaymentId
--			,[intSplitId]				= @SplitId
--			,[intLoadDistributionHeaderId]	= @LoadDistributionHeaderId
--			,[strActualCostId]			= @ActualCostId
--			,[intShipmentId]			= @ShipmentId
--			,[intTransactionId]			= @TransactionId 
--			,[intMeterReadingId]		= @MeterReadingId
--			,[intContractHeaderId]		= @ContractHeaderId
--			,[intLoadId]				= @LoadId
--			,[intOriginalInvoiceId]		= @OriginalInvoiceId 
--			,[intEntityId]				= @EntityId
--			,[intTruckDriverId]			= @TruckDriverId
--			,[intTruckDriverReferenceId]	= @TruckDriverReferenceId
--			,[intConcurrencyId]			= [tblARInvoice].[intConcurrencyId] + 1
--		FROM
--			tblARCustomer C
--		LEFT OUTER JOIN
--						(	SELECT 
--								 [intEntityLocationId]
--								,[strLocationName]
--								,[strAddress]
--								,[intEntityId] 
--								,[strCountry]
--								,[strState]
--								,[strCity]
--								,[strZipCode]
--								,[intTermsId]
--								,[intShipViaId]
--							FROM 
--								[tblEMEntityLocation]
--							WHERE
--								ysnDefaultLocation = 1
--						) EL
--							ON C.[intEntityCustomerId] = EL.[intEntityId]
--		LEFT OUTER JOIN
--			[tblEMEntityLocation] SL
--				ON ISNULL(@ShipToLocationId, 0) <> 0
--				AND @ShipToLocationId = SL.intEntityLocationId
--		LEFT OUTER JOIN
--			[tblEMEntityLocation] SL1
--				ON C.intShipToId = SL1.intEntityLocationId
--		LEFT OUTER JOIN
--			[tblEMEntityLocation] BL
--				ON ISNULL(@BillToLocationId, 0) <> 0
--				AND @BillToLocationId = BL.intEntityLocationId		
--		LEFT OUTER JOIN
--			[tblEMEntityLocation] BL1
--				ON C.intShipToId = BL1.intEntityLocationId		
--		WHERE
--			[tblARInvoice].[intInvoiceId] = @ExistingInvoiceId
--			AND C.[intEntityCustomerId] = @EntityCustomerId
--			AND ISNULL(@UpdateAvailableDiscount, 0) = 0


--		IF ISNULL(@ExistingInvoiceId, 0) <> 0
--			BEGIN			
--				EXEC [dbo].[uspARInsertTransactionDetail] @InvoiceId = @ExistingInvoiceId
--			END	
			

--		DECLARE @ForExistingDetailId INT
--				,@NewExistingDetailId INT			
--		--RESET Invoice Details						
--		IF (ISNULL(@ExistingInvoiceId, 0) <> 0 AND ISNULL(@ResetDetails,0) = 1)
--		BEGIN
--			DELETE FROM tblARInvoiceDetailTax 
--			WHERE [intInvoiceDetailId] IN (SELECT [intInvoiceDetailId] FROM tblARInvoiceDetail  WHERE [intInvoiceId] = @ExistingInvoiceId)
			
--			DELETE FROM tblARInvoiceDetail
--			WHERE [intInvoiceId]  = @ExistingInvoiceId
			
--			WHILE EXISTS(SELECT NULL FROM #EntriesForProcessing WHERE ISNULL([ysnForUpdate],0) = 1 AND ISNULL([ysnProcessed],0) = 0 AND [intInvoiceId] = @ExistingInvoiceId)
--			BEGIN
--				SELECT TOP 1 @ForExistingDetailId = [intId] FROM #EntriesForProcessing WHERE ISNULL([ysnForUpdate],0) = 1 AND ISNULL([ysnProcessed],0) = 0 AND [intInvoiceId] = @ExistingInvoiceId ORDER BY [intId]
				
--					SELECT TOP 1
--						 @ShipmentId					= [intShipmentId]		 	
--						,@ItemId						= [intItemId]
--						,@ItemPrepayTypeId				= [intPrepayTypeId]
--						,@ItemPrepayRate				= [dblPrepayRate]
--						,@Inventory						= [ysnInventory]
--						,@ItemDocumentNumber			= ISNULL([strDocumentNumber], @SourceNumber)
--						,@ItemDescription				= [strItemDescription]
--						,@OrderUOMId					= [intOrderUOMId]
--						,@ItemQtyOrdered				= [dblQtyOrdered]
--						,@ItemUOMId						= [intItemUOMId]
--						,@ItemQtyShipped				= [dblQtyShipped]
--						,@ItemDiscount					= [dblDiscount]
--						,@ItemPrice						= [dblPrice]
--						,@ItemPricing					= [strPricing] 
--						,@ItemVFDDocumentNumber			= [strVFDDocumentNumber]
--						,@RefreshPrice					= [ysnRefreshPrice]
--						,@ItemMaintenanceType			= [strMaintenanceType]
--						,@ItemFrequency					= [strFrequency]
--						,@ItemMaintenanceDate			= [dtmMaintenanceDate]
--						,@ItemMaintenanceAmount			= [dblMaintenanceAmount]
--						,@ItemLicenseAmount				= [dblLicenseAmount]
--						,@ItemTaxGroupId				= [intTaxGroupId]
--						,@ItemStorageLocationId			= [intStorageLocationId]
--						,@ItemCompanyLocationSubLocationId	= [intCompanyLocationSubLocationId]
--						,@RecomputeTax					= [ysnRecomputeTax]
--						,@ItemSCInvoiceId				= [intSCInvoiceId]
--						,@ItemSCInvoiceNumber			= [strSCInvoiceNumber]
--						,@ItemInventoryShipmentItemId	= [intInventoryShipmentItemId]
--						,@ItemInventoryShipmentChargeId	= [intInventoryShipmentChargeId]
--						,@ItemShipmentNumber			= [strShipmentNumber]						
--						,@ItemRecipeItemId				= [intRecipeItemId]
--						,@ItemRecipeId					= [intRecipeId]
--						,@ItemSublocationId				= [intSubLocationId]
--						,@ItemCostTypeId				= [intCostTypeId]
--						,@ItemMarginById				= [intMarginById]
--						,@ItemCommentTypeId				= [intCommentTypeId]
--						,@ItemMargin					= [dblMargin]
--						,@ItemRecipeQty					= [dblRecipeQuantity]
--						,@ItemSalesOrderDetailId		= [intSalesOrderDetailId]
--						,@ItemSalesOrderNumber			= [strSalesOrderNumber]
--						,@ContractHeaderId				= [intContractHeaderId]
--						,@ItemContractDetailId			= [intContractDetailId]
--						,@ItemShipmentPurchaseSalesContractId =  [intShipmentPurchaseSalesContractId]
--						,@ItemWeightUOMId				= [intItemWeightUOMId]
--						,@ItemWeight					= [dblItemWeight]
--						,@ItemShipmentGrossWt			= [dblShipmentGrossWt]
--						,@ItemShipmentTareWt			= [dblShipmentTareWt]
--						,@ItemShipmentNetWt				= [dblShipmentNetWt]
--						,@ItemTicketId					= [intTicketId]
--						,@ItemTicketHoursWorkedId		= [intTicketHoursWorkedId]
--						,@ItemCustomerStorageId			= [intCustomerStorageId]
--						,@ItemSiteDetailId				= [intSiteDetailId]
--						,@ItemLoadDetailId				= [intLoadDetailId]
--						,@ItemLotId						= [intLotId]
--						,@ItemOriginalInvoiceDetailId	= [intOriginalInvoiceDetailId]
--						,@ItemSiteId					= [intSiteId]
--						,@ItemBillingBy					= [strBillingBy]
--						,@ItemPercentFull				= [dblPercentFull]
--						,@ItemNewMeterReading			= [dblNewMeterReading]
--						,@ItemPreviousMeterReading		= [dblPreviousMeterReading]
--						,@ItemConversionFactor			= [dblConversionFactor]
--						,@ItemPerformerId				= [intPerformerId]
--						,@ItemLeaseBilling				= [ysnLeaseBilling]
--						,@ItemVirtualMeterReading		= [ysnVirtualMeterReading]
--						,@TempDetailIdForTaxes			= [intTempDetailIdForTaxes]
--						,@ItemConversionAccountId		= [intConversionAccountId]
--						,@ItemCurrencyExchangeRateTypeId	= [intCurrencyExchangeRateTypeId]
--						,@ItemCurrencyExchangeRateId	= [intCurrencyExchangeRateId]
--						,@ItemCurrencyExchangeRate		= [dblCurrencyExchangeRate]
--						,@ItemSubCurrencyId				= [intSubCurrencyId]
--						,@ItemSubCurrencyRate			= [dblSubCurrencyRate]
--						,@ItemStorageScheduleTypeId		= [intStorageScheduleTypeId]
--						,@ItemDestinationGradeId		= [intDestinationGradeId]
--						,@ItemDestinationWeightId		= [intDestinationWeightId]
--						,@ItemSalesAccountId			= [intSalesAccountId]
--					FROM
--						@InvoiceEntries
--					WHERE
--						[intId] = @ForExistingDetailId
						
--					BEGIN TRY
--						EXEC [dbo].[uspARAddItemToInvoice]
--							 @InvoiceId						= @ExistingInvoiceId	
--							,@ItemId						= @ItemId
--							,@ItemPrepayTypeId				= @ItemPrepayTypeId
--							,@ItemPrepayRate				= @ItemPrepayRate
--							,@ItemIsInventory				= @Inventory
--							,@NewInvoiceDetailId			= @NewExistingDetailId	OUTPUT 
--							,@ErrorMessage					= @CurrentErrorMessage	OUTPUT
--							,@RaiseError					= @RaiseError
--							,@ItemDocumentNumber			= @ItemDocumentNumber
--							,@ItemDescription				= @ItemDescription
--							,@OrderUOMId					= @OrderUOMId
--							,@ItemQtyOrdered				= @ItemQtyOrdered
--							,@ItemUOMId						= @ItemUOMId
--							,@ItemQtyShipped				= @ItemQtyShipped
--							,@ItemDiscount					= @ItemDiscount
--							,@ItemPrice						= @ItemPrice
--							,@ItemPricing					= @ItemPricing
--							,@ItemVFDDocumentNumber			= @ItemVFDDocumentNumber
--							,@RefreshPrice					= @RefreshPrice
--							,@ItemMaintenanceType			= @ItemMaintenanceType
--							,@ItemFrequency					= @ItemFrequency
--							,@ItemMaintenanceDate			= @ItemMaintenanceDate
--							,@ItemMaintenanceAmount			= @ItemMaintenanceAmount
--							,@ItemLicenseAmount				= @ItemLicenseAmount
--							,@ItemTaxGroupId				= @ItemTaxGroupId
--							,@ItemStorageLocationId			= @ItemStorageLocationId
--							,@ItemCompanyLocationSubLocationId	= @ItemCompanyLocationSubLocationId
--							,@RecomputeTax					= @RecomputeTax
--							,@ItemSCInvoiceId				= @ItemSCInvoiceId
--							,@ItemSCInvoiceNumber			= @ItemSCInvoiceNumber
--							,@ItemInventoryShipmentItemId	= @ItemInventoryShipmentItemId
--							,@ItemInventoryShipmentChargeId	= @ItemInventoryShipmentChargeId
--							,@ItemShipmentNumber			= @ItemShipmentNumber
--							,@ItemRecipeItemId				= @ItemRecipeItemId
--							,@ItemRecipeId					= @ItemRecipeId
--							,@ItemSublocationId				= @ItemSublocationId
--							,@ItemCostTypeId				= @ItemCostTypeId
--							,@ItemMarginById				= @ItemMarginById
--							,@ItemCommentTypeId				= @ItemCommentTypeId
--							,@ItemMargin					= @ItemMargin
--							,@ItemRecipeQty					= @ItemRecipeQty							
--							,@ItemSalesOrderDetailId		= @ItemSalesOrderDetailId
--							,@ItemSalesOrderNumber			= @ItemSalesOrderNumber
--							,@ItemContractHeaderId			= @ContractHeaderId
--							,@ItemContractDetailId			= @ItemContractDetailId
--							,@ItemShipmentId				= @ShipmentId
--							,@ItemShipmentPurchaseSalesContractId	= @ItemShipmentPurchaseSalesContractId
--							,@ItemTicketId					= @ItemTicketId
--							,@ItemTicketHoursWorkedId		= @ItemTicketHoursWorkedId
--							,@ItemCustomerStorageId			= @ItemCustomerStorageId
--							,@ItemSiteDetailId				= @ItemSiteDetailId
--							,@ItemLoadDetailId				= @ItemLoadDetailId
--							,@ItemLotId						= @ItemLotId
--							,@ItemOriginalInvoiceDetailId	= @ItemOriginalInvoiceDetailId
--							,@ItemSiteId					= @ItemSiteId
--							,@ItemBillingBy					= @ItemBillingBy
--							,@ItemPercentFull				= @ItemPercentFull
--							,@ItemNewMeterReading			= @ItemNewMeterReading
--							,@ItemPreviousMeterReading		= @ItemPreviousMeterReading
--							,@ItemConversionFactor			= @ItemConversionFactor
--							,@ItemPerformerId				= @ItemPerformerId
--							,@ItemLeaseBilling				= @ItemLeaseBilling
--							,@ItemConversionAccountId		= @ItemConversionAccountId
--							,@ItemCurrencyExchangeRateTypeId	= @ItemCurrencyExchangeRateTypeId
--							,@ItemCurrencyExchangeRateId	= @ItemCurrencyExchangeRateId
--							,@ItemCurrencyExchangeRate		= @ItemCurrencyExchangeRate
--							,@ItemSubCurrencyId				= @ItemSubCurrencyId
--							,@ItemSubCurrencyRate			= @ItemSubCurrencyRate
--							,@ItemWeightUOMId				= @ItemWeightUOMId
--							,@ItemWeight					= @ItemWeight
--							,@ItemStorageScheduleTypeId		= @ItemStorageScheduleTypeId
--							,@ItemDestinationGradeId		= @ItemDestinationGradeId
--							,@ItemDestinationWeightId		= @ItemDestinationWeightId
--							,@ItemSalesAccountId			= @ItemSalesAccountId

--						IF LEN(ISNULL(@CurrentErrorMessage,'')) > 0
--							BEGIN
--								IF ISNULL(@RaiseError,0) = 0
--									ROLLBACK TRANSACTION
--								SET @ErrorMessage = @CurrentErrorMessage;
--								IF ISNULL(@RaiseError,0) = 1
--									RAISERROR(@ErrorMessage, 16, 1);
--								RETURN 0;
--							END
--					END TRY
--					BEGIN CATCH
--						IF ISNULL(@RaiseError,0) = 0
--							ROLLBACK TRANSACTION
--						SET @ErrorMessage = ERROR_MESSAGE();
--						IF ISNULL(@RaiseError,0) = 1
--							RAISERROR(@ErrorMessage, 16, 1);
--						RETURN 0;
--					END CATCH

--					IF ISNULL(@NewExistingDetailId,0) <> 0					
--					BEGIN
--						UPDATE #EntriesForProcessing
--						SET
--							 [ysnProcessed]			= 1
--							,[intInvoiceDetailId]	= @NewExistingDetailId
--						WHERE
--							[intId] = @ForExistingDetailId
--					END
					
--					IF ISNULL(@NewExistingDetailId,0) <> 0					
--					BEGIN															
--						BEGIN TRY
--							DELETE FROM @TaxDetails
--							INSERT INTO @TaxDetails
--								([intDetailId]
--								,[intDetailTaxId]
--								,[intTaxGroupId]
--								,[intTaxCodeId]
--								,[intTaxClassId]
--								,[strTaxableByOtherTaxes]
--								,[strCalculationMethod]
--								,[dblRate]
--								,[intTaxAccountId]
--								,[dblTax]
--								,[dblAdjustedTax]
--								,[ysnTaxAdjusted]
--								,[ysnSeparateOnInvoice]
--								,[ysnCheckoffTax]
--								,[ysnTaxExempt]
--								,[strNotes])
--							SELECT
--								 @NewDetailId
--								,[intDetailTaxId]
--								,[intTaxGroupId]
--								,[intTaxCodeId]
--								,[intTaxClassId]
--								,[strTaxableByOtherTaxes]
--								,[strCalculationMethod]
--								,[dblRate]
--								,[intTaxAccountId]
--								,[dblTax]
--								,[dblAdjustedTax]
--								,[ysnTaxAdjusted]
--								,[ysnSeparateOnInvoice]
--								,[ysnCheckoffTax]
--								,[ysnTaxExempt]
--								,[strNotes]
--							FROM
--								@LineItemTaxEntries
--							WHERE
--								[intTempDetailIdForTaxes] = @TempDetailIdForTaxes
						
--							EXEC	[dbo].[uspARProcessTaxDetailsForLineItem]
--										 @TaxDetails	= @TaxDetails
--										,@UserId		= @EntityId
--										,@ClearExisting	= @ClearDetailTaxes
--										,@RaiseError	= @RaiseError
--										,@ErrorMessage	= @CurrentErrorMessage OUTPUT

--							IF LEN(ISNULL(@CurrentErrorMessage,'')) > 0
--								BEGIN
--									IF ISNULL(@RaiseError,0) = 0
--										ROLLBACK TRANSACTION
--									SET @ErrorMessage = @CurrentErrorMessage;
--									IF ISNULL(@RaiseError,0) = 1
--										RAISERROR(@ErrorMessage, 16, 1);
--									RETURN 0;
--								END
--						END TRY
--						BEGIN CATCH
--							IF ISNULL(@RaiseError,0) = 0
--								ROLLBACK TRANSACTION
--							SET @ErrorMessage = ERROR_MESSAGE();
--							IF ISNULL(@RaiseError,0) = 1
--								RAISERROR(@ErrorMessage, 16, 1);
--							RETURN 0;
--						END CATCH
--					END				
						
--			END
			
--		END

--		--UPDATE Invoice Details						
--		IF (ISNULL(@ExistingInvoiceId, 0) <> 0 AND ISNULL(@ResetDetails,0) = 0)
--		BEGIN		
--			WHILE EXISTS(SELECT NULL FROM #EntriesForProcessing WHERE ISNULL([ysnForUpdate],0) = 1 AND ISNULL([ysnProcessed],0) = 0 AND [intInvoiceId] = @ExistingInvoiceId AND ISNULL([intInvoiceDetailId],0) <> 0)
--			BEGIN
--				SELECT TOP 1 @ForExistingDetailId = [intId] FROM #EntriesForProcessing WHERE ISNULL([ysnForUpdate],0) = 1 AND ISNULL([ysnProcessed],0) = 0 AND [intInvoiceId] = @ExistingInvoiceId AND ISNULL([intInvoiceDetailId],0) <> 0 ORDER BY [intId]
				
--				SELECT TOP 1
--					 @ShipmentId					= [intShipmentId]		 	
--					,@InvoiceDetailId				= [intInvoiceDetailId] 
--					,@ItemId						= [intItemId]
--					,@ItemPrepayTypeId				= [intPrepayTypeId]
--					,@ItemPrepayRate				= [dblPrepayRate]
--					,@Inventory						= [ysnInventory]
--					,@ItemDocumentNumber			= ISNULL([strDocumentNumber],@SourceNumber)
--					,@ItemDescription				= [strItemDescription]
--					,@OrderUOMId					= [intOrderUOMId]
--					,@ItemQtyOrdered				= [dblQtyOrdered]
--					,@ItemUOMId						= [intItemUOMId]
--					,@ItemQtyShipped				= [dblQtyShipped]
--					,@ItemDiscount					= [dblDiscount]
--					,@ItemPrice						= [dblPrice]
--					,@ItemPricing					= [strPricing] 
--					,@ItemVFDDocumentNumber			= [strVFDDocumentNumber]
--					,@RefreshPrice					= [ysnRefreshPrice]
--					,@ItemMaintenanceType			= [strMaintenanceType]
--					,@ItemFrequency					= [strFrequency]
--					,@ItemMaintenanceDate			= [dtmMaintenanceDate]
--					,@ItemMaintenanceAmount			= [dblMaintenanceAmount]
--					,@ItemLicenseAmount				= [dblLicenseAmount]
--					,@ItemTaxGroupId				= [intTaxGroupId]
--					,@ItemStorageLocationId			= @ItemStorageLocationId
--					,@ItemCompanyLocationSubLocationId	= [intCompanyLocationSubLocationId]
--					,@RecomputeTax					= [ysnRecomputeTax]
--					,@ItemSCInvoiceId				= [intSCInvoiceId]
--					,@ItemSCInvoiceNumber			= [strSCInvoiceNumber]
--					,@ItemInventoryShipmentItemId	= [intInventoryShipmentItemId]
--					,@ItemInventoryShipmentChargeId	= [intInventoryShipmentChargeId]
--					,@ItemShipmentNumber			= [strShipmentNumber]
--					,@ItemRecipeItemId				= [intRecipeItemId]	
--					,@ItemRecipeId					= [intRecipeId]
--					,@ItemSublocationId				= [intSubLocationId]
--					,@ItemCostTypeId				= [intCostTypeId]
--					,@ItemMarginById				= [intMarginById]
--					,@ItemCommentTypeId				= [intCommentTypeId]
--					,@ItemMargin					= [dblMargin]
--					,@ItemRecipeQty					= [dblRecipeQuantity]				
--					,@ItemSalesOrderDetailId		= [intSalesOrderDetailId]
--					,@ItemSalesOrderNumber			= [strSalesOrderNumber]
--					,@ContractHeaderId				= [intContractHeaderId]
--					,@ItemContractDetailId			= [intContractDetailId]
--					,@ItemShipmentPurchaseSalesContractId =  [intShipmentPurchaseSalesContractId]
--					,@ItemWeightUOMId				= [intItemWeightUOMId]
--					,@ItemWeight					= [dblItemWeight]
--					,@ItemShipmentGrossWt			= [dblShipmentGrossWt]
--					,@ItemShipmentTareWt			= [dblShipmentTareWt]
--					,@ItemShipmentNetWt				= [dblShipmentNetWt]
--					,@ItemTicketId					= [intTicketId]
--					,@ItemOriginalInvoiceDetailId	= [intOriginalInvoiceDetailId]
--					,@ItemTicketHoursWorkedId		= [intTicketHoursWorkedId]
--					,@ItemCustomerStorageId			= [intCustomerStorageId]
--					,@ItemSiteDetailId				= [intSiteDetailId]
--					,@ItemLoadDetailId				= [intLoadDetailId]
--					,@ItemLotId						= [intLotId]
--					,@ItemSiteId					= [intSiteId]
--					,@ItemBillingBy					= [strBillingBy]
--					,@ItemPercentFull				= [dblPercentFull]
--					,@ItemNewMeterReading			= [dblNewMeterReading]
--					,@ItemPreviousMeterReading		= [dblPreviousMeterReading]
--					,@ItemConversionFactor			= [dblConversionFactor]
--					,@ItemPerformerId				= [intPerformerId]
--					,@ItemLeaseBilling				= [ysnLeaseBilling]
--					,@ItemVirtualMeterReading		= [ysnVirtualMeterReading]
--					,@TempDetailIdForTaxes			= [intTempDetailIdForTaxes]
--					,@ItemConversionAccountId		= [intConversionAccountId]
--					,@ItemCurrencyExchangeRateTypeId	= [intCurrencyExchangeRateTypeId]
--					,@ItemCurrencyExchangeRateId	= [intCurrencyExchangeRateId]
--					,@ItemCurrencyExchangeRate		= [dblCurrencyExchangeRate]
--					,@ItemSubCurrencyId				= [intSubCurrencyId]
--					,@ItemSubCurrencyRate			= [dblSubCurrencyRate]
--					,@ItemStorageScheduleTypeId		= [intStorageScheduleTypeId]
--					,@ItemDestinationGradeId		= [intDestinationGradeId]
--					,@ItemDestinationWeightId		= [intDestinationWeightId]
--				FROM
--					@InvoiceEntries
--				WHERE
--					[intId] = @ForExistingDetailId
					
--				IF (ISNULL(@RefreshPrice,0) = 1 AND ISNULL(@UpdateAvailableDiscount, 0) = 0)
--					BEGIN
--						DECLARE @Pricing			NVARCHAR(250)				
--								,@ContractNumber	INT
--								,@ContractSeq		INT
--								,@InvoiceType		NVARCHAR(200)

--						BEGIN TRY
--						SELECT TOP 1 @InvoiceType = strType, @TermId = intTermId FROM tblARInvoice WHERE intInvoiceId = @InvoiceId 
--						EXEC dbo.[uspARGetItemPrice]  
--							 @ItemId					= @ItemId
--							,@CustomerId				= @EntityCustomerId
--							,@LocationId				= @CompanyLocationId
--							,@ItemUOMId					= @ItemUOMId
--							,@TransactionDate			= @Date
--							,@Quantity					= @ItemQtyShipped
--							,@Price						= @ItemPrice			OUTPUT
--							,@Pricing					= @Pricing				OUTPUT
--							,@ContractHeaderId			= @ContractHeaderId		OUTPUT
--							,@ContractDetailId			= @ItemContractDetailId	OUTPUT
--							,@ContractNumber			= @ContractNumber		OUTPUT
--							,@ContractSeq				= @ContractSeq			OUTPUT
--							,@TermDiscount				= @ItemTermDiscount		OUTPUT
--							,@TermDiscountBy			= @ItemTermDiscountBy	OUTPUT							
--							,@InvoiceType				= @InvoiceType
--							,@TermId					= @TermId
--						END TRY
--						BEGIN CATCH
--							SET @ErrorMessage = ERROR_MESSAGE();
--							IF ISNULL(@RaiseError,0) = 1
--								RAISERROR(@ErrorMessage, 16, 1);
--							RETURN 0;
--						END CATCH
--					END
					
--				BEGIN TRY
--					UPDATE
--						[tblARInvoiceDetail]
--					SET	
--						 [intItemId]							= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemId ELSE [intItemId] END
--						,[intPrepayTypeId]						= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemPrepayTypeId ELSE [intPrepayTypeId] END
--						,[dblPrepayRate]						= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemPrepayRate ELSE [dblPrepayRate] END
--						,[strDocumentNumber]					= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemDocumentNumber ELSE [strDocumentNumber] END
--						,[strItemDescription]					= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemDescription ELSE [strItemDescription] END
--						,[intOrderUOMId]						= CASE WHEN @UpdateAvailableDiscount = 0 THEN @OrderUOMId ELSE [intOrderUOMId] END
--						,[dblQtyOrdered]						= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemQtyOrdered ELSE [dblQtyOrdered] END
--						,[intItemUOMId]							= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemUOMId ELSE [intItemUOMId] END
--						,[dblQtyShipped]						= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemQtyShipped ELSE [dblQtyShipped] END
--						,[dblDiscount]							= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemDiscount ELSE [dblDiscount] END
--						,[dblItemTermDiscount]					= @ItemTermDiscount
--						,[strItemTermDiscountBy]				= @ItemTermDiscountBy
--						,[dblPrice]								= CASE WHEN @UpdateAvailableDiscount = 0 THEN 
--																		(CASE WHEN (ISNULL(@RefreshPrice,0) = 1) THEN @ItemPrice / ISNULL(@ItemSubCurrencyRate, 1) ELSE @ItemPrice END)
--																	ELSE
--																		[dblPrice]
--																  END
--						,[strPricing]							= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemPricing ELSE [strPricing] END							
--						,[strVFDDocumentNumber]					= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemVFDDocumentNumber ELSE [strVFDDocumentNumber] END
--						,[strMaintenanceType]					= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemMaintenanceType ELSE [strMaintenanceType] END
--						,[strFrequency]							= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemFrequency ELSE [strFrequency] END					
--						,[dtmMaintenanceDate]					= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemMaintenanceDate ELSE [dtmMaintenanceDate] END			
--						,[dblMaintenanceAmount]					= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemMaintenanceAmount ELSE [dblMaintenanceAmount] END			
--						,[dblLicenseAmount]						= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemLicenseAmount ELSE [dblLicenseAmount] END				
--						,[intTaxGroupId]						= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemTaxGroupId ELSE [intTaxGroupId] END				
--						,[intStorageLocationId]					= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemStorageLocationId ELSE [intStorageLocationId] END				
--						,[intCompanyLocationSubLocationId]		= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemCompanyLocationSubLocationId ELSE [intCompanyLocationSubLocationId] END				
--						,[intSCInvoiceId]						= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemSCInvoiceId ELSE [intSCInvoiceId] END					
--						,[strSCInvoiceNumber]					= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemSCInvoiceNumber ELSE [strSCInvoiceNumber] END				
--						,[intInventoryShipmentItemId]			= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemInventoryShipmentItemId ELSE [intInventoryShipmentItemId] END			
--						,[intInventoryShipmentChargeId]			= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemInventoryShipmentChargeId ELSE [intInventoryShipmentChargeId] END			
--						,[strShipmentNumber]					= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemShipmentNumber ELSE [strShipmentNumber] END	
--						,[intRecipeItemId]						= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemRecipeItemId ELSE [intRecipeItemId] END
--						,[intRecipeId]							= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemRecipeId ELSE [intRecipeId] END
--						,[intSubLocationId]						= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemSublocationId ELSE [intSubLocationId] END
--						,[intCostTypeId]						= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemCostTypeId ELSE [intCostTypeId] END
--						,[intMarginById]						= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemMarginById ELSE [intMarginById] END
--						,[intCommentTypeId]						= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemCommentTypeId ELSE [intCommentTypeId] END
--						,[dblMargin]							= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemMargin ELSE [dblMargin] END
--						,[dblRecipeQuantity]					= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemRecipeQty ELSE [dblRecipeQuantity] END									
--						,[intSalesOrderDetailId]				= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemSalesOrderDetailId ELSE [intSalesOrderDetailId] END			
--						,[strSalesOrderNumber]					= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemSalesOrderNumber ELSE [strSalesOrderNumber] END		
--						,[intContractHeaderId]					= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ContractHeaderId ELSE [intContractHeaderId] END			
--						,[intContractDetailId]					= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemContractDetailId ELSE [intContractDetailId] END			
--						,[intShipmentId]						= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ShipmentId ELSE [intShipmentId] END			
--						,[intShipmentPurchaseSalesContractId]	= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemShipmentPurchaseSalesContractId ELSE [intShipmentPurchaseSalesContractId] END
--						,[intItemWeightUOMId]					= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemWeightUOMId ELSE [intItemWeightUOMId] END
--						,[dblItemWeight]						= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemWeight ELSE [dblItemWeight] END
--						,[dblShipmentGrossWt]					= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemShipmentGrossWt ELSE [dblShipmentGrossWt] END
--						,[dblShipmentTareWt]					= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemShipmentTareWt ELSE [dblShipmentTareWt] END
--						,[dblShipmentNetWt]						= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemShipmentNetWt ELSE [dblShipmentNetWt] END
--						,[intTicketId]							= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemTicketId ELSE [intTicketId] END
--						,[intTicketHoursWorkedId]				= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemTicketHoursWorkedId ELSE [intTicketHoursWorkedId] END
--						,[intCustomerStorageId]					= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemCustomerStorageId ELSE [intCustomerStorageId] END
--						,[intSiteDetailId]						= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemSiteDetailId ELSE [intSiteDetailId] END
--						,[intLoadDetailId]						= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemLoadDetailId ELSE [intLoadDetailId] END
--						,[intLotId]								= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemLotId ELSE [intLotId] END
--						,[intOriginalInvoiceDetailId]			= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemOriginalInvoiceDetailId ELSE [intOriginalInvoiceDetailId] END
--						,[intSiteId]							= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemSiteId ELSE [intSiteId] END
--						,[strBillingBy]							= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemBillingBy ELSE [strBillingBy] END
--						,[dblPercentFull]						= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemPercentFull ELSE [dblPercentFull] END
--						,[dblNewMeterReading]					= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemNewMeterReading ELSE [dblNewMeterReading] END
--						,[dblPreviousMeterReading]				= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemPreviousMeterReading ELSE [dblPreviousMeterReading] END
--						,[dblConversionFactor]					= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemConversionFactor ELSE [dblConversionFactor] END
--						,[intPerformerId]						= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemPerformerId ELSE [intPerformerId] END
--						,[ysnLeaseBilling]						= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemLeaseBilling ELSE [ysnLeaseBilling] END
--						,[ysnVirtualMeterReading]				= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemVirtualMeterReading ELSE [ysnVirtualMeterReading] END
--						,[intConversionAccountId]				= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemConversionAccountId ELSE [intConversionAccountId] END
--						,@ItemCurrencyExchangeRateTypeId		= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemCurrencyExchangeRateTypeId ELSE [intCurrencyExchangeRateTypeId] END
--						,@ItemCurrencyExchangeRateId			= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemCurrencyExchangeRateId ELSE [intCurrencyExchangeRateId] END
--						,@ItemCurrencyExchangeRate				= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemCurrencyExchangeRate ELSE [dblCurrencyExchangeRate] END
--						,@ItemSubCurrencyId						= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemSubCurrencyId ELSE [intSubCurrencyId] END
--						,@ItemSubCurrencyRate					= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemSubCurrencyRate ELSE [dblSubCurrencyRate] END
--						,[intConcurrencyId]						= [intConcurrencyId] + 1
--						,[intStorageScheduleTypeId]				= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemStorageScheduleTypeId ELSE [intStorageScheduleTypeId] END
--						,[intDestinationGradeId]				= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemDestinationGradeId ELSE [intDestinationGradeId] END
--						,[intDestinationWeightId]				= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemDestinationWeightId ELSE [intDestinationWeightId] END
--					WHERE
--						[intInvoiceId] = @ExistingInvoiceId
--						AND [intInvoiceDetailId] = @InvoiceDetailId						
--				END TRY
--				BEGIN CATCH
--					IF ISNULL(@RaiseError,0) = 0
--						ROLLBACK TRANSACTION
--					SET @ErrorMessage = ERROR_MESSAGE();
--					IF ISNULL(@RaiseError,0) = 1
--						RAISERROR(@ErrorMessage, 16, 1);
--					RETURN 0;
--				END CATCH



--				BEGIN TRY
--					DELETE FROM @TaxDetails
--					INSERT INTO @TaxDetails
--						([intDetailId]
--						,[intDetailTaxId]
--						,[intTaxGroupId]
--						,[intTaxCodeId]
--						,[intTaxClassId]
--						,[strTaxableByOtherTaxes]
--						,[strCalculationMethod]
--						,[dblRate]
--						,[intTaxAccountId]
--						,[dblTax]
--						,[dblAdjustedTax]
--						,[ysnTaxAdjusted]
--						,[ysnSeparateOnInvoice]
--						,[ysnCheckoffTax]
--						,[ysnTaxExempt]
--						,[strNotes])
--					SELECT
--						 [intDetailId]
--						,[intDetailTaxId]
--						,[intTaxGroupId]
--						,[intTaxCodeId]
--						,[intTaxClassId]
--						,[strTaxableByOtherTaxes]
--						,[strCalculationMethod]
--						,[dblRate]
--						,[intTaxAccountId]
--						,[dblTax]
--						,[dblAdjustedTax]
--						,[ysnTaxAdjusted]
--						,[ysnSeparateOnInvoice]
--						,[ysnCheckoffTax]
--						,[ysnTaxExempt]
--						,[strNotes]
--					FROM
--						@LineItemTaxEntries
--					WHERE
--						[intTempDetailIdForTaxes] = @TempDetailIdForTaxes
--						AND @UpdateAvailableDiscount = 0
						
--					EXEC	[dbo].[uspARProcessTaxDetailsForLineItem]
--									@TaxDetails	= @TaxDetails
--								,@UserId		= @EntityId
--								,@ClearExisting	= @ClearDetailTaxes
--								,@RaiseError	= @RaiseError
--								,@ErrorMessage	= @CurrentErrorMessage OUTPUT

--					IF LEN(ISNULL(@CurrentErrorMessage,'')) > 0
--						BEGIN
--							IF ISNULL(@RaiseError,0) = 0
--								ROLLBACK TRANSACTION
--							SET @ErrorMessage = @CurrentErrorMessage;
--							IF ISNULL(@RaiseError,0) = 1
--								RAISERROR(@ErrorMessage, 16, 1);
--							RETURN 0;
--						END
--				END TRY
--				BEGIN CATCH
--					IF ISNULL(@RaiseError,0) = 0
--						ROLLBACK TRANSACTION
--					SET @ErrorMessage = ERROR_MESSAGE();
--					IF ISNULL(@RaiseError,0) = 1
--						RAISERROR(@ErrorMessage, 16, 1);
--					RETURN 0;
--				END CATCH
		


--				UPDATE #EntriesForProcessing
--				SET
--					 [ysnProcessed]			= 1
--					,[intInvoiceDetailId]	= @NewExistingDetailId
--				WHERE
--					[intId] = @ForExistingDetailId
			
					
--			END
			
--		END
		
--		IF ISNULL(@ExistingInvoiceId, 0) <> 0
--			BEGIN			
--				EXEC [dbo].[uspARUpdateInvoiceIntegrations] @InvoiceId = @ExistingInvoiceId, @ForDelete = 0, @UserId = @EntityId	
--			END			
			
--		UPDATE #EntriesForProcessing
--		SET
--			 [ysnProcessed]	= 1
--			,[ysnPost]		= @Post
--			,[ysnRecap] 	= @Recap
--		WHERE		
--			[intInvoiceId] = @ExistingInvoiceId
--			AND ISNULL([ysnForUpdate],0) = 1
			
--	END
--END TRY
--BEGIN CATCH
--	IF ISNULL(@RaiseError,0) = 0
--		ROLLBACK TRANSACTION
--	SET @ErrorMessage = ERROR_MESSAGE();
--	IF ISNULL(@RaiseError,0) = 1
--		RAISERROR(@ErrorMessage, 16, 1);
--	RETURN 0;
--END CATCH

----Re-Compute
--BEGIN TRY
--	WHILE EXISTS(SELECT NULL FROM #EntriesForProcessing WHERE ISNULL([ysnRecomputed],0) = 0 AND ISNULL([ysnProcessed],0) = 1 AND ISNULL([intInvoiceId],0) <> 0)
--	BEGIN
--		SELECT TOP 1 @InvoiceId = [intInvoiceId], @Id = [intId] FROM #EntriesForProcessing WHERE ISNULL([ysnRecomputed],0) = 0 AND ISNULL([ysnProcessed],0) = 1 AND ISNULL([intInvoiceId],0) <> 0 ORDER BY [intId]
--		--SELECT TOP 1 @RecomputeTax = ISNULL([ysnRecomputeTax],0), @UpdateAvailableDiscount = ISNULL([ysnUpdateAvailableDiscount],0) FROM @InvoiceEntries WHERE [intId] = @Id 
--		--IF @RecomputeTax = 1
--		--	EXEC [dbo].[uspARReComputeInvoiceTaxes] @InvoiceId = @InvoiceId
--		--ELSE
--			EXEC [dbo].[uspARReComputeInvoiceAmounts] @InvoiceId = @InvoiceId, @AvailableDiscountOnly = @UpdateAvailableDiscount
						
--		UPDATE #EntriesForProcessing SET [ysnRecomputed] = 1 WHERE [intInvoiceId] = @InvoiceId
--	END	
--END TRY
--BEGIN CATCH
--	IF ISNULL(@RaiseError,0) = 0
--		ROLLBACK TRANSACTION
--	SET @ErrorMessage = ERROR_MESSAGE();
--	IF ISNULL(@RaiseError,0) = 1
--		RAISERROR(@ErrorMessage, 16, 1);
--	RETURN 0;
--END CATCH

--SET @batchIdUsed = ''

		
----Posting newly added Invoices
--DECLARE @IdsForPosting VARCHAR(MAX)
--BEGIN TRY
--	DELETE FROM @TempInvoiceIdTable
--	INSERT INTO @TempInvoiceIdTable
--	SELECT DISTINCT
--		[intInvoiceId]
--	FROM
--		#EntriesForProcessing
--	WHERE
--		ISNULL([ysnForInsert],0) = 1
--		AND ISNULL([ysnProcessed],0) = 1
--		AND ISNULL([intInvoiceId],0) <> 0
--		AND ISNULL([ysnPost],0) = 1
--		AND ISNULL([ysnRecap],0) <> 1	
		
--	SELECT 
--		@IdsForPosting = COALESCE(@IdsForPosting + ',' ,'') + CAST([intInvoiceId] AS NVARCHAR(250))
--	FROM
--		@TempInvoiceIdTable
		
--	IF LEN(RTRIM(LTRIM(@IdsForPosting))) > 0
--		BEGIN		
--		EXEC [dbo].[uspARPostInvoice]
--			@batchId			= @BatchIdForNewPost,
--			@post				= 1,
--			@recap				= 0,
--			@param				= @IdsForPosting,
--			@userId				= @UserId,
--			@beginDate			= NULL,
--			@endDate			= NULL,
--			@beginTransaction	= NULL,
--			@endTransaction		= NULL,
--			@exclude			= NULL,
--			@successfulCount	= @successfulCount OUTPUT,
--			@invalidCount		= @invalidCount OUTPUT,
--			@success			= @success OUTPUT,
--			@batchIdUsed		= @batchIdUsed OUTPUT,
--			@recapId			= @recapId OUTPUT,
--			@transType			= N'all',
--			@raiseError			= @RaiseError

--			SET @BatchIdForNewPost = @batchIdUsed
--			SET @PostedNewCount = @successfulCount
--		END
	
--	SET @IdsForPosting = ''
--	SET @batchIdUsed = ''	
--	SET @successfulCount = 0


--	DELETE FROM @TempInvoiceIdTable
--	INSERT INTO @TempInvoiceIdTable
--	SELECT DISTINCT
--		[intInvoiceId]
--	FROM
--		#EntriesForProcessing
--	WHERE
--		ISNULL([ysnForInsert],0) = 1
--		AND ISNULL([ysnProcessed],0) = 1
--		AND ISNULL([intInvoiceId],0) <> 0
--		AND ISNULL([ysnPost],0) = 1
--		AND ISNULL([ysnRecap],0) = 1	

--	SELECT
--		@IdsForPosting = COALESCE(@IdsForPosting + ',' ,'') + CAST([intInvoiceId] AS NVARCHAR(250))
--	FROM
--		@TempInvoiceIdTable
		
		
--	IF LEN(RTRIM(LTRIM(@IdsForPosting))) > 0
--		BEGIN	
--		EXEC [dbo].[uspARPostInvoice]
--			@batchId			= @BatchIdForNewPostRecap,
--			@post				= 1,
--			@recap				= 1,
--			@param				= @IdsForPosting,
--			@userId				= @UserId,
--			@beginDate			= NULL,
--			@endDate			= NULL,
--			@beginTransaction	= NULL,
--			@endTransaction		= NULL,
--			@exclude			= NULL,
--			@successfulCount	= @successfulCount OUTPUT,
--			@invalidCount		= @invalidCount OUTPUT,
--			@success			= @success OUTPUT,
--			@batchIdUsed		= @batchIdUsed OUTPUT,
--			@recapId			= @recapId OUTPUT,
--			@transType			= N'all',
--			@raiseError			= @RaiseError	

--			SET @BatchIdForNewPostRecap = @batchIdUsed
--			SET @RecapNewCount = @successfulCount
--		END
		
--	SET @IdsForPosting = ''
--	SET @batchIdUsed = ''	
--	SET @successfulCount = 0


--END TRY
--BEGIN CATCH
--	IF ISNULL(@RaiseError,0) = 0
--		ROLLBACK TRANSACTION
--	SET @ErrorMessage = ERROR_MESSAGE();
--	IF ISNULL(@RaiseError,0) = 1
--		RAISERROR(@ErrorMessage, 16, 1);
--	RETURN 0;
--END CATCH

----Posting Updated Invoices
--DECLARE @IdsForPostingUpdated VARCHAR(MAX)
--BEGIN TRY
--	DELETE FROM @TempInvoiceIdTable
--	INSERT INTO @TempInvoiceIdTable
--	SELECT DISTINCT
--		[intInvoiceId]
--	FROM
--		#EntriesForProcessing
--	WHERE
--		ISNULL([ysnForUpdate],0) = 1
--		AND ISNULL([ysnProcessed],0) = 1
--		AND ISNULL([intInvoiceId],0) <> 0
--		AND ISNULL([ysnPost],0) = 1
--		AND ISNULL([ysnRecap],0) <> 1	

--	SELECT
--		@IdsForPostingUpdated = COALESCE(@IdsForPostingUpdated + ',' ,'') + CAST([intInvoiceId] AS NVARCHAR(250))
--	FROM
--		@TempInvoiceIdTable
	
		
		
--	IF LEN(RTRIM(LTRIM(@IdsForPostingUpdated))) > 0
--		BEGIN			
--		EXEC [dbo].[uspARPostInvoice]
--			@batchId			= @BatchIdForExistingPost,
--			@post				= 1,
--			@recap				= 0,
--			@param				= @IdsForPostingUpdated,
--			@userId				= @UserId,
--			@beginDate			= NULL,
--			@endDate			= NULL,
--			@beginTransaction	= NULL,
--			@endTransaction		= NULL,
--			@exclude			= NULL,
--			@successfulCount	= @successfulCount OUTPUT,
--			@invalidCount		= @invalidCount OUTPUT,
--			@success			= @success OUTPUT,
--			@batchIdUsed		= @batchIdUsed OUTPUT,
--			@recapId			= @recapId OUTPUT,
--			@transType			= N'all',
--			@raiseError			= @RaiseError

--			SET @BatchIdForExistingPost = @batchIdUsed
--			SET @PostedExistingCount  = @successfulCount
--		END

--	SET @IdsForPostingUpdated = ''
--	SET @batchIdUsed = ''
--	SET @successfulCount = 0


--	DELETE FROM @TempInvoiceIdTable
--	INSERT INTO @TempInvoiceIdTable
--	SELECT DISTINCT
--		[intInvoiceId]
--	FROM
--		#EntriesForProcessing
--	WHERE
--		ISNULL([ysnForUpdate],0) = 1
--		AND ISNULL([ysnProcessed],0) = 1
--		AND ISNULL([intInvoiceId],0) <> 0
--		AND ISNULL([ysnPost],0) = 1
--		AND ISNULL([ysnRecap],0) = 1

--	SELECT
--		@IdsForPostingUpdated = COALESCE(@IdsForPostingUpdated + ',' ,'') + CAST([intInvoiceId] AS NVARCHAR(250))
--	FROM
--		@TempInvoiceIdTable
	
		
		
--	IF LEN(RTRIM(LTRIM(@IdsForPostingUpdated))) > 0
--		BEGIN			
--		EXEC [dbo].[uspARPostInvoice]
--			@batchId			= @BatchIdForExistingRecap,
--			@post				= 1,
--			@recap				= 1,
--			@param				= @IdsForPostingUpdated,
--			@userId				= @UserId,
--			@beginDate			= NULL,
--			@endDate			= NULL,
--			@beginTransaction	= NULL,
--			@endTransaction		= NULL,
--			@exclude			= NULL,
--			@successfulCount	= @successfulCount OUTPUT,
--			@invalidCount		= @invalidCount OUTPUT,
--			@success			= @success OUTPUT,
--			@batchIdUsed		= @batchIdUsed OUTPUT,
--			@recapId			= @recapId OUTPUT,
--			@transType			= N'all',
--			@raiseError			= @RaiseError

--			SET @BatchIdForExistingRecap = @batchIdUsed
--			SET @RecapPostExistingCount  = @successfulCount
--		END
		
--	SET @IdsForPostingUpdated = ''
--	SET @batchIdUsed = ''
--	SET @successfulCount = 0

--END TRY
--BEGIN CATCH
--	IF ISNULL(@RaiseError,0) = 0
--		ROLLBACK TRANSACTION
--	SET @ErrorMessage = ERROR_MESSAGE();
--	IF ISNULL(@RaiseError,0) = 1
--		RAISERROR(@ErrorMessage, 16, 1);
--	RETURN 0;
--END CATCH

----UnPosting Updated Invoices
--DECLARE @IdsForUnPostingUpdated VARCHAR(MAX)
--BEGIN TRY
--	DELETE FROM @TempInvoiceIdTable
--	INSERT INTO @TempInvoiceIdTable
--	SELECT DISTINCT
--		[intInvoiceId]
--	FROM
--		#EntriesForProcessing
--	WHERE
--		ISNULL([ysnForUpdate],0) = 1
--		AND ISNULL([ysnProcessed],0) = 1
--		AND ISNULL([intInvoiceId],0) <> 0
--		AND [ysnPost] IS NOT NULL
--		AND [ysnPost] = 0
--		AND ISNULL([ysnRecap],0) <> 1
			
--	SELECT
--		@IdsForUnPostingUpdated = COALESCE(@IdsForUnPostingUpdated + ',' ,'') + CAST([intInvoiceId] AS NVARCHAR(250))
--	FROM
--		@TempInvoiceIdTable
			
		
--	IF LEN(RTRIM(LTRIM(@IdsForUnPostingUpdated))) > 0
--		BEGIN			
--		EXEC [dbo].[uspARPostInvoice]
--			@batchId			= @BatchIdForExistingUnPost,
--			@post				= 0,
--			@recap				= 0,
--			@param				= @IdsForUnPostingUpdated,
--			@userId				= @UserId,
--			@beginDate			= NULL,
--			@endDate			= NULL,
--			@beginTransaction	= NULL,
--			@endTransaction		= NULL,
--			@exclude			= NULL,
--			@successfulCount	= @successfulCount OUTPUT,
--			@invalidCount		= @invalidCount OUTPUT,
--			@success			= @success OUTPUT,
--			@batchIdUsed		= @batchIdUsed OUTPUT,
--			@recapId			= @recapId OUTPUT,
--			@transType			= N'all',
--			@raiseError			= @RaiseError

--			SET @BatchIdForExistingUnPost = @batchIdUsed
--			SET @UnPostedExistingCount = @successfulCount
--		END

--	SET @IdsForUnPostingUpdated = ''
--	SET @batchIdUsed = ''
--	SET @successfulCount = 0

--	DELETE FROM @TempInvoiceIdTable
--	INSERT INTO @TempInvoiceIdTable
--	SELECT DISTINCT
--		[intInvoiceId]
--	FROM
--		#EntriesForProcessing
--	WHERE
--		ISNULL([ysnForUpdate],0) = 1
--		AND ISNULL([ysnProcessed],0) = 1
--		AND ISNULL([intInvoiceId],0) <> 0
--		AND [ysnPost] IS NOT NULL
--		AND [ysnPost] = 0
--		AND ISNULL([ysnRecap],0) = 1

--	SELECT
--		@IdsForUnPostingUpdated = COALESCE(@IdsForUnPostingUpdated + ',' ,'') + CAST([intInvoiceId] AS NVARCHAR(250))
--	FROM
--		@TempInvoiceIdTable	
		
		
--	IF LEN(RTRIM(LTRIM(@IdsForUnPostingUpdated))) > 0
--		BEGIN			
--		EXEC [dbo].[uspARPostInvoice]
--			@batchId			= @BatchIdForExistingUnPostRecap,
--			@post				= 0,
--			@recap				= 1,
--			@param				= @IdsForUnPostingUpdated,
--			@userId				= @UserId,
--			@beginDate			= NULL,
--			@endDate			= NULL,
--			@beginTransaction	= NULL,
--			@endTransaction		= NULL,
--			@exclude			= NULL,
--			@successfulCount	= @successfulCount OUTPUT,
--			@invalidCount		= @invalidCount OUTPUT,
--			@success			= @success OUTPUT,
--			@batchIdUsed		= @batchIdUsed OUTPUT,
--			@recapId			= @recapId OUTPUT,
--			@transType			= N'all',
--			@raiseError			= @RaiseError

--			SET @BatchIdForExistingUnPostRecap = @batchIdUsed
--			SET @RecapUnPostedExistingCount = @successfulCount
--		END

--END TRY
--BEGIN CATCH
--	IF ISNULL(@RaiseError,0) = 0
--		ROLLBACK TRANSACTION
--	SET @ErrorMessage = ERROR_MESSAGE();
--	IF ISNULL(@RaiseError,0) = 1
--		RAISERROR(@ErrorMessage, 16, 1);
--	RETURN 0;
--END CATCH


--DECLARE @CreateIds VARCHAR(MAX)
--DELETE FROM @TempInvoiceIdTable
--INSERT INTO @TempInvoiceIdTable
--SELECT DISTINCT
--	[intInvoiceId]
--FROM
--	#EntriesForProcessing
--WHERE
--	ISNULL([ysnForInsert],0) = 1
--	AND ISNULL([ysnProcessed],0) = 1
--	AND ISNULL([intInvoiceId],0) <> 0

--SELECT
--	@CreateIds = COALESCE(@CreateIds + ',' ,'') + CAST([intInvoiceId] AS NVARCHAR(250))
--FROM
--	@TempInvoiceIdTable

	
--SET @CreatedIvoices = @CreateIds


--DECLARE @UpdatedIds VARCHAR(MAX)
--DELETE FROM @TempInvoiceIdTable
--INSERT INTO @TempInvoiceIdTable
--SELECT DISTINCT
--	[intInvoiceId]
--FROM
--	#EntriesForProcessing
--WHERE
--	ISNULL([ysnForUpdate],0) = 1
--	AND ISNULL([ysnProcessed],0) = 1
--	AND ISNULL([intInvoiceId],0) <> 0

--SELECT
--	@UpdatedIds = COALESCE(@UpdatedIds + ',' ,'') + CAST([intInvoiceId] AS NVARCHAR(250))
--FROM
--	@TempInvoiceIdTable

	
--SET @UpdatedIvoices = @UpdatedIds



IF ISNULL(@RaiseError,0) = 0
	COMMIT TRANSACTION 
	
RETURN 1;

END
