CREATE PROCEDURE uspApiSchemaTransformRebateProgram 
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
	, strField = 'Item No'
	, strValue = vts.strItemNo
	, strLogLevel = 'Error'
	, strStatus = 'Failed'
	, intRowNo = vts.intRowNumber
	, strMessage = 'The Item No "' + vts.strItemNo + '" does not exist.'
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
	, strField = 'Item Name'
	, strValue = vts.strItemName
	, strLogLevel = 'Error'
	, strStatus = 'Failed'
	, intRowNo = vts.intRowNumber
	, strMessage = 'The Item Name "' + vts.strItemName + '" does not exist.'
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
	, strField = 'Vendor Item No'
	, strValue = vts.strVendorItemNo
	, strLogLevel = 'Error'
	, strStatus = 'Failed'
	, intRowNo = vts.intRowNumber
	, strMessage = 'The Vendor Item No "' + vts.strVendorItemNo + '" does not exist.'
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
	, strField = 'Category'
	, strValue = vts.strCategory
	, strLogLevel = 'Error'
	, strStatus = 'Failed'
	, intRowNo = vts.intRowNumber
	, strMessage = 'The Category "' + vts.strCategory + '" does not exist.'
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
	, strField = 'Rebate By'
	, strValue = vts.strRebateBy
	, strLogLevel = 'Error'
	, strStatus = 'Failed'
	, intRowNo = vts.intRowNumber
	, strMessage = 'The Rebate By "' + vts.strRebateBy + '" is not valid. Should be either "Unit" or "Percentage".'
	, strAction = 'Skipped'
FROM tblApiSchemaTransformRebateProgram vts
WHERE vts.guiApiUniqueId = @guiApiUniqueId
	AND vts.strRebateBy NOT IN ('Unit', 'Percentage')

INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage, strAction)
SELECT
	  NEWID()
	, guiApiImportLogId = @guiLogId
	, strField = 'Vendor Category'
	, strValue = vts.strVendorCategory
	, strLogLevel = 'Error'
	, strStatus = 'Failed'
	, intRowNo = vts.intRowNumber
	, strMessage = 'The Vendor Category "' + vts.strVendorCategory + '" does not exist.'
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
	, strField = 'Rebate UOM'
	, strValue = vts.strRebateUOM
	, strLogLevel = 'Error'
	, strStatus = 'Failed'
	, intRowNo = vts.intRowNumber
	, strMessage = 'The Rebate UOM "' + vts.strRebateUOM + '" does not exist.'
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
	, strField = 'Vendor Rebate UOM'
	, strValue = vts.strVendorRebateUOM
	, strLogLevel = 'Error'
	, strStatus = 'Failed'
	, intRowNo = vts.intRowNumber
	, strMessage = 'The Vendor Rebate UOM "' + vts.strVendorRebateUOM + '" does not exist.'
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
	, strField = 'Customer No'
	, strValue = vts.strCustomer
	, strLogLevel = 'Error'
	, strStatus = 'Failed'
	, intRowNo = vts.intRowNumber
	, strMessage = 'The Customer No "' + vts.strCustomer + '" does not exist.'
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
	, strField = 'Customer Name'
	, strValue = vts.strCustomerName
	, strLogLevel = 'Error'
	, strStatus = 'Failed'
	, intRowNo = vts.intRowNumber
	, strMessage = 'The Customer Name "' + vts.strCustomerName + '" does not exist.'
	, strAction = 'Skipped'
FROM tblApiSchemaTransformRebateProgram vts
LEFT JOIN vyuARCustomer c ON c.strName = vts.strCustomerName
WHERE vts.guiApiUniqueId = @guiApiUniqueId
	AND c.intEntityId IS NULL
	AND NULLIF(vts.strCustomer, '') IS NULL
	AND NULLIF(vts.strCustomerName, '') IS NOT NULL

DECLARE @UniquePrograms TABLE (
	  strVendorProgram NVARCHAR(20	) COLLATE Latin1_General_CI_AS
	, strProgramDescription NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
	, intVendorSetupId INT
	, ysnActive BIT NULL
	, intConcurrencyId INT
	, guiApiUniqueId UNIQUEIDENTIFIER
	, intRowNumber INT
)

INSERT INTO @UniquePrograms (strVendorProgram, strProgramDescription, intVendorSetupId, ysnActive, intConcurrencyId, guiApiUniqueId, intRowNumber)
SELECT DISTINCT
	  p.strVendorProgram
	, p.strDescription
	, vs.intVendorSetupId
	, CAST(1 AS BIT)
	, 1
	, @guiApiUniqueId
	, MIN(p.intRowNumber)
FROM tblApiSchemaTransformRebateProgram p
JOIN vyuAPVendor v ON v.strName = p.strVendor OR v.strVendorId = p.strVendor
JOIN tblVRVendorSetup vs ON vs.intEntityId = v.intEntityId
WHERE p.guiApiUniqueId = @guiApiUniqueId
	AND NOT EXISTS (
		SELECT TOP 1 1
		FROM tblApiImportLogDetail
		WHERE guiApiImportLogId = @guiLogId
			AND intRowNo = p.intRowNumber
			AND strStatus = 'Failed'
			AND strField = 'Vendor'
			AND strLogLevel = 'Error'
			AND strAction = 'Skipped'
	)
GROUP BY p.strVendorProgram
	, p.strDescription
	, vs.intVendorSetupId

INSERT INTO tblVRProgram (
	  strVendorProgram
	, strProgramDescription
	, intVendorSetupId
	, ysnActive
	, guiApiUniqueId
	, intRowNumber
	, intConcurrencyId
)
SELECT
	  p.strVendorProgram
	, p.strProgramDescription
	, p.intVendorSetupId
	, p.ysnActive
	, p.guiApiUniqueId
	, p.intRowNumber
	, p.intConcurrencyId
FROM @UniquePrograms p

DECLARE @CreatedPrograms TABLE (intProgramId INT, intVendorSetupId INT, strProgram NVARCHAR(200) COLLATE Latin1_General_CI_AS, strVendorProgram NVARCHAR(200) COLLATE Latin1_General_CI_AS)

DECLARE @intProgramId INT
DECLARE @intVendorSetupId INT
DECLARE @startingNo NVARCHAR(150)
DECLARE @strVendorProgram NVARCHAR(200)

DECLARE cur CURSOR LOCAL FAST_FORWARD
FOR
SELECT p.intProgramId, p.intVendorSetupId, p.strVendorProgram
FROM tblVRProgram p
WHERE p.guiApiUniqueId = @guiApiUniqueId

OPEN cur

FETCH NEXT FROM cur INTO @intProgramId, @intVendorSetupId, @strVendorProgram

WHILE @@FETCH_STATUS = 0
BEGIN
	EXEC dbo.uspSMGetStartingNumber 125, @startingNo OUTPUT
	UPDATE tblVRProgram
	SET strProgram = @startingNo
	WHERE intProgramId = @intProgramId

	INSERT INTO @CreatedPrograms(intProgramId, intVendorSetupId, strProgram, strVendorProgram)
	VALUES (@intProgramId, @intVendorSetupId, @startingNo, @strVendorProgram)

	FETCH NEXT FROM cur INTO @intProgramId, @intVendorSetupId, @strVendorProgram
END

CLOSE cur
DEALLOCATE cur


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
	  COALESCE(xi.intItemId, i.intItemId)
	, COALESCE(xc.intCategoryId, i.intCategoryId)
	, rp.strRebateBy
	, rp.dblRebateRate
	, rp.dtmBeginDate
	, rp.dtmEndDate
	, p.intProgramId
	, COALESCE(xu.intUnitMeasureId, u.intUnitMeasureId, du.intUnitMeasureId, 0)
	, 1
	, rp.intRowNumber
	, @guiApiUniqueId
FROM tblApiSchemaTransformRebateProgram rp
LEFT JOIN tblICItem i ON i.strItemNo = rp.strItemNo
	OR i.strDescription = rp.strItemName
JOIN tblVRProgram p ON p.strVendorProgram = rp.strVendorProgram
	AND p.guiApiUniqueId = @guiApiUniqueId
OUTER APPLY (
	SELECT TOP 1 xxi.intItemId
	FROM tblICItemVendorXref xxi
	WHERE xxi.strVendorProduct = rp.strVendorItemNo
	AND xxi.intVendorSetupId = p.intVendorSetupId
) xi
LEFT JOIN tblICUnitMeasure u ON u.strUnitMeasure = rp.strRebateUOM
OUTER APPLY (
	SELECT TOP 1 intUnitMeasureId 
	FROM tblVRUOMXref 
	WHERE strVendorUOM = rp.strVendorRebateUOM
	AND intVendorSetupId = p.intVendorSetupId
) xu
OUTER APPLY (
	SELECT TOP 1 intCategoryId
	FROM tblICCategoryVendor
	WHERE strVendorDepartment = rp.strVendorCategory
	AND intVendorSetupId = p.intVendorSetupId
) xc
OUTER APPLY (
	SELECT TOP 1 intUnitMeasureId
	FROM tblICItemUOM
	WHERE intItemId = i.intItemId
		AND ysnStockUnit = 1
) du
WHERE rp.guiApiUniqueId = @guiApiUniqueId
	AND NOT EXISTS (
		SELECT TOP 1 1
		FROM tblApiImportLogDetail
		WHERE guiApiImportLogId = @guiLogId
			AND intRowNo = rp.intRowNumber
			AND strStatus = 'Failed'
			AND strLogLevel = 'Error'
			AND strAction = 'Skipped'
	)


INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage, strAction)
SELECT
	  NEWID()
	, guiApiImportLogId = @guiLogId
	, strField = 'Vendor Customer'
	, strValue = vts.strVendorCustomer
	, strLogLevel = 'Error'
	, strStatus = 'Failed'
	, intRowNo = vts.intRowNumber
	, strMessage = 'The Vendor Customer "' + vts.strVendorCustomer + '" does not exist.'
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
)
SELECT ct.Id, 1, ct.EntityId, ct.ProgramId
FROM (
	SELECT
		@guiApiUniqueId Id
		, COALESCE(xc.intEntityId, c.intEntityId, nc.intEntityId) EntityId
		, p.intProgramId ProgramId
		, vs.intVendorSetupId VendorSetupId
		, vts.strVendorProgram
	FROM tblApiSchemaTransformRebateProgram vts
	LEFT JOIN vyuAPVendor v ON v.strName = vts.strVendor OR v.strVendorId = vts.strVendor
	LEFT JOIN tblVRVendorSetup vs ON vs.intEntityId = v.intEntityId
	LEFT JOIN vyuARCustomer c ON c.strCustomerNumber = vts.strCustomer
	LEFT JOIN tblVRCustomerXref x ON x.intVendorSetupId = vs.intVendorSetupId
		AND x.strVendorCustomer = vts.strVendorCustomer
	LEFT JOIN vyuARCustomer xc ON xc.intEntityId = x.intEntityId
	LEFT JOIN vyuARCustomer nc ON nc.strName = vts.strCustomerName
	LEFT JOIN @CreatedPrograms p ON p.intVendorSetupId = vs.intVendorSetupId
		AND p.strVendorProgram = vts.strVendorProgram
	WHERE vts.guiApiUniqueId = @guiApiUniqueId
	GROUP BY xc.intEntityId, c.intEntityId, nc.intEntityId, p.intProgramId, vs.intVendorSetupId, vts.strVendorProgram
) ct
WHERE ct.EntityId IS NOT NULL
GROUP BY ct.Id, ct.EntityId, ct.ProgramId, ct.VendorSetupId

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
SET log.intTotalRowsImported = r.intCount
FROM tblApiImportLog log
CROSS APPLY (
	SELECT COUNT(*) intCount
	FROM tblICItem
	WHERE guiApiUniqueId = log.guiApiUniqueId
) r
WHERE log.guiApiImportLogId = @guiLogId