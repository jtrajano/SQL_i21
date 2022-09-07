CREATE PROCEDURE [dbo].[uspMFGetRecipeItemsCost]
	@intRecipeId int,
	@intLocationId int
AS

DECLARE @intCostTypeId INT;

SELECT @intCostTypeId = ISNULL(intCostTypeId, 1)
FROM tblMFRecipe 
WHERE intRecipeId=@intRecipeId;

SELECT ri.intRecipeId
	 , ri.intRecipeItemId
	 , ri.intItemId
	 , iu.dblUnitQty
	 , ISNULL(dbo.fnMFConvertCostToTargetItemUOM((SELECT intItemUOMId 
												  FROM tblICItemUOM 
												  WHERE intItemId = ri.intItemId 
												    AND ysnStockUnit=1), ri.intItemUOMId, CASE WHEN @intCostTypeId = 2 AND ISNULL(itp.dblAverageCost, 0) > 0 THEN 
																									ISNULL(itp.dblAverageCost, 0) 
																						       WHEN @intCostTypeId = 3 AND ISNULL(itp.dblLastCost, 0) > 0 THEN 
																									ISNULL(itp.dblLastCost, 0)
																							   ELSE 
																									ISNULL(itp.dblStandardCost, 0) 
																						  END), 0) AS dblCost
	, itp.dblSalePrice
FROM tblMFRecipeItem ri 
JOIN tblICItemUOM iu ON ri.intItemUOMId = iu.intItemUOMId --AND ysnStockUnit=1
JOIN tblICItemLocation il ON ri.intItemId = il.intItemId 
LEFT JOIN tblICItemPricing itp ON itp.intItemId = ri.intItemId AND itp.intItemLocationId = il.intItemLocationId
JOIN tblICItem i on ri.intItemId=i.intItemId
WHERE ri.intRecipeId = @intRecipeId AND ri.intRecipeItemTypeId=1 AND il.intLocationId = @intLocationId AND i.strType<>'Other Charge'
UNION
SELECT ri.intRecipeId
     , ri.intRecipeItemId
	 , ri.intItemId
	 , 1 AS dblUnitQty
	 , ISNULL(CASE WHEN @intCostTypeId = 2 AND ISNULL(itp.dblAverageCost, 0) > 0 THEN 
						ISNULL(itp.dblAverageCost, 0) 
				   WHEN @intCostTypeId = 3 AND ISNULL(itp.dblLastCost, 0) > 0 THEN 
						ISNULL(itp.dblLastCost, 0)
				   ELSE ISNULL(itp.dblStandardCost, 0) 
			  END ,0) AS dblCost
	 , itp.dblSalePrice
FROM tblMFRecipeItem ri 
JOIN tblICItemLocation il on ri.intItemId=il.intItemId 
LEFT JOIN tblICItemPricing itp on itp.intItemId=ri.intItemId AND itp.intItemLocationId = il.intItemLocationId
JOIN tblICItem i on ri.intItemId = i.intItemId
WHERE ri.intRecipeId = @intRecipeId 
  AND ri.intRecipeItemTypeId = 1 
  AND il.intLocationId = @intLocationId 
  AND i.strType = 'Other Charge'