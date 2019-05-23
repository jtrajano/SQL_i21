CREATE VIEW dbo.vyuICPriceSearch
AS
	SELECT strPricingCategory, dblAccumulatedAmount,dblAccumulatedQty,dblAmountPercent,dblAverageCost,dblDiscount,dblDiscountThruAmount,dblDiscountThruQty,dblDiscountedPrice,dblEndMonthCost,
		dblLastCost,dblMSRPPrice,dblSalePrice,dblStandardCost,dblUnit,dblUnitAfterDiscount,dblUnitQty,dtmBeginDate,dtmEndDate,intCategoryId,intCommodityId,intConcurrencyId
		,intCurrencyId,intDecimalPlaces,intEntityVendorId,intItemId,intItemLocationId,intItemPricingId,intItemSpecialPricingId,intItemUOMId,intItemUnitMeasureId,intKey = NEWID()
		,intLocationId,intPricingKey,intSort,intUnitMeasureId,intVendorId,intVendorPricingId,strCategory,strCommodity,strCurrency,strDescription,strDiscountBy,strEntityLocation
		,strItemNo,strLocationName,strLocationType,strLongUPCCode,strLotTracking,strName,strPricingMethod,strPricingType,strPromotionType,strStatus,strType,strUPC
		,strUnitMeasure,strUnitType,strUpcCode,strVendorId,strVendorName,ysnAllowPurchase,ysnAllowSale,ysnStockUnit
	FROM (
		SELECT 'Item Pricing' strPricingCategory,
			dblAccumulatedAmount = NULL, dblAccumulatedQty = NULL, dblAmountPercent, dblAverageCost, dblDiscount = NULL, dblDiscountThruAmount = NULL, dblDiscountThruQty = NULL, dblDiscountedPrice = NULL
		, dblEndMonthCost, dblLastCost, dblMSRPPrice, dblSalePrice, dblStandardCost, dblUnit = NULL, dblUnitAfterDiscount = NULL, dblUnitQty, dtmBeginDate = NULL
		, dtmEndDate = NULL, intCategoryId = NULL, intCommodityId = NULL, intConcurrencyId = NULL, intCurrencyId = NULL, intDecimalPlaces, intEntityVendorId = NULL, intItemId, intItemLocationId
		, intItemPricingId, intItemSpecialPricingId = NULL, intItemUOMId, intItemUnitMeasureId, intKey, intLocationId, intPricingKey, intSort
		, intUnitMeasureId, intVendorId, intVendorPricingId = NULL, strCategory = NULL, strCommodity = NULL, strCurrency = NULL, strDescription, strDiscountBy = NULL, strEntityLocation = NULL
		, strItemNo, strLocationName, strLocationType, strLongUPCCode, strLotTracking = NULL, strName = NULL, strPricingMethod, strPricingType = NULL, strPromotionType = NULL
		, strStatus = NULL, strType = NULL, strUPC = NULL, strUnitMeasure, strUnitType, strUpcCode, strVendorId, strVendorName, ysnAllowPurchase, ysnAllowSale, ysnStockUnit
		FROM vyuICGetItemPricing
		WHERE ysnStockUnit = 1

	UNION ALL

		SELECT 'Vendor Pricing' strPricingCategory,
			dblAccumulatedAmount  = NULL, dblAccumulatedQty  = NULL, dblAmountPercent  = NULL, dblAverageCost  = NULL, dblDiscount  = NULL, dblDiscountThruAmount  = NULL, dblDiscountThruQty  = NULL
		, dblDiscountedPrice = NULL, dblEndMonthCost = NULL, dblLastCost = NULL, dblMSRPPrice = NULL, dblSalePrice = NULL, dblStandardCost = NULL, dblUnit
		, dblUnitAfterDiscount = NULL, dblUnitQty = NULL, dtmBeginDate
		, dtmEndDate, intCategoryId = NULL, intCommodityId = NULL, intConcurrencyId = NULL, intCurrencyId = NULL, intDecimalPlaces = NULL, intEntityVendorId, intItemId, intItemLocationId = NULL
		, intItemPricingId = NULL, intItemSpecialPricingId = NULL, intItemUOMId = NULL, intItemUnitMeasureId = NULL, intKey = NULL, intLocationId = NULL, intPricingKey = NULL, intSort = NULL
		, intUnitMeasureId = NULL, intVendorId = NULL, intVendorPricingId, strCategory = NULL, strCommodity = NULL, strCurrency, strDescription = NULL, strDiscountBy = NULL, strEntityLocation
		, strItemNo, strLocationName = NULL, strLocationType = NULL, strLongUPCCode = NULL, strLotTracking = NULL, strName = NULL, strPricingMethod = NULL, strPricingType = NULL, strPromotionType = NULL
		, strStatus = NULL, strType = NULL, strUPC = NULL, strUnitMeasure, strUnitType = NULL, strUpcCode = NULL, strVendorId = NULL, strVendorName = strName, ysnAllowPurchase = NULL, ysnAllowSale = NULL, ysnStockUnit = NULL
		FROM vyuICGetItemVendorPricing

	UNION ALL

		SELECT 'Pricing Level' strPricingCategory,
			dblAccumulatedAmount = NULL, dblAccumulatedQty = NULL, dblAmountPercent = NULL, dblAverageCost = NULL, dblDiscount = NULL, dblDiscountThruAmount = NULL, dblDiscountThruQty
			 = NULL, dblDiscountedPrice = NULL, dblEndMonthCost = NULL, dblLastCost = NULL, dblMSRPPrice = NULL, dblSalePrice = NULL, dblStandardCost = NULL, dblUnit, dblUnitAfterDiscount = NULL
			, dblUnitQty = NULL, dtmBeginDate = NULL, dtmEndDate = NULL, intCategoryId, intCommodityId, intConcurrencyId, intCurrencyId, intDecimalPlaces = NULL
			, intEntityVendorId = NULL, intItemId, intItemLocationId = NULL, intItemPricingId = NULL, intItemSpecialPricingId = NULL, intItemUOMId = NULL, intItemUnitMeasureId
			, intKey = NULL, intLocationId, intPricingKey = NULL, intSort, intUnitMeasureId = NULL, intVendorId = NULL, intVendorPricingId = NULL, strCategory, strCommodity
			, strCurrency, strDescription, strDiscountBy = NULL, strEntityLocation = NULL, strItemNo, strLocationName, strLocationType = NULL, strLongUPCCode = NULL
			, strLotTracking, strName = NULL, strPricingMethod, strPricingType = NULL, strPromotionType = NULL, strStatus, strType, strUPC, strUnitMeasure
			, strUnitType = NULL, strUpcCode = NULL, strVendorId = NULL, strVendorName = NULL, ysnAllowPurchase = NULL, ysnAllowSale = NULL, ysnStockUnit = NULL
		FROM vyuICGetItemPricingLevel

	UNION ALL

		SELECT 'Special Pricing' strPricingCategory,
			dblAccumulatedAmount, dblAccumulatedQty, dblAmountPercent = NULL, dblAverageCost = NULL, dblDiscount, dblDiscountThruAmount, dblDiscountThruQty
			, dblDiscountedPrice, dblEndMonthCost = NULL, dblLastCost = NULL, dblMSRPPrice = NULL, dblSalePrice = NULL, dblStandardCost = NULL, dblUnit
			, dblUnitAfterDiscount, dblUnitQty = NULL, dtmBeginDate, dtmEndDate, intCategoryId, intCommodityId, intConcurrencyId, intCurrencyId
			, intDecimalPlaces = NULL, intEntityVendorId = NULL, intItemId, intItemLocationId = NULL, intItemPricingId = NULL, intItemSpecialPricingId
			, intItemUOMId = NULL, intItemUnitMeasureId, intKey = NULL, intLocationId, intPricingKey = NULL, intSort = NULL, intUnitMeasureId = NULL
			, intVendorId = NULL, intVendorPricingId = NULL, strCategory, strCommodity, strCurrency, strDescription, strDiscountBy
			, strEntityLocation = NULL, strItemNo, strLocationName, strLocationType = NULL, strLongUPCCode = NULL, strLotTracking, strName = NULL
			, strPricingMethod = NULL, strPricingType = NULL, strPromotionType, strStatus, strType, strUPC, strUnitMeasure, strUnitType = NULL
			, strUpcCode = NULL, strVendorId = NULL, strVendorName = NULL, ysnAllowPurchase = NULL, ysnAllowSale = NULL, ysnStockUnit = NULL
		FROM vyuICGetItemSpecialPricing
) price