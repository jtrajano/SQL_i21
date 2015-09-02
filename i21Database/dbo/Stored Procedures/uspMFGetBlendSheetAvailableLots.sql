﻿
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
Declare @intManufacturingProcessId int
Declare @ysnShowOtherFactoryLots bit
Declare @ysnShowAvailableLotsByStorageLocation bit
Declare @ysnEnableParentLot bit=0

Select TOP 1 @ysnEnableParentLot=ISNULL(ysnEnableParentLot,0) From tblMFCompanyPreference

Select TOP 1 @intManufacturingProcessId=intManufacturingProcessId From tblMFManufacturingProcess Where intAttributeTypeId=2

Select @ysnShowOtherFactoryLots=CASE When UPPER(pa.strAttributeValue) = 'TRUE' then 1 Else 0 End 
From tblMFManufacturingProcessAttribute pa Join tblMFAttribute at on pa.intAttributeId=at.intAttributeId
Where intManufacturingProcessId=@intManufacturingProcessId and intLocationId=@intLocationId 
and at.strAttributeName='Show Other Factory Lots'

Select @ysnShowAvailableLotsByStorageLocation=CASE When UPPER(pa.strAttributeValue) = 'TRUE' then 1 Else 0 End 
From tblMFManufacturingProcessAttribute pa Join tblMFAttribute at on pa.intAttributeId=at.intAttributeId
Where intManufacturingProcessId=@intManufacturingProcessId and intLocationId=@intLocationId 
and at.strAttributeName='Show Available Lots By Storage Location'

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
--ISNULL(c.dblReservedQty,0) AS dblReservedQty, ISNULL((ISNULL(l.dblWeight,0) - ISNULL(c.dblReservedQty,0)),0) AS dblAvailableQty,
l.intWeightUOMId AS intItemUOMId ,u.strUnitMeasure AS strUOM, 
--ROUND((ISNULL((ISNULL(l.dblWeight,0) - ISNULL(c.dblReservedQty,0)),0)/ case when ISNULL(iu1.dblUnitQty,0)=0 then 1 else iu1.dblUnitQty end ),0) AS dblAvailableUnit,
l.dblLastCost AS dblUnitCost,iu1.dblUnitQty AS dblWeightPerUnit,u.strUnitMeasure AS strWeightPerUnitUOM,
l.intItemUOMId  AS intPhysicalItemUOMId,l.dtmDateCreated AS dtmReceiveDate,l.dtmExpiryDate,ISNULL(' ','') AS strVendorId,ISNULL(l.strVendorLotNo,'') AS strVendorLotNo,
l.strVendorLocation AS strGarden,l.intLocationId,
cl.strLocationName AS strLocationName,
sbl.strSubLocationName,
sl.strName AS strStorageLocationName,
l.strNotes AS strRemarks,
i.dblRiskScore,
ri.dblQuantity/@dblRecipeQty AS dblConfigRatio,
CAST(ISNULL(q.Density,0) AS decimal) AS dblDensity,
CAST(ISNULL(q.Score,0) AS decimal) AS dblScore,
l.intParentLotId,
sl.intStorageLocationId
into #tempLot
from tblICLot l
--Left Join @tblReservedQty c on l.intLotId=c.intLotId
Join tblICItem i on l.intItemId=i.intItemId
Join tblICItemUOM iu on l.intWeightUOMId=iu.intItemUOMId
Join tblICUnitMeasure u on iu.intUnitMeasureId=u.intUnitMeasureId
Join tblSMCompanyLocation cl on cl.intCompanyLocationId=l.intLocationId
Left Join tblSMCompanyLocationSubLocation sbl on sbl.intCompanyLocationSubLocationId=l.intSubLocationId
Left Join tblICStorageLocation sl on sl.intStorageLocationId=l.intStorageLocationId
Left Join tblICStorageUnitType ut on sl.intStorageUnitTypeId=ut.intStorageUnitTypeId AND ut.strInternalCode <> 'PROD_STAGING'
Join tblICItemUOM iu1 on l.intItemUOMId=iu1.intItemUOMId
--Left Join vyuAPVendor v on l.intVendorId=v.intVendorId
Left Join tblMFRecipeItem ri on ri.intItemId=i.intItemId and ri.intRecipeItemId=@intRecipeItemId
Left Join vyuQMGetLotQuality q on l.intLotId=q.intLotId
Join tblICLotStatus ls on l.intLotStatusId=ls.intLotStatusId
Where l.intItemId=@intItemId and l.dblWeight>0 and ls.strPrimaryStatus='Active' 
And l.intLocationId = Case When @ysnShowOtherFactoryLots=1 Then l.intLocationId Else @intLocationId End 
Order by l.dtmExpiryDate, l.dtmDateCreated



--Parent Lot
If @ysnEnableParentLot=0
Begin
		Select tl.intLotId, tl.strLotNumber, tl.intItemId, tl.strItemNo, tl.strDescription, 
		tl.strLotAlias, tl.dblPhysicalQty, 
		ISNULL(r.dblReservedQty,0) AS dblReservedQty, ISNULL((ISNULL(tl.dblPhysicalQty,0) - ISNULL(r.dblReservedQty,0)),0) AS dblAvailableQty,
		ROUND((ISNULL((ISNULL(tl.dblPhysicalQty,0) - ISNULL(r.dblReservedQty,0)),0)/ case when ISNULL(tl.dblWeightPerUnit,0)=0 then 1 else tl.dblWeightPerUnit end ),0) AS dblAvailableUnit,
		tl.intItemUOMId, tl.strUOM, tl.dblUnitCost, tl.dblWeightPerUnit, tl.strWeightPerUnitUOM, 
		tl.intPhysicalItemUOMId, tl.dtmReceiveDate, tl.dtmExpiryDate, tl.strVendorId, tl.strVendorLotNo, 
		tl.strGarden, tl.intLocationId, tl.strLocationName, tl.strSubLocationName, tl.strStorageLocationName,tl.intStorageLocationId, 
		tl.strRemarks, tl.dblRiskScore, tl.dblConfigRatio, tl.dblDensity, tl.dblScore, tl.intParentLotId,
		CAST(0 AS bit) AS ysnParentLot 
		from #tempLot tl Left Join @tblReservedQty r on tl.intLotId=r.intLotId
End
Else
Begin
	If @ysnShowAvailableLotsByStorageLocation=1
	Begin
		Select pl.intParentLotId AS intLotId, pl.strParentLotNumber AS strLotNumber, tl.intItemId, tl.strItemNo, tl.strDescription, 
		MAX(tl.strLotAlias) AS strLotAlias, SUM(tl.dblPhysicalQty) AS dblPhysicalQty, tl.intItemUOMId, 
		tl.strUOM, MAX(tl.dblUnitCost) AS dblUnitCost, AVG(tl.dblWeightPerUnit) AS dblWeightPerUnit, tl.strWeightPerUnitUOM, 
		tl.intPhysicalItemUOMId, MAX(tl.dtmReceiveDate) AS dtmReceiveDate, MAX(tl.dtmExpiryDate) AS dtmExpiryDate, MAX(tl.strVendorId) AS strVendorId, MAX(tl.strVendorLotNo) AS strVendorLotNo, 
		MAX(tl.strGarden) AS strGarden, tl.intLocationId, tl.strLocationName, MAX(tl.strSubLocationName) AS strSubLocationName, tl.strStorageLocationName AS strStorageLocationName,tl.intStorageLocationId, 
		MAX(tl.strRemarks) AS strRemarks, MAX(tl.dblRiskScore) AS dblRiskScore, MAX(tl.dblConfigRatio) AS dblConfigRatio, MAX(tl.dblDensity) AS dblDensity, 
		MAX(tl.dblScore) AS dblScore,CAST(1 AS bit) AS ysnParentLot
		into #tempParentLotByStorageLocation
		From #tempLot tl Join tblICParentLot pl on tl.intParentLotId=pl.intParentLotId 
		Group By pl.intParentLotId, pl.strParentLotNumber, tl.intItemId, tl.strItemNo, tl.strDescription,
		tl.intItemUOMId,tl.strUOM, tl.strWeightPerUnitUOM,
		tl.intPhysicalItemUOMId,tl.intLocationId, tl.strLocationName,tl.strStorageLocationName,tl.intStorageLocationId

		Select tpl.*,
		ISNULL(r.dblReservedQty,0) AS dblReservedQty, ISNULL((ISNULL(tpl.dblPhysicalQty,0) - ISNULL(r.dblReservedQty,0)),0) AS dblAvailableQty,
		ROUND((ISNULL((ISNULL(tpl.dblPhysicalQty,0) - ISNULL(r.dblReservedQty,0)),0)/ case when ISNULL(tpl.dblWeightPerUnit,0)=0 then 1 else tpl.dblWeightPerUnit end ),0) AS dblAvailableUnit
		from #tempParentLotByStorageLocation tpl Left Join @tblReservedQty r on tpl.intLotId=r.intLotId	
	End
	Else
	Begin
		Select pl.intParentLotId AS intLotId, pl.strParentLotNumber AS strLotNumber, tl.intItemId, tl.strItemNo, tl.strDescription, 
		tl.strLotAlias, SUM(tl.dblPhysicalQty) AS dblPhysicalQty, tl.intItemUOMId, 
		tl.strUOM, MAX(tl.dblUnitCost) AS dblUnitCost, AVG(tl.dblWeightPerUnit) AS dblWeightPerUnit, tl.strWeightPerUnitUOM, 
		tl.intPhysicalItemUOMId, MAX(tl.dtmReceiveDate) AS dtmReceiveDate, MAX(tl.dtmExpiryDate) AS dtmExpiryDate, MAX(tl.strVendorId) AS strVendorId, MAX(tl.strVendorLotNo) AS strVendorLotNo, 
		MAX(tl.strGarden) AS strGarden, tl.intLocationId, tl.strLocationName, '' AS strSubLocationName, '' AS strStorageLocationName,0 AS intStorageLocationId,
		MAX(tl.strRemarks) AS strRemarks, MAX(tl.dblRiskScore) AS dblRiskScore, MAX(tl.dblConfigRatio) AS dblConfigRatio, MAX(tl.dblDensity) AS dblDensity, 
		MAX(tl.dblScore) AS dblScore,CAST(1 AS bit) AS ysnParentLot 
		into #tempParentLotByLocation
		From #tempLot tl Join tblICParentLot pl on tl.intParentLotId=pl.intParentLotId 
		Group By pl.intParentLotId, pl.strParentLotNumber, tl.intItemId, tl.strItemNo, tl.strDescription,tl.strLotAlias,
		tl.intItemUOMId,tl.strUOM,tl.strWeightPerUnitUOM,
		tl.intPhysicalItemUOMId, tl.intLocationId, tl.strLocationName

		Select tpl.*,
		ISNULL(r.dblReservedQty,0) AS dblReservedQty, ISNULL((ISNULL(tpl.dblPhysicalQty,0) - ISNULL(r.dblReservedQty,0)),0) AS dblAvailableQty,
		ROUND((ISNULL((ISNULL(tpl.dblPhysicalQty,0) - ISNULL(r.dblReservedQty,0)),0)/ case when ISNULL(tpl.dblWeightPerUnit,0)=0 then 1 else tpl.dblWeightPerUnit end ),0) AS dblAvailableUnit
		from #tempParentLotByLocation tpl Left Join @tblReservedQty r on tpl.intLotId=r.intLotId
	End
End