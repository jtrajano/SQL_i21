CREATE PROCEDURE dbo.uspICUpdateItemImportedPricingLevel
AS

UPDATE p
SET p.dblSalePrice = 
	dbo.fnICCalculatePrice(
		p.strPricingMethod, 
		p.dblStandardCost, 
		p.dblLastCost, 
		p.dblAverageCost, 
		p.dblAmountPercent,
		p.dblSalePrice
	),
	p.strPricingMethod = CASE WHEN NULLIF(LTRIM(p.strPricingMethod), '') IS NULL THEN 'None' ELSE ISNULL(p.strPricingMethod, 'None') END
FROM tblICItemPricing p
WHERE p.intImportFlagInternal = 1

UPDATE pl
SET pl.dblUnitPrice =
	dbo.fnICCalculateSalePriceLevel(
		pl.strPricingMethod, 
		pl.dblUnitPrice, 
		CASE WHEN cp.intDefaultCurrencyId IS NOT NULL THEN 1 ELSE 0 END,
		p.dblSalePrice,
		p.dblMSRPPrice,
		pl.dblAmountRate,
		pl.dblUnit,
		p.dblStandardCost,
		p.dblLastCost,
		p.dblAverageCost
	)
FROM tblICItemPricingLevel pl
	INNER JOIN tblICItemPricing p ON p.intItemLocationId = pl.intItemLocationId
		AND p.intItemId = pl.intItemId
		AND pl.dtmEffectiveDate >= p.dtmEffectiveCostDate
	LEFT JOIN tblSMCompanyPreference cp ON cp.intDefaultCurrencyId = pl.intCurrencyId
	INNER JOIN tblICItem i ON i.intItemId = p.intItemId
WHERE p.intImportFlagInternal = 1

UPDATE tblICItemPricing SET intImportFlagInternal = 0