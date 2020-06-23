CREATE PROCEDURE [dbo].[uspCTCreateInvoiceFromShipment]
	@ShipmentId				INT
    ,@UserId				INT
	,@intContractDetailId	INT
    ,@LogId					INT = NULL  OUTPUT
	,@NewInvoiceId			INT OUTPUT
AS

BEGIN TRY

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ZeroDecimal    DECIMAL(18,6)
		,@ZeroBit       DECIMAL(18,6)
		,@OneBit        DECIMAL(18,6)
        ,@DateOnly      DATETIME
		,@ErrMsg		NVARCHAR(MAX)
SELECT
     @ZeroDecimal   = 0.000000
    ,@ZeroBit       = CAST(0 AS BIT)	
    ,@OneBit        = CAST(1 AS BIT)
    ,@DateOnly      = CAST(GETDATE() AS DATE)		

DECLARE @EntriesForInvoice AS InvoiceStagingTable
DECLARE @TaxDetails AS LineItemTaxDetailStagingTable 

INSERT INTO @EntriesForInvoice
    ([intId]
    ,[strTransactionType]
    ,[strType]
    ,[strSourceTransaction]
    ,[intSourceId]
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
    ,[strComments]
    ,[intShipToLocationId]
    ,[intBillToLocationId]
    ,[ysnTemplate]
    ,[ysnForgiven]
    ,[ysnCalculated]
    ,[ysnSplitted]
    ,[ysnImpactInventory]
    ,[ysnFromProvisional]
    ,[ysnExported]
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
    ,[ysnUnPostAndUpdate]
    ,[ysnUpdateAvailableDiscount]
    ,[ysnAccrueLicense]
    ,[ysnInsertDetail]
    ,[intInvoiceDetailId]
    ,[intItemId]
    ,[intPrepayTypeId]
    ,[dblPrepayRate]
    ,[ysnRestricted]
    ,[ysnInventory]
    ,[strDocumentNumber]
    ,[strItemDescription]
    ,[intOrderUOMId]
    ,[dblQtyOrdered]
    ,[intItemUOMId]
    ,[intPriceUOMId]
    ,[dblContractPriceUOMQty]
    ,[dblQtyShipped]
    ,[dblDiscount]
    ,[dblItemTermDiscount]
    ,[strItemTermDiscountBy]
    ,[dblItemWeight]
    ,[intItemWeightUOMId]
    ,[dblPrice]
    ,[dblUnitPrice]
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
    ,[intDestinationWeightId]
    --,[strAddonDetailKey]
    --,[ysnAddonParent]
    --,[dblAddOnQuantity]
	)
SELECT
     [intId]                                = ISNULL(ARSI.[intInventoryShipmentItemId], ARSI.[intInventoryShipmentChargeId])
    ,[strTransactionType]                   = 'Invoice'
    ,[strType]                              = 'Standard'
    ,[strSourceTransaction]                 = 'Inventory Shipment'
    ,[intSourceId]                          = ICIS.[intInventoryShipmentId]
    ,[strSourceId]                          = ICIS.[strShipmentNumber]
    ,[intInvoiceId]                         = NULL
    ,[intEntityCustomerId]                  = ICIS.[intEntityCustomerId]
    ,[intEntityContactId]                   = NULL
    ,[intCompanyLocationId]                 = ICIS.[intShipFromLocationId]
    ,[intAccountId]                         = NULL
    ,[intCurrencyId]                        = ISNULL(ARSI.[intCurrencyId], ICIS.[intCurrencyId])
    ,[intTermId]                            = ARSI.[intTermID]
    ,[intPeriodsToAccrue]                   = 1
    ,[dtmDate]                              = (case when isnull(ICIS.[dtmShipDate],@DateOnly) > @DateOnly then ICIS.[dtmShipDate] else @DateOnly end)
    ,[dtmDueDate]                           = NULL
    ,[dtmShipDate]                          = ICIS.[dtmShipDate]
    ,[dtmPostDate]                          = (case when isnull(ICIS.[dtmShipDate],@DateOnly) > @DateOnly then ICIS.[dtmShipDate] else @DateOnly end)
    ,[intEntitySalespersonId]               = ch.intSalespersonId
    ,[intFreightTermId]                     = ICIS.[intFreightTermId]
    ,[intShipViaId]                         = ICIS.[intShipViaId]
    ,[intPaymentMethodId]                   = NULL
    ,[strInvoiceOriginId]                   = NULL
    ,[ysnUseOriginIdAsInvoiceNumber]        = @ZeroBit
    ,[strPONumber]                          = ''
    ,[strBOLNumber]                         = ICIS.[strBOLNumber]
    ,[strComments]                          = ICIS.[strShipmentNumber] + ' : '	+ ISNULL(ICIS.[strReferenceNumber], '')
    ,[intShipToLocationId]                  = ICIS.intShipToLocationId
    ,[intBillToLocationId]                  = NULL
    ,[ysnTemplate]                          = @ZeroBit
    ,[ysnForgiven]                          = @ZeroBit
    ,[ysnCalculated]                        = @ZeroBit
    ,[ysnSplitted]                          = @ZeroBit
    ,[ysnImpactInventory]                   = @OneBit
    ,[ysnFromProvisional]                   = @ZeroBit
    ,[ysnExported]                          = @ZeroBit
    ,[intPaymentId]                         = NULL
    ,[intSplitId]                           = NULL
    ,[intLoadDistributionHeaderId]          = NULL
    ,[strActualCostId]                      = NULL
    ,[intShipmentId]                        = NULL
    ,[intTransactionId]                     = NULL
    ,[intMeterReadingId]                    = NULL
    ,[intContractHeaderId]                  = ARSI.[intContractHeaderId]
    ,[intLoadId]                            = NULL
    ,[intOriginalInvoiceId]                 = NULL
    ,[intEntityId]                          = @UserId
    ,[intTruckDriverId]                     = NULL
    ,[intTruckDriverReferenceId]            = NULL
    ,[ysnResetDetails]                      = @ZeroBit
    ,[ysnRecap]                             = NULL
    ,[ysnPost]                              = NULL
    ,[ysnUnPostAndUpdate]                   = NULL
    ,[ysnUpdateAvailableDiscount]           = @ZeroBit
    ,[ysnAccrueLicense]                     = @ZeroBit
    ,[ysnInsertDetail]                      = @OneBit
    ,[intInvoiceDetailId]                   = NULL
    ,[intItemId]                            = ARSI.[intItemId]
    ,[intPrepayTypeId]                      = NULL
    ,[dblPrepayRate]                        = @ZeroDecimal
    ,[ysnRestricted]                        = @ZeroBit
    ,[ysnInventory]                         = NULL
    ,[strDocumentNumber]                    = ARSI.[strTransactionNumber]
    ,[strItemDescription]                   = ARSI.[strItemDescription]
    ,[intOrderUOMId]                        = ARSI.[intOrderUOMId]
    ,[dblQtyOrdered]                        = ICISI.dblQuantity
    ,[intItemUOMId]                         = ARSI.[intItemUOMId]
    ,[intPriceUOMId]                        = ARSI.[intPriceUOMId]
    ,[dblContractPriceUOMQty]               = ARSI.[dblPriceUOMQuantity]
    ,[dblQtyShipped]                        = ARSI.[dblQtyShipped]
    ,[dblDiscount]                          = ARSI.[dblDiscount]
    ,[dblItemTermDiscount]                  = @ZeroDecimal
    ,[strItemTermDiscountBy]                = ''
    ,[dblItemWeight]                        = ARSI.[dblWeight]
    ,[intItemWeightUOMId]                   = ARSI.[intWeightUOMId]
    ,[dblPrice]                             = ARSI.[dblShipmentUnitPrice]
    ,[dblUnitPrice]                         = ARSI.[dblUnitPrice]
    ,[strPricing]                           = ARSI.[strPricing]
    ,[strVFDDocumentNumber]                 = NULL
    ,[ysnRefreshPrice]                      = @ZeroBit
    ,[strMaintenanceType]                   = NULL
    ,[strFrequency]                         = NULL
    ,[intMaintenanceAccountId]              = NULL
    ,[dtmMaintenanceDate]                   = NULL
    ,[dblMaintenanceAmount]                 = @ZeroDecimal
    ,[intLicenseAccountId]                  = NULL
    ,[dblLicenseAmount]                     = @ZeroDecimal
    ,[intTaxGroupId]                        = ARSI.[intTaxGroupId] 
    ,[intStorageLocationId]                 = ARSI.[intStorageLocationId] 
    ,[intCompanyLocationSubLocationId]      = ARSI.[intSubLocationId]
    ,[ysnRecomputeTax]                      = (CASE WHEN ISNULL(ARSI.[intSalesOrderDetailId], 0) = 0 THEN 1 ELSE 0 END)	
    ,[intSCInvoiceId]                       = NULL
    ,[strSCInvoiceNumber]                   = NULL
    ,[intSCBudgetId]                        = NULL
    ,[strSCBudgetDescription]               = NULL
    ,[intInventoryShipmentItemId]           = ARSI.[intInventoryShipmentItemId] 
    ,[intInventoryShipmentChargeId]         = ARSI.[intInventoryShipmentChargeId]
    ,[strShipmentNumber]                    = ARSI.[strInventoryShipmentNumber]
    ,[intRecipeItemId]                      = ARSI.[intRecipeItemId]
    ,[intRecipeId]                          = ARSI.[intRecipeId]
    ,[intSubLocationId]                     = ARSI.[intSubLocationId]
    ,[intCostTypeId]                        = ARSI.[intCostTypeId]
    ,[intMarginById]                        = ARSI.[intMarginById]
    ,[intCommentTypeId]                     = ARSI.[intCommentTypeId]
    ,[dblMargin]                            = ARSI.[dblMargin]
    ,[dblRecipeQuantity]                    = ARSI.[dblRecipeQuantity]
    ,[intSalesOrderDetailId]                = ARSI.[intSalesOrderDetailId]
    ,[strSalesOrderNumber]                  = ARSI.[strSalesOrderNumber]
    ,[intContractDetailId]                  = ARSI.[intContractDetailId]
    ,[intShipmentPurchaseSalesContractId]   = NULL
    ,[dblShipmentGrossWt]                   = ARSI.[dblGrossWt]
    ,[dblShipmentTareWt]                    = ARSI.[dblTareWt]
    ,[dblShipmentNetWt]                     = ARSI.[dblNetWt]
    ,[intTicketId]                          = ARSI.[intTicketId]
    ,[intTicketHoursWorkedId]               = NULL
    ,[intDocumentMaintenanceId]             = NULL
    ,[intCustomerStorageId]                 = NULL
    ,[intSiteDetailId]                      = NULL
    ,[intLoadDetailId]                      = NULL
    ,[intLotId]                             = NULL
    ,[intOriginalInvoiceDetailId]           = NULL
    ,[intSiteId]                            = NULL
    ,[strBillingBy]                         = NULL
    ,[dblPercentFull]                       = NULL
    ,[dblNewMeterReading]                   = @ZeroDecimal
    ,[dblPreviousMeterReading]              = @ZeroDecimal
    ,[dblConversionFactor]                  = @ZeroDecimal
    ,[intPerformerId]                       = NULL
    ,[ysnLeaseBilling]                      = @ZeroBit
    ,[ysnVirtualMeterReading]               = @ZeroBit
    ,[ysnClearDetailTaxes]                  = @ZeroBit
    ,[intTempDetailIdForTaxes]              = ARSI.[intSalesOrderDetailId]
    ,[intCurrencyExchangeRateTypeId]        = ARSI.[intCurrencyExchangeRateTypeId]
    ,[intCurrencyExchangeRateId]            = ARSI.[intCurrencyExchangeRateId]
    ,[dblCurrencyExchangeRate]              = ARSI.[dblCurrencyExchangeRate]
    ,[intSubCurrencyId]                     = ARSI.[intSubCurrencyId]
    ,[dblSubCurrencyRate]                   = ARSI.[dblSubCurrencyRate]
    ,[ysnBlended]                           = ARSI.[ysnBlended]
    ,[strImportFormat]                      = NULL
    ,[dblCOGSAmount]                        = @ZeroDecimal
    ,[intConversionAccountId]               = NULL
    ,[intSalesAccountId]                    = NULL
    ,[intStorageScheduleTypeId]             = ARSI.[intStorageScheduleTypeId]
    ,[intDestinationGradeId]                = ARSI.[intDestinationGradeId]
    ,[intDestinationWeightId]               = ARSI.[intDestinationWeightId]
    --,[strAddonDetailKey]                    = NULL
    --,[ysnAddonParent]                       = @ZeroBit
    --,[dblAddOnQuantity]                     = @ZeroDecimal
FROM
    tblICInventoryShipment ICIS
INNER JOIN
	tblICInventoryShipmentItem ICISI on ICISI.intInventoryShipmentId = ICIS.intInventoryShipmentId and ICISI.intLineNo = @intContractDetailId
INNER JOIN
    vyuARShippedItems ARSI
        ON ICIS.[intInventoryShipmentId] = ARSI.[intInventoryShipmentId] and ARSI.intContractDetailId = ICISI.intLineNo
LEFT JOIN tblCTContractDetail CD ON CD.intContractDetailId = ARSI.intContractDetailId 
left join tblCTContractHeader ch on ch.intContractHeaderId = CD.intContractHeaderId
WHERE
ICIS.[intInventoryShipmentId] = @ShipmentId AND ARSI.strTransactionType = 'Inventory Shipment'
--AND (
--		(CD.intContractDetailId <> @intContractDetailId AND CD.dblCashPrice IS NOT NULL) 
--			OR 
--		CD.intContractDetailId = @intContractDetailId
--	)
--AND CD.intContractDetailId NOT IN 
--(
--	SELECT ISNULL(intContractDetailId,0) 
--	FROM tblARInvoiceDetail 
--	-- TICKET BASED IS EXEMPTED
--	WHERE intContractDetailId NOT IN
--	(
--		SELECT b.intContractDetailId
--		FROM tblCTPriceFixationTicket a 
--		INNER JOIN tblCTPriceFixation b on a.intPriceFixationId = b.intPriceFixationId AND a.intInventoryShipmentId IS NOT NULL
--	)
--)

INSERT INTO @TaxDetails(
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
	,[strNotes]					= SOSODT.[strNotes]
	,[intTempDetailIdForTaxes]	= EFI.[intTempDetailIdForTaxes]
FROM
	@EntriesForInvoice  EFI
INNER JOIN
	tblSOSalesOrderDetailTax SOSODT
		ON EFI.[intTempDetailIdForTaxes] = SOSODT.[intSalesOrderDetailId] 
ORDER BY 
	 EFI.[intSalesOrderDetailId] ASC
	,SOSODT.[intSalesOrderDetailTaxId] ASC
        

DECLARE @ErrorMessage NVARCHAR(250)

EXEC    [dbo].[uspARProcessInvoicesByBatch]
             @InvoiceEntries        = @EntriesForInvoice
             ,@LineItemTaxEntries   = @TaxDetails
             ,@UserId               = @UserId
             ,@GroupingOption       = 11
             ,@RaiseError           = 1
             ,@ErrorMessage         = @ErrorMessage OUTPUT
             ,@LogId                = @LogId OUTPUT
             
SELECT @NewInvoiceId = intInvoiceId FROM tblARInvoiceIntegrationLogDetail WHERE intIntegrationLogId = @LogId

exec uspCTUpdateSequenceStatus
     @intContractDetailId = @intContractDetailId
     ,@intUserId = @UserId

END	TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH