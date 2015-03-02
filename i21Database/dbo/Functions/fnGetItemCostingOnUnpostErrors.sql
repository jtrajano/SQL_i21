/**
* This function will centralize the validation for each items. This is used prior to unposting a transaction. 
* 
* Sample usage: 
*
*	SELECT	B.*
*	FROM	tblICItemLocation A CROSS APPLY dbo.fnGetItemCostingOnUnpostErrors(A.intItemId, A.intItemLocationId, A.intItemUOMId, A.dblQty) B
* 
*/
CREATE FUNCTION fnGetItemCostingOnUnpostErrors (@intItemId AS INT, @intItemLocationId AS INT, @intItemUOMId AS INT, @intSubLocationId AS INT, @intStorageLocationId AS INT, @dblQty AS NUMERIC(18,6) = 0, @intLotId AS INT)
RETURNS TABLE 
AS
RETURN (
	
	SELECT * FROM (
		SELECT	intItemId = @intItemId
				,intItemLocationId = @intItemLocationId
				,strText = FORMATMESSAGE(50029)
				,intErrorCode = 50029
		WHERE	EXISTS (
					SELECT	TOP 1 1 
					FROM	dbo.tblICItem Item INNER JOIN dbo.tblICItemLocation Location
								ON Item.intItemId = Location.intItemId
							INNER JOIN dbo.tblICItemStockUOM StockUOM
								ON StockUOM.intItemId = Item.intItemId
								AND StockUOM.intItemLocationId = Location.intItemLocationId
								AND ISNULL(StockUOM.intSubLocationId, 0) = ISNULL(@intSubLocationId, 0)
								AND ISNULL(StockUOM.intStorageLocationId, 0) = ISNULL(@intStorageLocationId, 0)
					WHERE	Item.intItemId = @intItemId
							AND Location.intItemLocationId = @intItemLocationId
							AND StockUOM.intItemUOMId = @intItemUOMId
							AND ISNULL(@dblQty, 0) + StockUOM.dblOnHand  < 0
							AND Location.intAllowNegativeInventory = 3 -- Value 3 means "NO", Negative stock is NOT allowed. 					
				)

		-- Check for negative stocks at the lot table. 
		UNION ALL 
		SELECT	intItemId = @intItemId
				,intItemLocationId = @intItemLocationId
				,strText = FORMATMESSAGE(50029)
				,intErrorCode = 50029
		WHERE	EXISTS (
					SELECT	TOP 1 1 
					FROM	dbo.tblICItem Item INNER JOIN dbo.tblICItemLocation Location
								ON Item.intItemId = Location.intItemId
							INNER JOIN dbo.tblICLot Lot
								ON Lot.intItemLocationId = Location.intItemLocationId
					WHERE	Item.intItemId = @intItemId
							AND Location.intItemLocationId = @intItemLocationId
							AND Lot.intLotId = @intLotId
							AND ISNULL(@dblQty, 0) + Lot.dblOnHand < 0
							AND Location.intAllowNegativeInventory = 3 -- Value 3 means "NO", Negative stock is NOT allowed. 					
				)

	) AS Query		
)