CREATE PROCEDURE [dbo].[uspMFGetRecipeItemsCost]
	@intRecipeId int,
	@intLocationId int
AS

Select ri.intRecipeId,ri.intRecipeItemId,ri.intItemId,iu.dblUnitQty,
ISNULL(dbo.fnMFConvertCostToTargetItemUOM(ip.intStockItemUOMId,ri.intItemUOMId,ISNULL(ip.dblCost,0)),0) AS dblCost
From tblMFRecipeItem ri Join tblICItemUOM iu on ri.intItemUOMId=iu.intItemUOMId 
Join tblICItemLocation il on ri.intItemId=il.intItemId 
Left Join vyuMFGetItemByLocation ip on ip.intItemId=ri.intItemId AND ip.intLocationId=@intLocationId
Where ri.intRecipeId=@intRecipeId AND ri.intRecipeItemTypeId=1 AND il.intLocationId=@intLocationId