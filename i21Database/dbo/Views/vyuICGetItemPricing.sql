CREATE VIEW [dbo].[vyuICGetItemPricing]
	AS 

SELECT 
	intPricingKey = CAST(ROW_NUMBER() OVER(ORDER BY Item.intKey, ItemPricing.intItemPricingId) AS INT),
	Item.intKey,
	Item.strDescription,
	ItemUOM.strUpcCode,
	ItemPricing.intItemPricingId,
	Item.intItemId,
	Item.intLocationId,
	ItemPricing.intItemLocationId as intItemLocationId,
	Item.strLocationName,
	Item.strLocationType,
	ItemUOM.intItemUOMId as intItemUnitMeasureId,
	UOM.intUnitMeasureId,
	UOM.strUnitMeasure,
	UOM.strUnitType,
	ItemUOM.ysnStockUnit,
	ItemUOM.dblUnitQty,
	dblAmountPercent = ISNULL(ItemPricing.dblAmountPercent, 0),
	dblSalePrice = ISNULL(ItemPricing.dblSalePrice * ItemUOM.dblUnitQty, 0),
	dblMSRPPrice = ISNULL(ItemPricing.dblMSRPPrice * ItemUOM.dblUnitQty, 0),
	ItemPricing.strPricingMethod,
	dblLastCost = ISNULL(ItemPricing.dblLastCost * ItemUOM.dblUnitQty, 0),
	dblStandardCost = ISNULL(ItemPricing.dblStandardCost * ItemUOM.dblUnitQty, 0),
	dblAverageCost = ISNULL(ItemPricing.dblAverageCost * ItemUOM.dblUnitQty, 0),
	dblEndMonthCost = ISNULL(ItemPricing.dblEndMonthCost * ItemUOM.dblUnitQty, 0),
	ItemPricing.intSort
FROM vyuICGetItemStock Item
LEFT JOIN tblICItemPricing ItemPricing ON ItemPricing.intItemId = Item.intItemId and ItemPricing.intItemLocationId = Item.intItemLocationId
LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemId = Item.intItemId
LEFT JOIN tblICUnitMeasure UOM ON UOM .intUnitMeasureId= ItemUOM.intUnitMeasureId
