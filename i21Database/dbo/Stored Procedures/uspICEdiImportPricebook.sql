CREATE PROCEDURE [dbo].[uspICEdiImportPricebook] 
	@intUserId INT
	, @intVendorId INT = NULL 
	, @Locations UdtCompanyLocations READONLY
	, @strFileName NVARCHAR(500) = NULL 
	, @strFileType NVARCHAR(50) = NULL 
	, @ErrorCount INT OUTPUT
	, @TotalRows INT OUTPUT
AS

DECLARE @LogId INT
SELECT @LogId = intImportLogId FROM tblICImportLog WHERE strUniqueId = (SELECT TOP 1 strUniqueId FROM tblICEdiPricebook)

IF(@LogId IS NULL)
BEGIN
	INSERT INTO tblICImportLog(strDescription, strType, strFileType, strFileName, dtmDateImported, intUserEntityId, intConcurrencyId)
	SELECT 'Import Pricebook successful', 'EDI', @strFileType, @strFileName, GETDATE(), @intUserId, 1
	SET @LogId = @@IDENTITY
END

--Update Item
UPDATE i
SET	  i.intBrandId = ISNULL(b.intBrandId, i.intBrandId)
	, i.strDescription = ISNULL(NULLIF(p.strSellingUpcLongDescription, ''), i.strDescription)
	, i.strShortName = ISNULL(ISNULL(NULLIF(p.strSellingUpcShortDescription, ''), SUBSTRING(p.strSellingUpcLongDescription, 1, 15)), i.strShortName)
	, i.strItemNo = p.strSellingUpcNumber
FROM 
	tblICEdiPricebook p
	INNER JOIN tblICItemUOM u 
		ON ISNULL(NULLIF(u.strLongUPCCode, ''), u.strUpcCode) = p.strSellingUpcNumber
	INNER JOIN tblICItem i 
		ON i.intItemId = u.intItemId
	LEFT OUTER JOIN tblICBrand b 
		ON b.strBrandName = p.strManufacturersBrandName

-------------------------------------------------
-- BEGIN Validation 
-------------------------------------------------

-- Log UPCs that don't have corresponding items
INSERT INTO tblICImportLogDetail(
	intImportLogId
	, strType
	, intRecordNo
	, strField
	, strValue
	, strMessage
	, strStatus
	, strAction
	, intConcurrencyId
)
SELECT 
	@LogId
	, 'Error'
	, p.intRecordNumber
	, 'SellingUpcNumber'
	, p.strSellingUpcNumber
	, 'Cannot find the item that matches the UPC: ' + p.strSellingUpcNumber
	, 'Skipped'
	, 'Record not imported.'
	, 1
FROM 
	tblICEdiPricebook p
	LEFT OUTER JOIN tblICItemUOM u 
		ON ISNULL(NULLIF(u.strLongUPCCode, ''), u.strUpcCode) = p.strSellingUpcNumber
	LEFT JOIN tblICItem i 
		ON i.intItemId = u.intItemId
WHERE 
	i.intItemId IS NULL

-- Log the records with invalid Vendor Ids. 
INSERT INTO tblICImportLogDetail(
	intImportLogId
	, strType
	, intRecordNo
	, strField
	, strValue
	, strMessage
	, strStatus
	, strAction
	, intConcurrencyId
)
SELECT 
	@LogId
	, 'Error'
	, p.intRecordNumber
	, 'strVendorId'
	, p.strVendorId
	, 'Cannot find the Vendor that matches: ' + p.strVendorId
	, 'Skipped'
	, 'Record not imported.'
	, 1
FROM 
	tblICEdiPricebook p
	LEFT JOIN vyuAPVendor v
		ON (v.strVendorId = p.strVendorId AND @intVendorId IS NULL) 
		OR (v.intEntityId = @intVendorId AND @intVendorId IS NOT NULL)
WHERE 
	v.intEntityId IS NULL 

-------------------------------------------------
-- END Validation 
-------------------------------------------------

-- Create the temp table for the audit log. 
IF OBJECT_ID('tempdb..#tmpICEdiImportPricebook_tblICItemVendorXref') IS NULL  
	CREATE TABLE #tmpICEdiImportPricebook_tblICItemVendorXref (
		intItemId INT
		,intItemLocationId INT 
		,strAction NVARCHAR(50) NULL
		,intVendorId_Old INT NULL 
		,intVendorId_New INT NULL 
		,strVendorProduct_Old NVARCHAR(50) NULL
		,strVendorProduct_New NVARCHAR(50) NULL 
		,strProductDescription_Old NVARCHAR(50) NULL
		,strProductDescription_New NVARCHAR(50) NULL
	)
;

DECLARE 
	@TotalRowsUpdated AS INT = 0 
	,@TotalRowsInserted AS INT = 0 

	
-- Update UOM
UPDATE u
SET u.intUnitMeasureId = ISNULL(ISNULL(m.intUnitMeasureId, s.intUnitMeasureId), u.intUnitMeasureId)
FROM 
	tblICEdiPricebook p
	INNER JOIN tblICItemUOM u 
		ON ISNULL(NULLIF(u.strLongUPCCode, ''), u.strUpcCode) = p.strSellingUpcNumber
	INNER JOIN tblICItem i 
		ON i.intItemId = u.intItemId
	LEFT OUTER JOIN tblICUnitMeasure m 
		ON m.strUnitMeasure = NULLIF(p.strItemUnitOfMeasure, '')
	LEFT OUTER JOIN tblICUnitMeasure s 
		ON s.strSymbol = NULLIF(p.strItemUnitOfMeasure, '')

SET @TotalRowsUpdated = ISNULL(@TotalRowsUpdated, 0) + @@ROWCOUNT; 
	
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
	, l.ysnTaxFlag1 = ISNULL(l.ysnTaxFlag1, catLoc.ysnUseTaxFlag1)
	, l.ysnTaxFlag2 = ISNULL(l.ysnTaxFlag2, catLoc.ysnUseTaxFlag2)
	, l.ysnTaxFlag3 = ISNULL(l.ysnTaxFlag3, catLoc.ysnUseTaxFlag3)
	, l.ysnTaxFlag4 = ISNULL(l.ysnTaxFlag4, catLoc.ysnUseTaxFlag4)
	, l.ysnApplyBlueLaw1 = ISNULL(l.ysnApplyBlueLaw1, catLoc.ysnBlueLaw1)
	, l.ysnApplyBlueLaw2 = ISNULL(l.ysnApplyBlueLaw2, catLoc.ysnBlueLaw2)
	, l.intProductCodeId = ISNULL(l.intProductCodeId, catLoc.intProductCodeId)
	, l.ysnFoodStampable = ISNULL(l.ysnFoodStampable, catLoc.ysnFoodStampable)
	, l.ysnReturnable = ISNULL(l.ysnReturnable, catLoc.ysnReturnable)
	, l.ysnSaleable = ISNULL(l.ysnSaleable, catLoc.ysnSaleable)
	, l.ysnIdRequiredCigarette = ISNULL(l.ysnIdRequiredCigarette, catLoc.ysnIdRequiredCigarette)
	, l.ysnIdRequiredLiquor = ISNULL(l.ysnIdRequiredLiquor, catLoc.ysnIdRequiredLiquor)
	, l.intMinimumAge = ISNULL(l.intMinimumAge, catLoc.intMinimumAge)
FROM tblICEdiPricebook p
	INNER JOIN tblICItemUOM u 
		ON ISNULL(NULLIF(u.strLongUPCCode, ''), u.strUpcCode) = p.strSellingUpcNumber
	INNER JOIN tblICItem i 
		ON i.intItemId = u.intItemId
	INNER JOIN tblICItemLocation l 
		ON l.intItemId = i.intItemId
	LEFT OUTER JOIN tblSTSubcategory sc 
		ON sc.strSubcategoryId = NULLIF(p.strProductClass, '')
		AND sc.strSubcategoryType = 'C'
	LEFT OUTER JOIN tblSTSubcategory sf 
		ON sf.strSubcategoryId = NULLIF(p.strProductFamily, '')
		AND sf.strSubcategoryType = 'F'
	LEFT OUTER JOIN tblICCategory cat 
		ON cat.intCategoryId = i.intCategoryId
	LEFT OUTER JOIN tblICCategoryLocation catLoc 
		ON catLoc.intCategoryId = cat.intCategoryId
		AND catLoc.intLocationId = l.intLocationId

SET @TotalRowsUpdated = ISNULL(@TotalRowsUpdated, 0) + @@ROWCOUNT; 

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

SET @TotalRowsUpdated = ISNULL(@TotalRowsUpdated, 0) + @@ROWCOUNT; 

--SELECT cat.strCategoryCode, catV.intVendorId
--FROM tblICEdiPricebook p
--	INNER JOIN tblICItemUOM u ON ISNULL(NULLIF(u.strLongUPCCode, ''), u.strUpcCode) = p.strSellingUpcNumber
--	INNER JOIN tblICItem i ON i.intItemId = u.intItemId
--	INNER JOIN tblICItemLocation il ON il.intItemId = i.intItemId
--	INNER JOIN @Locations loc ON loc.intCompanyLocationId = il.intLocationId
--	INNER JOIN tblICItemPricing price ON price.intItemId = i.intItemId
--		AND il.intItemLocationId = price.intItemLocationId
--	INNER JOIN tblICCategory cat ON cat.intCategoryId = i.intCategoryId
--	INNER JOIN tblICCategoryLocation catLoc ON catLoc.intCategoryId = cat.intCategoryId
--		AND catLoc.intLocationId = il.intLocationId
--	INNER JOIN tblICCategoryVendor catV ON catV.intCategoryLocationId = catLoc.intCategoryLocationId
--		AND catV.intVendorId = @intVendorId
--WHERE catV.intVendorId = @intVendorId
--	AND catV.ysnUpdatePrice = 1
	
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

SET @TotalRowsUpdated = ISNULL(@TotalRowsUpdated, 0) + @@ROWCOUNT; 

-- Upsert the Vendor XRef (Cross Reference)
INSERT INTO #tmpICEdiImportPricebook_tblICItemVendorXref (
	intItemId
	,intItemLocationId
	,strAction
	,intVendorId_Old
	,intVendorId_New
	,strVendorProduct_Old
	,strVendorProduct_New
	,strProductDescription_Old
	,strProductDescription_New
)
SELECT 
	[Changes].intItemId
	,[Changes].intItemLocationId
	,[Changes].strAction
	,[Changes].intVendorId_Old
	,[Changes].intVendorId_New
	,[Changes].strVendorProduct_Old
	,[Changes].strVendorProduct_New
	,[Changes].strProductDescription_Old
	,[Changes].strProductDescription_New
FROM (
	MERGE	
	INTO	dbo.tblICItemVendorXref 
	WITH	(HOLDLOCK) 
	AS		ItemVendorXref
	USING (
			SELECT 
				i.intItemId 
				,il.intItemLocationId 
				,v.intEntityId 
				,p.strSellingUpcNumber
				,p.strVendorsItemNumberForOrdering
				,p.strSellingUpcLongDescription
				,u.intItemUOMId 
				,u.dblUnitQty
			FROM 
				tblICEdiPricebook p 
				INNER JOIN tblICItemUOM u 
					ON ISNULL(NULLIF(u.strLongUPCCode, ''), u.strUpcCode) = p.strSellingUpcNumber
				INNER JOIN tblICItem i 
					ON i.intItemId = u.intItemId
				INNER JOIN tblICItemLocation il 
					ON il.intItemId = i.intItemId
				INNER JOIN @Locations loc 
					ON loc.intCompanyLocationId = il.intLocationId
				INNER JOIN vyuAPVendor v
					ON (v.strVendorId = p.strVendorId AND @intVendorId IS NULL) 
					OR (v.intEntityId = @intVendorId AND @intVendorId IS NOT NULL)
				
	) AS Source_Query  
		ON ItemVendorXref.intItemId = Source_Query.intItemId
		AND ItemVendorXref.intItemLocationId = Source_Query.intItemLocationId 
		AND ItemVendorXref.intVendorId = Source_Query.intEntityId 				
	   
	-- If matched, update the In-Transit Inbound qty 
	WHEN MATCHED THEN 
		UPDATE 
		SET		
			strVendorProduct = Source_Query.strVendorsItemNumberForOrdering
			,strProductDescription = Source_Query.strSellingUpcLongDescription

	-- If none is found, insert a new vendor xref
	WHEN NOT MATCHED THEN 
		INSERT (		
			intItemId
			,intItemLocationId
			,intVendorId
			,strVendorProduct
			,strProductDescription
			,dblConversionFactor
			,intItemUnitMeasureId
			,intConcurrencyId
			,dtmDateCreated
			,dtmDateModified
			,intCreatedByUserId
			,intModifiedByUserId
			,intDataSourceId		
		)
		VALUES (
			Source_Query.intItemId --intItemId
			,Source_Query.intItemLocationId --,intItemLocationId
			,Source_Query.intEntityId --,intVendorId
			,Source_Query.strVendorsItemNumberForOrdering --,strVendorProduct
			,Source_Query.strSellingUpcLongDescription --,strProductDescription
			,Source_Query.dblUnitQty --,dblConversionFactor
			,Source_Query.intItemUOMId --,intItemUnitMeasureId
			,1--,intConcurrencyId
			,GETDATE()--,dtmDateCreated
			,NULL--,dtmDateModified
			,@intUserId--,intCreatedByUserId
			,NULL--,intModifiedByUserId
			,2--,intDataSourceId		
		)		

		OUTPUT 
			$action
			, inserted.intItemId 
			, inserted.intItemLocationId
			, deleted.strVendorProduct
			, inserted.strVendorProduct
			, deleted.strProductDescription
			, inserted.strProductDescription
			, deleted.intVendorId
			, inserted.intVendorId

) AS [Changes] (
	strAction
	, intItemId 
	, intItemLocationId
	, strVendorProduct_Old
	, strVendorProduct_New
	, strProductDescription_Old
	, strProductDescription_New 
	, intVendorId_Old
	, intVendorId_New
);

SELECT @TotalRowsUpdated = ISNULL(@TotalRowsUpdated, 0) + COUNT(1) FROM #tmpICEdiImportPricebook_tblICItemVendorXref WHERE strAction = 'UPDATE'
SELECT @TotalRowsInserted = ISNULL(@TotalRowsInserted, 0) + COUNT(1) FROM #tmpICEdiImportPricebook_tblICItemVendorXref WHERE strAction = 'INSERTED'

SELECT @ErrorCount = COUNT(*) FROM tblICImportLogDetail WHERE intImportLogId = @LogId AND strType = 'Error'
SELECT @TotalRows = COUNT(*) FROM tblICEdiPricebook WHERE strUniqueId = (SELECT TOP 1 strUniqueId FROM tblICImportLogDetail WHERE intImportLogId = @LogId)

IF @ErrorCount > 0
BEGIN
	UPDATE tblICImportLog 
	SET 
		strDescription = 'Import finished with ' + CAST(@ErrorCount AS NVARCHAR(50))+ ' error(s).',
		intTotalErrors = @ErrorCount,
		intTotalRows = @TotalRows,
		intRowsUpdated = @TotalRowsUpdated, 
		intRowsImported = @TotalRowsInserted
	WHERE 
		intImportLogId = @LogId
END
ELSE 
BEGIN 
	UPDATE tblICImportLog 
	SET 
		intTotalErrors = @ErrorCount,
		intTotalRows = @TotalRows,
		intRowsUpdated = @TotalRowsUpdated, 
		intRowsImported = @TotalRowsInserted
	WHERE 
		intImportLogId = @LogId
END 

DELETE FROM tblICEdiPricebook