﻿/**
* This function will centralize the validation for each items. This is used prior to unposting a transaction. 
* 
* Sample usage: 
*
*	SELECT	B.*
*	FROM	tblICItemLocation A CROSS APPLY dbo.fnGetItemCostingOnUnpostErrors(A.intItemId, A.intItemLocationId, A.intItemUOMId, A.dblQty) B
* 
*/
CREATE FUNCTION fnGetItemCostingOnUnpostErrors (@intItemId AS INT, @intItemLocationId AS INT, @intItemUOMId AS INT, @intSubLocationId AS INT, @intStorageLocationId AS INT, @dblQty AS NUMERIC(38,20) = 0, @intLotId AS INT)
RETURNS TABLE 
AS
RETURN (
	
	-- 'Negative stock quantity is not allowed for {Item Name} on {Location Name}, {Sub Location Name}, and {Storage Location Name}.'
	SELECT DISTINCT * 
	FROM (
		SELECT	intItemId = @intItemId
				,intItemLocationId = @intItemLocationId
				,strText =	dbo.fnFormatMessage(
								dbo.fnICGetErrorMessage(80235)
								,(SELECT strItemNo FROM dbo.tblICItem WHERE intItemId = @intItemId)
								,dbo.fnFormatMsg80003(
									@intItemLocationId
									,@intSubLocationId
									,@intStorageLocationId
								)
								, v.dblOnHand
								, v.dblUnitReserved
								, v.dblOnHand - v.dblUnitReserved
								, DEFAULT
								, DEFAULT
								, DEFAULT
								, DEFAULT
								, DEFAULT
							)
				,intErrorCode = 80235
		FROM	(
				
					SELECT	TOP 1 
							Item.intItemId
							,dblOnHand = ISNULL(StockUOM.dblOnHand, 0)
							,dblUnitReserved = ISNULL(StockUOM.dblUnitReserved, 0)
					FROM	dbo.tblICItem Item INNER JOIN dbo.tblICItemLocation Location
								ON Item.intItemId = @intItemId								
								AND Location.intItemLocationId = @intItemLocationId
							LEFT JOIN dbo.tblICItemStockUOM StockUOM
								ON StockUOM.intItemId = Item.intItemId
								AND StockUOM.intItemUOMId = @intItemUOMId
								AND StockUOM.intItemLocationId = Location.intItemLocationId
								AND ISNULL(StockUOM.intSubLocationId, 0) = ISNULL(@intSubLocationId, 0)
								AND ISNULL(StockUOM.intStorageLocationId, 0) = ISNULL(@intStorageLocationId, 0)
					WHERE	ROUND(ISNULL(@dblQty, 0) + ISNULL(StockUOM.dblOnHand, 0) - ISNULL(StockUOM.dblUnitReserved, 0), 6) < 0
							AND Location.intAllowNegativeInventory = 3 -- Value 3 means "NO", Negative stock is NOT allowed. 													
						
				) v
		WHERE	v.intItemId IS NOT NULL 

		-- Check for negative stocks at the lot table. 
		-- 'Negative stock quantity is not allowed for {Item Name} on {Location Name}, {Sub Location Name}, and {Storage Location Name}.'
		UNION ALL 
		SELECT	intItemId = @intItemId
				,intItemLocationId = @intItemLocationId
				,strText =	dbo.fnFormatMessage(
								dbo.fnICGetErrorMessage(80003)
								,(SELECT strItemNo FROM dbo.tblICItem WHERE intItemId = @intItemId)
								,dbo.fnFormatMsg80003(
									@intItemLocationId
									,@intSubLocationId
									,@intStorageLocationId
								)
								, DEFAULT
								, DEFAULT
								, DEFAULT
								, DEFAULT
								, DEFAULT
								, DEFAULT
								, DEFAULT
								, DEFAULT
							)
				,intErrorCode = 80003
		WHERE	EXISTS (
					SELECT	TOP 1 1
					FROM	dbo.tblICItem Item INNER JOIN dbo.tblICItemLocation Location
								ON Item.intItemId = @intItemId
								AND Location.intItemLocationId = @intItemLocationId
							INNER JOIN dbo.tblICLot Lot
								ON Lot.intItemLocationId = Location.intItemLocationId 
								AND Lot.intWeightUOMId IS NOT NULL
								AND Lot.intItemUOMId <> Lot.intWeightUOMId 
								AND Lot.intItemUOMId = @intItemUOMId
								AND ISNULL(Lot.intLotId, 0) = ISNULL(@intLotId, 0)	
					WHERE	ROUND(ISNULL(@dblQty, 0) + ISNULL(Lot.dblQty, 0), 6) < 0
							AND Location.intAllowNegativeInventory = 3													
				)

		-- Check for negative lot weight. 
		UNION ALL 
		SELECT	intItemId = @intItemId
				,intItemLocationId = @intItemLocationId
				,strText =	dbo.fnFormatMessage(
								dbo.fnICGetErrorMessage(80003)
								,(SELECT strItemNo FROM dbo.tblICItem WHERE intItemId = @intItemId)
								,dbo.fnFormatMsg80003(
									@intItemLocationId
									,@intSubLocationId
									,@intStorageLocationId
								)
								, DEFAULT
								, DEFAULT
								, DEFAULT
								, DEFAULT
								, DEFAULT
								, DEFAULT
								, DEFAULT
								, DEFAULT
							)
				,intErrorCode = 80003
		WHERE	EXISTS (
					SELECT	TOP 1 1
					FROM	dbo.tblICItem Item INNER JOIN dbo.tblICItemLocation Location
								ON Item.intItemId = @intItemId
								AND Location.intItemLocationId = @intItemLocationId
							INNER JOIN dbo.tblICLot Lot
								ON Lot.intItemLocationId = Location.intItemLocationId 
								AND Lot.intWeightUOMId IS NOT NULL
								--AND Lot.intItemUOMId <> Lot.intWeightUOMId 
								AND Lot.intWeightUOMId = @intItemUOMId								 
								AND ISNULL(Lot.intLotId, 0) = ISNULL(@intLotId, 0)	
					WHERE	ROUND(ISNULL(@dblQty, 0) + ISNULL(Lot.dblWeight, 0), 6) < 0
							AND Location.intAllowNegativeInventory = 3													
				)

		-- 'Negative stock quantity is not allowed for {Item Name} on {Location Name}, {Sub Location Name}, and {Storage Location Name}.'
		UNION ALL 
		SELECT	intItemId = @intItemId
				,intItemLocationId = @intItemLocationId
				,strText =	dbo.fnFormatMessage(
								dbo.fnICGetErrorMessage(80003)
								,(SELECT strItemNo FROM dbo.tblICItem WHERE intItemId = @intItemId)
								,dbo.fnFormatMsg80003(
									@intItemLocationId
									,@intSubLocationId
									,@intStorageLocationId
								)
								, DEFAULT
								, DEFAULT
								, DEFAULT
								, DEFAULT
								, DEFAULT
								, DEFAULT
								, DEFAULT
								, DEFAULT
							)
				,intErrorCode = 80003
		WHERE	EXISTS (
					SELECT	TOP 1 1
					FROM	dbo.tblICItem Item INNER JOIN dbo.tblICItemLocation Location
								ON Item.intItemId = @intItemId
								AND Location.intItemLocationId = @intItemLocationId
							INNER JOIN dbo.tblICLot Lot
								ON Lot.intItemLocationId = Location.intItemLocationId 
								AND Lot.intWeightUOMId IS NULL
								AND Lot.intItemUOMId = @intItemUOMId
								AND ISNULL(Lot.intLotId, 0) = ISNULL(@intLotId, 0)	
					WHERE	ROUND(ISNULL(@dblQty, 0) + ISNULL(Lot.dblQty, 0), 6) < 0
							AND Location.intAllowNegativeInventory = 3													
				)

		-- Check for locked inventory. 
		-- Inventory count ongoing. 
		UNION ALL 
		SELECT	intItemId = @intItemId
				,intItemLocationId = @intItemLocationId
				,strText = dbo.fnFormatMessage(
								dbo.fnICGetErrorMessage(80066)
								,(SELECT strItemNo FROM dbo.tblICItem WHERE intItemId = @intItemId)
								,(
									SELECT	tblSMCompanyLocation.strLocationName 
									FROM	dbo.tblICItemLocation INNER JOIN dbo.tblSMCompanyLocation 
												ON tblICItemLocation.intLocationId = tblSMCompanyLocation.intCompanyLocationId
									WHERE	tblICItemLocation.intItemId = @intItemId
											AND tblICItemLocation.intItemLocationId = @intItemLocationId
								)
								, DEFAULT
								, DEFAULT
								, DEFAULT
								, DEFAULT
								, DEFAULT
								, DEFAULT
								, DEFAULT
								, DEFAULT
							)
				,intErrorCode = 80066
		WHERE	EXISTS (
					-- Validate Locked Company Locations
					SELECT	TOP 1 1
					FROM	dbo.tblICItem Item INNER JOIN dbo.tblICItemLocation Location
								ON Item.intItemId = @intItemId
								AND Location.intItemLocationId = @intItemLocationId
					WHERE	ysnLockedInventory = 1

					UNION
					-- Validate Locked Sub Lcoations
					SELECT TOP 1 1
					FROM tblICItem i
						INNER JOIN tblICItemLocation il ON il.intItemId = i.intItemId
						INNER JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = il.intLocationId
						INNER JOIN tblSMCompanyLocationSubLocation csl ON csl.intCompanyLocationId = cl.intCompanyLocationId
						INNER JOIN tblICLockedSubLocation ll ON ll.intSubLocationId = csl.intCompanyLocationSubLocationId
					WHERE i.intItemId = @intItemId
						AND ll.intSubLocationId = @intSubLocationId

					UNION
					-- Validate Locked Storage Locations
					SELECT TOP 1 1
					FROM tblICItemLocation il
						INNER JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = il.intLocationId
						INNER JOIN tblICItem i ON i.intItemId = il.intItemId
						INNER JOIN tblSMCompanyLocationSubLocation csl ON csl.intCompanyLocationId = cl.intCompanyLocationId
						INNER JOIN tblICStorageLocation sl ON sl.intSubLocationId = csl.intCompanyLocationSubLocationId
						INNER JOIN tblICLockedStorageLocation ll ON ll.intStorageLocationId = sl.intStorageLocationId
					WHERE i.intItemId = @intItemId
						AND csl.intCompanyLocationSubLocationId = @intSubLocationId
						AND sl.intStorageLocationId = @intStorageLocationId

					UNION
					-- Validate Locked Lots
					SELECT TOP 1 1
					FROM tblICLot l
					WHERE l.intLotId = @intLotId
						AND l.ysnLockedInventory = 1
				)

	) AS Query		
)