CREATE PROCEDURE uspApiSchemaTransformCategory 
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

--Filter Category imported

DECLARE @tblFilteredCategory TABLE(
	intKey INT NOT NULL,
    guiApiUniqueId UNIQUEIDENTIFIER NOT NULL,
    intRowNumber INT NULL,
	strCategoryCode NVARCHAR(200) COLLATE Latin1_General_CI_AS NOT NULL,
	strDescription NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	strLineOfBusiness NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
)
INSERT INTO @tblFilteredCategory
(
	intKey,
    guiApiUniqueId,
    intRowNumber,
	strCategoryCode,
	strDescription,
	strLineOfBusiness
)
SELECT 
	intKey,
    guiApiUniqueId,
    intRowNumber,
	strCategoryCode,
	strDescription,
	strLineOfBusiness
FROM
tblApiSchemaTransformCategory
WHERE guiApiUniqueId = @guiApiUniqueId;

--Create Error Table

DECLARE @tblErrorCategory TABLE(
	strCategoryCode NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strFieldValue NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	intRowNumber INT NULL,
	intErrorType INT
)

-- Error Types
-- 1 - Duplicate Imported Category
-- 2 - Existing Cateogry
-- 3 - Invalid Line of Business

--Validate Records

INSERT INTO @tblErrorCategory
(
	strCategoryCode,
	strFieldValue,
	intRowNumber, 
	intErrorType
)
SELECT -- Duplicate Imported Category
	strCategoryCode = DuplicateImportCategory.strCategoryCode,
	strFieldValue = DuplicateImportCategory.strCategoryCode,
	intRowNumber = DuplicateImportCategory.intRowNumber,
	intErrorType = 1
FROM
(
	SELECT 
		strCategoryCode,
		intRowNumber,
		RowNumber = ROW_NUMBER() OVER(PARTITION BY strCategoryCode ORDER BY strCategoryCode)
	FROM 
		@tblFilteredCategory
) AS DuplicateImportCategory
WHERE RowNumber > 1
UNION
SELECT -- Existing Cateogry
	strCategoryCode = FilteredCategory.strCategoryCode,
	strFieldValue = FilteredCategory.strCategoryCode,
	intRowNumber = FilteredCategory.intRowNumber,
	intErrorType = 2
FROM
@tblFilteredCategory FilteredCategory 
INNER JOIN
tblICCategory Category
ON
FilteredCategory.strCategoryCode = Category.strCategoryCode
AND @ysnAllowOverwrite = 0
UNION
SELECT
	strCategoryCode = FilteredCategory.strCategoryCode,
	strFieldValue = FilteredCategory.strLineOfBusiness,
	intRowNumber = FilteredCategory.intRowNumber,
	intErrorType = 3
FROM
@tblFilteredCategory FilteredCategory
LEFT JOIN
tblSMLineOfBusiness LineOfBusiness
ON
FilteredCategory.strLineOfBusiness = LineOfBusiness.strLineOfBusiness
WHERE
LineOfBusiness.intLineOfBusinessId IS NULL

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
		WHEN ErrorCategory.intErrorType IN(1,2)
		THEN 'Category Code'
		ELSE 'Line of Business'
	END,
	strValue = ErrorCategory.strFieldValue,
	strLogLevel =  CASE
		WHEN ErrorCategory.intErrorType IN(1,2)
		THEN 'Warning'
		ELSE 'Error'
	END,
	strStatus = CASE
		WHEN ErrorCategory.intErrorType IN(1,2)
		THEN 'Skipped'
		ELSE 'Failed'
	END,
	intRowNo = ErrorCategory.intRowNumber,
	strMessage = CASE
		WHEN ErrorCategory.intErrorType = 1
		THEN 'Duplicate imported category: ' + ErrorCategory.strFieldValue + '.'
		WHEN ErrorCategory.intErrorType = 2
		THEN 'Category: ' + ErrorCategory.strFieldValue + ' already exists and overwrite is not enabled.'
		ELSE 'Line of Business: ' + ErrorCategory.strFieldValue + ' does not exist.'
	END
FROM @tblErrorCategory ErrorCategory
WHERE ErrorCategory.intErrorType IN(1, 2, 3)

--Filter Category to be removed

DELETE 
FilteredCategory
FROM 
	@tblFilteredCategory FilteredCategory
	INNER JOIN @tblErrorCategory ErrorCategory
		ON FilteredCategory.intRowNumber = ErrorCategory.intRowNumber
WHERE ErrorCategory.intErrorType IN(1, 2, 3)

--Crete Output Table

DECLARE @tblCategoryOutput TABLE(
	strCategoryCode NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strAction NVARCHAR(100) COLLATE Latin1_General_CI_AS
)

--Transform and Insert statement

;MERGE INTO tblICCategory AS TARGET
USING
(
	SELECT
		guiApiUniqueId = FilteredCategory.guiApiUniqueId,
		strCategoryCode = FilteredCategory.strCategoryCode,
		strDescription = FilteredCategory.strDescription,
		intLineOfBusinessId = LineOfBusiness.intLineOfBusinessId
	FROM @tblFilteredCategory FilteredCategory
	LEFT JOIN tblSMLineOfBusiness LineOfBusiness
		ON FilteredCategory.strLineOfBusiness = LineOfBusiness.strLineOfBusiness
) AS SOURCE
ON TARGET.strCategoryCode = SOURCE.strCategoryCode
WHEN MATCHED AND @ysnAllowOverwrite = 1 
THEN
	UPDATE SET
		guiApiUniqueId = SOURCE.guiApiUniqueId,
		strCategoryCode = SOURCE.strCategoryCode,
		strDescription = SOURCE.strDescription,
		intLineOfBusinessId = SOURCE.intLineOfBusinessId,
		dtmDateModified = GETUTCDATE()
WHEN NOT MATCHED THEN
	INSERT
	(
		guiApiUniqueId,
		strCategoryCode,
		strDescription,
		intLineOfBusinessId,
		dtmDateCreated
	)
	VALUES
	(
		guiApiUniqueId,
		strCategoryCode,
		strDescription,
		intLineOfBusinessId,
		GETUTCDATE()
	)
OUTPUT INSERTED.strCategoryCode, $action AS strAction INTO @tblCategoryOutput;

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
	strField = 'Category Code',
	strValue = FilteredCategory.strCategoryCode,
	strLogLevel = 'Warning',
	strStatus = 'Skipped',
	intRowNo = FilteredCategory.intRowNumber,
	strMessage = 'Category: ' + FilteredCategory.strCategoryCode + ' already exists and overwrite is not enabled.'
FROM @tblFilteredCategory FilteredCategory
LEFT JOIN @tblCategoryOutput CategoryOutput
	ON FilteredCategory.strCategoryCode = CategoryOutput.strCategoryCode
WHERE CategoryOutput.strCategoryCode IS NULL