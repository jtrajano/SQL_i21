﻿/**
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
				,strText = FORMATMESSAGE(80001)
				,intErrorCode = 80001
		WHERE	NOT EXISTS (
					SELECT TOP 1 1 
					FROM	tblICItem 
					WHERE	intItemId = @intItemId
				)

		-- Check for any invalid item location 
		UNION ALL 
		SELECT	intItemId = @intItemId
				,intItemLocationId = @intItemLocationId
				,strText = FORMATMESSAGE(80002)
				,intErrorCode = 80002
		WHERE	NOT EXISTS (
					SELECT TOP 1 1 
					FROM	dbo.tblICItemLocation
					WHERE	intItemLocationId = @intItemLocationId
							AND intItemId = @intItemId
				)
				AND @intItemId IS NOT NULL 	

		-- Check for invalid item UOM Id
		UNION ALL 
		SELECT	intItemId = @intItemId
				,intItemLocationId = @intItemLocationId
				,strText = FORMATMESSAGE(80048)
				,intErrorCode = 80048
		WHERE	NOT EXISTS (
					SELECT TOP 1 1 
					FROM	dbo.tblICItemUOM 
					WHERE	intItemId = @intItemId
							AND intItemUOMId = @intItemUOMId
				)
				AND @intItemId IS NOT NULL 	
				AND @intItemUOMId IS NOT NULL

		-- Check for missing costing method. 
		UNION ALL 
		SELECT	intItemId = @intItemId
				,intItemLocationId = @intItemLocationId
				,strText = FORMATMESSAGE(80023)
				,intErrorCode = 80023
		FROM	dbo.tblICItem Item INNER JOIN dbo.tblICItemLocation ItemLocation 
					ON Item.intItemId = ItemLocation.intItemLocationId
		WHERE	ISNULL(dbo.fnGetCostingMethod(ItemLocation.intItemId, ItemLocation.intItemLocationId), 0) = 0 
				AND ItemLocation.intItemId = @intItemId 
				AND ItemLocation.intItemLocationId = @intItemLocationId

		-- Check for "Discontinued" status. Do not allow use of that item even if there are stocks on it. 
		UNION ALL 
		SELECT	intItemId = @intItemId
				,intItemLocationId = @intItemLocationId
				,strText = FORMATMESSAGE(80022)
				,intErrorCode = 80022
		FROM	tblICItem Item
		WHERE	Item.intItemId = @intItemId
				AND Item.strStatus = 'Discontinued'

		-- Check for "Discontinued" status. Do not allow use of that item even if there are stocks on it. 
		UNION ALL 
		SELECT	intItemId = @intItemId
				,intItemLocationId = @intItemLocationId
				,strText = FORMATMESSAGE(80022)
				,intErrorCode = 80022
		FROM	tblICItem Item
		WHERE	Item.intItemId = @intItemId
				AND Item.strStatus = 'Discontinued'

		-- Check for negative stock and if negative stock is NOT allowed. 
		-- and do not allow negative stock on items being phased-out. 
		UNION ALL 
		SELECT	intItemId = @intItemId
				,intItemLocationId = @intItemLocationId
				,strText = FORMATMESSAGE(80003)
				,intErrorCode = 80003
		WHERE	EXISTS (
					SELECT	TOP 1 1
					FROM	dbo.tblICItem Item INNER JOIN dbo.tblICItemLocation Location
								ON Item.intItemId = @intItemId
								AND Location.intItemLocationId = @intItemLocationId
							LEFT JOIN dbo.tblICItemStockUOM StockUOM
								ON StockUOM.intItemId = Item.intItemId
								AND StockUOM.intItemUOMId = @intItemUOMId
								AND StockUOM.intItemLocationId = Location.intItemLocationId
								AND ISNULL(StockUOM.intSubLocationId, 0) = ISNULL(@intSubLocationId, 0)
								AND ISNULL(StockUOM.intStorageLocationId, 0) = ISNULL(@intStorageLocationId, 0)
					WHERE	ISNULL(@dblQty, 0) + ISNULL(StockUOM.dblOnHand, 0) + ISNULL(StockUOM.dblUnitReserved, 0) < 0
							AND (							
								Location.intAllowNegativeInventory = 3 -- Value 3 means "NO", Negative stock is NOT allowed. 
								OR Item.strStatus = 'Phased Out'
							)							
				)

		-- Check for negative stocks at the lot table. 
		-- and do not allow negative stock on items being phased-out. 
		UNION ALL 
		SELECT	intItemId = @intItemId
				,intItemLocationId = @intItemLocationId
				,strText = FORMATMESSAGE(80003)
				,intErrorCode = 80003
		WHERE	EXISTS (
					SELECT	TOP 1 1
					FROM	dbo.tblICItem Item INNER JOIN dbo.tblICItemLocation Location
								ON Item.intItemId = @intItemId
								AND Location.intItemLocationId = @intItemLocationId
							LEFT JOIN dbo.tblICLot Lot
								ON Lot.intItemLocationId = Location.intItemLocationId 
								AND ISNULL(Lot.intLotId, 0) = ISNULL(@intLotId, 0)								
								AND Lot.intItemUOMId = @intItemUOMId
					WHERE	Item.intItemId = @intItemId
							AND Lot.intLotId IS NOT NULL
							AND ISNULL(@dblQty, 0) + ISNULL(Lot.dblQty, 0) < 0
							AND (							
								Location.intAllowNegativeInventory = 3 -- Value 3 means "NO", Negative stock is NOT allowed. 
								OR Item.strStatus = 'Phased Out'
							)		
				)

		-- Check for the missing Stock Unit UOM 
		UNION ALL 
		SELECT	intItemId = @intItemId
				,intItemLocationId = @intItemLocationId
				,strText = FORMATMESSAGE(80049)
				,intErrorCode = 80049
		WHERE	dbo.fnGetItemStockUOM(@intItemId) IS NULL 
				AND @intItemId IS NOT NULL 

	) AS Query		
)
