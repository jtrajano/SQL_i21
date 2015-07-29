CREATE VIEW [dbo].[vyuICGetInventoryReceiptItemLot]
	AS

SELECT ReceiptItemLot.intInventoryReceiptItemLotId
	, ReceiptItemLot.intInventoryReceiptItemId
	, ReceiptItemLot.intLotId
	, ReceiptItemLot.strLotNumber
	, ReceiptItemLot.strLotAlias
	, ReceiptItemLot.intSubLocationId
	, SubLocation.strSubLocationName
	, ReceiptItemLot.intStorageLocationId
	, strStorageLocationName = StorageLocation.strName
	, ReceiptItemLot.intItemUnitMeasureId
	, ItemUOM.dblUnitQty
	, UOM.strUnitMeasure
	, UOM.strUnitType
	, ReceiptItemLot.dblQuantity
	, ReceiptItemLot.dblGrossWeight
	, ReceiptItemLot.dblTareWeight
	, ReceiptItemLot.dblCost
	, ReceiptItemLot.intUnitPallet
	, ReceiptItemLot.dblStatedGrossPerUnit
	, ReceiptItemLot.dblStatedTarePerUnit
	, ReceiptItemLot.strContainerNo
	, ReceiptItemLot.intEntityVendorId
	, Vendor.strVendorId
	, ReceiptItemLot.intVendorLocationId
	, strVendorLocation = VendorLocation.strLocationName
	, ReceiptItemLot.strMarkings
	, ReceiptItemLot.intOriginId
	, strOrigin = Origin.strCountry
	, ReceiptItemLot.intGradeId
	, strGrade = Grade.strDescription
	, ReceiptItemLot.intSeasonCropYear
	, ReceiptItemLot.strVendorLotId
	, ReceiptItemLot.dtmManufacturedDate
	, ReceiptItemLot.strRemarks
	, ReceiptItemLot.strCondition
	, ReceiptItemLot.dtmCertified
	, ReceiptItemLot.dtmExpiryDate
	, ReceiptItemLot.intSort
FROM tblICInventoryReceiptItemLot ReceiptItemLot
LEFT JOIN tblSMCompanyLocationSubLocation SubLocation ON SubLocation.intCompanyLocationSubLocationId = ReceiptItemLot.intSubLocationId
LEFT JOIN tblICStorageLocation StorageLocation ON StorageLocation.intStorageLocationId = ReceiptItemLot.intStorageLocationId
LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = ReceiptItemLot.intItemUnitMeasureId
LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
LEFT JOIN tblAPVendor Vendor ON Vendor.intEntityVendorId = ReceiptItemLot.intEntityVendorId
LEFT JOIN tblEntityLocation VendorLocation ON VendorLocation.intEntityLocationId = ReceiptItemLot.intVendorLocationId
LEFT JOIN tblSMCountry Origin ON Origin.intCountryID = ReceiptItemLot.intOriginId
LEFT JOIN tblICCommodityAttribute Grade ON Grade.intCommodityAttributeId = ReceiptItemLot.intGradeId