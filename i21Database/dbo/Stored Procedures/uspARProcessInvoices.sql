CREATE PROCEDURE [dbo].[uspARProcessInvoices]
	 @InvoiceEntries				InvoiceIntegrationStagingTable					READONLY	
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
	,@RaiseError					BIT								= 0
	,@ErrorMessage					NVARCHAR(250)					= NULL			OUTPUT
	,@CreatedIvoices				NVARCHAR(MAX)					= NULL			OUTPUT
	,@UpdatedIvoices				NVARCHAR(MAX)					= NULL			OUTPUT
	,@BatchIdForNewPost				NVARCHAR(50)					= NULL			OUTPUT
	,@PostedNewCount				INT								= 0				OUTPUT
	,@BatchIdForNewPostRecap		NVARCHAR(50)					= NULL			OUTPUT
	,@RecapNewCount					INT								= 0				OUTPUT
	,@BatchIdForExistingPost		NVARCHAR(50)					= NULL			OUTPUT
	,@PostedExistingCount			INT								= 0				OUTPUT
	,@BatchIdForExistingRecap		NVARCHAR(50)					= NULL			OUTPUT
	,@RecapPostExistingCount		INT								= 0				OUTPUT
	,@BatchIdForExistingUnPost		NVARCHAR(50)					= NULL			OUTPUT
	,@UnPostedExistingCount			INT								= 0				OUTPUT
	,@BatchIdForExistingUnPostRecap	NVARCHAR(50)					= NULL			OUTPUT
	,@RecapUnPostedExistingCount	INT								= 0				OUTPUT
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
		(ISNULL([intSourceId],0) = 0 AND [strSourceTransaction] IN ('Sale OffSite','Settle Storage','Process Grain Storage','Transfer Storage','Load/Shipment Schedules','Credit Card Reconciliation', 'CF Invoice')) 

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
			,@intId AS VARCHAR(100)
			
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
					END)
					
	SET @intId = (CASE WHEN @GroupingOption = 0 THEN '' ELSE '[intId],' END)
					
	SET @QueryString = 'INSERT INTO #EntriesForProcessing( ' + @intId + @Columns + ', [ysnForInsert]) SELECT ' + @intId + @Columns + ', 1 FROM #TempInvoiceEntries WHERE ISNULL([intInvoiceId],0) = 0 GROUP BY ' + @intId + @Columns
	EXECUTE(@QueryString);

	SET @QueryString = 'INSERT INTO #EntriesForProcessing(' + @intId + ' [intInvoiceId], [intInvoiceDetailId], ' + @Columns + ', [ysnForUpdate]) SELECT DISTINCT ' + @intId + ' [intInvoiceId], [intInvoiceDetailId], ' + @Columns + ', 1 FROM #TempInvoiceEntries WHERE ISNULL([intInvoiceId],0) <> 0 GROUP BY ' + @intId + ' [intInvoiceId], [intInvoiceDetailId],' + @Columns
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

DECLARE @TaxDetails AS LineItemTaxDetailStagingTable

DECLARE  @Id									INT
		,@TransactionType						NVARCHAR(25)	
		,@Type									NVARCHAR(100)	
		,@SourceTransaction						NVARCHAR(250)	
		,@SourceId								INT	
		,@PeriodsToAccrue						INT	
		,@SourceNumber							NVARCHAR(250)
		,@InvoiceId								INT
		,@EntityCustomerId						INT
		,@CompanyLocationId						INT
		,@AccountId								INT
		,@CurrencyId							INT
		,@TermId								INT
		,@Date									DATETIME
		,@DueDate								DATETIME
		,@ShipDate								DATETIME
		,@PostDate								DATETIME
		,@EntitySalespersonId					INT
		,@FreightTermId							INT
		,@ShipViaId								INT
		,@PaymentMethodId						INT
		,@InvoiceOriginId						NVARCHAR(25)
		,@UseOriginIdAsInvoiceNumber			BIT
		,@PONumber								NVARCHAR(25)
		,@BOLNumber								NVARCHAR(50)
		,@DeliverPickup							NVARCHAR(100)
		,@Comment								NVARCHAR(500)
		,@ShipToLocationId						INT
		,@BillToLocationId						INT
		,@Template								BIT
		,@Forgiven								BIT
		,@Calculated							BIT
		,@Splitted								BIT
		,@PaymentId								INT
		,@SplitId								INT
		,@LoadDistributionHeaderId				INT
		,@ActualCostId							NVARCHAR(50)
		,@ShipmentId							INT
		,@TransactionId							INT
		,@MeterReadingId						INT
		,@ContractHeaderId						INT
		,@LoadId								INT
		,@OriginalInvoiceId						INT
		,@EntityId								INT
		,@TruckDriverId							INT
		,@TruckDriverReferenceId				INT
		,@ResetDetails							BIT
		,@Recap									BIT
		,@Post									BIT
		,@UpdateAvailableDiscount				BIT
		,@ImportFormat							NVARCHAR(50)

		,@InvoiceDetailId						INT
		,@ItemId								INT
		,@ItemPrepayTypeId						INT
		,@ItemPrepayRate						NUMERIC(18, 6)
		,@Inventory								BIT
		,@ItemDocumentNumber					NVARCHAR(100)
		,@ItemDescription						NVARCHAR(250)
		,@OrderUOMId							INT
		,@ItemQtyOrdered						NUMERIC(18, 6)
		,@ItemUOMId								INT
		,@ItemQtyShipped						NUMERIC(18, 6)
		,@ItemDiscount							NUMERIC(18, 6)
		,@ItemTermDiscount						NUMERIC(18, 6)
		,@ItemTermDiscountBy					NVARCHAR(50)
		,@ItemPrice								NUMERIC(18, 6)
		,@ItemPricing							NVARCHAR(250)
		,@ItemVFDDocumentNumber					NVARCHAR(100)
		,@RefreshPrice							BIT
		,@ItemMaintenanceType					NVARCHAR(25)
		,@ItemFrequency							NVARCHAR(25)
		,@ItemMaintenanceDate					DATETIME
		,@ItemMaintenanceAmount					NUMERIC(18, 6)
		,@ItemLicenseAmount						NUMERIC(18, 6)
		,@ItemTaxGroupId						INT
		,@ItemStorageLocationId					INT
		,@ItemCompanyLocationSubLocationId		INT
		,@RecomputeTax							BIT
		,@ItemSCInvoiceId						INT
		,@ItemSCInvoiceNumber					NVARCHAR(25)
		,@ItemInventoryShipmentItemId			INT
		,@ItemInventoryShipmentChargeId			INT
		,@ItemShipmentNumber					NVARCHAR(50)
		,@ItemRecipeItemId						INT
		,@ItemRecipeId							INT
		,@ItemSublocationId						INT
		,@ItemCostTypeId						INT
		,@ItemMarginById						INT
		,@ItemCommentTypeId						INT
		,@ItemMargin							NUMERIC(18,6)
		,@ItemRecipeQty							NUMERIC(18,6)
		,@ItemSalesOrderDetailId				INT
		,@ItemSalesOrderNumber					NVARCHAR(25)		
		,@ItemContractDetailId					INT
		,@ItemShipmentPurchaseSalesContractId	INT
		,@ItemWeightUOMId						INT
		,@ItemWeight							NUMERIC(18,6)
		,@ItemShipmentGrossWt					NUMERIC(18,6)
		,@ItemShipmentTareWt					NUMERIC(18,6)
		,@ItemShipmentNetWt						NUMERIC(18,6)
		,@ItemTicketId							INT
		,@ItemTicketHoursWorkedId				INT
		,@ItemCustomerStorageId					INT
		,@ItemSiteDetailId						INT
		,@ItemLoadDetailId						INT
		,@ItemOriginalInvoiceDetailId			INT			
		,@ItemSiteId							INT
		,@ItemBillingBy							NVARCHAR(100)
		,@ItemPercentFull						NUMERIC(18, 6)
		,@ItemNewMeterReading					NUMERIC(18, 6)
		,@ItemPreviousMeterReading				NUMERIC(18, 6)
		,@ItemConversionFactor					NUMERIC(18, 8)
		,@ItemPerformerId						INT
		,@ItemLeaseBilling						BIT
		,@ItemVirtualMeterReading				BIT
		,@ClearDetailTaxes						BIT
		,@TempDetailIdForTaxes					INT
		,@ItemCurrencyExchangeRateTypeId		INT
		,@ItemCurrencyExchangeRateId			INT
		,@ItemCurrencyExchangeRate				NUMERIC(18, 8)
		,@ItemSubCurrencyId						INT
		,@ItemSubCurrencyRate					NUMERIC(18, 8)
		,@ItemIsBlended							BIT
		,@ItemConversionAccountId				INT
		,@ItemSalesAccountId					INT
		,@ItemStorageScheduleTypeId				INT
		,@ItemDestinationGradeId				INT
		,@ItemDestinationWeightId				INT

--INSERT
BEGIN TRY
WHILE EXISTS(SELECT NULL FROM #EntriesForProcessing WHERE ISNULL([ysnForInsert],0) = 1 AND ISNULL([ysnProcessed],0) = 0)
BEGIN
	DECLARE @NewSourceId INT = 0					
	SELECT TOP 1
		 @Id						= [intId]				
		,@EntityCustomerId			= [intEntityCustomerId]		
		,@SourceId					= [intSourceId]				
		,@CompanyLocationId			= [intCompanyLocationId]		
		,@CurrencyId				= [intCurrencyId]			
		,@Date						= CAST([dtmDate] AS DATE)					
		,@TermId					= [intTermId]
		,@Comment					= [strComments]				
		,@ShipViaId					= [intShipViaId]			
		,@EntitySalespersonId		= [intEntitySalespersonId]				
		,@PONumber					= [strPONumber]				
		,@BOLNumber					= [strBOLNumber]				
		
	FROM 
		#EntriesForProcessing
	WHERE
		ISNULL([ysnForInsert],0) = 1
		AND ISNULL([ysnProcessed],0) = 0
	ORDER BY
		[intSourceId]
		,[intId]
								
	SELECT TOP 1		 	
		 @TransactionType				= [strTransactionType]
		,@Type							= [strType]
		,@SourceTransaction				= [strSourceTransaction]
		,@SourceId						= [intSourceId] -- dbo.[fnARValidateInvoiceSourceId]([strSourceTransaction], [intSourceId])
		,@PeriodsToAccrue				= [intPeriodsToAccrue] 
		,@SourceNumber					= [strSourceId]
		,@InvoiceId						= [intInvoiceId]
		,@EntityCustomerId				= [intEntityCustomerId]
		,@CompanyLocationId				= [intCompanyLocationId]
		,@AccountId						= [intAccountId]
		,@CurrencyId					= [intCurrencyId]
		,@TermId						= [intTermId]
		,@Date							= CAST(ISNULL([dtmDate], @DateNow) AS DATE)
		,@DueDate						= [dtmDueDate]
		,@ShipDate						= CAST(ISNULL([dtmShipDate], @DateNow) AS DATE)
		,@PostDate						= [dtmPostDate]
		,@EntitySalespersonId			= [intEntitySalespersonId]
		,@FreightTermId					= [intFreightTermId]
		,@ShipViaId						= [intShipViaId]
		,@PaymentMethodId				= [intPaymentMethodId]
		,@InvoiceOriginId				= [strInvoiceOriginId]
		,@UseOriginIdAsInvoiceNumber	= [ysnUseOriginIdAsInvoiceNumber]
		,@PONumber						= [strPONumber]
		,@BOLNumber						= [strBOLNumber]
		,@DeliverPickup					= [strDeliverPickup]
		,@Comment						= [strComments]
		,@ShipToLocationId				= [intShipToLocationId]
		,@BillToLocationId				= [intBillToLocationId]
		,@Template						= [ysnTemplate]
		,@Forgiven						= [ysnForgiven]
		,@Calculated					= [ysnCalculated]
		,@Splitted						= [ysnSplitted]
		,@PaymentId						= [intPaymentId]
		,@SplitId						= [intSplitId]
		,@LoadDistributionHeaderId		= (CASE WHEN ISNULL([strSourceTransaction],'') = 'Transport Load' THEN ISNULL([intLoadDistributionHeaderId], [intSourceId]) ELSE NULL END)
		,@ActualCostId					= (CASE WHEN ISNULL([strSourceTransaction],'') = 'Transport Load' THEN [strActualCostId] ELSE NULL END)
		,@ShipmentId					= (CASE WHEN ISNULL([strSourceTransaction],'') = 'Inbound Shipment' THEN ISNULL([intShipmentId], [intSourceId]) ELSE NULL END)
		,@TransactionId 				= (CASE WHEN ISNULL([strSourceTransaction],'') IN ('Card Fueling Transaction', 'CF Tran') THEN ISNULL([intTransactionId], [intSourceId]) ELSE NULL END)
		,@MeterReadingId				= (CASE WHEN ISNULL([strSourceTransaction],'') = 'Meter Billing' THEN ISNULL([intMeterReadingId], [intSourceId]) ELSE NULL END)
		,@ContractHeaderId				= (CASE WHEN ISNULL([strSourceTransaction],'') = 'Sales Contract' THEN ISNULL([intContractHeaderId], [intSourceId]) ELSE NULL END)
		,@LoadId						= (CASE WHEN ISNULL([strSourceTransaction],'') = 'Load Schedule' THEN ISNULL([intLoadId], [intSourceId]) ELSE NULL END)
		,@OriginalInvoiceId				= (CASE WHEN ISNULL([strSourceTransaction],'') = 'Provisional Invoice' THEN ISNULL([intOriginalInvoiceId], [intSourceId]) ELSE NULL END)
		,@EntityId						= [intEntityId]
		,@TruckDriverId					= [intTruckDriverId]
		,@TruckDriverReferenceId		= [intTruckDriverReferenceId]
		,@ResetDetails					= [ysnResetDetails]
		,@Recap							= [ysnRecap]
		,@Post							= [ysnPost]
		,@UpdateAvailableDiscount		= [ysnUpdateAvailableDiscount]
		,@ImportFormat					= [strImportFormat]

		,@InvoiceDetailId				= [intInvoiceDetailId]
		,@ItemId						= (CASE WHEN @GroupingOption = 0 THEN [intItemId] ELSE NULL END) 
		,@ItemPrepayTypeId 				= (CASE WHEN @GroupingOption = 0 THEN [intPrepayTypeId] ELSE NULL END) 
		,@ItemPrepayRate 				= (CASE WHEN @GroupingOption = 0 THEN [dblPrepayRate] ELSE NULL END) 
		,@Inventory						= (CASE WHEN @GroupingOption = 0 THEN [ysnInventory] ELSE NULL END)
		,@ItemDocumentNumber			= (CASE WHEN @GroupingOption = 0 THEN ISNULL(ISNULL([strDocumentNumber], @SourceNumber),[strSourceId]) ELSE NULL END)
		,@ItemDescription				= (CASE WHEN @GroupingOption = 0 THEN [strItemDescription] ELSE NULL END)
		,@OrderUOMId					= (CASE WHEN @GroupingOption = 0 THEN [intOrderUOMId] ELSE NULL END)
		,@ItemQtyOrdered				= (CASE WHEN @GroupingOption = 0 THEN [dblQtyOrdered] ELSE NULL END)
		,@ItemUOMId						= (CASE WHEN @GroupingOption = 0 THEN [intItemUOMId] ELSE NULL END)
		,@ItemQtyShipped				= (CASE WHEN @GroupingOption = 0 THEN [dblQtyShipped] ELSE NULL END)
		,@ItemDiscount					= (CASE WHEN @GroupingOption = 0 THEN [dblDiscount] ELSE NULL END)
		,@ItemTermDiscount				= (CASE WHEN @GroupingOption = 0 THEN [dblItemTermDiscount] ELSE NULL END)
		,@ItemTermDiscountBy			= (CASE WHEN @GroupingOption = 0 THEN [strItemTermDiscountBy] ELSE NULL END)
		,@ItemPrice						= (CASE WHEN @GroupingOption = 0 THEN [dblPrice] ELSE NULL END)
		,@ItemPricing					= (CASE WHEN @GroupingOption = 0 THEN [strPricing] ELSE NULL END)
		,@ItemVFDDocumentNumber			= (CASE WHEN @GroupingOption = 0 THEN [strVFDDocumentNumber] ELSE NULL END)
		,@RefreshPrice					= (CASE WHEN @GroupingOption = 0 THEN [ysnRefreshPrice] ELSE 0 END)
		,@ItemMaintenanceType			= (CASE WHEN @GroupingOption = 0 THEN [strMaintenanceType] ELSE NULL END)
		,@ItemFrequency					= (CASE WHEN @GroupingOption = 0 THEN [strFrequency] ELSE NULL END)
		,@ItemMaintenanceDate			= (CASE WHEN @GroupingOption = 0 THEN [dtmMaintenanceDate] ELSE NULL END)
		,@ItemMaintenanceAmount			= (CASE WHEN @GroupingOption = 0 THEN [dblMaintenanceAmount] ELSE NULL END)
		,@ItemLicenseAmount				= (CASE WHEN @GroupingOption = 0 THEN [dblLicenseAmount] ELSE NULL END)
		,@ItemTaxGroupId				= (CASE WHEN @GroupingOption = 0 THEN [intTaxGroupId] ELSE NULL END)
		,@ItemStorageLocationId			= (CASE WHEN @GroupingOption = 0 THEN [intStorageLocationId] ELSE NULL END)
		,@ItemCompanyLocationSubLocationId	= (CASE WHEN @GroupingOption = 0 THEN [intCompanyLocationSubLocationId] ELSE NULL END)
		,@RecomputeTax					= (CASE WHEN @GroupingOption = 0 THEN [ysnRecomputeTax] ELSE 0 END)
		,@ItemSCInvoiceId				= (CASE WHEN @GroupingOption = 0 THEN [intSCInvoiceId] ELSE NULL END)
		,@ItemSCInvoiceNumber			= (CASE WHEN @GroupingOption = 0 THEN [strSCInvoiceNumber] ELSE NULL END)
		,@ItemInventoryShipmentItemId	= (CASE WHEN @GroupingOption = 0 THEN [intInventoryShipmentItemId] ELSE NULL END)
		,@ItemInventoryShipmentChargeId	= (CASE WHEN @GroupingOption = 0 THEN [intInventoryShipmentChargeId] ELSE NULL END)
		,@ItemShipmentNumber			= (CASE WHEN @GroupingOption = 0 THEN [strShipmentNumber] ELSE NULL END)
		,@ItemRecipeItemId				= (CASE WHEN @GroupingOption = 0 THEN [intRecipeItemId] ELSE NULL END)
		,@ItemRecipeId					= (CASE WHEN @GroupingOption = 0 THEN [intRecipeId] ELSE NULL END)
		,@ItemSublocationId				= (CASE WHEN @GroupingOption = 0 THEN [intSubLocationId] ELSE NULL END)
		,@ItemCostTypeId				= (CASE WHEN @GroupingOption = 0 THEN [intCostTypeId] ELSE NULL END)
		,@ItemMarginById				= (CASE WHEN @GroupingOption = 0 THEN [intMarginById] ELSE NULL END)
		,@ItemCommentTypeId				= (CASE WHEN @GroupingOption = 0 THEN [intCommentTypeId] ELSE NULL END)
		,@ItemMargin					= (CASE WHEN @GroupingOption = 0 THEN [dblMargin] ELSE NULL END)
		,@ItemRecipeQty					= (CASE WHEN @GroupingOption = 0 THEN [dblRecipeQuantity] ELSE NULL END)
		,@ItemSalesOrderDetailId		= (CASE WHEN @GroupingOption = 0 THEN [intSalesOrderDetailId] ELSE NULL END)
		,@ItemSalesOrderNumber			= (CASE WHEN @GroupingOption = 0 THEN [strSalesOrderNumber] ELSE NULL END)		
		,@ItemContractDetailId			= (CASE WHEN @GroupingOption = 0 THEN [intContractDetailId] ELSE NULL END)
		,@ItemShipmentPurchaseSalesContractId = (CASE WHEN @GroupingOption = 0 THEN [intShipmentPurchaseSalesContractId] ELSE NULL END)
		,@ItemWeightUOMId				= (CASE WHEN @GroupingOption = 0 THEN [intItemWeightUOMId] ELSE NULL END)
		,@ItemWeight					= (CASE WHEN @GroupingOption = 0 THEN [dblItemWeight] ELSE NULL END)
		,@ItemShipmentGrossWt			= (CASE WHEN @GroupingOption = 0 THEN [dblShipmentGrossWt] ELSE NULL END)
		,@ItemShipmentTareWt			= (CASE WHEN @GroupingOption = 0 THEN [dblShipmentTareWt] ELSE NULL END)
		,@ItemShipmentNetWt				= (CASE WHEN @GroupingOption = 0 THEN [dblShipmentNetWt] ELSE NULL END)
		,@ItemTicketId					= (CASE WHEN @GroupingOption = 0 THEN [intTicketId] ELSE NULL END)
		,@ItemTicketHoursWorkedId		= (CASE WHEN @GroupingOption = 0 THEN [intTicketHoursWorkedId] ELSE NULL END)
		,@ItemCustomerStorageId			= (CASE WHEN @GroupingOption = 0 THEN [intCustomerStorageId] ELSE NULL END)
		,@ItemSiteDetailId				= (CASE WHEN @GroupingOption = 0 THEN [intSiteDetailId] ELSE NULL END)
		,@ItemLoadDetailId				= (CASE WHEN @GroupingOption = 0 THEN [intLoadDetailId] ELSE NULL END)
		,@ItemOriginalInvoiceDetailId	= (CASE WHEN @GroupingOption = 0 THEN [intOriginalInvoiceDetailId] ELSE NULL END)
		,@ItemSiteId					= (CASE WHEN @GroupingOption = 0 THEN [intSiteId] ELSE NULL END)
		,@ItemBillingBy					= (CASE WHEN @GroupingOption = 0 THEN [strBillingBy] ELSE NULL END)
		,@ItemPercentFull				= (CASE WHEN @GroupingOption = 0 THEN [dblPercentFull] ELSE NULL END)
		,@ItemNewMeterReading			= (CASE WHEN @GroupingOption = 0 THEN [dblNewMeterReading] ELSE NULL END)
		,@ItemPreviousMeterReading		= (CASE WHEN @GroupingOption = 0 THEN [dblPreviousMeterReading] ELSE NULL END)
		,@ItemConversionFactor			= (CASE WHEN @GroupingOption = 0 THEN [dblConversionFactor] ELSE NULL END)
		,@ItemPerformerId				= (CASE WHEN @GroupingOption = 0 THEN [intPerformerId] ELSE NULL END)
		,@ItemLeaseBilling				= (CASE WHEN @GroupingOption = 0 THEN [ysnLeaseBilling] ELSE NULL END)
		,@ItemVirtualMeterReading		= (CASE WHEN @GroupingOption = 0 THEN [ysnVirtualMeterReading] ELSE NULL END)
		,@ItemCurrencyExchangeRateTypeId	= (CASE WHEN @GroupingOption = 0 THEN [intCurrencyExchangeRateTypeId] ELSE NULL END)
		,@ItemCurrencyExchangeRateId	= (CASE WHEN @GroupingOption = 0 THEN [intCurrencyExchangeRateId] ELSE NULL END)
		,@ItemCurrencyExchangeRate		= (CASE WHEN @GroupingOption = 0 THEN [dblCurrencyExchangeRate] ELSE 1 END)
		,@ItemSubCurrencyId				= (CASE WHEN @GroupingOption = 0 THEN [intSubCurrencyId] ELSE NULL END)
		,@ItemSubCurrencyRate			= (CASE WHEN @GroupingOption = 0 THEN [dblSubCurrencyRate] ELSE 1 END)
		,@ItemIsBlended					= (CASE WHEN @GroupingOption = 0 THEN [ysnBlended] ELSE 0 END)
		,@ItemConversionAccountId		= (CASE WHEN @GroupingOption = 0 THEN [intConversionAccountId] ELSE NULL END)
		,@ItemSalesAccountId			= (CASE WHEN @GroupingOption = 0 THEN [intSalesAccountId] ELSE NULL END)
		,@ItemStorageScheduleTypeId		= (CASE WHEN @GroupingOption = 0 THEN [intStorageScheduleTypeId] ELSE NULL END)
		,@ItemDestinationGradeId		= (CASE WHEN @GroupingOption = 0 THEN [intDestinationGradeId] ELSE NULL END)
		,@ItemDestinationWeightId		= (CASE WHEN @GroupingOption = 0 THEN [intDestinationWeightId] ELSE NULL END)
	FROM
		@InvoiceEntries
	WHERE
			([intId] = @Id OR @GroupingOption > 0)
		AND ([intEntityCustomerId] = @EntityCustomerId OR (@EntityCustomerId IS NULL AND @GroupingOption < 1))
		AND ([intSourceId] = @SourceId OR (@SourceId IS NULL AND (@GroupingOption < 2 OR [strSourceTransaction] IN ('Sale OffSite','Settle Storage','Process Grain Storage','Transfer Storage','Load/Shipment Schedules','Credit Card Reconciliation', 'CF Invoice'))))
		AND ([intCompanyLocationId] = @CompanyLocationId OR (@CompanyLocationId IS NULL AND @GroupingOption < 3))
		AND (ISNULL([intCurrencyId],0) = ISNULL(@CurrencyId,0) OR (@CurrencyId IS NULL AND @GroupingOption < 4))
		AND (CAST([dtmDate] AS DATE) = @Date OR (@Date IS NULL AND @GroupingOption < 5))
		AND (ISNULL([intTermId],0) = ISNULL(@TermId,0) OR (@TermId IS NULL AND @GroupingOption < 6))		
		AND (ISNULL([intShipViaId],0) = ISNULL(@ShipViaId,0) OR (@ShipViaId IS NULL AND @GroupingOption < 7))
		AND (ISNULL([intEntitySalespersonId],0) = ISNULL(@EntitySalespersonId,0) OR (@EntitySalespersonId IS NULL AND @GroupingOption < 8))
		AND (ISNULL([strPONumber],'') = ISNULL(@PONumber,'') OR (@PONumber IS NULL AND @GroupingOption < 9))			
		AND (ISNULL([strBOLNumber],'') = ISNULL(@BOLNumber,'') OR (@BOLNumber IS NULL AND @GroupingOption < 10))
		AND (ISNULL([strComments],'') = ISNULL(@Comment,'') OR (@Comment IS NULL AND @GroupingOption < 11))
	ORDER BY
		[intId]


	BEGIN TRY
		IF ISNULL(@SourceTransaction, '') <> 'Import'
			BEGIN
				IF ISNULL(@SourceTransaction,'') = 'Transport Load'
					BEGIN
						SET @SourceColumn = 'intLoadDistributionHeaderId'
						SET @SourceTable = 'tblTRLoadDistributionHeader'
					END
				IF ISNULL(@SourceTransaction,'') = 'Inbound Shipment'
					BEGIN
						SET @SourceColumn = 'intShipmentId'
						SET @SourceTable = 'tblLGShipment'
					END
				IF ISNULL(@SourceTransaction,'') = 'Card Fueling Transaction' OR ISNULL(@SourceTransaction,'') = 'CF Tran'
					BEGIN
						SET @SourceColumn = 'intTransactionId'
						SET @SourceTable = 'tblCFTransaction'
					END
				IF ISNULL(@SourceTransaction, '') = 'Meter Billing'
					BEGIN
						SET @SourceColumn = 'intMeterReadingId'
						SET @SourceTable = 'tblMBMeterReading' 
					END
				IF ISNULL(@SourceTransaction,'') = 'Provisional Invoice'
					BEGIN
						SET @SourceColumn = 'intInvoiceId'
						SET @SourceTable = 'tblARInvoice'
					END					
				IF ISNULL(@SourceTransaction,'') = 'Inventory Shipment'
					BEGIN
						SET @SourceColumn = 'intInventoryShipmentId'
						SET @SourceTable = 'tblICInventoryShipment'
					END		

				IF ISNULL(@SourceTransaction,'') = 'Sales Contract'
					BEGIN
						SET @SourceColumn = 'intContractHeaderId'
						SET @SourceTable = 'tblCTContractHeader'
					END

				IF ISNULL(@SourceTransaction,'') = 'Load Schedule'
					BEGIN
						SET @SourceColumn = 'intLoadId'
						SET @SourceTable = 'tblLGLoad'
					END

				IF ISNULL(@SourceTransaction,'') IN ('Transport Load', 'Inbound Shipment', 'Card Fueling Transaction', 'CF Tran', 'Meter Billing', 'Provisional Invoice', 'Inventory Shipment', 'Sales Contract', 'Load Schedule')
					BEGIN
						EXECUTE('IF NOT EXISTS(SELECT NULL FROM ' + @SourceTable + ' WHERE ' + @SourceColumn + ' = ' + @SourceId + ') RAISERROR(''' + @SourceTransaction + ' does not exists!'', 16, 1);');
					END
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
		
	DECLARE @NewInvoiceId INT

	IF ISNULL(@TransactionType, '') = ''
		SET @TransactionType = 'Invoice'

	IF ISNULL(@Type, '') = ''
		SET @Type = 'Standard'
	
	IF ISNULL(@LoadDistributionHeaderId, 0) > 0
		BEGIN
			SET @Type = 'Transport Delivery'
		END

	SET @NewSourceId = dbo.[fnARValidateInvoiceSourceId](@SourceTransaction, @SourceId)

	BEGIN TRY		
		EXEC [dbo].[uspARCreateCustomerInvoice]
			 @EntityCustomerId				= @EntityCustomerId
			,@CompanyLocationId				= @CompanyLocationId
			,@AccountId						= @AccountId
			,@CurrencyId					= @CurrencyId
			,@TermId						= @TermId
			,@EntityId						= @EntityId			
			,@InvoiceDate					= @Date
			,@DueDate						= @DueDate
			,@ShipDate						= @ShipDate
			,@PostDate						= @PostDate
			,@TransactionType				= @TransactionType
			,@Type							= @Type
			,@NewInvoiceId					= @NewInvoiceId			OUTPUT 
			,@ErrorMessage					= @CurrentErrorMessage	OUTPUT
			,@RaiseError					= @RaiseError
			,@EntitySalespersonId			= @EntitySalespersonId
			,@FreightTermId					= @FreightTermId
			,@ShipViaId						= @ShipViaId
			,@PaymentMethodId				= @PaymentMethodId
			,@InvoiceOriginId				= @InvoiceOriginId
			,@UseOriginIdAsInvoiceNumber	= @UseOriginIdAsInvoiceNumber
			,@PONumber						= @PONumber
			,@BOLNumber						= @BOLNumber
			,@DeliverPickUp					= @DeliverPickup
			,@Comment						= @Comment
			,@ShipToLocationId				= @ShipToLocationId
			,@BillToLocationId				= @BillToLocationId
			,@Template						= @Template
			,@Forgiven						= @Forgiven
			,@Calculated					= @Calculated
			,@Splitted						= @Splitted
			,@PaymentId						= @PaymentId
			,@SplitId						= @SplitId
			,@LoadDistributionHeaderId		= @LoadDistributionHeaderId
			,@ActualCostId					= @ActualCostId
			,@ShipmentId					= @ShipmentId
			,@TransactionId 				= @TransactionId
			,@MeterReadingId				= @MeterReadingId
			,@OriginalInvoiceId 			= @OriginalInvoiceId
			,@LoadId			 			= @LoadId
			,@PeriodsToAccrue				= @PeriodsToAccrue
			,@SourceId						= @NewSourceId
			,@ImportFormat					= @ImportFormat
			,@TruckDriverId					= @TruckDriverId
			,@TruckDriverReferenceId		= @TruckDriverReferenceId

			,@ItemId						= @ItemId
			,@ItemPrepayTypeId				= @ItemPrepayTypeId
			,@ItemPrepayRate				= @ItemPrepayRate
			,@ItemIsInventory				= @Inventory
			,@ItemDocumentNumber			= @ItemDocumentNumber
			,@ItemDescription				= @ItemDescription
			,@OrderUOMId					= @OrderUOMId
			,@ItemQtyOrdered				= @ItemQtyOrdered
			,@ItemUOMId						= @ItemUOMId
			,@ItemQtyShipped				= @ItemQtyShipped
			,@ItemDiscount					= @ItemDiscount
			,@ItemTermDiscount				= @ItemTermDiscount
			,@ItemTermDiscountBy			= @ItemTermDiscountBy
			,@ItemPrice						= @ItemPrice
			,@RefreshPrice					= @RefreshPrice
			,@ItemMaintenanceType			= @ItemMaintenanceType
			,@ItemFrequency					= @ItemFrequency
			,@ItemMaintenanceDate			= @ItemMaintenanceDate
			,@ItemMaintenanceAmount			= @ItemMaintenanceAmount
			,@ItemLicenseAmount				= @ItemLicenseAmount
			,@ItemTaxGroupId				= @ItemTaxGroupId
			,@ItemStorageLocationId			= @ItemStorageLocationId 
			,@ItemCompanyLocationSubLocationId	= @ItemCompanyLocationSubLocationId 
			,@RecomputeTax					= @RecomputeTax
			,@ItemSCInvoiceId				= @ItemSCInvoiceId
			,@ItemSCInvoiceNumber			= @ItemSCInvoiceNumber
			,@ItemInventoryShipmentItemId	= @ItemInventoryShipmentItemId
			,@ItemInventoryShipmentChargeId	= @ItemInventoryShipmentChargeId
			,@ItemShipmentNumber			= @ItemShipmentNumber
			,@ItemRecipeItemId				= @ItemRecipeItemId
			,@ItemRecipeId					= @ItemRecipeId
			,@ItemSublocationId				= @ItemSublocationId
			,@ItemCostTypeId				= @ItemCostTypeId
			,@ItemMarginById				= @ItemMarginById
			,@ItemCommentTypeId				= @ItemCommentTypeId
			,@ItemMargin					= @ItemMargin
			,@ItemRecipeQty					= @ItemRecipeQty			
			,@ItemSalesOrderDetailId		= @ItemSalesOrderDetailId
			,@ItemSalesOrderNumber			= @ItemSalesOrderNumber
			,@ItemContractHeaderId			= @ContractHeaderId
			,@ItemContractDetailId			= @ItemContractDetailId
			,@ItemShipmentPurchaseSalesContractId = @ItemShipmentPurchaseSalesContractId
			,@ItemWeightUOMId				= @ItemWeightUOMId
			,@ItemWeight					= @ItemWeight
			,@ItemShipmentGrossWt			= @ItemShipmentGrossWt
			,@ItemShipmentTareWt			= @ItemShipmentTareWt
			,@ItemShipmentNetWt				= @ItemShipmentNetWt		
			,@ItemTicketId					= @ItemTicketId
			,@ItemTicketHoursWorkedId		= @ItemTicketHoursWorkedId
			,@ItemCustomerStorageId			= @ItemCustomerStorageId
			,@ItemSiteDetailId				= @ItemSiteDetailId
			,@ItemLoadDetailId				= @ItemLoadDetailId
			,@ItemOriginalInvoiceDetailId	= @ItemOriginalInvoiceDetailId
			,@ItemSiteId					= @ItemSiteId
			,@ItemBillingBy					= @ItemBillingBy
			,@ItemPercentFull				= @ItemPercentFull
			,@ItemNewMeterReading			= @ItemNewMeterReading
			,@ItemPreviousMeterReading		= @ItemPreviousMeterReading
			,@ItemConversionFactor			= @ItemConversionFactor
			,@ItemPerformerId				= @ItemPerformerId
			,@ItemLeaseBilling				= @ItemLeaseBilling
			,@ItemVirtualMeterReading		= @ItemVirtualMeterReading
			,@ItemConversionAccountId		= @ItemConversionAccountId
			,@ItemSalesAccountId			= @ItemSalesAccountId
			,@ItemCurrencyExchangeRateTypeId	= @ItemCurrencyExchangeRateTypeId
			,@ItemCurrencyExchangeRateId	= @ItemCurrencyExchangeRateId
			,@ItemCurrencyExchangeRate		= @ItemCurrencyExchangeRate
			,@ItemSubCurrencyId				= @ItemSubCurrencyId
			,@ItemSubCurrencyRate			= @ItemSubCurrencyRate
			,@ItemStorageScheduleTypeId		= @ItemStorageScheduleTypeId
			,@ItemDestinationGradeId		= @ItemDestinationGradeId
			,@ItemDestinationWeightId		= @ItemDestinationWeightId
			
	
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
	
	IF ISNULL(@NewInvoiceId, 0) <> 0
		BEGIN
			DECLARE @InvoiceNumber NVARCHAR(250)
					,@SourceScreen NVARCHAR(250)
			SELECT @InvoiceNumber = strInvoiceNumber FROM tblARInvoice WHERE intInvoiceId = @NewInvoiceId
			SET	@SourceScreen = @SourceTransaction + ' to Invoice'
			EXEC dbo.uspSMAuditLog 
				 @keyValue			= @NewInvoiceId						-- Primary Key Value of the Invoice. 
				,@screenName		= 'AccountsReceivable.view.Invoice'	-- Screen Namespace
				,@entityId			= @EntityId							-- Entity Id.
				,@actionType		= 'Processed'						-- Action Type
				,@changeDescription	= @SourceScreen						-- Description
				,@fromValue			= @SourceNumber						-- Previous Value
				,@toValue			= @InvoiceNumber					-- New Value	
		END	       
	
	UPDATE
		#EntriesForProcessing
	SET
		[intInvoiceId] = @NewInvoiceId
	FROM
		@InvoiceEntries I
	WHERE 
			(I.[intId] = @Id OR @GroupingOption > 0)
		AND (I.[intEntityCustomerId] = @EntityCustomerId OR (@EntityCustomerId IS NULL AND @GroupingOption < 1))
		AND (I.[intSourceId] = @SourceId OR (@SourceId IS NULL AND (@GroupingOption < 2 OR I.[strSourceTransaction] IN ('Sale OffSite','Settle Storage','Process Grain Storage','Transfer Storage','Load/Shipment Schedules','Credit Card Reconciliation', 'CF Invoice'))))
		AND (I.[intCompanyLocationId] = @CompanyLocationId OR (@CompanyLocationId IS NULL AND @GroupingOption < 3))
		AND (ISNULL(I.[intCurrencyId],0) = ISNULL(@CurrencyId,0) OR (@CurrencyId IS NULL AND @GroupingOption < 4))
		AND (CAST(I.[dtmDate] AS DATE) = @Date OR (@Date IS NULL AND @GroupingOption < 5))
		AND (ISNULL(I.[intTermId],0) = ISNULL(@TermId,0) OR (@TermId IS NULL AND @GroupingOption < 6))		
		AND (ISNULL(I.[intShipViaId],0) = ISNULL(@ShipViaId,0) OR (@ShipViaId IS NULL AND @GroupingOption < 7))
		AND (ISNULL(I.[intEntitySalespersonId],0) = ISNULL(@EntitySalespersonId,0) OR (@EntitySalespersonId IS NULL AND @GroupingOption < 8))
		AND (ISNULL(I.[strPONumber],'') = ISNULL(@PONumber,'') OR (@PONumber IS NULL AND @GroupingOption < 9))			
		AND (ISNULL(I.[strBOLNumber],'') = ISNULL(@BOLNumber,'') OR (@BOLNumber IS NULL AND @GroupingOption < 10))
		AND (ISNULL(I.[strComments],'') = ISNULL(@Comment,'') OR (@Comment IS NULL AND @GroupingOption < 11))
		AND I.[intId] = #EntriesForProcessing.[intId]
		AND ISNULL(#EntriesForProcessing.[ysnForInsert],0) = 1
		
	IF (ISNULL(@NewInvoiceId, 0) <> 0 AND @GroupingOption > 0)
	BEGIN

		WHILE EXISTS(SELECT NULL FROM #EntriesForProcessing WHERE ISNULL([ysnForInsert],0) = 1 AND ISNULL([ysnProcessed],0) = 0 AND [intInvoiceId] = @NewInvoiceId)
		BEGIN
			DECLARE @ForDetailId INT
					,@NewDetailId INT
			SELECT TOP 1 @ForDetailId = [intId] FROM #EntriesForProcessing WHERE ISNULL([ysnForInsert],0) = 1 AND ISNULL([ysnProcessed],0) = 0 AND [intInvoiceId] = @NewInvoiceId ORDER BY [intId]
			
				SELECT TOP 1
					 @ShipmentId					= [intShipmentId]		 	
					,@ItemId						= [intItemId]
					,@ItemPrepayTypeId				= [intPrepayTypeId]
					,@ItemPrepayRate 				= [dblPrepayRate]
					,@Inventory						= [ysnInventory]
					,@ItemDocumentNumber			= ISNULL([strDocumentNumber], @SourceNumber)
					,@ItemDescription				= [strItemDescription]
					,@OrderUOMId					= [intOrderUOMId]					
					,@ItemQtyOrdered				= [dblQtyOrdered]
					,@ItemUOMId						= [intItemUOMId]
					,@ItemQtyShipped				= [dblQtyShipped]
					,@ItemDiscount					= [dblDiscount]
					,@ItemTermDiscount				= [dblItemTermDiscount]
					,@ItemTermDiscountBy			= [strItemTermDiscountBy]
					,@ItemPrice						= [dblPrice]
					,@ItemPricing					= CASE WHEN ISNULL([strPricing],'') = '' THEN 'Subsystem - ' COLLATE Latin1_General_CI_AS + strSourceTransaction COLLATE Latin1_General_CI_AS ELSE [strPricing] COLLATE Latin1_General_CI_AS END
					,@ItemVFDDocumentNumber			= [strVFDDocumentNumber]
					,@RefreshPrice					= [ysnRefreshPrice]
					,@ItemMaintenanceType			= [strMaintenanceType]
					,@ItemFrequency					= [strFrequency]
					,@ItemMaintenanceDate			= [dtmMaintenanceDate]
					,@ItemMaintenanceAmount			= [dblMaintenanceAmount]
					,@ItemLicenseAmount				= [dblLicenseAmount]
					,@ItemTaxGroupId				= [intTaxGroupId]
					,@RecomputeTax					= [ysnRecomputeTax]
					,@ItemSCInvoiceId				= [intSCInvoiceId]
					,@ItemSCInvoiceNumber			= [strSCInvoiceNumber]
					,@ItemInventoryShipmentItemId	= [intInventoryShipmentItemId]
					,@ItemInventoryShipmentChargeId	= [intInventoryShipmentChargeId]
					,@ItemShipmentNumber			= [strShipmentNumber]
					,@ItemRecipeItemId				= [intRecipeItemId]
					,@ItemRecipeId					= [intRecipeId]
					,@ItemSublocationId				= [intSubLocationId]
					,@ItemCostTypeId				= [intCostTypeId]
					,@ItemMarginById				= [intMarginById]
					,@ItemCommentTypeId				= [intCommentTypeId]
					,@ItemMargin					= [dblMargin]
					,@ItemRecipeQty					= [dblRecipeQuantity]
					,@ItemSalesOrderDetailId		= [intSalesOrderDetailId]
					,@ItemSalesOrderNumber			= [strSalesOrderNumber]
					,@ContractHeaderId				= [intContractHeaderId]
					,@ItemContractDetailId			= [intContractDetailId]
					,@ItemShipmentPurchaseSalesContractId =  [intShipmentPurchaseSalesContractId]
					,@ItemWeightUOMId				= [intItemWeightUOMId]
					,@ItemWeight					= [dblItemWeight]
					,@ItemShipmentGrossWt			= [dblShipmentGrossWt]
					,@ItemShipmentTareWt			= [dblShipmentTareWt]
					,@ItemShipmentNetWt				= [dblShipmentNetWt]
					,@ItemTicketId					= [intTicketId]
					,@ItemTicketHoursWorkedId		= [intTicketHoursWorkedId]
					,@ItemCustomerStorageId			= [intCustomerStorageId]
					,@ItemSiteDetailId				= [intSiteDetailId]
					,@ItemLoadDetailId				= [intLoadDetailId]
					,@ItemOriginalInvoiceDetailId	= [intOriginalInvoiceDetailId]
					,@ItemSiteId					= [intSiteId]
					,@ItemBillingBy					= [strBillingBy]
					,@ItemPercentFull				= [dblPercentFull]
					,@ItemNewMeterReading			= [dblNewMeterReading]
					,@ItemPreviousMeterReading		= [dblPreviousMeterReading]
					,@ItemConversionFactor			= [dblConversionFactor]
					,@ItemPerformerId				= [intPerformerId]
					,@ItemLeaseBilling				= [ysnLeaseBilling]
					,@ItemVirtualMeterReading		= [ysnVirtualMeterReading]
					,@ClearDetailTaxes				= [ysnClearDetailTaxes]
					,@TempDetailIdForTaxes			= [intTempDetailIdForTaxes]
					,@ItemConversionAccountId		= [intConversionAccountId]
					,@ItemCurrencyExchangeRateTypeId	= [intCurrencyExchangeRateTypeId]
					,@ItemCurrencyExchangeRateId	= [intCurrencyExchangeRateId]
					,@ItemCurrencyExchangeRate		= [dblCurrencyExchangeRate]
					,@ItemSubCurrencyId				= [intSubCurrencyId]
					,@ItemSubCurrencyRate			= [dblSubCurrencyRate]
					,@ItemIsBlended					= [ysnBlended]
					,@ItemStorageScheduleTypeId		= [intStorageScheduleTypeId]
					,@ItemDestinationGradeId		= [intDestinationGradeId]
					,@ItemDestinationWeightId		= [intDestinationWeightId]
					,@ItemSalesAccountId			= [intSalesAccountId]
				FROM
					@InvoiceEntries
				WHERE
					[intId] = @ForDetailId
					
				BEGIN TRY
					EXEC [dbo].[uspARAddItemToInvoice]
						 @InvoiceId						= @NewInvoiceId	
						,@ItemId						= @ItemId
						,@ItemPrepayTypeId				= @ItemPrepayTypeId
						,@ItemPrepayRate 				= @ItemPrepayRate
						,@ItemIsInventory				= @Inventory
						,@NewInvoiceDetailId			= @NewDetailId			OUTPUT 
						,@ErrorMessage					= @CurrentErrorMessage	OUTPUT
						,@RaiseError					= @RaiseError
						,@ItemDocumentNumber			= @ItemDocumentNumber
						,@ItemDescription				= @ItemDescription
						,@OrderUOMId					= @OrderUOMId
						,@ItemQtyOrdered				= @ItemQtyOrdered
						,@ItemUOMId						= @ItemUOMId
						,@ItemQtyShipped				= @ItemQtyShipped
						,@ItemDiscount					= @ItemDiscount
						,@ItemTermDiscount				= @ItemTermDiscount
						,@ItemTermDiscountBy			= @ItemTermDiscountBy
						,@ItemPrice						= @ItemPrice
						,@ItemPricing					= @ItemPricing
						,@ItemVFDDocumentNumber			= @ItemVFDDocumentNumber
						,@RefreshPrice					= @RefreshPrice
						,@ItemMaintenanceType			= @ItemMaintenanceType
						,@ItemFrequency					= @ItemFrequency
						,@ItemMaintenanceDate			= @ItemMaintenanceDate
						,@ItemMaintenanceAmount			= @ItemMaintenanceAmount
						,@ItemLicenseAmount				= @ItemLicenseAmount
						,@ItemTaxGroupId				= @ItemTaxGroupId
						,@RecomputeTax					= @RecomputeTax
						,@ItemSCInvoiceId				= @ItemSCInvoiceId
						,@ItemSCInvoiceNumber			= @ItemSCInvoiceNumber
						,@ItemInventoryShipmentItemId	= @ItemInventoryShipmentItemId
						,@ItemInventoryShipmentChargeId	= @ItemInventoryShipmentChargeId
						,@ItemShipmentNumber			= @ItemShipmentNumber
						,@ItemRecipeItemId				= @ItemRecipeItemId
						,@ItemRecipeId					= @ItemRecipeId
						,@ItemSublocationId				= @ItemSublocationId
						,@ItemCostTypeId				= @ItemCostTypeId
						,@ItemMarginById				= @ItemMarginById
						,@ItemCommentTypeId				= @ItemCommentTypeId
						,@ItemMargin					= @ItemMargin
						,@ItemRecipeQty					= @ItemRecipeQty						
						,@ItemSalesOrderDetailId		= @ItemSalesOrderDetailId
						,@ItemSalesOrderNumber			= @ItemSalesOrderNumber
						,@ItemContractHeaderId			= @ContractHeaderId
						,@ItemContractDetailId			= @ItemContractDetailId
						,@ItemShipmentId				= @ShipmentId
						,@ItemShipmentPurchaseSalesContractId	= @ItemShipmentPurchaseSalesContractId
						,@ItemWeightUOMId				= @ItemWeightUOMId
						,@ItemWeight					= @ItemWeight
						,@ItemShipmentGrossWt			= @ItemShipmentGrossWt
						,@ItemShipmentTareWt			= @ItemShipmentTareWt
						,@ItemShipmentNetWt				= @ItemShipmentNetWt
						,@ItemTicketId					= @ItemTicketId
						,@ItemOriginalInvoiceDetailId	= @ItemOriginalInvoiceDetailId
						,@ItemTicketHoursWorkedId		= @ItemTicketHoursWorkedId
						,@ItemCustomerStorageId			= @ItemCustomerStorageId
						,@ItemSiteDetailId				= @ItemSiteDetailId
						,@ItemLoadDetailId				= @ItemLoadDetailId
						,@ItemSiteId					= @ItemSiteId
						,@ItemBillingBy					= @ItemBillingBy
						,@ItemPercentFull				= @ItemPercentFull
						,@ItemNewMeterReading			= @ItemNewMeterReading
						,@ItemPreviousMeterReading		= @ItemPreviousMeterReading
						,@ItemConversionFactor			= @ItemConversionFactor
						,@ItemPerformerId				= @ItemPerformerId
						,@ItemLeaseBilling				= @ItemLeaseBilling
						,@ItemConversionAccountId		= @ItemConversionAccountId
						,@ItemCurrencyExchangeRateTypeId	= @ItemCurrencyExchangeRateTypeId
						,@ItemCurrencyExchangeRateId	= @ItemCurrencyExchangeRateId
						,@ItemCurrencyExchangeRate		= @ItemCurrencyExchangeRate
						,@ItemSubCurrencyId				= @ItemSubCurrencyId
						,@ItemSubCurrencyRate			= @ItemSubCurrencyRate
						,@ItemIsBlended					= @ItemIsBlended
						,@ItemStorageScheduleTypeId		= @ItemStorageScheduleTypeId
						,@ItemDestinationGradeId		= @ItemDestinationGradeId
						,@ItemDestinationWeightId		= @ItemDestinationWeightId
						,@ItemSalesAccountId			= @ItemSalesAccountId

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

				IF ISNULL(@NewDetailId,0) <> 0					
				BEGIN															
					UPDATE #EntriesForProcessing
					SET
						 [ysnProcessed]			= 1
						,[intInvoiceDetailId]	= @NewDetailId
					WHERE
						[intId] = @ForDetailId
				END


				IF ISNULL(@NewDetailId,0) <> 0					
				BEGIN															
					BEGIN TRY
						DELETE FROM @TaxDetails
						INSERT INTO @TaxDetails
							([intDetailId]
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
							,[strNotes])
						SELECT
							 @NewDetailId
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
						FROM
							@LineItemTaxEntries
						WHERE
							[intTempDetailIdForTaxes] = @TempDetailIdForTaxes
						
						EXEC	[dbo].[uspARProcessTaxDetailsForLineItem]
									 @TaxDetails	= @TaxDetails
									,@UserId		= @EntityId
									,@ClearExisting	= @ClearDetailTaxes
									,@RaiseError	= @RaiseError
									,@ErrorMessage	= @CurrentErrorMessage OUTPUT

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
				END
				DELETE FROM #EntriesForProcessing WHERE intId = @ForDetailId
		END		
	END

	IF ISNULL(@NewInvoiceId, 0) <> 0
		BEGIN			
			EXEC [dbo].[uspARUpdateInvoiceIntegrations] @InvoiceId = @NewInvoiceId, @ForDelete = 0, @UserId = @EntityId	
		END	
		
	UPDATE #EntriesForProcessing
	SET
		 [ysnProcessed]	= 1
		,[intInvoiceId]	= @NewInvoiceId
		,[ysnPost]		= @Post
		,[ysnRecap] 	= @Recap
	FROM
		@InvoiceEntries I
	WHERE
			(I.[intId] = @Id OR @GroupingOption > 0)
		AND (I.[intEntityCustomerId] = @EntityCustomerId OR (@EntityCustomerId IS NULL AND @GroupingOption < 1))
		AND (I.[intSourceId] = @SourceId OR (@SourceId IS NULL AND (@GroupingOption < 2 OR I.[strSourceTransaction] IN ('Sale OffSite','Settle Storage','Process Grain Storage','Transfer Storage','Load/Shipment Schedules','Credit Card Reconciliation', 'CF Invoice'))))
		AND (I.[intCompanyLocationId] = @CompanyLocationId OR (@CompanyLocationId IS NULL AND @GroupingOption < 3))
		AND (ISNULL(I.[intCurrencyId],0) = ISNULL(@CurrencyId,0) OR (@CurrencyId IS NULL AND @GroupingOption < 4))
		AND (CAST(I.[dtmDate] AS DATE) = @Date OR (@Date IS NULL AND @GroupingOption < 5))
		AND (ISNULL(I.[intTermId],0) = ISNULL(@TermId,0) OR (@TermId IS NULL AND @GroupingOption < 6))		
		AND (ISNULL(I.[intShipViaId],0) = ISNULL(@ShipViaId,0) OR (@ShipViaId IS NULL AND @GroupingOption < 7))
		AND (ISNULL(I.[intEntitySalespersonId],0) = ISNULL(@EntitySalespersonId,0) OR (@EntitySalespersonId IS NULL AND @GroupingOption < 8))
		AND (ISNULL(I.[strPONumber],'') = ISNULL(@PONumber,'') OR (@PONumber IS NULL AND @GroupingOption < 9))			
		AND (ISNULL(I.[strBOLNumber],'') = ISNULL(@BOLNumber,'') OR (@BOLNumber IS NULL AND @GroupingOption < 10))
		AND (ISNULL(I.[strComments],'') = ISNULL(@Comment,'') OR (@Comment IS NULL AND @GroupingOption < 11))
		AND I.[intId] = #EntriesForProcessing.[intId]
		AND ISNULL(#EntriesForProcessing.[ysnForInsert],0) = 1
		
END

	UPDATE
		tblARInvoice
	SET
		[ysnProcessed] = 1
	WHERE
		[intInvoiceId] IN (SELECT [intSourceId] FROM @InvoiceEntries WHERE [intId] IN (SELECT [intId] FROM #EntriesForProcessing WHERE ISNULL([ysnForInsert],0) = 1 AND [ysnProcessed] = 1))
		AND [strType] = 'Provisional Invoice'

END TRY
BEGIN CATCH
	IF ISNULL(@RaiseError,0) = 0
		ROLLBACK TRANSACTION
	SET @ErrorMessage = ERROR_MESSAGE();
	IF ISNULL(@RaiseError,0) = 1
		RAISERROR(@ErrorMessage, 16, 1);
	RETURN 0;
END CATCH

DECLARE	@successfulCount INT
		,@invalidCount INT
		,@success BIT
		,@batchIdUsed NVARCHAR(40)
		,@recapId NVARCHAR(250)

DECLARE @TempInvoiceIdTable AS TABLE ([intInvoiceId] INT)

--UnPosting posted Invoices for update
BEGIN TRY
	DECLARE @IdsForUnPosting VARCHAR(MAX)
	DELETE FROM @TempInvoiceIdTable
	INSERT INTO @TempInvoiceIdTable
	SELECT DISTINCT
		EFP.[intInvoiceId]
	FROM
		#EntriesForProcessing EFP
	INNER JOIN
		@InvoiceEntries IE
			ON EFP.[intInvoiceId] = IE.[intInvoiceId] 
	WHERE
		ISNULL(EFP.[ysnForUpdate],0) = 1
		AND ISNULL(EFP.[ysnProcessed],0) = 0
		AND ISNULL(EFP.[intInvoiceId],0) <> 0
		AND EFP.[ysnPost] IS NOT NULL AND EFP.[ysnPost] = 0
		AND ISNULL(IE.[ysnUpdateAvailableDiscount], 0) = 0

	SELECT
		@IdsForUnPosting = COALESCE(@IdsForUnPosting + ',' ,'') + CAST([intInvoiceId] AS NVARCHAR(250))
	FROM
		@TempInvoiceIdTable
	
		
	IF LEN(RTRIM(LTRIM(@IdsForUnPosting))) > 0
		EXEC [dbo].[uspARPostInvoice]
			@batchId			= NULL,
			@post				= 0,
			@recap				= 0,
			@param				= @IdsForUnPosting,
			@userId				= @UserId,
			@beginDate			= NULL,
			@endDate			= NULL,
			@beginTransaction	= NULL,
			@endTransaction		= NULL,
			@exclude			= NULL,
			@successfulCount	= @successfulCount OUTPUT,
			@invalidCount		= @invalidCount OUTPUT,
			@success			= @success OUTPUT,
			@batchIdUsed		= @batchIdUsed OUTPUT,
			@recapId			= @recapId OUTPUT,
			@transType			= N'all',
			@raiseError			= @RaiseError

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
	WHILE EXISTS(SELECT NULL FROM #EntriesForProcessing WHERE ISNULL([ysnForUpdate],0) = 1 AND ISNULL([ysnProcessed],0) = 0 AND ISNULL([intInvoiceId],0) <> 0)
	BEGIN
			
		DECLARE @ExistingInvoiceId INT		
		SELECT @ExistingInvoiceId = [intInvoiceId] FROM #EntriesForProcessing WHERE ISNULL([ysnForUpdate],0) = 1 AND ISNULL([ysnProcessed],0) = 0 AND ISNULL([intInvoiceId],0) <> 0 ORDER BY [intId]
									
		SELECT TOP 1
			 @TransactionType				= [strTransactionType]
			,@Type							= [strType]		 	
			,@SourceTransaction				= [strSourceTransaction]
			,@SourceId						= [intSourceId]
			,@PeriodsToAccrue 				= [intPeriodsToAccrue]
			,@SourceNumber					= [strSourceId]
			,@InvoiceId						= [intInvoiceId]
			,@EntityCustomerId				= [intEntityCustomerId]
			,@CompanyLocationId				= [intCompanyLocationId]
			,@AccountId						= [intAccountId] 
			,@CurrencyId					= ISNULL([intCurrencyId], [dbo].[fnARGetCustomerDefaultCurreny]([intEntityCustomerId]))
			,@TermId						= [intTermId]
			,@Date							= CAST([dtmDate] AS DATE)
			,@DueDate						= [dtmDueDate]
			,@ShipDate						= [dtmShipDate]
			,@PostDate						= [dtmPostDate]
			,@EntitySalespersonId			= [intEntitySalespersonId]
			,@FreightTermId					= [intFreightTermId]
			,@ShipViaId						= [intShipViaId]
			,@PaymentMethodId				= [intPaymentMethodId]
			,@InvoiceOriginId				= [strInvoiceOriginId]
			,@PONumber						= [strPONumber]
			,@BOLNumber						= [strBOLNumber]
			,@DeliverPickup					= [strDeliverPickup]
			,@Comment						= [strComments]
			,@ShipToLocationId				= [intShipToLocationId]
			,@BillToLocationId				= [intBillToLocationId]
			,@Template						= [ysnTemplate]
			,@Forgiven						= [ysnForgiven]
			,@Calculated					= [ysnCalculated]
			,@Splitted						= [ysnSplitted]
			,@PaymentId						= [intPaymentId]
			,@SplitId						= [intSplitId]			
			,@LoadDistributionHeaderId		= [intLoadDistributionHeaderId]
			,@ActualCostId					= [strActualCostId]
			,@ShipmentId					= [intShipmentId]
			,@TransactionId 				= [intTransactionId]
			,@MeterReadingId				= [intMeterReadingId]
			,@ContractHeaderId				= [intContractHeaderId] 
			,@LoadId						= [intLoadId] 
			,@OriginalInvoiceId				= [intOriginalInvoiceId]
			,@EntityId						= [intEntityId]
			,@TruckDriverId					= [intTruckDriverId]
			,@TruckDriverReferenceId		= [intTruckDriverReferenceId]
			,@ResetDetails					= [ysnResetDetails]
			,@Recap							= [ysnRecap] 
			,@Post							= [ysnPost]
			,@UpdateAvailableDiscount		= [ysnUpdateAvailableDiscount]
		FROM
			@InvoiceEntries
		WHERE
			ISNULL([intInvoiceId],0) = @ExistingInvoiceId
		ORDER BY
			[intId]

		BEGIN TRY
			IF ISNULL(@SourceTransaction,'') = 'Transport Load'
				BEGIN
					SET @SourceColumn = 'intLoadDistributionHeaderId'
					SET @SourceTable = 'tblTRLoadDistributionHeader'
				END
			IF ISNULL(@SourceTransaction,'') = 'Inbound Shipment'
				BEGIN
					SET @SourceColumn = 'intShipmentId'
					SET @SourceTable = 'tblLGShipment'
				END
			IF ISNULL(@SourceTransaction,'') = 'Card Fueling Transaction' OR ISNULL(@SourceTransaction,'') = 'CF Tran'
				BEGIN
					SET @SourceColumn = 'intTransactionId'
					SET @SourceTable = 'tblCFTransaction'
				END
			IF ISNULL(@SourceTransaction, '') = 'Meter Billing'
					BEGIN
						SET @SourceColumn = 'intMeterReadingId'
						SET @SourceTable = 'tblMBMeterReading' 
					END
			IF ISNULL(@SourceTransaction,'') = 'Provisional Invoice'
				BEGIN
					SET @SourceColumn = 'intInvoiceId'
					SET @SourceTable = 'tblARInvoice'
				END

			IF ISNULL(@SourceTransaction,'') = 'Inventory Shipment'
					BEGIN
						SET @SourceColumn = 'intInventoryShipmentId'
						SET @SourceTable = 'tblICInventoryShipment'
					END

			IF ISNULL(@SourceTransaction,'') = 'Sales Contract'
					BEGIN
						SET @SourceColumn = 'intContractHeaderId'
						SET @SourceTable = 'tblCTContractHeader'
					END	

			IF ISNULL(@SourceTransaction,'') = 'Load Schedule'
					BEGIN
						SET @SourceColumn = 'intLoadId'
						SET @SourceTable = 'tblLGLoad'
					END

			IF ISNULL(@SourceTransaction,'') IN ('Transport Load', 'Inbound Shipment', 'Card Fueling Transaction', 'CF Tran', 'Meter Billing', 'Provisional Invoice', 'Inventory Shipment', 'Sales Contract', 'Load Schedule')
				BEGIN
					EXECUTE('IF NOT EXISTS(SELECT NULL FROM ' + @SourceTable + ' WHERE ' + @SourceColumn + ' = ' + @SourceId + ') RAISERROR(''' + @SourceTransaction + ' does not exists!'', 16, 1);');
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

		SET @NewSourceId = dbo.[fnARValidateInvoiceSourceId](@SourceTransaction, @SourceId)
			
		UPDATE
			[tblARInvoice]
		SET 
			 [strTransactionType]		= CASE WHEN ISNULL(@TransactionType, '') NOT IN ('Invoice', 'Credit Memo', 'Debit Memo', 'Cash', 'Cash Refund', 'Overpayment', 'Customer Prepayment') THEN [tblARInvoice].[strTransactionType] ELSE @TransactionType END
			,[strType]					= CASE WHEN ISNULL(@Type, '') NOT IN ('Meter Billing', 'Standard', 'Software', 'Tank Delivery', 'Provisional Invoice', 'Service Charge', 'Transport Delivery', 'Store', 'Card Fueling') THEN [tblARInvoice].[strType] ELSE @Type END
			,[intEntityCustomerId]		= @EntityCustomerId
			,[intCompanyLocationId]		= @CompanyLocationId
			--,[intAccountId]				= @AccountId 
			,[intCurrencyId]			= @CurrencyId
			,[intTermId]				= ISNULL(@TermId, C.[intTermsId])
			,[intSourceId] 				= @NewSourceId
			,[intPeriodsToAccrue] 		= ISNULL(@PeriodsToAccrue,1)
			,[dtmDate]					= @Date
			,[dtmDueDate]				= ISNULL(@DueDate, (CAST(dbo.fnGetDueDateBasedOnTerm(@Date, ISNULL(ISNULL(@TermId, C.[intTermsId]),0)) AS DATE)))
			,[dtmShipDate]				= @ShipDate
			,[dtmPostDate]				= @PostDate
			,[dblInvoiceSubtotal]		= @ZeroDecimal
			,[dblShipping]				= @ZeroDecimal
			,[dblTax]					= @ZeroDecimal
			,[dblInvoiceTotal]			= @ZeroDecimal
			,[dblDiscount]				= @ZeroDecimal
			,[dblAmountDue]				= @ZeroDecimal
			,[dblPayment]				= @ZeroDecimal
			,[intEntitySalespersonId]	= ISNULL(@EntitySalespersonId, C.[intSalespersonId])
			,[intFreightTermId]			= @FreightTermId
			,[intShipViaId]				= ISNULL(@ShipViaId, EL.[intShipViaId])
			,[intPaymentMethodId]		= (SELECT intPaymentMethodID FROM tblSMPaymentMethod WHERE intPaymentMethodID = @PaymentMethodId)
			,[strInvoiceOriginId]		= @InvoiceOriginId
			,[strPONumber]				= @PONumber
			,[strBOLNumber]				= @BOLNumber
			,[strDeliverPickup]			= @DeliverPickup
			,[strComments]				= @Comment
			,[intShipToLocationId]		= ISNULL(@ShipToLocationId, ISNULL(SL1.[intEntityLocationId], EL.[intEntityLocationId]))
			,[strShipToLocationName]	= ISNULL(SL.[strLocationName], ISNULL(SL1.[strLocationName], EL.[strLocationName]))
			,[strShipToAddress]			= ISNULL(SL.[strAddress], ISNULL(SL1.[strAddress], EL.[strAddress]))
			,[strShipToCity]			= ISNULL(SL.[strCity], ISNULL(SL1.[strCity], EL.[strCity]))
			,[strShipToState]			= ISNULL(SL.[strState], ISNULL(SL1.[strState], EL.[strState]))
			,[strShipToZipCode]			= ISNULL(SL.[strZipCode], ISNULL(SL1.[strZipCode], EL.[strZipCode]))
			,[strShipToCountry]			= ISNULL(SL.[strCountry], ISNULL(SL1.[strCountry], EL.[strCountry]))
			,[intBillToLocationId]		= ISNULL(@BillToLocationId, ISNULL(BL1.[intEntityLocationId], EL.[intEntityLocationId]))
			,[strBillToLocationName]	= ISNULL(BL.[strLocationName], ISNULL(BL1.[strLocationName], EL.[strLocationName]))
			,[strBillToAddress]			= ISNULL(BL.[strAddress], ISNULL(BL1.[strAddress], EL.[strAddress]))
			,[strBillToCity]			= ISNULL(BL.[strCity], ISNULL(BL1.[strCity], EL.[strCity]))
			,[strBillToState]			= ISNULL(BL.[strState], ISNULL(BL1.[strState], EL.[strState]))
			,[strBillToZipCode]			= ISNULL(BL.[strZipCode], ISNULL(BL1.[strZipCode], EL.[strZipCode]))
			,[strBillToCountry]			= ISNULL(BL.[strCountry], ISNULL(BL1.[strCountry], EL.[strCountry]))
			,[ysnRecurring]				= ISNULL(@Template,0)
			,[ysnForgiven]				= ISNULL(@Forgiven,0)
			,[ysnCalculated]			= ISNULL(@Calculated,0)
			,[ysnSplitted]				= ISNULL(@Splitted,0)
			,[intPaymentId]				= @PaymentId
			,[intSplitId]				= @SplitId
			,[intLoadDistributionHeaderId]	= @LoadDistributionHeaderId
			,[strActualCostId]			= @ActualCostId
			,[intShipmentId]			= @ShipmentId
			,[intTransactionId]			= @TransactionId 
			,[intMeterReadingId]		= @MeterReadingId
			,[intContractHeaderId]		= @ContractHeaderId
			,[intLoadId]				= @LoadId
			,[intOriginalInvoiceId]		= @OriginalInvoiceId 
			,[intEntityId]				= @EntityId
			,[intTruckDriverId]			= @TruckDriverId
			,[intTruckDriverReferenceId]	= @TruckDriverReferenceId
			,[intConcurrencyId]			= [tblARInvoice].[intConcurrencyId] + 1
		FROM
			tblARCustomer C
		LEFT OUTER JOIN
						(	SELECT 
								 [intEntityLocationId]
								,[strLocationName]
								,[strAddress]
								,[intEntityId] 
								,[strCountry]
								,[strState]
								,[strCity]
								,[strZipCode]
								,[intTermsId]
								,[intShipViaId]
							FROM 
								[tblEMEntityLocation]
							WHERE
								ysnDefaultLocation = 1
						) EL
							ON C.[intEntityId] = EL.[intEntityId]
		LEFT OUTER JOIN
			[tblEMEntityLocation] SL
				ON ISNULL(@ShipToLocationId, 0) <> 0
				AND @ShipToLocationId = SL.intEntityLocationId
		LEFT OUTER JOIN
			[tblEMEntityLocation] SL1
				ON C.intShipToId = SL1.intEntityLocationId
		LEFT OUTER JOIN
			[tblEMEntityLocation] BL
				ON ISNULL(@BillToLocationId, 0) <> 0
				AND @BillToLocationId = BL.intEntityLocationId		
		LEFT OUTER JOIN
			[tblEMEntityLocation] BL1
				ON C.intShipToId = BL1.intEntityLocationId		
		WHERE
			[tblARInvoice].[intInvoiceId] = @ExistingInvoiceId
			AND C.[intEntityId] = @EntityCustomerId
			AND ISNULL(@UpdateAvailableDiscount, 0) = 0


		IF ISNULL(@ExistingInvoiceId, 0) <> 0
			BEGIN			
				EXEC [dbo].[uspARInsertTransactionDetail] @InvoiceId = @ExistingInvoiceId
			END	
			

		DECLARE @ForExistingDetailId INT
				,@NewExistingDetailId INT			
		--RESET Invoice Details						
		IF (ISNULL(@ExistingInvoiceId, 0) <> 0 AND ISNULL(@ResetDetails,0) = 1)
		BEGIN
			DELETE FROM tblARInvoiceDetailTax 
			WHERE [intInvoiceDetailId] IN (SELECT [intInvoiceDetailId] FROM tblARInvoiceDetail  WHERE [intInvoiceId] = @ExistingInvoiceId)
			
			DELETE FROM tblARInvoiceDetail
			WHERE [intInvoiceId]  = @ExistingInvoiceId
			
			WHILE EXISTS(SELECT NULL FROM #EntriesForProcessing WHERE ISNULL([ysnForUpdate],0) = 1 AND ISNULL([ysnProcessed],0) = 0 AND [intInvoiceId] = @ExistingInvoiceId)
			BEGIN
				SELECT TOP 1 @ForExistingDetailId = [intId] FROM #EntriesForProcessing WHERE ISNULL([ysnForUpdate],0) = 1 AND ISNULL([ysnProcessed],0) = 0 AND [intInvoiceId] = @ExistingInvoiceId ORDER BY [intId]
				
					SELECT TOP 1
						 @ShipmentId					= [intShipmentId]		 	
						,@ItemId						= [intItemId]
						,@ItemPrepayTypeId				= [intPrepayTypeId]
						,@ItemPrepayRate				= [dblPrepayRate]
						,@Inventory						= [ysnInventory]
						,@ItemDocumentNumber			= ISNULL([strDocumentNumber], @SourceNumber)
						,@ItemDescription				= [strItemDescription]
						,@OrderUOMId					= [intOrderUOMId]
						,@ItemQtyOrdered				= [dblQtyOrdered]
						,@ItemUOMId						= [intItemUOMId]
						,@ItemQtyShipped				= [dblQtyShipped]
						,@ItemDiscount					= [dblDiscount]
						,@ItemPrice						= [dblPrice]
						,@ItemPricing					= [strPricing] 
						,@ItemVFDDocumentNumber			= [strVFDDocumentNumber]
						,@RefreshPrice					= [ysnRefreshPrice]
						,@ItemMaintenanceType			= [strMaintenanceType]
						,@ItemFrequency					= [strFrequency]
						,@ItemMaintenanceDate			= [dtmMaintenanceDate]
						,@ItemMaintenanceAmount			= [dblMaintenanceAmount]
						,@ItemLicenseAmount				= [dblLicenseAmount]
						,@ItemTaxGroupId				= [intTaxGroupId]
						,@RecomputeTax					= [ysnRecomputeTax]
						,@ItemSCInvoiceId				= [intSCInvoiceId]
						,@ItemSCInvoiceNumber			= [strSCInvoiceNumber]
						,@ItemInventoryShipmentItemId	= [intInventoryShipmentItemId]
						,@ItemInventoryShipmentChargeId	= [intInventoryShipmentChargeId]
						,@ItemShipmentNumber			= [strShipmentNumber]						
						,@ItemRecipeItemId				= [intRecipeItemId]
						,@ItemRecipeId					= [intRecipeId]
						,@ItemSublocationId				= [intSubLocationId]
						,@ItemCostTypeId				= [intCostTypeId]
						,@ItemMarginById				= [intMarginById]
						,@ItemCommentTypeId				= [intCommentTypeId]
						,@ItemMargin					= [dblMargin]
						,@ItemRecipeQty					= [dblRecipeQuantity]
						,@ItemSalesOrderDetailId		= [intSalesOrderDetailId]
						,@ItemSalesOrderNumber			= [strSalesOrderNumber]
						,@ContractHeaderId				= [intContractHeaderId]
						,@ItemContractDetailId			= [intContractDetailId]
						,@ItemShipmentPurchaseSalesContractId =  [intShipmentPurchaseSalesContractId]
						,@ItemWeightUOMId				= [intItemWeightUOMId]
						,@ItemWeight					= [dblItemWeight]
						,@ItemShipmentGrossWt			= [dblShipmentGrossWt]
						,@ItemShipmentTareWt			= [dblShipmentTareWt]
						,@ItemShipmentNetWt				= [dblShipmentNetWt]
						,@ItemTicketId					= [intTicketId]
						,@ItemTicketHoursWorkedId		= [intTicketHoursWorkedId]
						,@ItemCustomerStorageId			= [intCustomerStorageId]
						,@ItemSiteDetailId				= [intSiteDetailId]
						,@ItemLoadDetailId				= [intLoadDetailId]
						,@ItemOriginalInvoiceDetailId	= [intOriginalInvoiceDetailId]
						,@ItemSiteId					= [intSiteId]
						,@ItemBillingBy					= [strBillingBy]
						,@ItemPercentFull				= [dblPercentFull]
						,@ItemNewMeterReading			= [dblNewMeterReading]
						,@ItemPreviousMeterReading		= [dblPreviousMeterReading]
						,@ItemConversionFactor			= [dblConversionFactor]
						,@ItemPerformerId				= [intPerformerId]
						,@ItemLeaseBilling				= [ysnLeaseBilling]
						,@ItemVirtualMeterReading		= [ysnVirtualMeterReading]
						,@TempDetailIdForTaxes			= [intTempDetailIdForTaxes]
						,@ItemConversionAccountId		= [intConversionAccountId]
						,@ItemCurrencyExchangeRateTypeId	= [intCurrencyExchangeRateTypeId]
						,@ItemCurrencyExchangeRateId	= [intCurrencyExchangeRateId]
						,@ItemCurrencyExchangeRate		= [dblCurrencyExchangeRate]
						,@ItemSubCurrencyId				= [intSubCurrencyId]
						,@ItemSubCurrencyRate			= [dblSubCurrencyRate]
						,@ItemStorageScheduleTypeId		= [intStorageScheduleTypeId]
						,@ItemDestinationGradeId		= [intDestinationGradeId]
						,@ItemDestinationWeightId		= [intDestinationWeightId]
						,@ItemSalesAccountId			= [intSalesAccountId]
					FROM
						@InvoiceEntries
					WHERE
						[intId] = @ForExistingDetailId
						
					BEGIN TRY
						EXEC [dbo].[uspARAddItemToInvoice]
							 @InvoiceId						= @ExistingInvoiceId	
							,@ItemId						= @ItemId
							,@ItemPrepayTypeId				= @ItemPrepayTypeId
							,@ItemPrepayRate				= @ItemPrepayRate
							,@ItemIsInventory				= @Inventory
							,@NewInvoiceDetailId			= @NewExistingDetailId	OUTPUT 
							,@ErrorMessage					= @CurrentErrorMessage	OUTPUT
							,@RaiseError					= @RaiseError
							,@ItemDocumentNumber			= @ItemDocumentNumber
							,@ItemDescription				= @ItemDescription
							,@OrderUOMId					= @OrderUOMId
							,@ItemQtyOrdered				= @ItemQtyOrdered
							,@ItemUOMId						= @ItemUOMId
							,@ItemQtyShipped				= @ItemQtyShipped
							,@ItemDiscount					= @ItemDiscount
							,@ItemPrice						= @ItemPrice
							,@ItemPricing					= @ItemPricing
							,@ItemVFDDocumentNumber			= @ItemVFDDocumentNumber
							,@RefreshPrice					= @RefreshPrice
							,@ItemMaintenanceType			= @ItemMaintenanceType
							,@ItemFrequency					= @ItemFrequency
							,@ItemMaintenanceDate			= @ItemMaintenanceDate
							,@ItemMaintenanceAmount			= @ItemMaintenanceAmount
							,@ItemLicenseAmount				= @ItemLicenseAmount
							,@ItemTaxGroupId				= @ItemTaxGroupId
							,@RecomputeTax					= @RecomputeTax
							,@ItemSCInvoiceId				= @ItemSCInvoiceId
							,@ItemSCInvoiceNumber			= @ItemSCInvoiceNumber
							,@ItemInventoryShipmentItemId	= @ItemInventoryShipmentItemId
							,@ItemInventoryShipmentChargeId	= @ItemInventoryShipmentChargeId
							,@ItemShipmentNumber			= @ItemShipmentNumber
							,@ItemRecipeItemId				= @ItemRecipeItemId
							,@ItemRecipeId					= @ItemRecipeId
							,@ItemSublocationId				= @ItemSublocationId
							,@ItemCostTypeId				= @ItemCostTypeId
							,@ItemMarginById				= @ItemMarginById
							,@ItemCommentTypeId				= @ItemCommentTypeId
							,@ItemMargin					= @ItemMargin
							,@ItemRecipeQty					= @ItemRecipeQty							
							,@ItemSalesOrderDetailId		= @ItemSalesOrderDetailId
							,@ItemSalesOrderNumber			= @ItemSalesOrderNumber
							,@ItemContractHeaderId			= @ContractHeaderId
							,@ItemContractDetailId			= @ItemContractDetailId
							,@ItemShipmentId				= @ShipmentId
							,@ItemShipmentPurchaseSalesContractId	= @ItemShipmentPurchaseSalesContractId
							,@ItemTicketId					= @ItemTicketId
							,@ItemTicketHoursWorkedId		= @ItemTicketHoursWorkedId
							,@ItemCustomerStorageId			= @ItemCustomerStorageId
							,@ItemSiteDetailId				= @ItemSiteDetailId
							,@ItemLoadDetailId				= @ItemLoadDetailId
							,@ItemOriginalInvoiceDetailId	= @ItemOriginalInvoiceDetailId
							,@ItemSiteId					= @ItemSiteId
							,@ItemBillingBy					= @ItemBillingBy
							,@ItemPercentFull				= @ItemPercentFull
							,@ItemNewMeterReading			= @ItemNewMeterReading
							,@ItemPreviousMeterReading		= @ItemPreviousMeterReading
							,@ItemConversionFactor			= @ItemConversionFactor
							,@ItemPerformerId				= @ItemPerformerId
							,@ItemLeaseBilling				= @ItemLeaseBilling
							,@ItemConversionAccountId		= @ItemConversionAccountId
							,@ItemCurrencyExchangeRateTypeId	= @ItemCurrencyExchangeRateTypeId
							,@ItemCurrencyExchangeRateId	= @ItemCurrencyExchangeRateId
							,@ItemCurrencyExchangeRate		= @ItemCurrencyExchangeRate
							,@ItemSubCurrencyId				= @ItemSubCurrencyId
							,@ItemSubCurrencyRate			= @ItemSubCurrencyRate
							,@ItemWeightUOMId				= @ItemWeightUOMId
							,@ItemWeight					= @ItemWeight
							,@ItemStorageScheduleTypeId		= @ItemStorageScheduleTypeId
							,@ItemDestinationGradeId		= @ItemDestinationGradeId
							,@ItemDestinationWeightId		= @ItemDestinationWeightId
							,@ItemSalesAccountId			= @ItemSalesAccountId

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

					IF ISNULL(@NewExistingDetailId,0) <> 0					
					BEGIN
						UPDATE #EntriesForProcessing
						SET
							 [ysnProcessed]			= 1
							,[intInvoiceDetailId]	= @NewExistingDetailId
						WHERE
							[intId] = @ForExistingDetailId
					END
					
					IF ISNULL(@NewExistingDetailId,0) <> 0					
					BEGIN															
						BEGIN TRY
							DELETE FROM @TaxDetails
							INSERT INTO @TaxDetails
								([intDetailId]
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
								,[strNotes])
							SELECT
								 @NewDetailId
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
							FROM
								@LineItemTaxEntries
							WHERE
								[intTempDetailIdForTaxes] = @TempDetailIdForTaxes
						
							EXEC	[dbo].[uspARProcessTaxDetailsForLineItem]
										 @TaxDetails	= @TaxDetails
										,@UserId		= @EntityId
										,@ClearExisting	= @ClearDetailTaxes
										,@RaiseError	= @RaiseError
										,@ErrorMessage	= @CurrentErrorMessage OUTPUT

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
					END				
						
			END
			
		END

		--UPDATE Invoice Details						
		IF (ISNULL(@ExistingInvoiceId, 0) <> 0 AND ISNULL(@ResetDetails,0) = 0)
		BEGIN		
			WHILE EXISTS(SELECT NULL FROM #EntriesForProcessing WHERE ISNULL([ysnForUpdate],0) = 1 AND ISNULL([ysnProcessed],0) = 0 AND [intInvoiceId] = @ExistingInvoiceId AND ISNULL([intInvoiceDetailId],0) <> 0)
			BEGIN
				SELECT TOP 1 @ForExistingDetailId = [intId] FROM #EntriesForProcessing WHERE ISNULL([ysnForUpdate],0) = 1 AND ISNULL([ysnProcessed],0) = 0 AND [intInvoiceId] = @ExistingInvoiceId AND ISNULL([intInvoiceDetailId],0) <> 0 ORDER BY [intId]
				
				SELECT TOP 1
					 @ShipmentId					= [intShipmentId]		 	
					,@InvoiceDetailId				= [intInvoiceDetailId] 
					,@ItemId						= [intItemId]
					,@ItemPrepayTypeId				= [intPrepayTypeId]
					,@ItemPrepayRate				= [dblPrepayRate]
					,@Inventory						= [ysnInventory]
					,@ItemDocumentNumber			= ISNULL([strDocumentNumber],@SourceNumber)
					,@ItemDescription				= [strItemDescription]
					,@OrderUOMId					= [intOrderUOMId]
					,@ItemQtyOrdered				= [dblQtyOrdered]
					,@ItemUOMId						= [intItemUOMId]
					,@ItemQtyShipped				= [dblQtyShipped]
					,@ItemDiscount					= [dblDiscount]
					,@ItemPrice						= [dblPrice]
					,@ItemPricing					= [strPricing] 
					,@ItemVFDDocumentNumber			= [strVFDDocumentNumber]
					,@RefreshPrice					= [ysnRefreshPrice]
					,@ItemMaintenanceType			= [strMaintenanceType]
					,@ItemFrequency					= [strFrequency]
					,@ItemMaintenanceDate			= [dtmMaintenanceDate]
					,@ItemMaintenanceAmount			= [dblMaintenanceAmount]
					,@ItemLicenseAmount				= [dblLicenseAmount]
					,@ItemTaxGroupId				= [intTaxGroupId]
					,@RecomputeTax					= [ysnRecomputeTax]
					,@ItemSCInvoiceId				= [intSCInvoiceId]
					,@ItemSCInvoiceNumber			= [strSCInvoiceNumber]
					,@ItemInventoryShipmentItemId	= [intInventoryShipmentItemId]
					,@ItemInventoryShipmentChargeId	= [intInventoryShipmentChargeId]
					,@ItemShipmentNumber			= [strShipmentNumber]
					,@ItemRecipeItemId				= [intRecipeItemId]	
					,@ItemRecipeId					= [intRecipeId]
					,@ItemSublocationId				= [intSubLocationId]
					,@ItemCostTypeId				= [intCostTypeId]
					,@ItemMarginById				= [intMarginById]
					,@ItemCommentTypeId				= [intCommentTypeId]
					,@ItemMargin					= [dblMargin]
					,@ItemRecipeQty					= [dblRecipeQuantity]				
					,@ItemSalesOrderDetailId		= [intSalesOrderDetailId]
					,@ItemSalesOrderNumber			= [strSalesOrderNumber]
					,@ContractHeaderId				= [intContractHeaderId]
					,@ItemContractDetailId			= [intContractDetailId]
					,@ItemShipmentPurchaseSalesContractId =  [intShipmentPurchaseSalesContractId]
					,@ItemWeightUOMId				= [intItemWeightUOMId]
					,@ItemWeight					= [dblItemWeight]
					,@ItemShipmentGrossWt			= [dblShipmentGrossWt]
					,@ItemShipmentTareWt			= [dblShipmentTareWt]
					,@ItemShipmentNetWt				= [dblShipmentNetWt]
					,@ItemTicketId					= [intTicketId]
					,@ItemOriginalInvoiceDetailId	= [intOriginalInvoiceDetailId]
					,@ItemTicketHoursWorkedId		= [intTicketHoursWorkedId]
					,@ItemCustomerStorageId			= [intCustomerStorageId]
					,@ItemSiteDetailId				= [intSiteDetailId]
					,@ItemLoadDetailId				= [intLoadDetailId]
					,@ItemSiteId					= [intSiteId]
					,@ItemBillingBy					= [strBillingBy]
					,@ItemPercentFull				= [dblPercentFull]
					,@ItemNewMeterReading			= [dblNewMeterReading]
					,@ItemPreviousMeterReading		= [dblPreviousMeterReading]
					,@ItemConversionFactor			= [dblConversionFactor]
					,@ItemPerformerId				= [intPerformerId]
					,@ItemLeaseBilling				= [ysnLeaseBilling]
					,@ItemVirtualMeterReading		= [ysnVirtualMeterReading]
					,@TempDetailIdForTaxes			= [intTempDetailIdForTaxes]
					,@ItemConversionAccountId		= [intConversionAccountId]
					,@ItemCurrencyExchangeRateTypeId	= [intCurrencyExchangeRateTypeId]
					,@ItemCurrencyExchangeRateId	= [intCurrencyExchangeRateId]
					,@ItemCurrencyExchangeRate		= [dblCurrencyExchangeRate]
					,@ItemSubCurrencyId				= [intSubCurrencyId]
					,@ItemSubCurrencyRate			= [dblSubCurrencyRate]
					,@ItemStorageScheduleTypeId		= [intStorageScheduleTypeId]
					,@ItemDestinationGradeId		= [intDestinationGradeId]
					,@ItemDestinationWeightId		= [intDestinationWeightId]
				FROM
					@InvoiceEntries
				WHERE
					[intId] = @ForExistingDetailId
					
				IF (ISNULL(@RefreshPrice,0) = 1 AND ISNULL(@UpdateAvailableDiscount, 0) = 0)
					BEGIN
						DECLARE @Pricing			NVARCHAR(250)				
								,@ContractNumber	INT
								,@ContractSeq		INT
								,@InvoiceType		NVARCHAR(200)

						BEGIN TRY
						SELECT TOP 1 @InvoiceType = strType, @TermId = intTermId FROM tblARInvoice WHERE intInvoiceId = @InvoiceId 
						EXEC dbo.[uspARGetItemPrice]  
							 @ItemId					= @ItemId
							,@CustomerId				= @EntityCustomerId
							,@LocationId				= @CompanyLocationId
							,@ItemUOMId					= @ItemUOMId
							,@TransactionDate			= @Date
							,@Quantity					= @ItemQtyShipped
							,@Price						= @ItemPrice			OUTPUT
							,@Pricing					= @Pricing				OUTPUT
							,@ContractHeaderId			= @ContractHeaderId		OUTPUT
							,@ContractDetailId			= @ItemContractDetailId	OUTPUT
							,@ContractNumber			= @ContractNumber		OUTPUT
							,@ContractSeq				= @ContractSeq			OUTPUT
							,@TermDiscount				= @ItemTermDiscount		OUTPUT
							,@TermDiscountBy			= @ItemTermDiscountBy	OUTPUT							
							,@InvoiceType				= @InvoiceType
							,@TermId					= @TermId
						END TRY
						BEGIN CATCH
							SET @ErrorMessage = ERROR_MESSAGE();
							IF ISNULL(@RaiseError,0) = 1
								RAISERROR(@ErrorMessage, 16, 1);
							RETURN 0;
						END CATCH
					END
					
				BEGIN TRY
					UPDATE
						[tblARInvoiceDetail]
					SET	
						 [intItemId]							= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemId ELSE [intItemId] END
						,[intPrepayTypeId]						= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemPrepayTypeId ELSE [intPrepayTypeId] END
						,[dblPrepayRate]						= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemPrepayRate ELSE [dblPrepayRate] END
						,[strDocumentNumber]					= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemDocumentNumber ELSE [strDocumentNumber] END
						,[strItemDescription]					= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemDescription ELSE [strItemDescription] END
						,[intOrderUOMId]						= CASE WHEN @UpdateAvailableDiscount = 0 THEN @OrderUOMId ELSE [intOrderUOMId] END
						,[dblQtyOrdered]						= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemQtyOrdered ELSE [dblQtyOrdered] END
						,[intItemUOMId]							= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemUOMId ELSE [intItemUOMId] END
						,[dblQtyShipped]						= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemQtyShipped ELSE [dblQtyShipped] END
						,[dblDiscount]							= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemDiscount ELSE [dblDiscount] END
						,[dblItemTermDiscount]					= @ItemTermDiscount
						,[strItemTermDiscountBy]				= @ItemTermDiscountBy
						,[dblPrice]								= CASE WHEN @UpdateAvailableDiscount = 0 THEN 
																		(CASE WHEN (ISNULL(@RefreshPrice,0) = 1) THEN @ItemPrice / ISNULL(@ItemSubCurrencyRate, 1) ELSE @ItemPrice END)
																	ELSE
																		[dblPrice]
																  END
						,[strPricing]							= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemPricing ELSE [strPricing] END							
						,[strVFDDocumentNumber]					= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemVFDDocumentNumber ELSE [strVFDDocumentNumber] END
						,[strMaintenanceType]					= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemMaintenanceType ELSE [strMaintenanceType] END
						,[strFrequency]							= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemFrequency ELSE [strFrequency] END					
						,[dtmMaintenanceDate]					= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemMaintenanceDate ELSE [dtmMaintenanceDate] END			
						,[dblMaintenanceAmount]					= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemMaintenanceAmount ELSE [dblMaintenanceAmount] END			
						,[dblLicenseAmount]						= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemLicenseAmount ELSE [dblLicenseAmount] END				
						,[intTaxGroupId]						= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemTaxGroupId ELSE [intTaxGroupId] END				
						,[intSCInvoiceId]						= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemSCInvoiceId ELSE [intSCInvoiceId] END					
						,[strSCInvoiceNumber]					= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemSCInvoiceNumber ELSE [strSCInvoiceNumber] END				
						,[intInventoryShipmentItemId]			= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemInventoryShipmentItemId ELSE [intInventoryShipmentItemId] END			
						,[intInventoryShipmentChargeId]			= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemInventoryShipmentChargeId ELSE [intInventoryShipmentChargeId] END			
						,[strShipmentNumber]					= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemShipmentNumber ELSE [strShipmentNumber] END	
						,[intRecipeItemId]						= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemRecipeItemId ELSE [intRecipeItemId] END
						,[intRecipeId]							= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemRecipeId ELSE [intRecipeId] END
						,[intSubLocationId]						= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemSublocationId ELSE [intSubLocationId] END
						,[intCostTypeId]						= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemCostTypeId ELSE [intCostTypeId] END
						,[intMarginById]						= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemMarginById ELSE [intMarginById] END
						,[intCommentTypeId]						= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemCommentTypeId ELSE [intCommentTypeId] END
						,[dblMargin]							= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemMargin ELSE [dblMargin] END
						,[dblRecipeQuantity]					= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemRecipeQty ELSE [dblRecipeQuantity] END									
						,[intSalesOrderDetailId]				= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemSalesOrderDetailId ELSE [intSalesOrderDetailId] END			
						,[strSalesOrderNumber]					= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemSalesOrderNumber ELSE [strSalesOrderNumber] END		
						,[intContractHeaderId]					= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ContractHeaderId ELSE [intContractHeaderId] END			
						,[intContractDetailId]					= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemContractDetailId ELSE [intContractDetailId] END			
						,[intShipmentId]						= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ShipmentId ELSE [intShipmentId] END			
						,[intShipmentPurchaseSalesContractId]	= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemShipmentPurchaseSalesContractId ELSE [intShipmentPurchaseSalesContractId] END
						,[intItemWeightUOMId]					= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemWeightUOMId ELSE [intItemWeightUOMId] END
						,[dblItemWeight]						= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemWeight ELSE [dblItemWeight] END
						,[dblShipmentGrossWt]					= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemShipmentGrossWt ELSE [dblShipmentGrossWt] END
						,[dblShipmentTareWt]					= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemShipmentTareWt ELSE [dblShipmentTareWt] END
						,[dblShipmentNetWt]						= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemShipmentNetWt ELSE [dblShipmentNetWt] END
						,[intTicketId]							= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemTicketId ELSE [intTicketId] END
						,[intTicketHoursWorkedId]				= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemTicketHoursWorkedId ELSE [intTicketHoursWorkedId] END
						,[intCustomerStorageId]					= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemCustomerStorageId ELSE [intCustomerStorageId] END
						,[intSiteDetailId]						=	CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemSiteDetailId ELSE [intSiteDetailId] END
						,[intLoadDetailId]						= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemLoadDetailId ELSE [intLoadDetailId] END
						,[intOriginalInvoiceDetailId]			= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemOriginalInvoiceDetailId ELSE [intOriginalInvoiceDetailId] END
						,[intSiteId]							= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemSiteId ELSE [intSiteId] END
						,[strBillingBy]							= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemBillingBy ELSE [strBillingBy] END
						,[dblPercentFull]						= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemPercentFull ELSE [dblPercentFull] END
						,[dblNewMeterReading]					= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemNewMeterReading ELSE [dblNewMeterReading] END
						,[dblPreviousMeterReading]				= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemPreviousMeterReading ELSE [dblPreviousMeterReading] END
						,[dblConversionFactor]					= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemConversionFactor ELSE [dblConversionFactor] END
						,[intPerformerId]						= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemPerformerId ELSE [intPerformerId] END
						,[ysnLeaseBilling]						= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemLeaseBilling ELSE [ysnLeaseBilling] END
						,[ysnVirtualMeterReading]				= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemVirtualMeterReading ELSE [ysnVirtualMeterReading] END
						,[intConversionAccountId]				= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemConversionAccountId ELSE [intConversionAccountId] END
						,@ItemCurrencyExchangeRateTypeId		= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemCurrencyExchangeRateTypeId ELSE [intCurrencyExchangeRateTypeId] END
						,@ItemCurrencyExchangeRateId			= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemCurrencyExchangeRateId ELSE [intCurrencyExchangeRateId] END
						,@ItemCurrencyExchangeRate				= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemCurrencyExchangeRate ELSE [dblCurrencyExchangeRate] END
						,@ItemSubCurrencyId						= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemSubCurrencyId ELSE [intSubCurrencyId] END
						,@ItemSubCurrencyRate					= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemSubCurrencyRate ELSE [dblSubCurrencyRate] END
						,[intConcurrencyId]						= [intConcurrencyId] + 1
						,[intStorageScheduleTypeId]				= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemStorageScheduleTypeId ELSE [intStorageScheduleTypeId] END
						,[intDestinationGradeId]				= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemDestinationGradeId ELSE [intDestinationGradeId] END
						,[intDestinationWeightId]				= CASE WHEN @UpdateAvailableDiscount = 0 THEN @ItemDestinationWeightId ELSE [intDestinationWeightId] END
					WHERE
						[intInvoiceId] = @ExistingInvoiceId
						AND [intInvoiceDetailId] = @InvoiceDetailId						
				END TRY
				BEGIN CATCH
					IF ISNULL(@RaiseError,0) = 0
						ROLLBACK TRANSACTION
					SET @ErrorMessage = ERROR_MESSAGE();
					IF ISNULL(@RaiseError,0) = 1
						RAISERROR(@ErrorMessage, 16, 1);
					RETURN 0;
				END CATCH



				BEGIN TRY
					DELETE FROM @TaxDetails
					INSERT INTO @TaxDetails
						([intDetailId]
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
						,[strNotes])
					SELECT
						 [intDetailId]
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
					FROM
						@LineItemTaxEntries
					WHERE
						[intTempDetailIdForTaxes] = @TempDetailIdForTaxes
						AND @UpdateAvailableDiscount = 0
						
					EXEC	[dbo].[uspARProcessTaxDetailsForLineItem]
									@TaxDetails	= @TaxDetails
								,@UserId		= @EntityId
								,@ClearExisting	= @ClearDetailTaxes
								,@RaiseError	= @RaiseError
								,@ErrorMessage	= @CurrentErrorMessage OUTPUT

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
		


				UPDATE #EntriesForProcessing
				SET
					 [ysnProcessed]			= 1
					,[intInvoiceDetailId]	= @NewExistingDetailId
				WHERE
					[intId] = @ForExistingDetailId
			
					
			END
			
		END
		
		IF ISNULL(@ExistingInvoiceId, 0) <> 0
			BEGIN			
				EXEC [dbo].[uspARUpdateInvoiceIntegrations] @InvoiceId = @ExistingInvoiceId, @ForDelete = 0, @UserId = @EntityId	
			END			
			
		UPDATE #EntriesForProcessing
		SET
			 [ysnProcessed]	= 1
			,[ysnPost]		= @Post
			,[ysnRecap] 	= @Recap
		WHERE		
			[intInvoiceId] = @ExistingInvoiceId
			AND ISNULL([ysnForUpdate],0) = 1
			
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

--Re-Compute
BEGIN TRY
	WHILE EXISTS(SELECT NULL FROM #EntriesForProcessing WHERE ISNULL([ysnRecomputed],0) = 0 AND ISNULL([ysnProcessed],0) = 1 AND ISNULL([intInvoiceId],0) <> 0)
	BEGIN
		SELECT TOP 1 @InvoiceId = [intInvoiceId], @Id = [intId] FROM #EntriesForProcessing WHERE ISNULL([ysnRecomputed],0) = 0 AND ISNULL([ysnProcessed],0) = 1 AND ISNULL([intInvoiceId],0) <> 0 ORDER BY [intId]
		SELECT TOP 1 @RecomputeTax = ISNULL([ysnRecomputeTax],0), @UpdateAvailableDiscount = ISNULL([ysnUpdateAvailableDiscount],0) FROM @InvoiceEntries WHERE [intId] = @Id 
		IF @RecomputeTax = 1
			EXEC [dbo].[uspARReComputeInvoiceTaxes] @InvoiceId = @InvoiceId
		ELSE
			EXEC [dbo].[uspARReComputeInvoiceAmounts] @InvoiceId = @InvoiceId, @AvailableDiscountOnly = @UpdateAvailableDiscount
						
		UPDATE #EntriesForProcessing SET [ysnRecomputed] = 1 WHERE [intInvoiceId] = @InvoiceId
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

SET @batchIdUsed = ''

		
--Posting newly added Invoices
DECLARE @IdsForPosting VARCHAR(MAX)
BEGIN TRY
	DELETE FROM @TempInvoiceIdTable
	INSERT INTO @TempInvoiceIdTable
	SELECT DISTINCT
		[intInvoiceId]
	FROM
		#EntriesForProcessing
	WHERE
		ISNULL([ysnForInsert],0) = 1
		AND ISNULL([ysnProcessed],0) = 1
		AND ISNULL([intInvoiceId],0) <> 0
		AND ISNULL([ysnPost],0) = 1
		AND ISNULL([ysnRecap],0) <> 1	
		
	SELECT 
		@IdsForPosting = COALESCE(@IdsForPosting + ',' ,'') + CAST([intInvoiceId] AS NVARCHAR(250))
	FROM
		@TempInvoiceIdTable
		
	IF LEN(RTRIM(LTRIM(@IdsForPosting))) > 0
		BEGIN		
		EXEC [dbo].[uspARPostInvoice]
			@batchId			= @BatchIdForNewPost,
			@post				= 1,
			@recap				= 0,
			@param				= @IdsForPosting,
			@userId				= @UserId,
			@beginDate			= NULL,
			@endDate			= NULL,
			@beginTransaction	= NULL,
			@endTransaction		= NULL,
			@exclude			= NULL,
			@successfulCount	= @successfulCount OUTPUT,
			@invalidCount		= @invalidCount OUTPUT,
			@success			= @success OUTPUT,
			@batchIdUsed		= @batchIdUsed OUTPUT,
			@recapId			= @recapId OUTPUT,
			@transType			= N'all',
			@raiseError			= @RaiseError

			SET @BatchIdForNewPost = @batchIdUsed
			SET @PostedNewCount = @successfulCount
		END
	
	SET @IdsForPosting = ''
	SET @batchIdUsed = ''	
	SET @successfulCount = 0


	DELETE FROM @TempInvoiceIdTable
	INSERT INTO @TempInvoiceIdTable
	SELECT DISTINCT
		[intInvoiceId]
	FROM
		#EntriesForProcessing
	WHERE
		ISNULL([ysnForInsert],0) = 1
		AND ISNULL([ysnProcessed],0) = 1
		AND ISNULL([intInvoiceId],0) <> 0
		AND ISNULL([ysnPost],0) = 1
		AND ISNULL([ysnRecap],0) = 1	

	SELECT
		@IdsForPosting = COALESCE(@IdsForPosting + ',' ,'') + CAST([intInvoiceId] AS NVARCHAR(250))
	FROM
		@TempInvoiceIdTable
		
		
	IF LEN(RTRIM(LTRIM(@IdsForPosting))) > 0
		BEGIN	
		EXEC [dbo].[uspARPostInvoice]
			@batchId			= @BatchIdForNewPostRecap,
			@post				= 1,
			@recap				= 1,
			@param				= @IdsForPosting,
			@userId				= @UserId,
			@beginDate			= NULL,
			@endDate			= NULL,
			@beginTransaction	= NULL,
			@endTransaction		= NULL,
			@exclude			= NULL,
			@successfulCount	= @successfulCount OUTPUT,
			@invalidCount		= @invalidCount OUTPUT,
			@success			= @success OUTPUT,
			@batchIdUsed		= @batchIdUsed OUTPUT,
			@recapId			= @recapId OUTPUT,
			@transType			= N'all',
			@raiseError			= @RaiseError	

			SET @BatchIdForNewPostRecap = @batchIdUsed
			SET @RecapNewCount = @successfulCount
		END
		
	SET @IdsForPosting = ''
	SET @batchIdUsed = ''	
	SET @successfulCount = 0


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
DECLARE @IdsForPostingUpdated VARCHAR(MAX)
BEGIN TRY
	DELETE FROM @TempInvoiceIdTable
	INSERT INTO @TempInvoiceIdTable
	SELECT DISTINCT
		[intInvoiceId]
	FROM
		#EntriesForProcessing
	WHERE
		ISNULL([ysnForUpdate],0) = 1
		AND ISNULL([ysnProcessed],0) = 1
		AND ISNULL([intInvoiceId],0) <> 0
		AND ISNULL([ysnPost],0) = 1
		AND ISNULL([ysnRecap],0) <> 1	

	SELECT
		@IdsForPostingUpdated = COALESCE(@IdsForPostingUpdated + ',' ,'') + CAST([intInvoiceId] AS NVARCHAR(250))
	FROM
		@TempInvoiceIdTable
	
		
		
	IF LEN(RTRIM(LTRIM(@IdsForPostingUpdated))) > 0
		BEGIN			
		EXEC [dbo].[uspARPostInvoice]
			@batchId			= @BatchIdForExistingPost,
			@post				= 1,
			@recap				= 0,
			@param				= @IdsForPostingUpdated,
			@userId				= @UserId,
			@beginDate			= NULL,
			@endDate			= NULL,
			@beginTransaction	= NULL,
			@endTransaction		= NULL,
			@exclude			= NULL,
			@successfulCount	= @successfulCount OUTPUT,
			@invalidCount		= @invalidCount OUTPUT,
			@success			= @success OUTPUT,
			@batchIdUsed		= @batchIdUsed OUTPUT,
			@recapId			= @recapId OUTPUT,
			@transType			= N'all',
			@raiseError			= @RaiseError

			SET @BatchIdForExistingPost = @batchIdUsed
			SET @PostedExistingCount  = @successfulCount
		END

	SET @IdsForPostingUpdated = ''
	SET @batchIdUsed = ''
	SET @successfulCount = 0


	DELETE FROM @TempInvoiceIdTable
	INSERT INTO @TempInvoiceIdTable
	SELECT DISTINCT
		[intInvoiceId]
	FROM
		#EntriesForProcessing
	WHERE
		ISNULL([ysnForUpdate],0) = 1
		AND ISNULL([ysnProcessed],0) = 1
		AND ISNULL([intInvoiceId],0) <> 0
		AND ISNULL([ysnPost],0) = 1
		AND ISNULL([ysnRecap],0) = 1

	SELECT
		@IdsForPostingUpdated = COALESCE(@IdsForPostingUpdated + ',' ,'') + CAST([intInvoiceId] AS NVARCHAR(250))
	FROM
		@TempInvoiceIdTable
	
		
		
	IF LEN(RTRIM(LTRIM(@IdsForPostingUpdated))) > 0
		BEGIN			
		EXEC [dbo].[uspARPostInvoice]
			@batchId			= @BatchIdForExistingRecap,
			@post				= 1,
			@recap				= 1,
			@param				= @IdsForPostingUpdated,
			@userId				= @UserId,
			@beginDate			= NULL,
			@endDate			= NULL,
			@beginTransaction	= NULL,
			@endTransaction		= NULL,
			@exclude			= NULL,
			@successfulCount	= @successfulCount OUTPUT,
			@invalidCount		= @invalidCount OUTPUT,
			@success			= @success OUTPUT,
			@batchIdUsed		= @batchIdUsed OUTPUT,
			@recapId			= @recapId OUTPUT,
			@transType			= N'all',
			@raiseError			= @RaiseError

			SET @BatchIdForExistingRecap = @batchIdUsed
			SET @RecapPostExistingCount  = @successfulCount
		END
		
	SET @IdsForPostingUpdated = ''
	SET @batchIdUsed = ''
	SET @successfulCount = 0

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
DECLARE @IdsForUnPostingUpdated VARCHAR(MAX)
BEGIN TRY
	DELETE FROM @TempInvoiceIdTable
	INSERT INTO @TempInvoiceIdTable
	SELECT DISTINCT
		[intInvoiceId]
	FROM
		#EntriesForProcessing
	WHERE
		ISNULL([ysnForUpdate],0) = 1
		AND ISNULL([ysnProcessed],0) = 1
		AND ISNULL([intInvoiceId],0) <> 0
		AND [ysnPost] IS NOT NULL
		AND [ysnPost] = 0
		AND ISNULL([ysnRecap],0) <> 1
			
	SELECT
		@IdsForUnPostingUpdated = COALESCE(@IdsForUnPostingUpdated + ',' ,'') + CAST([intInvoiceId] AS NVARCHAR(250))
	FROM
		@TempInvoiceIdTable
			
		
	IF LEN(RTRIM(LTRIM(@IdsForUnPostingUpdated))) > 0
		BEGIN			
		EXEC [dbo].[uspARPostInvoice]
			@batchId			= @BatchIdForExistingUnPost,
			@post				= 0,
			@recap				= 0,
			@param				= @IdsForUnPostingUpdated,
			@userId				= @UserId,
			@beginDate			= NULL,
			@endDate			= NULL,
			@beginTransaction	= NULL,
			@endTransaction		= NULL,
			@exclude			= NULL,
			@successfulCount	= @successfulCount OUTPUT,
			@invalidCount		= @invalidCount OUTPUT,
			@success			= @success OUTPUT,
			@batchIdUsed		= @batchIdUsed OUTPUT,
			@recapId			= @recapId OUTPUT,
			@transType			= N'all',
			@raiseError			= @RaiseError

			SET @BatchIdForExistingUnPost = @batchIdUsed
			SET @UnPostedExistingCount = @successfulCount
		END

	SET @IdsForUnPostingUpdated = ''
	SET @batchIdUsed = ''
	SET @successfulCount = 0

	DELETE FROM @TempInvoiceIdTable
	INSERT INTO @TempInvoiceIdTable
	SELECT DISTINCT
		[intInvoiceId]
	FROM
		#EntriesForProcessing
	WHERE
		ISNULL([ysnForUpdate],0) = 1
		AND ISNULL([ysnProcessed],0) = 1
		AND ISNULL([intInvoiceId],0) <> 0
		AND [ysnPost] IS NOT NULL
		AND [ysnPost] = 0
		AND ISNULL([ysnRecap],0) = 1

	SELECT
		@IdsForUnPostingUpdated = COALESCE(@IdsForUnPostingUpdated + ',' ,'') + CAST([intInvoiceId] AS NVARCHAR(250))
	FROM
		@TempInvoiceIdTable	
		
		
	IF LEN(RTRIM(LTRIM(@IdsForUnPostingUpdated))) > 0
		BEGIN			
		EXEC [dbo].[uspARPostInvoice]
			@batchId			= @BatchIdForExistingUnPostRecap,
			@post				= 0,
			@recap				= 1,
			@param				= @IdsForUnPostingUpdated,
			@userId				= @UserId,
			@beginDate			= NULL,
			@endDate			= NULL,
			@beginTransaction	= NULL,
			@endTransaction		= NULL,
			@exclude			= NULL,
			@successfulCount	= @successfulCount OUTPUT,
			@invalidCount		= @invalidCount OUTPUT,
			@success			= @success OUTPUT,
			@batchIdUsed		= @batchIdUsed OUTPUT,
			@recapId			= @recapId OUTPUT,
			@transType			= N'all',
			@raiseError			= @RaiseError

			SET @BatchIdForExistingUnPostRecap = @batchIdUsed
			SET @RecapUnPostedExistingCount = @successfulCount
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


DECLARE @CreateIds VARCHAR(MAX)
DELETE FROM @TempInvoiceIdTable
INSERT INTO @TempInvoiceIdTable
SELECT DISTINCT
	[intInvoiceId]
FROM
	#EntriesForProcessing
WHERE
	ISNULL([ysnForInsert],0) = 1
	AND ISNULL([ysnProcessed],0) = 1
	AND ISNULL([intInvoiceId],0) <> 0

SELECT
	@CreateIds = COALESCE(@CreateIds + ',' ,'') + CAST([intInvoiceId] AS NVARCHAR(250))
FROM
	@TempInvoiceIdTable

	
SET @CreatedIvoices = @CreateIds


DECLARE @UpdatedIds VARCHAR(MAX)
DELETE FROM @TempInvoiceIdTable
INSERT INTO @TempInvoiceIdTable
SELECT DISTINCT
	[intInvoiceId]
FROM
	#EntriesForProcessing
WHERE
	ISNULL([ysnForUpdate],0) = 1
	AND ISNULL([ysnProcessed],0) = 1
	AND ISNULL([intInvoiceId],0) <> 0

SELECT
	@UpdatedIds = COALESCE(@UpdatedIds + ',' ,'') + CAST([intInvoiceId] AS NVARCHAR(250))
FROM
	@TempInvoiceIdTable

	
SET @UpdatedIvoices = @UpdatedIds



IF ISNULL(@RaiseError,0) = 0
	COMMIT TRANSACTION 
	
RETURN 1;

END