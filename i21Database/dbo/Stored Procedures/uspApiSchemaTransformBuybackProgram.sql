CREATE PROCEDURE uspApiSchemaTransformBuybackProgram 
	@guiApiUniqueId UNIQUEIDENTIFIER,
	@guiLogId UNIQUEIDENTIFIER
AS

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
FROM tblApiSchemaTransformBuybackProgram vts
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
FROM tblApiSchemaTransformBuybackProgram vts
JOIN vyuAPVendor v ON v.strVendorId = vts.strVendor OR v.strName = vts.strVendor
WHERE vts.guiApiUniqueId = @guiApiUniqueId
	AND ISNULL(v.ysnPymtCtrlActive, 0) = 0

INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage, strAction)
SELECT
	  NEWID()
	, guiApiImportLogId = @guiLogId
	, strField = dbo.fnApiSchemaTransformMapField(@guiApiUniqueId, 'Customer Location') 
	, strValue = vts.strCustomerLocation
	, strLogLevel = 'Error'
	, strStatus = 'Failed'
	, intRowNo = vts.intRowNumber
	, strMessage = 'The ' + dbo.fnApiSchemaTransformMapField(@guiApiUniqueId, 'Customer Location') + ' "' + vts.strCustomerLocation + '" does not exist in the buyback vendor setup.'
	, strAction = 'Skipped'
FROM tblApiSchemaTransformBuybackProgram vts
JOIN vyuAPVendor v ON v.strVendorId = vts.strVendor OR v.strName = vts.strVendor
JOIN tblVRVendorSetup e ON e.intEntityId = v.intEntityId
LEFT JOIN tblEMEntityLocation l ON l.intEntityId = v.intEntityId
	AND l.strLocationName = vts.strCustomerLocation
LEFT JOIN tblBBCustomerLocationXref xc ON xc.intVendorSetupId = e.intVendorSetupId
	AND xc.intEntityLocationId = l.intEntityLocationId
WHERE vts.guiApiUniqueId = @guiApiUniqueId
	AND xc.intEntityLocationId IS NULL
	AND NULLIF(vts.strCustomerLocation, '') IS NOT NULL

INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage, strAction)
SELECT
	  NEWID()
	, guiApiImportLogId = @guiLogId
	, strField = dbo.fnApiSchemaTransformMapField(@guiApiUniqueId, 'Vendor''s Customer Location') 
	, strValue = vts.strVendorCustomerLocation
	, strLogLevel = 'Error'
	, strStatus = 'Failed'
	, intRowNo = vts.intRowNumber
	, strMessage = 'The ' + dbo.fnApiSchemaTransformMapField(@guiApiUniqueId, 'Vendor''s Customer Location') + ' "' + vts.strVendorCustomerLocation + '" does not exist in the buyback vendor setup.'
	, strAction = 'Skipped'
FROM tblApiSchemaTransformBuybackProgram vts
JOIN vyuAPVendor v ON v.strVendorId = vts.strVendor OR v.strName = vts.strVendor
JOIN tblVRVendorSetup e ON e.intEntityId = v.intEntityId
OUTER APPLY (
	SELECT TOP 1 xxc.strVendorCustomerLocation, xxc.intEntityLocationId
	FROM tblBBCustomerLocationXref xxc 
	WHERE xxc.intVendorSetupId = e.intVendorSetupId
	AND xxc.strVendorCustomerLocation = vts.strVendorCustomerLocation
) xc
WHERE vts.guiApiUniqueId = @guiApiUniqueId
	AND xc.intEntityLocationId IS NULL
	AND NULLIF(vts.strCustomerLocation, '') IS NULL
	AND NULLIF(vts.strVendorCustomerLocation, '') IS NOT NULL

INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage, strAction)
SELECT
	  NEWID()
	, guiApiImportLogId = @guiLogId
	, strField = dbo.fnApiSchemaTransformMapField(@guiApiUniqueId, 'UOM') 
	, strValue = vts.strUnitMeasure
	, strLogLevel = 'Warning'
	, strStatus = 'Failed'
	, intRowNo = vts.intRowNumber
	, strMessage = 'The ' + dbo.fnApiSchemaTransformMapField(@guiApiUniqueId, 'UOM') + ' "' + vts.strUnitMeasure + '" does not exist.'
	, strAction = 'Skipped'
FROM tblApiSchemaTransformBuybackProgram vts
LEFT JOIN tblICUnitMeasure u ON u.strUnitMeasure = vts.strUnitMeasure
WHERE vts.guiApiUniqueId = @guiApiUniqueId
	AND u.intUnitMeasureId IS NULL
	AND NULLIF(vts.strUnitMeasure, '') IS NOT NULL

INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage, strAction)
SELECT
	  NEWID()
	, guiApiImportLogId = @guiLogId
	, strField = dbo.fnApiSchemaTransformMapField(@guiApiUniqueId, 'Item No') 
	, strValue = vts.strItemNo
	, strLogLevel = 'Warning'
	, strStatus = 'Failed'
	, intRowNo = vts.intRowNumber
	, strMessage = 'The ' + dbo.fnApiSchemaTransformMapField(@guiApiUniqueId, 'Item No') + ' "' + vts.strItemNo + '" does not exist.'
	, strAction = 'Skipped'
FROM tblApiSchemaTransformBuybackProgram vts
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
	, strLogLevel = 'Warning'
	, strStatus = 'Failed'
	, intRowNo = vts.intRowNumber
	, strMessage = 'The ' + dbo.fnApiSchemaTransformMapField(@guiApiUniqueId, 'Item Name') + ' "' + vts.strItemName + '" does not exist.'
	, strAction = 'Skipped'
FROM tblApiSchemaTransformBuybackProgram vts
LEFT JOIN tblICItem i ON i.strDescription = vts.strItemName
WHERE vts.guiApiUniqueId = @guiApiUniqueId
	AND i.intItemId IS NULL
	AND NULLIF(vts.strItemName, '') IS NOT NULL
	AND NULLIF(vts.strItemNo, '') IS NULL

DECLARE @UniqueVendors TABLE (
	  intEntityId INT
	, strVendor NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
	, intVendorSetupId INT
	, strProgram NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
	, guiApiUniqueId UNIQUEIDENTIFIER
	, intRowNumber INT
)

INSERT INTO @UniqueVendors
SELECT v.intEntityId, vts.strVendor, vs.intVendorSetupId, vts.strProgramName, @guiApiUniqueId, MAX(vts.intRowNumber)
FROM tblApiSchemaTransformBuybackProgram vts
JOIN vyuAPVendor v ON v.strVendorId = vts.strVendor OR v.strName = vts.strVendor
JOIN tblVRVendorSetup vs ON vs.intEntityId = v.intEntityId
WHERE vts.guiApiUniqueId = @guiApiUniqueId
	AND v.ysnPymtCtrlActive = 1
GROUP BY v.intEntityId, vts.strVendor, vs.intVendorSetupId, vts.strProgramName
	
INSERT INTO tblBBProgram (
	  intVendorSetupId
	, strProgramName
	, strProgramDescription
	, strVendorProgramId
	, intConcurrencyId
	, guiApiUniqueId
	, intRowNumber
)
SELECT 
	  v.intVendorSetupId
	, vts.strProgramName
	, vts.strDescription
	, vts.strVendorProgram
	, 1
	, @guiApiUniqueId
	, vts.intRowNumber
FROM tblApiSchemaTransformBuybackProgram vts
JOIN @UniqueVendors v ON v.intRowNumber = vts.intRowNumber
WHERE vts.guiApiUniqueId = @guiApiUniqueId
	AND NOT EXISTS (
		SELECT TOP 1 1
		FROM tblBBProgram xp
		JOIN tblVRVendorSetup xvs ON xvs.intVendorSetupId = xp.intVendorSetupId
		WHERE xp.intVendorSetupId = v.intVendorSetupId
			AND ((xp.strProgramName = vts.strProgramName) OR (xp.strVendorProgramId = vts.strVendorProgram AND NULLIF(xp.strVendorProgramId, '') IS NOT NULL AND NULLIF(vts.strVendorProgram, '') IS NOT NULL))
			AND xvs.intEntityId = v.intEntityId
	)

UPDATE xp
SET   xp.strProgramName = vts.strProgramName
	, xp.guiApiUniqueId = @guiApiUniqueId
	, xp.strProgramDescription = vts.strDescription
	, xp.intConcurrencyId = xp.intConcurrencyId + 1
FROM tblBBProgram xp
JOIN tblVRVendorSetup xvs ON xvs.intVendorSetupId = xp.intVendorSetupId
JOIN vyuAPVendor v ON v.intEntityId = xvs.intEntityId
JOIN tblApiSchemaTransformBuybackProgram vts ON v.strVendorId = vts.strVendor OR v.strName = vts.strVendor
JOIN @UniqueVendors uv ON uv.intEntityId = v.intEntityId
WHERE vts.guiApiUniqueId = @guiApiUniqueId
	AND ((NULLIF(vts.strVendorProgram, '') IS NOT NULL AND vts.strVendorProgram = xp.strVendorProgramId)
	OR (NULLIF(vts.strVendorProgram, '') IS NULL AND vts.strProgramName = xp.strProgramName))
	AND NULLIF(xp.strProgramId, '') IS NOT NULL

DECLARE @CreatedPrograms TABLE (intProgramId INT, intVendorSetupId INT, strProgramId NVARCHAR(20) COLLATE Latin1_General_CI_AS, strProgramName NVARCHAR(200) COLLATE Latin1_General_CI_AS, strVendorProgram NVARCHAR(200) COLLATE Latin1_General_CI_AS)

DECLARE @intProgramId INT
DECLARE @intVendorSetupId INT
DECLARE @strProgramId NVARCHAR(20)
DECLARE @strProgramName NVARCHAR(200)
DECLARE @strVendorProgram NVARCHAR(200)

DECLARE cur CURSOR LOCAL FAST_FORWARD
FOR
-- SELECT xp.intProgramId, xp.intVendorSetupId, xp.strProgramId, xp.strProgramName,  xp.strVendorProgramId
-- FROM tblBBProgram xp
-- JOIN tblVRVendorSetup xvs ON xvs.intVendorSetupId = xp.intVendorSetupId
-- JOIN vyuAPVendor v ON v.intEntityId = xvs.intEntityId
-- JOIN tblApiSchemaTransformBuybackProgram vts ON v.strVendorId = vts.strVendor OR v.strName = vts.strVendor
-- WHERE xvs.guiApiUniqueId = @guiApiUniqueId
-- 	AND NOT ((NULLIF(vts.strVendorProgram, '') IS NOT NULL AND vts.strVendorProgram = xp.strVendorProgramId)
-- 	OR (NULLIF(vts.strVendorProgram, '') IS NULL AND vts.strProgramName = xp.strProgramName))
-- GROUP BY xp.intProgramId, xp.intVendorSetupId, xp.strProgramId, xp.strProgramName,  xp.strVendorProgramId
SELECT xp.intProgramId, xp.intVendorSetupId, xp.strProgramId, xp.strProgramName,  xp.strVendorProgramId
FROM tblBBProgram xp
WHERE xp.guiApiUniqueId = @guiApiUniqueId

OPEN cur

FETCH NEXT FROM cur INTO @intProgramId, @intVendorSetupId, @strProgramId, @strProgramName, @strVendorProgram

WHILE @@FETCH_STATUS = 0
BEGIN
	EXEC dbo.uspSMGetStartingNumber 129, @strProgramId OUTPUT
	UPDATE tblBBProgram
	SET strProgramId = @strProgramId
	WHERE intProgramId = @intProgramId
		AND intConcurrencyId = 1

	INSERT INTO @CreatedPrograms(intProgramId, intVendorSetupId, strProgramId, strProgramName, strVendorProgram)
	VALUES (@intProgramId, @intVendorSetupId, @strProgramId, @strProgramName, @strVendorProgram)

	FETCH NEXT FROM cur INTO @intProgramId, @intVendorSetupId, @strProgramId, @strProgramName, @strVendorProgram
END

CLOSE cur
DEALLOCATE cur

IF NOT EXISTS(SELECT TOP 1 1 FROM tblBBProgram WHERE guiApiUniqueId = @guiApiUniqueId)
BEGIN
	INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage, strAction)
	SELECT
		NEWID()
		, guiApiImportLogId = @guiLogId
		, strField = 'Buyback Program'
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
		FROM tblBBRate
		WHERE guiApiUniqueId = log.guiApiUniqueId
	) rv
	WHERE log.guiApiImportLogId = @guiLogId

	RETURN
END

INSERT INTO tblBBProgramCharge (
	  intProgramId
	, strCharge
	, guiApiUniqueId
	, intRowNumber
	, intConcurrencyId
)
SELECT DISTINCT
	  p.intProgramId
	, vts.strCharge
	, @guiApiUniqueId
	, MAX(vts.intRowNumber)
	, 1
FROM tblApiSchemaTransformBuybackProgram vts
JOIN vyuAPVendor v ON v.strVendorId = vts.strVendor OR v.strName = vts.strVendor
JOIN tblVRVendorSetup vs ON vs.intEntityId = v.intEntityId
JOIN @CreatedPrograms p ON p.intVendorSetupId = vs.intVendorSetupId
	AND vts.strProgramName = p.strProgramName
WHERE vts.guiApiUniqueId = @guiApiUniqueId
	AND NOT EXISTS (
		SELECT TOP 1 1
		FROM tblBBProgramCharge xpc
		WHERE xpc.intProgramId = p.intProgramId
			AND xpc.strCharge = vts.strCharge
	)
GROUP BY v.intEntityId, vts.strCharge, p.intProgramId
ORDER BY MAX(vts.intRowNumber)

INSERT INTO tblBBProgramCharge (
	  intProgramId
	, strCharge
	, guiApiUniqueId
	, intRowNumber
	, intConcurrencyId
)
SELECT DISTINCT
	  p.intProgramId
	, vts.strCharge
	, @guiApiUniqueId
	, MAX(vts.intRowNumber)
	, 1
FROM tblApiSchemaTransformBuybackProgram vts
JOIN vyuAPVendor v ON v.strVendorId = vts.strVendor OR v.strName = vts.strVendor
JOIN tblVRVendorSetup vs ON vs.intEntityId = v.intEntityId
JOIN tblBBProgram p ON p.intVendorSetupId = vs.intVendorSetupId
	AND vts.strProgramName = p.strProgramName
WHERE vts.guiApiUniqueId = @guiApiUniqueId
	AND NOT EXISTS (
		SELECT TOP 1 1
		FROM tblBBProgramCharge xpc
		WHERE xpc.intProgramId = p.intProgramId
			AND xpc.strCharge = vts.strCharge
	)
GROUP BY v.intEntityId, vts.strCharge, p.intProgramId
ORDER BY MAX(vts.intRowNumber)

UPDATE pc
SET pc.guiApiUniqueId = @guiApiUniqueId
FROM tblBBProgramCharge pc
JOIN tblBBProgram p ON p.intProgramId = pc.intProgramId
JOIN tblVRVendorSetup vs ON vs.intVendorSetupId = p.intVendorSetupId
JOIN vyuAPVendor v ON v.intEntityId = vs.intEntityId
JOIN tblApiSchemaTransformBuybackProgram bp ON bp.strCharge = pc.strCharge
	AND bp.strVendor = v.strVendorId OR bp.strVendor = v.strName
WHERE bp.guiApiUniqueId = @guiApiUniqueId

DECLARE @CreatedProgramRates TABLE(
	intProgramChargeId INT,
	strCharge NVARCHAR(200) COLLATE Latin1_General_CI_AS,
	intVendorSetupId INT,
	intEntityId INT,
	intProgramId INT,
	intEntityLocationId INT NULL,
	intItemId INT NULL,
	intUnitMeasureId INT NULL,
	dtmBeginDate DATETIME NULL,
	dtmEndDate DATETIME NULL,
	dblRate NUMERIC(38, 20),
	intRowNumber INT
)

INSERT INTO @CreatedProgramRates
SELECT
	  cp.intProgramChargeId
	, vts.strCharge
	, vr.intVendorSetupId
	, v.intEntityId
	, p.intProgramId
	, COALESCE(cl.intEntityLocationId, vcl.intEntityLocationId) intEntityLocationId
	, i.intItemId
	, u.intUnitMeasureId
	, vts.dtmBeginDate
	, vts.dtmEndDate
	, vts.dblRatePerUnit
	, vts.intRowNumber
FROM tblApiSchemaTransformBuybackProgram vts
JOIN tblBBProgramCharge cp ON cp.strCharge = vts.strCharge
	AND cp.guiApiUniqueId = @guiApiUniqueId
JOIN tblBBProgram p ON p.intProgramId = cp.intProgramId
	AND p.strProgramName = vts.strProgramName
JOIN tblVRVendorSetup vr ON vr.intVendorSetupId = p.intVendorSetupId
JOIN vyuAPVendor v ON v.intEntityId = vr.intEntityId
OUTER APPLY (
	SElECT TOP 1 c.intEntityLocationId
	FROM tblBBCustomerLocationXref c
	LEFT JOIN tblEMEntityLocation el ON el.intEntityLocationId = c.intEntityLocationId
	WHERE c.intVendorSetupId = p.intVendorSetupId
		AND el.strLocationName = vts.strCustomerLocation
		AND vts.strCustomerLocation IS NOT NULL
) cl
OUTER APPLY (
	SElECT TOP 1 c.intEntityLocationId
	FROM tblBBCustomerLocationXref c
	WHERE c.intVendorSetupId = p.intVendorSetupId
		AND c.strVendorCustomerLocation = vts.strVendorCustomerLocation
		AND vts.strVendorCustomerLocation IS NOT NULL
) vcl
LEFT JOIN tblICItem i ON (i.strItemNo = vts.strItemNo AND NULLIF(vts.strItemNo, '') IS NOT NULL)
	OR (NULLIF(vts.strItemNo, '') IS NULL AND vts.strItemName = i.strDescription)
LEFT JOIN tblICUnitMeasure u ON u.strUnitMeasure = vts.strUnitMeasure
WHERE vts.guiApiUniqueId = @guiApiUniqueId

INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage, strAction)
SELECT
	  NEWID()
	, guiApiImportLogId = @guiLogId
	, strField = dbo.fnApiSchemaTransformMapField(@guiApiUniqueId, 'Customer Location') + ', ' +
		dbo.fnApiSchemaTransformMapField(@guiApiUniqueId, 'Item No') + ', and/or ' +
		dbo.fnApiSchemaTransformMapField(@guiApiUniqueId, 'UOM')
	, strValue = ''
	, strLogLevel = 'Error'
	, strStatus = 'Failed'
	, intRowNo = vts.intRowNumber
	, strMessage = 'A program rate must at least specify any of the following fields: ' + 
		dbo.fnApiSchemaTransformMapField(@guiApiUniqueId, 'Customer Location') + ' and ' +
		dbo.fnApiSchemaTransformMapField(@guiApiUniqueId, 'Item No') + ' and ' +
		dbo.fnApiSchemaTransformMapField(@guiApiUniqueId, 'UOM') + '.' 
	, strAction = 'Skipped'
FROM @CreatedProgramRates vts
WHERE vts.intEntityLocationId IS NULL AND vts.intItemId IS NULL AND vts.intUnitMeasureId IS NULL

INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage, strAction)
SELECT
	  NEWID()
	, guiApiImportLogId = @guiLogId
	, strField = dbo.fnApiSchemaTransformMapField(@guiApiUniqueId, 'Begin Date') + ' and/or ' + dbo.fnApiSchemaTransformMapField(@guiApiUniqueId, 'End Date')
	, strValue = CONVERT(NVARCHAR(100), cpr.dtmBeginDate, 101) + ' - ' + CONVERT(NVARCHAR(100), cpr.dtmEndDate, 101)
	, strLogLevel = 'Error'
	, strStatus = 'Failed'
	, intRowNo = cpr.intRowNumber
	, strMessage = 'The date range from ' + CONVERT(NVARCHAR(100), cpr.dtmBeginDate, 101) + ' to ' + CONVERT(NVARCHAR(100), cpr.dtmEndDate, 101)
		+ ' overlaps with existing rates for the customer location ' + el.strLocationName + ' of the vendor ' + v.strName + '.'
	, strAction = 'Skipped'
FROM @CreatedProgramRates cpr
JOIN tblVRVendorSetup vs ON vs.intVendorSetupId = cpr.intVendorSetupId
JOIN vyuAPVendor v ON v.intEntityId = vs.intEntityId
JOIN tblEMEntityLocation el ON el.intEntityLocationId = cpr.intEntityLocationId
OUTER APPLY (
	SELECT TOP 1 xr.dblRatePerUnit
	FROM tblBBRate xr
	JOIN tblBBProgramCharge xpc ON xpc.intProgramChargeId = xr.intProgramChargeId
	JOIN tblBBProgram xp ON xp.intProgramId = xpc.intProgramId
	JOIN tblVRVendorSetup xvs ON xvs.intVendorSetupId = xp.intVendorSetupId
	JOIN vyuAPVendor xv ON xv.intEntityId = xvs.intEntityId
	JOIN tblEMEntityLocation xel ON xel.intEntityLocationId = xr.intCustomerLocationId
	WHERE xr.intCustomerLocationId = cpr.intEntityLocationId
		AND xr.intCustomerLocationId = cpr.intEntityLocationId
		AND ((xr.intUnitMeasureId = cpr.intUnitMeasureId AND xr.intUnitMeasureId IS NOT NULL AND xr.intItemId IS NULL)
			OR (xr.intItemId = cpr.intItemId AND xr.intItemId IS NOT NULL))
		AND (cpr.dtmBeginDate <= xr.dtmEndDate AND xr.dtmBeginDate <= cpr.dtmEndDate)
		AND NOT (
			ISNULL(cpr.intEntityLocationId, 0) = ISNULL(xr.intCustomerLocationId, 0)
			AND ISNULL(cpr.intItemId, 0) = ISNULL(xr.intItemId, 0)
			AND ISNULL(cpr.intUnitMeasureId, 0) = ISNULL(xr.intUnitMeasureId, 0)
			AND cpr.intProgramChargeId = xr.intProgramChargeId
			AND cpr.dtmBeginDate = xr.dtmBeginDate
			AND cpr.dtmEndDate = xr.dtmEndDate
		)
) r
WHERE r.dblRatePerUnit IS NOT NULL

-- INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage, strAction)
-- SELECT
-- 	  NEWID()
-- 	, guiApiImportLogId = @guiLogId
-- 	, strField = dbo.fnApiSchemaTransformMapField(@guiApiUniqueId, 'Begin Date') + ' and/or ' + dbo.fnApiSchemaTransformMapField(@guiApiUniqueId, 'End Date')
-- 	, strValue = CONVERT(NVARCHAR(100), cpr.dtmBeginDate, 101) + ' - ' + CONVERT(NVARCHAR(100), cpr.dtmEndDate, 101)
-- 	, strLogLevel = 'Error'
-- 	, strStatus = 'Failed'
-- 	, intRowNo = cpr.intRowNumber
-- 	, strMessage = 'The date range from ' + CONVERT(NVARCHAR(100), cpr.dtmBeginDate, 101) + ' to ' + CONVERT(NVARCHAR(100), cpr.dtmEndDate, 101)
-- 		+ ' overlaps with existing UOM rates for the customer location ' + el.strLocationName + ' of the vendor ' + v.strName + '.'
-- 	, strAction = 'Skipped'
-- FROM @CreatedProgramRates cpr
-- JOIN tblVRVendorSetup vs ON vs.intVendorSetupId = cpr.intVendorSetupId
-- JOIN vyuAPVendor v ON v.intEntityId = vs.intEntityId
-- JOIN tblEMEntityLocation el ON el.intEntityLocationId = cpr.intEntityLocationId
-- CROSS APPLY (
-- 	SELECT TOP 1 xr.dblRatePerUnit
-- 	FROM tblBBRate xr
-- 	JOIN tblBBProgramCharge xpc ON xpc.intProgramChargeId = xr.intProgramChargeId
-- 	JOIN tblBBProgram xp ON xp.intProgramId = xpc.intProgramId
-- 	JOIN tblVRVendorSetup xvs ON xvs.intVendorSetupId = xp.intVendorSetupId
-- 	JOIN vyuAPVendor xv ON xv.intEntityId = xvs.intEntityId
-- 	JOIN tblEMEntityLocation xel ON xel.intEntityLocationId = xr.intCustomerLocationId
-- 	WHERE xr.intCustomerLocationId = cpr.intEntityLocationId
-- 		AND xr.intUnitMeasureId = cpr.intUnitMeasureId
-- 		AND cpr.intUnitMeasureId IS NOT NULL
-- 		AND xr.dtmBeginDate <= cpr.dtmEndDate AND cpr.dtmBeginDate <= xr.dtmEndDate
-- ) r
INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage, strAction)
SELECT
	  NEWID()
	, guiApiImportLogId = @guiLogId
	, strField = dbo.fnApiSchemaTransformMapField(@guiApiUniqueId, 'Begin Date') + ' and/or ' + dbo.fnApiSchemaTransformMapField(@guiApiUniqueId, 'End Date')
	, strValue = CONVERT(NVARCHAR(100), pr.dtmBeginDate, 101) + ' - ' + CONVERT(NVARCHAR(100), pr.dtmEndDate, 101)
	, strLogLevel = 'Error'
	, strStatus = 'Failed'
	, intRowNo = pr.intRowNumber
	, strMessage = 'The date range from ' + CONVERT(NVARCHAR(100), pr.dtmBeginDate, 101) + ' to ' + CONVERT(NVARCHAR(100), pr.dtmEndDate, 101)
		+ ' overlaps with existing rates for the customer location ' + el.strLocationName + ' of the vendor ' + v.strName + ' at line #' + CAST(f.intRowNumber AS NVARCHAR(50)) + ' in this file.'
	, strAction = 'Skipped'
FROM @CreatedProgramRates pr
JOIN vyuAPVendor v ON v.intEntityId = pr.intEntityId
JOIN tblEMEntityLocation el ON el.intEntityLocationId = pr.intEntityLocationId
	AND el.intEntityId = pr.intEntityId
OUTER APPLY (
	SELECT TOP 1 xpr.intRowNumber
	FROM @CreatedProgramRates xpr
	WHERE xpr.intRowNumber < pr.intRowNumber
		AND xpr.intEntityId = pr.intEntityId
		AND xpr.intEntityLocationId = pr.intEntityLocationId
		AND ((xpr.intUnitMeasureId = pr.intUnitMeasureId AND xpr.intUnitMeasureId IS NOT NULL AND xpr.intItemId IS NULL)
			OR (xpr.intItemId = pr.intItemId AND xpr.intItemId IS NOT NULL))
		AND (pr.dtmBeginDate <= xpr.dtmEndDate AND xpr.dtmBeginDate <= pr.dtmEndDate)
) f
WHERE NOT EXISTS (
	SELECT TOP 1 1
	FROM tblBBRate xr
	JOIN tblBBProgramCharge xpc ON xpc.intProgramChargeId = xr.intProgramChargeId
	JOIN tblBBProgram xp ON xp.intProgramId = xpc.intProgramId
	JOIN tblVRVendorSetup xvs ON xvs.intVendorSetupId = xp.intVendorSetupId
	JOIN vyuAPVendor xv ON xv.intEntityId = xvs.intEntityId
	JOIN tblEMEntityLocation xel ON xel.intEntityLocationId = xr.intCustomerLocationId
	WHERE xr.intCustomerLocationId = pr.intEntityLocationId
		AND ((xr.intUnitMeasureId = pr.intUnitMeasureId) OR (xr.intItemId = pr.intItemId))
		AND pr.dtmBeginDate <= xr.dtmEndDate AND xr.dtmBeginDate <= pr.dtmEndDate
		AND xr.guiApiUniqueId = @guiApiUniqueId
) AND f.intRowNumber IS NOT NULL

DECLARE @CreatedProgramRatesOriginal TABLE(
	intProgramChargeId INT,
	strCharge NVARCHAR(200) COLLATE Latin1_General_CI_AS,
	intVendorSetupId INT,
	intEntityId INT,
	intProgramId INT,
	intEntityLocationId INT NULL,
	intItemId INT NULL,
	intUnitMeasureId INT NULL,
	dtmBeginDate DATETIME NULL,
	dtmEndDate DATETIME NULL,
	dblRate NUMERIC(38, 20),
	intRowNumber INT
)

INSERT INTO @CreatedProgramRatesOriginal
SELECT * FROM @CreatedProgramRates
ORDER BY intRowNumber DESC

DELETE pr
FROM @CreatedProgramRates pr
WHERE EXISTS (
	SELECT *
	FROM @CreatedProgramRatesOriginal xpr
	WHERE xpr.intRowNumber < pr.intRowNumber
		AND xpr.intEntityId = pr.intEntityId
		AND NULLIF(xpr.intEntityLocationId, 0) = NULLIF(pr.intEntityLocationId, 0)
		AND ((xpr.intUnitMeasureId = pr.intUnitMeasureId AND xpr.intUnitMeasureId IS NOT NULL AND xpr.intItemId IS NULL)
			OR (xpr.intItemId = pr.intItemId AND xpr.intItemId IS NOT NULL))
		AND pr.dtmBeginDate <= xpr.dtmEndDate AND xpr.dtmBeginDate <= pr.dtmEndDate
)

INSERT INTO tblBBRate (
	  intProgramChargeId
	, intCustomerLocationId
	, intItemId
	, intUnitMeasureId
	, dtmBeginDate
	, dtmEndDate
	, dblRatePerUnit
	, intConcurrencyId
	, guiApiUniqueId
	, intRowNumber
)
SELECT
	  r.intProgramChargeId
	, r.intEntityLocationId
	, r.intItemId
	, r.intUnitMeasureId
	, r.dtmBeginDate
	, r.dtmEndDate
	, r.dblRate
	, 1
	, @guiApiUniqueId
	, r.intRowNumber
FROM @CreatedProgramRates r
OUTER APPLY (
	SELECT TOP 1 xr.*
	FROM tblBBRate xr
	JOIN tblBBProgramCharge xpc ON xpc.intProgramChargeId = xr.intProgramChargeId
	JOIN tblBBProgram xp ON xp.intProgramId = xpc.intProgramId
	JOIN tblVRVendorSetup xvs ON xvs.intVendorSetupId = xp.intVendorSetupId
	JOIN vyuAPVendor xv ON xv.intEntityId = xvs.intEntityId
	WHERE (xr.intCustomerLocationId = r.intEntityLocationId
		AND ((xr.intItemId = r.intItemId AND r.intItemId IS NOT NULL)
			OR (xr.intUnitMeasureId = r.intUnitMeasureId AND r.intUnitMeasureId IS NOT NULL AND r.intItemId IS NULL))
		AND r.dtmBeginDate <= xr.dtmEndDate AND xr.dtmBeginDate <= r.dtmEndDate
		AND NOT (
			xr.intCustomerLocationId = r.intEntityLocationId
			AND ((xr.intUnitMeasureId = r.intUnitMeasureId) OR (xr.intItemId = r.intItemId))
			AND r.dtmBeginDate <= xr.dtmEndDate AND xr.dtmBeginDate <= r.dtmEndDate
		))
		-- This line is to fix duplicate rate when location is null
		OR (
			ISNULL(xr.intCustomerLocationId, 0) = ISNULL(r.intEntityLocationId, 0)
			AND ISNULL(xr.intItemId, 0) = ISNULL(r.intItemId, 0)
			AND ISNULL(xr.intUnitMeasureId, 0) = ISNULL(r.intUnitMeasureId, 0)
			AND xr.intProgramChargeId = r.intProgramChargeId
			AND xr.dtmBeginDate = r.dtmBeginDate
			AND xr.dtmEndDate = r.dtmEndDate
		)
) x
WHERE NOT (r.intEntityLocationId IS NULL AND r.intItemId IS NULL AND r.intUnitMeasureId IS NULL)
	AND x.intRateId IS NULL
	AND NOT EXISTS (
		SELECT TOP 1 1
		FROM tblApiImportLogDetail xd
		WHERE xd.guiApiImportLogId = @guiLogId
			AND xd.intRowNo = r.intRowNumber
			AND xd.strLogLevel = 'Error'
			AND xd.strStatus = 'Failed'
	)

UPDATE r
SET   r.guiApiUniqueId = @guiApiUniqueId
	, r.dblRatePerUnit = cr.dblRate
	, r.intRowNumber = cr.intRowNumber
FROM tblBBRate r
JOIN tblBBProgramCharge xpc ON xpc.intProgramChargeId = r.intProgramChargeId
JOIN tblBBProgram xp ON xp.intProgramId = xpc.intProgramId
JOIN tblVRVendorSetup xvs ON xvs.intVendorSetupId = xp.intVendorSetupId
JOIN vyuAPVendor xv ON xv.intEntityId = xvs.intEntityId
LEFT JOIN tblEMEntityLocation xel ON xel.intEntityLocationId = r.intCustomerLocationId
JOIN @CreatedProgramRates cr ON cr.intEntityId = xv.intEntityId
	AND cr.intProgramId = xp.intProgramId
	AND ISNULL(cr.intEntityLocationId, 0) = ISNULL(r.intCustomerLocationId, 0)
	AND ISNULL(cr.intItemId, 0) = ISNULL(r.intItemId, 0)
	AND ISNULL(cr.intUnitMeasureId, 0) = ISNULL(r.intUnitMeasureId, 0)
	AND cr.intProgramChargeId = r.intProgramChargeId
	AND cr.dtmBeginDate = r.dtmBeginDate
	AND cr.dtmEndDate = r.dtmEndDate
	AND NOT EXISTS (
		SELECT TOP 1 1
		FROM tblApiImportLogDetail xd
		WHERE xd.guiApiImportLogId = @guiLogId
			AND xd.intRowNo = r.intRowNumber
			AND xd.strLogLevel = 'Error'
			AND xd.strStatus = 'Failed'
	)

INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage, strAction)
SELECT
      NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Buyback Program'
    , strValue = CAST(r.dblRatePerUnit AS NVARCHAR(200))
    , strLogLevel = 'Info'
    , strStatus = 'Success'
    , intRowNo = r.intRowNumber
    , strMessage = 'The buyback program with rate ' + ISNULL(CAST(r.dblRatePerUnit AS NVARCHAR(200)), '') + ' was imported successfully.'
    , strAction = 'Create'
FROM tblBBRate r
WHERE r.guiApiUniqueId = @guiApiUniqueId

INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage, strAction)
SELECT
      NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Buyback Program'
    , strValue = xp.strProgramName
    , strLogLevel = 'Info'
    , strStatus = 'Success'
    , intRowNo = MAX(vts.intRowNumber)
    , strMessage = 'The buyback program was updated successfully.'
    , strAction = 'Update'
FROM tblBBProgram xp
JOIN tblVRVendorSetup xvs ON xvs.intVendorSetupId = xp.intVendorSetupId
JOIN vyuAPVendor v ON v.intEntityId = xvs.intEntityId
JOIN tblApiSchemaTransformBuybackProgram vts ON v.strVendorId = vts.strVendor OR v.strName = vts.strVendor
WHERE vts.guiApiUniqueId = @guiApiUniqueId
	AND ((NULLIF(vts.strVendorProgram, '') IS NOT NULL AND vts.strVendorProgram = xp.strVendorProgramId)
	OR (NULLIF(vts.strVendorProgram, '') IS NULL AND vts.strProgramName = xp.strProgramName))
GROUP BY xp.strProgramName

UPDATE log
SET log.intTotalRowsImported = ISNULL(rv.intCount, 0)
FROM tblApiImportLog log
OUTER APPLY (
	SELECT COUNT(*) intCount
	FROM tblBBRate
	WHERE guiApiUniqueId = log.guiApiUniqueId
) rv
WHERE log.guiApiImportLogId = @guiLogId