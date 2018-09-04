CREATE VIEW [dbo].[vyuICGetSubLocationBinDetails]
AS
SELECT
	  intItemId					= sm.intItemId
	, intCompanyLocationId		= sd.intLocationId
	, intItemLocationId			= sm.intItemLocationId
	, intSubLocationId			= sm.intSubLocationId
	, strSubLocationName		= sc.strSubLocationName
	, strLocation				= sd.strLocationName
	, strStorageLocation		= sl.strName
	, intStorageLocationId		= sl.intStorageLocationId
	, strItemNo					= sd.strItemNo
	, strItemDescription		= sd.strDescription
	, dblStock					= (sd.dblUnitOnHand + sd.dblUnitStorage)
	, dblCapacity				= sl.dblEffectiveDepth *  sl.dblUnitPerFoot
	, dblAvailable				= (sl.dblEffectiveDepth *  sl.dblUnitPerFoot) - (sd.dblUnitOnHand + sd.dblUnitStorage)
	, strCommodityCode			= sd.strCommodityCode
FROM vyuICStockDetail sd
	INNER JOIN tblICItemStockUOM sm ON sm.intItemStockUOMId = sd.intStockUOMId
	INNER JOIN tblICItemUOM im ON im.intItemUOMId = sm.intItemUOMId
	INNER JOIN tblICUnitMeasure um ON um.intUnitMeasureId = im.intUnitMeasureId
	INNER JOIN tblICStorageLocation sl ON sl.intStorageLocationId = sm.intStorageLocationId
	LEFT OUTER JOIN tblSMCompanyLocationSubLocation sc ON sc.intCompanyLocationSubLocationId = sm.intSubLocationId
WHERE sd.strType IN (N'Inventory',N'Finished Good',N'Raw Material')
