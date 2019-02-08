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
	, strItemUOM				= um.strUnitMeasure
	, dblStock					= SUM((ISNULL(sm.dblOnHand, 0) + ISNULL(sm.dblUnitStorage, 0)))
	, dblCapacity				= SUM(ISNULL(sl.dblEffectiveDepth, 0) *  ISNULL(sl.dblUnitPerFoot, 0))
	, dblAvailable				= SUM(
									(ISNULL(sl.dblEffectiveDepth, 0) *  ISNULL(sl.dblUnitPerFoot, 0)) 
									- (ISNULL(sm.dblOnHand, 0) + ISNULL(sm.dblUnitStorage, 0))
								)
	, strCommodityCode			= cd.strCommodityCode
FROM tblICItemStockUOM sm
	INNER JOIN tblICItemUOM im ON im.intItemUOMId = sm.intItemUOMId AND im.ysnStockUnit = 1
	INNER JOIN tblICItem i ON i.intItemId = sm.intItemId
	INNER JOIN tblICItemLocation il ON il.intItemId = sm.intItemId
		AND il.intItemLocationId = sm.intItemLocationId
	INNER JOIN tblICUnitMeasure um ON um.intUnitMeasureId = im.intUnitMeasureId
	LEFT JOIN tblICStorageLocation sl ON sl.intStorageLocationId = sm.intStorageLocationId
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
		 , um.strUnitMeasure
		 , cd.strCommodityCode