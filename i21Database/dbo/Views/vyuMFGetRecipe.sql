CREATE VIEW [dbo].[vyuMFGetRecipe]
AS
Select r.intRecipeId,i.strItemNo,i.strDescription,
r.dblQuantity,CASE WHEN ISNULL(r.intItemId,0)>0 THEN um.strUnitMeasure ELSE um1.strUnitMeasure END AS strUOM,r.intVersionNo,r.ysnActive,
cl.strLocationName,mp.strProcessName,cs.strName AS strCustomer,cs.strCustomerNumber,r.strName,r.dblQuantity AS dblQuantityCopy,
r.intCostTypeId,ct.strName AS strCostType,r.intMarginById,mg.strName AS strMarginBy,r.dblMargin,r.dblDiscount
from tblMFRecipe r
Left Join tblICItem i on r.intItemId=i.intItemId 
Left Join tblICItemUOM iu on r.intItemUOMId=iu.intItemUOMId
Left Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
Left Join tblSMCompanyLocation cl on r.intLocationId=cl.intCompanyLocationId
Left Join tblMFManufacturingProcess mp on r.intManufacturingProcessId=mp.intManufacturingProcessId 
Left Join vyuARCustomer cs on r.intCustomerId=cs.[intEntityId]
Left Join tblMFCostType ct on r.intCostTypeId=ct.intCostTypeId
Left Join tblMFMarginBy mg on r.intMarginById=mg.intMarginById
Left Join tblICUnitMeasure um1 on r.intMarginUOMId=um1.intUnitMeasureId