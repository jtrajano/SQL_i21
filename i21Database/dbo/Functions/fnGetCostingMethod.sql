
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
	SELECT 	@costingMethod = ISNULL(ItemLevel.intCostingMethod, ItemLocationCategoryLevel.intCostingMethod)
	FROM	(
				SELECT	intCostingMethod =  
							CASE	WHEN Item.strLotTracking IN ('Yes, Manual', 'Yes, Serial Number') THEN @LotCost 
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

	RETURN @costingMethod;	
END
GO