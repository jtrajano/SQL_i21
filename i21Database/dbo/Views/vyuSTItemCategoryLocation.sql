CREATE VIEW [dbo].[vyuSTItemCategoryLocation]
AS
SELECT DISTINCT
		C.intCategoryId
      , C.strCategoryCode
	  , C.strDescription AS strCategoryDescription
	  , I.intItemId
	  , I.strItemNo
	  , I.strDescription AS strItemDescription
	  , CL.intCompanyLocationId
	  , CL.strLocationName
	  , ST.intStoreId
	  , ST.intStoreNo
	  , C.intConcurrencyId
	  , ItemLoc.intIssueUOMId
	  , CASE
			WHEN ItemLoc.intIssueUOMId IS NOT NULL
				THEN CAST(1 AS BIT)
			ELSE
				CAST(0 AS BIT)
	  END AS ysnHasIssuedUOM
	  , dblAverageMargin	= ISNULL(CategoryPricing.dblAverageMargin, 0)
	  , dblTotalCostValue	= ISNULL(CategoryPricing.dblTotalCostValue, 0)
	  , dblTotalRetailValue	= ISNULL(CategoryPricing.dblTotalRetailValue, 0)
FROM tblICCategory C
LEFT JOIN tblICCategoryLocation CLOC
	ON C.intCategoryId = CLOC.intCategoryId
LEFT JOIN tblICItem I
	ON CLOC.intGeneralItemId = I.intItemId
LEFT JOIN tblSMCompanyLocation CL
	ON CLOC.intLocationId = CL.intCompanyLocationId
LEFT JOIN tblICItemLocation ItemLoc
	ON I.intItemId = ItemLoc.intItemId
	AND CL.intCompanyLocationId = ItemLoc.intLocationId
LEFT JOIN tblSTStore ST
	ON CL.intCompanyLocationId = ST.intCompanyLocationId
LEFT JOIN tblICCategoryPricing CategoryPricing
	ON C.intCategoryId = CategoryPricing.intCategoryId
		AND ItemLoc.intItemLocationId = CategoryPricing.intItemLocationId