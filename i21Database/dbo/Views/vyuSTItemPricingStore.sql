CREATE VIEW dbo.vyuSTItemPricingStore
AS
SELECT 
	pricing.intItemPricingId 
	, item.intItemId
	, itemLoc.intItemLocationId
	, companyLoc.intCompanyLocationId
	, store.intStoreId
	, item.strItemNo
	, item.strDescription AS strItemDescription
	, companyLoc.strLocationName
	, store.intStoreNo
	, store.strDescription AS strStoreDescription
	, store.strRegion
	, store.strDistrict
	, pricing.intConcurrencyId
FROM tblICItemPricing pricing
INNER JOIN tblICItem item
	ON pricing.intItemId = item.intItemId
INNER JOIN tblICItemLocation itemLoc
	ON pricing.intItemLocationId = itemLoc.intItemLocationId
	AND item.intItemId = itemLoc.intItemId
INNER JOIN tblSMCompanyLocation companyLoc
	ON itemLoc.intLocationId = companyLoc.intCompanyLocationId
INNER JOIN tblSTStore store
	ON companyLoc.intCompanyLocationId = store.intCompanyLocationId