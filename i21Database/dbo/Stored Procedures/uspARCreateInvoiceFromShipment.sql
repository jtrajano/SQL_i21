﻿CREATE PROCEDURE [dbo].[uspARCreateInvoiceFromShipment]
	 @ShipmentId		   AS INT
	,@UserId			   AS INT
	,@NewInvoiceId		   AS INT			= NULL OUTPUT		
	,@OnlyUseShipmentPrice AS BIT           = 0
	,@IgnoreNoAvailableItemError AS BIT     = 0
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
		,@InvoiceNumber		NVARCHAR(25) = ''
		,@strReferenceNumber NVARCHAR(100)

SELECT TOP 1
	@InvoiceNumber = ARI.[strInvoiceNumber]
FROM
	tblARInvoiceDetail ARID 
INNER JOIN
	tblARInvoice ARI 
		ON ARID.[intInvoiceId] = ARI.[intInvoiceId]
INNER JOIN
	tblICInventoryShipmentItem ICISI
		ON ARID.[intInventoryShipmentItemId] = ICISI.[intInventoryShipmentItemId]
WHERE
	ICISI.[intInventoryShipmentId] = @ShipmentId

IF (ISNULL(@InvoiceNumber,'') <> '')
	BEGIN
		RAISERROR('There is already an existing Invoice(%s) for this shipment!', 16, 1,@InvoiceNumber);
		RETURN 0;
	END

SELECT
	 @ZeroDecimal	= 0.000000	
	,@DateOnly		= CAST(GETDATE() AS DATE)

SELECT TOP 1 @strReferenceNumber = strSalesOrderNumber FROM tblSOSalesOrder ORDER BY intSalesOrderId DESC

DECLARE
	 @TransactionType			NVARCHAR(25)
	,@Type						NVARCHAR(100)
	,@EntityCustomerId			INT
	,@CompanyLocationId			INT
	,@CurrencyId				INT	
	,@SourceId					INT
	,@PeriodsToAccrue			INT
	,@Date						DATETIME
	,@ShipDate					DATETIME
	,@PostDate					DATETIME
	,@CalculatedDate			DATETIME
	,@EntitySalespersonId		INT
	,@FreightTermId				INT
	,@ShipViaId					INT
	,@PONumber					NVARCHAR(25)
	,@BOLNumber					NVARCHAR(50)
	,@Comments					NVARCHAR(MAX)
	,@SalesOrderComments		NVARCHAR(MAX)
	,@InvoiceComments			NVARCHAR(MAX)
	,@ShipToLocationId			INT
	,@SalesOrderId				INT
	,@StorageScheduleTypeId		INT
	
SELECT
	 @ShipmentNumber			= ICIS.[strShipmentNumber]
	,@TransactionType			= 'Invoice'
	,@Type						= 'Standard'
	,@EntityCustomerId			= ICIS.[intEntityCustomerId]
	,@CompanyLocationId			= ICIS.[intShipFromLocationId]	
	,@CurrencyId				= ISNULL( ICIS.intCurrencyId, ISNULL((SELECT TOP 1 intCurrencyId FROM vyuARShippedItems WHERE intInventoryShipmentId = @ShipmentId AND intInventoryShipmentChargeId IS NOT NULL AND intCurrencyId IS nOT NULL),ISNULL(ARC.[intCurrencyId], (SELECT TOP 1 intDefaultCurrencyId FROM tblSMCompanyPreference WHERE intDefaultCurrencyId IS NOT NULL AND intDefaultCurrencyId <> 0))))
	,@SourceId					= @ShipmentId
	,@PeriodsToAccrue			= 1
	,@Date						= @DateOnly
	,@ShipDate					= ICIS.[dtmShipDate]
	,@PostDate					= @DateOnly
	,@CalculatedDate			= @DateOnly
	,@EntitySalespersonId		= ISNULL(CT.[intSalespersonId],ARC.[intSalespersonId])
	,@FreightTermId				= ICIS.[intFreightTermId]
	,@ShipViaId					= ICIS.[intShipViaId]
	,@PONumber					= SO.[strPONumber]
	,@BOLNumber					= ICIS.[strBOLNumber]
	,@Comments					= ICIS.[strShipmentNumber] + ' : '	+ ISNULL(ICIS.[strReferenceNumber], '')
	,@SalesOrderComments		= SO.strComments
	,@ShipToLocationId			= ICIS.intShipToLocationId
	,@SalesOrderId				= SO.intSalesOrderId
	,@StorageScheduleTypeId		= @StorageScheduleTypeId
FROM 
	[tblICInventoryShipment] ICIS
INNER JOIN
	[tblARCustomer] ARC
		ON ICIS.[intEntityCustomerId] = ARC.[intEntityId] 
LEFT JOIN
	[tblICInventoryShipmentItem] ICISITEM
		ON ICIS.[intInventoryShipmentId] = ICISITEM.[intInventoryShipmentId]
LEFT JOIN
	[tblCTContractHeader] CT
		ON ICISITEM.[intOrderId] = CT.[intContractHeaderId]
LEFT OUTER JOIN
	tblSOSalesOrder SO
		ON SO.strSalesOrderNumber = @strReferenceNumber
		AND ICIS.strReferenceNumber = @strReferenceNumber
WHERE ICIS.intInventoryShipmentId = @ShipmentId
	AND ((ISNULL(ICISITEM.[ysnAllowInvoice], 1) = 1 AND ICIS.[intSourceType] = 1)
		OR
		ICIS.[intSourceType] <> 1
		)

IF (ISNULL(@SalesOrderId, 0) > 0) AND EXISTS  (SELECT NULL FROM tblSOSalesOrderDetail WHERE intSalesOrderId = @SalesOrderId AND ISNULL(intRecipeId, 0) <> 0)
	BEGIN
		EXEC dbo.uspARGetDefaultComment @CompanyLocationId, @EntityCustomerId, 'Invoice', 'Standard', @InvoiceComments OUT

		SET @Comments = ISNULL(@Comments, '') + ' ' + ISNULL(@InvoiceComments,'') + ' ' + ISNULL(@SalesOrderComments, '')
	END
		
DECLARE @UnsortedEntriesForInvoice AS InvoiceIntegrationStagingTable
DECLARE @EntriesForInvoice AS InvoiceIntegrationStagingTable		

INSERT INTO @UnsortedEntriesForInvoice
	([strSourceTransaction]
	,[intSourceId]
	,[strSourceId]
	,[intInvoiceId]
	,[intEntityCustomerId]
	,[intCompanyLocationId]
	,[intCurrencyId]
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
	,[intPriceUOMId]
	,[dblQtyShipped]
	,[dblContractPriceUOMQty]
	,[dblDiscount]
	,[dblItemWeight]
	,[intItemWeightUOMId]
	,[dblPrice]
	,[dblUnitPrice]
	,[strPricing]
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
	,[ysnBlended]
	,[intStorageScheduleTypeId]
	,[intDestinationGradeId]
	,[intDestinationWeightId]
	,[intCurrencyExchangeRateTypeId]
	,[intCurrencyExchangeRateId]
	,[dblCurrencyExchangeRate]
	,[intSubCurrencyId] 
	,[dblSubCurrencyRate] 
	)
SELECT
	 [strSourceTransaction]					= 'Inventory Shipment'
	,[intSourceId]							= @ShipmentId
	,[strSourceId]							= @ShipmentNumber
	,[intInvoiceId]							= NULL
	,[intEntityCustomerId]					= @EntityCustomerId 
	,[intCompanyLocationId]					= @CompanyLocationId 
	,[intCurrencyId]						= @CurrencyId 
	,[intTermId]							= NULL 
	,[intPeriodsToAccrue]					= @PeriodsToAccrue 
	,[dtmDate]								= @Date 
	,[dtmDueDate]							= NULL
	,[dtmShipDate]							= @ShipDate 
	,[intEntitySalespersonId]				= @EntitySalespersonId 
	,[intFreightTermId]						= @FreightTermId 
	,[intShipViaId]							= @ShipViaId 
	,[intPaymentMethodId]					= NULL 
	,[strInvoiceOriginId]					= NULL 
	,[strPONumber]							= @PONumber 
	,[strBOLNumber]							= @BOLNumber 
	,[strComments]							= @Comments 
	,[intShipToLocationId]					= @ShipToLocationId 
	,[intBillToLocationId]					= NULL
	,[ysnTemplate]							= 0
	,[ysnForgiven]							= 0
	,[ysnCalculated]						= 0
	,[ysnSplitted]							= 0
	,[intPaymentId]							= NULL
	,[intSplitId]							= (SELECT TOP 1 intSplitId FROM tblSOSalesOrder WHERE intSalesOrderId = ARSI.intSalesOrderId)
	,[intDistributionHeaderId]				= NULL
	,[strActualCostId]						= NULL
	,[intShipmentId]						= NULL
	,[intTransactionId]						= NULL
	,[intOriginalInvoiceId]					= NULL
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
	,[intPriceUOMId]						= CASE WHEN ISNULL(@OnlyUseShipmentPrice, 0) = 0 THEN ARSI.[intPriceUOMId] ELSE ARSI.[intItemUOMId] END
	,[dblQtyShipped]						= ARSI.[dblQtyShipped]
	,[dblContractPriceUOMQty]				= CASE WHEN ISNULL(@OnlyUseShipmentPrice, 0) = 0 THEN ARSI.[dblPriceUOMQuantity] ELSE ARSI.[dblQtyShipped] END 
	,[dblDiscount]							= ARSI.[dblDiscount] 
	,[dblItemWeight]						= ARSI.[dblWeight]  
	,[intItemWeightUOMId]					= ARSI.[intWeightUOMId] 
	,[dblPrice]								= CASE WHEN ARSI.[intOwnershipType] = 2 THEN 0 ELSE ARSI.[dblShipmentUnitPrice] END
	,[dblUnitPrice]							= CASE WHEN ARSI.[intOwnershipType] = 2 THEN 0 ELSE (CASE WHEN ISNULL(@OnlyUseShipmentPrice, 0) = 0 THEN ARSI.[dblUnitPrice] ELSE ARSI.[dblShipmentUnitPrice] END) END
	,[strPricing]							= ARSI.[strPricing]
	,[ysnRefreshPrice]						= 0
	,[strMaintenanceType]					= NULL
	,[strFrequency]							= NULL
	,[dtmMaintenanceDate]					= NULL
	,[dblMaintenanceAmount]					= @ZeroDecimal 
	,[dblLicenseAmount]						= @ZeroDecimal
	,[intTaxGroupId]						= ARSI.[intTaxGroupId] 
	,[intStorageLocationId]					= ARSI.[intStorageLocationId] 
	,[intCompanyLocationSubLocationId]		= ARSI.[intSubLocationId]
	,[ysnRecomputeTax]						= (CASE WHEN ISNULL(ARSI.[intSalesOrderDetailId], 0) = 0 THEN 1 ELSE 0 END)	
	,[intSCInvoiceId]						= NULL
	,[strSCInvoiceNumber]					= NULL
	,[intSCBudgetId]						= NULL
	,[strSCBudgetDescription]				= NULL
	,[intInventoryShipmentItemId]			= ARSI.[intInventoryShipmentItemId] 
	,[intInventoryShipmentChargeId]			= ARSI.[intInventoryShipmentChargeId]
	,[strShipmentNumber]					= ARSI.[strInventoryShipmentNumber] 
	,[intRecipeItemId]						= ARSI.[intRecipeItemId] 
	,[intRecipeId]							= ARSI.[intRecipeId]
	,[intSubLocationId]						= ARSI.[intSubLocationId]
	,[intCostTypeId]						= ARSI.[intCostTypeId]
	,[intMarginById]						= ARSI.[intMarginById]
	,[intCommentTypeId]						= ARSI.[intCommentTypeId]
	,[dblMargin]							= ARSI.[dblMargin]
	,[dblRecipeQuantity]					= ARSI.[dblRecipeQuantity]
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
	,[intTempDetailIdForTaxes]				= ARSI.[intSalesOrderDetailId]
	,[ysnBlended]							= ARSI.[ysnBlended]
	,[intStorageScheduleTypeId]				= @StorageScheduleTypeId
	,[intDestinationGradeId]				= ARSI.[intDestinationGradeId]
	,[intDestinationWeightId]				= ARSI.[intDestinationWeightId]
	,[intCurrencyExchangeRateTypeId]		= ARSI.[intCurrencyExchangeRateTypeId]
	,[intCurrencyExchangeRateId]			= ARSI.[intCurrencyExchangeRateId]
	,[dblCurrencyExchangeRate]				= ARSI.[dblCurrencyExchangeRate]
	,[intSubCurrencyId]						= ARSI.[intSubCurrencyId]
	,[dblSubCurrencyRate]					= ARSI.[dblSubCurrencyRate]
FROM
	vyuARShippedItems ARSI
WHERE
	ARSI.[strTransactionType] = 'Inventory Shipment'
	AND ARSI.[intInventoryShipmentId] = @ShipmentId
	AND ARSI.intEntityCustomerId = @EntityCustomerId
	AND (ISNULL(ARSI.intPricingTypeId, 0) <> 2 OR (ISNULL(ARSI.intPricingTypeId, 0) = 2 AND ISNULL(dbo.fnCTGetAvailablePriceQuantity(ARSI.[intContractDetailId],0), 0) > 0))

UNION ALL

SELECT 
	 [strSourceTransaction]					= 'Inventory Shipment'
	,[intSourceId]							= @ShipmentId
	,[strSourceId]							= @ShipmentNumber
	,[intInvoiceId]							= NULL
	,[intEntityCustomerId]					= @EntityCustomerId 
	,[intCompanyLocationId]					= @CompanyLocationId 
	,[intCurrencyId]						= @CurrencyId 
	,[intTermId]							= NULL 
	,[intPeriodsToAccrue]					= @PeriodsToAccrue 
	,[dtmDate]								= @Date 
	,[dtmDueDate]							= NULL
	,[dtmShipDate]							= @ShipDate 
	,[intEntitySalespersonId]				= @EntitySalespersonId 
	,[intFreightTermId]						= @FreightTermId 
	,[intShipViaId]							= @ShipViaId 
	,[intPaymentMethodId]					= NULL 
	,[strInvoiceOriginId]					= NULL 
	,[strPONumber]							= @PONumber 
	,[strBOLNumber]							= @BOLNumber 
	,[strComments]							= @Comments 
	,[intShipToLocationId]					= @ShipToLocationId 
	,[intBillToLocationId]					= NULL
	,[ysnTemplate]							= 0
	,[ysnForgiven]							= 0
	,[ysnCalculated]						= 0
	,[ysnSplitted]							= 0
	,[intPaymentId]							= NULL
	,[intSplitId]							= SO.intSplitId
	,[intDistributionHeaderId]				= NULL
	,[strActualCostId]						= NULL
	,[intShipmentId]						= NULL
	,[intTransactionId]						= NULL
	,[intOriginalInvoiceId]					= NULL
	,[intEntityId]							= @UserId
	,[ysnResetDetails]						= 0
	,[ysnRecap]								= 0
	,[ysnPost]								= 0

	,[intInvoiceDetailId]					= NULL
	,[intItemId]							= SOD.intItemId
	,[ysnInventory]							= 0
	,[strDocumentNumber]					= SO.strSalesOrderNumber 
	,[strItemDescription]					= SOD.strItemDescription
	,[intOrderUOMId]						= NULL
	,[dblQtyOrdered]						= @ZeroDecimal
	,[intItemUOMId]							= NULL
	,[intPriceUOMId]						= NULL
	,[dblQtyShipped]						= @ZeroDecimal
	,[dblContractPriceUOMQty]				= @ZeroDecimal
	,[dblDiscount]							= @ZeroDecimal
	,[dblItemWeight]						= @ZeroDecimal
	,[intItemWeightUOMId]					= @ZeroDecimal
	,[dblPrice]								= @ZeroDecimal
	,[dblUnitPrice]							= @ZeroDecimal
	,[strPricing]							= SOD.[strPricing]
	,[ysnRefreshPrice]						= 0
	,[strMaintenanceType]					= NULL
	,[strFrequency]							= NULL
	,[dtmMaintenanceDate]					= NULL
	,[dblMaintenanceAmount]					= @ZeroDecimal 
	,[dblLicenseAmount]						= @ZeroDecimal
	,[intTaxGroupId]						= NULL
	,[intStorageLocationId]					= SOD.[intStorageLocationId] 
	,[intCompanyLocationSubLocationId]		= SOD.[intSubLocationId] 
	,[ysnRecomputeTax]						= (CASE WHEN ISNULL(SOD.[intSalesOrderDetailId], 0) = 0 THEN 1 ELSE 0 END)
	,[intSCInvoiceId]						= NULL
	,[strSCInvoiceNumber]					= NULL
	,[intSCBudgetId]						= NULL
	,[strSCBudgetDescription]				= NULL
	,[intInventoryShipmentItemId]			= NULL 
	,[intInventoryShipmentChargeId]			= NULL
	,[strShipmentNumber]					= ICIS.strShipmentNumber
	,[intRecipeItemId]						= SOD.intRecipeItemId 
	,[intRecipeId]							= SOD.intRecipeId
	,[intSubLocationId]						= NULL
	,[intCostTypeId]						= NULL
	,[intMarginById]						= NULL
	,[intCommentTypeId]						= SOD.intCommentTypeId
	,[dblMargin]							= @ZeroDecimal
	,[dblRecipeQuantity]					= @ZeroDecimal
	,[intSalesOrderDetailId]				= SOD.intSalesOrderDetailId
	,[strSalesOrderNumber]					= SO.strSalesOrderNumber 
	,[intContractHeaderId]					= NULL
	,[intContractDetailId]					= NULL
	,[intShipmentPurchaseSalesContractId]	= NULL
	,[dblShipmentGrossWt]					= @ZeroDecimal 
	,[dblShipmentTareWt]					= @ZeroDecimal
	,[dblShipmentNetWt]						= @ZeroDecimal
	,[intTicketId]							= NULL
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
	,[intTempDetailIdForTaxes]				= SOD.intSalesOrderDetailId
	,[ysnBlended]							= 0
	,[intStorageScheduleTypeId]				= SOD.intStorageScheduleTypeId
	,[intDestinationGradeId]				= NULL
	,[intDestinationWeightId]				= NULL
	,[intCurrencyExchangeRateTypeId]		= SOD.[intCurrencyExchangeRateTypeId]
	,[intCurrencyExchangeRateId]			= SOD.[intCurrencyExchangeRateId]
	,[dblCurrencyExchangeRate]				= SOD.[dblCurrencyExchangeRate]
	,[intSubCurrencyId]						= SOD.[intSubCurrencyId]
	,[dblSubCurrencyRate]					= SOD.[dblSubCurrencyRate]
FROM 
	tblICInventoryShipment ICIS
	INNER JOIN tblSOSalesOrder SO 
		ON SO.strSalesOrderNumber = @strReferenceNumber
		AND ICIS.intEntityCustomerId = SO.intEntityCustomerId 
	INNER JOIN tblSOSalesOrderDetail SOD 
		ON SO.intSalesOrderId = SOD.intSalesOrderId 
		AND SOD.intCommentTypeId IN (0,1,3)
		AND SOD.dblQtyOrdered = 0
WHERE 
	ICIS.intInventoryShipmentId = @ShipmentId


UNION ALL

SELECT 
	 [strSourceTransaction]					= 'Inventory Shipment'
	,[intSourceId]							= @ShipmentId
	,[strSourceId]							= @ShipmentNumber
	,[intInvoiceId]							= NULL
	,[intEntityCustomerId]					= @EntityCustomerId 
	,[intCompanyLocationId]					= @CompanyLocationId 
	,[intCurrencyId]						= @CurrencyId 
	,[intTermId]							= NULL 
	,[intPeriodsToAccrue]					= @PeriodsToAccrue 
	,[dtmDate]								= @Date 
	,[dtmDueDate]							= NULL
	,[dtmShipDate]							= @ShipDate 
	,[intEntitySalespersonId]				= @EntitySalespersonId 
	,[intFreightTermId]						= @FreightTermId 
	,[intShipViaId]							= @ShipViaId 
	,[intPaymentMethodId]					= NULL 
	,[strInvoiceOriginId]					= NULL 
	,[strPONumber]							= @PONumber 
	,[strBOLNumber]							= @BOLNumber 
	,[strComments]							= @Comments 
	,[intShipToLocationId]					= @ShipToLocationId 
	,[intBillToLocationId]					= NULL
	,[ysnTemplate]							= 0
	,[ysnForgiven]							= 0
	,[ysnCalculated]						= 0
	,[ysnSplitted]							= 0
	,[intPaymentId]							= NULL
	,[intSplitId]							= NULL
	,[intDistributionHeaderId]				= NULL
	,[strActualCostId]						= NULL
	,[intShipmentId]						= NULL
	,[intTransactionId]						= NULL
	,[intOriginalInvoiceId]					= NULL
	,[intEntityId]							= @UserId
	,[ysnResetDetails]						= 0
	,[ysnRecap]								= 0
	,[ysnPost]								= 0

	,[intInvoiceDetailId]					= NULL
	,[intItemId]							= ICISI.intItemId
	,[ysnInventory]							= 0
	,[strDocumentNumber]					= ''
	,[strItemDescription]					= ICI.strDescription
	,[intOrderUOMId]						= NULL
	,[dblQtyOrdered]						= @ZeroDecimal
	,[intItemUOMId]							= ICISI.intItemUOMId
	,[intPriceUOMId]						= ICISI.intPriceUOMId
	--,[dblQtyShipped]						= (CASE WHEN ISNULL(ICISI.dblDestinationQuantity,0) = 0 THEN ISNULL(ICISI.dblQuantity,0) ELSE ICISI.dblDestinationQuantity END)
	,[dblQtyShipped]						= ISNULL(ICISI.dblQuantity,0)
	,[dblContractPriceUOMQty]				= ISNULL(ICISI.dblQuantity,0)
	,[dblDiscount]							= @ZeroDecimal
	,[dblItemWeight]						= @ZeroDecimal
	,[intItemWeightUOMId]					= @ZeroDecimal
	,[dblPrice]								= ICISI.dblUnitPrice
	,[dblUnitPrice]							= ICISI.dblUnitPrice
	,[strPricing]							= 'Inventory Shipment'
	,[ysnRefreshPrice]						= 0
	,[strMaintenanceType]					= NULL
	,[strFrequency]							= NULL
	,[dtmMaintenanceDate]					= NULL
	,[dblMaintenanceAmount]					= @ZeroDecimal 
	,[dblLicenseAmount]						= @ZeroDecimal
	,[intTaxGroupId]						= NULL
	,[intStorageLocationId]					= ICISI.[intStorageLocationId] 
	,[intCompanyLocationSubLocationId]		= ICISI.[intSubLocationId] 
	,[ysnRecomputeTax]						= 0
	,[intSCInvoiceId]						= NULL
	,[strSCInvoiceNumber]					= NULL
	,[intSCBudgetId]						= NULL
	,[strSCBudgetDescription]				= NULL
	,[intInventoryShipmentItemId]			= NULL 
	,[intInventoryShipmentChargeId]			= NULL
	,[strShipmentNumber]					= ICIS.strShipmentNumber
	,[intRecipeItemId]						= NULL
	,[intRecipeId]							= NULL
	,[intSubLocationId]						= NULL
	,[intCostTypeId]						= NULL
	,[intMarginById]						= NULL
	,[intCommentTypeId]						= NULL
	,[dblMargin]							= @ZeroDecimal
	,[dblRecipeQuantity]					= @ZeroDecimal
	,[intSalesOrderDetailId]				= NULL
	,[strSalesOrderNumber]					= '' 
	,[intContractHeaderId]					= NULL
	,[intContractDetailId]					= NULL
	,[intShipmentPurchaseSalesContractId]	= NULL
	,[dblShipmentGrossWt]					= @ZeroDecimal 
	,[dblShipmentTareWt]					= @ZeroDecimal
	,[dblShipmentNetWt]						= @ZeroDecimal
	,[intTicketId]							= NULL
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
	,[ysnBlended]							= 0
	,[intStorageScheduleTypeId]				= ICISI.intStorageScheduleTypeId
	,[intDestinationGradeId]				= NULL
	,[intDestinationWeightId]				= NULL
	,[intCurrencyExchangeRateTypeId]		= ICISI.[intForexRateTypeId]
	,[intCurrencyExchangeRateId]			= NULL
	,[dblCurrencyExchangeRate]				= ICISI.[dblForexRate]
	,[intSubCurrencyId]						= NULL
	,[dblSubCurrencyRate]					= @ZeroDecimal
FROM 
	tblICInventoryShipment ICIS
INNER JOIN
	tblICInventoryShipmentItem ICISI
		ON ICIS.intInventoryShipmentId = ICISI.intInventoryShipmentId
INNER JOIN
	tblICItem ICI
		ON ICISI.intItemId = ICI.intItemId
WHERE 
	ICIS.intInventoryShipmentId = @ShipmentId
	AND ICISI.intOwnershipType = 1
	AND ICISI.intOrderId IS NULL
	AND ICISI.intLineNo IS NULL
	AND ((ISNULL(ICISI.[ysnAllowInvoice], 1) = 1 AND ICIS.[intSourceType] = 1)
		OR
		ICIS.[intSourceType] <> 1
		)
	AND ICIS.strShipmentNumber NOT IN (SELECT strTransactionNumber FROM vyuARShippedItems WHERE strTransactionNumber = @ShipmentNumber)

DECLARE @ErrorMessage NVARCHAR(250)

IF NOT EXISTS (SELECT TOP 1 NULL FROM @UnsortedEntriesForInvoice)
	BEGIN
		IF EXISTS (
			SELECT TOP 1 1 FROM tblICInventoryShipmentItem ICISI 
			INNER JOIN tblCTContractDetail CTD ON ICISI.intLineNo = CTD.intContractDetailId AND ICISI.intOrderId = CTD.intContractHeaderId 
			WHERE CTD.intPricingTypeId = 2 
			  AND ICISI.intInventoryShipmentId = @ShipmentId
			  AND ISNULL(dbo.fnCTGetAvailablePriceQuantity(ICISI.intLineNo,0), 0) = 0
		)
		BEGIN
			RAISERROR('Unable to process. Use Price Contract screen to process Basis Contract shipments.', 16, 1);
			RETURN 0;
		END

		IF ISNULL(@IgnoreNoAvailableItemError,0) = 1 RETURN 0;
		SELECT TOP 1 @ShipmentNumber = strShipmentNumber FROM tblICInventoryShipment WHERE intInventoryShipmentId = @ShipmentId
		
		SET @ErrorMessage = 'The items in ' + @ShipmentNumber + ' are not allowed to be converted to Invoice. It could be a DP or Zero Spot Priced.'
		RAISERROR(@ErrorMessage, 16, 1);
		RETURN 0;
	END

SELECT * INTO #TempTable
FROM @UnsortedEntriesForInvoice

ALTER TABLE #TempTable
DROP COLUMN intId

IF EXISTS (SELECT NULL FROM #TempTable WHERE ISNULL(intRecipeId, 0) > 0)
	BEGIN
		DECLARE @tblItemsWithRecipe TABLE(intSalesOrderDetailId INT, intRecipeId INT)
		DECLARE @intCurrentSalesOrderDetailId INT
		      , @intCurrentRecipeId INT
			  , @intMinSalesOrderDetailId INT

		INSERT INTO @tblItemsWithRecipe
		SELECT DISTINCT MIN(intSalesOrderDetailId), intRecipeId FROM #TempTable WHERE intRecipeId > 0 GROUP BY intRecipeId

		WHILE EXISTS (SELECT NULL FROM @tblItemsWithRecipe)
			BEGIN
				SELECT TOP 1 @intMinSalesOrderDetailId = MIN(intSalesOrderDetailId) FROM @tblItemsWithRecipe
				SELECT TOP 1 @intCurrentRecipeId = intRecipeId FROM @tblItemsWithRecipe WHERE intSalesOrderDetailId = @intMinSalesOrderDetailId

				WHILE EXISTS (SELECT NULL FROM #TempTable)
					BEGIN
						SELECT TOP 1 @intCurrentSalesOrderDetailId = MIN(intSalesOrderDetailId) FROM #TempTable WHERE intRecipeId IS NULL

						IF @intMinSalesOrderDetailId > @intCurrentSalesOrderDetailId
							BEGIN
								INSERT INTO @EntriesForInvoice
								SELECT * FROM #TempTable WHERE intSalesOrderDetailId = @intCurrentSalesOrderDetailId

								DELETE FROM #TempTable WHERE intSalesOrderDetailId = @intCurrentSalesOrderDetailId
								CONTINUE
							END
						ELSE
							BEGIN
								INSERT INTO @EntriesForInvoice
								SELECT * FROM #TempTable WHERE intRecipeId = @intCurrentRecipeId ORDER BY intRecipeItemId

								DELETE FROM #TempTable WHERE intRecipeId = @intCurrentRecipeId

								SET @intMinSalesOrderDetailId = 0
								BREAK
							END

						SET @intCurrentSalesOrderDetailId = 0						
					END

				DELETE FROM @tblItemsWithRecipe WHERE intRecipeId = @intCurrentRecipeId
			END

		INSERT INTO @EntriesForInvoice
		SELECT * FROM #TempTable ORDER BY intSalesOrderDetailId
	END
ELSE
	BEGIN
		INSERT INTO @EntriesForInvoice
		SELECT * FROM #TempTable ORDER BY intSalesOrderDetailId
	END

DROP TABLE #TempTable
	
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

	SET @ErrorMessage = 'Invoice(' + @InvoiceNumber + ') was already created for ' + @ShipmentNumber;

	RAISERROR(@ErrorMessage, 16, 1);
	RETURN 0;
END	
	
DECLARE	 @LineItemTaxEntries	LineItemTaxDetailStagingTable
		,@CurrentErrorMessage NVARCHAR(250)
		,@CreatedIvoices NVARCHAR(MAX)
		,@UpdatedIvoices NVARCHAR(MAX)	

INSERT INTO @LineItemTaxEntries(
	 [intDetailId]
	,[intDetailTaxId]
	,[intTaxGroupId]
	,[intTaxCodeId]
	,[intTaxClassId]
	,[strTaxableByOtherTaxes]
	,[strCalculationMethod]
	,[dblRate]
	,[dblBaseRate]
	,[intTaxAccountId]
	,[dblTax]
	,[dblAdjustedTax]
	,[ysnTaxAdjusted]
	,[ysnSeparateOnInvoice]
	,[ysnCheckoffTax]
	,[ysnTaxExempt]
	,[ysnTaxOnly]
	,[ysnInvalidSetup]
	,[strNotes]
	,[intTempDetailIdForTaxes]
)
SELECT
	 [intDetailId]				= NULL
	,[intDetailTaxId]			= NULL
	,[intTaxGroupId]			= SOSODT.[intTaxGroupId]
	,[intTaxCodeId]				= SOSODT.[intTaxCodeId]
	,[intTaxClassId]			= SOSODT.[intTaxClassId]
	,[strTaxableByOtherTaxes]	= SOSODT.[strTaxableByOtherTaxes] 
	,[strCalculationMethod]		= SOSODT.[strCalculationMethod]
	,[dblRate]					= SOSODT.[dblRate]
	,[dblBaseRate]				= SOSODT.[dblBaseRate]
	,[intTaxAccountId]			= SOSODT.[intSalesTaxAccountId]
	,[dblTax]					= SOSODT.[dblTax]
	,[dblAdjustedTax]			= SOSODT.[dblAdjustedTax]
	,[ysnTaxAdjusted]			= SOSODT.[ysnTaxAdjusted]
	,[ysnSeparateOnInvoice]		= SOSODT.[ysnSeparateOnInvoice]
	,[ysnCheckoffTax]			= SOSODT.[ysnCheckoffTax]
	,[ysnTaxExempt]				= SOSODT.[ysnTaxExempt]
	,[ysnTaxOnly]				= SOSODT.[ysnTaxOnly]
	,[ysnInvalidSetup]			= SOSODT.[ysnInvalidSetup]
	,[strNotes]					= SOSODT.[strNotes]
	,[intTempDetailIdForTaxes]	= EFI.[intTempDetailIdForTaxes]
FROM
	@UnsortedEntriesForInvoice  EFI
INNER JOIN
	tblSOSalesOrderDetailTax SOSODT
		ON EFI.[intTempDetailIdForTaxes] = SOSODT.[intSalesOrderDetailId] 
ORDER BY 
	 EFI.[intSalesOrderDetailId] ASC
	,SOSODT.[intSalesOrderDetailTaxId] ASC

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