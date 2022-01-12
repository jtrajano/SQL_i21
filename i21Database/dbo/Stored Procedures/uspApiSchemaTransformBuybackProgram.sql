CREATE PROCEDURE uspApiSchemaTransformBuybackProgram 
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

--Filter Buyback Program imported

DECLARE @tblFilteredBuybackProgram TABLE(
	intKey INT NOT NULL,
    intRowNumber INT NULL,
	strVendor NVARCHAR(200) COLLATE Latin1_General_CI_AS NOT NULL,
	strProgramName NVARCHAR(200) COLLATE Latin1_General_CI_AS NOT NULL,
	strVendorProgram NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	strDescription NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	strCharge NVARCHAR(200) COLLATE Latin1_General_CI_AS NOT NULL,
	strCustomerLocation NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	strVendorCustomerLocation NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	strItemNo NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	strVendorItemNo NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	strUnitMeasure NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	strVendorUnitMeasure NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	dtmBeginDate DATETIME NOT NULL,
	dtmEndDate DATETIME NULL,
	dblRatePerUnit NUMERIC(38, 20) NOT NULL
)
INSERT INTO @tblFilteredBuybackProgram
(
	intKey,
    intRowNumber,
	strVendor,
	strProgramName,
	strVendorProgram,
	strDescription,
	strCharge,
	strCustomerLocation,
	strVendorCustomerLocation,
	strItemNo,
	strVendorItemNo,
	strUnitMeasure,
	strVendorUnitMeasure,
	dtmBeginDate,
	dtmEndDate,
	dblRatePerUnit
)
SELECT 
	intKey,
    intRowNumber,
	strVendor,
	strProgramName,
	strVendorProgram,
	strDescription,
	strCharge,
	strCustomerLocation,
	strVendorCustomerLocation,
	strItemNo,
	strVendorItemNo,
	strUnitMeasure,
	strVendorUnitMeasure,
	dtmBeginDate,
	dtmEndDate,
	dblRatePerUnit
FROM
tblApiSchemaTransformBuybackProgram
WHERE guiApiUniqueId = @guiApiUniqueId;

-- Error Types
-- Buyback Program Logs
-- 1 - Invalid Vendor
-- Buyback Rate Logs
-- 2 - Duplicate imported buyback program rate
-- 3 - Buyback program rate already exist and overwrite is not enabled
-- 4 - Invalid Customer Location
-- 5 - Invalid Customer Location Xref
-- 6 - Invalid Item
-- 7 - Invalid Item Xref
-- 8 - Invalid Unit of Measure
-- 9 - Invalid Unit of Measure Xref

DECLARE @tblLogBuybackProgram TABLE(
	strFieldValue NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strMessage NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	intRowNumber INT NULL,
	intLogType INT NULL
)

INSERT INTO @tblLogBuybackProgram
(
	strFieldValue,
	strMessage,
	intRowNumber,
	intLogType
)
------------------------- Buyback Program Logs -------------------------
SELECT -- Invalid Vendor
	FilteredBuybackProgram.strVendor,
	'Vendor: ' + FilteredBuybackProgram.strVendor + ' does not exist.',
	FilteredBuybackProgram.intRowNumber,
	1
FROM
	@tblFilteredBuybackProgram FilteredBuybackProgram
LEFT JOIN
(
	tblEMEntity Vendor
	INNER JOIN
	(
		tblAPVendor VendorRecord
		INNER JOIN
			tblVRVendorSetup VendorSetup
			ON
				VendorRecord.intEntityId = VendorSetup.intEntityId
	)
		ON
			Vendor.intEntityId = VendorRecord.intEntityId
			AND
			VendorRecord.ysnPymtCtrlActive = 1

)
	ON
		Vendor.strName = FilteredBuybackProgram.strVendor
WHERE
Vendor.intEntityId IS NULL
UNION
-------------------------- Buyback Rate Logs --------------------------
SELECT -- Duplicate imported buyback program rate
	DuplicateBuybackProgram.strVendor,
	'Duplicate imported buyback referenced customer location and UOM of item: ' + DuplicateBuybackProgram.strItemNo + ' on vendor: ' + DuplicateBuybackProgram.strVendor + ' and charges: ' + DuplicateBuybackProgram.strCharge + '.',
	DuplicateBuybackProgram.intRowNumber,
	2
FROM
(
	SELECT 
		strItemNo = ISNULL(MIN(FilteredItem.strItemNo), MIN(FilteredBuybackProgram.strItemNo)),
		strVendorItemNo = MIN(FilteredBuybackProgram.strVendorItemNo),
		strVendor = MIN(FilteredBuybackProgram.strVendor),
		strCharge = MIN(FilteredBuybackProgram.strCharge),
		FilteredBuybackProgram.intRowNumber,
		RowNumber = ROW_NUMBER() OVER(PARTITION BY 
						MIN(FilteredBuybackProgram.strVendor), 
						MIN(FilteredBuybackProgram.strCharge),
						ISNULL(MIN(FilteredLocation.strLocationName), MIN(FilteredBuybackProgram.strCustomerLocation)),
						ISNULL(MIN(FilteredItem.strItemNo), MIN(FilteredBuybackProgram.strItemNo)),
						ISNULL(MIN(FilteredUnitMeasure.strUnitMeasure), MIN(FilteredBuybackProgram.strUnitMeasure)) ORDER BY FilteredBuybackProgram.intRowNumber)
		
	FROM 
		@tblFilteredBuybackProgram FilteredBuybackProgram
	LEFT JOIN
	(
		tblEMEntity Vendor
		INNER JOIN
		(
			tblAPVendor VendorRecord
			INNER JOIN
				tblVRVendorSetup VendorSetup
				ON
					VendorRecord.intEntityId = VendorSetup.intEntityId
		)
			ON
				Vendor.intEntityId = VendorRecord.intEntityId
				AND
				VendorRecord.ysnPymtCtrlActive = 1

	)
		ON
			Vendor.strName = FilteredBuybackProgram.strVendor
	LEFT JOIN
		tblBBCustomerLocationXref FilteredLocationXref
		ON
			FilteredLocationXref.intVendorSetupId = VendorSetup.intVendorSetupId
			AND
			FilteredLocationXref.strVendorCustomerLocation = FilteredBuybackProgram.strVendorCustomerLocation
	LEFT JOIN
		tblEMEntityLocation FilteredLocation
		ON
			FilteredLocationXref.intEntityLocationId = FilteredLocation.intEntityLocationId
	LEFT JOIN 
		tblICItemVendorXref FilteredItemXref
		ON
			FilteredItemXref.intVendorSetupId = VendorSetup.intVendorSetupId
			AND
			FilteredItemXref.strVendorProduct = FilteredBuybackProgram.strVendorItemNo
	LEFT JOIN
		tblICItem FilteredItem
		ON
			FilteredItemXref.intItemId = FilteredItem.intItemId
	LEFT JOIN
		tblVRUOMXref FilteredUnitMeasureXref
		ON
			FilteredUnitMeasureXref.intVendorSetupId = VendorSetup.intVendorSetupId
			AND
			FilteredUnitMeasureXref.strVendorUOM = FilteredBuybackProgram.strVendorUnitMeasure
	LEFT JOIN
		tblICUnitMeasure FilteredUnitMeasure
		ON
			FilteredUnitMeasureXref.intUnitMeasureId = FilteredUnitMeasure.intUnitMeasureId
	INNER JOIN
	(
		@tblFilteredBuybackProgram ComparedBuybackProgram
		LEFT JOIN
		(
			tblEMEntity ComparedVendor
			INNER JOIN
			(
				tblAPVendor ComparedVendorRecord
				INNER JOIN
					tblVRVendorSetup ComparedVendorSetup
					ON
						ComparedVendorRecord.intEntityId = ComparedVendorSetup.intEntityId
			)
				ON
					ComparedVendor.intEntityId = ComparedVendorRecord.intEntityId
					AND
					ComparedVendorRecord.ysnPymtCtrlActive = 1

		)
			ON
				ComparedVendor.strName = ComparedBuybackProgram.strVendor
		LEFT JOIN
			tblBBCustomerLocationXref ComparedLocationXref
			ON
				ComparedLocationXref.intVendorSetupId = ComparedVendorSetup.intVendorSetupId
				AND
				ComparedLocationXref.strVendorCustomerLocation = ComparedBuybackProgram.strVendorCustomerLocation
		LEFT JOIN
			tblEMEntityLocation ComparedLocation
			ON
				ComparedLocationXref.intEntityLocationId = ComparedLocation.intEntityLocationId
		LEFT JOIN 
			tblICItemVendorXref ComparedItemXref
			ON
				ComparedItemXref.intVendorSetupId = ComparedVendorSetup.intVendorSetupId
				AND
				ComparedItemXref.strVendorProduct = ComparedBuybackProgram.strVendorItemNo
		LEFT JOIN
			tblICItem ComparedItem
			ON
				ComparedItemXref.intItemId = ComparedItem.intItemId	
		LEFT JOIN
			tblVRUOMXref ComparedUnitMeasureXref
			ON
				ComparedUnitMeasureXref.intVendorSetupId = ComparedVendorSetup.intVendorSetupId
				AND
				ComparedUnitMeasureXref.strVendorUOM = ComparedBuybackProgram.strVendorUnitMeasure
		LEFT JOIN
			tblICUnitMeasure ComparedUnitMeasure
			ON
				ComparedUnitMeasureXref.intUnitMeasureId = ComparedUnitMeasure.intUnitMeasureId		
	)
		ON
			FilteredBuybackProgram.strVendor = ComparedBuybackProgram.strVendor
			AND
			ISNULL(FilteredLocation.strLocationName, FilteredBuybackProgram.strCustomerLocation) = ISNULL(ComparedLocation.strLocationName, ComparedBuybackProgram.strCustomerLocation)
			AND
			ISNULL(FilteredItem.strItemNo, FilteredBuybackProgram.strItemNo) = ISNULL(ComparedItem.strItemNo, ComparedBuybackProgram.strItemNo)
			AND
			ISNULL(FilteredUnitMeasure.strUnitMeasure, FilteredBuybackProgram.strUnitMeasure) = ISNULL(ComparedUnitMeasure.strUnitMeasure, ComparedBuybackProgram.strUnitMeasure)
			AND
			FilteredBuybackProgram.intRowNumber <> ComparedBuybackProgram.intRowNumber
	GROUP BY FilteredBuybackProgram.intRowNumber
) AS DuplicateBuybackProgram
WHERE DuplicateBuybackProgram.RowNumber > 1
UNION
SELECT -- Buyback program rate already exist and overwrite is not enabled
	FilteredBuybackProgram.strVendor,
	'Imported buyback referenced customer location and UOM of item: ' + ISNULL(VendorItem.strItemNo, FilteredBuybackProgram.strItemNo) + ' on vendor: ' + FilteredBuybackProgram.strVendor + ' and charges: ' + FilteredBuybackProgram.strCharge + '.',
	FilteredBuybackProgram.intRowNumber,
	3
FROM
	@tblFilteredBuybackProgram FilteredBuybackProgram
INNER JOIN
(
	tblEMEntity Vendor
	INNER JOIN
	(
		tblAPVendor VendorRecord
		INNER JOIN
			tblVRVendorSetup VendorSetup
			ON
				VendorRecord.intEntityId = VendorSetup.intEntityId
	)
		ON
			Vendor.intEntityId = VendorRecord.intEntityId
			AND
			VendorRecord.ysnPymtCtrlActive = 1

)
	ON
		Vendor.strName = FilteredBuybackProgram.strVendor
LEFT JOIN 
	tblBBCustomerLocationXref CustomerLocationXref
	ON
		FilteredBuybackProgram.strVendorCustomerLocation IS NOT NULL
		AND
		CustomerLocationXref.strVendorCustomerLocation = FilteredBuybackProgram.strVendorCustomerLocation
LEFT JOIN
	tblEMEntityLocation VendorCustomerLocation
	ON
		VendorCustomerLocation.intEntityLocationId = CustomerLocationXref.intEntityLocationId
LEFT JOIN
	tblEMEntityLocation CustomerLocation
	ON
		CustomerLocation.strLocationName = FilteredBuybackProgram.strCustomerLocation
LEFT JOIN
	tblICItemVendorXref ItemXref
	ON
		FilteredBuybackProgram.strVendorItemNo IS NOT NULL
		AND
		ItemXref.strVendorProduct = FilteredBuybackProgram.strVendorItemNo
LEFT JOIN 
	tblICItem VendorItem
	ON
		VendorItem.intItemId = ItemXref.intItemId
LEFT JOIN
	tblICItem Item
	ON
		Item.strItemNo = FilteredBuybackProgram.strItemNo
LEFT JOIN
	tblVRUOMXref UOMXref
	ON
		FilteredBuybackProgram.strVendorUnitMeasure IS NOT NULL
		AND
		UOMXref.strVendorUOM = FilteredBuybackProgram.strVendorUnitMeasure
LEFT JOIN
	tblICUnitMeasure VendorUOM
	ON
		VendorUOM.intUnitMeasureId = UOMXref.intUnitMeasureId
LEFT JOIN
	tblICUnitMeasure UOM
	ON
		UOM.strUnitMeasure = FilteredBuybackProgram.strUnitMeasure
CROSS APPLY
(
	SELECT TOP 1 * FROM tblBBProgram WHERE intVendorSetupId = VendorSetup.intVendorSetupId ORDER BY intProgramId DESC
) Program
CROSS APPLY
(
	SELECT TOP 1 * FROM tblBBProgramCharge WHERE intProgramId = Program.intProgramId AND strCharge = FilteredBuybackProgram.strCharge ORDER BY intProgramChargeId DESC
) Charge
INNER JOIN
	tblBBRate Rate
	ON
		Rate.intProgramChargeId = Charge.intProgramChargeId
		AND
		Rate.intItemId = ISNULL(VendorItem.intItemId, Item.intItemId)
		AND
		Rate.intCustomerLocationId = ISNULL(VendorCustomerLocation.intEntityLocationId, CustomerLocation.intEntityLocationId)
		AND
		Rate.intUnitMeasureId = ISNULL(VendorUOM.intUnitMeasureId, UOM.intUnitMeasureId)
WHERE
@ysnAllowOverwrite = 0
UNION
SELECT -- Invalid Customer Location
	FilteredBuybackProgram.strCustomerLocation,
	'Customer location: ' + FilteredBuybackProgram.strCustomerLocation + ' does not exist.',
	FilteredBuybackProgram.intRowNumber,
	4
FROM
	@tblFilteredBuybackProgram FilteredBuybackProgram
LEFT JOIN
	vyuARCustomer Customer
	ON
		Customer.strName = FilteredBuybackProgram.strVendor
LEFT JOIN
	tblEMEntityLocation EntityLocation 
	ON
		Customer.intEntityId = EntityLocation.intEntityId
		AND
		FilteredBuybackProgram.strCustomerLocation = EntityLocation.strLocationName
WHERE
EntityLocation.intEntityLocationId IS NULL
AND
FilteredBuybackProgram.strCustomerLocation IS NOT NULL
UNION
SELECT -- Invalid Customer Location Xref
	FilteredBuybackProgram.strVendorCustomerLocation,
	'Buyback customer location: ' + FilteredBuybackProgram.strVendorCustomerLocation + ' cross reference does not exist.',
	FilteredBuybackProgram.intRowNumber,
	5
FROM
	@tblFilteredBuybackProgram FilteredBuybackProgram
LEFT JOIN
(
	tblEMEntity Vendor
	INNER JOIN
	(
		tblAPVendor VendorRecord
		INNER JOIN
			tblVRVendorSetup VendorSetup
			ON
				VendorRecord.intEntityId = VendorSetup.intEntityId
	)
		ON
			Vendor.intEntityId = VendorRecord.intEntityId
			AND
			VendorRecord.ysnPymtCtrlActive = 1

)
	ON
		Vendor.strName = FilteredBuybackProgram.strVendor
LEFT JOIN 
	tblBBCustomerLocationXref CustomerLocationXref
	ON
		VendorSetup.intVendorSetupId = CustomerLocationXref.intVendorSetupId
		AND
		FilteredBuybackProgram.strVendorCustomerLocation = CustomerLocationXref.strVendorCustomerLocation
WHERE
CustomerLocationXref.intCustomerLocationXrefId IS NULL
AND
FilteredBuybackProgram.strVendorItemNo IS NOT NULL
UNION
SELECT -- Invalid Item
	FilteredBuybackProgram.strItemNo,
	'Buyback rate item: ' + FilteredBuybackProgram.strItemNo + ' does not exist.', 
	FilteredBuybackProgram.intRowNumber,
	6
FROM
	@tblFilteredBuybackProgram FilteredBuybackProgram
LEFT JOIN
	tblICItem Item
	ON
		FilteredBuybackProgram.strItemNo = Item.strItemNo
WHERE
Item.intItemId IS NULL
AND
FilteredBuybackProgram.strItemNo IS NOT NULL
UNION
SELECT -- Invalid Item No Xref
	FilteredBuybackProgram.strVendorItemNo,
	'Buyback vendor item no: ' + FilteredBuybackProgram.strVendorItemNo + ' cross reference does not exist.', 
	FilteredBuybackProgram.intRowNumber,
	7
FROM
	@tblFilteredBuybackProgram FilteredBuybackProgram
LEFT JOIN
(
	tblEMEntity Vendor
	INNER JOIN
	(
		tblAPVendor VendorRecord
		INNER JOIN
			tblVRVendorSetup VendorSetup
			ON
				VendorRecord.intEntityId = VendorSetup.intEntityId
	)
		ON
			Vendor.intEntityId = VendorRecord.intEntityId
			AND
			VendorRecord.ysnPymtCtrlActive = 1

)
	ON
		Vendor.strName = FilteredBuybackProgram.strVendor
LEFT JOIN 
	tblICItemVendorXref ItemXref
	ON
		VendorSetup.intVendorSetupId = ItemXref.intVendorSetupId
		AND
		FilteredBuybackProgram.strVendorItemNo = ItemXref.strVendorProduct
WHERE
ItemXref.intItemVendorXrefId IS NULL
AND
FilteredBuybackProgram.strVendorItemNo IS NOT NULL
UNION
SELECT -- Invalid Unit of Measure
	FilteredBuybackProgram.strUnitMeasure,
	'Buyback rate unit of measure: ' + FilteredBuybackProgram.strUnitMeasure + ' does not exist.', 
	FilteredBuybackProgram.intRowNumber,
	8
FROM
	@tblFilteredBuybackProgram FilteredBuybackProgram
LEFT JOIN
	tblICUnitMeasure UnitMeasure
	ON
		FilteredBuybackProgram.strUnitMeasure = UnitMeasure.strUnitMeasure
WHERE
UnitMeasure.intUnitMeasureId IS NULL
AND
FilteredBuybackProgram.strUnitMeasure IS NOT NULL
UNION
SELECT -- Invalid Unit of Measure Xref
	FilteredBuybackProgram.strVendorUnitMeasure,
	'Buyback vendor unit of measure: ' + FilteredBuybackProgram.strVendorUnitMeasure + ' cross reference does not exist.', 
	FilteredBuybackProgram.intRowNumber,
	9
FROM
	@tblFilteredBuybackProgram FilteredBuybackProgram
LEFT JOIN
(
	tblEMEntity Vendor
	INNER JOIN
	(
		tblAPVendor VendorRecord
		INNER JOIN
			tblVRVendorSetup VendorSetup
			ON
				VendorRecord.intEntityId = VendorSetup.intEntityId
	)
		ON
			Vendor.intEntityId = VendorRecord.intEntityId
			AND
			VendorRecord.ysnPymtCtrlActive = 1

)
	ON
		Vendor.strName = FilteredBuybackProgram.strVendor
LEFT JOIN 
	tblVRUOMXref UOMXref
	ON
		VendorSetup.intVendorSetupId = UOMXref.intVendorSetupId
		AND
		FilteredBuybackProgram.strVendorUnitMeasure = UOMXref.strVendorUOM
WHERE
UOMXref.intUOMXrefId IS NULL
AND
FilteredBuybackProgram.strVendorUnitMeasure IS NOT NULL

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
		WHEN LogBuybackProgram.intLogType IN (1,2,3)
		THEN 'Vendor'
		WHEN LogBuybackProgram.intLogType = 4
		THEN 'Customer Location'
		WHEN LogBuybackProgram.intLogType = 5
		THEN 'Vendor Customer Location'
		WHEN LogBuybackProgram.intLogType = 6
		THEN 'Item Name'
		WHEN LogBuybackProgram.intLogType = 7
		THEN 'Vendor''s Item'
		WHEN LogBuybackProgram.intLogType = 8
		THEN 'Unit of Measure'
		ELSE 'Vendor''s UOM'
	END,
	strValue = LogBuybackProgram.strFieldValue,
	strLogLevel =  CASE
		WHEN LogBuybackProgram.intLogType IN(2,3)
		THEN 'Warning'
		ELSE 'Error'
	END,
	strStatus = CASE
		WHEN LogBuybackProgram.intLogType IN(2,3)
		THEN 'Skipped'
		ELSE 'Failed'
	END,
	intRowNo = LogBuybackProgram.intRowNumber,
	strMessage = LogBuybackProgram.strMessage
FROM @tblLogBuybackProgram LogBuybackProgram
WHERE LogBuybackProgram.intLogType BETWEEN 1 AND 9

--Buyback Program Transform logic

;MERGE INTO tblBBProgram AS TARGET
USING
(
	SELECT
		guiApiUniqueId = @guiApiUniqueId,
		intVendorSetupId = MAX(VendorSetup.intVendorSetupId),
		strVendorProgramId = MAX(FilteredBuybackProgram.strVendorProgram),
		strProgramName = MAX(FilteredBuybackProgram.strProgramName),
		strProgramDescription = MAX(FilteredBuybackProgram.strDescription)
	FROM @tblFilteredBuybackProgram FilteredBuybackProgram
	LEFT JOIN
		@tblLogBuybackProgram LogBuybackProgram
		ON
			FilteredBuybackProgram.intRowNumber = LogBuybackProgram.intRowNumber
			AND
			LogBuybackProgram.intLogType = 1
	INNER JOIN
	(
		tblEMEntity Vendor
		INNER JOIN
		(
			tblAPVendor VendorRecord
			INNER JOIN
				tblVRVendorSetup VendorSetup
				ON
					VendorRecord.intEntityId = VendorSetup.intEntityId
		)
			ON
				Vendor.intEntityId = VendorRecord.intEntityId
				AND
				VendorRecord.ysnPymtCtrlActive = 1

	)
		ON
			Vendor.strName = FilteredBuybackProgram.strVendor
	WHERE
	LogBuybackProgram.intLogType <> 1 OR LogBuybackProgram.intLogType IS NULL
	GROUP BY
	FilteredBuybackProgram.strVendor
) AS SOURCE
ON TARGET.intVendorSetupId = SOURCE.intVendorSetupId
WHEN MATCHED AND @ysnAllowOverwrite = 1
THEN
	UPDATE SET
		guiApiUniqueId = SOURCE.guiApiUniqueId,
		intVendorSetupId = SOURCE.intVendorSetupId,
		strVendorProgramId = SOURCE.strVendorProgramId,
		strProgramName = SOURCE.strProgramName,
		strProgramDescription = SOURCE.strProgramDescription
WHEN NOT MATCHED THEN
	INSERT
	(
		guiApiUniqueId,
		intVendorSetupId,
		strVendorProgramId,
		strProgramName,
		strProgramDescription,
		intConcurrencyId
	)
	VALUES
	(
		guiApiUniqueId,
		intVendorSetupId,
		strVendorProgramId,
		strProgramName,
		strProgramDescription,
		1
	);

--Add Transaction No to inserted Buyback Program

DECLARE @intProgramId INT

DECLARE program_cursor CURSOR FOR 
SELECT
	intProgramId
FROM 
	tblBBProgram 
WHERE
	strProgramId IS NULL
	
OPEN program_cursor  
FETCH NEXT FROM program_cursor INTO 
	@intProgramId

WHILE @@FETCH_STATUS = 0  
BEGIN  

	DECLARE @strProgramId NVARCHAR(MAX)

	EXEC dbo.uspSMGetStartingNumber 129, @strProgramId OUTPUT, NULL

	UPDATE 
		tblBBProgram 
	SET 
		strProgramId = @strProgramId
	WHERE 
		intProgramId = @intProgramId
	
	FETCH NEXT FROM program_cursor INTO 
		@intProgramId
END 

CLOSE program_cursor  
DEALLOCATE program_cursor

--Buyback Program Charge Transform Logic

INSERT INTO tblBBProgramCharge
(
	guiApiUniqueId,
	intProgramId,
	strCharge,
	intConcurrencyId
)
SELECT
	@guiApiUniqueId,
	Program.intProgramId,
	FilteredBuybackProgram.strCharge,
	1
FROM @tblFilteredBuybackProgram FilteredBuybackProgram
LEFT JOIN
	@tblLogBuybackProgram LogBuybackProgram
	ON
		FilteredBuybackProgram.intRowNumber = LogBuybackProgram.intRowNumber
		AND
		LogBuybackProgram.intLogType = 1
INNER JOIN
(
	tblEMEntity Vendor
	INNER JOIN
	(
		tblAPVendor VendorRecord
		INNER JOIN
			tblVRVendorSetup VendorSetup
			ON
				VendorRecord.intEntityId = VendorSetup.intEntityId
	)
		ON
			Vendor.intEntityId = VendorRecord.intEntityId
			AND
			VendorRecord.ysnPymtCtrlActive = 1

)
	ON
		Vendor.strName = FilteredBuybackProgram.strVendor
OUTER APPLY
(
	SELECT TOP 1 intProgramId FROM tblBBProgram WHERE intVendorSetupId = VendorSetup.intVendorSetupId ORDER BY intProgramId DESC	
) Program
LEFT JOIN 
	tblBBProgramCharge Charge
	ON
		FilteredBuybackProgram.strCharge = Charge.strCharge
		AND
		Program.intProgramId = Charge.intProgramId
WHERE 
	(
		LogBuybackProgram.intLogType <> 1 
		OR 
		LogBuybackProgram.intLogType IS NULL
	)
	AND
	Charge.intProgramChargeId IS NULL
GROUP BY
Program.intProgramId, FilteredBuybackProgram.strCharge

--Buyback Program Rate Transform logic

;MERGE INTO tblBBRate AS TARGET
USING
(
	SELECT
		guiApiUniqueId = @guiApiUniqueId,
		intItemId = ISNULL(ItemXref.intItemId, Item.intItemId),
		intProgramChargeId = Charge.intProgramChargeId,
		intCustomerLocationId = ISNULL(CustomerLocationXref.intEntityLocationId, CustomerLocation.intEntityLocationId),
		intUnitMeasureId = ISNULL(UOMXref.intUnitMeasureId, UnitMeasure.intUnitMeasureId),
		dtmBeginDate = FilteredBuybackProgram.dtmBeginDate,
		dtmEndDate = FilteredBuybackProgram.dtmEndDate,
		dblRatePerUnit = FilteredBuybackProgram.dblRatePerUnit
	FROM @tblFilteredBuybackProgram FilteredBuybackProgram
	LEFT JOIN
		@tblLogBuybackProgram LogBuybackProgram
		ON
			FilteredBuybackProgram.intRowNumber = LogBuybackProgram.intRowNumber
			AND
			LogBuybackProgram.intLogType IN (1,2,3,4,5,6,7,8,9)
	INNER JOIN
	(
		tblEMEntity Vendor
		INNER JOIN
		(
			tblAPVendor VendorRecord
			INNER JOIN
				tblVRVendorSetup VendorSetup
				ON
					VendorRecord.intEntityId = VendorSetup.intEntityId
		)
			ON
				Vendor.intEntityId = VendorRecord.intEntityId
				AND
				VendorRecord.ysnPymtCtrlActive = 1

	)
		ON
			Vendor.strName = FilteredBuybackProgram.strVendor
	CROSS APPLY
	(
		SELECT TOP 1 intProgramId FROM tblBBProgram WHERE intVendorSetupId = VendorSetup.intVendorSetupId ORDER BY intProgramId DESC	
	) Program
	CROSS APPLY
	(
		SELECT TOP 1 intProgramChargeId FROM tblBBProgramCharge WHERE intProgramId = Program.intProgramId AND strCharge = FilteredBuybackProgram.strCharge
	) Charge
	LEFT JOIN
		tblEMEntityLocation CustomerLocation
		ON
			FilteredBuybackProgram.strCustomerLocation = CustomerLocation.strLocationName
	LEFT JOIN 
		tblICItem Item
		ON
			FilteredBuybackProgram.strItemNo = Item.strItemNo
	LEFT JOIN
		tblICUnitMeasure UnitMeasure
		ON
			FilteredBuybackProgram.strUnitMeasure = UnitMeasure.strUnitMeasure
	LEFT JOIN
		tblBBCustomerLocationXref CustomerLocationXref
		ON
			FilteredBuybackProgram.strVendorCustomerLocation IS NOT NULL
			AND
			FilteredBuybackProgram.strVendorCustomerLocation = CustomerLocationXref.strVendorCustomerLocation
	LEFT JOIN
		tblICItemVendorXref ItemXref
		ON
			FilteredBuybackProgram.strVendorItemNo IS NOT NULL
			AND
			FilteredBuybackProgram.strVendorItemNo = ItemXref.strVendorProduct
	LEFT JOIN
		tblVRUOMXref UOMXref
		ON
			FilteredBuybackProgram.strVendorUnitMeasure IS NOT NULL
			AND
			FilteredBuybackProgram.strVendorUnitMeasure = UOMXref.strVendorUOM
	WHERE 
	LogBuybackProgram.intLogType NOT IN (1,2,3,4,5,6,7,8,9) OR LogBuybackProgram.intLogType IS NULL
) AS SOURCE
ON 
TARGET.intProgramChargeId = SOURCE.intProgramChargeId
AND
TARGET.intCustomerLocationId = SOURCE.intCustomerLocationId
AND
TARGET.intItemId = SOURCE.intItemId
AND
TARGET.intUnitMeasureId = SOURCE.intUnitMeasureId
WHEN MATCHED AND @ysnAllowOverwrite = 1 
THEN
	UPDATE SET
		guiApiUniqueId = SOURCE.guiApiUniqueId,
		intItemId = SOURCE.intItemId,
		intProgramChargeId = SOURCE.intProgramChargeId,
		intCustomerLocationId = SOURCE.intCustomerLocationId,
		intUnitMeasureId = SOURCE.intUnitMeasureId,
		dtmBeginDate = ISNULL(SOURCE.dtmBeginDate, TARGET.dtmBeginDate),
		dtmEndDate = ISNULL(SOURCE.dtmEndDate, TARGET.dtmEndDate),
		dblRatePerUnit = ISNULL(SOURCE.dblRatePerUnit, TARGET.dblRatePerUnit)
WHEN NOT MATCHED THEN
	INSERT
	(
		guiApiUniqueId,
		intItemId,
		intProgramChargeId,
		intCustomerLocationId,
		intUnitMeasureId,
		dtmBeginDate,
		dtmEndDate,
		dblRatePerUnit,
		intConcurrencyId
	)
	VALUES
	(
		guiApiUniqueId,
		intItemId,
		intProgramChargeId,
		intCustomerLocationId,
		intUnitMeasureId,
		dtmBeginDate,
		dtmEndDate,
		dblRatePerUnit,
		1
	);