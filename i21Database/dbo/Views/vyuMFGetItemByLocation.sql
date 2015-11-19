CREATE VIEW [dbo].[vyuMFGetItemByLocation]
	AS
Select CAST(ROW_NUMBER() OVER(ORDER BY i.intItemId DESC) AS INT) AS intRowNo,
i.intItemId,i.strItemNo,i.strDescription,i.strType,i.intCategoryId,i.strStatus,i.strInventoryTracking,
il.intLocationId,iu.intItemUOMId AS intStockItemUOMId,iu.intUnitMeasureId AS intStockUOMId ,um.strUnitMeasure AS strStockUOM
From tblICItem i 
Join tblICItemLocation il on i.intItemId=il.intItemId
Join tblICItemUOM iu on i.intItemId=iu.intItemId
Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
Where  iu.ysnStockUnit=1
