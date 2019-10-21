CREATE PROCEDURE [dbo].[uspMFGetPickListAvailableLots]
	@intParentLotId int,
	@intItemId int,
	@intLocationId int,
	@strWorkOrderIds nvarchar(max)
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @intKitStagingLocationId INT
DECLARE @intBlendStagingLocationId INT
DECLARE @intManufacturingProcessId INT
Declare @intWorkOrderId INT
Declare @index int
Declare @id int
Declare @dblRecipeQty NUMERIC(38,20)
Declare @dblQtyToProduce NUMERIC(38,20)
Declare @strLotTracking nvarchar(50)
Declare @ysnIncludeKitStagingLocation bit=0
Declare @dblDefaultResidueQty NUMERIC(38,20)

Declare @tblReservedQty table
(
	intLotId int,
	dblReservedQty numeric(38,20)
)

Declare @tblItem table
(
	intItemId int,
	dblReqQty numeric(38,20),
	ysnIsSubstitute bit,
	intItemUOMId int
)

Declare @tblWorkOrder table
(
	intRowNo int Identity(1,1),
	intWorkOrderId int
)

--Get the Comma Separated Work Order Ids into a table
INSERT INTO @tblWorkOrder(intWorkOrderId) 
Select * from dbo.[fnCommaSeparatedValueToTable](@strWorkOrderIds)

Select TOP 1 @dblDefaultResidueQty=ISNULL(dblDefaultResidueQty,0.00001) From tblMFCompanyPreference

Select TOP 1 @intManufacturingProcessId=w.intManufacturingProcessId From tblMFWorkOrder w join @tblWorkOrder tw on w.intWorkOrderId=tw.intWorkOrderId

Select TOP 1 @intWorkOrderId=intWorkOrderId From tblMFWorkOrder Where intWorkOrderId=(Select TOP 1 intWorkOrderId From @tblWorkOrder)

Select @dblQtyToProduce=SUM(dblQuantity) From tblMFWorkOrder Where intWorkOrderId IN (Select intWorkOrderId From @tblWorkOrder)

SELECT @intKitStagingLocationId = pa.strAttributeValue
FROM tblMFManufacturingProcessAttribute pa
JOIN tblMFAttribute at ON pa.intAttributeId = at.intAttributeId
WHERE intManufacturingProcessId = @intManufacturingProcessId
	AND intLocationId = @intLocationId
	AND at.strAttributeName = 'Kit Staging Location'

SELECT @ysnIncludeKitStagingLocation = CASE 
		WHEN UPPER(pa.strAttributeValue) = 'TRUE'
			THEN 1
		ELSE 0
		END
FROM tblMFManufacturingProcessAttribute pa
JOIN tblMFAttribute at ON pa.intAttributeId = at.intAttributeId
WHERE intManufacturingProcessId = @intManufacturingProcessId
	AND intLocationId = @intLocationId
	AND at.strAttributeName = 'Include Kit Staging Location In Pick List'

If ISNULL(@ysnIncludeKitStagingLocation,0)=1 
	Set @intKitStagingLocationId=0

SELECT @intBlendStagingLocationId = ISNULL(intBlendProductionStagingUnitId, 0)
FROM tblSMCompanyLocation
WHERE intCompanyLocationId = @intLocationId

--Substitute Items
Insert into @tblItem(intItemId,dblReqQty,ysnIsSubstitute,intItemUOMId)
Select intSubstituteItemId,dblQuantity,1,intItemUOMId From tblMFWorkOrderRecipeSubstituteItem Where intWorkOrderId=@intWorkOrderId AND intItemId=@intItemId

--Main Input Item
Insert into @tblItem(intItemId,dblReqQty,ysnIsSubstitute,intItemUOMId)
Select @intItemId,(Select TOP 1 dblQuantity From tblMFWorkOrderRecipeItem Where intWorkOrderId=@intWorkOrderId AND intItemId=@intItemId ),0,
(Select TOP 1 intItemUOMId From tblMFWorkOrderRecipeItem Where intWorkOrderId=@intWorkOrderId AND intItemId=@intItemId )

Select @dblRecipeQty=dblQuantity From tblMFWorkOrderRecipe Where intWorkOrderId=@intWorkOrderId

Select @strLotTracking=strLotTracking From tblICItem where intItemId=@intItemId

If @strLotTracking = 'No'
Begin
	Select 0 AS intLotId,'' AS strLotNumber,sd.intItemId,i.strItemNo,i.strDescription,'' AS strLotAlias,
	dbo.fnMFConvertQuantityToTargetItemUOM(sd.intItemUOMId,ti.intItemUOMId,sd.dblAvailableQty) AS dblPhysicalQty,
	ti.intItemUOMId,um.strUnitMeasure AS strUOM,ti.intItemUOMId AS intItemIssuedUOMId,um.strUnitMeasure AS strIssuedUOM,
	sd.intLocationId,sd.intSubLocationId,sd.intStorageLocationId,sl.strName AS strStorageLocationName,csl.strSubLocationName,
	0 AS intParentLotId,sd.dblUnitQty AS dblWeightPerUnit,'' AS strParentLotNumber,ti.ysnIsSubstitute,ti.dblReqQty AS dblRequiredQty,
	sd.dblReservedQty,sd.dblAvailableQty,sd.dblAvailableQty AS dblAvailableUnit
	From vyuMFGetItemStockDetail sd
	JOIN @tblItem ti on sd.intItemId=ti.intItemId
	JOIN tblICItem i ON sd.intItemId=i.intItemId
	Left JOIN tblICStorageLocation sl ON sd.intStorageLocationId=sl.intStorageLocationId
	JOIN tblSMCompanyLocationSubLocation csl ON sd.intSubLocationId=csl.intCompanyLocationSubLocationId	 
	Join tblICItemUOM iu on ti.intItemUOMId=iu.intItemUOMId
	Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
	Where sd.intItemId=@intItemId AND sd.dblAvailableQty > @dblDefaultResidueQty AND sd.intLocationId=@intLocationId AND ISNULL(sd.ysnStockUnit,0)=1 
	AND sd.intStorageLocationId NOT IN (@intKitStagingLocationId,@intBlendStagingLocationId) 
	ORDER BY sd.intItemStockUOMId
End
Else
Begin
	Select l.intLotId,l.strLotNumber,l.intItemId,i.strItemNo,i.strDescription,ISNULL(l.strLotAlias,'') AS strLotAlias,l.dblWeight AS dblPhysicalQty,
	l.intWeightUOMId AS intItemUOMId ,um.strUnitMeasure AS strUOM, 
	l.intItemUOMId AS intItemIssuedUOMId ,um1.strUnitMeasure AS strIssuedUOM,
	sl.intStorageLocationId,
	sl.strName AS strStorageLocationName,
	l.intParentLotId,
	l.dblWeightPerQty AS dblWeightPerUnit,
	pl.strParentLotNumber,ti.ysnIsSubstitute,(ti.dblReqQty * (@dblQtyToProduce / @dblRecipeQty)) AS dblRequiredQty
	into #tempLot
	from @tblItem ti Join tblICLot l on ti.intItemId=l.intItemId
	Join tblICItem i on l.intItemId=i.intItemId
	Join tblICItemUOM iu on l.intWeightUOMId=iu.intItemUOMId
	Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
	Join tblICStorageLocation sl on sl.intStorageLocationId=l.intStorageLocationId
	Join tblICItemUOM iu1 on l.intItemUOMId=iu1.intItemUOMId
	Join tblICUnitMeasure um1 on iu1.intUnitMeasureId=um1.intUnitMeasureId
	Join tblICLotStatus ls on l.intLotStatusId=ls.intLotStatusId
	Join tblICParentLot pl on l.intParentLotId=pl.intParentLotId
	Where l.dblQty>0 and ls.strPrimaryStatus='Active' 
	And l.intLocationId=@intLocationId  And ISNULL(sl.ysnAllowConsume,0)=1 
	AND l.intStorageLocationId NOT IN (@intKitStagingLocationId,@intBlendStagingLocationId) 

	Insert into @tblReservedQty
	Select sr.intLotId,Sum(sr.dblQty) AS dblReservedQty 
	From tblICStockReservation sr Join #tempLot tl on sr.intLotId=tl.intLotId Where ISNULL(sr.ysnPosted,0)=0
	group by sr.intLotId

	Select tl.*,
	ISNULL(rq.dblReservedQty,0) AS dblReservedQty, ISNULL((ISNULL(tl.dblPhysicalQty,0) - ISNULL(rq.dblReservedQty,0)),0) AS dblAvailableQty,
	ROUND((ISNULL((ISNULL(tl.dblPhysicalQty,0) - ISNULL(rq.dblReservedQty,0)),0)/ case when ISNULL(tl.dblWeightPerUnit,0)=0 then 1 else tl.dblWeightPerUnit end ),0) AS dblAvailableUnit
	from #tempLot tl Left Join @tblReservedQty rq on tl.intLotId=rq.intLotId 
	Where ISNULL((ISNULL(tl.dblPhysicalQty,0) - ISNULL(rq.dblReservedQty,0)),0) > 0
End