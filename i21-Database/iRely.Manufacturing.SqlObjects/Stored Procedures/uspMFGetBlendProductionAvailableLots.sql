
CREATE PROCEDURE [dbo].[uspMFGetBlendProductionAvailableLots]
	@intParentLotId int,
	@intItemId int,
	@intLocationId int,
	@ysnShowAllPallets bit,
	@intItemUOMId int=0,
	@intManufacturingProcessId int=0
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

Declare @ysnEnableParentLot bit=0
Declare @strRecipeItemUOM nvarchar(50)
Declare @strSourceLocationIds NVARCHAR(MAX)

Select TOP 1 @ysnEnableParentLot=ISNULL(ysnEnableParentLot,0) From tblMFCompanyPreference
Select @strRecipeItemUOM=um.strUnitMeasure 
From tblICItemUOM iu join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
Where iu.intItemUOMId=@intItemUOMId

SELECT @strSourceLocationIds = ISNULL(pa.strAttributeValue, '')
FROM tblMFManufacturingProcessAttribute pa
JOIN tblMFAttribute at ON pa.intAttributeId = at.intAttributeId
WHERE intManufacturingProcessId = @intManufacturingProcessId
	AND intLocationId = @intLocationId
	AND at.strAttributeName = 'Source Location'

Declare @tblSourceStorageLocation AS Table
(
	intStorageLocationId int
)

If ISNULL(@strSourceLocationIds,'')<>''
Begin
	Insert Into @tblSourceStorageLocation
	Select * from dbo.fnCommaSeparatedValueToTable(@strSourceLocationIds)
End
Else
Begin
	Insert Into @tblSourceStorageLocation
	Select intStorageLocationId from tblICStorageLocation Where intLocationId=@intLocationId AND ISNULL(ysnAllowConsume,0)=1
End

Declare @tblReservedQty table
(
	intLotId int,
	dblReservedQty numeric(38,20)
)

Insert into @tblReservedQty
Select sr.intLotId,Sum(sr.dblQty) AS dblReservedQty 
From tblICStockReservation sr 
where sr.intItemId=@intItemId AND ISNULL(sr.ysnPosted,0)=0
group by sr.intLotId

Select l.intLotId,l.strLotNumber,l.intItemId,i.strItemNo,i.strDescription,ISNULL(l.strLotAlias,'') AS strLotAlias,
CASE WHEN isnull(l.dblWeight,0)>0 Then l.dblWeight Else dbo.fnMFConvertQuantityToTargetItemUOM(l.intItemUOMId,@intItemUOMId,l.dblQty) End AS dblPhysicalQty,
ISNULL(c.dblReservedQty,0) AS dblReservedQty, 
ISNULL((ISNULL(CASE WHEN isnull(l.dblWeight,0)>0 Then l.dblWeight Else dbo.fnMFConvertQuantityToTargetItemUOM(l.intItemUOMId,@intItemUOMId,l.dblQty) End,0) 
- ISNULL(c.dblReservedQty,0)),0) AS dblAvailableQty,
ISNULL(l.intWeightUOMId,@intItemUOMId) AS intItemUOMId ,ISNULL(u.strUnitMeasure,@strRecipeItemUOM) AS strUOM, 
ROUND((ISNULL((ISNULL(CASE WHEN isnull(l.dblWeight,0)>0 Then l.dblWeight Else dbo.fnMFConvertQuantityToTargetItemUOM(l.intItemUOMId,@intItemUOMId,l.dblQty) End,0) 
- ISNULL(c.dblReservedQty,0)),0)/ case when ISNULL(iu1.dblUnitQty,0)=0 then 1 else iu1.dblUnitQty end ),0) AS dblAvailableUnit,
l.dblLastCost AS dblUnitCost,iu1.dblUnitQty AS dblWeightPerUnit,u.strUnitMeasure AS strWeightPerUnitUOM,
l.intItemUOMId  AS intPhysicalItemUOMId,l.dtmDateCreated AS dtmReceiveDate,l.dtmExpiryDate,ISNULL(' ','') AS strVendorId,ISNULL(l.strVendorLotNo,'') AS strVendorLotNo,
l.strGarden AS strGarden,l.intLocationId,
cl.strLocationName AS strLocationName,
sbl.strSubLocationName,
sl.strName AS strStorageLocationName,
l.strNotes AS strRemarks,
i.dblRiskScore,
ISNULL(l.intParentLotId,0) AS intParentLotId,
sl.intStorageLocationId,
ISNULL(pl.strParentLotNumber,'') AS strParentLotNumber,
i.strLotTracking,
i.intCategoryId
into #tempLot
from tblICLot l
Left Join @tblReservedQty c on l.intLotId=c.intLotId
Join tblICItem i on l.intItemId=i.intItemId
Left Join tblICItemUOM iu on l.intWeightUOMId=iu.intItemUOMId
Left Join tblICUnitMeasure u on iu.intUnitMeasureId=u.intUnitMeasureId
Join tblSMCompanyLocation cl on cl.intCompanyLocationId=l.intLocationId
Left Join tblSMCompanyLocationSubLocation sbl on sbl.intCompanyLocationSubLocationId=l.intSubLocationId
Left Join tblICStorageLocation sl on sl.intStorageLocationId=l.intStorageLocationId
Left Join tblICStorageUnitType ut on sl.intStorageUnitTypeId=ut.intStorageUnitTypeId AND ut.strInternalCode <> 'PROD_STAGING'
Join @tblSourceStorageLocation tsl on sl.intStorageLocationId=tsl.intStorageLocationId
Join tblICItemUOM iu1 on l.intItemUOMId=iu1.intItemUOMId
--Left Join vyuAPVendor v on l.intVendorId=v.intVendorId
Join tblICLotStatus ls on l.intLotStatusId=ls.intLotStatusId
Left Join tblICParentLot pl on l.intParentLotId=pl.intParentLotId
Where l.intItemId=@intItemId and l.dblQty>0 and ls.strPrimaryStatus='Active' 
And l.intLocationId = @intLocationId AND ISNULL(sl.ysnAllowConsume,0)=1
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


