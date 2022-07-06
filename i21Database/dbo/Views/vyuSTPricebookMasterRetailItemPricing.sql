CREATE VIEW [dbo].[vyuSTPricebookMasterRetailItemPricing]
AS 
SELECT 
     CAST(ROW_NUMBER() OVER (ORDER BY intItemId, dblRetailPrice) AS INT) AS intEffectiveItemPriceId
	 , intItemLocationId
	 , intItemId
	 , intPrimaryId
	 , intStoreId
	 , intStoreNo
	 , strLocationName
	 , strUnitMeasure
	 , dblRetailPrice
	 , CAST(dtmEffectiveRetailPriceDate AS DATE) AS dtmEffectiveRetailPriceDate
	 , strType
	 , intConcurrencyId
	 
FROM 
(
	SELECT 
		retail.intEffectiveItemPriceId
		, retail.intItemLocationId
		, retail.intItemId
		, retail.intEffectiveItemPriceId AS intPrimaryId
		, Store.intStoreId
		, Store.intStoreNo
		, CompanyLoc.strLocationName
		, UM.strUnitMeasure
		, retail.dblRetailPrice
		, retail.dtmEffectiveRetailPriceDate
		, 'R' AS strType
		, retail.intConcurrencyId
	FROM tblICEffectiveItemPrice retail
	INNER JOIN tblICItemLocation ItemLoc
		ON retail.intItemLocationId = ItemLoc.intItemLocationId
		AND retail.intItemId = ItemLoc.intItemId
	INNER JOIN tblSMCompanyLocation CompanyLoc
		ON ItemLoc.intLocationId = CompanyLoc.intCompanyLocationId
	INNER JOIN tblSTStore Store
		ON CompanyLoc.intCompanyLocationId = Store.intCompanyLocationId
	INNER JOIN tblICItemUOM UOM
		ON UOM.intItemUOMId = retail.intItemUOMId
	INNER JOIN tblICUnitMeasure UM
		ON UM.intUnitMeasureId = UOM.intUnitMeasureId
	UNION
	SELECT 
		NULL AS intEffectiveItemPriceId
		, sp.intItemLocationId
		, sp.intItemId
		, sp.intItemSpecialPricingId AS intPrimaryId
		, Store.intStoreId
		, Store.intStoreNo
		, ISNULL(CompanyLoc.strLocationName, '') AS strLocationName
		, UM.strUnitMeasure
		, sp.dblUnitAfterDiscount
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
	INNER JOIN tblICItemUOM UOM
		ON UOM.intItemUOMId = sp.intItemUnitMeasureId
	INNER JOIN tblICUnitMeasure UM
		ON UM.intUnitMeasureId = UOM.intUnitMeasureId
	WHERE sp.dblUnitAfterDiscount != 0
) effective
