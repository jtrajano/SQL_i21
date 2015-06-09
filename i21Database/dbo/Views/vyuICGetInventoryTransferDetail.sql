CREATE VIEW [dbo].[vyuICGetInventoryTransferDetail]
	AS 

SELECT TransferDetail.intInventoryTransferId
	, TransferDetail.intInventoryTransferDetailId
	, TransferDetail.intSourceId
	, strSourceNumber = (
		CASE WHEN Transfer.intSourceType = 1 -- Scale
				THEN (SELECT CAST(ISNULL(intTicketNumber, 'Ticket Number not found!')AS NVARCHAR(50)) FROM tblSCTicket WHERE intTicketId = TransferDetail.intSourceId)
			WHEN Transfer.intSourceType = 2 -- Inbound Shipment
				THEN (SELECT CAST(ISNULL(intTrackingNumber, 'Inbound Shipment not found!')AS NVARCHAR(50)) FROM tblLGShipment WHERE intShipmentId = TransferDetail.intSourceId)
			ELSE NULL
			END
	)
	, Item.strItemNo
	, strItemDescription = Item.strDescription
	, Lot.strLotNumber
	, strFromSubLocationName = FromSubLocation.strSubLocationName
	, strToSubLocationName = ToSubLocation.strSubLocationName
	, strFromStorageLocationName = FromStorageLocation.strName
	, strToStorageLocationName = ToStorageLocation.strName
	, strUnitMeasure = UOM.strUnitMeasure
	, strWeightUOM = WeightUOM.strUnitMeasure
	, TaxCode.strTaxCode
	, strAvailableUOM = CASE WHEN ISNULL(Lot.intLotId, '') = '' THEN StockFrom.strUnitMeasure ELSE Lot.strItemUOM END
	, StockFrom.dblOnHand
	, StockFrom.dblOnOrder
	, StockFrom.dblReservedQty
	, dblAvailableQty = CASE WHEN ISNULL(Lot.intLotId, '') = '' THEN StockFrom.dblAvailableQty ELSE Lot.dblQty END
FROM tblICInventoryTransferDetail TransferDetail
	LEFT JOIN tblICInventoryTransfer Transfer ON Transfer.intInventoryTransferId = TransferDetail.intInventoryTransferId
	LEFT JOIN tblICItem Item ON Item.intItemId = TransferDetail.intItemId
	LEFT JOIN vyuICGetLot Lot ON Lot.intLotId = TransferDetail.intLotId
	LEFT JOIN tblSMCompanyLocationSubLocation FromSubLocation ON FromSubLocation.intCompanyLocationSubLocationId = TransferDetail.intFromSubLocationId
	LEFT JOIN tblSMCompanyLocationSubLocation ToSubLocation ON ToSubLocation.intCompanyLocationSubLocationId = TransferDetail.intToSubLocationId
	LEFT JOIN tblICStorageLocation FromStorageLocation ON FromStorageLocation.intStorageLocationId = TransferDetail.intFromStorageLocationId
	LEFT JOIN tblICStorageLocation ToStorageLocation ON ToStorageLocation.intStorageLocationId = TransferDetail.intToStorageLocationId
	LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = TransferDetail.intItemUOMId
	LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
	LEFT JOIN tblICItemUOM ItemWeightUOM ON ItemWeightUOM.intItemUOMId = TransferDetail.intItemWeightUOMId
	LEFT JOIN tblICUnitMeasure WeightUOM ON WeightUOM.intUnitMeasureId = ItemWeightUOM.intUnitMeasureId
	LEFT JOIN tblSMTaxCode TaxCode ON TaxCode.intTaxCodeId = TransferDetail.intTaxCodeId
	LEFT JOIN vyuICGetItemStockUOM StockFrom ON StockFrom.intItemId = TransferDetail.intItemId
		AND StockFrom.intLocationId = Transfer.intFromLocationId
		AND StockFrom.intItemUOMId = TransferDetail.intItemUOMId
		AND StockFrom.intSubLocationId = TransferDetail.intFromSubLocationId
		AND StockFrom.intStorageLocationId = TransferDetail.intFromStorageLocationId
