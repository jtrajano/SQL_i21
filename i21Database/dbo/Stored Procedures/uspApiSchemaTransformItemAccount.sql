CREATE PROCEDURE uspApiSchemaTransformItemAccount 
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

--Filter Item Account imported

DECLARE @tblFilteredItemAccount TABLE(
	intKey INT NOT NULL,
    guiApiUniqueId UNIQUEIDENTIFIER NOT NULL,
    intRowNumber INT NULL,
	strItemNo NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	strAccountCategory NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	strAccountId NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
)
INSERT INTO @tblFilteredItemAccount
(
	intKey,
    guiApiUniqueId,
    intRowNumber,
	strItemNo,
	strAccountCategory,
	strAccountId
)
SELECT 
	intKey,
    guiApiUniqueId,
    intRowNumber,
	strItemNo,
	strAccountCategory,
	strAccountId
FROM
tblApiSchemaTransformItemAccount
WHERE guiApiUniqueId = @guiApiUniqueId;

--Create Error Table

DECLARE @tblErrorItemAccount TABLE(
	strItemNo NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strFieldValue NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	intRowNumber INT NULL,
	intErrorType INT
)

-- Error Types
-- 1 - Duplicate Imported Item Account
-- 2 - Existing Item Account
-- 3 - Invalid Account Category
-- 4 - Invalid Account ID
-- 5 - Invalid Item

--Validate Records

INSERT INTO @tblErrorItemAccount
(
	strItemNo,
	strFieldValue,
	intRowNumber, 
	intErrorType
)
SELECT -- Duplicate Imported Item Account
	strItemNo = DuplicateImportItemAccount.strItemNo,
	strFieldValue = DuplicateImportItemAccount.strAccountCategory,
	intRowNumber = DuplicateImportItemAccount.intRowNumber,
	intErrorType = 1
FROM
(
	SELECT 
		strItemNo,
		strAccountCategory,
		intRowNumber,
		RowNumber = ROW_NUMBER() OVER(PARTITION BY strItemNo, strAccountCategory ORDER BY strItemNo)
	FROM 
		@tblFilteredItemAccount
) AS DuplicateImportItemAccount
WHERE RowNumber > 1
UNION
SELECT -- Existing Item Account
	strItemNo = FilteredItemAccount.strItemNo,
	strFieldValue = FilteredItemAccount.strAccountCategory,
	intRowNumber = FilteredItemAccount.intRowNumber,
	intErrorType = 2
FROM
@tblFilteredItemAccount FilteredItemAccount 
INNER JOIN
tblICItem Item
ON
FilteredItemAccount.strItemNo = Item.strItemNo
INNER JOIN
vyuGLAccountDetail AccountDetail
ON
FilteredItemAccount.strAccountCategory = AccountDetail.strAccountCategory
AND
FilteredItemAccount.strAccountId = AccountDetail.strAccountId
INNER JOIN
tblICItemAccount ItemAccount
ON
Item.intItemId = ItemAccount.intItemId
AND
AccountDetail.intAccountId = ItemAccount.intAccountId
AND
AccountDetail.intAccountCategoryId = ItemAccount.intAccountCategoryId
WHERE
@ysnAllowOverwrite = 0
UNION
SELECT -- Invalid Account Category
	strItemNo = FilteredItemAccount.strItemNo,
	strFieldValue = FilteredItemAccount.strAccountCategory,
	intRowNumber = FilteredItemAccount.intRowNumber,
	intErrorType = 3
FROM
@tblFilteredItemAccount FilteredItemAccount
LEFT JOIN
tblGLAccountCategory AccountCategory
ON
FilteredItemAccount.strAccountCategory = AccountCategory.strAccountCategory
WHERE
AccountCategory.intAccountCategoryId IS NULL
UNION
SELECT -- Invalid Account ID
	strItemNo = FilteredItemAccount.strItemNo,
	strFieldValue = FilteredItemAccount.strAccountId,
	intRowNumber = FilteredItemAccount.intRowNumber,
	intErrorType = 4
FROM
@tblFilteredItemAccount FilteredItemAccount
LEFT JOIN
vyuGLAccountDetail AccountDetail
ON
FilteredItemAccount.strAccountCategory = AccountDetail.strAccountCategory
AND
FilteredItemAccount.strAccountId = AccountDetail.strAccountId
WHERE
AccountDetail.strAccountId IS NULL
UNION
SELECT -- Invalid Item
	strItemNo = FilteredItemAccount.strItemNo,
	strFieldValue = FilteredItemAccount.strItemNo,
	intRowNumber = FilteredItemAccount.intRowNumber,
	intErrorType = 5
FROM
@tblFilteredItemAccount FilteredItemAccount
LEFT JOIN
tblICItem Item
ON
FilteredItemAccount.strItemNo = Item.strItemNo
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
		WHEN ErrorItemAccount.intErrorType IN(1,2,3)
		THEN 'GL Account Category'
		WHEN ErrorItemAccount.intErrorType = 4
		THEN 'GL Account Id'
		ELSE 'Item No'
	END,
	strValue = ErrorItemAccount.strFieldValue,
	strLogLevel =  CASE
		WHEN ErrorItemAccount.intErrorType IN(1,2)
		THEN 'Warning'
		ELSE 'Error'
	END,
	strStatus = CASE
		WHEN ErrorItemAccount.intErrorType IN(1,2)
		THEN 'Skipped'
		ELSE 'Failed'
	END,
	intRowNo = ErrorItemAccount.intRowNumber,
	strMessage = CASE
		WHEN ErrorItemAccount.intErrorType = 1
		THEN 'Duplicate imported account category: ' + ErrorItemAccount.strFieldValue + ' on item: ' + ErrorItemAccount.strItemNo + '.'
		WHEN ErrorItemAccount.intErrorType = 2
		THEN 'Account category: ' + ErrorItemAccount.strFieldValue + ' on item: ' + ErrorItemAccount.strItemNo + ' already exists and overwrite is not enabled.'
		WHEN ErrorItemAccount.intErrorType = 3
		THEN 'Account category: ' + ErrorItemAccount.strFieldValue + ' does not exist.'
		WHEN ErrorItemAccount.intErrorType = 4
		THEN 'Account ID: ' + ErrorItemAccount.strFieldValue + ' does not exist or does not belong to imported account category.'
		ELSE 'Item: ' + ErrorItemAccount.strFieldValue + ' does not exist.'
	END
FROM @tblErrorItemAccount ErrorItemAccount
WHERE ErrorItemAccount.intErrorType IN(1, 2, 3, 4, 5)

--Filter Item Account to be removed

DELETE 
FilteredItemAccount
FROM 
	@tblFilteredItemAccount FilteredItemAccount
	INNER JOIN @tblErrorItemAccount ErrorItemAccount
		ON FilteredItemAccount.intRowNumber = ErrorItemAccount.intRowNumber
WHERE ErrorItemAccount.intErrorType IN(1, 2, 3, 4, 5)

--Transform and Insert statement

;MERGE INTO tblICItemAccount AS TARGET
USING
(
	SELECT
		guiApiUniqueId = FilteredItemAccount.guiApiUniqueId,
		intItemId = Item.intItemId,
		intAccountCategoryId = AccountDetail.intAccountCategoryId,
		intAccountId = AccountDetail.intAccountId
	FROM @tblFilteredItemAccount FilteredItemAccount
	INNER JOIN
	tblICItem Item
		ON
		FilteredItemAccount.strItemNo = Item.strItemNo
	INNER JOIN
	vyuGLAccountDetail AccountDetail
		ON
		FilteredItemAccount.strAccountCategory = AccountDetail.strAccountCategory
		AND
		FilteredItemAccount.strAccountId = AccountDetail.strAccountId
) AS SOURCE
ON 
TARGET.intItemId = SOURCE.intItemId
AND
TARGET.intAccountCategoryId = SOURCE.intAccountCategoryId
WHEN MATCHED AND @ysnAllowOverwrite = 1 
THEN
	UPDATE SET
		guiApiUniqueId = SOURCE.guiApiUniqueId,
		intItemId = SOURCE.intItemId,
		intAccountCategoryId = SOURCE.intAccountCategoryId,
		intAccountId = SOURCE.intAccountId,
		dtmDateModified = GETUTCDATE()
WHEN NOT MATCHED THEN
	INSERT
	(
		guiApiUniqueId,
		intItemId,
		intAccountCategoryId,
		intAccountId,
		dtmDateCreated
	)
	VALUES
	(
		guiApiUniqueId,
		intItemId,
		intAccountCategoryId,
		intAccountId,
		GETUTCDATE()
	);