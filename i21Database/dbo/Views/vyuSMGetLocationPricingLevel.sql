﻿CREATE VIEW [dbo].[vyuSMGetLocationPricingLevel]

AS 
	SELECT TOP 100 PERCENT 
		[intSort] AS ['intKey'], 
		[intCompanyLocationId], 
		[strPricingLevelName] AS [strPriceLevel]
	FROM tblSMCompanyLocationPricingLevel
	ORDER BY intCompanyLocationId, intSort ASC

--SELECT intKey = CAST(ROW_NUMBER() OVER(ORDER BY tblLocationPriceLevel.intCompanyLocationId, tblLocationPriceLevel.strPriceLevel) AS INT),
--* FROM (
--	SELECT intCompanyLocationId, strPriceLevel1 AS strPriceLevel from tblSMCompanyLocation
--	UNION ALL SELECT intCompanyLocationId, strPriceLevel2 AS strPriceLevel from tblSMCompanyLocation
--	UNION ALL SELECT intCompanyLocationId, strPriceLevel3 AS strPriceLevel from tblSMCompanyLocation
--	UNION ALL SELECT intCompanyLocationId, strPriceLevel4 AS strPriceLevel from tblSMCompanyLocation
--	UNION ALL SELECT intCompanyLocationId, strPriceLevel5 AS strPriceLevel from tblSMCompanyLocation
--	) tblLocationPriceLevel
--WHERE ISNULL(strPriceLevel, '') <> ''

GO