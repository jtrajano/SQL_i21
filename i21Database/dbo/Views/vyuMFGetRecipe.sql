CREATE VIEW [dbo].[vyuMFGetRecipe]
AS
Select r.intRecipeId,i.strItemNo,i.strDescription,
r.dblQuantity,um.strUnitMeasure AS strUOM,r.intVersionNo,r.ysnActive,
cl.strLocationName,mc.strCellName,mp.strProcessName,cs.strCustomerNumber AS strCustomer
from tblMFRecipe r
Join tblICItem i on r.intItemId=i.intItemId 
Join tblICUnitMeasure um on r.intUOMId=um.intUnitMeasureId
Join tblSMCompanyLocation cl on r.intLocationId=cl.intCompanyLocationId
Join tblMFManufacturingCell mc on r.intManufacturingCellId=mc.intManufacturingCellId
Join tblMFManufacturingProcess mp on r.intManufacturingProcessId=mp.intManufacturingProcessId 
Left Join tblARCustomer cs on r.intCustomerId=cs.intEntityCustomerId
