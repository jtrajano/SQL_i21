CREATE VIEW [dbo].[vyuICGetStorageBinDetails]
AS 
SELECT storageLocation.intStorageLocationId, stockUOM.intItemId, companyLocation.intCompanyLocationId, stockUOM.intItemLocationId
	, companyLocation.strLocationName strLocation, storageLocation.strName strStorageLocation, unitMeasure.strUnitMeasure strUOM
	, item.strItemNo, item.strDescription strItemDescription
	, storageLocation.dblEffectiveDepth, storageLocation.dblPackFactor, storageLocation.dblUnitPerFoot
	, CAST(SUM(stockUOM.dblOnHand + stockUOM.dblUnitStorage) AS NUMERIC(16, 8)) dblStock
	, CAST(storageLocation.dblEffectiveDepth * storageLocation.dblPackFactor * storageLocation.dblUnitPerFoot AS NUMERIC(16, 8)) dblCapacity
	, CAST(dbo.fnMaxNumeric(storageLocation.dblEffectiveDepth * storageLocation.dblPackFactor * storageLocation.dblUnitPerFoot - dbo.fnMaxNumeric(summary.dblStock, 0), 0) AS NUMERIC(16, 8)) dblAvailable
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
GROUP BY storageLocation.intStorageLocationId, stockUOM.intItemId,
	companyLocation.intCompanyLocationId, storageLocation.strName, companyLocation.strLocationName,
	item.strItemNo, item.strDescription, storageLocation.dblEffectiveDepth, stockUOM.intItemLocationId,
	storageLocation.dblPackFactor, storageLocation.dblUnitPerFoot, summary.dblStock, unitMeasure.strUnitMeasure