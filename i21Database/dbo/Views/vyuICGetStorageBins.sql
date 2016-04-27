CREATE VIEW [dbo].[vyuICGetStorageBins]
AS 
SELECT su.intStorageLocationId, sl.intCompanyLocationId,
	cl.strLocationName strLocation, stl.strName strStorageLocation,
	SUM(CAST((ISNULL(stl.dblPackFactor, 0) * ISNULL(stl.dblEffectiveDepth, 0) * ISNULL(stl.dblUnitPerFoot, 0)) AS NUMERIC(18,6))) dblCapacity,
	ABS(SUM(CAST(su.dblOnHand + su.dblUnitStorage AS NUMERIC(18,6)))) dblStock, 
	ABS(SUM(CAST(CASE WHEN ISNULL(stl.dblEffectiveDepth, 0) = 0 THEN 0 
	ELSE (ISNULL(stl.dblPackFactor, 1) * ISNULL(stl.dblEffectiveDepth, 1)
		* ISNULL(stl.dblUnitPerFoot, 1)) - (su.dblOnHand + su.dblUnitStorage) End AS NUMERIC(18,6)))) dblAvailable
FROM tblICItemStockUOM su
	INNER JOIN tblICItem i ON i.intItemId = su.intItemId
	INNER JOIN tblICItemLocation il ON il.intItemLocationId = su.intItemLocationId
	INNER JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = il.intLocationId
	INNER JOIN tblSMCompanyLocationSubLocation sl ON sl.intCompanyLocationSubLocationId = su.intSubLocationId
	INNER JOIN tblICStorageLocation stl ON stl.intStorageLocationId = su.intStorageLocationId
	INNER JOIN tblICItemUOM iu ON iu.intItemUOMId = su.intItemUOMId
	INNER JOIN tblICUnitMeasure u ON u.intUnitMeasureId = iu.intUnitMeasureId
GROUP BY su.intStorageLocationId, sl.intCompanyLocationId, cl.strLocationName, stl.strName