CREATE PROCEDURE uspApiSchemaTransformItem 
	@guiApiUniqueId UNIQUEIDENTIFIER,
	@guiLogId UNIQUEIDENTIFIER
AS

-- Retrieve Properties
DECLARE @OverwriteExisting BIT = 1

SELECT
    @OverwriteExisting = ISNULL(CAST(Overwrite AS BIT), 0)
FROM (
	SELECT tp.strPropertyName, tp.varPropertyValue
	FROM tblApiSchemaTransformProperty tp
	WHERE tp.guiApiUniqueId = @guiApiUniqueId
) AS Properties
PIVOT (
	MIN(varPropertyValue)
	FOR strPropertyName IN
	(
		Overwrite
	)
) AS PivotTable

DECLARE @Types TABLE (strType NVARCHAR(50) COLLATE Latin1_General_CI_AS)
INSERT INTO @Types
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

DECLARE  @Statuses TABLE(strStatus NVARCHAR(50) COLLATE Latin1_General_CI_AS)
INSERT INTO @Statuses
SELECT 'Active' strStatus UNION
SELECT 'Phased Out' strStatus UNION
SELECT 'Discontinued' strStatus

DECLARE @LotTracking TABLE (strLotTracking NVARCHAR(50) COLLATE Latin1_General_CI_AS)
INSERT INTO @LotTracking
SELECT 'No' strLotTracking UNION
SELECT 'Yes - Manual' strLotTracking UNION
SELECT 'Yes - Serial Number' strLotTracking UNION
SELECT 'Yes - Manual/Serial Number' strLotTracking

IF @OverwriteExisting = 1
BEGIN
	-- Check if lot tracking can be changed
	INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
	SELECT
      NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Lot Tracking'
    , strValue = sr.strLotTracking
    , strLogLevel = 'Error'
    , strStatus = 'Failed'
    , intRowNo = sr.intRowNumber
    , strMessage = 'The Lot Tracking of "' + ISNULL(i.strItemNo, '') + '" cannot be changed.'
	FROM tblApiSchemaTransformItem sr
	JOIN tblICItem i ON sr.strItemNo = i.strItemNo
	WHERE sr.guiApiUniqueId = @guiApiUniqueId
		AND sr.strLotTracking IS NOT NULL
		AND sr.strLotTracking != ''
		AND LOWER(i.strLotTracking) <> RTRIM(LTRIM(LOWER(ISNULL(sr.strLotTracking, 'No'))))	
		AND dbo.fnAllowLotTrackingToChange(i.intItemId, i.strLotTracking) = 0

	-- Check if item type can be changed. 
	INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
	SELECT
      NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Type'
    , strValue = sr.strType
    , strLogLevel = 'Error'
    , strStatus = 'Failed'
    , intRowNo = sr.intRowNumber
    , strMessage = 'The Type of "' + ISNULL(i.strItemNo, '') + '" cannot be changed. The item already has transactions.'
	FROM tblApiSchemaTransformItem sr
	JOIN tblICItem i ON sr.strItemNo = i.strItemNo
	WHERE sr.guiApiUniqueId = @guiApiUniqueId
		AND sr.strType IS NOT NULL
		AND sr.strType != ''
		AND LOWER(i.strType) != LTRIM(RTRIM(LOWER(ISNULL(sr.strType, 'Inventory'))))
		AND dbo.fnAllowItemTypeChange(i.intItemId, i.strType) = 0

	-- Check if commodity can be changed. 
	INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
	SELECT
      NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Commodity'
    , strValue = sr.strCommodity
    , strLogLevel = 'Error'
    , strStatus = 'Failed'
    , intRowNo = sr.intRowNumber
    , strMessage = 'The Commodity of "' + ISNULL(i.strItemNo, '') + '" cannot be changed. The item have a contract and/or transactions and it will affect the commodity position.'
	FROM tblApiSchemaTransformItem sr
	JOIN tblICItem i ON sr.strItemNo = i.strItemNo
	JOIN tblICCommodity c ON c.intCommodityId = i.intCommodityId
	WHERE sr.guiApiUniqueId = @guiApiUniqueId
		AND sr.strCommodity IS NOT NULL
		AND sr.strCommodity != ''
		AND LOWER(c.strCommodityCode) <> LTRIM(RTRIM(LOWER(sr.strCommodity)))
		AND dbo.fnAllowCommodityToChange(i.intItemId, i.intCommodityId) = 0
END

-- Remove duplicate item numbers from file
;WITH cte AS
(
   SELECT *, ROW_NUMBER() OVER(PARTITION BY sr.strItemNo ORDER BY sr.strItemNo) AS RowNumber
   FROM tblApiSchemaTransformItem sr
   WHERE sr.guiApiUniqueId = @guiApiUniqueId
   AND sr.strItemNo IS NOT NULL
   AND sr.strItemNo != ''
   AND @OverwriteExisting = 0
)
INSERT INTO tblApiImportLogDetail(guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage, strAction)
SELECT
      NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Item No'
    , strValue = sr.strItemNo
    , strLogLevel = 'Error'
    , strStatus = 'Failed'
    , intRowNo = sr.intRowNumber
    , strMessage = 'The Item No ' + ISNULL(sr.strItemNo, '') + ' in the file has duplicates.'
    , strAction = 'Skipped'
FROM cte sr
JOIN tblICItem i ON i.strItemNo = sr.strItemNo
WHERE sr.guiApiUniqueId = @guiApiUniqueId
	AND sr.RowNumber > 1
  AND @OverwriteExisting = 0

;WITH cte AS
(
   SELECT *, ROW_NUMBER() OVER(PARTITION BY sr.strItemNo ORDER BY sr.strItemNo) AS RowNumber
   FROM tblApiSchemaTransformItem sr
   WHERE sr.guiApiUniqueId = @guiApiUniqueId
   AND sr.strItemNo IS NOT NULL
   AND sr.strItemNo != ''
   AND @OverwriteExisting = 0
)
DELETE FROM cte WHERE RowNumber > 1
AND @OverwriteExisting = 0

INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT
      NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Category'
    , strValue = sr.strCategory
    , strLogLevel = 'Error'
    , strStatus = 'Failed'
    , intRowNo = sr.intRowNumber
    , strMessage = 'The Category "' + ISNULL(sr.strCategory, '') + '" does not exist.'
FROM tblApiSchemaTransformItem sr
LEFT JOIN tblICCategory c ON c.strCategoryCode =  sr.strCategory OR c.strDescription = sr.strCategory
WHERE sr.guiApiUniqueId = @guiApiUniqueId
	AND sr.strCategory IS NOT NULL
	AND sr.strCategory != ''
  AND c.intCategoryId IS NULL

INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT
      NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Commodity'
    , strValue = sr.strCommodity
    , strLogLevel = 'Error'
    , strStatus = 'Failed'
    , intRowNo = sr.intRowNumber
    , strMessage = 'The Commodity "' + ISNULL(sr.strCommodity, '') + '" does not exist.'
FROM tblApiSchemaTransformItem sr
LEFT JOIN tblICCommodity c ON c.strCommodityCode = sr.strCommodity OR c.strDescription = sr.strCommodity
WHERE sr.guiApiUniqueId = @guiApiUniqueId
	AND sr.strCommodity IS NOT NULL
	AND sr.strCommodity != ''
  AND c.intCommodityId IS NULL

INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT
      NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Type'
    , strValue = sr.strType
    , strLogLevel = 'Error'
    , strStatus = 'Failed'
    , intRowNo = sr.intRowNumber
    , strMessage = 'The Type "' + ISNULL(sr.strType, '') + '" is not valid.'
FROM tblApiSchemaTransformItem sr
LEFT JOIN @Types types ON types.strType = sr.strType
WHERE sr.guiApiUniqueId = @guiApiUniqueId
	AND sr.strType IS NOT NULL
	AND sr.strType != ''
  AND types.strType IS NULL

INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT
      NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Lot Tracking'
    , strValue = sr.strLotTracking
    , strLogLevel = 'Error'
    , strStatus = 'Failed'
    , intRowNo = sr.intRowNumber
    , strMessage = 'The Lot Tracking "' + ISNULL(sr.strLotTracking, '') + '" is not valid.'
FROM tblApiSchemaTransformItem sr
LEFT JOIN @LotTracking lotTracking ON lotTracking.strLotTracking = sr.strLotTracking
WHERE sr.guiApiUniqueId = @guiApiUniqueId
	AND sr.strLotTracking IS NOT NULL
	AND sr.strLotTracking != ''
  AND lotTracking.strLotTracking IS NULL

-- Existing item
INSERT INTO tblApiImportLogDetail(guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT
      NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Item No'
    , strValue = sr.strItemNo
    , strLogLevel = 'Error'
    , strStatus = 'Failed'
    , intRowNo = sr.intRowNumber
    , strMessage = ISNULL(sr.strItemNo, '') + ' already exists.'
FROM tblApiSchemaTransformItem sr
CROSS APPLY (
  SELECT TOP 1 1 intCount
  FROM tblICItem i
  WHERE i.strItemNo = sr.strItemNo
) ex
WHERE sr.guiApiUniqueId = @guiApiUniqueId
  AND @OverwriteExisting = 0

-- Flag items for modifications
DECLARE @ForUpdates TABLE (strItemNo NVARCHAR(200) COLLATE Latin1_General_CI_AS, intRowNumber INT NULL)
INSERT INTO @ForUpdates
SELECT i.strItemNo, sr.intRowNumber
FROM tblApiSchemaTransformItem sr
JOIN tblICItem i ON i.strItemNo = sr.strItemNo
WHERE sr.guiApiUniqueId = @guiApiUniqueId

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
, strInvoiceComments
, strPickListComments
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
  , sr.strInvoiceComments
  , sr.strPickListComments
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


-- Update type
UPDATE i
SET i.strType = COALESCE(invTypes.strType, 'Inventory')
FROM tblApiSchemaTransformItem sr
JOIN tblICItem i ON i.strItemNo = sr.strItemNo
JOIN @Types invTypes ON LOWER(invTypes.strType) = LTRIM(RTRIM(LOWER(ISNULL(sr.strType, 'Inventory'))))
WHERE sr.guiApiUniqueId = @guiApiUniqueId
  AND @OverwriteExisting = 1
  AND sr.strType != ''
  AND sr.strType IS NOT NULL
  AND dbo.fnAllowItemTypeChange(i.intItemId, i.strType) = 1

-- Update Lot Tracking
UPDATE i
SET i.strLotTracking = COALESCE(lotTrackTypes.strLotTracking, 'No')
FROM tblApiSchemaTransformItem sr
JOIN tblICItem i ON i.strItemNo = sr.strItemNo
JOIN @LotTracking lotTrackTypes ON LOWER(lotTrackTypes.strLotTracking) = RTRIM(LTRIM(LOWER(ISNULL(sr.strLotTracking, 'No'))))
WHERE sr.guiApiUniqueId = @guiApiUniqueId
  AND @OverwriteExisting = 1
  AND sr.strLotTracking != ''
  AND sr.strLotTracking IS NOT NULL
  AND dbo.fnAllowLotTrackingToChange(i.intItemId, i.strLotTracking) = 1

-- Update commodity
UPDATE i
SET i.intCommodityId = cm.intCommodityId
FROM tblApiSchemaTransformItem sr
JOIN tblICItem i ON i.strItemNo = sr.strItemNo
LEFT OUTER JOIN tblICCommodity cm ON LOWER(cm.strCommodityCode) = LTRIM(RTRIM(LOWER(sr.strCommodity)))
WHERE sr.guiApiUniqueId = @guiApiUniqueId
  AND @OverwriteExisting = 1
  AND sr.strCommodity != ''
  AND sr.strCommodity IS NOT NULL
  AND dbo.fnAllowCommodityToChange(i.intItemId, i.intCommodityId) = 1

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
  , i.strInvoiceComments = sr.strInvoiceComments
  , i.strPickListComments = sr.strPickListComments
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

INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage, strAction)
SELECT
      NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Item'
    , strValue = i.strItemNo
    , strLogLevel = 'Info'
    , strStatus = 'Success'
    , intRowNo = i.intRowNumber
    , strMessage = 'The item ' + ISNULL(i.strItemNo, '') + ' was updated successfully.'
    , strAction = 'Update'
FROM tblICItem i
JOIN @ForUpdates u ON u.strItemNo = i.strItemNo
WHERE i.guiApiUniqueId = @guiApiUniqueId

UPDATE log
SET log.intTotalRowsImported = r.intCount
FROM tblApiImportLog log
CROSS APPLY (
	SELECT COUNT(*) intCount
	FROM tblICItem
	WHERE guiApiUniqueId = log.guiApiUniqueId
) r
WHERE log.guiApiImportLogId = @guiLogId