CREATE PROCEDURE [dbo].[uspSOUpdateCommitted]
	@SalesOrderId INT,
	@Negate BIT,
	@QuantityToPost NUMERIC (18, 6) = NULL
AS
BEGIN

	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	DECLARE @items ItemCostingTableType

	INSERT INTO @items (
		[intItemId]				
		,[intItemLocationId]	
		,[intItemUOMId]			
		,[dtmDate]				
		,[dblQty]				
		,[dblUOMQty]			
		,[dblCost]				
		,[dblValue]				
		,[dblSalesPrice]		
		,[intCurrencyId]		
		,[dblExchangeRate]		
		,[intTransactionId]	
		,[intTransactionDetailId]	
		,[strTransactionId]		
		,[intTransactionTypeId]	
		,[intLotId]				
		,[intSubLocationId]		
		,[intStorageLocationId]		
	)

	--Quantity/UOM Changed
	SELECT
		[intItemId]					=	Detail.intItemId
		,[intItemLocationId]		=	IST.intItemLocationId
		,[intItemUOMId]				=	Detail.intItemUOMId
		,[dtmDate]					=	Header.dtmDate
		,[dblQty]					=	(CASE WHEN @Negate = 1 THEN (Detail.dblQtyShipped * -1) ELSE (CASE WHEN @QuantityToPost IS NULL OR @QuantityToPost = 0 THEN ((Detail.dblQtyOrdered - Detail.dblQtyShipped) - (TD.dblQtyOrdered - TD.dblQtyShipped)) ELSE @QuantityToPost END) END)
		,[dblUOMQty]				=	ItemUOM.dblUnitQty
		,[dblCost]					=	IST.dblLastCost
		,[dblValue]					=	0
		,[dblSalesPrice]			=	Detail.dblPrice
		,[intCurrencyId]			=	Header.intCurrencyId
		,[dblExchangeRate]			=	0
		,[intTransactionId]			=	Header.intSalesOrderId
		,[intTransactionDetailId]	=	Detail.intSalesOrderDetailId
		,[strTransactionId]			=	Header.strSalesOrderNumber
		,[intTransactionTypeId]		=	7
		,[intLotId]					=	NULL
		,[intSubLocationId]			=	NULL
		,[intStorageLocationId]		=	NULL
	FROM 
		tblSOSalesOrderDetail Detail
	INNER JOIN
		tblSOSalesOrder Header
			ON Detail.intSalesOrderId = Header.intSalesOrderId
	INNER JOIN
		tblARTransactionDetail TD
			ON Detail.intSalesOrderDetailId = TD.intTransactionDetailId 
			AND Detail.intSalesOrderId = TD.intTransactionId 
			AND TD.strTransactionType = 'Order'
	INNER JOIN
		tblICItemUOM ItemUOM 
			ON ItemUOM.intItemUOMId = Detail.intItemUOMId
	LEFT OUTER JOIN
		vyuICGetItemStock IST
			ON Detail.intItemId = IST.intItemId 
			AND Header.intCompanyLocationId = IST.intLocationId 
	WHERE 
		Header.intSalesOrderId = @SalesOrderId
		AND Header.strTransactionType = 'Order'
		AND Detail.intItemId = TD.intItemId		
		AND (Detail.intItemUOMId <> TD.intItemUOMId OR ((Detail.dblQtyOrdered - Detail.dblQtyShipped) <> (TD.dblQtyOrdered - TD.dblQtyShipped)))

	UNION ALL

	--Item Changed
	SELECT
		[intItemId]					=	TD.intItemId
		,[intItemLocationId]		=	IST.intItemLocationId
		,[intItemUOMId]				=	TD.intItemUOMId
		,[dtmDate]					=	Header.dtmDate
		,[dblQty]					=	(TD.dblQtyOrdered - TD.dblQtyShipped) * -1
		,[dblUOMQty]				=	ItemUOM.dblUnitQty
		,[dblCost]					=	IST.dblLastCost
		,[dblValue]					=	0
		,[dblSalesPrice]			=	TD.dblPrice
		,[intCurrencyId]			=	Header.intCurrencyId
		,[dblExchangeRate]			=	0
		,[intTransactionId]			=	Header.intSalesOrderId
		,[intTransactionDetailId]	=	TD.intSalesOrderDetailId
		,[strTransactionId]			=	Header.strSalesOrderNumber
		,[intTransactionTypeId]		=	7
		,[intLotId]					=	NULL
		,[intSubLocationId]			=	NULL
		,[intStorageLocationId]		=	NULL
	FROM 
		tblSOSalesOrderDetail Detail
	INNER JOIN
		tblSOSalesOrder Header
			ON Detail.intSalesOrderId = Header.intSalesOrderId
	INNER JOIN
		tblARTransactionDetail TD
			ON Detail.intSalesOrderDetailId = TD.intTransactionDetailId 
			AND Detail.intSalesOrderId = TD.intTransactionId 
			AND TD.strTransactionType = 'Order'
	INNER JOIN
		tblICItemUOM ItemUOM 
			ON ItemUOM.intItemUOMId = TD.intItemUOMId
	LEFT OUTER JOIN
		vyuICGetItemStock IST
			ON TD.intItemId = IST.intItemId 
			AND Header.intCompanyLocationId = IST.intLocationId 
	WHERE 
		Header.intSalesOrderId = @SalesOrderId
		AND Header.strTransactionType = 'Order'
		AND Detail.intItemId <> TD.intItemId				

	UNION ALL

	--Deleted Item
	SELECT
		[intItemId]					=	TD.intItemId
		,[intItemLocationId]		=	IST.intItemLocationId
		,[intItemUOMId]				=	TD.intItemUOMId
		,[dtmDate]					=	Header.dtmDate
		,[dblQty]					=	(TD.dblQtyOrdered - TD.dblQtyShipped) * -1
		,[dblUOMQty]				=	ItemUOM.dblUnitQty
		,[dblCost]					=	IST.dblLastCost
		,[dblValue]					=	0
		,[dblSalesPrice]			=	TD.dblPrice
		,[intCurrencyId]			=	Header.intCurrencyId
		,[dblExchangeRate]			=	0
		,[intTransactionId]			=	Header.intSalesOrderId
		,[intTransactionDetailId]	=	TD.intSalesOrderDetailId
		,[strTransactionId]			=	Header.strSalesOrderNumber
		,[intTransactionTypeId]		=	7
		,[intLotId]					=	NULL
		,[intSubLocationId]			=	NULL
		,[intStorageLocationId]		=	NULL
	FROM 
		tblARTransactionDetail TD
	INNER JOIN
		tblSOSalesOrder Header
			ON TD.intTransactionId = Header.intSalesOrderId							
	INNER JOIN
		tblICItemUOM ItemUOM 
			ON ItemUOM.intItemUOMId = TD.intItemUOMId
	LEFT OUTER JOIN
		vyuICGetItemStock IST
			ON TD.intItemId = IST.intItemId 
			AND Header.intCompanyLocationId = IST.intLocationId 
	WHERE 
		TD.intTransactionId = @SalesOrderId
		AND TD.strTransactionType = 'Order'
		AND (TD.intInventoryShipmentItemId IS NULL OR TD.intInventoryShipmentItemId = 0)
		AND TD.intTransactionDetailId NOT IN (SELECT intSalesOrderDetailId FROM tblSOSalesOrderDetail WHERE intSalesOrderId = @SalesOrderId)
		
	UNION ALL	
		
	--Added Item
	SELECT
		[intItemId]					=	Detail.intItemId
		,[intItemLocationId]		=	IST.intItemLocationId
		,[intItemUOMId]				=	Detail.intItemUOMId
		,[dtmDate]					=	Header.dtmDate
		,[dblQty]					=	ISNULL(dbo.fnCalculateQtyBetweenUOM(ISHI.intItemUOMId, Detail.intItemUOMId, ISHI.dblQuantity),(Detail.dblQtyOrdered - Detail.dblQtyShipped))
		,[dblUOMQty]				=	ItemUOM.dblUnitQty
		,[dblCost]					=	IST.dblLastCost
		,[dblValue]					=	0
		,[dblSalesPrice]			=	Detail.dblPrice 
		,[intCurrencyId]			=	Header.intCurrencyId
		,[dblExchangeRate]			=	0
		,[intTransactionId]			=	Header.intSalesOrderId
		,[intTransactionDetailId]	=	Detail.intSalesOrderDetailId
		,[strTransactionId]			=	Header.strSalesOrderNumber
		,[intTransactionTypeId]		=	7
		,[intLotId]					=	NULL
		,[intSubLocationId]			=	NULL
		,[intStorageLocationId]		=	NULL
	FROM 
		tblSOSalesOrderDetail Detail
	INNER JOIN
		tblSOSalesOrder Header
			ON Detail.intSalesOrderId = Header.intSalesOrderId							
	INNER JOIN
		tblICItemUOM ItemUOM 
			ON ItemUOM.intItemUOMId = Detail.intItemUOMId
	LEFT OUTER JOIN
		vyuICGetItemStock IST
			ON Detail.intItemId = IST.intItemId 
			AND Header.intCompanyLocationId = IST.intLocationId 
	LEFT JOIN 
		tblICInventoryShipmentItem ISHI 
			ON Detail.intSalesOrderDetailId = ISHI.intLineNo
	WHERE 
		Detail.intSalesOrderId = @SalesOrderId
		AND Header.strTransactionType = 'Order'
		AND Detail.intSalesOrderDetailId NOT IN (SELECT intTransactionDetailId FROM tblARTransactionDetail WHERE intTransactionId = @SalesOrderId AND strTransactionType = 'Order')	
		
	UPDATE
		@items
	SET
		dblQty = dblQty * (CASE WHEN @Negate = 1 THEN -1 ELSE 1 END)	


	EXEC uspICIncreaseOrderCommitted @items

END
GO