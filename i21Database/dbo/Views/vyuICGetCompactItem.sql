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
, Item.intOriginId
, strOriginName = CommodityAttrib.strDescription
, Item.strCostType
, Item.strShortName
, Item.strRequired
, Item.ysnBasisContract
, Item.intM2MComputationId
, M2M.strM2MComputation
, strTonnageTaxUOM = TonnageUOM.strUnitMeasure
, Item.intTonnageTaxUOMId
, strFuelCategory 		= FuelCategory.strRinFuelCategoryCode
, strMedicationTag 		= Medication.strDescription
, strIngredientTag 		= Ingredient.strDescription
, strPhysicalItem 		= PhysicalItem.strItemNo
, strPatronageCategory 	= PatronageCategory.strCategoryCode
, strPatronageDirect 	= PatronageDirect.strCategoryCode
, strOrigin 			= Origin.strDescription
, strProductType		= ProductType.strDescription
, strRegion 			= Region.strDescription
, strSeason 			= Season.strDescription
, strClass 				= Class.strDescription
, strProductLine 		= ProductLine.strDescription
--, strItemMessage		= ItemMessage.strDescription
, strHazmatMessage		= HazMat.strDescription
FROM tblICItem Item
LEFT JOIN tblICCommodity Commodity ON Commodity.intCommodityId = Item.intCommodityId
LEFT JOIN tblICCategory Category ON Category.intCategoryId = Item.intCategoryId
LEFT JOIN tblICManufacturer Manufacturer ON Manufacturer.intManufacturerId = Item.intManufacturerId
LEFT JOIN tblICBrand Brand ON Brand.intBrandId = Item.intBrandId
LEFT JOIN tblICItem OnCostType ON OnCostType.intItemId = Item.intOnCostTypeId
LEFT JOIN tblICItemUOM CostItemUOM ON CostItemUOM.intItemUOMId = Item.intCostUOMId
LEFT JOIN tblICUnitMeasure CostUOM ON CostUOM.intUnitMeasureId = CostItemUOM.intUnitMeasureId
LEFT JOIN tblICUnitMeasure TonnageUOM ON TonnageUOM.intUnitMeasureId = Item.intTonnageTaxUOMId
LEFT JOIN tblICCommodityAttribute CommodityAttrib ON CommodityAttrib.intCommodityAttributeId = Item.intOriginId
LEFT JOIN tblICM2MComputation M2M ON M2M.intM2MComputationId = Item.intM2MComputationId
LEFT JOIN tblICRinFuelCategory FuelCategory ON FuelCategory.intRinFuelCategoryId = Item.intRINFuelTypeId
LEFT JOIN tblICTag Medication ON Medication.intTagId = Item.intMedicationTag
LEFT JOIN tblICTag Ingredient ON Ingredient.intTagId = Item.intIngredientTag
LEFT JOIN tblICTag HazMat ON HazMat.intTagId = Item.intHazmatMessage
--LEFT JOIN tblICTag ItemMessage ON ItemMessage.intTagId = Item.intItemMessage
LEFT JOIN tblICItem PhysicalItem ON PhysicalItem.intItemId = Item.intPhysicalItem
LEFT JOIN tblPATPatronageCategory PatronageCategory ON PatronageCategory.intPatronageCategoryId = Item.intPatronageCategoryId
LEFT JOIN tblPATPatronageCategory PatronageDirect ON PatronageDirect.intPatronageCategoryId = Item.intPatronageCategoryDirectId
LEFT JOIN tblICCommodityAttribute Origin ON Origin.intCommodityAttributeId = Item.intOriginId
LEFT JOIN tblICCommodityAttribute ProductType ON ProductType.intCommodityAttributeId = Item.intProductTypeId
LEFT JOIN tblICCommodityAttribute Region ON Region.intCommodityAttributeId = Item.intRegionId
LEFT JOIN tblICCommodityAttribute Season ON Season.intCommodityAttributeId = Item.intSeasonId
LEFT JOIN tblICCommodityAttribute Class ON Class.intCommodityAttributeId = Item.intClassVarietyId
LEFT JOIN tblICCommodityProductLine ProductLine ON ProductLine.intCommodityProductLineId = Item.intProductLineId