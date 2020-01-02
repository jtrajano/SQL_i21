CREATE VIEW [dbo].[vyuIPGetItem]
AS
SELECT I.[intItemId]
	,I.[strItemNo]
	,I.[strShortName]
	,I.[strType]
	,I.[strBundleType]
	,I.[strDescription]
	,I.[intManufacturerId]
	,I.[intBrandId]
	,I.[intCategoryId]
	,I.[strStatus]
	,I.[strModelNo]
	,I.[strInventoryTracking]
	,I.[strLotTracking]
	,I.[ysnRequireCustomerApproval]
	,I.[intRecipeId]
	,I.[ysnSanitationRequired]
	,I.[intLifeTime]
	,I.[strLifeTimeType]
	,I.[intReceiveLife]
	,I.[strGTIN]
	,I.[strRotationType]
	,I.[intNMFCId]
	,I.[ysnStrictFIFO]
	,I.[intDimensionUOMId]
	,I.[dblHeight]
	,I.[dblWidth]
	,I.[dblDepth]
	,I.[intWeightUOMId]
	,I.[dblWeight]
	,I.[intMaterialPackTypeId]
	,I.[strMaterialSizeCode]
	,I.[intInnerUnits]
	,I.[intLayerPerPallet]
	,I.[intUnitPerLayer]
	,I.[dblStandardPalletRatio]
	,I.[strMask1]
	,I.[strMask2]
	,I.[strMask3]
	,I.[dblMaxWeightPerPack]
	,I.[intPatronageCategoryId]
	,I.[intPatronageCategoryDirectId]
	,I.[ysnStockedItem]
	,I.[ysnDyedFuel]
	,I.[strBarcodePrint]
	,I.[ysnMSDSRequired]
	,I.[strEPANumber]
	,I.[ysnInboundTax]
	,I.[ysnOutboundTax]
	,I.[ysnRestrictedChemical]
	,I.[ysnFuelItem]
	,I.[ysnTankRequired]
	,I.[ysnAvailableTM]
	,I.[dblDefaultFull]
	,I.[strFuelInspectFee]
	,I.[strRINRequired]
	,I.[intRINFuelTypeId]
	,I.[dblDenaturantPercent]
	,I.[ysnTonnageTax]
	,I.[ysnLoadTracking]
	,I.[dblMixOrder]
	,I.[ysnHandAddIngredient]
	,I.[intMedicationTag]
	,I.[intIngredientTag]
	,I.[intHazmatTag]
	,I.[strVolumeRebateGroup]
	,I.[intPhysicalItem]
	,I.[ysnExtendPickTicket]
	,I.[ysnExportEDI]
	,I.[ysnHazardMaterial]
	,I.[ysnMaterialFee]
	,I.[ysnAutoBlend]
	,I.[dblUserGroupFee]
	,I.[dblWeightTolerance]
	,I.[dblOverReceiveTolerance]
	,I.[strMaintenanceCalculationMethod]
	,I.[dblMaintenanceRate]
	,I.[ysnListBundleSeparately]
	,I.[intModuleId]
	,I.[strNACSCategory]
	,I.[strWICCode]
	,I.[intAGCategory]
	,I.[ysnReceiptCommentRequired]
	,I.[strCountCode]
	,I.[ysnLandedCost]
	,I.[strLeadTime]
	,I.[ysnTaxable]
	,I.[strKeywords]
	,I.[dblCaseQty]
	,I.[dtmDateShip]
	,I.[dblTaxExempt]
	,I.[ysnDropShip]
	,I.[ysnCommisionable]
	,I.[ysnSpecialCommission]
	,I.[intCommodityId]
	,I.[intCommodityHierarchyId]
	,I.[dblGAShrinkFactor]
	,I.[intOriginId]
	,I.[intProductTypeId]
	,I.[intRegionId]
	,I.[intSeasonId]
	,I.[intClassVarietyId]
	,I.[intProductLineId]
	,I.[intGradeId]
	,I.[strMarketValuation]
	,I.[ysnInventoryCost]
	,I.[ysnAccrue]
	,I.[ysnMTM]
	,I.[ysnPrice]
	,I.[strCostMethod]
	,I.[strCostType]
	,I.[intOnCostTypeId]
	,I.[dblAmount]
	,I.[intCostUOMId]
	,I.[intPackTypeId]
	,I.[strWeightControlCode]
	,I.[dblBlendWeight]
	,I.[dblNetWeight]
	,I.[dblUnitPerCase]
	,I.[dblQuarantineDuration]
	,I.[intOwnerId]
	,I.[intCustomerId]
	,I.[dblCaseWeight]
	,I.[strWarehouseStatus]
	,I.[ysnKosherCertified]
	,I.[ysnFairTradeCompliant]
	,I.[ysnOrganic]
	,I.[ysnRainForestCertified]
	,I.[dblRiskScore]
	,I.[dblDensity]
	,I.[dtmDateAvailable]
	,I.[ysnMinorIngredient]
	,I.[ysnExternalItem]
	,I.[strExternalGroup]
	,I.[ysnSellableItem]
	,I.[dblMinStockWeeks]
	,I.[dblFullContainerSize]
	,I.[ysnHasMFTImplication]
	,I.[intBuyingGroupId]
	,I.[intAccountManagerId]
	,I.[intConcurrencyId]
	,I.[ysnItemUsedInDiscountCode]
	,I.[ysnUsedForEnergyTracExport]
	,I.[strInvoiceComments]
	,I.[strPickListComments]
	,I.[intLotStatusId]
	,I.[strRequired]
	,I.[ysnBasisContract]
	,I.[intM2MComputationId]
	,I.[intTonnageTaxUOMId]
	,I.[ysn1099Box3]
	,I.[ysnUseWeighScales]
	,I.[ysnLotWeightsRequired]
	,I.[ysnBillable]
	,I.[ysnSupported]
	,I.[ysnDisplayInHelpdesk]
	,I.[intHazmatMessage]
	,I.[strOriginStatus]
	,I.[intCompanyId]
	,I.[dtmDateCreated]
	,I.[dtmDateModified]
	,I.[intCreatedByUserId]
	,I.[intModifiedByUserId]
	,I.[strServiceType]
	,I.[intDataSourceId]
	,M.strManufacturer
	,B.strBrandCode
	,UM.strUnitMeasure AS strDimensionUOM
	,W.strUnitMeasure AS strWeightUOM
	,PC.strCategoryCode AS strPatronageCategoryCode
	,RFC.strRinFuelCategoryCode
	,T.strTagNumber AS strMedicationTag
	,T1.strTagNumber AS strIngredientTag
	,Comm.strCommodityCode
	,C.strCategoryCode
	,CA.strDescription AS strOrigin
	,MP.strUnitMeasure AS strMaterialPackType
	,A.strCustomerNumber AS strOwner
	,A1.strCustomerNumber AS strCustomer
	,M1.strModule
	,BG.strBuyingGroup
	,E.strName AS strAccountManager
	,L.strSecondaryStatus
	,M2MC.strM2MComputation
	,UM1.strUnitMeasure AS strTonnageTaxUOM
	,DS.strSourceName
	,PItem.strItemNo as strPhysicalItemNo
FROM tblICItem I
LEFT JOIN tblICManufacturer M ON M.intManufacturerId = I.intManufacturerId
LEFT JOIN tblICBrand B ON B.intBrandId = I.intBrandId
LEFT JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = I.intDimensionUOMId
LEFT JOIN tblICUnitMeasure W ON W.intUnitMeasureId = I.intWeightUOMId
LEFT JOIN tblPATPatronageCategory PC ON PC.intPatronageCategoryId = I.intPatronageCategoryId
LEFT JOIN tblICRinFuelCategory RFC ON RFC.intRinFuelCategoryId = I.intRINFuelTypeId
LEFT JOIN tblICTag T ON T.intTagId = I.intMedicationTag
LEFT JOIN tblICTag T1 ON T1.intTagId = I.intIngredientTag
LEFT JOIN tblICCommodity Comm ON Comm.intCommodityId = I.intCommodityId
LEFT JOIN tblICCategory C ON C.intCategoryId = I.intCategoryId
LEFT JOIN tblICCommodityAttribute CA ON CA.intCommodityAttributeId = I.intOriginId
LEFT JOIN tblICUnitMeasure MP ON MP.intUnitMeasureId = I.intMaterialPackTypeId
LEFT JOIN tblARCustomer A ON A.intEntityId = I.intOwnerId
LEFT JOIN tblARCustomer A1 ON A1.intEntityId = I.intCustomerId
LEFT JOIN tblSMModule M1 ON M1.intModuleId = I.intModuleId
LEFT JOIN tblMFBuyingGroup BG ON BG.intBuyingGroupId = I.intBuyingGroupId
LEFT JOIN tblEMEntity E ON E.intEntityId = I.intAccountManagerId
LEFT JOIN tblICLotStatus L ON L.intLotStatusId = I.intLotStatusId
LEFT JOIN tblICM2MComputation M2MC ON M2MC.intM2MComputationId = I.intM2MComputationId
LEFT JOIN tblICUnitMeasure UM1 ON UM1.intUnitMeasureId = I.intTonnageTaxUOMId
LEFT JOIN tblICDataSource DS ON DS.intDataSourceId = I.intDataSourceId
Left JOIN tblICItem PItem on PItem.intItemId=I.intPhysicalItem

