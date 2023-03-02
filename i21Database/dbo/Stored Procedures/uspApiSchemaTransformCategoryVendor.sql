CREATE PROCEDURE uspApiSchemaTransformCategoryVendor
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
FROM tblApiSchemaTransformCategoryVendor vts
LEFT JOIN tblICCategory c ON c.strCategoryCode = vts.strCategory
	OR c.strDescription  = vts.strCategory 
WHERE vts.guiApiUniqueId = @guiApiUniqueId
	AND c.intCategoryId IS NULL

INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage, strAction)
SELECT
	  NEWID()
	, guiApiImportLogId = @guiLogId
	, strField = dbo.fnApiSchemaTransformMapField(@guiApiUniqueId, 'Vendor') 
	, strValue = vts.strVendor
	, strLogLevel = 'Error'
	, strStatus = 'Failed'
	, intRowNo = vts.intRowNumber
	, strMessage = 'The ' + dbo.fnApiSchemaTransformMapField(@guiApiUniqueId, 'Vendor') + ' "' + vts.strVendor + '" does not exist.'
	, strAction = 'Skipped'
FROM tblApiSchemaTransformCategoryVendor vts
LEFT JOIN vyuAPVendor v ON v.strVendorId  = vts.strVendor  
	OR v.strName   = vts.strVendor 
WHERE vts.guiApiUniqueId = @guiApiUniqueId
	AND v.intEntityId IS NULL

INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage, strAction)
SELECT
	  NEWID()
	, guiApiImportLogId = @guiLogId
	, strField = dbo.fnApiSchemaTransformMapField(@guiApiUniqueId, 'Location') 
	, strValue = vts.strLocation
	, strLogLevel = 'Warning'
	, strStatus = 'Failed'
	, intRowNo = vts.intRowNumber
	, strMessage = 'The ' + dbo.fnApiSchemaTransformMapField(@guiApiUniqueId, 'Location') + ' "' + vts.strLocation + '" does not exist.'
	, strAction = 'Skipped'
FROM tblApiSchemaTransformCategoryVendor vts
JOIN tblICCategory c ON c.strCategoryCode  = vts.strCategory 
	OR c.strDescription  = vts.strCategory 
LEFT JOIN tblSMCompanyLocation l ON l.strLocationNumber  = vts.strLocation 
	OR l.strLocationName  = vts.strLocation 
LEFT JOIN tblICCategoryLocation cl ON cl.intCategoryId = c.intCategoryId
	AND cl.intLocationId = l.intCompanyLocationId
WHERE vts.guiApiUniqueId = @guiApiUniqueId
	AND cl.intCategoryLocationId IS NULL
	AND NULLIF(vts.strLocation, '') IS NOT NULL

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
FROM tblApiSchemaTransformCategoryVendor vts
LEFT JOIN tblSTSubcategory s ON s.strSubcategoryId  = vts.strDefaultFamily 
	AND s.strSubcategoryType = 'F'
WHERE vts.guiApiUniqueId = @guiApiUniqueId
	AND s.intSubcategoryId IS NULL
	AND NULLIF(vts.strDefaultFamily, '') IS NOT NULL

INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage, strAction)
SELECT
	  NEWID()
	, guiApiImportLogId = @guiLogId
	, strField = dbo.fnApiSchemaTransformMapField(@guiApiUniqueId, 'Default Sell Class') 
	, strValue = vts.strDefaultSellClass
	, strLogLevel = 'Warning'
	, strStatus = 'Failed'
	, intRowNo = vts.intRowNumber
	, strMessage = 'The ' + dbo.fnApiSchemaTransformMapField(@guiApiUniqueId, 'Default Sell Class') + ' "' + vts.strDefaultSellClass + '" does not exist.'
	, strAction = 'Skipped'
FROM tblApiSchemaTransformCategoryVendor vts
LEFT JOIN tblSTSubcategory s ON s.strSubcategoryId  = vts.strDefaultSellClass 
	AND s.strSubcategoryType = 'C'
WHERE vts.guiApiUniqueId = @guiApiUniqueId
	AND s.intSubcategoryId IS NULL
	AND NULLIF(vts.strDefaultSellClass, '') IS NOT NULL

INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage, strAction)
SELECT
	  NEWID()
	, guiApiImportLogId = @guiLogId
	, strField = dbo.fnApiSchemaTransformMapField(@guiApiUniqueId, 'Default Order Class') 
	, strValue = vts.strDefaultOrderClass
	, strLogLevel = 'Warning'
	, strStatus = 'Failed'
	, intRowNo = vts.intRowNumber
	, strMessage = 'The ' + dbo.fnApiSchemaTransformMapField(@guiApiUniqueId, 'Default Order Class') + ' "' + vts.strDefaultOrderClass + '" does not exist.'
	, strAction = 'Skipped'
FROM tblApiSchemaTransformCategoryVendor vts
LEFT JOIN tblSTSubcategory s ON s.strSubcategoryId  = vts.strDefaultOrderClass 
	AND s.strSubcategoryType = 'C'
WHERE vts.guiApiUniqueId = @guiApiUniqueId
	AND s.intSubcategoryId IS NULL
	AND NULLIF(vts.strDefaultOrderClass, '') IS NOT NULL


Update cv
SET
	cv.intCategoryLocationId = cl.intCategoryLocationId,
	cv.intVendorId = v.intEntityId,
	cv.strVendorDepartment  = vts.strVendorCategory,
	cv.ysnAddOrderingUPC = vts.ysnAddOrderingUPCtoPricebook,
	cv.ysnUpdateExistingRecords = vts.ysnUpdateExistingRecords,
	cv.ysnAddNewRecords = vts.ysnAddNewRecords,
	cv.ysnUpdatePrice = vts.ysnUpdatePrice,
	cv.intFamilyId = f.intSubcategoryId,
	cv.intSellClassId = sc.intSubcategoryId,
	cv.intOrderClassId = oc.intSubcategoryId,
	cv.strComments = vts.strComments
FROM tblICCategoryVendor cv
JOIN tblICCategory c ON c.intCategoryId = cv.intCategoryId
JOIN tblApiSchemaTransformCategoryVendor vts ON (vts.strCategory = c.strCategoryCode OR vts.strCategory = c.strDescription)
JOIN vyuAPVendor v ON v.strVendorId  = vts.strVendor  
	OR v.strName  = vts.strVendor
LEFT JOIN tblSMCompanyLocation l ON l.strLocationNumber  = vts.strLocation 
	OR l.strLocationName  = vts.strLocation 
LEFT JOIN tblICCategoryLocation cl ON cl.intCategoryId = c.intCategoryId
	AND cl.intLocationId = l.intCompanyLocationId
LEFT JOIN tblSTSubcategory f ON f.strSubcategoryId  = vts.strDefaultFamily
	AND f.strSubcategoryType = 'F'
LEFT JOIN tblSTSubcategory sc ON sc.strSubcategoryId  = vts.strDefaultSellClass
	AND sc.strSubcategoryType = 'C'
LEFT JOIN tblSTSubcategory oc ON oc.strSubcategoryId  = vts.strDefaultOrderClass
	AND oc.strSubcategoryType = 'C'
WHERE vts.guiApiUniqueId = @guiApiUniqueId
AND @OverwriteExisting = 1


INSERT INTO tblICCategoryVendor (
	  intCategoryId
	, intVendorId
	, intCategoryLocationId
	, intFamilyId
	, intSellClassId
	, intOrderClassId
	, ysnAddNewRecords
	, ysnAddOrderingUPC
	, ysnUpdateExistingRecords
	, ysnUpdatePrice
	, strVendorDepartment
	, strComments
	, dtmDateCreated
	, intConcurrencyId
	, intRowNumber
	, guiApiUniqueId
)
SELECT
	  c.intCategoryId
	, v.intEntityId
	, cl.intCategoryLocationId
	, f.intSubcategoryId
	, sc.intSubcategoryId
	, oc.intSubcategoryId
	, vts.ysnAddNewRecords
	, vts.ysnAddOrderingUPCtoPricebook
	, vts.ysnUpdateExistingRecords
	, vts.ysnUpdatePrice
	, vts.strVendorCategory
	, vts.strComments
	, GETUTCDATE()
	, 1
	, vts.intRowNumber
	, @guiApiUniqueId
FROM tblApiSchemaTransformCategoryVendor vts
JOIN tblICCategory c ON c.strCategoryCode  = vts.strCategory 
	OR c.strDescription  = vts.strCategory 
JOIN vyuAPVendor v ON v.strVendorId  = vts.strVendor  
	OR v.strName  = vts.strVendor 
LEFT JOIN tblSMCompanyLocation l ON l.strLocationNumber  = vts.strLocation 
	OR l.strLocationName  = vts.strLocation 
LEFT JOIN tblICCategoryLocation cl ON cl.intCategoryId = c.intCategoryId
	AND cl.intLocationId = l.intCompanyLocationId
LEFT JOIN tblSTSubcategory f ON f.strSubcategoryId  = vts.strDefaultFamily
	AND f.strSubcategoryType = 'F'
LEFT JOIN tblSTSubcategory sc ON sc.strSubcategoryId  = vts.strDefaultSellClass
	AND sc.strSubcategoryType = 'C'
LEFT JOIN tblSTSubcategory oc ON oc.strSubcategoryId  = vts.strDefaultOrderClass
	AND oc.strSubcategoryType = 'C'
WHERE vts.guiApiUniqueId = @guiApiUniqueId
AND NOT EXISTS (
		SELECT TOP 1 1
		FROM tblICCategoryVendor xx
		WHERE xx.intCategoryId = c.intCategoryId
			AND xx.intCategoryLocationId = cl.intCategoryLocationId
			AND xx.intVendorId = v.intEntityId
	)


INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage, strAction)
SELECT
      NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Category Xref'
    , strValue = v.strName
    , strLogLevel = 'Info'
    , strStatus = 'Success'
    , intRowNo = cv.intRowNumber
    , strMessage = 'The vendor category xref ' + v.strName + ' for the category ' + c.strCategoryCode + ' was imported successfully.'
    , strAction = 'Created'
FROM tblICCategoryVendor cv
JOIN tblICCategory c ON c.intCategoryId = cv.intCategoryId
JOIN vyuAPVendor v ON v.intEntityId = cv.intVendorId
WHERE cv.guiApiUniqueId = @guiApiUniqueId


UPDATE log
SET log.intTotalRowsImported = r.intCount
FROM tblApiImportLog log
CROSS APPLY (
	SELECT COUNT(*) intCount
	FROM tblICCategoryVendor
	WHERE guiApiUniqueId = log.guiApiUniqueId
) r
WHERE log.guiApiImportLogId = @guiLogId