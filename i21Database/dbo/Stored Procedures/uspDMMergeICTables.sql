CREATE PROCEDURE [dbo].[uspDMMergeICTables]
    @remoteDB NVARCHAR(MAX)
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON

DECLARE @SQLString NVARCHAR(MAX) = '';

BEGIN

   -- tblICItem
    SET @SQLString = N'
		MERGE tblICItem AS Target
        USING (
			SELECT * FROM REMOTEDBSERVER.[repDB].[dbo].[tblICItem]
		) AS Source
        ON (
			Target.intItemId = Source.intItemId
		)
        WHEN MATCHED THEN
            UPDATE SET 
				Target.strItemNo = Source.strItemNo
				,Target.strShortName = Source.strShortName
				,Target.strType = Source.strType
				,Target.strBundleType = Source.strBundleType
				,Target.strDescription = Source.strDescription
				,Target.intManufacturerId = Source.intManufacturerId
				,Target.intBrandId = Source.intBrandId
				,Target.intCategoryId = Source.intCategoryId
				,Target.strStatus = Source.strStatus
				,Target.strModelNo = Source.strModelNo
				,Target.strInventoryTracking = Source.strInventoryTracking
				,Target.strLotTracking = Source.strLotTracking
				,Target.ysnRequireCustomerApproval = Source.ysnRequireCustomerApproval
				,Target.intRecipeId = Source.intRecipeId
				,Target.ysnSanitationRequired = Source.ysnSanitationRequired
				,Target.intLifeTime = Source.intLifeTime
				,Target.strLifeTimeType = Source.strLifeTimeType
				,Target.intReceiveLife = Source.intReceiveLife
				,Target.strGTIN = Source.strGTIN
				,Target.strRotationType = Source.strRotationType
				,Target.intNMFCId = Source.intNMFCId
				,Target.ysnStrictFIFO = Source.ysnStrictFIFO
				,Target.intDimensionUOMId = Source.intDimensionUOMId
				,Target.dblHeight = Source.dblHeight
				,Target.dblWidth = Source.dblWidth
				,Target.dblDepth = Source.dblDepth
				,Target.intWeightUOMId = Source.intWeightUOMId
				,Target.dblWeight = Source.dblWeight
				,Target.intMaterialPackTypeId = Source.intMaterialPackTypeId
				,Target.strMaterialSizeCode = Source.strMaterialSizeCode
				,Target.intInnerUnits = Source.intInnerUnits
				,Target.intLayerPerPallet = Source.intLayerPerPallet
				,Target.intUnitPerLayer = Source.intUnitPerLayer
				,Target.dblStandardPalletRatio = Source.dblStandardPalletRatio
				,Target.strMask1 = Source.strMask1
				,Target.strMask2 = Source.strMask2
				,Target.strMask3 = Source.strMask3
				,Target.dblMaxWeightPerPack = Source.dblMaxWeightPerPack
				,Target.intPatronageCategoryId = Source.intPatronageCategoryId
				,Target.intPatronageCategoryDirectId = Source.intPatronageCategoryDirectId
				,Target.ysnStockedItem = Source.ysnStockedItem
				,Target.ysnDyedFuel = Source.ysnDyedFuel
				,Target.strBarcodePrint = Source.strBarcodePrint
				,Target.ysnMSDSRequired = Source.ysnMSDSRequired
				,Target.strEPANumber = Source.strEPANumber
				,Target.ysnInboundTax = Source.ysnInboundTax
				,Target.ysnOutboundTax = Source.ysnOutboundTax
				,Target.ysnRestrictedChemical = Source.ysnRestrictedChemical
				,Target.ysnFuelItem = Source.ysnFuelItem
				,Target.ysnTankRequired = Source.ysnTankRequired
				,Target.ysnAvailableTM = Source.ysnAvailableTM
				,Target.dblDefaultFull = Source.dblDefaultFull
				,Target.strFuelInspectFee = Source.strFuelInspectFee
				,Target.strRINRequired = Source.strRINRequired
				,Target.intRINFuelTypeId = Source.intRINFuelTypeId
				,Target.dblDenaturantPercent = Source.dblDenaturantPercent
				,Target.ysnTonnageTax = Source.ysnTonnageTax
				,Target.ysnLoadTracking = Source.ysnLoadTracking
				,Target.dblMixOrder = Source.dblMixOrder
				,Target.ysnHandAddIngredient = Source.ysnHandAddIngredient
				,Target.intMedicationTag = Source.intMedicationTag
				,Target.intIngredientTag = Source.intIngredientTag
				,Target.intHazmatTag = Source.intHazmatTag
				,Target.strVolumeRebateGroup = Source.strVolumeRebateGroup
				,Target.intPhysicalItem = Source.intPhysicalItem
				,Target.ysnExtendPickTicket = Source.ysnExtendPickTicket
				,Target.ysnExportEDI = Source.ysnExportEDI
				,Target.ysnHazardMaterial = Source.ysnHazardMaterial
				,Target.ysnMaterialFee = Source.ysnMaterialFee
				,Target.ysnAutoBlend = Source.ysnAutoBlend
				,Target.dblUserGroupFee = Source.dblUserGroupFee
				,Target.dblWeightTolerance = Source.dblWeightTolerance
				,Target.dblOverReceiveTolerance = Source.dblOverReceiveTolerance
				,Target.strMaintenanceCalculationMethod = Source.strMaintenanceCalculationMethod
				,Target.dblMaintenanceRate = Source.dblMaintenanceRate
				,Target.ysnListBundleSeparately = Source.ysnListBundleSeparately
				,Target.intModuleId = Source.intModuleId
				,Target.strNACSCategory = Source.strNACSCategory
				,Target.strWICCode = Source.strWICCode
				,Target.intAGCategory = Source.intAGCategory
				,Target.ysnReceiptCommentRequired = Source.ysnReceiptCommentRequired
				,Target.strCountCode = Source.strCountCode
				,Target.ysnLandedCost = Source.ysnLandedCost
				,Target.strLeadTime = Source.strLeadTime
				,Target.ysnTaxable = Source.ysnTaxable
				,Target.strKeywords = Source.strKeywords
				,Target.dblCaseQty = Source.dblCaseQty
				,Target.dtmDateShip = Source.dtmDateShip
				,Target.dblTaxExempt = Source.dblTaxExempt
				,Target.ysnDropShip = Source.ysnDropShip
				,Target.ysnCommisionable = Source.ysnCommisionable
				,Target.ysnSpecialCommission = Source.ysnSpecialCommission
				,Target.intCommodityId = Source.intCommodityId
				,Target.intCommodityHierarchyId = Source.intCommodityHierarchyId
				,Target.dblGAShrinkFactor = Source.dblGAShrinkFactor
				,Target.intOriginId = Source.intOriginId
				,Target.intProductTypeId = Source.intProductTypeId
				,Target.intRegionId = Source.intRegionId
				,Target.intSeasonId = Source.intSeasonId
				,Target.intClassVarietyId = Source.intClassVarietyId
				,Target.intProductLineId = Source.intProductLineId
				,Target.intGradeId = Source.intGradeId
				,Target.strMarketValuation = Source.strMarketValuation
				,Target.ysnInventoryCost = Source.ysnInventoryCost
				,Target.ysnAccrue = Source.ysnAccrue
				,Target.ysnMTM = Source.ysnMTM
				,Target.ysnPrice = Source.ysnPrice
				,Target.strCostMethod = Source.strCostMethod
				,Target.strCostType = Source.strCostType
				,Target.intOnCostTypeId = Source.intOnCostTypeId
				,Target.dblAmount = Source.dblAmount
				,Target.intCostUOMId = Source.intCostUOMId
				,Target.intPackTypeId = Source.intPackTypeId
				,Target.strWeightControlCode = Source.strWeightControlCode
				,Target.dblBlendWeight = Source.dblBlendWeight
				,Target.dblNetWeight = Source.dblNetWeight
				,Target.dblUnitPerCase = Source.dblUnitPerCase
				,Target.dblQuarantineDuration = Source.dblQuarantineDuration
				,Target.intOwnerId = Source.intOwnerId
				,Target.intCustomerId = Source.intCustomerId
				,Target.dblCaseWeight = Source.dblCaseWeight
				,Target.strWarehouseStatus = Source.strWarehouseStatus
				,Target.ysnKosherCertified = Source.ysnKosherCertified
				,Target.ysnFairTradeCompliant = Source.ysnFairTradeCompliant
				,Target.ysnOrganic = Source.ysnOrganic
				,Target.ysnRainForestCertified = Source.ysnRainForestCertified
				,Target.dblRiskScore = Source.dblRiskScore
				,Target.dblDensity = Source.dblDensity
				,Target.dtmDateAvailable = Source.dtmDateAvailable
				,Target.ysnMinorIngredient = Source.ysnMinorIngredient
				,Target.ysnExternalItem = Source.ysnExternalItem
				,Target.strExternalGroup = Source.strExternalGroup
				,Target.ysnSellableItem = Source.ysnSellableItem
				,Target.dblMinStockWeeks = Source.dblMinStockWeeks
				,Target.dblFullContainerSize = Source.dblFullContainerSize
				,Target.ysnHasMFTImplication = Source.ysnHasMFTImplication
				,Target.intBuyingGroupId = Source.intBuyingGroupId
				,Target.intAccountManagerId = Source.intAccountManagerId
				,Target.intConcurrencyId = Source.intConcurrencyId
				,Target.ysnItemUsedInDiscountCode = Source.ysnItemUsedInDiscountCode
				,Target.ysnUsedForEnergyTracExport = Source.ysnUsedForEnergyTracExport
				,Target.strInvoiceComments = Source.strInvoiceComments
				,Target.strPickListComments = Source.strPickListComments
				,Target.intLotStatusId = Source.intLotStatusId
				,Target.strRequired = Source.strRequired
				,Target.ysnBasisContract = Source.ysnBasisContract
				,Target.intM2MComputationId = Source.intM2MComputationId
				,Target.intTonnageTaxUOMId = Source.intTonnageTaxUOMId
				,Target.ysnUseWeighScales = Source.ysnUseWeighScales
				,Target.ysnLotWeightsRequired = Source.ysnLotWeightsRequired
				,Target.intHazmatMessage = Source.intHazmatMessage
				,Target.strOriginStatus = Source.strOriginStatus
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;';

    SET @SQLString = 'Exec('' ' + Replace(@SQLString, 'repDB', @remoteDB) + ' '')'
    EXECUTE sp_executesql @SQLString;

    -- tblICCommodity
    SET @SQLString = N'
		MERGE tblICCommodity AS Target
        USING (
			SELECT * FROM REMOTEDBSERVER.[repDB].[dbo].[tblICCommodity]
		) AS Source
        ON (
			Target.intCommodityId = Source.intCommodityId
		)
        WHEN MATCHED THEN
            UPDATE SET 
				Target.strCommodityCode = Source.strCommodityCode
				,Target.strDescription = Source.strDescription
				,Target.ysnExchangeTraded = Source.ysnExchangeTraded
				,Target.intFutureMarketId = Source.intFutureMarketId
				,Target.intDecimalDPR = Source.intDecimalDPR
				,Target.dblConsolidateFactor = Source.dblConsolidateFactor
				,Target.ysnFXExposure = Source.ysnFXExposure
				,Target.dblPriceCheckMin = Source.dblPriceCheckMin
				,Target.dblPriceCheckMax = Source.dblPriceCheckMax
				,Target.strCheckoffTaxDesc = Source.strCheckoffTaxDesc
				,Target.strCheckoffAllState = Source.strCheckoffAllState
				,Target.strInsuranceTaxDesc = Source.strInsuranceTaxDesc
				,Target.strInsuranceAllState = Source.strInsuranceAllState
				,Target.dtmCropEndDateCurrent = Source.dtmCropEndDateCurrent
				,Target.dtmCropEndDateNew = Source.dtmCropEndDateNew
				,Target.strEDICode = Source.strEDICode
				,Target.intScheduleStoreId = Source.intScheduleStoreId
				,Target.intScheduleDiscountId = Source.intScheduleDiscountId
				,Target.intScaleAutoDistId = Source.intScaleAutoDistId
				,Target.ysnAllowLoadContracts = Source.ysnAllowLoadContracts
				,Target.dblMaxUnder = Source.dblMaxUnder
				,Target.dblMaxOver = Source.dblMaxOver
				,Target.intAdjustInventorySales = Source.intAdjustInventorySales
				,Target.intAdjustInventoryTransfer = Source.intAdjustInventoryTransfer
				,Target.intConcurrencyId = Source.intConcurrencyId
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;';

    SET @SQLString = 'Exec('' ' + Replace(@SQLString, 'repDB', @remoteDB) + ' '')'
    EXECUTE sp_executesql @SQLString;

    -- tblICCommodityAccount
    SET @SQLString = N'
		MERGE tblICCommodityAccount AS Target
        USING (
			SELECT * FROM REMOTEDBSERVER.[repDB].[dbo].[tblICCommodityAccount]
		) AS Source
        ON (
			Target.intCommodityAccountId = Source.intCommodityAccountId
		)
        WHEN MATCHED THEN
            UPDATE SET 
				Target.intCommodityId = Source.intCommodityId
				,Target.intAccountCategoryId = Source.intAccountCategoryId
				,Target.intAccountId = Source.intAccountId
				,Target.intSort = Source.intSort
				,Target.intConcurrencyId = Source.intConcurrencyId			
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;';

    SET @SQLString = 'Exec('' ' + Replace(@SQLString, 'repDB', @remoteDB) + ' '')'
    EXECUTE sp_executesql @SQLString;

    -- tblICCommodityAttribute
    SET @SQLString = N'
		MERGE tblICCommodityAttribute AS Target
        USING (
			SELECT * FROM REMOTEDBSERVER.[repDB].[dbo].[tblICCommodityAttribute]
		) AS Source
        ON (
			Target.intCommodityAttributeId = Source.intCommodityAttributeId
		)
        WHEN MATCHED THEN
            UPDATE SET 
				Target.intCommodityId = Source.intCommodityId
				,Target.strType = Source.strType
				,Target.strDescription = Source.strDescription
				,Target.intDefaultPackingUOMId = Source.intDefaultPackingUOMId
				,Target.intCountryID = Source.intCountryID
				,Target.intPurchasingGroupId = Source.intPurchasingGroupId
				,Target.intSort = Source.intSort
				,Target.intConcurrencyId = Source.intConcurrencyId
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;';

    SET @SQLString = 'Exec('' ' + Replace(@SQLString, 'repDB', @remoteDB) + ' '')'
    EXECUTE sp_executesql @SQLString;

    -- tblICCommodityGroup
    SET @SQLString = N'
		MERGE tblICCommodityGroup AS Target
        USING (
			SELECT * FROM REMOTEDBSERVER.[repDB].[dbo].[tblICCommodityGroup]
		) AS Source
        ON (
			Target.intCommodityGroupId = Source.intCommodityGroupId
		)
        WHEN MATCHED THEN
            UPDATE SET 
				Target.intCommodityId = Source.intCommodityId
				,Target.intParentGroupId = Source.intParentGroupId
				,Target.strDescription = Source.strDescription
				,Target.intSort = Source.intSort
				,Target.intConcurrencyId = Source.intConcurrencyId
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;';

    SET @SQLString = 'Exec('' ' + Replace(@SQLString, 'repDB', @remoteDB) + ' '')'
    EXECUTE sp_executesql @SQLString;

    -- tblICCommodityProductLine
    SET @SQLString = N'
		MERGE tblICCommodityProductLine AS Target
        USING (
			SELECT * FROM REMOTEDBSERVER.[repDB].[dbo].[tblICCommodityProductLine]
		) AS Source
        ON (
			Target.intCommodityProductLineId = Source.intCommodityProductLineId
		)
        WHEN MATCHED THEN
            UPDATE SET 
				Target.intCommodityId = Source.intCommodityId
				,Target.strDescription = Source.strDescription
				,Target.ysnDeltaHedge = Source.ysnDeltaHedge
				,Target.dblDeltaPercent = Source.dblDeltaPercent
				,Target.intSort = Source.intSort
				,Target.intConcurrencyId = Source.intConcurrencyId
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;';

    SET @SQLString = 'Exec('' ' + Replace(@SQLString, 'repDB', @remoteDB) + ' '')'
    EXECUTE sp_executesql @SQLString;

    -- tblICCommodityUnitMeasure
    SET @SQLString = N'
		MERGE tblICCommodityUnitMeasure AS Target
        USING (
			SELECT * FROM REMOTEDBSERVER.[repDB].[dbo].[tblICCommodityUnitMeasure]
		) AS Source
        ON (
			Target.intCommodityUnitMeasureId = Source.intCommodityUnitMeasureId
		)
        WHEN MATCHED THEN
            UPDATE SET 
				Target.intCommodityId = Source.intCommodityId
				,Target.intUnitMeasureId = Source.intUnitMeasureId
				,Target.dblUnitQty = Source.dblUnitQty
				,Target.ysnStockUnit = Source.ysnStockUnit
				,Target.ysnDefault = Source.ysnDefault
				,Target.ysnStockUOM = Source.ysnStockUOM
				,Target.intSort = Source.intSort
				,Target.intConcurrencyId = Source.intConcurrencyId
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;';

    SET @SQLString = 'Exec('' ' + Replace(@SQLString, 'repDB', @remoteDB) + ' '')'
    EXECUTE sp_executesql @SQLString;

    -- tblICStorageLocation
    SET @SQLString = N'
		MERGE tblICStorageLocation AS Target
        USING (
			SELECT * FROM REMOTEDBSERVER.[repDB].[dbo].[tblICStorageLocation]
		) AS Source
        ON (
			Target.intStorageLocationId = Source.intStorageLocationId
		)
        WHEN MATCHED THEN
            UPDATE SET 
				Target.strName = Source.strName
				,Target.strDescription = Source.strDescription
				,Target.intStorageUnitTypeId = Source.intStorageUnitTypeId
				,Target.intLocationId = Source.intLocationId
				,Target.intSubLocationId = Source.intSubLocationId
				,Target.intParentStorageLocationId = Source.intParentStorageLocationId
				,Target.ysnAllowConsume = Source.ysnAllowConsume
				,Target.ysnAllowMultipleItem = Source.ysnAllowMultipleItem
				,Target.ysnAllowMultipleLot = Source.ysnAllowMultipleLot
				,Target.ysnMergeOnMove = Source.ysnMergeOnMove
				,Target.ysnCycleCounted = Source.ysnCycleCounted
				,Target.ysnDefaultWHStagingUnit = Source.ysnDefaultWHStagingUnit
				,Target.intRestrictionId = Source.intRestrictionId
				,Target.strUnitGroup = Source.strUnitGroup
				,Target.dblMinBatchSize = Source.dblMinBatchSize
				,Target.dblBatchSize = Source.dblBatchSize
				,Target.intBatchSizeUOMId = Source.intBatchSizeUOMId
				,Target.intSequence = Source.intSequence
				,Target.ysnActive = Source.ysnActive
				,Target.intRelativeX = Source.intRelativeX
				,Target.intRelativeY = Source.intRelativeY
				,Target.intRelativeZ = Source.intRelativeZ
				,Target.intCommodityId = Source.intCommodityId
				,Target.intItemId = Source.intItemId
				,Target.dblPackFactor = Source.dblPackFactor
				,Target.dblEffectiveDepth = Source.dblEffectiveDepth
				,Target.dblUnitPerFoot = Source.dblUnitPerFoot
				,Target.dblResidualUnit = Source.dblResidualUnit
				,Target.intConcurrencyId = Source.intConcurrencyId
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;';

    SET @SQLString = 'Exec('' ' + Replace(@SQLString, 'repDB', @remoteDB) + ' '')'
    EXECUTE sp_executesql @SQLString;

    -- tblICStorageLocationCategory
    SET @SQLString = N'
		MERGE tblICStorageLocationCategory AS Target
        USING (
			SELECT * FROM REMOTEDBSERVER.[repDB].[dbo].[tblICStorageLocationCategory]
		) AS Source
        ON (
			Target.intStorageLocationCategoryId = Source.intStorageLocationCategoryId
		)
        WHEN MATCHED THEN
            UPDATE SET 
				Target.intStorageLocationId = Source.intStorageLocationId
				,Target.intCategoryId = Source.intCategoryId
				,Target.intSort = Source.intSort
				,Target.intConcurrencyId = Source.intConcurrencyId				
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;';

    SET @SQLString = 'Exec('' ' + Replace(@SQLString, 'repDB', @remoteDB) + ' '')'
    EXECUTE sp_executesql @SQLString;

    -- tblICStorageLocationContainer
    SET @SQLString = N'
		MERGE tblICStorageLocationContainer AS Target
        USING (
			SELECT * FROM REMOTEDBSERVER.[repDB].[dbo].[tblICStorageLocationContainer]
		) AS Source
        ON (
			Target.intStorageLocationContainerId = Source.intStorageLocationContainerId
		)
        WHEN MATCHED THEN
            UPDATE SET 
				Target.intStorageLocationId = Source.intStorageLocationId
				,Target.intContainerId = Source.intContainerId
				,Target.intExternalSystemId = Source.intExternalSystemId
				,Target.intContainerTypeId = Source.intContainerTypeId
				,Target.strLastUpdatedBy = Source.strLastUpdatedBy
				,Target.dtmLastUpdatedOn = Source.dtmLastUpdatedOn
				,Target.intSort = Source.intSort
				,Target.intConcurrencyId = Source.intConcurrencyId
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;';

    SET @SQLString = 'Exec('' ' + Replace(@SQLString, 'repDB', @remoteDB) + ' '')'
    EXECUTE sp_executesql @SQLString;

    -- tblICStorageLocationMeasurement
    SET @SQLString = N'
		MERGE tblICStorageLocationMeasurement AS Target
        USING (
			SELECT * FROM REMOTEDBSERVER.[repDB].[dbo].[tblICStorageLocationMeasurement]
		) AS Source
        ON (
			Target.intStorageLocationMeasurementId = Source.intStorageLocationMeasurementId
		)
        WHEN MATCHED THEN
            UPDATE SET 
				Target.intStorageLocationId = Source.intStorageLocationId
				,Target.intMeasurementId = Source.intMeasurementId
				,Target.intReadingPointId = Source.intReadingPointId
				,Target.ysnActive = Source.ysnActive
				,Target.intSort = Source.intSort
				,Target.intConcurrencyId = Source.intConcurrencyId				
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;';

    SET @SQLString = 'Exec('' ' + Replace(@SQLString, 'repDB', @remoteDB) + ' '')'
    EXECUTE sp_executesql @SQLString;

    -- tblICStorageLocationSku
    SET @SQLString = N'
		MERGE tblICStorageLocationSku AS Target
        USING (
			SELECT * FROM REMOTEDBSERVER.[repDB].[dbo].[tblICStorageLocationSku]
		) AS Source
        ON (
			Target.intStorageLocationSkuId = Source.intStorageLocationSkuId
		)
        WHEN MATCHED THEN
            UPDATE SET 
				Target.intStorageLocationId = Source.intStorageLocationId
				,Target.intItemId = Source.intItemId
				,Target.intSkuId = Source.intSkuId
				,Target.dblQuantity = Source.dblQuantity
				,Target.intContainerId = Source.intContainerId
				,Target.intLotCodeId = Source.intLotCodeId
				,Target.intLotStatusId = Source.intLotStatusId
				,Target.intOwnerId = Source.intOwnerId
				,Target.intSort = Source.intSort
				,Target.intConcurrencyId = Source.intConcurrencyId
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;';

    SET @SQLString = 'Exec('' ' + Replace(@SQLString, 'repDB', @remoteDB) + ' '')'
    EXECUTE sp_executesql @SQLString;

END