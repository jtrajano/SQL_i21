CREATE PROCEDURE [dbo].[uspMFGetRecipeGuideItems]
	@intPropertyId int = 0,
	@intCostTypeId int,
	@intLocationId int
AS

If ISNULL(@intPropertyId,0)>0
	SELECT i.intItemId,i.strItemNo,i.strDescription,iu.intItemUOMId,um.strUnitMeasure AS strUOM,
	CASE When @intCostTypeId=2 AND ISNULL(ip.dblAverageCost,0) > 0 THEN ISNULL(ip.dblAverageCost,0) 
		When @intCostTypeId=3 AND ISNULL(ip.dblLastCost,0) > 0 THEN ISNULL(ip.dblLastCost,0)
		Else ISNULL(ip.dblStandardCost,0) End
	AS dblCost
	From tblICItem i 
	Join tblICItemUOM iu on i.intItemId=iu.intItemId AND iu.ysnStockUnit=1
	Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
	Join tblICItemLocation il on i.intItemId=il.intItemId AND il.intLocationId=@intLocationId 
	Left Join tblICItemPricing ip on ip.intItemId=i.intItemId AND ip.intItemLocationId=il.intItemLocationId
	Join tblQMProduct p on i.intItemId=p.intProductValueId AND p.intProductTypeId=2
	Join tblQMProductProperty pp on p.intProductId=pp.intProductId AND pp.intPropertyId=@intPropertyId
Else
	SELECT i.intItemId,i.strItemNo,i.strDescription,iu.intItemUOMId,um.strUnitMeasure AS strUOM,
	CASE When @intCostTypeId=2 AND ISNULL(ip.dblAverageCost,0) > 0 THEN ISNULL(ip.dblAverageCost,0) 
		When @intCostTypeId=3 AND ISNULL(ip.dblLastCost,0) > 0 THEN ISNULL(ip.dblLastCost,0)
		Else ISNULL(ip.dblStandardCost,0) End
	AS dblCost
	From tblICItem i 
	Join tblICItemUOM iu on i.intItemId=iu.intItemId AND iu.ysnStockUnit=1
	Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
	Join tblICItemLocation il on i.intItemId=il.intItemId AND il.intLocationId=@intLocationId 
	Left Join tblICItemPricing ip on ip.intItemId=i.intItemId AND ip.intItemLocationId=il.intItemLocationId
