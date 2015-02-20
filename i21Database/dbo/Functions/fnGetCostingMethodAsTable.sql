
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
			CostingMethod =  ISNULL(ItemLevel.intCostingMethod, ItemLocationCategoryLevel.intCostingMethod)
	FROM	(
				SELECT	intCostingMethod =  
							CASE	WHEN Item.strLotTracking IN ('Yes, Manual', 'Yes, Serial Number') THEN (SELECT intCostingMethodId FROM	dbo.tblICCostingMethod WHERE strCostingMethod = 'LOT COST') 
									ELSE NULL 
							END 
				FROM	dbo.tblICItem Item
				WHERE	Item.intItemId = @intItemId
			) ItemLevel 
			LEFT JOIN (
				SELECT	intCostingMethod = ISNULL(ItemLocation.intCostingMethod, Category.intCostingMethod)
				FROM	dbo.tblICItemLocation ItemLocation LEFT JOIN dbo.tblICCategory Category
							ON ItemLocation.intCategoryId = Category.intCategoryId
				WHERE	ItemLocation.intItemId = @intItemId
						AND ItemLocation.intItemLocationId = @intItemLocationId
			) ItemLocationCategoryLevel
				ON 1 = 1

)	