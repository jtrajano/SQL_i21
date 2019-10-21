
CREATE VIEW dbo.vyuSTItemPricingAndUOM
AS 
SELECT 
	tblICItemLocation.intItemLocationId,
	tblSTStore.intStoreId,
	tblSTStore.intStoreNo,
	tblSTStore.strDescription,
	tblICItem.intItemId,
	tblICItem.strItemNo,
	tblICItem.strDescription as strItemDescription,
	tblICItemUOM.intItemUOMId,
	tblICItemUOM.strLongUPCCode,
	tblICItemUOM.strUpcCode,
	tblICItemPricing.dblLastCost,
	tblICItemPricing.dblAverageCost,
	tblICItemPricing.dblStandardCost,
	tblICItemPricing.dblSalePrice,
	strItemNoAndDescription = ISNULL(tblICItem.strItemNo,'') + '-' + ISNULL(tblICItem.strDescription,'')
FROM tblICItemPricing
INNER JOIN tblICItemLocation
	ON tblICItemPricing.intItemLocationId = tblICItemLocation.intItemLocationId
	AND tblICItemPricing.intItemId = tblICItemLocation.intItemId
INNER JOIN tblSMCompanyLocation CompanyLoc
	ON tblICItemLocation.intLocationId = CompanyLoc.intCompanyLocationId
INNER JOIN tblSTStore 
	ON CompanyLoc.intCompanyLocationId = tblSTStore.intCompanyLocationId
INNER JOIN tblICItem 
	ON tblICItem.intItemId = tblICItemPricing.intItemId
LEFT JOIN tblICItemUOM 
	ON tblICItemUOM.intItemUOMId = tblICItemLocation.intIssueUOMId
	

	