CREATE VIEW [dbo].[vyuICGetInventoryReceiptItemLot]
	AS

SELECT 
	receiptItemLot.intInventoryReceiptItemLotId
	,receiptItemLot.intInventoryReceiptItemId
	,receiptItem.intInventoryReceiptId
	,receiptItem.strReceiptNumber
	,receiptItem.strReceiptType
	,receiptItem.strOrderNumber
	,receiptItem.intLocationId
	,receiptItem.strLocationName
	,receiptItem.strSourceType
	,receiptItem.strSourceNumber 
	,receiptItem.dtmReceiptDate
	,receiptItem.strBillOfLading
	,receiptItem.ysnPosted
	,receiptItem.strItemNo
	,receiptItem.strItemDescription
	,strItemUOM = receiptItem.strUnitMeasure
	,receiptItemLot.intLotId
	,receiptItemLot.strLotNumber
	,receiptItemLot.strLotAlias
	,receiptItemLot.intSubLocationId
	,SubLocation.strSubLocationName
	,receiptItemLot.intStorageLocationId
	,strStorageLocationName = StorageLocation.strName
	,receiptItemLot.intItemUnitMeasureId
	,ItemUOM.dblUnitQty
	,UOM.strUnitMeasure
	,UOM.strUnitType
	,receiptItemLot.dblQuantity
	,receiptItemLot.dblGrossWeight
	,receiptItemLot.dblTareWeight
	,dblNetWeight = ISNULL(receiptItemLot.dblGrossWeight, 0) - ISNULL(receiptItemLot.dblTareWeight, 0)
	,receiptItemLot.dblCost
	,receiptItemLot.intUnitPallet
	,receiptItemLot.dblStatedGrossPerUnit
	,receiptItemLot.dblStatedTarePerUnit
	,receiptItemLot.strContainerNo
	,receiptItemLot.intEntityVendorId
	,Vendor.strVendorId
	,receiptItemLot.strGarden
	,receiptItemLot.strMarkings
	,receiptItemLot.intOriginId
	,strOrigin = Origin.strCountry
	,receiptItemLot.intGradeId
	,strGrade = Grade.strDescription
	,receiptItemLot.intSeasonCropYear
	,receiptItemLot.strVendorLotId
	,receiptItemLot.dtmManufacturedDate
	,receiptItemLot.strRemarks
	,receiptItemLot.strCondition
	,receiptItemLot.dtmCertified
	,receiptItemLot.dtmExpiryDate
	,receiptItemLot.intSort		
	,receiptItemLot.intParentLotId
	,receiptItemLot.strParentLotNumber
	,receiptItemLot.strParentLotAlias
	,receiptItemLot.dblStatedNetPerUnit
	,receiptItemLot.dblStatedTotalNet
	,receiptItemLot.dblPhysicalVsStated
	,receiptItem.intCurrencyId
	,receiptItem.strCurrency
	,receiptItem.strBook
	,receiptItem.strSubBook
	,receiptItemLot.strCertificate
	,strProducer = Producer.strName
	,receiptItemLot.strCertificateId
	,receiptItemLot.strTrackingNumber
	,strWeightUOM = WeightUOM.strUnitMeasure
	,intGrossUOMDecimalPlaces = WeightUOM.intDecimalPlaces
	,intQtyUOMDecimalPlaces = UOM.intDecimalPlaces
	,receiptItem.strCommodityCode
	,receiptItem.strCommodity
	,receiptItem.strCategoryCode
	,receiptItem.strCategory
	,receiptItem.intCategoryId
	,receiptItem.intCommodityId
	,receiptItem.intBookId
	,receiptItem.intSubBookId
FROM tblICInventoryReceiptItemLot receiptItemLot
LEFT JOIN vyuICGetInventoryReceiptItem receiptItem ON receiptItem.intInventoryReceiptItemId = receiptItemLot.intInventoryReceiptItemId
LEFT JOIN tblICInventoryReceiptItem rItem ON rItem.intInventoryReceiptItemId = receiptItem.intInventoryReceiptItemId
LEFT JOIN tblSMCompanyLocationSubLocation SubLocation ON SubLocation.intCompanyLocationSubLocationId = receiptItem.intSubLocationId
LEFT JOIN tblICStorageLocation StorageLocation ON StorageLocation.intStorageLocationId = receiptItemLot.intStorageLocationId
LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = receiptItemLot.intItemUnitMeasureId
LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
LEFT JOIN tblICItemUOM WeightItemUOM ON WeightItemUOM.intItemUOMId = rItem.intWeightUOMId
LEFT JOIN tblICUnitMeasure WeightUOM ON WeightUOM.intUnitMeasureId = WeightItemUOM.intUnitMeasureId
LEFT JOIN tblAPVendor Vendor ON Vendor.[intEntityId] = receiptItemLot.intEntityVendorId
LEFT JOIN tblSMCountry Origin ON Origin.intCountryID = receiptItemLot.intOriginId
LEFT JOIN tblICCommodityAttribute Grade ON Grade.intCommodityAttributeId = receiptItemLot.intGradeId
LEFT JOIN tblEMEntity Producer ON Producer.intEntityId = receiptItemLot.intProducerId