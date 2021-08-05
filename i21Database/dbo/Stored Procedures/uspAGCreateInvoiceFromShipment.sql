
CREATE PROCEDURE [dbo].[uspAGCreateInvoiceFromShipment]
	 @ShipmentId		   			AS INT
	,@UserId			   			AS INT
	,@NewInvoiceId		   			AS INT	= NULL OUTPUT		
	,@OnlyUseShipmentPrice 			AS BIT  = 0
	,@IgnoreNoAvailableItemError 	AS BIT  = 0
	,@dtmShipmentDate				AS DATETIME = NULL
	,@intAGWorkOrderId AS INT 
AS

BEGIN

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @EntriesForInvoice AS InvoiceIntegrationStagingTable
DECLARE @LineItemTaxEntries	LineItemTaxDetailStagingTable
	  , @CurrentErrorMessage NVARCHAR(250)
	  , @CreatedIvoices NVARCHAR(MAX)
	  , @UpdatedIvoices NVARCHAR(MAX)	

INSERT INTO @EntriesForInvoice (
	 [strSourceTransaction]
	,[strTransactionType]
	,[strType]
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
	,[intShipToLocationId]
	,[intBillToLocationId]
	,[ysnSplitted]
	,[intSplitId]
	,[intEntityId]
	,[ysnPost]

	,[intInvoiceDetailId]
	,[intItemId]
	,[strDocumentNumber]
	,[strItemDescription]
	,[intOrderUOMId]
	,[dblQtyOrdered]
	,[intItemUOMId]
	,[intPriceUOMId]
	,[dblQtyShipped]
	,[dblPrice]
	,[dblUnitPrice]
	,[intStorageLocationId]
	,[intCompanyLocationSubLocationId]
	,[intInventoryShipmentItemId]
	,[intInventoryShipmentChargeId]
	,[strShipmentNumber]
	,[intSubLocationId]
	,[intTicketId]
	,[intDestinationGradeId]
	,[intDestinationWeightId]
	,[intCurrencyExchangeRateTypeId]
	,[intCurrencyExchangeRateId]
	,[dblCurrencyExchangeRate]
	,[intSubCurrencyId]
)
SELECT [strSourceTransaction]			= strTransactionType
	,[strTransactionType]				= 'Invoice'
	,[strType]							= strTransactionType
	,[intSourceId]						= intWorkOrderId
	,[strSourceId]						= strTransactionNumber
	,[intInvoiceId]						= NULL
	,[intEntityCustomerId]				= intEntityCustomerId
	,[intCompanyLocationId]				= intCompanyLocationId
	,[intCurrencyId]					= intCurrencyId
	,[intTermId]						= NULL
	,[dtmDate]							= dtmProcessDate
	,[dtmDueDate]						= dtmProcessDate
	,[dtmShipDate]						= dtmProcessDate
	,[intEntitySalespersonId]			= intEntitySalespersonId
	,[intFreightTermId]					= intFreightTermId
	,[intShipToLocationId]				= intShipToLocationId
	,[intBillToLocationId]				= NULL
	,[ysnSplitted]						= 0
	,[intSplitId]						= intSplitId
	,[intEntityId]						= @UserId
	,[ysnPost]							= 1

	,[intInvoiceDetailId]				= NULL
	,[intItemId]						= intItemId
	,[strDocumentNumber]				= strShipmentNumber
	,[strItemDescription]				= strItemDescription
	,[intOrderUOMId]					= intOrderUOMId
	,[dblQtyOrdered]					= dblQtyOrdered
	,[intItemUOMId]						= intItemUOMId
	,[intPriceUOMId]					= intPriceUOMId
	,[dblQtyShipped]					= dblQtyShipped
	,[dblPrice]							= dblPrice
	,[dblUnitPrice]						= dblPrice
	,[intStorageLocationId]				= intStorageLocationId
	,[intCompanyLocationSubLocationId]	= intSubLocationId
	,[intInventoryShipmentItemId]		= intInventoryShipmentItemId
	,[intInventoryShipmentChargeId]		= intInventoryShipmentChargeId
	,[strShipmentNumber]				= strShipmentNumber
	,[intSubLocationId]					= intSubLocationId
	,[intTicketId]						= intTicketId
	,[intDestinationGradeId]			= intDestinationGradeId
	,[intDestinationWeightId]			= intDestinationWeightId
	,[intCurrencyExchangeRateTypeId]	= intCurrencyExchangeRateTypeId
	,[intCurrencyExchangeRateId]		= intCurrencyExchangeRateId
	,[dblCurrencyExchangeRate]			= dblCurrencyExchangeRate
	,[intSubCurrencyId] 				= intSubCurrencyId
FROM vyuAGWorkOrderForInvoice
WHERE intWorkOrderId = @intAGWorkOrderId  
--WHERE intInventoryShipmentId = @ShipmentId
 
EXEC [dbo].[uspARProcessInvoices] @InvoiceEntries		= @EntriesForInvoice
								, @LineItemTaxEntries	= @LineItemTaxEntries
								, @UserId				= @UserId
								, @GroupingOption		= 11
								, @RaiseError			= 1
								, @ErrorMessage			= @CurrentErrorMessage	OUTPUT
								, @CreatedIvoices		= @CreatedIvoices		OUTPUT
								, @UpdatedIvoices		= @UpdatedIvoices		OUTPUT

SELECT TOP 1 @NewInvoiceId = intInvoiceId FROM tblARInvoice WHERE intInvoiceId IN (SELECT intID FROM fnGetRowsFromDelimitedValues(@CreatedIvoices))

END