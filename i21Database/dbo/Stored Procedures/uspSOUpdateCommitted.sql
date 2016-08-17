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

	--Quantity Shipped Changed
	SELECT
		[intItemId]					=	Detail.intItemId
		,[intItemLocationId]		=	IST.intItemLocationId
		,[intItemUOMId]				=	Detail.intItemUOMId
		,[dtmDate]					=	Header.dtmDate
		,[dblQty]					=	@QuantityToPost ---Detail.dblQtyShipped - dbo.fnCalculateQtyBetweenUOM(TD.intItemUOMId, Detail.intItemUOMId, TD.dblQtyShipped)
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
		AND (Detail.intItemUOMId <> TD.intItemUOMId OR Detail.dblQtyShipped <> dbo.fnCalculateQtyBetweenUOM(TD.intItemUOMId, Detail.intItemUOMId, TD.dblQtyShipped))
		AND Header.strOrderStatus NOT IN ('Cancelled', 'Short Closed')

	UNION ALL

	--Quantity/UOM Changed
	SELECT
		[intItemId]					=	Detail.intItemId
		,[intItemLocationId]		=	IST.intItemLocationId
		,[intItemUOMId]				=	Detail.intItemUOMId
		,[dtmDate]					=	Header.dtmDate
		,[dblQty]					=	Detail.dblQtyOrdered - dbo.fnCalculateQtyBetweenUOM(TD.intItemUOMId, Detail.intItemUOMId, TD.dblQtyOrdered)
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
		AND (Detail.intItemUOMId <> TD.intItemUOMId OR Detail.dblQtyOrdered <> dbo.fnCalculateQtyBetweenUOM(TD.intItemUOMId, Detail.intItemUOMId, TD.dblQtyOrdered))
		AND Header.strOrderStatus NOT IN ('Cancelled', 'Short Closed')

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
		AND Header.strOrderStatus NOT IN ('Cancelled', 'Short Closed')

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
		AND TD.intTransactionDetailId NOT IN (SELECT intSalesOrderDetailId FROM tblSOSalesOrderDetail WHERE intSalesOrderId = @SalesOrderId)
		AND Header.strOrderStatus NOT IN ('Cancelled', 'Short Closed')
		
	UNION ALL	
		
	--Added Item
	SELECT
		[intItemId]					=	Detail.intItemId
		,[intItemLocationId]		=	IST.intItemLocationId
		,[intItemUOMId]				=	Detail.intItemUOMId
		,[dtmDate]					=	Header.dtmDate
		--,[dblQty]					=	ISNULL(dbo.fnCalculateQtyBetweenUOM(ISHI.intItemUOMId, Detail.intItemUOMId, ISHI.dblQuantity),(Detail.dblQtyOrdered - Detail.dblQtyShipped))
		,[dblQty]					=	(CASE WHEN ISNULL(dbo.fnCalculateQtyBetweenUOM(ISHI.intItemUOMId, Detail.intItemUOMId, ISHI.dblQuantity),0) > Detail.dblQtyOrdered THEN Detail.dblQtyOrdered ELSE ISNULL(dbo.fnCalculateQtyBetweenUOM(ISHI.intItemUOMId, Detail.intItemUOMId, ISHI.dblQuantity),(CASE WHEN Detail.dblQtyShipped > Detail.dblQtyOrdered THEN Detail.dblQtyOrdered ELSE Detail.dblQtyOrdered - Detail.dblQtyShipped END)) END)
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
		AND Header.strOrderStatus NOT IN ('Cancelled', 'Short Closed')


	UNION ALL

	--Cancelled & Short Closed
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
		AND Header.strOrderStatus <> TD.strTransactionStatus				
		AND Header.strOrderStatus IN ('Cancelled', 'Short Closed')


	UNION ALL

	--Short Closed to Partial
	SELECT
		[intItemId]					=	TD.intItemId
		,[intItemLocationId]		=	IST.intItemLocationId
		,[intItemUOMId]				=	TD.intItemUOMId
		,[dtmDate]					=	Header.dtmDate
		,[dblQty]					=	(TD.dblQtyOrdered - TD.dblQtyShipped)
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
		AND Header.strOrderStatus <> TD.strTransactionStatus				
		AND TD.strTransactionStatus = 'Short Closed'
		AND Header.strOrderStatus = 'Partial'
		
	UPDATE
		@items
	SET
		dblQty = dblQty * (CASE WHEN @Negate = 1 THEN -1 ELSE 1 END)	


	EXEC uspICIncreaseOrderCommitted @items

END
GO