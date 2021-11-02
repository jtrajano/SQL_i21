CREATE PROCEDURE uspApiSchemaTransformVendorSetup 
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
    intRowNumber INT NULL,
	strVendor NVARCHAR(200) COLLATE Latin1_General_CI_AS NOT NULL,
	strExportFileType NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	strExportFilePath NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	strCompany1Id NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	strCompany2Id NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	strCustomer NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	strVendorCustomer NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	strItemNo NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	strVendorItemNo NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	strUnitMeasure NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	strVendorUnitMeasure NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	strEquipmentType NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	strCategory NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	strVendorCategory NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
)
INSERT INTO @tblFilteredVendorSetup
(
	intKey,
    intRowNumber,
	strVendor,
	strExportFileType,
	strExportFilePath,
	strCompany1Id,
	strCompany2Id,
	strCustomer,
	strVendorCustomer,
	strItemNo,
	strVendorItemNo,
	strUnitMeasure,
	strVendorUnitMeasure,
	strEquipmentType,
	strCategory,
	strVendorCategory
)
SELECT 
	intKey,
    intRowNumber,
	strVendor,
	strExportFileType,
	strExportFilePath,
	strCompany1Id,
	strCompany2Id,
	strCustomer,
	strVendorCustomer,
	strItemNo,
	strVendorItemNo,
	strUnitMeasure,
	strVendorUnitMeasure,
	strEquipmentType,
	strCategory,
	strVendorCategory
FROM
tblApiSchemaTransformVendorSetup
WHERE guiApiUniqueId = @guiApiUniqueId;

-- Error Types
-- Vendor Setup Logs
-- 1 - Invalid Vendor
-- 2 - Invalid Export File Type
-- Customer Xref Logs
-- 3 - Invalid Customer
-- 4 - Duplicate imported customer
-- 5 - Customer already exists
-- Item Xref Logs
-- 6 - Invalid Item
-- 7 - Duplicate imported item
-- 8 - Item already exists
-- UOM Xref Logs
-- 9 - Invalid UOM
-- 10 - Duplicate imported UOM
-- 11 - UOM already exists and overwrite is not enabled
-- Category Xref Logs
-- 12 - Invalid Category
-- 13 - Duplicate imported category
-- 14 - Category already exists

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
	vyuAPVendor Vendor
	ON
		Vendor.strVendorId = FilteredVendorSetup.strVendor
WHERE
Vendor.intEntityId IS NULL
UNION
SELECT -- Invalid Export File Type
	FilteredVendorSetup.strExportFileType,
	'Export file type: ' + FilteredVendorSetup.strExportFileType + ' does not exist.',
	FilteredVendorSetup.intRowNumber,
	2
FROM
	@tblFilteredVendorSetup FilteredVendorSetup
WHERE
FilteredVendorSetup.strExportFileType NOT IN('CSV','TXT','XML')
UNION
------------------------- Customer Xref Logs -------------------------
SELECT -- Invalid Customer
	FilteredVendorSetup.strCustomer,
	'Customer: ' + FilteredVendorSetup.strCustomer + ' does not exist.',
	FilteredVendorSetup.intRowNumber,
	3
FROM
	@tblFilteredVendorSetup FilteredVendorSetup
LEFT JOIN
	vyuARCustomer Customer
	ON
		FilteredVendorSetup.strCustomer = Customer.strCustomerNumber
		AND
		Customer.ysnActive = 1
WHERE
Customer.intEntityId IS NULL
UNION
SELECT -- Duplicate imported customer
	DuplicateVendorSetup.strCustomer,
	'Duplicate imported customer: ' + DuplicateVendorSetup.strCustomer + ' on vendor: ' + DuplicateVendorSetup.strVendor + '.', 
	DuplicateVendorSetup.intRowNumber,
	4
FROM
(
	SELECT 
		FilteredVendorSetup.strCustomer,
		FilteredVendorSetup.strVendor,
		FilteredVendorSetup.intRowNumber,
		RowNumber = ROW_NUMBER() OVER(PARTITION BY FilteredVendorSetup.strVendor, FilteredVendorSetup.strCustomer ORDER BY FilteredVendorSetup.intRowNumber)
	FROM 
		@tblFilteredVendorSetup FilteredVendorSetup
) AS DuplicateVendorSetup
WHERE DuplicateVendorSetup.RowNumber > 1
AND
DuplicateVendorSetup.strCustomer IS NOT NULL
UNION
SELECT -- Customer already exists
	FilteredVendorSetup.strCustomer,
	'Customer: ' + FilteredVendorSetup.strCustomer + ' on vendor: ' + FilteredVendorSetup.strVendor + ' already exists and overwrite is not enabled.',
	FilteredVendorSetup.intRowNumber,
	5
FROM
	@tblFilteredVendorSetup FilteredVendorSetup
LEFT JOIN
	vyuARCustomer Customer
	ON
		FilteredVendorSetup.strCustomer = Customer.strCustomerNumber
LEFT JOIN
	vyuAPVendor Vendor
	ON
		FilteredVendorSetup.strVendor = Vendor.strVendorId
INNER JOIN
	tblVRVendorSetup VendorSetup
	ON
		VendorSetup.intEntityId = Vendor.intEntityId
INNER JOIN
	tblVRCustomerXref CustomerXref
	ON
		Customer.intEntityId = CustomerXref.intEntityId
		AND
		VendorSetup.intVendorSetupId = CustomerXref.intVendorSetupId
WHERE
@ysnAllowOverwrite = 0
UNION
--------------------------- Item Xref Logs ---------------------------
SELECT -- Invalid Item
	FilteredVendorSetup.strItemNo,
	'Item: ' + FilteredVendorSetup.strItemNo + ' does not exist.',
	FilteredVendorSetup.intRowNumber,
	6
FROM
	@tblFilteredVendorSetup FilteredVendorSetup
LEFT JOIN
	tblICItem Item
	ON
		FilteredVendorSetup.strItemNo = Item.strItemNo
		AND
		Item.strType NOT LIKE '%Comment%'
WHERE
Item.intItemId IS NULL
UNION
SELECT -- Duplicate imported item
	DuplicateVendorSetup.strItemNo,
	'Duplicate imported item: ' + DuplicateVendorSetup.strItemNo + ' on vendor: ' + DuplicateVendorSetup.strVendor + '.', 
	DuplicateVendorSetup.intRowNumber,
	7
FROM
(
	SELECT 
		FilteredVendorSetup.strItemNo,
		FilteredVendorSetup.strVendor,
		FilteredVendorSetup.intRowNumber,
		RowNumber = ROW_NUMBER() OVER(PARTITION BY FilteredVendorSetup.strVendor, FilteredVendorSetup.strItemNo ORDER BY FilteredVendorSetup.intRowNumber)
	FROM 
		@tblFilteredVendorSetup FilteredVendorSetup
) AS DuplicateVendorSetup
WHERE DuplicateVendorSetup.RowNumber > 1
AND
DuplicateVendorSetup.strItemNo IS NOT NULL
UNION
SELECT  -- Item already exists
	FilteredVendorSetup.strItemNo,
	'Item: ' + FilteredVendorSetup.strItemNo + ' on vendor: ' + FilteredVendorSetup.strVendor + ' already exists and overwrite is not enabled.',
	FilteredVendorSetup.intRowNumber,
	8
FROM
	@tblFilteredVendorSetup FilteredVendorSetup
LEFT JOIN
	tblICItem Item
	ON
		FilteredVendorSetup.strItemNo = Item.strItemNo
LEFT JOIN
	vyuAPVendor Vendor
	ON
		FilteredVendorSetup.strVendor = Vendor.strVendorId
INNER JOIN
	tblVRVendorSetup VendorSetup
	ON
		VendorSetup.intEntityId = Vendor.intEntityId
INNER JOIN
	tblICItemVendorXref ItemXref
	ON
		Item.intItemId = ItemXref.intItemId
		AND
		VendorSetup.intVendorSetupId = ItemXref.intVendorSetupId
WHERE 
@ysnAllowOverwrite = 0
UNION
--------------------------- UOM Xref Logs ---------------------------
SELECT -- Invalid UOM
	FilteredVendorSetup.strUnitMeasure,
	'Unit of measure: ' + FilteredVendorSetup.strUnitMeasure + ' does not exist.',
	FilteredVendorSetup.intRowNumber,
	9
FROM
	@tblFilteredVendorSetup FilteredVendorSetup
LEFT JOIN
	tblICUnitMeasure UnitMeasure
	ON
		FilteredVendorSetup.strUnitMeasure = UnitMeasure.strUnitMeasure
WHERE
UnitMeasure.intUnitMeasureId IS NULL
UNION
SELECT -- Duplicate imported unit of measure
	DuplicateVendorSetup.strUnitMeasure,
	'Duplicate imported unit of measure: ' + DuplicateVendorSetup.strUnitMeasure + ' on vendor: ' + DuplicateVendorSetup.strVendor + '.', 
	DuplicateVendorSetup.intRowNumber,
	10
FROM
(
	SELECT 
		FilteredVendorSetup.strUnitMeasure,
		FilteredVendorSetup.strVendor,
		FilteredVendorSetup.intRowNumber,
		RowNumber = ROW_NUMBER() OVER(PARTITION BY FilteredVendorSetup.strVendor, FilteredVendorSetup.strUnitMeasure ORDER BY FilteredVendorSetup.intRowNumber)
	FROM 
		@tblFilteredVendorSetup FilteredVendorSetup
) AS DuplicateVendorSetup
WHERE DuplicateVendorSetup.RowNumber > 1
AND
DuplicateVendorSetup.strUnitMeasure IS NOT NULL
UNION
SELECT  -- Unit of measure already exists
	FilteredVendorSetup.strUnitMeasure,
	'Unit of measure: ' + FilteredVendorSetup.strUnitMeasure + ' on vendor: ' + FilteredVendorSetup.strVendor + ' already exists and overwrite is not enabled.',
	FilteredVendorSetup.intRowNumber,
	11
FROM
	@tblFilteredVendorSetup FilteredVendorSetup
LEFT JOIN
	tblICUnitMeasure UnitMeasure
	ON
		FilteredVendorSetup.strUnitMeasure = UnitMeasure.strUnitMeasure
LEFT JOIN
	vyuAPVendor Vendor
	ON
		FilteredVendorSetup.strVendor = Vendor.strVendorId
INNER JOIN
	tblVRVendorSetup VendorSetup
	ON
		VendorSetup.intEntityId = Vendor.intEntityId
INNER JOIN
	tblVRUOMXref UOMXref
	ON
		UnitMeasure.intUnitMeasureId = UOMXref.intUnitMeasureId
		AND
		VendorSetup.intVendorSetupId = UOMXref.intVendorSetupId
WHERE
@ysnAllowOverwrite = 0
UNION
------------------------- Category Xref Logs -------------------------
SELECT -- Invalid Category
	FilteredVendorSetup.strCategory,
	'Category: ' + FilteredVendorSetup.strCategory + ' does not exist.',
	FilteredVendorSetup.intRowNumber,
	12
FROM
	@tblFilteredVendorSetup FilteredVendorSetup
LEFT JOIN
	tblICCategory Category
	ON
		FilteredVendorSetup.strCategory = Category.strCategoryCode
WHERE
Category.intCategoryId IS NULL
UNION
SELECT -- Duplicate imported category
	DuplicateVendorSetup.strCategory,
	'Duplicate imported category: ' + DuplicateVendorSetup.strCategory + ' on vendor: ' + DuplicateVendorSetup.strVendor + '.', 
	DuplicateVendorSetup.intRowNumber,
	13
FROM
(
	SELECT 
		FilteredVendorSetup.strCategory,
		FilteredVendorSetup.strVendor,
		FilteredVendorSetup.intRowNumber,
		RowNumber = ROW_NUMBER() OVER(PARTITION BY FilteredVendorSetup.strVendor, FilteredVendorSetup.strCategory ORDER BY FilteredVendorSetup.intRowNumber)
	FROM 
		@tblFilteredVendorSetup FilteredVendorSetup
) AS DuplicateVendorSetup
WHERE DuplicateVendorSetup.RowNumber > 1
AND
DuplicateVendorSetup.strCategory IS NOT NULL
UNION
SELECT  -- Category already exists
	FilteredVendorSetup.strCategory,
	'Category: ' + FilteredVendorSetup.strCategory + ' on vendor: ' + FilteredVendorSetup.strVendor + ' already exists and overwrite is not enabled.',
	FilteredVendorSetup.intRowNumber,
	14
FROM
	@tblFilteredVendorSetup FilteredVendorSetup
LEFT JOIN
	tblICCategory Category
	ON
		FilteredVendorSetup.strCategory = Category.strCategoryCode
LEFT JOIN
	vyuAPVendor Vendor
	ON
		FilteredVendorSetup.strVendor = Vendor.strVendorId
INNER JOIN
	tblVRVendorSetup VendorSetup
	ON
		VendorSetup.intEntityId = Vendor.intEntityId
INNER JOIN
	tblICCategoryVendor CategoryXref
	ON
		Category.intCategoryId = CategoryXref.intCategoryId
		AND
		VendorSetup.intVendorSetupId = CategoryXref.intVendorSetupId
WHERE
@ysnAllowOverwrite = 0

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
		WHEN LogVendorSetup.intLogType = 1
		THEN 'Vendor'
		WHEN LogVendorSetup.intLogType = 2
		THEN 'Export File Type'
		WHEN LogVendorSetup.intLogType IN (3,4,5)
		THEN 'Customer'
		WHEN LogVendorSetup.intLogType IN (6,7,8)
		THEN 'Item No'
		WHEN LogVendorSetup.intLogType IN (9,10,11)
		THEN 'Unit of Measure'
		ELSE 'Category'
	END,
	strValue = LogVendorSetup.strFieldValue,
	strLogLevel =  CASE
		WHEN LogVendorSetup.intLogType IN(4,5,7,8,10,11,13,14)
		THEN 'Warning'
		ELSE 'Error'
	END,
	strStatus = CASE
		WHEN LogVendorSetup.intLogType IN(4,5,7,8,10,11,13,14)
		THEN 'Skipped'
		ELSE 'Failed'
	END,
	intRowNo = LogVendorSetup.intRowNumber,
	strMessage = LogVendorSetup.strMessage
FROM @tblLogVendorSetup LogVendorSetup
WHERE LogVendorSetup.intLogType BETWEEN 1 AND 14

--Vendor Setup Transform logic

;MERGE INTO tblVRVendorSetup AS TARGET
USING
(
	SELECT
		guiApiUniqueId = @guiApiUniqueId,
		intEntityId = MAX(Vendor.intEntityId),
		strExportFileType = MAX(FilteredVendorSetup.strExportFileType),
		strExportFilePath = MAX(FilteredVendorSetup.strExportFilePath),
		strCompany1Id = MAX(FilteredVendorSetup.strCompany1Id),
		strCompany2Id = MAX(FilteredVendorSetup.strCompany2Id)
	FROM @tblFilteredVendorSetup FilteredVendorSetup
	LEFT JOIN
		@tblLogVendorSetup LogVendorSetup
		ON
			FilteredVendorSetup.intRowNumber = LogVendorSetup.intRowNumber
			AND
			LogVendorSetup.intLogType IN (1,2)
	INNER JOIN
		vyuAPVendor Vendor
		ON
			Vendor.strVendorId = FilteredVendorSetup.strVendor
	WHERE
	LogVendorSetup.intLogType NOT IN (1,2) OR LogVendorSetup.intLogType IS NULL
	GROUP BY
	FilteredVendorSetup.strVendor
) AS SOURCE
ON TARGET.intEntityId = SOURCE.intEntityId
WHEN MATCHED AND @ysnAllowOverwrite = 1 
THEN
	UPDATE SET
		guiApiUniqueId = SOURCE.guiApiUniqueId,
		intEntityId = SOURCE.intEntityId,
		strExportFileType = SOURCE.strExportFileType,
		strExportFilePath = SOURCE.strExportFilePath,
		strCompany1Id = SOURCE.strCompany1Id,
		strCompany2Id = SOURCE.strCompany2Id
WHEN NOT MATCHED THEN
	INSERT
	(
		guiApiUniqueId,
		intEntityId,
		strExportFileType,
		strExportFilePath,
		strCompany1Id,
		strCompany2Id,
		intConcurrencyId
	)
	VALUES
	(
		guiApiUniqueId,
		intEntityId,
		strExportFileType,
		strExportFilePath,
		strCompany1Id,
		strCompany2Id,
		1
	);

--Customer Xref Transform logic

;MERGE INTO tblVRCustomerXref AS TARGET
USING
(
	SELECT
		guiApiUniqueId = @guiApiUniqueId,
		intEntityId = Customer.intEntityId,
		intVendorSetupId = VendorSetup.intVendorSetupId,
		strVendorCustomer = ISNULL(FilteredVendorSetup.strVendorCustomer, Customer.strCustomerNumber)
	FROM @tblFilteredVendorSetup FilteredVendorSetup
	LEFT JOIN
		@tblLogVendorSetup LogVendorSetup
		ON
			FilteredVendorSetup.intRowNumber = LogVendorSetup.intRowNumber
			AND
			LogVendorSetup.intLogType IN (1,2,3,4,5)
	INNER JOIN
		vyuARCustomer Customer
		ON
			FilteredVendorSetup.strCustomer = Customer.strCustomerNumber
			AND
			Customer.ysnActive = 1
	INNER JOIN
	(
		vyuAPVendor Vendor
		INNER JOIN
			tblVRVendorSetup VendorSetup 
			ON
				Vendor.intEntityId = VendorSetup.intEntityId
	)
		ON
			Vendor.strVendorId = FilteredVendorSetup.strVendor
	WHERE 
	LogVendorSetup.intLogType NOT IN (1,2,3,4,5) OR LogVendorSetup.intLogType IS NULL
) AS SOURCE
ON TARGET.intEntityId = SOURCE.intEntityId AND TARGET.intVendorSetupId = SOURCE.intVendorSetupId
WHEN MATCHED AND @ysnAllowOverwrite = 1 
THEN
	UPDATE SET
		guiApiUniqueId = SOURCE.guiApiUniqueId,
		intEntityId = SOURCE.intEntityId,
		intVendorSetupId = SOURCE.intVendorSetupId,
		strVendorCustomer = SOURCE.strVendorCustomer
WHEN NOT MATCHED THEN
	INSERT
	(
		guiApiUniqueId,
		intEntityId,
		intVendorSetupId,
		strVendorCustomer,
		intConcurrencyId
	)
	VALUES
	(
		guiApiUniqueId,
		intEntityId,
		intVendorSetupId,
		strVendorCustomer,
		1
	);

--Item Xref Transform logic

;MERGE INTO tblICItemVendorXref AS TARGET
USING
(
	SELECT
		guiApiUniqueId = @guiApiUniqueId,
		intItemId = Item.intItemId,
		intVendorId = Vendor.intEntityId,
		intVendorSetupId = VendorSetup.intVendorSetupId,
		strVendorProduct = ISNULL(FilteredVendorSetup.strVendorItemNo, Item.strItemNo)
	FROM @tblFilteredVendorSetup FilteredVendorSetup
	LEFT JOIN
		@tblLogVendorSetup LogVendorSetup
		ON
			FilteredVendorSetup.intRowNumber = LogVendorSetup.intRowNumber
			AND
			LogVendorSetup.intLogType IN (1,2,6,7,8)
	INNER JOIN
		tblICItem Item
		ON
			FilteredVendorSetup.strItemNo = Item.strItemNo
			AND
			Item.strType NOT LIKE '%Comment%'
	INNER JOIN
	(
		vyuAPVendor Vendor
		INNER JOIN
			tblVRVendorSetup VendorSetup 
			ON
				Vendor.intEntityId = VendorSetup.intEntityId
	)
		ON
			Vendor.strVendorId = FilteredVendorSetup.strVendor
	WHERE 
	LogVendorSetup.intLogType NOT IN (1,2,6,7,8) OR LogVendorSetup.intLogType IS NULL
) AS SOURCE
ON TARGET.intItemId = SOURCE.intItemId AND TARGET.intVendorSetupId = SOURCE.intVendorSetupId
WHEN MATCHED AND @ysnAllowOverwrite = 1 
THEN
	UPDATE SET
		guiApiUniqueId = SOURCE.guiApiUniqueId,
		intItemId = SOURCE.intItemId,
		intVendorId = SOURCE.intVendorId,
		intVendorSetupId = SOURCE.intVendorSetupId,
		strVendorProduct = SOURCE.strVendorProduct
WHEN NOT MATCHED THEN
	INSERT
	(
		guiApiUniqueId,
		intItemId,
		intVendorId,
		intVendorSetupId,
		strVendorProduct,
		intConcurrencyId
	)
	VALUES
	(
		guiApiUniqueId,
		intItemId,
		intVendorId,
		intVendorSetupId,
		strVendorProduct,
		1
	);

--UOM Xref Transform logic

;MERGE INTO tblVRUOMXref AS TARGET
USING
(
	SELECT
		guiApiUniqueId = @guiApiUniqueId,
		intVendorSetupId = VendorSetup.intVendorSetupId,
		intUnitMeasureId = UnitMeasure.intUnitMeasureId,
		strVendorUOM = ISNULL(FilteredVendorSetup.strVendorUnitMeasure, UnitMeasure.strUnitMeasure),
		strEquipmentType = FilteredVendorSetup.strEquipmentType
	FROM @tblFilteredVendorSetup FilteredVendorSetup
	LEFT JOIN
		@tblLogVendorSetup LogVendorSetup
		ON
			FilteredVendorSetup.intRowNumber = LogVendorSetup.intRowNumber
			AND
			LogVendorSetup.intLogType IN (1,2,9,10,11)
	INNER JOIN
		tblICUnitMeasure UnitMeasure
		ON
			FilteredVendorSetup.strUnitMeasure = UnitMeasure.strUnitMeasure
	INNER JOIN
	(
		vyuAPVendor Vendor
		INNER JOIN
			tblVRVendorSetup VendorSetup 
			ON
				Vendor.intEntityId = VendorSetup.intEntityId
	)
		ON
			Vendor.strVendorId = FilteredVendorSetup.strVendor
	WHERE 
	LogVendorSetup.intLogType NOT IN (1,2,9,10,11) OR LogVendorSetup.intLogType IS NULL
) AS SOURCE
ON 
TARGET.intVendorSetupId = SOURCE.intVendorSetupId 
AND
TARGET.intUnitMeasureId = SOURCE.intUnitMeasureId 
WHEN MATCHED AND @ysnAllowOverwrite = 1 
THEN
	UPDATE SET
		guiApiUniqueId = SOURCE.guiApiUniqueId,
		intVendorSetupId = SOURCE.intVendorSetupId,
		intUnitMeasureId = SOURCE.intUnitMeasureId,
		strVendorUOM = SOURCE.strVendorUOM,
		strEquipmentType = SOURCE.strEquipmentType
WHEN NOT MATCHED THEN
	INSERT
	(
		guiApiUniqueId,
		intVendorSetupId,
		intUnitMeasureId,
		strVendorUOM,
		strEquipmentType,
		intConcurrencyId
	)
	VALUES
	(
		guiApiUniqueId,
		intVendorSetupId,
		intUnitMeasureId,
		strVendorUOM,
		strEquipmentType,
		1
	);

--Category Xref Transform logic

;MERGE INTO tblICCategoryVendor AS TARGET
USING
(
	SELECT
		guiApiUniqueId = @guiApiUniqueId,
		intCategoryId = Category.intCategoryId,
		intVendorId = Vendor.intEntityId,
		intVendorSetupId = VendorSetup.intVendorSetupId,
		strVendorDepartment = ISNULL(FilteredVendorSetup.strVendorCategory, Category.strCategoryCode)
	FROM @tblFilteredVendorSetup FilteredVendorSetup
	LEFT JOIN
		@tblLogVendorSetup LogVendorSetup
		ON
			FilteredVendorSetup.intRowNumber = LogVendorSetup.intRowNumber
			AND
			LogVendorSetup.intLogType IN (1,2,12,13,14)
	INNER JOIN
		tblICCategory Category
		ON
			FilteredVendorSetup.strCategory = Category.strCategoryCode
	INNER JOIN
	(
		vyuAPVendor Vendor
		INNER JOIN
			tblVRVendorSetup VendorSetup 
			ON
				Vendor.intEntityId = VendorSetup.intEntityId
	)
		ON
			Vendor.strVendorId = FilteredVendorSetup.strVendor
	WHERE 
	LogVendorSetup.intLogType NOT IN (1,2,12,13,14) OR LogVendorSetup.intLogType IS NULL
) AS SOURCE
ON 
TARGET.intVendorSetupId = SOURCE.intVendorSetupId 
AND
TARGET.intCategoryId = SOURCE.intCategoryId 
WHEN MATCHED AND @ysnAllowOverwrite = 1 
THEN
	UPDATE SET
		guiApiUniqueId = SOURCE.guiApiUniqueId,
		intCategoryId = SOURCE.intCategoryId,
		intVendorId = SOURCE.intVendorId,
		intVendorSetupId = SOURCE.intVendorSetupId,
		strVendorDepartment = SOURCE.strVendorDepartment
WHEN NOT MATCHED THEN
	INSERT
	(
		guiApiUniqueId,
		intCategoryId,
		intVendorId,
		intVendorSetupId,
		strVendorDepartment,
		intConcurrencyId
	)
	VALUES
	(
		guiApiUniqueId,
		intCategoryId,
		intVendorId,
		intVendorSetupId,
		strVendorDepartment,
		1
	);