CREATE VIEW [dbo].[vyuICGetSubLocationBins]
AS 
SELECT 
	  intCompanyLocationId	= companyLocation.intCompanyLocationId
	, intSubLocationId		= subLocation.intCompanyLocationSubLocationId
	, strLocation			= companyLocation.strLocationName
	, strSubLocation		= subLocation.strSubLocationName
	, dblEffectiveDepth		= ISNULL(storage.dblEffectiveDepth, 0)
	, dblPackFactor			= ISNULL(storage.dblPackFactor, 0)
	, dblUnitPerFoot		= ISNULL(storage.dblUnitPerFoot, 0)
	, dblStock				= CAST(summary.dblStock AS NUMERIC(16, 8))
	, dblCapacity			= CAST(ISNULL(storage.dblEffectiveDepth, 0) * ISNULL(storage.dblPackFactor, 0) * ISNULL(storage.dblUnitPerFoot, 0) AS NUMERIC(16, 8))
	, dblAvailable			= CAST(dbo.fnMaxNumeric((ISNULL(storage.dblEffectiveDepth, 0) * ISNULL(storage.dblPackFactor, 0) * ISNULL(storage.dblUnitPerFoot, 0)) - summary.dblStock, 0) AS NUMERIC(16, 8))
FROM tblSMCompanyLocationSubLocation subLocation
	INNER JOIN (
		SELECT 
			  intSubLocationId	= subLocation.intCompanyLocationSubLocationId
			, dblStock			= SUM(stockUOM.dblOnHand + stockUOM.dblUnitStorage)
		FROM tblICItemStockUOM stockUOM
			INNER JOIN tblSMCompanyLocationSubLocation subLocation ON subLocation.intCompanyLocationSubLocationId = stockUOM.intSubLocationId
		GROUP BY subLocation.intCompanyLocationSubLocationId
	) summary ON summary.intSubLocationId = subLocation.intCompanyLocationSubLocationId
	INNER JOIN tblSMCompanyLocation companyLocation ON companyLocation.intCompanyLocationId = subLocation.intCompanyLocationId
	LEFT JOIN (
		SELECT 
			  intSubLocationId		= intSubLocationId
			, dblEffectiveDepth		= SUM(ISNULL(dblEffectiveDepth, 0))
			, dblPackFactor			= SUM(ISNULL(dblPackFactor, 0))
			, dblUnitPerFoot		= SUM(ISNULL(dblUnitPerFoot, 0))
		FROM tblICStorageLocation storageLocation
		GROUP BY intSubLocationId
	) storage ON storage.intSubLocationId = subLocation.intCompanyLocationSubLocationId
WHERE summary.dblStock <> 0
GROUP BY companyLocation.intCompanyLocationId
	, subLocation.intCompanyLocationSubLocationId
	, companyLocation.strLocationName
	, subLocation.strSubLocationName
	, storage.dblEffectiveDepth
	, storage.dblPackFactor
	, storage.dblUnitPerFoot
	, summary.dblStock