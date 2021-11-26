CREATE PROCEDURE uspApiSchemaTransformCategoryAccount 
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

--Filter Category Account imported

DECLARE @tblFilteredCategoryAccount TABLE(
	intKey INT NOT NULL,
    guiApiUniqueId UNIQUEIDENTIFIER NOT NULL,
    intRowNumber INT NULL,
	strCategoryCode NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	strAccountCategory NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	strAccountId NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
)
INSERT INTO @tblFilteredCategoryAccount
(
	intKey,
    guiApiUniqueId,
    intRowNumber,
	strCategoryCode,
	strAccountCategory,
	strAccountId
)
SELECT 
	intKey,
    guiApiUniqueId,
    intRowNumber,
	strCategoryCode,
	strAccountCategory,
	strAccountId
FROM
tblApiSchemaTransformCategoryAccount
WHERE guiApiUniqueId = @guiApiUniqueId;

--Create Error Table

DECLARE @tblErrorCategoryAccount TABLE(
	strCategoryCode NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strFieldValue NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	intRowNumber INT NULL,
	intErrorType INT
)

-- Error Types
-- 1 - Duplicate Imported Category Account
-- 2 - Existing Cateogry Account
-- 3 - Invalid Account Category
-- 4 - Invalid Account ID
-- 5 - Invalid Category

--Validate Records

INSERT INTO @tblErrorCategoryAccount
(
	strCategoryCode,
	strFieldValue,
	intRowNumber, 
	intErrorType
)
SELECT -- Duplicate Imported Category Account
	strCategoryCode = DuplicateImportCategoryAccount.strCategoryCode,
	strFieldValue = DuplicateImportCategoryAccount.strAccountCategory,
	intRowNumber = DuplicateImportCategoryAccount.intRowNumber,
	intErrorType = 1
FROM
(
	SELECT 
		strCategoryCode,
		strAccountCategory,
		intRowNumber,
		RowNumber = ROW_NUMBER() OVER(PARTITION BY strCategoryCode, strAccountCategory ORDER BY strCategoryCode)
	FROM 
		@tblFilteredCategoryAccount
) AS DuplicateImportCategoryAccount
WHERE RowNumber > 1
UNION
SELECT -- Existing Cateogry Account
	strCategoryCode = FilteredCategoryAccount.strCategoryCode,
	strFieldValue = FilteredCategoryAccount.strAccountCategory,
	intRowNumber = FilteredCategoryAccount.intRowNumber,
	intErrorType = 2
FROM
@tblFilteredCategoryAccount FilteredCategoryAccount 
INNER JOIN
tblICCategory Category
ON
FilteredCategoryAccount.strCategoryCode = Category.strCategoryCode
INNER JOIN
vyuGLAccountDetail AccountDetail
ON
FilteredCategoryAccount.strAccountCategory = AccountDetail.strAccountCategory
AND
FilteredCategoryAccount.strAccountId = AccountDetail.strAccountId
INNER JOIN
tblICCategoryAccount CategoryAccount
ON
Category.intCategoryId = CategoryAccount.intCategoryId
AND
AccountDetail.intAccountId = CategoryAccount.intAccountId
AND
AccountDetail.intAccountCategoryId = CategoryAccount.intAccountCategoryId
WHERE
@ysnAllowOverwrite = 0
UNION
SELECT
	strCategoryCode = FilteredCategoryAccount.strCategoryCode,
	strFieldValue = FilteredCategoryAccount.strAccountCategory,
	intRowNumber = FilteredCategoryAccount.intRowNumber,
	intErrorType = 3
FROM
@tblFilteredCategoryAccount FilteredCategoryAccount
LEFT JOIN
tblGLAccountCategory AccountCategory
ON
FilteredCategoryAccount.strAccountCategory = AccountCategory.strAccountCategory
WHERE
AccountCategory.intAccountCategoryId IS NULL
UNION
SELECT
	strCategoryCode = FilteredCategoryAccount.strCategoryCode,
	strFieldValue = FilteredCategoryAccount.strAccountId,
	intRowNumber = FilteredCategoryAccount.intRowNumber,
	intErrorType = 4
FROM
@tblFilteredCategoryAccount FilteredCategoryAccount
LEFT JOIN
vyuGLAccountDetail AccountDetail
ON
FilteredCategoryAccount.strAccountCategory = AccountDetail.strAccountCategory
AND
FilteredCategoryAccount.strAccountId = AccountDetail.strAccountId
WHERE
AccountDetail.strAccountId IS NULL
UNION
SELECT
	strCategoryCode = FilteredCategoryAccount.strCategoryCode,
	strFieldValue = FilteredCategoryAccount.strCategoryCode,
	intRowNumber = FilteredCategoryAccount.intRowNumber,
	intErrorType = 5
FROM
@tblFilteredCategoryAccount FilteredCategoryAccount
LEFT JOIN
tblICCategory Category
ON
FilteredCategoryAccount.strCategoryCode = Category.strCategoryCode
WHERE
Category.intCategoryId IS NULL

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
		WHEN ErrorCategoryAccount.intErrorType IN(1,2,3)
		THEN 'GL Account Category'
		ELSE 'GL Account Id'
	END,
	strValue = ErrorCategoryAccount.strFieldValue,
	strLogLevel =  CASE
		WHEN ErrorCategoryAccount.intErrorType IN(1,2)
		THEN 'Warning'
		ELSE 'Error'
	END,
	strStatus = CASE
		WHEN ErrorCategoryAccount.intErrorType IN(1,2)
		THEN 'Skipped'
		ELSE 'Failed'
	END,
	intRowNo = ErrorCategoryAccount.intRowNumber,
	strMessage = CASE
		WHEN ErrorCategoryAccount.intErrorType = 1
		THEN 'Duplicate imported account category: ' + ErrorCategoryAccount.strFieldValue + ' on category: ' + ErrorCategoryAccount.strCategoryCode + '.'
		WHEN ErrorCategoryAccount.intErrorType = 2
		THEN 'Account category: ' + ErrorCategoryAccount.strFieldValue + ' on ' + ErrorCategoryAccount.strCategoryCode + ' already exists and overwrite is not enabled.'
		WHEN ErrorCategoryAccount.intErrorType = 3
		THEN 'Account category: ' + ErrorCategoryAccount.strFieldValue + ' does not exist.'
		WHEN ErrorCategoryAccount.intErrorType = 4
		THEN 'Account ID: ' + ErrorCategoryAccount.strFieldValue + ' does not exist or does not belong to imported account category.'
		ELSE 'Category code: ' + ErrorCategoryAccount.strFieldValue + ' does not exist.'
	END
FROM @tblErrorCategoryAccount ErrorCategoryAccount
WHERE ErrorCategoryAccount.intErrorType IN(1, 2, 3, 4, 5)

--Filter Category to be removed

DELETE 
FilteredCategoryAccount
FROM 
	@tblFilteredCategoryAccount FilteredCategoryAccount
	INNER JOIN @tblErrorCategoryAccount ErrorCategoryAccount
		ON FilteredCategoryAccount.intRowNumber = ErrorCategoryAccount.intRowNumber
WHERE ErrorCategoryAccount.intErrorType IN(1, 2, 3, 4, 5)

--Transform and Insert statement

;MERGE INTO tblICCategoryAccount AS TARGET
USING
(
	SELECT
		guiApiUniqueId = FilteredCategoryAccount.guiApiUniqueId,
		intCategoryId = Category.intCategoryId,
		intAccountCategoryId = AccountDetail.intAccountCategoryId,
		intAccountId = AccountDetail.intAccountId
	FROM @tblFilteredCategoryAccount FilteredCategoryAccount
	INNER JOIN
	tblICCategory Category
		ON
		FilteredCategoryAccount.strCategoryCode = Category.strCategoryCode
	INNER JOIN
	vyuGLAccountDetail AccountDetail
		ON
		FilteredCategoryAccount.strAccountCategory = AccountDetail.strAccountCategory
		AND
		FilteredCategoryAccount.strAccountId = AccountDetail.strAccountId
) AS SOURCE
ON 
TARGET.intCategoryId = SOURCE.intCategoryId
AND
TARGET.intAccountCategoryId = SOURCE.intAccountCategoryId
WHEN MATCHED AND @ysnAllowOverwrite = 1 
THEN
	UPDATE SET
		guiApiUniqueId = SOURCE.guiApiUniqueId,
		intCategoryId = SOURCE.intCategoryId,
		intAccountCategoryId = SOURCE.intAccountCategoryId,
		intAccountId = SOURCE.intAccountId,
		dtmDateModified = GETUTCDATE()
WHEN NOT MATCHED THEN
	INSERT
	(
		guiApiUniqueId,
		intCategoryId,
		intAccountCategoryId,
		intAccountId,
		dtmDateCreated
	)
	VALUES
	(
		guiApiUniqueId,
		intCategoryId,
		intAccountCategoryId,
		intAccountId,
		GETUTCDATE()
	);