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
-- 1 - Invalid Item
-- 2 - Invalid Location
-- 3 - Invalid Customer

--Validate Records
INSERT INTO @tblErrorCustomerXref
(
	strItemNo,
	strFieldValue,
	intRowNumber, 
	intErrorType
)
SELECT -- Invalid Item
	strItemNo = FilteredCustomerXref.strItemNo,
	strFieldValue = FilteredCustomerXref.strItemNo,
	intRowNumber = FilteredCustomerXref.intRowNumber,
	intErrorType = 1
FROM
@tblFilteredCustomerXref FilteredCustomerXref
LEFT JOIN
tblICItem Item
ON
FilteredCustomerXref.strItemNo = Item.strItemNo
WHERE
Item.intItemId IS NULL
UNION
SELECT -- Invalid Location
	strItemNo = FilteredCustomerXref.strItemNo,
	strFieldValue = FilteredCustomerXref.strLocationName,
	intRowNumber = FilteredCustomerXref.intRowNumber,
	intErrorType = 2
FROM
@tblFilteredCustomerXref FilteredCustomerXref
LEFT JOIN
vyuICGetItemLocation ItemLocation
ON
FilteredCustomerXref.strLocationName = ItemLocation.strLocationName
AND
FilteredCustomerXref.strItemNo = ItemLocation.strItemNo
WHERE
ItemLocation.intItemId IS NULL
UNION
SELECT -- Invalid Customer
	strItemNo = FilteredCustomerXref.strItemNo,
	strFieldValue = FilteredCustomerXref.strCustomerName,
	intRowNumber = FilteredCustomerXref.intRowNumber,
	intErrorType = 3
FROM
@tblFilteredCustomerXref FilteredCustomerXref
LEFT JOIN
vyuARCustomer Customer
ON
FilteredCustomerXref.strCustomerName = Customer.strName
WHERE
Customer.intEntityId IS NULL

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
		WHEN ErrorCustomerXref.intErrorType IN(1)
		THEN 'Item No'
		WHEN ErrorCustomerXref.intErrorType IN(2)
		THEN 'Location'
		ELSE 'Customer'
	END,
	strValue = ErrorCustomerXref.strFieldValue,
	strLogLevel =  CASE
		WHEN ErrorCustomerXref.intErrorType IN(1,2,3)
		THEN 'Error'
		ELSE 'Warning'
	END,
	strStatus = CASE
		WHEN ErrorCustomerXref.intErrorType IN(1,2,3)
		THEN 'Failed'
		ELSE 'Skipped'
	END,
	intRowNo = ErrorCustomerXref.intRowNumber,
	strMessage = CASE
		WHEN ErrorCustomerXref.intErrorType = 1
		THEN 'Item: ' + ErrorCustomerXref.strFieldValue + ' does not exist.'
		WHEN ErrorCustomerXref.intErrorType = 2
		THEN 'Location: ' + ErrorCustomerXref.strFieldValue + ' does not exist.'
		ELSE 'Customer: ' + ErrorCustomerXref.strFieldValue + ' does not exist.'
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