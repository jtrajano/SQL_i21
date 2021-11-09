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
	strVendorCategory NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	strRebateUnitMeasure NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	strVendorRebateUnitMeasure NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
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
	strVendorCategory,
	strRebateUnitMeasure,
	strVendorRebateUnitMeasure
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
	strVendorCategory,
	strRebateUnitMeasure,
	strVendorRebateUnitMeasure
FROM
tblApiSchemaTransformVendorSetup
WHERE guiApiUniqueId = @guiApiUniqueId;

-- Error Types
-- Vendor Setup Logs
-- 1 - Invalid Vendor
-- 2 - Duplicate Vendor Name
-- 3 - Invalid Export File Type
-- Customer Xref Logs
-- 4 - Invalid Customer
-- 5 - Duplicate Customer Name
-- 6 - Duplicate imported customer
-- 7 - Customer already exists and overwrite is not enabled
-- 8 - Customer Xref incomplete
-- Item Xref Logs
-- 9 - Invalid Item
-- 10 - Duplicate imported item
-- 11 - Item already exists and overwrite is not enabled
-- 12 - Item Xref incomplete
-- UOM Xref Logs
-- 13 - Invalid UOM
-- 14 - Duplicate imported UOM
-- 15 - UOM already exists and overwrite is not enabled
-- 16 - UOM Xref incomplete
-- Category Xref Logs
-- 17 - Invalid Category
-- 18 - Duplicate imported category
-- 19 - Category already exists and overwrite is not enabled
-- 20 - Category Xref incomplete
-- Rebate UOM Xref Logs
-- 21 - Invalid Rebate UOM
-- 22 - Duplicate imported rebate UOM
-- 23 - Rebate UOM already exists and overwrite is not enabled
-- 24 - Rebate UOM Xref incomplete

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
		Vendor.strName = FilteredVendorSetup.strVendor
WHERE
Vendor.intEntityId IS NULL
AND
FilteredVendorSetup.strVendor IS NOT NULL
UNION
SELECT -- Duplicate Vendor Name
	FilteredVendorSetup.strVendor,
	'Vendor: ' + FilteredVendorSetup.strVendor + ' has duplicate name matches.',
	FilteredVendorSetup.intRowNumber,
	2
FROM
	@tblFilteredVendorSetup FilteredVendorSetup
OUTER APPLY
(
	SELECT 
		intMatchCount = COUNT(*) 
	FROM 
		vyuAPVendor Vendor 
	WHERE Vendor.strName = FilteredVendorSetup.strVendor 
) Vendor
WHERE
Vendor.intMatchCount > 1
UNION
SELECT -- Invalid Export File Type
	FilteredVendorSetup.strExportFileType,
	'Export file type: ' + FilteredVendorSetup.strExportFileType + ' does not exist.',
	FilteredVendorSetup.intRowNumber,
	3
FROM
	@tblFilteredVendorSetup FilteredVendorSetup
WHERE
FilteredVendorSetup.strExportFileType NOT IN('CSV','TXT','XML')
AND
FilteredVendorSetup.strExportFileType IS NOT NULL
UNION
------------------------- Customer Xref Logs -------------------------
SELECT -- Invalid Customer
	FilteredVendorSetup.strCustomer,
	'Customer: ' + FilteredVendorSetup.strCustomer + ' does not exist.',
	FilteredVendorSetup.intRowNumber,
	4
FROM
	@tblFilteredVendorSetup FilteredVendorSetup
LEFT JOIN
	vyuARCustomer Customer
	ON
		FilteredVendorSetup.strCustomer = Customer.strName
		AND
		Customer.ysnActive = 1
WHERE
Customer.intEntityId IS NULL
AND
FilteredVendorSetup.strCustomer IS NOT NULL
UNION
SELECT -- Duplicate Customer Name
	FilteredVendorSetup.strCustomer,
	'Customer: ' + FilteredVendorSetup.strCustomer + ' has duplicate name matches.',
	FilteredVendorSetup.intRowNumber,
	5
FROM
	@tblFilteredVendorSetup FilteredVendorSetup
OUTER APPLY
(
	SELECT 
		intMatchCount = COUNT(*) 
	FROM 
		vyuARCustomer 
	WHERE 
		strName = FilteredVendorSetup.strCustomer 
) Customer
WHERE
Customer.intMatchCount > 1
UNION
SELECT -- Duplicate imported customer
	DuplicateVendorSetup.strCustomer,
	'Duplicate imported customer: ' + DuplicateVendorSetup.strCustomer + ' on vendor: ' + DuplicateVendorSetup.strVendor + '.', 
	DuplicateVendorSetup.intRowNumber,
	6
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
	7
FROM
	@tblFilteredVendorSetup FilteredVendorSetup
LEFT JOIN
	vyuARCustomer Customer
	ON
		FilteredVendorSetup.strCustomer = Customer.strName
LEFT JOIN
	vyuAPVendor Vendor
	ON
		FilteredVendorSetup.strVendor = Vendor.strName
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
SELECT -- Customer Xref incomplete
	CASE
		WHEN FilteredVendorSetup.strCustomer IS NOT NULL AND FilteredVendorSetup.strVendorCustomer IS NULL
		THEN FilteredVendorSetup.strCustomer
		WHEN FilteredVendorSetup.strCustomer IS NULL AND FilteredVendorSetup.strVendorCustomer IS NOT NULL
		THEN FilteredVendorSetup.strVendorCustomer
		ELSE NULL
	END,
	CASE
		WHEN FilteredVendorSetup.strCustomer IS NOT NULL AND FilteredVendorSetup.strVendorCustomer IS NULL
		THEN 'Vendor cross reference is missing for customer: ' + FilteredVendorSetup.strCustomer + '.'
		WHEN FilteredVendorSetup.strCustomer IS NULL AND FilteredVendorSetup.strVendorCustomer IS NOT NULL
		THEN 'Customer is missing for vendor cross reference: ' + FilteredVendorSetup.strVendorCustomer + '.'
		ELSE NULL
	END,
	FilteredVendorSetup.intRowNumber,
	8
FROM
	@tblFilteredVendorSetup FilteredVendorSetup
WHERE
(
	FilteredVendorSetup.strCustomer IS NOT NULL 
	AND 
	FilteredVendorSetup.strVendorCustomer IS NULL
)
OR
(
	FilteredVendorSetup.strCustomer IS NULL 
	AND 
	FilteredVendorSetup.strVendorCustomer IS NOT NULL
)
UNION
--------------------------- Item Xref Logs ---------------------------
SELECT -- Invalid Item
	FilteredVendorSetup.strItemNo,
	'Item: ' + FilteredVendorSetup.strItemNo + ' does not exist.',
	FilteredVendorSetup.intRowNumber,
	9
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
AND
FilteredVendorSetup.strItemNo IS NOT NULL
UNION
SELECT -- Duplicate imported item
	DuplicateVendorSetup.strItemNo,
	'Duplicate imported item: ' + DuplicateVendorSetup.strItemNo + ' on vendor: ' + DuplicateVendorSetup.strVendor + '.', 
	DuplicateVendorSetup.intRowNumber,
	10
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
	11
FROM
	@tblFilteredVendorSetup FilteredVendorSetup
LEFT JOIN
	tblICItem Item
	ON
		FilteredVendorSetup.strItemNo = Item.strItemNo
LEFT JOIN
	vyuAPVendor Vendor
	ON
		FilteredVendorSetup.strVendor = Vendor.strName
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
SELECT -- Item Xref incomplete
	CASE
		WHEN FilteredVendorSetup.strItemNo IS NOT NULL AND FilteredVendorSetup.strVendorItemNo IS NULL
		THEN FilteredVendorSetup.strItemNo
		WHEN FilteredVendorSetup.strItemNo IS NULL AND FilteredVendorSetup.strVendorItemNo IS NOT NULL
		THEN FilteredVendorSetup.strVendorItemNo
		ELSE NULL
	END,
	CASE
		WHEN FilteredVendorSetup.strItemNo IS NOT NULL AND FilteredVendorSetup.strVendorItemNo IS NULL
		THEN 'Vendor cross reference is missing for item: ' + FilteredVendorSetup.strItemNo + '.'
		WHEN FilteredVendorSetup.strItemNo IS NULL AND FilteredVendorSetup.strVendorItemNo IS NOT NULL
		THEN 'Item is missing for vendor cross reference: ' + FilteredVendorSetup.strVendorItemNo + '.'
		ELSE NULL
	END,
	FilteredVendorSetup.intRowNumber,
	12
FROM
	@tblFilteredVendorSetup FilteredVendorSetup
WHERE
(
	FilteredVendorSetup.strItemNo IS NOT NULL 
	AND 
	FilteredVendorSetup.strVendorItemNo IS NULL
)
OR
(
	FilteredVendorSetup.strItemNo IS NULL 
	AND 
	FilteredVendorSetup.strVendorItemNo IS NOT NULL
)
UNION
--------------------------- UOM Xref Logs ---------------------------
SELECT -- Invalid UOM
	FilteredVendorSetup.strUnitMeasure,
	'Unit of measure: ' + FilteredVendorSetup.strUnitMeasure + ' does not exist.',
	FilteredVendorSetup.intRowNumber,
	13
FROM
	@tblFilteredVendorSetup FilteredVendorSetup
LEFT JOIN
	tblICUnitMeasure UnitMeasure
	ON
		FilteredVendorSetup.strUnitMeasure = UnitMeasure.strUnitMeasure
WHERE
UnitMeasure.intUnitMeasureId IS NULL
AND
FilteredVendorSetup.strUnitMeasure IS NOT NULL
UNION
SELECT -- Duplicate imported unit of measure
	DuplicateVendorSetup.strUnitMeasure,
	'Duplicate imported unit of measure: ' + DuplicateVendorSetup.strUnitMeasure + ' on vendor: ' + DuplicateVendorSetup.strVendor + '.', 
	DuplicateVendorSetup.intRowNumber,
	14
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
	15
FROM
	@tblFilteredVendorSetup FilteredVendorSetup
LEFT JOIN
	tblICUnitMeasure UnitMeasure
	ON
		FilteredVendorSetup.strUnitMeasure = UnitMeasure.strUnitMeasure
LEFT JOIN
	vyuAPVendor Vendor
	ON
		FilteredVendorSetup.strVendor = Vendor.strName
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
SELECT -- UOM Xref incomplete
	CASE
		WHEN FilteredVendorSetup.strUnitMeasure IS NOT NULL AND FilteredVendorSetup.strVendorUnitMeasure IS NULL
		THEN FilteredVendorSetup.strUnitMeasure
		WHEN FilteredVendorSetup.strUnitMeasure IS NULL AND FilteredVendorSetup.strVendorUnitMeasure IS NOT NULL
		THEN FilteredVendorSetup.strVendorUnitMeasure
		ELSE NULL
	END,
	CASE
		WHEN FilteredVendorSetup.strUnitMeasure IS NOT NULL AND FilteredVendorSetup.strVendorUnitMeasure IS NULL
		THEN 'Vendor cross reference is missing for unit of measure: ' + FilteredVendorSetup.strUnitMeasure + '.'
		WHEN FilteredVendorSetup.strUnitMeasure IS NULL AND FilteredVendorSetup.strVendorUnitMeasure IS NOT NULL
		THEN 'Unit of measure is missing for vendor cross reference: ' + FilteredVendorSetup.strVendorUnitMeasure + '.'
		ELSE NULL
	END,
	FilteredVendorSetup.intRowNumber,
	16
FROM
	@tblFilteredVendorSetup FilteredVendorSetup
WHERE
(
	FilteredVendorSetup.strUnitMeasure IS NOT NULL 
	AND 
	FilteredVendorSetup.strVendorUnitMeasure IS NULL
)
OR
(
	FilteredVendorSetup.strUnitMeasure IS NULL 
	AND 
	FilteredVendorSetup.strVendorUnitMeasure IS NOT NULL
)
UNION
------------------------- Category Xref Logs -------------------------
SELECT -- Invalid Category
	FilteredVendorSetup.strCategory,
	'Category: ' + FilteredVendorSetup.strCategory + ' does not exist.',
	FilteredVendorSetup.intRowNumber,
	17
FROM
	@tblFilteredVendorSetup FilteredVendorSetup
LEFT JOIN
	tblICCategory Category
	ON
		FilteredVendorSetup.strCategory = Category.strCategoryCode
WHERE
Category.intCategoryId IS NULL
AND
FilteredVendorSetup.strCategory IS NOT NULL
UNION
SELECT -- Duplicate imported category
	DuplicateVendorSetup.strCategory,
	'Duplicate imported category: ' + DuplicateVendorSetup.strCategory + ' on vendor: ' + DuplicateVendorSetup.strVendor + '.', 
	DuplicateVendorSetup.intRowNumber,
	18
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
	19
FROM
	@tblFilteredVendorSetup FilteredVendorSetup
LEFT JOIN
	tblICCategory Category
	ON
		FilteredVendorSetup.strCategory = Category.strCategoryCode
LEFT JOIN
	vyuAPVendor Vendor
	ON
		FilteredVendorSetup.strVendor = Vendor.strName
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
UNION
SELECT -- Category Xref incomplete
	CASE
		WHEN FilteredVendorSetup.strCategory IS NOT NULL AND FilteredVendorSetup.strVendorCategory IS NULL
		THEN FilteredVendorSetup.strCategory
		WHEN FilteredVendorSetup.strCategory IS NULL AND FilteredVendorSetup.strVendorCategory IS NOT NULL
		THEN FilteredVendorSetup.strVendorCategory
		ELSE NULL
	END,
	CASE
		WHEN FilteredVendorSetup.strCategory IS NOT NULL AND FilteredVendorSetup.strVendorCategory IS NULL
		THEN 'Vendor cross reference is missing for category: ' + FilteredVendorSetup.strCategory + '.'
		WHEN FilteredVendorSetup.strCategory IS NULL AND FilteredVendorSetup.strVendorCategory IS NOT NULL
		THEN 'Category is missing for vendor cross reference: ' + FilteredVendorSetup.strVendorCategory + '.'
		ELSE NULL
	END,
	FilteredVendorSetup.intRowNumber,
	20
FROM
	@tblFilteredVendorSetup FilteredVendorSetup
WHERE
(
	FilteredVendorSetup.strCategory IS NOT NULL 
	AND 
	FilteredVendorSetup.strVendorCategory IS NULL
)
OR
(
	FilteredVendorSetup.strCategory IS NULL 
	AND 
	FilteredVendorSetup.strVendorCategory IS NOT NULL
)
UNION
------------------------ Rebate UOM Xref Logs ------------------------
SELECT -- Invalid Rebate UOM
	FilteredVendorSetup.strRebateUnitMeasure,
	'Rebate Unit of measure: ' + FilteredVendorSetup.strRebateUnitMeasure + ' does not exist.',
	FilteredVendorSetup.intRowNumber,
	21
FROM
	@tblFilteredVendorSetup FilteredVendorSetup
LEFT JOIN
	tblICUnitMeasure UnitMeasure
	ON
		FilteredVendorSetup.strRebateUnitMeasure = UnitMeasure.strUnitMeasure
WHERE
UnitMeasure.intUnitMeasureId IS NULL
AND
FilteredVendorSetup.strRebateUnitMeasure IS NOT NULL
UNION
SELECT -- Duplicate imported unit of measure
	DuplicateVendorSetup.strRebateUnitMeasure,
	'Duplicate imported rebate unit of measure: ' + DuplicateVendorSetup.strRebateUnitMeasure + ' on vendor: ' + DuplicateVendorSetup.strVendor + '.', 
	DuplicateVendorSetup.intRowNumber,
	22
FROM
(
	SELECT 
		FilteredVendorSetup.strRebateUnitMeasure,
		FilteredVendorSetup.strVendor,
		FilteredVendorSetup.intRowNumber,
		RowNumber = ROW_NUMBER() OVER(PARTITION BY FilteredVendorSetup.strVendor, FilteredVendorSetup.strRebateUnitMeasure ORDER BY FilteredVendorSetup.intRowNumber)
	FROM 
		@tblFilteredVendorSetup FilteredVendorSetup
) AS DuplicateVendorSetup
WHERE DuplicateVendorSetup.RowNumber > 1
AND
DuplicateVendorSetup.strRebateUnitMeasure IS NOT NULL
UNION
SELECT  -- Unit of measure already exists
	FilteredVendorSetup.strRebateUnitMeasure,
	'Rebate unit of measure: ' + FilteredVendorSetup.strRebateUnitMeasure + ' on vendor: ' + FilteredVendorSetup.strVendor + ' already exists and overwrite is not enabled.',
	FilteredVendorSetup.intRowNumber,
	23
FROM
	@tblFilteredVendorSetup FilteredVendorSetup
LEFT JOIN
	tblICUnitMeasure UnitMeasure
	ON
		FilteredVendorSetup.strRebateUnitMeasure = UnitMeasure.strUnitMeasure
LEFT JOIN
	vyuAPVendor Vendor
	ON
		FilteredVendorSetup.strVendor = Vendor.strName
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
SELECT -- Rebate UOM Xref incomplete
	CASE
		WHEN FilteredVendorSetup.strRebateUnitMeasure IS NOT NULL AND FilteredVendorSetup.strVendorRebateUnitMeasure IS NULL
		THEN FilteredVendorSetup.strRebateUnitMeasure
		WHEN FilteredVendorSetup.strRebateUnitMeasure IS NULL AND FilteredVendorSetup.strVendorRebateUnitMeasure IS NOT NULL
		THEN FilteredVendorSetup.strVendorRebateUnitMeasure
		ELSE NULL
	END,
	CASE
		WHEN FilteredVendorSetup.strRebateUnitMeasure IS NOT NULL AND FilteredVendorSetup.strVendorRebateUnitMeasure IS NULL
		THEN 'Vendor cross reference is missing for rebate unit of measure: ' + FilteredVendorSetup.strRebateUnitMeasure + '.'
		WHEN FilteredVendorSetup.strRebateUnitMeasure IS NULL AND FilteredVendorSetup.strVendorRebateUnitMeasure IS NOT NULL
		THEN 'Rebate unit of measure is missing for vendor cross reference: ' + FilteredVendorSetup.strVendorRebateUnitMeasure + '.'
		ELSE NULL
	END,
	FilteredVendorSetup.intRowNumber,
	24
FROM
	@tblFilteredVendorSetup FilteredVendorSetup
WHERE
(
	FilteredVendorSetup.strRebateUnitMeasure IS NOT NULL 
	AND 
	FilteredVendorSetup.strVendorRebateUnitMeasure IS NULL
)
OR
(
	FilteredVendorSetup.strRebateUnitMeasure IS NULL 
	AND 
	FilteredVendorSetup.strVendorRebateUnitMeasure IS NOT NULL
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
		WHEN LogVendorSetup.intLogType IN (1,2)
		THEN 'Vendor'
		WHEN LogVendorSetup.intLogType = 3
		THEN 'Export File Type'
		WHEN LogVendorSetup.intLogType IN (4,5,6,7,8)
		THEN 'Customer Name'
		WHEN LogVendorSetup.intLogType IN (9,10,11,12)
		THEN 'Item Name'
		WHEN LogVendorSetup.intLogType IN (13,14,15,16)
		THEN 'UOM Name'
		WHEN LogVendorSetup.intLogType IN (17,18,19,20)
		THEN 'Category Name'
		ELSE 'Rebate UOM Name'
	END,
	strValue = LogVendorSetup.strFieldValue,
	strLogLevel =  CASE
		WHEN LogVendorSetup.intLogType IN(2,5,6,7,8,10,11,12,14,15,16,18,19,20,22,23,24)
		THEN 'Warning'
		ELSE 'Error'
	END,
	strStatus = CASE
		WHEN LogVendorSetup.intLogType IN(2,5,6,7,8,10,11,12,14,15,16,18,19,20,22,23,24)
		THEN 'Skipped'
		ELSE 'Failed'
	END,
	intRowNo = LogVendorSetup.intRowNumber,
	strMessage = LogVendorSetup.strMessage
FROM @tblLogVendorSetup LogVendorSetup
WHERE LogVendorSetup.intLogType BETWEEN 1 AND 24

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
			LogVendorSetup.intLogType IN (1,2,3)
	INNER JOIN
		vyuAPVendor Vendor
		ON
			Vendor.strName = FilteredVendorSetup.strVendor
	WHERE
	LogVendorSetup.intLogType NOT IN (1,2,3) OR LogVendorSetup.intLogType IS NULL
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
		strVendorCustomer = ISNULL(FilteredVendorSetup.strVendorCustomer, Customer.strName)
	FROM @tblFilteredVendorSetup FilteredVendorSetup
	LEFT JOIN
		@tblLogVendorSetup LogVendorSetup
		ON
			FilteredVendorSetup.intRowNumber = LogVendorSetup.intRowNumber
			AND
			LogVendorSetup.intLogType IN (1,2,3,4,5,6,7,8)
	INNER JOIN
		vyuARCustomer Customer
		ON
			FilteredVendorSetup.strCustomer = Customer.strName
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
			Vendor.strName = FilteredVendorSetup.strVendor
	WHERE 
	LogVendorSetup.intLogType NOT IN (1,2,3,4,5,6,7,8) OR LogVendorSetup.intLogType IS NULL
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
			LogVendorSetup.intLogType IN (1,2,3,9,10,11,12)
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
			Vendor.strName = FilteredVendorSetup.strVendor
	WHERE 
	LogVendorSetup.intLogType NOT IN (1,2,3,9,10,11,12) OR LogVendorSetup.intLogType IS NULL
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
			LogVendorSetup.intLogType IN (1,2,3,13,14,15,16)
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
			Vendor.strName = FilteredVendorSetup.strVendor
	WHERE 
	LogVendorSetup.intLogType NOT IN (1,2,3,13,14,15,16) OR LogVendorSetup.intLogType IS NULL
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
			LogVendorSetup.intLogType IN (1,2,3,17,18,19,20)
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
			Vendor.strName = FilteredVendorSetup.strVendor
	WHERE 
	LogVendorSetup.intLogType NOT IN (1,2,3,17,18,19,20) OR LogVendorSetup.intLogType IS NULL
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

--Rebate UOM Xref Transform logic

;MERGE INTO tblVRUOMXref AS TARGET
USING
(
	SELECT
		guiApiUniqueId = @guiApiUniqueId,
		intVendorSetupId = VendorSetup.intVendorSetupId,
		intUnitMeasureId = UnitMeasure.intUnitMeasureId,
		strVendorUOM = ISNULL(FilteredVendorSetup.strVendorRebateUnitMeasure, UnitMeasure.strUnitMeasure),
		strEquipmentType = FilteredVendorSetup.strEquipmentType
	FROM @tblFilteredVendorSetup FilteredVendorSetup
	LEFT JOIN
		@tblLogVendorSetup LogVendorSetup
		ON
			FilteredVendorSetup.intRowNumber = LogVendorSetup.intRowNumber
			AND
			LogVendorSetup.intLogType IN (1,2,3,21,22,23,24)
	INNER JOIN
		tblICUnitMeasure UnitMeasure
		ON
			FilteredVendorSetup.strRebateUnitMeasure = UnitMeasure.strUnitMeasure
	INNER JOIN
	(
		vyuAPVendor Vendor
		INNER JOIN
			tblVRVendorSetup VendorSetup 
			ON
				Vendor.intEntityId = VendorSetup.intEntityId
	)
		ON
			Vendor.strName = FilteredVendorSetup.strVendor
	WHERE 
	LogVendorSetup.intLogType NOT IN (1,2,3,21,22,23,24) OR LogVendorSetup.intLogType IS NULL
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