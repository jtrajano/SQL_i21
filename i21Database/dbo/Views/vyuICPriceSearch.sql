CREATE VIEW dbo.vyuICPriceSearch
AS
	SELECT strPricingCategory, dblAccumulatedAmount,dblAccumulatedQty,dblAmountPercent,dblAverageCost,dblDiscount,dblDiscountThruAmount,dblDiscountThruQty,dblDiscountedPrice,dblEndMonthCost,
		dblLastCost,dblMSRPPrice,dblSalePrice,dblStandardCost,dblUnit,dblUnitAfterDiscount,dblUnitQty,dtmBeginDate,dtmEndDate,intCategoryId,intCommodityId,intConcurrencyId
		,intCurrencyId,intDecimalPlaces,intEntityVendorId,intItemId,intItemLocationId,intItemPricingId,intItemSpecialPricingId,intItemUOMId,intItemUnitMeasureId,intKey = NEWID()
		,intLocationId,intPricingKey,intSort,intUnitMeasureId,intVendorId,intVendorPricingId,strCategory,strCommodity,strCurrency,strDescription,strDiscountBy,strEntityLocation
		,strItemNo,strLocationName,strLocationType,strLongUPCCode,strLotTracking,strName,strPricingMethod,strPricingType,strPromotionType,strStatus,strType,strUPC
		,strUnitMeasure,strUnitType,strUpcCode,strVendorId,strVendorName,ysnAllowPurchase,ysnAllowSale,ysnStockUnit, strFamily, strClass, ysnSaleable, strProductCode
		,dblGrossMargin = CASE WHEN dblSalePrice = 0 AND dblLastCost = 0 THEN 0 ELSE (dblSalePrice - dblLastCost) / ISNULL(NULLIF(dblSalePrice, 0), dblLastCost) END * 100.00
		,dtmEffectiveCostDate,dtmEffectiveRetailDate
	FROM (
		SELECT 'Item Pricing' COLLATE Latin1_General_CI_AS strPricingCategory,
			dblAccumulatedAmount = NULL, dblAccumulatedQty = NULL, p.dblAmountPercent, p.dblAverageCost, dblDiscount = NULL, dblDiscountThruAmount = NULL, dblDiscountThruQty = NULL, dblDiscountedPrice = NULL
		, p.dblEndMonthCost, p.dblLastCost, p.dblMSRPPrice, p.dblSalePrice, p.dblStandardCost, dblUnit = NULL, dblUnitAfterDiscount = NULL, p.dblUnitQty, dtmBeginDate = NULL
		, dtmEndDate = NULL, i.intCategoryId, i.intCommodityId, intConcurrencyId = NULL, intCurrencyId = NULL, p.intDecimalPlaces, intEntityVendorId = NULL, p.intItemId, p.intItemLocationId
		, p.intItemPricingId, intItemSpecialPricingId = NULL, p.intItemUOMId, p.intItemUnitMeasureId, p.intKey, p.intLocationId, p.intPricingKey, p.intSort
		, p.intUnitMeasureId, p.intVendorId, intVendorPricingId = NULL, strCategory = cr.strCategoryCode, strCommodity = cm.strCommodityCode, strCurrency = NULL, p.strDescription, strDiscountBy = NULL, strEntityLocation = NULL
		, p.strItemNo, p.strLocationName, p.strLocationType, p.strLongUPCCode, strLotTracking = NULL, strName = NULL, p.strPricingMethod, strPricingType = NULL, strPromotionType = NULL
		, i.strStatus, i.strType, strUPC = p.strLongUPCCode, p.strUnitMeasure, p.strUnitType, p.strUpcCode, p.strVendorId, p.strVendorName, p.ysnAllowPurchase, p.ysnAllowSale, p.ysnStockUnit
		, strFamily = sf.strSubcategoryId, strClass = sc.strSubcategoryId, il.ysnSaleable, strProductCode = sp.strRegProdCode
		, p.dtmEffectiveCostDate, p.dtmEffectiveRetailDate
		FROM vyuICGetItemPricing p
			INNER JOIN tblICItem i ON i.intItemId = p.intItemId
			LEFT OUTER JOIN tblICCategory cr ON cr.intCategoryId = i.intCategoryId
			LEFT OUTER JOIN tblICCommodity cm ON cm.intCommodityId = i.intCommodityId
			LEFT OUTER JOIN tblICItemLocation il ON il.intItemLocationId = p.intItemLocationId
			LEFT OUTER JOIN tblSTSubcategory sf ON sf.intSubcategoryId = il.intFamilyId
			LEFT OUTER JOIN tblSTSubcategory sc ON sc.intSubcategoryId = il.intClassId
			LEFT OUTER JOIN tblSTSubcategoryRegProd sp ON sp.intRegProdId = il.intProductCodeId
		WHERE p.ysnStockUnit = 1
	UNION ALL
	
		SELECT 'Vendor Pricing' COLLATE Latin1_General_CI_AS strPricingCategory ,
			dblAccumulatedAmount  = NULL, dblAccumulatedQty  = NULL, dblAmountPercent  = NULL, dblAverageCost  = NULL, dblDiscount  = NULL, dblDiscountThruAmount  = NULL, dblDiscountThruQty  = NULL
		, dblDiscountedPrice = NULL, dblEndMonthCost = NULL, dblLastCost = NULL, dblMSRPPrice = NULL, dblSalePrice = NULL, dblStandardCost = NULL, p.dblUnit
		, dblUnitAfterDiscount = NULL, dblUnitQty = NULL, p.dtmBeginDate
		, p.dtmEndDate, intCategoryId = i.intCategoryId, intCommodityId = i.intCommodityId, intConcurrencyId = NULL, intCurrencyId = NULL, intDecimalPlaces = NULL, p.intEntityVendorId, p.intItemId, intItemLocationId = NULL
		, intItemPricingId = NULL, intItemSpecialPricingId = NULL, intItemUOMId = NULL, intItemUnitMeasureId = NULL, intKey = NULL, intLocationId = NULL, intPricingKey = NULL, intSort = NULL
		, intUnitMeasureId = NULL, intVendorId = NULL, p.intVendorPricingId, strCategory = cr.strCategoryCode, strCommodity = cm.strCommodityCode, p.strCurrency, strDescription = i.strDescription, strDiscountBy = NULL, p.strEntityLocation
		, p.strItemNo, strLocationName = NULL, strLocationType = NULL, strLongUPCCode = NULL, strLotTracking = i.strLotTracking, strName = NULL, strPricingMethod = NULL, strPricingType = NULL, strPromotionType = NULL
		, strStatus = i.strStatus, strType = i.strType, strUPC = NULL, p.strUnitMeasure, strUnitType = NULL, strUpcCode = NULL, strVendorId = NULL, strVendorName = strName, ysnAllowPurchase = NULL, ysnAllowSale = NULL, ysnStockUnit = NULL
		, strFamily = NULL, strClass = NULL, ysnSaleable = NULL, strProductCode = NULL
		, dtmEffectiveCostDate = NULL, dtmEffectiveRetailDate = NULL
		FROM vyuICGetItemVendorPricing p
			INNER JOIN tblICItem i ON i.intItemId = p.intItemId
			LEFT OUTER JOIN tblICCategory cr ON cr.intCategoryId = i.intCategoryId
			LEFT OUTER JOIN tblICCommodity cm ON cm.intCommodityId = i.intCommodityId


	UNION ALL

		SELECT 'Pricing Level' COLLATE Latin1_General_CI_AS strPricingCategory ,
			dblAccumulatedAmount = NULL, dblAccumulatedQty = NULL, dblAmountPercent = p.dblAmountRate, dblAverageCost = pr.dblAverageCost, dblDiscount = NULL, dblDiscountThruAmount = NULL, dblDiscountThruQty
			 = NULL, dblDiscountedPrice = NULL, dblEndMonthCost = pr.dblEndMonthCost, dblLastCost = pr.dblLastCost, dblMSRPPrice = pr.dblMSRPPrice, dblSalePrice = p.dblUnitPrice, dblStandardCost = pr.dblStandardCost, p.dblUnit, dblUnitAfterDiscount = NULL
			, dblUnitQty = NULL, dtmBeginDate = NULL, dtmEndDate = NULL, p.intCategoryId, p.intCommodityId, p.intConcurrencyId, p.intCurrencyId, intDecimalPlaces = NULL
			, intEntityVendorId = NULL, p.intItemId, intItemLocationId = il.intItemLocationId, intItemPricingId = NULL, intItemSpecialPricingId = NULL, intItemUOMId = p.intItemUnitMeasureId, p.intItemUnitMeasureId
			, intKey = NULL, p.intLocationId, intPricingKey = NULL, p.intSort, intUnitMeasureId = NULL, intVendorId = NULL, intVendorPricingId = NULL, p.strCategory, p.strCommodity
			, p.strCurrency, p.strDescription, strDiscountBy = NULL, strEntityLocation = NULL, p.strItemNo, p.strLocationName, strLocationType = NULL, strLongUPCCode = NULL
			, p.strLotTracking, strName = NULL, p.strPricingMethod, strPricingType = NULL, strPromotionType = NULL, p.strStatus, p.strType, p.strUPC, p.strUnitMeasure
			, strUnitType = um.strUnitType, strUpcCode = p.strUPC, strVendorId = NULL, strVendorName = NULL, ysnAllowPurchase = u.ysnAllowPurchase, ysnAllowSale = u.ysnAllowSale, ysnStockUnit = u.ysnStockUnit
			, strFamily = sf.strSubcategoryId, strClass = sc.strSubcategoryId, ysnSaleable = il.ysnSaleable, strProductCode = sp.strRegProdCode
			, dtmEffectiveCostDate = NULL, dtmEffectiveRetailDate = NULL
		FROM vyuICGetItemPricingLevel p
			LEFT OUTER JOIN tblICItemLocation il ON il.intItemId = p.intItemId AND p.intLocationId = il.intLocationId
			LEFT OUTER JOIN tblICItemPricing pr ON pr.intItemLocationId = il.intItemLocationId
				AND pr.intItemId = p.intItemId
			LEFT OUTER JOIN tblSTSubcategory sf ON sf.intSubcategoryId = il.intFamilyId
			LEFT OUTER JOIN tblSTSubcategory sc ON sc.intSubcategoryId = il.intClassId
			LEFT OUTER JOIN tblSTSubcategoryRegProd sp ON sp.intRegProdId = il.intProductCodeId
			LEFT OUTER JOIN tblICItemUOM u ON u.intItemUOMId = p.intItemUnitMeasureId
			LEFT OUTER JOIN tblICUnitMeasure um ON um.intUnitMeasureId = u.intUnitMeasureId
	UNION ALL
		SELECT 'Special Pricing' COLLATE Latin1_General_CI_AS strPricingCategory,
			p.dblAccumulatedAmount, p.dblAccumulatedQty, dblAmountPercent = p.dblDiscount, dblAverageCost = pr.dblAverageCost, p.dblDiscount, p.dblDiscountThruAmount, p.dblDiscountThruQty
			, p.dblDiscountedPrice, dblEndMonthCost = pr.dblEndMonthCost, dblLastCost = pr.dblLastCost, dblMSRPPrice = pr.dblMSRPPrice, dblSalePrice = p.dblUnitAfterDiscount, dblStandardCost = pr.dblStandardCost, p.dblUnit
			, p.dblUnitAfterDiscount, dblUnitQty = NULL, p.dtmBeginDate, p.dtmEndDate, p.intCategoryId, p.intCommodityId, p.intConcurrencyId, p.intCurrencyId
			, intDecimalPlaces = NULL, intEntityVendorId = NULL, p.intItemId, intItemLocationId = NULL, intItemPricingId = NULL, p.intItemSpecialPricingId
			, intItemUOMId = u.intItemUOMId, p.intItemUnitMeasureId, intKey = NULL, p.intLocationId, intPricingKey = NULL, intSort = NULL, intUnitMeasureId = NULL
			, intVendorId = NULL, intVendorPricingId = NULL, p.strCategory, p.strCommodity, p.strCurrency, p.strDescription, p.strDiscountBy
			, strEntityLocation = NULL, p.strItemNo, p.strLocationName, strLocationType = NULL, strLongUPCCode = NULL, p.strLotTracking, strName = NULL
			, strPricingMethod = pr.strPricingMethod, strPricingType = NULL, p.strPromotionType, p.strStatus, p.strType, p.strUPC, p.strUnitMeasure, strUnitType = um.strUnitType
			, strUpcCode = u.strLongUPCCode, strVendorId = NULL, strVendorName = NULL, ysnAllowPurchase = u.ysnAllowPurchase, ysnAllowSale = u.ysnAllowSale, ysnStockUnit = u.ysnStockUnit
			, strFamily = sf.strSubcategoryId, strClass = sc.strSubcategoryId, ysnSaleable = il.ysnSaleable, strProductCode = sp.strRegProdCode
			, dtmEffectiveCostDate = NULL, dtmEffectiveRetailDate = NULL
		FROM vyuICGetItemSpecialPricing p
			LEFT OUTER JOIN tblICItemLocation il ON il.intItemId = p.intItemId AND p.intLocationId = il.intLocationId
			LEFT OUTER JOIN tblICItemPricing pr ON pr.intItemLocationId = il.intItemLocationId
				AND pr.intItemId = p.intItemId
			LEFT OUTER JOIN tblSTSubcategory sf ON sf.intSubcategoryId = il.intFamilyId
			LEFT OUTER JOIN tblSTSubcategory sc ON sc.intSubcategoryId = il.intClassId
			LEFT OUTER JOIN tblSTSubcategoryRegProd sp ON sp.intRegProdId = il.intProductCodeId
			LEFT OUTER JOIN tblICItemUOM u ON u.intItemUOMId = p.intItemUnitMeasureId
			LEFT OUTER JOIN tblICUnitMeasure um ON um.intUnitMeasureId = u.intUnitMeasureId
) price