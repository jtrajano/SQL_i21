CREATE VIEW [dbo].[vyuICGetInventoryTransferDetail]
	AS 

SELECT TransferDetail.intInventoryTransferDetailId
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
	, strAvailableUOM = StockFrom.strUnitMeasure
	, StockFrom.dblOnHand
	, StockFrom.dblOnOrder
	, StockFrom.dblReservedQty
	, StockFrom.dblAvailableQty
FROM tblICInventoryTransferDetail TransferDetail
LEFT JOIN tblICItem Item ON Item.intItemId = TransferDetail.intItemId
LEFT JOIN tblICLot Lot ON Lot.intLotId = TransferDetail.intLotId
LEFT JOIN tblSMCompanyLocationSubLocation FromSubLocation ON FromSubLocation.intCompanyLocationSubLocationId = TransferDetail.intFromSubLocationId
LEFT JOIN tblSMCompanyLocationSubLocation ToSubLocation ON ToSubLocation.intCompanyLocationSubLocationId = TransferDetail.intToSubLocationId
LEFT JOIN tblICStorageLocation FromStorageLocation ON FromStorageLocation.intStorageLocationId = TransferDetail.intFromStorageLocationId
LEFT JOIN tblICStorageLocation ToStorageLocation ON ToStorageLocation.intStorageLocationId = TransferDetail.intToStorageLocationId
LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = TransferDetail.intItemUOMId
LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
LEFT JOIN tblICItemUOM ItemWeightUOM ON ItemWeightUOM.intItemUOMId = TransferDetail.intItemWeightUOMId
LEFT JOIN tblICUnitMeasure WeightUOM ON WeightUOM.intUnitMeasureId = ItemWeightUOM.intUnitMeasureId
LEFT JOIN tblSMTaxCode TaxCode ON TaxCode.intTaxCodeId = TransferDetail.intTaxCodeId
INNER JOIN tblICInventoryTransfer Transfer ON Transfer.intInventoryTransferId = TransferDetail.intInventoryTransferId
LEFT JOIN vyuICGetItemStockUOM StockFrom ON StockFrom.intItemId = TransferDetail.intItemId
	AND StockFrom.intLocationId = Transfer.intFromLocationId
	AND StockFrom.intItemUOMId = TransferDetail.intItemUOMId
	AND StockFrom.intSubLocationId = TransferDetail.intFromSubLocationId
	AND StockFrom.intStorageLocationId = TransferDetail.intFromStorageLocationId