CREATE PROCEDURE uspApiSchemaTransformItemPricing 
	@guiApiUniqueId UNIQUEIDENTIFIER,
	@guiLogId UNIQUEIDENTIFIER
AS

--Check import settings

DECLARE @ysnAllowOverwrite BIT = 0
DECLARE @ysnVerboseLog BIT = 0

SELECT @ysnAllowOverwrite = ISNULL(CAST(Overwrite AS BIT), 0),
		@ysnVerboseLog = ISNULL(CAST(VerboseLogging AS BIT), 0) 	
FROM (
	SELECT strPropertyName, varPropertyValue
	FROM tblApiSchemaTransformProperty
	WHERE guiApiUniqueId = @guiApiUniqueId
) AS Properties
PIVOT (
	MIN(varPropertyValue)
	FOR strPropertyName IN
	(
		Overwrite,
		VerboseLogging
	)
) AS PivotProperties

--Filter Item Pricing imported

DECLARE @tblFilteredItemPricing TABLE(
	intKey INT NOT NULL,
    guiApiUniqueId UNIQUEIDENTIFIER NOT NULL,
    intRowNumber INT NULL,
	strItemNo NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	strLocation NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	dblAmountPercent NUMERIC(38, 20) NULL,
	dblSalePrice NUMERIC(38, 20) NULL,
	dblMSRPPrice NUMERIC(38, 20) NULL,
	strPricingMethod NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	dblLastCost NUMERIC(38, 20) NULL,
	dblStandardCost NUMERIC(38, 20) NULL,
	dblAverageCost NUMERIC(38, 20) NULL,
	dblDefaultGrossPrice NUMERIC(38, 20) NULL
)
INSERT INTO @tblFilteredItemPricing
(
	intKey,
    guiApiUniqueId,
    intRowNumber,
	strItemNo,
	strLocation,
	dblAmountPercent,
	dblSalePrice,
	dblMSRPPrice,
	strPricingMethod,
	dblLastCost,
	dblStandardCost,
	dblAverageCost,
	dblDefaultGrossPrice
)
SELECT 
	intKey,
    guiApiUniqueId,
    intRowNumber,
	strItemNo,
	strLocation,
	dblAmountPercent,
	dblSalePrice,
	dblMSRPPrice,
	strPricingMethod,
	dblLastCost,
	dblStandardCost,
	dblAverageCost,
	dblDefaultGrossPrice
FROM
tblApiSchemaTransformItemPricing
WHERE guiApiUniqueId = @guiApiUniqueId;

--Create Error Table

DECLARE @tblErrorItemPricing TABLE(
	strItemNo NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strFieldValue NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	intRowNumber INT NULL,
	intErrorType INT
)

-- Error Types
-- 1 - Duplicate Imported Item Pricing
-- 2 - Existing Item Pricing
-- 3 - Location not configured for Item
-- 4 - Invalid Item
-- 5 - Invalid Location

--Validate Records

INSERT INTO @tblErrorItemPricing
(
	strItemNo,
	strFieldValue,
	intRowNumber, 
	intErrorType
)
SELECT -- Duplicate Imported Item Pricing
	strItemNo = DuplicateImportItemPricing.strItemNo,
	strFieldValue = DuplicateImportItemPricing.strLocation,
	intRowNumber = DuplicateImportItemPricing.intRowNumber,
	intErrorType = 1
FROM
(
	SELECT 
		strItemNo,
		strLocation,
		intRowNumber,
		RowNumber = ROW_NUMBER() OVER(PARTITION BY strItemNo, strLocation ORDER BY strItemNo)
	FROM 
		@tblFilteredItemPricing
) AS DuplicateImportItemPricing
WHERE RowNumber > 1
UNION
SELECT -- Existing Item Pricing
	strItemNo = FilteredItemPricing.strItemNo,
	strFieldValue = FilteredItemPricing.strLocation,
	intRowNumber = FilteredItemPricing.intRowNumber,
	intErrorType = 2
FROM
@tblFilteredItemPricing FilteredItemPricing 
INNER JOIN
vyuICGetItemLocation ItemLocation
ON
FilteredItemPricing.strItemNo = ItemLocation.strItemNo
AND
FilteredItemPricing.strLocation = ItemLocation.strLocationName
INNER JOIN
tblICItemPricing ItemPricing
ON
ItemLocation.intItemId = ItemPricing.intItemId
AND
ItemLocation.intItemLocationId = ItemPricing.intItemLocationId
WHERE
@ysnAllowOverwrite = 0
UNION
SELECT -- Location not configured for Item
	strItemNo = FilteredItemPricing.strItemNo,
	strFieldValue = FilteredItemPricing.strLocation,
	intRowNumber = FilteredItemPricing.intRowNumber,
	intErrorType = 3
FROM
@tblFilteredItemPricing FilteredItemPricing 
LEFT JOIN
vyuICGetItemLocation ItemLocation
ON
FilteredItemPricing.strItemNo = ItemLocation.strItemNo
AND
FilteredItemPricing.strLocation = ItemLocation.strLocationName
WHERE
ItemLocation.intItemLocationId IS NULL
UNION
SELECT -- Invalid Item
	strItemNo = FilteredItemPricing.strItemNo,
	strFieldValue = FilteredItemPricing.strItemNo,
	intRowNumber = FilteredItemPricing.intRowNumber,
	intErrorType = 4
FROM
@tblFilteredItemPricing FilteredItemPricing 
LEFT JOIN
tblICItem Item
ON
FilteredItemPricing.strItemNo = Item.strItemNo
WHERE
Item.intItemId IS NULL
UNION
SELECT -- Invalid Location
	strItemNo = FilteredItemPricing.strItemNo,
	strFieldValue = FilteredItemPricing.strLocation,
	intRowNumber = FilteredItemPricing.intRowNumber,
	intErrorType = 5
FROM
@tblFilteredItemPricing FilteredItemPricing 
LEFT JOIN
tblSMCompanyLocation CompanyLocation
ON
FilteredItemPricing.strLocation = CompanyLocation.strLocationName
WHERE
CompanyLocation.intCompanyLocationId IS NULL

IF @ysnVerboseLog = 1
BEGIN
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
			WHEN ErrorItemPricing.intErrorType IN(1,2,3,5)
			THEN 'Location'
			ELSE 'Item No'
		END,
		strValue = ErrorItemPricing.strFieldValue,
		strLogLevel =  CASE
			WHEN ErrorItemPricing.intErrorType IN(1,2)
			THEN 'Warning'
			ELSE 'Error'
		END,
		strStatus = CASE
			WHEN ErrorItemPricing.intErrorType IN(1,2)
			THEN 'Skipped'
			ELSE 'Failed'
		END,
		intRowNo = ErrorItemPricing.intRowNumber,
		strMessage = CASE
			WHEN ErrorItemPricing.intErrorType = 1
			THEN 'Duplicate imported item pricing location: ' + ErrorItemPricing.strFieldValue + ' on item: ' + ErrorItemPricing.strItemNo + '.'
			WHEN ErrorItemPricing.intErrorType = 2
			THEN 'Item pricing location: ' + ErrorItemPricing.strFieldValue + ' on item: ' + ErrorItemPricing.strItemNo + ' already exists and overwrite is not enabled.'
			WHEN ErrorItemPricing.intErrorType = 3
			THEN 'Location: ' + ErrorItemPricing.strFieldValue + ' is not configured on item: ' + ErrorItemPricing.strItemNo + '.'
			WHEN ErrorItemPricing.intErrorType = 4
			THEN 'Item: ' + ErrorItemPricing.strItemNo + ' does not exist.'
			ELSE 'Location: ' + ErrorItemPricing.strFieldValue + ' does not exist.'
		END
	FROM @tblErrorItemPricing ErrorItemPricing
	WHERE ErrorItemPricing.intErrorType IN(1, 2, 3, 4, 5)
END
ELSE
BEGIN
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
			WHEN ErrorCount.intErrorType IN(1,2,3,5)
			THEN 'Location'
			ELSE 'Item No'
		END,
		strValue = '',
		strLogLevel =  CASE
			WHEN ErrorCount.intErrorType IN(1,2)
			THEN 'Warning'
			ELSE 'Error'
		END,
		strStatus = CASE
			WHEN ErrorCount.intErrorType IN(1,2)
			THEN 'Skipped'
			ELSE 'Failed'
		END,
		intRowNo = ErrorCount.intRowNumber,
		strMessage = CASE
			WHEN ErrorCount.intErrorType = 1
			THEN 'There are ' + CAST(ErrorCount.intErrorCount AS NVARCHAR(200)) + ' duplicate item pricing record(s) found.'
			WHEN ErrorCount.intErrorType = 2
			THEN 'There are ' + CAST(ErrorCount.intErrorCount AS NVARCHAR(200)) + ' existing item pricing record(s) and overwrite is not enabled.'
			WHEN ErrorCount.intErrorType = 3
			THEN 'There are ' + CAST(ErrorCount.intErrorCount AS NVARCHAR(200)) + ' record(s) where location is not configured on the selected item.'
			WHEN ErrorCount.intErrorType = 4
			THEN 'There are ' + CAST(ErrorCount.intErrorCount AS NVARCHAR(200)) + ' record(s) where item that does not exist.'
			ELSE 'There are ' + CAST(ErrorCount.intErrorCount AS NVARCHAR(200)) + ' record(s) where location that does not exist.'
		END 
	FROM
	(
		SELECT 
			intRowNumber = MIN(intRowNumber), 
			intErrorType, 
			intErrorCount = COUNT(intErrorType)
		FROM @tblErrorItemPricing 
		GROUP BY intErrorType
	) ErrorCount
END

--Filter Item Pricing to be removed

DELETE 
FilteredItemPricing
FROM 
	@tblFilteredItemPricing FilteredItemPricing
	INNER JOIN @tblErrorItemPricing ErrorItemPricing
		ON FilteredItemPricing.intRowNumber = ErrorItemPricing.intRowNumber
WHERE ErrorItemPricing.intErrorType IN(1, 2, 3, 4, 5)

--Transform and Insert statement

;MERGE INTO tblICItemPricing AS TARGET
USING
(
	SELECT
		guiApiUniqueId = FilteredItemPricing.guiApiUniqueId,
		intItemId = ItemLocation.intItemId,				
		intItemLocationId = ItemLocation.intItemLocationId,
		dblAmountPercent = NULLIF(FilteredItemPricing.dblAmountPercent, 0),
		dblSalePrice = NULLIF(FilteredItemPricing.dblSalePrice, 0),
		dblMSRPPrice = NULLIF(FilteredItemPricing.dblMSRPPrice, 0),
		strPricingMethod = ISNULL(FilteredItemPricing.strPricingMethod, 'None'),
		dblLastCost = NULLIF(FilteredItemPricing.dblLastCost, 0),
		dblStandardCost = NULLIF(FilteredItemPricing.dblStandardCost, 0),
		dblAverageCost = NULLIF(FilteredItemPricing.dblAverageCost, 0),
		dblDefaultGrossPrice = NULLIF(FilteredItemPricing.dblDefaultGrossPrice, 0)
	FROM @tblFilteredItemPricing FilteredItemPricing
	LEFT JOIN
	vyuICGetItemLocation ItemLocation
		ON
		FilteredItemPricing.strItemNo = ItemLocation.strItemNo
		AND
		FilteredItemPricing.strLocation = ItemLocation.strLocationName
	
) AS SOURCE
ON TARGET.intItemId = SOURCE.intItemId AND TARGET.intItemLocationId = SOURCE.intItemLocationId
WHEN MATCHED AND @ysnAllowOverwrite = 1 
THEN
	UPDATE SET
		guiApiUniqueId = SOURCE.guiApiUniqueId,
		intItemId = SOURCE.intItemId,				
		intItemLocationId = SOURCE.intItemLocationId,
		dblAmountPercent = ISNULL(SOURCE.dblAmountPercent, TARGET.dblAmountPercent),
		dblSalePrice = ISNULL(SOURCE.dblSalePrice, TARGET.dblSalePrice),
		dblMSRPPrice = ISNULL(SOURCE.dblMSRPPrice, TARGET.dblMSRPPrice),
		strPricingMethod = ISNULL(SOURCE.strPricingMethod, 'None'),
		dblLastCost = ISNULL(SOURCE.dblLastCost, TARGET.dblLastCost),
		dblStandardCost = ISNULL(SOURCE.dblStandardCost, TARGET.dblStandardCost),
		dblAverageCost = ISNULL(SOURCE.dblAverageCost, TARGET.dblAverageCost),
		dblDefaultGrossPrice = ISNULL(SOURCE.dblDefaultGrossPrice, TARGET.dblDefaultGrossPrice),
		dtmDateModified = GETUTCDATE()
WHEN NOT MATCHED THEN
	INSERT
	(
		guiApiUniqueId,
		intItemId,				
		intItemLocationId,
		dblAmountPercent,
		dblSalePrice,
		dblMSRPPrice,
		strPricingMethod,
		dblLastCost,
		dblStandardCost,
		dblAverageCost,
		dblDefaultGrossPrice,
		dtmDateCreated
	)
	VALUES
	(
		guiApiUniqueId,
		intItemId,				
		intItemLocationId,
		dblAmountPercent,
		dblSalePrice,
		dblMSRPPrice,
		strPricingMethod,
		dblLastCost,
		dblStandardCost,
		dblAverageCost,
		dblDefaultGrossPrice,
		GETUTCDATE()
	);