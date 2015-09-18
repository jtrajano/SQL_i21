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
		,[intConcurrencyId]
	)
	SELECT
		 [intTransactionDetailId]		= [intInvoiceDetailId] 
		,[intTransactionId]				= [intInvoiceId] 
		,[strTransactionType]			= 'Invoice'
		,[intItemId]					= [intItemId] 
		,[intItemUOMId]					= [intItemUOMId] 
		,[dblQtyOrdered]				= [dblQtyOrdered] 
		,[dblQtyShipped]				= [dblQtyShipped] 
		,[dblPrice]						= [dblPrice]
		,[intInventoryShipmentItemId]	= [intInventoryShipmentItemId]
		,[intSalesOrderDetailId]		= [intSalesOrderDetailId]
		,[intContractHeaderId]			= [intContractHeaderId]
		,[intContractDetailId]			= [intContractDetailId]
		,[intConcurrencyId]				= 1
	FROM
		[tblARInvoiceDetail]
	WHERE
		[intInvoiceId] = @InvoiceId
END
