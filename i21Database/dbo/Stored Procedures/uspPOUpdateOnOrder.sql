CREATE PROCEDURE [dbo].[uspPOUpdateOnOrder]
	@poId INT,
	@negate BIT
AS
BEGIN

	DECLARE @items ItemCostingTableType

	INSERT INTO @items
	SELECT
		[intItemId]				=	B.intItemId
		,[intItemLocationId]	=	B.intLocationId
		,[intItemUOMId]			=	B.intUnitOfMeasureId
		,[dtmDate]				=	A.dtmDate
		,[dblQty]				=	CASE WHEN @negate = 1 THEN B.dblQtyOrdered * -1 ELSE B.dblQtyOrdered END
		,1
		,B.dblCost
		,0
		,0
		,A.intCurrencyId
		,0
		,A.intPurchaseId
		,A.strPurchaseOrderNumber
		,6
		,0
		,B.intSubLocationId
		,B.intStorageLocationId
	FROM tblPOPurchase A
		INNER JOIN tblPOPurchaseDetail B ON A.intPurchaseId = B.intPurchaseId
	WHERE A.intPurchaseId = @poId

	EXEC uspICIncreaseOnOrderQty @items

END
