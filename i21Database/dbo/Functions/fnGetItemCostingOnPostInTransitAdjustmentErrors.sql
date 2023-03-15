CREATE FUNCTION fnGetItemCostingOnPostInTransitAdjustmentErrors (
	@intItemId AS INT
	, @intItemLocationId AS INT	
	--, @dblValue AS NUMERIC(38, 20) 
	--, @strSourceTransactionId AS NVARCHAR(50) 
)
RETURNS TABLE 
AS
/**
* This function will centralize the validation for each items. This is used prior to posting a transaction. 
* 
* Sample usage: 
*
*	SELECT	B.*
*	FROM	tblICItemLocation A CROSS APPLY dbo.fnGetItemCostingOnPostInTransitErrors(A.intItemId, A.intLocationId, A.intItemUOMId, A.dblQty) B
* 
*/
RETURN (
	
	SELECT DISTINCT * 
	FROM (
		-- Check for any invalid item.
		SELECT	intItemId = @intItemId
				,intItemLocationId = @intItemLocationId
				,strText = dbo.fnICGetErrorMessage(80001) -- 'Item id is invalid or missing.'
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
				,strText = dbo.fnICGetErrorMessage(80002) -- 'Item Location is invalid or missing for %s.'
				,intErrorCode = 80002
		WHERE	NOT EXISTS (
					SELECT TOP 1 1 
					FROM	dbo.tblICItemLocation
					WHERE	intItemLocationId = @intItemLocationId
				)
				AND @intItemId IS NOT NULL 	

		-- Check for missing costing method. 
		UNION ALL 
		SELECT	intItemId = @intItemId
				,intItemLocationId = @intItemLocationId
				,strText = dbo.fnFormatMessage(dbo.fnICGetErrorMessage(80023), Item.strItemNo, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT) 
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
				,strText = dbo.fnFormatMessage(dbo.fnICGetErrorMessage(80022), Item.strItemNo, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
				,intErrorCode = 80022
		FROM	tblICItem Item
		WHERE	Item.intItemId = @intItemId
				AND Item.strStatus = 'Discontinued'

		---- '{Item} will have a negative cost. Negative cost is not allowed.'
		--UNION ALL 
		--SELECT	intItemId = @intItemId
		--		,intItemLocationId = @intItemLocationId
		--		,strText = dbo.fnFormatMessage(
		--					dbo.fnICGetErrorMessage(80196)
		--					, Item.strItemNo
		--					, DEFAULT
		--					, DEFAULT
		--					, DEFAULT
		--					, DEFAULT
		--					, DEFAULT
		--					, DEFAULT
		--					, DEFAULT
		--					, DEFAULT
		--					, DEFAULT
		--				) 
		--		,intErrorCode = 80196				
		--FROM	tblICItem Item INNER JOIN tblICInventoryTransaction t 
		--			ON t.intItemId = @intItemId
		--			AND t.intItemLocationId = @intItemLocationId
		--			AND Item.intItemId = t.intItemId
		--WHERE	ISNULL(@dblValue, 0) < 0

		-- '{Item} is a bundle type and it is not allowed to receive nor reduce stocks.'
		UNION ALL 
		SELECT	intItemId = @intItemId
				,intItemLocationId = @intItemLocationId
				,strText = dbo.fnFormatMessage(
							dbo.fnICGetErrorMessage(80202)
							, Item.strItemNo
							, DEFAULT
							, DEFAULT
							, DEFAULT
							, DEFAULT
							, DEFAULT
							, DEFAULT
							, DEFAULT
							, DEFAULT
							, DEFAULT
						) 
				,intErrorCode = 80202				
		FROM	tblICItem Item
		WHERE	Item.intItemId = @intItemId
				AND Item.strType = 'Bundle'

		-- 'In-Transit value cannot be adjusted for {Other Charge}. Item type must be an "Inventory" type.'
		UNION ALL 
		SELECT	intItemId = @intItemId
				,intItemLocationId = @intItemLocationId
				,strText = dbo.fnFormatMessage(
							dbo.fnICGetErrorMessage(80275)
							, Item.strItemNo
							, DEFAULT
							, DEFAULT
							, DEFAULT
							, DEFAULT
							, DEFAULT
							, DEFAULT
							, DEFAULT
							, DEFAULT
							, DEFAULT
						) 
				,intErrorCode = 80275				
		FROM	tblICItem Item
		WHERE	Item.intItemId = @intItemId
				AND Item.strType NOT IN ('Inventory')

	) AS Query		
)
