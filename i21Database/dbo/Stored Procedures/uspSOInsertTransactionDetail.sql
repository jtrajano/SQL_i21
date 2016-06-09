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

	
	--if there are bundles, use the actual bundle details

	SELECT AR.* into #tmpDetail FROM tblARTransactionDetail AR inner join tblICItem I on  AR.intItemId = I.intItemId where  I.strType = 'Bundle' and I.ysnListBundleSeparately = 0 and AR.[intTransactionId] = @SalesOrderId 

	IF EXISTS (select top 1 1 from #tmpDetail)
	BEGIN
		delete from tblARTransactionDetail where intItemId in (select intItemId from #tmpDetail)

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
			select
				[intTransactionDetailId]
				,[intTransactionId]
				,[strTransactionType]
				,ICB.intBundleItemId
				,ICB.intItemUnitMeasureId
				,dbo.fnCalculateQtyBetweenUOM(T.[intItemUOMId], ICB.intItemUnitMeasureId, [dblQtyOrdered])
				,dbo.fnCalculateQtyBetweenUOM(T.[intItemUOMId], ICB.intItemUnitMeasureId, [dblQtyShipped])
				,[dblPrice]
				,[intInventoryShipmentItemId]
				,[intSalesOrderDetailId]
				,[intContractHeaderId]
				,[intContractDetailId]
				,T.[intConcurrencyId]
			from #tmpDetail T inner join tblICItemBundle ICB on T.intItemId = ICB.intItemId
	END


END
