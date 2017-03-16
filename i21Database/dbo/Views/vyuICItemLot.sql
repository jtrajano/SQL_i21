﻿CREATE VIEW [dbo].[vyuICItemLot]
AS

SELECT
	  strItemNo = item.strItemNo
	, strItemDescription = item.strDescription
	, strProductType = att.strDescription
	, strLocationName = loc.strLocationName
	, strSubLocationName = subLoc.strSubLocationName
	, strStorageLocation = stLoc.strName
	, strLotNumber = lot.strLotNumber
	, dblQty = lot.dblQty
	, dblWeight = lot.dblWeight
	, strItemUOM = uom.strUnitMeasure
	, dblWeightPerQty = lot.dblWeightPerQty
	, dblLastCost = lot.dblLastCost
	, intLotId = lot.intLotId
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