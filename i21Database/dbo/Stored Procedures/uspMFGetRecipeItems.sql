CREATE PROCEDURE [dbo].[uspMFGetRecipeItems]
	@intRecipeId int,
	@intLocationId int
AS

Select ri.intRecipeId,ri.intRecipeItemId,ri.intItemId,i.strItemNo,i.strDescription AS strItemDescription,i.strType AS strItemType,ri.dblQuantity,ri.dblCalculatedQuantity,
ri.intItemUOMId,um.strUnitMeasure AS strUOM,ri.intMarginById,mg.strName AS strMarginBy,ISNULL(ri.dblMargin,0) AS dblMargin,
ISNULL(ip.dblStandardCost,0) AS dblCost,ISNULL(ip.dblStandardCost,0) AS dblCostCopy,1 AS intCostSourceId,'Item' AS strCostSource,
CASE WHEN ISNULL(ri.intMarginById,0)=1 THEN  dbo.fnICConvertUOMtoStockUnit(ri.intItemId,ri.intItemUOMId,ri.dblQuantity) * (ISNULL(ip.dblStandardCost ,0) + ((ISNULL(ri.dblMargin,0) * ISNULL(ip.dblStandardCost ,1)) / 100))
WHEN ISNULL(ri.intMarginById,0)=2 THEN dbo.fnICConvertUOMtoStockUnit(ri.intItemId,ri.intItemUOMId,ri.dblQuantity) * (ISNULL(ip.dblStandardCost ,0) + ISNULL(ri.dblMargin,0))
ELSE dbo.fnICConvertUOMtoStockUnit(ri.intItemId,ri.intItemUOMId,ri.dblQuantity) * ISNULL(ip.dblStandardCost ,0) End AS dblRetailPrice,
iu.dblUnitQty,ri.dblCalculatedLowerTolerance,ri.dblCalculatedUpperTolerance,ri.dblLowerTolerance,ri.dblUpperTolerance
From tblMFRecipeItem ri Join tblICItem i on ri.intItemId=i.intItemId 
Join tblICItemUOM iu on ri.intItemUOMId=iu.intItemUOMId
Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
Left Join tblMFMarginBy mg on ri.intMarginById=mg.intMarginById
Join tblICItemLocation il on ri.intItemId=il.intItemId AND il.intLocationId=@intLocationId 
Join tblICItemPricing ip on ri.intItemId=ip.intItemId AND il.intItemLocationId=ip.intItemLocationId
Where ri.intRecipeId=@intRecipeId AND ri.intRecipeItemTypeId=1 AND i.strType <> 'Other Charge'
