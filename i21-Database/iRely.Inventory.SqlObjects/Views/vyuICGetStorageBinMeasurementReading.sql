CREATE VIEW [dbo].[vyuICGetStorageBinMeasurementReading]
AS 
SELECT i.intItemId, i.strItemNo, i.strDescription strItemDescription, su.intItemLocationId, su.intStorageLocationId, sl.intCompanyLocationSubLocationId, sl.intCompanyLocationId,
	cl.strLocationName strLocation, sl.strSubLocationName strSubLocation, stl.strName strStorageLocation,
	co.strCommodityCode, i.intCommodityId, CAST(stl.dblEffectiveDepth AS NUMERIC(18, 6)) dblEffectiveDepth, uom.strUnitMeasure, uom.intUnitMeasureId
FROM tblICItemStockUOM su
	INNER JOIN tblICItem i ON i.intItemId = su.intItemId
	INNER JOIN tblICItemLocation il ON il.intItemLocationId = su.intItemLocationId
	INNER JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = il.intLocationId
	INNER JOIN tblSMCompanyLocationSubLocation sl ON sl.intCompanyLocationSubLocationId = su.intSubLocationId
	INNER JOIN tblICStorageLocation stl ON stl.intStorageLocationId = su.intStorageLocationId
	LEFT OUTER JOIN tblICCommodity co ON co.intCommodityId = i.intCommodityId
	LEFT OUTER JOIN vyuICGetItemUOM uom ON uom.intItemId = i.intItemId
		AND uom.ysnStockUnit = 1
GROUP BY i.intItemId, i.strItemNo, i.strDescription, su.intItemLocationId, su.intStorageLocationId,
	sl.intCompanyLocationSubLocationId, sl.intCompanyLocationId, cl.strLocationName, sl.strSubLocationName,
	stl.strName, stl.dblPackFactor, stl.dblEffectiveDepth, stl.dblUnitPerFoot, co.strCommodityCode, i.intCommodityId, uom.strUnitMeasure, uom.intUnitMeasureId