CREATE VIEW [dbo].[vyuICGetInventoryShipmentItem]
	AS 

SELECT ShipmentItem.intInventoryShipmentId
	, ShipmentItem.intInventoryShipmentItemId
	, Shipment.strOrderType
	, Shipment.strSourceType
	, Shipment.strShipmentNumber
	, Shipment.strShipFromLocation
	, Shipment.strShipToLocation
	, Shipment.strBOLNumber
	, Shipment.dtmShipDate
	, Shipment.strCustomerNumber
	, Shipment.strCustomerName
	, Shipment.ysnPosted
	, ShipmentItem.intLineNo
	, ShipmentItem.intOrderId
	, ShipmentItemSource.strOrderNumber
	, ShipmentItem.intSourceId
	, ShipmentItemSource.strSourceNumber
	, Item.strItemNo
	, strItemDescription = Item.strDescription
	, Item.strLotTracking
	, Item.intCommodityId
	, ShipmentItem.intSubLocationId
	, SubLocation.strSubLocationName
	, ShipmentItem.intStorageLocationId
	, strStorageLocationName = StorageLocation.strName
	, strOrderUOM = ShipmentItemSource.strOrderUOM
	, strUnitMeasure = UOM.strUnitMeasure
	, dblItemUOMConv = ItemUOM.dblUnitQty
	, strUnitType = UOM.strUnitType
	, ShipmentItem.intCurrencyId
	, Currency.strCurrency
	, strWeightUOM = WeightUOM.strUnitMeasure
	, dblWeightItemUOMConv = ItemWeightUOM.dblUnitQty
	, dblUnitCost = ShipmentItemSource.dblCost
	, dblQtyOrdered = ISNULL(ShipmentItemSource.dblQtyOrdered, 0)
    , dblQtyAllocated = ISNULL(ShipmentItemSource.dblQtyAllocated, 0)
    , dblUnitPrice = ISNULL(ShipmentItemSource.dblUnitPrice, 0)
    , dblDiscount = ISNULL(ShipmentItemSource.dblDiscount, 0)
    , dblTotal = ISNULL(ShipmentItemSource.dblTotal, 0)
	, dblQtyToShip = ISNULL(ShipmentItem.dblQuantity, 0)
	, dblPrice = ISNULL(ShipmentItem.dblUnitPrice, 0)
	, dblLineTotal = ISNULL(ShipmentItem.dblQuantity, 0) * ISNULL(ShipmentItem.dblUnitPrice, 0)
	, ShipmentItem.intGradeId
	, strGrade = Grade.strDescription
	, ShipmentItem.intDiscountSchedule
	, strDiscountSchedule = DiscountSchedule.strDiscountId
	, strStorageTypeDescription = StorageType.strStorageTypeDescription
FROM tblICInventoryShipmentItem ShipmentItem
	LEFT JOIN vyuICGetInventoryShipment Shipment ON Shipment.intInventoryShipmentId = ShipmentItem.intInventoryShipmentId
	LEFT JOIN vyuICGetShipmentItemSource ShipmentItemSource ON ShipmentItemSource.intInventoryShipmentItemId = ShipmentItem.intInventoryShipmentItemId
	LEFT JOIN tblICItem Item ON Item.intItemId = ShipmentItem.intItemId
	LEFT JOIN tblSMCompanyLocationSubLocation SubLocation ON SubLocation.intCompanyLocationSubLocationId = ShipmentItem.intSubLocationId
	LEFT JOIN tblICStorageLocation StorageLocation ON StorageLocation.intStorageLocationId = ShipmentItem.intStorageLocationId
	LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = ShipmentItem.intItemUOMId
	LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
	LEFT JOIN tblICItemUOM ItemWeightUOM ON ItemWeightUOM.intItemUOMId = ShipmentItem.intWeightUOMId
	LEFT JOIN tblICUnitMeasure WeightUOM ON WeightUOM.intUnitMeasureId = ItemWeightUOM.intUnitMeasureId    
	LEFT JOIN tblICCommodityAttribute Grade ON Grade.intCommodityAttributeId = ShipmentItem.intGradeId
	LEFT JOIN tblGRDiscountId DiscountSchedule ON DiscountSchedule.intDiscountId = ShipmentItem.intDiscountSchedule
	LEFT JOIN tblSMCurrency Currency ON Currency.intCurrencyID = ShipmentItem.intCurrencyId
	LEFT JOIN tblGRCustomerStorage CustomerStorage ON CustomerStorage.intCustomerStorageId = ShipmentItem.intCustomerStorageId
	LEFT JOIN tblGRStorageType StorageType ON StorageType.intStorageScheduleTypeId = CustomerStorage.intStorageTypeId