
CREATE PROCEDURE [dbo].[uspMFGetBlendSheetAvailableLots]
	@intItemId int,
	@intLocationId int,
	@intRecipeItemId int
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

Declare @intRecipeId int
Declare @dblRecipeQty numeric(18,6)

Select TOP 1 @intRecipeId = r.intRecipeId,@dblRecipeQty=r.dblQuantity 
from tblMFRecipe r Join tblMFRecipeItem ri on r.intRecipeId=ri.intRecipeId
where ri.intItemId=@intItemId and ri.intRecipeItemId=@intRecipeItemId and r.intLocationId=@intLocationId and r.ysnActive=1

Declare @tblReservedQty table
(
	intLotId int,
	dblReservedQty numeric(18,6)
)

--Insert into @tblReservedQty
--Select rd.intLotId,Sum(rd.dblQuantity) AS dblReservedQty 
--From tblICInventoryReservationDetail rd 
--where rd.intItemId=@intItemId
--group by rd.intLotId

Insert into @tblReservedQty
Select cl.intLotId,Sum(cl.dblQuantity) AS dblReservedQty 
From tblMFWorkOrderConsumedLot cl 
Join tblMFWorkOrder w on cl.intWorkOrderId=w.intWorkOrderId
join tblICLot l on l.intLotId=cl.intLotId
where l.intItemId=@intItemId and w.intStatusId<>13
group by cl.intLotId

--intPhysicalItemUOMId is 
Select l.intLotId,l.strLotNumber,l.intItemId,i.strItemNo,i.strDescription,ISNULL(l.strLotAlias,'') AS strLotAlias,l.dblWeight AS dblPhysicalQty,
ISNULL(c.dblReservedQty,0) AS dblReservedQty, ISNULL((ISNULL(l.dblWeight,0) - ISNULL(c.dblReservedQty,0)),0) AS dblAvailableQty,
l.intWeightUOMId AS intItemUOMId ,u.strUnitMeasure AS strUOM, 
ROUND((ISNULL((ISNULL(l.dblWeight,0) - ISNULL(c.dblReservedQty,0)),0)/ case when ISNULL(iu1.dblUnitQty,0)=0 then 1 else iu1.dblUnitQty end ),0) AS dblAvailableUnit,
l.dblLastCost AS dblUnitCost,iu1.dblUnitQty AS dblWeightPerUnit,u.strUnitMeasure AS strWeightPerUnitUOM,
l.intItemUOMId  AS intPhysicalItemUOMId,l.dtmDateCreated AS dtmReceiveDate,l.dtmExpiryDate,ISNULL(' ','') AS strVendorId,ISNULL(l.strVendorLotNo,'') AS strVendorLotNo,
l.strVendorLocation AS strGarden,l.intLocationId,
cl.strLocationName AS strLocationName,
sbl.strSubLocationName,
sl.strName AS strStorageLocationName,
l.strNotes AS strRemarks,
i.dblRiskScore,
ri.dblQuantity/@dblRecipeQty AS dblConfigRatio,
0.0 AS dblDensity,
0.0 AS dblScore
from tblICLot l
Left Join @tblReservedQty c on l.intLotId=c.intLotId
Join tblICItem i on l.intItemId=i.intItemId
Join tblICItemUOM iu on l.intWeightUOMId=iu.intItemUOMId
Join tblICUnitMeasure u on iu.intUnitMeasureId=u.intUnitMeasureId
Join tblSMCompanyLocation cl on cl.intCompanyLocationId=l.intLocationId
Left Join tblSMCompanyLocationSubLocation sbl on sbl.intCompanyLocationSubLocationId=l.intSubLocationId
Left Join tblICStorageLocation sl on sl.intStorageLocationId=l.intStorageLocationId
Join tblICItemUOM iu1 on l.intItemUOMId=iu1.intItemUOMId
--Left Join vyuAPVendor v on l.intVendorId=v.intVendorId
Left Join tblMFRecipeItem ri on ri.intItemId=i.intItemId
Where l.intItemId=@intItemId and l.dblWeight>0 and ri.intRecipeItemId=@intRecipeItemId Order by l.dtmDateCreated

