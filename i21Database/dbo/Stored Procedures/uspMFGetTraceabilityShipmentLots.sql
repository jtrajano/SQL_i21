CREATE PROCEDURE [dbo].[uspMFGetTraceabilityShipmentLots]
	@intInventoryShipmentId int,
	@ysnParentLot bit=0
AS

	If @ysnParentLot=0
		Select 'Ship' AS strTransactionName,t.intLotId,t.strLotNumber,t.strLotAlias,t.intItemId,t.strItemNo,t.strDescription,
		t.intCategoryId,t.strCategoryCode,SUM(t.dblQuantity) AS dblQuantity,MAX(t.strUOM) AS strUOM,
		MAX(t.dtmTransactionDate) AS dtmTransactionDate,t.intParentLotId,'L' AS strType,t.intImageTypeId
		FROM (  
		Select DISTINCT 'Ship' AS strTransactionName,l.intLotId,l.strLotNumber,l.strLotAlias,i.intItemId,i.strItemNo,i.strDescription,
		mt.intCategoryId,mt.strCategoryCode,shl.dblQuantityShipped AS dblQuantity,um.strUnitMeasure AS strUOM,
		sh.dtmShipDate AS dtmTransactionDate,l.intParentLotId,
		4 AS intImageTypeId
		from tblICInventoryShipmentItemLot shl 
		Join tblICInventoryShipmentItem shi on shl.intInventoryShipmentItemId=shi.intInventoryShipmentItemId
		Join tblICInventoryShipment sh on sh.intInventoryShipmentId=shi.intInventoryShipmentId  
		Join tblICLot l on shl.intLotId=l.intLotId
		Join tblICItem i on l.intItemId=i.intItemId
		Join tblICCategory mt on mt.intCategoryId=i.intCategoryId
		Join tblICItemUOM iu on shi.intItemUOMId=iu.intItemUOMId
		Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
		Where sh.intInventoryShipmentId=@intInventoryShipmentId) t
		group by t.strTransactionName,t.intItemId,t.strItemNo,t.strDescription,intCategoryId,t.strCategoryCode,t.intLotId,t.strLotNumber,
		t.strLotAlias,t.intParentLotId,t.intImageTypeId

	If @ysnParentLot=1
		Select 'Ship' AS strTransactionName,t.intLotId,t.strLotNumber,t.strLotAlias,t.intItemId,t.strItemNo,t.strDescription,
		t.intCategoryId,t.strCategoryCode,SUM(t.dblQuantity) AS dblQuantity,MAX(t.strUOM) AS strUOM,
		MAX(t.dtmTransactionDate) AS dtmTransactionDate,t.intParentLotId,'L' AS strType,t.intImageTypeId
		FROM (  
		Select DISTINCT 'Ship' AS strTransactionName,pl.intParentLotId AS intLotId, pl.strParentLotNumber AS strLotNumber,pl.strParentLotAlias AS strLotAlias,i.intItemId,i.strItemNo,i.strDescription,
		mt.intCategoryId,mt.strCategoryCode,shl.dblQuantityShipped AS dblQuantity,um.strUnitMeasure AS strUOM,
		sh.dtmShipDate AS dtmTransactionDate,l.intParentLotId,
		4 AS intImageTypeId
		from tblICInventoryShipmentItemLot shl 
		Join tblICInventoryShipmentItem shi on shl.intInventoryShipmentItemId=shi.intInventoryShipmentItemId
		Join tblICInventoryShipment sh on sh.intInventoryShipmentId=shi.intInventoryShipmentId  
		Join tblICLot l on shl.intLotId=l.intLotId
		Join tblICParentLot pl on l.intParentLotId=pl.intParentLotId
		Join tblICItem i on l.intItemId=i.intItemId
		Join tblICCategory mt on mt.intCategoryId=i.intCategoryId
		Join tblICItemUOM iu on shi.intItemUOMId=iu.intItemUOMId
		Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
		Where sh.intInventoryShipmentId=@intInventoryShipmentId) t
		group by t.strTransactionName,t.intItemId,t.strItemNo,t.strDescription,intCategoryId,t.strCategoryCode,t.intLotId,t.strLotNumber,
		t.strLotAlias,t.intParentLotId,t.intImageTypeId
