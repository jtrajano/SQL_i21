CREATE VIEW [dbo].[vyuICGetSubLocationBinDetails]
AS
SELECT 
	  intCompanyLocationId		= companyLocation.intCompanyLocationId
	, strLocation				= companyLocation.strLocationName
	, intSubLocationId			= subLocation.intCompanyLocationSubLocationId
	, strSubLocationName		= subLocation.strSubLocationName
	, intItemId					= stockUOM.intItemId
	, strItemNo					= item.strItemNo
	, strItemDescription		= item.strDescription
	, intItemLocationId			= stockUOM.intItemLocationId
	, dblStock					= CAST(dbo.fnMaxNumeric(SUM(stockUOM.dblOnHand + stockUOM.dblUnitStorage),0) AS NUMERIC(16, 8))
	, dblCapacity				= CAST(storageLocation.dblEffectiveDepth * storageLocation.dblPackFactor * storageLocation.dblUnitPerFoot AS NUMERIC(16, 8))
	, dblAvailable				= CAST(dbo.fnMaxNumeric(storageLocation.dblEffectiveDepth * storageLocation.dblPackFactor * storageLocation.dblUnitPerFoot - dbo.fnMaxNumeric(SUM(stockUOM.dblOnHand + stockUOM.dblUnitStorage), 0), 0) AS NUMERIC(16, 8))
	, strCommodityCode			= commodity.strCommodityCode
FROM tblICItemStockUOM stockUOM
	INNER JOIN tblICItem item ON item.intItemId = stockUOM.intItemId
	INNER JOIN tblICItemUOM itemUOM ON itemUOM.intItemUOMId = stockUOM.intItemUOMId
	LEFT OUTER JOIN tblICUnitMeasure unitMeasure ON unitMeasure.intUnitMeasureId = itemUOM.intUnitMeasureId
	INNER JOIN tblICStorageLocation storageLocation ON storageLocation.intStorageLocationId = stockUOM.intStorageLocationId
	INNER JOIN tblSMCompanyLocation companyLocation ON companyLocation.intCompanyLocationId = storageLocation.intLocationId
	LEFT OUTER JOIN tblICCommodity commodity ON commodity.intCommodityId = item.intCommodityId
	LEFT OUTER JOIN tblICStorageMeasurementReadingConversion mrc ON mrc.intCommodityId = commodity.intCommodityId
		AND mrc.intStorageLocationId = storageLocation.intStorageLocationId
		AND mrc.intItemId = item.intItemId
	LEFT OUTER JOIN tblICStorageMeasurementReading smr ON smr.intLocationId = companyLocation.intCompanyLocationId
	LEFT OUTER JOIN tblGRDiscountId grd ON grd.intDiscountId = mrc.intDiscountSchedule
	LEFT OUTER JOIN tblSMCompanyLocationSubLocation subLocation ON subLocation.intCompanyLocationSubLocationId = stockUOM.intSubLocationId
GROUP BY stockUOM.intItemId, subLocation.intCompanyLocationSubLocationId, subLocation.strSubLocationName,
	companyLocation.intCompanyLocationId, companyLocation.strLocationName,
	item.strItemNo, item.strDescription, storageLocation.dblEffectiveDepth, stockUOM.intItemLocationId,
	storageLocation.dblPackFactor, storageLocation.dblUnitPerFoot, commodity.strCommodityCode