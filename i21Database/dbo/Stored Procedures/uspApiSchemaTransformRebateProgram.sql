CREATE PROCEDURE uspApiSchemaTransformRebateProgram 
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

--Filter Rebate Program imported

DECLARE @tblFilteredRebateProgram TABLE(
	intKey INT NOT NULL,
    intRowNumber INT NULL,
	strVendor NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	strVendorProgram NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	strDescription NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	ysnActive BIT NULL,
	strItemNo NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	strVendorItemNo NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	strRebateBy NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	strRebateUOM NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	strVendorRebateUOM NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	dblRebateRate NUMERIC(38, 20) NULL,
	dtmBeginDate DATETIME NULL,
	dtmEndDate DATETIME NULL,
	strCategory NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	strVendorCategory NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	strCustomer NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	strVendorCustomer NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
)
INSERT INTO @tblFilteredRebateProgram
(
	intKey,
    intRowNumber,
	strVendor,
	strVendorProgram,
	strDescription,
	ysnActive,
	strItemNo,
	strVendorItemNo,
	strRebateBy,
	strRebateUOM,
	strVendorRebateUOM,
	dblRebateRate,
	dtmBeginDate,
	dtmEndDate,
	strCategory,
	strVendorCategory,
	strCustomer,
	strVendorCustomer
)
SELECT 
	intKey,
    intRowNumber,
	strVendor,
	strVendorProgram,
	strDescription,
	ysnActive,
	strItemNo,
	strVendorItemNo,
	strRebateBy,
	strRebateUOM,
	strVendorRebateUOM,
	dblRebateRate,
	dtmBeginDate,
	dtmEndDate,
	strCategory,
	strVendorCategory,
	strCustomer,
	strVendorCustomer
FROM
tblApiSchemaTransformRebateProgram
WHERE guiApiUniqueId = @guiApiUniqueId;

-- Error Types
-- Rebate Program Logs
-- 1 - Invalid Vendor
-- Rebate Item Logs
-- 2 - Duplicate or overlapping imported rebate program item effectivity duration
-- 3 - Overlapping existing record on rebate program item effectivity duration
-- 4 - Rebate program item effectivity duration already exist and overwrite is not enabled
-- 5 - Invalid Item No
-- 6 - Invalid Category
-- 7 - Invalid Item No Xref
-- 8 - Invalid Category Xref
-- 9 - Invalid Rebate by
-- 10 - Invalid Rebate UOM
-- 11 - Invalid Rebate UOM Xref
-- Rebate Customer Logs
-- 12 - Invalid Rebate Customer
-- 13 - Invalid Customer Xref


DECLARE @tblLogRebateProgram TABLE(
	strFieldValue NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strMessage NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	intRowNumber INT NULL,
	intLogType INT NULL
)

INSERT INTO @tblLogRebateProgram
(
	strFieldValue,
	strMessage,
	intRowNumber,
	intLogType
)
------------------------- Rebate Program Logs -------------------------
SELECT -- Invalid Vendor
	FilteredRebateProgram.strVendor,
	'Vendor: ' + FilteredRebateProgram.strVendor + ' does not exist.',
	FilteredRebateProgram.intRowNumber,
	1
FROM
	@tblFilteredRebateProgram FilteredRebateProgram
LEFT JOIN
(
	vyuAPVendor Vendor
	INNER JOIN
		tblVRVendorSetup VendorSetup 
		ON
			Vendor.intEntityId = VendorSetup.intEntityId
)
	ON
		Vendor.strName = FilteredRebateProgram.strVendor
WHERE
Vendor.intEntityId IS NULL
UNION
-------------------------- Rebate Item Logs --------------------------
SELECT -- Duplicate or overlapping imported rebate program item effectivity duration
	CASE
		WHEN DuplicateRebateProgram.Error = 'Category'
		THEN ISNULL(DuplicateRebateProgram.strVendorCategory, DuplicateRebateProgram.strCategory)
		ELSE ISNULL(DuplicateRebateProgram.strVendorItemNo, DuplicateRebateProgram.strItemNo)
	END,
	CASE
		WHEN DuplicateRebateProgram.Error = 'Category'
		THEN 'Duplicate or overlapping effectivity duration of imported rebate referenced item category: ' + DuplicateRebateProgram.strCategory + ' on vendor: ' + DuplicateRebateProgram.strVendor + '.'
		ELSE 'Duplicate or overlapping effectivity duration of imported rebate referenced item: ' + DuplicateRebateProgram.strItemNo + ' on vendor: ' + DuplicateRebateProgram.strVendor + '.' 
	END,
	DuplicateRebateProgram.intRowNumber,
	2
FROM
(
	SELECT 
		strItemNo = ISNULL(MIN(FilteredItem.strItemNo), MIN(FilteredRebateProgram.strItemNo)),
		strVendorItemNo = MIN(FilteredRebateProgram.strVendorItemNo),
		strCategory = ISNULL(MIN(FilteredCategory.strCategoryCode), MIN(FilteredRebateProgram.strCategory)),
		strVendorCategory = MIN(FilteredRebateProgram.strVendorCategory),
		strVendor = MIN(FilteredRebateProgram.strVendor),
		FilteredRebateProgram.intRowNumber,
		Error = CASE
			WHEN MIN(FilteredRebateProgram.strItemNo) IS NULL AND MIN(FilteredRebateProgram.strVendorItemNo) IS NULL
			THEN 'Category'
			ELSE 'Item'
		END,
		RowNumber = CASE
			WHEN MIN(FilteredRebateProgram.strItemNo) IS NULL AND MIN(FilteredRebateProgram.strVendorItemNo) IS NULL
			THEN ROW_NUMBER() OVER(PARTITION BY 
					MIN(FilteredRebateProgram.strVendor), 
					ISNULL(MIN(FilteredCategory.strCategoryCode), MIN(FilteredRebateProgram.strCategory)) ORDER BY FilteredRebateProgram.intRowNumber)
			ELSE ROW_NUMBER() OVER(PARTITION BY 
					MIN(FilteredRebateProgram.strVendor), 
					ISNULL(MIN(FilteredItem.strItemNo), MIN(FilteredRebateProgram.strItemNo)) ORDER BY FilteredRebateProgram.intRowNumber)
		END
	FROM 
		@tblFilteredRebateProgram FilteredRebateProgram
	LEFT JOIN
	(
		vyuAPVendor Vendor
		INNER JOIN
			tblVRVendorSetup VendorSetup 
			ON
				Vendor.intEntityId = VendorSetup.intEntityId
	)
		ON
			Vendor.strName = FilteredRebateProgram.strVendor
	LEFT JOIN 
		tblICItemVendorXref FilteredItemXref
		ON
			FilteredItemXref.intVendorSetupId = VendorSetup.intVendorSetupId
			AND
			FilteredItemXref.strVendorProduct = FilteredRebateProgram.strVendorItemNo
	LEFT JOIN
		tblICItem FilteredItem
		ON
			FilteredItemXref.intItemId = FilteredItem.intItemId
	LEFT JOIN 
		tblICCategoryVendor FilteredCategoryXref
		ON
			FilteredCategoryXref.intVendorSetupId = VendorSetup.intVendorSetupId
			AND
			FilteredCategoryXref.strVendorDepartment = FilteredRebateProgram.strVendorCategory
	LEFT JOIN
		tblICCategory FilteredCategory
		ON
			FilteredCategoryXref.intCategoryId = FilteredCategory.intCategoryId
	INNER JOIN
	(
		@tblFilteredRebateProgram ComparedRebateProgram
		LEFT JOIN
		(
			vyuAPVendor ComparedVendor
			INNER JOIN
				tblVRVendorSetup ComparedVendorSetup 
				ON
					ComparedVendor.intEntityId = ComparedVendorSetup.intEntityId
		)
			ON
				ComparedVendor.strName = ComparedRebateProgram.strVendor
		LEFT JOIN 
			tblICItemVendorXref ComparedItemXref
			ON
				ComparedItemXref.intVendorSetupId = ComparedVendorSetup.intVendorSetupId
				AND
				ComparedItemXref.strVendorProduct = ComparedRebateProgram.strVendorItemNo
		LEFT JOIN
			tblICItem ComparedItem
			ON
				ComparedItemXref.intItemId = ComparedItem.intItemId
		LEFT JOIN 
			tblICCategoryVendor ComparedCategoryXref
			ON
				ComparedCategoryXref.intVendorSetupId = ComparedVendorSetup.intVendorSetupId
				AND
				ComparedCategoryXref.strVendorDepartment = ComparedRebateProgram.strVendorCategory
		LEFT JOIN
			tblICCategory ComparedCategory
			ON
				ComparedCategoryXref.intCategoryId = ComparedCategory.intCategoryId
			
	)
		ON
			FilteredRebateProgram.strVendor = ComparedRebateProgram.strVendor
			AND
			(
				(
					ISNULL(FilteredRebateProgram.strVendorItemNo, FilteredRebateProgram.strItemNo) IS NULL
					AND
					ISNULL(FilteredRebateProgram.strVendorCategory, FilteredRebateProgram.strCategory) IS NOT NULL
					AND
					ISNULL(FilteredCategory.strCategoryCode, FilteredRebateProgram.strCategory) = ISNULL(ComparedCategory.strCategoryCode, ComparedRebateProgram.strCategory)	
				)
				OR
				(
					ISNULL(FilteredRebateProgram.strVendorItemNo, FilteredRebateProgram.strItemNo) IS NOT NULL
					AND
					ISNULL(FilteredItem.strItemNo, FilteredRebateProgram.strItemNo) = ISNULL(ComparedItem.strItemNo, ComparedRebateProgram.strItemNo)	
				)
			)
			AND
			FilteredRebateProgram.intRowNumber <> ComparedRebateProgram.intRowNumber
			AND
			FilteredRebateProgram.dtmBeginDate < ComparedRebateProgram.dtmEndDate
			AND
			FilteredRebateProgram.dtmEndDate > ComparedRebateProgram.dtmBeginDate
	GROUP BY FilteredRebateProgram.intRowNumber
) AS DuplicateRebateProgram
WHERE DuplicateRebateProgram.RowNumber > 1
UNION
SELECT -- Overlapping existing record on rebate program item effectivity duration
	CASE
		WHEN ISNULL(Item.strItemNo, FilteredRebateProgram.strItemNo) IS NULL
		THEN ISNULL(Category.strCategoryCode, FilteredRebateProgram.strCategory)
		ELSE ISNULL(Item.strItemNo, FilteredRebateProgram.strItemNo)
	END,
	CASE
		WHEN ISNULL(Item.strItemNo, FilteredRebateProgram.strItemNo) IS NULL
		THEN 'Rebate item category: ' + ISNULL(Category.strCategoryCode, FilteredRebateProgram.strCategory) + ' on vendor: ' + FilteredRebateProgram.strVendor + ' overlaps effectivity date of existing record.'
		ELSE 'Rebate item: ' + ISNULL(Item.strItemNo, FilteredRebateProgram.strItemNo) + ' on vendor: ' + FilteredRebateProgram.strVendor + ' overlaps effectivity date of existing record.'
	END,
	FilteredRebateProgram.intRowNumber,
	3
FROM
	@tblFilteredRebateProgram FilteredRebateProgram
INNER JOIN
(
	vyuAPVendor Vendor
	INNER JOIN
		tblVRVendorSetup VendorSetup 
		ON
			Vendor.intEntityId = VendorSetup.intEntityId
)
	ON
		Vendor.strName = FilteredRebateProgram.strVendor
LEFT JOIN
	tblICCategoryVendor CategoryXref
	ON
		ISNULL(FilteredRebateProgram.strVendorItemNo, FilteredRebateProgram.strItemNo) IS NULL
		AND
		FilteredRebateProgram.strVendorCategory IS NOT NULL
		AND
		CategoryXref.strVendorDepartment = FilteredRebateProgram.strVendorCategory
LEFT JOIN
	tblICCategory Category
	ON
		Category.intCategoryId = CategoryXref.intCategoryId
LEFT JOIN
	tblICItemVendorXref ItemXref
	ON
		FilteredRebateProgram.strVendorItemNo IS NOT NULL
		AND
		ItemXref.strVendorProduct = FilteredRebateProgram.strVendorItemNo
LEFT JOIN 
	tblICItem Item
	ON
		Item.intItemId = ItemXref.intItemId
INNER JOIN
	vyuVRProgramItemDetail RebateItem
	ON
		FilteredRebateProgram.strVendor = RebateItem.strVendorName
		AND
		(
			(
				ISNULL(Item.strItemNo, FilteredRebateProgram.strItemNo) IS NULL
				AND
				ISNULL(Category.strCategoryCode, FilteredRebateProgram.strCategory) IS NOT NULL
				AND
				ISNULL(Category.strCategoryCode, FilteredRebateProgram.strCategory) = RebateItem.strCategoryCode
				AND
				(
					RebateItem.strItemNumber IS NULL 
					OR 
					RebateItem.strItemNumber = ''
				)
			)
			OR
			(
				ISNULL(Item.strItemNo, FilteredRebateProgram.strItemNo) IS NOT NULL
				AND
				ISNULL(Item.strItemNo, FilteredRebateProgram.strItemNo) = RebateItem.strItemNumber
			)
		)
WHERE
FilteredRebateProgram.dtmBeginDate < RebateItem.dtmEndDate
AND
FilteredRebateProgram.dtmEndDate > RebateItem.dtmBeginDate
AND
(
	FilteredRebateProgram.dtmBeginDate <> RebateItem.dtmBeginDate
	OR
	FilteredRebateProgram.dtmEndDate <> RebateItem.dtmEndDate
)
UNION
SELECT -- Rebate program item effectivity duration already exist and overwrite is not enabled
	CASE
		WHEN ISNULL(Item.strItemNo, FilteredRebateProgram.strItemNo) IS NULL
		THEN ISNULL(Category.strCategoryCode, FilteredRebateProgram.strCategory)
		ELSE ISNULL(Item.strItemNo, FilteredRebateProgram.strItemNo)
	END,
	CASE
		WHEN ISNULL(Item.strItemNo, FilteredRebateProgram.strItemNo) IS NULL
		THEN 'Rebate item category: ' + ISNULL(Category.strCategoryCode, FilteredRebateProgram.strCategory) + ' on vendor: ' + FilteredRebateProgram.strVendor + ' with this effectivity date already exist and overwrite is not enabled.'
		ELSE 'Rebate item: ' + ISNULL(Item.strItemNo, FilteredRebateProgram.strItemNo) + ' on vendor: ' + FilteredRebateProgram.strVendor + ' with this effectivity date already exist and overwrite is not enabled.'
	END,
	FilteredRebateProgram.intRowNumber,
	4
FROM
	@tblFilteredRebateProgram FilteredRebateProgram
INNER JOIN
(
	vyuAPVendor Vendor
	INNER JOIN
		tblVRVendorSetup VendorSetup 
		ON
			Vendor.intEntityId = VendorSetup.intEntityId
)
	ON
		Vendor.strName = FilteredRebateProgram.strVendor
LEFT JOIN
	tblICCategoryVendor CategoryXref
	ON
		ISNULL(FilteredRebateProgram.strVendorItemNo, FilteredRebateProgram.strItemNo) IS NULL
		AND
		FilteredRebateProgram.strVendorCategory IS NOT NULL
		AND
		CategoryXref.strVendorDepartment = FilteredRebateProgram.strVendorCategory
LEFT JOIN
	tblICCategory Category
	ON
		Category.intCategoryId = CategoryXref.intCategoryId
LEFT JOIN
	tblICItemVendorXref ItemXref
	ON
		FilteredRebateProgram.strVendorItemNo IS NOT NULL
		AND
		ItemXref.strVendorProduct = FilteredRebateProgram.strVendorItemNo
LEFT JOIN 
	tblICItem Item
	ON
		Item.intItemId = ItemXref.intItemId
INNER JOIN
	vyuVRProgramItemDetail RebateItem
	ON
		FilteredRebateProgram.strVendor = RebateItem.strVendorName
		AND
		(
			(
				ISNULL(Item.strItemNo, FilteredRebateProgram.strItemNo) IS NULL
				AND
				ISNULL(Category.strCategoryCode, FilteredRebateProgram.strCategory) IS NOT NULL
				AND
				ISNULL(Category.strCategoryCode, FilteredRebateProgram.strCategory) = RebateItem.strCategoryCode
				AND
				(
					RebateItem.strItemNumber IS NULL 
					OR 
					RebateItem.strItemNumber = ''
				)
			)
			OR
			(
				ISNULL(Item.strItemNo, FilteredRebateProgram.strItemNo) IS NOT NULL
				AND
				ISNULL(Item.strItemNo, FilteredRebateProgram.strItemNo) = RebateItem.strItemNumber
			)
		)
WHERE
FilteredRebateProgram.dtmBeginDate = RebateItem.dtmBeginDate
AND
FilteredRebateProgram.dtmEndDate = RebateItem.dtmEndDate
AND
@ysnAllowOverwrite = 0
UNION
SELECT -- Invalid Item No
	FilteredRebateProgram.strItemNo,
	'Rebate item: ' + FilteredRebateProgram.strItemNo + ' does not exist.', 
	FilteredRebateProgram.intRowNumber,
	5
FROM
	@tblFilteredRebateProgram FilteredRebateProgram
LEFT JOIN
	tblICItem Item
	ON
		FilteredRebateProgram.strItemNo = Item.strItemNo
WHERE
Item.intItemId IS NULL
AND
FilteredRebateProgram.strItemNo IS NOT NULL
UNION
SELECT -- Invalid Category
	FilteredRebateProgram.strCategory,
	'Rebate category: ' + FilteredRebateProgram.strCategory + ' does not exist.', 
	FilteredRebateProgram.intRowNumber,
	6
FROM
	@tblFilteredRebateProgram FilteredRebateProgram
LEFT JOIN
	tblICCategory Category
	ON
		FilteredRebateProgram.strCategory = Category.strCategoryCode
WHERE
Category.intCategoryId IS NULL
AND
FilteredRebateProgram.strItemNo IS NULL
AND
FilteredRebateProgram.strVendorItemNo IS NULL
AND
FilteredRebateProgram.strCategory IS NOT NULL
UNION
SELECT -- Invalid Item No Xref
	FilteredRebateProgram.strVendorItemNo,
	'Rebate vendor item no: ' + FilteredRebateProgram.strVendorItemNo + ' cross reference does not exist.', 
	FilteredRebateProgram.intRowNumber,
	7
FROM
	@tblFilteredRebateProgram FilteredRebateProgram
LEFT JOIN
(
	vyuAPVendor Vendor
	INNER JOIN
		tblVRVendorSetup VendorSetup 
		ON
			Vendor.intEntityId = VendorSetup.intEntityId
)
	ON
		Vendor.strName = FilteredRebateProgram.strVendor
LEFT JOIN 
	tblICItemVendorXref ItemXref
	ON
		VendorSetup.intVendorSetupId = ItemXref.intVendorSetupId
		AND
		FilteredRebateProgram.strVendorItemNo = ItemXref.strVendorProduct
WHERE
ItemXref.intItemVendorXrefId IS NULL
AND
FilteredRebateProgram.strVendorItemNo IS NOT NULL
UNION
SELECT -- Invalid Category Xref
	FilteredRebateProgram.strVendorCategory,
	'Rebate vendor category: ' + FilteredRebateProgram.strVendorCategory + ' cross reference does not exist.', 
	FilteredRebateProgram.intRowNumber,
	8
FROM
	@tblFilteredRebateProgram FilteredRebateProgram
LEFT JOIN
(
	vyuAPVendor Vendor
	INNER JOIN
		tblVRVendorSetup VendorSetup 
		ON
			Vendor.intEntityId = VendorSetup.intEntityId
)
	ON
		Vendor.strName = FilteredRebateProgram.strVendor
LEFT JOIN 
	tblICCategoryVendor CategoryXref
	ON
		VendorSetup.intVendorSetupId = CategoryXref.intVendorSetupId
		AND
		FilteredRebateProgram.strVendorCategory = CategoryXref.strVendorDepartment
WHERE
CategoryXref.intCategoryVendorId IS NULL
AND
FilteredRebateProgram.strItemNo IS NULL
AND
FilteredRebateProgram.strVendorItemNo IS NULL
AND
FilteredRebateProgram.strVendorCategory IS NOT NULL
UNION
SELECT -- Invalid Rebate by
	FilteredRebateProgram.strRebateBy,
	'Rebate by: ' + FilteredRebateProgram.strRebateBy + ' of rebate item: ' + FilteredRebateProgram.strItemNo + ' does not exist.', 
	FilteredRebateProgram.intRowNumber,
	9
FROM
	@tblFilteredRebateProgram FilteredRebateProgram
WHERE
	FilteredRebateProgram.strRebateBy NOT IN ('Unit', 'Percentage')
UNION
SELECT -- Invalid Rebate UOM
	ISNULL(FilteredRebateProgram.strVendorRebateUOM, FilteredRebateProgram.strRebateUOM),
	CASE
		WHEN ISNULL(FilteredRebateProgram.strVendorItemNo, FilteredRebateProgram.strItemNo) IS NULL
		THEN 'Rebate UOM: ' + ISNULL(FilteredRebateProgram.strVendorRebateUOM, FilteredRebateProgram.strRebateUOM) + ' of rebate category: ' + 
			COALESCE(Category.strCategoryCode, FilteredRebateProgram.strVendorCategory, FilteredRebateProgram.strCategory) + ' does not exist or not configured.'
		ELSE 'Rebate UOM: ' + ISNULL(FilteredRebateProgram.strVendorRebateUOM, FilteredRebateProgram.strRebateUOM) + ' of rebate item: ' + 
			COALESCE(Item.strItemNo, FilteredRebateProgram.strVendorItemNo, FilteredRebateProgram.strItemNo) + ' does not exist or not configured.'
	END,
	FilteredRebateProgram.intRowNumber,
	10
FROM
	@tblFilteredRebateProgram FilteredRebateProgram
LEFT JOIN
(
	vyuAPVendor Vendor
	INNER JOIN
		tblVRVendorSetup VendorSetup 
		ON
			Vendor.intEntityId = VendorSetup.intEntityId
)
	ON
		Vendor.strName = FilteredRebateProgram.strVendor
LEFT JOIN
	tblICCategoryVendor CategoryXref
	ON
		ISNULL(FilteredRebateProgram.strVendorItemNo, FilteredRebateProgram.strItemNo) IS NULL
		AND
		FilteredRebateProgram.strVendorCategory IS NOT NULL
		AND
		CategoryXref.strVendorDepartment = FilteredRebateProgram.strVendorCategory
LEFT JOIN
	tblICCategory Category
	ON
		Category.intCategoryId = CategoryXref.intCategoryId
LEFT JOIN
	tblICItemVendorXref ItemXref
	ON
		FilteredRebateProgram.strVendorItemNo IS NOT NULL
		AND
		ItemXref.strVendorProduct = FilteredRebateProgram.strVendorItemNo
LEFT JOIN 
	tblICItem Item
	ON
		Item.intItemId = ItemXref.intItemId
LEFT JOIN
	tblVRUOMXref UOMXref
	ON
		VendorSetup.intVendorSetupId = UOMXref.intVendorSetupId
		AND
		FilteredRebateProgram.strVendorRebateUOM = UOMXref.strVendorUOM
LEFT JOIN
	tblICUnitMeasure UnitMeasure
	ON
		UnitMeasure.intUnitMeasureId = UOMXref.intUnitMeasureId
LEFT JOIN
	vyuICItemUOM ItemUOM
	ON
		(
			(
				ISNULL(FilteredRebateProgram.strVendorItemNo, FilteredRebateProgram.strItemNo) IS NULL
				AND
				ItemUOM.strCategoryCode = ISNULL(Category.strCategoryCode, FilteredRebateProgram.strCategory)
			)
			OR
			(
				ISNULL(FilteredRebateProgram.strVendorItemNo, FilteredRebateProgram.strItemNo) IS NOT NULL
				AND
				ItemUOM.strItemNo = ISNULL(Item.strItemNo, FilteredRebateProgram.strItemNo)
			)
		)
		AND
		ItemUOM.strUnitMeasure = ISNULL(UnitMeasure.strUnitMeasure, FilteredRebateProgram.strRebateUOM)
WHERE
ItemUOM.intItemUOMId IS NULL
AND
ISNULL(FilteredRebateProgram.strVendorRebateUOM, FilteredRebateProgram.strRebateUOM) IS NOT NULL
UNION
SELECT -- Invalid Rebate UOM Xref
	FilteredRebateProgram.strVendorRebateUOM,
	'Rebate vendor rebate unit of measure: ' + FilteredRebateProgram.strVendorRebateUOM + ' cross reference does not exist.', 
	FilteredRebateProgram.intRowNumber,
	11
FROM
	@tblFilteredRebateProgram FilteredRebateProgram
LEFT JOIN
(
	vyuAPVendor Vendor
	INNER JOIN
		tblVRVendorSetup VendorSetup 
		ON
			Vendor.intEntityId = VendorSetup.intEntityId
)
	ON
		Vendor.strName = FilteredRebateProgram.strVendor
LEFT JOIN 
	tblVRUOMXref UOMXref
	ON
		VendorSetup.intVendorSetupId = UOMXref.intVendorSetupId
		AND
		FilteredRebateProgram.strVendorRebateUOM = UOMXref.strVendorUOM
WHERE
UOMXref.intUOMXrefId IS NULL
AND
FilteredRebateProgram.strVendorRebateUOM IS NOT NULL
UNION
------------------------ Rebate Customers Logs ------------------------
SELECT -- Invalid Rebate Customer
	FilteredRebateProgram.strCustomer,
	'Rebate customer: ' + FilteredRebateProgram.strCustomer + ' does not exist.', 
	FilteredRebateProgram.intRowNumber,
	12
FROM 
	@tblFilteredRebateProgram FilteredRebateProgram
LEFT JOIN
	vyuARCustomer Customer
	ON
		Customer.strName = FilteredRebateProgram.strCustomer
		AND
		Customer.ysnActive = 1
WHERE
Customer.intEntityId IS NULL
AND
FilteredRebateProgram.strCustomer IS NOT NULL
UNION
SELECT -- Invalid Customer Xref
	FilteredRebateProgram.strVendorCustomer,
	'Rebate vendor customer: ' + FilteredRebateProgram.strVendorCustomer + ' cross reference does not exist.', 
	FilteredRebateProgram.intRowNumber,
	13
FROM
	@tblFilteredRebateProgram FilteredRebateProgram
LEFT JOIN
(
	vyuAPVendor Vendor
	INNER JOIN
		tblVRVendorSetup VendorSetup 
		ON
			Vendor.intEntityId = VendorSetup.intEntityId
)
	ON
		Vendor.strName = FilteredRebateProgram.strVendor
LEFT JOIN 
	tblVRCustomerXref CustomerXref
	ON
		VendorSetup.intVendorSetupId = CustomerXref.intVendorSetupId
		AND
		FilteredRebateProgram.strVendorCustomer = CustomerXref.strVendorCustomer
WHERE
CustomerXref.intCustomerXrefId IS NULL
AND
FilteredRebateProgram.strVendorCustomer IS NOT NULL

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
		WHEN LogRebateProgram.intLogType IN (1,2,3,4)
		THEN 'Vendor'
		WHEN LogRebateProgram.intLogType = 5
		THEN 'Item No'
		WHEN LogRebateProgram.intLogType = 6
		THEN 'Category'
		WHEN LogRebateProgram.intLogType = 7
		THEN 'Vendor Item No'
		WHEN LogRebateProgram.intLogType = 8
		THEN 'Vendor Category'
		WHEN LogRebateProgram.intLogType = 9
		THEN 'Rebate By'
		WHEN LogRebateProgram.intLogType = 12
		THEN 'Customer'
		WHEN LogRebateProgram.intLogType = 13
		THEN 'Vendor Customer'
		ELSE 'Rebate UOM'
	END,
	strValue = LogRebateProgram.strFieldValue,
	strLogLevel =  CASE
		WHEN LogRebateProgram.intLogType IN(2,3,4)
		THEN 'Warning'
		ELSE 'Error'
	END,
	strStatus = CASE
		WHEN LogRebateProgram.intLogType IN(2,3,4)
		THEN 'Skipped'
		ELSE 'Failed'
	END,
	intRowNo = LogRebateProgram.intRowNumber,
	strMessage = LogRebateProgram.strMessage
FROM @tblLogRebateProgram LogRebateProgram
WHERE LogRebateProgram.intLogType BETWEEN 1 AND 13

--Rebate Program Transform logic

;MERGE INTO tblVRProgram AS TARGET
USING
(
	SELECT
		guiApiUniqueId = @guiApiUniqueId,
		intVendorSetupId = MAX(VendorSetup.intVendorSetupId),
		strVendorProgram = MAX(FilteredRebateProgram.strVendorProgram),
		strProgramDescription = MAX(FilteredRebateProgram.strDescription),
		ysnActive = MAX(CAST(FilteredRebateProgram.ysnActive AS tinyint))
	FROM @tblFilteredRebateProgram FilteredRebateProgram
	LEFT JOIN
		@tblLogRebateProgram LogRebateProgram
		ON
			FilteredRebateProgram.intRowNumber = LogRebateProgram.intRowNumber
			AND
			LogRebateProgram.intLogType = 1
	INNER JOIN
	(
		vyuAPVendor Vendor
		INNER JOIN
			tblVRVendorSetup VendorSetup 
			ON
				Vendor.intEntityId = VendorSetup.intEntityId
	)
		ON
			Vendor.strName = FilteredRebateProgram.strVendor
	WHERE
	LogRebateProgram.intLogType <> 1 OR LogRebateProgram.intLogType IS NULL
	GROUP BY
	FilteredRebateProgram.strVendor
) AS SOURCE
ON TARGET.intVendorSetupId = SOURCE.intVendorSetupId
WHEN MATCHED AND @ysnAllowOverwrite = 1 
THEN
	UPDATE SET
		guiApiUniqueId = SOURCE.guiApiUniqueId,
		strVendorProgram = SOURCE.strVendorProgram,
		strProgramDescription = SOURCE.strProgramDescription,
		ysnActive = COALESCE(SOURCE.ysnActive, TARGET.ysnActive)
WHEN NOT MATCHED THEN
	INSERT
	(
		guiApiUniqueId,
		intVendorSetupId,
		strVendorProgram,
		strProgramDescription,
		ysnActive,
		intConcurrencyId
	)
	VALUES
	(
		guiApiUniqueId,
		intVendorSetupId,
		strVendorProgram,
		strProgramDescription,
		COALESCE(ysnActive, 1),
		1
	);

--Add Transaction No to inserted Rebate Program

DECLARE @intProgramId INT

DECLARE program_cursor CURSOR FOR 
SELECT
	intProgramId
FROM 
	tblVRProgram 
WHERE
	strProgram IS NULL
	
OPEN program_cursor  
FETCH NEXT FROM program_cursor INTO 
	@intProgramId

WHILE @@FETCH_STATUS = 0  
BEGIN  

	DECLARE @strProgram NVARCHAR(MAX)

	EXEC dbo.uspSMGetStartingNumber 125, @strProgram OUTPUT, NULL

	UPDATE 
		tblVRProgram 
	SET 
		strProgram = @strProgram
	WHERE 
		intProgramId = @intProgramId
	
	FETCH NEXT FROM program_cursor INTO 
		@intProgramId
END 

CLOSE program_cursor  
DEALLOCATE program_cursor

--Rebate Program Item Transform logic

;MERGE INTO tblVRProgramItem AS TARGET
USING
(
	SELECT
		guiApiUniqueId = @guiApiUniqueId,
		intItemId = COALESCE(ItemXref.intItemId, Item.intItemId),
		intCategoryId = COALESCE(CategoryXref.intCategoryId, Category.intCategoryId, Item.intCategoryId),
		strRebateBy = FilteredRebateProgram.strRebateBy,
		dblRebateRate = FilteredRebateProgram.dblRebateRate,
		dtmBeginDate = FilteredRebateProgram.dtmBeginDate,
		dtmEndDate = FilteredRebateProgram.dtmEndDate,
		intProgramId = Program.intProgramId,
		intUnitMeasureId = COALESCE(UOMXref.intUnitMeasureId, UnitMeasure.intUnitMeasureId)
	FROM @tblFilteredRebateProgram FilteredRebateProgram
	LEFT JOIN
		@tblLogRebateProgram LogRebateProgram
		ON
			FilteredRebateProgram.intRowNumber = LogRebateProgram.intRowNumber
			AND
			LogRebateProgram.intLogType IN (1,2,3,4,5,6,7,8,9,10,11)
	INNER JOIN
	(
		vyuAPVendor Vendor
		INNER JOIN
			tblVRVendorSetup VendorSetup 
			ON
				Vendor.intEntityId = VendorSetup.intEntityId
	)
		ON
			Vendor.strName = FilteredRebateProgram.strVendor
	LEFT JOIN 
		tblICItem Item
		ON
			FilteredRebateProgram.strItemNo = Item.strItemNo
	LEFT JOIN
		tblICCategory Category
		ON
			ISNULL(FilteredRebateProgram.strVendorItemNo, FilteredRebateProgram.strItemNo) IS NULL
			AND
			FilteredRebateProgram.strCategory = Category.strCategoryCode
	LEFT JOIN
		tblICUnitMeasure UnitMeasure
		ON
			FilteredRebateProgram.strRebateUOM = UnitMeasure.strUnitMeasure
	LEFT JOIN
		tblICItemVendorXref ItemXref
		ON
			FilteredRebateProgram.strVendorItemNo IS NOT NULL
			AND
			ItemXref.intVendorSetupId = VendorSetup.intVendorSetupId
			AND
			ItemXref.strVendorProduct = FilteredRebateProgram.strVendorItemNo
	LEFT JOIN
		tblICCategoryVendor CategoryXref
		ON
			ISNULL(FilteredRebateProgram.strVendorItemNo, FilteredRebateProgram.strItemNo) IS NULL
			AND
			FilteredRebateProgram.strVendorCategory IS NOT NULL
			AND
			CategoryXref.intVendorSetupId = VendorSetup.intVendorSetupId
			AND
			CategoryXref.strVendorDepartment = FilteredRebateProgram.strVendorCategory
	LEFT JOIN 
		tblVRUOMXref UOMXref
		ON
			VendorSetup.intVendorSetupId = UOMXref.intVendorSetupId
			AND
			UOMXref.intVendorSetupId = VendorSetup.intVendorSetupId
			AND
			UOMXref.strVendorUOM = FilteredRebateProgram.strVendorRebateUOM
	OUTER APPLY
	(
		SELECT TOP 1 intProgramId FROM tblVRProgram WHERE intVendorSetupId = VendorSetup.intVendorSetupId ORDER BY intProgramId DESC	
	) Program
	WHERE 
	LogRebateProgram.intLogType NOT IN (1,2,3,4,5,6,7,8,9,10,11) OR LogRebateProgram.intLogType IS NULL
) AS SOURCE
ON 
TARGET.intProgramId = SOURCE.intProgramId
AND
TARGET.intItemId = SOURCE.intItemId
AND
TARGET.dtmBeginDate = SOURCE.dtmBeginDate
AND
TARGET.dtmEndDate = SOURCE.dtmEndDate
WHEN MATCHED AND @ysnAllowOverwrite = 1 
THEN
	UPDATE SET
		guiApiUniqueId = SOURCE.guiApiUniqueId,
		intItemId = SOURCE.intItemId,
		intCategoryId = SOURCE.intCategoryId,
		strRebateBy = SOURCE.strRebateBy,
		dblRebateRate = SOURCE.dblRebateRate,
		dtmBeginDate = SOURCE.dtmBeginDate,
		dtmEndDate = SOURCE.dtmEndDate,
		intProgramId = SOURCE.intProgramId,
		intUnitMeasureId = SOURCE.intUnitMeasureId
WHEN NOT MATCHED THEN
	INSERT
	(
		intItemId,
		guiApiUniqueId,
		intCategoryId,
		strRebateBy,
		dblRebateRate,
		dtmBeginDate,
		dtmEndDate,
		intProgramId,
		intUnitMeasureId,
		intConcurrencyId
	)
	VALUES
	(
		intItemId,
		guiApiUniqueId,
		intCategoryId,
		strRebateBy,
		dblRebateRate,
		dtmBeginDate,
		dtmEndDate,
		intProgramId,
		intUnitMeasureId,
		1
	); 

--Rebate Program Customer Transform logic

INSERT INTO tblVRProgramCustomer
(
	guiApiUniqueId,
	intProgramId,
	intEntityId,
	intConcurrencyId
)
SELECT
	@guiApiUniqueId,
	MAX(Program.intProgramId),
	ISNULL(MAX(CustomerXref.intEntityId), MAX(Customer.intEntityId)),
	1
FROM @tblFilteredRebateProgram FilteredRebateProgram
LEFT JOIN
	@tblLogRebateProgram LogRebateProgram
	ON
		FilteredRebateProgram.intRowNumber = LogRebateProgram.intRowNumber
		AND
		LogRebateProgram.intLogType IN (1,12,13)
INNER JOIN
(
	vyuAPVendor Vendor
	INNER JOIN
		tblVRVendorSetup VendorSetup 
		ON
			Vendor.intEntityId = VendorSetup.intEntityId
)
	ON
		Vendor.strName = FilteredRebateProgram.strVendor
OUTER APPLY
(
	SELECT TOP 1 intProgramId FROM tblVRProgram WHERE intVendorSetupId = VendorSetup.intVendorSetupId ORDER BY intProgramId DESC	
) Program
LEFT JOIN 
	tblEMEntity Customer
	ON
		FilteredRebateProgram.strCustomer = Customer.strName
LEFT JOIN
	tblVRCustomerXref CustomerXref
	ON
		CustomerXref.intVendorSetupId = VendorSetup.intVendorSetupId
		AND
		FilteredRebateProgram.strVendorCustomer = CustomerXref.strVendorCustomer
LEFT JOIN
	tblEMEntity VendorCustomer
	ON
		CustomerXref.intEntityId = VendorCustomer.intEntityId
LEFT JOIN
	tblVRProgramCustomer ProgramCustomer
	ON
		ProgramCustomer.intProgramId = Program.intProgramId
		AND
		ProgramCustomer.intEntityId = ISNULL(CustomerXref.intEntityId, Customer.intEntityId)
WHERE 
(
	LogRebateProgram.intLogType NOT IN (1,12,13) 
	OR 
	LogRebateProgram.intLogType IS NULL
)
AND
ProgramCustomer.intProgramCustomerId IS NULL
GROUP BY ISNULL(VendorCustomer.strName, FilteredRebateProgram.strCustomer)