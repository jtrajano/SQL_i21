CREATE VIEW [dbo].[vyuICSearchItem]
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
, Item.strCostType
, Item.strShortName
, Item.strRequired
, Item.ysnBasisContract
, Item.intM2MComputationId
, M2M.strM2MComputation
, strTonnageTaxUOM = TonnageUOM.strUnitMeasure
, Item.intTonnageTaxUOMId
--Begin: Commodity fields 
, Item.dblGAShrinkFactor 
, Item.intOriginId
, strOrigin = CommodityAttribOrigin.strDescription
, Item.intProductTypeId
, strProductType = CommodityAttribProductType.strDescription
, Item.intRegionId 
, strRegion = CommodityAttribRegion.strDescription
, Item.intSeasonId 
, strSeason = CommodityAttribSeason.strDescription
, Item.intClassVarietyId
, strClass = CommodityAttribClass.strDescription
, Item.intProductLineId 
, strProductLine = CommodityAttribProductLine.strDescription
, Item.intGradeId
, strGrade = CommodityAttribGrade.strDescription
, Item.strMarketValuation
--End: Commodity fields 
FROM tblICItem Item
LEFT JOIN tblICCommodity Commodity ON Commodity.intCommodityId = Item.intCommodityId
LEFT JOIN tblICCategory Category ON Category.intCategoryId = Item.intCategoryId
LEFT JOIN tblICManufacturer Manufacturer ON Manufacturer.intManufacturerId = Item.intManufacturerId
LEFT JOIN tblICBrand Brand ON Brand.intBrandId = Item.intBrandId
LEFT JOIN tblICItem OnCostType ON OnCostType.intItemId = Item.intOnCostTypeId
LEFT JOIN tblICItemUOM CostItemUOM ON CostItemUOM.intItemUOMId = Item.intCostUOMId
LEFT JOIN tblICUnitMeasure CostUOM ON CostUOM.intUnitMeasureId = CostItemUOM.intUnitMeasureId
LEFT JOIN tblICUnitMeasure TonnageUOM ON TonnageUOM.intUnitMeasureId = Item.intTonnageTaxUOMId
LEFT JOIN tblICM2MComputation M2M ON M2M.intM2MComputationId = Item.intM2MComputationId

LEFT JOIN tblICCommodityAttribute CommodityAttribOrigin ON CommodityAttribOrigin.intCommodityAttributeId = Item.intOriginId
LEFT JOIN tblICCommodityAttribute CommodityAttribProductType ON CommodityAttribProductType.intCommodityAttributeId = Item.intProductTypeId
LEFT JOIN tblICCommodityAttribute CommodityAttribRegion ON CommodityAttribRegion.intCommodityAttributeId = Item.intRegionId
LEFT JOIN tblICCommodityAttribute CommodityAttribSeason ON CommodityAttribSeason.intCommodityAttributeId = Item.intSeasonId
LEFT JOIN tblICCommodityAttribute CommodityAttribClass ON CommodityAttribClass.intCommodityAttributeId = Item.intClassVarietyId
LEFT JOIN tblICCommodityProductLine CommodityAttribProductLine ON CommodityAttribProductLine.intCommodityProductLineId = Item.intProductLineId
LEFT JOIN tblICCommodityAttribute CommodityAttribGrade ON CommodityAttribGrade.intCommodityAttributeId = Item.intGradeId
