CREATE PROCEDURE [dbo].[uspICDuplicateItem]
	@ItemId INT,
	@NewItemId INT OUTPUT
AS
BEGIN

	--------------------------
	-- Generate New Item No --
	--------------------------
	DECLARE @ItemNo NVARCHAR(50),
		@NewItemNo NVARCHAR(50),
		@NewItemNoWithCounter NVARCHAR(50),
		@counter INT
	SELECT @ItemNo = strItemNo, @NewItemNo = strItemNo + '-copy' FROM tblICItem WHERE intItemId = @ItemId
	IF EXISTS(SELECT TOP 1 1 FROM tblICItem WHERE strItemNo = @NewItemNo)
	BEGIN
		SET @counter = 1
		SET @NewItemNoWithCounter = @NewItemNo + (CAST(@counter AS NVARCHAR(50)))
		WHILE EXISTS(SELECT TOP 1 1 FROM tblICItem WHERE strItemNo = @NewItemNoWithCounter)
		BEGIN
			SET @counter += 1
			SET @NewItemNoWithCounter = @NewItemNo + (CAST(@counter AS NVARCHAR(50)))
		END
		SET @NewItemNo = @NewItemNoWithCounter
	END
	-- PRINT @NewItemNo
	-----------------------------------
	-- End Generation of New Item No --
	-----------------------------------

	---------------------------------
	-- Duplicate Item Header table --
	---------------------------------
	INSERT INTO tblICItem(strItemNo,
		strType,
		strDescription,
		intManufacturerId,
		intBrandId,
		intCategoryId,
		strStatus,
		strModelNo,
		strInventoryTracking,
		strLotTracking,
		ysnRequireCustomerApproval,
		intRecipeId,
		ysnSanitationRequired,
		intLifeTime,
		strLifeTimeType,
		intReceiveLife,
		strGTIN,
		strRotationType,
		intNMFCId,
		ysnStrictFIFO,
		intDimensionUOMId,
		dblHeight,
		dblWidth,
		dblDepth,
		intWeightUOMId,
		dblWeight,
		intMaterialPackTypeId,
		strMaterialSizeCode,
		intInnerUnits,
		intLayerPerPallet,
		intUnitPerLayer,
		dblStandardPalletRatio,
		strMask1,
		strMask2,
		strMask3,
		intPatronageCategoryId,
		intFuelTaxClassId,
		intSalesTaxGroupId,
		intPurchaseTaxGroupId,
		ysnStockedItem,
		ysnDyedFuel,
		strBarcodePrint,
		ysnMSDSRequired,
		strEPANumber,
		ysnInboundTax,
		ysnOutboundTax,
		ysnRestrictedChemical,
		ysnFuelItem,
		ysnTankRequired,
		ysnAvailableTM,
		dblDefaultFull,
		strFuelInspectFee,
		strRINRequired,
		intRINFuelTypeId,
		dblDenaturantPercent,
		ysnTonnageTax,
		ysnLoadTracking,
		dblMixOrder,
		ysnHandAddIngredient,
		intMedicationTag,
		intIngredientTag,
		strVolumeRebateGroup,
		intPhysicalItem,
		ysnExtendPickTicket,
		ysnExportEDI,
		ysnHazardMaterial,
		ysnMaterialFee,
		ysnAutoBlend,
		dblUserGroupFee,
		dblWeightTolerance,
		dblOverReceiveTolerance,
		strMaintenanceCalculationMethod,
		dblMaintenanceRate,
		strNACSCategory,
		strWICCode,
		intAGCategory,
		ysnReceiptCommentRequired,
		strCountCode,
		ysnLandedCost,
		strLeadTime,
		ysnTaxable,
		strKeywords,
		dblCaseQty,
		dtmDateShip,
		dblTaxExempt,
		ysnDropShip,
		ysnCommisionable,
		ysnSpecialCommission,
		intCommodityId,
		intCommodityHierarchyId,
		dblGAShrinkFactor,
		intOriginId,
		intProductTypeId,
		intRegionId,
		intSeasonId,
		intClassVarietyId,
		intProductLineId,
		strMarketValuation,
		ysnInventoryCost,
		ysnAccrue,
		ysnMTM,
		ysnPrice,
		strCostMethod,
		intOnCostTypeId,
		dblAmount,
		intCostUOMId)
	SELECT @NewItemNo,
		strType,
		strDescription,
		intManufacturerId,
		intBrandId,
		intCategoryId,
		strStatus,
		strModelNo,
		strInventoryTracking,
		strLotTracking,
		ysnRequireCustomerApproval,
		intRecipeId,
		ysnSanitationRequired,
		intLifeTime,
		strLifeTimeType,
		intReceiveLife,
		strGTIN,
		strRotationType,
		intNMFCId,
		ysnStrictFIFO,
		intDimensionUOMId,
		dblHeight,
		dblWidth,
		dblDepth,
		intWeightUOMId,
		dblWeight,
		intMaterialPackTypeId,
		strMaterialSizeCode,
		intInnerUnits,
		intLayerPerPallet,
		intUnitPerLayer,
		dblStandardPalletRatio,
		strMask1,
		strMask2,
		strMask3,
		intPatronageCategoryId,
		intFuelTaxClassId,
		intSalesTaxGroupId,
		intPurchaseTaxGroupId,
		ysnStockedItem,
		ysnDyedFuel,
		strBarcodePrint,
		ysnMSDSRequired,
		strEPANumber,
		ysnInboundTax,
		ysnOutboundTax,
		ysnRestrictedChemical,
		ysnFuelItem,
		ysnTankRequired,
		ysnAvailableTM,
		dblDefaultFull,
		strFuelInspectFee,
		strRINRequired,
		intRINFuelTypeId,
		dblDenaturantPercent,
		ysnTonnageTax,
		ysnLoadTracking,
		dblMixOrder,
		ysnHandAddIngredient,
		intMedicationTag,
		intIngredientTag,
		strVolumeRebateGroup,
		intPhysicalItem,
		ysnExtendPickTicket,
		ysnExportEDI,
		ysnHazardMaterial,
		ysnMaterialFee,
		ysnAutoBlend,
		dblUserGroupFee,
		dblWeightTolerance,
		dblOverReceiveTolerance,
		strMaintenanceCalculationMethod,
		dblMaintenanceRate,
		strNACSCategory,
		strWICCode,
		intAGCategory,
		ysnReceiptCommentRequired,
		strCountCode,
		ysnLandedCost,
		strLeadTime,
		ysnTaxable,
		strKeywords,
		dblCaseQty,
		dtmDateShip,
		dblTaxExempt,
		ysnDropShip,
		ysnCommisionable,
		ysnSpecialCommission,
		intCommodityId,
		intCommodityHierarchyId,
		dblGAShrinkFactor,
		intOriginId,
		intProductTypeId,
		intRegionId,
		intSeasonId,
		intClassVarietyId,
		intProductLineId,
		strMarketValuation,
		ysnInventoryCost,
		ysnAccrue,
		ysnMTM,
		ysnPrice,
		strCostMethod,
		intOnCostTypeId,
		dblAmount,
		intCostUOMId
	FROM tblICItem
	WHERE intItemId = @ItemId
	------------------------------------------
	-- End duplication of Item Header table --
	------------------------------------------

	SET @NewItemId = SCOPE_IDENTITY()
	
	------------------------------
	-- Duplicate Item UOM table --
	------------------------------
	INSERT INTO tblICItemUOM(intItemId,
		intUnitMeasureId,
		dblUnitQty,
		dblWeight,
		intWeightUOMId,
		strUpcCode,
		ysnStockUnit,
		ysnAllowPurchase,
		ysnAllowSale,
		dblLength,
		dblWidth,
		dblHeight,
		intDimensionUOMId,
		dblVolume,
		intVolumeUOMId,
		dblMaxQty,
		intSort)
	SELECT @NewItemId,
		intUnitMeasureId,
		dblUnitQty,
		dblWeight,
		intWeightUOMId,
		strUpcCode,
		ysnStockUnit,
		ysnAllowPurchase,
		ysnAllowSale,
		dblLength,
		dblWidth,
		dblHeight,
		intDimensionUOMId,
		dblVolume,
		intVolumeUOMId,
		dblMaxQty,
		intSort
	FROM tblICItemUOM
	WHERE intItemId = @ItemId
	---------------------------------------
	-- End duplication of Item UOM table --
	---------------------------------------

	----------------------------------
	-- Duplicate Item Account table --
	----------------------------------
	INSERT INTO tblICItemAccount(intItemId,
		intAccountCategoryId,
		intAccountId,
		intSort)
	SELECT @NewItemId,
		intAccountCategoryId,
		intAccountId,
		intSort
	FROM tblICItemAccount
	WHERE intItemId = @ItemId
	-------------------------------------------
	-- End duplication of Item Account table --
	-------------------------------------------

	-----------------------------------
	-- Duplicate Item Location table --
	-----------------------------------
	INSERT INTO tblICItemLocation(intItemId,
		intLocationId,
		intVendorId,
		strDescription,
		intCostingMethod,
		intAllowNegativeInventory,
		intSubLocationId,
		intStorageLocationId,
		intIssueUOMId,
		intReceiveUOMId,
		intFamilyId,
		intClassId,
		intProductCodeId,
		intFuelTankId,
		strPassportFuelId1,
		strPassportFuelId2,
		strPassportFuelId3,
		ysnTaxFlag1,
		ysnTaxFlag2,
		ysnTaxFlag3,
		ysnTaxFlag4,
		ysnPromotionalItem,
		intMixMatchId,
		ysnDepositRequired,
		intDepositPLUId,
		intBottleDepositNo,
		ysnSaleable,
		ysnQuantityRequired,
		ysnScaleItem,
		ysnFoodStampable,
		ysnReturnable,
		ysnPrePriced,
		ysnOpenPricePLU,
		ysnLinkedItem,
		strVendorCategory,
		ysnCountBySINo,
		strSerialNoBegin,
		strSerialNoEnd,
		ysnIdRequiredLiquor,
		ysnIdRequiredCigarette,
		intMinimumAge,
		ysnApplyBlueLaw1,
		ysnApplyBlueLaw2,
		ysnCarWash,
		intItemTypeCode,
		intItemTypeSubCode,
		ysnAutoCalculateFreight,
		intFreightMethodId,
		dblFreightRate,
		intShipViaId,
		intNegativeInventory,
		dblReorderPoint,
		dblMinOrder,
		dblSuggestedQty,
		dblLeadTime,
		strCounted,
		intCountGroupId,
		ysnCountedDaily,
		intSort)
	SELECT @NewItemId,
		intLocationId,
		intVendorId,
		strDescription,
		intCostingMethod,
		intAllowNegativeInventory,
		intSubLocationId,
		intStorageLocationId,
		dbo.fnICGetItemUOMIdFromDuplicateItem(intIssueUOMId, @NewItemId),
		dbo.fnICGetItemUOMIdFromDuplicateItem(intReceiveUOMId, @NewItemId),
		intFamilyId,
		intClassId,
		intProductCodeId,
		intFuelTankId,
		strPassportFuelId1,
		strPassportFuelId2,
		strPassportFuelId3,
		ysnTaxFlag1,
		ysnTaxFlag2,
		ysnTaxFlag3,
		ysnTaxFlag4,
		ysnPromotionalItem,
		intMixMatchId,
		ysnDepositRequired,
		intDepositPLUId,
		intBottleDepositNo,
		ysnSaleable,
		ysnQuantityRequired,
		ysnScaleItem,
		ysnFoodStampable,
		ysnReturnable,
		ysnPrePriced,
		ysnOpenPricePLU,
		ysnLinkedItem,
		strVendorCategory,
		ysnCountBySINo,
		strSerialNoBegin,
		strSerialNoEnd,
		ysnIdRequiredLiquor,
		ysnIdRequiredCigarette,
		intMinimumAge,
		ysnApplyBlueLaw1,
		ysnApplyBlueLaw2,
		ysnCarWash,
		intItemTypeCode,
		intItemTypeSubCode,
		ysnAutoCalculateFreight,
		intFreightMethodId,
		dblFreightRate,
		intShipViaId,
		intNegativeInventory,
		dblReorderPoint,
		dblMinOrder,
		dblSuggestedQty,
		dblLeadTime,
		strCounted,
		intCountGroupId,
		ysnCountedDaily,
		intSort
	FROM tblICItemLocation
	WHERE intItemId = @ItemId
	--------------------------------------------
	-- End duplication of Item Location table --
	--------------------------------------------

	----------------------------------
	-- Duplicate Item Pricing table --
	----------------------------------
	INSERT INTO tblICItemPricing(intItemId,
		intItemLocationId,
		dblAmountPercent,
		dblSalePrice,
		dblMSRPPrice,
		strPricingMethod,
		dblLastCost,
		dblStandardCost,
		dblAverageCost,
		dblEndMonthCost,
		intSort)
	SELECT @NewItemId,
		dbo.fnICGetItemLocationIdFromDuplicateItem(intItemLocationId, @NewItemId),
		dblAmountPercent,
		dblSalePrice,
		dblMSRPPrice,
		strPricingMethod,
		dblLastCost,
		dblStandardCost,
		dblAverageCost,
		dblEndMonthCost,
		intSort 
	FROM tblICItemPricing
	WHERE intItemId = @ItemId
	-------------------------------------------
	-- End duplication of Item Pricing table --
	-------------------------------------------

	----------------------------------------
	-- Duplicate Item Pricing Level table --
	----------------------------------------
	INSERT INTO tblICItemPricingLevel(intItemId,
		intItemLocationId,
		strPriceLevel,
		intItemUnitMeasureId,
		dblUnit,
		dblMin,
		dblMax,
		strPricingMethod,
		dblAmountRate,
		dblUnitPrice,
		strCommissionOn,
		dblCommissionRate,
		intSort )
	SELECT @NewItemId,
		dbo.fnICGetItemLocationIdFromDuplicateItem(intItemLocationId, @NewItemId),
		strPriceLevel,
		dbo.fnICGetItemUOMIdFromDuplicateItem(intItemUnitMeasureId, @NewItemId),
		dblUnit,
		dblMin,
		dblMax,
		strPricingMethod,
		dblAmountRate,
		dblUnitPrice,
		strCommissionOn,
		dblCommissionRate,
		intSort 
	FROM tblICItemPricingLevel
	WHERE intItemId = @ItemId
	-------------------------------------------------
	-- End duplication of Item Pricing Level table --
	-------------------------------------------------

	------------------------------------------
	-- Duplicate Item Special Pricing table --
	------------------------------------------
	INSERT INTO tblICItemSpecialPricing(intItemId,
		intItemLocationId,
		strPromotionType,
		dtmBeginDate,
		dtmEndDate,
		intItemUnitMeasureId,
		dblUnit,
		strDiscountBy,
		dblDiscount,
		dblUnitAfterDiscount,
		dblDiscountThruQty,
		dblDiscountThruAmount,
		dblAccumulatedQty,
		dblAccumulatedAmount,
		intSort )
	SELECT @NewItemId,
		dbo.fnICGetItemLocationIdFromDuplicateItem(intItemLocationId, @NewItemId),
		strPromotionType,
		dtmBeginDate,
		dtmEndDate,
		dbo.fnICGetItemUOMIdFromDuplicateItem(intItemUnitMeasureId, @NewItemId),
		dblUnit,
		strDiscountBy,
		dblDiscount,
		dblUnitAfterDiscount,
		dblDiscountThruQty,
		dblDiscountThruAmount,
		dblAccumulatedQty,
		dblAccumulatedAmount,
		intSort 
	FROM tblICItemSpecialPricing
	WHERE intItemId = @ItemId
	---------------------------------------------------
	-- End duplication of Item Special Pricing table --
	---------------------------------------------------
	
	---------------------------------
	-- Duplicate Item Bundle table --
	---------------------------------
	INSERT INTO tblICItemBundle(intItemId,
		intBundleItemId,
		strDescription,
		dblQuantity,
		intItemUnitMeasureId,
		dblUnit,
		dblPrice,
		intSort )
	SELECT @NewItemId,
		intBundleItemId,
		strDescription,
		dblQuantity,
		dbo.fnICGetItemUOMIdFromDuplicateItem(intItemUnitMeasureId, @NewItemId),
		dblUnit,
		dblPrice,
		intSort 
	FROM tblICItemBundle
	WHERE intItemId = @ItemId
	------------------------------------------
	-- End duplication of Item Bundle table --
	------------------------------------------

	-----------------------------------
	-- Duplicate Item Assembly table --
	-----------------------------------
	INSERT INTO tblICItemAssembly(intItemId,
		intAssemblyItemId,
		strDescription,
		dblQuantity,
		intItemUnitMeasureId,
		dblUnit,
		dblCost,
		intSort )
	SELECT @NewItemId,
		intAssemblyItemId,
		strDescription,
		dblQuantity,
		dbo.fnICGetItemUOMIdFromDuplicateItem(intItemUnitMeasureId, @NewItemId),
		dblUnit,
		dblCost,
		intSort 
	FROM tblICItemAssembly
	WHERE intItemId = @ItemId
	--------------------------------------------
	-- End duplication of Item Assembly table --
	--------------------------------------------

	-----------------------------------------
	-- Duplicate Item Commodity Cost table --
	-----------------------------------------
	INSERT INTO tblICItemCommodityCost(intItemId,
		intItemLocationId,
		dblLastCost,
		dblStandardCost,
		dblAverageCost,
		dblEOMCost,
		intSort)
	SELECT @NewItemId,
		dbo.fnICGetItemLocationIdFromDuplicateItem(intItemLocationId, @NewItemId),
		dblLastCost,
		dblStandardCost,
		dblAverageCost,
		dblEOMCost,
		intSort
	FROM tblICItemCommodityCost
	WHERE intItemId = @ItemId
	--------------------------------------------------
	-- End duplication of Item Commodity Cost table --
	--------------------------------------------------
	
	--------------------------------
	-- Duplicate Item Owner table --
	--------------------------------
	INSERT INTO tblICItemOwner(intItemId,
		intOwnerId,
		ysnActive,
		intSort)
	SELECT @NewItemId,
		intOwnerId,
		ysnActive,
		intSort
	FROM tblICItemOwner
	WHERE intItemId = @ItemId
	-----------------------------------------
	-- End duplication of Item Owner table --
	-----------------------------------------

	---------------------------------------
	-- Duplicate Item POS Category table --
	---------------------------------------
	INSERT INTO tblICItemPOSCategory(intItemId,
		intCategoryId,
		intSort)
	SELECT @NewItemId,
		intCategoryId,
		intSort
	FROM tblICItemPOSCategory
	WHERE intItemId = @ItemId
	------------------------------------------------
	-- End duplication of Item POS Category table --
	------------------------------------------------

	----------------------------------
	-- Duplicate Item POS SLA table --
	----------------------------------
	INSERT INTO tblICItemPOSSLA(intItemId,
		strSLAContract,
		dblContractPrice,
		ysnServiceWarranty)
	SELECT @NewItemId,
		strSLAContract,
		dblContractPrice,
		ysnServiceWarranty
	FROM tblICItemPOSSLA
	WHERE intItemId = @ItemId
	-------------------------------------------
	-- End duplication of Item POS SLA table --
	-------------------------------------------

	---------------------------------------------------
	-- Duplicate Item Customer Cross Reference table --
	---------------------------------------------------
	INSERT INTO tblICItemCustomerXref(intItemId,
		intItemLocationId,
		intCustomerId,
		strCustomerProduct,
		strProductDescription,
		strPickTicketNotes,
		intSort)
	SELECT @NewItemId,
		dbo.fnICGetItemLocationIdFromDuplicateItem(intItemLocationId, @NewItemId),
		intCustomerId,
		strCustomerProduct,
		strProductDescription,
		strPickTicketNotes,
		intSort
	FROM tblICItemCustomerXref
	WHERE intItemId = @ItemId
	------------------------------------------------------------
	-- End duplication of Item Customer Cross Reference table --
	------------------------------------------------------------

	-------------------------------------------------
	-- Duplicate Item Vendor Cross Reference table --
	-------------------------------------------------
	INSERT INTO tblICItemVendorXref(intItemId,
		intItemLocationId,
		intVendorId,
		strVendorProduct,
		strProductDescription,
		dblConversionFactor,
		intItemUnitMeasureId,
		intSort)
	SELECT @NewItemId,
		dbo.fnICGetItemLocationIdFromDuplicateItem(intItemLocationId, @NewItemId),
		intVendorId,
		strVendorProduct,
		strProductDescription,
		dblConversionFactor,
		dbo.fnICGetItemUOMIdFromDuplicateItem(intItemUnitMeasureId, @NewItemId),
		intSort
	FROM tblICItemVendorXref
	WHERE intItemId = @ItemId
	----------------------------------------------------------
	-- End duplication of Item Vendor Cross Reference table --
	----------------------------------------------------------

	----------------------------------------
	-- Duplicate Item Certification table --
	----------------------------------------
	INSERT INTO tblICItemCertification(intItemId,
		intCertificationId,
		intSort)
	SELECT @NewItemId,
		intCertificationId,
		intSort
	FROM tblICItemCertification
	WHERE intItemId = @ItemId
	-------------------------------------------------
	-- End duplication of Item Certification table --
	-------------------------------------------------

	-------------------------------
	-- Duplicate Item Note table --
	-------------------------------
	INSERT INTO tblICItemNote(intItemId,
		intItemLocationId,
		strCommentType,
		strComments,
		intSort)
	SELECT @NewItemId,
		dbo.fnICGetItemLocationIdFromDuplicateItem(intItemLocationId, @NewItemId),
		strCommentType,
		strComments,
		intSort
	FROM tblICItemNote
	WHERE intItemId = @ItemId
	----------------------------------------
	-- End duplication of Item Note table --
	----------------------------------------
	
	-------------------------------------------------------------
	-------------------------------------------------------------
	-- Iterate Detail tables that have their own detail tables --
	-------------------------------------------------------------
	-------------------------------------------------------------

	DECLARE @currId INT,
		@NewDetailId INT

	------------------------------------------------
	---- Duplicate Item Kit table and its details --
	------------------------------------------------
	SELECT * INTO #tmpItemKits
	FROM tblICItemKit
	WHERE intItemId = @ItemId

	WHILE EXISTS(SELECT TOP 1 1 FROM #tmpItemKits)
	BEGIN
		SELECT TOP 1 @currId = intItemKitId FROM #tmpItemKits

		INSERT INTO tblICItemKit(intItemId,
			strComponent,
			strInputType,
			intSort)
		SELECT @NewItemId,
			strComponent,
			strInputType,
			intSort
		FROM #tmpItemKits
		WHERE intItemKitId = @currId

		SET @NewDetailId = SCOPE_IDENTITY()

		INSERT INTO tblICItemKitDetail(intItemKitId,
			intItemId,
			dblQuantity,
			intItemUnitMeasureId,
			dblPrice,
			ysnSelected,
			inSort)
		SELECT @NewDetailId,
			intItemId,
			dblQuantity,
			dbo.fnICGetItemUOMIdFromDuplicateItem(intItemUnitMeasureId, @NewItemId),
			dblPrice,
			ysnSelected,
			inSort 
		FROM tblICItemKitDetail
		WHERE intItemKitId = @currId

		DELETE FROM #tmpItemKits WHERE intItemKitId = @currId
	END

	DROP TABLE #tmpItemKits
	---------------------------------------------------------
	---- End duplication of Item Kit table and its details --
	---------------------------------------------------------

	----------------------------------------------------
	---- Duplicate Item Factory table and its details --
	----------------------------------------------------
	SELECT * INTO #tmpItemFactories
	FROM tblICItemFactory
	WHERE intItemId = @ItemId

	WHILE EXISTS(SELECT TOP 1 1 FROM #tmpItemFactories)
	BEGIN
		SELECT TOP 1 @currId = intItemFactoryId FROM #tmpItemFactories

		INSERT INTO tblICItemFactory(intItemId,
			intFactoryId,
			ysnDefault,
			intSort)
		SELECT @NewItemId,
			intFactoryId,
			ysnDefault,
			intSort
		FROM #tmpItemFactories
		WHERE intItemFactoryId = @currId

		SET @NewDetailId = SCOPE_IDENTITY()

		INSERT INTO tblICItemFactoryManufacturingCell(intItemFactoryId,
			intManufacturingCellId,
			ysnDefault,
			intPreference,
			intSort)
		SELECT @NewDetailId,
			intManufacturingCellId,
			ysnDefault,
			intPreference,
			intSort
		FROM tblICItemFactoryManufacturingCell
		WHERE intItemFactoryId = @currId

		DELETE FROM #tmpItemFactories WHERE intItemFactoryId = @currId
	END

	DROP TABLE #tmpItemFactories
	-------------------------------------------------------------
	---- End duplication of Item Factory table and its details --
	-------------------------------------------------------------

	-----------------------------------------------------
	---- Duplicate Item Contract table and its details --
	-----------------------------------------------------
	SELECT * INTO #tmpItemContracts
	FROM tblICItemContract
	WHERE intItemId = @ItemId

	WHILE EXISTS(SELECT TOP 1 1 FROM #tmpItemContracts)
	BEGIN
		SELECT TOP 1 @currId = intItemContractId FROM #tmpItemContracts

		INSERT INTO tblICItemContract(intItemId,
			intItemLocationId,
			strContractItemName,
			intCountryId,
			strGrade,
			strGradeType,
			strGarden,
			dblYieldPercent,
			dblTolerancePercent,
			dblFranchisePercent,
			intSort)
		SELECT @NewItemId,
			dbo.fnICGetItemLocationIdFromDuplicateItem(intItemLocationId, @NewItemId),
			strContractItemName,
			intCountryId,
			strGrade,
			strGradeType,
			strGarden,
			dblYieldPercent,
			dblTolerancePercent,
			dblFranchisePercent,
			intSort
		FROM #tmpItemContracts
		WHERE intItemContractId = @currId

		SET @NewDetailId = SCOPE_IDENTITY()

		INSERT INTO tblICItemContractDocument(intItemContractId,
			intDocumentId,
			intSort)
		SELECT @NewDetailId,
			intDocumentId,
			intSort
		FROM tblICItemContractDocument
		WHERE intItemContractId = @currId

		DELETE FROM #tmpItemContracts WHERE intItemContractId = @currId
	END

	DROP TABLE #tmpItemContracts
	--------------------------------------------------------------
	---- End duplication of Item Contract table and its details --
	--------------------------------------------------------------
END
GO