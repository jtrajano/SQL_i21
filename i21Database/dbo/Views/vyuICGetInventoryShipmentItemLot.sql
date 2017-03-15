CREATE VIEW [dbo].[vyuICGetInventoryShipmentItemLot]
	AS 

SELECT ShipmentItem.intInventoryShipmentId
	, ShipmentItem.intInventoryShipmentItemId
	, ShipmentItemLot.intInventoryShipmentItemLotId
	, ShipmentItem.strOrderType
	, ShipmentItem.strSourceType
	, ShipmentItem.strShipmentNumber
	, ShipmentItem.strShipFromLocation
	, ShipmentItem.strShipToLocation
	, ShipmentItem.strBOLNumber
	, ShipmentItem.dtmShipDate
	, ShipmentItem.strCustomerNumber
	, ShipmentItem.strCustomerName
	, ShipmentItem.ysnPosted
	, ShipmentItem.intLineNo
	, ShipmentItem.intOrderId
	, ShipmentItem.strOrderNumber
	, ShipmentItem.intSourceId
	, ShipmentItem.strSourceNumber
	, ShipmentItem.strItemNo
	, ShipmentItem.strItemDescription
	, ShipmentItem.strLotTracking
	, ShipmentItem.intCommodityId
	, ShipmentItem.strOrderUOM
	, ShipmentItem.strUnitMeasure
	, ShipmentItem.dblItemUOMConv
	, ShipmentItem.strUnitType
	, ShipmentItem.strWeightUOM
	, ShipmentItem.dblWeightItemUOMConv
	, ShipmentItem.dblQtyOrdered
    , ShipmentItem.dblQtyAllocated
    , ShipmentItem.dblUnitPrice
    , ShipmentItem.dblDiscount
    , ShipmentItem.dblTotal
	, ShipmentItem.dblQtyToShip
	, ShipmentItem.dblPrice
	, ShipmentItem.dblLineTotal
	, ShipmentItem.intGradeId
	, ShipmentItem.strGrade
	, Lot.intLotId
	, Lot.strLotNumber
	, Lot.strLotAlias
	, Lot.intSubLocationId
	, Lot.strSubLocationName
	, Lot.intStorageLocationId
	, strStorageLocationName = Lot.strStorageLocation
	, dblLotQty = ShipmentItemLot.dblQuantityShipped
	, strLotUOM = Lot.strItemUOM
	, ShipmentItemLot.dblGrossWeight
	, ShipmentItemLot.dblTareWeight
	, dblNetWeight = ISNULL(ShipmentItemLot.dblGrossWeight, 0) - ISNULL(ShipmentItemLot.dblTareWeight, 0)
	, ShipmentItem.intCurrencyId
	, ShipmentItem.strCurrency
FROM tblICInventoryShipmentItemLot ShipmentItemLot
	LEFT JOIN vyuICGetInventoryShipmentItem ShipmentItem ON ShipmentItem.intInventoryShipmentItemId = ShipmentItemLot.intInventoryShipmentItemId
	LEFT JOIN vyuICGetLot Lot ON Lot.intLotId = ShipmentItemLot.intLotId
	