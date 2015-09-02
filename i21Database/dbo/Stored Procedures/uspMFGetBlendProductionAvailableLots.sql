
CREATE PROCEDURE [dbo].[uspMFGetBlendProductionAvailableLots]
	@intParentLotId int,
	@intItemId int,
	@intLocationId int,
	@ysnShowAllPallets bit
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

Declare @ysnEnableParentLot bit=0

Select TOP 1 @ysnEnableParentLot=ISNULL(ysnEnableParentLot,0) From tblMFCompanyPreference

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
ISNULL(l.intParentLotId,0) AS intParentLotId,
sl.intStorageLocationId,
ISNULL(pl.strParentLotNumber,'') AS strParentLotNumber
into #tempLot
from tblICLot l
Left Join @tblReservedQty c on l.intLotId=c.intLotId
Join tblICItem i on l.intItemId=i.intItemId
Join tblICItemUOM iu on l.intWeightUOMId=iu.intItemUOMId
Join tblICUnitMeasure u on iu.intUnitMeasureId=u.intUnitMeasureId
Join tblSMCompanyLocation cl on cl.intCompanyLocationId=l.intLocationId
Left Join tblSMCompanyLocationSubLocation sbl on sbl.intCompanyLocationSubLocationId=l.intSubLocationId
Left Join tblICStorageLocation sl on sl.intStorageLocationId=l.intStorageLocationId
Left Join tblICStorageUnitType ut on sl.intStorageUnitTypeId=ut.intStorageUnitTypeId AND ut.strInternalCode <> 'PROD_STAGING'
Join tblICItemUOM iu1 on l.intItemUOMId=iu1.intItemUOMId
--Left Join vyuAPVendor v on l.intVendorId=v.intVendorId
Join tblICLotStatus ls on l.intLotStatusId=ls.intLotStatusId
Left Join tblICParentLot pl on l.intParentLotId=pl.intParentLotId
Where l.intItemId=@intItemId and l.dblWeight>0 and ls.strPrimaryStatus='Active' 
And l.intLocationId = @intLocationId
Order by l.dtmExpiryDate, l.dtmDateCreated

If @ysnEnableParentLot=0
Begin
	Select * from #tempLot
End
Else
Begin
	if @ysnShowAllPallets=0
	Begin
		Select * from #tempLot where intParentLotId=@intParentLotId
	End
	Else
	Begin
		Select * from #tempLot where intParentLotId <> 0
	End
End


