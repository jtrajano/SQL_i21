
-- This function will retrieve the costing method configured in an item (and per location).
CREATE FUNCTION [dbo].[fnGetCostingMethodAsTable](
	@intItemId INT
	,@intItemLocationId INT
)
RETURNS TABLE
RETURN (
	-- If costing method is not found at item-Location level, get the costing method in the category level. 
	SELECT	TOP 1 
			CostingMethod = ISNULL(ItemLocation.intCostingMethod, Category.intCostingMethod)
	FROM	dbo.tblICItemLocation ItemLocation LEFT JOIN dbo.tblICCategory Category
				ON ItemLocation.intCategoryId = Category.intCategoryId
	WHERE	ItemLocation.intItemId = @intItemId
			AND ItemLocation.intItemLocationId = @intItemLocationId

)	