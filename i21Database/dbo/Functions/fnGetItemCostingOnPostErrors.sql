/**
* This function will centralize the validation for each items. This is used prior to posting a transaction. 
* 
* Sample usage: 
*
*	SELECT	B.*
*	FROM	tblICItemLocation A CROSS APPLY dbo.fnGetItemCostingOnPostErrors(A.intItemId, A.intLocationId, A.intItemUOMId, A.dblQty) B
* 
*/
CREATE FUNCTION fnGetItemCostingOnPostErrors (@intItemId AS INT, @intItemLocationId AS INT, @intItemUOMId AS INT, @intSubLocationId AS INT, @intStorageLocationId AS INT, @dblQty AS NUMERIC(38,20) = 0, @intLotId AS INT)
RETURNS TABLE 
AS
RETURN (
	
	SELECT DISTINCT * 
	FROM (
		-- Check for any invalid item.
		SELECT	intItemId = @intItemId
				,intItemLocationId = @intItemLocationId
				,strText = 'Item id is invalid or missing.'
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
				,strText = 'Item Location is invalid or missing for %s.'
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
				,strText = FORMATMESSAGE('Item UOM is invalid or missing.')
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
				,strText = FORMATMESSAGE('Missing costing method setup for item %s.')
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
				,strText = 'The status of %s is Discontinued.'
				,intErrorCode = 80022
		FROM	tblICItem Item
		WHERE	Item.intItemId = @intItemId
				AND Item.strStatus = 'Discontinued'

		-- Check for "Discontinued" status. Do not allow use of that item even if there are stocks on it. 
		UNION ALL 
		SELECT	intItemId = @intItemId
				,intItemLocationId = @intItemLocationId
				,strText = 'The status of %s is Discontinued.'
				,intErrorCode = 80022
		FROM	tblICItem Item
		WHERE	Item.intItemId = @intItemId
				AND Item.strStatus = 'Discontinued'

		-- Check for negative stock and if negative stock is NOT allowed. 
		-- and do not allow negative stock on items being phased-out. 
		-- 'Negative stock quantity is not allowed for {Item Name} on {Location Name}, {Storage Location Name}, and {Storage Unit Name}.'
		UNION ALL 
		SELECT	intItemId = @intItemId
				,intItemLocationId = @intItemLocationId
				,strText = FORMATMESSAGE(
								'Negative stock quantity is not allowed for %s in %s.'
								,(SELECT strItemNo FROM dbo.tblICItem WHERE intItemId = @intItemId)
								,dbo.fnFormatMsg80003(
									@intItemLocationId
									,@intSubLocationId
									,@intStorageLocationId
								)
								,ISNULL(
									(
										SELECT	strSubLocationName
										FROM	dbo.tblSMCompanyLocationSubLocation
										WHERE	intCompanyLocationSubLocationId = @intSubLocationId
									)
									, '(Blank Storage Location)'
								)
								,ISNULL(
									(
										SELECT	strName
										FROM	dbo.tblICStorageLocation
										WHERE	intStorageLocationId = @intStorageLocationId
									)
									, '(Blank Storage Unit)'
								)
							)
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
					WHERE	ROUND(ISNULL(@dblQty, 0) + ISNULL(StockUOM.dblOnHand, 0) + ISNULL(StockUOM.dblUnitReserved, 0), 4) < 0
							AND (							
								Location.intAllowNegativeInventory = 3 -- Value 3 means "NO", Negative stock is NOT allowed. 
								OR Item.strStatus = 'Phased Out'
							)							
				)

		-- Check for negative stocks at the lot table. 
		-- and do not allow negative stock on items being phased-out. 
		-- 'Negative stock quantity is not allowed for {Item Name} on {Location Name}, {Sub Location Name}, and {Storage Location Name}.'
		UNION ALL 
		SELECT	intItemId = @intItemId
				,intItemLocationId = @intItemLocationId
				,strText =	FORMATMESSAGE(
								'Negative stock quantity is not allowed for %s in %s.'
								,(SELECT strItemNo FROM dbo.tblICItem WHERE intItemId = @intItemId)
								,dbo.fnFormatMsg80003(
									@intItemLocationId
									,@intSubLocationId
									,@intStorageLocationId
								)
								,ISNULL(
									(
										SELECT	strSubLocationName
										FROM	dbo.tblSMCompanyLocationSubLocation
										WHERE	intCompanyLocationSubLocationId = @intSubLocationId
									)
									, '(Blank Storage Location)'
								)
								,ISNULL(
									(
										SELECT	strName
										FROM	dbo.tblICStorageLocation
										WHERE	intStorageLocationId = @intStorageLocationId
									)
									, '(Blank Storage Unit)' 
								)
							)
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
							AND ROUND(ISNULL(@dblQty, 0) + ISNULL(Lot.dblQty, 0), 4) < 0
							AND (							
								Location.intAllowNegativeInventory = 3 -- Value 3 means "NO", Negative stock is NOT allowed. 
								OR Item.strStatus = 'Phased Out'
							)		
				)

		-- Check for negative stocks at the lot table. 
		-- and do not allow negative stock on items being phased-out. 
		-- 'Negative stock quantity is not allowed for {Item Name} on {Location Name}, {Storage Location Name}, and {Storage Unit Name}.'
		UNION ALL 
		SELECT	intItemId = @intItemId
				,intItemLocationId = @intItemLocationId
				,strText =	FORMATMESSAGE(
								'Negative stock quantity is not allowed for %s in %s.'
								,(SELECT strItemNo FROM dbo.tblICItem WHERE intItemId = @intItemId)
								,dbo.fnFormatMsg80003(
									@intItemLocationId
									,@intSubLocationId
									,@intStorageLocationId
								)
								,ISNULL(
									(
										SELECT	strSubLocationName
										FROM	dbo.tblSMCompanyLocationSubLocation
										WHERE	intCompanyLocationSubLocationId = @intSubLocationId
									)
									, '(Blank Storage Location)'
								)
								,ISNULL(
									(
										SELECT	strName
										FROM	dbo.tblICStorageLocation
										WHERE	intStorageLocationId = @intStorageLocationId
									)
									, '(Blank Storage Unit)'
								)
							)
				,intErrorCode = 80003
		WHERE	EXISTS (
					SELECT	TOP 1 1
					FROM	dbo.tblICItem Item INNER JOIN dbo.tblICItemLocation Location
								ON Item.intItemId = @intItemId
								AND Location.intItemLocationId = @intItemLocationId
							LEFT JOIN dbo.tblICLot Lot
								ON Lot.intItemLocationId = Location.intItemLocationId 
								AND ISNULL(Lot.intLotId, 0) = ISNULL(@intLotId, 0)								
								AND Lot.intWeightUOMId = @intItemUOMId
					WHERE	Item.intItemId = @intItemId
							AND Lot.intLotId IS NOT NULL
							AND ROUND(ISNULL(@dblQty, 0) + ISNULL(Lot.dblWeight, 0), 4) < 0
							AND (							
								Location.intAllowNegativeInventory = 3 -- Value 3 means "NO", Negative stock is NOT allowed. 
								OR Item.strStatus = 'Phased Out'
							)		
				)

		-- Check for the missing Stock Unit UOM 
		UNION ALL 
		SELECT	intItemId = @intItemId
				,intItemLocationId = @intItemLocationId
				,strText = FORMATMESSAGE('Item %s is missing a Stock Unit. Please check the Unit of Measure setup.')
				,intErrorCode = 80049
		WHERE	dbo.fnGetItemStockUOM(@intItemId) IS NULL 
				AND @intItemId IS NOT NULL 

		-- Check for locked inventory. 
		-- Inventory count ongoing. 
		UNION ALL 
		SELECT	intItemId = @intItemId
				,intItemLocationId = @intItemLocationId
				,strText = FORMATMESSAGE(
								'Inventory Count is ongoing for Item %s and is locked under Location %s.'
								,(SELECT strItemNo FROM dbo.tblICItem WHERE intItemId = @intItemId)
								,(
									SELECT	tblSMCompanyLocation.strLocationName 
									FROM	dbo.tblICItemLocation INNER JOIN dbo.tblSMCompanyLocation 
												ON tblICItemLocation.intLocationId = tblSMCompanyLocation.intCompanyLocationId
									WHERE	tblICItemLocation.intItemId = @intItemId
											AND tblICItemLocation.intItemLocationId = @intItemLocationId
								)
							)
				,intErrorCode = 80066
		WHERE	EXISTS (
					SELECT	TOP 1 1
					FROM	dbo.tblICItem Item INNER JOIN dbo.tblICItemLocation Location
								ON Item.intItemId = @intItemId
								AND Location.intItemLocationId = @intItemLocationId
					WHERE	ysnLockedInventory = 1
				)

	) AS Query		
)
