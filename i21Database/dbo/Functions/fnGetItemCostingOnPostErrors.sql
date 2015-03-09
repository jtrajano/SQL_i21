/**
* This function will centralize the validation for each items. This is used prior to posting a transaction. 
* 
* Sample usage: 
*
*	SELECT	B.*
*	FROM	tblICItemLocation A CROSS APPLY dbo.fnGetItemCostingOnPostErrors(A.intItemId, A.intLocationId, A.intItemUOMId, A.dblQty) B
* 
*/
CREATE FUNCTION fnGetItemCostingOnPostErrors (@intItemId AS INT, @intItemLocationId AS INT, @intItemUOMId AS INT, @intSubLocationId AS INT, @intStorageLocationId AS INT, @dblQty AS NUMERIC(18,6) = 0, @intLotId AS INT)
RETURNS TABLE 
AS
RETURN (
	
	SELECT DISTINCT * 
	FROM (
		-- Check for any invalid item.
		SELECT	intItemId = @intItemId
				,intItemLocationId = @intItemLocationId
				,strText = FORMATMESSAGE(50027)
				,intErrorCode = 50027
		WHERE	NOT EXISTS (
					SELECT TOP 1 1 
					FROM	tblICItem 
					WHERE	intItemId = @intItemId
				)	

		-- Check for negative stock and if negative stock is NOT allowed. 
		UNION ALL 
		SELECT	intItemId = @intItemId
				,intItemLocationId = @intItemLocationId
				,strText = FORMATMESSAGE(50029)
				,intErrorCode = 50029
		WHERE	EXISTS (
					SELECT	TOP 1 1
					FROM	dbo.tblICItem Item INNER JOIN dbo.tblICItemLocation Location
								ON Item.intItemId = @intItemId
								AND Location.intItemLocationId = @intItemLocationId
							LEFT JOIN dbo.tblICItemStockUOM StockUOM
								ON StockUOM.intItemId = Item.intItemId
								AND StockUOM.intItemLocationId = Location.intItemLocationId
								AND ISNULL(StockUOM.intSubLocationId, 0) = ISNULL(@intSubLocationId, 0)
								AND ISNULL(StockUOM.intStorageLocationId, 0) = ISNULL(@intStorageLocationId, 0)
					WHERE	ISNULL(@dblQty, 0) + ISNULL(StockUOM.dblOnHand, 0)  < 0
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
								ON Item.intItemId = @intItemId
								AND Location.intItemLocationId = @intItemLocationId
							LEFT JOIN dbo.tblICLot Lot
								ON Lot.intItemLocationId = Location.intItemLocationId 
								AND ISNULL(Lot.intLotId, 0) = ISNULL(@intLotId, 0)	
					WHERE	Item.intItemId = @intItemId
							AND Location.intItemLocationId = @intItemLocationId							
							AND ISNULL(@dblQty, 0) + ISNULL(Lot.dblQty, 0) < 0
							AND Location.intAllowNegativeInventory = 3			
				)
	) AS Query		
)
