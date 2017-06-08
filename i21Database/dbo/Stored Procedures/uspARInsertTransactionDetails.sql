CREATE PROCEDURE [dbo].[uspARInsertTransactionDetails]
	@InvoiceIds		AS InvoiceId		READONLY
AS
BEGIN

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DELETE FROM [tblARTransactionDetail] WHERE EXISTS(SELECT NULL FROM @InvoiceIds II WHERE [tblARTransactionDetail].[intTransactionId] = II.[intHeaderId] AND  [tblARTransactionDetail].[strTransactionType] = II.[strTransactionType])

INSERT INTO [tblARTransactionDetail](
	 [intTransactionDetailId]
	,[intTransactionId]
	,[strTransactionType]
	,[intItemId]
	,[intItemUOMId]
	,[dblQtyOrdered]
	,[dblQtyShipped]
	,[dblPrice]
	,[strPricing]
	,[intInventoryShipmentItemId]
	,[intSalesOrderDetailId]
	,[intContractHeaderId]
	,[intContractDetailId]
	,[intShipmentId]
	,[intShipmentPurchaseSalesContractId]
	,[intTicketId]
	,[intTicketHoursWorkedId]
	,[intOriginalInvoiceDetailId]
	,[intSiteId]
	,[intCompanyLocationSubLocationId]
	,[intStorageLocationId]
	,[intOwnershipTypeId])
SELECT
	 [intTransactionDetailId]				= ARID.[intInvoiceDetailId]
	,[intTransactionId]						= ARID.[intInvoiceId] 
	,[strTransactionType]					= II.[strTransactionType]
	,[intItemId]							= ARID.[intItemId] 
	,[intItemUOMId]							= ARID.[intItemUOMId] 
	,[dblQtyOrdered]						= ARID.[dblQtyOrdered] 
	,[dblQtyShipped]						= ARID.[dblQtyShipped] 
	,[dblPrice]								= ARID.[dblPrice]
	,[strPricing]							= ARID.[strPricing]
	,[intInventoryShipmentItemId]			= ARID.[intInventoryShipmentItemId]
	,[intSalesOrderDetailId]				= ARID.[intSalesOrderDetailId]
	,[intContractHeaderId]					= ARID.[intContractHeaderId]
	,[intContractDetailId]					= ARID.[intContractDetailId]
	,[intShipmentId]						= ARID.[intShipmentId]
    ,[intShipmentPurchaseSalesContractId]	= ARID.[intShipmentPurchaseSalesContractId]
    ,[intTicketId]							= ARID.[intTicketId]
    ,[intTicketHoursWorkedId]				= ARID.[intTicketHoursWorkedId]
	,[intOriginalInvoiceDetailId]			= ARID.[intOriginalInvoiceDetailId]
    ,[intSiteId]							= ARID.[intSiteId]
	,[intCompanyLocationSubLocationId]		= ARID.[intCompanyLocationSubLocationId]
	,[intStorageLocationId]					= ARID.[intStorageLocationId]
	,[intOwnershipTypeId]					= NULL

FROM
	[tblARInvoiceDetail] ARID
INNER JOIN
	@InvoiceIds II
		ON ARID.[intInvoiceId] = II.[intHeaderId]
	
END

