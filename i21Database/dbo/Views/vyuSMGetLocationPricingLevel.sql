CREATE VIEW [dbo].[vyuSMGetLocationPricingLevel]

AS 
	SELECT TOP 100 PERCENT 
		[intCompanyLocationPricingLevelId] AS [intKey], 
		[intCompanyLocationId], 
		[strPricingLevelName] AS [strPriceLevel]
	FROM tblSMCompanyLocationPricingLevel
	ORDER BY intCompanyLocationId, intSort ASC

GO