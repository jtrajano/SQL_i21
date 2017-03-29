CREATE PROCEDURE [dbo].[uspARProcessPOSToInvoice]
	 @intPOSId			INT
	,@intEntityUserId	INT	
	,@strTransactionType NVARCHAR(25)
	,@ErrorMessage		NVARCHAR(250) OUTPUT
	,@CreatedIvoices	NVARCHAR(MAX)  = NULL OUTPUT
AS	

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF


DECLARE @EntriesForInvoice AS InvoiceIntegrationStagingTable

BEGIN TRANSACTION
INSERT INTO @EntriesForInvoice(
	 [strTransactionType]
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
	,[intCurrencyExchangeRateTypeId]
	,[intCurrencyExchangeRateId]
	,[dblCurrencyExchangeRate]
	,[intSubCurrencyId]
	,[dblSubCurrencyRate]
)
SELECT
	 [strTransactionType]					= @strTransactionType
	,[strSourceTransaction]					= 'POS'
	,[intSourceId]							= POS.intPOSId
	,[strSourceId]							= POS.strReceiptNumber
	,[intInvoiceId]							= NULL --NULL Value will create new invoice
	,[intEntityCustomerId]					= POS.intEntityCustomerId
	,[intCompanyLocationId]					= POS.intCompanyLocationId
	,[intCurrencyId]						= POS.intCurrencyId
	,[intTermId]							= isnull(Cus.intTermsId, Loc.intTermsId)--NULL --Check this one
	,[dtmDate]								= POS.dtmDate
	,[dtmDueDate]							= NULL
	,[dtmShipDate]							= POS.dtmDate
	,[intEntitySalespersonId]				= POS.intEntityUserId -- This is the Cashier
	,[intFreightTermId]						= NULL 
	,[intShipViaId]							= NULL 
	,[intPaymentMethodId]					= NULL
	,[strInvoiceOriginId]					= ''
	,[strPONumber]							= '' --Check this one
	,[strBOLNumber]							= ''
	,[strDeliverPickup]						= ''
	,[strComments]							= ''
	,[intShipToLocationId]					= NULL
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
	,[intTransactionId]						= 0 --cfTrans.intTransactionId
	,[intEntityId]							= POS.intEntityUserId
	,[ysnResetDetails]						= 0
	,[ysnPost]								= 1
	,[intInvoiceDetailId]					= (SELECT TOP 1 intInvoiceDetailId 
												FROM tblARInvoiceDetail 
												WHERE intInvoiceId = POS.intInvoiceId)
	,[intItemId]							= POSDetail.intItemId
	,[ysnInventory]							= 1
	,[strItemDescription]					= POSDetail.strItemDescription 
	,[intItemUOMId]							= POSDetail.intItemUOMId
	,[dblQtyOrdered]						= POSDetail.dblQuantity
	,[dblQtyShipped]						= POSDetail.dblQuantity 
	,[dblDiscount]							= POSDetail.dblDiscount
	,[dblPrice]								= POSDetail.dblPrice
	,[ysnRefreshPrice]						= 0
	,[strMaintenanceType]					= ''
    ,[strFrequency]							= ''
    ,[dtmMaintenanceDate]					= NULL
    ,[dblMaintenanceAmount]					= NULL
    ,[dblLicenseAmount]						= NULL
	,[intTaxGroupId]						= NULL--cfSiteItem.intTaxGroupId
	,[ysnRecomputeTax]						= 1 --To recompute the tax
	,[intSCInvoiceId]						= NULL
	,[strSCInvoiceNumber]					= ''
	,[intInventoryShipmentItemId]			= NULL
	,[strShipmentNumber]					= ''
	,[intSalesOrderDetailId]				= NULL
	,[strSalesOrderNumber]					= ''
	,[intContractHeaderId]					= NULL --ctContracts.intContractHeaderId
	,[intContractDetailId]					= NULL --ctContracts.intContractDetailId
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
	,[intTempDetailIdForTaxes]				= @intPOSId
	,[intCurrencyExchangeRateTypeId]		= NULL
	,[intCurrencyExchangeRateId]			= NULL
	,[dblCurrencyExchangeRate]				= 1.000000
	,[intSubCurrencyId]						= NULL
	,[dblSubCurrencyRate]					= 1.000000

FROM tblARPOS POS 
INNER JOIN tblARPOSDetail POSDetail ON POS.intPOSId = POSDetail.intPOSId
JOIN tblARCustomer Cus on Cus.[intEntityId] = POS.intEntityCustomerId
JOIN tblEMEntityLocation Loc on Loc.intEntityId = Cus.[intEntityId] and Loc.ysnDefaultLocation = 1
Where POS.intPOSId = @intPOSId

DECLARE @TaxDetails AS LineItemTaxDetailStagingTable 

DECLARE @UpdatedIvoices AS NVARCHAR(MAX)
EXEC [dbo].[uspARProcessInvoices]
		 @InvoiceEntries	= @EntriesForInvoice
		,@LineItemTaxEntries = @TaxDetails
		,@UserId			= @intEntityUserId
		,@GroupingOption	= 11
		,@RaiseError		= 1
		,@ErrorMessage		= @ErrorMessage OUTPUT
		,@CreatedIvoices	= @CreatedIvoices OUTPUT
		,@UpdatedIvoices	= @UpdatedIvoices OUTPUT


IF (@ErrorMessage IS NULL)
	BEGIN
		COMMIT TRANSACTION
	END
ELSE
	BEGIN
		ROLLBACK TRANSACTION
	END

IF (@CreatedIvoices IS NOT NULL AND @ErrorMessage IS NULL)
BEGIN
	UPDATE tblARPOS 
	SET intInvoiceId = @CreatedIvoices,
		ysnHold = 0
	WHERE intPOSId = @intPOSId
END