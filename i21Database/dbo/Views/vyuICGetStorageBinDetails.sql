CREATE VIEW [dbo].[vyuICGetStorageBinDetails]
AS
SELECT
	  intItemId					= sm.intItemId
	, intCompanyLocationId		= sd.intLocationId
	, intItemLocationId			= sm.intItemLocationId
	, intSubLocationId			= sm.intSubLocationId
	, strSubLocationName		= sc.strSubLocationName
	, strLocation				= sd.strLocationName
	, strStorageLocation		= sl.strName
	, strItemNo					= sd.strItemNo
	, strItemDescription		= sd.strDescription
	, intStorageLocationId		= sm.intStorageLocationId
	, strCommodityCode			= sd.strCommodityCode
	, dblStock					= (sd.dblUnitOnHand + sd.dblUnitStorage)
	, dblCapacity				= sl.dblEffectiveDepth *  sl.dblUnitPerFoot
	, dblAvailable				= (sl.dblEffectiveDepth *  sl.dblUnitPerFoot) - (sd.dblUnitOnHand + sd.dblUnitStorage)
	, dblAirSpaceReading		= ISNULL(mrc.dblAirSpaceReading, 0)
	, dblPhysicalReading		= ((sl.dblEffectiveDepth - ISNULL(mrc.dblAirSpaceReading, 0)) * sl.dblUnitPerFoot) + sl.dblResidualUnit
	, dblStockVariance			= (sd.dblUnitOnHand + sd.dblUnitStorage) - (((sl.dblEffectiveDepth - ISNULL(mrc.dblAirSpaceReading, 0)) * sl.dblUnitPerFoot)) + sl.dblResidualUnit
	, dtmReadingDate			= smr.dtmReadingDate
	, strDiscountCode			= grd.strDiscountId
	, strDiscountDescription	= grd.strDiscountDescription
	, strUOM					= um.strUnitMeasure
FROM vyuICStockDetail sd
	INNER JOIN tblICItemStockUOM sm ON sm.intItemStockUOMId = sd.intStockUOMId
	INNER JOIN tblICItemUOM im ON im.intItemUOMId = sm.intItemUOMId
	INNER JOIN tblICUnitMeasure um ON um.intUnitMeasureId = im.intUnitMeasureId
	INNER JOIN tblICStorageLocation sl ON sl.intStorageLocationId = sm.intStorageLocationId
	LEFT OUTER JOIN tblSMCompanyLocationSubLocation sc ON sc.intCompanyLocationSubLocationId = sm.intSubLocationId
	LEFT OUTER JOIN (
		SELECT 
			  dblAirSpaceReading						= SUM(ISNULL(mrc.dblAirSpaceReading, 0))
			, intItemId									= mrc.intItemId
			, intStorageLocationId						= mrc.intStorageLocationId
			, intCommodityId							= mrc.intCommodityId
			, intDiscountSchedule						= mrc.intDiscountSchedule
			, intStorageMeasurementReadingId			= mrc.intStorageMeasurementReadingId
			, intStorageMeasurementReadingConversionId	= mrc.intStorageMeasurementReadingConversionId
		FROM tblICStorageMeasurementReadingConversion mrc
		GROUP BY 
			  mrc.intItemId
			, mrc.intStorageLocationId
			, mrc.intCommodityId
			, mrc.intDiscountSchedule
			, mrc.intStorageMeasurementReadingId
			, mrc.intStorageMeasurementReadingConversionId
	) mrc ON mrc.intItemId = sd.intItemId
		AND mrc.intStorageLocationId = sm.intStorageLocationId
		AND mrc.intCommodityId = sd.intCommodityId
	LEFT OUTER JOIN (
		SELECT
			  intLocationId						= smr.intLocationId
			, dtmReadingDate					= MAX(smr.dtmDate)
			, intStorageMeasurementReadingId	= smr.intStorageMeasurementReadingId
		FROM tblICStorageMeasurementReading smr
			INNER JOIN tblICStorageMeasurementReadingConversion smrc ON smrc.intStorageMeasurementReadingId = smr.intStorageMeasurementReadingId
		GROUP BY smr.intLocationId, smr.intStorageMeasurementReadingId
	) smr ON smr.intLocationId = sd.intLocationId
		AND mrc.intStorageMeasurementReadingId = smr.intStorageMeasurementReadingId
	LEFT OUTER JOIN tblGRDiscountId grd ON grd.intDiscountId = mrc.intDiscountSchedule
WHERE sd.strType IN (N'Inventory',N'Finished Good',N'Raw Material')
	AND sm.intStorageLocationId IS NOT NULL