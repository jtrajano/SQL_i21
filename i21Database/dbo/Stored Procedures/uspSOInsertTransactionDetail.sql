CREATE PROCEDURE [dbo].[uspSOInsertTransactionDetail]
	@SalesOrderId	INT
AS
BEGIN

	DELETE FROM [tblARTransactionDetail] WHERE [intTransactionId] = @SalesOrderId AND [strTransactionType] = 'Order'

	INSERT INTO [tblARTransactionDetail](
		 [intTransactionDetailId]
		,[intTransactionId]
		,[strTransactionType]
		,[strTransactionStatus]
		,[intItemId]
		,[intItemUOMId]
		,[dblQtyOrdered]
		,[dblQtyShipped]
		,[dblPrice]
		,[intInventoryShipmentItemId]
		,[intSalesOrderDetailId]
		,[intContractHeaderId]
		,[intContractDetailId]
		,[intConcurrencyId])
	SELECT
		 [intTransactionDetailId]			= SOD.[intSalesOrderDetailId]
		,[intTransactionId]					= SOD.[intSalesOrderId]
		,[strTransactionType]				= 'Order'
		,[strTransactionStatus]				= SO.[strOrderStatus]
		,[intItemId]						= SOD.[intItemId] 
		,[intItemUOMId]						= SOD.[intItemUOMId] 
		,[dblQtyOrdered]					= SOD.[dblQtyOrdered] 
		,[dblQtyShipped]					= SOD.[dblQtyShipped] 
		,[dblPrice]							= SOD.[dblPrice]
		,[intInventoryShipmentItemId]		= NULL
		,[intSalesOrderDetailId]			= NULL
		,[intContractHeaderId]				= SOD.[intContractHeaderId]
		,[intContractDetailId]				= SOD.[intContractDetailId]
		,[intConcurrencyId]					= 1
	FROM
		[tblSOSalesOrderDetail] SOD
	INNER JOIN
		[tblSOSalesOrder] SO
			ON SOD.[intSalesOrderId] = SO.[intSalesOrderId] 
	WHERE
		SOD.[intSalesOrderId] = @SalesOrderId
	
END
