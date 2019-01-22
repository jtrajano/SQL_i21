CREATE VIEW [dbo].[vyuICGetSubLocationBinDetails]
AS
SELECT
	  intItemId					= sm.intItemId
	, intCompanyLocationId		= il.intLocationId
	, intItemLocationId			= sm.intItemLocationId
	, intSubLocationId			= sm.intSubLocationId
	, strSubLocationName		= sc.strSubLocationName
	, intStorageLocationId		= MAX(sl.intStorageLocationId)
	, strLocation				= MAX(c.strLocationName)
	, strStorageLocation		= MAX(sl.strName)
	, strItemNo					= i.strItemNo
	, strItemDescription		= i.strDescription
	, dblStock					= SUM((sm.dblOnHand + sm.dblUnitStorage))
	, dblCapacity				= SUM(sl.dblEffectiveDepth *  sl.dblUnitPerFoot)
	, dblAvailable				= SUM((sl.dblEffectiveDepth *  sl.dblUnitPerFoot) - (sm.dblOnHand + sm.dblUnitStorage))
	, strCommodityCode			= cd.strCommodityCode
FROM tblICItemStockUOM sm
	INNER JOIN tblICItemUOM im ON im.intItemUOMId = sm.intItemUOMId AND im.ysnStockUnit = 1
	INNER JOIN tblICItem i ON i.intItemId = sm.intItemId
	INNER JOIN tblICItemLocation il ON il.intItemId = sm.intItemId
		AND il.intItemLocationId = sm.intItemLocationId
	INNER JOIN tblICUnitMeasure um ON um.intUnitMeasureId = im.intUnitMeasureId
	INNER JOIN tblICStorageLocation sl ON sl.intStorageLocationId = sm.intStorageLocationId
	LEFT OUTER JOIN tblSMCompanyLocationSubLocation sc ON sc.intCompanyLocationSubLocationId = sm.intSubLocationId
	LEFT OUTER JOIN tblICCommodity cd ON cd.intCommodityId = i.intCommodityId
	INNER JOIN tblSMCompanyLocation c ON c.intCompanyLocationId = il.intLocationId
WHERE i.strType IN (N'Inventory',N'Finished Good',N'Raw Material')
GROUP BY   sm.intItemId
		 , il.intLocationId
		 , sm.intItemLocationId
		 , sm.intSubLocationId
		 , sc.strSubLocationName
		 , c.strLocationName
		 , i.strItemNo
		 , i.strDescription
		 , cd.strCommodityCode