CREATE PROCEDURE uspApiSchemaTransformUnitMeasure 
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

--Filter Unit of Measure imported

DECLARE @tblFilteredUnitMeasure TABLE(
	intKey INT NOT NULL,
    guiApiUniqueId UNIQUEIDENTIFIER NOT NULL,
    intRowNumber INT NULL,
	strUnitMeasure NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	strSymbol NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	strUnitType NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	intDecimalPlaces INT NULL
)
INSERT INTO @tblFilteredUnitMeasure
(
	intKey,
    guiApiUniqueId,
    intRowNumber,
	strUnitMeasure,
	strSymbol,
	strUnitType,
	intDecimalPlaces
)
SELECT 
	intKey,
    guiApiUniqueId,
    intRowNumber,
	strUnitMeasure,
	strSymbol,
	strUnitType,
	intDecimalPlaces
FROM
tblApiSchemaTransformUnitMeasure
WHERE guiApiUniqueId = @guiApiUniqueId;

--Create Error Table

DECLARE @tblErrorUnitMeasure TABLE(
	strUnitMeasure NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	intRowNumber INT NULL,
	intErrorType INT
)

-- Error Types
-- 1 - Duplicate Imported Unit of Measure
-- 2 - Existing Unit of Measure

--Validate Records

INSERT INTO @tblErrorUnitMeasure
(
	strUnitMeasure,
	intRowNumber, 
	intErrorType
)
SELECT -- Duplicate Imported Unit of Measure
	strUnitMeasure = DuplicateImportUnitMeasure.strUnitMeasure,
	intRowNumber = DuplicateImportUnitMeasure.intRowNumber,
	intErrorType = 1
FROM
(
	SELECT 
		strUnitMeasure,
		intRowNumber,
		RowNumber = ROW_NUMBER() OVER(PARTITION BY strUnitMeasure ORDER BY strUnitMeasure)
	FROM 
		@tblFilteredUnitMeasure
) AS DuplicateImportUnitMeasure
WHERE RowNumber > 1
UNION
SELECT -- Existing Unit of Measure
	strUnitMeasure = FilteredUnitMeasure.strUnitMeasure,
	intRowNumber = FilteredUnitMeasure.intRowNumber,
	intErrorType = 2
FROM
@tblFilteredUnitMeasure FilteredUnitMeasure 
INNER JOIN
tblICUnitMeasure UnitMeasure
ON
FilteredUnitMeasure.strUnitMeasure = UnitMeasure.strUnitMeasure
AND @ysnAllowOverwrite = 0

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
	strField = 'Unit of Measure',
	strValue = ErrorUnitMeasure.strUnitMeasure,
	strLogLevel = 'Warning',
	strStatus = 'Skpped',
	intRowNo = ErrorUnitMeasure.intRowNumber,
	strMessage = CASE
		WHEN ErrorUnitMeasure.intErrorType = 1
			THEN 'Duplicate imported unit of measure: ' + ISNULL(ErrorUnitMeasure.strUnitMeasure, '') + '.'
		ELSE 'Unit of measure: ' + ISNULL(ErrorUnitMeasure.strUnitMeasure, '') + ' already exists and overwrite is not enabled.'
	END
FROM @tblErrorUnitMeasure ErrorUnitMeasure
WHERE ErrorUnitMeasure.intErrorType IN(1, 2)

--Filter Unit of Measure to be removed

DELETE 
FilteredUnitMeasure
FROM 
	@tblFilteredUnitMeasure FilteredUnitMeasure
	INNER JOIN @tblErrorUnitMeasure ErrorUnitMeasure
		ON FilteredUnitMeasure.intRowNumber = ErrorUnitMeasure.intRowNumber
WHERE ErrorUnitMeasure.intErrorType IN(1, 2)

--Crete Output Table

DECLARE @tblUnitMeasureOutput TABLE(
	strUnitMeasure NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strAction NVARCHAR(100) COLLATE Latin1_General_CI_AS
)

--Transform and Insert statement

;MERGE INTO tblICUnitMeasure AS TARGET
USING
(
	SELECT
		guiApiUniqueId = FilteredUnitMeasure.guiApiUniqueId,
		strUnitMeasure = FilteredUnitMeasure.strUnitMeasure,
		strSymbol = FilteredUnitMeasure.strSymbol,
		strUnitType = FilteredUnitMeasure.strUnitType,
		intDecimalPlaces = FilteredUnitMeasure.intDecimalPlaces
	FROM @tblFilteredUnitMeasure FilteredUnitMeasure
) AS SOURCE
ON TARGET.strUnitMeasure = SOURCE.strUnitMeasure
WHEN MATCHED AND @ysnAllowOverwrite = 1 
THEN
	UPDATE SET
		guiApiUniqueId = SOURCE.guiApiUniqueId,
		strUnitMeasure = SOURCE.strUnitMeasure,
		strSymbol = SOURCE.strSymbol,
		strUnitType = SOURCE.strUnitType,
		intDecimalPlaces = SOURCE.intDecimalPlaces,
		dtmDateModified = GETUTCDATE()
WHEN NOT MATCHED THEN
	INSERT
	(
		guiApiUniqueId,
		strUnitMeasure,
		strSymbol,
		strUnitType,
		intDecimalPlaces,
		dtmDateCreated
	)
	VALUES
	(
		guiApiUniqueId,
		strUnitMeasure,
		strSymbol,
		strUnitType,
		intDecimalPlaces,
		GETUTCDATE()
	)
OUTPUT INSERTED.strUnitMeasure, $action AS strAction INTO @tblUnitMeasureOutput;

--Log skipped items when overwrite is not enabled.

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
	strField = 'Unit of Measure',
	strValue = FilteredUnitMeasure.strUnitMeasure,
	strLogLevel = 'Warning',
	strStatus = 'Skipped',
	intRowNo = FilteredUnitMeasure.intRowNumber,
	strMessage = 'Unit of measure: ' + FilteredUnitMeasure.strUnitMeasure + ' already exists and overwrite is not enabled.'
FROM @tblFilteredUnitMeasure FilteredUnitMeasure
LEFT JOIN @tblUnitMeasureOutput UnitMeasureOutput
	ON FilteredUnitMeasure.strUnitMeasure = UnitMeasureOutput.strUnitMeasure
WHERE UnitMeasureOutput.strUnitMeasure IS NULL