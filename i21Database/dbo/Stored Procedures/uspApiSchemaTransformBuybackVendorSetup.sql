CREATE PROCEDURE uspApiSchemaTransformBuybackVendorSetup 
	@guiApiUniqueId UNIQUEIDENTIFIER,
	@guiLogId UNIQUEIDENTIFIER
AS

--Check overwrite settings

DECLARE @ysnAllowOverwrite BIT = 0

SELECT @ysnAllowOverwrite = CAST(varPropertyValue AS BIT)
FROM tblApiSchemaTransformProperty
WHERE 
guiApiUniqueId = @guiApiUniqueId
AND
strPropertyName = 'Overwrite'

--Filter Vendor Setup imported

DECLARE @tblFilteredVendorSetup TABLE(
	intKey INT NOT NULL,
    guiApiUniqueId UNIQUEIDENTIFIER NOT NULL,
    intRowNumber INT NULL,
	strVendor NVARCHAR(200) COLLATE Latin1_General_CI_AS NOT NULL,
	strBuybackExportFileType NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	strBuybackExportFilePath NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	strCompany1Id NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	strCompany2Id NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	strReimbursementType  NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	strGLAccount  NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	strLocation NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	strVendorCustomerLocation NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	strVendorShipTo NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	strVendorSoldTo NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
)
INSERT INTO @tblFilteredVendorSetup
(
	intKey,
    guiApiUniqueId,
    intRowNumber,
	strVendor,
	strBuybackExportFileType,
	strBuybackExportFilePath,
	strCompany1Id,
	strCompany2Id,
	strReimbursementType,
	strGLAccount,
	strLocation,
	strVendorCustomerLocation,
	strVendorShipTo,
	strVendorSoldTo
)
SELECT 
	intKey,
    guiApiUniqueId,
    intRowNumber,
	strVendor,
	strBuybackExportFileType,
	strBuybackExportFilePath,
	strCompany1Id,
	strCompany2Id,
	strReimbursementType,
	strGLAccount,
	strLocation,
	strVendorCustomerLocation,
	strVendorShipTo,
	strVendorSoldTo
FROM
tblApiSchemaTransformBuybackVendorSetup
WHERE guiApiUniqueId = @guiApiUniqueId;

-- Error Types
-- Vendor Setup Logs
-- 1 - Invalid Vendor
-- 2 - Invalid Export File Type
-- 3 - Invalid Reimbursement Type
-- 4 - Invalid GL Account
-- Customer Location Xref Logs
-- 5 - Invalid Customer Location
-- 6 - Duplicate imported customer location
-- 7 - Customer location already exists and overwrite is not enabled
-- 8 - Customer Location Xref Incomplete

DECLARE @tblLogVendorSetup TABLE(
	strFieldValue NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strMessage NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	intRowNumber INT NULL,
	intLogType INT NULL
)

INSERT INTO @tblLogVendorSetup
(
	strFieldValue,
	strMessage,
	intRowNumber,
	intLogType
)
-------------------------- Vendor Setup Logs --------------------------
SELECT -- Invalid Vendor
	FilteredVendorSetup.strVendor,
	'Vendor: ' + FilteredVendorSetup.strVendor + ' does not exist.',
	FilteredVendorSetup.intRowNumber,
	1
FROM
	@tblFilteredVendorSetup FilteredVendorSetup
LEFT JOIN
(
	tblEMEntity Entity
	INNER JOIN
		tblAPVendor Vendor
		ON
			Entity.intEntityId = Vendor.intEntityId
)
	ON
		Entity.strName = FilteredVendorSetup.strVendor
WHERE
Vendor.intEntityId IS NULL
UNION
SELECT -- Invalid Export File Type
	FilteredVendorSetup.strBuybackExportFileType,
	'Export file type: ' + FilteredVendorSetup.strBuybackExportFileType + ' does not exist.',
	FilteredVendorSetup.intRowNumber,
	2
FROM
	@tblFilteredVendorSetup FilteredVendorSetup
WHERE
FilteredVendorSetup.strBuybackExportFileType NOT IN('CSV','TXT','XML')
UNION
SELECT -- Invalid Reimbursement Type
	FilteredVendorSetup.strReimbursementType,
	'Reimbursement Type: ' + FilteredVendorSetup.strReimbursementType + ' does not exist.',
	FilteredVendorSetup.intRowNumber,
	3
FROM
	@tblFilteredVendorSetup FilteredVendorSetup
WHERE
FilteredVendorSetup.strReimbursementType NOT IN('AP','AR')
UNION
SELECT -- Invalid GL Account
	FilteredVendorSetup.strGLAccount,
	'GL Account: ' + FilteredVendorSetup.strGLAccount + ' does not exist.',
	FilteredVendorSetup.intRowNumber,
	4
FROM 
	@tblFilteredVendorSetup FilteredVendorSetup
LEFT JOIN
	vyuGLAccountDetail AccountDetail
	ON
		FilteredVendorSetup.strGLAccount = AccountDetail.strAccountId
		AND
		AccountDetail.strAccountCategory = 'General'
WHERE
AccountDetail.intAccountId IS NULL
UNION
------------------------- Customer Location Xref Logs -------------------------
SELECT -- Invalid Customer Location
	FilteredVendorSetup.strLocation,
	'Customer location: ' + FilteredVendorSetup.strLocation + ' does not exist.',
	FilteredVendorSetup.intRowNumber,
	5
FROM
	@tblFilteredVendorSetup FilteredVendorSetup
LEFT JOIN
	vyuARCustomer Customer
	ON
		Customer.strName = FilteredVendorSetup.strVendor
LEFT JOIN
	tblEMEntityLocation EntityLocation 
	ON
		Customer.intEntityId = EntityLocation.intEntityId
		AND
		FilteredVendorSetup.strLocation = EntityLocation.strLocationName
WHERE
EntityLocation.intEntityLocationId IS NULL
AND
FilteredVendorSetup.strLocation IS NOT NULL
UNION
SELECT -- Duplicate imported customer location
	DuplicateVendorSetup.strLocation,
	'Duplicate imported customer location: ' + DuplicateVendorSetup.strLocation + ' on vendor: ' + DuplicateVendorSetup.strVendor + '.', 
	DuplicateVendorSetup.intRowNumber,
	6
FROM
(
	SELECT 
		FilteredVendorSetup.strLocation,
		FilteredVendorSetup.strVendor,
		FilteredVendorSetup.intRowNumber,
		RowNumber = ROW_NUMBER() OVER(PARTITION BY FilteredVendorSetup.strVendor, FilteredVendorSetup.strLocation ORDER BY FilteredVendorSetup.intRowNumber)
	FROM 
		@tblFilteredVendorSetup FilteredVendorSetup
) AS DuplicateVendorSetup
WHERE DuplicateVendorSetup.RowNumber > 1
AND
DuplicateVendorSetup.strLocation IS NOT NULL
UNION
SELECT -- Customer location already exists and overwrite is not enabled.
	FilteredVendorSetup.strLocation,
	'Customer: ' + FilteredVendorSetup.strLocation + ' on vendor: ' + FilteredVendorSetup.strVendor + ' already exists and overwrite is not enabled.',
	FilteredVendorSetup.intRowNumber,
	7
FROM
	@tblFilteredVendorSetup FilteredVendorSetup
LEFT JOIN
	vyuARCustomer Customer
	ON
		Customer.strName = FilteredVendorSetup.strVendor
LEFT JOIN
	tblEMEntityLocation EntityLocation 
	ON
		Customer.intEntityId = EntityLocation.intEntityId
		AND
		FilteredVendorSetup.strLocation = EntityLocation.strLocationName
LEFT JOIN
(
	tblEMEntity Entity
	INNER JOIN
		(
			tblAPVendor Vendor
			INNER JOIN 
				tblVRVendorSetup VendorSetup
				ON
					VendorSetup.intEntityId = Vendor.intEntityId
		)
		ON
			Entity.intEntityId = Vendor.intEntityId
)
	ON
		Entity.strName = FilteredVendorSetup.strVendor
INNER JOIN
	tblBBCustomerLocationXref CustomerLocationXref
	ON
		EntityLocation.intEntityLocationId = CustomerLocationXref.intEntityLocationId
		AND
		VendorSetup.intVendorSetupId = CustomerLocationXref.intVendorSetupId
UNION
SELECT -- Customer Location Xref incomplete
	CASE
		WHEN FilteredVendorSetup.strLocation IS NOT NULL AND FilteredVendorSetup.strVendorCustomerLocation IS NULL
		THEN FilteredVendorSetup.strLocation
		WHEN FilteredVendorSetup.strLocation IS NULL AND FilteredVendorSetup.strVendorCustomerLocation IS NOT NULL
		THEN FilteredVendorSetup.strVendorCustomerLocation
		ELSE NULL
	END,
	CASE
		WHEN FilteredVendorSetup.strLocation IS NOT NULL AND FilteredVendorSetup.strVendorCustomerLocation IS NULL
		THEN 'Vendor cross reference is missing for customer location: ' + FilteredVendorSetup.strLocation + '.'
		WHEN FilteredVendorSetup.strLocation IS NULL AND FilteredVendorSetup.strVendorCustomerLocation IS NOT NULL
		THEN 'Customer Location is missing for vendor cross reference: ' + FilteredVendorSetup.strVendorCustomerLocation + '.'
		ELSE NULL
	END,
	FilteredVendorSetup.intRowNumber,
	8
FROM
	@tblFilteredVendorSetup FilteredVendorSetup
WHERE
(
	FilteredVendorSetup.strLocation IS NOT NULL 
	AND 
	FilteredVendorSetup.strVendorCustomerLocation IS NULL
)
OR
(
	FilteredVendorSetup.strLocation IS NULL 
	AND 
	FilteredVendorSetup.strVendorCustomerLocation IS NOT NULL
)

--Validate Records

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
		WHEN LogVendorSetup.intLogType IN (1,8)
		THEN 'Vendor'
		WHEN LogVendorSetup.intLogType = 2
		THEN 'Export File Type'
		WHEN LogVendorSetup.intLogType = 3
		THEN 'Reimbursement Type'
		WHEN LogVendorSetup.intLogType = 4
		THEN 'Income GL Account'
		ELSE 'Customer Location'
	END,
	strValue = LogVendorSetup.strFieldValue,
	strLogLevel =  CASE
		WHEN LogVendorSetup.intLogType IN(6,7)
		THEN 'Warning'
		ELSE 'Error'
	END,
	strStatus = CASE
		WHEN LogVendorSetup.intLogType IN(6,7)
		THEN 'Skipped'
		ELSE 'Failed'
	END,
	intRowNo = LogVendorSetup.intRowNumber,
	strMessage = LogVendorSetup.strMessage
FROM @tblLogVendorSetup LogVendorSetup
WHERE LogVendorSetup.intLogType BETWEEN 1 AND 8

--Buyback Vendor Setup Transform logic

;MERGE INTO tblVRVendorSetup AS TARGET
USING
(
	SELECT
		guiApiUniqueId = @guiApiUniqueId,
		intEntityId = MAX(Vendor.intEntityId),
		strBuybackExportFileType = MAX(FilteredVendorSetup.strBuybackExportFileType),
		strBuybackExportFilePath = MAX(FilteredVendorSetup.strBuybackExportFilePath),
		strCompany1Id = MAX(FilteredVendorSetup.strCompany1Id),
		strCompany2Id = MAX(FilteredVendorSetup.strCompany2Id),
		strReimbursementType = MAX(FilteredVendorSetup.strReimbursementType),
		intAccountId = MAX(AccountDetail.intAccountId)
	FROM @tblFilteredVendorSetup FilteredVendorSetup
	LEFT JOIN
		@tblLogVendorSetup LogVendorSetup
		ON
			FilteredVendorSetup.intRowNumber = LogVendorSetup.intRowNumber
			AND
			LogVendorSetup.intLogType IN (1,2,3,4)
	INNER JOIN
	(
		tblEMEntity Entity
		INNER JOIN
			tblAPVendor Vendor
			ON
				Entity.intEntityId = Vendor.intEntityId
	)
		ON
			Entity.strName = FilteredVendorSetup.strVendor
	INNER JOIN
		vyuGLAccountDetail AccountDetail
		ON
			FilteredVendorSetup.strGLAccount = AccountDetail.strAccountId
			AND
			AccountDetail.strAccountCategory = 'General'
	WHERE
	LogVendorSetup.intLogType NOT IN (1,2,3,4) OR LogVendorSetup.intLogType IS NULL
	GROUP BY
	FilteredVendorSetup.strVendor
) AS SOURCE
ON TARGET.intEntityId = SOURCE.intEntityId
WHEN MATCHED AND @ysnAllowOverwrite = 1 
THEN
	UPDATE SET
		guiApiUniqueId = SOURCE.guiApiUniqueId,
		intEntityId = SOURCE.intEntityId,
		strBuybackExportFileType = SOURCE.strBuybackExportFileType,
		strBuybackExportFilePath = SOURCE.strBuybackExportFilePath,
		strCompany1Id = SOURCE.strCompany1Id,
		strCompany2Id = SOURCE.strCompany2Id,
		strReimbursementType = SOURCE.strReimbursementType,
		intAccountId = SOURCE.intAccountId
WHEN NOT MATCHED THEN
	INSERT
	(
		guiApiUniqueId,
		intEntityId,
		strBuybackExportFileType,
		strBuybackExportFilePath,
		strCompany1Id,
		strCompany2Id,
		strReimbursementType,
		intAccountId,
		intConcurrencyId
	)
	VALUES
	(
		guiApiUniqueId,
		intEntityId,
		strBuybackExportFileType,
		strBuybackExportFilePath,
		strCompany1Id,
		strCompany2Id,
		strReimbursementType,
		intAccountId,
		1
	);

--Customer Location Xref Transform logic

;MERGE INTO tblBBCustomerLocationXref AS TARGET
USING
(
	SELECT
		guiApiUniqueId = FilteredVendorSetup.guiApiUniqueId,
		intEntityLocationId = EntityLocation.intEntityLocationId,
		intVendorSetupId = VendorSetup.intVendorSetupId,
		strVendorCustomerLocation = FilteredVendorSetup.strVendorCustomerLocation,
		strVendorShipTo = FilteredVendorSetup.strVendorShipTo,
		strVendorSoldTo = FilteredVendorSetup.strVendorSoldTo
	FROM @tblFilteredVendorSetup FilteredVendorSetup
	LEFT JOIN
		@tblLogVendorSetup LogVendorSetup
		ON
			FilteredVendorSetup.intRowNumber = LogVendorSetup.intRowNumber
			AND
			LogVendorSetup.intLogType IN (1,2,3,4,5,6,7,8)
	INNER JOIN
	(
		tblEMEntity Entity
		INNER JOIN
			(
				tblAPVendor Vendor
				INNER JOIN 
					tblVRVendorSetup VendorSetup
					ON
						VendorSetup.intEntityId = Vendor.intEntityId
			)
			ON
				Entity.intEntityId = Vendor.intEntityId
	)
		ON
			Entity.strName = FilteredVendorSetup.strVendor
	INNER JOIN
		vyuARCustomer Customer
		ON
			Customer.strName = FilteredVendorSetup.strVendor
	INNER JOIN
		tblEMEntityLocation EntityLocation 
		ON
			Customer.intEntityId = EntityLocation.intEntityId
			AND
			FilteredVendorSetup.strLocation = EntityLocation.strLocationName
	WHERE 
	LogVendorSetup.intLogType NOT IN (1,2,3,4,5,6,7,8) OR LogVendorSetup.intLogType IS NULL
) AS SOURCE
ON 
TARGET.intVendorSetupId = SOURCE.intVendorSetupId 
AND
TARGET.intEntityLocationId = SOURCE.intEntityLocationId 
WHEN MATCHED AND @ysnAllowOverwrite = 1 
THEN
	UPDATE SET
		guiApiUniqueId = SOURCE.guiApiUniqueId,
		intEntityLocationId = SOURCE.intEntityLocationId,
		intVendorSetupId = SOURCE.intVendorSetupId,
		strVendorCustomerLocation = SOURCE.strVendorCustomerLocation,
		strVendorShipTo = SOURCE.strVendorShipTo,
		strVendorSoldTo = SOURCE.strVendorSoldTo
WHEN NOT MATCHED THEN
	INSERT
	(
		guiApiUniqueId,
		intEntityLocationId,
		intVendorSetupId,
		strVendorCustomerLocation,
		strVendorShipTo,
		strVendorSoldTo,
		intConcurrencyId
	)
	VALUES
	(
		guiApiUniqueId,
		intEntityLocationId,
		intVendorSetupId,
		strVendorCustomerLocation,
		strVendorShipTo,
		strVendorSoldTo,
		1
	);