CREATE VIEW [dbo].[vyuICSearchItem]
AS

SELECT Item.intItemId
, Item.strItemNo
, Item.ysnRestrictedChemical
, Item.strType
, Item.strDescription
, strItemDescription = Item.strDescription
, Manufacturer.strManufacturer
, Brand.strBrandCode
, Brand.strBrandName
, Item.strStatus
, Item.strModelNo
, strTracking = Item.strInventoryTracking
, Item.strLotTracking
, Item.intCommodityId
, strCommodity = Commodity.strCommodityCode
, Commodity.strCommodityCode
, Item.intCategoryId
, strCategory = Category.strCategoryCode
, Category.strCategoryCode
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
, Item.ysnAutoAdjustAccrualDiff
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
, Item.ysnLotWeightsRequired
--End: Commodity fields 
, Item.strBundleType
, Item.ysnListBundleSeparately
, Item.strManufactureType
, Item.intValuationGroupId
, strValuationGroup = VG.strName
, CommodityAttribute1.strAttribute1
, CommodityAttribute2.strAttribute2
, CommodityAttribute3.strAttribute3
, CommodityAttribute4.strAttribute4
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
LEFT JOIN tblCTValuationGroup VG ON VG.intValuationGroupId = Item.intValuationGroupId
LEFT JOIN tblICCommodityAttribute CommodityAttribOrigin ON CommodityAttribOrigin.intCommodityAttributeId = Item.intOriginId
LEFT JOIN tblICCommodityAttribute CommodityAttribProductType ON CommodityAttribProductType.intCommodityAttributeId = Item.intProductTypeId
LEFT JOIN tblICCommodityAttribute CommodityAttribRegion ON CommodityAttribRegion.intCommodityAttributeId = Item.intRegionId
LEFT JOIN tblICCommodityAttribute CommodityAttribSeason ON CommodityAttribSeason.intCommodityAttributeId = Item.intSeasonId
LEFT JOIN tblICCommodityAttribute CommodityAttribClass ON CommodityAttribClass.intCommodityAttributeId = Item.intClassVarietyId
LEFT JOIN tblICCommodityProductLine CommodityAttribProductLine ON CommodityAttribProductLine.intCommodityProductLineId = Item.intProductLineId
LEFT JOIN tblICCommodityAttribute CommodityAttribGrade ON CommodityAttribGrade.intCommodityAttributeId = Item.intGradeId
LEFT JOIN tblICCommodityAttribute1 CommodityAttribute1 ON CommodityAttribute1.intCommodityAttributeId1 = Item.intCommodityAttributeId1
LEFT JOIN tblICCommodityAttribute2 CommodityAttribute2 ON CommodityAttribute2.intCommodityAttributeId2 = Item.intCommodityAttributeId2
LEFT JOIN tblICCommodityAttribute3 CommodityAttribute3 ON CommodityAttribute3.intCommodityAttributeId3 = Item.intCommodityAttributeId3
LEFT JOIN tblICCommodityAttribute4 CommodityAttribute4 ON CommodityAttribute4.intCommodityAttributeId4 = Item.intCommodityAttributeId4
