CREATE VIEW [dbo].[vyuICGetItemPricing]
	AS 

SELECT 
	intPricingKey = CAST(ROW_NUMBER() OVER(ORDER BY Item.intKey, ItemPricing.intItemPricingId) AS INT),
	Item.intKey,
	Item.strItemNo,
	Item.strDescription,
	Item.intVendorId,
	Item.strVendorId,
	strVendorName = Vendor.strName,
	ItemUOM.strUpcCode,
	ItemUOM.strLongUPCCode,
	ItemPricing.intItemPricingId,
	Item.intItemId,
	Item.intLocationId,
	ItemPricing.intItemLocationId as intItemLocationId,
	Item.strLocationName,
	Item.strLocationType,
	ItemUOM.intItemUOMId as intItemUnitMeasureId,
	ItemUOM.intItemUOMId, 
	UOM.intUnitMeasureId,
	UOM.strUnitMeasure,
	UOM.strUnitType,
	UOM.intDecimalPlaces,
	ItemUOM.ysnStockUnit,
	ItemUOM.ysnAllowPurchase,
	ItemUOM.ysnAllowSale,
	ItemUOM.dblUnitQty,
	dblAmountPercent = ISNULL(ItemPricing.dblAmountPercent, 0),
	dblSalePrice = ISNULL(ItemPricing.dblSalePrice * ItemUOM.dblUnitQty, 0),
	dblMSRPPrice = ISNULL(ItemPricing.dblMSRPPrice * ItemUOM.dblUnitQty, 0),
	ItemPricing.strPricingMethod,
	dblLastCost = ISNULL(ItemPricing.dblLastCost * ItemUOM.dblUnitQty, 0),
	dblStandardCost = ISNULL(ItemPricing.dblStandardCost * ItemUOM.dblUnitQty, 0),
	dblAverageCost = ISNULL(ItemPricing.dblAverageCost * ItemUOM.dblUnitQty, 0),
	dblEndMonthCost = ISNULL(ItemPricing.dblEndMonthCost * ItemUOM.dblUnitQty, 0),
	ItemPricing.intSort,
	Item.strType,
	Item.strLotTracking,
	Item.strCommodityCode AS strCommodity,
	Item.strCategoryCode AS strCategory,
	Item.strStatus,
	ItemPricing.dtmEffectiveCostDate,
	ItemPricing.dtmEffectiveRetailDate
FROM vyuICGetItemStock Item
LEFT JOIN tblEMEntity Vendor ON Vendor.intEntityId = Item.intVendorId
LEFT JOIN tblICItemPricing ItemPricing ON ItemPricing.intItemId = Item.intItemId and ItemPricing.intItemLocationId = Item.intItemLocationId
LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemId = Item.intItemId
LEFT JOIN tblICUnitMeasure UOM ON UOM .intUnitMeasureId= ItemUOM.intUnitMeasureId