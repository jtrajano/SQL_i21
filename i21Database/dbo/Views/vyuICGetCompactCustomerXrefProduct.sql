CREATE VIEW [dbo].[vyuICGetCompactCustomerXrefProduct]
AS

SELECT 
	Item.intItemId
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
	, Item.ysnAutoAdjustAccrualDiff
	, Item.intM2MComputationId
	, M2M.strM2MComputation
	, strTonnageTaxUOM = TonnageUOM.strUnitMeasure
	, Item.intTonnageTaxUOMId
	, strFuelCategory 		= FuelCategory.strRinFuelCategoryCode
	, strPhysicalItem 		= PhysicalItem.strItemNo
	, strPatronageCategory 	= PatronageCategory.strCategoryCode
	, strDirectSaleCategory	= PatronageDirect.strCategoryCode
 	, intSubcategoriesId = subcategory.intSubcategoriesId  
  	, strSubCategory  = subcategory.strSubCategory
	, strGrade				= Grade.strDescription
	, strOrigin 			= Origin.strDescription
	, strProductType		= ProductType.strDescription
	, strRegion 			= Region.strDescription
	, strSeason 			= Season.strDescription
	, strClass 				= Class.strDescription
	, strProductLine 		= ProductLine.strDescription
	, ysnUseWeighScales		= Item.ysnUseWeighScales
	, strBundleType			= Item.strBundleType
	, strDimensionUOM		= mfgDimensionUOM.strUnitMeasure
	, strWeightUOM			= mfgWeightUOM.strUnitMeasure
	, strSecondaryStatus    = LotStatus.strSecondaryStatus
	, Item.ysnLotWeightsRequired
	, strMedicationTag 		= Medication.strTagNumber
	, strIngredientTag 		= Ingredient.strTagNumber
	, strHazmatTag			= HazMat.strTagNumber
	, strMedicationMessage 		= Medication.strDescription
	, strIngredientMessage 		= Ingredient.strDescription
	, strHazmatMessage			= HazMat.strDescription
	, strMaterialPackUOM	= ManufacturingPackingUOM.strUnitMeasure
	, Item.intMaterialPackTypeId
	, Item.ysn1099Box3
	, Item.ysnBillable
	, Item.ysnSupported
	, Item.ysnDisplayInHelpdesk
	, Module.strModule
	, Item.strManufactureType
	, Item.strRemarks
	, Certification.strCertificationName
	, Item.dblGAShrinkFactor
	, Item.strMarketValuation
	, Item.intValuationGroupId
	, strValuationGroup = VG.strName
	, attribute1.strAttribute1
	, attribute2.strAttribute2
	, attribute3.strAttribute3
	, attribute4.strAttribute4
	, strStoreFamily = StoreFamily.strSubcategoryId
	, strStoreClass = StoreClass.strSubcategoryId
	, CustomerXref.strCustomerProduct
	, CustomerXref.strProductDescription
	, CustomerXref.intCustomerId
	, c.strCustomerNumber
	, CustomerXref.intItemCustomerXrefId
FROM 
	tblICItemCustomerXref CustomerXref
	INNER JOIN tblICItem Item ON Item.intItemId = CustomerXref.intItemId
	INNER JOIN tblARCustomer c ON c.intEntityId = CustomerXref.intCustomerId
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
	LEFT JOIN tblICTag HazMat ON HazMat.intTagId = Item.intHazmatTag
	LEFT JOIN tblICItem PhysicalItem ON PhysicalItem.intItemId = Item.intPhysicalItem
	LEFT JOIN tblPATPatronageCategory PatronageCategory ON PatronageCategory.intPatronageCategoryId = Item.intPatronageCategoryId
	LEFT JOIN tblPATPatronageCategory PatronageDirect ON PatronageDirect.intPatronageCategoryId = Item.intPatronageCategoryDirectId
	LEFT JOIN tblICCommodityAttribute Grade ON Grade.intCommodityAttributeId = Item.intGradeId
	LEFT JOIN tblICCommodityAttribute Origin ON Origin.intCommodityAttributeId = Item.intOriginId
	LEFT JOIN tblICCommodityAttribute ProductType ON ProductType.intCommodityAttributeId = Item.intProductTypeId
	LEFT JOIN tblICCommodityAttribute Region ON Region.intCommodityAttributeId = Item.intRegionId
	LEFT JOIN tblICCommodityAttribute Season ON Season.intCommodityAttributeId = Item.intSeasonId
	LEFT JOIN tblICCommodityAttribute Class ON Class.intCommodityAttributeId = Item.intClassVarietyId
	LEFT JOIN tblICCommodityProductLine ProductLine ON ProductLine.intCommodityProductLineId = Item.intProductLineId
	LEFT JOIN tblICUnitMeasure ManufacturingPackingUOM ON ManufacturingPackingUOM.intUnitMeasureId = Item.intMaterialPackTypeId
	LEFT JOIN tblICLotStatus LotStatus ON LotStatus.intLotStatusId = Item.intLotStatusId
	LEFT JOIN tblCTValuationGroup VG ON VG.intValuationGroupId = Item.intValuationGroupId
	LEFT JOIN (
		tblICUnitMeasure mfgDimensionUOM INNER JOIN tblICItemUOM mfgDimensionItemUOM
			ON mfgDimensionUOM.intUnitMeasureId = mfgDimensionItemUOM.intUnitMeasureId		
	)
		ON mfgDimensionItemUOM.intItemId = Item.intItemId
		AND mfgDimensionUOM.intUnitMeasureId = Item.intDimensionUOMId
	LEFT JOIN (
		tblICUnitMeasure mfgWeightUOM INNER JOIN tblICItemUOM mfgWeightItemUOM
			ON mfgWeightUOM.intUnitMeasureId = mfgWeightItemUOM.intUnitMeasureId		
	)
		ON mfgWeightItemUOM.intItemId = Item.intItemId	
		AND mfgWeightUOM.intUnitMeasureId = Item.intWeightUOMId
	LEFT JOIN tblSMModule Module
		ON Module.intModuleId = Item.intModuleId
	LEFT JOIN tblICCertification Certification
		ON Certification.intCertificationId = Item.intCertificationId
	LEFT JOIN tblICCommodityAttribute1 attribute1 ON attribute1.intCommodityAttributeId1 = Item.intCommodityAttributeId1
	LEFT JOIN tblICCommodityAttribute2 attribute2 ON attribute2.intCommodityAttributeId2 = Item.intCommodityAttributeId2
	LEFT JOIN tblICCommodityAttribute3 attribute3 ON attribute3.intCommodityAttributeId3 = Item.intCommodityAttributeId3
	LEFT JOIN tblICCommodityAttribute4 attribute4 ON attribute4.intCommodityAttributeId4 = Item.intCommodityAttributeId4
	LEFT JOIN tblSTSubCategories subcategory  ON subcategory.intSubcategoriesId = Item.intSubcategoriesId
	OUTER APPLY (SELECT strSubcategoryId FROM tblSTSubcategory WHERE intSubcategoryId = Item.intStoreFamilyId) AS StoreFamily
	OUTER APPLY (SELECT strSubcategoryId FROM tblSTSubcategory WHERE intSubcategoryId = Item.intStoreClassId) AS StoreClass
