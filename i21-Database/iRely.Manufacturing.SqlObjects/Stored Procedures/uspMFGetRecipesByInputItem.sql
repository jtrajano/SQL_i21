CREATE PROCEDURE [dbo].[uspMFGetRecipesByInputItem]
	@intItemId int,
	@intLocationId int
AS

Select Distinct r.intRecipeId,i.intItemId,i.strItemNo,i.strDescription
From tblMFRecipe r Join tblICItem i on r.intItemId=i.intItemId
Join tblMFRecipeItem ri on r.intRecipeId=ri.intRecipeId
Where ri.intItemId=@intItemId And r.intLocationId=@intLocationId And r.ysnActive=1 And ri.intRecipeItemTypeId=1
