CREATE PROCEDURE [dbo].[uspARCreateInvoiceFromShipment]
	 @ShipmentId		AS INT
	,@UserId			AS INT
	,@NewInvoiceId		AS INT			= NULL OUTPUT			
AS

BEGIN

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE  @ZeroDecimal		DECIMAL(18,6)
		,@DateOnly			DATETIME
		,@ShipmentNumber	NVARCHAR(100)
		,@InvoiceId			INT
		,@InvoiceNumber		NVARCHAR(25) 

SELECT
	 @ZeroDecimal	= 0.000000	
	,@DateOnly		= CAST(GETDATE() AS DATE)


DECLARE
	 @TransactionType			NVARCHAR(25)
	,@Type						NVARCHAR(100)
	,@EntityCustomerId			INT
	,@CompanyLocationId			INT
	,@AccountId					INT
	,@CurrencyId				INT
	,@SubCurrencyCents			INT
	,@TermId					INT
	,@SourceId					INT
	,@PeriodsToAccrue			INT
	,@Date						DATETIME
	,@DueDate					DATETIME
	,@ShipDate					DATETIME
	,@PostDate					DATETIME
	,@CalculatedDate			DATETIME
	,@InvoiceSubtotal			NUMERIC(18, 6)
	,@Shipping					NUMERIC(18, 6)
	,@Tax						NUMERIC(18, 6)
	,@InvoiceTotal				NUMERIC(18, 6)
	,@Discount					NUMERIC(18, 6)
	,@DiscountAvailable			NUMERIC(18, 6)
	,@Interest					NUMERIC(18, 6)
	,@AmountDue					NUMERIC(18, 6)
	,@Payment					NUMERIC(18, 6)
	,@EntitySalespersonId		INT
	,@FreightTermId				INT
	,@ShipViaId					INT
	,@PaymentMethodId			INT
	,@InvoiceOriginId			NVARCHAR(8)
	,@PONumber					NVARCHAR(25)
	,@BOLNumber					NVARCHAR(50)
	,@DeliverPickup				NVARCHAR(100)
	,@Comments					NVARCHAR(max)
	,@FooterComments			NVARCHAR(max)
	,@ShipToLocationId			INT
	,@ShipToLocationName		NVARCHAR(50)
	,@ShipToAddress				NVARCHAR(100)
	,@ShipToCity				NVARCHAR(30)
	,@ShipToState				NVARCHAR(50)
	,@ShipToZipCode				NVARCHAR(12)
	,@ShipToCountry				NVARCHAR(25)
	,@BillToLocationId			INT
	,@BillToLocationName		NVARCHAR(50)
	,@BillToAddress				NVARCHAR(100)
	,@BillToCity				NVARCHAR(30)
	,@BillToState				NVARCHAR(50)
	,@BillToZipCode				NVARCHAR(12)
	,@BillToCountry				NVARCHAR(25)
	,@Posted					BIT
	,@Paid						BIT
	,@Processed					BIT
	,@Template					BIT
	,@Forgiven					BIT
	,@Calculated				BIT
	,@Splitted					BIT
	,@PaymentId					INT
	,@SplitId					INT
	,@DistributionHeaderId		INT
	,@LoadDistributionHeaderId	INT
	,@ActualCostId				NVARCHAR(50)
	,@InboundShipmentId			INT
	,@TransactionId				INT
	,@OriginalInvoiceId			INT
	
	
SELECT
	 @ShipmentNumber			= ICIS.[strShipmentNumber]
	,@TransactionType			= 'Invoice'
	,@Type						= 'Standard'
	,@EntityCustomerId			= ICIS.[intEntityCustomerId]
	,@CompanyLocationId			= ICIS.[intShipFromLocationId]	
	,@AccountId					= NULL
	,@CurrencyId				= ISNULL(ARC.[intCurrencyId], (SELECT TOP 1 intDefaultCurrencyId FROM tblSMCompanyPreference WHERE intDefaultCurrencyId IS NOT NULL AND intDefaultCurrencyId <> 0))
	,@SubCurrencyCents			= NULL
	,@TermId					= NULL
	,@SourceId					= @ShipmentId
	,@PeriodsToAccrue			= 1
	,@Date						= @DateOnly
	,@DueDate					= NULL
	,@ShipDate					= ICIS.[dtmShipDate]
	,@PostDate					= @DateOnly
	,@CalculatedDate			= @DateOnly
	,@InvoiceSubtotal			= @ZeroDecimal
	,@Shipping					= @ZeroDecimal
	,@Tax						= @ZeroDecimal
	,@InvoiceTotal				= @ZeroDecimal
	,@Discount					= @ZeroDecimal
	,@DiscountAvailable			= @ZeroDecimal
	,@Interest					= @ZeroDecimal
	,@AmountDue					= @ZeroDecimal
	,@Payment					= @ZeroDecimal
	,@EntitySalespersonId		= ARC.[intSalespersonId]
	,@FreightTermId				= ICIS.[intFreightTermId]
	,@ShipViaId					= ICIS.[intShipViaId]
	,@PaymentMethodId			= NULL
	,@InvoiceOriginId			= NULL
	,@PONumber					= SO.[strPONumber]
	,@BOLNumber					= ICIS.[strBOLNumber]
	,@DeliverPickup				= NULL
	,@Comments					= ICIS.[strShipmentNumber] + ' : '	+ ICIS.[strReferenceNumber]
	,@FooterComments			= NULL
	,@ShipToLocationId			= NULL
	,@ShipToLocationName		= NULL
	,@ShipToAddress				= NULL
	,@ShipToCity				= NULL
	,@ShipToState				= NULL
	,@ShipToZipCode				= NULL
	,@ShipToCountry				= NULL
	,@BillToLocationId			= NULL
	,@BillToLocationName		= NULL
	,@BillToAddress				= NULL
	,@BillToCity				= NULL
	,@BillToState				= NULL
	,@BillToZipCode				= NULL
	,@BillToCountry				= NULL
	,@Posted					= 0
	,@Paid						= 0
	,@Processed					= 0
	,@Template					= 0
	,@Forgiven					= 0
	,@Calculated				= 0
	,@Splitted					= 0
	,@PaymentId					= NULL
	,@SplitId					= NULL
	,@DistributionHeaderId		= NULL
	,@LoadDistributionHeaderId	= NULL
	,@ActualCostId				= NULL
	,@InboundShipmentId			= NULL
	,@TransactionId				= NULL
	,@OriginalInvoiceId			= NULL
FROM 
	[tblICInventoryShipment] ICIS
INNER JOIN
	[tblARCustomer] ARC
		ON ICIS.[intEntityCustomerId] = ARC.[intEntityCustomerId] 
LEFT OUTER JOIN
	tblSOSalesOrder SO
		ON ICIS.strReferenceNumber = SO.strSalesOrderNumber
		
DECLARE @EntriesForInvoice AS InvoiceIntegrationStagingTable		

INSERT INTO @EntriesForInvoice
	([strSourceTransaction]
	,[intSourceId]
	,[strSourceId]
	,[intInvoiceId]
	,[intEntityCustomerId]
	,[intCompanyLocationId]
	,[intCurrencyId]
	,[intSubCurrencyCents]
	,[intTermId]
	,[intPeriodsToAccrue]
	,[dtmDate]
	,[dtmDueDate]
	,[dtmShipDate]
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
	,[intOriginalInvoiceId]
	,[intEntityId]
	,[ysnResetDetails]
	,[ysnRecap]
	,[ysnPost]
																																																		
	,[intInvoiceDetailId]
	,[intItemId]
	,[ysnInventory]
	,[strDocumentNumber]
	,[strItemDescription]
	,[intOrderUOMId]
	,[dblQtyOrdered]
	,[intItemUOMId]
	,[dblQtyShipped]
	,[dblDiscount]
	,[dblItemWeight]
	,[intItemWeightUOMId]
	,[dblPrice]
	,[strPricing]
	,[ysnRefreshPrice]
	,[strMaintenanceType]
	,[strFrequency]
	,[dtmMaintenanceDate]
	,[dblMaintenanceAmount]
	,[dblLicenseAmount]
	,[intTaxGroupId]
	,[intStorageLocationId]
	--,[intCompanyLocationSubLocationId]
	,[ysnRecomputeTax]
	,[intSCInvoiceId]
	,[strSCInvoiceNumber]
	,[intSCBudgetId]
	,[strSCBudgetDescription]
	,[intInventoryShipmentItemId]
	,[strShipmentNumber]
	,[intSalesOrderDetailId]
	,[strSalesOrderNumber]
	,[intContractHeaderId]
	,[intContractDetailId]
	,[intShipmentPurchaseSalesContractId]
	,[dblShipmentGrossWt]
	,[dblShipmentTareWt]
	,[dblShipmentNetWt]
	,[intTicketId]
	,[intTicketHoursWorkedId]
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
	,[ysnSubCurrency]
	)
SELECT
	 [strSourceTransaction]					= 'Inventory Shipment'
	,[intSourceId]							= @ShipmentId
	,[strSourceId]							= @ShipmentNumber
	,[intInvoiceId]							= NULL
	,[intEntityCustomerId]					= @EntityCustomerId 
	,[intCompanyLocationId]					= @CompanyLocationId 
	,[intCurrencyId]						= @CurrencyId 
	,[intSubCurrencyCents]					= @SubCurrencyCents 
	,[intTermId]							= @TermId 
	,[intPeriodsToAccrue]					= @PeriodsToAccrue 
	,[dtmDate]								= @Date 
	,[dtmDueDate]							= @DueDate 
	,[dtmShipDate]							= @ShipDate 
	,[intEntitySalespersonId]				= @EntitySalespersonId 
	,[intFreightTermId]						= @FreightTermId 
	,[intShipViaId]							= @ShipViaId 
	,[intPaymentMethodId]					= @PaymentMethodId 
	,[strInvoiceOriginId]					= @InvoiceOriginId 
	,[strPONumber]							= @PONumber 
	,[strBOLNumber]							= @BOLNumber 
	,[strDeliverPickup]						= @DeliverPickup 
	,[strComments]							= @Comments 
	,[intShipToLocationId]					= @ShipToLocationId 
	,[intBillToLocationId]					= @BillToLocationId
	,[ysnTemplate]							= @Template
	,[ysnForgiven]							= @Forgiven
	,[ysnCalculated]						= @Calculated
	,[ysnSplitted]							= @Splitted
	,[intPaymentId]							= @PaymentId
	,[intSplitId]							= @SplitId
	,[intDistributionHeaderId]				= @DistributionHeaderId
	,[strActualCostId]						= @ActualCostId
	,[intShipmentId]						= NULL
	,[intTransactionId]						= @TransactionId
	,[intOriginalInvoiceId]					= @OriginalInvoiceId
	,[intEntityId]							= @UserId
	,[ysnResetDetails]						= 0
	,[ysnRecap]								= 0
	,[ysnPost]								= 0
																																																		
	,[intInvoiceDetailId]					= NULL
	,[intItemId]							= ARSI.[intItemId]
	,[ysnInventory]							= 1
	,[strDocumentNumber]					= @ShipmentNumber 
	,[strItemDescription]					= ARSI.[strItemDescription]
	,[intOrderUOMId]						= ARSI.[intOrderUOMId] 
	,[dblQtyOrdered]						= ARSI.[dblQtyOrdered] 
	,[intItemUOMId]							= ARSI.[intItemUOMId] 
	,[dblQtyShipped]						= ARSI.[dblQtyShipped] 
	,[dblDiscount]							= ARSI.[dblDiscount] 
	,[dblItemWeight]						= ARSI.[dblWeight]  
	,[intItemWeightUOMId]					= ARSI.[intWeightUOMId] 
	,[dblPrice]								= ARSI.[dblShipmentUnitPrice] 
	,[strPricing]							= 'Inventory Shipment Item Price'
	,[ysnRefreshPrice]						= 0
	,[strMaintenanceType]					= NULL
	,[strFrequency]							= NULL
	,[dtmMaintenanceDate]					= NULL
	,[dblMaintenanceAmount]					= @ZeroDecimal 
	,[dblLicenseAmount]						= @ZeroDecimal
	,[intTaxGroupId]						= ARSI.[intTaxGroupId] 
	,[intStorageLocationId]					= ARSI.[intStorageLocationId] 
	--,[intCompanyLocationSubLocationId]		= ARSI.[intStorageLocationId] 
	,[ysnRecomputeTax]						= 1
	,[intSCInvoiceId]						= NULL
	,[strSCInvoiceNumber]					= NULL
	,[intSCBudgetId]						= NULL
	,[strSCBudgetDescription]				= NULL
	,[intInventoryShipmentItemId]			= ARSI.[intInventoryShipmentItemId] 
	,[strShipmentNumber]					= ARSI.strInventoryShipmentNumber 
	,[intSalesOrderDetailId]				= ARSI.[intSalesOrderDetailId] 
	,[strSalesOrderNumber]					= ARSI.[strSalesOrderNumber] 
	,[intContractHeaderId]					= ARSI.[intContractHeaderId] 
	,[intContractDetailId]					= ARSI.[intContractDetailId] 
	,[intShipmentPurchaseSalesContractId]	= NULL
	,[dblShipmentGrossWt]					= ARSI.[dblGrossWt] 
	,[dblShipmentTareWt]					= ARSI.[dblTareWt] 
	,[dblShipmentNetWt]						= ARSI.[dblNetWt] 
	,[intTicketId]							= ARSI.[intTicketId] 
	,[intTicketHoursWorkedId]				= NULL
	,[intOriginalInvoiceDetailId]			= NULL
	,[intSiteId]							= NULL
	,[strBillingBy]							= NULL
	,[dblPercentFull]						= NULL
	,[dblNewMeterReading]					= @ZeroDecimal
	,[dblPreviousMeterReading]				= @ZeroDecimal
	,[dblConversionFactor]					= @ZeroDecimal
	,[intPerformerId]						= NULL
	,[ysnLeaseBilling]						= 0
	,[ysnVirtualMeterReading]				= 0
	,[ysnClearDetailTaxes]					= 0
	,[intTempDetailIdForTaxes]				= NULL
	,[ysnSubCurrency]						= 0
FROM
	vyuARShippedItems ARSI
WHERE
	ARSI.[strTransactionType] = 'Inventory Shipment'
	--AND ARSI.[strTransactionNumber] = @ShipmentNumber
	AND ARSI.[intInventoryShipmentId] = @ShipmentId


IF NOT EXISTS(SELECT TOP 1 NULL FROM @EntriesForInvoice)
BEGIN
	SELECT TOP 1
		@InvoiceNumber		= ARI.[strInvoiceNumber]
		,@ShipmentNumber	= ICIS.[strShipmentNumber] 
	FROM
		tblARInvoice ARI
	INNER JOIN
		tblARInvoiceDetail ARID
			ON ARI.[intInvoiceId] = ARID.[intInvoiceId]
	INNER JOIN
		tblICInventoryShipmentItem ICISI
			ON ARID.[intInventoryShipmentItemId] = ICISI.[intInventoryShipmentItemId]
	INNER JOIN
		tblICInventoryShipment ICIS
			ON ICISI.[intInventoryShipmentId] = ICIS.[intInventoryShipmentId] 
	WHERE
		ICISI.[intInventoryShipmentId] = @ShipmentId 

	DECLARE @ErrorMessage NVARCHAR(250)

	SET @ErrorMessage = 'Invoice(' + @InvoiceNumber + ') was already created for ' + @ShipmentNumber;

	RAISERROR(@ErrorMessage, 16, 1);
	RETURN 0;
END
	
	
DECLARE	 @LineItemTaxEntries	LineItemTaxDetailStagingTable
		,@CurrentErrorMessage NVARCHAR(250)
		,@CreatedIvoices NVARCHAR(MAX)
		,@UpdatedIvoices NVARCHAR(MAX)	
				

EXEC [dbo].[uspARProcessInvoices]
	 @InvoiceEntries		= @EntriesForInvoice
	,@LineItemTaxEntries	= @LineItemTaxEntries
	,@UserId				= @UserId
	,@GroupingOption		= 11
	,@RaiseError			= 1
	,@ErrorMessage			= @CurrentErrorMessage	OUTPUT
	,@CreatedIvoices		= @CreatedIvoices		OUTPUT
	,@UpdatedIvoices		= @UpdatedIvoices		OUTPUT

		
SELECT TOP 1 @NewInvoiceId = intInvoiceId FROM tblARInvoice WHERE intInvoiceId IN (SELECT intID FROM fnGetRowsFromDelimitedValues(@CreatedIvoices))			
         
RETURN @NewInvoiceId

END		