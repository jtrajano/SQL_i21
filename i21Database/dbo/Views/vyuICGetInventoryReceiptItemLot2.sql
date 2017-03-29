CREATE VIEW [dbo].[vyuICGetInventoryReceiptItemLot2]
AS
SELECT 
		receiptItemLot.intInventoryReceiptItemLotId
		,receiptItemLot.intInventoryReceiptItemId
		,receiptItemLot.intLotId
		,receiptItemLot.strLotNumber
		,receiptItemLot.strLotAlias
		,receiptItemLot.intSubLocationId
		,receiptItemLot.intStorageLocationId
		,receiptItemLot.intItemUnitMeasureId
		,receiptItemLot.dblQuantity
		,receiptItemLot.dblGrossWeight
		,receiptItemLot.dblTareWeight
		,receiptItemLot.dblCost
		,receiptItemLot.intNoPallet
		,receiptItemLot.intUnitPallet
		,receiptItemLot.dblStatedGrossPerUnit
		,receiptItemLot.dblStatedTarePerUnit
		,receiptItemLot.strContainerNo
		,receiptItemLot.intEntityVendorId
		,receiptItemLot.strGarden
		,receiptItemLot.strMarkings
		,receiptItemLot.intOriginId
		,receiptItemLot.intGradeId
		,receiptItemLot.intSeasonCropYear
		,receiptItemLot.strVendorLotId
		,receiptItemLot.dtmManufacturedDate
		,receiptItemLot.strRemarks
		,receiptItemLot.strCondition
		,receiptItemLot.dtmCertified
		,receiptItemLot.dtmExpiryDate
		,receiptItemLot.intParentLotId
		,receiptItemLot.strParentLotNumber
		,receiptItemLot.strParentLotAlias
		,receiptItemLot.intSort
		,receiptItemLot.intConcurrencyId
		,ISNULL(receiptItemLot.dblGrossWeight, 0) - ISNULL(receiptItemLot.dblTareWeight, 0) dblNetWeight
		,uom.strUnitMeasure
		,uom.strUnitType
		,iuom.dblUnitQty
		,itemUOM.strUnitMeasure strItemUOM
		,weightUOM.strUnitMeasure strWeightUOM
		,ISNULL(iuom.dblUnitQty, 0) dblLotUOMConvFactor
		,sloc.strName strStorageLocation
		,sub.strSubLocationName
		,v.strVendorId
		,ctry.strCountry strOrigin
		,attr.strDescription strGrade
		,receiptItemLot.dblStatedNetPerUnit
		,receiptItemLot.dblStatedTotalNet
		,receiptItemLot.dblPhysicalVsStated
		,receipt.intCurrencyId
		,Currency.strCurrency
FROM	tblICInventoryReceiptItemLot receiptItemLot
		INNER JOIN tblICInventoryReceiptItem item 
			ON item.intInventoryReceiptItemId = receiptItemLot.intInventoryReceiptItemId
		INNER JOIN tblICInventoryReceipt receipt
			ON receipt.intInventoryReceiptId = item.intInventoryReceiptId
		LEFT OUTER JOIN tblSMCompanyLocationSubLocation sub 
			ON sub.intCompanyLocationSubLocationId = receiptItemLot.intSubLocationId
		LEFT OUTER JOIN tblICStorageLocation sloc 
			ON sloc.intStorageLocationId = receiptItemLot.intStorageLocationId
		LEFT OUTER JOIN tblSMCountry ctry 
			ON ctry.intCountryID = receiptItemLot.intOriginId
		LEFT OUTER JOIN tblICCommodityAttribute attr 
			ON attr.intCommodityAttributeId = receiptItemLot.intGradeId
		LEFT OUTER JOIN tblAPVendor v 
			ON v.[intEntityId] = receiptItemLot.intEntityVendorId
		LEFT OUTER JOIN tblICItemUOM iuom 
			ON iuom.intItemUOMId = receiptItemLot.intItemUnitMeasureId
		LEFT OUTER JOIN tblICUnitMeasure uom 
			ON uom.intUnitMeasureId = iuom.intUnitMeasureId
		LEFT JOIN tblICItemUOM itemItemUOM 
			ON itemItemUOM.intItemUOMId = item.intUnitMeasureId
		LEFT OUTER JOIN tblICUnitMeasure itemUOM 
			ON itemUOM.intUnitMeasureId = itemItemUOM.intUnitMeasureId
		LEFT JOIN tblICItemUOM itemWeightUOM 
			ON itemWeightUOM.intItemUOMId = item.intWeightUOMId 
			AND itemWeightUOM.intItemId = item.intItemId
		LEFT OUTER JOIN tblICUnitMeasure weightUOM 
			ON weightUOM.intUnitMeasureId = itemWeightUOM.intUnitMeasureId
		LEFT JOIN tblSMCurrency Currency
			ON Currency.intCurrencyID = receipt.intCurrencyId