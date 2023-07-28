--liquibase formatted sql

-- changeset Von:vyuICGetInventoryShipmentItemLotByLocation.sql.1 runOnChange:true splitStatements:false
-- comment: RK-1234

CREATE OR ALTER VIEW [dbo].[vyuICGetInventoryShipmentItemLotByLocation]
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
	, Lot.strItemUOM
	, ShipmentItem.dblItemUOMConv
	, ShipmentItem.strUnitType
	, Lot.strWeightUOM
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
	, Lot.strStorageLocation
	, Lot.dblQty AS dblLotQty
	, ShipmentItemLot.dblQuantityShipped
	, strLotUOM = Lot.strItemUOM
	, ShipmentItemLot.dblGrossWeight
	, ShipmentItemLot.dblTareWeight
	, dblNetWeight = ISNULL(ShipmentItemLot.dblGrossWeight, 0) - ISNULL(ShipmentItemLot.dblTareWeight, 0)
	, ShipmentItem.intCurrencyId
	, ShipmentItem.strCurrency
	, Lot.dblAvailableQty
	, ShipmentItemLot.strWarehouseCargoNumber 
	, dblWeightPerQty = Lot.dblWeightPerQty
	, ShipmentItemLot.intConcurrencyId
	, intQtyUOMDecimalPlaces = ShipmentItem.intDecimalPlaces
	, intGrossUOMDecimalPlaces = ShipmentItem.intGrossUOMDecimalPlaces
	, intItemId = ShipmentItem.intItemId
	, intItemUOMId = ShipmentItem.intItemUOMId
	, intWeightUOMId = ShipmentItem.intWeightUOMId
	, strShipQtyUOM = ShipmentItem.strUnitMeasure
	, dblDestinationQuantityShipped = ShipmentItemLot.dblDestinationQuantityShipped
	, dblDestinationGrossWeight = ShipmentItemLot.dblDestinationGrossWeight
	, dblDestinationTareWeight = ShipmentItemLot.dblDestinationTareWeight
    , permission.intEntityId intUserId
    , permission.intUserRoleID intRoleId
FROM tblICInventoryShipmentItemLot ShipmentItemLot
	LEFT JOIN vyuICGetInventoryShipmentItem ShipmentItem ON ShipmentItem.intInventoryShipmentItemId = ShipmentItemLot.intInventoryShipmentItemId
	LEFT JOIN vyuICGetLot Lot ON Lot.intLotId = ShipmentItemLot.intLotId
	INNER JOIN tblICInventoryShipment Shipment ON Shipment.intInventoryShipmentId = ShipmentItem.intInventoryShipmentId
    INNER JOIN vyuICUserCompanyLocations permission ON permission.intCompanyLocationId = Shipment.intShipFromLocationId



