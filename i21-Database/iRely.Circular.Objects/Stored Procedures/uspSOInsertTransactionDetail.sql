CREATE PROCEDURE [dbo].[uspSOInsertTransactionDetail]
	@SalesOrderId	INT
AS
BEGIN

	DELETE FROM [tblARTransactionDetail] WHERE [intTransactionId] = @SalesOrderId AND [strTransactionType] IN ('Order', 'Quote')

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
		,[strPricing]
		,[intInventoryShipmentItemId]
		,[intSalesOrderDetailId]
		,[intContractHeaderId]
		,[intContractDetailId]
		,[intCompanyLocationSubLocationId]
		,[intStorageLocationId]
		,[intOwnershipTypeId]
		,[intConcurrencyId])
	SELECT
		 [intTransactionDetailId]			= SOD.[intSalesOrderDetailId]
		,[intTransactionId]					= SOD.[intSalesOrderId]
		,[strTransactionType]				= SO.[strTransactionType]
		,[strTransactionStatus]				= SO.[strOrderStatus]
		,[intItemId]						= SOD.[intItemId] 
		,[intItemUOMId]						= SOD.[intItemUOMId] 
		,[dblQtyOrdered]					= SOD.[dblQtyOrdered] 
		,[dblQtyShipped]					= SOD.[dblQtyShipped] 
		,[dblPrice]							= SOD.[dblPrice]
		,[strPricing]						= SOD.[strPricing]
		,[intInventoryShipmentItemId]		= NULL
		,[intSalesOrderDetailId]			= NULL
		,[intContractHeaderId]				= SOD.[intContractHeaderId]
		,[intContractDetailId]				= SOD.[intContractDetailId]		
		,[intCompanyLocationSubLocationId]	= SOD.[intSubLocationId]
		,[intStorageLocationId]				= SOD.[intStorageLocationId] 
		,[intOwnershipTypeId]				= NULL
		,[intConcurrencyId]					= 1
	FROM
		[tblSOSalesOrderDetail] SOD
	INNER JOIN
		[tblSOSalesOrder] SO
			ON SOD.[intSalesOrderId] = SO.[intSalesOrderId] 
	WHERE
		SOD.[intSalesOrderId] = @SalesOrderId
		AND SO.[strTransactionType] IN ('Order', 'Quote')
	
END
