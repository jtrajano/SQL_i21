
-- This function will retrieve the costing method configured in an item (and per location).
CREATE FUNCTION [dbo].[fnGetCostingMethod](
	@intItemId INT
	,@intItemLocationId INT
)
RETURNS INT
AS 
BEGIN 
	DECLARE	@LotCost AS INT

	SELECT	@LotCost = intCostingMethodId
	FROM	dbo.tblICCostingMethod
	WHERE	strCostingMethod = 'LOT COST'

	DECLARE @costingMethod AS INT

	-- If item is a Lot item, return Lot Costing. 
	-- If not, get the costing method at item-location level. 
	-- If not found, get the costing method at the category level. 
	SELECT 	@costingMethod = ISNULL(ItemLevel.intCostingMethod, ISNULL(ItemLocation.intCostingMethod, Category.intCostingMethod))
	FROM	(
				SELECT	intCostingMethod =  
							CASE	WHEN Item.strLotTracking IN ('Yes - Manual', 'Yes - Serial Number') THEN @LotCost 
									ELSE NULL 
							END 
				FROM	dbo.tblICItem Item
				WHERE	Item.intItemId = @intItemId
			) ItemLevel 
			LEFT JOIN tblICItemLocation ItemLocation
				ON ItemLocation.intItemId = @intItemId AND ItemLocation.intItemLocationId = @intItemLocationId
			LEFT JOIN dbo.tblICCategory Category
				ON ItemLevel.intCategoryId = Category.intCategoryId

	RETURN @costingMethod;	
END
GO