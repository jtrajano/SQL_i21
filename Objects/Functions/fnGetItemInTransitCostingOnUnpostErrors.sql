/**
* This function will centralize the validation for each items. This is used prior to unposting a transaction. 
* 
* Sample usage: 
*
*	SELECT	B.*
*	FROM	tblICItemLocation A CROSS APPLY dbo.fnGetItemCostingOnUnpostErrors(A.intItemId, A.intItemLocationId, A.intItemUOMId, A.dblQty) B
* 
*/
CREATE FUNCTION fnGetItemInTransitCostingOnUnpostErrors (
	@intItemId AS INT
	, @intItemLocationId AS INT
	, @intItemUOMId AS INT
	, @intSubLocationId AS INT
	, @intStorageLocationId AS INT
	, @dblQty AS NUMERIC(38,20) = 0
	, @intLotId AS INT
	, @intTransactionId AS INT 
	, @strTransactionId AS NVARCHAR(50) 
)
RETURNS TABLE 
AS
RETURN (
	
	SELECT DISTINCT * 
	FROM (
	
		-- 'Negative stock quantity is not allowed for {Item Name} on {Location Name}, {Sub Location Name}, and {Storage Location Name}.'
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
					SELECT	dblQty = SUM(ISNULL(cb.dblStockIn, 0) - ISNULL(cb.dblStockOut, 0)) 
					FROM	dbo.tblICItem Item INNER JOIN dbo.tblICItemLocation [Location]
								ON Item.intItemId = @intItemId								
								AND [Location].intItemLocationId = @intItemLocationId
							INNER JOIN dbo.tblICInventoryActualCost cb 
								ON cb.intItemId = Item.intItemId 
								AND cb.intItemLocationId = [Location].intItemLocationId 
								AND cb.strTransactionId = @strTransactionId
								AND cb.ysnIsUnposted = 0 
					WHERE	ISNULL(cb.dblStockIn, 0) - ISNULL(cb.dblStockOut, 0) <> 0 
					HAVING	ROUND(SUM(ISNULL(cb.dblStockIn, 0) - ISNULL(cb.dblStockOut, 0)) + ISNULL(@dblQty, 0), 6) < 0 
				)

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
								AND Lot.intItemUOMId <> Lot.intWeightUOMId 
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
								dbo.fnICGetErrorMessage(locked.intError)
								,locked.strItemNo
								,locked.strText
								, DEFAULT
								, DEFAULT
								, DEFAULT
								, DEFAULT
								, DEFAULT
								, DEFAULT
								, DEFAULT
								, DEFAULT
							)
				,intErrorCode = locked.intError
		FROM (
					-- Validate Locked Company Locations
					SELECT	TOP 1
						intError = 80066
						,i.strItemNo
						,strText = cl.strLocationName
					FROM	
						dbo.tblICItem i INNER JOIN dbo.tblICItemLocation il
							ON i.intItemId = il.intItemId
						INNER JOIN tblSMCompanyLocation cl 
							ON cl.intCompanyLocationId = il.intLocationId
					WHERE	
						ysnLockedInventory = 1
						AND i.intItemId = @intItemId
						AND il.intItemLocationId = @intItemLocationId					

					-- Validate Locked Sub Locations
					UNION ALL 
					SELECT	TOP 1 
						intError = 80239
						,i.strItemNo
						,strText = csl.strSubLocationName
					FROM	
						tblICItem i INNER JOIN (
							tblICLockedSubLocation ll INNER JOIN tblSMCompanyLocationSubLocation csl 
								ON csl.intCompanyLocationSubLocationId = ll.intSubLocationId
						)
							ON i.intItemId = ll.intItemId 
					WHERE 
						i.intItemId = @intItemId
						AND ll.intSubLocationId = @intSubLocationId
											
					-- Validate Locked Storage Locations
					UNION ALL 
					SELECT TOP 1 
						intError = 80240
						,i.strItemNo
						,strText = sl.strName
					FROM 
						tblICItem i INNER JOIN (
							tblICLockedStorageLocation ll INNER JOIN tblICStorageLocation sl 
								ON sl.intStorageLocationId = ll.intStorageLocationId
						)
							ON i.intItemId = ll.intItemId
					WHERE 
						i.intItemId = @intItemId
						AND sl.intSubLocationId = @intSubLocationId
						AND sl.intStorageLocationId = @intStorageLocationId
					
					-- Validate Locked Lots
					UNION ALL 
					SELECT TOP 1 
						intError = 80241
						,i.strItemNo
						,strText = l.strLotNumber
					FROM 
						tblICLot l INNER JOIN tblICItem i 
							ON l.intItemId = i.intItemId
					WHERE 
						l.intLotId = @intLotId
						AND l.ysnLockedInventory = 1
		) locked

	) AS Query		
)