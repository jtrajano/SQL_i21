CREATE PROCEDURE uspICImportItemPricingsFromStaging @strIdentifier NVARCHAR(100)
AS

;WITH cte AS
(
   SELECT *, ROW_NUMBER() OVER(PARTITION BY strItemNo, strLocation ORDER BY strItemNo, strLocation) AS RowNumber
   FROM tblICImportStagingItemPricing
)
DELETE FROM cte WHERE RowNumber > 1;

INSERT INTO tblICItemPricing(
	  intItemId
	, intItemLocationId
	, dblAmountPercent
	, dblSalePrice
	, dblMSRPPrice
	, strPricingMethod
	, dblLastCost
	, dblStandardCost
	, dblAverageCost
	, dblDefaultGrossPrice
	, dtmDateCreated
	, intCreatedByUserId
)
SELECT
	  intItemId				= i.intItemId
	, intItemLocationId		= il.intItemLocationId
	, dblAmountPercent		= s.dblAmountPercent
	, dblSalePrice			= s.dblRetailPrice
	, dblMSRPPrice			= s.dblMSRP		
	, strPricingMethod		= s.strPricingMethod		
	, dblLastCost			= s.dblLastCost			
	, dblStandardCost		= s.dblStandardCost		
	, dblAverageCost		= s.dblAverageCost			
	, dblDefaultGrossPrice	= s.dblDefaultGrossPrice	
	, dtmDateCreated		= s.dtmDateCreated		
	, intCreatedByUserId	= s.intCreatedByUserId	
FROM tblICImportStagingItemPricing s
	INNER JOIN tblICItem i ON LOWER(i.strItemNo) = LTRIM(RTRIM(LOWER(s.strItemNo))) 
	INNER JOIN tblSMCompanyLocation c ON LOWER(c.strLocationName) = LTRIM(RTRIM(LOWER(s.strLocation)))
	INNER JOIN tblICItemLocation il ON il.intLocationId = c.intCompanyLocationId
		AND il.intItemId = i.intItemId
WHERE s.strImportIdentifier = @strIdentifier
	AND NOT EXISTS(
		SELECT TOP 1 1
		FROM tblICItemPricing
		WHERE intItemId = i.intItemId
			AND intLocationId = c.intCompanyLocationId
	)


UPDATE l
SET l.intRowsImported = @@ROWCOUNT
FROM tblICImportLog l
WHERE l.strUniqueId = @strIdentifier

DELETE FROM [tblICImportStagingItemPricing] WHERE strImportIdentifier = @strIdentifier