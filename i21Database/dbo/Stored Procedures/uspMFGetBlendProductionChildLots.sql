CREATE PROCEDURE [dbo].[uspMFGetBlendProductionChildLots]
@intWorkOrderId int
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

Declare @tblReservedQty table
(
	intLotId int,
	dblReservedQty numeric(18,6)
)
Insert into @tblReservedQty
Select cl.intLotId,Sum(cl.dblQuantity) AS dblReservedQty 
From tblMFWorkOrderConsumedLot cl 
Join tblMFWorkOrder w on cl.intWorkOrderId=w.intWorkOrderId
join tblICLot l on l.intLotId=cl.intLotId
where w.intWorkOrderId=@intWorkOrderId and w.intStatusId<>13
group by cl.intLotId

Select wcl.intWorkOrderConsumedLotId,wcl.intWorkOrderId,l.intLotId,l.strLotNumber,i.intItemId,i.strItemNo,i.strDescription,
wcl.dblQuantity,wcl.intItemUOMId,um.strUnitMeasure AS strUOM,wcl.dblIssuedQuantity, 
wcl.intItemIssuedUOMId,iu2.strUnitMeasure AS strIssuedUOM,
sl.strName AS strStorageLocationName,i.dblRiskScore,ISNULL(wcl.ysnStaged,0) AS ysnStaged,
(ISNULL(l.dblWeight,0) - ISNULL(rq.dblReservedQty,0)) AS dblAvailableQty,ISNULL(l.dblWeightPerQty,0) AS dblWeightPerUnit,
wcl.intRecipeItemId,l.intParentLotId,pl.strParentLotNumber
from tblMFWorkOrderConsumedLot wcl
Join tblICLot l on wcl.intLotId=l.intLotId
Join tblICItem i on l.intItemId=i.intItemId
Join tblICItemUOM iu on wcl.intItemUOMId=iu.intItemUOMId
Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
Join tblICItemUOM iu1 on wcl.intItemIssuedUOMId=iu1.intItemUOMId
Join tblICUnitMeasure iu2 on iu1.intUnitMeasureId=iu2.intUnitMeasureId
Left Join tblICStorageLocation sl on l.intStorageLocationId=sl.intStorageLocationId
Left Join tblICParentLot pl on l.intParentLotId=pl.intParentLotId 
Left Join @tblReservedQty rq on l.intLotId=rq.intLotId
Where wcl.intWorkOrderId=@intWorkOrderId