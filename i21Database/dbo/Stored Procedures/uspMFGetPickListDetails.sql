CREATE PROCEDURE [dbo].[uspMFGetPickListDetails]
	@intPickListId int
AS
Select pld.intPickListDetailId,pld.intPickListId,pld.intLotId,l.strLotNumber,l.strLotAlias,l.intParentLotId,pl.strParentLotNumber,
l.intItemId,i.strItemNo,i.strDescription,pld.intStorageLocationId,sl.strName AS strStorageLocationName,
pld.dblQuantity,pld.intItemUOMId,um.strUnitMeasure AS strUOM,pld.dblIssuedQuantity,pld.intItemIssuedUOMId,um1.strUnitMeasure AS strIssuedUOM, 
0.0 AS dblAvailableQty,0.0 AS dblReservedQty,
pld.dblPickQuantity,pld.intPickUOMId,um1.strUnitMeasure AS strPickUOM,
pld.intStageLotId,0.0 AS dblAvailableUint,um1.strUnitMeasure AS strAvailableUnitUOM,0.0 AS dblWeightPerUnit
From tblMFPickListDetail pld Join tblICLot l on pld.intLotId=l.intLotId 
Join tblICParentLot pl on l.intParentLotId=pl.intParentLotId 
Join tblICItem i on l.intItemId=i.intItemId
Join tblICStorageLocation sl on pld.intStorageLocationId=sl.intStorageLocationId
Join tblICItemUOM iu on pld.intItemUOMId=iu.intItemUOMId
Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
Join tblICItemUOM iu1 on pld.intItemUOMId=iu1.intItemUOMId
Join tblICUnitMeasure um1 on iu1.intUnitMeasureId=um1.intUnitMeasureId
Where pld.intPickListId=@intPickListId