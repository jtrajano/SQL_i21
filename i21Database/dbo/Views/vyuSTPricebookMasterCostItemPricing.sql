CREATE VIEW [dbo].[vyuSTPricebookMasterCostItemPricing]
AS 
SELECT 
     CAST(ROW_NUMBER() OVER (ORDER BY intItemId, dblCost) AS INT) AS intEffectiveItemCostId
	 , intItemLocationId
	 , intItemId
	 , intPrimaryId
	 , intStoreId
	 , intStoreNo
	 , strLocationName
	 , dblCost
	 , CAST(dtmEffectiveCostDate AS DATE) AS dtmEffectiveCostDate
	 , strType
	 , intConcurrencyId
	 
FROM 
(
	SELECT 
		cost.intEffectiveItemCostId
		, cost.intItemLocationId
		, cost.intItemId
		, cost.intEffectiveItemCostId AS intPrimaryId
		, Store.intStoreId
		, Store.intStoreNo
		, CompanyLoc.strLocationName
		, cost.dblCost
		, cost.dtmEffectiveCostDate
		, 'R' AS strType
		, cost.intConcurrencyId
	FROM tblICEffectiveItemCost cost
	INNER JOIN tblICItemLocation ItemLoc
		ON cost.intItemLocationId = ItemLoc.intItemLocationId
		AND cost.intItemId = ItemLoc.intItemId
	INNER JOIN tblSMCompanyLocation CompanyLoc
		ON ItemLoc.intLocationId = CompanyLoc.intCompanyLocationId
	LEFT JOIN tblSTStore Store
		ON CompanyLoc.intCompanyLocationId = Store.intCompanyLocationId
	UNION
	SELECT 
		NULL AS intEffectiveItemPriceId
		, sp.intItemLocationId
		, sp.intItemId
		, sp.intItemSpecialPricingId AS intPrimaryId
		, Store.intStoreId
		, Store.intStoreNo
		, ISNULL(CompanyLoc.strLocationName, '') AS strLocationName
		, sp.dblCost
		, sp.dtmBeginDate
		, 'P' AS strType
		, sp.intConcurrencyId
	FROM tblICItemSpecialPricing sp
	LEFT JOIN tblICItemLocation ItemLoc
		ON sp.intItemLocationId = ItemLoc.intItemLocationId
		AND sp.intItemId = ItemLoc.intItemId
	LEFT JOIN tblSMCompanyLocation CompanyLoc
		ON ItemLoc.intLocationId = CompanyLoc.intCompanyLocationId
	LEFT JOIN tblSTStore Store
		ON CompanyLoc.intCompanyLocationId = Store.intCompanyLocationId
	WHERE sp.dblCost != 0
) effective

