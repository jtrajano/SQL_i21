CREATE VIEW dbo.vyuSTPricebookMaster
AS
SELECT DISTINCT
	ItemLoc.intItemLocationId AS intUniqueId
    , Item.intItemId
	, Item.strItemNo
	, Item.strShortName
	, Item.strDescription
	, Uom.strLongUPCCode
	, Uom.strUpcCode
	, Item.intConcurrencyId
	
	-- Unit Of Measure
	, unit.intUnitMeasureId
	, unit.strUnitMeasure

	-- Category
	, Category.intCategoryId
	, Category.strCategoryCode

	-- tblICItemPricing
	, Pricing.intItemPricingId
	, (CASE
				WHEN (CAST(GETDATE() AS DATE) BETWEEN SplPrc.dtmBeginDate AND SplPrc.dtmEndDate)
					THEN SplPrc.dblUnitAfterDiscount 
				WHEN (CAST(GETDATE() AS DATE) >= effectivePrice.dtmEffectiveRetailPriceDate)
					THEN effectivePrice.dblRetailPrice --Effective Retail Price
				ELSE Pricing.dblSalePrice
			END) AS dblSalePrice
	, Pricing.dblLastCost
	, (CASE
				WHEN (CAST(GETDATE() AS DATE) >= effectiveCost.dtmEffectiveCostDate)
					THEN effectiveCost.dblCost --Effective Cost
				ELSE Pricing.dblStandardCost
			END) AS dblStandardCost
	, Pricing.dblAverageCost
	, CASE
		WHEN Pricing.dblSalePrice > 0
			THEN (Pricing.dblSalePrice - Pricing.dblLastCost) / Pricing.dblSalePrice
		ELSE 0
	END AS dblGrossMargin

	-- Item Location
	, ItemLoc.intItemLocationId
	--, ISNULL(ItemLoc.strDescription,'') AS strPOSDescription
	, ItemLoc.intFamilyId
	, ItemLoc.intClassId
	, Family.strSubcategoryId AS strFamily
	, Class.strSubcategoryId AS strClass

	-- Vendor
	, Vendor.intEntityId AS intVendorId
	, Vendor.strName AS strVendorName

	-- tblICItemVendorXref
	, VendorXref.intItemVendorXrefId
	, VendorXref.strVendorProduct

	-- tblSMCompanyLocation
	, CompanyLoc.intCompanyLocationId
	, CompanyLoc.strLocationName
FROM dbo.tblICItem AS Item 
INNER JOIN tblICItemLocation ItemLoc
	ON Item.intItemId = ItemLoc.intItemId
INNER JOIN tblSMCompanyLocation CompanyLoc
	ON ItemLoc.intLocationId = CompanyLoc.intCompanyLocationId
INNER JOIN dbo.tblICCategory Category
	ON Item.intCategoryId = Category.intCategoryId

LEFT JOIN dbo.tblICItemPricing Pricing
	ON ItemLoc.intItemLocationId = Pricing.intItemLocationId
	AND Item.intItemId = Pricing.intItemId
LEFT JOIN dbo.tblICItemUOM Uom
	ON Item.intItemId = Uom.intItemId
LEFT JOIN dbo.tblICUnitMeasure unit
	ON Uom.intUnitMeasureId = unit.intUnitMeasureId
LEFT JOIN dbo.tblSTSubcategory Family
	ON ItemLoc.intFamilyId = Family.intSubcategoryId
LEFT JOIN dbo.tblSTSubcategory Class
	ON ItemLoc.intClassId = Class.intSubcategoryId
LEFT JOIN dbo.tblEMEntity Vendor
	ON ItemLoc.intVendorId = Vendor.intEntityId
LEFT JOIN dbo.tblICItemVendorXref VendorXref
	ON Item.intItemId = VendorXref.intItemId
	AND ItemLoc.intItemLocationId = VendorXref.intItemLocationId
LEFT JOIN 
(
	SELECT * FROM (
		SELECT 
				intItemId,
				intItemLocationId,
				dtmEffectiveRetailPriceDate,
				dblRetailPrice,
				ROW_NUMBER() OVER (PARTITION BY intItemId, intItemLocationId ORDER BY dtmEffectiveRetailPriceDate DESC) AS intRowNum
		FROM tblICEffectiveItemPrice
		WHERE CAST(GETDATE() AS DATE) >= dtmEffectiveRetailPriceDate
	) AS tblSTItemOnFirstLocation WHERE intRowNum = 1
) AS effectivePrice
	ON Item.intItemId = effectivePrice.intItemId
	AND effectivePrice.intItemLocationId = ItemLoc.intItemLocationId
LEFT JOIN 
(
	SELECT * FROM (
		SELECT 
				intItemId,
				intItemLocationId,
				dtmEffectiveCostDate,
				dblCost,
				ROW_NUMBER() OVER (PARTITION BY intItemId, intItemLocationId ORDER BY dtmEffectiveCostDate DESC) AS intRowNum
		FROM tblICEffectiveItemCost
		WHERE CAST(GETDATE() AS DATE) >= dtmEffectiveCostDate
	) AS tblSTItemOnFirstLocation WHERE intRowNum = 1
) AS effectiveCost
	ON Item.intItemId = effectiveCost.intItemId
	AND effectiveCost.intItemLocationId = ItemLoc.intItemLocationId
LEFT JOIN 
(
	SELECT * FROM (
		SELECT 
				intItemId,
				intItemLocationId,
				dtmBeginDate,
				dtmEndDate,
				dblUnitAfterDiscount,
				row_number() over (partition by intItemId, intItemLocationId order by intItemLocationId asc) as intRowNum
		FROM tblICItemSpecialPricing
		WHERE CAST(GETDATE() AS DATE) BETWEEN dtmBeginDate AND dtmEndDate
	) AS tblSTItemOnFirstLocation WHERE intRowNum = 1
) AS SplPrc
	ON Item.intItemId = SplPrc.intItemId
	AND ItemLoc.intItemLocationId = SplPrc.intItemLocationId
WHERE Uom.ysnStockUnit = 1



--LEFT JOIN 
--(
--	SELECT DISTINCT
--		intItemId
--		, strDescription
--		, ROW_NUMBER() OVER (PARTITION BY intItemId ORDER BY strDescription DESC) AS rn
--	FROM dbo.tblICItemLocation
--) ItemLoc_POSDescription
--	ON Item.intItemId = ItemLoc_POSDescription.intItemId
--	AND ItemLoc_POSDescription.rn = 1

--LEFT JOIN 
--(
--	SELECT DISTINCT
--		intItemId
--		, intFamilyId
--		, ROW_NUMBER() OVER (PARTITION BY intItemId ORDER BY intFamilyId DESC) AS rn
--	FROM dbo.tblICItemLocation
--) ItemLoc_Family
--	ON Item.intItemId = ItemLoc_Family.intItemId
--	AND ItemLoc_Family.rn = 1
--LEFT JOIN dbo.tblSTSubcategory Family
--	ON ItemLoc_Family.intFamilyId = Family.intSubcategoryId

--LEFT JOIN 
--(
--	SELECT DISTINCT
--		intItemId
--		, intClassId
--		, ROW_NUMBER() OVER (PARTITION BY intItemId ORDER BY intClassId DESC) AS rn
--	FROM dbo.tblICItemLocation
--) ItemLoc_Class
--	ON Item.intItemId = ItemLoc_Class.intItemId
--	AND ItemLoc_Class.rn = 1
--LEFT JOIN dbo.tblSTSubcategory Class
--	ON ItemLoc_Class.intClassId = Class.intSubcategoryId

--LEFT JOIN 
--(
--	SELECT DISTINCT
--		intItemId
--		, intVendorId
--		, ROW_NUMBER() OVER (PARTITION BY intItemId ORDER BY intVendorId DESC) AS rn
--	FROM dbo.tblICItemLocation
--) ItemLoc_Vendor
--	ON Item.intItemId = ItemLoc_Vendor.intItemId
--	AND ItemLoc_Vendor.rn = 1
--LEFT JOIN dbo.tblEMEntity Vendor
--	ON ItemLoc_Vendor.intVendorId = Vendor.intEntityId


--LEFT JOIN 
--(
--	SELECT DISTINCT
--		intItemId
--		, strVendorProduct
--		, ROW_NUMBER() OVER (PARTITION BY intItemId ORDER BY strVendorProduct DESC) AS rn
--	FROM dbo.tblICItemVendorXref
--) VendorXref
--	ON Item.intItemId = VendorXref.intItemId
--	AND VendorXref.rn = 1
