CREATE PROCEDURE [dbo].[uspMFGetRecipeItemsCost]
	@intRecipeId int,
	@intLocationId int
AS

Select ri.intRecipeId,ri.intRecipeItemId,ri.intItemId,iu.dblUnitQty,ip.dblStandardCost AS dblCost 
From tblMFRecipeItem ri Join tblICItemUOM iu on ri.intItemUOMId=iu.intItemUOMId 
Join tblICItemLocation il on ri.intItemId=il.intItemId 
Join tblICItemPricing ip on ip.intItemLocationId=il.intItemLocationId 
Where ri.intRecipeId=@intRecipeId AND ri.intRecipeItemTypeId=1 AND il.intLocationId=@intLocationId