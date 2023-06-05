CREATE PROCEDURE [dbo].[uspApiSchemaTransformVendorXref]
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

--Filter Vendor Xref imported
DECLARE @tblFilteredVendorXref TABLE(
    guiApiUniqueId UNIQUEIDENTIFIER NOT NULL,
    intRowNumber INT NULL,
	intKey INT NOT NULL,
	strItemNo NVARCHAR (50)  COLLATE Latin1_General_CI_AS NOT NULL,
    strLocationName NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
    strVendorName NVARCHAR (100)  COLLATE Latin1_General_CI_AS NOT NULL,
    strVendorProduct NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    strProductDescription NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL, 
    dblConversionFactor NUMERIC(38, 20) NOT NULL DEFAULT ((0)),
    strUnitMeasure NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
)
INSERT INTO @tblFilteredVendorXref
(
    guiApiUniqueId,
    intRowNumber,
	intKey,
	strItemNo,
	strLocationName,
	strVendorName,
    strVendorProduct,
    strProductDescription,
    dblConversionFactor,
    strUnitMeasure
)
SELECT 
	guiApiUniqueId,
    intRowNumber,
	intKey,
	strItemNo,
	strLocationName,
	strVendorName,
    strVendorProduct,
    strProductDescription,
    dblConversionFactor,
    strUnitMeasure
FROM
tblApiSchemaVendorXref
WHERE guiApiUniqueId = @guiApiUniqueId;

--Create Error Table
DECLARE @tblErrorVendorXref TABLE(
	strItemNo NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strFieldValue NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	intRowNumber INT NULL,
	intErrorType INT
)

-- Error Types
-- 1 - Duplicate Imported Vendor Xref
-- 2 - Existing Vendor Xref
-- 3 - Invalid Item

--Validate Records
INSERT INTO @tblErrorVendorXref
(
	strItemNo,
	strFieldValue,
	intRowNumber, 
	intErrorType
)
SELECT -- Duplicate Imported Vendor Xref
	strItemNo = DuplicateImportVendorXref.strItemNo,
	strFieldValue = DuplicateImportVendorXref.strVendorProduct,
	intRowNumber = DuplicateImportVendorXref.intRowNumber,
	intErrorType = 1
FROM
(
	SELECT 
		strItemNo,
		strVendorProduct,
		intRowNumber,
		RowNumber = ROW_NUMBER() OVER(PARTITION BY strItemNo, strVendorProduct ORDER BY strItemNo)
	FROM 
		@tblFilteredVendorXref
) AS DuplicateImportVendorXref
WHERE RowNumber > 1
UNION
SELECT -- Existing Vendor Xref
	strItemNo = FilteredVendorXref.strItemNo,
	strFieldValue = FilteredVendorXref.strVendorProduct,
	intRowNumber = FilteredVendorXref.intRowNumber,
	intErrorType = 2
FROM
@tblFilteredVendorXref FilteredVendorXref 
INNER JOIN
tblICItem Item
ON
FilteredVendorXref.strItemNo = Item.strItemNo
INNER JOIN
vyuICSearchItemVendorXref VendorXrefDetail
ON
FilteredVendorXref.strVendorProduct = VendorXrefDetail.strVendorProduct
AND
FilteredVendorXref.strVendorName = VendorXrefDetail.strName
INNER JOIN
tblICItemVendorXref ItemVendorXref
ON
Item.intItemId = ItemVendorXref.intItemId
AND
VendorXrefDetail.intItemVendorXrefId = ItemVendorXref.intItemVendorXrefId
WHERE
@ysnAllowOverwrite = 0
UNION
SELECT -- Invalid Item
	strItemNo = FilteredVendorXref.strItemNo,
	strFieldValue = FilteredVendorXref.strItemNo,
	intRowNumber = FilteredVendorXref.intRowNumber,
	intErrorType = 3
FROM
@tblFilteredVendorXref FilteredVendorXref
LEFT JOIN
tblICItem Item
ON
FilteredVendorXref.strItemNo = Item.strItemNo
WHERE
Item.intItemId IS NULL

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
		WHEN ErrorVendorXref.intErrorType IN(1,2)
		THEN 'Vendor Product'
		ELSE 'Item No'
	END,
	strValue = ErrorVendorXref.strFieldValue,
	strLogLevel =  CASE
		WHEN ErrorVendorXref.intErrorType IN(1,2)
		THEN 'Warning'
		ELSE 'Error'
	END,
	strStatus = CASE
		WHEN ErrorVendorXref.intErrorType IN(1,2)
		THEN 'Skipped'
		ELSE 'Failed'
	END,
	intRowNo = ErrorVendorXref.intRowNumber,
	strMessage = CASE
		WHEN ErrorVendorXref.intErrorType = 1
		THEN 'Duplicate imported Vendor Xref: ' + ErrorVendorXref.strFieldValue + ' on item: ' + ErrorVendorXref.strItemNo + '.'
		WHEN ErrorVendorXref.intErrorType = 2
		THEN 'Vendor Xref: ' + ErrorVendorXref.strFieldValue + ' on item: ' + ErrorVendorXref.strItemNo + ' already exists and overwrite is not enabled.'
		ELSE 'Item: ' + ErrorVendorXref.strFieldValue + ' does not exist.'
	END
FROM @tblErrorVendorXref ErrorVendorXref
WHERE ErrorVendorXref.intErrorType IN(1, 2, 3)

--Filter Vendor Xref to be removed
DELETE 
FilteredVendorXref
FROM 
	@tblFilteredVendorXref FilteredVendorXref
	INNER JOIN @tblErrorVendorXref ErrorVendorXref
		ON FilteredVendorXref.intRowNumber = ErrorVendorXref.intRowNumber
WHERE ErrorVendorXref.intErrorType IN(1, 2, 3)

--Transform and Insert statement
;MERGE INTO tblICItemVendorXref AS TARGET
USING
(
	SELECT
		guiApiUniqueId = FilteredVendorXref.guiApiUniqueId,
		intItemId = Item.intItemId,
		intItemLocationId = ItemLocation.intItemLocationId,
		intVendorId = VendorName.intEntityId,
		strVendorProduct = FilteredVendorXref.strVendorProduct,
		strProductDescription = FilteredVendorXref.strProductDescription,
		dblConversionFactor = FilteredVendorXref.dblConversionFactor,
		intItemUnitMeasureId = CASE
                                WHEN FilteredVendorXref.strUnitMeasure IS NULL OR FilteredVendorXref.strUnitMeasure = ''
                                THEN NULL
                                ELSE UnitOfMeasure.intItemUnitMeasureId
                            END
	FROM @tblFilteredVendorXref FilteredVendorXref
	INNER JOIN
	tblICItem Item
		ON
		FilteredVendorXref.strItemNo = Item.strItemNo
	INNER JOIN
	vyuICGetItemLocation ItemLocation
		ON
		FilteredVendorXref.strItemNo = ItemLocation.strItemNo
		AND
		Item.intItemId = ItemLocation.intItemId
	INNER JOIN
	vyuAPVendor VendorName
		ON
		FilteredVendorXref.strVendorName = VendorName.strName
	INNER JOIN
	vyuICGetItemPricing UnitOfMeasure
		ON
		FilteredVendorXref.strItemNo = UnitOfMeasure.strItemNo
) AS SOURCE
ON 
TARGET.intItemId = SOURCE.intItemId
AND
TARGET.strVendorProduct = SOURCE.strVendorProduct
WHEN MATCHED AND @ysnAllowOverwrite = 1 
THEN
	UPDATE SET
		guiApiUniqueId = SOURCE.guiApiUniqueId,
		intItemId = SOURCE.intItemId,
		intItemLocationId = SOURCE.intItemLocationId,
		intVendorId = SOURCE.intVendorId,
		strVendorProduct = SOURCE.strVendorProduct,
		strProductDescription = SOURCE.strProductDescription,
		dblConversionFactor = SOURCE.dblConversionFactor,
		intItemUnitMeasureId = SOURCE.intItemUnitMeasureId,
		dtmDateModified = GETUTCDATE()
WHEN NOT MATCHED THEN
	INSERT
	(
		guiApiUniqueId,
		intItemId,
		intItemLocationId,
		intVendorId,
		strVendorProduct,
		strProductDescription,
		dblConversionFactor,
		intItemUnitMeasureId,
		dtmDateCreated
	)
	VALUES
	(
		guiApiUniqueId,
		intItemId,
		intItemLocationId,
		intVendorId,
		strVendorProduct,
		strProductDescription,
		dblConversionFactor,
		intItemUnitMeasureId,
		GETUTCDATE()
	);