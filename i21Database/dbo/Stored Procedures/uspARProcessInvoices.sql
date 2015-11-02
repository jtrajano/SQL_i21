CREATE PROCEDURE [dbo].[uspARProcessInvoices]
	 @InvoiceEntries	InvoiceIntegrationStagingTable READONLY	
	,@UserId			INT
	,@GroupingOption	INT				= 0	-- 0  = [intId] - An Invoice will be created for each record in @InvoiceEntries
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
	,@RaiseError		BIT				= 0
	,@ErrorMessage		NVARCHAR(250)	= NULL			OUTPUT
	,@CreatedIvoices	NVARCHAR(MAX)	= NULL			OUTPUT
	,@UpdatedIvoices	NVARCHAR(MAX)	= NULL			OUTPUT
AS

BEGIN

SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS OFF

DECLARE @CurrentErrorMessage NVARCHAR(250)
		,@ZeroDecimal NUMERIC(18, 6)
		
SET @ZeroDecimal = 0.000000

DECLARE @SourceColumn AS NVARCHAR (500)
		,@SourceTable AS NVARCHAR (500)	
		
IF ISNULL(@RaiseError,0) = 0
	BEGIN TRANSACTION
	

BEGIN TRY
	IF OBJECT_ID('tempdb..#TempInvoiceEntries') IS NOT NULL DROP TABLE #TempInvoiceEntries	
	SELECT * INTO #TempInvoiceEntries FROM @InvoiceEntries WHERE ISNULL([intSourceId],0) <> 0

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
					END)
					
	SET @QueryString = 'INSERT INTO #EntriesForProcessing([intId], ' + @Columns + ', [ysnForInsert]) SELECT DISTINCT MIN([intId]), ' + @Columns + ', 1 FROM #TempInvoiceEntries WHERE ISNULL([intInvoiceId],0) = 0 GROUP BY ' + @Columns
	EXECUTE(@QueryString);

	SET @QueryString = 'INSERT INTO #EntriesForProcessing([intId], [intInvoiceId], [intInvoiceDetailId], ' + @Columns + ', [ysnForUpdate]) SELECT DISTINCT [intId], [intInvoiceId], [intInvoiceDetailId], ' + @Columns + ', 1 FROM #TempInvoiceEntries WHERE ISNULL([intInvoiceId],0) <> 0 GROUP BY [intId], [intInvoiceId], [intInvoiceDetailId],' + @Columns
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


DECLARE  @Id									INT
		,@SourceTransaction						NVARCHAR(250)	
		,@SourceId								INT	
		,@SourceNumber							NVARCHAR(250)
		,@InvoiceId								INT
		,@EntityCustomerId						INT
		,@CompanyLocationId						INT
		,@CurrencyId							INT
		,@TermId								INT
		,@Date									DATETIME
		,@DueDate								DATETIME
		,@ShipDate								DATETIME
		,@EntitySalespersonId					INT
		,@FreightTermId							INT
		,@ShipViaId								INT
		,@PaymentMethodId						INT
		,@InvoiceOriginId						NVARCHAR(8)
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
		,@DistributionHeaderId					INT
		,@ActualCostId							NVARCHAR(50)
		,@ShipmentId							INT
		,@TransactionId							INT
		,@OriginalInvoiceId						INT
		,@EntityId								INT
		,@ResetDetails							BIT
		,@Post									BIT

		,@InvoiceDetailId						INT
		,@ItemId								INT
		,@Inventory								BIT
		,@ItemDocumentNumber					NVARCHAR(100)
		,@ItemDescription						NVARCHAR(250)
		,@ItemUOMId								INT
		,@ItemQtyOrdered						NUMERIC(18, 6)
		,@ItemQtyShipped						NUMERIC(18, 6)
		,@ItemDiscount							NUMERIC(18, 6)
		,@ItemPrice								NUMERIC(18, 6)
		,@RefreshPrice							BIT
		,@ItemMaintenanceType					NVARCHAR(25)
		,@ItemFrequency							NVARCHAR(25)
		,@ItemMaintenanceDate					DATETIME
		,@ItemMaintenanceAmount					NUMERIC(18, 6)
		,@ItemLicenseAmount						NUMERIC(18, 6)
		,@ItemTaxGroupId						INT
		,@RecomputeTax							BIT
		,@ItemSCInvoiceId						INT
		,@ItemSCInvoiceNumber					NVARCHAR(25)
		,@ItemInventoryShipmentItemId			INT
		,@ItemShipmentNumber					NVARCHAR(50)
		,@ItemSalesOrderDetailId				INT
		,@ItemSalesOrderNumber					NVARCHAR(25)
		,@ItemContractHeaderId					INT
		,@ItemContractDetailId					INT
		,@ItemShipmentPurchaseSalesContractId	INT
		,@ItemTicketId							INT
		,@ItemTicketHoursWorkedId				INT
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

--INSERT
BEGIN TRY
WHILE EXISTS(SELECT NULL FROM #EntriesForProcessing WHERE ISNULL([ysnForInsert],0) = 1 AND ISNULL([ysnProcessed],0) = 0)
BEGIN					
	SELECT TOP 1
		 @Id						= [intId]				
		,@EntityCustomerId			= [intEntityCustomerId]		
		,@SourceId					= [intSourceId]				
		,@CompanyLocationId			= [intCompanyLocationId]		
		,@CurrencyId				= [intCurrencyId]			
		,@Date						= [dtmDate]					
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
		 @SourceTransaction				= [strSourceTransaction]
		,@SourceId						= [intSourceId]
		,@SourceNumber					= [strSourceId]
		,@InvoiceId						= [intInvoiceId]
		,@EntityCustomerId				= [intEntityCustomerId]
		,@CompanyLocationId				= [intCompanyLocationId]
		,@CurrencyId					= [intCurrencyId]
		,@TermId						= [intTermId]
		,@Date							= [dtmDate]
		,@DueDate						= [dtmDueDate]
		,@ShipDate						= [dtmShipDate]
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
		,@DistributionHeaderId			= (CASE WHEN ISNULL([strSourceTransaction],'') = 'Transport Load' THEN ISNULL([intDistributionHeaderId], [intSourceId]) ELSE NULL END)
		,@ActualCostId					= (CASE WHEN ISNULL([strSourceTransaction],'') = 'Transport Load' THEN [strActualCostId] ELSE NULL END)
		,@ShipmentId					= (CASE WHEN ISNULL([strSourceTransaction],'') = 'Inbound Shipment' THEN ISNULL([intShipmentId], [intSourceId]) ELSE NULL END)
		,@TransactionId 				= (CASE WHEN ISNULL([strSourceTransaction],'') = 'Card Fueling Transaction' THEN ISNULL([intTransactionId], [intSourceId]) ELSE NULL END)
		,@OriginalInvoiceId				= (CASE WHEN ISNULL([strSourceTransaction],'') = 'Provisional Invoice' THEN ISNULL([intOriginalInvoiceId], [intSourceId]) ELSE NULL END)
		,@EntityId						= [intEntityId]
		,@ResetDetails					= [ysnResetDetails]
		,@Post							= [ysnPost]

		,@InvoiceDetailId				= [intInvoiceDetailId]
		,@ItemId						= (CASE WHEN @GroupingOption = 0 THEN [intItemId] ELSE NULL END) 
		,@Inventory						= (CASE WHEN @GroupingOption = 0 THEN [ysnInventory] ELSE NULL END)
		,@ItemDocumentNumber			= (CASE WHEN @GroupingOption = 0 THEN [strDocumentNumber] ELSE NULL END)
		,@ItemDescription				= (CASE WHEN @GroupingOption = 0 THEN [strItemDescription] ELSE NULL END)
		,@ItemUOMId						= (CASE WHEN @GroupingOption = 0 THEN [intItemUOMId] ELSE NULL END)
		,@ItemQtyOrdered				= (CASE WHEN @GroupingOption = 0 THEN [dblQtyOrdered] ELSE NULL END)
		,@ItemQtyShipped				= (CASE WHEN @GroupingOption = 0 THEN [dblQtyShipped] ELSE NULL END)
		,@ItemDiscount					= (CASE WHEN @GroupingOption = 0 THEN [dblDiscount] ELSE NULL END)
		,@ItemPrice						= (CASE WHEN @GroupingOption = 0 THEN [dblPrice] ELSE NULL END)
		,@RefreshPrice					= (CASE WHEN @GroupingOption = 0 THEN [ysnRefreshPrice] ELSE 0 END)
		,@ItemMaintenanceType			= (CASE WHEN @GroupingOption = 0 THEN [strMaintenanceType] ELSE NULL END)
		,@ItemFrequency					= (CASE WHEN @GroupingOption = 0 THEN [strFrequency] ELSE NULL END)
		,@ItemMaintenanceDate			= (CASE WHEN @GroupingOption = 0 THEN [dtmMaintenanceDate] ELSE NULL END)
		,@ItemMaintenanceAmount			= (CASE WHEN @GroupingOption = 0 THEN [dblMaintenanceAmount] ELSE NULL END)
		,@ItemLicenseAmount				= (CASE WHEN @GroupingOption = 0 THEN [dblLicenseAmount] ELSE NULL END)
		,@ItemTaxGroupId				= (CASE WHEN @GroupingOption = 0 THEN [intTaxGroupId] ELSE NULL END)
		,@RecomputeTax					= (CASE WHEN @GroupingOption = 0 THEN [ysnRecomputeTax] ELSE 0 END)
		,@ItemSCInvoiceId				= (CASE WHEN @GroupingOption = 0 THEN [intSCInvoiceId] ELSE NULL END)
		,@ItemSCInvoiceNumber			= (CASE WHEN @GroupingOption = 0 THEN [strSCInvoiceNumber] ELSE NULL END)
		,@ItemInventoryShipmentItemId	= (CASE WHEN @GroupingOption = 0 THEN [intInventoryShipmentItemId] ELSE NULL END)
		,@ItemShipmentNumber			= (CASE WHEN @GroupingOption = 0 THEN [strShipmentNumber] ELSE NULL END)
		,@ItemSalesOrderDetailId		= (CASE WHEN @GroupingOption = 0 THEN [intSalesOrderDetailId] ELSE NULL END)
		,@ItemSalesOrderNumber			= (CASE WHEN @GroupingOption = 0 THEN [strSalesOrderNumber] ELSE NULL END)
		,@ItemContractHeaderId			= (CASE WHEN @GroupingOption = 0 THEN [intContractHeaderId] ELSE NULL END)
		,@ItemContractDetailId			= (CASE WHEN @GroupingOption = 0 THEN [intContractDetailId] ELSE NULL END)
		,@ItemShipmentPurchaseSalesContractId = (CASE WHEN @GroupingOption = 0 THEN [intShipmentPurchaseSalesContractId] ELSE NULL END)
		,@ItemTicketId					= (CASE WHEN @GroupingOption = 0 THEN [intTicketId] ELSE NULL END)
		,@ItemTicketHoursWorkedId		= (CASE WHEN @GroupingOption = 0 THEN [intTicketHoursWorkedId] ELSE NULL END)
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
	FROM
		@InvoiceEntries
	WHERE
			([intId] = @Id OR @GroupingOption > 0)
		AND ([intEntityCustomerId] = @EntityCustomerId OR (@EntityCustomerId IS NULL AND @GroupingOption < 1))
		AND ([intSourceId] = @SourceId OR (@SourceId IS NULL AND @GroupingOption < 2))
		AND ([intCompanyLocationId] = @CompanyLocationId OR (@CompanyLocationId IS NULL AND @GroupingOption < 3))
		AND ([intCurrencyId] = @CurrencyId OR (@CurrencyId IS NULL AND @GroupingOption < 4))
		AND ([dtmDate] = @Date OR (@Date IS NULL AND @GroupingOption < 5))
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
						SET @SourceColumn = 'intDistributionHeaderId'
						SET @SourceTable = 'tblTRDistributionHeader'
					END
				IF ISNULL(@SourceTransaction,'') = 'Inbound Shipment'
					BEGIN
						SET @SourceColumn = 'intShipmentId'
						SET @SourceTable = 'tblLGShipment'
					END
				IF ISNULL(@SourceTransaction,'') = 'Card Fueling Transaction'
					BEGIN
						SET @SourceColumn = 'intTransactionId'
						SET @SourceTable = 'tblCFTransaction'
					END
				IF ISNULL(@SourceTransaction,'') = 'Provisional Invoice'
					BEGIN
						SET @SourceColumn = 'intInvoiceId'
						SET @SourceTable = 'tblARInvoice'
					END

				IF ISNULL(@SourceTransaction,'') IN ('Transport Load', 'Inbound Shipment', 'Card Fueling Transaction', 'Provisional Invoice')
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
	
	BEGIN TRY		
		EXEC [dbo].[uspARCreateCustomerInvoice]
			@EntityCustomerId				= @EntityCustomerId
			,@CompanyLocationId				= @CompanyLocationId
			,@CurrencyId					= @CurrencyId
			,@TermId						= @TermId
			,@EntityId						= @EntityId
			,@InvoiceDate					= @Date
			,@DueDate						= @DueDate
			,@ShipDate						= @ShipDate
			,@PostDate						= NULL
			,@TransactionType				= 'Invoice'
			,@Type							= 'Standard'
			,@NewInvoiceId					= @NewInvoiceId			OUTPUT 
			,@ErrorMessage					= @CurrentErrorMessage	OUTPUT
			,@RaiseError					= @RaiseError
			,@EntitySalespersonId			= @EntitySalespersonId
			,@FreightTermId					= @FreightTermId
			,@ShipViaId						= @ShipViaId
			,@PaymentMethodId				= @PaymentMethodId
			,@InvoiceOriginId				= @InvoiceOriginId
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
			,@DistributionHeaderId			= @DistributionHeaderId
			,@ActualCostId					= @ActualCostId
			,@ShipmentId					= @ShipmentId
			,@TransactionId 				= @TransactionId
			,@OriginalInvoiceId 			= @OriginalInvoiceId

			,@ItemId						= @ItemId
			,@ItemIsInventory				= @Inventory
			,@ItemDocumentNumber			= @ItemDocumentNumber
			,@ItemDescription				= @ItemDescription
			,@ItemUOMId						= @ItemUOMId
			,@ItemQtyOrdered				= @ItemQtyOrdered
			,@ItemQtyShipped				= @ItemQtyShipped
			,@ItemDiscount					= @ItemDiscount
			,@ItemPrice						= @ItemPrice
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
			,@ItemShipmentNumber			= @ItemShipmentNumber
			,@ItemSalesOrderDetailId		= @ItemSalesOrderDetailId
			,@ItemSalesOrderNumber			= @ItemSalesOrderNumber
			,@ItemContractHeaderId			= @ItemContractHeaderId
			,@ItemContractDetailId			= @ItemContractDetailId
			,@ItemShipmentPurchaseSalesContractId = @ItemShipmentPurchaseSalesContractId		
			,@ItemTicketId					= @ItemTicketId
			,@ItemTicketHoursWorkedId		= @ItemTicketHoursWorkedId
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
		AND (I.[intSourceId] = @SourceId OR (@SourceId IS NULL AND @GroupingOption < 2))
		AND (I.[intCompanyLocationId] = @CompanyLocationId OR (@CompanyLocationId IS NULL AND @GroupingOption < 3))
		AND (I.[intCurrencyId] = @CurrencyId OR (@CurrencyId IS NULL AND @GroupingOption < 4))
		AND (I.[dtmDate] = @Date OR (@Date IS NULL AND @GroupingOption < 5))
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
					 @ShipmentId					=  [intShipmentId]		 	
					,@ItemId						=  [intItemId]
					,@Inventory						=  [ysnInventory]
					,@ItemDocumentNumber			=  [strDocumentNumber]
					,@ItemDescription				=  [strItemDescription]
					,@ItemUOMId						=  [intItemUOMId]
					,@ItemQtyOrdered				=  [dblQtyOrdered]
					,@ItemQtyShipped				=  [dblQtyShipped]
					,@ItemDiscount					=  [dblDiscount]
					,@ItemPrice						=  [dblPrice]
					,@RefreshPrice					=  [ysnRefreshPrice]
					,@ItemMaintenanceType			=  [strMaintenanceType]
					,@ItemFrequency					=  [strFrequency]
					,@ItemMaintenanceDate			=  [dtmMaintenanceDate]
					,@ItemMaintenanceAmount			=  [dblMaintenanceAmount]
					,@ItemLicenseAmount				=  [dblLicenseAmount]
					,@ItemTaxGroupId				=  [intTaxGroupId]
					,@RecomputeTax					=  [ysnRecomputeTax]
					,@ItemSCInvoiceId				=  [intSCInvoiceId]
					,@ItemSCInvoiceNumber			=  [strSCInvoiceNumber]
					,@ItemInventoryShipmentItemId	=  [intInventoryShipmentItemId]
					,@ItemShipmentNumber			=  [strShipmentNumber]
					,@ItemSalesOrderDetailId		=  [intSalesOrderDetailId]
					,@ItemSalesOrderNumber			=  [strSalesOrderNumber]
					,@ItemContractHeaderId			=  [intContractHeaderId]
					,@ItemContractDetailId			=  [intContractDetailId]
					,@ItemShipmentPurchaseSalesContractId =  [intShipmentPurchaseSalesContractId]
					,@ItemTicketId					=  [intTicketId]
					,@ItemTicketHoursWorkedId		=  [intTicketHoursWorkedId]
					,@ItemOriginalInvoiceDetailId	=	[intOriginalInvoiceDetailId]
					,@ItemSiteId					=  [intSiteId]
					,@ItemBillingBy					=  [strBillingBy]
					,@ItemPercentFull				=  [dblPercentFull]
					,@ItemNewMeterReading			=  [dblNewMeterReading]
					,@ItemPreviousMeterReading		=  [dblPreviousMeterReading]
					,@ItemConversionFactor			=  [dblConversionFactor]
					,@ItemPerformerId				=  [intPerformerId]
					,@ItemLeaseBilling				=  [ysnLeaseBilling]
					,@ItemVirtualMeterReading		=  [ysnVirtualMeterReading]
				FROM
					@InvoiceEntries
				WHERE
					[intId] = @ForDetailId
					
				BEGIN TRY
					EXEC [dbo].[uspARAddItemToInvoice]
						 @InvoiceId						= @NewInvoiceId	
						,@ItemId						= @ItemId
						,@ItemIsInventory				= @Inventory
						,@NewInvoiceDetailId			= @NewDetailId			OUTPUT 
						,@ErrorMessage					= @CurrentErrorMessage	OUTPUT
						,@RaiseError					= @RaiseError
						,@ItemDocumentNumber			= @ItemDocumentNumber
						,@ItemDescription				= @ItemDescription
						,@ItemUOMId						= @ItemUOMId
						,@ItemQtyOrdered				= @ItemQtyShipped
						,@ItemQtyShipped				= @ItemQtyShipped
						,@ItemDiscount					= @ItemDiscount
						,@ItemPrice						= @ItemPrice
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
						,@ItemShipmentNumber			= @ItemShipmentNumber
						,@ItemSalesOrderDetailId		= @ItemSalesOrderDetailId
						,@ItemSalesOrderNumber			= @ItemSalesOrderNumber
						,@ItemContractHeaderId			= @ItemContractHeaderId
						,@ItemContractDetailId			= @ItemContractDetailId
						,@ItemShipmentId				= @ShipmentId
						,@ItemShipmentPurchaseSalesContractId	= @ItemShipmentPurchaseSalesContractId
						,@ItemTicketId					= @ItemTicketId
						,@ItemOriginalInvoiceDetailId	= @ItemOriginalInvoiceDetailId
						,@ItemTicketHoursWorkedId		= @ItemTicketHoursWorkedId
						,@ItemSiteId					= @ItemSiteId
						,@ItemBillingBy					= @ItemBillingBy
						,@ItemPercentFull				= @ItemPercentFull
						,@ItemNewMeterReading			= @ItemNewMeterReading
						,@ItemPreviousMeterReading		= @ItemPreviousMeterReading
						,@ItemConversionFactor			= @ItemConversionFactor
						,@ItemPerformerId				= @ItemPerformerId
						,@ItemLeaseBilling				= @ItemLeaseBilling

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
					
		END		
	END
		
	UPDATE #EntriesForProcessing
	SET
		 [ysnProcessed]	= 1
		,[intInvoiceId]	= @NewInvoiceId
		,[ysnPost]		= ISNULL(@Post,0)
	FROM
		@InvoiceEntries I
	WHERE
			(I.[intId] = @Id OR @GroupingOption > 0)
		AND (I.[intEntityCustomerId] = @EntityCustomerId OR (@EntityCustomerId IS NULL AND @GroupingOption < 1))
		AND (I.[intSourceId] = @SourceId OR (@SourceId IS NULL AND @GroupingOption < 2))
		AND (I.[intCompanyLocationId] = @CompanyLocationId OR (@CompanyLocationId IS NULL AND @GroupingOption < 3))
		AND (I.[intCurrencyId] = @CurrencyId OR (@CurrencyId IS NULL AND @GroupingOption < 4))
		AND (I.[dtmDate] = @Date OR (@Date IS NULL AND @GroupingOption < 5))
		AND (ISNULL(I.[intTermId],0) = ISNULL(@TermId,0) OR (@TermId IS NULL AND @GroupingOption < 6))		
		AND (ISNULL(I.[intShipViaId],0) = ISNULL(@ShipViaId,0) OR (@ShipViaId IS NULL AND @GroupingOption < 7))
		AND (ISNULL(I.[intEntitySalespersonId],0) = ISNULL(@EntitySalespersonId,0) OR (@EntitySalespersonId IS NULL AND @GroupingOption < 8))
		AND (ISNULL(I.[strPONumber],'') = ISNULL(@PONumber,'') OR (@PONumber IS NULL AND @GroupingOption < 9))			
		AND (ISNULL(I.[strBOLNumber],'') = ISNULL(@BOLNumber,'') OR (@BOLNumber IS NULL AND @GroupingOption < 10))
		AND (ISNULL(I.[strComments],'') = ISNULL(@Comment,'') OR (@Comment IS NULL AND @GroupingOption < 11))
		AND I.[intId] = #EntriesForProcessing.[intId]
		AND ISNULL(#EntriesForProcessing.[ysnForInsert],0) = 1
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

DECLARE	@successfulCount INT
		,@invalidCount INT
		,@success BIT
		,@batchIdUsed NVARCHAR(40)
		,@recapId NVARCHAR(250)

--UnPosting posted Invoices for update
BEGIN TRY
	DECLARE @IdsForUnPosting VARCHAR(MAX)
	SELECT DISTINCT
		@IdsForUnPosting = COALESCE(@IdsForUnPosting + ',' ,'') + CAST([intInvoiceID] AS NVARCHAR(250))
	FROM
		#EntriesForProcessing
	WHERE
		ISNULL([ysnForUpdate],0) = 1
		AND ISNULL([ysnProcessed],0) = 0
		AND ISNULL([intInvoiceID],0) <> 0
		AND [ysnPost] IS NOT NULL AND [ysnPost] = 0
		
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
			@raiseError			= 1

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
			 @SourceTransaction				= [strSourceTransaction]
			,@SourceId						= [intSourceId]
			,@SourceNumber					= [strSourceId]
			,@InvoiceId						= [intInvoiceId]
			,@EntityCustomerId				= [intEntityCustomerId]
			,@CompanyLocationId				= [intCompanyLocationId]
			,@CurrencyId					= [intCurrencyId]
			,@TermId						= [intTermId]
			,@Date							= [dtmDate]
			,@DueDate						= [dtmDueDate]
			,@ShipDate						= [dtmShipDate]
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
			,@DistributionHeaderId			= (CASE WHEN ISNULL([strSourceTransaction],'') = 'Transport Load' THEN ISNULL([intDistributionHeaderId], [intSourceId]) ELSE NULL END)
			,@ActualCostId					= (CASE WHEN ISNULL([strSourceTransaction],'') = 'Transport Load' THEN [strActualCostId] ELSE NULL END)
			,@ShipmentId					= (CASE WHEN ISNULL([strSourceTransaction],'') = 'Inbound Shipment' THEN ISNULL([intShipmentId], [intSourceId]) ELSE NULL END)
			,@TransactionId 				= (CASE WHEN ISNULL([strSourceTransaction],'') = 'Card Fueling Transaction' THEN ISNULL([intTransactionId], [intSourceId]) ELSE NULL END)
			,@OriginalInvoiceId				= (CASE WHEN ISNULL([strSourceTransaction],'') = 'Provisional Invoice' THEN ISNULL([intOriginalInvoiceId], [intSourceId]) ELSE NULL END)
			,@EntityId						= [intEntityId]
			,@ResetDetails					= [ysnResetDetails]
			,@Post							= [ysnPost]
		FROM
			@InvoiceEntries
		WHERE
			ISNULL([intInvoiceId],0) = @ExistingInvoiceId
		ORDER BY
			[intId]

		BEGIN TRY
			IF ISNULL(@SourceTransaction,'') = 'Transport Load'
				BEGIN
					SET @SourceColumn = 'intDistributionHeaderId'
					SET @SourceTable = 'tblTRDistributionHeader'
				END
			IF ISNULL(@SourceTransaction,'') = 'Inbound Shipment'
				BEGIN
					SET @SourceColumn = 'intShipmentId'
					SET @SourceTable = 'tblLGShipment'
				END
			IF ISNULL(@SourceTransaction,'') = 'Card Fueling Transaction'
				BEGIN
					SET @SourceColumn = 'intTransactionId'
					SET @SourceTable = 'tblCFTransaction'
				END

			IF ISNULL(@SourceTransaction,'') = 'Provisional Invoice'
				BEGIN
					SET @SourceColumn = 'intInvoiceId'
					SET @SourceTable = 'tblARInvoice'
				END

			IF ISNULL(@SourceTransaction,'') IN ('Transport Load', 'Inbound Shipment', 'Card Fueling Transaction', 'Provisional Invoice')
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
			
		UPDATE
			[tblARInvoice]
		SET 
			 [intEntityCustomerId]		= @EntityCustomerId
			,[intCompanyLocationId]		= @CompanyLocationId
			,[intCurrencyId]			= ISNULL(@CurrencyId, C.[intCurrencyId])	
			,[intTermId]				= ISNULL(@TermId, EL.[intTermsId])
			,[dtmDate]					= @Date
			,[dtmDueDate]				= ISNULL(@DueDate, (CAST(dbo.fnGetDueDateBasedOnTerm(@Date, ISNULL(ISNULL(@TermId, EL.[intTermsId]),0)) AS DATE)))
			,[dtmShipDate]				= @ShipDate
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
			,[intPaymentMethodId]		= @PaymentMethodId
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
			,[ysnTemplate]				= ISNULL(@Template,0)
			,[ysnForgiven]				= ISNULL(@Forgiven,0)
			,[ysnCalculated]			= ISNULL(@Calculated,0)
			,[ysnSplitted]				= ISNULL(@Splitted,0)
			,[intPaymentId]				= @PaymentId
			,[intSplitId]				= @SplitId
			,[intDistributionHeaderId]	= @DistributionHeaderId
			,[strActualCostId]			= @ActualCostId
			,[intShipmentId]			= @ShipmentId
			,[intTransactionId]			= @TransactionId 
			,[intOriginalInvoiceId]		= @OriginalInvoiceId 
			,[intEntityId]				= @EntityId
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
								tblEntityLocation
							WHERE
								ysnDefaultLocation = 1
						) EL
							ON C.[intEntityCustomerId] = EL.[intEntityId]
		LEFT OUTER JOIN
			tblEntityLocation SL
				ON ISNULL(@ShipToLocationId, 0) <> 0
				AND @ShipToLocationId = SL.intEntityLocationId
		LEFT OUTER JOIN
			tblEntityLocation SL1
				ON C.intShipToId = SL1.intEntityLocationId
		LEFT OUTER JOIN
			tblEntityLocation BL
				ON ISNULL(@BillToLocationId, 0) <> 0
				AND @BillToLocationId = BL.intEntityLocationId		
		LEFT OUTER JOIN
			tblEntityLocation BL1
				ON C.intShipToId = BL1.intEntityLocationId		
		WHERE
			[tblARInvoice].[intInvoiceId] = @ExistingInvoiceId
			AND C.[intEntityCustomerId] = @EntityCustomerId
			

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
						 @ShipmentId					=  [intShipmentId]		 	
						,@ItemId						=  [intItemId]
						,@Inventory						=  [ysnInventory]
						,@ItemDocumentNumber			=  [strDocumentNumber]
						,@ItemDescription				=  [strItemDescription]
						,@ItemUOMId						=  [intItemUOMId]
						,@ItemQtyOrdered				=  [dblQtyOrdered]
						,@ItemQtyShipped				=  [dblQtyShipped]
						,@ItemDiscount					=  [dblDiscount]
						,@ItemPrice						=  [dblPrice]
						,@RefreshPrice					=  [ysnRefreshPrice]
						,@ItemMaintenanceType			=  [strMaintenanceType]
						,@ItemFrequency					=  [strFrequency]
						,@ItemMaintenanceDate			=  [dtmMaintenanceDate]
						,@ItemMaintenanceAmount			=  [dblMaintenanceAmount]
						,@ItemLicenseAmount				=  [dblLicenseAmount]
						,@ItemTaxGroupId				=  [intTaxGroupId]
						,@RecomputeTax					=  [ysnRecomputeTax]
						,@ItemSCInvoiceId				=  [intSCInvoiceId]
						,@ItemSCInvoiceNumber			=  [strSCInvoiceNumber]
						,@ItemInventoryShipmentItemId	=  [intInventoryShipmentItemId]
						,@ItemShipmentNumber			=  [strShipmentNumber]
						,@ItemSalesOrderDetailId		=  [intSalesOrderDetailId]
						,@ItemSalesOrderNumber			=  [strSalesOrderNumber]
						,@ItemContractHeaderId			=  [intContractHeaderId]
						,@ItemContractDetailId			=  [intContractDetailId]
						,@ItemShipmentPurchaseSalesContractId =  [intShipmentPurchaseSalesContractId]
						,@ItemTicketId					=  [intTicketId]
						,@ItemTicketHoursWorkedId		=  [intTicketHoursWorkedId]
						,@ItemOriginalInvoiceDetailId	=  [intOriginalInvoiceDetailId]
						,@ItemSiteId					=  [intSiteId]
						,@ItemBillingBy					=  [strBillingBy]
						,@ItemPercentFull				=  [dblPercentFull]
						,@ItemNewMeterReading			=  [dblNewMeterReading]
						,@ItemPreviousMeterReading		=  [dblPreviousMeterReading]
						,@ItemConversionFactor			=  [dblConversionFactor]
						,@ItemPerformerId				=  [intPerformerId]
						,@ItemLeaseBilling				=  [ysnLeaseBilling]
						,@ItemVirtualMeterReading		=  [ysnVirtualMeterReading]
					FROM
						@InvoiceEntries
					WHERE
						[intId] = @ForExistingDetailId
						
					BEGIN TRY
						EXEC [dbo].[uspARAddItemToInvoice]
							 @InvoiceId						= @ExistingInvoiceId	
							,@ItemId						= @ItemId
							,@ItemIsInventory				= @Inventory
							,@NewInvoiceDetailId			= @NewExistingDetailId	OUTPUT 
							,@ErrorMessage					= @CurrentErrorMessage	OUTPUT
							,@RaiseError					= @RaiseError
							,@ItemDocumentNumber			= @ItemDocumentNumber
							,@ItemDescription				= @ItemDescription
							,@ItemUOMId						= @ItemUOMId
							,@ItemQtyOrdered				= @ItemQtyShipped
							,@ItemQtyShipped				= @ItemQtyShipped
							,@ItemDiscount					= @ItemDiscount
							,@ItemPrice						= @ItemPrice
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
							,@ItemShipmentNumber			= @ItemShipmentNumber
							,@ItemSalesOrderDetailId		= @ItemSalesOrderDetailId
							,@ItemSalesOrderNumber			= @ItemSalesOrderNumber
							,@ItemContractHeaderId			= @ItemContractHeaderId
							,@ItemContractDetailId			= @ItemContractDetailId
							,@ItemShipmentId				= @ShipmentId
							,@ItemShipmentPurchaseSalesContractId	= @ItemShipmentPurchaseSalesContractId
							,@ItemTicketId					= @ItemTicketId
							,@ItemTicketHoursWorkedId		= @ItemTicketHoursWorkedId
							,@ItemOriginalInvoiceDetailId	= @ItemOriginalInvoiceDetailId
							,@ItemSiteId					= @ItemSiteId
							,@ItemBillingBy					= @ItemBillingBy
							,@ItemPercentFull				= @ItemPercentFull
							,@ItemNewMeterReading			= @ItemNewMeterReading
							,@ItemPreviousMeterReading		= @ItemPreviousMeterReading
							,@ItemConversionFactor			= @ItemConversionFactor
							,@ItemPerformerId				= @ItemPerformerId
							,@ItemLeaseBilling				= @ItemLeaseBilling

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
					,@Inventory						= [ysnInventory]
					,@ItemDocumentNumber			= [strDocumentNumber]
					,@ItemDescription				= [strItemDescription]
					,@ItemUOMId						= [intItemUOMId]
					,@ItemQtyOrdered				= [dblQtyOrdered]
					,@ItemQtyShipped				= [dblQtyShipped]
					,@ItemDiscount					= [dblDiscount]
					,@ItemPrice						= [dblPrice]
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
					,@ItemShipmentNumber			= [strShipmentNumber]
					,@ItemSalesOrderDetailId		= [intSalesOrderDetailId]
					,@ItemSalesOrderNumber			= [strSalesOrderNumber]
					,@ItemContractHeaderId			= [intContractHeaderId]
					,@ItemContractDetailId			= [intContractDetailId]
					,@ItemShipmentPurchaseSalesContractId =  [intShipmentPurchaseSalesContractId]
					,@ItemTicketId					= [intTicketId]
					,@ItemOriginalInvoiceDetailId	= [intOriginalInvoiceDetailId]
					,@ItemTicketHoursWorkedId		= [intTicketHoursWorkedId]
					,@ItemSiteId					= [intSiteId]
					,@ItemBillingBy					= [strBillingBy]
					,@ItemPercentFull				= [dblPercentFull]
					,@ItemNewMeterReading			= [dblNewMeterReading]
					,@ItemPreviousMeterReading		= [dblPreviousMeterReading]
					,@ItemConversionFactor			= [dblConversionFactor]
					,@ItemPerformerId				= [intPerformerId]
					,@ItemLeaseBilling				= [ysnLeaseBilling]
					,@ItemVirtualMeterReading		= [ysnVirtualMeterReading]
				FROM
					@InvoiceEntries
				WHERE
					[intId] = @ForExistingDetailId
					
				IF (ISNULL(@RefreshPrice,0) = 1)
					BEGIN
						DECLARE @Pricing			NVARCHAR(250)				
								,@ContractNumber	INT
								,@ContractSeq		INT
						BEGIN TRY
						EXEC dbo.[uspARGetItemPrice]  
								 @ItemId  
								,@EntityCustomerId
								,@CompanyLocationId
								,@ItemUOMId
								,@Date
								,@ItemQtyShipped
								,@ItemPrice				OUTPUT
								,@Pricing				OUTPUT
								,@ItemContractHeaderId	OUTPUT
								,@ItemContractDetailId	OUTPUT
								,@ContractNumber		OUTPUT
								,@ContractSeq			OUTPUT
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
						 [intItemId]							= @ItemId
						,[strDocumentNumber]					= @ItemDocumentNumber
						,[strItemDescription]					= @ItemDescription
						,[intItemUOMId]							= @ItemUOMId
						,[dblQtyOrdered]						= @ItemQtyOrdered
						,[dblQtyShipped]						= @ItemQtyShipped
						,[dblDiscount]							= @ItemDiscount
						,[dblPrice]								= @ItemPrice							
						,[strMaintenanceType]					= @ItemMaintenanceType
						,[strFrequency]							= @ItemFrequency					
						,[dtmMaintenanceDate]					= @ItemMaintenanceDate			
						,[dblMaintenanceAmount]					= @ItemMaintenanceAmount			
						,[dblLicenseAmount]						= @ItemLicenseAmount				
						,[intTaxGroupId]						= @ItemTaxGroupId				
						,[intSCInvoiceId]						= @ItemSCInvoiceId					
						,[strSCInvoiceNumber]					= @ItemSCInvoiceNumber				
						,[intInventoryShipmentItemId]			= @ItemInventoryShipmentItemId			
						,[strShipmentNumber]					= @ItemShipmentNumber	
						,[intSalesOrderDetailId]				= @ItemSalesOrderDetailId			
						,[strSalesOrderNumber]					= @ItemSalesOrderNumber		
						,[intContractHeaderId]					= @ItemContractHeaderId			
						,[intContractDetailId]					= @ItemContractDetailId			
						,[intShipmentId]						= @ShipmentId			
						,[intShipmentPurchaseSalesContractId]	= @ItemShipmentPurchaseSalesContractId
						,[intTicketId]							= @ItemTicketId
						,[intTicketHoursWorkedId]				= @ItemTicketHoursWorkedId
						,[intOriginalInvoiceDetailId]			= @ItemOriginalInvoiceDetailId
						,[intSiteId]							= @ItemSiteId
						,[strBillingBy]							= @ItemBillingBy
						,[dblPercentFull]						= @ItemPercentFull
						,[dblNewMeterReading]					= @ItemNewMeterReading
						,[dblPreviousMeterReading]				= @ItemPreviousMeterReading
						,[dblConversionFactor]					= @ItemConversionFactor
						,[intPerformerId]						= @ItemPerformerId
						,[ysnLeaseBilling]						= @ItemLeaseBilling
						,[ysnVirtualMeterReading]				= @ItemVirtualMeterReading
						,[intConcurrencyId]						= [intConcurrencyId] + 1
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


				UPDATE #EntriesForProcessing
				SET
					 [ysnProcessed]			= 1
					,[intInvoiceDetailId]	= @NewExistingDetailId
				WHERE
					[intId] = @ForExistingDetailId
			
					
			END
			
		END		
			
		UPDATE #EntriesForProcessing
		SET
			 [ysnProcessed]	= 1
			,[ysnPost]		= @Post
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
		SELECT TOP 1 @RecomputeTax = ISNULL([ysnRecomputeTax],0) FROM @InvoiceEntries WHERE [intId] = @Id 
		IF @RecomputeTax = 1
			EXEC [dbo].[uspARReComputeInvoiceTaxes] @InvoiceId = @InvoiceId
		ELSE
			EXEC [dbo].[uspARReComputeInvoiceAmounts] @InvoiceId = @InvoiceId
			
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
		
--Posting newly added Invoices
BEGIN TRY
	DECLARE @IdsForPosting VARCHAR(MAX)
	SELECT DISTINCT
		@IdsForPosting = COALESCE(@IdsForPosting + ',' ,'') + CAST([intInvoiceID] AS NVARCHAR(250))
	FROM
		#EntriesForProcessing
	WHERE
		ISNULL([ysnForInsert],0) = 1
		AND ISNULL([ysnProcessed],0) = 1
		AND ISNULL([intInvoiceID],0) <> 0
		AND ISNULL([ysnPost],0) = 1		
		
	IF LEN(RTRIM(LTRIM(@IdsForPosting))) > 0		
		EXEC [dbo].[uspARPostInvoice]
			@batchId			= NULL,
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
			@raiseError			= 1

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
	DECLARE @IdsForPostingUpdated VARCHAR(MAX)
	SELECT DISTINCT
		@IdsForPostingUpdated = COALESCE(@IdsForPostingUpdated + ',' ,'') + CAST([intInvoiceID] AS NVARCHAR(250))
	FROM
		#EntriesForProcessing
	WHERE
		ISNULL([ysnForUpdate],0) = 1
		AND ISNULL([ysnProcessed],0) = 1
		AND ISNULL([intInvoiceID],0) <> 0
		AND ISNULL([ysnPost],0) = 1
		
		
	SET @UpdatedIvoices = @IdsForPostingUpdated

	IF LEN(RTRIM(LTRIM(@IdsForPostingUpdated))) > 0				
		EXEC [dbo].[uspARPostInvoice]
			@batchId			= NULL,
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
			@raiseError			= 1

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
SELECT DISTINCT
	@CreateIds = COALESCE(@CreateIds + ',' ,'') + CAST([intInvoiceID] AS NVARCHAR(250))
FROM
	#EntriesForProcessing
WHERE
	ISNULL([ysnForInsert],0) = 1
	AND ISNULL([ysnProcessed],0) = 1
	AND ISNULL([intInvoiceID],0) <> 0
	
SET @CreatedIvoices = @CreateIds


DECLARE @UpdatedIds VARCHAR(MAX)
SELECT DISTINCT
	@UpdatedIds = COALESCE(@UpdatedIds + ',' ,'') + CAST([intInvoiceID] AS NVARCHAR(250))
FROM
	#EntriesForProcessing
WHERE
	ISNULL([ysnForUpdate],0) = 1
	AND ISNULL([ysnProcessed],0) = 1
	AND ISNULL([intInvoiceID],0) <> 0
	
SET @UpdatedIvoices = @UpdatedIds



IF ISNULL(@RaiseError,0) = 0
	COMMIT TRANSACTION 
	
RETURN 1;

END