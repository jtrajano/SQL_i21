
-- This function will retrieve the costing method configured in an item (and per location).
CREATE FUNCTION [dbo].[fnGetCostingMethodAsTable](
	@intItemId INT
	,@intItemLocationId INT
)
RETURNS TABLE
RETURN (
	-- If item is a Lot item, return Lot Costing. 
	-- If not, get the costing method at item-location level. 
	-- If not found, get the costing method at the category level. 
	SELECT 	TOP 1 
			CostingMethod =  ISNULL(ItemLevel.intCostingMethod, ISNULL(ItemLocation.intCostingMethod, Category.intCostingMethod))
	FROM	(
				SELECT	intCostingMethod =  
							CASE	WHEN Item.strLotTracking IN ('Yes - Manual', 'Yes - Serial Number') THEN (SELECT intCostingMethodId FROM tblICCostingMethod WHERE strCostingMethod = 'LOT COST') 
									ELSE NULL 
							END,
						intCategoryId
				FROM	tblICItem Item
				WHERE	Item.intItemId = @intItemId
			) ItemLevel 
			LEFT JOIN tblICItemLocation ItemLocation
				ON ItemLocation.intItemId = @intItemId AND ItemLocation.intItemLocationId = @intItemLocationId
			LEFT JOIN dbo.tblICCategory Category
				ON ItemLevel.intCategoryId = Category.intCategoryId
)	