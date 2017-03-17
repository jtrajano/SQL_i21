CREATE VIEW [dbo].[vyuICGetStorageBinDetails]
AS 
SELECT storageLocation.intStorageLocationId, stockUOM.intItemId, companyLocation.intCompanyLocationId, stockUOM.intItemLocationId
	, subLocation.intCompanyLocationSubLocationId intSubLocationId, subLocation.strSubLocationName
	, companyLocation.strLocationName strLocation, storageLocation.strName strStorageLocation, unitMeasure.strUnitMeasure strUOM
	, item.strItemNo, item.strDescription strItemDescription
	, storageLocation.dblEffectiveDepth, storageLocation.dblPackFactor, storageLocation.dblUnitPerFoot
	, CAST(SUM(stockUOM.dblOnHand + stockUOM.dblUnitStorage) AS NUMERIC(16, 8)) dblStock
	, CAST(storageLocation.dblEffectiveDepth * storageLocation.dblPackFactor * storageLocation.dblUnitPerFoot AS NUMERIC(16, 8)) dblCapacity
	, CAST(dbo.fnMaxNumeric(storageLocation.dblEffectiveDepth * storageLocation.dblPackFactor * storageLocation.dblUnitPerFoot - dbo.fnMaxNumeric(summary.dblStock, 0), 0) AS NUMERIC(16, 8)) dblAvailable
	, commodity.strCommodityCode
	, CAST(ISNULL(mrc.dblAirSpaceReading, 0) AS NUMERIC(16, 8)) dblAirSpaceReading
	, CAST(((storageLocation.dblEffectiveDepth - ISNULL(mrc.dblAirSpaceReading, 0)) * storageLocation.dblUnitPerFoot * storageLocation.dblPackFactor) + storageLocation.dblResidualUnit AS NUMERIC(16, 8)) dblPhysicalReading
	, CAST(SUM(stockUOM.dblOnHand + stockUOM.dblUnitStorage) - ((storageLocation.dblEffectiveDepth - ISNULL(mrc.dblAirSpaceReading, 0)) * storageLocation.dblUnitPerFoot * storageLocation.dblPackFactor) + storageLocation.dblResidualUnit AS NUMERIC(16, 8)) dblStockVariance,
	grd.strDiscountId strDiscountCode, grd.strDiscountDescription, smr.dtmDate [dtmReadingDate]
FROM tblICItemStockUOM stockUOM
	INNER JOIN tblICItem item ON item.intItemId = stockUOM.intItemId
	INNER JOIN tblICItemUOM itemUOM ON itemUOM.intItemUOMId = stockUOM.intItemUOMId
	LEFT OUTER JOIN tblICUnitMeasure unitMeasure ON unitMeasure.intUnitMeasureId = itemUOM.intUnitMeasureId
	INNER JOIN tblICStorageLocation storageLocation ON storageLocation.intStorageLocationId = stockUOM.intStorageLocationId
	INNER JOIN tblSMCompanyLocation companyLocation ON companyLocation.intCompanyLocationId = storageLocation.intLocationId
	INNER JOIN (
		SELECT storageLocation.intStorageLocationId,
			SUM(stockUOM.dblOnHand + stockUOM.dblUnitStorage) dblStock
		FROM tblICItemStockUOM stockUOM
			INNER JOIN tblICStorageLocation storageLocation ON storageLocation.intStorageLocationId = stockUOM.intStorageLocationId
		GROUP BY storageLocation.intStorageLocationId
	) summary ON summary.intStorageLocationId = storageLocation.intStorageLocationId
	LEFT OUTER JOIN tblICCommodity commodity ON commodity.intCommodityId = item.intCommodityId
	LEFT OUTER JOIN tblICStorageMeasurementReadingConversion mrc ON mrc.intCommodityId = commodity.intCommodityId
		AND mrc.intStorageLocationId = storageLocation.intStorageLocationId
		AND mrc.intItemId = item.intItemId
	LEFT OUTER JOIN tblICStorageMeasurementReading smr ON smr.intLocationId = companyLocation.intCompanyLocationId
	LEFT OUTER JOIN tblGRDiscountId grd ON grd.intDiscountId = mrc.intDiscountSchedule
	LEFT OUTER JOIN tblSMCompanyLocationSubLocation subLocation ON subLocation.intCompanyLocationSubLocationId = stockUOM.intSubLocationId
GROUP BY storageLocation.intStorageLocationId, stockUOM.intItemId, subLocation.intCompanyLocationSubLocationId, subLocation.strSubLocationName,
	companyLocation.intCompanyLocationId, storageLocation.strName, companyLocation.strLocationName,
	item.strItemNo, item.strDescription, storageLocation.dblEffectiveDepth, stockUOM.intItemLocationId,
	storageLocation.dblPackFactor, storageLocation.dblUnitPerFoot, summary.dblStock, unitMeasure.strUnitMeasure,
	commodity.strCommodityCode, mrc.dblAirSpaceReading, storageLocation.dblResidualUnit, grd.strDiscountId, grd.strDiscountDescription,
	smr.dtmDate
