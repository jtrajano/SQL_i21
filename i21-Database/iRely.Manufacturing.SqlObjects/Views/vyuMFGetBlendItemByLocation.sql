CREATE VIEW [dbo].[vyuMFGetBlendItemByLocation]
	AS 
Select DISTINCT 
i.intItemId,i.strItemNo,i.strDescription,i.strType,i.intCategoryId,i.strStatus,i.strInventoryTracking,i.strLotTracking,
il.intLocationId,iu.intItemUOMId AS intStockItemUOMId,iu.intUnitMeasureId AS intStockUOMId ,um.strUnitMeasure AS strStockUOM,cg.strCategoryCode,cl.strLocationName
From tblICItem i 
Join tblICItemLocation il on i.intItemId=il.intItemId
Join tblICItemUOM iu on i.intItemId=iu.intItemId
Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
Left Join tblICCategory cg on i.intCategoryId=cg.intCategoryId
JOIN tblMFRecipe r on i.intItemId=r.intItemId
JOIN tblMFManufacturingProcess mp on r.intManufacturingProcessId=mp.intManufacturingProcessId AND mp.intAttributeTypeId=2
JOIN tblSMCompanyLocation cl on il.intLocationId=cl.intCompanyLocationId
Where  iu.ysnStockUnit=1 AND r.ysnActive=1
