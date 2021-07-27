CREATE PROCEDURE [dbo].[uspICEdiImportPricebook] 
	@intUserId INT
	, @intVendorId INT = NULL 
	, @Locations UdtCompanyLocations READONLY
	, @UniqueId NVARCHAR(100)
	, @strFileName NVARCHAR(500) = NULL 
	, @strFileType NVARCHAR(50) = NULL 
	, @ErrorCount INT OUTPUT
	, @TotalRows INT OUTPUT
AS

SET @intVendorId = NULLIF(@intVendorId, '0') 

DECLARE @LogId INT
SELECT @LogId = intImportLogId FROM tblICImportLog WHERE strUniqueId = @UniqueId

IF(@LogId IS NULL AND @UniqueId IS NOT NULL)
BEGIN
	INSERT INTO tblICImportLog(strDescription, strType, strFileType, strFileName, dtmDateImported, intUserEntityId, strUniqueId, intConcurrencyId)
	SELECT 'Import Pricebook successful', 'EDI', @strFileType, @strFileName, GETDATE(), @intUserId, @UniqueId, 1
	SET @LogId = @@IDENTITY
END

-- Remove the bad records from previous import
DELETE tblICEdiPricebook WHERE strUniqueId <> @UniqueId OR strUniqueId IS NULL

DECLARE 
	@updatedItems AS INT = 0
	,@updatedItemUOM AS INT = 0
	,@updatedItemPricing AS INT = 0
	,@insertedItemPricing AS INT = 0
	,@updatedSpecialItemPricing AS INT = 0
	,@insertedSpecialItemPricing AS INT = 0
	,@updatedVendorXRef AS INT = 0
	,@insertedVendorXRef AS INT = 0 
	,@updatedItemLocation AS INT = 0
	,@insertedItemLocation AS INT = 0 
	
-- Remove the duplicate records in tblICEdiPricebook
;WITH deleteDuplicate_CTE (
	intEdiPricebookId
	,strSellingUpcNumber
	,dblDuplicateCount
)
AS (
	
	SELECT 
		p.intEdiPricebookId
		,p.strSellingUpcNumber
		,dblDuplicateCount = ROW_NUMBER() OVER (PARTITION BY p.strSellingUpcNumber ORDER BY p.intEdiPricebookId, p.strSellingUpcNumber)
	FROM 
		tblICEdiPricebook p
	WHERE 
		p.strUniqueId = @UniqueId
)
DELETE FROM deleteDuplicate_CTE
WHERE dblDuplicateCount > 1;

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
WHERE
	p.strUniqueId = @UniqueId

SET @updatedItems = @@ROWCOUNT; 

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
	AND p.strUniqueId = @UniqueId

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
	AND p.strUniqueId = @UniqueId

-------------------------------------------------
-- END Validation 
-------------------------------------------------

-- Create the temp table for the audit log. 
IF OBJECT_ID('tempdb..#tmpICEdiImportPricebook_tblICItemVendorXref') IS NULL  
	CREATE TABLE #tmpICEdiImportPricebook_tblICItemVendorXref (
		intItemId INT
		,strAction NVARCHAR(50) NULL
		,intVendorId_Old INT NULL 
		,intVendorId_New INT NULL 
		,strVendorProduct_Old NVARCHAR(50) NULL
		,strVendorProduct_New NVARCHAR(50) NULL 
		,strProductDescription_Old NVARCHAR(50) NULL
		,strProductDescription_New NVARCHAR(50) NULL
	)
;

-- Create the temp table for the audit log. 
IF OBJECT_ID('tempdb..#tmpICEdiImportPricebook_tblICItemLocation') IS NULL  
	CREATE TABLE #tmpICEdiImportPricebook_tblICItemLocation (
		intItemId INT
		,intItemLocationId INT 
		,strAction NVARCHAR(50) NULL
		,intLocationId_Old INT NULL 
		,intLocationId_New INT NULL 
	)
;


-- Create the temp table for the audit log. 
IF OBJECT_ID('tempdb..#tmpICEdiImportPricebook_tblICItemPricing') IS NULL  
	CREATE TABLE #tmpICEdiImportPricebook_tblICItemPricing (
		intItemId INT
		,intItemLocationId INT 
		,intItemPricingId INT 
		,strAction NVARCHAR(50) NULL
	)
;


-- Create the temp table for the audit log. 
IF OBJECT_ID('tempdb..#tmpICEdiImportPricebook_tblICItemSpecialPricing') IS NULL  
	CREATE TABLE #tmpICEdiImportPricebook_tblICItemSpecialPricing (
		intItemId INT
		,intItemLocationId INT 
		,intItemSpecialPricingId INT 
		,strAction NVARCHAR(50) NULL
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
WHERE
	p.strUniqueId = @UniqueId

SET @updatedItemUOM = @@ROWCOUNT;
	
-- Upsert the Item Location 
INSERT INTO #tmpICEdiImportPricebook_tblICItemLocation (
	strAction
	,intItemId
	,intItemLocationId	
	,intLocationId_Old
	,intLocationId_New
)
SELECT 
	[Changes].strAction
	,[Changes].intItemId
	,[Changes].intItemLocationId 	
	,[Changes].intLocationId_Old
	,[Changes].intLocationId_New
FROM (
	MERGE	
	INTO	dbo.tblICItemLocation
	WITH	(HOLDLOCK) 
	AS		ItemLocation
	USING (
			SELECT 
				i.intItemId
				,l.intItemLocationId
				,intClassId = ISNULL(ISNULL(sc.intSubcategoryId, catLoc.intClassId), l.intClassId)
				,intFamilyId = ISNULL(ISNULL(sf.intSubcategoryId, catLoc.intFamilyId), l.intFamilyId)
				,ysnDepositRequired = ISNULL(CASE p.strDepositRequired WHEN 'Y' THEN 1 WHEN 'N' THEN 0 ELSE NULL END, l.ysnDepositRequired)
				,ysnPromotionalItem = ISNULL(CASE p.strPromotionalItem WHEN 'Y' THEN 1 WHEN 'N' THEN 0 ELSE NULL END, l.ysnPromotionalItem)
				,ysnPrePriced = ISNULL(ISNULL(CASE p.strPrePriced WHEN 'Y' THEN 1 WHEN 'N' THEN 0 ELSE NULL END, catLoc.ysnPrePriced), l.ysnPrePriced)
				,dblSuggestedQty = ISNULL(NULLIF(p.strSuggestedOrderQuantity, ''), l.dblSuggestedQty)
				,dblMinOrder = ISNULL(NULLIF(p.strMinimumOrderQuantity, ''), l.dblMinOrder)
				,intBottleDepositNo = ISNULL(NULLIF(p.strBottleDepositNumber, ''), l.intBottleDepositNo)
				,ysnTaxFlag1 = ISNULL(l.ysnTaxFlag1, catLoc.ysnUseTaxFlag1)
				,ysnTaxFlag2 = ISNULL(l.ysnTaxFlag2, catLoc.ysnUseTaxFlag2)
				,ysnTaxFlag3 = ISNULL(l.ysnTaxFlag3, catLoc.ysnUseTaxFlag3)
				,ysnTaxFlag4 = ISNULL(l.ysnTaxFlag4, catLoc.ysnUseTaxFlag4)
				,ysnApplyBlueLaw1 = ISNULL(l.ysnApplyBlueLaw1, catLoc.ysnBlueLaw1)
				,ysnApplyBlueLaw2 = ISNULL(l.ysnApplyBlueLaw2, catLoc.ysnBlueLaw2)
				,intProductCodeId = ISNULL(l.intProductCodeId, catLoc.intProductCodeId)
				,ysnFoodStampable = ISNULL(l.ysnFoodStampable, catLoc.ysnFoodStampable)
				,ysnReturnable = ISNULL(l.ysnReturnable, catLoc.ysnReturnable)
				,ysnSaleable = ISNULL(l.ysnSaleable, catLoc.ysnSaleable)
				,ysnIdRequiredCigarette = ISNULL(l.ysnIdRequiredCigarette, catLoc.ysnIdRequiredCigarette)
				,ysnIdRequiredLiquor = ISNULL(l.ysnIdRequiredLiquor, catLoc.ysnIdRequiredLiquor)
				,intMinimumAge = ISNULL(l.intMinimumAge, catLoc.intMinimumAge)
				,intCountGroupId = cg.intCountGroupId
				,intLocationId = l.intCompanyLocationId 
			FROM tblICEdiPricebook p
				INNER JOIN tblICItemUOM u 
					ON ISNULL(NULLIF(u.strLongUPCCode, ''), u.strUpcCode) = p.strSellingUpcNumber
				INNER JOIN tblICItem i 
					ON i.intItemId = u.intItemId
				LEFT JOIN tblICCategory cat 
					ON cat.intCategoryId = i.intCategoryId
				LEFT JOIN tblSTSubcategory sc 
					ON sc.strSubcategoryId = NULLIF(p.strProductClass, '')
					AND sc.strSubcategoryType = 'C'
				LEFT JOIN tblSTSubcategory sf 
					ON sf.strSubcategoryId = NULLIF(p.strProductFamily, '')
					AND sf.strSubcategoryType = 'F'
				LEFT JOIN tblICCountGroup cg
					ON cg.strCountGroup = p.strInventoryGroup
				OUTER APPLY (
					SELECT 
						loc.intCompanyLocationId 
						,l.*
					FROM 						
						@Locations loc LEFT JOIN tblICItemLocation l 
							ON l.intItemId = i.intItemId
							AND loc.intCompanyLocationId = l.intLocationId
				) l
				LEFT JOIN tblICCategoryLocation catLoc 
					ON catLoc.intCategoryId = cat.intCategoryId
					AND catLoc.intLocationId = l.intLocationId
			WHERE
				p.strUniqueId = @UniqueId
	) AS Source_Query  
		ON ItemLocation.intItemLocationId = Source_Query.intItemLocationId
	   
	-- If matched, update the existing item location
	WHEN MATCHED THEN 
		UPDATE 
		SET   ItemLocation.intClassId = Source_Query.intClassId
			, ItemLocation.intFamilyId = Source_Query.intFamilyId
			, ItemLocation.ysnDepositRequired = Source_Query.ysnDepositRequired
			, ItemLocation.ysnPromotionalItem = Source_Query.ysnPromotionalItem
			, ItemLocation.ysnPrePriced = Source_Query.ysnPrePriced
			, ItemLocation.dblSuggestedQty = Source_Query.dblSuggestedQty
			, ItemLocation.dblMinOrder = Source_Query.dblMinOrder
			, ItemLocation.intBottleDepositNo = Source_Query.intBottleDepositNo
			, ItemLocation.ysnTaxFlag1 = Source_Query.ysnTaxFlag1
			, ItemLocation.ysnTaxFlag2 = Source_Query.ysnTaxFlag2
			, ItemLocation.ysnTaxFlag3 = Source_Query.ysnTaxFlag3
			, ItemLocation.ysnTaxFlag4 = Source_Query.ysnTaxFlag4
			, ItemLocation.ysnApplyBlueLaw1 = Source_Query.ysnApplyBlueLaw1
			, ItemLocation.ysnApplyBlueLaw2 = Source_Query.ysnApplyBlueLaw2
			, ItemLocation.intProductCodeId = Source_Query.intProductCodeId
			, ItemLocation.ysnFoodStampable = Source_Query.ysnFoodStampable
			, ItemLocation.ysnReturnable = Source_Query.ysnReturnable
			, ItemLocation.ysnSaleable = Source_Query.ysnSaleable
			, ItemLocation.ysnIdRequiredCigarette = Source_Query.ysnIdRequiredCigarette
			, ItemLocation.ysnIdRequiredLiquor = Source_Query.ysnIdRequiredLiquor
			, ItemLocation.intMinimumAge = Source_Query.intMinimumAge
			, ItemLocation.intCountGroupId = Source_Query.intCountGroupId

	-- If none is found, insert a new item location 
	WHEN NOT MATCHED THEN 
		INSERT (		
			intItemId
			,intLocationId
			,intVendorId
			,strDescription
			,intCostingMethod
			,intAllowNegativeInventory
			,intSubLocationId
			,intStorageLocationId
			,intIssueUOMId
			,intReceiveUOMId
			,intGrossUOMId
			,intFamilyId
			,intClassId
			,intProductCodeId
			,intFuelTankId
			,strPassportFuelId1
			,strPassportFuelId2
			,strPassportFuelId3
			,ysnTaxFlag1
			,ysnTaxFlag2
			,ysnTaxFlag3
			,ysnTaxFlag4
			,ysnPromotionalItem
			,intMixMatchId
			,ysnDepositRequired
			,intDepositPLUId
			,intBottleDepositNo
			,ysnSaleable
			,ysnQuantityRequired
			,ysnScaleItem
			,ysnFoodStampable
			,ysnReturnable
			,ysnPrePriced
			,ysnOpenPricePLU
			,ysnLinkedItem
			,strVendorCategory
			,ysnCountBySINo
			,strSerialNoBegin
			,strSerialNoEnd
			,ysnIdRequiredLiquor
			,ysnIdRequiredCigarette
			,intMinimumAge
			,ysnApplyBlueLaw1
			,ysnApplyBlueLaw2
			,ysnCarWash
			,intItemTypeCode
			,intItemTypeSubCode
			,ysnAutoCalculateFreight
			,intFreightMethodId
			,dblFreightRate
			,intShipViaId
			,intNegativeInventory
			,dblReorderPoint
			,dblMinOrder
			,dblSuggestedQty
			,dblLeadTime
			,strCounted
			,intCountGroupId
			,ysnCountedDaily
			,intAllowZeroCostTypeId
			,ysnLockedInventory
			,ysnStorageUnitRequired
			,strStorageUnitNo
			,intCostAdjustmentType
			,ysnActive
			,intSort
			,intConcurrencyId
			,dtmDateCreated
			,dtmDateModified
			,intCreatedByUserId
			,intModifiedByUserId
			,intDataSourceId
		)
		VALUES (
			Source_Query.intItemId --intItemId
			,Source_Query.intLocationId --,intLocationId
			,DEFAULT--,intVendorId
			,DEFAULT--,strDescription
			,1--,intCostingMethod
			,3--,intAllowNegativeInventory
			,DEFAULT--,intSubLocationId
			,DEFAULT--,intStorageLocationId
			,DEFAULT--,intIssueUOMId
			,DEFAULT--,intReceiveUOMId
			,DEFAULT--,intGrossUOMId
			,DEFAULT--,intFamilyId
			,Source_Query.intClassId--,intClassId
			,Source_Query.intProductCodeId--,intProductCodeId
			,DEFAULT--,intFuelTankId
			,DEFAULT--,strPassportFuelId1
			,DEFAULT--,strPassportFuelId2
			,DEFAULT--,strPassportFuelId3
			,Source_Query.ysnTaxFlag1--,ysnTaxFlag1
			,Source_Query.ysnTaxFlag2--,ysnTaxFlag2
			,Source_Query.ysnTaxFlag3--,ysnTaxFlag3
			,Source_Query.ysnTaxFlag4--,ysnTaxFlag4
			,Source_Query.ysnPromotionalItem--,ysnPromotionalItem
			,DEFAULT--,intMixMatchId
			,Source_Query.ysnDepositRequired--,ysnDepositRequired
			,DEFAULT--,intDepositPLUId
			,Source_Query.intBottleDepositNo--,intBottleDepositNo
			,Source_Query.ysnSaleable--,ysnSaleable
			,DEFAULT--,ysnQuantityRequired
			,DEFAULT--,ysnScaleItem
			,Source_Query.ysnFoodStampable--,ysnFoodStampable
			,Source_Query.ysnReturnable--,ysnReturnable
			,Source_Query.ysnPrePriced--,ysnPrePriced
			,DEFAULT--,ysnOpenPricePLU
			,DEFAULT--,ysnLinkedItem
			,DEFAULT--,strVendorCategory
			,DEFAULT--,ysnCountBySINo
			,DEFAULT--,strSerialNoBegin
			,DEFAULT--,strSerialNoEnd
			,Source_Query.ysnIdRequiredLiquor--,ysnIdRequiredLiquor
			,Source_Query.ysnIdRequiredCigarette--,ysnIdRequiredCigarette
			,Source_Query.intMinimumAge--,intMinimumAge
			,Source_Query.ysnApplyBlueLaw1--,ysnApplyBlueLaw1
			,Source_Query.ysnApplyBlueLaw2--,ysnApplyBlueLaw2
			,DEFAULT--,ysnCarWash
			,DEFAULT--,intItemTypeCode
			,DEFAULT--,intItemTypeSubCode
			,DEFAULT--,ysnAutoCalculateFreight
			,DEFAULT--,intFreightMethodId
			,DEFAULT--,dblFreightRate
			,DEFAULT--,intShipViaId
			,DEFAULT--,intNegativeInventory
			,DEFAULT --,dblReorderPoint
			,Source_Query.dblMinOrder--,dblMinOrder
			,Source_Query.dblSuggestedQty--,dblSuggestedQty
			,DEFAULT--,dblLeadTime
			,DEFAULT--,strCounted
			,Source_Query.intCountGroupId--,intCountGroupId
			,DEFAULT--,ysnCountedDaily
			,1--,intAllowZeroCostTypeId
			,DEFAULT--,ysnLockedInventory
			,DEFAULT--,ysnStorageUnitRequired
			,DEFAULT--,strStorageUnitNo
			,DEFAULT--,intCostAdjustmentType
			,1--,ysnActive
			,DEFAULT--,intSort
			,1--,intConcurrencyId
			,GETDATE()--,dtmDateCreated
			,DEFAULT--,dtmDateModified
			,@intUserId--,intCreatedByUserId
			,DEFAULT--,intModifiedByUserId
			,2--,intDataSourceId			
		)		

		OUTPUT 
			$action
			, inserted.intItemId 
			, inserted.intItemLocationId			
			, deleted.intLocationId
			, inserted.intLocationId

) AS [Changes] (
	strAction
	, intItemId 
	, intItemLocationId 
	, intLocationId_Old
	, intLocationId_New
);

SELECT @updatedItemLocation = COUNT(1) FROM #tmpICEdiImportPricebook_tblICItemLocation WHERE strAction = 'UPDATE'
SELECT @insertedItemLocation = COUNT(1) FROM #tmpICEdiImportPricebook_tblICItemLocation WHERE strAction = 'INSERT'

-- Upsert the Item Pricing
INSERT INTO #tmpICEdiImportPricebook_tblICItemPricing (
	strAction
	,intItemId
	,intItemLocationId	
	,intItemPricingId
)
SELECT 
	[Changes].strAction
	,[Changes].intItemId
	,[Changes].intItemLocationId 	
	,[Changes].intItemPricingId 	
FROM (
	MERGE	
	INTO	dbo.tblICItemPricing
	WITH	(HOLDLOCK) 
	AS		ItemPricing
	USING (
		SELECT 
			i.intItemId
			,il.intItemLocationId
			,price.intItemPricingId
			,dblSalePrice = 
				CAST(CASE WHEN ISNUMERIC(p.strRetailPrice) = 1 THEN p.strRetailPrice ELSE price.dblSalePrice END AS NUMERIC(38, 20))
			,dblStandardCost = 
				ISNULL(
					CASE 
						WHEN ISNUMERIC(p.strCaseCost) = 1 THEN 
							CAST(p.strCaseCost AS NUMERIC(38, 20)) 
						ELSE NULL 
					END 
					/ 
					CASE 
						WHEN ISNUMERIC(p.strCaseBoxSizeQuantityPerCaseBox) = 1 AND CAST(p.strCaseBoxSizeQuantityPerCaseBox AS NUMERIC(38, 20)) <> 0 THEN 
							CAST(p.strCaseBoxSizeQuantityPerCaseBox AS NUMERIC(38, 20)) 
						ELSE 
							NULL 
					END
						
					,price.dblStandardCost
				)
			,dblLastCost = 
				ISNULL(
					NULLIF(price.dblLastCost, 0)
					, ISNULL(
						CASE 
							WHEN ISNUMERIC(p.strCaseCost) = 1 THEN 
								CAST(p.strCaseCost AS NUMERIC(38, 20)) 
							ELSE 
								NULL 
						END 
						/ 
						CASE 
							WHEN ISNUMERIC(p.strCaseBoxSizeQuantityPerCaseBox) = 1 AND CAST(p.strCaseBoxSizeQuantityPerCaseBox AS NUMERIC(38, 20)) <> 0 THEN 
								CAST(p.strCaseBoxSizeQuantityPerCaseBox AS NUMERIC(38, 20)) 
							ELSE 
								NULL 
						END
						,price.dblLastCost
					)
				)
			,dblAverageCost = 
				ISNULL(
					NULLIF(price.dblAverageCost, 0)
					, ISNULL(
						CASE 
							WHEN ISNUMERIC(p.strCaseCost) = 1 THEN 
								CAST(p.strCaseCost AS NUMERIC(38, 20)) 
							ELSE 
								NULL 
						END 
						/ 
						CASE 
							WHEN ISNUMERIC(p.strCaseBoxSizeQuantityPerCaseBox) = 1 AND CAST(p.strCaseBoxSizeQuantityPerCaseBox AS NUMERIC(38, 20)) <> 0 THEN 
								CAST(p.strCaseBoxSizeQuantityPerCaseBox AS NUMERIC(38, 20)) 
							ELSE NULL 
						END
						,price.dblAverageCost
					)
				)
			,catV.ysnUpdatePrice
		FROM tblICEdiPricebook p
			INNER JOIN tblICItemUOM u 
				ON ISNULL(NULLIF(u.strLongUPCCode, ''), u.strUpcCode) = p.strSellingUpcNumber
			INNER JOIN tblICItem i 
				ON i.intItemId = u.intItemId
			LEFT JOIN vyuAPVendor v
				ON (v.strVendorId = p.strVendorId AND @intVendorId IS NULL) 
				OR (v.intEntityId = @intVendorId AND @intVendorId IS NOT NULL)
			OUTER APPLY (
				SELECT 
					loc.intCompanyLocationId 
					,l.*
				FROM 						
					@Locations loc INNER JOIN tblICItemLocation l 
						ON l.intItemId = i.intItemId
						AND loc.intCompanyLocationId = l.intLocationId
			) il
			LEFT JOIN tblICCategory cat 
				ON cat.intCategoryId = i.intCategoryId
			LEFT JOIN tblICCategoryLocation catLoc 
				ON catLoc.intCategoryId = cat.intCategoryId
				AND catLoc.intLocationId = il.intLocationId
			LEFT JOIN tblICCategoryVendor catV 
				ON catV.intCategoryLocationId = catLoc.intCategoryLocationId
				AND catV.intVendorId = v.intEntityId
			LEFT JOIN tblICItemPricing price 
				ON price.intItemId = i.intItemId
				AND price.intItemLocationId = il.intItemLocationId
		WHERE
			p.strUniqueId = @UniqueId
	) AS Source_Query  
		ON ItemPricing.intItemPricingId = Source_Query.intItemPricingId 
	   
	-- If matched, update the existing item pricing
	WHEN MATCHED 
		AND Source_Query.ysnUpdatePrice = 1	
	THEN 
		UPDATE 
		SET   
			ItemPricing.dblSalePrice = Source_Query.dblSalePrice
			,ItemPricing.dblStandardCost = Source_Query.dblStandardCost
			,ItemPricing.dblLastCost = Source_Query.dblLastCost
			,ItemPricing.dblAverageCost = Source_Query.dblAverageCost
			,ItemPricing.dtmDateChanged = GETDATE()
			,ItemPricing.dtmDateModified = GETDATE()
			,ItemPricing.intModifiedByUserId = @intUserId

	-- If none is found, insert a new item pricing
	WHEN NOT MATCHED 
		AND Source_Query.intItemId IS NOT NULL 
		AND Source_Query.intItemLocationId IS NOT NULL 
	THEN 
		INSERT (		
			intItemId
			,intItemLocationId
			,dblAmountPercent
			,dblSalePrice
			,dblMSRPPrice
			,strPricingMethod
			,dblLastCost
			,dblStandardCost
			,dblAverageCost
			,dblEndMonthCost
			,dblDefaultGrossPrice
			,intSort
			,ysnIsPendingUpdate
			,dtmDateChanged
			,intConcurrencyId
			,dtmDateCreated
			,dtmDateModified
			,intCreatedByUserId
			,intModifiedByUserId
			,intDataSourceId
			,intImportFlagInternal
			,ysnAvgLocked
		)
		VALUES (
			Source_Query.intItemId--intItemId
			,Source_Query.intItemLocationId--,intItemLocationId
			,DEFAULT--,dblAmountPercent
			,Source_Query.dblSalePrice--,dblSalePrice
			,DEFAULT--,dblMSRPPrice
			,'None'--,strPricingMethod
			,Source_Query.dblLastCost--,dblLastCost
			,Source_Query.dblStandardCost--,dblStandardCost
			,Source_Query.dblAverageCost--,dblAverageCost
			,DEFAULT--,dblEndMonthCost
			,DEFAULT--,dblDefaultGrossPrice
			,DEFAULT--,intSort
			,DEFAULT--,ysnIsPendingUpdate
			,DEFAULT--,dtmDateChanged
			,1--,intConcurrencyId
			,GETDATE()--,dtmDateCreated
			,DEFAULT--,dtmDateModified
			,@intUserId--,intCreatedByUserId
			,DEFAULT--,intModifiedByUserId
			,2--,intDataSourceId
			,DEFAULT--,intImportFlagInternal
			,DEFAULT--,ysnAvgLocked
		)

		OUTPUT 
			$action
			, inserted.intItemId 
			, inserted.intItemLocationId			
			, inserted.intItemPricingId

) AS [Changes] (
	strAction
	, intItemId 
	, intItemLocationId 
	, intItemPricingId
);

SELECT @updatedItemPricing = COUNT(1) FROM #tmpICEdiImportPricebook_tblICItemPricing WHERE strAction = 'UPDATE'
SELECT @insertedItemPricing = COUNT(1) FROM #tmpICEdiImportPricebook_tblICItemPricing WHERE strAction = 'INSERT'
	
-- Upsert the Item Special Pricing
INSERT INTO #tmpICEdiImportPricebook_tblICItemSpecialPricing (
	strAction
	,intItemId
	,intItemLocationId	
	,intItemSpecialPricingId
)
SELECT 
	[Changes].strAction
	,[Changes].intItemId
	,[Changes].intItemLocationId 	
	,[Changes].intItemSpecialPricingId 	
FROM (
	MERGE	
	INTO	dbo.tblICItemSpecialPricing
	WITH	(HOLDLOCK) 
	AS		ItemSpecialPricing
	USING (
		SELECT 
			i.intItemId
			,il.intItemLocationId
			,price.intItemSpecialPricingId
			,u.intItemUOMId 
			,companyPref.intDefaultCurrencyId
			,dblUnitAfterDiscount = CAST(CASE WHEN ISNUMERIC(p.strSalePrice) = 1 THEN p.strSalePrice ELSE price.dblUnitAfterDiscount END AS NUMERIC(38, 20))
			,dtmBeginDate = CAST(CASE WHEN ISDATE(p.strSaleStartDate) = 1 THEN p.strSaleStartDate ELSE price.dtmBeginDate END AS DATETIME)
			,dtmEndDate = CAST(CASE WHEN ISDATE(p.strSaleEndingDate) = 1 THEN p.strSaleEndingDate ELSE price.dtmEndDate END AS DATETIME)
			,catV.ysnUpdatePrice 
		FROM tblICEdiPricebook p
			INNER JOIN tblICItemUOM u ON ISNULL(NULLIF(u.strLongUPCCode, ''), u.strUpcCode) = p.strSellingUpcNumber
			INNER JOIN tblICItem i ON i.intItemId = u.intItemId
			LEFT JOIN tblICCategory cat 
				ON cat.intCategoryId = i.intCategoryId
			OUTER APPLY (
				SELECT 
					loc.intCompanyLocationId 
					,l.*
				FROM 						
					@Locations loc INNER JOIN tblICItemLocation l 
						ON l.intItemId = i.intItemId
						AND loc.intCompanyLocationId = l.intLocationId
			) il
			LEFT JOIN tblICCategoryLocation catLoc 
				ON catLoc.intCategoryId = cat.intCategoryId
				AND catLoc.intLocationId = il.intLocationId
			LEFT JOIN vyuAPVendor v
				ON (v.strVendorId = p.strVendorId AND @intVendorId IS NULL) 
				OR (v.intEntityId = @intVendorId AND @intVendorId IS NOT NULL)
			LEFT JOIN tblICCategoryVendor catV 
				ON catV.intCategoryLocationId = catLoc.intCategoryLocationId
				AND catV.intVendorId = v.intEntityId
			LEFT JOIN tblICItemSpecialPricing price 
				ON price.intItemId = i.intItemId
				AND price.intItemLocationId = il.intItemLocationId
			OUTER APPLY (
				SELECT TOP 1 intDefaultCurrencyId FROM tblSMCompanyPreference
			) companyPref
		WHERE
			p.strUniqueId = @UniqueId
	) AS Source_Query  
		ON ItemSpecialPricing.intItemSpecialPricingId = Source_Query.intItemSpecialPricingId 
		AND ItemSpecialPricing.dtmBeginDate = Source_Query.dtmBeginDate 
		AND ItemSpecialPricing.dtmEndDate = Source_Query.dtmEndDate 
		AND ItemSpecialPricing.strPromotionType = 'Discount'
	   
	-- If matched, update the existing special pricing
	WHEN MATCHED 
		AND Source_Query.ysnUpdatePrice = 1
	THEN 
		UPDATE 
		SET   
			dblUnitAfterDiscount = Source_Query.dblUnitAfterDiscount

	-- If none is found, insert a new special pricing
	WHEN NOT MATCHED 
		AND Source_Query.intItemId IS NOT NULL 
		AND Source_Query.intItemLocationId IS NOT NULL 
		AND Source_Query.dtmBeginDate IS NOT NULL
		AND Source_Query.dtmEndDate IS NOT NULL 
	THEN 
		INSERT (		
			intItemId
			,intItemLocationId
			,strPromotionType
			,dtmBeginDate
			,dtmEndDate
			,intItemUnitMeasureId
			,dblUnit
			,strDiscountBy
			,dblDiscount
			,dblUnitAfterDiscount
			,dblDiscountThruQty
			,dblDiscountThruAmount
			,dblAccumulatedQty
			,dblAccumulatedAmount
			,intCurrencyId
			,intSort
			,intConcurrencyId
			,dtmDateCreated
			,dtmDateModified
			,intCreatedByUserId
			,intModifiedByUserId
		)
		VALUES (
			Source_Query.intItemId--intItemId
			,Source_Query.intItemLocationId--,intItemLocationId
			,'Discount'--,strPromotionType
			,Source_Query.dtmBeginDate--,dtmBeginDate
			,Source_Query.dtmEndDate--,dtmEndDate
			,Source_Query.intItemUOMId--,intItemUnitMeasureId
			,1--,dblUnit
			,'Amount'--,strDiscountBy
			,0--,dblDiscount
			,Source_Query.dblUnitAfterDiscount--,dblUnitAfterDiscount
			,0--,dblDiscountThruQty
			,0--,dblDiscountThruAmount
			,0--,dblAccumulatedQty
			,0--,dblAccumulatedAmount
			,Source_Query.intDefaultCurrencyId--,intCurrencyId
			,DEFAULT--,intSort
			,1--,intConcurrencyId
			,GETDATE()--,dtmDateCreated
			,DEFAULT--,dtmDateModified
			,@intUserId--,intCreatedByUserId
			,DEFAULT--,intModifiedByUserId
		)		

		OUTPUT 
			$action
			, inserted.intItemId 
			, inserted.intItemLocationId			
			, inserted.intItemSpecialPricingId

) AS [Changes] (
	strAction
	, intItemId 
	, intItemLocationId 
	, intItemSpecialPricingId
);

SELECT @updatedSpecialItemPricing = COUNT(1) FROM #tmpICEdiImportPricebook_tblICItemSpecialPricing WHERE strAction = 'UPDATE'
SELECT @insertedSpecialItemPricing = COUNT(1) FROM #tmpICEdiImportPricebook_tblICItemSpecialPricing WHERE strAction = 'INSERT'

-- Upsert the Vendor XRef (Cross Reference)
INSERT INTO #tmpICEdiImportPricebook_tblICItemVendorXref (
	intItemId
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
				INNER JOIN vyuAPVendor v
					ON (v.strVendorId = p.strVendorId AND @intVendorId IS NULL) 
					OR (v.intEntityId = @intVendorId AND @intVendorId IS NOT NULL)
			WHERE
				p.strUniqueId = @UniqueId
	) AS Source_Query  
		ON ItemVendorXref.intItemId = Source_Query.intItemId		
		AND ItemVendorXref.intVendorId = Source_Query.intEntityId
		AND ItemVendorXref.intItemLocationId IS NULL 
	   
	-- If matched, update the existing vendor xref 
	WHEN MATCHED THEN 
		UPDATE 
		SET		
			strVendorProduct = Source_Query.strVendorsItemNumberForOrdering
			,strProductDescription = Source_Query.strSellingUpcLongDescription

	-- If none is found, insert a new vendor xref
	WHEN NOT MATCHED THEN 
		INSERT (		
			intItemId
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
			, deleted.strVendorProduct
			, inserted.strVendorProduct
			, deleted.strProductDescription
			, inserted.strProductDescription
			, deleted.intVendorId
			, inserted.intVendorId

) AS [Changes] (
	strAction
	, intItemId 
	, strVendorProduct_Old
	, strVendorProduct_New
	, strProductDescription_Old
	, strProductDescription_New 
	, intVendorId_Old
	, intVendorId_New
);

SELECT @updatedVendorXRef = COUNT(1) FROM #tmpICEdiImportPricebook_tblICItemVendorXref WHERE strAction = 'UPDATE'
SELECT @insertedVendorXRef = COUNT(1) FROM #tmpICEdiImportPricebook_tblICItemVendorXref WHERE strAction = 'INSERT'

SELECT @ErrorCount = COUNT(*) FROM tblICImportLogDetail WHERE intImportLogId = @LogId AND strType = 'Error'
SELECT @TotalRows = COUNT(*) FROM tblICEdiPricebook WHERE strUniqueId = @UniqueId

SET @TotalRowsUpdated = @TotalRowsUpdated + @updatedItems + @updatedItemUOM + @updatedItemPricing + @updatedItemLocation + @updatedSpecialItemPricing + @updatedVendorXRef
SET @TotalRowsInserted = @TotalRowsInserted + @insertedItemLocation + @insertedItemPricing + @insertedSpecialItemPricing + @insertedVendorXRef 

BEGIN 
	UPDATE tblICImportLog 
	SET 
		intTotalErrors = @ErrorCount,
		intTotalRows = @TotalRows,
		intRowsUpdated = @TotalRowsUpdated, 
		intRowsImported = @TotalRowsInserted
	WHERE 
		intImportLogId = @LogId

	UPDATE tblICImportLog 
	SET 
		strDescription = 'Import finished with ' + CAST(@ErrorCount AS NVARCHAR(50))+ ' error(s).'
	WHERE 
		intImportLogId = @LogId
		AND @ErrorCount > 0

	-- Log the updated items. 
	IF @updatedItems <> 0 
	BEGIN 
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
			, 'Info'
			, NULL
			, NULL 
			, NULL 
			, dbo.fnFormatMessage('%i item(s) are updated.', @updatedItems,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT)
			, 'Success'
			, 'Updated'
			, 1
		WHERE 
			@updatedItems <> 0 
	END 

	-- Log the updated item uom. 
	IF @updatedItemUOM <> 0 
	BEGIN 
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
			, 'Info'
			, NULL
			, NULL 
			, NULL 
			, dbo.fnFormatMessage('%i item UOM(s) are updated.', @updatedItemUOM,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT)
			, 'Success'
			, 'Updated'
			, 1
		WHERE 
			@updatedItemUOM <> 0 
	END 
	
	-- Log the created item locations
	IF @insertedItemLocation <> 0 
	BEGIN 
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
			, 'Info'
			, NULL
			, NULL 
			, NULL 
			, dbo.fnFormatMessage('%i item location record(s) are created.', @insertedItemLocation,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT)
			, 'Success'
			, 'Updated'
			, 1
		WHERE 
			@insertedItemLocation <> 0 
	END
	
	-- Log the updated item location. 
	IF @updatedItemLocation <> 0 
	BEGIN 
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
			, 'Info'
			, NULL
			, NULL 
			, NULL 
			, dbo.fnFormatMessage('%i item location record(s) are updated.', @updatedItemLocation,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT)
			, 'Success'
			, 'Updated'
			, 1
		WHERE 
			@updatedItemLocation <> 0 
	END

	-- Log the created item pricing. 
	IF @insertedItemPricing <> 0 
	BEGIN 
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
			, 'Info'
			, NULL
			, NULL 
			, NULL 
			, dbo.fnFormatMessage('%i item pricing record(s) are created.', @insertedItemPricing,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT)
			, 'Success'
			, 'Updated'
			, 1
		WHERE 
			@insertedItemPricing <> 0 
	END

	-- Log the updated item pricing. 
	IF @updatedItemPricing <> 0 
	BEGIN 
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
			, 'Info'
			, NULL
			, NULL 
			, NULL 
			, dbo.fnFormatMessage('%i item pricing record(s) are updated.', @updatedItemPricing,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT)
			, 'Success'
			, 'Updated'
			, 1
		WHERE 
			@updatedItemPricing <> 0 
	END

	-- Log the created item special pricing. 
	IF @insertedSpecialItemPricing <> 0 
	BEGIN 
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
			, 'Info'
			, NULL
			, NULL 
			, NULL 
			, dbo.fnFormatMessage('%i item special pricing record(s) are created.', @insertedSpecialItemPricing,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT)
			, 'Success'
			, 'Updated'
			, 1
		WHERE 
			@insertedSpecialItemPricing <> 0 
	END

	-- Log the updated item special pricing. 
	IF @updatedSpecialItemPricing <> 0 
	BEGIN 
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
			, 'Info'
			, NULL
			, NULL 
			, NULL 
			, dbo.fnFormatMessage('%i item special pricing record(s) are updated.', @updatedSpecialItemPricing,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT)
			, 'Success'
			, 'Updated'
			, 1
		WHERE 
			@updatedSpecialItemPricing <> 0 
	END

	-- Log the inserted vendor xref
	IF @insertedVendorXRef <> 0 
	BEGIN 
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
			, 'Info'
			, NULL
			, NULL 
			, NULL 
			, dbo.fnFormatMessage('%i vendor xref record(s) are created.', @insertedVendorXRef,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT)
			, 'Success'
			, 'Created'
			, 1
		WHERE 
			@insertedVendorXRef <> 0 
	END

	-- Log the updated vendor xref
	IF @updatedVendorXRef <> 0 
	BEGIN 
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
			, 'Info'
			, NULL
			, NULL 
			, NULL 
			, dbo.fnFormatMessage('%i vendor xref record(s) are updated.', @updatedVendorXRef,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT)
			, 'Success'
			, 'Updated'
			, 1
		WHERE 
			@updatedVendorXRef <> 0 
	END
END 

DELETE FROM tblICEdiPricebook WHERE strUniqueId = @UniqueId