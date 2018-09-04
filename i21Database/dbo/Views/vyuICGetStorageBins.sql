CREATE VIEW [dbo].[vyuICGetStorageBins]
AS
SELECT companyLocation.intCompanyLocationId, storageLocation.intStorageLocationId
	, companyLocation.strLocationName strLocation, storageLocation.strName strStorageLocation
	, CAST(SUM(bd.dblStock) AS NUMERIC(16, 8)) dblStock
	, CAST(SUM(bd.dblCapacity) AS NUMERIC(16, 8)) dblCapacity
	, CAST(dbo.fnMaxNumeric(SUM(bd.dblAvailable), 0) AS NUMERIC(16, 8)) dblAvailable
FROM tblICStorageLocation storageLocation
	INNER JOIN vyuICGetStorageBinDetails bd ON bd.intStorageLocationId = storageLocation.intStorageLocationId
	INNER JOIN tblSMCompanyLocation companyLocation ON companyLocation.intCompanyLocationId = storageLocation.intLocationId
GROUP BY companyLocation.intCompanyLocationId, storageLocation.intStorageLocationId
	, companyLocation.strLocationName, storageLocation.strName