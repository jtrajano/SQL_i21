CREATE VIEW [dbo].[vyuICGetInventoryShipmentItem]
AS 

SELECT ShipmentItem.intInventoryShipmentId
	, ShipmentItem.intInventoryShipmentItemId
	, intContractSeq = ShipmentItemSource.intContractSeq
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
	, ShipmentItem.dblGross
	, ShipmentItem.dblTare
	, dblNet = ShipmentItem.dblNet
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
	, intDecimalPlaces = UOM.intDecimalPlaces
	, intUnitMeasureId = UOM.intUnitMeasureId
	, strUnitType = UOM.strUnitType
	, intCurrencyId = Currency.intCurrencyID
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
	, ShipmentItemSource.ysnLoad
	, ShipmentItemSource.intNoOfLoad
	, ShipmentItemSource.dblBalance
	, ShipmentItem.intLoadShipped
	, ShipmentItemSource.dblQuantityPerLoad
	, ShipmentItem.intGradeId
	, strGrade = Grade.strDescription
	, ShipmentItem.intDiscountSchedule
	, strDiscountSchedule = DiscountSchedule.strDiscountId
	, strStorageTypeDescription = StorageType.strStorageTypeDescription
	, intDestinationWeightId = ShipmentItem.intDestinationWeightId
	, strDestinationWeights = DestWeights.strWeightGradeDesc
	, intDestinationGradeId = ShipmentItem.intDestinationGradeId
	, strDestinationGrades = DestGrades.strWeightGradeDesc
	--, ShipmentItem.dblDestinationGrossQty
	--, ShipmentItem.dblDestinationNetQty
	--, ShipmentItem.intDestinationQtyUOMId
	--, strDestinationQtyUOM = DestinationQtyUOM.strUnitMeasure
	, strForexRateType = forexRateType.strCurrencyExchangeRateType
	, strDockDoor = DockDoor.strName
	, ShipmentItem.dblDestinationQuantity
	, strPriceUOM = ISNULL(PriceUOM.strUnitMeasure, UOM.strUnitMeasure) 
	, dblPriceUOMConv = ISNULL(ItemPriceUOM.dblUnitQty, ItemUOM.dblUnitQty)
	, ShipmentItemSource.strFieldNo
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
	--LEFT JOIN tblICUnitMeasure DestinationQtyUOM ON DestinationQtyUOM.intUnitMeasureId = ShipmentItem.intDestinationQtyUOMId
	LEFT JOIN tblICCommodityAttribute Grade ON Grade.intCommodityAttributeId = ShipmentItem.intGradeId
	LEFT JOIN tblGRDiscountId DiscountSchedule ON DiscountSchedule.intDiscountId = ShipmentItem.intDiscountSchedule
	LEFT JOIN tblSMCurrency Currency ON Currency.intCurrencyID = Shipment.intCurrencyId
	LEFT JOIN tblGRStorageType StorageType ON StorageType.intStorageScheduleTypeId = ShipmentItem.intStorageScheduleTypeId
	LEFT JOIN tblCTWeightGrade DestWeights ON DestWeights.intWeightGradeId = ShipmentItem.intDestinationWeightId
	LEFT JOIN tblCTWeightGrade DestGrades ON DestGrades.intWeightGradeId = ShipmentItem.intDestinationGradeId
	LEFT JOIN tblSMCurrencyExchangeRateType forexRateType ON ShipmentItem.intForexRateTypeId = forexRateType.intCurrencyExchangeRateTypeId
	LEFT JOIN tblICStorageLocation DockDoor ON DockDoor.intStorageLocationId = ShipmentItem.intDockDoorId
	LEFT JOIN tblICItemUOM ItemPriceUOM ON ItemPriceUOM.intItemUOMId = ShipmentItem.intPriceUOMId
	LEFT JOIN tblICUnitMeasure PriceUOM ON PriceUOM.intUnitMeasureId = ItemPriceUOM.intUnitMeasureId    