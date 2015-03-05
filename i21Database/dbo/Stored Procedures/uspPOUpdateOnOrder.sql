CREATE PROCEDURE [dbo].[uspPOUpdateOnOrder]
	@poId INT,
	@negate BIT
AS
BEGIN

	DECLARE @items ItemCostingTableType

	INSERT INTO @items
	SELECT
		[intItemId]				=	B.intItemId
		,[intItemLocationId]	=	ItemLocation.intItemLocationId
		,[intItemUOMId]			=	B.intUnitOfMeasureId
		,[dtmDate]				=	A.dtmDate
		,[dblQty]				=	CASE WHEN @negate = 1 THEN B.dblQtyOrdered * -1 ELSE B.dblQtyOrdered END
		,[dblUOMQty]			=	1
		,[dblCost]				=	B.dblCost
		,[dblValue]				=	0
		,[dblSalesPrice]		=	0
		,[intCurrencyId]		=	A.intCurrencyId
		,[dblExchangeRate]		=	0
		,[intTransactionId]		=	A.intPurchaseId
		,[strTransactionId]		=	A.strPurchaseOrderNumber
		,[intTransactionTypeId]	=	6
		,[intLotId]				=	0
		,[intSubLocationId]		=	B.intSubLocationId
		,[intStorageLocationId]	=	B.intStorageLocationId
	FROM tblPOPurchase A INNER JOIN tblICItemLocation ItemLocation
			ON A.intLocationId = ItemLocation.intLocationId
		INNER JOIN tblPOPurchaseDetail B ON A.intPurchaseId = B.intPurchaseId
	WHERE A.intPurchaseId = @poId

	EXEC uspICIncreaseOnOrderQty @items

END
