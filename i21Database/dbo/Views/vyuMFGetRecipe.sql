CREATE VIEW [dbo].[vyuMFGetRecipe]
AS
Select r.intRecipeId,i.strItemNo,i.strDescription,
r.dblQuantity,um.strUnitMeasure AS strUOM,r.intVersionNo,r.ysnActive,
cl.strLocationName,mp.strProcessName,cs.strName AS strCustomer,r.strName,r.dblQuantity AS dblQuantityCopy
from tblMFRecipe r
Left Join tblICItem i on r.intItemId=i.intItemId 
Left Join tblICItemUOM iu on r.intItemUOMId=iu.intItemUOMId
Left Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
Left Join tblSMCompanyLocation cl on r.intLocationId=cl.intCompanyLocationId
Left Join tblMFManufacturingProcess mp on r.intManufacturingProcessId=mp.intManufacturingProcessId 
Left Join vyuARCustomer cs on r.intCustomerId=cs.intEntityCustomerId
