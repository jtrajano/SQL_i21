CREATE VIEW [dbo].[vyuICGetStorageBins]
AS
SELECT companyLocation.intCompanyLocationId, storageLocation.intStorageLocationId
	, companyLocation.strLocationName strLocation, storageLocation.strName strStorageLocation
	, storageLocation.dblEffectiveDepth, storageLocation.dblPackFactor, storageLocation.dblUnitPerFoot
	, CAST(dbo.fnMaxNumeric(summary.dblStock, 0) AS NUMERIC(16, 8)) dblStock
	, CAST(storageLocation.dblEffectiveDepth * storageLocation.dblPackFactor * storageLocation.dblUnitPerFoot AS NUMERIC(16, 8)) dblCapacity
	, CAST(dbo.fnMaxNumeric((storageLocation.dblEffectiveDepth * storageLocation.dblPackFactor * storageLocation.dblUnitPerFoot) - dbo.fnMaxNumeric(summary.dblStock, 0), 0) AS NUMERIC(16, 8)) dblAvailable
FROM tblICStorageLocation storageLocation
	INNER JOIN (
		SELECT storageLocation.intStorageLocationId,
			SUM(stockUOM.dblOnHand + stockUOM.dblUnitStorage) dblStock
		FROM tblICItemStockUOM stockUOM
			INNER JOIN tblICStorageLocation storageLocation ON storageLocation.intStorageLocationId = stockUOM.intStorageLocationId
		GROUP BY storageLocation.intStorageLocationId
	) summary ON summary.intStorageLocationId = storageLocation.intStorageLocationId
	INNER JOIN tblSMCompanyLocation companyLocation ON companyLocation.intCompanyLocationId = storageLocation.intLocationId