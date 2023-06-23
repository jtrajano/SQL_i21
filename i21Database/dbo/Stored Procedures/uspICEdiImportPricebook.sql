CREATE PROCEDURE [dbo].[uspICEdiImportPricebook] 
	@intUserId INT
	, @intVendorId INT = NULL 
	, @Locations UdtCompanyLocations READONLY
	, @UniqueId NVARCHAR(100)
	, @strFileName NVARCHAR(500) = NULL 
	, @strFileType NVARCHAR(50) = NULL 
	, @ErrorCount INT OUTPUT
	, @TotalRows INT OUTPUT
	, @storeGroup udtStoreGroup READONLY
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
	@updatedItem AS INT = 0
	,@insertedItem AS INT = 0	
	,@updatedItemUOM AS INT = 0
	,@insertedItemUOM AS INT = 0 	
	,@updatedItemPricing AS INT = 0
	,@insertedItemPricing AS INT = 0
	,@updatedEffectiveItemPricing AS INT = 0
	,@insertedEffectiveItemPricing AS INT = 0
	,@updatedSpecialItemPricing AS INT = 0
	,@insertedSpecialItemPricing AS INT = 0
	,@updatedVendorXRef AS INT = 0
	,@insertedVendorXRef AS INT = 0 
	,@updatedItemLocation AS INT = 0
	,@insertedItemLocation AS INT = 0 
	,@insertedProductClass AS INT = 0 
	,@insertedFamilyClass AS INT = 0
	,@originalPricebookCount AS INT = 0 
	,@duplicatePricebookCount AS INT = 0 
	,@missingVendorCategoryXRef AS INT = 0 
	,@duplicate2ndUOMUPCCode AS INT = 0 
	,@duplicateAlternate1UOMUPCCode AS INT = 0
	,@duplicateAlternate2UOMUPCCode AS INT = 0
	,@updatedEffectiveItemCost AS INT = 0
	,@insertedEffectiveItemCost AS INT = 0
	,@warningNotImported AS INT = 0
DECLARE 
	@TotalRowsUpdated AS INT = 0 
	,@TotalRowsInserted AS INT = 0 
	,@TotalRowsSkipped AS INT = 0 

-- Get the original record count. 
SELECT @originalPricebookCount = COUNT(1) 
FROM 
	tblICEdiPricebook p
WHERE 
	p.strUniqueId = @UniqueId

-- Clean the UPC codes 
UPDATE tblICEdiPricebook SET strSellingUpcNumber	= NULLIF(NULLIF(LTRIM(RTRIM(strSellingUpcNumber)), ''), '0') 
						   , strOrderCaseUpcNumber  = NULLIF(NULLIF(LTRIM(RTRIM(strOrderCaseUpcNumber)), ''), '0') 
						   , strAltUPCNumber1		= NULLIF(NULLIF(LTRIM(RTRIM(strAltUPCNumber1)), ''), '0') 
						   , strAltUPCNumber2		= NULLIF(NULLIF(LTRIM(RTRIM(strAltUPCNumber2)), ''), '0') 
WHERE strUniqueId = @UniqueId

-- Get the data for Vendor Item XRef
DECLARE @vendorItemXRef AS TABLE (strSellingUpcNumber				NVARCHAR(50)  COLLATE Latin1_General_CI_AS NULL
								, strVendorsItemNumberForOrdering	NVARCHAR(50)  COLLATE Latin1_General_CI_AS NULL
								, strSellingUpcLongDescription		NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
								, strVendorId						NVARCHAR(50)  COLLATE Latin1_General_CI_AS NULL
								, strItemNo							NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
								, strUpcModifierNumber				NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
								, strUniqueId						UNIQUEIDENTIFIER NULL
)

INSERT INTO @vendorItemXRef (strSellingUpcNumber 
						   , strVendorsItemNumberForOrdering 
						   , strSellingUpcLongDescription 
						   , strVendorId 
						   , strItemNo
						   , strUpcModifierNumber
						   , strUniqueId)
SELECT DISTINCT strSellingUpcNumber 
			  , strVendorsItemNumberForOrdering 
			  , strSellingUpcLongDescription 
			  , strVendorId 
			  , strItemNo
			  , strUpcModifierNumber
			  , strUniqueId 
FROM tblICEdiPricebook
WHERE strUniqueId = @UniqueId;

-- Remove the duplicate records in tblICEdiPricebook
;WITH deleteDuplicate_CTE (intEdiPricebookId
						 , strItemNo
						 , dblDuplicateCount)
AS (SELECT intEdiPricebookId
		 , strItemNo
		 , dblDuplicateCount = ROW_NUMBER() OVER (PARTITION BY strItemNo ORDER BY intEdiPricebookId, strItemNo)
	FROM tblICEdiPricebook
	WHERE strUniqueId = @UniqueId
)
DELETE FROM deleteDuplicate_CTE
WHERE dblDuplicateCount > 1;

-- Remove the UPC code that will trigger the Unique Constraint in tblICItemUOM. 
--DELETE p
--FROM tblICEdiPricebook p
--LEFT JOIN tblICItemUOM u ON ISNULL(NULLIF(u.strLongUPCCode, ''), u.strUpcCode) IN (p.strSellingUpcNumber, p.strOrderCaseUpcNumber ,p.strAltUPCNumber1, p.strAltUPCNumber2) AND u.intModifier IN (CAST(p.strOrderCaseUpcNumber AS BIGINT), ISNULL(NULLIF(p.strAltUPCModifier1, ''),1), ISNULL(NULLIF(p.strAltUPCModifier2, ''), 1))
--OUTER APPLY (SELECT TOP 1 i.intItemId 
--			 FROM tblICItem i 
--			 WHERE i.strItemNo = NULLIF(p.strItemNo ,'')) i		
--OUTER APPLY (SELECT TOP 1 m.*
--			 FROM tblICUnitMeasure m 
--			 WHERE m.strUnitMeasure = NULLIF(p.strItemUnitOfMeasure, '')
--		     ORDER BY m.intUnitMeasureId) m
--OUTER APPLY (SELECT TOP 1 s.*
--			 FROM tblICUnitMeasure s 
--			 WHERE s.strSymbol = NULLIF(p.strItemUnitOfMeasure, '')
--			 ORDER BY m.intUnitMeasureId) s
--OUTER APPLY (SELECT TOP 1 iu.intItemUOMId 
--			 FROM tblICItemUOM iu
--			 WHERE iu.intItemId = i.intItemId AND iu.ysnStockUnit = 1) stockUnit
--OUTER APPLY (SELECT TOP 1 *
--			 FROM tblICItemUOM dup
--			 WHERE dup.intItemId = i.intItemId
--			   AND dup.intItemUOMId <> u.intItemUOMId
--			   AND dup.intUnitMeasureId = COALESCE(m.intUnitMeasureId, s.intUnitMeasureId, u.intUnitMeasureId)) dup
--WHERE p.strUniqueId = @UniqueId AND dup.intItemUOMId IS NOT NULL ;

-- Get the duplicate count. 
--SELECT @duplicatePricebookCount = @originalPricebookCount - COUNT(1) 
--FROM tblICEdiPricebook 
--WHERE strUniqueId = @UniqueId;

-- Retrieve the Category -> Vendor Category XRef setup. 
UPDATE p
SET 
	intCategoryId = vendorCategoryXRef.intCategoryId
	,intVendorId = vendorCategoryXRef.intVendorId
	,ysnAddOrderingUPC = vendorCategoryXRef.ysnAddOrderingUPC
	,ysnUpdateExistingRecords = vendorCategoryXRef.ysnUpdateExistingRecords
	,ysnAddNewRecords = vendorCategoryXRef.ysnAddNewRecords
	,ysnUpdatePrice = vendorCategoryXRef.ysnUpdatePrice
FROM 
	tblICEdiPricebook p
	CROSS APPLY (
		-- Get the top record if there are multiple categories found for a Vendor-Category 
		SELECT TOP 1 
			c.intCategoryId
			,vXRef.intVendorId
			,vXRef.ysnAddOrderingUPC
			,vXRef.ysnUpdateExistingRecords
			,vXRef.ysnAddNewRecords
			,vXRef.ysnUpdatePrice
		FROM 
			tblICCategory c INNER JOIN tblICCategoryVendor vXRef 
				ON c.intCategoryId = vXRef.intCategoryId
			CROSS APPLY (
				SELECT TOP 1 
					v.* 
				FROM 
					vyuAPVendor v
				WHERE 
					((v.strVendorId = p.strVendorId AND @intVendorId IS NULL) OR (v.intEntityId = @intVendorId AND @intVendorId IS NOT NULL))
					AND v.intEntityId = vXRef.intVendorId 
			) v	
		WHERE
			vXRef.strVendorDepartment = p.strVendorCategory	
	) vendorCategoryXRef
WHERE
	p.strUniqueId = @UniqueId

-- Create the temp table for the audit log. 
IF OBJECT_ID('tempdb..#tmpICEdiImportPricebook_tblICItem') IS NULL  
	CREATE TABLE #tmpICEdiImportPricebook_tblICItem (
		intItemId INT
		,strAction NVARCHAR(50) NULL
		,intBrandId_Old INT NULL 
		,intBrandId_New INT NULL 
		,strDescription_Old NVARCHAR(250) NULL
		,strDescription_New NVARCHAR(250) NULL 
		,strShortName_Old NVARCHAR(50) NULL
		,strShortName_New NVARCHAR(50) NULL
		,strItemNo_Old NVARCHAR(50) NULL
		,strItemNo_New NVARCHAR(50) NULL
	)
;

-- Create the temp table for the audit log. 
IF OBJECT_ID('tempdb..#tmpICEdiImportPricebook_tblICItemUOM') IS NULL  
	CREATE TABLE #tmpICEdiImportPricebook_tblICItemUOM (
		intItemId INT
		,intItemUOMId INT
		,strAction NVARCHAR(50) NULL
		,intUnitMeasureId_Old INT NULL
		,intUnitMeasureId_New INT NULL
	)
;

-- Create the temp table for the audit log. 
IF OBJECT_ID('tempdb..#tmpICEdiImportPricebook_tblICItemVendorXref') IS NULL  
	CREATE TABLE #tmpICEdiImportPricebook_tblICItemVendorXref (
		intItemId INT
		,strAction NVARCHAR(50) NULL
		,intVendorId_Old INT NULL 
		,intVendorId_New INT NULL 
		,strVendorProduct_Old NVARCHAR(50) NULL
		,strVendorProduct_New NVARCHAR(50) NULL 
		,strProductDescription_Old NVARCHAR(250) NULL
		,strProductDescription_New NVARCHAR(250) NULL
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
		,dblSalePrice NUMERIC(38, 6) NULL
	)
;


-- Create the temp table for the audit log. 
IF OBJECT_ID('tempdb..#tmpICEdiImportPricebook_tblICEffectiveItemPrice') IS NULL  
	CREATE TABLE #tmpICEdiImportPricebook_tblICEffectiveItemPrice (
		intItemId INT
		,intItemLocationId INT 
		,intEffectiveItemPriceId INT 
		,strAction NVARCHAR(50) NULL
	)
;

-- Create the temp table for the audit log. 
IF OBJECT_ID('tempdb..#tmpICEdiImportPricebook_tblICItemPriceLevel') IS NULL  
	CREATE TABLE #tmpICEdiImportPricebook_tblICItemPriceLevel (
		  intItemId INT
		, intItemLocationId INT 
		, intItemPricingLevelId INT 
		, strAction NVARCHAR(50) NULL
	)
;

-- Create the temp table for the audit log. 
IF OBJECT_ID('tempdb..#tmpICEdiImportPricebook_tblICEffectiveItemCost') IS NULL  
	CREATE TABLE #tmpICEdiImportPricebook_tblICEffectiveItemCost (
		  intItemId INT
		, intItemLocationId INT 
		, intEffectiveItemCostId INT 
		, strAction NVARCHAR(50) NULL
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

-------------------------------------------------
-- BEGIN Validation 
-------------------------------------------------

-- Log the records with invalid Vendor Ids. 
INSERT INTO tblICImportLogDetail(intImportLogId
							   , strType
							   , intRecordNo
							   , strField
							   , strValue
							   , strMessage
							   , strStatus
							   , strAction
							   , intConcurrencyId)
SELECT @LogId
	 , 'Error'
	 , p.intRecordNumber
	 , 'strVendorId'
	 , p.strVendorId
	 , 'Cannot find the Vendor that matches: ' + p.strVendorId
	 , 'Skipped'
	 , 'Record not imported.'
	 , 1
FROM tblICEdiPricebook p
OUTER APPLY (SELECT TOP 1 v.* 
			 FROM vyuAPVendor v
			 WHERE (v.strVendorId = p.strVendorId AND @intVendorId IS NULL) OR (v.intEntityId = @intVendorId AND @intVendorId IS NOT NULL)) v	
WHERE v.intEntityId IS NULL AND p.strUniqueId = @UniqueId

/* Log the records with invalid Selling UPC */

INSERT INTO tblICImportLogDetail(intImportLogId
							   , strType
							   , intRecordNo
							   , strField
							   , strValue
							   , strMessage
							   , strStatus
							   , strAction
							   , intConcurrencyId)
SELECT @LogId
	 , 'Warning'
	 , p.intRecordNumber
	 , 'Selling UPC Number'		
	 , strSellingUpcNumber
	 , 'Invalid UPC Format or Value.'
	 , 'Imported'			
	 , 'Record is imported.'
	 , 1
FROM tblICEdiPricebook p
WHERE NULLIF(dbo.fnSTConvertUPCaToUPCe(strSellingUpcNumber),'') IS NULL AND NULLIF(strSellingUpcNumber,'') IS NULL;

/* Log the records with invalid Order Case UPC */

INSERT INTO tblICImportLogDetail(intImportLogId
							   , strType
							   , intRecordNo
							   , strField
							   , strValue
							   , strMessage
							   , strStatus
							   , strAction
							   , intConcurrencyId)
SELECT @LogId
	 , 'Warning'
	 , p.intRecordNumber
	 , 'Order Case UPC Number'
	 ,  strOrderCaseUpcNumber
	 , 'Invalid UPC Format or Value.'
	 , 'Imported'			
	 , 'Record is imported.'
	 , 1
FROM tblICEdiPricebook p
WHERE NULLIF(dbo.fnSTConvertUPCaToUPCe(strSellingUpcNumber),'') IS NULL AND NULLIF(strOrderCaseUpcNumber,'') IS NULL;


-- Log the records with duplicate records
--INSERT INTO tblICImportLogDetail(
--	intImportLogId
--	, strType
--	, intRecordNo
--	, strField
--	, strValue
--	, strMessage
--	, strStatus
--	, strAction
--	, intConcurrencyId
--)
--SELECT 
--	@LogId
--	, 'Warning'
--	, NULL
--	, NULL 
--	, NULL 
--	, dbo.fnFormatMessage(
--		'There are %i records(s) already exists.'
--		,@duplicatePricebookCount
--		,DEFAULT
--		,DEFAULT
--		,DEFAULT
--		,DEFAULT
--		,DEFAULT
--		,DEFAULT
--		,DEFAULT
--		,DEFAULT
--		,DEFAULT
--	)
--	, 'Skipped'
--	, 'Record not imported.'
--	, 1
--WHERE 
--	@duplicatePricebookCount > 0 

-- Log the records with missing Vendor-Category setup
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
	, 'strVendorCategory'
	, p.strVendorCategory
	, 'Cannot find the Category &#8594; Vendor Category XRef that matches: ' + p.strVendorCategory
	, 'Skipped'
	, 'Record not imported.'
	, 1
FROM 
	tblICEdiPricebook p
WHERE 
	p.strUniqueId = @UniqueId
	AND p.intCategoryId IS NULL 
	AND p.intVendorId IS NULL 	

-- Log the duplicate UOM from strItemUnitOfMeasure
--INSERT INTO tblICImportLogDetail(
--	intImportLogId
--	, strType
--	, intRecordNo
--	, strField
--	, strValue
--	, strMessage
--	, strStatus
--	, strAction
--	, intConcurrencyId
--)
--SELECT 
--	@LogId
--	, 'Error'
--	, intRecordNumber
--	, 'strItemUnitOfMeasure'
--	, strSymbol
--	, 'Duplicate UOM Symbol is used for ' + strUnitMeasure
--	, 'Skipped'
--	, 'Record not imported.'
--	, 1
--FROM (
--		SELECT 
--			strUnitMeasure = u.strUnitMeasure
--			,strSymbol = u.strSymbol
--			,intRecordNumber = p.intRecordNumber
--			,row_no = u.row_no
--		FROM 
--			tblICEdiPricebook p 
--			LEFT JOIN (
--				SELECT * 
--				FROM (
--					SELECT 
--						strUnitMeasure
--						,strSymbol
--						,row_no = ROW_NUMBER() OVER (PARTITION BY u.strSymbol ORDER BY u.strSymbol) 
--					FROM 
--						tblICUnitMeasure u 
--				) x
--				WHERE
--					x.row_no > 1 			
--			) u
--			ON 
--				(p.ysnUpdateExistingRecords = 1 OR p.ysnAddNewRecords = 1) 
--				AND u.strSymbol = NULLIF(p.strItemUnitOfMeasure, '')				
--		WHERE
--			p.strUniqueId = @UniqueId
--	) x
--WHERE
--	x.row_no > 1 

---- Log the duplicate 2nd UOM from strOrderPackageDescription
--INSERT INTO tblICImportLogDetail(intImportLogId
--							   , strType
--							   , intRecordNo
--							   , strField
--							   , strValue
--							   , strMessage
--							   , strStatus
--							   , strAction
--							   , intConcurrencyId
--)
--SELECT @LogId
--	 , 'Error'
--	 , intRecordNumber
--	 , 'strOrderPackageDescription'
--	 , strSymbol
--	 , 'Duplicate UOM Symbol is used for ' + strUnitMeasure
--	 , 'Skipped'
--	 , 'Record not imported.'
--	 , 1
--FROM (SELECT strUnitMeasure = u.strUnitMeasure
--		   , strSymbol = u.strSymbol
--		   , intRecordNumber = p.intRecordNumber
--		   , row_no = u.row_no
--		FROM tblICEdiPricebook p 
--		LEFT JOIN (SELECT * 
--				   FROM (SELECT strUnitMeasure
--							  , strSymbol
--							  , row_no = ROW_NUMBER() OVER (PARTITION BY u.strSymbol ORDER BY u.strSymbol) 
--						FROM tblICUnitMeasure u) x
--		WHERE x.row_no > 1) u ON p.ysnAddOrderingUPC = 1 AND u.strSymbol = NULLIF(p.strOrderPackageDescription, '')				
--		WHERE p.strUniqueId = @UniqueId) x
--WHERE x.row_no > 1 
	
---- Log the duplicate UPC code for the 2nd UOM. 
--INSERT INTO tblICImportLogDetail(
--	intImportLogId
--	, strType
--	, intRecordNo
--	, strField
--	, strValue
--	, strMessage
--	, strStatus
--	, strAction
--	, intConcurrencyId
--)
--SELECT 
--	@LogId
--	, 'Error'
--	, intRecordNumber
--	, 'strOrderCaseUpcNumber'
--	, strOrderCaseUpcNumber
--	, 'Duplicate UPC code is used for ' + strOrderPackageDescription
--	, 'Skipped'
--	, 'Record not imported.'
--	, 1
--FROM 
--	tblICEdiPricebook p
--	LEFT JOIN tblICItemUOM u 
--		--ON ISNULL(NULLIF(u.strLongUPCCode, ''), u.strUpcCode) = p.strSellingUpcNumber
--		ON (
--			ISNULL(NULLIF(RTRIM(LTRIM(u.strLongUPCCode)), ''), RTRIM(LTRIM(u.strUpcCode))) = p.strSellingUpcNumber
--			OR u.intUpcCode = 
--				CASE 
--					WHEN p.strSellingUpcNumber IS NOT NULL 
--						AND ISNUMERIC(RTRIM(LTRIM(p.strSellingUpcNumber))) = 1 
--						AND NOT (p.strSellingUpcNumber LIKE '%.%' OR p.strSellingUpcNumber LIKE '%e%' OR p.strSellingUpcNumber LIKE '%E%') 
--					THEN 
--						CAST(RTRIM(LTRIM(p.strSellingUpcNumber)) AS BIGINT) 
--					ELSE 
--						CAST(NULL AS BIGINT) 	
--				END		
--		)
--	OUTER APPLY (
--		SELECT TOP 1 
--			i.intItemId 
--		FROM
--			tblICItem i 
--		WHERE
--			i.intItemId = u.intItemId
--			OR i.strItemNo = ISNULL(NULLIF(p.strItemNo ,''), p.strSellingUpcNumber)
--	) i
--	OUTER APPLY (
--		SELECT TOP 1 
--			iu.intItemUOMId 
--		FROM 
--			tblICItemUOM iu
--		WHERE
--			iu.intItemId = i.intItemId
--			AND iu.strLongUPCCode = NULLIF(p.strOrderCaseUpcNumber, '0') 
--	) existUOM
--WHERE
--	p.strUniqueId = @UniqueId
--	AND i.intItemId IS NOT NULL 
--	AND NULLIF(p.strOrderCaseUpcNumber, '') IS NOT NULL 
--	AND p.ysnAddOrderingUPC = 1
--	AND existUOM.intItemUOMId IS NOT NULL  

--IF EXISTS (SELECT TOP 1 1 FROM tblICImportLogDetail l WHERE l.intImportLogId = @LogId AND strType = 'Error')
--	GOTO _Exit_With_Errors

---- Log the duplicate UPC code for the 3rd UOM / Alt UPC 1. 
--INSERT INTO tblICImportLogDetail(intImportLogId
--							   , strType
--							   , intRecordNo
--							   , strField
--							   , strValue
--							   , strMessage
--							   , strStatus
--							   , strAction
--							   , intConcurrencyId
--)
--SELECT @LogId
--	 , 'Error'
--	 , intRecordNumber
--	 , 'strAltUPCNumber1 / Alt UPC Number 1'
--	 , strAltUPCNumber1
--	 , 'Duplicate UPC code is used for ' + strAltUPCUOM1
--	 , 'Skipped'
--	 , 'Record not imported.'
--	 , 1
--FROM tblICEdiPricebook p
--OUTER APPLY (SELECT TOP 1 i.intItemId 
--			 FROM tblICItem i 
--			 WHERE i.strItemNo = NULLIF(p.strItemNo ,'')) i
--OUTER APPLY (SELECT TOP 1 iu.intItemUOMId 
--			 FROM tblICItemUOM iu
--			 WHERE iu.intItemId = i.intItemId AND iu.strLongUPCCode = NULLIF(p.strAltUPCNumber1, '')) existUOM
--WHERE p.strUniqueId = @UniqueId 
--  AND i.intItemId IS NOT NULL 
--  AND NULLIF(p.strAltUPCNumber1, '') IS NOT NULL 
--  AND p.ysnAddOrderingUPC = 1 
--  AND existUOM.intItemUOMId IS NOT NULL  
--  AND (p.strAltUPCModifier1 <> p.strAltUPCModifier2 AND p.strAltUPCModifier1 <> strUpcModifierNumber)

--IF EXISTS (SELECT TOP 1 1 FROM tblICImportLogDetail l WHERE l.intImportLogId = @LogId AND strType = 'Error')
--	GOTO _Exit_With_Errors


---- Log the duplicate UPC code for the 4th UOM / Alt UPC 2. 
--INSERT INTO tblICImportLogDetail(intImportLogId
--							   , strType
--							   , intRecordNo
--							   , strField
--							   , strValue
--							   , strMessage
--							   , strStatus
--							   , strAction
--							   , intConcurrencyId
--)
--SELECT @LogId
--	 , 'Error'
--	 , intRecordNumber
--	 , 'strAltUPCNumber2 / Alt UPC Number 2'
--	 , strAltUPCNumber2
--	 , 'Duplicate UPC code is used for ' + strAltUPCUOM2
--	 , 'Skipped'
--	 , 'Record not imported.'
--	 , 1
--FROM tblICEdiPricebook p
--LEFT JOIN tblICItemUOM u ON (ISNULL(NULLIF(RTRIM(LTRIM(u.strLongUPCCode)), ''), RTRIM(LTRIM(u.strUpcCode))) = p.strSellingUpcNumber OR u.intUpcCode = CASE WHEN p.strSellingUpcNumber IS NOT NULL AND ISNUMERIC(RTRIM(LTRIM(p.strSellingUpcNumber))) = 1 AND NOT (p.strSellingUpcNumber LIKE '%.%' OR p.strSellingUpcNumber LIKE '%e%' OR p.strSellingUpcNumber LIKE '%E%') THEN 
--																																							CAST(RTRIM(LTRIM(p.strSellingUpcNumber)) AS BIGINT) 
--																																					  ELSE 
--																																							CAST(NULL AS BIGINT) 	
--																																					  END)
--OUTER APPLY (SELECT TOP 1 i.intItemId 
--			 FROM tblICItem i 
--			 WHERE i.intItemId = u.intItemId OR i.strItemNo = ISNULL(NULLIF(p.strItemNo ,''), p.strSellingUpcNumber)) i
--OUTER APPLY (SELECT TOP 1 iu.intItemUOMId 
--			 FROM tblICItemUOM iu
--			 WHERE iu.intItemId = i.intItemId AND iu.strLongUPCCode = NULLIF(p.strAltUPCNumber2, '0')) existUOM
--WHERE p.strUniqueId = @UniqueId 
--  AND i.intItemId IS NOT NULL 
--  AND NULLIF(p.strAltUPCNumber2, '') IS NOT NULL 
--  AND p.ysnAddOrderingUPC = 1 
--  AND existUOM.intItemUOMId IS NOT NULL  
--  AND (p.strAltUPCModifier1 <> p.strAltUPCModifier2 AND p.strAltUPCModifier2 <> strUpcModifierNumber)

--IF EXISTS (SELECT TOP 1 1 FROM tblICImportLogDetail l WHERE l.intImportLogId = @LogId AND strType = 'Error')
--	GOTO _Exit_With_Errors

-- Log the records with invalid intBottleDepositNo
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
	, 'strBottleDepositNumber'
	, p.strBottleDepositNumber
	, 'Invalid Bottle Deposit No. It should be an integer value.'
	, 'Skipped'
	, 'Record not imported.'
	, 1
FROM 
	tblICEdiPricebook p
WHERE 
	p.strBottleDepositNumber IS NOT NULL 
	AND ISNUMERIC(p.strBottleDepositNumber) = 0 
	AND NULLIF(RTRIM(LTRIM(p.strBottleDepositNumber)), '') IS NOT NULL 
	AND p.strUniqueId = @UniqueId

-------------------------------------------------
-- END Validation 
-------------------------------------------------
-- Remove the pricebook records with the missing Vendor-Category setup
DELETE p
FROM 
	tblICEdiPricebook p
WHERE
	p.strUniqueId = @UniqueId
	AND p.intCategoryId IS NULL 
	AND p.intVendorId IS NULL 

/* Log and remove invalid Item Type */

INSERT INTO tblICImportLogDetail(intImportLogId
							   , strType
							   , intRecordNo
							   , strField
							   , strValue
							   , strMessage
							   , strStatus
							   , strAction
							   , intConcurrencyId
)
SELECT @LogId
	 , 'Error'
	 , PriceBook.intRecordNumber
	 , 'strInventoryType / Inventory Type'
	 , PriceBook.strInventoryType
	 , 'Invalid Inventory Type'
	 , 'Skipped'
	 , 'Record not imported.'
	 , 1
FROM tblICEdiPricebook PriceBook
WHERE NULLIF(PriceBook.strInventoryType,'') IS NOT NULL AND PriceBook.strInventoryType NOT IN ('Inventory'
																						     , 'Non-Inventory'
																						     , 'Other Charge'
																						     , 'Service'
																						     , 'Software'
																						     , 'Comment');

DELETE 
FROM tblICEdiPricebook 
WHERE strUniqueId = @UniqueId AND NULLIF(strInventoryType,'') IS NOT NULL AND strInventoryType NOT IN ('Inventory'
																									 , 'Non-Inventory'
																									 , 'Other Charge'
																									 , 'Service'
																									 , 'Software'
																									 , 'Comment');

/* End of Log and remove invalid Item Type */

/* Log and remove if there is null in required fields of ALT UPC 1 */

INSERT INTO tblICImportLogDetail(intImportLogId
							   , strType
							   , intRecordNo
							   , strField
							   , strValue
							   , strMessage
							   , strStatus
							   , strAction
							   , intConcurrencyId
)
SELECT @LogId
	 , 'Error'
	 , PriceBook.intRecordNumber
	 , 'ALT UPC 1'
	 , PriceBook.strAltUPCNumber1
	 , 'All fields should have a value for ALT UPC 1 if any of the columns for Alt UPC 1 has value'
	 , 'Skipped'
	 , 'Record not imported.'
	 , 1
FROM tblICEdiPricebook AS PriceBook
WHERE (ISNULL(strAltUPCNumber1, '') = ''
OR ISNULL(strAltUPCUOM1, '') = ''
OR ISNULL(strAltUPCQuantity1, '') = ''
OR ISNULL(strAltUPCPrice1, '') = ''
OR ISNULL(strPurchaseSale1, '') = '') AND
(ISNULL(strAltUPCNumber1, '') != ''
OR ISNULL(strAltUPCUOM1, '') != ''
OR ISNULL(strAltUPCQuantity1, '') != ''
OR ISNULL(strAltUPCPrice1, '') != ''
OR ISNULL(strPurchaseSale1, '') != '')

DELETE 
FROM tblICEdiPricebook 
WHERE (ISNULL(strAltUPCNumber1, '') = ''
OR ISNULL(strAltUPCUOM1, '') = ''
OR ISNULL(strAltUPCQuantity1, '') = ''
OR ISNULL(strAltUPCPrice1, '') = ''
OR ISNULL(strPurchaseSale1, '') = '') AND
(ISNULL(strAltUPCNumber1, '') != ''
OR ISNULL(strAltUPCUOM1, '') != ''
OR ISNULL(strAltUPCQuantity1, '') != ''
OR ISNULL(strAltUPCPrice1, '') != ''
OR ISNULL(strPurchaseSale1, '') != '')

/* End of Log and remove if there is null in required fields of ALT UPC 1 */

/* Log and remove if there is null in required fields of ALT UPC 2 */

INSERT INTO tblICImportLogDetail(intImportLogId
							   , strType
							   , intRecordNo
							   , strField
							   , strValue
							   , strMessage
							   , strStatus
							   , strAction
							   , intConcurrencyId
)
SELECT @LogId
	 , 'Error'
	 , PriceBook.intRecordNumber
	 , 'ALT UPC 2'
	 , PriceBook.strAltUPCNumber2
	 , 'All fields should have a value for ALT UPC 2 if any of the columns for Alt UPC 2 has value'
	 , 'Skipped'
	 , 'Record not imported.'
	 , 1
FROM tblICEdiPricebook AS PriceBook
WHERE (ISNULL(strAltUPCNumber2, '') = ''
OR ISNULL(strAltUPCUOM2, '') = ''
OR ISNULL(strAltUPCQuantity2, '') = ''
OR ISNULL(strAltUPCCost2, '') = ''
OR ISNULL(strAltUPCPrice2, '') = '') AND
(ISNULL(strAltUPCNumber2, '') != ''
OR ISNULL(strAltUPCUOM2, '') != ''
OR ISNULL(strAltUPCQuantity2, '') != ''
OR ISNULL(strAltUPCPrice2, '') != ''
OR ISNULL(strPurchaseSale2, '') != '')

DELETE 
FROM tblICEdiPricebook 
WHERE (ISNULL(strAltUPCNumber2, '') = ''
OR ISNULL(strAltUPCUOM2, '') = ''
OR ISNULL(strAltUPCQuantity2, '') = ''
OR ISNULL(strAltUPCCost2, '') = ''
OR ISNULL(strAltUPCPrice2, '') = '') AND
(ISNULL(strAltUPCNumber2, '') != ''
OR ISNULL(strAltUPCUOM2, '') != ''
OR ISNULL(strAltUPCQuantity2, '') != ''
OR ISNULL(strAltUPCPrice2, '') != ''
OR ISNULL(strPurchaseSale2, '') != '')

/* End of Log and remove if there is null in required fields of ALT UPC 2 */

/* Log and remove invalid UOM */

INSERT INTO tblICImportLogDetail(intImportLogId
							   , strType
							   , intRecordNo
							   , strField
							   , strValue
							   , strMessage
							   , strStatus
							   , strAction
							   , intConcurrencyId
)
SELECT @LogId
	 , 'Error'
	 , PriceBook.intRecordNumber
	 , 'strItemUnitOfMeasure / Item Unit of Measure'
	 , PriceBook.strItemUnitOfMeasure
	 , 'Invalid Item Unit of Measure or Item Unit of Measure does not exists'
	 , 'Skipped'
	 , 'Record not imported.'
	 , 1
FROM tblICEdiPricebook AS PriceBook
WHERE NULLIF(strItemUnitOfMeasure, '') NOT IN (SELECT strUnitMeasure
											   FROM tblICUnitMeasure);


DELETE 
FROM tblICEdiPricebook 
WHERE NULLIF(strItemUnitOfMeasure, '') NOT IN (SELECT strUnitMeasure
											   FROM tblICUnitMeasure);

/* End of Log and remove UOM */

/* Log and remove invalid Order Package Description if not null and not same with Item Unit of Measure */

INSERT INTO tblICImportLogDetail(intImportLogId
							   , strType
							   , intRecordNo
							   , strField
							   , strValue
							   , strMessage
							   , strStatus
							   , strAction
							   , intConcurrencyId
)
SELECT @LogId
	 , 'Error'
	 , PriceBook.intRecordNumber
	 , 'strOrderPackageDescription / Order Package Description'
	 , PriceBook.strOrderPackageDescription
	 , 'Invalid Order Package Description or Order Package Description does not exists'
	 , 'Skipped'
	 , 'Record not imported.'
	 , 1
FROM tblICEdiPricebook AS PriceBook
WHERE NULLIF(strOrderPackageDescription, '') IS NOT NULL AND NULLIF(strOrderPackageDescription, '') NOT IN (SELECT strUnitMeasure
																											FROM tblICUnitMeasure);


DELETE 
FROM tblICEdiPricebook 
WHERE NULLIF(strOrderPackageDescription, '') IS NOT NULL AND NULLIF(strOrderPackageDescription, '') NOT IN (SELECT strUnitMeasure
																											FROM tblICUnitMeasure);

/* End of Log and remove UOM */

/* Log and duplicate UOM for Item Pricing Level*/

--INSERT INTO tblICImportLogDetail(intImportLogId
--							   , strType
--							   , intRecordNo
--							   , strField
--							   , strValue
--							   , strMessage
--							   , strStatus
--							   , strAction
--							   , intConcurrencyId
--)
--SELECT @LogId
--	 , 'Error'
--	 , PriceBook.intRecordNumber
--	 , 'Item Unit Measure / Alt UPC UOM'
--	 , PriceBook.strItemUnitOfMeasure
--	 , 'Duplicate UOM found on Item Unit Measure and Alt UPC UOM'
--	 , 'Skipped'
--	 , 'Record not imported.'
--	 , 1
--FROM tblICEdiPricebook AS PriceBook
--WHERE (PriceBook.strAltUPCUOM1 = PriceBook.strItemUnitOfMeasure) OR (PriceBook.strAltUPCUOM2 = PriceBook.strItemUnitOfMeasure)

/* Remove the duplicate Alt UPC UOM & Item Unit Measure */

--DELETE 
--FROM tblICEdiPricebook
--WHERE (strAltUPCUOM1 = strItemUnitOfMeasure) OR (strAltUPCUOM2 = strItemUnitOfMeasure)
/* End of Log of Alt UPC UOM & Item Unit Measure */

/* Log and duplicate UOM for Item Pricing Level*/

INSERT INTO tblICImportLogDetail(intImportLogId
							   , strType
							   , intRecordNo
							   , strField
							   , strValue
							   , strMessage
							   , strStatus
							   , strAction
							   , intConcurrencyId
)
SELECT @LogId
	 , 'Error'
	 , PriceBook.intRecordNumber
	 , 'Alt UPC UOM'
	 , PriceBook.strAltUPCUOM2
	 , 'Duplicate UOM found on Alt UPC UOM 1 and Alt UPC UOM 2'
	 , 'Skipped'
	 , 'Record not imported.'
	 , 1
FROM tblICEdiPricebook AS PriceBook
WHERE (PriceBook.strAltUPCUOM1 = PriceBook.strAltUPCUOM2) AND ISNULL(PriceBook.strAltUPCUOM1, '') != ''

/* Remove the duplicate Alt UPC UOM & Item Unit Measure */

DELETE 
FROM tblICEdiPricebook
WHERE (strAltUPCUOM1 = strAltUPCUOM2) AND ISNULL(strAltUPCUOM1, '') != ''
/* End of Log of Alt UPC UOM & Item Unit Measure */

/* Log Existing UPC and Modifier */

INSERT INTO tblICImportLogDetail(intImportLogId
							   , strType
							   , intRecordNo
							   , strField
							   , strValue
							   , strMessage
							   , strStatus
							   , strAction
							   , intConcurrencyId
)
SELECT @LogId
	 , 'Error'
	 , intRecordNumber
	 , 'Selling UPC Number and Modifier already exists on Item'
	 , DuplicateUPC.strSellingUpcNumber + ' - ' + strUpcModifierNumber
	 , 'Duplicate UPC Number with the same Modifier found.'
	 , 'Skipped'
	 , 'Record not imported.'
	 , 1
FROM(SELECT strSellingUpcNumber, strUpcModifierNumber, intRecordNumber
	 FROM tblICEdiPricebook AS Pricebook	
	 JOIN tblICUnitMeasure AS UnitOfMeasure ON  Pricebook.strItemUnitOfMeasure = UnitOfMeasure.strUnitMeasure
	 JOIN tblICItemUOM AS ItemUOM ON Pricebook.strSellingUpcNumber = ItemUOM.strLongUPCCode 
								AND ISNULL(ItemUOM.intModifier, 0) = ISNULL(NULLIF(Pricebook.strUpcModifierNumber,''), 0)
								AND UnitOfMeasure.intUnitMeasureId <> ItemUOM.intUnitMeasureId
	AND strUniqueId = @UniqueId) AS DuplicateUPC
	

/* Remove the duplicate UPC Selling Number. */

DELETE 
FROM tblICEdiPricebook
WHERE intEdiPricebookId IN  (SELECT intEdiPricebookId
							 FROM tblICEdiPricebook AS Pricebook	
							JOIN tblICUnitMeasure AS UnitOfMeasure ON  Pricebook.strItemUnitOfMeasure = UnitOfMeasure.strUnitMeasure
							JOIN tblICItemUOM AS ItemUOM ON Pricebook.strSellingUpcNumber = ItemUOM.strLongUPCCode 
								AND ISNULL(ItemUOM.intModifier, 0) = ISNULL(NULLIF(Pricebook.strUpcModifierNumber,''), 0)
								AND UnitOfMeasure.intUnitMeasureId <> ItemUOM.intUnitMeasureId
							AND strUniqueId = @UniqueId)

/* End of Log duplicate UPC Selling Number.*/



/* Log Duplicate UPC with modifier. */

INSERT INTO tblICImportLogDetail(intImportLogId
							   , strType
							   , intRecordNo
							   , strField
							   , strValue
							   , strMessage
							   , strStatus
							   , strAction
							   , intConcurrencyId
)
SELECT @LogId
	 , 'Error'
	 , ''
	 , 'Selling UPC Number / Alternate UPC 1 / Alternate UPC 2'
	 , DuplicateUPC.strSellingUpcNumber
	 , 'Duplicate UPC Number with the same Modifier found.'
	 , 'Skipped'
	 , 'Record not imported.'
	 , 1
FROM(
	 SELECT strSellingUpcNumber
	 FROM tblICEdiPricebook 
	 WHERE (strSellingUpcNumber = strAltUPCNumber1 AND strUpcModifierNumber = strAltUPCModifier1) 
	    OR (strSellingUpcNumber = strAltUPCNumber2 AND strUpcModifierNumber = strAltUPCModifier2)
	    OR (strAltUPCNumber1 = strAltUPCNumber2 AND strAltUPCNumber1 = strAltUPCModifier2)
	 UNION
	 SELECT P.strSellingUpcNumber
	 FROM tblICEdiPricebook AS P 
	 JOIN tblICEdiPricebook AS P1 ON ((P.strSellingUpcNumber = P1.strSellingUpcNumber AND P.strUpcModifierNumber = P1.strUpcModifierNumber) 
	 						      OR (P.strAltUPCNumber1 = P1.strAltUPCNumber1 AND P.strAltUPCModifier1 = P1.strAltUPCModifier1) 
	 						      OR (P.strAltUPCNumber2 = P1.strAltUPCNumber2 AND P.strAltUPCModifier1 = P1.strAltUPCModifier2))
								  AND (P.strItemNo <> P1.strItemNo)) AS DuplicateUPC

/* Remove the duplicate UPC Selling Number. */

DELETE 
FROM tblICEdiPricebook
WHERE intEdiPricebookId IN  (SELECT intEdiPricebookId
							 FROM tblICEdiPricebook 
							 WHERE (strSellingUpcNumber = strAltUPCNumber1 AND strUpcModifierNumber = strAltUPCModifier1) 
								OR (strSellingUpcNumber = strAltUPCNumber2 AND strUpcModifierNumber = strAltUPCModifier2)
								OR (strAltUPCNumber1 = strAltUPCNumber2 AND strAltUPCNumber1 = strAltUPCModifier2)
							 UNION
							 SELECT P.intEdiPricebookId
							 FROM tblICEdiPricebook AS P 
							 JOIN tblICEdiPricebook AS P1 ON ((P.strSellingUpcNumber = P1.strSellingUpcNumber AND P.strUpcModifierNumber = P1.strUpcModifierNumber) 
	 													  OR (P.strAltUPCNumber1 = P1.strAltUPCNumber1 AND P.strAltUPCModifier1 = P1.strAltUPCModifier1) 
	 													  OR (P.strAltUPCNumber2 = P1.strAltUPCNumber2 AND P.strAltUPCModifier1 = P1.strAltUPCModifier2))
														  AND (P.strItemNo <> P1.strItemNo))
/* End of Log duplicate UPC Selling Number.*/




SET @missingVendorCategoryXRef = @@ROWCOUNT;	

-- Update or Insert items based on the Category -> Vendor Category XRef. 
INSERT INTO #tmpICEdiImportPricebook_tblICItem (strAction 
											  , intBrandId_Old 
											  , intBrandId_New 
											  , strDescription_Old 
											  , strDescription_New 
											  , strShortName_Old 
											  , strShortName_New 
											  , strItemNo_Old 
											  , strItemNo_New)
SELECT [Changes].strAction
	 , [Changes].intBrandId_Old
	 , [Changes].intBrandId_New
	 , [Changes].strDescription_Old
	 , [Changes].strDescription_New
	 , [Changes].strShortName_Old
	 , [Changes].strShortName_New
	 , [Changes].strItemNo_Old
	 , [Changes].strItemNo_New
FROM (MERGE	INTO dbo.tblICItem WITH	(HOLDLOCK) AS Item
USING (	
	SELECT Item.intItemId 
		 , intBrandId			= ISNULL(b.intBrandId, Item.intBrandId)
		 , strDescription		= CAST(ISNULL(NULLIF(Pricebook.strSellingUpcLongDescription, ''), Item.strDescription) AS NVARCHAR(250))
		 , strShortName			= CAST(ISNULL(ISNULL(NULLIF(Pricebook.strSellingUpcShortDescription, ''), SUBSTRING(Pricebook.strSellingUpcLongDescription, 1, 15)), Item.strShortName) AS NVARCHAR(50))
		 , b.intManufacturerId 
		 , intDuplicateItemId	= dup.intItemId 
		 , intStoreFamilyId		= sf.intSubcategoryId
		 , intStoreClassId		= sc.intSubcategoryId
		 , intSubcategoriesId   = ItemSubCategories.intSubcategoriesId
		 , strStatusId			= CASE WHEN Pricebook.strActiveInactiveDeleteIndicator = 'Y'
										THEN 'Active'
									WHEN Pricebook.strActiveInactiveDeleteIndicator = 'P'
										THEN 'Phased Out'
									WHEN Pricebook.strActiveInactiveDeleteIndicator = 'D'
										THEN 'Discontinued'
									ELSE 'Active' END
		 , Pricebook.* 
	FROM tblICEdiPricebook AS Pricebook
	LEFT JOIN tblICItem AS Item ON LOWER(Item.strItemNo) =  NULLIF(LOWER(Pricebook.strItemNo), '')
	LEFT JOIN tblICBrand b ON b.strBrandName = Pricebook.strManufacturersBrandName	
	LEFT JOIN tblSTSubcategory sc ON sc.strSubcategoryId = CAST(NULLIF(Pricebook.strProductClass, '') AS NVARCHAR(8)) AND sc.strSubcategoryType = 'C'
	LEFT JOIN tblSTSubcategory sf ON sf.strSubcategoryId = CAST(NULLIF(Pricebook.strProductFamily, '') AS NVARCHAR(8)) AND sf.strSubcategoryType = 'F'
	LEFT JOIN tblSTSubCategories ItemSubCategories ON CAST(NULLIF(LOWER(Pricebook.strSubcategory), '') AS NVARCHAR(8)) = LOWER(ItemSubCategories.strSubCategoryCode)
	OUTER APPLY (SELECT TOP 1 dup.*
				 FROM tblICItem dup
				 WHERE dup.strItemNo = NULLIF(Pricebook.strItemNo, '')) dup
	WHERE Pricebook.strUniqueId = @UniqueId		
) AS Source_Query ON Item.intItemId = Source_Query.intItemId 

/* If matched and it is allowed to update, update the item record. */ 
WHEN MATCHED AND Source_Query.ysnUpdateExistingRecords = 1 THEN 
	UPDATE SET intBrandId			= Source_Query.intBrandId
		     , strDescription		= LEFT(Source_Query.strDescription, 250)
		     , strShortName			= LEFT(Source_Query.strShortName, 50)
		     , strItemNo			= (LEFT(Source_Query.strItemNo, 50))
		     , strStatus			= Source_Query.strStatusId
		     , dtmDateModified		= GETDATE()
		     , intModifiedByUserId = @intUserId
		     , intConcurrencyId		= Item.intConcurrencyId + 1
		     , intStoreFamilyId		= Source_Query.intStoreFamilyId
		     , intStoreClassId		= Source_Query.intStoreClassId
		     , intSubcategoriesId	= Source_Query.intSubcategoriesId

/* If not found and it is allowed, insert a new item record. */
WHEN NOT MATCHED AND Source_Query.ysnAddNewRecords = 1 AND Source_Query.intDuplicateItemId IS NULL THEN 
	INSERT (strItemNo
		  , strShortName
		  , strType
		  , strDescription
		  , intManufacturerId
		  , intBrandId
		  , intCategoryId
		  , strStatus
		  , strInventoryTracking
		  , strLotTracking
		  , intLifeTime
		  , dtmDateCreated
		  , intCreatedByUserId
		  , intDataSourceId
		  , intConcurrencyId
		  , intStoreFamilyId
		  , intStoreClassId
		  , intSubcategoriesId)
	VALUES (LEFT(Source_Query.strItemNo, 50)				-- strItemNo
		  , LEFT(Source_Query.strShortName, 50)				-- strShortName
		  , ISNULL(NULLIF(LEFT(Source_Query.strInventoryType, 50), ''), 'Inventory') -- strType
		  , LEFT(Source_Query.strDescription, 250)			-- strDescription
		  , Source_Query.intManufacturerId					-- intManufacturerId
		  , Source_Query.intBrandId							-- intBrandId
		  , Source_Query.intCategoryId						-- intCategoryId
		  , Source_Query.strStatusId						-- strStatus
		  , 'Item Level'									-- strInventoryTracking
		  , 'No'											-- strLotTracking
		  , 0												-- intLifeTime
		  , GETDATE()										-- dtmDateCreated
		  , @intUserId										-- intCreatedByUserId
		  , 2												-- intDataSourceId
		  , 1												-- intConcurrencyId
		  , Source_Query.intStoreFamilyId
		  , Source_Query.intStoreClassId
		  , Source_Query.intSubcategoriesId)
OUTPUT $action
	 , deleted.intBrandId
	 , inserted.intBrandId 
	 , deleted.strDescription
	 , inserted.strDescription
	 , deleted.strShortName
	 , inserted.strShortName
	 , deleted.strItemNo
	 , inserted.strItemNo) AS [Changes] (strAction
									   , intBrandId_Old
									   , intBrandId_New
									   , strDescription_Old
									   , strDescription_New
									   , strShortName_Old
									   , strShortName_New
									   , strItemNo_Old
									   , strItemNo_New);

SELECT @updatedItem = COUNT(1) 
FROM #tmpICEdiImportPricebook_tblICItem 
WHERE strAction = 'UPDATE';

SELECT @insertedItem = COUNT(1) 
FROM #tmpICEdiImportPricebook_tblICItem 
WHERE strAction = 'INSERT';

SELECT @warningNotImported = COUNT(1) 
FROM tblICEdiPricebook 
WHERE strUniqueId = @UniqueId AND ysnAddNewRecords = 0 AND ysnUpdateExistingRecords = 0 AND ysnAddOrderingUPC = 0 AND ysnUpdatePrice = 0;

;
-- Update or Insert Item UOM
INSERT INTO #tmpICEdiImportPricebook_tblICItemUOM (
	intItemId 
	, intItemUOMId 
	, strAction 
	, intUnitMeasureId_Old 
	, intUnitMeasureId_New
)
SELECT [Changes].intItemId
	 , [Changes].intItemUOMId
	 , [Changes].strAction
	 , [Changes].intUnitMeasureId_Old
	 , [Changes].intUnitMeasureId_New
FROM (
MERGE INTO dbo.tblICItemUOM 
WITH (HOLDLOCK) AS ItemUOM
	USING (
		SELECT Item.intItemId 
			 , ISNULL(ItemUOM.intItemUOMId, 0) AS intItemUOMId
			 , intUnitMeasureId = COALESCE(UnitMeasure.intUnitMeasureId, Symbol.intUnitMeasureId)			
			 , ysnStockUnit = CASE WHEN StockUnit.intItemUOMId IS NOT NULL THEN 0 ELSE 1 END 
			 , strUpcModifierNumber = CASE WHEN NULLIF(Pricebook.strUpcModifierNumber, '') IS NULL THEN  ISNULL(ItemUOM.intModifier, 0) ELSE ISNULL(Pricebook.strUpcModifierNumber, 0) END
			 , strSellingUpcNumber =  CASE WHEN NULLIF(Pricebook.strSellingUpcNumber, '') IS NULL THEN ItemUOM.strLongUPCCode ELSE Pricebook.strSellingUpcNumber END
			 , Pricebook.ysnUpdateExistingRecords
			 , Pricebook.ysnAddNewRecords
		FROM 
			tblICEdiPricebook AS Pricebook
			INNER JOIN tblICItem AS Item 
				ON Item.strItemNo = NULLIF(Pricebook.strItemNo, '')
			OUTER APPLY (
				SELECT TOP 1 *
				FROM tblICUnitMeasure 
				WHERE strUnitMeasure = NULLIF(Pricebook.strItemUnitOfMeasure, '')
				ORDER BY intUnitMeasureId
			) AS UnitMeasure
			OUTER APPLY (
				SELECT TOP 1 *
				FROM tblICUnitMeasure 
				WHERE strSymbol = NULLIF(Pricebook.strItemUnitOfMeasure, '')
				ORDER BY intUnitMeasureId
			) AS Symbol
			OUTER APPLY (
				SELECT TOP 1 iu.intItemUOMId 
				FROM tblICItemUOM iu
				WHERE iu.intItemId = Item.intItemId AND iu.ysnStockUnit = 1
			) AS StockUnit
			LEFT JOIN tblICItemUOM AS ItemUOM ON ItemUOM.intItemId = Item.intItemId AND COALESCE(UnitMeasure.intUnitMeasureId, Symbol.intUnitMeasureId)	= ItemUOM.intUnitMeasureId
			
			OUTER APPLY (
				SELECT TOP 1 
					iu.intItemUOMId 
				FROM 
					tblICItemUOM iu
				WHERE
					iu.intItemId = Item.intItemId
					AND (
						iu.intUnitMeasureId = COALESCE(UnitMeasure.intUnitMeasureId, Symbol.intUnitMeasureId)
						OR iu.strLongUPCCode = NULLIF(Pricebook.strSellingUpcNumber, '0') 
					)
			) existUOM
			OUTER APPLY (
				SELECT TOP 1 
					iu.intItemUOMId
				FROM 
					tblICItemUOM iu
				WHERE
					iu.strLongUPCCode = Pricebook.strSellingUpcNumber
			) existUPCCode
		WHERE 
			Pricebook.strUniqueId = @UniqueId
			AND existUOM.intItemUOMId IS NULL  
			AND existUPCCode.intItemUOMId IS NULL 
	) AS Source_Query 
		ON ItemUOM.intItemUOMId = Source_Query.intItemUOMId 
		AND ItemUOM.intItemId = Source_Query.intItemId 

			   
/* If matched and it is allowed to update, update the item uom record. */
WHEN 
	MATCHED 
	AND Source_Query.ysnUpdateExistingRecords = 1 
THEN 
	UPDATE SET intUnitMeasureId		= Source_Query.intUnitMeasureId
		     , strUpcCode			= dbo.fnSTConvertUPCaToUPCe(RIGHT(Source_Query.strSellingUpcNumber, 11)) -- Update the short UPC code. 
		     , intModifiedByUserId  = @intUserId 
		     , intConcurrencyId		= ItemUOM.intConcurrencyId + 1
		     , intCheckDigit		= dbo.fnICValidateCheckDigit(Source_Query.strSellingUpcNumber)
		     , intModifier			= CAST(Source_Query.strUpcModifierNumber AS INT)
			 , strLongUPCCode		= Source_Query.strSellingUpcNumber
			 , strUPCA				= CASE WHEN LEN(Source_Query.strSellingUpcNumber) IN (10, 11, 12) 
											THEN RIGHT('0000' + dbo.fnICValidateUPCCode(Source_Query.strSellingUpcNumber), 12)
											ELSE NULL
											END
			 , strSCC14				=  CASE WHEN LEN(Source_Query.strSellingUpcNumber) IN (10, 11, 12, 13, 14, 15) 
											THEN RIGHT('000000' + dbo.fnICValidateUPCCode(Source_Query.strSellingUpcNumber), 14)
											ELSE NULL
											END
/* If not found and it is allowed, insert a new item uom record. */
WHEN 
	NOT MATCHED 
	AND Source_Query.ysnAddNewRecords = 1 
	AND Source_Query.intItemId IS NOT NULL 
	AND Source_Query.intUnitMeasureId IS NOT NULL 
THEN 
	INSERT (
		intItemId
		, intUnitMeasureId
		, dblUnitQty
		, strUpcCode
		, strLongUPCCode
		, strUPCA
		, strSCC14
		--, intCheckDigit
		, intModifier
		, ysnStockUnit
		, ysnAllowPurchase
		, ysnAllowSale
		, intConcurrencyId
		, dtmDateCreated
		, intCreatedByUserId
		, intDataSourceId
	)
	VALUES (
		Source_Query.intItemId												-- intItemId
		, Source_Query.intUnitMeasureId										-- intUnitMeasureId
		, 1																	-- dblUnitQty
		, dbo.fnSTConvertUPCaToUPCe(RIGHT(Source_Query.strSellingUpcNumber, 11))
		, Source_Query.strSellingUpcNumber 									-- strLongUPCCode
		, CASE WHEN LEN(Source_Query.strSellingUpcNumber) IN (10, 11, 12) 
											THEN RIGHT('0000' + dbo.fnICValidateUPCCode(Source_Query.strSellingUpcNumber), 12)
											ELSE NULL
											END 							-- strUPCA
		, CASE WHEN LEN(Source_Query.strSellingUpcNumber) IN (10, 11, 12, 13, 14, 15) 
											THEN RIGHT('0000' + dbo.fnICValidateUPCCode(Source_Query.strSellingUpcNumber), 14)
											ELSE NULL
											END 							-- strSCC14
		--, dbo.fnICValidateCheckDigit(Source_Query.strSellingUpcNumber)	-- intCheckDigit
		, CAST(Source_Query.strUpcModifierNumber AS INT)					-- intModifier
		, Source_Query.ysnStockUnit											-- ysnStockUnit
		, 1																	-- ysnAllowPurchase
		, 1																	-- ysnAllowSale
		, 1																	-- intConcurrencyId
		, GETDATE()															-- dtmDateCreated
		, @intUserId														-- intCreatedByUserId
		, 2																	-- intDataSourceId
	)
OUTPUT $action
	 , inserted.intItemId
	 , inserted.intItemUOMId
	 , deleted.intUnitMeasureId
	 , inserted.intUnitMeasureId) AS [Changes] (strAction
											  , intItemId
											  , intItemUOMId
											  , intUnitMeasureId_Old
											  , intUnitMeasureId_New);	   	
	
SELECT @updatedItemUOM = COUNT(1) 
FROM #tmpICEdiImportPricebook_tblICItemUOM 
WHERE strAction = 'UPDATE';

SELECT @insertedItemUOM = COUNT(1) 
FROM #tmpICEdiImportPricebook_tblICItemUOM 
WHERE strAction = 'INSERT';

-- Create the valid list of 2nd UOM
DECLARE @valid2ndUOM AS TABLE (intEdiPricebookId INT 
							 , strLongUPCCode	 NVARCHAR(50) NULL 
							 , strUpcCode		 NVARCHAR(50) NULL)

INSERT INTO @valid2ndUOM (intEdiPricebookId
						, strLongUPCCode
						, strUpcCode)
SELECT p.intEdiPricebookId
	 , p.strOrderCaseUpcNumber
	 , dbo.fnSTConvertUPCaToUPCe(RIGHT(p.strOrderCaseUpcNumber, 11))
FROM tblICEdiPricebook p
LEFT JOIN tblICItemUOM u ON ISNULL(NULLIF(u.strLongUPCCode, ''), u.strUpcCode) = p.strSellingUpcNumber
OUTER APPLY (SELECT TOP 1 i.intItemId 
			 FROM tblICItem i 
			 WHERE i.intItemId = u.intItemId OR i.strItemNo = ISNULL(NULLIF(p.strItemNo ,''), p.strSellingUpcNumber)) i		
WHERE p.strUniqueId = @UniqueId
  AND i.intItemId IS NOT NULL 
  AND (NULLIF(p.strCaseBoxSizeQuantityPerCaseBox, '') IS NOT NULL AND NULLIF(p.strOrderPackageDescription, '') IS NOT NULL)
  AND p.ysnAddOrderingUPC = 1

SELECT @duplicate2ndUOMUPCCode = @@ROWCOUNT;

-- Remove the duplicate records in @valid2ndUOM
--;WITH deleteDuplicate2ndUOMLongUPC_CTE (
--	intEdiPricebookId
--	,strLongUPCCode
--	,dblDuplicateCount
--)
--AS (SELECT p.intEdiPricebookId
--		 , p.strLongUPCCode
--		 , dblDuplicateCount = ROW_NUMBER() OVER (PARTITION BY p.strLongUPCCode ORDER BY p.strLongUPCCode)
--	FROM @valid2ndUOM p
--	WHERE p.strLongUPCCode IS NOT NULL		
--)
--DELETE FROM deleteDuplicate2ndUOMLongUPC_CTE
--WHERE dblDuplicateCount > 1;

-- Remove the duplicate records in @valid2ndUOM
--DELETE p 
--FROM tblICItemUOM iu RIGHT JOIN @valid2ndUOM p ON iu.strLongUPCCode = p.strLongUPCCode COLLATE Latin1_General_CI_AS
--WHERE iu.intItemUOMId IS NOT NULL ;

--SELECT @duplicate2ndUOMUPCCode = ISNULL(@duplicate2ndUOMUPCCode, 0) - COUNT(1) 
--FROM  @valid2ndUOM

-- Insert 2nd UOM
INSERT INTO tblICItemUOM (			
	intItemId
	,intUnitMeasureId
	,dblUnitQty
	,strUpcCode
	,strLongUPCCode
	,strUPCA
	,strSCC14
	--,intCheckDigit
	,ysnStockUnit
	,ysnAllowPurchase
	,ysnAllowSale
	,intConcurrencyId
	,dtmDateCreated
	,intCreatedByUserId
	,intDataSourceId
	,intModifier
)
SELECT DISTINCT
	intItemId = i.intItemId 
	,intUnitMeasureId = COALESCE(m.intUnitMeasureId, s.intUnitMeasureId)			
	,dblUnitQty = CAST(p.strCaseBoxSizeQuantityPerCaseBox AS NUMERIC(38, 20)) 
	,strUpcCode = v.strUpcCode
	,p.strOrderCaseUpcNumber
	,strUPCA = CASE WHEN LEN(p.strOrderCaseUpcNumber) IN (10, 11, 12) 
											THEN RIGHT('0000' + dbo.fnICValidateUPCCode(p.strOrderCaseUpcNumber), 12)
											ELSE NULL
											END 
	,strSCC14 = CASE WHEN LEN(p.strOrderCaseUpcNumber) IN (10, 11, 12, 13, 14, 15) 
											THEN RIGHT('0000' + dbo.fnICValidateUPCCode(p.strOrderCaseUpcNumber), 14)
											ELSE NULL
											END
	--,intCheckDigit = dbo.fnICValidateCheckDigit(p.strOrderCaseUpcNumber)
	,ysnStockUnit = 0
	,ysnAllowPurchase = 1
	,ysnAllowSale = CASE WHEN CAST(NULLIF(p.strCaseRetailPrice, '') AS NUMERIC(38, 20)) <> 0 THEN 1 ELSE 0 END 
	,intConcurrencyId = 1
	,dtmDateCreated = GETDATE()
	,intCreatedByUserId = @intUserId
	,intDataSourceId = 2
	, CASE WHEN p.strOrderCaseUpcNumber = p.strSellingUpcNumber THEN CAST(p.strUpcModifierNumber AS INT) + 1
		   ELSE 1
	  END
FROM 
	tblICEdiPricebook p
	INNER JOIN @valid2ndUOM v
		ON p.intEdiPricebookId = v.intEdiPricebookId

	LEFT JOIN tblICItemUOM u 
		--ON ISNULL(NULLIF(u.strLongUPCCode, ''), u.strUpcCode) = p.strSellingUpcNumber
		ON (
			ISNULL(NULLIF(RTRIM(LTRIM(u.strLongUPCCode)), ''), RTRIM(LTRIM(u.strUpcCode))) = p.strSellingUpcNumber
			OR u.intUpcCode = 
				CASE 
					WHEN p.strSellingUpcNumber IS NOT NULL 
						AND ISNUMERIC(RTRIM(LTRIM(p.strSellingUpcNumber))) = 1 
						AND NOT (p.strSellingUpcNumber LIKE '%.%' OR p.strSellingUpcNumber LIKE '%e%' OR p.strSellingUpcNumber LIKE '%E%') 
					THEN 
						CAST(RTRIM(LTRIM(p.strSellingUpcNumber)) AS BIGINT) 
					ELSE 
						CAST(NULL AS BIGINT) 	
				END		
		)
	OUTER APPLY (
		SELECT TOP 1 
			i.intItemId 
		FROM
			tblICItem i 
		WHERE
			i.intItemId = u.intItemId
			OR (i.strItemNo = ISNULL(NULLIF(p.strItemNo ,''), p.strSellingUpcNumber) AND u.intItemId IS NULL) 
	) i			
	OUTER APPLY (			
		SELECT TOP 1 
			m.*
		FROM tblICUnitMeasure m 
		WHERE
			m.strUnitMeasure = NULLIF(p.strOrderPackageDescription, '')
		ORDER BY 
			m.intUnitMeasureId 
	) m
	OUTER APPLY (
		SELECT TOP 1 
			s.*
		FROM tblICUnitMeasure s 
		WHERE
			s.strSymbol = NULLIF(p.strOrderPackageDescription, '')
		ORDER BY 
			s.intUnitMeasureId 
	) s
	OUTER APPLY (
		SELECT TOP 1 
			iu.intItemUOMId 
		FROM 
			tblICItemUOM iu
		WHERE
			iu.intItemId = i.intItemId
			AND iu.ysnStockUnit = 1 
	) stockUnit
	OUTER APPLY (
		SELECT TOP 1 
			iu.intItemUOMId 
		FROM 
			tblICItemUOM iu
		WHERE
			iu.intItemId = i.intItemId
			AND (
				iu.intUnitMeasureId = COALESCE(m.intUnitMeasureId, s.intUnitMeasureId)
				OR (iu.strLongUPCCode = NULLIF(p.strOrderCaseUpcNumber, '0')  AND  iu.intModifier = CAST(ISNULL(NULLIF(CASE WHEN p.strOrderCaseUpcNumber = p.strSellingUpcNumber THEN CAST(p.strUpcModifierNumber AS INT) + 1
																									   ELSE 1
																								  END, ''), 1) AS BIGINT))
			)
	) existUOM
	OUTER APPLY (
		SELECT TOP 1 
			iu.intItemUOMId
		FROM 
			tblICItemUOM iu
		WHERE
			iu.strLongUPCCode = p.strOrderCaseUpcNumber AND iu.intModifier = CAST(ISNULL(NULLIF(CASE WHEN p.strOrderCaseUpcNumber = p.strSellingUpcNumber THEN CAST(p.strUpcModifierNumber AS INT) + 1
																									   ELSE 1
																								  END, ''), 1) AS BIGINT)
	) existUPCCode
WHERE
	p.strUniqueId = @UniqueId
	AND i.intItemId IS NOT NULL 
	AND NULLIF(p.strCaseBoxSizeQuantityPerCaseBox, '') IS NOT NULL 
	AND NULLIF(p.strOrderPackageDescription, '') IS NOT NULL 
	AND p.ysnAddOrderingUPC = 1
	AND stockUnit.intItemUOMId IS NOT NULL 
	AND existUOM.intItemUOMId IS NULL  
	AND existUPCCode.intItemUOMId IS NULL 

SET @insertedItemUOM = ISNULL(@insertedItemUOM, 0) + @@ROWCOUNT;

-- Create the valid list of 1st Alternate UOM
--DECLARE @validAlternate1UOM AS TABLE (intEdiPricebookId INT 
--									, strLongUPCCode	NVARCHAR(50) NULL 
--									, strUpcCode		NVARCHAR(50) NULL
--)

--INSERT INTO @validAlternate1UOM (intEdiPricebookId
--					    	   , strLongUPCCode
--					    	   , strUpcCode
--)
--SELECT p.intEdiPricebookId
--	 , p.strAltUPCNumber1
--	 , dbo.fnSTConvertUPCaToUPCe(p.strAltUPCNumber1)
--FROM tblICEdiPricebook p
--LEFT JOIN tblICItemUOM u ON ISNULL(NULLIF(u.strLongUPCCode, ''), u.strUpcCode) = p.strSellingUpcNumber
--OUTER APPLY (SELECT TOP 1 i.intItemId 
--			 FROM tblICItem i 
--			 WHERE i.intItemId = u.intItemId OR i.strItemNo = NULLIF(p.strItemNo ,'')) i		
--WHERE p.strUniqueId = @UniqueId
--  AND i.intItemId IS NOT NULL 
--  AND (NULLIF(p.strAltUPCQuantity1, '') IS NOT NULL AND NULLIF(p.strAltUPCUOM1, '') IS NOT NULL) 
--  AND NULLIF(dbo.fnSTConvertUPCaToUPCe(p.strAltUPCNumber1),'') IS NOT NULL
--  AND p.ysnAddOrderingUPC = 1

--SELECT @duplicateAlternate1UOMUPCCode = @@ROWCOUNT;

---- Remove the duplicate records in @validAlternate1UOM
--;WITH deleteDuplicateAlternate1UOMLongUPC_CTE (intEdiPricebookId
--											 , strLongUPCCode
--											 , dblDuplicateCount
--)
--AS (SELECT p.intEdiPricebookId
--		 , p.strLongUPCCode
--		 , dblDuplicateCount = ROW_NUMBER() OVER (PARTITION BY p.strLongUPCCode ORDER BY p.strLongUPCCode)
--	FROM @validAlternate1UOM p
--	WHERE p.strLongUPCCode IS NOT NULL		
--)
--DELETE FROM deleteDuplicateAlternate1UOMLongUPC_CTE
--WHERE dblDuplicateCount > 1;

---- Remove the duplicate records in @validAlternate1UOM
--DELETE p 
--FROM tblICItemUOM iu 
--RIGHT JOIN @validAlternate1UOM p ON iu.strLongUPCCode = p.strLongUPCCode COLLATE Latin1_General_CI_AS
--WHERE iu.intItemUOMId IS NOT NULL ;

--SELECT @duplicateAlternate1UOMUPCCode = ISNULL(@duplicateAlternate1UOMUPCCode, 0) - COUNT(1) 
--FROM  @validAlternate1UOM

-- Insert Alternate1 UOM
INSERT INTO tblICItemUOM (intItemId
						, intUnitMeasureId
						, dblUnitQty
						, strUpcCode
						, strLongUPCCode
						, strUPCA
						, strSCC14
						--, intCheckDigit
						, ysnStockUnit
						, ysnAllowPurchase
						, ysnAllowSale
						, intConcurrencyId
						, dtmDateCreated
						, intCreatedByUserId
						, intDataSourceId
						, intModifier
)
SELECT DISTINCT intItemId = i.intItemId 
	 , intUnitMeasureId = COALESCE(m.intUnitMeasureId, s.intUnitMeasureId)			
	 , dblUnitQty = CAST(p.strAltUPCQuantity1 AS NUMERIC(38, 20)) 
	 , strUpcCode = dbo.fnSTConvertUPCaToUPCe(RIGHT(strAltUPCNumber1, 11))
	 , p.strAltUPCNumber1
	 , strUPCA = CASE WHEN LEN(p.strAltUPCNumber1) IN (10, 11, 12) 
											THEN RIGHT('0000' + dbo.fnICValidateUPCCode(p.strAltUPCNumber1), 12)
											ELSE NULL
											END  
	 , strSCC14 = CASE WHEN LEN(p.strAltUPCNumber1) IN (10, 11, 12, 13, 14, 15) 
											THEN RIGHT('0000' + dbo.fnICValidateUPCCode(p.strAltUPCNumber1), 14)
											ELSE NULL
											END  
	 --, intCheckDigit = dbo.fnICValidateCheckDigit(p.strAltUPCNumber1)
	 , ysnStockUnit = 0
	 , ysnAllowPurchase = CASE WHEN NULLIF(p.strPurchaseSale1, '') IS NULL THEN NULL 
							   WHEN p.strPurchaseSale1 = 'P' OR p.strPurchaseSale1 = 'B' THEN 1
							   ELSE 0 
						  END 
	 , ysnAllowSale = CASE WHEN NULLIF(p.strPurchaseSale1, '') IS NULL THEN NULL 
						   WHEN p.strPurchaseSale1 = 'S' OR p.strPurchaseSale1 = 'B' THEN 1
						   ELSE 0 
					  END 
	 , intConcurrencyId = 1
	 , dtmDateCreated = GETDATE()
	 , intCreatedByUserId = @intUserId
	 , intDataSourceId = 2
	 , CASE WHEN p.strSellingUpcNumber = p.strOrderCaseUpcNumber AND p.strSellingUpcNumber = p.strAltUPCNumber1 THEN CAST(p.strUpcModifierNumber AS INT) + 2
			WHEN (p.strSellingUpcNumber = p.strAltUPCNumber1) AND (p.strOrderCaseUpcNumber <> p.strAltUPCNumber1) THEN CAST(p.strUpcModifierNumber AS INT) + 1
			WHEN (p.strSellingUpcNumber <> p.strAltUPCNumber1) AND (p.strOrderCaseUpcNumber = p.strAltUPCNumber1) THEN 2
			ELSE ISNULL(p.strAltUPCModifier1, 1)
	   END
FROM tblICEdiPricebook p
--INNER JOIN @validAlternate1UOM v ON p.intEdiPricebookId = v.intEdiPricebookId
LEFT JOIN tblICItemUOM u ON (ISNULL(NULLIF(RTRIM(LTRIM(u.strLongUPCCode)), ''), RTRIM(LTRIM(u.strUpcCode))) = p.strSellingUpcNumber OR u.intUpcCode = CASE WHEN p.strSellingUpcNumber IS NOT NULL 
																																								AND ISNUMERIC(RTRIM(LTRIM(p.strSellingUpcNumber))) = 1 
																																								AND NOT (p.strSellingUpcNumber LIKE '%.%' OR p.strSellingUpcNumber LIKE '%e%' OR p.strSellingUpcNumber LIKE '%E%') 
																																								THEN CAST(RTRIM(LTRIM(p.strSellingUpcNumber)) AS BIGINT) 
																																						   ELSE CAST(NULL AS BIGINT) 
																																					  END)
OUTER APPLY (SELECT TOP 1 i.intItemId 
			 FROM tblICItem i 
			 WHERE i.intItemId = u.intItemId OR (i.strItemNo = ISNULL(NULLIF(p.strItemNo ,''), p.strSellingUpcNumber) AND u.intItemId IS NULL)) i			
OUTER APPLY (SELECT TOP 1 m.*
			 FROM tblICUnitMeasure m 
			 WHERE m.strUnitMeasure = NULLIF(p.strAltUPCUOM1, '') 
			 ORDER BY m.intUnitMeasureId) m
OUTER APPLY (SELECT TOP 1 s.*
			 FROM tblICUnitMeasure s 
			 WHERE s.strSymbol = NULLIF(p.strAltUPCUOM1, '')
			 ORDER BY s.intUnitMeasureId) s
OUTER APPLY (SELECT TOP 1 iu.intItemUOMId 
			 FROM tblICItemUOM iu
			 WHERE iu.intItemId = i.intItemId AND iu.ysnStockUnit = 1) stockUnit
OUTER APPLY (SELECT TOP 1 iu.intItemUOMId 
			 FROM tblICItemUOM iu
			 WHERE iu.intItemId = i.intItemId AND (iu.intUnitMeasureId = COALESCE(m.intUnitMeasureId, s.intUnitMeasureId) OR (iu.strLongUPCCode = NULLIF(p.strAltUPCNumber1, '0')) AND NULLIF(p.strAltUPCModifier1, '') = iu.intModifier)) existUOM
OUTER APPLY (SELECT TOP 1 iu.intItemUOMId
			 FROM tblICItemUOM iu
			 WHERE iu.strLongUPCCode = p.strAltUPCNumber1 AND iu.intModifier = CAST(ISNULL(NULLIF(p.strAltUPCModifier1, ''), 1) AS BIGINT)) existUPCCode
WHERE p.strUniqueId = @UniqueId
  AND i.intItemId IS NOT NULL 
  AND NULLIF(p.strAltUPCQuantity1, '') IS NOT NULL 
  AND NULLIF(p.strAltUPCUOM1, '') IS NOT NULL 
  AND p.ysnAddOrderingUPC = 1
  AND stockUnit.intItemUOMId IS NOT NULL	
  AND existUOM.intItemUOMId IS NULL   
  AND existUPCCode.intItemUOMId IS NULL 
  --AND NULLIF(dbo.fnSTConvertUPCaToUPCe(p.strAltUPCNumber1),'') IS NOT NULL

SET @insertedItemUOM = ISNULL(@insertedItemUOM, 0) + @@ROWCOUNT;


-- Create the valid list of 2nd Alternate UOM
DECLARE @validAlternate2UOM AS TABLE (intEdiPricebookId INT 
									, strLongUPCCode	NVARCHAR(50) NULL 
									, strUpcCode		NVARCHAR(50) NULL
)

INSERT INTO @validAlternate2UOM (intEdiPricebookId
					    	   , strLongUPCCode
					    	   , strUpcCode
)
SELECT p.intEdiPricebookId
	 , p.strAltUPCNumber2
	 , dbo.fnSTConvertUPCaToUPCe(RIGHT(p.strAltUPCNumber2, 11))
FROM tblICEdiPricebook p
LEFT JOIN tblICItemUOM u ON ISNULL(NULLIF(u.strLongUPCCode, ''), u.strUpcCode) = p.strSellingUpcNumber
OUTER APPLY (SELECT TOP 1 i.intItemId 
			 FROM tblICItem i 
			 WHERE i.intItemId = u.intItemId OR i.strItemNo = ISNULL(NULLIF(p.strItemNo ,''), p.strSellingUpcNumber)) i		
WHERE p.strUniqueId = @UniqueId
  AND i.intItemId IS NOT NULL 
  AND (NULLIF(p.strAltUPCQuantity2, '') IS NOT NULL AND NULLIF(p.strAltUPCUOM2, '') IS NOT NULL)
  --AND NULLIF(dbo.fnSTConvertUPCaToUPCe(p.strAltUPCNumber2),'') IS NOT NULL
  AND p.ysnAddOrderingUPC = 1

SELECT @duplicateAlternate2UOMUPCCode = @@ROWCOUNT;

-- Remove the duplicate records in @validAlternate2UOM
--;WITH deleteDuplicateAlternate2UOMLongUPC_CTE (intEdiPricebookId
--											 , strLongUPCCode
--											 , dblDuplicateCount
--)
--AS (SELECT p.intEdiPricebookId
--		 , p.strLongUPCCode
--		 , dblDuplicateCount = ROW_NUMBER() OVER (PARTITION BY p.strLongUPCCode ORDER BY p.strLongUPCCode)
--	FROM @validAlternate2UOM p
--	WHERE p.strLongUPCCode IS NOT NULL		
--)
--DELETE FROM deleteDuplicateAlternate2UOMLongUPC_CTE
--WHERE dblDuplicateCount > 1;

-- Remove the duplicate records in @validAlternate2UOM
--DELETE p 
--FROM tblICItemUOM iu RIGHT JOIN @validAlternate2UOM p ON iu.strLongUPCCode = p.strLongUPCCode COLLATE Latin1_General_CI_AS
--WHERE iu.intItemUOMId IS NOT NULL ;

--SELECT @duplicateAlternate2UOMUPCCode = ISNULL(@duplicateAlternate2UOMUPCCode, 0) - COUNT(1) 
--FROM  @validAlternate2UOM

-- Insert Alternate2 UOM
INSERT INTO tblICItemUOM (intItemId
						, intUnitMeasureId
						, dblUnitQty
						, strUpcCode
						, strLongUPCCode
						, strUPCA
						, strSCC14
						--, intCheckDigit
						, ysnStockUnit
						, ysnAllowPurchase
						, ysnAllowSale
						, intConcurrencyId
						, dtmDateCreated
						, intCreatedByUserId
						, intDataSourceId
						, intModifier
)
SELECT DISTINCT intItemId = i.intItemId 
	 , intUnitMeasureId = COALESCE(m.intUnitMeasureId, s.intUnitMeasureId)			
	 , dblUnitQty = CAST(p.strAltUPCQuantity2 AS NUMERIC(38, 20)) 
	 , strUpcCode = dbo.fnSTConvertUPCaToUPCe(RIGHT(strAltUPCNumber2, 11))
	 , strLongUPCCode = p.strAltUPCNumber2
	 , strUPCA = CASE WHEN LEN(p.strAltUPCNumber2) IN (10, 11, 12) 
											THEN RIGHT('0000' + dbo.fnICValidateUPCCode(p.strAltUPCNumber2), 12)
											ELSE NULL
											END  
	 , strSCC14 = CASE WHEN LEN(p.strAltUPCNumber2) IN (10, 11, 12, 13, 14, 15) 
											THEN RIGHT('0000' + dbo.fnICValidateUPCCode(p.strAltUPCNumber2), 14)
											ELSE NULL
											END 
	 --, intCheckDigit = dbo.fnICValidateCheckDigit(p.strAltUPCNumber2)
	 , ysnStockUnit = 0
	 , ysnAllowPurchase = CASE WHEN NULLIF(p.strPurchaseSale2, '') IS NULL THEN NULL 
							   WHEN p.strPurchaseSale2 = 'P' OR p.strPurchaseSale2 = 'B' THEN 1
							   ELSE 0 
						  END 
	 , ysnAllowSale = CASE WHEN NULLIF(p.strPurchaseSale2, '') IS NULL THEN NULL 
						   WHEN p.strPurchaseSale2 = 'S' OR p.strPurchaseSale2 = 'B' THEN 1
						   ELSE 0 
					  END 
	 , intConcurrencyId = 1
	 , dtmDateCreated = GETDATE()
	 , intCreatedByUserId = @intUserId
	 , intDataSourceId = 2
	 , CASE WHEN p.strSellingUpcNumber = p.strOrderCaseUpcNumber AND p.strSellingUpcNumber = p.strAltUPCNumber1 AND p.strAltUPCNumber1 = p.strAltUPCNumber2 THEN CAST(p.strUpcModifierNumber AS INT) + 3
			WHEN (p.strSellingUpcNumber = p.strAltUPCNumber1) AND (p.strAltUPCNumber1 = p.strAltUPCNumber2) AND (p.strOrderCaseUpcNumber <> p.strAltUPCNumber1)  THEN CAST(p.strUpcModifierNumber AS INT) + 2
			WHEN (p.strSellingUpcNumber = p.strOrderCaseUpcNumber) AND (p.strOrderCaseUpcNumber = p.strAltUPCNumber2) AND (p.strSellingUpcNumber <> p.strAltUPCNumber1) THEN CAST(p.strUpcModifierNumber AS INT) + 2
			WHEN (p.strAltUPCNumber1 = p.strOrderCaseUpcNumber) AND (p.strOrderCaseUpcNumber = p.strAltUPCNumber2) AND (p.strSellingUpcNumber <> p.strAltUPCNumber2) THEN 3
			WHEN (p.strOrderCaseUpcNumber <> p.strAltUPCNumber2 AND p.strAltUPCNumber2 <> p.strAltUPCNumber1) AND (p.strSellingUpcNumber = p.strAltUPCNumber2) THEN ISNULL(p.strAltUPCModifier1, CAST(p.strUpcModifierNumber AS INT) + 1) 
			WHEN (p.strSellingUpcNumber <> p.strAltUPCNumber2 AND p.strAltUPCNumber2 <> p.strAltUPCNumber1) AND (p.strOrderCaseUpcNumber = p.strAltUPCNumber2) THEN 2
			WHEN (p.strSellingUpcNumber <> p.strAltUPCNumber2 AND p.strAltUPCNumber2 <> p.strOrderCaseUpcNumber) AND (p.strAltUPCNumber1 = p.strAltUPCNumber2) THEN 2
			ELSE ISNULL(p.strAltUPCModifier2, 1)
	   END
FROM tblICEdiPricebook p
--INNER JOIN @validAlternate2UOM v ON p.intEdiPricebookId = v.intEdiPricebookId
LEFT JOIN tblICItemUOM u ON (ISNULL(NULLIF(RTRIM(LTRIM(u.strLongUPCCode)), ''), RTRIM(LTRIM(u.strUpcCode))) = p.strSellingUpcNumber OR u.intUpcCode = CASE WHEN p.strSellingUpcNumber IS NOT NULL 
																																								AND ISNUMERIC(RTRIM(LTRIM(p.strSellingUpcNumber))) = 1 
																																								AND NOT (p.strSellingUpcNumber LIKE '%.%' OR p.strSellingUpcNumber LIKE '%e%' OR p.strSellingUpcNumber LIKE '%E%') 
																																								THEN CAST(RTRIM(LTRIM(p.strSellingUpcNumber)) AS BIGINT) 
																																						   ELSE CAST(NULL AS BIGINT) 
																																					  END)
OUTER APPLY (SELECT TOP 1 i.intItemId 
			 FROM tblICItem i 
			 WHERE i.intItemId = u.intItemId OR (i.strItemNo = ISNULL(NULLIF(p.strItemNo ,''), p.strSellingUpcNumber) AND u.intItemId IS NULL)) i			
OUTER APPLY (SELECT TOP 1 m.*
			 FROM tblICUnitMeasure m 
			 WHERE m.strUnitMeasure = NULLIF(p.strAltUPCUOM2, '') 
			 ORDER BY m.intUnitMeasureId) m
OUTER APPLY (SELECT TOP 1 s.*
			 FROM tblICUnitMeasure s 
			 WHERE s.strSymbol = NULLIF(p.strAltUPCUOM2, '')
			 ORDER BY s.intUnitMeasureId) s
OUTER APPLY (SELECT TOP 1 iu.intItemUOMId 
			 FROM tblICItemUOM iu
			 WHERE iu.intItemId = i.intItemId AND iu.ysnStockUnit = 1) stockUnit
OUTER APPLY (SELECT TOP 1 iu.intItemUOMId 
			 FROM tblICItemUOM iu
			 WHERE iu.intItemId = i.intItemId AND (iu.intUnitMeasureId = COALESCE(m.intUnitMeasureId, s.intUnitMeasureId) OR (iu.strLongUPCCode = NULLIF(p.strAltUPCNumber2, '0')) AND NULLIF(p.strAltUPCModifier2, '') = iu.intModifier)) existUOM
OUTER APPLY (SELECT TOP 1 iu.intItemUOMId
			 FROM tblICItemUOM iu
			 WHERE iu.strLongUPCCode = p.strAltUPCNumber2 AND iu.intModifier = CAST(ISNULL(NULLIF(p.strAltUPCModifier2, ''), 1) AS BIGINT)) existUPCCode
WHERE p.strUniqueId = @UniqueId
  AND i.intItemId IS NOT NULL 
  AND NULLIF(p.strAltUPCQuantity2, '') IS NOT NULL 
  AND NULLIF(p.strAltUPCUOM2, '') IS NOT NULL 
  AND p.ysnAddOrderingUPC = 1
  AND stockUnit.intItemUOMId IS NOT NULL 
  AND existUOM.intItemUOMId IS NULL  
  AND existUPCCode.intItemUOMId IS NULL 
  --AND NULLIF(dbo.fnSTConvertUPCaToUPCe(p.strAltUPCNumber2),'') IS NOT NULL

SET @insertedItemUOM = ISNULL(@insertedItemUOM, 0) + @@ROWCOUNT;

-- Insert the Product Sub Category if it does not exists 
INSERT INTO tblSTSubcategory (strSubcategoryType
							, strSubcategoryId
							, intConcurrencyId)
SELECT DISTINCT strSubcategoryType	= 'C'
			  , strSubcategoryId	= CAST(p.strProductClass AS NVARCHAR(8)) 
			  , intConcurrencyId	= 1	
FROM tblICEdiPricebook p 
LEFT JOIN tblSTSubcategory sc ON sc.strSubcategoryId = CAST(NULLIF(p.strProductClass, '') AS NVARCHAR(8)) AND sc.strSubcategoryType = 'C'
WHERE sc.intSubcategoryId IS NULL AND NULLIF(p.strProductClass, '') IS NOT NULL 

SET @insertedProductClass = ISNULL(@insertedProductClass, 0) + @@ROWCOUNT;

-- Insert the Family Sub Category if it does not exists 
INSERT INTO tblSTSubcategory (
	strSubcategoryType
	,strSubcategoryId
	,intConcurrencyId
)
SELECT 
	DISTINCT 
	strSubcategoryType = 'F'
	,strSubcategoryId = CAST(p.strProductFamily AS NVARCHAR(8)) 
	,intConcurrencyId = 1	
FROM 
	tblICEdiPricebook p LEFT JOIN tblSTSubcategory sc 
		ON sc.strSubcategoryId = CAST(NULLIF(p.strProductFamily, '') AS NVARCHAR(8))
		AND sc.strSubcategoryType = 'F'
WHERE
	sc.intSubcategoryId IS NULL 
	AND NULLIF(p.strProductFamily, '') IS NOT NULL 

SET @insertedFamilyClass = ISNULL(@insertedFamilyClass, 0) + @@ROWCOUNT;

-- Check if import is for all locations
DECLARE @ValidLocations UdtCompanyLocations 
IF EXISTS (SELECT TOP 1 1 FROM @Locations WHERE intCompanyLocationId = -1) 
BEGIN 
	INSERT INTO @ValidLocations (intCompanyLocationId) 
	SELECT ss.intCompanyLocationId
	FROM tblSTStore ss 
	INNER JOIN tblSMCompanyLocation cl ON ss.intCompanyLocationId = cl.intCompanyLocationId
END 
ELSE
BEGIN 
	IF EXISTS (SELECT TOP 1 1 FROM @storeGroup)
		BEGIN
			INSERT INTO @ValidLocations (intCompanyLocationId) 
			SELECT DISTINCT (Store.intCompanyLocationId)
			FROM tblSTStoreGroupDetail AS StoreGroupDetail
			LEFT JOIN tblSTStore AS Store ON StoreGroupDetail.intStoreId = Store.intStoreId
			WHERE StoreGroupDetail.intStoreGroupId IN (SELECT paramStoreGroup.intStoreGroupId
													   FROM @storeGroup AS paramStoreGroup)

		END
	ELSE
		BEGIN
			INSERT INTO @ValidLocations (intCompanyLocationId) 
			SELECT intCompanyLocationId
			FROM @Locations
		END
END 


/* Log Pricing Level*/

INSERT INTO tblICImportLogDetail(intImportLogId
							   , strType
							   , intRecordNo
							   , strField
							   , strValue
							   , strMessage
							   , strStatus
							   , strAction
							   , intConcurrencyId
)
SELECT @LogId
	 , 'Warning'
	 , ''
	 , 'Pricing Level'
	 ,  CompanyLocation.strLocationName
	 , 'Location does not have Pricing Level'
	 , 'Skipped'
	 , 'Pricing Level not Imported'
	 , 1
FROM @ValidLocations AS ValidLocation 
INNER JOIN tblSMCompanyLocation CompanyLocation ON ValidLocation.intCompanyLocationId = CompanyLocation.intCompanyLocationId
LEFT JOIN tblSMCompanyLocationPricingLevel AS PricingLevel ON PricingLevel.intCompanyLocationId = CompanyLocation.intCompanyLocationId 	
WHERE PricingLevel.intCompanyLocationPricingLevelId IS NULL

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
FROM (MERGE	INTO dbo.tblICItemLocation WITH	(HOLDLOCK) AS ItemLocation
USING (
	SELECT Item.intItemId
		 , ItemLocation.intItemLocationId
		 , intClassId						= COALESCE(StoreClass.intSubcategoryId, CategoryLocation.intClassId, ItemLocation.intClassId)
		 , intFamilyId						= COALESCE(StoreFamily.intSubcategoryId, CategoryLocation.intFamilyId, ItemLocation.intFamilyId)
		 , ysnDepositRequired				= ISNULL(CASE Pricebook.strDepositRequired WHEN 'Y' THEN 1 WHEN 'N' THEN 0 ELSE NULL END, ItemLocation.ysnDepositRequired)
		 , ysnPromotionalItem				= ISNULL(CASE Pricebook.strPromotionalItem WHEN 'Y' THEN 1 WHEN 'N' THEN 0 ELSE NULL END, ItemLocation.ysnPromotionalItem)
		 , ysnPrePriced						= ISNULL(ISNULL(CASE Pricebook.strPrePriced WHEN 'Y' THEN 1 WHEN 'N' THEN 0 ELSE NULL END, CategoryLocation.ysnPrePriced), ItemLocation.ysnPrePriced)
		 , dblSuggestedQty					= ISNULL(NULLIF(Pricebook.strSuggestedOrderQuantity, ''), ItemLocation.dblSuggestedQty)
		 , dblMinOrder						= ISNULL(NULLIF(Pricebook.strMinimumOrderQuantity, ''), ItemLocation.dblMinOrder)
		 , intBottleDepositNo				= ISNULL(NULLIF(LTRIM(RTRIM(Pricebook.strBottleDepositNumber)), ''), ItemLocation.intBottleDepositNo)
		 , ysnTaxFlag1						= ISNULL(CASE Pricebook.strTaxFlag1 WHEN 'Y' THEN 1 WHEN 'N' THEN 0 ELSE NULL END, CategoryLocation.ysnUseTaxFlag1) 
		 , ysnTaxFlag2						= ISNULL(CASE Pricebook.strTaxFlag2 WHEN 'Y' THEN 1 WHEN 'N' THEN 0 ELSE NULL END, CategoryLocation.ysnUseTaxFlag2) 
		 , ysnTaxFlag3						= ISNULL(CASE Pricebook.strTaxFlag3 WHEN 'Y' THEN 1 WHEN 'N' THEN 0 ELSE NULL END, CategoryLocation.ysnUseTaxFlag3) 
		 , ysnTaxFlag4						= ISNULL(CASE Pricebook.strTaxFlag4 WHEN 'Y' THEN 1 WHEN 'N' THEN 0 ELSE NULL END, CategoryLocation.ysnUseTaxFlag4) 
		 , ysnApplyBlueLaw1					= CategoryLocation.ysnBlueLaw1 
		 , ysnApplyBlueLaw2					= CategoryLocation.ysnBlueLaw2 
		 , intProductCodeId					= ISNULL(ProductCode.intRegProdId, CategoryLocation.intProductCodeId) 
		 , ysnFoodStampable					= ISNULL(CASE Pricebook.strFoodStamp WHEN 'Y' THEN 1 WHEN 'N' THEN 0 ELSE NULL END, CategoryLocation.ysnFoodStampable)
		 , ysnReturnable					= CategoryLocation.ysnReturnable 
		 , ysnSaleable						= ISNULL(CASE Pricebook.strSaleable WHEN 'Y' THEN 1 WHEN 'N' THEN 0 ELSE NULL END, CategoryLocation.ysnSaleable) 
		 , ysnIdRequiredCigarette			= ISNULL(CASE Pricebook.strIdRequiredCigarettes WHEN 'Y' THEN 1 WHEN 'N' THEN 0 ELSE NULL END, CategoryLocation.ysnIdRequiredCigarette) 
		 , ysnIdRequiredLiquor				= ISNULL(CASE Pricebook.strIdRequiredLiquor WHEN 'Y' THEN 1 WHEN 'N' THEN 0 ELSE NULL END, CategoryLocation.ysnIdRequiredLiquor)
		 , intMinimumAge					= ISNULL(Pricebook.strMinimumAge, CategoryLocation.intMinimumAge)
		 , intCountGroupId					= CountGroup.intCountGroupId
		 , intLocationId					= CountGroupLocation.intCompanyLocationId 
		 , Pricebook.ysnAddOrderingUPC
		 , Pricebook.ysnUpdateExistingRecords
		 , Pricebook.ysnAddNewRecords
		 , Pricebook.ysnUpdatePrice
		 , Vendor.intEntityId
		 , intIssueUOMId					= SaleUOM.intItemUOMId
		 , intReceiveUOMId					= ReceiveUOM.intItemUOMId
		 , ysnOpenPricePLU					= CASE Pricebook.strOpenPLU WHEN 'Y' THEN 1 WHEN 'N' THEN 0 ELSE NULL END
		 , intAllowNegativeInventory		= ISNULL(CASE Pricebook.strAllowNegativeInventory WHEN 'Y' THEN 1 WHEN 'N' THEN 3 ELSE 3 END, ItemLocation.intAllowNegativeInventory) 
		 , intAllowZeroCostTypeId			= ISNULL(CASE Pricebook.strAllowZeroCostTypeId 
													 WHEN 'Y' THEN 2 
													 WHEN 'N' THEN 1 
													 WHEN 'W' THEN 3 
													 WHEN 'P' THEN 4
													 ELSE 1 END, ItemLocation.intAllowZeroCostTypeId) 
	FROM tblICEdiPricebook AS Pricebook
	INNER JOIN tblICItem AS Item ON LOWER(Item.strItemNo) =  NULLIF(LTRIM(RTRIM(LOWER(Pricebook.strItemNo))), '')
	LEFT JOIN tblICCategory AS Category ON Category.intCategoryId = Item.intCategoryId
	LEFT JOIN tblSTSubcategory AS StoreClass ON StoreClass.strSubcategoryId = CAST(NULLIF(Pricebook.strProductClass, '') AS NVARCHAR(8)) AND StoreClass.strSubcategoryType = 'C'
	LEFT JOIN tblSTSubcategory AS StoreFamily ON StoreFamily.strSubcategoryId = CAST(NULLIF(Pricebook.strProductFamily, '') AS NVARCHAR(8)) AND StoreFamily.strSubcategoryType = 'F'
	LEFT JOIN tblICCountGroup AS CountGroup ON CountGroup.strCountGroup = Pricebook.strInventoryGroup 
	OUTER APPLY (SELECT loc.intCompanyLocationId 					
				 FROM @ValidLocations loc 
				 INNER JOIN tblSMCompanyLocation cl ON loc.intCompanyLocationId = cl.intCompanyLocationId) AS CountGroupLocation
	OUTER APPLY (SELECT TOP 1 l.*
				 FROM tblICItemLocation l 
				 WHERE l.intItemId = Item.intItemId AND l.intLocationId = CountGroupLocation.intCompanyLocationId) AS ItemLocation
	LEFT JOIN tblICCategoryLocation AS CategoryLocation ON CategoryLocation.intCategoryId = Category.intCategoryId AND CategoryLocation.intLocationId = ItemLocation.intLocationId
	OUTER APPLY (SELECT TOP 1 m.*
				 FROM tblICUnitMeasure m 
				 WHERE m.strUnitMeasure = NULLIF(Pricebook.strItemUnitOfMeasure, '')
				 ORDER BY m.intUnitMeasureId) AS SaleUnitMeasure
	OUTER APPLY (SELECT TOP 1 s.*
				 FROM tblICUnitMeasure s 
				 WHERE s.strSymbol = NULLIF(Pricebook.strItemUnitOfMeasure, '')
				 ORDER BY s.intUnitMeasureId) AS SaleSymbol
	OUTER APPLY (SELECT TOP 1 saleUOM.intItemUOMId					
				 FROM tblICItemUOM saleUOM
				 WHERE saleUOM.intItemId = Item.intItemId AND saleUOM.intUnitMeasureId = ISNULL(SaleUnitMeasure.intUnitMeasureId, SaleSymbol.intUnitMeasureId)) AS SaleUOM
	-- Receive (Purchase) UOM: strOrderPackageDescription
	OUTER APPLY (SELECT TOP 1 m.*
				 FROM tblICUnitMeasure m 
				 WHERE m.strUnitMeasure = NULLIF(Pricebook.strOrderPackageDescription, '')
				 ORDER BY m.intUnitMeasureId) AS ReceiveUnitMeasure
	OUTER APPLY (SELECT TOP 1 s.*
				 FROM tblICUnitMeasure s 
				 WHERE s.strSymbol = NULLIF(Pricebook.strOrderPackageDescription, '')
				 ORDER BY s.intUnitMeasureId) AS ReceiveSymbol
	OUTER APPLY (SELECT TOP 1 receiveUOM.intItemUOMId					
				 FROM tblICItemUOM receiveUOM
				 WHERE receiveUOM.intItemId = Item.intItemId AND receiveUOM.intUnitMeasureId = ISNULL(ReceiveUnitMeasure.intUnitMeasureId, ReceiveSymbol.intUnitMeasureId)) AS ReceiveUOM
	OUTER APPLY (SELECT TOP 1 v.* 
				 FROM vyuAPVendor v
				 WHERE (v.strVendorId = Pricebook.strVendorId AND @intVendorId IS NULL) OR (v.intEntityId = @intVendorId AND @intVendorId IS NOT NULL)) AS Vendor	
	OUTER APPLY (SELECT TOP 1 intRegProdId
				 FROM tblSTSubcategoryRegProd
				 WHERE strRegProdCode = Pricebook.strProductCode) AS ProductCode
	WHERE Pricebook.strUniqueId = @UniqueId
) AS Source_Query ON ItemLocation.intItemLocationId = Source_Query.intItemLocationId

/* If matched, update the existing item location. */
WHEN MATCHED AND Source_Query.ysnUpdateExistingRecords = 1 THEN 
	UPDATE SET ItemLocation.intClassId					= Source_Query.intClassId
			 , ItemLocation.intFamilyId					= Source_Query.intFamilyId
			 , ItemLocation.ysnDepositRequired			= Source_Query.ysnDepositRequired
			 , ItemLocation.ysnPromotionalItem			= Source_Query.ysnPromotionalItem
			 , ItemLocation.ysnPrePriced				= Source_Query.ysnPrePriced
			 , ItemLocation.dblSuggestedQty				= Source_Query.dblSuggestedQty
			 , ItemLocation.dblMinOrder					= Source_Query.dblMinOrder
			 , ItemLocation.intBottleDepositNo			= Source_Query.intBottleDepositNo
			 , ItemLocation.ysnTaxFlag1					= Source_Query.ysnTaxFlag1
			 , ItemLocation.ysnTaxFlag2					= Source_Query.ysnTaxFlag2
			 , ItemLocation.ysnTaxFlag3					= Source_Query.ysnTaxFlag3
			 , ItemLocation.ysnTaxFlag4					= Source_Query.ysnTaxFlag4
			 , ItemLocation.ysnApplyBlueLaw1			= Source_Query.ysnApplyBlueLaw1
			 , ItemLocation.ysnApplyBlueLaw2			= Source_Query.ysnApplyBlueLaw2
			 , ItemLocation.intProductCodeId			= Source_Query.intProductCodeId
			 , ItemLocation.ysnFoodStampable			= Source_Query.ysnFoodStampable
			 , ItemLocation.ysnReturnable				= Source_Query.ysnReturnable
			 , ItemLocation.ysnSaleable					= Source_Query.ysnSaleable
			 , ItemLocation.ysnIdRequiredCigarette		= Source_Query.ysnIdRequiredCigarette
			 , ItemLocation.ysnIdRequiredLiquor			= Source_Query.ysnIdRequiredLiquor
			 , ItemLocation.intMinimumAge				= Source_Query.intMinimumAge
			 , ItemLocation.intCountGroupId				= Source_Query.intCountGroupId
			 , ItemLocation.intConcurrencyId			= ItemLocation.intConcurrencyId + 1
			 , ItemLocation.intIssueUOMId				= Source_Query.intIssueUOMId
			 , ItemLocation.intReceiveUOMId				= Source_Query.intReceiveUOMId
			 , ItemLocation.intVendorId					= Source_Query.intEntityId
			 , ItemLocation.ysnOpenPricePLU				= Source_Query.ysnOpenPricePLU
			 , ItemLocation.intAllowNegativeInventory	= Source_Query.intAllowNegativeInventory
			 , ItemLocation.intAllowZeroCostTypeId		= Source_Query.intAllowZeroCostTypeId

/* If none is found, insert a new item location. */
WHEN NOT MATCHED AND Source_Query.ysnAddNewRecords = 1 THEN 
INSERT (intItemId
	  , intLocationId
	  , intVendorId
	  , strDescription
	  , intCostingMethod
	  , intAllowNegativeInventory
	  , intSubLocationId
	  , intStorageLocationId
	  , intIssueUOMId
	  , intReceiveUOMId
	  , intGrossUOMId
	  , intFamilyId
	  , intClassId
	  , intProductCodeId
	  , intFuelTankId
	  , strPassportFuelId1
	  , strPassportFuelId2
	  , strPassportFuelId3
	  , ysnTaxFlag1
	  , ysnTaxFlag2
	  , ysnTaxFlag3
	  , ysnTaxFlag4
	  , ysnPromotionalItem
	  , intMixMatchId
	  , ysnDepositRequired
	  , intDepositPLUId
	  , intBottleDepositNo
	  , ysnSaleable
	  , ysnQuantityRequired
	  , ysnScaleItem
	  , ysnFoodStampable
	  , ysnReturnable
	  , ysnPrePriced
	  , ysnOpenPricePLU
	  , ysnLinkedItem
	  , strVendorCategory
	  , ysnCountBySINo
	  , strSerialNoBegin
	  , strSerialNoEnd
	  , ysnIdRequiredLiquor
	  , ysnIdRequiredCigarette
	  , intMinimumAge
	  , ysnApplyBlueLaw1
	  , ysnApplyBlueLaw2
	  , ysnCarWash
	  , intItemTypeCode
	  , intItemTypeSubCode
	  , ysnAutoCalculateFreight
	  , intFreightMethodId
	  , dblFreightRate
	  , intShipViaId
	  , intNegativeInventory
	  , dblReorderPoint
	  , dblMinOrder
	  , dblSuggestedQty
	  , dblLeadTime
	  , strCounted
	  , intCountGroupId
	  , ysnCountedDaily
	  , intAllowZeroCostTypeId
	  , ysnLockedInventory
	  , ysnStorageUnitRequired
	  , strStorageUnitNo
	  , intCostAdjustmentType
	  , ysnActive
	  , intSort
	  , intConcurrencyId
	  , dtmDateCreated
	  , dtmDateModified
	  , intCreatedByUserId
	  , intModifiedByUserId
	  , intDataSourceId)
VALUES (Source_Query.intItemId					-- intItemId
      , Source_Query.intLocationId				-- intLocationId
      , Source_Query.intEntityId				-- intVendorId
      , DEFAULT									-- strDescription
      , 1										-- intCostingMethod
      , Source_Query.intAllowNegativeInventory	-- intAllowNegativeInventory
      , DEFAULT									-- intSubLocationId
      , DEFAULT									-- intStorageLocationId
      , Source_Query.intIssueUOMId				-- intIssueUOMId
      , Source_Query.intReceiveUOMId			-- intReceiveUOMId
      , DEFAULT									-- intGrossUOMId
      , Source_Query.intFamilyId				-- intFamilyId
      , Source_Query.intClassId					-- intClassId
      , Source_Query.intProductCodeId			-- intProductCodeId
      , DEFAULT									-- intFuelTankId
      , DEFAULT									-- strPassportFuelId1
      , DEFAULT									-- strPassportFuelId2
      , DEFAULT									-- strPassportFuelId3
      , Source_Query.ysnTaxFlag1				-- ysnTaxFlag1
      , Source_Query.ysnTaxFlag2				-- ysnTaxFlag2
      , Source_Query.ysnTaxFlag3				-- ysnTaxFlag3
      , Source_Query.ysnTaxFlag4				-- ysnTaxFlag4
      , Source_Query.ysnPromotionalItem			-- ysnPromotionalItem
      , DEFAULT									-- intMixMatchId
      , Source_Query.ysnDepositRequired			-- ysnDepositRequired
      , DEFAULT									-- intDepositPLUId
      , Source_Query.intBottleDepositNo			-- intBottleDepositNo
      , Source_Query.ysnSaleable				-- ysnSaleable
      , DEFAULT									-- ysnQuantityRequired
      , DEFAULT									-- ysnScaleItem
      , Source_Query.ysnFoodStampable			-- ysnFoodStampable
      , Source_Query.ysnReturnable				-- ysnReturnable
      , Source_Query.ysnPrePriced				-- ysnPrePriced
      , Source_Query.ysnOpenPricePLU			-- ysnOpenPricePLU
      , DEFAULT									-- ysnLinkedItem
      , DEFAULT									-- strVendorCategory
      , DEFAULT									-- ysnCountBySINo
      , DEFAULT									-- strSerialNoBegin
      , DEFAULT									-- strSerialNoEnd
      , Source_Query.ysnIdRequiredLiquor		-- ysnIdRequiredLiquor
      , Source_Query.ysnIdRequiredCigarette		-- ysnIdRequiredCigarette
      , Source_Query.intMinimumAge				-- intMinimumAge
      , Source_Query.ysnApplyBlueLaw1			-- ysnApplyBlueLaw1
      , Source_Query.ysnApplyBlueLaw2			-- ysnApplyBlueLaw2
     , DEFAULT									-- ysnCarWash
      , DEFAULT									-- intItemTypeCode
      , DEFAULT									-- intItemTypeSubCode
      , DEFAULT									-- ysnAutoCalculateFreight
      , DEFAULT									-- intFreightMethodId
      , DEFAULT									-- dblFreightRate
      , DEFAULT									-- intShipViaId
      , DEFAULT									-- intNegativeInventory
      , DEFAULT									-- dblReorderPoint
      , Source_Query.dblMinOrder				-- dblMinOrder
      , Source_Query.dblSuggestedQty			-- dblSuggestedQty
      , DEFAULT									-- dblLeadTime
      , DEFAULT									-- strCounted
      , Source_Query.intCountGroupId			-- intCountGroupId
      , DEFAULT									-- ysnCountedDaily
      , Source_Query.intAllowZeroCostTypeId		-- intAllowZeroCostTypeId
      , DEFAULT									-- ysnLockedInventory
      , 0										-- ysnStorageUnitRequired
      , DEFAULT									-- strStorageUnitNo
      , DEFAULT									-- intCostAdjustmentType
      , 1										-- ysnActive
      , DEFAULT									-- intSort
      , 1										-- intConcurrencyId
      , GETDATE()								-- dtmDateCreated
      , DEFAULT--,dtmDateModified
      , @intUserId--,intCreatedByUserId
      , DEFAULT--,intModifiedByUserId
      , 2)		--,intDataSourceId			
OUTPUT $action
	 , inserted.intItemId 
	 , inserted.intItemLocationId			
	 , deleted.intLocationId
	 , inserted.intLocationId) AS [Changes] (strAction
										   , intItemId 
										   , intItemLocationId 
										   , intLocationId_Old
										   , intLocationId_New);

SELECT @updatedItemLocation = COUNT(1) 
FROM #tmpICEdiImportPricebook_tblICItemLocation 
WHERE strAction = 'UPDATE';

SELECT @insertedItemLocation = COUNT(1) 
FROM #tmpICEdiImportPricebook_tblICItemLocation 
WHERE strAction = 'INSERT';

-- Upsert the Item Pricing
INSERT INTO #tmpICEdiImportPricebook_tblICItemPricing (strAction
													 , intItemId
													 , intItemLocationId	
													 , intItemPricingId)
SELECT [Changes].strAction
	 , [Changes].intItemId
	 , [Changes].intItemLocationId 	
	 , [Changes].intItemPricingId 	
FROM (MERGE	INTO dbo.tblICItemPricing WITH (HOLDLOCK) AS ItemPricing
USING (
	SELECT Item.intItemId
		 , ItemLocation.intItemLocationId
		 , Price.intItemPricingId
		 , dblSalePrice			= CAST(CASE WHEN ISNUMERIC(Pricebook.strRetailPrice) = 1 THEN Pricebook.strRetailPrice ELSE Price.dblSalePrice END AS NUMERIC(38, 20))
		 , dblStandardCost		= ISNULL(CASE WHEN ISNUMERIC(Pricebook.strCaseCost) = 1 THEN CAST(Pricebook.strCaseCost AS NUMERIC(38, 20)) 
											  ELSE NULL 
										 END / CASE WHEN ISNUMERIC(Pricebook.strCaseBoxSizeQuantityPerCaseBox) = 1 THEN CAST(Pricebook.strCaseBoxSizeQuantityPerCaseBox AS NUMERIC(38, 20)) 
													ELSE 1
											   END, Price.dblStandardCost)
		 , dblLastCost			= (CASE WHEN ISNULL(Price.dblLastCost, 0) = 0 THEN ISNULL(CASE WHEN ISNUMERIC(Pricebook.strCaseCost) = 1  THEN CAST(Pricebook.strCaseCost AS NUMERIC(38, 20)) / ISNULL(CAST(ISNULL(Pricebook.strCaseBoxSizeQuantityPerCaseBox, '1') AS NUMERIC(16, 8)), 1)
																							  ELSE NULL 
																						  END, Price.dblLastCost)
									   ELSE Price.dblLastCost
								  END)
		 , dblAverageCost		= (CASE WHEN ISNULL(Price.dblAverageCost, 0) = 0 THEN ISNULL(CASE WHEN ISNUMERIC(Pricebook.strCaseCost) = 1 THEN CAST(Pricebook.strCaseCost AS NUMERIC(38, 20)) / ISNULL(CAST(ISNULL(Pricebook.strCaseBoxSizeQuantityPerCaseBox, '1') AS NUMERIC(16, 8)), 1)
																							  ELSE NULL 
																						  END, Price.dblAverageCost)
									   ELSE Price.dblAverageCost
								  END)
		 , Pricebook.ysnAddOrderingUPC
		 , Pricebook.ysnUpdateExistingRecords
		 , Pricebook.ysnAddNewRecords
		 , Pricebook.ysnUpdatePrice
	FROM tblICEdiPricebook Pricebook
	INNER JOIN tblICItem Item ON LOWER(Item.strItemNo) =  NULLIF(LTRIM(RTRIM(LOWER(Pricebook.strItemNo))), '')
	OUTER APPLY (SELECT loc.intCompanyLocationId 
					  , l.*
				FROM @ValidLocations loc INNER JOIN tblSMCompanyLocation cl ON loc.intCompanyLocationId = cl.intCompanyLocationId
				INNER JOIN tblICItemLocation l ON l.intItemId = Item.intItemId AND l.intLocationId = loc.intCompanyLocationId) As ItemLocation
	LEFT JOIN tblICItemPricing AS Price ON Price.intItemId = Item.intItemId AND Price.intItemLocationId = ItemLocation.intItemLocationId
	WHERE Pricebook.strUniqueId = @UniqueId
) AS Source_Query ON ItemPricing.intItemPricingId = Source_Query.intItemPricingId 
	   
/* If matched, update the existing item pricing. */
WHEN MATCHED AND Source_Query.ysnUpdatePrice = 1 THEN 
	UPDATE SET ItemPricing.dblSalePrice			= Source_Query.dblSalePrice
			 , ItemPricing.dblStandardCost		= Source_Query.dblStandardCost
			 , ItemPricing.dblLastCost			= Source_Query.dblLastCost
			 , ItemPricing.dblAverageCost		= Source_Query.dblAverageCost
			 , ItemPricing.dtmDateChanged		= GETDATE()
			 , ItemPricing.dtmDateModified		= GETDATE()
			 , ItemPricing.intModifiedByUserId	= @intUserId

/* If none is found, insert a new item pricing. */
WHEN NOT MATCHED AND Source_Query.intItemId IS NOT NULL AND Source_Query.intItemLocationId IS NOT NULL AND Source_Query.ysnAddNewRecords = 1 THEN 
	INSERT (intItemId
		  , intItemLocationId
		  , dblAmountPercent
		  , dblSalePrice
		  , dblMSRPPrice
		  , strPricingMethod
		  , dblLastCost
		  , dblStandardCost
		  , dblAverageCost
		  , dblEndMonthCost
		  , dblDefaultGrossPrice
		  , intSort
		  , ysnIsPendingUpdate
		  , dtmDateChanged
		  , intConcurrencyId
		  , dtmDateCreated
		  , dtmDateModified
		  , intCreatedByUserId
		  , intModifiedByUserId
		  , intDataSourceId
		  , intImportFlagInternal
		  , ysnAvgLocked)
	VALUES (Source_Query.intItemId			-- intItemId
		  , Source_Query.intItemLocationId	-- intItemLocationId
		  , DEFAULT							-- dblAmountPercent
		  , Source_Query.dblSalePrice		-- dblSalePrice
		  , DEFAULT							-- dblMSRPPrice
		  , 'None'							-- strPricingMethod
		  , Source_Query.dblLastCost		-- dblLastCost
		  , Source_Query.dblStandardCost	-- dblStandardCost
		  , Source_Query.dblAverageCost		-- dblAverageCost
		  , DEFAULT							-- dblEndMonthCost
		  , DEFAULT							-- dblDefaultGrossPrice
		  , DEFAULT							-- intSort
		  , DEFAULT							-- ysnIsPendingUpdate
		  , DEFAULT							-- dtmDateChanged
		  , 1								-- intConcurrencyId
		  , GETDATE()						-- dtmDateCreated
		  , DEFAULT							-- dtmDateModified
		  , @intUserId						-- intCreatedByUserId
		  , DEFAULT							-- intModifiedByUserId
		  , 2								-- intDataSourceId
		  , DEFAULT							-- intImportFlagInternal
		  , DEFAULT)						-- ysnAvgLocked
OUTPUT $action
	 , inserted.intItemId 
	 , inserted.intItemLocationId			
	 , inserted.intItemPricingId) AS [Changes] (strAction
											  , intItemId 
											  , intItemLocationId 
											  , intItemPricingId);

INSERT INTO #tmpICEdiImportPricebook_tblICItemPricing (strAction
													 , intItemId
													 , intItemLocationId	
													 , intItemPricingId)
SELECT [Changes].strAction
	 , [Changes].intItemId
	 , [Changes].intItemLocationId 	
	 , [Changes].intItemPricingId 	
FROM (MERGE	INTO dbo.tblICItemPricing WITH (HOLDLOCK) AS ItemPricing
USING (
	SELECT intItemId				= Item.intItemId
		 , intItemLocationId		= ItemLocation.intItemLocationId
		 , intItemPricingId			= Price.intItemPricingId
		 , dblSalePrice				= CAST(Pricebook.strRetailPrice AS NUMERIC(38, 20)) 
		 , dblStandardCost			= Price.dblStandardCost
		 , dblLastCost				= Price.dblLastCost
		 , dblAverageCost			= Price.dblAverageCost
		 , ysnAddOrderingUPC		= Pricebook.ysnAddOrderingUPC
		 , ysnUpdateExistingRecords = Pricebook.ysnUpdateExistingRecords
		 , ysnAddNewRecords			= Pricebook.ysnAddNewRecords
		 , ysnUpdatePrice			= Pricebook.ysnUpdatePrice
	FROM tblICEdiPricebook AS Pricebook
	INNER JOIN tblICItem AS Item ON LOWER(Item.strItemNo) =  NULLIF(LTRIM(RTRIM(LOWER(Pricebook.strItemNo))), '')
	OUTER APPLY (SELECT loc.intCompanyLocationId 					
				 FROM @ValidLocations loc 
				 INNER JOIN tblSMCompanyLocation cl ON loc.intCompanyLocationId = cl.intCompanyLocationId) AS ValidLocation
	INNER JOIN tblICItemLocation AS ItemLocation ON ItemLocation.intLocationId = ValidLocation.intCompanyLocationId AND ItemLocation.intItemId = Item.intItemId
	LEFT JOIN tblICItemPricing AS Price ON Price.intItemId = Item.intItemId AND Price.intItemLocationId = ItemLocation.intItemLocationId
	WHERE Pricebook.strUniqueId = @UniqueId AND Pricebook.strCaseRetailPrice IS NOT NULL
) AS Source_Query ON ItemPricing.intItemPricingId = Source_Query.intItemPricingId 
	   
/* If matched, update the existing item pricing. */
WHEN MATCHED AND Source_Query.ysnUpdatePrice = 1 THEN 
	UPDATE SET ItemPricing.dblSalePrice			= Source_Query.dblSalePrice
			 , ItemPricing.dblStandardCost		= Source_Query.dblStandardCost
			 , ItemPricing.dblLastCost			= Source_Query.dblLastCost
			 , ItemPricing.dblAverageCost		= Source_Query.dblAverageCost
			 , ItemPricing.dtmDateChanged		= GETDATE()
			 , ItemPricing.dtmDateModified		= GETDATE()
			 , ItemPricing.intModifiedByUserId	= @intUserId

/* If none is found, insert a new item pricing. */
WHEN NOT MATCHED AND Source_Query.intItemId IS NOT NULL AND Source_Query.intItemLocationId IS NOT NULL AND Source_Query.ysnAddNewRecords = 1 THEN 
	INSERT (intItemId
		  , intItemLocationId
		  , dblAmountPercent
		  , dblSalePrice
		  , dblMSRPPrice
		  , strPricingMethod
		  , dblLastCost
		  , dblStandardCost
		  , dblAverageCost
		  , dblEndMonthCost
		  , dblDefaultGrossPrice
		  , intSort
		  , ysnIsPendingUpdate
		  , dtmDateChanged
		  , intConcurrencyId
		  , dtmDateCreated
		  , dtmDateModified
		  , intCreatedByUserId
		  , intModifiedByUserId
		  , intDataSourceId
		  , intImportFlagInternal
		  , ysnAvgLocked)
	VALUES (Source_Query.intItemId			-- intItemId
		  , Source_Query.intItemLocationId	-- intItemLocationId
		  , DEFAULT							-- dblAmountPercent
		  , Source_Query.dblSalePrice		-- dblSalePrice
		  , DEFAULT							-- dblMSRPPrice
		  , 'None'							-- strPricingMethod
		  , Source_Query.dblLastCost		-- dblLastCost
		  , Source_Query.dblStandardCost	-- dblStandardCost
		  , Source_Query.dblAverageCost		-- dblAverageCost
		  , DEFAULT							-- dblEndMonthCost
		  , DEFAULT							-- dblDefaultGrossPrice
		  , DEFAULT							-- intSort
		  , DEFAULT							-- ysnIsPendingUpdate
		  , DEFAULT							-- dtmDateChanged
		  , 1								-- intConcurrencyId
		  , GETDATE()						-- dtmDateCreated
		  , DEFAULT							-- dtmDateModified
		  , @intUserId						-- intCreatedByUserId
		  , DEFAULT							-- intModifiedByUserId
		  , 2								-- intDataSourceId
		  , DEFAULT							-- intImportFlagInternal
		  , DEFAULT)						-- ysnAvgLocked
OUTPUT $action
	 , inserted.intItemId 
	 , inserted.intItemLocationId			
	 , inserted.intItemPricingId) AS [Changes] (strAction
											  , intItemId 
											  , intItemLocationId 
											  , intItemPricingId);

SELECT @updatedItemPricing = COUNT(1) 
FROM #tmpICEdiImportPricebook_tblICItemPricing 
WHERE strAction = 'UPDATE';

SELECT @insertedItemPricing = COUNT(1) 
FROM #tmpICEdiImportPricebook_tblICItemPricing 
WHERE strAction = 'INSERT';

-- Upsert the Effective	Item Pricing
INSERT INTO #tmpICEdiImportPricebook_tblICEffectiveItemPrice (strAction
															, intItemId
															, intItemLocationId	
															, intEffectiveItemPriceId)
SELECT [Changes].strAction
	 , [Changes].intItemId
	 , [Changes].intItemLocationId 	
	 , [Changes].intEffectiveItemPriceId 	
FROM (MERGE	INTO dbo.tblICEffectiveItemPrice WITH (HOLDLOCK) AS	EffectiveItemPrice
USING (
	SELECT Item.intItemId
		 , ItemLocation.intItemLocationId
		 , ItemUOM.intItemUOMId
		 , intCompanyLocationId				= ValidLocation.intCompanyLocationId 
		 , dblRetailPrice					= CAST(NULLIF(Pricebook.strCaseRetailPrice, '') AS NUMERIC(38, 20)) 
		 , dtmEffectiveDate					= CAST(GETUTCDATE() AS DATE)
		 , dtmDateCreated					= GETUTCDATE()		
		 , intCreatedByUserId				= @intUserId
		 , ysnUpdatePrice					= Pricebook.ysnUpdatePrice
	FROM tblICEdiPricebook AS Pricebook
	INNER JOIN tblICItem AS Item ON LOWER(Item.strItemNo) =  NULLIF(LTRIM(RTRIM(LOWER(Pricebook.strItemNo))), '')
	OUTER APPLY (SELECT loc.intCompanyLocationId 					
				 FROM @ValidLocations loc 
				 INNER JOIN tblSMCompanyLocation cl ON loc.intCompanyLocationId = cl.intCompanyLocationId) AS ValidLocation
	INNER JOIN tblICItemLocation AS ItemLocation ON ItemLocation.intLocationId = ValidLocation.intCompanyLocationId AND ItemLocation.intItemId = Item.intItemId
	INNER JOIN vyuICGetItemUOM AS ItemUOM ON Item.intItemId = ItemUOM.intItemId AND LOWER(ItemUOM.strUnitMeasure) = LTRIM(RTRIM(LOWER(Pricebook.strOrderPackageDescription)))
	WHERE Pricebook.strUniqueId = @UniqueId AND Pricebook.strCaseRetailPrice IS NOT NULL AND CAST(NULLIF(Pricebook.strCaseRetailPrice, '') AS NUMERIC(38, 20)) <> 0
	UNION
	SELECT Item.intItemId
		 , ItemLocation.intItemLocationId
		 , ItemUOM.intItemUOMId
		 , intCompanyLocationId = ValidLocation.intCompanyLocationId 
		 , dblRetailPrice = CAST(NULLIF(Pricebook.strRetailPrice, '') AS NUMERIC(38, 20)) 
		 , dtmEffectiveDate = CAST(GETUTCDATE() AS DATE)
		 , dtmDateCreated = GETUTCDATE()		
		 , intCreatedByUserId	= @intUserId
		 , ysnUpdatePrice = Pricebook.ysnUpdatePrice
	FROM tblICEdiPricebook AS Pricebook
	INNER JOIN tblICItem AS Item ON LOWER(Item.strItemNo) =  NULLIF(LTRIM(RTRIM(LOWER(Pricebook.strItemNo))), '')
	OUTER APPLY (SELECT loc.intCompanyLocationId 					
				 FROM @ValidLocations loc 
				 INNER JOIN tblSMCompanyLocation cl ON loc.intCompanyLocationId = cl.intCompanyLocationId) AS ValidLocation
	INNER JOIN tblICItemLocation AS ItemLocation ON ItemLocation.intLocationId = ValidLocation.intCompanyLocationId AND ItemLocation.intItemId = Item.intItemId
	INNER JOIN vyuICGetItemUOM AS ItemUOM ON Item.intItemId = ItemUOM.intItemId AND LOWER(ItemUOM.strUnitMeasure) = LTRIM(RTRIM(LOWER(Pricebook.strItemUnitOfMeasure)))
	WHERE Pricebook.strUniqueId = @UniqueId AND Pricebook.strRetailPrice IS NOT NULL
	
	UNION
	SELECT Item.intItemId
		, ItemLocation.intItemLocationId
		, ItemUOM.intItemUOMId
		, intCompanyLocationId = ValidLocation.intCompanyLocationId 
		, dblPrice			   = CAST(NULLIF(Pricebook.strAltUPCPrice1, '') AS NUMERIC(38, 20)) 
		, dtmEffectiveDate	   = CAST(GETUTCDATE() AS DATE)
		, dtmDateCreated	   = GETUTCDATE()		
		, intCreatedByUserId   = @intUserId
		, ysnUpdatePrice	   = Pricebook.ysnUpdatePrice
	FROM tblICEdiPricebook AS Pricebook
	INNER JOIN tblICItem AS Item ON LOWER(Item.strItemNo) =  NULLIF(LTRIM(RTRIM(LOWER(Pricebook.strItemNo))), '')
	OUTER APPLY (SELECT loc.intCompanyLocationId 					
				 FROM @ValidLocations loc 
				 INNER JOIN tblSMCompanyLocation cl ON loc.intCompanyLocationId = cl.intCompanyLocationId) AS ValidLocation
	INNER JOIN tblICItemLocation AS ItemLocation ON ItemLocation.intLocationId = ValidLocation.intCompanyLocationId AND ItemLocation.intItemId = Item.intItemId
	INNER JOIN vyuICGetItemUOM AS ItemUOM ON Item.intItemId = ItemUOM.intItemId AND LOWER(ItemUOM.strUnitMeasure) = LTRIM(RTRIM(LOWER(Pricebook.strAltUPCUOM1)))
	WHERE Pricebook.strUniqueId = @UniqueId AND CAST(NULLIF(Pricebook.strAltUPCPrice1, '') AS NUMERIC(38, 20)) <> 0
	UNION
	SELECT Item.intItemId
		 , ItemLocation.intItemLocationId
		 , ItemUOM.intItemUOMId
		 , intCompanyLocationId = ValidLocation.intCompanyLocationId 
		 , dblPrice				= CAST(NULLIF(Pricebook.strAltUPCPrice2, '') AS NUMERIC(38, 20)) 
		 , dtmEffectiveDate		= CAST(GETUTCDATE() AS DATE)
		 , dtmDateCreated		= GETUTCDATE()		
		 , intCreatedByUserId	= @intUserId
		 , ysnUpdatePrice		= Pricebook.ysnUpdatePrice
	FROM tblICEdiPricebook AS Pricebook
	INNER JOIN tblICItem AS Item ON LOWER(Item.strItemNo) =  NULLIF(LTRIM(RTRIM(LOWER(Pricebook.strItemNo))), '')
	OUTER APPLY (SELECT loc.intCompanyLocationId 					
				 FROM @ValidLocations loc 
				 INNER JOIN tblSMCompanyLocation cl ON loc.intCompanyLocationId = cl.intCompanyLocationId) AS ValidLocation
	INNER JOIN tblICItemLocation AS ItemLocation ON ItemLocation.intLocationId = ValidLocation.intCompanyLocationId AND ItemLocation.intItemId = Item.intItemId 
	INNER JOIN vyuICGetItemUOM AS ItemUOM ON Item.intItemId = ItemUOM.intItemId AND LOWER(ItemUOM.strUnitMeasure) = LTRIM(RTRIM(LOWER(Pricebook.strAltUPCUOM2)))
	WHERE Pricebook.strUniqueId = @UniqueId AND CAST(NULLIF(Pricebook.strAltUPCPrice2, '') AS NUMERIC(38, 20)) <> 0 
) AS Source_Query ON EffectiveItemPrice.intItemId		  = Source_Query.intItemId 
				 AND EffectiveItemPrice.intItemLocationId = Source_Query.intItemLocationId
				 AND EffectiveItemPrice.intItemUOMId	  = Source_Query.intItemUOMId
				 AND CONVERT(DATE, EffectiveItemPrice.dtmEffectiveRetailPriceDate, 101) = CONVERT(DATE, Source_Query.dtmEffectiveDate, 101) 
	
/* If matched, update the existing effective item pricing. */
WHEN MATCHED AND Source_Query.ysnUpdatePrice = 1 THEN
	UPDATE SET EffectiveItemPrice.dblRetailPrice		= Source_Query.dblRetailPrice
			 , EffectiveItemPrice.dtmDateModified		= GETDATE()
			 , EffectiveItemPrice.intModifiedByUserId	= @intUserId

/* If none is found, insert a new item pricing. */
WHEN NOT MATCHED THEN 
	INSERT (intItemId				
		  , intItemLocationId	
		  , intItemUOMId	
		  , dblRetailPrice		
		  , dtmEffectiveRetailPriceDate
		  , dtmDateCreated		
		  , intCreatedByUserId
		  , intDataSourceId
		  , intImportFlagInternal)
	VALUES (Source_Query.intItemId				  
		  , Source_Query.intItemLocationId	
		  , Source_Query.intItemUOMId	
		  , Source_Query.dblRetailPrice		
		  , Source_Query.dtmEffectiveDate			
		  , Source_Query.dtmDateCreated		
		  , Source_Query.intCreatedByUserId
		  , 2
		  , DEFAULT)
OUTPUT $action
	 , inserted.intItemId 
	 , inserted.intItemLocationId			
	 , inserted.intEffectiveItemPriceId) AS [Changes] (strAction
													 , intItemId 
													 , intItemLocationId 
													 , intEffectiveItemPriceId);

SELECT @updatedEffectiveItemPricing = COUNT(1) 
FROM #tmpICEdiImportPricebook_tblICEffectiveItemPrice 
WHERE strAction = 'UPDATE';

SELECT @insertedEffectiveItemPricing = COUNT(1) 
FROM #tmpICEdiImportPricebook_tblICEffectiveItemPrice 
WHERE strAction = 'INSERT';

-- Update or Insert the Item Pricing Level
INSERT INTO #tmpICEdiImportPricebook_tblICItemPriceLevel (
	strAction
	, intItemId
	, intItemLocationId	
	, intItemPricingLevelId
)
SELECT 
	[Changes].strAction 
	 , [Changes].intItemId
	 , [Changes].intItemLocationId 	
	 , [Changes].intItemPricingLevelId 	
FROM  (MERGE INTO dbo.tblICItemPricingLevel WITH (HOLDLOCK) AS ItemPriceLevel 
USING (
	SELECT Item.intItemId
		 , ItemLocation.intItemLocationId
		 , ItemUOM.intItemUOMId
		 , intCompanyLocationId				= ValidLocation.intCompanyLocationId 
		 , dblUnitPrice						= CAST(NULLIF(Pricebook.strCaseRetailPrice, '') AS NUMERIC(38, 20)) 
		 , dtmEffectiveDate					= CAST(GETUTCDATE() AS DATE)
		 , dtmDateCreated					= GETUTCDATE()		
		 , intCreatedByUserId				= @intUserId
		 , ysnUpdatePrice					= Pricebook.ysnUpdatePrice
		 , intCompanyLocationPricingLevelId = CompanyPricingLevel.intCompanyLocationPricingLevelId
	FROM tblICEdiPricebook AS Pricebook
	INNER JOIN tblICItem AS Item ON LOWER(Item.strItemNo) =  NULLIF(LTRIM(RTRIM(LOWER(Pricebook.strItemNo))), '')
	OUTER APPLY (
		SELECT loc.intCompanyLocationId 					
		FROM 
			@ValidLocations loc INNER JOIN tblSMCompanyLocation cl 
				ON loc.intCompanyLocationId = cl.intCompanyLocationId
	) AS ValidLocation
	OUTER APPLY (
		SELECT TOP 1 
			pl.intCompanyLocationPricingLevelId
		FROM 
			tblSMCompanyLocationPricingLevel pl
		WHERE
			pl.intCompanyLocationId = ValidLocation.intCompanyLocationId 	
	) AS CompanyPricingLevel
	INNER JOIN tblICItemLocation AS ItemLocation ON ItemLocation.intLocationId = ValidLocation.intCompanyLocationId AND ItemLocation.intItemId = Item.intItemId
	INNER JOIN vyuICGetItemUOM AS ItemUOM ON Item.intItemId = ItemUOM.intItemId AND LOWER(ItemUOM.strUnitMeasure) = LTRIM(RTRIM(LOWER(Pricebook.strItemUnitOfMeasure)))
	WHERE Pricebook.strUniqueId = @UniqueId AND CAST(NULLIF(Pricebook.strCaseRetailPrice, '') AS NUMERIC(38, 20)) <> 0
	
	UNION ALL 
	SELECT Item.intItemId
		, ItemLocation.intItemLocationId
		, ItemUOM.intItemUOMId
		, intCompanyLocationId = ValidLocation.intCompanyLocationId 
		, dblUnitPrice = CAST(NULLIF(Pricebook.strAltUPCPrice1, '') AS NUMERIC(38, 20)) 
		, dtmEffectiveDate = CAST(GETUTCDATE() AS DATE)
		, dtmDateCreated = GETUTCDATE()		
		, intCreatedByUserId	= @intUserId
		, ysnUpdatePrice = Pricebook.ysnUpdatePrice
		, intCompanyLocationPricingLevelId = CompanyPricingLevel.intCompanyLocationPricingLevelId
	FROM tblICEdiPricebook AS Pricebook
	INNER JOIN tblICItem AS Item ON LOWER(Item.strItemNo) =  NULLIF(LTRIM(RTRIM(LOWER(Pricebook.strItemNo))), '')
	OUTER APPLY (
		SELECT	loc.intCompanyLocationId 					
		FROM	@ValidLocations loc INNER JOIN tblSMCompanyLocation cl 
				ON loc.intCompanyLocationId = cl.intCompanyLocationId
	) AS ValidLocation
	OUTER APPLY (
		SELECT TOP 1 
			pl.intCompanyLocationPricingLevelId
		FROM 
			tblSMCompanyLocationPricingLevel pl
		WHERE
			pl.intCompanyLocationId = ValidLocation.intCompanyLocationId 	
	) AS CompanyPricingLevel
	INNER JOIN tblICItemLocation AS ItemLocation ON ItemLocation.intLocationId = ValidLocation.intCompanyLocationId AND ItemLocation.intItemId = Item.intItemId
	INNER JOIN vyuICGetItemUOM AS ItemUOM ON Item.intItemId = ItemUOM.intItemId AND LOWER(ItemUOM.strUnitMeasure) = LTRIM(RTRIM(LOWER(Pricebook.strAltUPCUOM1))) AND ItemUOM.intModifier = NULLIF(Pricebook.strAltUPCModifier1,'')
	WHERE 
		Pricebook.strUniqueId = @UniqueId 
		AND CAST(NULLIF(Pricebook.strAltUPCPrice1, '') AS NUMERIC(38, 20)) <> 0 
		--AND dbo.fnSTConvertUPCaToUPCe(Pricebook.strAltUPCNumber1) IS NOT NULL
	
	UNION ALL 
	SELECT Item.intItemId
		 , ItemLocation.intItemLocationId
		 , ItemUOM.intItemUOMId
		 , intCompanyLocationId = ValidLocation.intCompanyLocationId 
		 , dblUnitPrice = CAST(NULLIF(Pricebook.strAltUPCPrice2, '') AS NUMERIC(38, 20)) 
		 , dtmEffectiveDate = CAST(GETUTCDATE() AS DATE)
		 , dtmDateCreated = GETUTCDATE()		
		 , intCreatedByUserId	= @intUserId
		 , ysnUpdatePrice = Pricebook.ysnUpdatePrice
		 , intCompanyLocationPricingLevelId = CompanyPricingLevel.intCompanyLocationPricingLevelId
	FROM tblICEdiPricebook AS Pricebook
	INNER JOIN tblICItem AS Item ON LOWER(Item.strItemNo) =  NULLIF(LTRIM(RTRIM(LOWER(Pricebook.strItemNo))), '')
	OUTER APPLY (
		SELECT loc.intCompanyLocationId 					
		FROM 
			@ValidLocations loc INNER JOIN tblSMCompanyLocation cl 
				ON loc.intCompanyLocationId = cl.intCompanyLocationId
		) AS ValidLocation
	OUTER APPLY (
		SELECT TOP 1 
			pl.intCompanyLocationPricingLevelId
		FROM 
			tblSMCompanyLocationPricingLevel pl
		WHERE
			pl.intCompanyLocationId = ValidLocation.intCompanyLocationId 	
	) AS CompanyPricingLevel
	INNER JOIN tblICItemLocation AS ItemLocation ON ItemLocation.intLocationId = ValidLocation.intCompanyLocationId AND ItemLocation.intItemId = Item.intItemId
	INNER JOIN vyuICGetItemUOM AS ItemUOM ON Item.intItemId = ItemUOM.intItemId AND LOWER(ItemUOM.strUnitMeasure) = LTRIM(RTRIM(LOWER(Pricebook.strAltUPCUOM2))) AND ISNULL(ItemUOM.intModifier, 0) = NULLIF(Pricebook.strAltUPCModifier2,'')
	WHERE 
		Pricebook.strUniqueId = @UniqueId 
		AND CAST(NULLIF(Pricebook.strAltUPCPrice2, '') AS NUMERIC(38, 20)) <> 0 
		--AND dbo.fnSTConvertUPCaToUPCe(Pricebook.strAltUPCNumber2) IS NOT NULL
) AS Source_Query 
	ON ItemPriceLevel.intItemId = Source_Query.intItemId
	AND ItemPriceLevel.intItemLocationId = Source_Query.intItemLocationId
	AND ItemPriceLevel.intItemUnitMeasureId = Source_Query.intItemUOMId
	AND CONVERT(DATE, ItemPriceLevel.dtmEffectiveDate, 101) = CONVERT(DATE, Source_Query.dtmEffectiveDate, 101) 

-- If matched, update the existing item pricing level
WHEN MATCHED AND Source_Query.ysnUpdatePrice = 1 THEN
	UPDATE SET ItemPriceLevel.dblUnitPrice		  = Source_Query.dblUnitPrice
			 , ItemPriceLevel.dtmDateModified	  = GETDATE()
			 , ItemPriceLevel.intModifiedByUserId = @intUserId

-- If none is found, insert a new item pricing level
WHEN NOT MATCHED AND Source_Query.intCompanyLocationPricingLevelId IS NOT NULL THEN 
	INSERT (
		intItemId				
		, intCompanyLocationPricingLevelId	
		, intItemLocationId	
		, intItemUnitMeasureId	
		, dblUnitPrice		
		, dtmEffectiveDate
		, dtmDateCreated		
		, intCreatedByUserId
		, strDataSource
		, strPricingMethod
		, dblUnit
	)
	 VALUES (
		Source_Query.intItemId				
		, Source_Query.intCompanyLocationPricingLevelId	
		, Source_Query.intItemLocationId	
		, Source_Query.intItemUOMId	
		, Source_Query.dblUnitPrice		
		, Source_Query.dtmEffectiveDate			
		, Source_Query.dtmDateCreated		
		, Source_Query.intCreatedByUserId
		, 'Import CSV'
		, 'None'
		, 1
	)
OUTPUT $action
	 , inserted.intItemId 
	 , inserted.intItemLocationId			
	 , inserted.intItemPricingLevelId) AS [Changes] (
		strAction
		, intItemId 
		, intItemLocationId 
		, intItemPricingLevelId
	);

SELECT @updatedEffectiveItemPricing = COUNT(1) 
FROM #tmpICEdiImportPricebook_tblICItemPriceLevel 
WHERE strAction = 'UPDATE';

SELECT @insertedEffectiveItemPricing = COUNT(1) 
FROM #tmpICEdiImportPricebook_tblICItemPriceLevel 
WHERE strAction = 'INSERT';


-- Update or Insert Alternate Item Effective Cost
INSERT INTO #tmpICEdiImportPricebook_tblICEffectiveItemCost (strAction
														   , intItemId
														   , intItemLocationId	
														   , intEffectiveItemCostId)
SELECT [Changes].strAction
	 , [Changes].intItemId
	 , [Changes].intItemLocationId 	
	 , [Changes].intEffectiveItemCostId
FROM (MERGE	INTO dbo.tblICEffectiveItemCost WITH (HOLDLOCK) AS EffectiveItemCost
USING (
	SELECT Item.intItemId
		 , ItemLocation.intItemLocationId
		 , intCompanyLocationId = ValidLocation.intCompanyLocationId 
		 , dblCost			    = CAST(NULLIF(Pricebook.strCaseCost, '') AS NUMERIC(38, 20)) 
		 , dtmEffectiveDate	    = CAST(GETUTCDATE() AS DATE)
		 , dtmDateCreated	    = GETUTCDATE()		
		 , intCreatedByUserId   = @intUserId
		 , ysnUpdatePrice	    = Pricebook.ysnUpdatePrice
	FROM tblICEdiPricebook AS Pricebook
	INNER JOIN tblICItem AS Item ON LOWER(Item.strItemNo) =  NULLIF(LTRIM(RTRIM(LOWER(Pricebook.strItemNo))), '')
	OUTER APPLY (SELECT loc.intCompanyLocationId 					
				 FROM @ValidLocations loc 
				 INNER JOIN tblSMCompanyLocation cl ON loc.intCompanyLocationId = cl.intCompanyLocationId) AS ValidLocation
	INNER JOIN tblICItemLocation AS ItemLocation ON ItemLocation.intLocationId = ValidLocation.intCompanyLocationId AND ItemLocation.intItemId = Item.intItemId
	WHERE Pricebook.strUniqueId = @UniqueId AND CAST(NULLIF(Pricebook.strCaseCost, '') AS NUMERIC(38, 20)) <> 0 
	--UNION
	--SELECT Item.intItemId
	--	, ItemLocation.intItemLocationId
	--	, intCompanyLocationId = ValidLocation.intCompanyLocationId 
	--	, dblCost			   = CAST(NULLIF(Pricebook.strAltUPCCost1, '') AS NUMERIC(38, 20)) 
	--	, dtmEffectiveDate	   = CAST(GETUTCDATE() AS DATE)
	--	, dtmDateCreated	   = GETUTCDATE()		
	--	, intCreatedByUserId   = @intUserId
	--	, ysnUpdatePrice	   = Pricebook.ysnUpdatePrice
	--FROM tblICEdiPricebook AS Pricebook
	--INNER JOIN tblICItem AS Item ON LOWER(Item.strItemNo) =  NULLIF(LTRIM(RTRIM(LOWER(Pricebook.strItemNo))), '')
	--OUTER APPLY (SELECT loc.intCompanyLocationId 					
	--			 FROM @ValidLocations loc 
	--			 INNER JOIN tblSMCompanyLocation cl ON loc.intCompanyLocationId = cl.intCompanyLocationId) AS ValidLocation
	--INNER JOIN tblICItemLocation AS ItemLocation ON ItemLocation.intLocationId = ValidLocation.intCompanyLocationId AND ItemLocation.intItemId = Item.intItemId
	--WHERE Pricebook.strUniqueId = @UniqueId AND CAST(NULLIF(Pricebook.strAltUPCCost1, '') AS NUMERIC(38, 20)) <> 0
	--UNION
	--SELECT Item.intItemId
	--	 , ItemLocation.intItemLocationId
	--	 , intCompanyLocationId = ValidLocation.intCompanyLocationId 
	--	 , dblCost				= CAST(NULLIF(Pricebook.strAltUPCCost2, '') AS NUMERIC(38, 20)) 
	--	 , dtmEffectiveDate		= CAST(GETUTCDATE() AS DATE)
	--	 , dtmDateCreated		= GETUTCDATE()		
	--	 , intCreatedByUserId	= @intUserId
	--	 , ysnUpdatePrice		= Pricebook.ysnUpdatePrice
	--FROM tblICEdiPricebook AS Pricebook
	--INNER JOIN tblICItem AS Item ON LOWER(Item.strItemNo) =  NULLIF(LTRIM(RTRIM(LOWER(Pricebook.strItemNo))), '')
	--OUTER APPLY (SELECT loc.intCompanyLocationId 					
	--			 FROM @ValidLocations loc 
	--			 INNER JOIN tblSMCompanyLocation cl ON loc.intCompanyLocationId = cl.intCompanyLocationId) AS ValidLocation
	--INNER JOIN tblICItemLocation AS ItemLocation ON ItemLocation.intLocationId = ValidLocation.intCompanyLocationId AND ItemLocation.intItemId = Item.intItemId 
	--WHERE Pricebook.strUniqueId = @UniqueId AND CAST(NULLIF(Pricebook.strAltUPCCost2, '') AS NUMERIC(38, 20)) <> 0 
) AS Source_Query ON EffectiveItemCost.intItemId = Source_Query.intItemId 
			     AND EffectiveItemCost.intItemLocationId = Source_Query.intItemLocationId
			     AND CONVERT(DATE, EffectiveItemCost.dtmEffectiveCostDate, 101) = CONVERT(DATE, Source_Query.dtmEffectiveDate, 101) 

/* If matched, update the existing effective item pricing. */
WHEN MATCHED AND Source_Query.ysnUpdatePrice = 1 THEN
	UPDATE SET EffectiveItemCost.dblCost		     = Source_Query.dblCost
			 , EffectiveItemCost.dtmDateModified	 = GETDATE()
			 , EffectiveItemCost.intModifiedByUserId = @intUserId
	
/* If none is found, insert a new item pricing. */
WHEN NOT MATCHED THEN 
	INSERT (intItemId				
		  , intItemLocationId	
		  , dblCost		
		  , dtmEffectiveCostDate
		  , dtmDateCreated		
		  , intCreatedByUserId
		  , intDataSourceId
		  , intImportFlagInternal)
	VALUES (Source_Query.intItemId				
		  , Source_Query.intItemLocationId	
		  , Source_Query.dblCost		
		  , Source_Query.dtmEffectiveDate			
		  , Source_Query.dtmDateCreated		
		  , Source_Query.intCreatedByUserId
		  , 2
		  , DEFAULT)
OUTPUT $action
	 , inserted.intItemId 
	 , inserted.intItemLocationId			
	 , inserted.intEffectiveItemCostId) AS [Changes] (strAction
													, intItemId 
													, intItemLocationId 
													, intEffectiveItemCostId
);

SELECT @updatedEffectiveItemCost = COUNT(1) 
FROM #tmpICEdiImportPricebook_tblICEffectiveItemCost 
WHERE strAction = 'UPDATE';

SELECT @insertedEffectiveItemCost = COUNT(1) 
FROM #tmpICEdiImportPricebook_tblICEffectiveItemCost 
WHERE strAction = 'INSERT';
	
-- Upsert the Item Special Pricing
INSERT INTO #tmpICEdiImportPricebook_tblICItemSpecialPricing (strAction
															, intItemId
															, intItemLocationId	
															, intItemSpecialPricingId)
SELECT [Changes].strAction
	 , [Changes].intItemId
	 , [Changes].intItemLocationId 	
	 , [Changes].intItemSpecialPricingId 	
FROM (MERGE	INTO dbo.tblICItemSpecialPricing WITH (HOLDLOCK) AS ItemSpecialPricing
USING (
	SELECT Item.intItemId
		 , ItemLocation.intItemLocationId
		 , Price.intItemSpecialPricingId
		 , UnitOfMeasure.intItemUOMId 
		 , CompanyPreference.intDefaultCurrencyId
		 , dblUnitAfterDiscount = CAST(CASE WHEN ISNUMERIC(Pricebook.strSalePrice) = 1 THEN Pricebook.strSalePrice ELSE Price.dblUnitAfterDiscount END AS NUMERIC(38, 20))
		 , dtmBeginDate = CAST(CASE WHEN ISDATE(Pricebook.strSaleStartDate) = 1 THEN Pricebook.strSaleStartDate ELSE Price.dtmBeginDate END AS DATETIME)
		 , dtmEndDate = CAST(CASE WHEN ISDATE(Pricebook.strSaleEndingDate) = 1 THEN Pricebook.strSaleEndingDate ELSE Price.dtmEndDate END AS DATETIME)
		 , Pricebook.ysnAddOrderingUPC
		 , Pricebook.ysnUpdateExistingRecords
		 , Pricebook.ysnAddNewRecords
		 , Pricebook.ysnUpdatePrice
	FROM tblICEdiPricebook AS Pricebook
	INNER JOIN tblICItem AS Item ON LOWER(Item.strItemNo) =  NULLIF(LTRIM(RTRIM(LOWER(Pricebook.strItemNo))), '')
	INNER JOIN tblICItemUOM AS UnitOfMeasure ON UnitOfMeasure.intItemId = Item.intItemId AND ISNULL(UnitOfMeasure.intModifier, 0) = ISNULL(NULLIF(Pricebook.strUpcModifierNumber,''), 0) AND UnitOfMeasure.strLongUPCCode =  NULLIF(Pricebook.strSellingUpcNumber,'')	
	OUTER APPLY (SELECT loc.intCompanyLocationId 
					  , l.*
				 FROM @ValidLocations loc 
				 INNER JOIN tblICItemLocation l ON l.intItemId = Item.intItemId AND loc.intCompanyLocationId = l.intLocationId) AS ItemLocation
	LEFT JOIN tblICItemSpecialPricing AS Price ON Price.intItemId = Item.intItemId AND Price.intItemLocationId = ItemLocation.intItemLocationId
	OUTER APPLY (SELECT TOP 1 intDefaultCurrencyId 
				 FROM tblSMCompanyPreference) AS CompanyPreference
	WHERE Pricebook.strUniqueId = @UniqueId
) AS Source_Query ON ItemSpecialPricing.intItemSpecialPricingId = Source_Query.intItemSpecialPricingId 
				 AND ItemSpecialPricing.dtmBeginDate = Source_Query.dtmBeginDate 
				 AND ItemSpecialPricing.dtmEndDate = Source_Query.dtmEndDate 
				 AND ItemSpecialPricing.strPromotionType = 'Discount'
	
/* If matched, update the existing special pricing. */
WHEN MATCHED AND Source_Query.ysnUpdatePrice = 1 THEN 
	UPDATE SET dblUnitAfterDiscount = Source_Query.dblUnitAfterDiscount

/* If none is found, insert a new special pricing. */
WHEN NOT MATCHED AND Source_Query.intItemId IS NOT NULL AND Source_Query.intItemLocationId IS NOT NULL AND Source_Query.dtmBeginDate IS NOT NULL AND Source_Query.dtmEndDate IS NOT NULL AND Source_Query.ysnAddNewRecords = 1 THEN 
	INSERT (intItemId
		  , intItemLocationId
		  , strPromotionType
		  , dtmBeginDate
		  , dtmEndDate
		  , intItemUnitMeasureId
		  , dblUnit
		  , strDiscountBy
		  , dblDiscount
		  , dblUnitAfterDiscount
		  , dblDiscountThruQty
		  , dblDiscountThruAmount
		  , dblAccumulatedQty
		  , dblAccumulatedAmount
		  , intCurrencyId
		  , intSort
		  , intConcurrencyId
		  , dtmDateCreated
		  , dtmDateModified
		  , intCreatedByUserId
		  , intModifiedByUserId)
	VALUES (Source_Query.intItemId				-- intItemId
		  , Source_Query.intItemLocationId		-- intItemLocationId
		  , 'Discount'							-- strPromotionType
		  , Source_Query.dtmBeginDate			-- dtmBeginDate
		  , Source_Query.dtmEndDate				-- dtmEndDate
		  , Source_Query.intItemUOMId			-- intItemUnitMeasureId
		  , 1									-- dblUnit
		  , 'Amount'							-- strDiscountBy
		  , 0									-- dblDiscount
		  , Source_Query.dblUnitAfterDiscount	-- dblUnitAfterDiscount
		  , 0									-- dblDiscountThruQty
		  , 0									-- dblDiscountThruAmount
		  , 0									-- dblAccumulatedQty
		  , 0									-- dblAccumulatedAmount
		  , Source_Query.intDefaultCurrencyId	-- intCurrencyId
		  , DEFAULT								-- intSort
		  , 1									-- intConcurrencyId
		  , GETDATE()							-- dtmDateCreated
		  , DEFAULT								-- dtmDateModified
		  , @intUserId							-- intCreatedByUserId
		  , DEFAULT)							-- intModifiedByUserId
OUTPUT $action
	 , inserted.intItemId 
	 , inserted.intItemLocationId			
	 , inserted.intItemSpecialPricingId) AS [Changes] (strAction
													 , intItemId 
													 , intItemLocationId 
													 , intItemSpecialPricingId);

SELECT @updatedSpecialItemPricing = COUNT(1) 
FROM #tmpICEdiImportPricebook_tblICItemSpecialPricing 
WHERE strAction = 'UPDATE';

SELECT @insertedSpecialItemPricing = COUNT(1) 
FROM #tmpICEdiImportPricebook_tblICItemSpecialPricing 
WHERE strAction = 'INSERT';

-- Upsert the Item Vendor XRef (Cross Reference)
INSERT INTO #tmpICEdiImportPricebook_tblICItemVendorXref (intItemId
														, strAction
														, intVendorId_Old
														, intVendorId_New
														, strVendorProduct_Old
														, strVendorProduct_New
														, strProductDescription_Old
														, strProductDescription_New)
SELECT [Changes].intItemId
	 , [Changes].strAction
	 , [Changes].intVendorId_Old
	 , [Changes].intVendorId_New
	 , [Changes].strVendorProduct_Old
	 , [Changes].strVendorProduct_New
	 , [Changes].strProductDescription_Old
	 , [Changes].strProductDescription_New
FROM (MERGE	INTO dbo.tblICItemVendorXref WITH (HOLDLOCK) AS	ItemVendorXref
USING (
	SELECT Item.intItemId 
		 , Vendor.intEntityId 
		 , VendorXRef.strSellingUpcNumber
		 , strVendorsItemNumberForOrdering = CAST(VendorXRef.strVendorsItemNumberForOrdering AS NVARCHAR(50)) 
		 , strSellingUpcLongDescription = CAST(VendorXRef.strSellingUpcLongDescription AS NVARCHAR(250)) 
		 , ItemUOM.intItemUOMId 
		 , ItemUOM.dblUnitQty
	FROM @vendorItemXRef AS VendorXRef 
	INNER JOIN tblICItem AS Item ON  LOWER(Item.strItemNo) =  NULLIF(LTRIM(RTRIM(LOWER(VendorXRef.strItemNo))), '')
	INNER JOIN tblICItemUOM AS ItemUOM ON ItemUOM.intItemId = Item.intItemId AND ISNULL(ItemUOM.intModifier, 0) = ISNULL(NULLIF(VendorXRef.strUpcModifierNumber,''), 0) AND ItemUOM.strLongUPCCode =  NULLIF(VendorXRef.strSellingUpcNumber,'')	
	CROSS APPLY (SELECT TOP 1 v.* 
				 FROM vyuAPVendor v
				 WHERE (v.strVendorId = VendorXRef.strVendorId AND @intVendorId IS NULL) OR (v.intEntityId = @intVendorId AND @intVendorId IS NOT NULL)) AS Vendor				
	WHERE VendorXRef.strUniqueId = @UniqueId
) AS Source_Query  ON ItemVendorXref.intItemId = Source_Query.intItemId	AND ItemVendorXref.intVendorId = Source_Query.intEntityId AND ItemVendorXref.intItemLocationId IS NULL 
	
/* If matched, update the existing vendor xref. */ 
WHEN MATCHED THEN 
	UPDATE SET strVendorProduct		 = Source_Query.strVendorsItemNumberForOrdering  
			 , strProductDescription = Source_Query.strSellingUpcLongDescription

/* If none is found, insert a new vendor xref. */
WHEN NOT MATCHED THEN 
	INSERT (intItemId
		  , intVendorId
		  , strVendorProduct
		  , strProductDescription
		  , dblConversionFactor
		  , intItemUnitMeasureId
		  , intConcurrencyId
		  , dtmDateCreated
		  , dtmDateModified
		  , intCreatedByUserId
		  , intModifiedByUserId
		  , intDataSourceId)
	VALUES (Source_Query.intItemId						 -- intItemId
		  , Source_Query.intEntityId					 -- intVendorId
		  , Source_Query.strVendorsItemNumberForOrdering -- strVendorProduct
		  , Source_Query.strSellingUpcLongDescription	 -- strProductDescription
		  , Source_Query.dblUnitQty						 -- dblConversionFactor
		  , Source_Query.intItemUOMId					 -- intItemUnitMeasureId
		  , 1											 -- intConcurrencyId
		  , GETDATE()									 -- dtmDateCreated
		  , NULL										 -- dtmDateModified
		  , @intUserId									 -- intCreatedByUserId
		  , NULL										 -- intModifiedByUserId
		  , 2)											 -- intDataSourceId		
OUTPUT $action
	 , inserted.intItemId 
	 , deleted.strVendorProduct
	 , inserted.strVendorProduct
	 , deleted.strProductDescription
	 , inserted.strProductDescription
	 , deleted.intVendorId
	 , inserted.intVendorId) AS [Changes] (strAction
										 , intItemId 
										 , strVendorProduct_Old
										 , strVendorProduct_New
										 , strProductDescription_Old
										 , strProductDescription_New 
										 , intVendorId_Old
										 , intVendorId_New);

SELECT @updatedVendorXRef = COUNT(1) 
FROM #tmpICEdiImportPricebook_tblICItemVendorXref 
WHERE strAction = 'UPDATE';

SELECT @insertedVendorXRef = COUNT(1) 
FROM #tmpICEdiImportPricebook_tblICItemVendorXref 
WHERE strAction = 'INSERT';

_Exit_With_Errors: 

-- Update the stats. 
BEGIN 
	SELECT @ErrorCount = COUNT(*) FROM tblICImportLogDetail WHERE intImportLogId = @LogId AND strType = 'Error'
	SELECT @TotalRows = @originalPricebookCount --COUNT(*) FROM tblICEdiPricebook WHERE strUniqueId = @UniqueId
	SELECT @TotalRowsSkipped = COUNT(*) FROM tblICImportLogDetail WHERE intImportLogId = @LogId AND strStatus = 'Skipped'
	SELECT @TotalRowsSkipped = @TotalRowsSkipped - 1 + @duplicatePricebookCount WHERE @duplicatePricebookCount <> 0 

	SET @TotalRowsUpdated = 
			@TotalRowsUpdated 
			+ @updatedItem 
			+ @updatedItemUOM 
			+ @updatedItemLocation 
			+ @updatedItemPricing
			+ @updatedEffectiveItemPricing 
			+ @updatedSpecialItemPricing 
			+ @updatedVendorXRef
			+ @updatedEffectiveItemCost
	
	SET @TotalRowsInserted = 
			@TotalRowsInserted 
			+ @insertedItem 
			+ @insertedItemUOM 
			+ @insertedProductClass
			+ @insertedFamilyClass			
			+ @insertedItemLocation 
			+ @insertedItemPricing
			+ @insertedEffectiveItemPricing 
			+ @insertedSpecialItemPricing 
			+ @insertedVendorXRef 
			+ @insertedEffectiveItemCost 


END 

BEGIN 
	UPDATE tblICImportLog 
	SET 
		intTotalErrors = @ErrorCount,
		intTotalRows = @TotalRows,
		intRowsUpdated = @TotalRowsUpdated, 
		intRowsImported = @TotalRowsInserted,
		intRowsSkipped = @TotalRowsSkipped
	WHERE 
		intImportLogId = @LogId

	UPDATE tblICImportLog 
	SET 
		strDescription = 'Import finished with ' + CAST(@ErrorCount AS NVARCHAR(50))+ ' error(s).'
	WHERE 
		intImportLogId = @LogId
		AND @ErrorCount > 0
	
	-- Log when Add Ordering UPC, Add Record, Update Record or Update Price was not checked.
	IF @warningNotImported <> 0
	BEGIN
		INSERT INTO tblICImportLogDetail
		( intImportLogId
		, strType
		, intRecordNo
		, strField
		, strValue
		, strMessage
		, strStatus
		, strAction
		, intConcurrencyId)

		SELECT @LogId
			 , 'Warning'
			 , intRecordNumber
			 , 'Vendor Category'
			 , strVendorCategory
			 , 'Import does not happen because the Vendor Category is not enabled for Add Ordering UPC, Add Record, Update Record or Update Price.'
			 , 'Skipped'
			 , 'Record not imported.'
			 , 1
		FROM tblICEdiPricebook 
		WHERE strUniqueId = @UniqueId AND ysnAddNewRecords = 0 AND ysnUpdateExistingRecords = 0 AND ysnAddOrderingUPC = 0 AND ysnUpdatePrice = 0;
	END;

	-- Log when Add Ordering UPC, Add Record, Update Record or Update Price was not checked.
	IF @warningNotImported <> 0
	BEGIN
		INSERT INTO tblICImportLogDetail
		( intImportLogId
		, strType
		, intRecordNo
		, strField
		, strValue
		, strMessage
		, strStatus
		, strAction
		, intConcurrencyId)

		SELECT @LogId
			 , 'Warning'
			 , intRecordNumber
			 , 'Vendor Category'
			 , strVendorCategory
			 , 'Import does not happen because the Vendor Category is not enabled for Add Ordering UPC, Add Record, Update Record or Update Price.'
			 , 'Skipped'
			 , 'Record not imported.'
			 , 1
		FROM tblICEdiPricebook 
		WHERE strUniqueId = @UniqueId AND ysnAddNewRecords = 0 AND ysnUpdateExistingRecords = 0 AND ysnAddOrderingUPC = 0 AND ysnUpdatePrice = 0;
	END;



	-- Log the inserted items. 
	IF @insertedItem <> 0 
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
			, dbo.fnFormatMessage('%i item(s) are created.', @insertedItem,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT)
			, 'Success'
			, 'Updated'
			, 1
		WHERE 
			@insertedItem <> 0 
	END 

	-- Log the records with duplicate records
	--INSERT INTO tblICImportLogDetail(
	--	intImportLogId
	--	, strType
	--	, intRecordNo
	--	, strField
	--	, strValue
	--	, strMessage
	--	, strStatus
	--	, strAction
	--	, intConcurrencyId
	--)
	--SELECT 
	--	@LogId
	--	, 'Warning'
	--	, NULL
	--	, NULL 
	--	, NULL 
	--	, dbo.fnFormatMessage(
	--		'There are %i duplicate 2nd UPC Code(s) found in the file.'
	--		,@duplicate2ndUOMUPCCode
	--		,DEFAULT
	--		,DEFAULT
	--		,DEFAULT
	--		,DEFAULT
	--		,DEFAULT
	--		,DEFAULT
	--		,DEFAULT
	--		,DEFAULT
	--		,DEFAULT
	--	)
	--	, 'Skipped'
	--	, 'Record not imported.'
	--	, 1
	--WHERE 
	--	@duplicate2ndUOMUPCCode <> 0

	-- Log the updated items. 
	IF @updatedItem <> 0 
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
			, dbo.fnFormatMessage('%i item(s) are updated.', @updatedItem,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT)
			, 'Success'
			, 'Updated'
			, 1
		WHERE 
			@updatedItem <> 0 
	END 

	-- Log the created item uom. 
	IF @insertedItemUOM <> 0 
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
			, dbo.fnFormatMessage('%i item UOM(s) are created.', @insertedItemUOM,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT)
			, 'Success'
			, 'Created'
			, 1
		WHERE 
			@insertedItemUOM <> 0 
	END 

	-- Log the created product class
	IF @insertedProductClass <> 0 
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
			, dbo.fnFormatMessage('%i Product class(es) are created.', @insertedProductClass,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT)
			, 'Success'
			, 'Created'
			, 1
		WHERE 
			@insertedProductClass <> 0 
	END

	-- Log the created family class
	IF @insertedFamilyClass <> 0 
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
			, dbo.fnFormatMessage('%i Family class(es) are created.', @insertedFamilyClass,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT)
			, 'Success'
			, 'Created'
			, 1
		WHERE 
			@insertedFamilyClass <> 0 
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
			, 'Created'
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

	-- Log the created item cost. 
	IF @insertedEffectiveItemCost <> 0 
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
			, dbo.fnFormatMessage('%i item effective cost record(s) are created.', @insertedEffectiveItemCost,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT)
			, 'Success'
			, 'Created'
			, 1
		WHERE 
			@insertedEffectiveItemCost <> 0 
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

	IF @updatedEffectiveItemPricing <> 0 
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
			, dbo.fnFormatMessage('%i effective item pricing record(s) are updated.', @updatedEffectiveItemPricing,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT)
			, 'Success'
			, 'Updated'
			, 1
		WHERE 
			@updatedEffectiveItemPricing <> 0 
	END

	/*Log updated effective cost*/

	IF @updatedEffectiveItemCost <> 0 
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
			, dbo.fnFormatMessage('%i effective item pricing record(s) are updated.', @updatedEffectiveItemCost,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT)
			, 'Success'
			, 'Updated'
			, 1
		WHERE 
			@updatedEffectiveItemCost <> 0 
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