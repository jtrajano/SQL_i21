﻿CREATE VIEW [dbo].[vyuICGetStorageBinDetails]
AS
SELECT
	  intItemId					= sm.intItemId
	, intCompanyLocationId		= il.intLocationId
	, intItemLocationId			= sm.intItemLocationId
	, intSubLocationId			= sm.intSubLocationId
	, strSubLocationName		= sc.strSubLocationName 
	, strLocation				= c.strLocationName
	, strStorageLocation		= sl.strName
	, strItemNo					= i.strItemNo
	, strItemDescription		= i.strDescription
	, intStorageLocationId		= sm.intStorageLocationId
	, strCommodityCode			= cd.strCommodityCode
	, dblStock					= CAST((sm.dblOnHand + sm.dblUnitStorage) AS NUMERIC(28, 6)) 
	, dblEffectiveDepth			= CAST(sl.dblEffectiveDepth AS NUMERIC(28, 6)) 
	, dblPackFactor				= CAST(1.00 AS NUMERIC(28, 6))
	, dblUnitPerFoot			= CAST(sl.dblUnitPerFoot AS NUMERIC(28, 6))
	, dblCapacity				= CAST(sl.dblEffectiveDepth *  sl.dblUnitPerFoot AS NUMERIC(28, 6))
	, dblAvailable				= CAST((sl.dblEffectiveDepth *  sl.dblUnitPerFoot) - (sm.dblOnHand + sm.dblUnitStorage) AS NUMERIC(28, 6))
	, dblAirSpaceReading		= CAST(ISNULL(mrc.dblAirSpaceReading, 0) AS NUMERIC(28, 6))
	, dblPhysicalReading		= CAST(((sl.dblEffectiveDepth - ISNULL(mrc.dblAirSpaceReading, 0)) * sl.dblUnitPerFoot) + sl.dblResidualUnit AS NUMERIC(28, 6))
	, dblStockVariance			= CAST((sm.dblOnHand + sm.dblUnitStorage) - (((sl.dblEffectiveDepth - ISNULL(mrc.dblAirSpaceReading, 0)) * sl.dblUnitPerFoot)) + sl.dblResidualUnit AS NUMERIC(28, 6))
	, dtmReadingDate			= smr.dtmReadingDate
	, strDiscountCode			= grd.strDiscountId
	, strDiscountDescription	= grd.strDiscountDescription
	, intItemUOMId				= im.intItemUOMId
	, strUOM					= um.strUnitMeasure
	, i.strStatus
FROM vyuICItemStockUOM sm
	INNER JOIN tblICItemUOM im ON im.intItemUOMId = sm.intItemUOMId
	INNER JOIN tblICItem i ON i.intItemId = sm.intItemId
	INNER JOIN tblICUnitMeasure um ON um.intUnitMeasureId = im.intUnitMeasureId	
	INNER JOIN (
		tblICItemLocation il INNER JOIN tblSMCompanyLocation c ON 
			c.intCompanyLocationId = il.intLocationId
	)
		ON il.intItemId = sm.intItemId
		AND il.intItemLocationId = sm.intItemLocationId
	INNER JOIN tblICStorageLocation sl ON sl.intStorageLocationId = sm.intStorageLocationId
		AND sl.intLocationId = il.intLocationId
	LEFT OUTER JOIN tblSMCompanyLocationSubLocation sc ON sc.intCompanyLocationSubLocationId = sm.intSubLocationId
	LEFT OUTER JOIN tblICCommodity cd ON cd.intCommodityId = i.intCommodityId
	
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
	) mrc ON mrc.intItemId = i.intItemId
		AND mrc.intStorageLocationId = sm.intStorageLocationId
		AND mrc.intCommodityId = i.intCommodityId
	LEFT OUTER JOIN (
		SELECT
			  intLocationId						= smr.intLocationId
			, dtmReadingDate					= MAX(smr.dtmDate)
			, intStorageMeasurementReadingId	= smr.intStorageMeasurementReadingId
		FROM tblICStorageMeasurementReading smr
			INNER JOIN tblICStorageMeasurementReadingConversion smrc ON smrc.intStorageMeasurementReadingId = smr.intStorageMeasurementReadingId
		GROUP BY smr.intLocationId, smr.intStorageMeasurementReadingId
	) smr ON smr.intLocationId = il.intLocationId
		AND mrc.intStorageMeasurementReadingId = smr.intStorageMeasurementReadingId
	LEFT OUTER JOIN tblGRDiscountId grd ON grd.intDiscountId = mrc.intDiscountSchedule
WHERE 
	i.strType = 'Inventory'
	--AND sl.intStorageLocationId IS NOT NULL