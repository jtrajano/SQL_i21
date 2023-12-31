﻿CREATE PROCEDURE [dbo].[uspARInsertTransactionDetail]
	@InvoiceId	INT
AS
BEGIN
	DECLARE @TransactionType AS NVARCHAR(25)
	SELECT @TransactionType = [strTransactionType] FROM tblARInvoice WHERE [intInvoiceId] = @InvoiceId
	DELETE FROM [tblARTransactionDetail] WHERE [intTransactionId] = @InvoiceId AND [strTransactionType] = @TransactionType

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
		 [intTransactionDetailId]				= [intInvoiceDetailId]
		,[intTransactionId]						= [intInvoiceId] 
		,[strTransactionType]					= @TransactionType
		,[intItemId]							= [intItemId] 
		,[intItemUOMId]							= [intItemUOMId] 
		,[dblQtyOrdered]						= [dblQtyOrdered] 
		,[dblQtyShipped]						= [dblQtyShipped] 
		,[dblPrice]								= [dblPrice]
		,[strPricing]							= [strPricing]
		,[intInventoryShipmentItemId]			= [intInventoryShipmentItemId]
		,[intSalesOrderDetailId]				= [intSalesOrderDetailId]
		,[intContractHeaderId]					= [intContractHeaderId]
		,[intContractDetailId]					= [intContractDetailId]
		,[intShipmentId]						= [intShipmentId]
        ,[intShipmentPurchaseSalesContractId]	= [intShipmentPurchaseSalesContractId]
        ,[intTicketId]							= [intTicketId]
        ,[intTicketHoursWorkedId]				= [intTicketHoursWorkedId]
		,[intOriginalInvoiceDetailId]			= [intOriginalInvoiceDetailId]
        ,[intSiteId]							= [intSiteId]
		,[intCompanyLocationSubLocationId]		= [intCompanyLocationSubLocationId]
		,[intStorageLocationId]					= [intStorageLocationId]
		,[intOwnershipTypeId]					= NULL

	FROM
		[tblARInvoiceDetail]
	WHERE
		[intInvoiceId] = @InvoiceId
	
END
