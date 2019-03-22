CREATE VIEW [dbo].[vyuICGetStorageBins]
AS
SELECT 
	bd.intCompanyLocationId
	, bd.intStorageLocationId
	, bd.strLocation
	, bd.strStorageLocation
	, CAST(dbo.fnMaxNumeric(SUM(bd.dblStock), 0) AS NUMERIC(16, 8)) dblStock
	, CAST(SUM(bd.dblCapacity) AS NUMERIC(16, 8)) dblCapacity
	, CAST(dbo.fnMaxNumeric(SUM(bd.dblAvailable), 0) AS NUMERIC(16, 8)) dblAvailable
FROM 
	vyuICGetStorageBinDetails bd	
WHERE	
	bd.intStorageLocationId IS NOT NULL 
GROUP BY 
	bd.intCompanyLocationId
	, bd.intStorageLocationId
	, bd.strLocation
	, bd.strStorageLocation
