
CREATE PROCEDURE [dbo].[uspSOUpdateCommitted]
	@SalesOrderId INT,
	@negate BIT
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
	SELECT
		[intItemId]					=	Detail.intItemId
		,[intItemLocationId]		=	IST.intItemLocationId
		,[intItemUOMId]				=	Detail.intItemUOMId
		,[dtmDate]					=	Header.dtmDate
		,[dblQty]					=	CASE WHEN @negate = 1 
											THEN 
												(Detail.dblQtyOrdered - Detail.dblQtyShipped) * -1
											ELSE 
												CASE WHEN Header.strOrderStatus IN ('Short Closed', 'Cancellled')
													THEN 0
													ELSE Detail.dblQtyOrdered - Detail.dblQtyShipped
													END
											END
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
		,[intStorageLocationId]		=	Detail.intStorageLocationId
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
	WHERE 
		Header.intSalesOrderId = @SalesOrderId	

	EXEC uspICIncreaseOrderCommitted @items

END
GO


