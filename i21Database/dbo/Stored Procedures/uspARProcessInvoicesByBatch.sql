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
			
	IF (EXISTS(SELECT TOP 1 NULL FROM tblARInvoiceIntegrationLogDetail WITH (NOLOCK) WHERE [intIntegrationLogId] = @IntegrationLogId AND ISNULL([ysnSuccess],0) = 1 AND ISNULL([ysnHeader],0) = 1  AND ISNULL([ysnInsert], 0) = 1) AND @GroupingOption > 0)
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
			(SELECT [intInvoiceId], [intInvoiceDetailId], [intTemporaryDetailIdForTax], [ysnHeader], [ysnSuccess], [intId], [strTransactionType], [strType], [strSourceTransaction], [intIntegrationLogId], [intSourceId], [strSourceId], [ysnInsert] FROM tblARInvoiceIntegrationLogDetail WITH (NOLOCK)) ARIILD
				ON LITE.[intTempDetailIdForTaxes] = ARIILD.[intTemporaryDetailIdForTax]
				AND ISNULL(ARIILD.[ysnHeader], 0) = 0
				AND ISNULL(ARIILD.[ysnSuccess], 0) = 1
				AND ISNULL(ARIILD.[intInvoiceDetailId], 0) <> 0
				AND ISNULL(ARIILD.[ysnInsert], 0) = 1
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

	DECLARE @InsertedInvoiceIds InvoiceId	
	DELETE FROM @InsertedInvoiceIds

	INSERT INTO @InsertedInvoiceIds(
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
				@InvoiceIds	= @InsertedInvoiceIds
				,@UserId		= @UserId


	EXEC [dbo].[uspARReComputeInvoicesAmounts] @InvoiceIds = @InsertedInvoiceIds
		
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


--UnPosting posted Invoices for update
BEGIN TRY
	DECLARE @IdsForUnPosting InvoiceId

	INSERT INTO @IdsForUnPosting(
		 [intHeaderId]
		,[ysnUpdateAvailableDiscountOnly]
		,[intDetailId]
		,[ysnPost]
		,[ysnAccrueLicense]
		,[strTransactionType]
	)
	SELECT DISTINCT
		 [intHeaderId]						= EFP.[intInvoiceId]
		,[ysnUpdateAvailableDiscountOnly]	= IE.[ysnUpdateAvailableDiscount] 
		,[intDetailId]						= EFP.[intInvoiceDetailId] 
		,[ysnPost]							= IE.[ysnPost] 
		,[ysnAccrueLicense]					= IE.[ysnAccrueLicense]
		,[strTransactionType]				= IE.[strTransactionType] 		
	FROM
		#EntriesForProcessing EFP
	INNER JOIN
		@InvoiceEntries IE
			ON EFP.[intInvoiceId] = IE.[intInvoiceId] 
	WHERE
		ISNULL(EFP.[ysnForUpdate],0) = 1
		AND ISNULL(EFP.[intInvoiceId],0) <> 0
		AND EFP.[ysnPost] IS NOT NULL AND EFP.[ysnPost] = 0
		AND ISNULL(IE.[ysnUpdateAvailableDiscount], 0) = 0
		AND ISNULL(EFP.[ysnRecap], 0) = 0

		
	IF EXISTS(SELECT TOP 1 NULL FROM @IdsForUnPosting)
		EXEC [dbo].[uspARPostInvoiceNew]
			 @BatchId			= NULL
			,@Post				= 0
			,@Recap				= 0
			,@UserId			= @UserId
			,@InvoiceIds		= @IdsForUnPosting
			,@IntegrationLogId	= @IntegrationLogId
			,@BeginDate			= NULL
			,@EndDate			= NULL
			,@BeginTransaction	= NULL
			,@EndTransaction	= NULL
			,@Exclude			= NULL
			,@TransType			= N'all'
			,@RaiseError		= @RaiseError

END TRY
BEGIN CATCH
	IF ISNULL(@RaiseError,0) = 0
		ROLLBACK TRANSACTION
	SET @ErrorMessage = ERROR_MESSAGE();
	IF ISNULL(@RaiseError,0) = 1
		RAISERROR(@ErrorMessage, 16, 1);
	RETURN 0;
END CATCH


--UPDATE
BEGIN TRY
IF EXISTS(SELECT TOP 1 NULL FROM #EntriesForProcessing WITH (NOLOCK) WHERE ISNULL([ysnForInsert],0) = 0)
BEGIN
	DECLARE @InvoicesForUpdate	InvoiceStagingTable	
	DELETE FROM @InvoicesForUpdate		
	INSERT INTO @InvoicesForUpdate						
	SELECT		 	
		 *
	FROM
		@InvoiceEntries IE
	INNER JOIN
		#EntriesForProcessing EFP WITH (NOLOCK)
			ON IE.[intId] = EFP.[intId]
	WHERE
		ISNULL(EFP.[ysnForInsert],0) = 0
		AND ISNULL(IE.[intInvoiceId], 0) <> 0
		AND ISNULL(IE.[intInvoiceDetailId], 0) <> 0
	ORDER BY
		[intId]

			
	BEGIN TRY		
		EXEC [dbo].[uspARUpdateCustomerInvoices]
			 	 @InvoiceEntries	= @InvoicesForUpdate
				,@IntegrationLogId	= @IntegrationLogId
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
			
	IF EXISTS(SELECT TOP 1 NULL FROM tblARInvoiceIntegrationLogDetail WITH (NOLOCK) WHERE [intIntegrationLogId] = @IntegrationLogId AND ISNULL([ysnSuccess],0) = 1 AND ISNULL([ysnHeader],0) = 1 AND ISNULL([ysnInsert], 0) = 0)
	BEGIN

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
			(SELECT [intInvoiceId], [intInvoiceDetailId], [intTemporaryDetailIdForTax], [ysnHeader], [ysnSuccess], [intId], [strTransactionType], [strType], [strSourceTransaction], [intIntegrationLogId], [intSourceId], [strSourceId], [ysnInsert] FROM tblARInvoiceIntegrationLogDetail WITH (NOLOCK)) ARIILD
				ON LITE.[intTempDetailIdForTaxes] = ARIILD.[intTemporaryDetailIdForTax]
				AND ISNULL(ARIILD.[ysnHeader], 0) = 0
				AND ISNULL(ARIILD.[ysnSuccess], 0) = 1
				AND ISNULL(ARIILD.[intInvoiceDetailId], 0) <> 0
				AND ISNULL(ARIILD.[ysnInsert], 0) = 0
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

	DECLARE @UpdatedInvoiceIds InvoiceId	
	DELETE FROM @UpdatedInvoiceIds

	INSERT INTO @UpdatedInvoiceIds(
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
				@InvoiceIds	= @UpdatedInvoiceIds
				,@UserId		= @UserId


	EXEC [dbo].[uspARReComputeInvoicesAmounts] @InvoiceIds = @UpdatedInvoiceIds
		
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

		
------Posting newly added Invoices
--BEGIN TRY
--	DECLARE @IdsForPostingNew InvoiceId

--	INSERT INTO @IdsForPostingNew
--	SELECT DISTINCT
--		EFP.[intInvoiceId]
--	FROM
--		#EntriesForProcessing EFP
--	INNER JOIN
--		@InvoiceEntries IE
--			ON EFP.[intInvoiceId] = IE.[intInvoiceId] 
--	WHERE
--		ISNULL(EFP.[ysnForInsert],0) = 1
--		AND ISNULL(EFP.[intInvoiceId],0) <> 0
--		AND EFP.[ysnPost] IS NOT NULL AND EFP.[ysnPost] = 1
--		AND ISNULL(IE.[ysnUpdateAvailableDiscount], 0) = 0
--		AND ISNULL(EFP.[ysnRecap], 0) = 0

--Posting newly added Invoices

--UnPosting posted Invoices for update

--Posting Newly Created Invoices
BEGIN TRY
	DECLARE @NewIdsForPosting InvoiceId
	INSERT INTO @NewIdsForPosting(
		 [intHeaderId]
		,[ysnUpdateAvailableDiscountOnly]
		,[intDetailId]
		,[ysnPost]
		,[ysnAccrueLicense]
		,[strTransactionType]
	)
	SELECT DISTINCT
		 [intHeaderId]						= [intInvoiceId]
		,[ysnUpdateAvailableDiscountOnly]	= [ysnUpdateAvailableDiscount] 
		,[intDetailId]						= [intInvoiceDetailId] 
		,[ysnPost]							= [ysnPost] 
		,[ysnAccrueLicense]					= [ysnAccrueLicense]
		,[strTransactionType]				= [strTransactionType] 	
	FROM
		tblARInvoiceIntegrationLogDetail
	WHERE
		[intIntegrationLogId] = @IntegrationLogId
		AND ISNULL([ysnSuccess], 0) = 1
		AND ISNULL([ysnHeader], 0) = 1	
		AND ISNULL([ysnInsert], 0) = 1	
		AND [ysnPost] IS NOT NULL
		AND [ysnPost] = 1
		AND ISNULL([ysnRecap], 0) = 0

		
	IF EXISTS(SELECT TOP 1 NULL FROM @NewIdsForPosting)
		EXEC [dbo].[uspARPostInvoiceNew]
			 @BatchId			= NULL
			,@Post				= 1
			,@Recap				= 0
			,@UserId			= @UserId
			,@InvoiceIds		= @NewIdsForPosting
			,@IntegrationLogId	= @IntegrationLogId
			,@BeginDate			= NULL
			,@EndDate			= NULL
			,@BeginTransaction	= NULL
			,@EndTransaction	= NULL
			,@Exclude			= NULL
			,@TransType			= N'all'
			,@RaiseError		= @RaiseError

	DECLARE @NewIdsForPostingRecap InvoiceId
	INSERT INTO @NewIdsForPostingRecap(
		 [intHeaderId]
		,[ysnUpdateAvailableDiscountOnly]
		,[intDetailId]
		,[ysnPost]
		,[ysnAccrueLicense]
		,[strTransactionType]
	)
	SELECT DISTINCT
		 [intHeaderId]						= [intInvoiceId]
		,[ysnUpdateAvailableDiscountOnly]	= [ysnUpdateAvailableDiscount] 
		,[intDetailId]						= [intInvoiceDetailId] 
		,[ysnPost]							= [ysnPost] 
		,[ysnAccrueLicense]					= [ysnAccrueLicense]
		,[strTransactionType]				= [strTransactionType] 	
	FROM
		tblARInvoiceIntegrationLogDetail
	WHERE
		[intIntegrationLogId] = @IntegrationLogId
		AND ISNULL([ysnSuccess], 0) = 1
		AND ISNULL([ysnHeader], 0) = 1	
		AND ISNULL([ysnInsert], 0) = 1	
		AND [ysnPost] IS NOT NULL
		AND [ysnPost] = 1
		AND ISNULL([ysnRecap], 0) = 1

		
	IF EXISTS(SELECT TOP 1 NULL FROM @NewIdsForPostingRecap)
		EXEC [dbo].[uspARPostInvoiceNew]
			 @BatchId			= NULL
			,@Post				= 1
			,@Recap				= 1
			,@UserId			= @UserId
			,@InvoiceIds		= @NewIdsForPostingRecap
			,@IntegrationLogId	= @IntegrationLogId
			,@BeginDate			= NULL
			,@EndDate			= NULL
			,@BeginTransaction	= NULL
			,@EndTransaction	= NULL
			,@Exclude			= NULL
			,@TransType			= N'all'
			,@RaiseError		= @RaiseError
END TRY
BEGIN CATCH
	IF ISNULL(@RaiseError,0) = 0
		ROLLBACK TRANSACTION
	SET @ErrorMessage = ERROR_MESSAGE();
	IF ISNULL(@RaiseError,0) = 1
		RAISERROR(@ErrorMessage, 16, 1);
	RETURN 0;
END CATCH

		
--Posting Updated Invoices
BEGIN TRY
	DECLARE @UpdatedIdsForPosting InvoiceId
	INSERT INTO @UpdatedIdsForPosting(
		 [intHeaderId]
		,[ysnUpdateAvailableDiscountOnly]
		,[intDetailId]
		,[ysnPost]
		,[ysnAccrueLicense]
		,[strTransactionType]
	)
	SELECT DISTINCT
		 [intHeaderId]						= [intInvoiceId]
		,[ysnUpdateAvailableDiscountOnly]	= [ysnUpdateAvailableDiscount] 
		,[intDetailId]						= [intInvoiceDetailId] 
		,[ysnPost]							= [ysnPost] 
		,[ysnAccrueLicense]					= [ysnAccrueLicense]
		,[strTransactionType]				= [strTransactionType] 	
	FROM
		tblARInvoiceIntegrationLogDetail
	WHERE
		[intIntegrationLogId] = @IntegrationLogId
		AND ISNULL([ysnSuccess], 0) = 1
		AND ISNULL([ysnHeader], 0) = 1	
		AND ISNULL([ysnInsert], 0) = 0	
		AND [ysnPost] IS NOT NULL
		AND [ysnPost] = 1
		AND ISNULL([ysnRecap], 0) = 0

		
	IF EXISTS(SELECT TOP 1 NULL FROM @UpdatedIdsForPosting)
		EXEC [dbo].[uspARPostInvoiceNew]
			 @BatchId			= NULL
			,@Post				= 1
			,@Recap				= 0
			,@UserId			= @UserId
			,@InvoiceIds		= @UpdatedIdsForPosting
			,@IntegrationLogId	= @IntegrationLogId
			,@BeginDate			= NULL
			,@EndDate			= NULL
			,@BeginTransaction	= NULL
			,@EndTransaction	= NULL
			,@Exclude			= NULL
			,@TransType			= N'all'
			,@RaiseError		= @RaiseError

	DECLARE @UpdatedIdsForPostingRecap InvoiceId
	INSERT INTO @UpdatedIdsForPostingRecap(
		 [intHeaderId]
		,[ysnUpdateAvailableDiscountOnly]
		,[intDetailId]
		,[ysnPost]
		,[ysnAccrueLicense]
		,[strTransactionType]
	)
	SELECT DISTINCT
		 [intHeaderId]						= [intInvoiceId]
		,[ysnUpdateAvailableDiscountOnly]	= [ysnUpdateAvailableDiscount] 
		,[intDetailId]						= [intInvoiceDetailId] 
		,[ysnPost]							= [ysnPost] 
		,[ysnAccrueLicense]					= [ysnAccrueLicense]
		,[strTransactionType]				= [strTransactionType] 	
	FROM
		tblARInvoiceIntegrationLogDetail
	WHERE
		[intIntegrationLogId] = @IntegrationLogId
		AND ISNULL([ysnSuccess], 0) = 1
		AND ISNULL([ysnHeader], 0) = 1	
		AND ISNULL([ysnInsert], 0) = 0	
		AND [ysnPost] IS NOT NULL
		AND [ysnPost] = 1
		AND ISNULL([ysnRecap], 0) = 1

		
	IF EXISTS(SELECT TOP 1 NULL FROM @UpdatedIdsForPostingRecap)
		EXEC [dbo].[uspARPostInvoiceNew]
			 @BatchId			= NULL
			,@Post				= 1
			,@Recap				= 1
			,@UserId			= @UserId
			,@InvoiceIds		= @UpdatedIdsForPostingRecap
			,@IntegrationLogId	= @IntegrationLogId
			,@BeginDate			= NULL
			,@EndDate			= NULL
			,@BeginTransaction	= NULL
			,@EndTransaction	= NULL
			,@Exclude			= NULL
			,@TransType			= N'all'
			,@RaiseError		= @RaiseError
END TRY
BEGIN CATCH
	IF ISNULL(@RaiseError,0) = 0
		ROLLBACK TRANSACTION
	SET @ErrorMessage = ERROR_MESSAGE();
	IF ISNULL(@RaiseError,0) = 1
		RAISERROR(@ErrorMessage, 16, 1);
	RETURN 0;
END CATCH

--UnPosting Updated Invoices
BEGIN TRY
	DECLARE @UpdatedIdsForUnPosting InvoiceId
	INSERT INTO @UpdatedIdsForUnPosting(
		 [intHeaderId]
		,[ysnUpdateAvailableDiscountOnly]
		,[intDetailId]
		,[ysnPost]
		,[ysnAccrueLicense]
		,[strTransactionType]
	)
	SELECT DISTINCT
		 [intHeaderId]						= [intInvoiceId]
		,[ysnUpdateAvailableDiscountOnly]	= [ysnUpdateAvailableDiscount] 
		,[intDetailId]						= [intInvoiceDetailId] 
		,[ysnPost]							= [ysnPost] 
		,[ysnAccrueLicense]					= [ysnAccrueLicense]
		,[strTransactionType]				= [strTransactionType] 	
	FROM
		tblARInvoiceIntegrationLogDetail
	WHERE
		[intIntegrationLogId] = @IntegrationLogId
		AND ISNULL([ysnSuccess], 0) = 1
		AND ISNULL([ysnHeader], 0) = 1	
		AND ISNULL([ysnInsert], 0) = 0	
		AND [ysnPost] IS NOT NULL
		AND [ysnPost] = 1
		AND ISNULL([ysnRecap], 0) = 0

		
	IF EXISTS(SELECT TOP 1 NULL FROM @UpdatedIdsForUnPosting)
		EXEC [dbo].[uspARPostInvoiceNew]
			 @BatchId			= NULL
			,@Post				= 0
			,@Recap				= 0
			,@UserId			= @UserId
			,@InvoiceIds		= @UpdatedIdsForUnPosting
			,@IntegrationLogId	= @IntegrationLogId
			,@BeginDate			= NULL
			,@EndDate			= NULL
			,@BeginTransaction	= NULL
			,@EndTransaction	= NULL
			,@Exclude			= NULL
			,@TransType			= N'all'
			,@RaiseError		= @RaiseError

	DECLARE @UpdatedIdsForUnPostingRecap InvoiceId
	INSERT INTO @UpdatedIdsForUnPostingRecap(
		 [intHeaderId]
		,[ysnUpdateAvailableDiscountOnly]
		,[intDetailId]
		,[ysnPost]
		,[ysnAccrueLicense]
		,[strTransactionType]
	)
	SELECT DISTINCT
		 [intHeaderId]						= [intInvoiceId]
		,[ysnUpdateAvailableDiscountOnly]	= [ysnUpdateAvailableDiscount] 
		,[intDetailId]						= [intInvoiceDetailId] 
		,[ysnPost]							= [ysnPost] 
		,[ysnAccrueLicense]					= [ysnAccrueLicense]
		,[strTransactionType]				= [strTransactionType] 	
	FROM
		tblARInvoiceIntegrationLogDetail
	WHERE
		[intIntegrationLogId] = @IntegrationLogId
		AND ISNULL([ysnSuccess], 0) = 1
		AND ISNULL([ysnHeader], 0) = 1	
		AND ISNULL([ysnInsert], 0) = 0	
		AND [ysnPost] IS NOT NULL
		AND [ysnPost] = 1
		AND ISNULL([ysnRecap], 0) = 1

		
	IF EXISTS(SELECT TOP 1 NULL FROM @UpdatedIdsForUnPostingRecap)
		EXEC [dbo].[uspARPostInvoiceNew]
			 @BatchId			= NULL
			,@Post				= 0
			,@Recap				= 1
			,@UserId			= @UserId
			,@InvoiceIds		= @UpdatedIdsForUnPostingRecap
			,@IntegrationLogId	= @IntegrationLogId
			,@BeginDate			= NULL
			,@EndDate			= NULL
			,@BeginTransaction	= NULL
			,@EndTransaction	= NULL
			,@Exclude			= NULL
			,@TransType			= N'all'
			,@RaiseError		= @RaiseError
END TRY
BEGIN CATCH
	IF ISNULL(@RaiseError,0) = 0
		ROLLBACK TRANSACTION
	SET @ErrorMessage = ERROR_MESSAGE();
	IF ISNULL(@RaiseError,0) = 1
		RAISERROR(@ErrorMessage, 16, 1);
	RETURN 0;
END CATCH


IF ISNULL(@RaiseError,0) = 0
	COMMIT TRANSACTION 
	
RETURN 1;

END
