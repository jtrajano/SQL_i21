
--------------------------------------------Update Price Adjustment DAta
----------------------------------------
GO

INSERT INTO tblCFSiteGroupPriceAdjustmentHeader(
intSiteGroupId
,dtmEffectiveDate)
SELECT
	intSiteGroupId = A.intSiteGroupId
	,dtmEffectiveDate  = A.dtmStartEffectiveDate
FROM tblCFSiteGroupPriceAdjustment A
WHERE NOT EXISTS(SELECT TOP 1 1 
				FROM tblCFSiteGroupPriceAdjustmentHeader
				WHERE intSiteGroupId = A.intSiteGroupId
					AND dtmEffectiveDate = A.dtmStartEffectiveDate)
	AND A.intSiteGroupId IS NOT NULL
GO

UPDATE tblCFSiteGroupPriceAdjustment
SET intSiteGroupPriceAdjustmentHeaderId = A.intSiteGroupPriceAdjustmentHeaderId
FROM tblCFSiteGroupPriceAdjustmentHeader A
WHERE tblCFSiteGroupPriceAdjustment.intSiteGroupId = A.intSiteGroupId
	AND tblCFSiteGroupPriceAdjustment.dtmStartEffectiveDate = A.dtmEffectiveDate

GO
-----------------------------------------------------------------
-------------------------------------------------------------