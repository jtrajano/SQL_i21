CREATE PROCEDURE uspApiSchemaTransformRebateProgram 
	@guiApiUniqueId UNIQUEIDENTIFIER,
	@guiLogId UNIQUEIDENTIFIER
AS

DECLARE @AutoCreateSetup TABLE (strVendor NVARCHAR(200) COLLATE Latin1_General_CI_AS)
INSERT INTO @AutoCreateSetup (strVendor)
SELECT DISTINCT vts.strVendor
FROM tblApiSchemaTransformRebateProgram vts
LEFT JOIN vyuAPVendor v ON v.strName = vts.strVendor OR v.strVendorId = vts.strVendor
LEFT JOIN tblVRVendorSetup vs ON vs.intEntityId = v.intEntityId
WHERE vts.guiApiUniqueId = @guiApiUniqueId
	AND vs.intEntityId IS NULL

INSERT INTO tblVRVendorSetup (
	guiApiUniqueId,
	intEntityId,
	intConcurrencyId
)
SELECT @guiApiUniqueId, v.intEntityId, 1
FROM @AutoCreateSetup a
JOIN vyuAPVendor v ON v.strVendorId = a.strVendor OR v.strName = a.strVendor

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
FROM tblApiSchemaTransformRebateProgram vts
LEFT JOIN vyuAPVendor v ON v.strVendorId = vts.strVendor OR v.strName = vts.strVendor
WHERE vts.guiApiUniqueId = @guiApiUniqueId
	AND v.intEntityId IS NULL
	OR v.ysnPymtCtrlActive != 1

INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage, strAction)
SELECT
	  NEWID()
	, guiApiImportLogId = @guiLogId
	, strField = dbo.fnApiSchemaTransformMapField(@guiApiUniqueId, 'Vendor') 
	, strValue = vts.strVendor
	, strLogLevel = 'Error'
	, strStatus = 'Failed'
	, intRowNo = vts.intRowNumber
	, strMessage = 'The payment control of ' + dbo.fnApiSchemaTransformMapField(@guiApiUniqueId, 'Vendor') + ' "' + vts.strVendor + '" is inactive.'
	, strAction = 'Skipped'
FROM tblApiSchemaTransformRebateProgram vts
JOIN vyuAPVendor v ON v.strVendorId = vts.strVendor OR v.strName = vts.strVendor
WHERE vts.guiApiUniqueId = @guiApiUniqueId
	AND ISNULL(v.ysnPymtCtrlActive, 0) = 0

INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage, strAction)
SELECT
	  NEWID()
	, guiApiImportLogId = @guiLogId
	, strField = 'Vendor Rebate Setup'
	, strValue = vts.strVendor
	, strLogLevel = 'Info'
	, strStatus = 'Success'
	, intRowNo = MIN(vts.intRowNumber)
	, strMessage = 'The Vendor Rebate Setup "' + vts.strVendor + '" does not exist so it is automatically created.'
	, strAction = 'Created'
FROM tblApiSchemaTransformRebateProgram vts
JOIN @AutoCreateSetup s ON s.strVendor = vts.strVendor
WHERE vts.guiApiUniqueId = @guiApiUniqueId
GROUP BY vts.strVendor

INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage, strAction)
SELECT
	  NEWID()
	, guiApiImportLogId = @guiLogId
	, strField = dbo.fnApiSchemaTransformMapField(@guiApiUniqueId, 'Item No') 
	, strValue = vts.strItemNo
	, strLogLevel = 'Error'
	, strStatus = 'Failed'
	, intRowNo = vts.intRowNumber
	, strMessage = 'The ' + dbo.fnApiSchemaTransformMapField(@guiApiUniqueId, 'Item No')  + ' "' + vts.strItemNo + '" does not exist.'
	, strAction = 'Skipped'
FROM tblApiSchemaTransformRebateProgram vts
LEFT JOIN vyuAPVendor v ON v.strVendorId = vts.strVendor OR v.strName = vts.strVendor
LEFT JOIN tblVRVendorSetup vs ON vs.intEntityId = v.intEntityId
LEFT JOIN tblICItem i ON i.strItemNo = vts.strItemNo
WHERE vts.guiApiUniqueId = @guiApiUniqueId
	AND i.intItemId IS NULL
	AND NULLIF(vts.strItemNo, '') IS NOT NULL
	AND NULLIF(vts.strVendorItemNo, '') IS NULL

INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage, strAction)
SELECT
	  NEWID()
	, guiApiImportLogId = @guiLogId
	, strField = dbo.fnApiSchemaTransformMapField(@guiApiUniqueId, 'Item Name') 
	, strValue = vts.strItemName
	, strLogLevel = 'Error'
	, strStatus = 'Failed'
	, intRowNo = vts.intRowNumber
	, strMessage = 'The ' + dbo.fnApiSchemaTransformMapField(@guiApiUniqueId, 'Item Name')  + ' "' + vts.strItemName + '" does not exist.'
	, strAction = 'Skipped'
FROM tblApiSchemaTransformRebateProgram vts
LEFT JOIN vyuAPVendor v ON v.strVendorId = vts.strVendor OR v.strName = vts.strVendor
LEFT JOIN tblVRVendorSetup vs ON vs.intEntityId = v.intEntityId
LEFT JOIN tblICItem i ON i.strDescription = vts.strItemName
WHERE vts.guiApiUniqueId = @guiApiUniqueId
	AND i.intItemId IS NULL
	AND NULLIF(vts.strItemNo, '') IS NULL
	AND NULLIF(vts.strItemName, '') IS NOT NULL
	AND NULLIF(vts.strVendorItemNo, '') IS NULL

INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage, strAction)
SELECT
	  NEWID()
	, guiApiImportLogId = @guiLogId
	, strField = dbo.fnApiSchemaTransformMapField(@guiApiUniqueId, 'Item No') 
	, strValue = vts.strItemName
	, strLogLevel = 'Error'
	, strStatus = 'Failed'
	, intRowNo = vts.intRowNumber
	, strMessage = 'The item or category must be specified.'
	, strAction = 'Skipped'
FROM tblApiSchemaTransformRebateProgram vts
LEFT JOIN vyuAPVendor v ON v.strVendorId = vts.strVendor OR v.strName = vts.strVendor
LEFT JOIN tblVRVendorSetup vs ON vs.intEntityId = v.intEntityId
WHERE vts.guiApiUniqueId = @guiApiUniqueId
	AND NULLIF(vts.strItemNo, '') IS NULL 
	AND NULLIF(vts.strItemName, '') IS NULL
	AND NULLIF(vts.strCategory, '') IS NULL

INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage, strAction)
SELECT
	  NEWID()
	, guiApiImportLogId = @guiLogId
	, strField = dbo.fnApiSchemaTransformMapField(@guiApiUniqueId, 'Vendor''s Item') 
	, strValue = vts.strVendorItemNo
	, strLogLevel = 'Error'
	, strStatus = 'Failed'
	, intRowNo = vts.intRowNumber
	, strMessage = 'The ' + dbo.fnApiSchemaTransformMapField(@guiApiUniqueId, 'Vendor''s Item') + ' "' + vts.strVendorItemNo + '" does not exist.'
	, strAction = 'Skipped'
FROM tblApiSchemaTransformRebateProgram vts
LEFT JOIN vyuAPVendor v ON v.strVendorId = vts.strVendor OR v.strName = vts.strVendor
LEFT JOIN tblVRVendorSetup vs ON vs.intEntityId = v.intEntityId
LEFT JOIN tblICItemVendorXref x ON x.intVendorSetupId = vs.intVendorSetupId
	AND x.strVendorProduct = vts.strVendorItemNo
WHERE vts.guiApiUniqueId = @guiApiUniqueId
	AND x.intItemVendorXrefId IS NULL
	AND NULLIF(vts.strVendorItemNo, '') IS NOT NULL

INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage, strAction)
SELECT
	  NEWID()
	, guiApiImportLogId = @guiLogId
	, strField = dbo.fnApiSchemaTransformMapField(@guiApiUniqueId, 'Category') 
	, strValue = vts.strCategory
	, strLogLevel = 'Error'
	, strStatus = 'Failed'
	, intRowNo = vts.intRowNumber
	, strMessage = 'The ' + dbo.fnApiSchemaTransformMapField(@guiApiUniqueId, 'Category')  + ' "' + vts.strCategory + '" does not exist.'
	, strAction = 'Skipped'
FROM tblApiSchemaTransformRebateProgram vts
LEFT JOIN vyuAPVendor v ON v.strName = vts.strVendor OR v.strVendorId = vts.strVendor
LEFT JOIN tblVRVendorSetup vs ON vs.intEntityId = v.intEntityId
LEFT JOIN tblICCategory c ON c.strCategoryCode = vts.strCategory
WHERE vts.guiApiUniqueId = @guiApiUniqueId
	AND c.intCategoryId IS NULL
	AND NULLIF(vts.strCategory, '') IS NOT NULL
	AND NULLIF(vts.strVendorCategory, '') IS NULL

INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage, strAction)
SELECT
	  NEWID()
	, guiApiImportLogId = @guiLogId
	, strField = dbo.fnApiSchemaTransformMapField(@guiApiUniqueId, 'Rebate By') 
	, strValue = vts.strRebateBy
	, strLogLevel = 'Error'
	, strStatus = 'Failed'
	, intRowNo = vts.intRowNumber
	, strMessage = 'The ' + dbo.fnApiSchemaTransformMapField(@guiApiUniqueId, 'Rebate By') + ' "' + vts.strRebateBy + '" is not valid. Should be either "Unit" or "Percentage".'
	, strAction = 'Skipped'
FROM tblApiSchemaTransformRebateProgram vts
WHERE vts.guiApiUniqueId = @guiApiUniqueId
	AND vts.strRebateBy NOT IN ('Unit', 'Percentage')

INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage, strAction)
SELECT
	  NEWID()
	, guiApiImportLogId = @guiLogId
	, strField = dbo.fnApiSchemaTransformMapField(@guiApiUniqueId, 'Vendor''s Category') 
	, strValue = vts.strVendorCategory
	, strLogLevel = 'Error'
	, strStatus = 'Failed'
	, intRowNo = vts.intRowNumber
	, strMessage = 'The ' + dbo.fnApiSchemaTransformMapField(@guiApiUniqueId, 'Vendor''s Category')  + ' "' + vts.strVendorCategory + '" does not exist.'
	, strAction = 'Skipped'
FROM tblApiSchemaTransformRebateProgram vts
LEFT JOIN vyuAPVendor v ON v.strName = vts.strVendor OR v.strVendorId = vts.strVendor
LEFT JOIN tblVRVendorSetup vs ON vs.intEntityId = v.intEntityId
LEFT JOIN tblICCategoryVendor x ON x.intVendorSetupId = vs.intVendorSetupId
	AND x.strVendorDepartment = vts.strVendorCategory
WHERE vts.guiApiUniqueId = @guiApiUniqueId
	AND x.intCategoryVendorId IS NULL
	AND NULLIF(vts.strVendorCategory, '') IS NOT NULL

INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage, strAction)
SELECT
	  NEWID()
	, guiApiImportLogId = @guiLogId
	, strField = dbo.fnApiSchemaTransformMapField(@guiApiUniqueId, 'Rebate UOM') 
	, strValue = vts.strRebateUOM
	, strLogLevel = 'Error'
	, strStatus = 'Failed'
	, intRowNo = vts.intRowNumber
	, strMessage = 'The ' + dbo.fnApiSchemaTransformMapField(@guiApiUniqueId, 'Rebate UOM') + ' "' + vts.strRebateUOM + '" does not exist.'
	, strAction = 'Skipped'
FROM tblApiSchemaTransformRebateProgram vts
LEFT JOIN tblICUnitMeasure u ON u.strUnitMeasure = vts.strRebateUOM
WHERE vts.guiApiUniqueId = @guiApiUniqueId
	AND u.intUnitMeasureId IS NULL
	AND NULLIF(vts.strRebateUOM, '') IS NOT NULL

INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage, strAction)
SELECT
	  NEWID()
	, guiApiImportLogId = @guiLogId
	, strField = dbo.fnApiSchemaTransformMapField(@guiApiUniqueId, 'Vendor''s Rebate UOM') 
	, strValue = vts.strVendorRebateUOM
	, strLogLevel = 'Error'
	, strStatus = 'Failed'
	, intRowNo = vts.intRowNumber
	, strMessage = 'The ' + dbo.fnApiSchemaTransformMapField(@guiApiUniqueId, 'Vendor''s Rebate UOM') + ' "' + vts.strVendorRebateUOM + '" does not exist.'
	, strAction = 'Skipped'
FROM tblApiSchemaTransformRebateProgram vts
LEFT JOIN tblVRUOMXref u ON u.strVendorUOM = vts.strVendorRebateUOM
WHERE vts.guiApiUniqueId = @guiApiUniqueId
	AND u.intUnitMeasureId IS NULL
	AND NULLIF(vts.strVendorRebateUOM, '') IS NOT NULL

INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage, strAction)
SELECT
	  NEWID()
	, guiApiImportLogId = @guiLogId
	, strField = dbo.fnApiSchemaTransformMapField(@guiApiUniqueId, 'Customer No') 
	, strValue = vts.strCustomer
	, strLogLevel = 'Error'
	, strStatus = 'Failed'
	, intRowNo = vts.intRowNumber
	, strMessage = 'The ' + dbo.fnApiSchemaTransformMapField(@guiApiUniqueId, 'Customer No') + ' "' + vts.strCustomer + '" does not exist.'
	, strAction = 'Skipped'
FROM tblApiSchemaTransformRebateProgram vts
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
	, strMessage = 'The ' + dbo.fnApiSchemaTransformMapField(@guiApiUniqueId, 'Customer Name')  + ' "' + vts.strCustomerName + '" does not exist.'
	, strAction = 'Skipped'
FROM tblApiSchemaTransformRebateProgram vts
LEFT JOIN vyuARCustomer c ON c.strName = vts.strCustomerName
WHERE vts.guiApiUniqueId = @guiApiUniqueId
	AND c.intEntityId IS NULL
	AND NULLIF(vts.strCustomer, '') IS NULL
	AND NULLIF(vts.strCustomerName, '') IS NOT NULL

DECLARE @UniqueVendors TABLE (
	  intEntityId INT
	, strVendor NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
	, intVendorSetupId INT
	, strProgram NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
	, guiApiUniqueId UNIQUEIDENTIFIER
	, intRowNumber INT
)

INSERT INTO @UniqueVendors
SELECT v.intEntityId, vts.strVendor, vs.intVendorSetupId, vts.strVendorProgram, @guiApiUniqueId, MAX(vts.intRowNumber)
FROM tblApiSchemaTransformRebateProgram vts
JOIN vyuAPVendor v ON v.strVendorId = vts.strVendor OR v.strName = vts.strVendor
JOIN tblVRVendorSetup vs ON vs.intEntityId = v.intEntityId
WHERE vts.guiApiUniqueId = @guiApiUniqueId
	AND v.ysnPymtCtrlActive = 1
GROUP BY v.intEntityId, vts.strVendor, vs.intVendorSetupId, vts.strVendorProgram

INSERT INTO tblVRProgram (
	  intVendorSetupId
	, strProgramDescription
	, strVendorProgram
	, ysnActive
	, guiApiUniqueId
	, intRowNumber
	, intConcurrencyId
)
SELECT 
	  v.intVendorSetupId
	, vts.strDescription
	, vts.strVendorProgram
	, 1
	, @guiApiUniqueId
	, vts.intRowNumber
	, 1
FROM tblApiSchemaTransformRebateProgram vts
JOIN @UniqueVendors v ON v.intRowNumber = vts.intRowNumber
WHERE vts.guiApiUniqueId = @guiApiUniqueId
	AND NOT EXISTS (
		SELECT TOP 1 1
		FROM tblVRProgram xp
		JOIN tblVRVendorSetup xvs ON xvs.intVendorSetupId = xp.intVendorSetupId
		WHERE xp.intVendorSetupId = v.intVendorSetupId
			AND xvs.intEntityId = v.intEntityId
			AND (xp.strVendorProgram = vts.strVendorProgram)
	)
		
UPDATE p
SET   p.strVendorProgram = x.strVendorProgram
	, p.guiApiUniqueId = @guiApiUniqueId
	, p.strProgramDescription = x.strDescription
	, p.intRowNumber = x.intRowNumber
	, p.intConcurrencyId = p.intConcurrencyId + 1
FROM tblVRProgram p
JOIN (
	SELECT DISTINCT xp.intProgramId, MAX(vts.strVendorProgram) strVendorProgram,
	MAX(vts.intRowNumber) intRowNumber, MAX(vts.strDescription) strDescription
	FROM tblVRProgram xp
	JOIN tblVRVendorSetup xvs ON xvs.intVendorSetupId = xp.intVendorSetupId
	JOIN vyuAPVendor v ON v.intEntityId = xvs.intEntityId
	JOIN tblApiSchemaTransformRebateProgram vts ON v.strVendorId = vts.strVendor OR v.strName = vts.strVendor
	JOIN @UniqueVendors uv ON uv.intEntityId = v.intEntityId
	WHERE vts.guiApiUniqueId = @guiApiUniqueId
		AND (xp.guiApiUniqueId != @guiApiUniqueId OR xp.guiApiUniqueId IS NULL)
		AND (xp.strVendorProgram = vts.strVendorProgram OR NULLIF(xp.strVendorProgram, '') IS NULL)
	GROUP BY xp.intProgramId
) x ON x.intProgramId = p.intProgramId


DECLARE @CreatedPrograms TABLE (intProgramId INT, intVendorSetupId INT, strProgram NVARCHAR(200) COLLATE Latin1_General_CI_AS, strVendorProgram NVARCHAR(200) COLLATE Latin1_General_CI_AS, intRowNumber INT)

DECLARE @intProgramId INT
DECLARE @intVendorSetupId INT
DECLARE @startingNo NVARCHAR(150)
DECLARE @strVendorProgram NVARCHAR(200)
DECLARE @intRowNumber INT

DECLARE cur CURSOR LOCAL FAST_FORWARD
FOR
SELECT p.intProgramId, p.intVendorSetupId, p.strVendorProgram, p.intRowNumber
FROM tblVRProgram p
WHERE p.guiApiUniqueId = @guiApiUniqueId

OPEN cur

FETCH NEXT FROM cur INTO @intProgramId, @intVendorSetupId, @strVendorProgram, @intRowNumber

WHILE @@FETCH_STATUS = 0
BEGIN
	EXEC dbo.uspSMGetStartingNumber 125, @startingNo OUTPUT
	UPDATE tblVRProgram
	SET strProgram = @startingNo
	WHERE intProgramId = @intProgramId

	INSERT INTO @CreatedPrograms(intProgramId, intVendorSetupId, strProgram, strVendorProgram, intRowNumber)
	VALUES (@intProgramId, @intVendorSetupId, @startingNo, @strVendorProgram, @intRowNumber)

	FETCH NEXT FROM cur INTO @intProgramId, @intVendorSetupId, @strVendorProgram, @intRowNumber
END

CLOSE cur
DEALLOCATE cur

IF NOT EXISTS(SELECT TOP 1 1 FROM tblVRProgram WHERE guiApiUniqueId = @guiApiUniqueId)
BEGIN
	INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage, strAction)
	SELECT
		NEWID()
		, guiApiImportLogId = @guiLogId
		, strField = 'Vendor Rebate Program'
		, strValue = ''
		, strLogLevel = 'Error'
		, strStatus = 'Failed'
		, intRowNo = 1
		, strMessage = 'There''s nothing to import.'
		, strAction = 'Skipped'

	UPDATE log
	SET log.intTotalRowsImported = ISNULL(rv.intCount, 0)
	FROM tblApiImportLog log
	OUTER APPLY (
		SELECT COUNT(*) intCount
		FROM tblVRProgramItem
		WHERE guiApiUniqueId = log.guiApiUniqueId
	) rv
	WHERE log.guiApiImportLogId = @guiLogId

	RETURN
END

DECLARE @CreatedProgramItems TABLE (
	  intProgramId INT
	, intItemId INT NULL
	, intCategoryId INT NULL
	, strRebateBy NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, dblRebateRate NUMERIC(38, 20)
	, dtmBeginDate DATETIME NULL
	, dtmEndDate DATETIME NULL
	, intUnitMeasureId INT NULL
	, intConcurrencyId INT NULL
	, intRowNumber INT NULL
)

INSERT INTO @CreatedProgramItems
SELECT
	  p.intProgramId
	, COALESCE(i.intItemId, xi.intItemId)
	, COALESCE(i.intCategoryId, xc.intCategoryId, cat.intCategoryId)
	, ISNULL(rp.strRebateBy, 'Unit')
	, rp.dblRebateRate
	, rp.dtmBeginDate
	, rp.dtmEndDate
	, COALESCE(u.intUnitMeasureId, xu.intUnitMeasureId, du.intUnitMeasureId, 0)
	, 1
	, rp.intRowNumber
FROM tblApiSchemaTransformRebateProgram rp
OUTER APPLY (
	SELECT uv.strProgram, uv.intVendorSetupId
	FROM @UniqueVendors uv
	JOIN vyuAPVendor v ON v.intEntityId = uv.intEntityId
	WHERE uv.strProgram = rp.strVendorProgram
		AND (rp.strVendor = v.strVendorId OR rp.strVendor = v.strName)
) v
OUTER APPLY (
	SELECT TOP 1 xp.intProgramId, xp.strProgram
	FROM @CreatedPrograms xp
	WHERE xp.strVendorProgram = rp.strVendorProgram
		AND xp.intVendorSetupId = v.intVendorSetupId
) p
LEFT JOIN tblICItem i ON (i.strItemNo = rp.strItemNo OR i.strDescription = rp.strItemName)
OUTER APPLY (
	SELECT TOP 1 xxi.intItemId
	FROM tblICItemVendorXref xxi
	WHERE xxi.strVendorProduct = rp.strVendorItemNo
	AND xxi.intVendorSetupId = v.intVendorSetupId
) xi
LEFT JOIN tblICUnitMeasure u ON u.strUnitMeasure = rp.strRebateUOM
OUTER APPLY (
	SELECT TOP 1 intUnitMeasureId 
	FROM tblVRUOMXref 
	WHERE strVendorUOM = rp.strVendorRebateUOM
	AND intVendorSetupId = v.intVendorSetupId
) xu
OUTER APPLY (
	SELECT TOP 1 intCategoryId
	FROM tblICCategoryVendor
	WHERE strVendorDepartment = rp.strVendorCategory
	AND intVendorSetupId = v.intVendorSetupId
	AND NULLIF(rp.strCategory, '') IS NULL
) xc
LEFT JOIN tblICCategory cat ON cat.strCategoryCode = rp.strCategory OR cat.strDescription = rp.strCategory
OUTER APPLY (
	SELECT TOP 1 intUnitMeasureId
	FROM tblICItemUOM
	WHERE intItemId = i.intItemId
		AND ysnStockUnit = 1
) du
WHERE rp.guiApiUniqueId = @guiApiUniqueId
ORDER BY rp.intRowNumber

INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage, strAction)
SELECT
	  NEWID()
	, guiApiImportLogId = @guiLogId
	, strField = dbo.fnApiSchemaTransformMapField(@guiApiUniqueId, 'Begin Date') + ' and/or ' + dbo.fnApiSchemaTransformMapField(@guiApiUniqueId, 'End Date')
	, strValue = CONVERT(NVARCHAR(100), cpi.dtmBeginDate, 101) + ' - ' + CONVERT(NVARCHAR(100), cpi.dtmEndDate, 101)
	, strLogLevel = 'Error'
	, strStatus = 'Failed'
	, intRowNo = cpi.intRowNumber
	, strMessage = 'The date range from ' + CONVERT(NVARCHAR(100), cpi.dtmBeginDate, 101) + ' to ' + CONVERT(NVARCHAR(100), cpi.dtmEndDate, 101)
		+ ' overlaps with existing rates for the item no. ' + i.strItemNo + ' of the vendor ' + v.strName + ' with a date range ' 
		+ CONVERT(NVARCHAR(100), pp.dtmBeginDate, 101) + ' to ' + CONVERT(NVARCHAR(100), pp.dtmEndDate, 101) + ' in program ' + pp.strProgram
	, strAction = 'Skipped'
FROM @CreatedProgramItems cpi
JOIN tblVRProgram p ON p.intProgramId = cpi.intProgramId
JOIN tblVRVendorSetup vs ON vs.intVendorSetupId = p.intVendorSetupId
JOIN vyuAPVendor v ON v.intEntityId = vs.intEntityId
JOIN tblICItem i ON i.intItemId = cpi.intItemId
OUTER APPLY (
	SELECT TOP 1 xpi.intItemId, xpi.dtmBeginDate, xpi.dtmEndDate, xp.strProgram
	FROM tblVRProgramItem xpi
	JOIN tblVRProgram xp ON xp.intProgramId = xpi.intProgramId
	JOIN tblVRVendorSetup xvs ON xvs.intVendorSetupId = xp.intVendorSetupId
	JOIN vyuAPVendor xv ON xv.intEntityId = xvs.intEntityId
	WHERE xpi.intItemId = cpi.intItemId
		AND xvs.intEntityId = vs.intEntityId
		AND (cpi.dtmBeginDate <= xpi.dtmEndDate AND xpi.dtmBeginDate <= cpi.dtmEndDate)
		AND NOT (cpi.dtmBeginDate = xpi.dtmBeginDate AND cpi.dtmEndDate = xpi.dtmEndDate AND cpi.intProgramId = xpi.intProgramId)
) pp
WHERE pp.intItemId IS NOT NULL

UPDATE pi
SET   pi.guiApiUniqueId  = @guiApiUniqueId
	, pi.dblRebateRate = cpi.dblRebateRate
	, pi.intRowNumber = cpi.intRowNumber
	, pi.dtmBeginDate = cpi.dtmBeginDate
	, pi.dtmEndDate = cpi.dtmEndDate
	, pi.intUnitMeasureId = cpi.intUnitMeasureId
	, pi.strRebateBy = ISNULL(cpi.strRebateBy, 'Unit')
	, pi.intConcurrencyId = ISNULL(pi.intConcurrencyId, 0) + 1
FROM tblVRProgramItem pi
JOIN tblVRProgram p ON p.intProgramId = pi.intProgramId
JOIN tblVRVendorSetup vs ON vs.intVendorSetupId = p.intVendorSetupId
JOIN @CreatedProgramItems cpi ON cpi.intProgramId = p.intProgramId
	AND cpi.intItemId = pi.intItemId
CROSS APPLY (
	SELECT TOP 1 xpi.intItemId, xpi.dtmBeginDate, xpi.dtmEndDate, xp.strProgram
	FROM tblVRProgramItem xpi
	JOIN tblVRProgram xp ON xp.intProgramId = xpi.intProgramId
	JOIN tblVRVendorSetup xvs ON xvs.intVendorSetupId = xp.intVendorSetupId
	JOIN vyuAPVendor xv ON xv.intEntityId = xvs.intEntityId
	WHERE xpi.intItemId = cpi.intItemId
		AND xvs.intEntityId = vs.intEntityId
		AND ((NOT (xpi.intProgramItemId != pi.intProgramItemId AND cpi.dtmBeginDate <= xpi.dtmEndDate AND xpi.dtmBeginDate <= cpi.dtmEndDate)) AND
		 (cpi.dtmBeginDate = xpi.dtmBeginDate AND cpi.dtmEndDate = xpi.dtmEndDate AND xpi.intProgramItemId = pi.intProgramItemId))
) pp
WHERE NOT EXISTS (
		SELECT TOP 1 1
		FROM tblApiImportLogDetail
		WHERE guiApiImportLogId = @guiLogId
			AND intRowNo = cpi.intRowNumber
			AND strStatus = 'Failed'
			AND strLogLevel = 'Error'
			AND strAction = 'Skipped'
	)

INSERT INTO tblVRProgramItem (
	  intItemId
	, intCategoryId
	, strRebateBy
	, dblRebateRate
	, dtmBeginDate
	, dtmEndDate
	, intProgramId
	, intUnitMeasureId
	, intConcurrencyId
	, intRowNumber
	, guiApiUniqueId
)
SELECT
	  cpi.intItemId
	, cpi.intCategoryId
	, cpi.strRebateBy
	, cpi.dblRebateRate
	, cpi.dtmBeginDate
	, cpi.dtmEndDate
	, cpi.intProgramId
	, cpi.intUnitMeasureId
	, cpi.intConcurrencyId
	, cpi.intRowNumber
	, @guiApiUniqueId
FROM @CreatedProgramItems cpi
JOIN tblVRProgram p ON p.intProgramId = cpi.intProgramId
JOIN tblVRVendorSetup vs ON vs.intVendorSetupId = p.intVendorSetupId
WHERE NOT EXISTS (
	SELECT TOP 1 xpi.intItemId, xpi.dtmBeginDate, xpi.dtmEndDate, xp.strProgram
	FROM tblVRProgramItem xpi
	JOIN tblVRProgram xp ON xp.intProgramId = xpi.intProgramId
	JOIN tblVRVendorSetup xvs ON xvs.intVendorSetupId = xp.intVendorSetupId
	JOIN vyuAPVendor xv ON xv.intEntityId = xvs.intEntityId
	WHERE xpi.intItemId = cpi.intItemId
		AND xvs.intEntityId = vs.intEntityId
		AND (cpi.dtmBeginDate <= xpi.dtmEndDate AND xpi.dtmBeginDate <= cpi.dtmEndDate)
)
AND NOT EXISTS (
	SELECT TOP 1 1
	FROM tblApiImportLogDetail
	WHERE guiApiImportLogId = @guiLogId
		AND intRowNo = cpi.intRowNumber
		AND strStatus = 'Failed'
		AND strLogLevel = 'Error'
		AND strAction = 'Skipped'
)
	
INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage, strAction)
SELECT
	  NEWID()
	, guiApiImportLogId = @guiLogId
	, strField = dbo.fnApiSchemaTransformMapField(@guiApiUniqueId, 'Vendor''s Customer')
	, strValue = vts.strVendorCustomer
	, strLogLevel = 'Error'
	, strStatus = 'Failed'
	, intRowNo = vts.intRowNumber
	, strMessage = 'The ' + dbo.fnApiSchemaTransformMapField(@guiApiUniqueId, 'Vendor''s Customer') + ' "' + vts.strVendorCustomer + '" does not exist.'
	, strAction = 'Skipped'
FROM tblApiSchemaTransformRebateProgram vts
LEFT JOIN vyuAPVendor v ON v.strName = vts.strVendor OR v.strVendorId = vts.strVendor
LEFT JOIN tblVRVendorSetup vs ON vs.intEntityId = v.intEntityId
LEFT JOIN tblVRCustomerXref x ON x.intVendorSetupId = vs.intVendorSetupId
	AND x.strVendorCustomer = vts.strVendorCustomer
WHERE vts.guiApiUniqueId = @guiApiUniqueId
	AND x.intCustomerXrefId IS NULL
	AND NULLIF(vts.strVendorCustomer, '') IS NOT NULL

INSERT INTO tblVRProgramCustomer (
	  guiApiUniqueId
	, intConcurrencyId
	, intEntityId
	, intProgramId
	, intRowNumber
)
SELECT
	  @guiApiUniqueId, 1
	, c.intEntityId
	, p.intProgramId
	, MAX(vts.intRowNumber)
FROM tblApiSchemaTransformRebateProgram vts
JOIN vyuAPVendor v ON v.strName = vts.strVendor OR v.strVendorId = vts.strVendor
JOIN tblVRVendorSetup vs ON vs.intEntityId = v.intEntityId
JOIN vyuARCustomer c ON c.strCustomerNumber = vts.strCustomer OR c.strName = vts.strCustomerName
JOIN @CreatedPrograms p ON p.intVendorSetupId = vs.intVendorSetupId
	AND p.strVendorProgram = vts.strVendorProgram
WHERE vts.guiApiUniqueId = @guiApiUniqueId
	AND NOT EXISTS (
		SELECT TOP 1 1 
		FROM tblVRProgramCustomer xc
		WHERE xc.intProgramId = p.intProgramId
			AND xc.intEntityId = c.intEntityId
	)
GROUP BY c.intEntityId, p.intProgramId, vs.intVendorSetupId, vts.strVendorProgram

INSERT INTO tblVRProgramCustomer (
	  guiApiUniqueId
	, intConcurrencyId
	, intEntityId
	, intProgramId
	, intRowNumber
)
SELECT
	  @guiApiUniqueId, 1
	, c.intEntityId
	, p.intProgramId
	, MAX(vts.intRowNumber)
FROM tblApiSchemaTransformRebateProgram vts
JOIN vyuAPVendor v ON v.strName = vts.strVendor OR v.strVendorId = vts.strVendor
JOIN tblVRVendorSetup vs ON vs.intEntityId = v.intEntityId
LEFT JOIN tblVRCustomerXref x ON x.intVendorSetupId = vs.intVendorSetupId
	AND x.strVendorCustomer = vts.strVendorCustomer
JOIN vyuARCustomer c ON c.intEntityId = x.intEntityId
JOIN @CreatedPrograms p ON p.intVendorSetupId = vs.intVendorSetupId
	AND p.strVendorProgram = vts.strVendorProgram
WHERE vts.guiApiUniqueId = @guiApiUniqueId
	AND NULLIF(vts.strCustomer, '') IS NULL
	AND NOT EXISTS (
		SELECT TOP 1 1 
		FROM tblVRProgramCustomer xc
		WHERE xc.intProgramId = p.intProgramId
			AND xc.intEntityId = c.intEntityId
	)
GROUP BY c.intEntityId, c.strName, c.strCustomerNumber, p.intProgramId, vs.intVendorSetupId, vts.strVendorProgram

INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage, strAction)
SELECT
      NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Rebate Vendor Program'
    , strValue = p.strProgram
    , strLogLevel = 'Info'
    , strStatus = 'Success'
    , intRowNo = p.intRowNumber
    , strMessage = 'The rebate vendor program ' + ISNULL(p.strProgram, '') + ' was imported successfully.'
    , strAction = 'Created'
FROM tblVRProgram p
WHERE p.guiApiUniqueId = @guiApiUniqueId

INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage, strAction)
SELECT
      NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Rebate Vendor Program Items'
    , strValue = p.strProgram
    , strLogLevel = 'Warning'
    , strStatus = 'Ignored'
    , intRowNo = p.intRowNumber
    , strMessage = 'The rebate vendor program ' + ISNULL(p.strProgram, '') + ' doesn''t have any program items.'
    , strAction = 'None'
FROM tblVRProgram p
WHERE p.guiApiUniqueId = @guiApiUniqueId
	AND NOT EXISTS (
		SELECT TOP 1 1
		FROM tblVRProgramItem
		WHERE intProgramId = p.intProgramId
	)

UPDATE log
SET log.intTotalRowsImported = ISNULL(rv.intCount, 0)
FROM tblApiImportLog log
OUTER APPLY (
	SELECT COUNT(*) intCount
	FROM tblVRProgramItem
	WHERE guiApiUniqueId = log.guiApiUniqueId
) rv
WHERE log.guiApiUniqueId = @guiApiUniqueId