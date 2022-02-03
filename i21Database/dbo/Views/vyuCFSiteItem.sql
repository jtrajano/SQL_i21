﻿CREATE VIEW dbo.vyuCFSiteItem
AS
SELECT   icfSite.intSiteId, icfSite.intNetworkId, icfSite.strSiteNumber, icfSite.intARLocationId, icfSite.intCardId, icfSite.strTaxState, icfSite.strAuthorityId1, icfSite.strAuthorityId2, 
                         icfSite.ysnFederalExciseTax, icfSite.ysnStateExciseTax, icfSite.ysnStateSalesTax, icfSite.ysnLocalTax1, icfSite.ysnLocalTax2, icfSite.ysnLocalTax3, icfSite.ysnLocalTax4, 
                         icfSite.ysnLocalTax5, icfSite.ysnLocalTax6, icfSite.ysnLocalTax7, icfSite.ysnLocalTax8, icfSite.ysnLocalTax9, icfSite.ysnLocalTax10, icfSite.ysnLocalTax11, 
                         icfSite.ysnLocalTax12, icfSite.intNumberOfLinesPerTransaction, icfSite.intIgnoreCardID, icfSite.strImportFileName, icfSite.strImportPath, icfSite.intNumberOfDecimalInPrice, 
                         icfSite.intNumberOfDecimalInQuantity, icfSite.intNumberOfDecimalInTotal, icfSite.strImportType, icfSite.strControllerType, icfSite.ysnPumpCalculatesTaxes, 
                         icfSite.ysnSiteAcceptsMajorCreditCards, icfSite.ysnCenexSite, icfSite.ysnUseControllerCard, icfSite.intCashCustomerID, icfSite.ysnProcessCashSales, 
                         icfSite.ysnAssignBatchByDate, icfSite.ysnMultipleSiteImport, icfSite.strSiteName, icfSite.strDeliveryPickup, icfSite.strSiteAddress, icfSite.strSiteCity, icfSite.intPPHostId, 
                         icfSite.strPPSiteType, icfSite.ysnPPLocalPrice, icfSite.intPPLocalHostId, icfSite.strPPLocalSiteType, icfSite.intPPLocalSiteId, icfSite.intRebateSiteGroupId, 
                         icfSite.intAdjustmentSiteGroupId, icfSite.dtmLastTransactionDate, icfSite.ysnEEEStockItemDetail, icfSite.ysnRecalculateTaxesOnRemote, icfSite.strSiteType, 
                         icfSite.intCreatedUserId, icfSite.dtmCreated, icfSite.intLastModifiedUserId, icfSite.dtmLastModified, icfSite.intConcurrencyId, icfSite.intImportMapperId, icfItem.intItemId, 
                         icfSite.intTaxGroupId, icfItem.intNetworkId AS EXPR1, icfItem.intSiteId AS EXPR2, icfItem.strProductNumber, icfItem.intARItemId, icfItem.strProductDescription, 
                         icfItem.dblOPISAverageCost1, icfItem.dtmOPISEffectiveDate1, icfItem.dblOPISAverageCost2, icfItem.dtmOPISEffectiveDate2, icfItem.dblOPISAverageCost3, 
                         icfItem.dtmOPISEffectiveDate3, icfItem.dblSellingPrice, icfItem.dblPumpPrice, icfItem.ysnCarryNegligibleBalance, icfItem.ysnIncludeInQuantityDiscount, 
                         icfItem.strDepartmentType, icfItem.ysnOverrideLocationSalesTax, icfItem.dblRemoteFeePerTransaction, icfItem.dblExtRemoteFeePerTransaction, 
                         icfItem.ysnMPGCalculation, icfItem.ysnChargeOregonP, icfItem.ysnIncludeInQuantityDiscount AS EXPR18, icfItem.intCreatedUserId AS EXPR3, 
                         icfItem.dtmCreated AS EXPR4, icfItem.intLastModifiedUserId AS EXPR5, icfItem.dtmLastModified AS EXPR6, icfItem.intConcurrencyId AS EXPR7, iicItem.intItemId AS EXPR8, 
                         iicItem.strItemNo, iicItem.strShortName, iicItem.strType, iicItem.strDescription, iicItem.intManufacturerId, iicItem.intBrandId, iicItem.intCategoryId, iicItem.strStatus, 
                         iicItem.strModelNo, iicItem.strInventoryTracking, iicItem.strLotTracking, iicItem.ysnRequireCustomerApproval, iicItem.intRecipeId, iicItem.ysnSanitationRequired, 
                         iicItem.intLifeTime, iicItem.strLifeTimeType, iicItem.intReceiveLife, iicItem.strGTIN, iicItem.strRotationType, iicItem.intNMFCId, iicItem.ysnStrictFIFO, 
                         iicItem.intDimensionUOMId, iicItem.dblHeight, iicItem.dblWidth, iicItem.dblDepth, iicItem.intWeightUOMId, iicItem.dblWeight, iicItem.intMaterialPackTypeId, 
                         iicItem.strMaterialSizeCode, iicItem.intInnerUnits, iicItem.intLayerPerPallet, iicItem.intUnitPerLayer, iicItem.dblStandardPalletRatio, iicItem.strMask1, iicItem.strMask2, 
                         iicItem.strMask3, iicItem.intPatronageCategoryId, iicItem.intPatronageCategoryDirectId, iicItem.ysnStockedItem, iicItem.ysnDyedFuel, iicItem.strBarcodePrint, 
                         iicItem.ysnMSDSRequired, iicItem.strEPANumber, iicItem.ysnInboundTax, iicItem.ysnOutboundTax, iicItem.ysnRestrictedChemical, iicItem.ysnFuelItem, 
                         iicItem.ysnTankRequired, iicItem.ysnAvailableTM, iicItem.dblDefaultFull, iicItem.strFuelInspectFee, iicItem.strRINRequired, iicItem.intRINFuelTypeId, 
                         iicItem.dblDenaturantPercent, iicItem.ysnTonnageTax, iicItem.ysnLoadTracking, iicItem.dblMixOrder, iicItem.ysnHandAddIngredient, iicItem.intMedicationTag, 
                         iicItem.intIngredientTag, iicItem.strVolumeRebateGroup, iicItem.intPhysicalItem, iicItem.ysnExtendPickTicket, iicItem.ysnExportEDI, iicItem.ysnHazardMaterial, 
                         iicItem.ysnMaterialFee, iicItem.ysnAutoBlend, iicItem.dblUserGroupFee, iicItem.dblWeightTolerance, iicItem.dblOverReceiveTolerance, 
                         iicItem.strMaintenanceCalculationMethod, iicItem.dblMaintenanceRate, iicItem.ysnListBundleSeparately, iicItem.intModuleId, iicItem.strNACSCategory, iicItem.strWICCode, 
                         iicItem.intAGCategory, iicItem.ysnReceiptCommentRequired, iicItem.strCountCode, iicItem.ysnLandedCost, iicItem.strLeadTime, iicItem.ysnTaxable, iicItem.strKeywords, 
                         iicItem.dblCaseQty, iicItem.dtmDateShip, iicItem.dblTaxExempt, iicItem.ysnDropShip, iicItem.ysnCommisionable, iicItem.ysnSpecialCommission, iicItem.intCommodityId, 
                         iicItem.intCommodityHierarchyId, iicItem.dblGAShrinkFactor, iicItem.intOriginId, iicItem.intProductTypeId, iicItem.intRegionId, iicItem.intSeasonId, iicItem.intClassVarietyId, 
                         iicItem.intProductLineId, iicItem.intGradeId, iicItem.strMarketValuation, iicItem.ysnInventoryCost, iicItem.ysnAccrue, iicItem.ysnMTM, iicItem.ysnPrice, iicItem.strCostMethod, 
                         iicItem.strCostType, iicItem.intOnCostTypeId, iicItem.dblAmount, iicItem.intCostUOMId, iicItem.intPackTypeId, iicItem.strWeightControlCode, iicItem.dblBlendWeight, 
                         iicItem.dblNetWeight, iicItem.dblUnitPerCase, iicItem.dblQuarantineDuration, iicItem.intOwnerId, iicItem.intCustomerId, iicItem.dblCaseWeight, iicItem.strWarehouseStatus, 
                         iicItem.ysnKosherCertified, iicItem.ysnFairTradeCompliant, iicItem.ysnOrganic, iicItem.ysnRainForestCertified, iicItem.dblRiskScore, iicItem.dblDensity, 
                         iicItem.dtmDateAvailable, iicItem.ysnMinorIngredient, iicItem.ysnExternalItem, iicItem.strExternalGroup, iicItem.ysnSellableItem, iicItem.dblMinStockWeeks, 
                         iicItem.dblFullContainerSize, iicItem.ysnHasMFTImplication, iicItem.intConcurrencyId AS EXPR9, iicItemLoc.intItemLocationId, iicItemLoc.intItemId AS EXPR10, 
                         iicItemLoc.intLocationId, iicItemLoc.intVendorId, iicItemLoc.strDescription AS EXPR11, iicItemLoc.intCostingMethod, iicItemLoc.intAllowNegativeInventory, 
                         iicItemLoc.intSubLocationId, iicItemLoc.intStorageLocationId, iicItemLoc.intIssueUOMId, iicItemLoc.intReceiveUOMId, iicItemLoc.intFamilyId, iicItemLoc.intClassId, 
                         iicItemLoc.intProductCodeId, iicItemLoc.intFuelTankId, iicItemLoc.strPassportFuelId1, iicItemLoc.strPassportFuelId2, iicItemLoc.strPassportFuelId3, iicItemLoc.ysnTaxFlag1, 
                         iicItemLoc.ysnTaxFlag2, iicItemLoc.ysnTaxFlag3, iicItemLoc.ysnTaxFlag4, iicItemLoc.ysnPromotionalItem, iicItemLoc.intMixMatchId, iicItemLoc.ysnDepositRequired, 
                         iicItemLoc.intDepositPLUId, iicItemLoc.intBottleDepositNo, iicItemLoc.ysnSaleable, iicItemLoc.ysnQuantityRequired, iicItemLoc.ysnScaleItem, iicItemLoc.ysnFoodStampable, 
                         iicItemLoc.ysnReturnable, iicItemLoc.ysnPrePriced, iicItemLoc.ysnOpenPricePLU, iicItemLoc.ysnLinkedItem, iicItemLoc.strVendorCategory, iicItemLoc.ysnCountBySINo, 
                         iicItemLoc.strSerialNoBegin, iicItemLoc.strSerialNoEnd, iicItemLoc.ysnIdRequiredLiquor, iicItemLoc.ysnIdRequiredCigarette, iicItemLoc.intMinimumAge, 
                         iicItemLoc.ysnApplyBlueLaw1, iicItemLoc.ysnApplyBlueLaw2, iicItemLoc.ysnCarWash, iicItemLoc.intItemTypeCode, iicItemLoc.intItemTypeSubCode, 
                         iicItemLoc.ysnAutoCalculateFreight, iicItemLoc.intFreightMethodId, iicItemLoc.dblFreightRate, iicItemLoc.intShipViaId, iicItemLoc.intNegativeInventory, 
                         iicItemLoc.dblReorderPoint, iicItemLoc.dblMinOrder, iicItemLoc.dblSuggestedQty, iicItemLoc.dblLeadTime, iicItemLoc.strCounted, iicItemLoc.intCountGroupId, 
                         iicItemLoc.ysnCountedDaily, iicItemLoc.ysnLockedInventory, iicItemLoc.intSort, iicItemLoc.intConcurrencyId AS EXPR12, iicItemPricing.intPricingKey, iicItemPricing.intKey, 
                         iicItemPricing.strDescription AS EXPR13, iicItemPricing.strUpcCode, iicItemPricing.intItemPricingId, iicItemPricing.intItemId AS EXPR14, 
                         iicItemPricing.intLocationId AS EXPR15, iicItemPricing.intItemLocationId AS EXPR16, iicItemPricing.strLocationName, iicItemPricing.strLocationType, 
                         iicItemPricing.intItemUnitMeasureId, iicItemPricing.intUnitMeasureId, iicItemPricing.strUnitMeasure, iicItemPricing.strUnitType, iicItemPricing.ysnStockUnit, 
                         iicItemPricing.ysnAllowPurchase, iicItemPricing.ysnAllowSale, iicItemPricing.dblUnitQty, iicItemPricing.dblAmountPercent, iicItemPricing.dblSalePrice, 
                         iicItemPricing.dblMSRPPrice, iicItemPricing.strPricingMethod, iicItemPricing.dblLastCost, iicItemPricing.dblStandardCost, iicItemPricing.dblAverageCost, 
                         iicItemPricing.dblEndMonthCost, iicItemPricing.intSort AS EXPR17
FROM         dbo.tblCFSite AS icfSite INNER JOIN
                         dbo.tblCFItem AS icfItem ON icfSite.intSiteId = icfItem.intSiteId INNER JOIN
                         dbo.tblICItem AS iicItem ON icfItem.intARItemId = iicItem.intItemId INNER JOIN
                         dbo.tblICItemLocation AS iicItemLoc ON iicItemLoc.intLocationId = icfSite.intARLocationId AND iicItemLoc.intItemId = icfItem.intARItemId INNER JOIN
                         dbo.vyuICGetItemPricing AS iicItemPricing ON iicItemPricing.intItemId = icfItem.intARItemId AND iicItemPricing.intLocationId = iicItemLoc.intLocationId AND 
                         iicItemPricing.intItemLocationId = iicItemLoc.intItemLocationId
