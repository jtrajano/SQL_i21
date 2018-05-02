﻿CREATE VIEW [dbo].[vyuICItemLot]
AS

SELECT
	  intItemId = item.intItemId
	, intItemLocationId = lot.intItemLocationId
	, intSubLocationId = lot.intSubLocationId
	, intStorageLocationId = lot.intStorageLocationId
	, intLotStatusId = lot.intLotStatusId
	, strLotStatus = lotStatus.strSecondaryStatus
	, intItemUOMId = lot.intItemUOMId
	, strItemNo = item.strItemNo
	, strItemDescription = item.strDescription
	, strProductType = att.strDescription
	, strLocationName = loc.strLocationName
	, strSubLocationName = subLoc.strSubLocationName
	, strStorageLocation = stLoc.strName
	, strLotNumber = lot.strLotNumber
	, dblQty = lot.dblQty
	, dblWeight = lot.dblWeight
	, strItemUOM = uom.strUnitMeasure
	, dblItemUnitQty = iuom.dblUnitQty
	, dblWeightPerQty = lot.dblWeightPerQty
	, dblLastCost = lot.dblLastCost
	, intLotId = lot.intLotId
	, strWeightUOM = weightUOM.strUnitMeasure
	, strCostUOM = costUOM.strUnitMeasure
	, book.strBook
	, subBook.strSubBook
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
