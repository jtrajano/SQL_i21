﻿CREATE PROCEDURE [dbo].[uspMFGetPickListAvailableLots]
	@intParentLotId int,
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
Declare @intItemId int
Declare @index int
Declare @id int
Declare @dblRecipeQty NUMERIC(38,20)
Declare @dblQtyToProduce NUMERIC(38,20)

Declare @tblReservedQty table
(
	intLotId int,
	dblReservedQty numeric(38,20)
)

Declare @tblItem table
(
	intItemId int,
	dblReqQty numeric(38,20),
	ysnIsSubstitute bit
)

Declare @tblWorkOrder table
(
	intRowNo int Identity(1,1),
	intWorkOrderId int
)

--Get the Comma Separated Work Order Ids into a table
SET @index = CharIndex(',',@strWorkOrderIds)
WHILE @index > 0
BEGIN
        SET @id = SUBSTRING(@strWorkOrderIds,1,@index-1)
        SET @strWorkOrderIds = SUBSTRING(@strWorkOrderIds,@index+1,LEN(@strWorkOrderIds)-@index)

        INSERT INTO @tblWorkOrder(intWorkOrderId) values (@id)
        SET @index = CharIndex(',',@strWorkOrderIds)
END
SET @id=@strWorkOrderIds
INSERT INTO @tblWorkOrder(intWorkOrderId) values (@id)

Select TOP 1 @intManufacturingProcessId=intManufacturingProcessId From tblMFManufacturingProcess where intAttributeTypeId=2

Select TOP 1 @intWorkOrderId=intWorkOrderId From tblMFWorkOrder Where intWorkOrderId=(Select TOP 1 intWorkOrderId From @tblWorkOrder)

Select @intItemId=intItemId From tblICParentLot Where intParentLotId=@intParentLotId

Select @dblQtyToProduce=SUM(dblQuantity) From tblMFWorkOrder Where intWorkOrderId IN (Select intWorkOrderId From @tblWorkOrder)

SELECT @intKitStagingLocationId = pa.strAttributeValue
FROM tblMFManufacturingProcessAttribute pa
JOIN tblMFAttribute at ON pa.intAttributeId = at.intAttributeId
WHERE intManufacturingProcessId = @intManufacturingProcessId
	AND intLocationId = @intLocationId
	AND at.strAttributeName = 'Kit Staging Location'

SELECT @intBlendStagingLocationId = ISNULL(intBlendProductionStagingUnitId, 0)
FROM tblSMCompanyLocation
WHERE intCompanyLocationId = @intLocationId

--Substitute Items
Insert into @tblItem(intItemId,dblReqQty,ysnIsSubstitute)
Select intSubstituteItemId,dblQuantity,1 From tblMFWorkOrderRecipeSubstituteItem Where intWorkOrderId=@intWorkOrderId AND intItemId=@intItemId

--Main Input Item
Insert into @tblItem(intItemId,dblReqQty,ysnIsSubstitute)
Select @intItemId,(Select TOP 1 dblQuantity From tblMFWorkOrderRecipeItem Where intWorkOrderId=@intWorkOrderId AND intItemId=@intItemId ),0

Select @dblRecipeQty=dblQuantity From tblMFWorkOrderRecipe Where intWorkOrderId=@intWorkOrderId

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
From tblICStockReservation sr Join #tempLot tl on sr.intLotId=tl.intLotId
group by sr.intLotId

Select tl.*,
ISNULL(rq.dblReservedQty,0) AS dblReservedQty, ISNULL((ISNULL(tl.dblPhysicalQty,0) - ISNULL(rq.dblReservedQty,0)),0) AS dblAvailableQty,
ROUND((ISNULL((ISNULL(tl.dblPhysicalQty,0) - ISNULL(rq.dblReservedQty,0)),0)/ case when ISNULL(tl.dblWeightPerUnit,0)=0 then 1 else tl.dblWeightPerUnit end ),0) AS dblAvailableUnit
from #tempLot tl Left Join @tblReservedQty rq on tl.intLotId=rq.intLotId 
Where ISNULL((ISNULL(tl.dblPhysicalQty,0) - ISNULL(rq.dblReservedQty,0)),0) > 0