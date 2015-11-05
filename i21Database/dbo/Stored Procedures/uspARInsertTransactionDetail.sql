CREATE PROCEDURE [dbo].[uspARInsertTransactionDetail]
	@InvoiceId	INT
AS
BEGIN

	DELETE FROM [tblARTransactionDetail] WHERE [intTransactionId] = @InvoiceId AND [strTransactionType] = 'Invoice'

	INSERT INTO [tblARTransactionDetail]
	(
			[intTransactionDetailId]
           ,[intTransactionId]
           ,[strTransactionType]
           ,[intItemId]
           ,[intItemUOMId]
           ,[dblQtyOrdered]
           ,[dblQtyShipped]
           ,[dblPrice]
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
	)
	SELECT
		 [intTransactionDetailId]				= [intInvoiceDetailId] 
		,[intTransactionId]						= [intInvoiceId] 
		,[strTransactionType]					= 'Invoice'
		,[intItemId]							= [intItemId] 
		,[intItemUOMId]							= [intItemUOMId] 
		,[dblQtyOrdered]						= [dblQtyOrdered] 
		,[dblQtyShipped]						= [dblQtyShipped] 
		,[dblPrice]								= [dblPrice]
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

	FROM
		[tblARInvoiceDetail]
	WHERE
		[intInvoiceId] = @InvoiceId
END
