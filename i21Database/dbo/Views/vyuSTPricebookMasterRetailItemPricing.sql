CREATE VIEW [dbo].[vyuSTPricebookMasterRetailItemPricing]
AS 
SELECT 
	retail.intEffectiveItemPriceId
	, retail.intItemLocationId
	, retail.intItemId
	, Store.intStoreId
	, Store.intStoreNo
	, CompanyLoc.strLocationName
	, retail.dblRetailPrice
	, retail.dtmEffectiveRetailPriceDate
	, retail.intConcurrencyId
FROM tblICEffectiveItemPrice retail
INNER JOIN tblICItemLocation ItemLoc
	ON retail.intItemLocationId = ItemLoc.intItemLocationId
	AND retail.intItemId = ItemLoc.intItemId
INNER JOIN tblSMCompanyLocation CompanyLoc
	ON ItemLoc.intLocationId = CompanyLoc.intCompanyLocationId
INNER JOIN tblSTStore Store
	ON CompanyLoc.intCompanyLocationId = Store.intCompanyLocationId