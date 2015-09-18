CREATE PROCEDURE [dbo].[uspSOInsertTransactionDetail]
	@SalesOrderId	INT
AS
BEGIN

	DELETE FROM [tblARTransactionDetail] WHERE [intTransactionId] = @SalesOrderId AND [strTransactionType] = 'Order'

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
		 [intTransactionDetailId]		= [intSalesOrderDetailId]
		,[intTransactionId]				= [intSalesOrderId]
		,[strTransactionType]			= 'Order'
		,[intItemId]					= [intItemId] 
		,[intItemUOMId]					= [intItemUOMId] 
		,[dblQtyOrdered]				= [dblQtyOrdered] 
		,[dblQtyShipped]				= [dblQtyShipped] 
		,[dblPrice]						= [dblPrice]
		,[intInventoryShipmentItemId]	= NULL
		,[intSalesOrderDetailId]		= NULL
		,[intContractHeaderId]			= [intContractHeaderId]
		,[intContractDetailId]			= [intContractDetailId]
		,[intConcurrencyId]				= 1
	FROM
		[tblSOSalesOrderDetail]
	WHERE
		[intSalesOrderId] = @SalesOrderId
END
