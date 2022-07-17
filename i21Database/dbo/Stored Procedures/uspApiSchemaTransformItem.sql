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

INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT
      NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Category'
    , strValue = sr.strCategory
    , strLogLevel = 'Error'
    , strStatus = 'Failed'
    , intRowNo = sr.intRowNumber
    , strMessage = 'The Category ' + ISNULL(sr.strCategory, '') + ' does not exist.'
FROM tblApiSchemaTransformItem sr
OUTER APPLY (
  SELECT TOP 1 * 
  FROM tblICCategory ii
  WHERE ii.strCategoryCode = sr.strCategory OR ii.strDescription = sr.strCategory
) e
WHERE sr.guiApiUniqueId = @guiApiUniqueId
AND e.intCategoryId IS NULL

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
	ysnSeparateStockForUOMs BIT NULL DEFAULT ((1)),
	strSubcategory NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
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
	ysnSeparateStockForUOMs,
	strSubcategory
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
	ysnSeparateStockForUOMs,
	strSubcategory
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
	UNION ALL
	SELECT
		FilteredItem.strItemNo,
		FilteredItem.intRowNumber,
		4 -- Category Error
	FROM 
		@tblFilteredItem FilteredItem		
		INNER JOIN tblICItem Item 
			ON FilteredItem.strItemNo = Item.strItemNo
		INNER JOIN tblICCategory Category
			ON Category.intCategoryId = Item.intCategoryId
	WHERE
		FilteredItem.strCommodity IS NOT NULL 		
		AND LOWER(Category.strCategoryCode) <> LTRIM(RTRIM(LOWER(FilteredItem.strCategory)))

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
			WHEN ErrorItem.intErrorType = 3
				THEN 'Commodity'
			ELSE 'Category'
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
			WHEN ErrorItem.intErrorType = 3
				THEN 'Commodity change is not allowed for item "' + ErrorItem.strItemNo + '"'
			ELSE 'Category is required for item "' + ErrorItem.strItemNo + '"'
		END
	FROM @tblErrorItem ErrorItem
	WHERE ErrorItem.intErrorType IN(1, 2, 3, 4)

END

INSERT INTO tblICItem (
  strItemNo
, strType
, strInventoryTracking
, strDescription
, strStatus
, intLifeTime
, strShortName
, strLotTracking
, ysnUseWeighScales
, strBarcodePrint
, intManufacturerId
, intCommodityId
, intBrandId
, strModelNo
, intCategoryId
, ysnStockedItem
, ysnDyedFuel
, ysnMSDSRequired
, strEPANumber
, ysnInboundTax
, ysnRestrictedChemical
, ysnFuelItem
, ysnListBundleSeparately
, dblDenaturantPercent
, ysnTonnageTax
, ysnLoadTracking
, dblMixOrder
, ysnHandAddIngredient
, ysnExtendPickTicket
, ysnExportEDI
, ysnHazardMaterial
, ysnMaterialFee
, ysnAutoBlend
, dblUserGroupFee
, dblWeightTolerance
, dblOverReceiveTolerance
, ysnTankRequired
, ysnAvailableTM
, dblDefaultFull
, dblMaintenanceRate
, intPatronageCategoryDirectId
, intPatronageCategoryId
, intPhysicalItem
, strVolumeRebateGroup
, intIngredientTag
, intMedicationTag
, intRINFuelTypeId
, strFuelInspectFee
, ysnSeparateStockForUOMs
, intSubcategoriesId
, dtmDateCreated
, intDataSourceId
, intRowNumber
, guiApiUniqueId)
SELECT
    sr.strItemNo
  , COALESCE(invTypes.strType, 'Inventory')
  , CASE WHEN ISNULL(sr.strLotTracking, 'No') = 'No' THEN
			CASE WHEN sr.strType IN ('Inventory', 'Raw Material', 'Finished Good') THEN 'Item Level' ELSE 'None' END
		ELSE 'Lot Level' END
  , ISNULL(sr.strDescription, sr.strItemNo)
  , COALESCE(statuses.strStatus, 'Active')
  , 1
  , sr.strShortName
  , COALESCE(lotTrackTypes.strLotTracking, 'No')
  , sr.ysnUseWeighScales
  , sr.strBarcodePrint
  , m.intManufacturerId
  , cm.intCommodityId
  , b.intBrandId
  , sr.strModelNo
  , c.intCategoryId
  , sr.ysnStockedItem
  , sr.ysnDyedFuel
  , sr.ysnMSDSRequired
  , sr.strEPANumber
  , sr.ysnInboundTax
  , sr.ysnRestrictedChemical
  , sr.ysnFuelItem
  , sr.ysnListBundleItemsSeparately
  , sr.dblDefaultPercentageFull
  , sr.ysnTonnageTax
  , sr.ysnLoadTracking
  , sr.dblMixOrder
  , sr.ysnHandAddIngredients
  , sr.ysnExtendPickTicket
  , sr.ysnExportEDI
  , sr.ysnHazardMaterial
  , sr.ysnMaterialFee
  , sr.ysnAutoBlend
  , sr.dblUserGroupFeePercentage
  , sr.dblWgtTolerancePercentage
  , sr.dblOverReceiveTolerancePercentage
  , sr.ysnTankRequired
  , sr.ysnAvailableforTM
  , sr.dblDefaultPercentageFull
  , sr.dblRate
  , ds.intPatronageCategoryId
  , p.intPatronageCategoryId
  , ph.intItemId
  , sr.strVolumeRebateGroup
  , ing.intTagId
  , med.intTagId
  , rin.intRinFuelCategoryId
  , sr.strFuelInspectFee
  , sr.ysnSeparateStockForUOMs
  , subcat.intSubcategoriesId
  , GETUTCDATE()
  , 3
  , sr.intRowNumber
  , @guiApiUniqueId
FROM tblApiSchemaTransformItem sr
LEFT JOIN @Types invTypes ON LOWER(invTypes.strType) = LTRIM(RTRIM(LOWER(ISNULL(sr.strType, 'Inventory'))))
LEFT JOIN @Statuses statuses ON LOWER(statuses.strStatus) = LTRIM(RTRIM(LOWER(ISNULL(sr.strStatus, 'Active'))))
LEFT JOIN @LotTracking lotTrackTypes ON LOWER(lotTrackTypes.strLotTracking) = RTRIM(LTRIM(LOWER(ISNULL(sr.strLotTracking, 'No'))))
LEFT OUTER JOIN tblICManufacturer m ON LOWER(m.strManufacturer) = LTRIM(RTRIM(LOWER(sr.strManufacturer)))
LEFT OUTER JOIN tblICCategory c 
  ON LOWER(c.strCategoryCode) = LTRIM(RTRIM(LOWER(sr.strCategory)))
  --AND c.strInventoryType = invTypes.strType
LEFT OUTER JOIN tblICCommodity cm ON LOWER(cm.strCommodityCode) = LTRIM(RTRIM(LOWER(sr.strCommodity)))
LEFT OUTER JOIN tblICBrand b ON LOWER(b.strBrandCode) = LTRIM(RTRIM(LOWER(sr.strBrand)))
LEFT OUTER JOIN tblPATPatronageCategory p ON LOWER(p.strCategoryCode) = LTRIM(RTRIM(LOWER(sr.strPatronageCategory)))
LEFT OUTER JOIN tblPATPatronageCategory ds ON LOWER(ds.strCategoryCode) = LTRIM(RTRIM(LOWER(sr.strDirectSale)))
LEFT OUTER JOIN tblICItem ph ON LOWER(ph.strItemNo) = LTRIM(RTRIM(LOWER(sr.strPhysicalItem)))
LEFT OUTER JOIN tblICTag med ON med.strTagNumber = sr.strMedicationTag AND med.strType = 'Medication Tag'
LEFT OUTER JOIN tblICTag ing ON ing.strTagNumber = sr.strIngredientTag AND ing.strType = 'Ingredient Tag'
LEFT OUTER JOIN tblICRinFuelCategory rin ON rin.strRinFuelCategoryCode = LTRIM(RTRIM(LOWER(sr.strFuelCategory)))
LEFT OUTER JOIN tblSTSubCategories subcat ON LOWER(subcat.strSubCategory) = LTRIM(RTRIM(LOWER(sr.strSubcategory)))
WHERE sr.guiApiUniqueId = @guiApiUniqueId
  AND NOT EXISTS (
    SELECT TOP 1 1
    FROM tblApiImportLogDetail d
    WHERE d.guiApiImportLogId = @guiLogId
      AND d.intRowNo = sr.intRowNumber
      AND d.strLogLevel = 'Error'
  )
  AND NOT EXISTS(
    SELECT TOP 1 1 
    FROM tblICItem x 
    WHERE x.strItemNo = sr.strItemNo
  )

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

UPDATE i 
SET
    i.strInventoryTracking = CASE WHEN ISNULL(sr.strLotTracking, 'No') = 'No' THEN CASE WHEN sr.strType IN ('Inventory', 'Raw Material', 'Finished Good') THEN 'Item Level' ELSE 'None' END ELSE 'Lot Level' END
  , i.strDescription = ISNULL(sr.strDescription, sr.strItemNo)
  , i.strStatus = COALESCE(statuses.strStatus, 'Active')
  , i.intLifeTime = 1
  , i.strShortName = sr.strShortName
  , i.ysnUseWeighScales = sr.ysnUseWeighScales
  , i.strBarcodePrint = sr.strBarcodePrint
  , i.intManufacturerId = m.intManufacturerId
  , i.intBrandId = b.intBrandId
  , i.strModelNo = sr.strModelNo
  , i.intCategoryId = c.intCategoryId
  , i.ysnStockedItem = sr.ysnStockedItem
  , i.ysnDyedFuel = sr.ysnDyedFuel
  , i.ysnMSDSRequired = sr.ysnMSDSRequired
  , i.strEPANumber = sr.strEPANumber
  , i.ysnInboundTax = sr.ysnInboundTax
  , i.ysnRestrictedChemical = sr.ysnRestrictedChemical
  , i.ysnFuelItem = sr.ysnFuelItem
  , i.ysnListBundleSeparately = sr.ysnListBundleItemsSeparately
  , i.dblDenaturantPercent = sr.dblDefaultPercentageFull
  , i.ysnTonnageTax = sr.ysnTonnageTax
  , i.ysnLoadTracking = sr.ysnLoadTracking
  , i.dblMixOrder = sr.dblMixOrder
  , i.ysnHandAddIngredient = sr.ysnHandAddIngredients
  , i.ysnExtendPickTicket = sr.ysnExtendPickTicket
  , i.ysnExportEDI = sr.ysnExportEDI
  , i.ysnHazardMaterial = sr.ysnHazardMaterial
  , i.ysnMaterialFee = sr.ysnMaterialFee
  , i.ysnAutoBlend = sr.ysnAutoBlend
  , i.dblUserGroupFee = sr.dblUserGroupFeePercentage
  , i.dblWeightTolerance = sr.dblWgtTolerancePercentage
  , i.dblOverReceiveTolerance = sr.dblOverReceiveTolerancePercentage
  , i.ysnTankRequired = sr.ysnTankRequired
  , i.ysnAvailableTM = sr.ysnAvailableforTM
  , i.dblDefaultFull = sr.dblDefaultPercentageFull
  , i.dblMaintenanceRate = sr.dblRate
  , i.intPatronageCategoryDirectId = ds.intPatronageCategoryId
  , i.intPatronageCategoryId = p.intPatronageCategoryId
  , i.intPhysicalItem = ph.intItemId
  , i.strVolumeRebateGroup = sr.strVolumeRebateGroup
  , i.intIngredientTag = ing.intTagId
  , i.intMedicationTag = med.intTagId
  , i.intRINFuelTypeId = rin.intRinFuelCategoryId
  , i.strFuelInspectFee = sr.strFuelInspectFee
  , i.ysnSeparateStockForUOMs = sr.ysnSeparateStockForUOMs
  , i.intSubcategoriesId = subcat.intSubcategoriesId
  , i.dtmDateCreated = GETUTCDATE()
  , i.intDataSourceId = 3
  , i.intRowNumber = sr.intRowNumber
  , i.guiApiUniqueId = @guiApiUniqueId
FROM tblApiSchemaTransformItem sr
JOIN tblICItem i ON i.strItemNo = sr.strItemNo
LEFT JOIN @Statuses statuses ON LOWER(statuses.strStatus) = LTRIM(RTRIM(LOWER(ISNULL(sr.strStatus, 'Active'))))
LEFT OUTER JOIN tblICManufacturer m ON LOWER(m.strManufacturer) = LTRIM(RTRIM(LOWER(sr.strManufacturer)))
LEFT OUTER JOIN tblICCategory c 
  ON LOWER(c.strCategoryCode) = LTRIM(RTRIM(LOWER(sr.strCategory)))
  --AND c.strInventoryType = invTypes.strType
LEFT OUTER JOIN tblICBrand b ON LOWER(b.strBrandCode) = LTRIM(RTRIM(LOWER(sr.strBrand))) OR LOWER(b.strBrandName) = LTRIM(RTRIM(LOWER(sr.strBrand)))
LEFT OUTER JOIN tblPATPatronageCategory p ON LOWER(p.strCategoryCode) = LTRIM(RTRIM(LOWER(sr.strPatronageCategory)))
LEFT OUTER JOIN tblPATPatronageCategory ds ON LOWER(ds.strCategoryCode) = LTRIM(RTRIM(LOWER(sr.strDirectSale)))
LEFT OUTER JOIN tblICItem ph ON LOWER(ph.strItemNo) = LTRIM(RTRIM(LOWER(sr.strPhysicalItem)))
LEFT OUTER JOIN tblICTag med ON med.strTagNumber = sr.strMedicationTag AND med.strType = 'Medication Tag'
LEFT OUTER JOIN tblICTag ing ON ing.strTagNumber = sr.strIngredientTag AND ing.strType = 'Ingredient Tag'
LEFT OUTER JOIN tblICRinFuelCategory rin ON rin.strRinFuelCategoryCode = LTRIM(RTRIM(LOWER(sr.strFuelCategory)))
LEFT OUTER JOIN tblSTSubCategories subcat ON LOWER(subcat.strSubCategory) = LTRIM(RTRIM(LOWER(sr.strSubcategory)))
WHERE sr.guiApiUniqueId = @guiApiUniqueId
  AND @OverwriteExisting = 1
  AND NOT EXISTS (
    SELECT TOP 1 1
    FROM tblApiImportLogDetail d
    WHERE d.guiApiImportLogId = @guiLogId
      AND d.intRowNo = sr.intRowNumber
      AND d.strLogLevel = 'Error'
  )
  
-- Log successful imports
INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage, strAction)
SELECT
      NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Item'
    , strValue = i.strItemNo
    , strLogLevel = 'Info'
    , strStatus = 'Success'
    , intRowNo = i.intRowNumber
    , strMessage = 'The item ' + ISNULL(i.strItemNo, '') + ' was imported successfully.'
    , strAction = 'Create'
FROM tblICItem i
WHERE i.guiApiUniqueId = @guiApiUniqueId
  AND NOT EXISTS(SELECT TOP 1 1 FROM @ForUpdates u WHERE u.strItemNo = i.strItemNo AND u.intRowNumber = i.intRowNumber)

--Log skipped items when overwrite is not enabled.

--INSERT INTO tblApiImportLogDetail 
--(
--	guiApiImportLogDetailId,
--	guiApiImportLogId,
--	strField,
--	strValue,
--	strLogLevel,
--	strStatus,
--	intRowNo,
--	strMessage
--)
--SELECT
--	guiApiImportLogDetailId = NEWID(),
--	guiApiImportLogId = @guiLogId,
--	strField = 'Item No',
--	strValue = FilteredItem.strItemNo,
--	strLogLevel = 'Warning',
--	strStatus = 'Skipped',
--	intRowNo = FilteredItem.intRowNumber,
--	strMessage = 'Item No "' + FilteredItem.strItemNo + '" already exists and overwrite is not enabled.'
--FROM @tblFilteredItem FilteredItem
--LEFT JOIN @tblItemOutput ItemOutput
--	ON FilteredItem.strItemNo = ItemOutput.strItemNo
--WHERE ItemOutput.strItemNo IS NULL