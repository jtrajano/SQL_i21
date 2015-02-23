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
ItemPricing.dblRetailPrice,
ItemPricing.dblWholesalePrice,
ItemPricing.dblLargeVolumePrice,
ItemPricing.dblAmountPercent,
ItemPricing.dblSalePrice,
ItemPricing.dblMSRPPrice,
ItemPricing.strPricingMethod,
ItemPricing.dblLastCost,
ItemPricing.dblStandardCost,
ItemPricing.dblAverageCost,
ItemPricing.dblEndMonthCost,
ItemPricing.intSort
FROM vyuICGetItemStock Item
INNER JOIN tblICItemPricing ItemPricing ON ItemPricing.intItemId = Item.intItemId and ItemPricing.intItemLocationId = Item.intItemLocationId
LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemId = Item.intItemId
LEFT JOIN tblICUnitMeasure UOM ON UOM .intUnitMeasureId= ItemUOM.intUnitMeasureId
