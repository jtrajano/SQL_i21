
-- This function will retrieve the costing method configured in an item (and per location).
CREATE FUNCTION [dbo].[fnGetCostingMethod](
	@intItemId INT
	,@intLocationId INT
)
RETURNS INT
AS 
BEGIN 
	DECLARE @costingMethod AS INT

	-- If costing method is not found at item-Location level, get the costing method in the category level. 
	SELECT	@costingMethod = ISNULL(ItemLocation.intCostingMethod, Category.intCostingMethod)
	FROM	tblICItemLocation ItemLocation LEFT JOIN tblICCategory Category
				ON ItemLocation.intCategoryId = Category.intCategoryId
	WHERE	intItemId = @intItemId
			AND intLocationId = @intLocationId

	RETURN @costingMethod;	
END
GO