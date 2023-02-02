CREATE PROCEDURE uspApiSchemaTransformBuybackVendorSetup 
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
	, strField = dbo.fnApiSchemaTransformMapField(@guiApiUniqueId, 'Vendor')
	, strValue = vts.strVendor
	, strLogLevel = 'Error'
	, strStatus = 'Failed'
	, intRowNo = vts.intRowNumber
	, strMessage = 'The vendor "' + vts.strVendor + '" does not exist.'
	, strAction = 'Skipped'
FROM tblApiSchemaTransformBuybackVendorSetup vts
LEFT JOIN vyuAPVendor v ON v.strVendorId = vts.strVendor OR v.strName = vts.strVendor
WHERE vts.guiApiUniqueId = @guiApiUniqueId
	AND v.intEntityId IS NULL

INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage, strAction)
SELECT
	  NEWID()
	, guiApiImportLogId = @guiLogId
	, strField = dbo.fnApiSchemaTransformMapField(@guiApiUniqueId, 'Export File Type')
	, strValue = vts.strBuybackExportFileType
	, strLogLevel = 'Warning'
	, strStatus = 'Failed'
	, intRowNo = vts.intRowNumber
	, strMessage = 'Invalid export file type "' + vts.strBuybackExportFileType + '". Valid types are: CSV, TXT, XML.'
	, strAction = 'Skipped'
FROM tblApiSchemaTransformBuybackVendorSetup vts
WHERE vts.guiApiUniqueId = @guiApiUniqueId
	AND NULLIF(vts.strBuybackExportFileType, '') IS NOT NULL
	AND vts.strBuybackExportFileType NOT IN ('CSV', 'TXT', 'XML')

INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage, strAction)
SELECT
	  NEWID()
	, guiApiImportLogId = @guiLogId
	, strField = dbo.fnApiSchemaTransformMapField(@guiApiUniqueId, 'Reimbursement Type')
	, strValue = vts.strReimbursementType
	, strLogLevel = 'Warning'
	, strStatus = 'Failed'
	, intRowNo = vts.intRowNumber
	, strMessage = 'Invalid reimbursement type "' + vts.strReimbursementType + '". Valid types are: AP, AR.'
	, strAction = 'Skipped'
FROM tblApiSchemaTransformBuybackVendorSetup vts
WHERE vts.guiApiUniqueId = @guiApiUniqueId
	AND NULLIF(vts.strReimbursementType, '') IS NOT NULL
	AND vts.strReimbursementType NOT IN ('AP', 'AR')

INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage, strAction)
SELECT
	  NEWID()
	, guiApiImportLogId = @guiLogId
	, strField = dbo.fnApiSchemaTransformMapField(@guiApiUniqueId, 'Customer Location')
	, strValue = vts.strLocation
	, strLogLevel = 'Error'
	, strStatus = 'Failed'
	, intRowNo = vts.intRowNumber
	, strMessage = 'The ' + dbo.fnApiSchemaTransformMapField(@guiApiUniqueId, 'Customer Location') + ' "' + ISNULL(vts.strLocation, '') + '" is not setup for the vendor ' + ISNULL(vts.strVendor, '') + '.'
	, strAction = 'Skipped'
FROM tblApiSchemaTransformBuybackVendorSetup vts
LEFT JOIN vyuAPVendor v ON v.strVendorId = vts.strVendor OR v.strName = vts.strVendor
LEFT JOIN tblVRVendorSetup e ON e.intEntityId = v.intEntityId
LEFT JOIN tblEMEntityLocation el ON (el.strLocationName = vts.strLocation)
	AND el.intEntityId = v.intEntityId
WHERE vts.guiApiUniqueId = @guiApiUniqueId
	AND NULLIF(vts.strLocation, '') IS NOT NULL
	AND el.intEntityId IS NULL

INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage, strAction)
SELECT
	  NEWID()
	, guiApiImportLogId = @guiLogId
	, strField = dbo.fnApiSchemaTransformMapField(@guiApiUniqueId, 'Income GL Account') 
	, strValue = vts.strGLAccount
	, strLogLevel = 'Warning'
	, strStatus = 'Failed'
	, intRowNo = vts.intRowNumber
	, strMessage = 'The ' + dbo.fnApiSchemaTransformMapField(@guiApiUniqueId, 'Income GL Account') + ' "' + ISNULL(vts.strGLAccount, '') + '" is invalid.'
	, strAction = 'Skipped'
FROM tblApiSchemaTransformBuybackVendorSetup vts
OUTER APPLY (
	SELECT TOP 1 strGLAccount
	FROM vyuGLAccountDetail
	WHERE strAccountCategory = 'General'
		AND strAccountId = vts.strGLAccount
) a
WHERE vts.guiApiUniqueId = @guiApiUniqueId
	AND NULLIF(vts.strGLAccount, '') IS NOT NULL
	AND a.strGLAccount IS NULL

DECLARE @UniqueSetups TABLE (
	  intEntityId INT
	, strBuybackExportFileType NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	, strBuybackExportFilePath NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
	, strCompany1Id NVARCHAR(300) COLLATE Latin1_General_CI_AS NULL
	, strCompany2Id NVARCHAR(300) COLLATE Latin1_General_CI_AS NULL
	, strReimbursementType NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	, intGLAccountId INT NULL
	, intConcurrencyId INT
	, guiApiUniqueId UNIQUEIDENTIFIER
	, intRowNumber INT
)

INSERT INTO @UniqueSetups (
	  intEntityId
	, strBuybackExportFileType
	, strBuybackExportFilePath
	, strCompany1Id
	, strCompany2Id
	, strReimbursementType
	, intGLAccountId
	, intConcurrencyId
	, guiApiUniqueId
	, intRowNumber
)
SELECT
	  v.intEntityId
	, vs.strBuybackExportFileType
	, vs.strBuybackExportFilePath
	, vs.strCompany1Id
	, vs.strCompany2Id
	, vs.strReimbursementType
	, a.intAccountId
	, 1
	, @guiApiUniqueId
	, vs.intRowNumber
FROM tblApiSchemaTransformBuybackVendorSetup vs
JOIN vyuAPVendor v ON v.strVendorId = vs.strVendor OR v.strName = vs.strVendor
OUTER APPLY (
	SELECT TOP 1 intAccountId
	FROM vyuGLAccountDetail
	WHERE strAccountCategory = 'General'
		AND strAccountId = vs.strGLAccount
) a
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
	, strBuybackExportFileType
	, strBuybackExportFilePath
	, strCompany1Id
	, strCompany2Id
	, strReimbursementType
	, intAccountId
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
FROM tblApiSchemaTransformBuybackVendorSetup vs
JOIN vyuAPVendor v ON v.strVendorId = vs.strVendor OR v.strName = vs.strVendor
JOIN tblVRVendorSetup e ON e.intEntityId = v.intEntityId 
WHERE vs.guiApiUniqueId = @guiApiUniqueId
	AND @OverwriteExisting = 1

UPDATE vs
SET 
	  vs.guiApiUniqueId = @guiApiUniqueId
	, vs.intRowNumber = sr.intRowNumber
	, vs.strBuybackExportFilePath = CASE dbo.fnApiSchemaTransformHasField(@guiApiUniqueId, 'Export File Path') WHEN 1 THEN sr.strBuybackExportFilePath ELSE vs.strBuybackExportFilePath END
	, vs.strBuybackExportFileType = CASE dbo.fnApiSchemaTransformHasField(@guiApiUniqueId, 'Export File Type') WHEN 1 THEN sr.strBuybackExportFileType ELSE vs.strBuybackExportFileType END
	, vs.strCompany1Id = CASE dbo.fnApiSchemaTransformHasField(@guiApiUniqueId, 'Company ID1') WHEN 1 THEN sr.strCompany1Id ELSE vs.strCompany1Id END
	, vs.strCompany2Id = CASE dbo.fnApiSchemaTransformHasField(@guiApiUniqueId, 'Company ID2') WHEN 1 THEN sr.strCompany2Id ELSE vs.strCompany2Id END
	, vs.strReimbursementType = CASE dbo.fnApiSchemaTransformHasField(@guiApiUniqueId, 'Reimbursement Type') WHEN 1 THEN sr.strReimbursementType ELSE vs.strReimbursementType END
	, vs.intConcurrencyId = ISNULL(vs.intConcurrencyId, 1) + 1
	, vs.intAccountId = CASE dbo.fnApiSchemaTransformHasField(@guiApiUniqueId, 'Income GL Account') WHEN 1 THEN a.intAccountId ELSE vs.intAccountId END
FROM tblVRVendorSetup vs
JOIN vyuAPVendor v ON v.intEntityId = vs.intEntityId
JOIN tblApiSchemaTransformBuybackVendorSetup sr ON sr.strVendor = v.strVendorId OR sr.strVendor = v.strName
OUTER APPLY (
	SELECT TOP 1 intAccountId
	FROM vyuGLAccountDetail
	WHERE strAccountCategory = 'General'
		AND strAccountId = sr.strGLAccount
) a

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

DECLARE @CustomerLocationForUpdates TABLE (intVendorSetupId INT, intEntityLocationId INT, 
	strVendorCustomerLocation NVARCHAR(50) COLLATE Latin1_General_CI_AS, 
	strVendorShipTo NVARCHAR(20) COLLATE Latin1_General_CI_AS,
	strVendorSoldTo NVARCHAR(20) COLLATE Latin1_General_CI_AS,
	intRowNumber INT NULL)
INSERT INTO @CustomerLocationForUpdates
SELECT e.intVendorSetupId, xc.intEntityLocationId, xc.strVendorCustomerLocation, xc.strVendorShipTo, xc.strVendorSoldTo, vs.intRowNumber
FROM tblApiSchemaTransformBuybackVendorSetup vs
JOIN vyuAPVendor v ON v.strVendorId = vs.strVendor OR v.strName = vs.strVendor
JOIN tblVRVendorSetup e ON e.intEntityId = v.intEntityId
JOIN tblEMEntityLocation l ON l.intEntityId = v.intEntityId
JOIN tblBBCustomerLocationXref xc ON xc.intVendorSetupId = e.intVendorSetupId
	AND xc.intEntityLocationId = l.intEntityLocationId
	AND xc.strVendorCustomerLocation = vs.strVendorCustomerLocation
WHERE vs.guiApiUniqueId = @guiApiUniqueId
	AND @OverwriteExisting = 1

UPDATE xc
SET   xc.guiApiUniqueId = @guiApiUniqueId
	-- , xc.intEntityLocationId = l.intEntityLocationId
	, xc.strVendorCustomerLocation = vs.strVendorCustomerLocation
	, xc.strVendorShipTo = vs.strVendorShipTo
	, xc.strVendorSoldTo = vs.strVendorSoldTo
	, xc.intRowNumber = vs.intRowNumber
FROM tblBBCustomerLocationXref xc
JOIN tblApiSchemaTransformBuybackVendorSetup vs ON xc.intVendorSetupId = xc.intVendorSetupId
	AND xc.strVendorCustomerLocation = vs.strVendorCustomerLocation
JOIN vyuAPVendor v ON v.strVendorId = vs.strVendor OR v.strName = vs.strVendor
JOIN tblVRVendorSetup e ON e.intEntityId = v.intEntityId
JOIN tblEMEntityLocation l ON l.intEntityId = v.intEntityId
WHERE vs.guiApiUniqueId = @guiApiUniqueId
	AND @OverwriteExisting = 1

DECLARE @UniqueCustomerLocations TABLE (
	  intEntityLocationId INT
	, intVendorSetupId INT
	, strVendorCustomerLocation NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL
	, strVendorShipTo NVARCHAR(20) COLLATE Latin1_General_CI_AS NULL
	, strVendorSoldTo NVARCHAR(20) COLLATE Latin1_General_CI_AS NULL
	, guiApiUniqueId UNIQUEIDENTIFIER
	, intRowNumber INT
)

INSERT INTO @UniqueCustomerLocations (
	  intEntityLocationId
	, intVendorSetupId
	, strVendorCustomerLocation
	, strVendorShipTo
	, strVendorSoldTo
	, guiApiUniqueId
	, intRowNumber
)
SELECT
	  l.intEntityLocationId
	, vs.intVendorSetupId
	, vts.strVendorCustomerLocation
	, vts.strVendorShipTo
	, vts.strVendorSoldTo
	, @guiApiUniqueId
	, vts.intRowNumber
FROM tblApiSchemaTransformBuybackVendorSetup vts
JOIN tblEMEntity e ON e.strEntityNo = vts.strVendor OR e.strName = vts.strVendor
JOIN tblAPVendor v ON e.intEntityId = v.intEntityId
JOIN tblVRVendorSetup vs ON vs.intEntityId = v.intEntityId
JOIN tblEMEntityLocation l ON e.intEntityId = l.intEntityId
	AND (vts.strLocation = l.strLocationName)
WHERE vts.guiApiUniqueId = @guiApiUniqueId

;WITH cte AS
(
   SELECT *, ROW_NUMBER() OVER(PARTITION BY sr.intEntityLocationId ORDER BY sr.intEntityLocationId) AS RowNumber
   FROM @UniqueCustomerLocations sr
   WHERE sr.guiApiUniqueId = @guiApiUniqueId
)
DELETE FROM cte
WHERE guiApiUniqueId = @guiApiUniqueId
  AND RowNumber > 1;

MERGE tblBBCustomerLocationXref AS Target
USING (
	SELECT
		  c.intEntityLocationId
		, c.intVendorSetupId
		, c.strVendorCustomerLocation
		, c.strVendorShipTo
		, c.strVendorSoldTo
		, 1 intConcurrencyId
		, c.guiApiUniqueId
		, c.intRowNumber
	FROM @UniqueCustomerLocations c
) AS Source
ON Source.intVendorSetupId = Target.intVendorSetupId
	AND Source.intEntityLocationId = Target.intEntityLocationId
    
-- For Inserts
WHEN NOT MATCHED BY Target THEN
    INSERT (intEntityLocationId, intVendorSetupId, strVendorCustomerLocation, strVendorShipTo, strVendorSoldTo, intConcurrencyId, guiApiUniqueId, intRowNumber) 
    VALUES (Source.intEntityLocationId, Source.intVendorSetupId, Source.strVendorCustomerLocation, Source.strVendorShipTo, Source.strVendorSoldTo, Source.intConcurrencyId, Source.guiApiUniqueId, Source.intRowNumber)

-- For Updates
WHEN MATCHED THEN UPDATE SET
    Target.strVendorCustomerLocation = Source.strVendorCustomerLocation,
	Target.strVendorShipTo = Source.strVendorShipTo,
	Target.strVendorSoldTo = Source.strVendorSoldTo,
	Target.guiApiUniqueId = @guiApiUniqueId,
    Target.intRowNumber = Source.intRowNumber;  

INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage, strAction)
SELECT
      NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Vendor''s Customer Location'
    , strValue = xc.strVendorCustomerLocation
    , strLogLevel = 'Info'
    , strStatus = 'Success'
    , intRowNo = xc.intRowNumber
    , strMessage = 'The Vendor Customer mapping ' + ISNULL(xc.strVendorCustomerLocation, '') + ' was ' 
		+ CASE WHEN updates.strVendorCustomerLocation IS NOT NULL THEN 'updated' ELSE 'imported' END + ' successfully.'
    , strAction = CASE WHEN updates.strVendorCustomerLocation IS NOT NULL THEN 'Update' ELSE 'Create' END
FROM tblBBCustomerLocationXref xc
OUTER APPLY (
	SELECT TOP 1 u.strVendorCustomerLocation
	FROM @CustomerLocationForUpdates u 
	WHERE u.intRowNumber = xc.intRowNumber
		AND u.intEntityLocationId = xc.intEntityLocationId
		AND u.intVendorSetupId = xc.intVendorSetupId
) updates
WHERE xc.guiApiUniqueId = @guiApiUniqueId

INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage, strAction)
SELECT
      NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Buyback Vendor Setup'
    , strValue = e.strName
    , strLogLevel = 'Info'
    , strStatus = 'Success'
    , intRowNo = vs.intRowNumber
    , strMessage = 'The buyback vendor setup ' + ISNULL(e.strName, '') + ' was updated successfully.'
    , strAction = 'Update'
FROM tblVRVendorSetup vs
JOIN tblEMEntity e ON e.intEntityId = vs.intEntityId
JOIN tblAPVendor v ON v.intEntityId = vs.intEntityId
JOIN @ForUpdates u ON u.strVendorNumber = v.strVendorId
WHERE vs.guiApiUniqueId = @guiApiUniqueId

UPDATE log
SET log.intTotalRowsImported = ISNULL(rv.intCount, 0)
FROM tblApiImportLog log
OUTER APPLY (
	SELECT COUNT(*) intCount
	FROM tblApiSchemaTransformBuybackVendorSetup
	WHERE guiApiUniqueId = log.guiApiUniqueId
) rv
WHERE log.guiApiImportLogId = @guiLogId