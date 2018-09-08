CREATE VIEW [dbo].[vyuICGetSubLocationBins]
AS
SELECT companyLocation.intCompanyLocationId, subLocation.intCompanyLocationSubLocationId intSubLocationId
	, companyLocation.strLocationName strLocation, subLocation.strSubLocationName strSubLocation
	, dblEffectiveDepth		= SUM(ISNULL(storage.dblEffectiveDepth, 0))
	, dblUnitPerFoot		= SUM(ISNULL(storage.dblUnitPerFoot, 0))
	, dblPackFactor			= 1.0
	, CAST(dbo.fnMaxNumeric(SUM(bd.dblStock), 0) AS NUMERIC(16, 8)) dblStock
	, CAST(SUM(bd.dblCapacity) AS NUMERIC(16, 8)) dblCapacity
	, CAST(dbo.fnMaxNumeric(SUM(bd.dblAvailable), 0) AS NUMERIC(16, 8)) dblAvailable
FROM tblSMCompanyLocationSubLocation subLocation
	INNER JOIN vyuICGetSubLocationBinDetails bd ON bd.intSubLocationId = subLocation.intCompanyLocationSubLocationId
	INNER JOIN tblSMCompanyLocation companyLocation ON companyLocation.intCompanyLocationId = subLocation.intCompanyLocationId
	LEFT OUTER JOIN (
		SELECT sl.intStorageLocationId, sl.dblEffectiveDepth, sl.dblUnitPerFoot
		FROM tblICStorageLocation sl
	) storage ON storage.intStorageLocationId = bd.intStorageLocationId
GROUP BY companyLocation.intCompanyLocationId, subLocation.intCompanyLocationSubLocationId
	, companyLocation.strLocationName, subLocation.strSubLocationName
