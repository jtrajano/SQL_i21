CREATE VIEW [dbo].[vyuICGetItemPricing]
	AS 

SELECT 
intPricingKey = CAST(ROW_NUMBER() OVER(ORDER BY Item.intKey, ItemPricing.intItemPricingId) AS INT),
Item.intKey,
Item.strDescription,
ItemUOM.strUpcCode,
ItemPricing.intItemPricingId,
ItemPricing.intItemId,
Item.intLocationId,
ItemPricing.intItemLocationId,
Item.strLocationName,
Item.strLocationType,
ItemUOM.intItemUOMId as intItemUnitMeasureId,
UOM.intUnitMeasureId,
UOM.strUnitMeasure,
UOM.strUnitType,
ItemUOM.ysnStockUnit,
ItemUOM.dblUnitQty,
ItemPricing.dblAmountPercent,
dblSalePrice = ItemPricing.dblSalePrice * ItemUOM.dblUnitQty,
dblMSRPPrice = ItemPricing.dblMSRPPrice * ItemUOM.dblUnitQty,
ItemPricing.strPricingMethod,
dblLastCost = ItemPricing.dblLastCost * ItemUOM.dblUnitQty,
dblStandardCost = ItemPricing.dblStandardCost * ItemUOM.dblUnitQty,
dblAverageCost = ItemPricing.dblAverageCost * ItemUOM.dblUnitQty,
dblEndMonthCost = ItemPricing.dblEndMonthCost * ItemUOM.dblUnitQty,
ItemPricing.intSort
FROM vyuICGetItemStock Item
INNER JOIN tblICItemPricing ItemPricing ON ItemPricing.intItemId = Item.intItemId and ItemPricing.intItemLocationId = Item.intItemLocationId
LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemId = Item.intItemId
LEFT JOIN tblICUnitMeasure UOM ON UOM .intUnitMeasureId= ItemUOM.intUnitMeasureId
