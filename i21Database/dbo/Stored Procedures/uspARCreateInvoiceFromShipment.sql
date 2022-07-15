﻿CREATE PROCEDURE [dbo].[uspARCreateInvoiceFromShipment]
	 @ShipmentId		   			AS INT
	,@UserId			   			AS INT
	,@NewInvoiceId		   			AS INT	= NULL OUTPUT		
	,@OnlyUseShipmentPrice 			AS BIT  = 0
	,@IgnoreNoAvailableItemError 	AS BIT  = 0
	,@dtmShipmentDate				AS DATETIME = NULL
	,@intScaleTicketId				AS INT = NULL
AS

BEGIN

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ZeroDecimal					DECIMAL(18,6) = 0 
	  , @DateOnly						DATETIME = CAST(GETDATE() AS DATE)
	  , @InvoiceId						INT = NULL
	  , @intExistingInvoiceId			INT = NULL
	  , @intShipToLocationId			INT = NULL
	  , @intContractShipToLocationId	INT = NULL
	  , @ShipmentNumber					NVARCHAR(100)
	  , @InvoiceNumber					NVARCHAR(25) = ''
	  , @strReferenceNumber 			NVARCHAR(100)
	  , @ysnHasPriceFixation			BIT = 0

SELECT TOP 1 @strReferenceNumber = strSalesOrderNumber FROM tblSOSalesOrder ORDER BY intSalesOrderId DESC
--SET @dtmShipmentDate			 = ISNULL(CAST(@dtmShipmentDate AS DATE), @DateOnly)

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
	,@Date						= ISNULL(@dtmShipmentDate, ICIS.[dtmShipDate])
	,@ShipDate					= ICIS.[dtmShipDate]
	,@PostDate					= ISNULL(@dtmShipmentDate, ICIS.[dtmShipDate])
	,@CalculatedDate			= ISNULL(@dtmShipmentDate, ICIS.[dtmShipDate])
	,@EntitySalespersonId		= ISNULL(CT.[intSalespersonId],ARC.[intSalespersonId])
	,@FreightTermId				= ICIS.[intFreightTermId]
	,@ShipViaId					= ICIS.[intShipViaId]
	,@PONumber					= SO.[strPONumber]
	,@BOLNumber					= ICIS.[strBOLNumber]
	,@Comments					= ICIS.[strShipmentNumber] + ' : '	+ ISNULL(ICIS.[strReferenceNumber], '')
	,@SalesOrderComments		= SO.strComments
	,@intShipToLocationId		= ICIS.intShipToLocationId
	,@SalesOrderId				= SO.intSalesOrderId
	,@StorageScheduleTypeId		= @StorageScheduleTypeId
FROM tblICInventoryShipment ICIS
INNER JOIN tblARCustomer ARC ON ICIS.[intEntityCustomerId] = ARC.[intEntityId] 
LEFT JOIN tblICInventoryShipmentItem ICISITEM ON ICIS.[intInventoryShipmentId] = ICISITEM.[intInventoryShipmentId]
LEFT JOIN tblCTContractHeader CT ON ICISITEM.[intOrderId] = CT.[intContractHeaderId]
LEFT OUTER JOIN tblSOSalesOrder SO ON SO.strSalesOrderNumber = @strReferenceNumber
								  AND ICIS.strReferenceNumber = @strReferenceNumber
WHERE ICIS.intInventoryShipmentId = @ShipmentId
	AND ((ISNULL(ICISITEM.[ysnAllowInvoice], 1) = 1 AND ICIS.[intSourceType] = 1)
		OR
		ICIS.[intSourceType] <> 1
		)

SET @Date = CAST(@Date AS DATE)
SET @ShipDate = CAST(@ShipDate AS DATE)
SET @PostDate = CAST(@PostDate AS DATE)

--VALIDATIONS
SELECT TOP 1 @InvoiceNumber = ARI.[strInvoiceNumber]
FROM tblARInvoiceDetail ARID 
INNER JOIN tblARInvoice ARI ON ARID.[intInvoiceId] = ARI.[intInvoiceId]
INNER JOIN tblICInventoryShipmentItem ICISI ON ARID.[intInventoryShipmentItemId] = ICISI.[intInventoryShipmentItemId]
WHERE ICISI.[intInventoryShipmentId] = @ShipmentId

IF ISNULL(@InvoiceNumber,'') <> ''
	BEGIN
		RAISERROR('There is already an existing Invoice(%s) for this shipment!', 16, 1,@InvoiceNumber);
		RETURN 0;
	END

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
	,[intItemContractHeaderId]
	,[intItemContractDetailId]
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
	,[intShipToLocationId]					= @intShipToLocationId 
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
	,[dblQtyOrdered]						= CASE WHEN ARSI.ysnDestinationWeightsAndGrades = 1 AND ARSI.dblDestinationQuantity > CTD.dblQuantity AND CTD.intPricingTypeId = 1 THEN CTD.dblQuantity  ELSE
											  (CASE WHEN ISNULL(ARSI.[intContractHeaderId], 0) = 0 AND ISNULL(ARSI.[intContractDetailId], 0) = 0 AND ISNULL(ARSI.[intItemContractHeaderId], 0) = 0 AND ISNULL(ARSI.[intItemContractDetailId], 0) = 0
											  THEN 0 
											  ELSE ARSI.[dblQtyOrdered] 
											  END)
											  END
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
	,[intItemContractHeaderId]				= ARSI.[intItemContractHeaderId] 
	,[intItemContractHeaderId]				= ARSI.[intItemContractDetailId] 
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
FROM vyuARShippedItems ARSI
LEFT JOIN(
 SELECT H.intPricingTypeId,D.intContractDetailId,D.dblQuantity  from tblCTContractHeader H
 INNER JOIN tblCTContractDetail D ON H.intContractHeaderId = D.intContractHeaderId
)CTD ON CTD.intContractDetailId =ARSI.intContractDetailId
WHERE ARSI.[strTransactionType] = 'Inventory Shipment'
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
	,[intShipToLocationId]					= @intShipToLocationId 
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
	,[intItemContractHeaderId]				= NULL
	,[intItemContractHeaderId]				= NULL
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
FROM tblICInventoryShipment ICIS
INNER JOIN tblSOSalesOrder SO ON SO.strSalesOrderNumber = @strReferenceNumber
							 AND ICIS.intEntityCustomerId = SO.intEntityCustomerId 
INNER JOIN tblSOSalesOrderDetail SOD ON SO.intSalesOrderId = SOD.intSalesOrderId 
								    AND SOD.intCommentTypeId IN (0,1,3)
									AND SOD.dblQtyOrdered = 0
WHERE ICIS.intInventoryShipmentId = @ShipmentId

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
	,[intShipToLocationId]					= @intShipToLocationId 
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
	,[intItemContractHeaderId]				= NULL
	,[intItemContractHeaderId]				= NULL
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

--TAX ENTRIES	
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
FROM @UnsortedEntriesForInvoice  EFI
INNER JOIN tblSOSalesOrderDetailTax SOSODT ON EFI.[intTempDetailIdForTaxes] = SOSODT.[intSalesOrderDetailId] 
ORDER BY EFI.[intSalesOrderDetailId] ASC
	   , SOSODT.[intSalesOrderDetailTaxId] ASC

--SCALE IN-TRANSIT TICKET
DECLARE @intScaleItemInTransitId	INT = NULL
	  , @dblScaleNetUnits			NUMERIC(18, 6) = 0
	  , @dblScaleContractUsed		NUMERIC(18, 6) = 0

SELECT TOP 1 @intScaleTicketId			= T.intTicketId
	       , @dblScaleNetUnits			= T.dblNetUnits
		   , @intScaleItemInTransitId	= T.intItemId
FROM tblSCTicket T 
WHERE T.intTicketId = @intScaleTicketId 
  AND T.ysnTicketApplied = 1 
  AND T.ysnTicketInTransit = 1

IF @intScaleTicketId IS NOT NULL
	BEGIN
		SELECT @dblScaleContractUsed = SUM(dblScheduleQty)  
		FROM tblSCTicketContractUsed 
		WHERE intTicketId = @intScaleTicketId
		  AND intContractDetailId IS NOT NULL
		  AND dblScheduleQty > 0

		IF @dblScaleNetUnits > @dblScaleContractUsed
			BEGIN
				UPDATE E
				SET dblQtyShipped = dblQtyShipped - @dblScaleContractUsed
				  , dblQtyOrdered = dblQtyShipped - @dblScaleContractUsed
				FROM @EntriesForInvoice E
				WHERE E.intTicketId = @intScaleTicketId
				  AND E.intContractDetailId IS NULL
				  AND E.intItemId = @intScaleItemInTransitId

				INSERT INTO @EntriesForInvoice (
					  strSourceTransaction
					, intSourceId
					, strSourceId
					, intEntityCustomerId
					, intCompanyLocationId
					, intCurrencyId
					, intPeriodsToAccrue
					, dtmDate
					, dtmShipDate
					, intEntitySalespersonId
					, intFreightTermId
					, strBOLNumber
					, strComments
					, intShipToLocationId
					, ysnTemplate
					, ysnForgiven
					, ysnCalculated
					, ysnSplitted
					, intContractHeaderId
					, intEntityId
					, ysnResetDetails
					, ysnRecap
					, ysnPost
					, intItemId
					, intTicketId
					, ysnInventory
					, strDocumentNumber
					, strItemDescription
					, intOrderUOMId
					, dblQtyOrdered
					, intItemUOMId
					, intPriceUOMId
					, dblContractPriceUOMQty
					, dblQtyShipped
					, dblDiscount
					, dblItemWeight
					, intItemWeightUOMId
					, dblPrice
					, dblUnitPrice
					, strPricing
					, ysnRefreshPrice
					, ysnRecomputeTax
					, intInventoryShipmentItemId
					, intInventoryShipmentChargeId
					, strShipmentNumber
					, strSalesOrderNumber
					, intContractDetailId
					, ysnClearDetailTaxes
					, dblSubCurrencyRate
					, intStorageLocationId
					, intCompanyLocationSubLocationId
					, intSubLocationId
				)
				SELECT strSourceTransaction
					, intSourceId
					, strSourceId
					, intEntityCustomerId
					, intCompanyLocationId			= E.intCompanyLocationId
					, intCurrencyId					= E.intCurrencyId
					, intPeriodsToAccrue
					, dtmDate
					, dtmShipDate
					, intEntitySalespersonId
					, intFreightTermId				= E.intFreightTermId
					, strBOLNumber	
					, strComments					= E.strComments
					, intShipToLocationId
					, ysnTemplate
					, ysnForgiven
					, ysnCalculated
					, ysnSplitted
					, intContractHeaderId			= CD.intContractHeaderId
					, intEntityId					= E.intEntityId
					, ysnResetDetails
					, ysnRecap
					, ysnPost
					, intItemId						= CD.intItemId
					, intTicketId					= TCU.intTicketId
					, ysnInventory
					, strDocumentNumber
					, strItemDescription
					, intOrderUOMId
					, dblQtyOrdered
					, intItemUOMId					= CD.intItemUOMId
					, intPriceUOMId
					, dblContractPriceUOMQty
					, dblQtyShipped					= TCU.dblScheduleQty
					, dblDiscount
					, dblItemWeight
					, intItemWeightUOMId
					, dblPrice						= CD.dblCashPrice
					, dblUnitPrice					= CD.dblCashPrice
					, strPricing
					, ysnRefreshPrice
					, ysnRecomputeTax
					, intInventoryShipmentItemId
					, intInventoryShipmentChargeId	= NULL
					, strShipmentNumber
					, strSalesOrderNumber
					, intContractDetailId			= TCU.intContractDetailId
					, ysnClearDetailTaxes
					, dblSubCurrencyRate
					, intStorageLocationId			= E.intStorageLocationId
					, intCompanyLocationSubLocationId
					, intSubLocationId				= E.intSubLocationId
				FROM tblSCTicketContractUsed TCU 
				INNER JOIN tblCTContractDetail CD ON TCU.intContractDetailId = CD.intContractDetailId
				CROSS APPLY (
					SELECT TOP 1 *
					FROM @EntriesForInvoice
				) E
				WHERE TCU.intTicketId = @intScaleTicketId
			END		
		ELSE 
			BEGIN
				INSERT INTO @EntriesForInvoice (
					  strSourceTransaction
					, intSourceId
					, strSourceId
					, intEntityCustomerId
					, intCompanyLocationId
					, intCurrencyId
					, intPeriodsToAccrue
					, dtmDate
					, dtmShipDate
					, intEntitySalespersonId
					, intFreightTermId
					, strBOLNumber
					, strComments
					, intShipToLocationId
					, ysnTemplate
					, ysnForgiven
					, ysnCalculated
					, ysnSplitted
					, intContractHeaderId
					, intEntityId
					, ysnResetDetails
					, ysnRecap
					, ysnPost
					, intItemId
					, intTicketId
					, ysnInventory
					, strDocumentNumber
					, strItemDescription
					, intOrderUOMId
					, dblQtyOrdered
					, intItemUOMId
					, intPriceUOMId
					, dblContractPriceUOMQty
					, dblQtyShipped
					, dblDiscount
					, dblItemWeight
					, intItemWeightUOMId
					, dblPrice
					, dblUnitPrice
					, strPricing
					, ysnRefreshPrice
					, ysnRecomputeTax
					, intInventoryShipmentItemId
					, intInventoryShipmentChargeId
					, strShipmentNumber
					, strSalesOrderNumber
					, intContractDetailId
					, ysnClearDetailTaxes
					, dblSubCurrencyRate
					, intStorageLocationId
					, intCompanyLocationSubLocationId
					, intSubLocationId
				)
				SELECT strSourceTransaction
					, intSourceId
					, strSourceId
					, intEntityCustomerId
					, intCompanyLocationId			= E.intCompanyLocationId
					, intCurrencyId					= E.intCurrencyId
					, intPeriodsToAccrue
					, dtmDate
					, dtmShipDate
					, intEntitySalespersonId
					, intFreightTermId				= E.intFreightTermId
					, strBOLNumber	
					, strComments					= E.strComments
					, intShipToLocationId
					, ysnTemplate
					, ysnForgiven
					, ysnCalculated
					, ysnSplitted
					, intContractHeaderId			= CD.intContractHeaderId
					, intEntityId					= E.intEntityId
					, ysnResetDetails
					, ysnRecap
					, ysnPost
					, intItemId						= CD.intItemId
					, intTicketId					= TCU.intTicketId
					, ysnInventory
					, strDocumentNumber
					, strItemDescription
					, intOrderUOMId
					, dblQtyOrdered
					, intItemUOMId					= CD.intItemUOMId
					, intPriceUOMId
					, dblContractPriceUOMQty
					, dblQtyShipped					= TCU.dblScheduleQty
					, dblDiscount
					, dblItemWeight
					, intItemWeightUOMId
					, dblPrice						= CD.dblCashPrice
					, dblUnitPrice					= CD.dblCashPrice
					, strPricing
					, ysnRefreshPrice
					, ysnRecomputeTax
					, intInventoryShipmentItemId	= CASE WHEN @dblScaleNetUnits = @dblScaleContractUsed THEN intInventoryShipmentItemId ELSE NULL END
					, intInventoryShipmentChargeId	= NULL
					, strShipmentNumber
					, strSalesOrderNumber
					, intContractDetailId			= TCU.intContractDetailId
					, ysnClearDetailTaxes
					, dblSubCurrencyRate
					, intStorageLocationId			= E.intStorageLocationId
					, intCompanyLocationSubLocationId
					, intSubLocationId				= E.intSubLocationId
				FROM tblSCTicketContractUsed TCU 
				INNER JOIN tblCTContractDetail CD ON TCU.intContractDetailId = CD.intContractDetailId
				CROSS APPLY (
					SELECT TOP 1 *
					FROM @EntriesForInvoice
				) E
				WHERE TCU.intTicketId = @intScaleTicketId

				IF @dblScaleNetUnits = @dblScaleContractUsed
					BEGIN
						DELETE E
						FROM @EntriesForInvoice E
						WHERE E.intTicketId = @intScaleTicketId
						  AND E.intContractDetailId IS NULL
						  AND E.intItemId = @intScaleItemInTransitId
					END
			END
	END

--GET DISTINCT SHIP TO FROM CONTRACT DETAIL
IF EXISTS (SELECT TOP 1 NULL FROM tblARCustomer WHERE ISNULL(strBatchInvoiceBy, '') <> '' AND intEntityId = @EntityCustomerId)
	BEGIN
		UPDATE IE
		SET intShipToLocationId 			= ISNULL(CD.intShipToId, @intShipToLocationId)
		, strComments						= ISNULL(IE.strComments, '') + ' Contract #' + ISNULL(CH.strContractNumber, '')
		, @intContractShipToLocationId	= ISNULL(CD.intShipToId, @intShipToLocationId)
		FROM @EntriesForInvoice IE
		INNER JOIN tblCTContractDetail CD ON IE.intContractDetailId = CD.intContractDetailId
		INNER JOIN tblCTContractHeader CH ON CD.intContractHeaderId = CH.intContractHeaderId
		WHERE IE.intContractDetailId IS NOT NULL
		AND ISNULL(CD.intShipToId, 0) <> @intShipToLocationId

		SET @intContractShipToLocationId = ISNULL(@intContractShipToLocationId, @intShipToLocationId) 
		SELECT @intExistingInvoiceId = dbo.fnARGetInvoiceForBatch(@EntityCustomerId, @intContractShipToLocationId)
	END


--GET INVENTORY SHIPMENT WITH PRICING CONTRACTS
IF(OBJECT_ID('tempdb..#FIXATION') IS NOT NULL)
BEGIN
	DROP TABLE #FIXATION
END

IF(OBJECT_ID('tempdb..#CONTRACTSPRICING') IS NOT NULL)
BEGIN
	DROP TABLE #CONTRACTSPRICING
END

IF(OBJECT_ID('tempdb..#CONTRACTSTOPRICE') IS NOT NULL)
BEGIN
	DROP TABLE #CONTRACTSTOPRICE
END

CREATE TABLE #FIXATION (
      intIdentity				INT
	, intContractHeaderId		INT
	, intContractDetailId		INT
	, ysnLoad					BIT
	, intPriceContractId		INT
	, intPriceFixationId		INT
	, intPriceFixationDetailId	INT
	, dblQuantity				NUMERIC(18, 6)
	, dblFinalPrice				NUMERIC(18, 6)
	, ysnProcessed				BIT DEFAULT ((0))
)

SELECT intInventoryShipmentItemId	= IE.intInventoryShipmentItemId
	 , intInventoryShipmentId		= ISI.intInventoryShipmentId
	 , intContractDetailId			= IE.intContractDetailId
	 , intContractHeaderId			= IE.intContractHeaderId
	 , intPriceFixationId			= PF.intPriceFixationId
	 , intInvoiceEntriesId			= IE.intId
	 , dtmInvoiceDate				= ISNULL(IE.dtmDate, @Date)
	 , dblQtyShipped				= IE.dblQtyShipped
	 , intTicketId					= IE.intTicketId
	 , ysnLoad						= ISNULL(CD.ysnLoad, CAST(0 AS BIT))
INTO #CONTRACTSPRICING
FROM @EntriesForInvoice IE
INNER JOIN tblICInventoryShipmentItem ISI ON IE.intInventoryShipmentItemId = ISI.intInventoryShipmentItemId AND IE.intContractDetailId = ISI.intLineNo
INNER JOIN tblCTContractHeader CD ON IE.intContractHeaderId = CD.intContractHeaderId
INNER JOIN tblCTPriceFixation PF ON IE.intContractDetailId = PF.intContractDetailId 
                                AND IE.intContractHeaderId = PF.intContractHeaderId
WHERE IE.intContractDetailId IS NOT NULL
  AND IE.intInventoryShipmentItemId IS NOT NULL
  AND IE.intInventoryShipmentChargeId IS NULL
  AND ISI.intInventoryShipmentId = @ShipmentId

--POPULATE PRICE FIXATION
IF EXISTS (SELECT TOP 1 NULL FROM #CONTRACTSPRICING)
	BEGIN
		SET @ysnHasPriceFixation = CAST(1 AS BIT)

		SELECT intContractHeaderId
			 , intContractDetailId
			 , dblQtyToPrice		= SUM(dblQtyShipped)
			 , ysnLoad
		INTO #CONTRACTSTOPRICE
		FROM #CONTRACTSPRICING
		GROUP BY intContractHeaderId, intContractDetailId, ysnLoad

		WHILE EXISTS (SELECT TOP 1 NULL FROM #CONTRACTSTOPRICE)
			BEGIN
				DECLARE @intContractHeaderToPriceId	INT = NULL
					, @intContractDetailToPriceId	INT = NULL
					, @dblQtyToPrice				NUMERIC(18, 6) = 0

				SELECT TOP 1 @intContractHeaderToPriceId = intContractHeaderId
						   , @intContractDetailToPriceId = intContractDetailId
						   , @dblQtyToPrice				 = CASE WHEN ysnLoad = 1 THEN 1 ELSE dblQtyToPrice END
				FROM #CONTRACTSTOPRICE

				INSERT INTO #FIXATION (
					  intIdentity
					, intContractHeaderId
					, intContractDetailId
					, ysnLoad
					, intPriceContractId
					, intPriceFixationId
					, intPriceFixationDetailId
					, dblQuantity
					, dblFinalPrice
				)
				EXEC dbo.uspCTGetContractPrice @intContractHeaderToPriceId, @intContractDetailToPriceId, @dblQtyToPrice, 'Invoice'

				DELETE FROM #CONTRACTSTOPRICE WHERE intContractDetailId = @intContractDetailToPriceId
			END

		WHILE EXISTS (SELECT TOP 1 NULL FROM #CONTRACTSPRICING)
			BEGIN
				DECLARE @dblQtyShipped					NUMERIC(18, 6) = 0
					  , @dblOriginalQtyShipped			NUMERIC(18, 6) = 0			  
					  , @intInvoiceEntriesId			INT = NULL
					  , @intPriceFixationId				INT = NULL
					  , @intContractDetailToDeleteId    INT = NULL
					  , @ysnLoad						BIT = 0
					  , @intContractDetailId			INT = NULL
					  , @intTicketId					INT = NULL
					  , @intInventoryShipmentId			INT = NULL

				SELECT TOP 1 @intInvoiceEntriesId			= intInvoiceEntriesId 
						   , @dblQtyShipped					= dblQtyShipped
						   , @dblOriginalQtyShipped			= dblQtyShipped				   
						   , @intPriceFixationId			= intPriceFixationId
						   , @intContractDetailToDeleteId	= intContractDetailId
						   , @ysnLoad						= ysnLoad
						   , @intContractDetailId			= intContractDetailId
						   , @intTicketId					= intTicketId
						   , @intInventoryShipmentId		= intInventoryShipmentId
				FROM #CONTRACTSPRICING 
				ORDER BY intInvoiceEntriesId

				IF NOT EXISTS(SELECT TOP 1 NULL FROM #FIXATION)
                    BEGIN
                        DELETE FROM @EntriesForInvoice 
                        WHERE intContractDetailId = @intContractDetailToDeleteId
                    END

				WHILE EXISTS (SELECT TOP 1 NULL FROM #FIXATION WHERE intPriceFixationId = @intPriceFixationId AND ISNULL(ysnProcessed, 0) = 0) AND @dblQtyShipped > 0
					BEGIN
						DECLARE @intPriceFixationDetailId		INT = NULL
							, @dblQuantity					NUMERIC(18, 6) = 0
							, @dblFinalPrice					NUMERIC(18, 6) = 0

						SELECT TOP 1 @intPriceFixationDetailId		= intPriceFixationDetailId
								   , @dblQuantity					= dblQuantity
								   , @dblFinalPrice					= dblFinalPrice
						FROM #FIXATION 
						WHERE intPriceFixationId = @intPriceFixationId
						AND ISNULL(ysnProcessed, 0) = 0
						ORDER BY intPriceFixationDetailId
						
						IF @dblOriginalQtyShipped = @dblQtyShipped AND @dblQuantity > 0
							BEGIN
								IF @dblQtyShipped > @dblQuantity AND @ysnLoad = 0
									BEGIN
										UPDATE @EntriesForInvoice
										SET dblQtyShipped	= @dblQuantity
										WHERE intId = @intInvoiceEntriesId

										UPDATE E
										SET dblPrice		= dbo.fnSCCalculateDiscount(E.intTicketId, intTicketDiscountId, @dblQuantity, intItemUOMId, 0) * -1
										  , dblUnitPrice	= dbo.fnSCCalculateDiscount(E.intTicketId, intTicketDiscountId, @dblQuantity, intItemUOMId, 0) * -1
										FROM @EntriesForInvoice E
										CROSS APPLY (
											SELECT QM.intTicketDiscountId
											FROM tblSCTicket SC
											INNER JOIN tblGRDiscountCrossReference GCR ON GCR.intDiscountId = SC.intDiscountId
											INNER JOIN tblGRDiscountSchedule GRDS ON GRDS.intDiscountScheduleId = GCR.intDiscountScheduleId AND GRDS.intCommodityId = SC.intCommodityId
											INNER JOIN tblGRDiscountScheduleCode GRDSC ON GRDSC.intDiscountScheduleId = GCR.intDiscountScheduleId 
											INNER JOIN tblQMTicketDiscount QM ON QM.intDiscountScheduleCodeId = GRDSC.intDiscountScheduleCodeId AND QM.strSourceType = 'Scale' AND QM.intTicketId = SC.intTicketId
											INNER JOIN tblICInventoryShipmentItem ICS ON ICS.intSourceId = SC.intTicketId
											INNER JOIN tblICInventoryShipmentCharge IC ON IC.intChargeId = GRDSC.intItemId AND IC.intInventoryShipmentId = ICS.intInventoryShipmentId
											WHERE SC.intTicketId = @intTicketId
											  AND ICS.intInventoryShipmentId = @intInventoryShipmentId
											  AND E.intItemId = IC.intChargeId
											GROUP BY SC.intTicketId, QM.intTicketDiscountId, IC.intCostUOMId, IC.intChargeId
										) SC
										WHERE intInventoryShipmentChargeId IS NOT NULL										
									END

								UPDATE @EntriesForInvoice
								SET dblPrice		= @dblFinalPrice
								  , dblUnitPrice	= @dblFinalPrice
								  , intPriceFixationDetailId	= @intPriceFixationDetailId
								WHERE intId = @intInvoiceEntriesId AND (intContractDetailId = @intContractDetailId AND ISNULL(intOrderUOMId, 0) <> 0)

								UPDATE @EntriesForInvoice
								SET dblQtyOrdered	= CASE WHEN @ysnLoad = 0 THEN dblQtyOrdered ELSE @dblOriginalQtyShipped END
								WHERE intId = @intInvoiceEntriesId

								SET @dblQtyShipped = @dblQtyShipped - @dblQuantity
							END
						ELSE IF @dblQuantity > 0 
							BEGIN
								IF @dblQuantity > @dblQtyShipped
									SET @dblQuantity = @dblQtyShipped

								INSERT INTO @EntriesForInvoice (
									strSourceTransaction
									, intSourceId
									, strSourceId
									, intEntityCustomerId
									, intCompanyLocationId
									, intCurrencyId
									, intPeriodsToAccrue
									, dtmDate
									, dtmShipDate
									, intEntitySalespersonId
									, intFreightTermId
									, strBOLNumber
									, strComments
									, intShipToLocationId
									, ysnTemplate
									, ysnForgiven
									, ysnCalculated
									, ysnSplitted
									, intContractHeaderId
									, intEntityId
									, ysnResetDetails
									, ysnRecap
									, ysnPost
									, intItemId
									, intTicketId
									, ysnInventory
									, strDocumentNumber
									, strItemDescription
									, intOrderUOMId
									, dblQtyOrdered
									, intItemUOMId
									, intPriceUOMId
									, dblContractPriceUOMQty
									, dblQtyShipped
									, dblDiscount
									, dblItemWeight
									, intItemWeightUOMId
									, dblPrice
									, dblUnitPrice
									, strPricing
									, ysnRefreshPrice
									, ysnRecomputeTax
									, intInventoryShipmentItemId
									, intInventoryShipmentChargeId
									, strShipmentNumber
									, strSalesOrderNumber
									, intContractDetailId
									, ysnClearDetailTaxes
									, dblSubCurrencyRate
									, intStorageLocationId
									, intCompanyLocationSubLocationId
									, intSubLocationId
									, intPriceFixationDetailId
								)
								SELECT strSourceTransaction
									, intSourceId
									, strSourceId
									, intEntityCustomerId
									, intCompanyLocationId
									, intCurrencyId
									, intPeriodsToAccrue
									, dtmDate
									, dtmShipDate
									, intEntitySalespersonId
									, intFreightTermId
									, strBOLNumber
									, strComments
									, intShipToLocationId
									, ysnTemplate
									, ysnForgiven
									, ysnCalculated
									, ysnSplitted
									, intContractHeaderId
									, intEntityId
									, ysnResetDetails
									, ysnRecap
									, ysnPost
									, intItemId
									, intTicketId
									, ysnInventory
									, strDocumentNumber
									, strItemDescription
									, intOrderUOMId
									, dblQtyOrdered
									, intItemUOMId
									, intPriceUOMId
									, dblContractPriceUOMQty
									, dblQtyShipped					= @dblQuantity
									, dblDiscount
									, dblItemWeight
									, intItemWeightUOMId
									, dblPrice						= @dblFinalPrice
									, dblUnitPrice					= @dblFinalPrice
									, strPricing
									, ysnRefreshPrice
									, ysnRecomputeTax
									, intInventoryShipmentItemId
									, intInventoryShipmentChargeId	= NULL
									, strShipmentNumber
									, strSalesOrderNumber
									, intContractDetailId
									, ysnClearDetailTaxes
									, dblSubCurrencyRate
									, intStorageLocationId
									, intCompanyLocationSubLocationId
									, intSubLocationId
									, intPriceFixationDetailId	= @intPriceFixationDetailId
								FROM @EntriesForInvoice
								WHERE intId = @intInvoiceEntriesId

								UNION ALL

								SELECT strSourceTransaction
									, intSourceId
									, strSourceId
									, intEntityCustomerId
									, intCompanyLocationId
									, intCurrencyId						= E.intCurrencyId
									, intPeriodsToAccrue
									, dtmDate
									, dtmShipDate
									, intEntitySalespersonId
									, intFreightTermId
									, strBOLNumber
									, strComments
									, intShipToLocationId
									, ysnTemplate
									, ysnForgiven
									, ysnCalculated
									, ysnSplitted
									, intContractHeaderId
									, intEntityId
									, ysnResetDetails
									, ysnRecap
									, ysnPost
									, intItemId							= C.intChargeId
									, intTicketId
									, ysnInventory
									, strDocumentNumber
									, strItemDescription				= I.strDescription
									, intOrderUOMId						= C.intCostUOMId
									, dblQtyOrdered						= 0
									, intItemUOMId						= C.intCostUOMId
									, intPriceUOMId						= C.intCostUOMId
									, dblContractPriceUOMQty
									, dblQtyShipped						= 1
									, dblDiscount
									, dblItemWeight
									, intItemWeightUOMId
									, dblPrice							= dbo.fnSCCalculateDiscount(E.intTicketId, SC.intTicketDiscountId, @dblQuantity, intItemUOMId, 0) * -1
									, dblUnitPrice						= dbo.fnSCCalculateDiscount(E.intTicketId, SC.intTicketDiscountId, @dblQuantity, intItemUOMId, 0) * -1
									, strPricing
									, ysnRefreshPrice
									, ysnRecomputeTax
									, intInventoryShipmentItemId		= NULL
									, intInventoryShipmentChargeId		= C.intInventoryShipmentChargeId
									, strShipmentNumber
									, strSalesOrderNumber
									, intContractDetailId				= E.intContractDetailId
									, ysnClearDetailTaxes
									, dblSubCurrencyRate
									, intStorageLocationId
									, intCompanyLocationSubLocationId
									, intSubLocationId
									, intPriceFixationDetailId			= NULL
								FROM (
									SELECT TOP 1 *
									FROM @EntriesForInvoice E
									WHERE E.intInventoryShipmentItemId IS NOT NULL
									  AND intId = @intInvoiceEntriesId
								) E
								CROSS APPLY (
									SELECT TOP 1 intInventoryShipmentChargeId
										       , intChargeId
											   , intCostUOMId
									FROM tblICInventoryShipmentCharge C 
									WHERE C.intInventoryShipmentId = @intInventoryShipmentId
									  AND C.ysnPrice = 1
								) C
								INNER JOIN tblICItem I ON C.intChargeId = I.intItemId
								CROSS APPLY (
									SELECT QM.intTicketDiscountId
									FROM tblSCTicket SC
									INNER JOIN tblGRDiscountCrossReference GCR ON GCR.intDiscountId = SC.intDiscountId
									INNER JOIN tblGRDiscountSchedule GRDS ON GRDS.intDiscountScheduleId = GCR.intDiscountScheduleId AND GRDS.intCommodityId = SC.intCommodityId
									INNER JOIN tblGRDiscountScheduleCode GRDSC ON GRDSC.intDiscountScheduleId = GCR.intDiscountScheduleId 
									INNER JOIN tblQMTicketDiscount QM ON QM.intDiscountScheduleCodeId = GRDSC.intDiscountScheduleCodeId AND QM.strSourceType = 'Scale' AND QM.intTicketId = SC.intTicketId
									INNER JOIN tblICInventoryShipmentItem ICS ON ICS.intSourceId = SC.intTicketId
									INNER JOIN tblICInventoryShipmentCharge IC ON IC.intChargeId = GRDSC.intItemId AND IC.intInventoryShipmentId = ICS.intInventoryShipmentId
									WHERE SC.intTicketId = @intTicketId
									  AND ICS.intInventoryShipmentId = @intInventoryShipmentId
									  AND C.intChargeId = IC.intChargeId
									GROUP BY SC.intTicketId, QM.intTicketDiscountId, IC.intCostUOMId, IC.intChargeId
								) SC

								SET @dblQtyShipped = @dblQtyShipped - @dblQuantity
							END
												
						UPDATE #FIXATION 
						SET ysnProcessed = CAST(1 AS BIT)
						WHERE intPriceFixationId = @intPriceFixationId
						AND intPriceFixationDetailId = @intPriceFixationDetailId
					END
				
				DELETE FROM #CONTRACTSPRICING WHERE intInvoiceEntriesId = @intInvoiceEntriesId
			END
	END

--CREATE INVOICE IF THERE's NONE
IF ISNULL(@intExistingInvoiceId, 0) = 0
	BEGIN
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
	END
ELSE
--INSERT TO EXISTING INVOICE
	BEGIN
		DECLARE @tblInvoiceDetailEntries	InvoiceStagingTable

			INSERT INTO @tblInvoiceDetailEntries (
				  intInvoiceDetailId
				, strSourceTransaction
				, intSourceId
				, strSourceId
				, intEntityCustomerId
				, intCompanyLocationId
				, dtmDate
				, strDocumentNumber
				, strShipmentNumber
				, intEntityId
				, intInvoiceId
				, intItemId
				, strItemDescription
				, strPricing
				, intOrderUOMId
				, dblQtyOrdered
				, intItemUOMId
				, intPriceUOMId
				, dblQtyShipped
				, dblPrice
				, dblUnitPrice
				, dblContractPriceUOMQty
				, intItemWeightUOMId
				, intContractDetailId
				, intContractHeaderId
				, intTicketId
				, intTaxGroupId
				, dblCurrencyExchangeRate
				, strAddonDetailKey
				, ysnAddonParent
				, intInventoryShipmentItemId
				, intInventoryShipmentChargeId
				, intStorageLocationId
				, intSubLocationId
				, intCompanyLocationSubLocationId
			)
			SELECT intInvoiceDetailId				= NULL
				, strSourceTransaction				= 'Direct'
				, intSourceId						= EI.intSourceId
				, strSourceId						= EI.strSourceId
				, intEntityCustomerId				= EI.intEntityCustomerId
				, intCompanyLocationId				= EI.intCompanyLocationId
				, dtmDate							= EI.dtmDate
				, strDocumentNumber					= EI.strSourceId
				, strShipmentNumber					= EI.strShipmentNumber
				, intEntityId						= EI.intEntityId
				, intInvoiceId						= @intExistingInvoiceId
				, intItemId							= EI.intItemId
				, strItemDescription				= EI.strItemDescription
				, strPricing						= 'Subsystem - Inventory Shipment'
				, intOrderUOMId						= EI.intOrderUOMId
				, dblQtyOrdered						= EI.dblQtyOrdered
				, intItemUOMId						= EI.intItemUOMId
				, intPriceUOMId						= EI.intPriceUOMId
				, dblQtyShipped						= EI.dblQtyShipped
				, dblPrice							= EI.dblPrice
				, dblUnitPrice						= EI.dblUnitPrice
				, dblContractPriceUOMQty			= EI.dblContractPriceUOMQty
				, intItemWeightUOMId				= EI.intItemWeightUOMId
				, intContractDetailId				= EI.intContractDetailId
				, intContractHeaderId				= EI.intContractHeaderId
				, intTicketId						= EI.intTicketId
				, intTaxGroupId						= NULL--SOD.intTaxGroupId
				, dblCurrencyExchangeRate			= EI.dblCurrencyExchangeRate
				, strAddonDetailKey					= EI.strAddonDetailKey
				, ysnAddonParent					= EI.ysnAddonParent
				, intInventoryShipmentItemId		= EI.intInventoryShipmentItemId
				, intInventoryShipmentChargeId		= EI.intInventoryShipmentChargeId
				, intStorageLocationId				= EI.intStorageLocationId
				, intSubLocationId					= EI.intSubLocationId
				, intCompanyLocationSubLocationId	= EI.intSubLocationId
			FROM @EntriesForInvoice EI

			EXEC dbo.uspARAddItemToInvoices @InvoiceEntries		= @tblInvoiceDetailEntries
									  	  , @IntegrationLogId	= NULL
									  	  , @UserId				= @UserId

			SET @NewInvoiceId = @intExistingInvoiceId

			EXEC dbo.uspARUpdateInvoiceIntegrations @intExistingInvoiceId, 0, @UserId
			EXEC dbo.uspARReComputeInvoiceTaxes @intExistingInvoiceId
	END

--LOG PRICE FIXATION
IF @ysnHasPriceFixation = 1
	BEGIN
		INSERT INTO tblCTPriceFixationDetailAPAR (
			  intPriceFixationDetailId
			, intInvoiceId
			, intInvoiceDetailId
			, intConcurrencyId
		)
		SELECT intPriceFixationDetailId = PRICE.intPriceFixationDetailId
		     , intInvoiceId				= ID.intInvoiceId
			 , intInvoiceDetailId		= ID.intInvoiceDetailId
			 , intConcurrencyId			= 1
		FROM tblARInvoiceDetail ID
		INNER JOIN #FIXATION PRICE ON ID.intContractDetailId = PRICE.intContractDetailId AND ID.intPriceFixationDetailId = PRICE.intPriceFixationDetailId
		WHERE ID.intInvoiceId = @NewInvoiceId
		  AND PRICE.ysnProcessed = 1
		  AND ID.intInventoryShipmentItemId IS NOT NULL
		  AND ID.intInventoryShipmentChargeId IS NULL
	END

RETURN @NewInvoiceId

END