CREATE VIEW [dbo].[vyuSMGetLocationPricingLevel]

AS 

SELECT * FROM (
	SELECT intCompanyLocationId, strPriceLevel1 AS strPriceLevel from tblSMCompanyLocation
	UNION ALL SELECT intCompanyLocationId, strPriceLevel2 AS strPriceLevel from tblSMCompanyLocation
	UNION ALL SELECT intCompanyLocationId, strPriceLevel3 AS strPriceLevel from tblSMCompanyLocation
	UNION ALL SELECT intCompanyLocationId, strPriceLevel4 AS strPriceLevel from tblSMCompanyLocation
	UNION ALL SELECT intCompanyLocationId, strPriceLevel5 AS strPriceLevel from tblSMCompanyLocation
	) tblLocationPriceLevel
WHERE ISNULL(strPriceLevel, '') <> ''

GO