CREATE PROCEDURE uspApiSchemaTransformEffectiveItemPrice 
	@guiApiUniqueId UNIQUEIDENTIFIER,
	@guiLogId UNIQUEIDENTIFIER
AS

--Check import settings

DECLARE @ysnAllowOverwrite BIT = 0

SELECT @ysnAllowOverwrite = ISNULL(CAST(Overwrite AS BIT), 0)	
FROM (
	SELECT strPropertyName, varPropertyValue
	FROM tblApiSchemaTransformProperty
	WHERE guiApiUniqueId = @guiApiUniqueId
) AS Properties
PIVOT (
	MIN(varPropertyValue)
	FOR strPropertyName IN
	(
		Overwrite
	)
) AS PivotProperties

--Filter Effective Item Price imported

DECLARE @tblFilteredEffectiveItemPrice TABLE(
	intKey INT NOT NULL,
    guiApiUniqueId UNIQUEIDENTIFIER NOT NULL,
    intRowNumber INT NULL,
	strItemNo NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	strLocation NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	dblRetailPrice NUMERIC(38, 20) NULL,
	dtmEffectiveDate DATETIME NULL
)
INSERT INTO @tblFilteredEffectiveItemPrice
(
	intKey,
    guiApiUniqueId,
    intRowNumber,
	strItemNo,
	strLocation,
	dblRetailPrice,
	dtmEffectiveDate
)
SELECT 
	intKey,
    guiApiUniqueId,
    intRowNumber,
	strItemNo,
	strLocation,
	dblRetailPrice,
	dtmEffectiveDate
FROM
tblApiSchemaTransformEffectiveItemPrice
WHERE guiApiUniqueId = @guiApiUniqueId;

--Create Error Table

DECLARE @tblErrorEffectiveItemPrice TABLE(
	strItemNo NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strFieldValue NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	intRowNumber INT NULL,
	intErrorType INT
)

-- Error Types
-- 1 - Duplicate Imported Effective Item Price
-- 2 - Existing Effective Item Price
-- 3 - Location not configured for Item
-- 4 - Invalid Item
-- 5 - Invalid Location

--Validate Records

INSERT INTO @tblErrorEffectiveItemPrice
(
	strItemNo,
	strFieldValue,
	intRowNumber, 
	intErrorType
)
SELECT -- Duplicate Imported Effective Item Price
	strItemNo = DuplicateImportEffectiveItemPrice.strItemNo,
	strFieldValue = DuplicateImportEffectiveItemPrice.strLocation,
	intRowNumber = DuplicateImportEffectiveItemPrice.intRowNumber,
	intErrorType = 1
FROM
(
	SELECT 
		strItemNo,
		strLocation,
		intRowNumber,
		RowNumber = ROW_NUMBER() OVER(PARTITION BY strItemNo, strLocation, dtmEffectiveDate ORDER BY strItemNo)
	FROM 
		@tblFilteredEffectiveItemPrice
) AS DuplicateImportEffectiveItemPrice
WHERE RowNumber > 1
UNION
SELECT -- Existing Effective Item Price
	strItemNo = FilteredEffectiveItemPrice.strItemNo,
	strFieldValue = FilteredEffectiveItemPrice.strLocation,
	intRowNumber = FilteredEffectiveItemPrice.intRowNumber,
	intErrorType = 2
FROM
@tblFilteredEffectiveItemPrice FilteredEffectiveItemPrice
INNER JOIN
vyuICGetItemLocation ItemLocation
ON
FilteredEffectiveItemPrice.strItemNo = ItemLocation.strItemNo
AND
FilteredEffectiveItemPrice.strLocation = ItemLocation.strLocationName
INNER JOIN
tblICEffectiveItemPrice EffectiveItemPrice
ON
ItemLocation.intItemId = EffectiveItemPrice.intItemId
AND
ItemLocation.intItemLocationId = EffectiveItemPrice.intItemLocationId
WHERE
@ysnAllowOverwrite = 0
UNION
SELECT -- Location not configured for Item
	strItemNo = FilteredEffectiveItemPrice.strItemNo,
	strFieldValue = FilteredEffectiveItemPrice.strLocation,
	intRowNumber = FilteredEffectiveItemPrice.intRowNumber,
	intErrorType = 3
FROM
@tblFilteredEffectiveItemPrice FilteredEffectiveItemPrice 
LEFT JOIN
vyuICGetItemLocation ItemLocation
ON
FilteredEffectiveItemPrice.strItemNo = ItemLocation.strItemNo
AND
FilteredEffectiveItemPrice.strLocation = ItemLocation.strLocationName
WHERE
ItemLocation.intItemLocationId IS NULL
UNION
SELECT -- Invalid Item
	strItemNo = FilteredEffectiveItemPrice.strItemNo,
	strFieldValue = FilteredEffectiveItemPrice.strItemNo,
	intRowNumber = FilteredEffectiveItemPrice.intRowNumber,
	intErrorType = 4
FROM
@tblFilteredEffectiveItemPrice FilteredEffectiveItemPrice 
LEFT JOIN
tblICItem Item
ON
FilteredEffectiveItemPrice.strItemNo = Item.strItemNo
WHERE
Item.intItemId IS NULL
UNION
SELECT -- Invalid Location
	strItemNo = FilteredEffectiveItemPrice.strItemNo,
	strFieldValue = FilteredEffectiveItemPrice.strLocation,
	intRowNumber = FilteredEffectiveItemPrice.intRowNumber,
	intErrorType = 5
FROM
@tblFilteredEffectiveItemPrice FilteredEffectiveItemPrice 
LEFT JOIN
tblSMCompanyLocation CompanyLocation
ON
FilteredEffectiveItemPrice.strLocation = CompanyLocation.strLocationName
WHERE
CompanyLocation.intCompanyLocationId IS NULL

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
			WHEN ErrorEffectiveItemPrice.intErrorType IN(1,2,3,5)
			THEN 'Location'
			ELSE 'Item No'
		END,
		strValue = ErrorEffectiveItemPrice.strFieldValue,
		strLogLevel =  CASE
			WHEN ErrorEffectiveItemPrice.intErrorType IN(1,2)
			THEN 'Warning'
			ELSE 'Error'
		END,
		strStatus = CASE
			WHEN ErrorEffectiveItemPrice.intErrorType IN(1,2)
			THEN 'Skipped'
			ELSE 'Failed'
		END,
		intRowNo = ErrorEffectiveItemPrice.intRowNumber,
		strMessage = CASE
			WHEN ErrorEffectiveItemPrice.intErrorType = 1
			THEN 'Duplicate imported effective item price location: ' + ErrorEffectiveItemPrice.strFieldValue + ' on item: ' + ErrorEffectiveItemPrice.strItemNo + '.'
			WHEN ErrorEffectiveItemPrice.intErrorType = 2
			THEN 'Effective item price location: ' + ErrorEffectiveItemPrice.strFieldValue + ' on item: ' + ErrorEffectiveItemPrice.strItemNo + ' already exists and overwrite is not enabled.'
			WHEN ErrorEffectiveItemPrice.intErrorType = 3
			THEN 'Location: ' + ErrorEffectiveItemPrice.strFieldValue + ' is not configured on item: ' + ErrorEffectiveItemPrice.strItemNo + '.'
			WHEN ErrorEffectiveItemPrice.intErrorType = 4
			THEN 'Item: ' + ErrorEffectiveItemPrice.strItemNo + ' does not exist.'
			ELSE 'Location: ' + ErrorEffectiveItemPrice.strFieldValue + ' does not exist.'
		END
	FROM @tblErrorEffectiveItemPrice ErrorEffectiveItemPrice
	WHERE ErrorEffectiveItemPrice.intErrorType IN(1, 2, 3, 4, 5)

--Filter Effective Item Price to be removed

DELETE 
FilteredEffectiveItemPrice
FROM 
	@tblFilteredEffectiveItemPrice FilteredEffectiveItemPrice
	INNER JOIN @tblErrorEffectiveItemPrice ErrorEffectiveItemPrice
		ON FilteredEffectiveItemPrice.intRowNumber = ErrorEffectiveItemPrice.intRowNumber
WHERE ErrorEffectiveItemPrice.intErrorType IN(1, 2, 3, 4, 5)

--Transform and Insert statement

;MERGE INTO tblICEffectiveItemPrice AS TARGET
USING
(
	SELECT
		guiApiUniqueId = FilteredEffectiveItemPrice.guiApiUniqueId,
		intItemId = ItemLocation.intItemId,				
		intItemLocationId = ItemLocation.intItemLocationId,
		dblRetailPrice = NULLIF(FilteredEffectiveItemPrice.dblRetailPrice, 0),
		dtmEffectiveRetailPriceDate = FilteredEffectiveItemPrice.dtmEffectiveDate
	FROM @tblFilteredEffectiveItemPrice FilteredEffectiveItemPrice
	LEFT JOIN
	vyuICGetItemLocation ItemLocation
		ON
		FilteredEffectiveItemPrice.strItemNo = ItemLocation.strItemNo
		AND
		FilteredEffectiveItemPrice.strLocation = ItemLocation.strLocationName
	
) AS SOURCE
ON TARGET.intItemId = SOURCE.intItemId AND TARGET.intItemLocationId = SOURCE.intItemLocationId AND TARGET.dtmEffectiveRetailPriceDate = SOURCE.dtmEffectiveRetailPriceDate
WHEN MATCHED AND @ysnAllowOverwrite = 1 
THEN
	UPDATE SET
		guiApiUniqueId = SOURCE.guiApiUniqueId,
		intItemId = SOURCE.intItemId,				
		intItemLocationId = SOURCE.intItemLocationId,
		dblRetailPrice = ISNULL(SOURCE.dblRetailPrice, TARGET.dblRetailPrice),
		dtmEffectiveRetailPriceDate = SOURCE.dtmEffectiveRetailPriceDate,
		dtmDateModified = GETUTCDATE()
WHEN NOT MATCHED THEN
	INSERT
	(
		guiApiUniqueId,
		intItemId,				
		intItemLocationId,
		dblRetailPrice,
		dtmEffectiveRetailPriceDate,
		dtmDateCreated
	)
	VALUES
	(
		guiApiUniqueId,
		intItemId,				
		intItemLocationId,
		dblRetailPrice,
		dtmEffectiveRetailPriceDate,
		GETUTCDATE()
	);