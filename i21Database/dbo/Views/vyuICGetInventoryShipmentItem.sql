CREATE VIEW [dbo].[vyuICGetInventoryShipmentItem]
	AS 

SELECT ShipmentItem.intInventoryShipmentId
	, ShipmentItem.intInventoryShipmentItemId
	, ShipmentItem.intLineNo
	, ShipmentItem.intOrderId
	, ShipmentItemSource.strOrderNumber
	, ShipmentItem.intSourceId
	, ShipmentItemSource.strSourceNumber
	, Item.strItemNo
	, strItemDescription = Item.strDescription
	, Item.strLotTracking
	, ShipmentItem.intSubLocationId
	, SubLocation.strSubLocationName
	, strOrderUOM = ShipmentItemSource.strOrderUOM
	, strUnitMeasure = UOM.strUnitMeasure
	, strUnitType = UOM.strUnitType
	, strWeightUOM = WeightUOM.strUnitMeasure
	, dblQtyOrdered = ISNULL(ShipmentItemSource.dblQtyOrdered, 0)
    , dblQtyAllocated = ISNULL(ShipmentItemSource.dblQtyAllocated, 0)
    , dblUnitPrice = ISNULL(ShipmentItemSource.dblUnitPrice, 0)
    , dblDiscount = ISNULL(ShipmentItemSource.dblDiscount, 0)
    , dblTotal = ISNULL(ShipmentItemSource.dblTotal, 0)
	, ShipmentItem.intGradeId
	, strGrade = Grade.strDescription
FROM tblICInventoryShipmentItem ShipmentItem
	LEFT JOIN vyuICGetShipmentItemSource ShipmentItemSource ON ShipmentItemSource.intInventoryShipmentItemId = ShipmentItem.intInventoryShipmentItemId
	LEFT JOIN tblICItem Item ON Item.intItemId = ShipmentItem.intItemId
	LEFT JOIN tblSMCompanyLocationSubLocation SubLocation ON SubLocation.intCompanyLocationSubLocationId = ShipmentItem.intSubLocationId
	LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = ShipmentItem.intItemUOMId
	LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
	LEFT JOIN tblICItemUOM ItemWeightUOM ON ItemWeightUOM.intItemUOMId = ShipmentItem.intWeightUOMId
	LEFT JOIN tblICUnitMeasure WeightUOM ON WeightUOM.intUnitMeasureId = ItemWeightUOM.intUnitMeasureId    
	LEFT JOIN tblICCommodityAttribute Grade ON Grade.intCommodityAttributeId = ShipmentItem.intGradeId