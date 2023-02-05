CREATE PROCEDURE dbo.uspApiSchemaTransformCategoryLocation
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
  
INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage, strAction)
SELECT
	  NEWID()
	, guiApiImportLogId = @guiLogId
	, strField = dbo.fnApiSchemaTransformMapField(@guiApiUniqueId, 'Category') 
	, strValue = vts.strCategory
	, strLogLevel = 'Error'
	, strStatus = 'Failed'
	, intRowNo = vts.intRowNumber
	, strMessage = 'The ' + dbo.fnApiSchemaTransformMapField(@guiApiUniqueId, 'Category') + ' "' + vts.strCategory + '" does not exist.'
	, strAction = 'Skipped'
FROM tblApiSchemaTransformCategoryLocation vts
LEFT JOIN tblICCategory c ON c.strCategoryCode = vts.strCategory 
	OR c.strDescription = vts.strCategory
WHERE vts.guiApiUniqueId = @guiApiUniqueId
	AND c.intCategoryId IS NULL

INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage, strAction)
SELECT
	  NEWID()
	, guiApiImportLogId = @guiLogId
	, strField = dbo.fnApiSchemaTransformMapField(@guiApiUniqueId, 'Location Name') 
	, strValue = vts.strLocationName
	, strLogLevel = 'Error'
	, strStatus = 'Failed'
	, intRowNo = vts.intRowNumber
	, strMessage = 'The ' + dbo.fnApiSchemaTransformMapField(@guiApiUniqueId, 'Location Name') + ' "' + vts.strLocationName + '" does not exist.'
	, strAction = 'Skipped'
FROM tblApiSchemaTransformCategoryLocation vts
LEFT JOIN vyuSMGetCompanyLocationSearchList c ON c.strLocationName = vts.strLocationName
WHERE vts.guiApiUniqueId = @guiApiUniqueId
	AND c.intCompanyLocationId IS NULL

INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage, strAction)
SELECT
	  NEWID()
	, guiApiImportLogId = @guiLogId
	, strField = dbo.fnApiSchemaTransformMapField(@guiApiUniqueId, 'Default Family') 
	, strValue = vts.strDefaultFamily
	, strLogLevel = 'Warning'
	, strStatus = 'Failed'
	, intRowNo = vts.intRowNumber
	, strMessage = 'The ' + dbo.fnApiSchemaTransformMapField(@guiApiUniqueId, 'Default Family') + ' "' + vts.strDefaultFamily + '" does not exist.'
	, strAction = 'Skipped'
FROM tblApiSchemaTransformCategoryLocation vts
LEFT JOIN tblSTSubcategory s ON s.strSubcategoryId  = vts.strDefaultFamily 
	AND s.strSubcategoryType = 'F'
WHERE vts.guiApiUniqueId = @guiApiUniqueId
	AND s.intSubcategoryId IS NULL
	AND NULLIF(vts.strDefaultFamily, '') IS NOT NULL

INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage, strAction)
SELECT
	  NEWID()
	, guiApiImportLogId = @guiLogId
	, strField = dbo.fnApiSchemaTransformMapField(@guiApiUniqueId, 'Default Class') 
	, strValue = vts.strDefaultClass
	, strLogLevel = 'Warning'
	, strStatus = 'Failed'
	, intRowNo = vts.intRowNumber
	, strMessage = 'The ' + dbo.fnApiSchemaTransformMapField(@guiApiUniqueId, 'Default Class') + ' "' + vts.strDefaultClass + '" does not exist.'
	, strAction = 'Skipped'
FROM tblApiSchemaTransformCategoryLocation vts
LEFT JOIN tblSTSubcategory s ON s.strSubcategoryId  = vts.strDefaultClass 
	AND s.strSubcategoryType = 'C'
WHERE vts.guiApiUniqueId = @guiApiUniqueId
	AND s.intSubcategoryId IS NULL
	AND NULLIF(vts.strDefaultClass, '') IS NOT NULL

INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage, strAction)
SELECT
	  NEWID()
	, guiApiImportLogId = @guiLogId
	, strField = dbo.fnApiSchemaTransformMapField(@guiApiUniqueId, 'General Item') 
	, strValue = vts.strGeneralItem
	, strLogLevel = 'Warning'
	, strStatus = 'Failed'
	, intRowNo = vts.intRowNumber
	, strMessage = 'The ' + dbo.fnApiSchemaTransformMapField(@guiApiUniqueId, 'General Item') + ' "' + vts.strGeneralItem + '" does not exist or is not valid for the category "' + c.strCategoryCode + '".'
	, strAction = 'Skipped'
FROM tblApiSchemaTransformCategoryLocation vts
JOIN tblICCategory c ON c.strCategoryCode = vts.strCategory OR c.strDescription = vts.strCategory
LEFT JOIN tblICItem i ON (i.strItemNo = vts.strGeneralItem OR i.strDescription = vts.strGeneralItem) AND i.intCategoryId = c.intCategoryId
WHERE vts.guiApiUniqueId = @guiApiUniqueId
	AND i.intItemId IS NULL
	AND NULLIF(vts.strGeneralItem, '') IS NOT NULL

INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage, strAction)
SELECT
	  NEWID()
	, guiApiImportLogId = @guiLogId
	, strField = dbo.fnApiSchemaTransformMapField(@guiApiUniqueId, 'Default Product Code') 
	, strValue = vts.strDefaultProductCode
	, strLogLevel = 'Warning'
	, strStatus = 'Failed'
	, intRowNo = vts.intRowNumber
	, strMessage = 'The ' + dbo.fnApiSchemaTransformMapField(@guiApiUniqueId, 'Default Product Code') + ' "' + vts.strDefaultProductCode + '" does not exist.'
	, strAction = 'Skipped'
FROM tblApiSchemaTransformCategoryLocation vts
LEFT JOIN tblSTSubcategoryRegProd p ON p.strRegProdCode = vts.strDefaultProductCode
WHERE vts.guiApiUniqueId = @guiApiUniqueId
	AND p.intRegProdId IS NULL
	AND NULLIF(vts.strDefaultProductCode, '') IS NOT NULL


-- Remove duplicate location from file
;WITH cte AS
(
   SELECT *, ROW_NUMBER() OVER(PARTITION BY sr.strCategory, sr.strLocationName ORDER BY sr.strCategory, sr.strLocationName) AS RowNumber
   FROM tblApiSchemaTransformCategoryLocation sr
   WHERE sr.guiApiUniqueId = @guiApiUniqueId
)
INSERT INTO tblApiImportLogDetail(guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage, strAction)
SELECT
      NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = dbo.fnApiSchemaTransformMapField(@guiApiUniqueId, 'Location Name') 
    , strValue = sr.strLocationName
    , strLogLevel = 'Error'
    , strStatus = 'Failed'
    , intRowNo = sr.intRowNumber
    , strMessage = 'The category location ' + sr.strLocationName + ' has duplicates in the file.'
    , strAction = 'Skipped'
FROM cte sr
WHERE sr.guiApiUniqueId = @guiApiUniqueId
  AND sr.RowNumber > 1

;WITH cte AS
(
   SELECT *, ROW_NUMBER() OVER(PARTITION BY sr.strCategory, sr.strLocationName ORDER BY sr.strCategory, sr.strLocationName) AS RowNumber
   FROM tblApiSchemaTransformCategoryLocation sr
   WHERE sr.guiApiUniqueId = @guiApiUniqueId
)
DELETE FROM cte
WHERE guiApiUniqueId = @guiApiUniqueId
  AND RowNumber > 1

INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage, strAction)
SELECT
	  NEWID()
	, guiApiImportLogId = @guiLogId
	, strField = dbo.fnApiSchemaTransformMapField(@guiApiUniqueId, 'Location Name') 
	, strValue = vts.strLocationName
	, strLogLevel = 'Error'
	, strStatus = 'Failed'
	, intRowNo = vts.intRowNumber
	, strMessage = 'The category location "' + vts.strLocationName + '" already exists.'
	, strAction = 'Skipped'
FROM tblICCategoryLocation cl
JOIN tblICCategory c ON c.intCategoryId = cl.intCategoryId
JOIN vyuSMGetCompanyLocationSearchList l ON l.intCompanyLocationId = cl.intLocationId
JOIN tblApiSchemaTransformCategoryLocation vts ON (vts.strCategory = c.strCategoryCode OR vts.strCategory = c.strDescription)
	AND vts.strLocationName = l.strLocationName
WHERE vts.guiApiUniqueId = @guiApiUniqueId
	AND @OverwriteExisting = 0

UPDATE cl
SET
	  cl.intClassId = sc.intSubcategoryId
	, cl.intFamilyId = sf.intSubcategoryId
	, cl.intGeneralItemId = i.intItemId
	, cl.intProductCodeId = pc.intRegProdId
	, cl.intConvertPaidOutId = vts.intConverttoPaidout
	, cl.intMinimumAge = vts.intDefaultMinimumAge
	, cl.intNucleusGroupId = vts.intDefaultNucleusGroupID
	, cl.dblCostInventoryBOM = vts.dblCostofInventoryatBOM
	, cl.dblHighGrossMarginAlert = vts.dblHighGrossMarginAlert
	, cl.dblLowGrossMarginAlert = vts.dblLowGrossMarginAlert
	, cl.dblTargetGrossProfit = vts.dblTargetGrossProfit
	, cl.dblTargetInventoryCost = vts.dblTargetInventoryAtCost
	, cl.ysnBlueLaw1 = ISNULL(vts.ysnDefaultBlueLaw1, 0)
	, cl.ysnBlueLaw2 = ISNULL(vts.ysnDefaultBlueLaw2, 0)
	, cl.ysnDeleteFromRegister = ISNULL(vts.ysnDeletefromRegister, 0)
	, cl.ysnDeptKeyTaxed = ISNULL(vts.ysnDepartmentKeyTaxed, 0)
	, cl.ysnFoodStampable = ISNULL(vts.ysnDefaultFoodStampable, 0)
	, cl.ysnIdRequiredCigarette = ISNULL(vts.ysnDefaultIDRequiredCigarette, 0)
	, cl.ysnIdRequiredLiquor = ISNULL(vts.ysnDefaultIDRequiredLiquor, 0)
	, cl.ysnNonRetailUseDepartment = ISNULL(vts.ysnNonRetailUseDepartment, 0)
	, cl.ysnPrePriced = ISNULL(vts.ysnDefaultPrePriced, 0)
	, cl.ysnReportNetGross = ISNULL(vts.ysnReportNetGross, 0)
	, cl.ysnReturnable = ISNULL(vts.ysnReturnable, 0)
	, cl.ysnSaleable = ISNULL(vts.ysnSaleable, 0)
	, cl.ysnUpdatePrices = ISNULL(vts.ysnUpdatePrices, 0)
	, cl.ysnUseTaxFlag1 = ISNULL(vts.ysnDefaultUseTaxFlag1, 0)
	, cl.ysnUseTaxFlag2 = ISNULL(vts.ysnDefaultUseTaxFlag2, 0)
	, cl.ysnUseTaxFlag3 = ISNULL(vts.ysnDefaultUseTaxFlag3, 0)
	, cl.ysnUseTaxFlag4 = ISNULL(vts.ysnDefaultUseTaxFlag4, 0)
	, cl.strCashRegisterDepartment = vts.strCashRegisterDepartment
	, cl.dtmLastInventoryLevelEntry = vts.dtmLastInventoryLevelEntry
	, cl.dtmDateModified = GETUTCDATE()
	, cl.intConcurrencyId = ISNULL(cl.intConcurrencyId, 0) + 1
	, cl.intRowNumber = vts.intRowNumber
	, cl.guiApiUniqueId = @guiApiUniqueId
FROM tblICCategoryLocation cl
JOIN tblICCategory c ON c.intCategoryId = cl.intCategoryId
JOIN vyuSMGetCompanyLocationSearchList l ON l.intCompanyLocationId = cl.intLocationId
JOIN tblApiSchemaTransformCategoryLocation vts ON (vts.strCategory = c.strCategoryCode OR vts.strCategory = c.strDescription)
	AND vts.strLocationName = l.strLocationName
LEFT JOIN tblSTSubcategory sc ON sc.strSubcategoryId  = vts.strDefaultClass AND sc.strSubcategoryType = 'C'
LEFT JOIN tblSTSubcategory sf ON sf.strSubcategoryId  = vts.strDefaultFamily AND sf.strSubcategoryType = 'F'
LEFT JOIN tblICItem i ON (i.strItemNo = vts.strGeneralItem OR i.strDescription = vts.strGeneralItem)
	AND i.intCategoryId = c.intCategoryId
LEFT JOIN tblSTSubcategoryRegProd pc ON pc.strRegProdCode = vts.strDefaultProductCode
WHERE vts.guiApiUniqueId = @guiApiUniqueId
	AND @OverwriteExisting = 1

INSERT INTO tblICCategoryLocation (
	  intCategoryId
	, intLocationId
	, intClassId
	, intFamilyId
	, intGeneralItemId
	, intProductCodeId
	, intConvertPaidOutId
	, intMinimumAge
	, intNucleusGroupId
	, dblCostInventoryBOM
	, dblHighGrossMarginAlert
	, dblLowGrossMarginAlert
	, dblTargetGrossProfit
	, dblTargetInventoryCost
	, ysnBlueLaw1
	, ysnBlueLaw2
	, ysnDeleteFromRegister
	, ysnDeptKeyTaxed
	, ysnFoodStampable
	, ysnIdRequiredCigarette
	, ysnIdRequiredLiquor
	, ysnNonRetailUseDepartment
	, ysnPrePriced
	, ysnReportNetGross
	, ysnReturnable
	, ysnSaleable
	, ysnUpdatePrices
	, ysnUseTaxFlag1
	, ysnUseTaxFlag2
	, ysnUseTaxFlag3
	, ysnUseTaxFlag4
	, strCashRegisterDepartment
	, dtmLastInventoryLevelEntry
	, dtmDateCreated
	, intConcurrencyId
	, intRowNumber
	, guiApiUniqueId
)
SELECT
	  c.intCategoryId
	, l.intCompanyLocationId
	, sc.intSubcategoryId
	, sf.intSubcategoryId
	, i.intItemId
	, pc.intRegProdId
	, vts.intConverttoPaidout
	, vts.intDefaultMinimumAge
	, vts.intDefaultNucleusGroupID
	, vts.dblCostofInventoryatBOM
	, vts.dblHighGrossMarginAlert
	, vts.dblLowGrossMarginAlert
	, vts.dblTargetGrossProfit
	, vts.dblTargetInventoryAtCost
	, ISNULL(vts.ysnDefaultBlueLaw1, 0)
	, ISNULL(vts.ysnDefaultBlueLaw2, 0)
	, ISNULL(vts.ysnDeletefromRegister, 0)
	, ISNULL(vts.ysnDepartmentKeyTaxed, 0)
	, ISNULL(vts.ysnDefaultFoodStampable, 0)
	, ISNULL(vts.ysnDefaultIDRequiredCigarette, 0)
	, ISNULL(vts.ysnDefaultIDRequiredLiquor, 0)
	, ISNULL(vts.ysnNonRetailUseDepartment, 0)
	, ISNULL(vts.ysnDefaultPrePriced, 0)
	, ISNULL(vts.ysnReportNetGross, 0)
	, ISNULL(vts.ysnReturnable, 0)
	, ISNULL(vts.ysnSaleable, 0)
	, ISNULL(vts.ysnUpdatePrices, 0)
	, ISNULL(vts.ysnDefaultUseTaxFlag1, 0)
	, ISNULL(vts.ysnDefaultUseTaxFlag2, 0)
	, ISNULL(vts.ysnDefaultUseTaxFlag3, 0)
	, ISNULL(vts.ysnDefaultUseTaxFlag4, 0)
	, ISNULL(vts.strCashRegisterDepartment, 0)
	, vts.dtmLastInventoryLevelEntry
	, GETUTCDATE()
	, 1
	, vts.intRowNumber
	, @guiApiUniqueId
FROM tblApiSchemaTransformCategoryLocation vts
JOIN tblICCategory c ON c.strCategoryCode = vts.strCategory OR c.strDescription = vts.strCategory
JOIN vyuSMGetCompanyLocationSearchList l ON l.strLocationName = vts.strLocationName
LEFT JOIN tblSTSubcategory sc ON sc.strSubcategoryId  = vts.strDefaultClass AND sc.strSubcategoryType = 'C'
LEFT JOIN tblSTSubcategory sf ON sf.strSubcategoryId  = vts.strDefaultFamily AND sf.strSubcategoryType = 'F'
LEFT JOIN tblICItem i ON (i.strItemNo = vts.strGeneralItem OR i.strDescription = vts.strGeneralItem)
	AND i.intCategoryId = c.intCategoryId
LEFT JOIN tblSTSubcategoryRegProd pc ON pc.strRegProdCode = vts.strDefaultProductCode
WHERE vts.guiApiUniqueId = @guiApiUniqueId
	AND NOT EXISTS (
		SELECT TOP 1 1
		FROM tblICCategoryLocation xx
		WHERE xx.intCategoryId = c.intCategoryId
			AND xx.intLocationId = l.intCompanyLocationId
	)

INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage, strAction)
SELECT
      NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Category Point of Sale'
    , strValue = l.strLocationName
    , strLogLevel = 'Info'
    , strStatus = 'Success'
    , intRowNo = cl.intRowNumber
    , strMessage = 'The Category Point of Sale ' + l.strLocationName + ' for the category ' + c.strCategoryCode + ' was imported successfully.'
    , strAction = 'Created'
FROM tblICCategoryLocation cl
JOIN tblICCategory c ON c.intCategoryId = cl.intCategoryId
JOIN vyuSMGetCompanyLocationSearchList l ON l.intCompanyLocationId = cl.intLocationId
WHERE cl.guiApiUniqueId = @guiApiUniqueId

UPDATE log
SET log.intTotalRowsImported = r.intCount
FROM tblApiImportLog log
CROSS APPLY (
	SELECT COUNT(*) intCount
	FROM tblICCategoryLocation
	WHERE guiApiUniqueId = log.guiApiUniqueId
) r
WHERE log.guiApiImportLogId = @guiLogId