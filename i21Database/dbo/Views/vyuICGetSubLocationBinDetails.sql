CREATE VIEW [dbo].[vyuICGetSubLocationBinDetails]
AS
SELECT intCompanyLocationId		= companyLocation.intCompanyLocationId
	, strLocation				= companyLocation.strLocationName
	, intSubLocationId			= subLocation.intCompanyLocationSubLocationId
	, strSubLocationName		= subLocation.strSubLocationName
	, intItemId					= stockUOM.intItemId
	, strItemNo					= item.strItemNo
	, strItemDescription		= item.strDescription
	, intItemLocationId			= stockUOM.intItemLocationId
	, dblStock					= CAST((totalStock.dblStock) AS NUMERIC(16, 8))
	, dblCapacity				= CAST(SUM(storageLocation.dblEffectiveDepth * storageLocation.dblUnitPerFoot) AS NUMERIC(16, 8))
	, dblAvailable				= CAST(SUM(storageLocation.dblEffectiveDepth * storageLocation.dblUnitPerFoot) - SUM(totalStock.dblStock) AS NUMERIC(16, 8))
	, strCommodityCode			= commodity.strCommodityCode
FROM tblICItemStockUOM stockUOM
	INNER JOIN tblICItem item ON item.intItemId = stockUOM.intItemId
	INNER JOIN tblICItemUOM itemUOM ON itemUOM.intItemUOMId = stockUOM.intItemUOMId
	LEFT OUTER JOIN tblICUnitMeasure unitMeasure ON unitMeasure.intUnitMeasureId = itemUOM.intUnitMeasureId
	LEFT JOIN tblICStorageLocation storageLocation ON storageLocation.intStorageLocationId = stockUOM.intStorageLocationId
	INNER JOIN tblSMCompanyLocation companyLocation ON companyLocation.intCompanyLocationId = storageLocation.intLocationId
	LEFT JOIN (
		SELECT stockUOM.intItemId, stockUOM.intItemLocationId,
			SUM(stockUOM.dblOnHand + stockUOM.dblUnitStorage) dblStock
		FROM tblICItemStockUOM stockUOM
			INNER JOIN tblICItemUOM iu ON iu.intItemUOMId = stockUOM.intItemUOMId
		WHERE iu.ysnStockUnit = 1
		GROUP BY stockUOM.intItemLocationId, stockUOM.intItemId
	) totalStock ON totalStock.intItemId = stockUOM.intItemId
		AND totalStock.intItemLocationId = stockUOM.intItemLocationId
	LEFT OUTER JOIN tblICCommodity commodity ON commodity.intCommodityId = item.intCommodityId
	LEFT OUTER JOIN tblICStorageMeasurementReadingConversion mrc ON mrc.intCommodityId = commodity.intCommodityId
		AND mrc.intStorageLocationId = storageLocation.intStorageLocationId
		AND mrc.intItemId = item.intItemId
	LEFT OUTER JOIN tblICStorageMeasurementReading smr ON smr.intLocationId = companyLocation.intCompanyLocationId
	LEFT OUTER JOIN tblGRDiscountId grd ON grd.intDiscountId = mrc.intDiscountSchedule
	LEFT OUTER JOIN tblSMCompanyLocationSubLocation subLocation ON subLocation.intCompanyLocationSubLocationId = stockUOM.intSubLocationId
WHERE itemUOM.ysnStockUnit = 1
GROUP BY stockUOM.intItemId, subLocation.intCompanyLocationSubLocationId, subLocation.strSubLocationName,
	companyLocation.intCompanyLocationId, companyLocation.strLocationName,
	item.strItemNo, item.strDescription, stockUOM.intItemLocationId, totalStock.dblStock, commodity.strCommodityCode
HAVING CAST(SUM(totalStock.dblStock) AS NUMERIC(16, 8)) <> 0