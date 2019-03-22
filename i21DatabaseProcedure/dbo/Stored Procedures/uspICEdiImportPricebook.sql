CREATE PROCEDURE [dbo].[uspICEdiImportPricebook] @intUserId INT, @intVendorId INT, @Locations UdtCompanyLocations READONLY, @ErrorCount INT OUTPUT, @TotalRows INT OUTPUT
AS

DECLARE @LogId INT
SELECT @LogId = intImportLogId FROM tblICImportLog WHERE strUniqueId = (SELECT TOP 1 strUniqueId FROM tblICEdiPricebook)

IF(@LogId IS NULL)
BEGIN
	INSERT INTO tblICImportLog(strDescription, strType, strFileType, strFileName, dtmDateImported, intUserEntityId, intConcurrencyId)
	SELECT 'Import Pricebook successful', 'EDI', 'txt', 'Pricebook.txt', GETDATE(), @intUserId, 1
	SET @LogId = @@IDENTITY
END

--Update Item
UPDATE i
SET	  i.intBrandId = ISNULL(b.intBrandId, i.intBrandId)
	, i.strDescription = ISNULL(NULLIF(p.strSellingUpcLongDescription, ''), i.strDescription)
	, i.strShortName = ISNULL(ISNULL(NULLIF(p.strSellingUpcShortDescription, ''), SUBSTRING(p.strSellingUpcLongDescription, 1, 15)), i.strShortName)
	, i.strItemNo = p.strSellingUpcNumber
FROM tblICEdiPricebook p
	INNER JOIN tblICItemUOM u ON ISNULL(NULLIF(u.strLongUPCCode, ''), u.strUpcCode) = p.strSellingUpcNumber
	INNER JOIN tblICItem i ON i.intItemId = u.intItemId
	LEFT OUTER JOIN tblICBrand b ON b.strBrandName = p.strManufacturersBrandName

-- Log UPCs that don't have corresponding items
INSERT INTO tblICImportLogDetail(intImportLogId, strType, intRecordNo, strField, strValue, strMessage, strStatus, strAction, intConcurrencyId)
SELECT @LogId, 'Error', p.intRecordNumber, 'SellingUpcNumber', p.strSellingUpcNumber, 'Cannot find the item that matches the UPC: ' + p.strSellingUpcNumber, 'Skipped', 'Record not imported.', 1
FROM tblICEdiPricebook p
	LEFT OUTER JOIN tblICItemUOM u ON ISNULL(NULLIF(u.strLongUPCCode, ''), u.strUpcCode) = p.strSellingUpcNumber
	LEFT JOIN tblICItem i ON i.intItemId = u.intItemId
WHERE i.intItemId IS NULL
	
-- Update UOM
UPDATE u
SET u.intUnitMeasureId = ISNULL(ISNULL(m.intUnitMeasureId, s.intUnitMeasureId), u.intUnitMeasureId)
FROM tblICEdiPricebook p
	INNER JOIN tblICItemUOM u ON ISNULL(NULLIF(u.strLongUPCCode, ''), u.strUpcCode) = p.strSellingUpcNumber
	INNER JOIN tblICItem i ON i.intItemId = u.intItemId
	LEFT OUTER JOIN tblICUnitMeasure m ON m.strUnitMeasure = NULLIF(p.strItemUnitOfMeasure, '')
	LEFT OUTER JOIN tblICUnitMeasure s ON s.strSymbol = NULLIF(p.strItemUnitOfMeasure, '')
	
-- Update Item Location
UPDATE l
SET   l.intClassId = ISNULL(ISNULL(sc.intSubcategoryId, catLoc.intClassId), l.intClassId)
	, l.intFamilyId = ISNULL(ISNULL(sf.intSubcategoryId, catLoc.intFamilyId), l.intFamilyId)
	, l.ysnDepositRequired = ISNULL(CASE p.strDepositRequired WHEN 'Y' THEN 1 WHEN 'N' THEN 0 ELSE NULL END, l.ysnDepositRequired)
	, l.ysnPromotionalItem = ISNULL(CASE p.strPromotionalItem WHEN 'Y' THEN 1 WHEN 'N' THEN 0 ELSE NULL END, l.ysnPromotionalItem)
	, l.ysnPrePriced = ISNULL(ISNULL(CASE p.strPrePriced WHEN 'Y' THEN 1 WHEN 'N' THEN 0 ELSE NULL END, catLoc.ysnPrePriced), l.ysnPrePriced)
	, l.dblSuggestedQty = ISNULL(NULLIF(p.strSuggestedOrderQuantity, ''), l.dblSuggestedQty)
	, l.dblMinOrder = ISNULL(NULLIF(p.strMinimumOrderQuantity, ''), l.dblMinOrder)
	, l.intBottleDepositNo = ISNULL(NULLIF(p.strBottleDepositNumber, ''), l.intBottleDepositNo)
FROM tblICEdiPricebook p
	INNER JOIN tblICItemUOM u ON ISNULL(NULLIF(u.strLongUPCCode, ''), u.strUpcCode) = p.strSellingUpcNumber
	INNER JOIN tblICItem i ON i.intItemId = u.intItemId
	INNER JOIN tblICItemLocation l ON l.intItemId = i.intItemId
	LEFT OUTER JOIN tblSTSubcategory sc ON sc.strSubcategoryId = NULLIF(p.strProductClass, '')
		AND sc.strSubcategoryType = 'C'
	LEFT OUTER JOIN tblSTSubcategory sf on sf.strSubcategoryId = NULLIF(p.strProductFamily, '')
		AND sf.strSubcategoryType = 'F'
	LEFT OUTER JOIN tblICCategory cat ON cat.intCategoryId = i.intCategoryId
	LEFT OUTER JOIN tblICCategoryLocation catLoc ON catLoc.intCategoryId = cat.intCategoryId
		AND catLoc.intLocationId = l.intLocationId

-- Update Standard Pricing
UPDATE price
SET   price.dblSalePrice = CAST(CASE WHEN ISNUMERIC(p.strRetailPrice) = 1 THEN p.strRetailPrice ELSE price.dblSalePrice END AS NUMERIC(38, 20))
	, price.dblStandardCost = ISNULL(CASE WHEN ISNUMERIC(p.strCaseCost) = 1 THEN CAST(p.strCaseCost AS NUMERIC(38, 20)) ELSE NULL END 
		/ CASE WHEN ISNUMERIC(p.strCaseBoxSizeQuantityPerCaseBox) = 1 THEN CAST(p.strCaseBoxSizeQuantityPerCaseBox AS NUMERIC(38, 20)) ELSE NULL END, price.dblStandardCost)
	, price.dblLastCost = ISNULL(NULLIF(price.dblLastCost, 0), ISNULL(CASE WHEN ISNUMERIC(p.strCaseCost) = 1 THEN CAST(p.strCaseCost AS NUMERIC(38, 20)) ELSE NULL END 
		/ CASE WHEN ISNUMERIC(p.strCaseBoxSizeQuantityPerCaseBox) = 1 THEN CAST(p.strCaseBoxSizeQuantityPerCaseBox AS NUMERIC(38, 20)) ELSE NULL END, price.dblLastCost))
	, price.dblAverageCost = ISNULL(NULLIF(price.dblAverageCost, 0), ISNULL(CASE WHEN ISNUMERIC(p.strCaseCost) = 1 THEN CAST(p.strCaseCost AS NUMERIC(38, 20)) ELSE NULL END 
		/ CASE WHEN ISNUMERIC(p.strCaseBoxSizeQuantityPerCaseBox) = 1 THEN CAST(p.strCaseBoxSizeQuantityPerCaseBox AS NUMERIC(38, 20)) ELSE NULL END, price.dblAverageCost))
	, price.dtmDateChanged = GETDATE()
	, price.dtmDateModified = GETDATE()
	, price.intModifiedByUserId = @intUserId
FROM tblICEdiPricebook p
	INNER JOIN tblICItemUOM u ON ISNULL(NULLIF(u.strLongUPCCode, ''), u.strUpcCode) = p.strSellingUpcNumber
	INNER JOIN tblICItem i ON i.intItemId = u.intItemId
	INNER JOIN tblICItemLocation il ON il.intItemId = i.intItemId
	INNER JOIN @Locations loc ON loc.intCompanyLocationId = il.intLocationId
	INNER JOIN tblICItemPricing price ON price.intItemId = i.intItemId
		AND il.intItemLocationId = price.intItemLocationId
	LEFT OUTER JOIN tblICCategory cat ON cat.intCategoryId = i.intCategoryId
	LEFT OUTER JOIN tblICCategoryLocation catLoc ON catLoc.intCategoryId = cat.intCategoryId
		AND catLoc.intLocationId = il.intLocationId
	LEFT OUTER JOIN tblICCategoryVendor catV ON catV.intCategoryLocationId = catLoc.intCategoryLocationId
		AND catV.intVendorId = @intVendorId
WHERE catV.ysnUpdatePrice = 1

SELECT cat.strCategoryCode, catV.intVendorId
FROM tblICEdiPricebook p
	INNER JOIN tblICItemUOM u ON ISNULL(NULLIF(u.strLongUPCCode, ''), u.strUpcCode) = p.strSellingUpcNumber
	INNER JOIN tblICItem i ON i.intItemId = u.intItemId
	INNER JOIN tblICItemLocation il ON il.intItemId = i.intItemId
	INNER JOIN @Locations loc ON loc.intCompanyLocationId = il.intLocationId
	INNER JOIN tblICItemPricing price ON price.intItemId = i.intItemId
		AND il.intItemLocationId = price.intItemLocationId
	INNER JOIN tblICCategory cat ON cat.intCategoryId = i.intCategoryId
	INNER JOIN tblICCategoryLocation catLoc ON catLoc.intCategoryId = cat.intCategoryId
		AND catLoc.intLocationId = il.intLocationId
	INNER JOIN tblICCategoryVendor catV ON catV.intCategoryLocationId = catLoc.intCategoryLocationId
		AND catV.intVendorId = @intVendorId
WHERE catV.intVendorId = @intVendorId
	AND catV.ysnUpdatePrice = 1
	
-- Update Special Pricing
UPDATE price
SET   price.dblUnitAfterDiscount = CAST(CASE WHEN ISNUMERIC(p.strSalePrice) = 1 THEN p.strSalePrice ELSE price.dblUnitAfterDiscount END AS NUMERIC(38, 20))
	, price.dtmBeginDate = CAST(CASE WHEN ISDATE(p.strSaleStartDate) = 1 THEN p.strSaleStartDate ELSE price.dtmBeginDate END AS DATETIME)
	, price.dtmEndDate = CAST(CASE WHEN ISDATE(p.strSaleEndingDate) = 1 THEN p.strSaleEndingDate ELSE price.dtmEndDate END AS DATETIME)
FROM tblICEdiPricebook p
	INNER JOIN tblICItemUOM u ON ISNULL(NULLIF(u.strLongUPCCode, ''), u.strUpcCode) = p.strSellingUpcNumber
	INNER JOIN tblICItem i ON i.intItemId = u.intItemId
	INNER JOIN tblICItemLocation il ON il.intItemId = i.intItemId
	INNER JOIN @Locations loc ON loc.intCompanyLocationId = il.intLocationId
	INNER JOIN tblICItemSpecialPricing price ON price.intItemId = i.intItemId
		AND price.intItemLocationId = il.intItemLocationId
	INNER JOIN tblICCategory cat ON cat.intCategoryId = i.intCategoryId
	INNER JOIN tblICCategoryLocation catLoc ON catLoc.intCategoryId = cat.intCategoryId
		AND catLoc.intLocationId = il.intLocationId
	INNER JOIN tblICCategoryVendor catV ON catV.intCategoryLocationId = catLoc.intCategoryLocationId
		AND catV.intVendorId = @intVendorId
WHERE catV.intVendorId = @intVendorId
	AND catV.ysnUpdatePrice = 1

SELECT @ErrorCount = COUNT(*) FROM tblICImportLogDetail WHERE intImportLogId = @LogId AND strType = 'Error'
SELECT @TotalRows = COUNT(*) FROM tblICEdiPricebook WHERE strUniqueId = (SELECT TOP 1 strUniqueId FROM tblICImportLogDetail WHERE intImportLogId = @LogId)

IF @ErrorCount > 0
BEGIN
	UPDATE tblICImportLog SET 
		strDescription = 'Import finished with ' + CAST(@ErrorCount AS NVARCHAR(50))+ ' error(s).',
		intTotalErrors = @ErrorCount,
		intTotalRows = @TotalRows,
		intRowsUpdated = CASE WHEN (@TotalRows - @ErrorCount) < 0 THEN 0 ELSE @TotalRows - @ErrorCount END
	WHERE intImportLogId = @LogId
END

DELETE FROM tblICEdiPricebook