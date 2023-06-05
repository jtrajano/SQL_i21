CREATE PROCEDURE [dbo].[uspApiSchemaTransformCustomerXref]
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

--Filter Customer Xref imported
DECLARE @tblFilteredCustomerXref TABLE(
    guiApiUniqueId UNIQUEIDENTIFIER NOT NULL,
    intRowNumber INT NULL,
	intKey INT NOT NULL,
	strItemNo NVARCHAR (50)  COLLATE Latin1_General_CI_AS NOT NULL,
    strLocationName NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
    strCustomerName NVARCHAR (100)  COLLATE Latin1_General_CI_AS NOT NULL,
    strCustomerProduct NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    strProductDescription NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL, 
    strPickTicketNotes NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
)
INSERT INTO @tblFilteredCustomerXref
(
    guiApiUniqueId,
    intRowNumber,
	intKey,
	strItemNo,
	strLocationName,
	strCustomerName,
    strCustomerProduct,
    strProductDescription,
    strPickTicketNotes
)
SELECT 
	guiApiUniqueId,
    intRowNumber,
	intKey,
	strItemNo,
	strLocationName,
	strCustomerName,
    strCustomerProduct,
    strProductDescription,
    strPickTicketNotes
FROM
tblApiSchemaCustomerXref
WHERE guiApiUniqueId = @guiApiUniqueId;

--Create Error Table
DECLARE @tblErrorCustomerXref TABLE(
	strItemNo NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strFieldValue NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	intRowNumber INT NULL,
	intErrorType INT
)

-- Error Types
-- 1 - Duplicate Imported Customer Xref
-- 2 - Existing Customer Xref
-- 3 - Invalid Item

--Validate Records
INSERT INTO @tblErrorCustomerXref
(
	strItemNo,
	strFieldValue,
	intRowNumber, 
	intErrorType
)
SELECT -- Duplicate Imported Customer Xref
	strItemNo = DuplicateImportCustomerXref.strItemNo,
	strFieldValue = DuplicateImportCustomerXref.strCustomerProduct,
	intRowNumber = DuplicateImportCustomerXref.intRowNumber,
	intErrorType = 1
FROM
(
	SELECT 
		strItemNo,
		strCustomerProduct,
		intRowNumber,
		RowNumber = ROW_NUMBER() OVER(PARTITION BY strItemNo, strCustomerProduct ORDER BY strItemNo)
	FROM 
		@tblFilteredCustomerXref
) AS DuplicateImportCustomerXref
WHERE RowNumber > 1
UNION
SELECT -- Existing Customer Xref
	strItemNo = FilteredCustomerXref.strItemNo,
	strFieldValue = FilteredCustomerXref.strCustomerProduct,
	intRowNumber = FilteredCustomerXref.intRowNumber,
	intErrorType = 2
FROM
@tblFilteredCustomerXref FilteredCustomerXref 
INNER JOIN
tblICItem Item
ON
FilteredCustomerXref.strItemNo = Item.strItemNo
INNER JOIN
vyuICSearchItemCustomerXref CustomerXrefDetail
ON
FilteredCustomerXref.strCustomerProduct = CustomerXrefDetail.strCustomerProduct
AND
FilteredCustomerXref.strCustomerName = CustomerXrefDetail.strName
INNER JOIN
tblICItemCustomerXref ItemCustomerXref
ON
Item.intItemId = ItemCustomerXref.intItemId
AND
CustomerXrefDetail.intItemCustomerXrefId = ItemCustomerXref.intItemCustomerXrefId
WHERE
@ysnAllowOverwrite = 0
UNION
SELECT -- Invalid Item
	strItemNo = FilteredCustomerXref.strItemNo,
	strFieldValue = FilteredCustomerXref.strItemNo,
	intRowNumber = FilteredCustomerXref.intRowNumber,
	intErrorType = 3
FROM
@tblFilteredCustomerXref FilteredCustomerXref
LEFT JOIN
tblICItem Item
ON
FilteredCustomerXref.strItemNo = Item.strItemNo
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
		WHEN ErrorCustomerXref.intErrorType IN(1,2)
		THEN 'Customer Product'
		ELSE 'Item No'
	END,
	strValue = ErrorCustomerXref.strFieldValue,
	strLogLevel =  CASE
		WHEN ErrorCustomerXref.intErrorType IN(1,2)
		THEN 'Warning'
		ELSE 'Error'
	END,
	strStatus = CASE
		WHEN ErrorCustomerXref.intErrorType IN(1,2)
		THEN 'Skipped'
		ELSE 'Failed'
	END,
	intRowNo = ErrorCustomerXref.intRowNumber,
	strMessage = CASE
		WHEN ErrorCustomerXref.intErrorType = 1
		THEN 'Duplicate imported Customer Xref: ' + ErrorCustomerXref.strFieldValue + ' on item: ' + ErrorCustomerXref.strItemNo + '.'
		WHEN ErrorCustomerXref.intErrorType = 2
		THEN 'Customer Xref: ' + ErrorCustomerXref.strFieldValue + ' on item: ' + ErrorCustomerXref.strItemNo + ' already exists and overwrite is not enabled.'
		ELSE 'Item: ' + ErrorCustomerXref.strFieldValue + ' does not exist.'
	END
FROM @tblErrorCustomerXref ErrorCustomerXref
WHERE ErrorCustomerXref.intErrorType IN(1, 2, 3)

--Filter Customer Xref to be removed
DELETE 
FilteredCustomerXref
FROM 
	@tblFilteredCustomerXref FilteredCustomerXref
	INNER JOIN @tblErrorCustomerXref ErrorCustomerXref
		ON FilteredCustomerXref.intRowNumber = ErrorCustomerXref.intRowNumber
WHERE ErrorCustomerXref.intErrorType IN(1, 2, 3)

--Transform and Insert statement
;MERGE INTO tblICItemCustomerXref AS TARGET
USING
(
	SELECT
		guiApiUniqueId = FilteredCustomerXref.guiApiUniqueId,
		intItemId = Item.intItemId,
		intItemLocationId = ItemLocation.intItemLocationId,
		intCustomerId = CustomerName.intEntityId,
		strCustomerProduct = FilteredCustomerXref.strCustomerProduct,
		strProductDescription = FilteredCustomerXref.strProductDescription,
		strPickTicketNotes = FilteredCustomerXref.strPickTicketNotes
	FROM @tblFilteredCustomerXref FilteredCustomerXref
	INNER JOIN
	tblICItem Item
		ON
		FilteredCustomerXref.strItemNo = Item.strItemNo
	INNER JOIN
	vyuICGetItemLocation ItemLocation
		ON
		FilteredCustomerXref.strItemNo = ItemLocation.strItemNo
		AND
		Item.intItemId = ItemLocation.intItemId
	INNER JOIN
	vyuARCustomer CustomerName
		ON
		FilteredCustomerXref.strCustomerName = CustomerName.strName
) AS SOURCE
ON 
TARGET.intItemId = SOURCE.intItemId
AND
TARGET.strCustomerProduct = SOURCE.strCustomerProduct
WHEN MATCHED AND @ysnAllowOverwrite = 1 
THEN
	UPDATE SET
		guiApiUniqueId = SOURCE.guiApiUniqueId,
		intItemId = SOURCE.intItemId,
		intItemLocationId = SOURCE.intItemLocationId,
		intCustomerId = SOURCE.intCustomerId,
		strCustomerProduct = SOURCE.strCustomerProduct,
		strProductDescription = SOURCE.strProductDescription,
		strPickTicketNotes = SOURCE.strPickTicketNotes,
		dtmDateModified = GETUTCDATE()
WHEN NOT MATCHED THEN
	INSERT
	(
		guiApiUniqueId,
		intItemId,
		intItemLocationId,
		intCustomerId,
		strCustomerProduct,
		strProductDescription,
		strPickTicketNotes,
		dtmDateCreated
	)
	VALUES
	(
		guiApiUniqueId,
		intItemId,
		intItemLocationId,
		intCustomerId,
		strCustomerProduct,
		strProductDescription,
		strPickTicketNotes,
		GETUTCDATE()
	);