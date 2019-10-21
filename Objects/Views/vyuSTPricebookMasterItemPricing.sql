CREATE VIEW dbo.vyuSTPricebookMasterItemPricing
AS 
SELECT 
	ItemPricing.intItemPricingId
	, ItemPricing.intItemLocationId
	, ItemPricing.intItemId
	, Store.intStoreId
	, Store.intStoreNo
	, CompanyLoc.strLocationName
	, ItemPricing.dblSalePrice
	, ItemPricing.dblStandardCost
	, ItemPricing.dblLastCost
	, ItemPricing.intConcurrencyId
FROM tblICItemPricing ItemPricing
INNER JOIN tblICItemLocation ItemLoc
	ON ItemPricing.intItemLocationId = ItemLoc.intItemLocationId
	AND ItemPricing.intItemId = ItemLoc.intItemId
INNER JOIN tblSMCompanyLocation CompanyLoc
	ON ItemLoc.intLocationId = CompanyLoc.intCompanyLocationId
INNER JOIN tblSTStore Store
	ON CompanyLoc.intCompanyLocationId = Store.intCompanyLocationId