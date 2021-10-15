CREATE PROCEDURE uspApiSchemaTransformItem 
	@guiApiUniqueId UNIQUEIDENTIFIER,
	@guiLogId UNIQUEIDENTIFIER
AS

DECLARE @ysnAllowOverwrite BIT

SELECT @ysnAllowOverwrite = CAST(varPropertyValue AS BIT)
FROM tblApiSchemaTransformProperty
WHERE 
guiApiUniqueId = @guiApiUniqueId
AND
strPropertyName = 'Overwrite'

DECLARE @tblFilteredItem TABLE(
	intKey INT NOT NULL,
    guiApiUniqueId UNIQUEIDENTIFIER NOT NULL,
    intRowNumber INT NULL,
	strItemNo NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	strType NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	strShortName NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	strDescription NVARCHAR(250) COLLATE Latin1_General_CI_AS NOT NULL,
	strManufacturer NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	strCommodity NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	strBrand NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	strModelNo NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	strCategory NVARCHAR(200) COLLATE Latin1_General_CI_AS NOT NULL,
	ysnStockedItem BIT NULL,
	ysnDyedFuel BIT NULL,
	ysnMSDSRequired BIT NULL,
	strEPANumber NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	ysnInboundTax BIT NULL,
	ysnOutboundTax BIT NULL,
	ysnRestrictedChemical BIT NULL,
	ysnFuelItem BIT NULL,
	ysnListBundleItemsSeparately BIT NULL,
	dblDenaturantPercentage NUMERIC(38, 20) NULL,
	ysnTonnageTax BIT NULL,
	ysnLoadTracking BIT NULL,
	dblMixOrder NUMERIC(38, 20) NULL,
	ysnHandAddIngredients BIT NULL,
	ysnExtendPickTicket BIT NULL,
	ysnExportEDI BIT NULL,
	ysnHazardMaterial BIT NULL,
	ysnMaterialFee BIT NULL,
	ysnAutoBlend BIT NULL,
	dblUserGroupFeePercentage NUMERIC(38, 20) NULL,
	dblWgtTolerancePercentage NUMERIC(38, 20) NULL,
	dblOverReceiveTolerancePercentage NUMERIC(38, 20) NULL,
	strMaintenanceCalculationMethod NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	strWICCode NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
	ysnLandedCost BIT NULL,
	strLeadTime NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	ysnTaxable BIT NULL,
	strKeywords NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	dblCaseQty NUMERIC(38, 20) NULL,
	dtmDateShip DATETIME NULL,
	dblTaxExempt NUMERIC(38, 20) NULL,
	ysnDropShip BIT NULL,
	ysnCommissionable BIT NULL,
	ysnSpecialCommission BIT NULL,
	ysnTankRequired BIT NULL,
	ysnAvailableforTM BIT NULL,
	dblDefaultPercentageFull NUMERIC(38, 20) NULL,
	dblRate NUMERIC(38, 20) NULL,
	strNACSCategory NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	ysnReceiptCommentReq BIT NULL,
	strDirectSale NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	strPatronageCategory NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	strPhysicalItem NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	strVolumeRebateGroup NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	strIngredientTag NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	strMedicationTag NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	strFuelCategory NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	ysnLotWeightsRequired BIT NULL,
	ysnUseWeighScales BIT NULL,
	strCountCode NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	strRinRequired NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	strStatus NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	strLotTracking NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	strBarcodePrint NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	strFuelInspectFee NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	ysnSeparateStockForUOMs BIT NULL DEFAULT ((1))
)
INSERT INTO @tblFilteredItem
(
	intKey,
    guiApiUniqueId,
    intRowNumber,
	strItemNo,
	strType,
	strShortName,
	strDescription,
	strManufacturer,
	strCommodity,
	strBrand,
	strModelNo,
	strCategory,
	ysnStockedItem ,
	ysnDyedFuel,
	ysnMSDSRequired,
	strEPANumber,
	ysnInboundTax,
	ysnOutboundTax,
	ysnRestrictedChemical,
	ysnFuelItem,
	ysnListBundleItemsSeparately,
	dblDenaturantPercentage,
	ysnTonnageTax,
	ysnLoadTracking,
	dblMixOrder,
	ysnHandAddIngredients,
	ysnExtendPickTicket,
	ysnExportEDI,
	ysnHazardMaterial,
	ysnMaterialFee,
	ysnAutoBlend,
	dblUserGroupFeePercentage,
	dblWgtTolerancePercentage,
	dblOverReceiveTolerancePercentage,
	strMaintenanceCalculationMethod,
	strWICCode,
	ysnLandedCost,
	strLeadTime,
	ysnTaxable,
	strKeywords,
	dblCaseQty,
	dtmDateShip,
	dblTaxExempt,
	ysnDropShip,
	ysnCommissionable,
	ysnSpecialCommission,
	ysnTankRequired,
	ysnAvailableforTM,
	dblDefaultPercentageFull,
	dblRate,
	strNACSCategory,
	ysnReceiptCommentReq,
	strDirectSale,
	strPatronageCategory,
	strPhysicalItem,
	strVolumeRebateGroup,
	strIngredientTag,
	strMedicationTag,
	strFuelCategory,
	ysnLotWeightsRequired,
	ysnUseWeighScales,
	strCountCode,
	strRinRequired,
	strStatus,
	strLotTracking,
	strBarcodePrint,
	strFuelInspectFee ,
	ysnSeparateStockForUOMs
)
SELECT 
	intKey,
    guiApiUniqueId,
    intRowNumber,
	strItemNo,
	strType,
	strShortName,
	strDescription,
	strManufacturer,
	strCommodity,
	strBrand,
	strModelNo,
	strCategory,
	ysnStockedItem ,
	ysnDyedFuel,
	ysnMSDSRequired,
	strEPANumber,
	ysnInboundTax,
	ysnOutboundTax,
	ysnRestrictedChemical,
	ysnFuelItem,
	ysnListBundleItemsSeparately,
	dblDenaturantPercentage,
	ysnTonnageTax,
	ysnLoadTracking,
	dblMixOrder,
	ysnHandAddIngredients,
	ysnExtendPickTicket,
	ysnExportEDI,
	ysnHazardMaterial,
	ysnMaterialFee,
	ysnAutoBlend,
	dblUserGroupFeePercentage,
	dblWgtTolerancePercentage,
	dblOverReceiveTolerancePercentage,
	strMaintenanceCalculationMethod,
	strWICCode,
	ysnLandedCost,
	strLeadTime,
	ysnTaxable,
	strKeywords,
	dblCaseQty,
	dtmDateShip,
	dblTaxExempt,
	ysnDropShip,
	ysnCommissionable,
	ysnSpecialCommission,
	ysnTankRequired,
	ysnAvailableforTM,
	dblDefaultPercentageFull,
	dblRate,
	strNACSCategory,
	ysnReceiptCommentReq,
	strDirectSale,
	strPatronageCategory,
	strPhysicalItem,
	strVolumeRebateGroup,
	strIngredientTag,
	strMedicationTag,
	strFuelCategory,
	ysnLotWeightsRequired,
	ysnUseWeighScales,
	strCountCode,
	strRinRequired,
	strStatus,
	strLotTracking,
	strBarcodePrint,
	strFuelInspectFee ,
	ysnSeparateStockForUOMs
FROM
tblApiSchemaTransformItem
WHERE guiApiUniqueId = @guiApiUniqueId;

--Validate

--Validate duplicate Item No

INSERT INTO tblApiImportLogDetail 
(
	guiApiImportLogDetailId,
	guiApiImportLogId,
	strField,
	strValue,
	strLogLevel,
	strStatus,
	intRowNo,
	strMessage
)
SELECT
	guiApiImportLogDetailId = NEWID(),
	guiApiImportLogId = @guiLogId,
	strField = 'Item No',
	strValue = DuplicateCounter.strItemNo,
	strLogLevel = 'Warning',
	strStatus = 'Skipped',
	intRowNo = DuplicateCounter.intRowNumber,
	strMessage = 'Duplicate imported item no: ' + ISNULL(DuplicateCounter.strItemNo, '') + '.'
FROM
(
	SELECT 
		*,
		RowNumber = ROW_NUMBER() OVER(PARTITION BY strItemNo ORDER BY strItemNo)
	FROM 
		@tblFilteredItem
) AS DuplicateCounter
WHERE RowNumber > 1

--Remove duplicate Item No

DELETE DuplicateCounter
FROM
(
	SELECT 
		RowNumber = ROW_NUMBER() OVER(PARTITION BY strItemNo ORDER BY strItemNo)
	FROM 
		@tblFilteredItem
) DuplicateCounter
WHERE RowNumber > 1

DECLARE @tblErrorItem TABLE(
	strItemNo NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	intRowNumber INT NULL,
	intErrorType INT -- 1 - Lot Tracking, 2 - Item Type, 3 - Commodity
)


IF @ysnAllowOverwrite = 1
BEGIN

	--Validate update changes on Lot Tracking, Item Type and Commodity

	INSERT INTO @tblErrorItem
	(
		strItemNo,
		intRowNumber,
		intErrorType
	)
	SELECT
		FilteredItem.strItemNo,
		FilteredItem.intRowNumber,
		1 -- Lot Tracking Error
	FROM 
		@tblFilteredItem FilteredItem 
		INNER JOIN 
		tblICItem Item
			ON FilteredItem.strItemNo = Item.strItemNo
	WHERE
		FilteredItem.strLotTracking IS NOT NULL 		
		AND LOWER(Item.strLotTracking) <> RTRIM(LTRIM(LOWER(ISNULL(FilteredItem.strLotTracking, 'No'))))	
		AND dbo.fnAllowLotTrackingToChange(Item.intItemId, Item.strLotTracking) = 0
	UNION ALL
	SELECT
		FilteredItem.strItemNo,
		FilteredItem.intRowNumber,
		2 -- Item Type Error
	FROM
		@tblFilteredItem FilteredItem
		INNER JOIN 
		tblICItem Item 
			ON FilteredItem.strItemNo = Item.strItemNo
	WHERE
		FilteredItem.strType IS NOT NULL
		AND LOWER(Item.strType) <> LTRIM(RTRIM(LOWER(ISNULL(FilteredItem.strType, 'Inventory'))))
		AND dbo.fnAllowItemTypeChange(Item.intItemId, Item.strType) = 0
	UNION ALL
	SELECT
		FilteredItem.strItemNo,
		FilteredItem.intRowNumber,
		3 -- Commodity Error
	FROM 
		@tblFilteredItem FilteredItem		
		INNER JOIN tblICItem Item 
			ON FilteredItem.strItemNo = Item.strItemNo
		INNER JOIN tblICCommodity Commodity
			ON Commodity.intCommodityId = Item.intCommodityId
	WHERE
		FilteredItem.strCommodity IS NOT NULL 		
		AND LOWER(Commodity.strCommodityCode) <> LTRIM(RTRIM(LOWER(FilteredItem.strCommodity)))
		AND dbo.fnAllowCommodityToChange(Item.intItemId, Item.intCommodityId) = 0

	INSERT INTO tblApiImportLogDetail 
	(
		guiApiImportLogDetailId,
		guiApiImportLogId,
		strField,
		strValue,
		strLogLevel,
		strStatus,
		intRowNo,
		strMessage
	)
	SELECT
		guiApiImportLogDetailId = NEWID(),
		guiApiImportLogId = @guiLogId,
		strField = CASE
			WHEN ErrorItem.intErrorType = 1
				THEN 'Lot Tracking'
			WHEN ErrorItem.intErrorType = 2
				THEN 'Item Type'
			ELSE 'Commodity'
		END,
		strValue = ErrorItem.strItemNo,
		strLogLevel = 'Error',
		strStatus = 'Failed',
		intRowNo = ErrorItem.intRowNumber,
		strMessage = CASE
			WHEN ErrorItem.intErrorType = 1
				THEN 'Lot Tracking change is not allowed for item "' + ErrorItem.strItemNo + '"'
			WHEN ErrorItem.intErrorType = 2
				THEN 'Item Type change is not allowed for item "' + ErrorItem.strItemNo + '"'
			ELSE 'Commodity change is not allowed for item "' + ErrorItem.strItemNo + '"'
		END
	FROM @tblErrorItem ErrorItem
	WHERE ErrorItem.intErrorType IN(1, 2, 3)

END

--Remove Items with update error

DELETE FilteredItem
FROM @tblFilteredItem FilteredItem
INNER JOIN @tblErrorItem Error
ON FilteredItem.strItemNo = Error.strItemNo

--Crete Output Table

DECLARE @tblItemOutput TABLE(
	strItemNo NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strAction NVARCHAR(100) COLLATE Latin1_General_CI_AS
)

--Transform and Insert statement

;MERGE INTO tblICItem AS TARGET
USING
(
	SELECT
		guiApiUniqueId = FilteredItem.guiApiUniqueId,
		strItemNo = FilteredItem.strItemNo,
		strType	= COALESCE(InventoryType.strType, 'Inventory'),
		strDescription = ISNULL(FilteredItem.strDescription, FilteredItem.strItemNo),
		strStatus = COALESCE(Stat.strStatus, 'Active'),
		intLifeTime = 1,
		strShortName = FilteredItem.strShortName,
		strLotTracking = COALESCE(LotTrackingTypes.strLotTracking, 'No'),
		ysnLotWeightsRequired = FilteredItem.ysnLotWeightsRequired,
		ysnUseWeighScales = FilteredItem.ysnUseWeighScales,
		strBarcodePrint = FilteredItem.strBarcodePrint,
		intManufacturerId = Manufacturer.intManufacturerId,
		intCommodityId = Commodity.intCommodityId,
		intBrandId = Brand.intBrandId,
		strModelNo = FilteredItem.strModelNo,
		intCategoryId = Category.intCategoryId,
		ysnStockedItem = FilteredItem.ysnStockedItem,
		ysnDyedFuel = FilteredItem.ysnDyedFuel,
		ysnMSDSRequired	= FilteredItem.ysnMSDSRequired,
		strEPANumber = FilteredItem.strEPANumber,
		ysnInboundTax = FilteredItem.ysnInboundTax,
		ysnRestrictedChemical = FilteredItem.ysnRestrictedChemical,
		ysnFuelItem = FilteredItem.ysnFuelItem,
		ysnListBundleSeparately	= FilteredItem.ysnListBundleItemsSeparately,
		dblDenaturantPercent = FilteredItem.dblDefaultPercentageFull,
		ysnTonnageTax = FilteredItem.ysnTonnageTax,
		ysnLoadTracking = FilteredItem.ysnLoadTracking,
		dblMixOrder = FilteredItem.dblMixOrder,
		ysnHandAddIngredient = FilteredItem.ysnHandAddIngredients,
		ysnExtendPickTicket = FilteredItem.ysnExtendPickTicket,
		ysnExportEDI = FilteredItem.ysnExportEDI,
		ysnHazardMaterial = FilteredItem.ysnHazardMaterial,
		ysnMaterialFee = FilteredItem.ysnMaterialFee,
		ysnAutoBlend = FilteredItem.ysnAutoBlend,
		dblUserGroupFee = FilteredItem.dblUserGroupFeePercentage,
		dblWeightTolerance = FilteredItem.dblWgtTolerancePercentage,
		dblOverReceiveTolerance = FilteredItem.dblOverReceiveTolerancePercentage,
		strMaintenanceCalculationMethod = FilteredItem.strMaintenanceCalculationMethod,
		strWICCode = FilteredItem.strWICCode,
		ysnLandedCost = ISNULL(FilteredItem.ysnLandedCost, 0),
		strLeadTime = FilteredItem.strLeadTime,
		ysnTaxable = ISNULL(FilteredItem.ysnTaxable, 0),
		strKeywords = FilteredItem.strKeywords,
		dblCaseQty = FilteredItem.dblCaseQty,
		dtmDateShip = FilteredItem.dtmDateShip,
		dblTaxExempt = FilteredItem.dblTaxExempt,
		ysnDropShip = ISNULL(FilteredItem.ysnDropShip, 0),
		ysnCommisionable = ISNULL(FilteredItem.ysnCommissionable, 0),
		ysnSpecialCommission = ISNULL(FilteredItem.ysnSpecialCommission, 0),
		ysnTankRequired = FilteredItem.ysnTankRequired,
		ysnAvailableTM = FilteredItem.ysnAvailableforTM,
		dblDefaultFull = FilteredItem.dblDefaultPercentageFull,
		dblMaintenanceRate = FilteredItem.dblRate,
		strNACSCategory = FilteredItem.strNACSCategory,
		ysnReceiptCommentRequired = FilteredItem.ysnReceiptCommentReq,
		intPatronageCategoryDirectId = DirectSale.intPatronageCategoryId,
		intPatronageCategoryId = Patronage.intPatronageCategoryId,
		intPhysicalItem	= PhysicalItem.intItemId,
		strVolumeRebateGroup = FilteredItem.strVolumeRebateGroup,
		intIngredientTag = IngredientTag.intTagId,
		intMedicationTag = MedicationTag.intTagId,
		intRINFuelTypeId = Rin.intRinFuelCategoryId,
		strFuelInspectFee = FilteredItem.strFuelInspectFee,
		ysnSeparateStockForUOMs = FilteredItem.ysnSeparateStockForUOMs,
		dtmDateCreated = GETDATE(),
		intCreatedByUserId = NULL
	FROM @tblFilteredItem FilteredItem
		OUTER APPLY (
			SElECT strType
			FROM (
				SELECT 'Bundle' strType UNION
				SELECT 'Inventory' strType UNION
				SELECT 'Non-Inventory' strType UNION
				SELECT 'Kit' strType UNION
				SELECT 'Finished Good' strType UNION
				SELECT 'Other Charge' strType UNION
				SELECT 'Raw Material' strType UNION
				SELECT 'Service' strType UNION
				SELECT 'Software' strType UNION
				SELECT 'Comment' strType
			) Types WHERE LOWER(Types.strType) = LTRIM(RTRIM(LOWER(ISNULL(FilteredItem.strType, 'Inventory'))))
		) InventoryType
		OUTER APPLY (
			SELECT strStatus
			FROM (
				SELECT 'Active' strStatus UNION
				SELECT 'Phased Out' strStatus UNION
				SELECT 'Discontinued' strStatus
			) Stat WHERE LOWER(Stat.strStatus) = LTRIM(RTRIM(LOWER(ISNULL(FilteredItem.strStatus, 'Active'))))
		) Stat
		OUTER APPLY (
			SELECT strLotTracking
			FROM (
				SELECT 'No' strLotTracking UNION
				SELECT 'Yes - Manual' strLotTracking UNION
				SELECT 'Yes - Serial Number' strLotTracking UNION
				SELECT 'Yes - Manual/Serial Number' strLotTracking
			) Lot WHERE LOWER(Lot.strLotTracking) = RTRIM(LTRIM(LOWER(ISNULL(FilteredItem.strLotTracking, 'No'))))
		) LotTrackingTypes
		LEFT OUTER JOIN tblICManufacturer Manufacturer ON LOWER(Manufacturer.strManufacturer) = LTRIM(RTRIM(LOWER(FilteredItem.strManufacturer)))
		LEFT OUTER JOIN tblICCategory Category
			ON LOWER(Category.strCategoryCode) = LTRIM(RTRIM(LOWER(FilteredItem.strCategory)))
			--AND c.strInventoryType = invTypes.strType
		LEFT OUTER JOIN tblICCommodity Commodity ON LOWER(Commodity.strCommodityCode) = LTRIM(RTRIM(LOWER(FilteredItem.strCommodity)))
		LEFT OUTER JOIN tblICBrand Brand ON LOWER(Brand.strBrandCode) = LTRIM(RTRIM(LOWER(FilteredItem.strBrand)))
		LEFT OUTER JOIN tblPATPatronageCategory Patronage ON LOWER(Patronage.strCategoryCode) = LTRIM(RTRIM(LOWER(FilteredItem.strPatronageCategory)))
		LEFT OUTER JOIN tblPATPatronageCategory DirectSale ON LOWER(DirectSale.strCategoryCode) = LTRIM(RTRIM(LOWER(FilteredItem.strDirectSale)))
		LEFT OUTER JOIN tblICItem PhysicalItem ON LOWER(PhysicalItem.strItemNo) = LTRIM(RTRIM(LOWER(FilteredItem.strPhysicalItem)))
		LEFT OUTER JOIN tblICTag MedicationTag ON MedicationTag.strTagNumber = FilteredItem.strMedicationTag AND MedicationTag.strType = 'Medication Tag'
		LEFT OUTER JOIN tblICTag IngredientTag ON IngredientTag.strTagNumber = FilteredItem.strIngredientTag AND IngredientTag.strType = 'Ingredient Tag'
		LEFT OUTER JOIN tblICRinFuelCategory Rin ON Rin.strRinFuelCategoryCode = LTRIM(RTRIM(LOWER(FilteredItem.strFuelCategory)))	
) AS SOURCE
ON LTRIM(RTRIM(TARGET.strItemNo)) = LTRIM(RTRIM(SOURCE.strItemNo))
WHEN MATCHED AND @ysnAllowOverwrite = 1 
THEN
	UPDATE SET
		guiApiUniqueId = SOURCE.guiApiUniqueId,
		strItemNo = SOURCE.strItemNo,
		strInventoryTracking = 
			CASE WHEN ISNULL(SOURCE.strLotTracking, 'No') = 'No' THEN 
				CASE WHEN SOURCE.strType IN ('Inventory', 'Raw Material', 'Finished Good') THEN 'Item Level' ELSE 'None' END 
			ELSE 'Lot Level' END,
		strDescription = SOURCE.strDescription,
		strStatus = SOURCE.strStatus,
		intLifeTime = SOURCE.intLifeTime,
		strShortName = SOURCE.strShortName,
		ysnLotWeightsRequired = SOURCE.ysnLotWeightsRequired,
		ysnUseWeighScales = SOURCE.ysnUseWeighScales,
		strBarcodePrint = SOURCE.strBarcodePrint,
		intManufacturerId = SOURCE.intManufacturerId		,
		intBrandId = SOURCE.intBrandId,
		strModelNo = SOURCE.strModelNo,
		intCategoryId = SOURCE.intCategoryId,
		ysnStockedItem = SOURCE.ysnStockedItem,
		ysnDyedFuel = SOURCE.ysnDyedFuel,
		ysnMSDSRequired = SOURCE.ysnMSDSRequired,
		strEPANumber = SOURCE.strEPANumber,
		ysnInboundTax = SOURCE.ysnInboundTax,
		ysnRestrictedChemical = SOURCE.ysnRestrictedChemical,
		ysnFuelItem = SOURCE.ysnFuelItem,
		ysnListBundleSeparately = SOURCE.ysnListBundleSeparately,
		dblDenaturantPercent = SOURCE.dblDenaturantPercent,
		ysnTonnageTax = SOURCE.ysnTonnageTax,
		ysnLoadTracking = SOURCE.ysnLoadTracking,
		dblMixOrder = SOURCE.dblMixOrder,
		ysnHandAddIngredient = SOURCE.ysnHandAddIngredient,
		ysnExtendPickTicket = SOURCE.ysnExtendPickTicket,
		ysnExportEDI = SOURCE.ysnExportEDI,
		ysnHazardMaterial = SOURCE.ysnHazardMaterial,
		ysnMaterialFee = SOURCE.ysnMaterialFee,
		ysnAutoBlend = SOURCE.ysnAutoBlend,
		dblUserGroupFee = SOURCE.dblUserGroupFee,
		dblWeightTolerance = SOURCE.dblWeightTolerance,
		dblOverReceiveTolerance = SOURCE.dblOverReceiveTolerance,
		strMaintenanceCalculationMethod = SOURCE.strMaintenanceCalculationMethod,
		strWICCode = SOURCE.strWICCode,
		ysnLandedCost = SOURCE.ysnLandedCost,
		strLeadTime = SOURCE.strLeadTime,
		ysnTaxable = SOURCE.ysnTaxable,
		strKeywords = SOURCE.strKeywords,
		dblCaseQty = SOURCE.dblCaseQty,
		dtmDateShip = SOURCE.dtmDateShip,
		dblTaxExempt = SOURCE.dblTaxExempt,
		ysnDropShip = SOURCE.ysnDropShip,
		ysnCommisionable = SOURCE.ysnCommisionable,
		ysnSpecialCommission = SOURCE.ysnSpecialCommission,
		ysnTankRequired = SOURCE.ysnTankRequired,
		ysnAvailableTM = SOURCE.ysnAvailableTM,
		dblDefaultFull = SOURCE.dblDefaultFull,
		dblMaintenanceRate = SOURCE.dblMaintenanceRate,
		strNACSCategory = SOURCE.strNACSCategory,
		ysnReceiptCommentRequired = SOURCE.ysnReceiptCommentRequired,
		intPatronageCategoryDirectId = SOURCE.intPatronageCategoryDirectId,
		intPatronageCategoryId = SOURCE.intPatronageCategoryId,
		intPhysicalItem = SOURCE.intPhysicalItem,
		strVolumeRebateGroup = SOURCE.strVolumeRebateGroup,
		intIngredientTag = SOURCE.intIngredientTag,
		intMedicationTag = SOURCE.intMedicationTag,
		intRINFuelTypeId = SOURCE.intRINFuelTypeId,
		strFuelInspectFee = SOURCE.strFuelInspectFee,
		ysnSeparateStockForUOMs = SOURCE.ysnSeparateStockForUOMs,
		dtmDateModified = GETUTCDATE(),
		intModifiedByUserId = SOURCE.intCreatedByUserId
WHEN NOT MATCHED THEN
	INSERT
	(
		guiApiUniqueId,
		strItemNo,
		strType,
		strInventoryTracking,
		strDescription,
		strStatus,
		intLifeTime,
		strShortName,
		strLotTracking,
		ysnLotWeightsRequired,
		ysnUseWeighScales,
		strBarcodePrint,
		intManufacturerId,
		intCommodityId,
		intBrandId,
		strModelNo,
		intCategoryId,
		ysnStockedItem,
		ysnDyedFuel,
		ysnMSDSRequired,
		strEPANumber,
		ysnInboundTax,
		ysnRestrictedChemical,
		ysnFuelItem,
		ysnListBundleSeparately,
		dblDenaturantPercent,
		ysnTonnageTax,
		ysnLoadTracking,
		dblMixOrder,
		ysnHandAddIngredient,
		ysnExtendPickTicket,
		ysnExportEDI,
		ysnHazardMaterial,
		ysnMaterialFee,
		ysnAutoBlend,
		dblUserGroupFee,
		dblWeightTolerance,
		dblOverReceiveTolerance,
		strMaintenanceCalculationMethod,
		strWICCode,
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
		ysnTankRequired,
		ysnAvailableTM,
		dblDefaultFull,
		dblMaintenanceRate,
		strNACSCategory,
		ysnReceiptCommentRequired,
		intPatronageCategoryDirectId,
		intPatronageCategoryId,
		intPhysicalItem,
		strVolumeRebateGroup,
		intIngredientTag,
		intMedicationTag,
		intRINFuelTypeId,
		strFuelInspectFee,
		ysnSeparateStockForUOMs,
		dtmDateCreated,
		intDataSourceId
	)
	VALUES
	(
		guiApiUniqueId,
		strItemNo,
		strType,
		CASE WHEN ISNULL(strLotTracking, 'No') = 'No' THEN
				CASE WHEN strType IN ('Inventory', 'Raw Material', 'Finished Good') THEN 'Item Level' ELSE 'None' END
			ELSE 'Lot Level' END,
		strDescription,
		strStatus,
		intLifeTime,
		strShortName,
		strLotTracking,
		ysnLotWeightsRequired,
		ysnUseWeighScales,
		strBarcodePrint,
		intManufacturerId,
		intCommodityId,
		intBrandId,
		strModelNo,
		intCategoryId,
		ysnStockedItem,
		ysnDyedFuel,
		ysnMSDSRequired,
		strEPANumber,
		ysnInboundTax,
		ysnRestrictedChemical,
		ysnFuelItem,
		ysnListBundleSeparately,
		dblDenaturantPercent,
		ysnTonnageTax,
		ysnLoadTracking,
		dblMixOrder,
		ysnHandAddIngredient,
		ysnExtendPickTicket,
		ysnExportEDI,
		ysnHazardMaterial,
		ysnMaterialFee,
		ysnAutoBlend,
		dblUserGroupFee,
		dblWeightTolerance,
		dblOverReceiveTolerance,
		strMaintenanceCalculationMethod,
		strWICCode,
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
		ysnTankRequired,
		ysnAvailableTM,
		dblDefaultFull,
		dblMaintenanceRate,
		strNACSCategory,
		ysnReceiptCommentRequired,
		intPatronageCategoryDirectId,
		intPatronageCategoryId,
		intPhysicalItem,
		strVolumeRebateGroup,
		intIngredientTag,
		intMedicationTag,
		intRINFuelTypeId,
		strFuelInspectFee,
		ysnSeparateStockForUOMs,
		dtmDateCreated,
		2
	)
OUTPUT INSERTED.strItemNo, $action AS strAction INTO @tblItemOutput;

--Log skipped items when overwrite is not enabled.

INSERT INTO tblApiImportLogDetail 
(
	guiApiImportLogDetailId,
	guiApiImportLogId,
	strField,
	strValue,
	strLogLevel,
	strStatus,
	intRowNo,
	strMessage
)
SELECT
	guiApiImportLogDetailId = NEWID(),
	guiApiImportLogId = @guiLogId,
	strField = 'Item No',
	strValue = FilteredItem.strItemNo,
	strLogLevel = 'Warning',
	strStatus = 'Skipped',
	intRowNo = FilteredItem.intRowNumber,
	strMessage = 'Item No "' + FilteredItem.strItemNo + '" already exists and overwrite is not enabled.'
FROM @tblFilteredItem FilteredItem
LEFT JOIN @tblItemOutput ItemOutput
	ON FilteredItem.strItemNo = ItemOutput.strItemNo
WHERE ItemOutput.strItemNo IS NULL