CREATE VIEW [dbo].[vyuICGetCompactItem]
	AS

SELECT Item.intItemId
, Item.strItemNo
, Item.strType
, Item.strDescription
, Manufacturer.strManufacturer
, Brand.strBrandCode
, Brand.strBrandName
, Item.strStatus
, Item.strModelNo
, strTracking = Item.strInventoryTracking
, Item.strLotTracking
, Item.intCommodityId
, strCommodity = Commodity.strCommodityCode
, Item.intCategoryId
, strCategory = Category.strCategoryCode
, Item.ysnInventoryCost
, Item.ysnAccrue
, Item.ysnMTM
, Item.ysnPrice
, Item.strCostMethod
, Item.intOnCostTypeId
, strOnCostType = OnCostType.strItemNo
, Item.dblAmount
, Item.intCostUOMId
, strCostUOM = CostUOM.strUnitMeasure
FROM tblICItem Item
LEFT JOIN tblICCommodity Commodity ON Commodity.intCommodityId = Item.intCommodityId
LEFT JOIN tblICCategory Category ON Category.intCategoryId = Item.intCategoryId
LEFT JOIN tblICManufacturer Manufacturer ON Manufacturer.intManufacturerId = Item.intManufacturerId
LEFT JOIN tblICBrand Brand ON Brand.intBrandId = Item.intBrandId
LEFT JOIN tblICItem OnCostType ON OnCostType.intItemId = Item.intOnCostTypeId
LEFT JOIN tblICItemUOM CostItemUOM ON CostItemUOM.intItemUOMId = Item.intCostUOMId
LEFT JOIN tblICUnitMeasure CostUOM ON CostUOM.intUnitMeasureId = CostItemUOM.intUnitMeasureId