CREATE PROCEDURE uspApiSchemaTransformItemSpecialPricing 
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

--Filter Item Special Pricing imported

DECLARE @tblFilteredItemSpecialPricing TABLE(
	intKey INT NOT NULL,
    guiApiUniqueId UNIQUEIDENTIFIER NOT NULL,
    intRowNumber INT NULL,
	strItemNo NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	strLocation NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	strPromotionType NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	strUnitMeasure NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	dblUnit NUMERIC(38, 20) NULL,
	strDiscountBy NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	dblDiscount NUMERIC(38, 20) NULL,
	strCurrency NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	dblUnitAfterDiscount NUMERIC(38, 20) NULL,
	dtmBeginDate DATETIME NULL,
	dtmEndDate DATETIME NULL,
	dblDiscountThruQty NUMERIC(38, 20) NULL,
	dblDiscountThruAmount NUMERIC(38, 20) NULL,
	dblAccumulatedQty NUMERIC(38, 20) NULL,
	dblAccumulatedAmount NUMERIC(38, 20) NULL
)
INSERT INTO @tblFilteredItemSpecialPricing
(
	intKey,
    guiApiUniqueId,
    intRowNumber,
	strItemNo,
	strLocation,
	strPromotionType,
	strUnitMeasure,
	dblUnit,
	strDiscountBy,
	dblDiscount,
	strCurrency,
	dblUnitAfterDiscount,
	dtmBeginDate,
	dtmEndDate,
	dblDiscountThruQty,
	dblDiscountThruAmount,
	dblAccumulatedQty,
	dblAccumulatedAmount
)
SELECT 
	intKey,
    guiApiUniqueId,
    intRowNumber,
	strItemNo,
	strLocation,
	strPromotionType,
	strUnitMeasure,
	dblUnit,
	strDiscountBy,
	dblDiscount,
	strCurrency,
	dblUnitAfterDiscount,
	dtmBeginDate,
	dtmEndDate,
	dblDiscountThruQty,
	dblDiscountThruAmount,
	dblAccumulatedQty,
	dblAccumulatedAmount
FROM
tblApiSchemaTransformItemSpecialPricing
WHERE guiApiUniqueId = @guiApiUniqueId;

--Create Error Table

DECLARE @tblErrorItemSpecialPricing TABLE(
	strItemNo NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strFieldValue NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	intRowNumber INT NULL,
	intErrorType INT
)

-- Error Types
-- 1 - Duplicate or overlapping Imported Item Special Pricing
-- 2 - Overlapping Item Special Pricing effectivity duration
-- 3 - Location not configured for Item
-- 4 - Unit of Measure not configured for Item
-- 5 - Invalid Item
-- 6 - Invalid Location
-- 7 - Invalid Unit of Measure
-- 8 - Invalid Promotion Type
-- 9 - Invalid Discount By
-- 10 - Invalid Currency

--Validate Records

INSERT INTO @tblErrorItemSpecialPricing
(
	strItemNo,
	strFieldValue,
	intRowNumber, 
	intErrorType
)
SELECT -- Duplicate or overlapping Imported Item Special Pricing
	strItemNo = DuplicateItemSpecialPricing.strItemNo,
	strFieldValue = DuplicateItemSpecialPricing.strLocation,
	intRowNumber = DuplicateItemSpecialPricing.intRowNumber,
	intErrorType = 1
FROM
(
	SELECT 
		strItemNo = MIN(FilteredItemSpecialPricing.strItemNo),
		strLocation = MIN(FilteredItemSpecialPricing.strLocation),
		FilteredItemSpecialPricing.intRowNumber,
		RowNumber = ROW_NUMBER() OVER(PARTITION BY 
			MIN(FilteredItemSpecialPricing.strItemNo), 
			MIN(FilteredItemSpecialPricing.strLocation), 
			MIN(FilteredItemSpecialPricing.strUnitMeasure) ORDER BY FilteredItemSpecialPricing.intRowNumber)
	FROM 
		@tblFilteredItemSpecialPricing FilteredItemSpecialPricing
	INNER JOIN
		@tblFilteredItemSpecialPricing ComparedItemSpecialPricing
		ON
		FilteredItemSpecialPricing.strItemNo = ComparedItemSpecialPricing.strItemNo
		AND
		FilteredItemSpecialPricing.strLocation = ComparedItemSpecialPricing.strLocation
		AND
		FilteredItemSpecialPricing.strUnitMeasure = ComparedItemSpecialPricing.strUnitMeasure
		AND
		FilteredItemSpecialPricing.dtmBeginDate < ComparedItemSpecialPricing.dtmEndDate
		AND
		FilteredItemSpecialPricing.dtmEndDate > ComparedItemSpecialPricing.dtmBeginDate
	GROUP BY FilteredItemSpecialPricing.intRowNumber
) AS DuplicateItemSpecialPricing
WHERE DuplicateItemSpecialPricing.RowNumber > 1
UNION
SELECT -- Overlapping Item Special Pricing effectivity duration
	strItemNo = FilteredItemSpecialPricing.strItemNo,
	strFieldValue = FilteredItemSpecialPricing.strLocation,
	intRowNumber = FilteredItemSpecialPricing.intRowNumber,
	intErrorType = 2
FROM
@tblFilteredItemSpecialPricing FilteredItemSpecialPricing
INNER JOIN
vyuICGetItemLocation ItemLocation
ON
FilteredItemSpecialPricing.strItemNo = ItemLocation.strItemNo
AND
FilteredItemSpecialPricing.strLocation = ItemLocation.strLocationName
INNER JOIN
vyuICItemUOM ItemUOM
ON
FilteredItemSpecialPricing.strItemNo = ItemUOM.strItemNo
AND
FilteredItemSpecialPricing.strUnitMeasure = ItemUOM.strUnitMeasure
INNER JOIN
tblICItemSpecialPricing ItemSpecialPricing
ON
ItemLocation.intItemLocationId = ItemSpecialPricing.intItemLocationId
AND
ItemUOM.intItemUOMId = ItemSpecialPricing.intItemUnitMeasureId
WHERE
(
	FilteredItemSpecialPricing.dtmBeginDate < ItemSpecialPricing.dtmEndDate
	AND
	FilteredItemSpecialPricing.dtmEndDate > ItemSpecialPricing.dtmBeginDate
	AND
	(
		FilteredItemSpecialPricing.dtmBeginDate <> ItemSpecialPricing.dtmBeginDate
		OR
		FilteredItemSpecialPricing.dtmEndDate <> ItemSpecialPricing.dtmEndDate
	)
)
OR
(
	FilteredItemSpecialPricing.dtmBeginDate = ItemSpecialPricing.dtmBeginDate
	AND
	FilteredItemSpecialPricing.dtmEndDate = ItemSpecialPricing.dtmEndDate
	AND
	@ysnAllowOverwrite = 0
)
UNION
SELECT -- Location not configured for Item
	strItemNo = FilteredItemSpecialPricing.strItemNo,
	strFieldValue = FilteredItemSpecialPricing.strLocation,
	intRowNumber = FilteredItemSpecialPricing.intRowNumber,
	intErrorType = 3
FROM
@tblFilteredItemSpecialPricing FilteredItemSpecialPricing
LEFT JOIN
vyuICGetItemLocation ItemLocation
ON
FilteredItemSpecialPricing.strItemNo = ItemLocation.strItemNo
AND
FilteredItemSpecialPricing.strLocation = ItemLocation.strLocationName
WHERE
ItemLocation.intItemLocationId IS NULL
UNION
SELECT -- Unit of Measure not configured for Item
	strItemNo = FilteredItemSpecialPricing.strItemNo,
	strFieldValue = FilteredItemSpecialPricing.strUnitMeasure,
	intRowNumber = FilteredItemSpecialPricing.intRowNumber,
	intErrorType = 4
FROM
@tblFilteredItemSpecialPricing FilteredItemSpecialPricing 
LEFT JOIN
vyuICItemUOM ItemUOM
ON
FilteredItemSpecialPricing.strItemNo = ItemUOM.strItemNo
AND
FilteredItemSpecialPricing.strUnitMeasure = ItemUOM.strUnitMeasure
WHERE
ItemUOM.intItemUOMId IS NULL
UNION
SELECT -- Invalid Item
	strItemNo = FilteredItemSpecialPricing.strItemNo,
	strFieldValue = FilteredItemSpecialPricing.strItemNo,
	intRowNumber = FilteredItemSpecialPricing.intRowNumber,
	intErrorType = 5
FROM
@tblFilteredItemSpecialPricing FilteredItemSpecialPricing 
LEFT JOIN
tblICItem Item
ON
FilteredItemSpecialPricing.strItemNo = Item.strItemNo
WHERE
Item.intItemId IS NULL
UNION
SELECT -- Invalid Location
	strItemNo = FilteredItemSpecialPricing.strItemNo,
	strFieldValue = FilteredItemSpecialPricing.strLocation,
	intRowNumber = FilteredItemSpecialPricing.intRowNumber,
	intErrorType = 6
FROM
@tblFilteredItemSpecialPricing FilteredItemSpecialPricing 
LEFT JOIN
tblSMCompanyLocation CompanyLocation
ON
FilteredItemSpecialPricing.strLocation = CompanyLocation.strLocationName
WHERE
CompanyLocation.intCompanyLocationId IS NULL
UNION
SELECT -- Invalid Unit of Measure
	strItemNo = FilteredItemSpecialPricing.strItemNo,
	strFieldValue = FilteredItemSpecialPricing.strUnitMeasure,
	intRowNumber = FilteredItemSpecialPricing.intRowNumber,
	intErrorType = 7
FROM
@tblFilteredItemSpecialPricing FilteredItemSpecialPricing 
LEFT JOIN
tblICUnitMeasure UnitMeasure
ON
FilteredItemSpecialPricing.strUnitMeasure = UnitMeasure.strUnitMeasure
WHERE
UnitMeasure.intUnitMeasureId IS NULL
UNION
SELECT -- Invalid Promotion Type
	strItemNo = FilteredItemSpecialPricing.strItemNo,
	strFieldValue = FilteredItemSpecialPricing.strPromotionType,
	intRowNumber = FilteredItemSpecialPricing.intRowNumber,
	intErrorType = 8
FROM
@tblFilteredItemSpecialPricing FilteredItemSpecialPricing 
WHERE
FilteredItemSpecialPricing.strPromotionType NOT IN (
	'Rebate', 
	'Discount', 
	'Vendor Discount', 
	'Terms Discount',
	'Terms Discount Exempt'
)
UNION
SELECT -- Invalid Discount By
	strItemNo = FilteredItemSpecialPricing.strItemNo,
	strFieldValue = FilteredItemSpecialPricing.strDiscountBy,
	intRowNumber = FilteredItemSpecialPricing.intRowNumber,
	intErrorType = 9
FROM
@tblFilteredItemSpecialPricing FilteredItemSpecialPricing 
WHERE
FilteredItemSpecialPricing.strDiscountBy NOT IN (
	'Percent', 
	'Amount'
)
UNION
SELECT -- Invalid Currency
	strItemNo = FilteredItemSpecialPricing.strItemNo,
	strFieldValue = FilteredItemSpecialPricing.strCurrency,
	intRowNumber = FilteredItemSpecialPricing.intRowNumber,
	intErrorType = 10
FROM
@tblFilteredItemSpecialPricing FilteredItemSpecialPricing 
LEFT JOIN tblSMCurrency Currency
ON
FilteredItemSpecialPricing.strCurrency = Currency.strCurrency
WHERE
Currency.intCurrencyID IS NULL
AND
FilteredItemSpecialPricing.strCurrency IS NOT NULL

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
		WHEN ErrorItemSpecialPricing.intErrorType IN (1,2,5)
		THEN 'Item No'
		WHEN ErrorItemSpecialPricing.intErrorType IN (3,6)
		THEN 'Location'
		WHEN ErrorItemSpecialPricing.intErrorType IN (4,7)
		THEN 'Unit Measure'
		WHEN ErrorItemSpecialPricing.intErrorType = 8
		THEN 'Promotion Type'
		WHEN ErrorItemSpecialPricing.intErrorType = 9
		THEN 'Discount By'
		ELSE 'Currency'
	END,
	strValue = CASE  
		WHEN ErrorItemSpecialPricing.intErrorType IN(1,2,5)
		THEN ErrorItemSpecialPricing.strItemNo
		ELSE ErrorItemSpecialPricing.strFieldValue
	END,
	strLogLevel =  CASE
		WHEN ErrorItemSpecialPricing.intErrorType IN(1,2)
		THEN 'Warning'
		ELSE 'Error'
	END,
	strStatus = CASE
		WHEN ErrorItemSpecialPricing.intErrorType IN(1,2)
		THEN 'Skipped'
		ELSE 'Failed'
	END,
	intRowNo = ErrorItemSpecialPricing.intRowNumber,
	strMessage = CASE
		WHEN ErrorItemSpecialPricing.intErrorType = 1
		THEN 'Duplicate or overlapping effectivitiy date of imported item special pricing on item: ' + ErrorItemSpecialPricing.strItemNo + ' at row: ' + CAST(ErrorItemSpecialPricing.intRowNumber AS NVARCHAR(10)) + '.' 
		WHEN ErrorItemSpecialPricing.intErrorType = 2
		THEN 'Item special pricing on item: ' + ErrorItemSpecialPricing.strItemNo + ' at row: ' + CAST(ErrorItemSpecialPricing.intRowNumber AS NVARCHAR(10)) +  ' overlaps effectivity date or already exists and overwrite is not enabled.'
		WHEN ErrorItemSpecialPricing.intErrorType = 3
		THEN 'Location: ' + ErrorItemSpecialPricing.strFieldValue + ' is not configured on item: ' + ErrorItemSpecialPricing.strItemNo + '.'
		WHEN ErrorItemSpecialPricing.intErrorType = 4
		THEN 'Unit of measure: ' + ErrorItemSpecialPricing.strFieldValue + ' is not configured on item: ' + ErrorItemSpecialPricing.strItemNo + '.'
		WHEN ErrorItemSpecialPricing.intErrorType = 5
		THEN 'Item: ' + ErrorItemSpecialPricing.strItemNo + ' does not exist.'
		WHEN ErrorItemSpecialPricing.intErrorType = 6
		THEN 'Location: ' + ErrorItemSpecialPricing.strFieldValue + ' does not exist.'
		WHEN ErrorItemSpecialPricing.intErrorType = 7
		THEN 'Unit of measure: ' + ErrorItemSpecialPricing.strFieldValue + ' does not exist.'
		WHEN ErrorItemSpecialPricing.intErrorType = 8
		THEN 'Promotion type: ' + ErrorItemSpecialPricing.strFieldValue + ' does not exist.'
		WHEN ErrorItemSpecialPricing.intErrorType = 9
		THEN 'Discount By: ' + ErrorItemSpecialPricing.strFieldValue + ' does not exist.'
		ELSE 'Currency: ' + ErrorItemSpecialPricing.strFieldValue + ' does not exist.'
	END
FROM @tblErrorItemSpecialPricing ErrorItemSpecialPricing
WHERE ErrorItemSpecialPricing.intErrorType BETWEEN 1 AND 10

--Filter Item Special Pricing to be removed

DELETE 
FilteredItemSpecialPricing
FROM 
	@tblFilteredItemSpecialPricing FilteredItemSpecialPricing
	INNER JOIN @tblErrorItemSpecialPricing ErrorItemSpecialPricing
		ON FilteredItemSpecialPricing.intRowNumber = ErrorItemSpecialPricing.intRowNumber
WHERE ErrorItemSpecialPricing.intErrorType BETWEEN 1 AND 10

--Transform and Insert statement

;MERGE INTO tblICItemSpecialPricing AS TARGET
USING
(
	SELECT
		guiApiUniqueId = FilteredItemSpecialPricing.guiApiUniqueId,
		intItemId = ItemUOM.intItemId,
		intItemLocationId = ItemLocation.intItemLocationId,
		strPromotionType = FilteredItemSpecialPricing.strPromotionType,
		dtmBeginDate = FilteredItemSpecialPricing.dtmBeginDate,
		dtmEndDate = FilteredItemSpecialPricing.dtmEndDate,
		intItemUnitMeasureId = ItemUOM.intItemUOMId,
		dblUnit = FilteredItemSpecialPricing.dblUnit,
		strDiscountBy = FilteredItemSpecialPricing.strDiscountBy,
		dblDiscount = FilteredItemSpecialPricing.dblDiscount,
		dblUnitAfterDiscount = FilteredItemSpecialPricing.dblUnitAfterDiscount,
		dblDiscountThruQty = FilteredItemSpecialPricing.dblDiscountThruQty,
		dblDiscountThruAmount = FilteredItemSpecialPricing.dblDiscountThruAmount,
		dblAccumulatedQty = FilteredItemSpecialPricing.dblAccumulatedQty,
		dblAccumulatedAmount = FilteredItemSpecialPricing.dblAccumulatedAmount,
		intCurrencyId = Currency.intCurrencyID
	FROM @tblFilteredItemSpecialPricing FilteredItemSpecialPricing
	LEFT JOIN
	vyuICGetItemLocation ItemLocation
		ON
		FilteredItemSpecialPricing.strItemNo = ItemLocation.strItemNo
		AND
		FilteredItemSpecialPricing.strLocation = ItemLocation.strLocationName
	LEFT JOIN
	vyuICItemUOM ItemUOM
		ON
		FilteredItemSpecialPricing.strItemNo = ItemUOM.strItemNo
		AND
		FilteredItemSpecialPricing.strUnitMeasure = ItemUOM.strUnitMeasure
	LEFT JOIN 
	tblSMCurrency Currency
		ON
		FilteredItemSpecialPricing.strCurrency = Currency.strCurrency
	OUTER APPLY
	(
		SELECT TOP 1 intDefaultCurrencyId AS intCurrencyID FROM tblSMCompanyPreference
	) DefaultCurrency
) AS SOURCE
ON 
TARGET.intItemId = SOURCE.intItemId 
AND 
TARGET.intItemLocationId = SOURCE.intItemLocationId
AND 
TARGET.intItemUnitMeasureId = SOURCE.intItemUnitMeasureId
AND 
TARGET.dtmBeginDate = SOURCE.dtmBeginDate
AND 
TARGET.dtmEndDate = SOURCE.dtmEndDate
WHEN MATCHED AND @ysnAllowOverwrite = 1 
THEN
	UPDATE SET
		guiApiUniqueId = SOURCE.guiApiUniqueId,
		intItemId = SOURCE.intItemId,
		intItemLocationId = SOURCE.intItemLocationId,
		strPromotionType = SOURCE.strPromotionType,
		dtmBeginDate = SOURCE.dtmBeginDate,
		dtmEndDate = SOURCE.dtmEndDate,
		intItemUnitMeasureId = SOURCE.intItemUnitMeasureId,
		dblUnit = COALESCE(SOURCE.dblUnit, TARGET.dblUnit, 0),
		strDiscountBy = SOURCE.strDiscountBy,
		dblDiscount = COALESCE(SOURCE.dblDiscount, TARGET.dblDiscount, 0),
		dblUnitAfterDiscount = COALESCE(SOURCE.dblUnitAfterDiscount, TARGET.dblUnitAfterDiscount, 0),
		dblDiscountThruQty = COALESCE(SOURCE.dblDiscountThruQty, TARGET.dblDiscountThruQty, 0),
		dblDiscountThruAmount = COALESCE(SOURCE.dblDiscountThruAmount, TARGET.dblDiscountThruAmount, 0),
		dblAccumulatedQty = COALESCE(SOURCE.dblAccumulatedQty, TARGET.dblAccumulatedQty, 0),
		dblAccumulatedAmount = COALESCE(SOURCE.dblAccumulatedAmount, TARGET.dblAccumulatedAmount, 0),
		intCurrencyId = SOURCE.intCurrencyId,
		dtmDateModified = GETUTCDATE()
WHEN NOT MATCHED THEN
	INSERT
	(
		guiApiUniqueId,
		intItemId,
		intItemLocationId,
		strPromotionType,
		dtmBeginDate,
		dtmEndDate,
		intItemUnitMeasureId,
		dblUnit,
		strDiscountBy,
		dblDiscount,
		dblUnitAfterDiscount,
		dblDiscountThruQty,
		dblDiscountThruAmount,
		dblAccumulatedQty,
		dblAccumulatedAmount,
		intCurrencyId,
		dtmDateCreated
	)
	VALUES
	(
		guiApiUniqueId,
		intItemId,
		intItemLocationId,
		strPromotionType,
		dtmBeginDate,
		dtmEndDate,
		intItemUnitMeasureId,
		dblUnit,
		strDiscountBy,
		dblDiscount,
		dblUnitAfterDiscount,
		dblDiscountThruQty,
		dblDiscountThruAmount,
		dblAccumulatedQty,
		dblAccumulatedAmount,
		intCurrencyId,
		GETUTCDATE()
	);