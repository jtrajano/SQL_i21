CREATE PROCEDURE [dbo].[uspMFGetPickListDetails]
	@intPickListId int
AS

Declare @intKitStatusId int

Select @intKitStatusId=intKitStatusId from tblMFPickList Where intPickListId=@intPickListId

Declare @tblReservedQty table
(
	intLotId int,
	dblReservedQty numeric(18,6)
)

If @intKitStatusId = 7
Begin
	Insert @tblReservedQty(intLotId,dblReservedQty)
	Select sr.intLotId,sum(sr.dblQty) 
	from tblMFPickListDetail pld join tblICStockReservation sr on pld.intLotId=sr.intLotId 
	Where pld.intPickListId=@intPickListId
	Group by sr.intLotId

	Select pld.intPickListDetailId,pld.intPickListId,pld.intLotId,l.strLotNumber,l.strLotAlias,l.intParentLotId,pl.strParentLotNumber,
	l.intItemId,i.strItemNo,i.strDescription,pld.intStorageLocationId,sl.strName AS strStorageLocationName,
	pld.dblQuantity,pld.intItemUOMId,um.strUnitMeasure AS strUOM,pld.dblIssuedQuantity,pld.intItemIssuedUOMId,um1.strUnitMeasure AS strIssuedUOM, 
	ISNULL(l.dblWeight,0) - ISNULL(rq.dblReservedQty,0) AS dblAvailableQty,ISNULL(rq.dblReservedQty,0) AS dblReservedQty,
	pld.dblPickQuantity,pld.intPickUOMId,um1.strUnitMeasure AS strPickUOM,
	pld.intStageLotId,(ISNULL(l.dblWeight,0) - ISNULL(rq.dblReservedQty,0))/ (Case When ISNULL(l.dblWeightPerQty,0)=0 Then 1 Else l.dblWeightPerQty End) AS dblAvailableUint,
	um1.strUnitMeasure AS strAvailableUnitUOM,l.dblWeightPerQty AS dblWeightPerUnit
	From tblMFPickListDetail pld Join tblICLot l on pld.intLotId=l.intLotId 
	Join tblICParentLot pl on l.intParentLotId=pl.intParentLotId 
	Join tblICItem i on l.intItemId=i.intItemId
	Join tblICStorageLocation sl on l.intStorageLocationId=sl.intStorageLocationId
	Join tblICItemUOM iu on pld.intItemUOMId=iu.intItemUOMId
	Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
	Join tblICItemUOM iu1 on pld.intItemUOMId=iu1.intItemUOMId
	Join tblICUnitMeasure um1 on iu1.intUnitMeasureId=um1.intUnitMeasureId
	Left Join @tblReservedQty rq on pld.intLotId=rq.intLotId
	Where pld.intPickListId=@intPickListId
End

If @intKitStatusId=12
Begin
	Insert @tblReservedQty(intLotId,dblReservedQty)
	Select sr.intLotId,sum(sr.dblQty) 
	from tblMFPickListDetail pld join tblICStockReservation sr on pld.intStageLotId=sr.intLotId 
	Where pld.intPickListId=@intPickListId
	Group by sr.intLotId

	Select pld.intPickListDetailId,pld.intPickListId,pld.intStageLotId AS intLotId,l.strLotNumber,l.strLotAlias,l.intParentLotId,pl.strParentLotNumber,
	l.intItemId,i.strItemNo,i.strDescription,pld.intStorageLocationId,sl.strName AS strStorageLocationName,
	pld.dblQuantity,pld.intItemUOMId,um.strUnitMeasure AS strUOM,pld.dblIssuedQuantity,pld.intItemIssuedUOMId,um1.strUnitMeasure AS strIssuedUOM, 
	ISNULL(l.dblWeight,0) - ISNULL(rq.dblReservedQty,0) AS dblAvailableQty,ISNULL(rq.dblReservedQty,0) AS dblReservedQty,
	pld.dblPickQuantity,pld.intPickUOMId,um1.strUnitMeasure AS strPickUOM,
	pld.intStageLotId,(ISNULL(l.dblWeight,0) - ISNULL(rq.dblReservedQty,0))/ (Case When ISNULL(l.dblWeightPerQty,0)=0 Then 1 Else l.dblWeightPerQty End) AS dblAvailableUint,
	um1.strUnitMeasure AS strAvailableUnitUOM,l.dblWeightPerQty AS dblWeightPerUnit
	From tblMFPickListDetail pld Join tblICLot l on pld.intStageLotId=l.intLotId 
	Left Join tblICParentLot pl on l.intParentLotId=pl.intParentLotId 
	Join tblICItem i on l.intItemId=i.intItemId
	Join tblICStorageLocation sl on l.intStorageLocationId=sl.intStorageLocationId
	Join tblICItemUOM iu on pld.intItemUOMId=iu.intItemUOMId
	Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
	Join tblICItemUOM iu1 on pld.intItemUOMId=iu1.intItemUOMId
	Join tblICUnitMeasure um1 on iu1.intUnitMeasureId=um1.intUnitMeasureId
	Left Join @tblReservedQty rq on pld.intStageLotId=rq.intLotId
	Where pld.intPickListId=@intPickListId
End