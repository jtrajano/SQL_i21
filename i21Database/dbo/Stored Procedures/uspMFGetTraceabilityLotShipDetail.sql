CREATE PROCEDURE [dbo].[uspMFGetTraceabilityLotShipDetail]
	@intLotId int
AS
	Select 'Ship' AS strTransactionName,sh.intInventoryShipmentId,sh.strShipmentNumber,'' AS strLotAlias,i.intItemId,i.strItemNo,i.strDescription,
	mt.strCategoryCode,shl.dblQuantityShipped AS dblQuantity,
	um.strUnitMeasure AS strUOM,
	sh.dtmShipDate AS dtmTransactionDate,c.strName ,'S' AS strType
	from tblICInventoryShipmentItemLot shl 
	Join tblICInventoryShipmentItem shi on shl.intInventoryShipmentItemId=shi.intInventoryShipmentItemId
	Join tblICInventoryShipment sh on sh.intInventoryShipmentId=shi.intInventoryShipmentId  
	Join tblICLot l on shl.intLotId=l.intLotId
	Join tblICItem i on l.intItemId=i.intItemId
	Join tblICCategory mt on mt.intCategoryId=i.intCategoryId
	Join tblICItemUOM iu on shi.intItemUOMId=iu.intItemUOMId
	Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
	Left Join vyuARCustomer c on sh.intEntityCustomerId=c.intEntityCustomerId
	Where shl.intLotId=@intLotId
