CREATE PROCEDURE uspApiSchemaTransformVendorSetup 
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

-- Remove duplicate vendor from file
-- ;WITH cte AS
-- (
--    SELECT *, ROW_NUMBER() OVER(PARTITION BY sr.strVendor ORDER BY sr.strVendor) AS RowNumber
--    FROM tblApiSchemaTransformVendorSetup sr
--    WHERE sr.guiApiUniqueId = @guiApiUniqueId
-- )
-- INSERT INTO tblApiImportLogDetail(guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage, strAction)
-- SELECT
--       NEWID()
--     , guiApiImportLogId = @guiLogId
--     , strField = 'Vendor'
--     , strValue = sr.strVendor
--     , strLogLevel = 'Error'
--     , strStatus = 'Failed'
--     , intRowNo = sr.intRowNumber
--     , strMessage = 'The vendor ' + sr.strVendor + ' has duplicates in the file.'
--     , strAction = 'Skipped'
-- FROM cte sr
-- WHERE sr.guiApiUniqueId = @guiApiUniqueId
--   AND sr.RowNumber > 1

-- ;WITH cte AS
-- (
--    SELECT *, ROW_NUMBER() OVER(PARTITION BY sr.strVendor ORDER BY sr.strVendor) AS RowNumber
--    FROM tblApiSchemaTransformVendorSetup sr
--    WHERE sr.guiApiUniqueId = @guiApiUniqueId
-- )
-- DELETE FROM cte
-- WHERE guiApiUniqueId = @guiApiUniqueId
--   AND RowNumber > 1

INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage, strAction)
SELECT
	  NEWID()
	, guiApiImportLogId = @guiLogId
	, strField = dbo.fnApiSchemaTransformMapField(@guiApiUniqueId, 'Vendor') 
	, strValue = vts.strVendor
	, strLogLevel = 'Error'
	, strStatus = 'Failed'
	, intRowNo = vts.intRowNumber
	, strMessage = 'The vendor "' + vts.strVendor + '" does not exist.'
	, strAction = 'Skipped'
FROM tblApiSchemaTransformVendorSetup vts
LEFT JOIN vyuAPVendor v ON v.strVendorId = vts.strVendor OR v.strName = vts.strVendor
WHERE vts.guiApiUniqueId = @guiApiUniqueId
	AND v.intEntityId IS NULL

INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage, strAction)
SELECT
	  NEWID()
	, guiApiImportLogId = @guiLogId
	, strField = dbo.fnApiSchemaTransformMapField(@guiApiUniqueId, 'Customer No') 
	, strValue = vts.strCustomer
	, strLogLevel = 'Error'
	, strStatus = 'Failed'
	, intRowNo = vts.intRowNumber
	, strMessage = 'The customer "' + vts.strCustomer + '" does not exist.'
	, strAction = 'Skipped'
FROM tblApiSchemaTransformVendorSetup vts
LEFT JOIN vyuARCustomer c ON c.strCustomerNumber = vts.strCustomer
WHERE vts.guiApiUniqueId = @guiApiUniqueId
	AND c.intEntityId IS NULL
	AND NULLIF(vts.strCustomer, '') IS NOT NULL

INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage, strAction)
SELECT
	  NEWID()
	, guiApiImportLogId = @guiLogId
	, strField = dbo.fnApiSchemaTransformMapField(@guiApiUniqueId, 'Customer Name') 
	, strValue = vts.strCustomerName
	, strLogLevel = 'Error'
	, strStatus = 'Failed'
	, intRowNo = vts.intRowNumber
	, strMessage = 'The customer "' + vts.strCustomerName + '" does not exist.'
	, strAction = 'Skipped'
FROM tblApiSchemaTransformVendorSetup vts
LEFT JOIN vyuARCustomer c ON c.strName = vts.strCustomerName
WHERE vts.guiApiUniqueId = @guiApiUniqueId
	AND c.intEntityId IS NULL
	AND NULLIF(vts.strCustomer, '') IS NULL
	AND NULLIF(vts.strCustomerName, '') IS NOT NULL

INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage, strAction)
SELECT
	  NEWID()
	, guiApiImportLogId = @guiLogId
	, strField = dbo.fnApiSchemaTransformMapField(@guiApiUniqueId, 'Vendor''s Customer') 
	, strValue = vts.strVendorCustomer
	, strLogLevel = 'Error'
	, strStatus = 'Failed'
	, intRowNo = vts.intRowNumber
	, strMessage = 'The vendor''s customer "' + vts.strVendorCustomer + '" already exists.'
	, strAction = 'Skipped'
FROM tblApiSchemaTransformVendorSetup vts
JOIN vyuAPVendor v ON v.strVendorId = vts.strVendor OR v.strName = vts.strVendor
JOIN tblVRVendorSetup vs ON vs.intEntityId = v.intEntityId
JOIN vyuARCustomer c ON c.strCustomerNumber = vts.strCustomer
WHERE vts.guiApiUniqueId = @guiApiUniqueId
	AND NULLIF(vts.strCustomer, '') IS NOT NULL
	AND EXISTS (
		SELECT TOP 1 1
		FROM tblVRCustomerXref xx
		WHERE xx.intVendorSetupId = vs.intVendorSetupId
			AND xx.intEntityId = c.intEntityId
			AND xx.strVendorCustomer = vts.strVendorCustomer
	)
	AND @OverwriteExisting = 0

INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage, strAction)
SELECT
	  NEWID()
	, guiApiImportLogId = @guiLogId
	, strField = dbo.fnApiSchemaTransformMapField(@guiApiUniqueId, 'Category') 
	, strValue = vts.strCategory
	, strLogLevel = 'Error'
	, strStatus = 'Failed'
	, intRowNo = vts.intRowNumber
	, strMessage = 'The category "' + vts.strCategory + '" does not exist.'
	, strAction = 'Skipped'
FROM tblApiSchemaTransformVendorSetup vts
LEFT JOIN tblICCategory c ON c.strCategoryCode = vts.strCategory OR c.strDescription = vts.strCategory
WHERE vts.guiApiUniqueId = @guiApiUniqueId
	AND c.intCategoryId IS NULL
	AND NULLIF(vts.strCategory, '') IS NOT NULL

INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage, strAction)
SELECT
	  NEWID()
	, guiApiImportLogId = @guiLogId
	, strField = dbo.fnApiSchemaTransformMapField(@guiApiUniqueId, 'Vendor''s Category') 
	, strValue = vts.strVendorCategory
	, strLogLevel = 'Error'
	, strStatus = 'Failed'
	, intRowNo = vts.intRowNumber
	, strMessage = 'The vendor''s category "' + vts.strVendorCategory + '" for "' + vts.strCategory + '" already exists.'
	, strAction = 'Skipped'
FROM tblApiSchemaTransformVendorSetup vts
JOIN vyuAPVendor v ON v.strVendorId = vts.strVendor OR v.strName = vts.strVendor
JOIN tblVRVendorSetup vs ON vs.intEntityId = v.intEntityId
JOIN tblICCategory c ON c.strCategoryCode = vts.strCategory
	AND c.strDescription = vts.strCategory
WHERE vts.guiApiUniqueId = @guiApiUniqueId
	AND NULLIF(vts.strCategory, '') IS NOT NULL
	AND EXISTS (
		SELECT TOP 1 1
		FROM tblICCategoryVendor xx
		JOIN tblICCategory xc ON xc.intCategoryId = xx.intCategoryId
		WHERE xx.intVendorSetupId = vs.intVendorSetupId
			AND xx.intCategoryId = c.intCategoryId
			--AND xx.strVendorDepartment = vts.strVendorCategory
	)
	AND @OverwriteExisting = 0

INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage, strAction)
SELECT
	  NEWID()
	, guiApiImportLogId = @guiLogId
	, strField =  dbo.fnApiSchemaTransformMapField(@guiApiUniqueId, 'UOM') 
	, strValue = vts.strUnitMeasure
	, strLogLevel = 'Error'
	, strStatus = 'Failed'
	, intRowNo = vts.intRowNumber
	, strMessage = 'The unit of measure "' + vts.strUnitMeasure + '" does not exist.'
	, strAction = 'Skipped'
FROM tblApiSchemaTransformVendorSetup vts
LEFT JOIN tblICUnitMeasure u ON u.strUnitMeasure = vts.strUnitMeasure
WHERE vts.guiApiUniqueId = @guiApiUniqueId
	AND u.intUnitMeasureId IS NULL
	AND NULLIF(vts.strUnitMeasure, '') IS NOT NULL

INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage, strAction)
SELECT
	  NEWID()
	, guiApiImportLogId = @guiLogId
	, strField = dbo.fnApiSchemaTransformMapField(@guiApiUniqueId, 'UOM') 
	, strValue = vts.strVendorUnitMeasure
	, strLogLevel = 'Error'
	, strStatus = 'Failed'
	, intRowNo = vts.intRowNumber
	, strMessage = 'The unit of measure "' + vts.strVendorUnitMeasure + '" for "' + vts.strUnitMeasure + '" already exists.'
	, strAction = 'Skipped'
FROM tblApiSchemaTransformVendorSetup vts
JOIN vyuAPVendor v ON v.strVendorId = vts.strVendor OR v.strName = vts.strVendor
JOIN tblVRVendorSetup vs ON vs.intEntityId = v.intEntityId
JOIN tblICUnitMeasure u ON u.strUnitMeasure = vts.strUnitMeasure
WHERE vts.guiApiUniqueId = @guiApiUniqueId
	AND NULLIF(vts.strVendorUnitMeasure, '') IS NOT NULL
	AND EXISTS (
		SELECT TOP 1 1
		FROM tblVRUOMXref xref
		WHERE xref.intVendorSetupId = vs.intVendorSetupId
			AND xref.intUnitMeasureId = u.intUnitMeasureId
			-- AND xref.strVendorUOM = vts.strVendorUnitMeasure
	)
	AND @OverwriteExisting = 0

INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage, strAction)
SELECT
	  NEWID()
	, guiApiImportLogId = @guiLogId
	, strField = dbo.fnApiSchemaTransformMapField(@guiApiUniqueId, 'Item No') 
	, strValue = vts.strItemNo
	, strLogLevel = 'Error'
	, strStatus = 'Failed'
	, intRowNo = vts.intRowNumber
	, strMessage = 'The item no. "' + vts.strItemNo + '" does not exist.'
	, strAction = 'Skipped'
FROM tblApiSchemaTransformVendorSetup vts
LEFT JOIN tblICItem i ON i.strItemNo = vts.strItemNo
WHERE vts.guiApiUniqueId = @guiApiUniqueId
	AND i.intItemId IS NULL
	AND NULLIF(vts.strItemNo, '') IS NOT NULL


INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage, strAction)
SELECT
	  NEWID()
	, guiApiImportLogId = @guiLogId
	, strField = dbo.fnApiSchemaTransformMapField(@guiApiUniqueId, 'Item Name')
	, strValue = vts.strItemName
	, strLogLevel = 'Error'
	, strStatus = 'Failed'
	, intRowNo = vts.intRowNumber
	, strMessage = 'The item name "' + vts.strItemName + '" does not exist.'
	, strAction = 'Skipped'
FROM tblApiSchemaTransformVendorSetup vts
LEFT JOIN tblICItem i ON i.strDescription = vts.strItemName
WHERE vts.guiApiUniqueId = @guiApiUniqueId
	AND i.intItemId IS NULL
	AND NULLIF(vts.strItemName, '') IS NOT NULL
	AND NULLIF(vts.strItemNo, '') IS NULL

INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage, strAction)
SELECT
	  NEWID()
	, guiApiImportLogId = @guiLogId
	, strField = dbo.fnApiSchemaTransformMapField(@guiApiUniqueId, 'Vendor''s Item')
	, strValue = vts.strVendorItemNo
	, strLogLevel = 'Error'
	, strStatus = 'Failed'
	, intRowNo = vts.intRowNumber
	, strMessage = 'The Item mapping "' + ISNULL(vts.strVendorItemNo, vts.strItemNo) + '" for "' + ISNULL(vts.strItemNo, '') + '" already exists.'
	, strAction = 'Skipped'
FROM tblApiSchemaTransformVendorSetup vts
JOIN vyuAPVendor v ON v.strVendorId = vts.strVendor OR v.strName = vts.strVendor
JOIN tblVRVendorSetup vs ON vs.intEntityId = v.intEntityId
JOIN tblICItem i ON i.strItemNo = vts.strItemNo OR i.strDescription = i.strItemNo
WHERE vts.guiApiUniqueId = @guiApiUniqueId
	AND NULLIF(vts.strItemNo, '') IS NOT NULL
	AND EXISTS (
		SELECT TOP 1 1
		FROM tblICItemVendorXref xref
		WHERE xref.intVendorSetupId = vs.intVendorSetupId
			AND xref.intItemId = i.intItemId
			--AND xref.strVendorProduct = vts.strVendorItemNo
	)
	AND @OverwriteExisting = 0

-- Existing item
-- INSERT INTO tblApiImportLogDetail(guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
-- SELECT
--       NEWID()
--     , guiApiImportLogId = @guiLogId
--     , strField = 'Rebate Vendor Setup'
--     , strValue = vs.strVendor
--     , strLogLevel = 'Error'
--     , strStatus = 'Failed'
--     , intRowNo = vs.intRowNumber
--     , strMessage = ISNULL(vs.strVendor, '') + ' already exists.'
-- FROM tblApiSchemaTransformVendorSetup vs
-- CROSS APPLY (
--   SELECT TOP 1 1 intCount
--   FROM tblAPVendor v
--   WHERE v.strVendorId = vs.strVendor
-- ) ex
-- WHERE vs.guiApiUniqueId = @guiApiUniqueId
--   AND @OverwriteExisting = 0

DECLARE @UniqueSetups TABLE (
	  intEntityId INT
	, strExportFileType NVARCHAR(3) COLLATE Latin1_General_CI_AS NULL
	, strExportFilePath NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
	, strCompany1Id NVARCHAR(300) COLLATE Latin1_General_CI_AS NULL
	, strCompany2Id NVARCHAR(300) COLLATE Latin1_General_CI_AS NULL
	, intConcurrencyId INT
	, guiApiUniqueId UNIQUEIDENTIFIER
	, intRowNumber INT
)

INSERT INTO @UniqueSetups (
	  intEntityId
	, strExportFileType
	, strExportFilePath
	, strCompany1Id
	, strCompany2Id
	, intConcurrencyId
	, guiApiUniqueId
	, intRowNumber
)
SELECT
	  v.intEntityId
	, vs.strExportFileType
	, vs.strExportFilePath
	, vs.strCompany1Id
	, vs.strCompany2Id
	, 1
	, @guiApiUniqueId
	, vs.intRowNumber
FROM tblApiSchemaTransformVendorSetup vs
JOIN vyuAPVendor v ON v.strVendorId = vs.strVendor OR v.strName = vs.strVendor
WHERE vs.guiApiUniqueId = @guiApiUniqueId
  AND NOT EXISTS (
    SELECT TOP 1 1
    FROM tblApiImportLogDetail d
    WHERE d.guiApiImportLogId = @guiLogId
      AND d.intRowNo = vs.intRowNumber
      AND d.strLogLevel = 'Error'
  )
  AND NOT EXISTS(
    SELECT TOP 1 1 
    FROM tblVRVendorSetup xvs
	WHERE xvs.intEntityId = v.intEntityId
  )

;WITH cte AS
(
   SELECT *, ROW_NUMBER() OVER(PARTITION BY sr.intEntityId ORDER BY sr.intEntityId) AS RowNumber
   FROM @UniqueSetups sr
   WHERE sr.guiApiUniqueId = @guiApiUniqueId
)
DELETE FROM cte
WHERE guiApiUniqueId = @guiApiUniqueId
  AND RowNumber > 1

INSERT INTO tblVRVendorSetup (
	  intEntityId
	, strExportFileType
	, strExportFilePath
	, strCompany1Id
	, strCompany2Id
	, intConcurrencyId
	, guiApiUniqueId
	, intRowNumber
)
SELECT * 
FROM @UniqueSetups vs
WHERE NOT EXISTS(
    SELECT TOP 1 1 
    FROM tblVRVendorSetup xvs
	JOIN tblAPVendor xv ON xv.intEntityId = xvs.intEntityId
		AND vs.intEntityId = xv.intEntityId
  )

-- Flag setup for modifications
DECLARE @ForUpdates TABLE (strVendorNumber NVARCHAR(400) COLLATE Latin1_General_CI_AS, intRowNumber INT NULL)
INSERT INTO @ForUpdates
SELECT v.strVendorId, vs.intRowNumber
FROM tblApiSchemaTransformVendorSetup vs
JOIN vyuAPVendor v ON v.strVendorId = vs.strVendor OR v.strName = vs.strVendor
JOIN tblVRVendorSetup e ON e.intEntityId = v.intEntityId 
WHERE vs.guiApiUniqueId = @guiApiUniqueId
	AND @OverwriteExisting = 1

UPDATE vs
SET 
	  vs.guiApiUniqueId = @guiApiUniqueId
	, vs.intRowNumber = sr.intRowNumber
	, vs.strExportFilePath = CASE dbo.fnApiSchemaTransformHasField(@guiApiUniqueId, 'Export File Path') WHEN 1 THEN sr.strExportFilePath ELSE vs.strExportFilePath END
	, vs.strExportFileType = CASE dbo.fnApiSchemaTransformHasField(@guiApiUniqueId, 'Export File Type') WHEN 1 THEN sr.strExportFileType ELSE vs.strExportFileType END
	, vs.strCompany1Id = CASE dbo.fnApiSchemaTransformHasField(@guiApiUniqueId, 'Company ID1') WHEN 1 THEN sr.strCompany1Id ELSE vs.strCompany1Id END
	, vs.strCompany2Id = CASE dbo.fnApiSchemaTransformHasField(@guiApiUniqueId, 'Company ID2') WHEN 1 THEN sr.strCompany2Id ELSE vs.strCompany2Id END
	, vs.intConcurrencyId = ISNULL(vs.intConcurrencyId, 1) + 1
FROM tblVRVendorSetup vs
JOIN vyuAPVendor v ON v.intEntityId = vs.intEntityId
JOIN tblApiSchemaTransformVendorSetup sr ON sr.strVendor = v.strVendorId OR sr.strVendor = v.strName
WHERE sr.guiApiUniqueId = @guiApiUniqueId
	AND NOT EXISTS (
		SELECT TOP 1 1
		FROM tblApiImportLogDetail d
		WHERE d.guiApiImportLogId = @guiLogId
		AND d.intRowNo = sr.intRowNumber
		AND d.strLogLevel = 'Error'
		AND d.ysnPreventRowUpdate = 1
	)
	AND @OverwriteExisting = 1


DECLARE @CustomerForUpdates TABLE (intVendorSetupId INT, intEntityId INT, strVendorCustomer NVARCHAR(400) COLLATE Latin1_General_CI_AS, intRowNumber INT NULL)
INSERT INTO @CustomerForUpdates
SELECT e.intVendorSetupId, xc.intEntityId, xc.strVendorCustomer, vs.intRowNumber
FROM tblApiSchemaTransformVendorSetup vs
JOIN vyuAPVendor v ON v.strVendorId = vs.strVendor OR v.strName = vs.strVendor
JOIN tblVRVendorSetup e ON e.intEntityId = v.intEntityId
JOIN vyuARCustomer c ON c.strCustomerNumber = vs.strCustomer
JOIN tblVRCustomerXref xc ON xc.intVendorSetupId = e.intVendorSetupId
	AND xc.intEntityId = c.intEntityId
	AND xc.strVendorCustomer = vs.strVendorCustomer
WHERE vs.guiApiUniqueId = @guiApiUniqueId
	AND @OverwriteExisting = 1

INSERT INTO @CustomerForUpdates
SELECT e.intVendorSetupId, xc.intEntityId, xc.strVendorCustomer, vs.intRowNumber
FROM tblApiSchemaTransformVendorSetup vs
JOIN vyuAPVendor v ON v.strVendorId = vs.strVendor OR v.strName = vs.strVendor
JOIN tblVRVendorSetup e ON e.intEntityId = v.intEntityId
JOIN tblEMEntity en ON en.strName = vs.strCustomerName
JOIN vyuARCustomer c ON c.intEntityId = en.intEntityId
JOIN tblVRCustomerXref xc ON xc.intVendorSetupId = e.intVendorSetupId
	AND xc.intEntityId = c.intEntityId
	AND xc.strVendorCustomer = vs.strVendorCustomer
WHERE vs.guiApiUniqueId = @guiApiUniqueId
	AND NULLIF(vs.strCustomer, '') IS NULL
	AND NULLIF(vs.strCustomerName, '') IS NOT NULL
	AND @OverwriteExisting = 1

UPDATE xc
SET 
	  xc.guiApiUniqueId = @guiApiUniqueId
	, xc.intConcurrencyId = ISNULL(xc.intConcurrencyId, 1) + 1
	, xc.strVendorCustomer = COALESCE(vs.strVendorCustomer, xc.strVendorCustomer)
	, xc.intRowNumber = vs.intRowNumber
FROM tblVRCustomerXref xc
JOIN vyuARCustomer c ON c.intEntityId = xc.intEntityId
JOIN tblApiSchemaTransformVendorSetup vs ON vs.strCustomer = c.strCustomerNumber
	AND vs.strVendorCustomer = xc.strVendorCustomer
JOIN vyuAPVendor v ON v.strVendorId = vs.strVendor OR v.strName = vs.strVendor
JOIN tblVRVendorSetup e ON e.intEntityId = v.intEntityId
WHERE vs.guiApiUniqueId = @guiApiUniqueId
	AND @OverwriteExisting = 1

UPDATE xc
SET 
	  xc.guiApiUniqueId = @guiApiUniqueId
	, xc.intConcurrencyId = ISNULL(xc.intConcurrencyId, 1) + 1
	, xc.strVendorCustomer = COALESCE(vs.strVendorCustomer, xc.strVendorCustomer)
	, xc.intRowNumber = vs.intRowNumber
FROM tblVRCustomerXref xc
JOIN tblEMEntity en ON en.intEntityId = xc.intEntityId
JOIN vyuARCustomer c ON c.intEntityId = xc.intEntityId
JOIN tblApiSchemaTransformVendorSetup vs ON vs.strCustomerName = en.strName
	AND vs.strVendorCustomer = xc.strVendorCustomer
JOIN vyuAPVendor v ON v.strVendorId = vs.strVendor OR v.strName = vs.strVendor
JOIN tblVRVendorSetup e ON e.intEntityId = v.intEntityId
WHERE vs.guiApiUniqueId = @guiApiUniqueId
	AND NULLIF(vs.strCustomer, '') IS NULL
	AND NULLIF(vs.strCustomerName, '') IS NOT NULL
	AND @OverwriteExisting = 1

DECLARE @UniqueCustomers TABLE (
	  intEntityId INT
	, intVendorSetupId INT
	, strVendorCustomer [nvarchar](50) COLLATE Latin1_General_CI_AS
	, guiApiUniqueId UNIQUEIDENTIFIER
	, intRowNumber INT
)

INSERT INTO @UniqueCustomers (
	  intEntityId
	, intVendorSetupId
	, strVendorCustomer
	, guiApiUniqueId
	, intRowNumber
)
SELECT
	  c.intEntityId
	, vs.intVendorSetupId
	, COALESCE(vts.strVendorCustomer, c.strCustomerNumber)
	, @guiApiUniqueId
	, vts.intRowNumber
FROM tblApiSchemaTransformVendorSetup vts
JOIN vyuAPVendor v ON v.strVendorId = vts.strVendor OR v.strName = vts.strVendor
JOIN tblVRVendorSetup vs ON vs.intEntityId = v.intEntityId
JOIN tblARCustomer c ON c.strCustomerNumber = vts.strCustomer
WHERE vts.guiApiUniqueId = @guiApiUniqueId
	AND NOT EXISTS (
		SELECT TOP 1 1
		FROM tblVRCustomerXref xx
		WHERE xx.intVendorSetupId = vs.intVendorSetupId
			AND xx.intEntityId = c.intEntityId 
			AND xx.strVendorCustomer = vts.strVendorCustomer
	)
	AND NULLIF(vts.strCustomer, '') IS NOT NULL

INSERT INTO @UniqueCustomers (
	  intEntityId
	, intVendorSetupId
	, strVendorCustomer
	, guiApiUniqueId
	, intRowNumber
)
SELECT
	  c.intEntityId
	, vs.intVendorSetupId
	, COALESCE(vts.strVendorCustomer, c.strCustomerNumber)
	, @guiApiUniqueId
	, vts.intRowNumber
FROM tblApiSchemaTransformVendorSetup vts
JOIN vyuAPVendor v ON v.strVendorId = vts.strVendor OR v.strName = vts.strVendor
JOIN tblVRVendorSetup vs ON vs.intEntityId = v.intEntityId
JOIN tblEMEntity e ON e.strName = vts.strCustomerName
JOIN tblARCustomer c ON c.intEntityId = e.intEntityId
WHERE vts.guiApiUniqueId = @guiApiUniqueId
	AND NOT EXISTS (
		SELECT TOP 1 1
		FROM tblVRCustomerXref xx
		WHERE xx.intVendorSetupId = vs.intVendorSetupId
			AND xx.intEntityId = c.intEntityId
			AND xx.strVendorCustomer = vts.strVendorCustomer
	)
	AND NULLIF(vts.strCustomer, '') IS NULL
	AND NULLIF(vts.strCustomerName, '') IS NOT NULL

;WITH cte AS
(
   SELECT *, ROW_NUMBER() OVER(PARTITION BY sr.intVendorSetupId, sr.intEntityId, sr.strVendorCustomer ORDER BY sr.intVendorSetupId, sr.intEntityId, sr.strVendorCustomer) AS RowNumber
   FROM @UniqueCustomers sr
   WHERE sr.guiApiUniqueId = @guiApiUniqueId
)
DELETE FROM cte
WHERE guiApiUniqueId = @guiApiUniqueId
  AND RowNumber > 1;

-- ;WITH cte AS
-- (
--    SELECT *, ROW_NUMBER() OVER(PARTITION BY sr.intVendorSetupId, sr.strVendorCustomer ORDER BY sr.intVendorSetupId, sr.strVendorCustomer) AS RowNumber
--    FROM @UniqueCustomers sr
--    WHERE sr.guiApiUniqueId = @guiApiUniqueId
-- )
-- DELETE FROM cte
-- WHERE guiApiUniqueId = @guiApiUniqueId
--   AND RowNumber > 1;

    
MERGE tblVRCustomerXref AS Target
USING (
	SELECT
		  c.intEntityId
		, c.intVendorSetupId
		, c.strVendorCustomer
		, 1 intConcurrencyId
		, c.guiApiUniqueId
		, c.intRowNumber
	FROM @UniqueCustomers c
) AS Source
ON Source.intVendorSetupId = Target.intVendorSetupId
	AND Source.intEntityId = Target.intEntityId
	AND Source.strVendorCustomer = Target.strVendorCustomer
    
-- For Inserts
WHEN NOT MATCHED BY Target THEN
    INSERT (intEntityId, intVendorSetupId, strVendorCustomer, intConcurrencyId, guiApiUniqueId, intRowNumber) 
    VALUES (Source.intEntityId, Source.intVendorSetupId, Source.strVendorCustomer, Source.intConcurrencyId, Source.guiApiUniqueId, Source.intRowNumber)

-- For Updates
WHEN MATCHED THEN UPDATE SET
    Target.strVendorCustomer = Source.strVendorCustomer,
    Target.intRowNumber = Source.intRowNumber;    

-- INSERT INTO tblVRCustomerXref (
-- 	  intEntityId
-- 	, intVendorSetupId
-- 	, strVendorCustomer
-- 	, intConcurrencyId
-- 	, guiApiUniqueId
-- 	, intRowNumber
-- )
-- SELECT
-- 	c.intEntityId
-- 	, c.intVendorSetupId
-- 	, c.strVendorCustomer
-- 	, 1
-- 	, c.guiApiUniqueId
-- 	, c.intRowNumber
-- FROM @UniqueCustomers c

DECLARE @CategoryForUpdates TABLE (intVendorSetupId INT, intCategoryId INT, intRowNumber INT NULL)
INSERT INTO @CategoryForUpdates
SELECT e.intVendorSetupId, c.intCategoryId, vs.intRowNumber
FROM tblApiSchemaTransformVendorSetup vs
JOIN vyuAPVendor v ON v.strVendorId = vs.strVendor OR v.strName = vs.strVendor
JOIN tblVRVendorSetup e ON e.intEntityId = v.intEntityId
JOIN tblICCategory c ON c.strCategoryCode = vs.strCategory
	OR c.strDescription = vs.strCategory
JOIN tblICCategoryVendor cv ON cv.intCategoryId=  c.intCategoryId
	AND cv.intVendorSetupId = e.intVendorSetupId
WHERE vs.guiApiUniqueId = @guiApiUniqueId
	AND @OverwriteExisting = 1

UPDATE xc
SET 
	  xc.guiApiUniqueId = @guiApiUniqueId
	, xc.intConcurrencyId = ISNULL(xc.intConcurrencyId, 1) + 1
	, xc.strVendorDepartment = COALESCE(vs.strVendorCategory, xc.strVendorDepartment)
	, xc.intRowNumber = vs.intRowNumber
FROM tblICCategoryVendor xc
JOIN tblICCategory c ON c.intCategoryId = xc.intCategoryId
JOIN tblApiSchemaTransformVendorSetup vs ON vs.strCategory = c.strCategoryCode
	OR c.strDescription = vs.strCategory
JOIN vyuAPVendor v ON v.strVendorId = vs.strVendor OR v.strName = vs.strVendor
JOIN tblVRVendorSetup e ON e.intEntityId = v.intEntityId
WHERE vs.guiApiUniqueId = @guiApiUniqueId
	AND e.intVendorSetupId = xc.intVendorSetupId
	AND NOT EXISTS (
		SELECT TOP 1 1
		FROM tblApiImportLogDetail d
		WHERE d.guiApiImportLogId = @guiLogId
		AND d.intRowNo = vs.intRowNumber
		AND d.strLogLevel = 'Error'
		AND d.ysnPreventRowUpdate = 1
	)
	AND @OverwriteExisting = 1

DECLARE @UniqueCategories TABLE (
	  intCategoryId INT
	, intVendorSetupId INT
	, strVendorDepartment NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	, guiApiUniqueId UNIQUEIDENTIFIER
	, intRowNumber INT
)
INSERT INTO @UniqueCategories (
	  intCategoryId
	, intVendorSetupId
	, strVendorDepartment
	, guiApiUniqueId
	, intRowNumber
)
SELECT
	  c.intCategoryId
	, vs.intVendorSetupId
	, COALESCE(vts.strVendorCategory, c.strCategoryCode)
	, @guiApiUniqueId
	, vts.intRowNumber
FROM tblApiSchemaTransformVendorSetup vts
JOIN vyuAPVendor v ON v.strVendorId = vts.strVendor OR v.strName = vts.strVendor
JOIN tblVRVendorSetup vs ON vs.intEntityId = v.intEntityId
JOIN tblICCategory c ON c.strCategoryCode = vts.strCategory
	OR c.strDescription = vts.strCategory
WHERE vts.guiApiUniqueId = @guiApiUniqueId
	AND NOT EXISTS (
		SELECT TOP 1 1
		FROM tblICCategoryVendor xx
		WHERE xx.intVendorSetupId = vs.intVendorSetupId
			AND xx.intCategoryId = c.intCategoryId
			--AND xx.strVendorDepartment = vts.strVendorCategory
	)

;WITH cte AS
(
   SELECT *, ROW_NUMBER() OVER(PARTITION BY sr.intVendorSetupId, sr.strVendorDepartment ORDER BY sr.intVendorSetupId, sr.strVendorDepartment) AS RowNumber
   FROM @UniqueCategories sr
   WHERE sr.guiApiUniqueId = @guiApiUniqueId
)
DELETE FROM cte
WHERE guiApiUniqueId = @guiApiUniqueId
  AND RowNumber > 1;

INSERT INTO tblICCategoryVendor (
	  intCategoryId
	, intVendorSetupId
	, strVendorDepartment
	, guiApiUniqueId
	, intRowNumber
	, intConcurrencyId
	, dtmDateCreated
)
SELECT 
  	  intCategoryId
	, intVendorSetupId
	, strVendorDepartment
	, guiApiUniqueId
	, intRowNumber
	, 1
	, GETUTCDATE()
FROM @UniqueCategories

DECLARE @UomForUpdates TABLE (intVendorSetupId INT, intUnitMeasureId INT, intRowNumber INT NULL)
INSERT INTO @UomForUpdates
SELECT e.intVendorSetupId, u.intUnitMeasureId, vs.intRowNumber
FROM tblApiSchemaTransformVendorSetup vs
JOIN vyuAPVendor v ON v.strVendorId = vs.strVendor OR v.strName = vs.strVendor
JOIN tblVRVendorSetup e ON e.intEntityId = v.intEntityId
JOIN tblICUnitMeasure u ON u.strUnitMeasure = vs.strUnitMeasure
JOIN tblVRUOMXref uv ON uv.intUnitMeasureId = u.intUnitMeasureId
	AND uv.intVendorSetupId = e.intVendorSetupId
	-- AND uv.strVendorUOM = vs.strVendorUnitMeasure
WHERE vs.guiApiUniqueId = @guiApiUniqueId
	AND @OverwriteExisting = 1

UPDATE xc
SET 
	  xc.guiApiUniqueId = @guiApiUniqueId
	, xc.intConcurrencyId = ISNULL(xc.intConcurrencyId, 1) + 1
	, xc.strVendorUOM = COALESCE(vs.strVendorUnitMeasure, xc.strVendorUOM)
	, xc.strEquipmentType = COALESCE(vs.strEquipmentType, xc.strEquipmentType)
	, xc.intRowNumber = vs.intRowNumber
FROM tblVRUOMXref xc
JOIN tblICUnitMeasure u ON u.intUnitMeasureId = xc.intUnitMeasureId
JOIN tblApiSchemaTransformVendorSetup vs ON vs.strUnitMeasure = u.strUnitMeasure
JOIN vyuAPVendor v ON v.strVendorId = vs.strVendor OR v.strName = vs.strVendor
JOIN tblVRVendorSetup e ON e.intEntityId = v.intEntityId
WHERE vs.guiApiUniqueId = @guiApiUniqueId
	AND e.intVendorSetupId = xc.intVendorSetupId
	AND vs.strVendorUnitMeasure = xc.strVendorUOM
	AND NOT EXISTS (
		SELECT TOP 1 1
		FROM tblApiImportLogDetail d
		WHERE d.guiApiImportLogId = @guiLogId
		AND d.intRowNo = vs.intRowNumber
		AND d.strLogLevel = 'Error'
		AND d.ysnPreventRowUpdate = 1
	)
	AND @OverwriteExisting = 1

DECLARE @UniqueUOMs TABLE (
	[intVendorSetupId] [int] NOT NULL,
	[intUnitMeasureId] [int] NOT NULL,
	[strVendorUOM] [nvarchar](50)  COLLATE Latin1_General_CI_AS NOT NULL,
	[strEquipmentType] [nvarchar](50)  COLLATE Latin1_General_CI_AS NULL,
	[intRowNumber] INT NULL,
	[guiApiUniqueId] UNIQUEIDENTIFIER NULL
)

INSERT INTO @UniqueUOMs (
	  intVendorSetupId
	, intUnitMeasureId
	, strVendorUOM
	, strEquipmentType
	, guiApiUniqueId
	, intRowNumber
)
SELECT
	  vs.intVendorSetupId
	, u.intUnitMeasureId
	, COALESCE(vts.strVendorUnitMeasure, u.strUnitMeasure)
	, vts.strEquipmentType
	, @guiApiUniqueId
	, vts.intRowNumber
FROM tblApiSchemaTransformVendorSetup vts
JOIN vyuAPVendor v ON v.strVendorId = vts.strVendor OR v.strName = vts.strVendor
JOIN tblVRVendorSetup vs ON vs.intEntityId = v.intEntityId
JOIN tblICUnitMeasure u ON u.strUnitMeasure = vts.strUnitMeasure
WHERE vts.guiApiUniqueId = @guiApiUniqueId
	AND NOT EXISTS (
		SELECT TOP 1 1
		FROM tblVRUOMXref xref
		WHERE xref.intVendorSetupId = vs.intVendorSetupId
			AND xref.intUnitMeasureId = u.intUnitMeasureId
			-- AND xref.strVendorUOM = vts.strVendorUnitMeasure
	)

;WITH cte AS
(
   SELECT *, ROW_NUMBER() OVER(PARTITION BY sr.intVendorSetupId, sr.intUnitMeasureId, sr.strVendorUOM ORDER BY sr.intVendorSetupId, sr.intUnitMeasureId, sr.strVendorUOM) AS RowNumber
   FROM @UniqueUOMs sr
   WHERE sr.guiApiUniqueId = @guiApiUniqueId
)
DELETE FROM cte
WHERE guiApiUniqueId = @guiApiUniqueId
  AND RowNumber > 1;

INSERT INTO tblVRUOMXref (
	  intVendorSetupId
	, intUnitMeasureId
	, strVendorUOM
	, strEquipmentType
	, intConcurrencyId
	, guiApiUniqueId
	, intRowNumber
)
SELECT   
	  intVendorSetupId
	, intUnitMeasureId
	, strVendorUOM
	, strEquipmentType
	, 1
	, guiApiUniqueId
	, intRowNumber
FROM @UniqueUOMs vs

DECLARE @ItemForUpdates TABLE (intVendorSetupId INT, intItemId INT, intRowNumber INT NULL)
INSERT INTO @ItemForUpdates
SELECT e.intVendorSetupId, i.intItemId, vs.intRowNumber
FROM tblApiSchemaTransformVendorSetup vs
JOIN vyuAPVendor v ON v.strVendorId = vs.strVendor OR v.strName = vs.strVendor
JOIN tblVRVendorSetup e ON e.intEntityId = v.intEntityId
JOIN tblICItem i ON i.strItemNo = vs.strItemNo OR i.strDescription = vs.strItemNo
JOIN tblICItemVendorXref xr ON xr.intItemId = i.intItemId
	AND xr.intVendorSetupId = e.intVendorSetupId
WHERE vs.guiApiUniqueId = @guiApiUniqueId
	AND @OverwriteExisting = 1

UPDATE xc
SET 
	  xc.guiApiUniqueId = @guiApiUniqueId
	, xc.intConcurrencyId = ISNULL(xc.intConcurrencyId, 1) + 1
	, xc.strVendorProduct = COALESCE(vs.strVendorItemNo, xc.strVendorProduct)
	, xc.strVendorProductUOM = COALESCE(vs.strVendorItemUOM, xc.strVendorProductUOM)
	, xc.intRowNumber = vs.intRowNumber
FROM tblICItemVendorXref xc
JOIN tblICItem i ON i.intItemId = xc.intItemId
JOIN tblApiSchemaTransformVendorSetup vs ON vs.strItemNo = i.strItemNo
JOIN vyuAPVendor v ON v.strVendorId = vs.strVendor OR v.strName = vs.strVendor
JOIN tblVRVendorSetup e ON e.intEntityId = v.intEntityId
WHERE vs.guiApiUniqueId = @guiApiUniqueId
	AND e.intVendorSetupId = xc.intVendorSetupId
	AND NOT EXISTS (
		SELECT TOP 1 1
		FROM tblApiImportLogDetail d
		WHERE d.guiApiImportLogId = @guiLogId
		AND d.intRowNo = vs.intRowNumber
		AND d.strLogLevel = 'Error'
		AND d.ysnPreventRowUpdate = 1
	)
	AND @OverwriteExisting = 1

UPDATE xc
SET 
	  xc.guiApiUniqueId = @guiApiUniqueId
	, xc.intConcurrencyId = ISNULL(xc.intConcurrencyId, 1) + 1
	, xc.strVendorProduct = COALESCE(vs.strVendorItemNo, xc.strVendorProduct)
	, xc.strVendorProductUOM = COALESCE(vs.strVendorItemUOM, xc.strVendorProductUOM)
	, xc.intRowNumber = vs.intRowNumber
FROM tblICItemVendorXref xc
JOIN tblICItem i ON i.intItemId = xc.intItemId
JOIN tblApiSchemaTransformVendorSetup vs ON vs.strItemName = i.strDescription
JOIN vyuAPVendor v ON v.strVendorId = vs.strVendor OR v.strName = vs.strVendor
JOIN tblVRVendorSetup e ON e.intEntityId = v.intEntityId
WHERE vs.guiApiUniqueId = @guiApiUniqueId
	AND e.intVendorSetupId = xc.intVendorSetupId
	AND NOT EXISTS (
		SELECT TOP 1 1
		FROM tblApiImportLogDetail d
		WHERE d.guiApiImportLogId = @guiLogId
		AND d.intRowNo = vs.intRowNumber
		AND d.strLogLevel = 'Error'
		AND d.ysnPreventRowUpdate = 1
	)
	AND NULLIF(vs.strItemName, '') IS NOT NULL
	AND NULLIF(vs.strItemNo, '') IS NULL
	AND @OverwriteExisting = 1

DECLARE @UniqueItems TABLE (
	  intItemId INT
	, intVendorId INT
	, intVendorSetupId INT
	, strVendorProduct NVARCHAR(150) COLLATE Latin1_General_CI_AS NOT NULL
	, strVendorProductUOM NVARCHAR(150) COLLATE Latin1_General_CI_AS NULL
	, guiApiUniqueId UNIQUEIDENTIFIER
	, intRowNumber INT
	, strItemNo NVARCHAR(150) COLLATE Latin1_General_CI_AS NOT NULL
)

INSERT INTO @UniqueItems (
	  intItemId
	, intVendorId
	, intVendorSetupId
	, strVendorProduct
	, strVendorProductUOM
	, guiApiUniqueId
	, intRowNumber
	, strItemNo
)
SELECT
	  i.intItemId
	, v.intEntityId
	, vs.intVendorSetupId
	, COALESCE(vts.strVendorItemNo, i.strItemNo)
	, vts.strVendorItemUOM
	, @guiApiUniqueId
	, vts.intRowNumber
	, i.strItemNo
FROM tblApiSchemaTransformVendorSetup vts
JOIN vyuAPVendor v ON v.strVendorId = vts.strVendor OR v.strName = vts.strVendor
JOIN tblVRVendorSetup vs ON vs.intEntityId = v.intEntityId
JOIN tblICItem i ON i.strItemNo = vts.strItemNo
WHERE vts.guiApiUniqueId = @guiApiUniqueId
	AND NOT EXISTS (
		SELECT TOP 1 1
		FROM tblICItemVendorXref xref
		WHERE xref.intVendorSetupId = vs.intVendorSetupId
			AND xref.intItemId = i.intItemId
			--AND xref.strVendorProduct = vts.strVendorItemNo
	)

INSERT INTO @UniqueItems (
	  intItemId
	, intVendorId
	, intVendorSetupId
	, strVendorProduct
	, strVendorProductUOM
	, guiApiUniqueId
	, intRowNumber
	, strItemNo
)
SELECT
	  i.intItemId
	, v.intEntityId
	, vs.intVendorSetupId
	, COALESCE(vts.strVendorItemNo, i.strItemNo)
	, vts.strVendorItemUOM
	, @guiApiUniqueId
	, vts.intRowNumber
	, i.strItemNo
FROM tblApiSchemaTransformVendorSetup vts
JOIN vyuAPVendor v ON v.strVendorId = vts.strVendor OR v.strName = vts.strVendor
JOIN tblVRVendorSetup vs ON vs.intEntityId = v.intEntityId
JOIN tblICItem i ON i.strDescription = vts.strItemName
WHERE vts.guiApiUniqueId = @guiApiUniqueId
	AND NOT EXISTS (
		SELECT TOP 1 1
		FROM tblICItemVendorXref xref
		WHERE xref.intVendorSetupId = vs.intVendorSetupId
			AND xref.intItemId = i.intItemId
			--AND xref.strVendorProduct = vts.strVendorItemNo
	)
	AND NULLIF(vts.strItemName, '') IS NOT NULL
	AND NULLIF(vts.strItemNo, '') IS NULL

;WITH cte AS
(
   SELECT *, ROW_NUMBER() OVER(PARTITION BY sr.intVendorSetupId, sr.strVendorProduct, sr.strItemNo ORDER BY sr.intVendorSetupId, sr.strVendorProduct, sr.strItemNo) AS RowNumber
   FROM @UniqueItems sr
   WHERE sr.guiApiUniqueId = @guiApiUniqueId
)
DELETE FROM cte
WHERE guiApiUniqueId = @guiApiUniqueId
  AND RowNumber > 1;


INSERT INTO tblICItemVendorXref (
	  intItemId
	, intVendorId
	, intVendorSetupId
	, strVendorProduct
	, strVendorProductUOM
	, guiApiUniqueId
	, intRowNumber
	, dtmDateCreated
	, intConcurrencyId
)
SELECT
	  intItemId
	, intVendorId
	, intVendorSetupId
	, strVendorProduct
	, strVendorProductUOM
	, @guiApiUniqueId
	, intRowNumber
	, GETUTCDATE()
	, 1
FROM @UniqueItems

-- Log successful imports
INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage, strAction)
SELECT
      NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Rebate Vendor Setup'
    , strValue = v.strVendorId
    , strLogLevel = 'Info'
    , strStatus = 'Success'
    , intRowNo = vs.intRowNumber
    , strMessage = 'The rebate vendor setup ' + ISNULL(v.strVendorId, '') + ' was imported successfully.'
    , strAction = 'Create'
FROM tblVRVendorSetup vs
JOIN tblEMEntity e ON e.intEntityId = vs.intEntityId
JOIN tblAPVendor v ON v.intEntityId = vs.intEntityId
WHERE vs.guiApiUniqueId = @guiApiUniqueId
  AND NOT EXISTS(SELECT TOP 1 1 FROM @ForUpdates u WHERE u.strVendorNumber = v.strVendorId AND u.intRowNumber = vs.intRowNumber)

INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage, strAction)
SELECT
      NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Item Mapping'
    , strValue = i.strVendorProduct
    , strLogLevel = 'Info'
    , strStatus = 'Success'
    , intRowNo = vs.intRowNumber
    , strMessage = 'The Item mapping ' + ISNULL(i.strVendorProduct, '') + ' was ' 
		+ CASE WHEN updates.intItemId IS NOT NULL THEN 'updated' ELSE 'imported' END + ' successfully.'
    , strAction = CASE WHEN updates.intItemId IS NOT NULL THEN 'Update' ELSE 'Create' END
FROM tblICItemVendorXref i
JOIN tblVRVendorSetup vs ON vs.intVendorSetupId = i.intVendorSetupId
OUTER APPLY (
	SELECT TOP 1 i.intItemId
	FROM @ItemForUpdates ux 
	WHERE ux.intRowNumber = i.intRowNumber
		AND ux.intItemId = i.intItemId
		AND ux.intVendorSetupId = i.intVendorSetupId
) updates
WHERE i.guiApiUniqueId = @guiApiUniqueId

INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage, strAction)
SELECT
      NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'UOM Mapping'
    , strValue = u.strVendorUOM
    , strLogLevel = 'Info'
    , strStatus = 'Success'
    , intRowNo = vs.intRowNumber
    , strMessage = 'The UOM mapping ' + ISNULL(u.strVendorUOM, '') + ' was ' 
		+ CASE WHEN updates.intUnitMeasureId IS NOT NULL THEN 'updated' ELSE 'imported' END + ' successfully.'
    , strAction = CASE WHEN updates.intUnitMeasureId IS NOT NULL THEN 'Update' ELSE 'Create' END
FROM tblVRUOMXref u
JOIN tblVRVendorSetup vs ON vs.intVendorSetupId = u.intVendorSetupId
OUTER APPLY (
	SELECT TOP 1 u.intUnitMeasureId
	FROM @UomForUpdates ux 
	WHERE ux.intRowNumber = u.intRowNumber
		AND ux.intUnitMeasureId = u.intUnitMeasureId
		AND ux.intVendorSetupId = u.intVendorSetupId
) updates
WHERE u.guiApiUniqueId = @guiApiUniqueId

INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage, strAction)
SELECT
      NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Vendor''s Category'
    , strValue = c.strVendorDepartment
    , strLogLevel = 'Info'
    , strStatus = 'Success'
    , intRowNo = vs.intRowNumber
   , strMessage = 'The Vendor''s Category mapping ' + ISNULL(c.strVendorDepartment, '') + ' was ' 
		+ CASE WHEN updates.intCategoryId IS NOT NULL THEN 'updated' ELSE 'imported' END + ' successfully.'
    , strAction = CASE WHEN updates.intCategoryId IS NOT NULL THEN 'Update' ELSE 'Create' END
FROM tblICCategoryVendor c
JOIN tblVRVendorSetup vs ON vs.intVendorSetupId = c.intVendorSetupId
OUTER APPLY (
	SELECT TOP 1 u.intCategoryId
	FROM @CategoryForUpdates u 
	WHERE u.intRowNumber = c.intRowNumber
		AND u.intCategoryId = c.intCategoryId
		AND u.intVendorSetupId = c.intVendorSetupId
) updates
WHERE c.guiApiUniqueId = @guiApiUniqueId

INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage, strAction)
SELECT
      NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Vendor Customer'
    , strValue = xc.strVendorCustomer
    , strLogLevel = 'Info'
    , strStatus = 'Success'
    , intRowNo = xc.intRowNumber
    , strMessage = 'The Vendor Customer mapping ' + ISNULL(xc.strVendorCustomer, '') + ' was ' 
		+ CASE WHEN updates.strVendorCustomer IS NOT NULL THEN 'updated' ELSE 'imported' END + ' successfully.'
    , strAction = CASE WHEN updates.strVendorCustomer IS NOT NULL THEN 'Update' ELSE 'Create' END
FROM tblVRCustomerXref xc
JOIN tblARCustomer c ON c.intEntityId = xc.intEntityId
OUTER APPLY (
	SELECT TOP 1 u.strVendorCustomer
	FROM @CustomerForUpdates u 
	WHERE u.intRowNumber = xc.intRowNumber
		AND u.intEntityId = xc.intEntityId
		AND u.intVendorSetupId = xc.intVendorSetupId
) updates
WHERE xc.guiApiUniqueId = @guiApiUniqueId


INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage, strAction)
SELECT
      NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Rebate Vendor Setup'
    , strValue = e.strName
    , strLogLevel = 'Info'
    , strStatus = 'Success'
    , intRowNo = vs.intRowNumber
    , strMessage = 'The rebate vendor setup ' + ISNULL(e.strName, '') + ' was updated successfully.'
    , strAction = 'Update'
FROM tblVRVendorSetup vs
JOIN tblEMEntity e ON e.intEntityId = vs.intEntityId
JOIN tblAPVendor v ON v.intEntityId = vs.intEntityId
JOIN @ForUpdates u ON u.strVendorNumber = v.strVendorId
WHERE vs.guiApiUniqueId = @guiApiUniqueId


UPDATE log
SET log.intTotalRowsImported = ISNULL(rv.intCount, 0) + ISNULL(rc.intCount, 0) + ISNULL(rp.intCount, 0) + ISNULL(ru.intCount, 0)
FROM tblApiImportLog log
OUTER APPLY (
	SELECT COUNT(*) intCount
	FROM tblApiSchemaTransformVendorSetup
	WHERE guiApiUniqueId = log.guiApiUniqueId
) rv
OUTER APPLY (
	SELECT COUNT(*) intCount
	FROM tblVRCustomerXref
	WHERE guiApiUniqueId = log.guiApiUniqueId
) rc
OUTER APPLY (
	SELECT COUNT(*) intCount
	FROM tblICCategoryVendor
	WHERE guiApiUniqueId = log.guiApiUniqueId
) rp
OUTER APPLY (
	SELECT COUNT(*) intCount
	FROM tblVRUOMXref
	WHERE guiApiUniqueId = log.guiApiUniqueId
) ru
WHERE log.guiApiImportLogId = @guiLogId