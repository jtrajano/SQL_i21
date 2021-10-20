CREATE VIEW vyuSTItemDetailSearch
AS
SELECT DISTINCT
	ROW_NUMBER() OVER (ORDER BY it.intItemId, it.strItemNo) as intUniqueId
	, it.intItemId
	, it.strItemNo
	, it.strDescription
	, st.intStoreNo
	, cl.strLocationName
	, uom.strLongUPCCode
	, uom.strUpcCode
	, um.strUnitMeasure
	, cg.strCountGroup
	, ven.strName AS strVendorName
	, ven.strVendorId AS strVendorNo
	, xref.strVendorProduct
	, xref.strProductDescription
	, ISNULL(ip.dblSalePrice, 0) AS dblSalePrice
	, ISNULL(effectivePrice.dblRetailPrice, 0) AS dblRetailPrice
	, effectivePrice.dtmEffectiveRetailPriceDate AS dtmEffectiveRetailPriceDate
	, ISNULL(ip.dblStandardCost, 0) AS dblStandardCost
	, ISNULL(effectiveCost.dblCost, 0) AS dblCost
	, effectiveCost.dtmEffectiveCostDate as dtmEffectiveCostDate
	, SplPrc.dtmBeginDate
	, SplPrc.dtmEndDate
	, ISNULL(SplPrc.dblUnitAfterDiscount, 0) AS dblUnitAfterDiscount
	, ISNULL(SplPrc.dblCost , 0) as dblPromotionalCost
	, ISNULL(
		(
			(CASE
					WHEN (CAST(GETDATE() AS DATE) BETWEEN SplPrc.dtmBeginDate AND SplPrc.dtmEndDate)
						THEN SplPrc.dblUnitAfterDiscount 
					WHEN (CAST(GETDATE() AS DATE) >= effectivePrice.dtmEffectiveRetailPriceDate)
						THEN effectivePrice.dblRetailPrice --Effective Retail Price
					ELSE ip.dblSalePrice
				END)
				- (CASE
					WHEN (CAST(GETDATE() AS DATE) BETWEEN SplPrc.dtmBeginDate AND SplPrc.dtmEndDate)
						THEN SplPrc.dblCost 
					WHEN (CAST(GETDATE() AS DATE) >= effectiveCost.dtmEffectiveCostDate)
						THEN effectiveCost.dblCost --Effective Cost
					ELSE ip.dblStandardCost
				END)
		) 
		/ CASE WHEN((CASE
			WHEN (CAST(GETDATE() AS DATE) BETWEEN SplPrc.dtmBeginDate AND SplPrc.dtmEndDate)
				THEN SplPrc.dblCost 
			WHEN (CAST(GETDATE() AS DATE) >= effectiveCost.dtmEffectiveCostDate)
				THEN effectiveCost.dblCost --Effective Cost
			ELSE ip.dblStandardCost
		END)) = 0 THEN 1 ELSE (CASE
			WHEN (CAST(GETDATE() AS DATE) BETWEEN SplPrc.dtmBeginDate AND SplPrc.dtmEndDate)
				THEN SplPrc.dblCost 
			WHEN (CAST(GETDATE() AS DATE) >= effectiveCost.dtmEffectiveCostDate)
				THEN effectiveCost.dblCost --Effective Cost
			ELSE ip.dblStandardCost
		END) END
		, 0)
		AS dblGrossMargin
	, cat.strCategoryCode
	, family.strSubcategoryId AS strFamily
	, class.strSubcategoryId AS strClass
FROM tblICItem AS it
JOIN tblICItemLocation loc
	ON it.intItemId = loc.intItemId
LEFT JOIN tblSTStore st
	ON loc.intLocationId = st.intCompanyLocationId
JOIN tblSMCompanyLocation cl
	ON loc.intLocationId = cl.intCompanyLocationId
LEFT JOIN tblICCountGroup cg
	ON loc.intCountGroupId = cg.intCountGroupId
LEFT JOIN tblICItemVendorXref xref
	ON it.intItemId = xref.intItemId
LEFT JOIN vyuAPVendor ven
	ON xref.intVendorId = ven.intEntityId
LEFT JOIN tblICCategory cat
	ON it.intCategoryId = cat.intCategoryId
LEFT JOIN tblICItemUOM uom
	ON it.intItemId = uom.intItemId
	AND uom.ysnStockUnit = 1
LEFT JOIN tblICUnitMeasure um
	ON uom.intUnitMeasureId = um.intUnitMeasureId
LEFT JOIN tblICManufacturer m
	ON it.intManufacturerId = m.intManufacturerId
LEFT JOIN tblICItemPricing ip
	ON loc.intItemLocationId = ip.intItemLocationId
LEFT JOIN 
(
	SELECT * FROM (
		SELECT 
				intItemId,
				intItemLocationId,
				dtmEffectiveRetailPriceDate,
				dblRetailPrice,
				ROW_NUMBER() OVER (PARTITION BY intItemId ORDER BY dtmEffectiveRetailPriceDate DESC) AS intRowNum
		FROM tblICEffectiveItemPrice
		WHERE CAST(GETDATE() AS DATE) >= dtmEffectiveRetailPriceDate
	) AS tblSTItemOnFirstLocation WHERE intRowNum = 1
) AS effectivePrice
	ON it.intItemId = effectivePrice.intItemId
	AND effectivePrice.intItemLocationId = loc.intItemLocationId
LEFT JOIN 
(
	SELECT * FROM (
		SELECT 
				intItemId,
				intItemLocationId,
				dtmEffectiveCostDate,
				dblCost,
				ROW_NUMBER() OVER (PARTITION BY intItemId ORDER BY dtmEffectiveCostDate DESC) AS intRowNum
		FROM tblICEffectiveItemCost
		WHERE CAST(GETDATE() AS DATE) >= dtmEffectiveCostDate
	) AS tblSTItemOnFirstLocation WHERE intRowNum = 1
) AS effectiveCost
	ON it.intItemId = effectiveCost.intItemId
	AND effectiveCost.intItemLocationId = loc.intItemLocationId
LEFT JOIN 
(
	SELECT * FROM (
		SELECT 
				intItemId,
				intItemLocationId,
				dtmBeginDate,
				dtmEndDate,
				dblUnitAfterDiscount,
				dblCost,
				row_number() over (partition by intItemId order by intItemLocationId asc) as intRowNum
		FROM tblICItemSpecialPricing
		WHERE CAST(GETDATE() AS DATE) BETWEEN dtmBeginDate AND dtmEndDate
	) AS tblSTItemOnFirstLocation WHERE intRowNum = 1
) AS SplPrc
	ON it.intItemId = SplPrc.intItemId
	AND loc.intItemLocationId = SplPrc.intItemLocationId
LEFT JOIN tblSTSubcategory family
	ON loc.intFamilyId = family.intSubcategoryId
LEFT JOIN tblSTSubcategory class
	ON loc.intClassId = class.intSubcategoryId