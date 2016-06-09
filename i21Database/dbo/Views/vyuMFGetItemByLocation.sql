CREATE VIEW [dbo].[vyuMFGetItemByLocation]
	AS
Select CAST(ROW_NUMBER() OVER(ORDER BY i.intItemId DESC) AS INT) AS intRowNo,
i.intItemId,i.strItemNo,i.strDescription,i.strType,i.intCategoryId,i.strStatus,i.strInventoryTracking,
il.intLocationId,iu.intItemUOMId AS intStockItemUOMId,iu.intUnitMeasureId AS intStockUOMId ,um.strUnitMeasure AS strStockUOM,cg.strCategoryCode,
ISNULL(ip.dblStandardCost,0) AS dblCost
From tblICItem i 
Join tblICItemLocation il on i.intItemId=il.intItemId
Join tblICItemUOM iu on i.intItemId=iu.intItemId
Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
Left Join tblICItemPricing ip on i.intItemId=ip.intItemId AND ip.intItemLocationId=il.intItemLocationId
Left Join tblICCategory cg on i.intCategoryId=cg.intCategoryId
Where  iu.ysnStockUnit=1 AND i.strStatus='Active'
