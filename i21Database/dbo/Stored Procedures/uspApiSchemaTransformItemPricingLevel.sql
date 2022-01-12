CREATE PROCEDURE uspApiSchemaTransformItemPricingLevel 
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

--Filter Item Pricing Level imported

DECLARE @tblFilteredItemPricingLevel TABLE(
	intKey INT NOT NULL,
    guiApiUniqueId UNIQUEIDENTIFIER NOT NULL,
    intRowNumber INT NULL,
	strItemNo NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	strLocation NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	strPriceLevel NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	strUnitMeasure NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	dblMin NUMERIC(38, 20) NULL,
	dblMax NUMERIC(38, 20) NULL,
	strPricingMethod NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	strCurrency NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	dblAmountRate NUMERIC(38, 20) NULL,
	dblUnitPrice NUMERIC(38, 20) NULL,
	strCommissionOn NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	dblCommissionRate NUMERIC(38, 20) NULL,
	dtmEffectiveDate DATETIME NULL
)
INSERT INTO @tblFilteredItemPricingLevel
(
	intKey,
    guiApiUniqueId,
    intRowNumber,
	strItemNo,
	strLocation,
	strPriceLevel,
	strUnitMeasure,
	dblMin,
	dblMax,
	strPricingMethod,
	strCurrency,
	dblAmountRate,
	dblUnitPrice,
	strCommissionOn,
	dblCommissionRate,
	dtmEffectiveDate
)
SELECT 
	intKey,
    guiApiUniqueId,
    intRowNumber,
	strItemNo,
	strLocation,
	strPriceLevel,
	strUnitMeasure,
	dblMin,
	dblMax,
	strPricingMethod,
	strCurrency,
	dblAmountRate,
	dblUnitPrice,
	strCommissionOn,
	dblCommissionRate,
	dtmEffectiveDate
FROM
tblApiSchemaTransformItemPricingLevel
WHERE guiApiUniqueId = @guiApiUniqueId;

--Create Error Table

DECLARE @tblErrorItemPricingLevel TABLE(
	strItemNo NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strFieldValue NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	intRowNumber INT NULL,
	intErrorType INT
)

-- Error Types
-- 1 - Duplicate Imported Item Pricing Level
-- 2 - Existing Item Pricing Level
-- 3 - Location not configured for Item
-- 4 - Price Level not configured for Location
-- 5 - Unit of Measure not configured for Item
-- 6 - Invalid Item
-- 7 - Invalid Location
-- 8 - Invalid Unit of Measure
-- 9 - Invalid Pricing Method
-- 10 - Invalid Currency
-- 11 - Invalid Commission
-- 12 - Price can't be zero

--Validate Records

INSERT INTO @tblErrorItemPricingLevel
(
	strItemNo,
	strFieldValue,
	intRowNumber, 
	intErrorType
)
SELECT -- Duplicate Imported Item Pricing Level
	strItemNo = DuplicateImportItemPricingLevel.strItemNo,
	strFieldValue = DuplicateImportItemPricingLevel.strLocation,
	intRowNumber = DuplicateImportItemPricingLevel.intRowNumber,
	intErrorType = 1
FROM
(
	SELECT 
		strItemNo,
		strLocation,
		intRowNumber,
		strPriceLevel,
		strUnitMeasure,
		dtmEffectiveDate,
		RowNumber = ROW_NUMBER() OVER(PARTITION BY strItemNo, strLocation, strPriceLevel, strUnitMeasure, dtmEffectiveDate ORDER BY strItemNo)
	FROM 
		@tblFilteredItemPricingLevel
) AS DuplicateImportItemPricingLevel
WHERE RowNumber > 1
UNION
SELECT -- Existing Item Pricing Level
	strItemNo = FilteredItemPricingLevel.strItemNo,
	strFieldValue = FilteredItemPricingLevel.strLocation,
	intRowNumber = FilteredItemPricingLevel.intRowNumber,
	intErrorType = 2
FROM
@tblFilteredItemPricingLevel FilteredItemPricingLevel
INNER JOIN
vyuICGetItemLocation ItemLocation
ON
FilteredItemPricingLevel.strItemNo = ItemLocation.strItemNo
AND
FilteredItemPricingLevel.strLocation = ItemLocation.strLocationName
INNER JOIN
vyuICItemUOM ItemUOM
ON
FilteredItemPricingLevel.strItemNo = ItemUOM.strItemNo
AND
FilteredItemPricingLevel.strUnitMeasure = ItemUOM.strUnitMeasure
INNER JOIN
tblICItemPricingLevel ItemPricingLevel
ON
ItemLocation.intItemLocationId = ItemPricingLevel.intItemLocationId
AND
ItemUOM.intItemUOMId = ItemPricingLevel.intItemUnitMeasureId
AND
FilteredItemPricingLevel.strPriceLevel = ItemPricingLevel.strPriceLevel
AND
FilteredItemPricingLevel.dtmEffectiveDate = ItemPricingLevel.dtmEffectiveDate
WHERE
@ysnAllowOverwrite = 0
UNION
SELECT -- Location not configured for Item
	strItemNo = FilteredItemPricingLevel.strItemNo,
	strFieldValue = FilteredItemPricingLevel.strLocation,
	intRowNumber = FilteredItemPricingLevel.intRowNumber,
	intErrorType = 3
FROM
@tblFilteredItemPricingLevel FilteredItemPricingLevel 
LEFT JOIN
vyuICGetItemLocation ItemLocation
ON
FilteredItemPricingLevel.strItemNo = ItemLocation.strItemNo
AND
FilteredItemPricingLevel.strLocation = ItemLocation.strLocationName
WHERE
ItemLocation.intItemLocationId IS NULL
UNION
SELECT -- Price Level not configured for Location
	strItemNo = FilteredItemPricingLevel.strItemNo,
	strFieldValue = FilteredItemPricingLevel.strPriceLevel,
	intRowNumber = FilteredItemPricingLevel.intRowNumber,
	intErrorType = 4
FROM
@tblFilteredItemPricingLevel FilteredItemPricingLevel 
LEFT JOIN
tblSMCompanyLocation CompanyLocation
ON
FilteredItemPricingLevel.strLocation = CompanyLocation.strLocationName
LEFT JOIN
tblSMCompanyLocationPricingLevel PricingLevel
ON
CompanyLocation.intCompanyLocationId = PricingLevel.intCompanyLocationId
AND
FilteredItemPricingLevel.strPriceLevel = PricingLevel.strPricingLevelName
WHERE
PricingLevel.intCompanyLocationPricingLevelId IS NULL
UNION
SELECT -- Unit of Measure not configured for Item
	strItemNo = FilteredItemPricingLevel.strItemNo,
	strFieldValue = FilteredItemPricingLevel.strUnitMeasure,
	intRowNumber = FilteredItemPricingLevel.intRowNumber,
	intErrorType = 5
FROM
@tblFilteredItemPricingLevel FilteredItemPricingLevel 
LEFT JOIN
vyuICItemUOM ItemUOM
ON
FilteredItemPricingLevel.strItemNo = ItemUOM.strItemNo
AND
FilteredItemPricingLevel.strUnitMeasure = ItemUOM.strUnitMeasure
WHERE
ItemUOM.intItemUOMId IS NULL
UNION
SELECT -- Invalid Item
	strItemNo = FilteredItemPricingLevel.strItemNo,
	strFieldValue = FilteredItemPricingLevel.strItemNo,
	intRowNumber = FilteredItemPricingLevel.intRowNumber,
	intErrorType = 6
FROM
@tblFilteredItemPricingLevel FilteredItemPricingLevel 
LEFT JOIN
tblICItem Item
ON
FilteredItemPricingLevel.strItemNo = Item.strItemNo
WHERE
Item.intItemId IS NULL
UNION
SELECT -- Invalid Location
	strItemNo = FilteredItemPricingLevel.strItemNo,
	strFieldValue = FilteredItemPricingLevel.strLocation,
	intRowNumber = FilteredItemPricingLevel.intRowNumber,
	intErrorType = 7
FROM
@tblFilteredItemPricingLevel FilteredItemPricingLevel 
LEFT JOIN
tblSMCompanyLocation CompanyLocation
ON
FilteredItemPricingLevel.strLocation = CompanyLocation.strLocationName
WHERE
CompanyLocation.intCompanyLocationId IS NULL
UNION
SELECT -- Invalid Unit of Measure
	strItemNo = FilteredItemPricingLevel.strItemNo,
	strFieldValue = FilteredItemPricingLevel.strUnitMeasure,
	intRowNumber = FilteredItemPricingLevel.intRowNumber,
	intErrorType = 8
FROM
@tblFilteredItemPricingLevel FilteredItemPricingLevel 
LEFT JOIN
tblICUnitMeasure UnitMeasure
ON
FilteredItemPricingLevel.strUnitMeasure = UnitMeasure.strUnitMeasure
WHERE
UnitMeasure.intUnitMeasureId IS NULL
UNION
SELECT -- Invalid Pricing Method
	strItemNo = FilteredItemPricingLevel.strItemNo,
	strFieldValue = FilteredItemPricingLevel.strPricingMethod,
	intRowNumber = FilteredItemPricingLevel.intRowNumber,
	intErrorType = 9
FROM
@tblFilteredItemPricingLevel FilteredItemPricingLevel 
WHERE
FilteredItemPricingLevel.strPricingMethod NOT IN (
	'None', 
	'Fixed Dollar Amount', 
	'Markup Standard Cost', 
	'Percent of Margin',
	'Discount Retail Price',
	'MSRP Discount',
	'Percent of Margin (MSRP)',
	'Markup Last Cost',
	'Markup Avg Cost'
)
UNION
SELECT -- Invalid Currency
	strItemNo = FilteredItemPricingLevel.strItemNo,
	strFieldValue = FilteredItemPricingLevel.strCurrency,
	intRowNumber = FilteredItemPricingLevel.intRowNumber,
	intErrorType = 10
FROM
@tblFilteredItemPricingLevel FilteredItemPricingLevel
LEFT JOIN tblSMCurrency Currency
ON
FilteredItemPricingLevel.strCurrency = Currency.strCurrency
WHERE
Currency.intCurrencyID IS NULL
AND
FilteredItemPricingLevel.strCurrency IS NOT NULL
UNION
SELECT -- Invalid Commission
	strItemNo = FilteredItemPricingLevel.strItemNo,
	strFieldValue = FilteredItemPricingLevel.strCommissionOn,
	intRowNumber = FilteredItemPricingLevel.intRowNumber,
	intErrorType = 11
FROM
@tblFilteredItemPricingLevel FilteredItemPricingLevel 
WHERE
FilteredItemPricingLevel.strCommissionOn IS NOT NULL
AND
FilteredItemPricingLevel.strCommissionOn NOT IN (
	'Percent', 
	'Units', 
	'Amount', 
	'Gross Profit'
)
UNION
SELECT -- Price can't be zero
	strItemNo = FilteredItemPricingLevel.strItemNo,
	strFieldValue = FilteredItemPricingLevel.strLocation,
	intRowNumber = FilteredItemPricingLevel.intRowNumber,
	intErrorType = 12
FROM
@tblFilteredItemPricingLevel FilteredItemPricingLevel 
WHERE
FilteredItemPricingLevel.dblUnitPrice IS NOT NULL
AND
FilteredItemPricingLevel.dblUnitPrice = 0

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
		WHEN ErrorItemPricingLevel.intErrorType IN (1,2,4)
		THEN 'Price Level'
		WHEN ErrorItemPricingLevel.intErrorType IN (3,7)
		THEN 'Location'
		WHEN ErrorItemPricingLevel.intErrorType IN (5,8)
		THEN 'Unit Measure'
		WHEN ErrorItemPricingLevel.intErrorType = 6
		THEN 'Item No'
		WHEN ErrorItemPricingLevel.intErrorType = 9
		THEN 'Pricing Method'
		WHEN ErrorItemPricingLevel.intErrorType = 10
		THEN 'Currency'
		WHEN ErrorItemPricingLevel.intErrorType = 11
		THEN 'Commission'
		ELSE 'Unit '
	END,
	strValue = CASE  
		WHEN ErrorItemPricingLevel.intErrorType IN(1,2,4)
		THEN ErrorItemPricingLevel.strItemNo
		ELSE ErrorItemPricingLevel.strFieldValue
	END,
	strLogLevel =  CASE
		WHEN ErrorItemPricingLevel.intErrorType IN(1,2)
		THEN 'Warning'
		ELSE 'Error'
	END,
	strStatus = CASE
		WHEN ErrorItemPricingLevel.intErrorType IN(1,2)
		THEN 'Skipped'
		ELSE 'Failed'
	END,
	intRowNo = ErrorItemPricingLevel.intRowNumber,
	strMessage = CASE
		WHEN ErrorItemPricingLevel.intErrorType = 1
		THEN 'Duplicate imported item pricing level on item: ' + ErrorItemPricingLevel.strItemNo + ' at row: ' + CAST(ErrorItemPricingLevel.intRowNumber AS NVARCHAR(10)) + '.' 
		WHEN ErrorItemPricingLevel.intErrorType = 2
		THEN 'Item pricing level on item: ' + ErrorItemPricingLevel.strItemNo + ' at row: ' + CAST(ErrorItemPricingLevel.intRowNumber AS NVARCHAR(10)) +  ' already exists and overwrite is not enabled.'
		WHEN ErrorItemPricingLevel.intErrorType = 3
		THEN 'Location: ' + ErrorItemPricingLevel.strFieldValue + ' is not configured on item: ' + ErrorItemPricingLevel.strItemNo + '.'
		WHEN ErrorItemPricingLevel.intErrorType = 4
		THEN 'Price Level: ' + ErrorItemPricingLevel.strFieldValue + ' is not configured for its location on item: ' + ErrorItemPricingLevel.strItemNo + '.'
		WHEN ErrorItemPricingLevel.intErrorType = 5
		THEN 'Unit of measure: ' + ErrorItemPricingLevel.strFieldValue + ' is not configured on item: ' + ErrorItemPricingLevel.strItemNo + '.'
		WHEN ErrorItemPricingLevel.intErrorType = 6
		THEN 'Item: ' + ErrorItemPricingLevel.strItemNo + ' does not exist.'
		WHEN ErrorItemPricingLevel.intErrorType = 7
		THEN 'Location: ' + ErrorItemPricingLevel.strFieldValue + ' does not exist.'
		WHEN ErrorItemPricingLevel.intErrorType = 8
		THEN 'Unit of measure: ' + ErrorItemPricingLevel.strFieldValue + ' does not exist.'
		WHEN ErrorItemPricingLevel.intErrorType = 9
		THEN 'Pricing method: ' + ErrorItemPricingLevel.strFieldValue + ' does not exist.'
		WHEN ErrorItemPricingLevel.intErrorType = 10
		THEN 'Currency: ' + ErrorItemPricingLevel.strFieldValue + ' does not exist.'
		WHEN ErrorItemPricingLevel.intErrorType = 11
		THEN 'Commission: ' + ErrorItemPricingLevel.strFieldValue + ' does not exist.'
		ELSE 'Price for location: ' + ErrorItemPricingLevel.strFieldValue + ' on item: ' + ErrorItemPricingLevel.strItemNo + ' cannot be equal to zero.'
	END
FROM @tblErrorItemPricingLevel ErrorItemPricingLevel
WHERE ErrorItemPricingLevel.intErrorType BETWEEN 1 AND 12

--Filter Item Pricing Level to be removed

DELETE 
FilteredItemPricingLevel
FROM 
	@tblFilteredItemPricingLevel FilteredItemPricingLevel
	INNER JOIN @tblErrorItemPricingLevel ErrorItemPricingLevel
		ON FilteredItemPricingLevel.intRowNumber = ErrorItemPricingLevel.intRowNumber
WHERE ErrorItemPricingLevel.intErrorType BETWEEN 1 AND 12

--Transform and Insert statement

;MERGE INTO tblICItemPricingLevel AS TARGET
USING
(
	SELECT
		guiApiUniqueId = FilteredItemPricingLevel.guiApiUniqueId,
		intItemId = ItemLocation.intItemId,				
		intItemLocationId = ItemLocation.intItemLocationId,
		intCompanyLocationPricingLevelId = PricingLevel.intCompanyLocationPricingLevelId,
		strPriceLevel = PricingLevel.strPricingLevelName,
		intItemUnitMeasureId = ItemUOM.intItemUOMId,
		dblUnit = ItemUOM.dblUnitQty,
		dtmEffectiveDate = FilteredItemPricingLevel.dtmEffectiveDate,
		dblMin = FilteredItemPricingLevel.dblMin,
		dblMax = FilteredItemPricingLevel.dblMax,
		strPricingMethod = ISNULL(FilteredItemPricingLevel.strPricingMethod, 'None'),
		dblAmountRate = FilteredItemPricingLevel.dblAmountRate,
		dblUnitPrice = FilteredItemPricingLevel.dblUnitPrice,
		strCommissionOn	= FilteredItemPricingLevel.strCommissionOn,
		dblCommissionRate = FilteredItemPricingLevel.dblCommissionRate,
		intCurrencyId = ISNULL(Currency.intCurrencyID, DefaultCurrency.intCurrencyID)
	FROM @tblFilteredItemPricingLevel FilteredItemPricingLevel
	LEFT JOIN
	vyuICGetItemLocation ItemLocation
		ON
		FilteredItemPricingLevel.strItemNo = ItemLocation.strItemNo
		AND
		FilteredItemPricingLevel.strLocation = ItemLocation.strLocationName
	LEFT JOIN
	tblSMCompanyLocation CompanyLocation
		ON
		FilteredItemPricingLevel.strLocation = CompanyLocation.strLocationName
	LEFT JOIN
	tblSMCompanyLocationPricingLevel PricingLevel
		ON
		FilteredItemPricingLevel.strPriceLevel = PricingLevel.strPricingLevelName
		AND
		CompanyLocation.intCompanyLocationId = PricingLevel.intCompanyLocationId
	LEFT JOIN
	vyuICItemUOM ItemUOM
		ON
		FilteredItemPricingLevel.strItemNo = ItemUOM.strItemNo
		AND
		FilteredItemPricingLevel.strUnitMeasure = ItemUOM.strUnitMeasure
	LEFT JOIN 
	tblSMCurrency Currency
		ON
		FilteredItemPricingLevel.strCurrency = Currency.strCurrency
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
TARGET.strPriceLevel = SOURCE.strPriceLevel
AND 
TARGET.intItemUnitMeasureId = SOURCE.intItemUnitMeasureId
AND 
TARGET.dtmEffectiveDate = SOURCE.dtmEffectiveDate
WHEN MATCHED AND @ysnAllowOverwrite = 1 
THEN
	UPDATE SET
		guiApiUniqueId = SOURCE.guiApiUniqueId,
		intItemId = SOURCE.intItemId,				
		intItemLocationId = SOURCE.intItemLocationId,
		intCompanyLocationPricingLevelId = SOURCE.intCompanyLocationPricingLevelId,
		strPriceLevel = SOURCE.strPriceLevel,
		intItemUnitMeasureId = SOURCE.intItemUnitMeasureId,
		dblUnit = SOURCE.dblUnit,
		dtmEffectiveDate = SOURCE.dtmEffectiveDate,
		dblMin = ISNULL(SOURCE.dblMin, TARGET.dblMin),
		dblMax = ISNULL(SOURCE.dblMax, TARGET.dblMax),
		strPricingMethod = SOURCE.strPricingMethod,
		dblAmountRate = ISNULL(SOURCE.dblAmountRate, TARGET.dblAmountRate),
		dblUnitPrice = ISNULL(SOURCE.dblUnitPrice, TARGET.dblUnitPrice),
		strCommissionOn	= ISNULL(SOURCE.strCommissionOn, TARGET.strCommissionOn),
		dblCommissionRate = ISNULL(SOURCE.dblCommissionRate, TARGET.dblCommissionRate),
		intCurrencyId = SOURCE.intCurrencyId,
		dtmDateModified = GETUTCDATE()
WHEN NOT MATCHED THEN
	INSERT
	(
		guiApiUniqueId,
		intItemId,	
		intItemLocationId,
		intCompanyLocationPricingLevelId,
		strPriceLevel,
		intItemUnitMeasureId,
		dblUnit,
		dtmEffectiveDate,
		dblMin,
		dblMax,
		strPricingMethod,
		dblAmountRate,
		dblUnitPrice,
		strCommissionOn,
		dblCommissionRate,
		intCurrencyId,
		dtmDateCreated
	)
	VALUES
	(
		guiApiUniqueId,
		intItemId,	
		intItemLocationId,
		intCompanyLocationPricingLevelId,
		strPriceLevel,
		intItemUnitMeasureId,
		dblUnit,
		dtmEffectiveDate,
		dblMin,
		dblMax,
		strPricingMethod,
		dblAmountRate,
		dblUnitPrice,
		strCommissionOn,
		dblCommissionRate,
		intCurrencyId,
		GETUTCDATE()
	);