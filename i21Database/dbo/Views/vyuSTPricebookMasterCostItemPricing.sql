CREATE VIEW [dbo].[vyuSTPricebookMasterCostItemPricing]
AS 
SELECT 
	cost.intEffectiveItemCostId
	, cost.intItemLocationId
	, cost.intItemId
	, Store.intStoreId
	, Store.intStoreNo
	, CompanyLoc.strLocationName
	, cost.dblCost
	, cost.dtmEffectiveCostDate
	, cost.intConcurrencyId
FROM tblICEffectiveItemCost cost
INNER JOIN tblICItemLocation ItemLoc
	ON cost.intItemLocationId = ItemLoc.intItemLocationId
	AND cost.intItemId = ItemLoc.intItemId
INNER JOIN tblSMCompanyLocation CompanyLoc
	ON ItemLoc.intLocationId = CompanyLoc.intCompanyLocationId
INNER JOIN tblSTStore Store
	ON CompanyLoc.intCompanyLocationId = Store.intCompanyLocationId