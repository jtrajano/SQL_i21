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
    guiApiUniqueId UNIQUEIDENTIFIER NOT NULL,
    intRowNumber INT NULL,
	strVendor NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	strVendorProgram NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	strDescription NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	ysnActive BIT NULL,
	strItemNo NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	strRebateBy NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	strRebateUOM NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	dblRebateRate NUMERIC(38, 20) NULL,
	dtmBeginDate DATETIME NULL,
	dtmEndDate DATETIME NULL,
	strCustomer NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
)
INSERT INTO @tblFilteredRebateProgram
(
	intKey,
    guiApiUniqueId,
    intRowNumber,
	strVendor,
	strVendorProgram,
	strDescription,
	ysnActive,
	strItemNo,
	strRebateBy,
	strRebateUOM,
	dblRebateRate,
	dtmBeginDate,
	dtmEndDate,
	strCustomer
)
SELECT 
	intKey,
    guiApiUniqueId,
    intRowNumber,
	strVendor,
	strVendorProgram,
	strDescription,
	ysnActive,
	strItemNo,
	strRebateBy,
	strRebateUOM,
	dblRebateRate,
	dtmBeginDate,
	dtmEndDate,
	strCustomer
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
-- 6 - Invalid Rebate by
-- 7 - Invalid Rebate UOM
-- Rebate Customer Logs
-- 8 - Invalid Rebate Customer


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
	DuplicateRebateProgram.strItemNo,
	'Duplicate or overlapping effectivitiy duration of imported rebate item: ' + DuplicateRebateProgram.strItemNo + ' on vendor: ' + DuplicateRebateProgram.strVendor + '.', 
	DuplicateRebateProgram.intRowNumber,
	2
FROM
(
	SELECT 
		strItemNo = MIN(FilteredRebateProgram.strVendor),
		strLocation = MIN(FilteredRebateProgram.strItemNo),
		strVendor = MIN(FilteredRebateProgram.strVendor),
		FilteredRebateProgram.intRowNumber,
		RowNumber = ROW_NUMBER() OVER(PARTITION BY 
			MIN(FilteredRebateProgram.strVendor), 
			MIN(FilteredRebateProgram.strItemNo) ORDER BY FilteredRebateProgram.intRowNumber)
	FROM 
		@tblFilteredRebateProgram FilteredRebateProgram
	INNER JOIN
		@tblFilteredRebateProgram ComparedRebateProgram
		ON
			FilteredRebateProgram.strVendor = ComparedRebateProgram.strVendor
			AND
			FilteredRebateProgram.strItemNo = ComparedRebateProgram.strItemNo
			AND
			FilteredRebateProgram.dtmBeginDate < ComparedRebateProgram.dtmEndDate
			AND
			FilteredRebateProgram.dtmEndDate > ComparedRebateProgram.dtmBeginDate
	GROUP BY FilteredRebateProgram.intRowNumber
) AS DuplicateRebateProgram
WHERE DuplicateRebateProgram.RowNumber > 1
UNION
SELECT -- Overlapping existing record on rebate program item effectivity duration
	FilteredRebateProgram.strItemNo,
	'Rebate item: ' + FilteredRebateProgram.strItemNo + ' on vendor: ' + FilteredRebateProgram.strVendor + ' overlaps effectivity date of existing record.', 
	FilteredRebateProgram.intRowNumber,
	3
FROM
	@tblFilteredRebateProgram FilteredRebateProgram
INNER JOIN
	vyuVRProgramItemDetail RebateItem
	ON
		FilteredRebateProgram.strVendor = RebateItem.strVendorName
		AND
		FilteredRebateProgram.strItemNo = RebateItem.strItemNumber
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
	FilteredRebateProgram.strItemNo,
	'Rebate item: ' + FilteredRebateProgram.strItemNo + ' on vendor: ' + FilteredRebateProgram.strVendor + ' with this effectivity date already exist and overwrite is not enabled.', 
	FilteredRebateProgram.intRowNumber,
	4
FROM
	@tblFilteredRebateProgram FilteredRebateProgram
INNER JOIN
	vyuVRProgramItemDetail RebateItem
	ON
		FilteredRebateProgram.strVendor = RebateItem.strVendorName
		AND
		FilteredRebateProgram.strItemNo = RebateItem.strItemNumber
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
SELECT -- Invalid Rebate by
	FilteredRebateProgram.strRebateBy,
	'Rebate by: ' + FilteredRebateProgram.strRebateBy + ' of rebate item: ' + FilteredRebateProgram.strItemNo + ' does not exist.', 
	FilteredRebateProgram.intRowNumber,
	6
FROM
	@tblFilteredRebateProgram FilteredRebateProgram
WHERE
	FilteredRebateProgram.strRebateBy NOT IN ('Unit', 'Percentage')
UNION
SELECT -- Invalid Rebate UOM
	FilteredRebateProgram.strRebateUOM,
	'Rebate UOM: ' + FilteredRebateProgram.strRebateUOM + ' of rebate item: ' + FilteredRebateProgram.strItemNo + ' does not exist.', 
	FilteredRebateProgram.intRowNumber,
	7
FROM
	@tblFilteredRebateProgram FilteredRebateProgram
LEFT JOIN
	vyuICItemUOM ItemUOM
	ON
		FilteredRebateProgram.strItemNo = ItemUOM.strItemNo
		AND
		FilteredRebateProgram.strRebateUOM = ItemUOM.strUnitMeasure
WHERE
ItemUOM.intItemUOMId IS NULL
AND
FilteredRebateProgram.strRebateUOM IS NOT NULL
UNION
------------------------ Rebate Customers Logs ------------------------
SELECT -- Invalid Rebate Customer
	FilteredRebateProgram.strCustomer,
	'Rebate customer: ' + FilteredRebateProgram.strCustomer + ' does not exist.', 
	FilteredRebateProgram.intRowNumber,
	8
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
		WHEN LogRebateProgram.intLogType = 1
		THEN 'Vendor'
		WHEN LogRebateProgram.intLogType IN (2,3,4,5)
		THEN 'Item No'
		WHEN LogRebateProgram.intLogType = 6
		THEN 'Rebate By'
		WHEN LogRebateProgram.intLogType IN (8,9,10)
		THEN 'Customer'
		ELSE 'Rebate UOM'
	END,
	strValue = LogRebateProgram.strFieldValue,
	strLogLevel =  CASE
		WHEN LogRebateProgram.intLogType IN(2,3,4,8,9)
		THEN 'Warning'
		ELSE 'Error'
	END,
	strStatus = CASE
		WHEN LogRebateProgram.intLogType IN(2,3,4,8,9)
		THEN 'Skipped'
		ELSE 'Failed'
	END,
	intRowNo = LogRebateProgram.intRowNumber,
	strMessage = LogRebateProgram.strMessage
FROM @tblLogRebateProgram LogRebateProgram
WHERE LogRebateProgram.intLogType BETWEEN 1 AND 10

--Rebate Program Transform logic

;MERGE INTO tblVRProgram AS TARGET
USING
(
	SELECT
		guiApiUniqueId = MAX(FilteredRebateProgram.guiApiUniqueId),
		intVendorSetupId = MAX(VendorSetup.intVendorSetupId),
		strVendorProgram = MAX(FilteredRebateProgram.strVendorProgram),
		strProgramDescription = MAX(FilteredRebateProgram.strDescription),
		ysnActive = ISNULL(MAX(CAST(FilteredRebateProgram.ysnActive AS tinyint)), 1)
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
		ysnActive = SOURCE.ysnActive
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
		ysnActive,
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
		guiApiUniqueId = FilteredRebateProgram.guiApiUniqueId,
		intItemId = Item.intItemId,
		intCategoryId = Item.intCategoryId,
		strRebateBy = FilteredRebateProgram.strRebateBy,
		dblRebateRate = FilteredRebateProgram.dblRebateRate,
		dtmBeginDate = FilteredRebateProgram.dtmBeginDate,
		dtmEndDate = FilteredRebateProgram.dtmEndDate,
		intProgramId = Program.intProgramId,
		intUnitMeasureId = UnitMeasure.intUnitMeasureId
	FROM @tblFilteredRebateProgram FilteredRebateProgram
	LEFT JOIN
		@tblLogRebateProgram LogRebateProgram
		ON
			FilteredRebateProgram.intRowNumber = LogRebateProgram.intRowNumber
			AND
			LogRebateProgram.intLogType IN (1,2,3,4,5,6,7)
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
	INNER JOIN 
		tblICItem Item
		ON
			FilteredRebateProgram.strItemNo = Item.strItemNo
	INNER JOIN
		tblICUnitMeasure UnitMeasure
		ON
			FilteredRebateProgram.strRebateUOM = UnitMeasure.strUnitMeasure
	OUTER APPLY
	(
		SELECT TOP 1 intProgramId FROM tblVRProgram WHERE intVendorSetupId = VendorSetup.intVendorSetupId ORDER BY intProgramId DESC	
	) Program
	WHERE 
	LogRebateProgram.intLogType NOT IN (1,2,3,4,5,6,7) OR LogRebateProgram.intLogType IS NULL
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
	intEntityId
)
SELECT
	MAX(FilteredRebateProgram.guiApiUniqueId),
	MAX(Program.intProgramId),
	MAX(Customer.intEntityId)
FROM @tblFilteredRebateProgram FilteredRebateProgram
LEFT JOIN
	@tblLogRebateProgram LogRebateProgram
	ON
		FilteredRebateProgram.intRowNumber = LogRebateProgram.intRowNumber
		AND
		LogRebateProgram.intLogType IN (1,8)
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
INNER JOIN 
	tblEMEntity Customer
	ON
		FilteredRebateProgram.strCustomer = Customer.strName
WHERE 
LogRebateProgram.intLogType NOT IN (1,8) OR LogRebateProgram.intLogType IS NULL
GROUP BY FilteredRebateProgram.strCustomer