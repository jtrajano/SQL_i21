CREATE PROCEDURE [dbo].[uspMFGetBlendSheetInputLots]
@intWorkOrderId int
AS

Declare @dblRecipeQty numeric(18,6)

Select TOP 1 @dblRecipeQty=r.dblQuantity 
from tblMFRecipe r Join tblMFRecipeItem ri on r.intRecipeId=ri.intRecipeId 
Join tblMFWorkOrder w on r.intItemId=w.intItemId And r.intLocationId=w.intLocationId
where r.ysnActive=1

Select wi.intWorkOrderInputLotId,wi.intWorkOrderId,wi.intLotId,wi.dblQuantity,
wi.intItemUOMId,wi.dblIssuedQuantity,wi.intItemIssuedUOMId,
l.dblWeightPerQty AS dblWeightPerUnit,wi.intSequenceNo,wi.dtmCreated,wi.intCreatedUserId,
wi.dtmLastModified,wi.intLastModifiedUserId,cast(0 as bit) AS ysnParentLot,
l.strLotNumber,i.intItemId,i.strItemNo,i.strDescription,um.strUnitMeasure AS strUOM,
um1.strUnitMeasure AS strIssuedUOM,wi.intRecipeItemId,l.dblLastCost AS dblUnitCost,
ISNULL(l.strLotAlias,'') AS strLotAlias,
l.strVendorLocation AS strGarden,l.intLocationId,
cl.strLocationName AS strLocationName,
sbl.strSubLocationName,
sl.strName AS strStorageLocationName,
l.strNotes AS strRemarks,
i.dblRiskScore,
ri.dblQuantity/@dblRecipeQty AS dblConfigRatio,
CAST(ISNULL(q.Density,0) AS decimal) AS dblDensity,
CAST(ISNULL(q.Score,0) AS decimal) AS dblScore
From tblMFWorkOrderInputLot wi Join tblMFWorkOrder w on wi.intWorkOrderId=w.intWorkOrderId
Join tblICItemUOM iu on wi.intItemUOMId=iu.intItemUOMId
Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
Join tblICLot l on wi.intLotId=l.intLotId
Join tblICItem i on l.intItemId=i.intItemId
Join tblICItemUOM iu1 on wi.intItemIssuedUOMId=iu1.intItemUOMId
Join tblICUnitMeasure um1 on iu1.intUnitMeasureId=um1.intUnitMeasureId
Join tblSMCompanyLocation cl on cl.intCompanyLocationId=l.intLocationId
Left Join tblSMCompanyLocationSubLocation sbl on sbl.intCompanyLocationSubLocationId=l.intSubLocationId
Left Join tblICStorageLocation sl on sl.intStorageLocationId=l.intStorageLocationId
Left Join vyuQMGetLotQuality q on l.intLotId=q.intLotId
Left Join tblMFRecipeItem ri on wi.intRecipeItemId=ri.intRecipeItemId
Where wi.intWorkOrderId=@intWorkOrderId
