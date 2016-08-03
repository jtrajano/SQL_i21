CREATE PROCEDURE [dbo].[uspMFGetRecipeItems]
	@intRecipeId int,
	@intLocationId int
AS

Declare @intCostTypeId int

Select @intCostTypeId=intCostTypeId From tblMFRecipe where intRecipeId=@intRecipeId

If ISNULL(@intCostTypeId,0)=0
	Set @intCostTypeId=1

Select *,t.dblCost AS dblCostCopy FROM
(
Select ri.intRecipeId,ri.intRecipeItemId,ri.intItemId,i.strItemNo,i.strDescription AS strItemDescription,i.strType AS strItemType,ri.dblQuantity,ri.dblCalculatedQuantity,
ri.intItemUOMId,um.strUnitMeasure AS strUOM,ri.intMarginById,mg.strName AS strMarginBy,ISNULL(ri.dblMargin,0) AS dblMargin,
ISNULL(dbo.fnMFConvertCostToTargetItemUOM(iu.intItemUOMId,ri.intItemUOMId,
CASE When @intCostTypeId=2 AND ISNULL(ip.dblAverageCost,0) > 0 THEN ISNULL(ip.dblAverageCost,0) 
When @intCostTypeId=3 AND ISNULL(ip.dblLastCost,0) > 0 THEN ISNULL(ip.dblLastCost,0)
Else ISNULL(ip.dblStandardCost,0) End
),0) AS dblCost,
1 AS intCostSourceId,'Item' AS strCostSource,
0.0 AS dblRetailPrice,
iu.dblUnitQty,ri.dblCalculatedLowerTolerance,ri.dblCalculatedUpperTolerance,ri.dblLowerTolerance,ri.dblUpperTolerance,
0 intCommentTypeId,'' strCommentType
From tblMFRecipeItem ri Join tblICItem i on ri.intItemId=i.intItemId 
Join tblICItemUOM iu on ri.intItemUOMId=iu.intItemUOMId AND iu.ysnStockUnit=1
Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
Left Join tblMFMarginBy mg on ri.intMarginById=mg.intMarginById
Join tblICItemLocation il on ri.intItemId=il.intItemId AND il.intLocationId=@intLocationId 
Left Join tblICItemPricing ip on ip.intItemId=ri.intItemId AND ip.intItemLocationId=il.intItemLocationId
Where ri.intRecipeId=@intRecipeId AND ri.intRecipeItemTypeId=1 AND i.strType <> 'Other Charge'
UNION
Select ri.intRecipeId,ri.intRecipeItemId,ri.intItemId,i.strItemNo,ri.strDescription AS strItemDescription,i.strType AS strItemType,0 dblQuantity,0 dblCalculatedQuantity,
0 intItemUOMId,'' strUOM,0 intMarginById,'' strMarginBy,0 AS dblMargin,
0 AS dblCost,0 AS intCostSourceId,'' AS strCostSource,0.0 AS dblRetailPrice,
0 dblUnitQty,0 dblCalculatedLowerTolerance,0 dblCalculatedUpperTolerance,0 dblLowerTolerance,0 dblUpperTolerance,
ri.intCommentTypeId,ct.strName strCommentType
From tblMFRecipeItem ri Join tblICItem i on ri.intItemId=i.intItemId 
Join tblMFCommentType ct on ri.intCommentTypeId=ct.intCommentTypeId
Where ri.intRecipeId=@intRecipeId
) t