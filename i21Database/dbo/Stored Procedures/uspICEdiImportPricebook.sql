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
	@updatedItem AS INT = 0
	,@insertedItem AS INT = 0	
	,@updatedItemUOM AS INT = 0
	,@insertedItemUOM AS INT = 0 	
	,@updatedItemPricing AS INT = 0
	,@insertedItemPricing AS INT = 0
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

-- Get the duplicate count. 
SELECT @duplicatePricebookCount = ISNULL(@originalPricebookCount, 0) - COUNT(1) 
FROM 
	tblICEdiPricebook p
WHERE 
	p.strUniqueId = @UniqueId

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
	OUTER APPLY (
		SELECT TOP 1 
			v.* 
		FROM 
			vyuAPVendor v
		WHERE 
			(v.strVendorId = p.strVendorId AND @intVendorId IS NULL) 
			OR (v.intEntityId = @intVendorId AND @intVendorId IS NOT NULL)
	) v	
WHERE 
	v.intEntityId IS NULL 
	AND p.strUniqueId = @UniqueId

-- Log the records with duplicate records
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
	, 'Warning'
	, NULL
	, NULL 
	, NULL 
	, dbo.fnFormatMessage(
		'There are %i duplicate records(s) found in the file.'
		,@duplicatePricebookCount
		,DEFAULT
		,DEFAULT
		,DEFAULT
		,DEFAULT
		,DEFAULT
		,DEFAULT
		,DEFAULT
		,DEFAULT
		,DEFAULT
	)
	, 'Skipped'
	, 'Record not imported.'
	, 1
WHERE 
	@duplicatePricebookCount <> 0 

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
	, intRecordNumber
	, 'strItemUnitOfMeasure'
	, strSymbol
	, 'Duplicate UOM Symbol is used for ' + strUnitMeasure
	, 'Skipped'
	, 'Record not imported.'
	, 1
FROM (
		SELECT 
			strUnitMeasure = u.strUnitMeasure
			,strSymbol = u.strSymbol
			,intRecordNumber = p.intRecordNumber
			,row_no = u.row_no
		FROM 
			tblICEdiPricebook p 
			LEFT JOIN (
				SELECT * 
				FROM (
					SELECT 
						strUnitMeasure
						,strSymbol
						,row_no = ROW_NUMBER() OVER (PARTITION BY u.strSymbol ORDER BY u.strSymbol) 
					FROM 
						tblICUnitMeasure u 
				) x
				WHERE
					x.row_no > 1 			
			) u
			ON 
				(p.ysnUpdateExistingRecords = 1 OR p.ysnAddNewRecords = 1) 
				AND u.strSymbol = NULLIF(p.strItemUnitOfMeasure, '')				
		WHERE
			p.strUniqueId = @UniqueId
	) x
WHERE
	x.row_no > 1 

-- Log the duplicate 2nd UOM from strOrderPackageDescription
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
	, intRecordNumber
	, 'strOrderPackageDescription'
	, strSymbol
	, 'Duplicate UOM Symbol is used for ' + strUnitMeasure
	, 'Skipped'
	, 'Record not imported.'
	, 1
FROM (
		SELECT 
			strUnitMeasure = u.strUnitMeasure
			,strSymbol = u.strSymbol
			,intRecordNumber = p.intRecordNumber
			,row_no = u.row_no
		FROM 
			tblICEdiPricebook p 
			LEFT JOIN (
				SELECT * 
				FROM (
					SELECT 
						strUnitMeasure
						,strSymbol
						,row_no = ROW_NUMBER() OVER (PARTITION BY u.strSymbol ORDER BY u.strSymbol) 
					FROM 
						tblICUnitMeasure u 
				) x
				WHERE
					x.row_no > 1 			
			) u
			ON 
				p.ysnAddOrderingUPC = 1 
				AND u.strSymbol = NULLIF(p.strOrderPackageDescription, '')				
		WHERE
			p.strUniqueId = @UniqueId
	) x
WHERE
	x.row_no > 1 
	
-- Log the duplicate UPC code for the 2nd UOM. 
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
	, intRecordNumber
	, 'strOrderCaseUpcNumber'
	, strOrderCaseUpcNumber
	, 'Duplicate UPC code is used for ' + strOrderPackageDescription
	, 'Skipped'
	, 'Record not imported.'
	, 1
FROM 
	tblICEdiPricebook p
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
			OR i.strItemNo = p.strSellingUpcNumber
	) i
	OUTER APPLY (
		SELECT TOP 1 
			iu.intItemUOMId 
		FROM 
			tblICItemUOM iu
		WHERE
			iu.intItemId = i.intItemId
			AND iu.strLongUPCCode = NULLIF(p.strOrderCaseUpcNumber, '0') 
	) existUOM
WHERE
	p.strUniqueId = @UniqueId
	AND i.intItemId IS NOT NULL 
	AND NULLIF(p.strOrderCaseUpcNumber, '') IS NOT NULL 
	AND p.ysnAddOrderingUPC = 1
	AND existUOM.intItemUOMId IS NOT NULL  

IF EXISTS (SELECT TOP 1 1 FROM tblICImportLogDetail l WHERE l.intImportLogId = @LogId AND strType = 'Error')
	GOTO _Exit_With_Errors

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

SET @missingVendorCategoryXRef = @@ROWCOUNT;	

-- Update or Insert items based on the Category -> Vendor Category XRef. 
INSERT INTO #tmpICEdiImportPricebook_tblICItem (
	strAction 
	,intBrandId_Old 
	,intBrandId_New 
	,strDescription_Old 
	,strDescription_New 
	,strShortName_Old 
	,strShortName_New 
	,strItemNo_Old 
	,strItemNo_New 
)
SELECT 
	[Changes].strAction
	,[Changes].intBrandId_Old
	,[Changes].intBrandId_New
	,[Changes].strDescription_Old
	,[Changes].strDescription_New
	,[Changes].strShortName_Old
	,[Changes].strShortName_New
	,[Changes].strItemNo_Old
	,[Changes].strItemNo_New
FROM (
	MERGE	
	INTO	dbo.tblICItem
	WITH	(HOLDLOCK) 
	AS		Item
	USING (	
		SELECT 
			i.intItemId 
			,intBrandId = ISNULL(b.intBrandId, i.intBrandId)
			,strDescription = CAST(ISNULL(NULLIF(p.strSellingUpcLongDescription, ''), i.strDescription) AS NVARCHAR(250))
			,strShortName = CAST(ISNULL(ISNULL(NULLIF(p.strSellingUpcShortDescription, ''), SUBSTRING(p.strSellingUpcLongDescription, 1, 15)), i.strShortName) AS NVARCHAR(50))
			,b.intManufacturerId 
			,intDuplicateItemId = dup.intItemId 
			,p.* 
		FROM 
			tblICEdiPricebook p
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
			LEFT JOIN tblICItem i 
				ON i.intItemId = u.intItemId
			LEFT JOIN tblICBrand b 
				ON b.strBrandName = p.strManufacturersBrandName	
			OUTER APPLY (
				SELECT TOP 1 
					dup.*
				FROM 
					tblICItem dup
				WHERE
					dup.strItemNo = p.strSellingUpcNumber			
			) dup
			
		WHERE
			p.strUniqueId = @UniqueId		
	) AS Source_Query  
		ON Item.intItemId = Source_Query.intItemId 
	   
	-- If matched and it is allowed to update, update the item record. 
	WHEN MATCHED AND Source_Query.ysnUpdateExistingRecords = 1 THEN 
		UPDATE 
		SET	
			intBrandId = Source_Query.intBrandId
			,strDescription = Source_Query.strDescription
			,strShortName = Source_Query.strShortName
			,strItemNo = Source_Query.strSellingUpcNumber
			,dtmDateModified = GETDATE()
			,intModifiedByUserId = @intUserId
			,intConcurrencyId = Item.intConcurrencyId + 1

	-- If not found and it is allowed, insert a new item record.
	WHEN NOT MATCHED AND Source_Query.ysnAddNewRecords = 1 AND Source_Query.intDuplicateItemId IS NULL THEN 
		INSERT (			
			strItemNo
			,strShortName
			,strType
			,strDescription
			,intManufacturerId
			,intBrandId
			,intCategoryId
			,strStatus
			,strInventoryTracking
			,strLotTracking
			,intLifeTime
			,dtmDateCreated
			,intCreatedByUserId
			,intDataSourceId
			,intConcurrencyId
		)
		VALUES ( 
			Source_Query.strSellingUpcNumber --strItemNo
			,Source_Query.strShortName --,strShortName
			,'Inventory'--,strType
			,Source_Query.strDescription --,strDescription
			,Source_Query.intManufacturerId --,intManufacturerId
			,Source_Query.intBrandId--,intBrandId
			,Source_Query.intCategoryId--,intCategoryId
			,'Active'--,strStatus
			,'Item Level'--,strInventoryTracking
			,'No'--,strLotTracking
			,0--,intLifeTime
			,GETDATE()--,dtmDateCreated
			,@intUserId --,intCreatedByUserId
			,2--,intDataSourceId
			,1--,intConcurrencyId
		)
	OUTPUT 
	$action
	, deleted.intBrandId
	, inserted.intBrandId 
	, deleted.strDescription
	, inserted.strDescription
	, deleted.strShortName
	, inserted.strShortName
	, deleted.strItemNo
	, inserted.strItemNo
) AS [Changes] (
	strAction
	, intBrandId_Old
	, intBrandId_New
	, strDescription_Old
	, strDescription_New
	, strShortName_Old
	, strShortName_New
	, strItemNo_Old
	, strItemNo_New
);

SELECT @updatedItem = COUNT(1) FROM #tmpICEdiImportPricebook_tblICItem WHERE strAction = 'UPDATE'
SELECT @insertedItem = COUNT(1) FROM #tmpICEdiImportPricebook_tblICItem WHERE strAction = 'INSERT'

-- Update or Insert Item UOM
INSERT INTO #tmpICEdiImportPricebook_tblICItemUOM (
	intItemId 
	,intItemUOMId 
	,strAction 
	,intUnitMeasureId_Old 
	,intUnitMeasureId_New 
)
SELECT 
	[Changes].intItemId
	,[Changes].intItemUOMId
	,[Changes].strAction
	,[Changes].intUnitMeasureId_Old
	,[Changes].intUnitMeasureId_New
FROM (
	MERGE	
	INTO	dbo.tblICItemUOM
	WITH	(HOLDLOCK) 
	AS		ItemUOM
	USING (	
		SELECT 
			i.intItemId 
			,u.intItemUOMId
			,intUnitMeasureId = COALESCE(m.intUnitMeasureId, s.intUnitMeasureId, u.intUnitMeasureId)			
			,ysnStockUnit = CASE WHEN stockUnit.intItemUOMId IS NOT NULL THEN 0 ELSE 1 END 
			,p.* 
		FROM 
			tblICEdiPricebook p
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
					OR i.strItemNo = p.strSellingUpcNumber
			) i			
			OUTER APPLY (			
				SELECT TOP 1 
					m.*
				FROM tblICUnitMeasure m 
				WHERE
					m.strUnitMeasure = NULLIF(p.strItemUnitOfMeasure, '')
				ORDER BY 
					m.intUnitMeasureId 
			) m
			OUTER APPLY (
				SELECT TOP 1 
					s.*
				FROM tblICUnitMeasure s 
				WHERE
					s.strSymbol = NULLIF(p.strItemUnitOfMeasure, '')
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
		WHERE
			p.strUniqueId = @UniqueId
	) AS Source_Query  
		ON ItemUOM.intItemUOMId = Source_Query.intItemUOMId
		AND ItemUOM.intItemId = Source_Query.intItemId 
			   
	-- If matched and it is allowed to update, update the item uom record. 
	WHEN 
		MATCHED 
		AND Source_Query.ysnUpdateExistingRecords = 1 
	THEN 
		UPDATE 
		SET	
			intUnitMeasureId = Source_Query.intUnitMeasureId
			,intModifiedByUserId = @intUserId 
			,intConcurrencyId = ItemUOM.intConcurrencyId + 1

	-- If not found and it is allowed, insert a new item uom record.
	WHEN 
		NOT MATCHED 
		AND Source_Query.ysnAddNewRecords = 1 
		AND Source_Query.intItemId IS NOT NULL 
		AND Source_Query.intUnitMeasureId IS NOT NULL 
	THEN 
		INSERT (			
			intItemId
			,intUnitMeasureId
			,dblUnitQty
			--,strUpcCode
			,strLongUPCCode
			,ysnStockUnit
			,ysnAllowPurchase
			,ysnAllowSale
			,intConcurrencyId
			,dtmDateCreated
			,intCreatedByUserId
			,intDataSourceId
		)
		VALUES ( 
			Source_Query.intItemId --intItemId
			,Source_Query.intUnitMeasureId --,intUnitMeasureId
			,1--,dblUnitQty
			--,Source_Query.strSellingUpcNumber--,strUpcCode
			,Source_Query.strSellingUpcNumber--,strLongUPCCode
			,Source_Query.ysnStockUnit--,ysnStockUnit
			,1--,ysnAllowPurchase
			,1--,ysnAllowSale
			,1--,intConcurrencyId
			,GETDATE()--,dtmDateCreated
			,@intUserId--,intCreatedByUserId
			,2--,intDataSourceId
		)
			
	OUTPUT 
	$action
	, inserted.intItemId
	, inserted.intItemUOMId
	, deleted.intUnitMeasureId
	, inserted.intUnitMeasureId
) AS [Changes] (
	strAction
	, intItemId
	, intItemUOMId
	, intUnitMeasureId_Old
	, intUnitMeasureId_New
);	   	
	
SELECT @updatedItemUOM = COUNT(1) FROM #tmpICEdiImportPricebook_tblICItemUOM WHERE strAction = 'UPDATE'
SELECT @insertedItemUOM = COUNT(1) FROM #tmpICEdiImportPricebook_tblICItemUOM WHERE strAction = 'INSERT'

-- Create the valid list of 2nd UOM
DECLARE @valid2ndUOM AS TABLE (
	intEdiPricebookId INT 
	,strLongUPCCode NVARCHAR(50) NULL 
)

INSERT INTO @valid2ndUOM (
	intEdiPricebookId
	,strLongUPCCode
)
SELECT  
	p.intEdiPricebookId
	,p.strOrderCaseUpcNumber
FROM 
	tblICEdiPricebook p
	LEFT JOIN tblICItemUOM u 
		ON ISNULL(NULLIF(u.strLongUPCCode, ''), u.strUpcCode) = p.strSellingUpcNumber
	OUTER APPLY (
		SELECT TOP 1 
			i.intItemId 
		FROM
			tblICItem i 
		WHERE
			i.intItemId = u.intItemId
			OR i.strItemNo = p.strSellingUpcNumber
	) i		
WHERE
	p.strUniqueId = @UniqueId
	AND i.intItemId IS NOT NULL 
	AND NULLIF(p.strCaseBoxSizeQuantityPerCaseBox, '') IS NOT NULL 
	AND NULLIF(p.strOrderPackageDescription, '') IS NOT NULL 
	AND p.ysnAddOrderingUPC = 1

SELECT @duplicate2ndUOMUPCCode = @@ROWCOUNT;

-- Remove the duplicate records in @valid2ndUOM
;WITH deleteDuplicate2ndUOMLongUPC_CTE (
	intEdiPricebookId
	,strLongUPCCode
	,dblDuplicateCount
)
AS (
	
	SELECT 
		p.intEdiPricebookId
		,p.strLongUPCCode
		,dblDuplicateCount = ROW_NUMBER() OVER (PARTITION BY p.strLongUPCCode ORDER BY p.strLongUPCCode)
	FROM 
		@valid2ndUOM p
)
DELETE FROM deleteDuplicate2ndUOMLongUPC_CTE
WHERE dblDuplicateCount > 1;

-- Remove the duplicate records in @valid2ndUOM
DELETE p 
FROM 
	tblICItemUOM iu RIGHT JOIN @valid2ndUOM p
		ON iu.strLongUPCCode = p.strLongUPCCode COLLATE Latin1_General_CI_AS
WHERE
	iu.intItemUOMId IS NOT NULL 

SELECT @duplicate2ndUOMUPCCode = ISNULL(@duplicate2ndUOMUPCCode, 0) - COUNT(1) 
FROM  @valid2ndUOM

-- Insert 2nd UOM
INSERT INTO tblICItemUOM (			
	intItemId
	,intUnitMeasureId
	,dblUnitQty
	--,strUpcCode
	,strLongUPCCode
	,ysnStockUnit
	,ysnAllowPurchase
	,ysnAllowSale
	,intConcurrencyId
	,dtmDateCreated
	,intCreatedByUserId
	,intDataSourceId
)
SELECT 
	intItemId = i.intItemId 
	,intUnitMeasureId = COALESCE(m.intUnitMeasureId, s.intUnitMeasureId)			
	,dblUnitQty = CAST(p.strCaseBoxSizeQuantityPerCaseBox AS NUMERIC(38, 20)) 
	--,strUpcCode = p.strOrderCaseUpcNumber
	,strLongUPCCode = p.strOrderCaseUpcNumber
	,ysnStockUnit = 0
	,ysnAllowPurchase = 1
	,ysnAllowSale = 1
	,intConcurrencyId = 1
	,dtmDateCreated = GETDATE()
	,intCreatedByUserId = @intUserId
	,intDataSourceId = 2
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
			OR (i.strItemNo = p.strSellingUpcNumber AND u.intItemId IS NULL) 
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
			AND iu.intUnitMeasureId = COALESCE(m.intUnitMeasureId, s.intUnitMeasureId)
	) existUOM
	OUTER APPLY (
		SELECT TOP 1 
			iu.intItemUOMId
		FROM 
			tblICItemUOM iu
		WHERE
			iu.strLongUPCCode = p.strOrderCaseUpcNumber
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

-- Insert the Product Sub Category if it does not exists 
INSERT INTO tblSTSubcategory (
	strSubcategoryType
	,strSubcategoryId
	,intConcurrencyId
)
SELECT 
	DISTINCT 
	strSubcategoryType = 'C'
	,strSubcategoryId = CAST(p.strProductClass AS NVARCHAR(8)) 
	,intConcurrencyId = 1	
FROM 
	tblICEdiPricebook p LEFT JOIN tblSTSubcategory sc 
		ON sc.strSubcategoryId = CAST(NULLIF(p.strProductClass, '') AS NVARCHAR(8))
		AND sc.strSubcategoryType = 'C'
WHERE
	sc.intSubcategoryId IS NULL 
	AND NULLIF(p.strProductClass, '') IS NOT NULL 

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
	INSERT INTO @ValidLocations (
		intCompanyLocationId
	) 
	SELECT 
		ss.intCompanyLocationId
	FROM	
		tblSTStore ss INNER JOIN tblSMCompanyLocation cl  
			ON ss.intCompanyLocationId = cl.intCompanyLocationId
END 
ELSE
BEGIN 
	INSERT INTO @ValidLocations (
		intCompanyLocationId
	) 
	SELECT 
		intCompanyLocationId
	FROM	
		@Locations
END 

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
				,intClassId = COALESCE(sc.intSubcategoryId, catLoc.intClassId, l.intClassId)
				,intFamilyId = COALESCE(sf.intSubcategoryId, catLoc.intFamilyId, l.intFamilyId)
				,ysnDepositRequired = ISNULL(CASE p.strDepositRequired WHEN 'Y' THEN 1 WHEN 'N' THEN 0 ELSE NULL END, l.ysnDepositRequired)
				,ysnPromotionalItem = ISNULL(CASE p.strPromotionalItem WHEN 'Y' THEN 1 WHEN 'N' THEN 0 ELSE NULL END, l.ysnPromotionalItem)
				,ysnPrePriced = ISNULL(ISNULL(CASE p.strPrePriced WHEN 'Y' THEN 1 WHEN 'N' THEN 0 ELSE NULL END, catLoc.ysnPrePriced), l.ysnPrePriced)
				,dblSuggestedQty = ISNULL(NULLIF(p.strSuggestedOrderQuantity, ''), l.dblSuggestedQty)
				,dblMinOrder = ISNULL(NULLIF(p.strMinimumOrderQuantity, ''), l.dblMinOrder)
				,intBottleDepositNo = ISNULL(NULLIF(p.strBottleDepositNumber, ''), l.intBottleDepositNo)
				,ysnTaxFlag1 = catLoc.ysnUseTaxFlag1--ISNULL(l.ysnTaxFlag1, catLoc.ysnUseTaxFlag1)
				,ysnTaxFlag2 = catLoc.ysnUseTaxFlag2--ISNULL(l.ysnTaxFlag2, catLoc.ysnUseTaxFlag2)
				,ysnTaxFlag3 = catLoc.ysnUseTaxFlag3--ISNULL(l.ysnTaxFlag3, catLoc.ysnUseTaxFlag3)
				,ysnTaxFlag4 = catLoc.ysnUseTaxFlag4--ISNULL(l.ysnTaxFlag4, catLoc.ysnUseTaxFlag4)
				,ysnApplyBlueLaw1 = catLoc.ysnBlueLaw1--ISNULL(l.ysnApplyBlueLaw1, catLoc.ysnBlueLaw1)
				,ysnApplyBlueLaw2 = catLoc.ysnBlueLaw2--ISNULL(l.ysnApplyBlueLaw2, catLoc.ysnBlueLaw2)
				,intProductCodeId = catLoc.intProductCodeId--ISNULL(l.intProductCodeId, catLoc.intProductCodeId)
				,ysnFoodStampable = catLoc.ysnFoodStampable--ISNULL(l.ysnFoodStampable, catLoc.ysnFoodStampable)
				,ysnReturnable = catLoc.ysnReturnable--ISNULL(l.ysnReturnable, catLoc.ysnReturnable)
				,ysnSaleable = catLoc.ysnSaleable--ISNULL(l.ysnSaleable, catLoc.ysnSaleable)
				,ysnIdRequiredCigarette = catLoc.ysnIdRequiredCigarette--ISNULL(l.ysnIdRequiredCigarette, catLoc.ysnIdRequiredCigarette)
				,ysnIdRequiredLiquor = catLoc.ysnIdRequiredLiquor--ISNULL(l.ysnIdRequiredLiquor, catLoc.ysnIdRequiredLiquor)
				,intMinimumAge = catLoc.intMinimumAge--ISNULL(l.intMinimumAge, catLoc.intMinimumAge)
				,intCountGroupId = cg.intCountGroupId
				,intLocationId = loc.intCompanyLocationId 
				,p.ysnAddOrderingUPC
				,p.ysnUpdateExistingRecords
				,p.ysnAddNewRecords
				,p.ysnUpdatePrice
				,v.intEntityId
				,intIssueUOMId = saleUOM.intItemUOMId
				,intReceiveUOMId = receiveUOM.intItemUOMId
			FROM tblICEdiPricebook p
				INNER JOIN tblICItemUOM u 
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
				INNER JOIN tblICItem i 
					ON i.intItemId = u.intItemId
				LEFT JOIN tblICCategory cat 
					ON cat.intCategoryId = i.intCategoryId
				LEFT JOIN tblSTSubcategory sc 
					ON sc.strSubcategoryId = CAST(NULLIF(p.strProductClass, '') AS NVARCHAR(8))
					AND sc.strSubcategoryType = 'C'
				LEFT JOIN tblSTSubcategory sf 
					ON sf.strSubcategoryId = CAST(NULLIF(p.strProductFamily, '') AS NVARCHAR(8)) 
					AND sf.strSubcategoryType = 'F'
				LEFT JOIN tblICCountGroup cg
					ON cg.strCountGroup = p.strInventoryGroup
				OUTER APPLY (
					SELECT 
						loc.intCompanyLocationId 					
					FROM 						
						@ValidLocations loc INNER JOIN tblSMCompanyLocation cl 
							ON loc.intCompanyLocationId = cl.intCompanyLocationId
				) loc
				OUTER APPLY (
					SELECT TOP 1 
						l.*
					FROM 						
						tblICItemLocation l 
					WHERE
						l.intItemId = i.intItemId
						AND l.intLocationId = loc.intCompanyLocationId
				) l
				LEFT JOIN tblICCategoryLocation catLoc 
					ON catLoc.intCategoryId = cat.intCategoryId
					AND catLoc.intLocationId = l.intLocationId

				-- Issue (Sale) UOM: strItemUnitOfMeasure 
				OUTER APPLY (			
					SELECT TOP 1 
						m.*
					FROM tblICUnitMeasure m 
					WHERE
						m.strUnitMeasure = NULLIF(p.strItemUnitOfMeasure, '')
					ORDER BY 
						m.intUnitMeasureId 
				) saleUnitMeasure
				OUTER APPLY (
					SELECT TOP 1 
						s.*
					FROM tblICUnitMeasure s 
					WHERE
						s.strSymbol = NULLIF(p.strItemUnitOfMeasure, '')
					ORDER BY 
						s.intUnitMeasureId 
				) saleSymbol
				OUTER APPLY (
					SELECT TOP 1 
						saleUOM.intItemUOMId					
					FROM 
						tblICItemUOM saleUOM
					WHERE
						saleUOM.intItemId = i.intItemId
						AND saleUOM.intUnitMeasureId = ISNULL(saleUnitMeasure.intUnitMeasureId, saleSymbol.intUnitMeasureId) 
				) saleUOM

				-- Receive (Purchase) UOM: strOrderPackageDescription
				OUTER APPLY (			
					SELECT TOP 1 
						m.*
					FROM tblICUnitMeasure m 
					WHERE
						m.strUnitMeasure = NULLIF(p.strOrderPackageDescription, '')
					ORDER BY 
						m.intUnitMeasureId 
				) receiveUnitMeasure
				OUTER APPLY (
					SELECT TOP 1 
						s.*
					FROM tblICUnitMeasure s 
					WHERE
						s.strSymbol = NULLIF(p.strOrderPackageDescription, '')
					ORDER BY 
						s.intUnitMeasureId 
				) receiveSymbol
				OUTER APPLY (
					SELECT TOP 1 
						receiveUOM.intItemUOMId					
					FROM 
						tblICItemUOM receiveUOM
					WHERE
						receiveUOM.intItemId = i.intItemId
						AND receiveUOM.intUnitMeasureId = ISNULL(receiveUnitMeasure.intUnitMeasureId, receiveSymbol.intUnitMeasureId) 
				) receiveUOM

				OUTER APPLY (
					SELECT TOP 1 
						v.* 
					FROM 
						vyuAPVendor v
					WHERE 
						(v.strVendorId = p.strVendorId AND @intVendorId IS NULL) 
						OR (v.intEntityId = @intVendorId AND @intVendorId IS NOT NULL)
				) v	
			WHERE
				p.strUniqueId = @UniqueId
	) AS Source_Query  
		ON ItemLocation.intItemLocationId = Source_Query.intItemLocationId
	   
	-- If matched, update the existing item location
	WHEN 
		MATCHED 
		AND Source_Query.ysnUpdateExistingRecords = 1 
	THEN 
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
			, ItemLocation.intConcurrencyId = ItemLocation.intConcurrencyId + 1
			, ItemLocation.intIssueUOMId = Source_Query.intIssueUOMId
			, ItemLocation.intReceiveUOMId = Source_Query.intReceiveUOMId
			, ItemLocation.intVendorId = Source_Query.intEntityId

	-- If none is found, insert a new item location 
	WHEN 
		NOT MATCHED 
		AND Source_Query.ysnAddNewRecords = 1 
	THEN 
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
			,Source_Query.intEntityId --,intVendorId
			,DEFAULT--,strDescription
			,1--,intCostingMethod
			,3--,intAllowNegativeInventory
			,DEFAULT--,intSubLocationId
			,DEFAULT--,intStorageLocationId
			,Source_Query.intIssueUOMId--,intIssueUOMId
			,Source_Query.intReceiveUOMId--,intReceiveUOMId
			,DEFAULT--,intGrossUOMId
			,Source_Query.intFamilyId--,intFamilyId
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
			,0--,ysnStorageUnitRequired
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
			,p.ysnAddOrderingUPC
			,p.ysnUpdateExistingRecords
			,p.ysnAddNewRecords
			,p.ysnUpdatePrice
		FROM tblICEdiPricebook p
			INNER JOIN tblICItemUOM u 
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
			INNER JOIN tblICItem i 
				ON i.intItemId = u.intItemId
			OUTER APPLY (
				SELECT 
					loc.intCompanyLocationId 
					,l.*
				FROM 						
					@ValidLocations loc INNER JOIN tblSMCompanyLocation cl 
						ON loc.intCompanyLocationId = cl.intCompanyLocationId
					INNER JOIN tblICItemLocation l 
						ON l.intItemId = i.intItemId
						AND l.intLocationId = loc.intCompanyLocationId 
			) il
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
		AND Source_Query.ysnAddNewRecords = 1	
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
			--,catV.ysnUpdatePrice 
			,p.ysnAddOrderingUPC
			,p.ysnUpdateExistingRecords
			,p.ysnAddNewRecords
			,p.ysnUpdatePrice

		FROM tblICEdiPricebook p
			INNER JOIN tblICItemUOM u 
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
			INNER JOIN tblICItem i ON i.intItemId = u.intItemId
			OUTER APPLY (
				SELECT 
					loc.intCompanyLocationId 
					,l.*
				FROM 						
					@ValidLocations loc INNER JOIN tblICItemLocation l 
						ON l.intItemId = i.intItemId
						AND loc.intCompanyLocationId = l.intLocationId
			) il
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
		AND Source_Query.ysnAddNewRecords = 1
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

-- Upsert the Item Vendor XRef (Cross Reference)
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
				,strVendorsItemNumberForOrdering = CAST(p.strVendorsItemNumberForOrdering AS NVARCHAR(50)) 
				,strSellingUpcLongDescription = CAST(p.strSellingUpcLongDescription AS NVARCHAR(250)) 
				,u.intItemUOMId 
				,u.dblUnitQty
			FROM 
				tblICEdiPricebook p 
				INNER JOIN tblICItemUOM u 
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
				INNER JOIN tblICItem i 
					ON i.intItemId = u.intItemId
				CROSS APPLY (
					SELECT TOP 1 
						v.* 
					FROM 
						vyuAPVendor v
					WHERE 
						(v.strVendorId = p.strVendorId AND @intVendorId IS NULL) 
						OR (v.intEntityId = @intVendorId AND @intVendorId IS NOT NULL)
				) v				
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
			+ @updatedSpecialItemPricing 
			+ @updatedVendorXRef
	
	SET @TotalRowsInserted = 
			@TotalRowsInserted 
			+ @insertedItem 
			+ @insertedItemUOM 
			+ @insertedProductClass
			+ @insertedFamilyClass			
			+ @insertedItemLocation 
			+ @insertedItemPricing 
			+ @insertedSpecialItemPricing 
			+ @insertedVendorXRef 

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
		, 'Warning'
		, NULL
		, NULL 
		, NULL 
		, dbo.fnFormatMessage(
			'There are %i duplicate 2nd UPC Code(s) found in the file.'
			,@duplicate2ndUOMUPCCode
			,DEFAULT
			,DEFAULT
			,DEFAULT
			,DEFAULT
			,DEFAULT
			,DEFAULT
			,DEFAULT
			,DEFAULT
			,DEFAULT
		)
		, 'Skipped'
		, 'Record not imported.'
		, 1
	WHERE 
		@duplicate2ndUOMUPCCode <> 0

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
			, 'Updated'
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
			, 'Updated'
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
			, 'Updated'
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
