CREATE VIEW [dbo].[vyuICItemMissingLot]
AS

SELECT
	  intItemId = item.intItemId
	, intItemLocationId = lot.intItemLocationId
	, intSubLocationId = lot.intSubLocationId
	, intStorageLocationId = lot.intStorageLocationId
	, intLocationId = lot.intLocationId
	, intLotStatusId = lot.intLotStatusId
	, strLotStatus = lotStatus.strSecondaryStatus
	, intItemUOMId = lot.intItemUOMId
	, strItemNo = item.strItemNo
	, strItemDescription = item.strDescription
	, strProductType = att.strDescription
	, strLocationName = loc.strLocationName
	, strSubLocationName = subLoc.strSubLocationName
	, strStorageLocation = stLoc.strName
	, strParentLotNumber = ParentLot.strParentLotNumber
	, strLotNumber = lot.strLotNumber
	, dblQty = CONVERT(NUMERIC(30, 15), lot.dblQty)
	, dblWeight = CONVERT(NUMERIC(30, 15), lot.dblWeight)
	, strItemUOM = uom.strUnitMeasure
	, dblItemUnitQty = CONVERT(NUMERIC(30, 15), iuom.dblUnitQty)
	, dblWeightPerQty = CONVERT(NUMERIC(30, 15), lot.dblWeightPerQty)
	, dblLastCost = CONVERT(NUMERIC(30, 15), lot.dblLastCost)
	, intLotId = lot.intLotId
	, strWeightUOM = weightUOM.strUnitMeasure
	, strCostUOM = costUOM.strUnitMeasure
	, book.strBook
	, subBook.strSubBook
	, lot.strWarehouseRefNo
	, intQtyUOMDecimalPlaces = uom.intDecimalPlaces
	, intGrossUOMDecimalPlaces = weightUOM.intDecimalPlaces
	, strCargoNo = lot.strCargoNo
	, strWarrantNo = lot.strWarrantNo
	, WarrantStatus.strWarrantStatus
	, lot.strCondition 
	, item.intCertificationId
	, Certification.strCertificationName
	, strGrade = Grade.strDescription
	, strOrigin = Origin.strDescription
	, strRegion = Region.strDescription
	, strSeason = Season.strDescription
	, strClass = Class.strDescription
	, strProductLine = ProductLine.strDescription
	, lot.dblTare
	, lot.dblTarePerQty
	, lot.ysnInsuranceClaimed
	, lot.ysnRejected
	, lot.strRejectedBy
FROM tblICLot lot
	INNER JOIN tblICItem item ON item.intItemId = lot.intItemId
	LEFT JOIN tblSMCompanyLocation loc ON loc.intCompanyLocationId = lot.intLocationId
	LEFT JOIN tblSMCompanyLocationSubLocation subLoc ON subLoc.intCompanyLocationId = lot.intLocationId
		AND subLoc.intCompanyLocationSubLocationId = lot.intSubLocationId
	LEFT JOIN tblICStorageLocation stLoc ON stLoc.intStorageLocationId = lot.intStorageLocationId
	LEFT JOIN tblICCommodityAttribute att ON att.intCommodityAttributeId = item.intProductTypeId
	LEFT JOIN tblICItemUOM iuom ON iuom.intItemUOMId = lot.intItemUOMId
		AND iuom.intItemId = lot.intItemId
	LEFT JOIN tblICUnitMeasure uom ON uom.intUnitMeasureId = iuom.intUnitMeasureId
	LEFT JOIN tblICItemUOM iweightUOM ON iweightUOM.intItemUOMId = lot.intWeightUOMId
	LEFT JOIN tblICUnitMeasure weightUOM ON weightUOM.intUnitMeasureId = iweightUOM.intUnitMeasureId
	LEFT JOIN tblICItemUOM icostUOM ON icostUOM.intItemId = lot.intItemId AND icostUOM.ysnStockUnit=1
	LEFT JOIN tblICUnitMeasure costUOM ON costUOM.intUnitMeasureId = icostUOM.intUnitMeasureId
	LEFT JOIN tblICLotStatus lotStatus ON lotStatus.intLotStatusId = lot.intLotStatusId
	LEFT JOIN tblCTBook book ON book.intBookId = lot.intBookId
	LEFT JOIN tblCTSubBook subBook ON subBook.intSubBookId = lot.intSubBookId
	LEFT JOIN tblICParentLot ParentLot ON ParentLot.intItemId = lot.intItemId
		AND ParentLot.intParentLotId = lot.intParentLotId
	LEFT JOIN tblICCertification Certification ON Certification.intCertificationId = item.intCertificationId
	LEFT JOIN tblICCommodityAttribute Grade ON Grade.intCommodityAttributeId = item.intGradeId
	LEFT JOIN tblICCommodityAttribute Origin ON Origin.intCommodityAttributeId = item.intOriginId
	LEFT JOIN tblICCommodityAttribute Region ON Region.intCommodityAttributeId = item.intRegionId
	LEFT JOIN tblICCommodityAttribute Season ON Season.intCommodityAttributeId = item.intSeasonId
	LEFT JOIN tblICCommodityAttribute Class ON Class.intCommodityAttributeId = item.intClassVarietyId
	LEFT JOIN tblICCommodityProductLine ProductLine ON ProductLine.intCommodityProductLineId = item.intProductLineId
	LEFT JOIN tblICWarrantStatus WarrantStatus ON WarrantStatus.intWarrantStatus = lot.intWarrantStatus
WHERE
	lot.strCondition = 'Missing'