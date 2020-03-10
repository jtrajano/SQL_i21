

CREATE VIEW [dbo].[vyuSTPricebookMasterItemPricing]
AS 
SELECT 
	ItemPricing.intItemPricingId
	, ItemPricing.intItemLocationId
	, ItemPricing.intItemId
	, Store.intStoreId
	, Store.intStoreNo
	, Store.intCompanyLocationId
	, CompanyLoc.strLocationName
	, ItemPricing.dblSalePrice
	, ItemPricing.dblStandardCost
	, ItemPricing.dblLastCost
	, ItemPricing.intConcurrencyId
	
	-- Product Code
	, strProductCode = ProductCode.strRegProdCode
	, intProductCodeId = ItemLoc.intProductCodeId

	--SalesUOM
	,strSaleUOM = IssueUOM.strUnitMeasure
	,ItemLoc.intIssueUOMId

FROM tblICItemPricing ItemPricing
INNER JOIN tblICItemLocation ItemLoc
	ON ItemPricing.intItemLocationId = ItemLoc.intItemLocationId
	AND ItemPricing.intItemId = ItemLoc.intItemId
INNER JOIN tblSMCompanyLocation CompanyLoc
	ON ItemLoc.intLocationId = CompanyLoc.intCompanyLocationId
INNER JOIN tblSTStore Store
	ON CompanyLoc.intCompanyLocationId = Store.intCompanyLocationId
LEFT JOIN tblSTSubcategoryRegProd ProductCode 
	ON ProductCode.intRegProdId = ItemLoc.intProductCodeId
LEFT JOIN vyuICGetItemUOM IssueUOM 
	ON IssueUOM.intItemUOMId = ItemLoc.intIssueUOMId
GO


