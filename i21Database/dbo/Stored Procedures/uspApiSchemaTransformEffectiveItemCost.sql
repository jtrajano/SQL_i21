CREATE PROCEDURE uspApiSchemaTransformEffectiveItemCost 
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

--Filter Effective Item Cost imported

DECLARE @tblFilteredEffectiveItemCost TABLE(
	intKey INT NOT NULL,
    guiApiUniqueId UNIQUEIDENTIFIER NOT NULL,
    intRowNumber INT NULL,
	strItemNo NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	strLocation NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	dblCost NUMERIC(38, 20) NULL,
	dtmEffectiveDate DATETIME NULL
)
INSERT INTO @tblFilteredEffectiveItemCost
(
	intKey,
    guiApiUniqueId,
    intRowNumber,
	strItemNo,
	strLocation,
	dblCost,
	dtmEffectiveDate
)
SELECT 
	intKey,
    guiApiUniqueId,
    intRowNumber,
	strItemNo,
	strLocation,
	dblCost,
	dtmEffectiveDate
FROM
tblApiSchemaTransformEffectiveItemCost
WHERE guiApiUniqueId = @guiApiUniqueId;

--Create Error Table

DECLARE @tblErrorEffectiveItemCost TABLE(
	strItemNo NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strFieldValue NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	intRowNumber INT NULL,
	intErrorType INT
)

-- Error Types
-- 1 - Duplicate Imported Effective Item Cost
-- 2 - Existing Effective Item Cost
-- 3 - Location not configured for Item
-- 4 - Invalid Item
-- 5 - Invalid Location

--Validate Records

INSERT INTO @tblErrorEffectiveItemCost
(
	strItemNo,
	strFieldValue,
	intRowNumber, 
	intErrorType
)
SELECT -- Duplicate Imported Effective Item Cost
	strItemNo = DuplicateImportEffectiveItemCost.strItemNo,
	strFieldValue = DuplicateImportEffectiveItemCost.strLocation,
	intRowNumber = DuplicateImportEffectiveItemCost.intRowNumber,
	intErrorType = 1
FROM
(
	SELECT 
		strItemNo,
		strLocation,
		intRowNumber,
		RowNumber = ROW_NUMBER() OVER(PARTITION BY strItemNo, strLocation, dtmEffectiveDate ORDER BY strItemNo)
	FROM 
		@tblFilteredEffectiveItemCost
) AS DuplicateImportEffectiveItemCost
WHERE RowNumber > 1
UNION
SELECT -- Existing Effective Item Cost
	strItemNo = FilteredEffectiveItemCost.strItemNo,
	strFieldValue = FilteredEffectiveItemCost.strLocation,
	intRowNumber = FilteredEffectiveItemCost.intRowNumber,
	intErrorType = 2
FROM
@tblFilteredEffectiveItemCost FilteredEffectiveItemCost
INNER JOIN
vyuICGetItemLocation ItemLocation
ON
FilteredEffectiveItemCost.strItemNo = ItemLocation.strItemNo
AND
FilteredEffectiveItemCost.strLocation = ItemLocation.strLocationName
INNER JOIN
tblICEffectiveItemCost EffectiveItemCost
ON
ItemLocation.intItemId = EffectiveItemCost.intItemId
AND
ItemLocation.intItemLocationId = EffectiveItemCost.intItemLocationId
WHERE
@ysnAllowOverwrite = 0
UNION
SELECT -- Location not configured for Item
	strItemNo = FilteredEffectiveItemCost.strItemNo,
	strFieldValue = FilteredEffectiveItemCost.strLocation,
	intRowNumber = FilteredEffectiveItemCost.intRowNumber,
	intErrorType = 3
FROM
@tblFilteredEffectiveItemCost FilteredEffectiveItemCost 
LEFT JOIN
vyuICGetItemLocation ItemLocation
ON
FilteredEffectiveItemCost.strItemNo = ItemLocation.strItemNo
AND
FilteredEffectiveItemCost.strLocation = ItemLocation.strLocationName
WHERE
ItemLocation.intItemLocationId IS NULL
UNION
SELECT -- Invalid Item
	strItemNo = FilteredEffectiveItemCost.strItemNo,
	strFieldValue = FilteredEffectiveItemCost.strItemNo,
	intRowNumber = FilteredEffectiveItemCost.intRowNumber,
	intErrorType = 4
FROM
@tblFilteredEffectiveItemCost FilteredEffectiveItemCost 
LEFT JOIN
tblICItem Item
ON
FilteredEffectiveItemCost.strItemNo = Item.strItemNo
WHERE
Item.intItemId IS NULL
UNION
SELECT -- Invalid Location
	strItemNo = FilteredEffectiveItemCost.strItemNo,
	strFieldValue = FilteredEffectiveItemCost.strLocation,
	intRowNumber = FilteredEffectiveItemCost.intRowNumber,
	intErrorType = 5
FROM
@tblFilteredEffectiveItemCost FilteredEffectiveItemCost 
LEFT JOIN
tblSMCompanyLocation CompanyLocation
ON
FilteredEffectiveItemCost.strLocation = CompanyLocation.strLocationName
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
			WHEN ErrorEffectiveItemCost.intErrorType IN(1,2,3,5)
			THEN 'Location'
			ELSE 'Item No'
		END,
		strValue = ErrorEffectiveItemCost.strFieldValue,
		strLogLevel =  CASE
			WHEN ErrorEffectiveItemCost.intErrorType IN(1,2)
			THEN 'Warning'
			ELSE 'Error'
		END,
		strStatus = CASE
			WHEN ErrorEffectiveItemCost.intErrorType IN(1,2)
			THEN 'Skipped'
			ELSE 'Failed'
		END,
		intRowNo = ErrorEffectiveItemCost.intRowNumber,
		strMessage = CASE
			WHEN ErrorEffectiveItemCost.intErrorType = 1
			THEN 'Duplicate imported effective item cost location: ' + ErrorEffectiveItemCost.strFieldValue + ' on item: ' + ErrorEffectiveItemCost.strItemNo + '.'
			WHEN ErrorEffectiveItemCost.intErrorType = 2
			THEN 'Effective item cost location: ' + ErrorEffectiveItemCost.strFieldValue + ' on item: ' + ErrorEffectiveItemCost.strItemNo + ' already exists and overwrite is not enabled.'
			WHEN ErrorEffectiveItemCost.intErrorType = 3
			THEN 'Location: ' + ErrorEffectiveItemCost.strFieldValue + ' is not configured on item: ' + ErrorEffectiveItemCost.strItemNo + '.'
			WHEN ErrorEffectiveItemCost.intErrorType = 4
			THEN 'Item: ' + ErrorEffectiveItemCost.strItemNo + ' does not exist.'
			ELSE 'Location: ' + ErrorEffectiveItemCost.strFieldValue + ' does not exist.'
		END
	FROM @tblErrorEffectiveItemCost ErrorEffectiveItemCost
	WHERE ErrorEffectiveItemCost.intErrorType IN(1, 2, 3, 4, 5)

--Filter Effective Item Cost to be removed

DELETE 
FilteredEffectiveItemCost
FROM 
	@tblFilteredEffectiveItemCost FilteredEffectiveItemCost
	INNER JOIN @tblErrorEffectiveItemCost ErrorEffectiveItemCost
		ON FilteredEffectiveItemCost.intRowNumber = ErrorEffectiveItemCost.intRowNumber
WHERE ErrorEffectiveItemCost.intErrorType IN(1, 2, 3, 4, 5)

--Transform and Insert statement

;MERGE INTO tblICEffectiveItemCost AS TARGET
USING
(
	SELECT
		guiApiUniqueId = FilteredEffectiveItemCost.guiApiUniqueId,
		intItemId = ItemLocation.intItemId,				
		intItemLocationId = ItemLocation.intItemLocationId,
		dblCost = NULLIF(FilteredEffectiveItemCost.dblCost, 0),
		dtmEffectiveCostDate = FilteredEffectiveItemCost.dtmEffectiveDate
	FROM @tblFilteredEffectiveItemCost FilteredEffectiveItemCost
	LEFT JOIN
	vyuICGetItemLocation ItemLocation
		ON
		FilteredEffectiveItemCost.strItemNo = ItemLocation.strItemNo
		AND
		FilteredEffectiveItemCost.strLocation = ItemLocation.strLocationName
	
) AS SOURCE
ON TARGET.intItemId = SOURCE.intItemId AND TARGET.intItemLocationId = SOURCE.intItemLocationId AND TARGET.dtmEffectiveCostDate = SOURCE.dtmEffectiveCostDate
WHEN MATCHED AND @ysnAllowOverwrite = 1 
THEN
	UPDATE SET
		guiApiUniqueId = SOURCE.guiApiUniqueId,
		intItemId = SOURCE.intItemId,				
		intItemLocationId = SOURCE.intItemLocationId,
		dblCost = ISNULL(SOURCE.dblCost, TARGET.dblCost),
		dtmEffectiveCostDate = SOURCE.dtmEffectiveCostDate,
		dtmDateModified = GETUTCDATE()
WHEN NOT MATCHED THEN
	INSERT
	(
		guiApiUniqueId,
		intItemId,				
		intItemLocationId,
		dblCost,
		dtmEffectiveCostDate,
		dtmDateCreated
	)
	VALUES
	(
		guiApiUniqueId,
		intItemId,				
		intItemLocationId,
		dblCost,
		dtmEffectiveCostDate,
		GETUTCDATE()
	);