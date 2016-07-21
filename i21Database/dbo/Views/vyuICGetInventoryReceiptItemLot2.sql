CREATE VIEW [dbo].[vyuICGetInventoryReceiptItemLot2]
AS
SELECT lot.intInventoryReceiptItemLotId, lot.intInventoryReceiptItemId, lot.intLotId, lot.strLotNumber, lot.strLotAlias,
	lot.intSubLocationId, lot.intStorageLocationId, lot.intItemUnitMeasureId, lot.dblQuantity, lot.dblGrossWeight, lot.dblTareWeight,
	lot.dblCost, lot.intNoPallet, lot.intUnitPallet, lot.dblStatedGrossPerUnit, lot.dblStatedTarePerUnit, lot.strContainerNo,
	lot.intEntityVendorId, lot.strGarden, lot.strMarkings, lot.intOriginId, lot.intGradeId, lot.intSeasonCropYear, lot.strVendorLotId,
	lot.dtmManufacturedDate, lot.strRemarks, lot.strCondition, lot.dtmCertified, lot.dtmExpiryDate, lot.intParentLotId, lot.strParentLotNumber,
	lot.strParentLotAlias, lot.intSort, lot.intConcurrencyId,
	ISNULL(lot.dblGrossWeight, 0) - ISNULL(lot.dblTareWeight, 0) dblNetWeight,
	uom.strUnitMeasure,
	uom.strUnitType,
	iuom.dblUnitQty,
	itemUOM.strUnitMeasure strItemUOM,
	weightUOM.strUnitMeasure strWeightUOM,
	ISNULL(iuom.dblUnitQty, 0) dblLotUOMConvFactor,
	sloc.strName strStorageLocation,
	sub.strSubLocationName,
	v.strVendorId,
	ctry.strCountry strOrigin,
	attr.strDescription strGrade
FROM tblICInventoryReceiptItemLot lot
	LEFT OUTER JOIN tblSMCompanyLocationSubLocation sub ON sub.intCompanyLocationSubLocationId = lot.intSubLocationId
	LEFT OUTER JOIN tblICStorageLocation sloc ON sloc.intStorageLocationId = lot.intStorageLocationId
	LEFT OUTER JOIN tblSMCountry ctry ON ctry.intCountryID = lot.intOriginId
	LEFT OUTER JOIN tblICCommodityAttribute attr ON attr.intCommodityAttributeId = lot.intGradeId
	LEFT OUTER JOIN tblAPVendor v ON v.intEntityVendorId = lot.intEntityVendorId
	LEFT OUTER JOIN tblICItemUOM iuom ON iuom.intItemUOMId = lot.intItemUnitMeasureId
	LEFT OUTER JOIN tblICUnitMeasure uom ON uom.intUnitMeasureId = iuom.intUnitMeasureId
	INNER JOIN tblICInventoryReceiptItem item ON item.intInventoryReceiptItemId = lot.intInventoryReceiptItemId
	LEFT JOIN tblICItemUOM itemItemUOM ON itemItemUOM.intItemUOMId = item.intUnitMeasureId
	LEFT OUTER JOIN tblICUnitMeasure itemUOM ON itemUOM.intUnitMeasureId = itemItemUOM.intUnitMeasureId
	LEFT JOIN tblICItemUOM itemWeightUOM ON itemWeightUOM.intItemUOMId = item.intWeightUOMId 
		AND itemWeightUOM.intItemId = item.intItemId
	LEFT OUTER JOIN tblICUnitMeasure weightUOM ON weightUOM.intUnitMeasureId = itemWeightUOM.intUnitMeasureId