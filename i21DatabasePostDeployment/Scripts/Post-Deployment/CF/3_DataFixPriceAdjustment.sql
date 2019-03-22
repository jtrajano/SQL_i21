﻿
--------------------------------------------Update Price Adjustment DAta
----------------------------------------
GO


--DECLARE @tblCFTempSiteGroupPriceAdjustment TABLE
--(
-- intSiteGroupPriceAdjustmentId	INT
--,intSiteGroupId					INT
--,dtmStartEffectiveDate			DATETIME
--)


--INSERT INTO @tblCFTempSiteGroupPriceAdjustment
--(
--	 intSiteGroupPriceAdjustmentId	
--	,intSiteGroupId					
--	,dtmStartEffectiveDate			
--)
--SELECT 
-- mtbl.intSiteGroupPriceAdjustmentId	
--,mtbl.intSiteGroupId					
--,mtbl.dtmStartEffectiveDate			
--FROM tblCFSiteGroupPriceAdjustment as mtbl
--INNER JOIN  (SELECT  ISNULL(intSiteGroupId,0) as intSiteGroupId,ISNULL(dtmStartEffectiveDate,0) as dtmStartEffectiveDate FROM tblCFSiteGroupPriceAdjustment GROUP BY intSiteGroupId, dtmStartEffectiveDate having count(*) > 1) as jtbl
--ON  ISNULL(mtbl.intSiteGroupId,0) = ISNULL(jtbl.intSiteGroupId,0) AND   ISNULL(mtbl.dtmStartEffectiveDate,0) = ISNULL(jtbl.dtmStartEffectiveDate,0)

--DECLARE @intId INT
--DECLARE @intSiteGroupId INT
--DECLARE @dtmStartEffectiveDate DATETIME
--WHILE (EXISTS(SELECT TOP 1 intSiteGroupPriceAdjustmentId FROM @tblCFTempSiteGroupPriceAdjustment))
--BEGIN
--	SELECT TOP 1 
--	 @intId = intSiteGroupPriceAdjustmentId 
--	,@intSiteGroupId = intSiteGroupId
--	,@dtmStartEffectiveDate = dtmStartEffectiveDate
--	FROM @tblCFTempSiteGroupPriceAdjustment

--	DELETE FROM tblCFSiteGroupPriceAdjustment 
--	WHERE intSiteGroupPriceAdjustmentId != @intId 
--	AND ISNULL(intSiteGroupId,0) = ISNULL(@intSiteGroupId ,0)
--	AND ISNULL(dtmStartEffectiveDate,0) = ISNULL(@dtmStartEffectiveDate,0)

--	DELETE FROM @tblCFTempSiteGroupPriceAdjustment 
--	WHERE ISNULL(intSiteGroupId,0) = ISNULL(@intSiteGroupId ,0)
--	AND ISNULL(dtmStartEffectiveDate,0) = ISNULL(@dtmStartEffectiveDate,0)
--END

--DELETE @tblCFTempSiteGroupPriceAdjustment


SELECT DISTINCT 
	intSiteGroupId
	,dtmStartEffectiveDate 
INTO #tmptblCFSiteGroupPriceAdjustment
FROM tblCFSiteGroupPriceAdjustment


INSERT INTO tblCFSiteGroupPriceAdjustmentHeader(
intSiteGroupId
,dtmEffectiveDate)
SELECT
	intSiteGroupId = A.intSiteGroupId
	,dtmEffectiveDate  = A.dtmStartEffectiveDate
FROM #tmptblCFSiteGroupPriceAdjustment A
WHERE NOT EXISTS(SELECT TOP 1 1
				FROM tblCFSiteGroupPriceAdjustmentHeader
				WHERE intSiteGroupId = A.intSiteGroupId
					AND dtmEffectiveDate = A.dtmStartEffectiveDate)
	AND A.intSiteGroupId IS NOT NULL AND A.dtmStartEffectiveDate IS NOT NULL
GO

UPDATE tblCFSiteGroupPriceAdjustment
SET intSiteGroupPriceAdjustmentHeaderId = A.intSiteGroupPriceAdjustmentHeaderId
FROM tblCFSiteGroupPriceAdjustmentHeader A
WHERE tblCFSiteGroupPriceAdjustment.intSiteGroupId = A.intSiteGroupId
	AND tblCFSiteGroupPriceAdjustment.dtmStartEffectiveDate = A.dtmEffectiveDate
	AND tblCFSiteGroupPriceAdjustment.dtmStartEffectiveDate IS NOT NULL
	AND tblCFSiteGroupPriceAdjustment.intSiteGroupId IS NOT NULL

GO

GO
-----------------------------------------------------------------
-------------------------------------------------------------