CREATE PROCEDURE [dbo].[uspMFGetRecipeItemsCost]
	@intRecipeId int,
	@intLocationId int
AS

Declare @intCostTypeId int

Select @intCostTypeId=intCostTypeId From tblMFRecipe where intRecipeId=@intRecipeId

If ISNULL(@intCostTypeId,0)=0
	Set @intCostTypeId=1

Select ri.intRecipeId,ri.intRecipeItemId,ri.intItemId,iu.dblUnitQty,
ISNULL(dbo.fnMFConvertCostToTargetItemUOM((Select intItemUOMId From tblICItemUOM Where intItemId=ri.intItemId AND ysnStockUnit=1),ri.intItemUOMId,
CASE When @intCostTypeId=2 AND ISNULL(ip.dblAverageCost,0) > 0 THEN ISNULL(ip.dblAverageCost,0) 
When @intCostTypeId=3 AND ISNULL(ip.dblLastCost,0) > 0 THEN ISNULL(ip.dblLastCost,0)
Else ISNULL(ip.dblStandardCost,0) End
),0) AS dblCost
From tblMFRecipeItem ri 
Join tblICItemUOM iu on ri.intItemUOMId=iu.intItemUOMId --AND ysnStockUnit=1
Join tblICItemLocation il on ri.intItemId=il.intItemId 
Left Join tblICItemPricing ip on ip.intItemId=ri.intItemId AND ip.intItemLocationId=il.intItemLocationId
Where ri.intRecipeId=@intRecipeId AND ri.intRecipeItemTypeId=1 AND il.intLocationId=@intLocationId