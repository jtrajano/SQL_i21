CREATE VIEW [dbo].[vyuMFGetRecipeItem]
AS
Select r.intRecipeId,ri.intRecipeItemId,r.strName,rhi.strItemNo AS strRecipeItemNo,rhi.strDescription AS strRecipeItemDesc,
cl.strLocationName,mp.strProcessName,cs.strName AS strCustomer,r.intVersionNo,rt.strName AS strRecipeItemType,
i.strItemNo,i.strDescription,ri.dblQuantity,um.strUnitMeasure strUOM,ri.dblLowerTolerance,ri.dblUpperTolerance,cm.strName AS strConsumptionMethod,
sl.strName AS strStorageLocation,ct.strName AS strCommentType,ri.dtmValidFrom,ri.dtmValidTo,
mg.strName AS strMarginBy,ri.dblMargin,ri.ysnCostAppliedAtInvoice,r.intLocationId,r.intItemId AS intRecipeHeaderItemId,ri.intItemId AS intRecipeIngredientItemId,ri.intRecipeItemTypeId,
r.intCustomerId,r.ysnActive
from tblMFRecipe r
Left Join tblICItem rhi on r.intItemId=rhi.intItemId
Left Join tblMFRecipeItem ri on r.intRecipeId=ri.intRecipeId
Join tblICItem i on ri.intItemId=i.intItemId 
Left Join tblICItemUOM iu on ri.intItemUOMId=iu.intItemUOMId
Left Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
Left Join tblSMCompanyLocation cl on r.intLocationId=cl.intCompanyLocationId
Left Join tblMFManufacturingProcess mp on r.intManufacturingProcessId=mp.intManufacturingProcessId 
Left Join vyuARCustomer cs on r.intCustomerId=cs.[intEntityId]
Left Join tblMFConsumptionMethod cm on ri.intConsumptionMethodId=cm.intConsumptionMethodId
Left Join tblICStorageLocation sl on ri.intStorageLocationId=sl.intStorageLocationId
Left Join tblMFCommentType ct on ri.intCommentTypeId=ct.intCommentTypeId
Left Join tblMFMarginBy mg on ri.intMarginById=mg.intMarginById
Left Join tblMFRecipeItemType rt on ri.intRecipeItemTypeId=rt.intRecipeItemTypeId