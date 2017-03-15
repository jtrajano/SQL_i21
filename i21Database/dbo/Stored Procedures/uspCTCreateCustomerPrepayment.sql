CREATE PROCEDURE [dbo].[uspCTCreateCustomerPrepayment]
	 @ContractHeaderId	INT
	,@UserId			INT
	,@NewInvoiceId		INT	= NULL OUTPUT			
AS

BEGIN

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE  @ZeroDecimal		DECIMAL(18,6)
		,@DateOnly			DATETIME
		,@InvoiceId			INT
		,@InvoiceNumber		NVARCHAR(25) 
		,@ContractNumber	NVARCHAR(25) 

SELECT
	 @ZeroDecimal	= 0.000000	
	,@DateOnly		= CAST(GETDATE() AS DATE)

		
DECLARE @EntriesForInvoice AS InvoiceIntegrationStagingTable		

INSERT INTO @EntriesForInvoice
	([strSourceTransaction]
	,[intSourceId]
	,[strSourceId]
	,[intInvoiceId]
	,[strTransactionType]
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
	,[intCompanyLocationSubLocationId]
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
	)
SELECT
	 [strSourceTransaction]					= 'Sales Contract'
	,[intSourceId]							= CTCHV.[intContractHeaderId]
	,[strSourceId]							= CTCHV.[strContractNumber] 
	,[intInvoiceId]							= AR.[intInvoiceId]
	,[strTransactionType]					= 'Prepayment'
	,[intEntityCustomerId]					= CTCHV.[intEntityId] 
	,[intCompanyLocationId]					= CTCDV.[intCompanyLocationId] 
	,[intCurrencyId]						= CTCDV.[intCurrencyId] 
	,[intTermId]							= CTCDV.[intTermId] 
	,[intPeriodsToAccrue]					= 1
	,[dtmDate]								= CTCDV.[dtmContractDate] 
	,[dtmDueDate]							= NULL 
	,[dtmShipDate]							= NULL 
	,[intEntitySalespersonId]				= CTCDV.[intSalespersonId]  
	,[intFreightTermId]						= CTCDV.[intFreightTermId] 
	,[intShipViaId]							= CTCDV.[intShipViaId]
	,[intPaymentMethodId]					= NULL 
	,[strInvoiceOriginId]					= NULL 
	,[strPONumber]							= NULL 
	,[strBOLNumber]							= NULL 
	,[strDeliverPickup]						= NULL 
	,[strComments]							= CTCHV.[strContractNumber] 
	,[intShipToLocationId]					= NULL 
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
	,[ysnPost]								= NULL
																																																		
	,[intInvoiceDetailId]					= AR.[intInvoiceDetailId] 
	,[intItemId]							= CTCDV.[intItemId] 
	,[ysnInventory]							= NULL
	,[strDocumentNumber]					= CTCDV.[strContractNumber]  
	,[strItemDescription]					= CTCDV.[strItemDescription]
	,[intOrderUOMId]						= CTCDV.[intItemUOMId] 
	,[dblQtyOrdered]						= CTCDV.[dblDetailQuantity]
	,[intItemUOMId]							= CTCDV.[intItemUOMId] 
	,[dblQtyShipped]						= CTCDV.[dblDetailQuantity]
	,[dblDiscount]							= @ZeroDecimal 
	,[dblItemWeight]						= @ZeroDecimal 
	,[intItemWeightUOMId]					= NULL
	,[dblPrice]								= CTCDV.[dblCashPrice] 
	,[strPricing]							= 'Contracts'
	,[ysnRefreshPrice]						= 0
	,[strMaintenanceType]					= NULL
	,[strFrequency]							= NULL
	,[dtmMaintenanceDate]					= NULL
	,[dblMaintenanceAmount]					= @ZeroDecimal 
	,[dblLicenseAmount]						= @ZeroDecimal
	,[intTaxGroupId]						= NULL
	,[intStorageLocationId]					= CTCDV.[intStorageLocationId] 
	,[intCompanyLocationSubLocationId]		= NULL
	,[ysnRecomputeTax]						= 0
	,[intSCInvoiceId]						= NULL
	,[strSCInvoiceNumber]					= NULL
	,[intSCBudgetId]						= NULL
	,[strSCBudgetDescription]				= NULL
	,[intInventoryShipmentItemId]			= NULL
	,[strShipmentNumber]					= NULL
	,[intSalesOrderDetailId]				= NULL
	,[strSalesOrderNumber]					= NULL 
	,[intContractHeaderId]					= CTCHV.[intContractHeaderId] 
	,[intContractDetailId]					= CTCDV.[intContractDetailId] 
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
FROM
	vyuCTContractDetailView CTCDV
INNER JOIN
	vyuCTContractHeaderView CTCHV
		ON CTCDV.[intContractHeaderId] = CTCHV.[intContractHeaderId]
LEFT OUTER JOIN
	(
		SELECT
			 ARID.[intInvoiceDetailId] 
			,ARID.[intContractDetailId]
			,ARI.[intInvoiceId]
			,ARI.[intContractHeaderId]  
		FROM
			tblARInvoiceDetail ARID
		INNER JOIN
			tblARInvoice ARI
				ON ARID.[intInvoiceId] = ARI.[intInvoiceId] 
	) AR
		ON CTCDV.[intContractDetailId] = AR.[intContractDetailId]
		AND CTCHV.[intContractHeaderId] = AR.[intContractHeaderId] 
WHERE
	CTCHV.[intContractHeaderId] = @ContractHeaderId
	
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
