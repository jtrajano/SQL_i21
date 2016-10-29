CREATE VIEW [dbo].[vyuMFGetItem]
	AS 
Select 
i.intItemId,i.strItemNo,i.strDescription,i.strType,i.intCategoryId,i.strStatus,i.strInventoryTracking,
iu.intItemUOMId AS intStockItemUOMId,iu.intUnitMeasureId AS intStockUOMId ,um.strUnitMeasure AS strStockUOM,cg.strCategoryCode,i.strRequired
From tblICItem i 
Join tblICItemUOM iu on i.intItemId=iu.intItemId
Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
Left Join tblICCategory cg on i.intCategoryId=cg.intCategoryId
Where  iu.ysnStockUnit=1 AND i.strStatus='Active'
UNION
Select intItemId,strItemNo,strDescription,strType,
0 intCategoryId,'' strStatus,'' strInventoryTracking,0 intStockItemUOMId,0 intStockUOMId,'' strStockUOM,'' strCategoryCode,'' strRequired
From tblICItem Where strType='Comment'
