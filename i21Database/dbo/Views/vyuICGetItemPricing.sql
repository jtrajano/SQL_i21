CREATE VIEW [dbo].[vyuICGetItemPricing]
	AS 

SELECT 
intPricingKey = CAST(ROW_NUMBER() OVER(ORDER BY Item.intKey, ItemPricing.intItemPricingId) AS INT),
Item.intKey,
Item.strDescription,
ItemUOM.strUpcCode,
ItemUOM.strDescription as strUPCDescription,
ItemPricing.intItemPricingId,
ItemPricing.intItemId,
Item.intLocationId,
ItemPricing.intItemLocationId,
Item.strLocationName,
Item.strLocationType,
ItemPricing.intItemUnitMeasureId,
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
ItemPricing.dblMovingAverageCost,
ItemPricing.dblEndMonthCost,
ItemPricing.dtmBeginDate,
ItemPricing.dtmEndDate,
ItemPricing.intSort
FROM vyuICGetItemStock Item
INNER JOIN tblICItemPricing ItemPricing ON ItemPricing.intItemId = Item.intItemId and ItemPricing.intItemLocationId = Item.intItemLocationId
LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = ItemPricing.intItemUnitMeasureId
LEFT JOIN tblICUnitMeasure UOM ON UOM .intUnitMeasureId= ItemUOM.intUnitMeasureId
