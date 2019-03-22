CREATE PROCEDURE [dbo].[uspICUpdateItemForCStore]
	-- filter params
	@strUpcCode AS NVARCHAR(50) = NULL 
	,@strDescription AS NVARCHAR(250) = NULL 
	,@dblRetailPriceFrom AS NUMERIC(38, 20) = NULL  
	,@dblRetailPriceTo AS NUMERIC(38, 20) = NULL 
	,@intItemId AS INT = NULL 
	-- update params
	,@intCategoryId INT = NULL
	,@strCountCode NVARCHAR(50) = NULL
	,@strItemDescription NVARCHAR(250) = NULL 
	,@intEntityUserSecurityId AS INT 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

-- Create the temp table used for filtering. 
IF OBJECT_ID('tempdb..#tmpUpdateItemForCStore_Location') IS NULL  
	CREATE TABLE #tmpUpdateItemForCStore_Location (
		intLocationId INT 
	)

IF OBJECT_ID('tempdb..#tmpUpdateItemForCStore_Vendor') IS NULL  
	CREATE TABLE #tmpUpdateItemForCStore_Vendor (
		intVendorId INT 
	)

IF OBJECT_ID('tempdb..#tmpUpdateItemForCStore_Category') IS NULL  
	CREATE TABLE #tmpUpdateItemForCStore_Category (
		intCategoryId INT 
	)

IF OBJECT_ID('tempdb..#tmpUpdateItemForCStore_Family') IS NULL  
	CREATE TABLE #tmpUpdateItemForCStore_Family (
		intFamilyId INT 
	)

IF OBJECT_ID('tempdb..#tmpUpdateItemForCStore_Class') IS NULL  
	CREATE TABLE #tmpUpdateItemForCStore_Class (
		intClassId INT 
	)

-- Create the temp table for the audit log. 
IF OBJECT_ID('tempdb..#tmpUpdateItemForCStore_itemAuditLog') IS NULL  
	CREATE TABLE #tmpUpdateItemForCStore_itemAuditLog (
		intItemId INT
		-- Original Fields
		,intCategoryId_Original INT NULL
		,strCountCode_Original NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
		,strDescription_Original NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL
		-- Modified Fields
		,intCategoryId_New INT NULL
		,strCountCode_New NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
		,strDescription_New NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL
	)
;

-- Update the Standard Cost and Retail Price in the Item Pricing table. 
BEGIN 
	INSERT INTO #tmpUpdateItemForCStore_itemAuditLog (
		intItemId 
		-- Original Fields
		,intCategoryId_Original 
		,strCountCode_Original
		,strDescription_Original
		-- Modified Fields
		,intCategoryId_New
		,strCountCode_New 
		,strDescription_New 
	)
	SELECT	[Changes].intItemId 
			, [Changes].intCategoryId_Original 
			, [Changes].strCountCode_Original 
			, [Changes].strDescription_Original 
			, [Changes].intCategoryId_New 
			, [Changes].strCountCode_New 
			, [Changes].strDescription_New 
	FROM	(
				-- Merge will help us build the audit log and update the records at the same time. 
				MERGE	
					INTO	dbo.tblICItem   
					WITH	(HOLDLOCK) 
					AS		item	
					USING (
						SELECT	i.intItemId 
						FROM	tblICItem i CROSS APPLY (
									SELECT	TOP 1
											itemLocation.intItemId  								
									FROM	tblICItemLocation itemLocation LEFT JOIN tblICItemPricing itemPricing
												ON itemPricing.intItemLocationId = itemLocation.intItemLocationId
									WHERE	itemLocation.intItemId = i.intItemId 
											AND	(
												NOT EXISTS (SELECT TOP 1 1 FROM #tmpUpdateItemForCStore_Location)
												OR EXISTS (SELECT TOP 1 1 FROM #tmpUpdateItemForCStore_Location WHERE intLocationId = itemLocation.intLocationId) 			
											)
											AND (
												NOT EXISTS (SELECT TOP 1 1 FROM #tmpUpdateItemForCStore_Vendor)
												OR EXISTS (SELECT TOP 1 1 FROM #tmpUpdateItemForCStore_Vendor WHERE intVendorId = itemLocation.intVendorId) 			
											)
											AND (
												NOT EXISTS (SELECT TOP 1 1 FROM #tmpUpdateItemForCStore_Family)
												OR EXISTS (SELECT TOP 1 1 FROM #tmpUpdateItemForCStore_Family WHERE intFamilyId = itemLocation.intFamilyId)			
											)
											AND (
												NOT EXISTS (SELECT TOP 1 1 FROM #tmpUpdateItemForCStore_Class)
												OR EXISTS (SELECT TOP 1 1 FROM #tmpUpdateItemForCStore_Class WHERE intClassId = itemLocation.intClassId )			
											)
											AND (
												@dblRetailPriceFrom IS NULL 
												OR ISNULL(itemPricing.dblSalePrice, 0) >= @dblRetailPriceFrom 
											)
											AND (
												@dblRetailPriceTo IS NULL 
												OR ISNULL(itemPricing.dblSalePrice, 0) <= @dblRetailPriceTo
											)
								) filterQuery 
						WHERE	(
									NOT EXISTS (SELECT TOP 1 1 FROM #tmpUpdateItemForCStore_Category)
									OR EXISTS (SELECT TOP 1 1 FROM #tmpUpdateItemForCStore_Category WHERE intCategoryId = i.intCategoryId)			
								)								
								AND (
									@strDescription IS NULL 
									OR i.strDescription = @strDescription 
								)
								AND (
									@strUpcCode IS NULL 
									OR EXISTS (
										SELECT TOP 1 1 
										FROM	tblICItemUOM uom 
										WHERE	uom.intItemId = i.intItemId 
												AND (uom.strUpcCode = @strUpcCode OR uom.strLongUPCCode = @strUpcCode)
									)
								)
					) AS Source_Query  
						ON item.intItemId = Source_Query.intItemId
						AND item.intItemId = ISNULL(@intItemId, item.intItemId) 
					
					-- If matched, update the Standard Cost and Retail Price. 
					WHEN MATCHED THEN 
						UPDATE 
						SET		
							intCategoryId = ISNULL(@intCategoryId, item.intCategoryId) 
							,strCountCode = ISNULL(@strCountCode, item.strCountCode) 
							,strDescription = ISNULL(@strItemDescription, item.strDescription) 
							,dtmDateModified = GETUTCDATE()
							,intModifiedByUserId = @intEntityUserSecurityId
					OUTPUT 
						$action
						, inserted.intItemId 
						-- Original values
						, deleted.intCategoryId
						, deleted.strCountCode
						, deleted.strDescription
						-- Modified values 
						, inserted.intCategoryId
						, inserted.strCountCode
						, inserted.strDescription

			) AS [Changes] (
				Action
				, intItemId 
				-- Original values
				, intCategoryId_Original
				, strCountCode_Original
				, strDescription_Original
				-- Modified values 
				, intCategoryId_New
				, strCountCode_New
				, strDescription_New
			)
	WHERE	[Changes].Action = 'UPDATE'
	;
END

IF EXISTS (SELECT TOP 1 1 FROM #tmpUpdateItemForCStore_itemAuditLog)
BEGIN 
	DECLARE @json1 AS NVARCHAR(2000) = '{"action":"Updated","change":"Updated - Record: %s","iconCls":"small-menu-maintenance","children":[%s]}'
	
	DECLARE @json2_int AS NVARCHAR(2000) = '{"change":"%s","iconCls":"small-menu-maintenance","from":"%i","to":"%i","leaf":true}'
	DECLARE @json2_float AS NVARCHAR(2000) = '{"change":"%s","iconCls":"small-menu-maintenance","from":"%f","to":"%f","leaf":true}'
	DECLARE @json2_string AS NVARCHAR(2000) = '{"change":"%s","iconCls":"small-menu-maintenance","from":"%s","to":"%s","leaf":true}'
	DECLARE @json2_date AS NVARCHAR(2000) = '{"change":"%s","iconCls":"small-menu-maintenance","from":"%d","to":"%d","leaf":true}'

	-- Add audit logs for Standard Cost changes. 
	INSERT INTO tblSMAuditLog(
			strActionType
			, strTransactionType
			, strRecordNo
			, strDescription
			, strRoute
			, strJsonData
			, dtmDate
			, intEntityId
			, intConcurrencyId
	)
	SELECT 
			strActionType = 'Updated'
			, strTransactionType =  'Inventory.view.Item'
			, strRecordNo = auditLog.intItemId
			, strDescription = ''
			, strRoute = null 
			, strJsonData = auditLog.strJsonData
			, dtmDate = GETUTCDATE()
			, intEntityId = @intEntityUserSecurityId 
			, intConcurrencyId = 1
	FROM	(
		SELECT	intItemId
				,strJsonData = 
					dbo.fnFormatMessage(
						@json1
						, CAST(intItemId AS NVARCHAR(20)) 
						, dbo.fnFormatMessage(
							@json2_string
							, 'C-Store updates the Category'
							, category_Original.strCategoryCode
							, category_New.strCategoryCode
							, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT
						) 
						, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT
					) 
		FROM	#tmpUpdateItemForCStore_itemAuditLog auditLog
				LEFT JOIN tblICCategory category_Original
					ON auditLog.intCategoryId_Original = category_Original.intCategoryId
				LEFT JOIN tblICCategory category_New
					ON auditLog.intCategoryId_New = category_New.intCategoryId

		WHERE	ISNULL(intCategoryId_Original, 0) <> ISNULL(intCategoryId_New, 0)
		UNION ALL
		SELECT	intItemId
				, strJsonData = 
					dbo.fnFormatMessage(
						@json1
						, CAST(intItemId AS NVARCHAR(20)) 
						, dbo.fnFormatMessage(
							@json2_string
							, 'C-Store updates the Count Code'
							, strCountCode_Original
							, strCountCode_New
							, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT
						) 
						, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT
					)
		FROM	#tmpUpdateItemForCStore_itemAuditLog 
		WHERE	ISNULL(strCountCode_Original, 0) <> ISNULL(strCountCode_New, 0)
		UNION ALL
		SELECT	intItemId
				, strJsonData = 
					dbo.fnFormatMessage(
						@json1
						, CAST(intItemId AS NVARCHAR(20)) 
						, dbo.fnFormatMessage(
							@json2_string
							, 'C-Store updates the Description'
							, strDescription_Original
							, strDescription_New
							, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT
						) 
						, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT
					)
		FROM	#tmpUpdateItemForCStore_itemAuditLog 
		WHERE	ISNULL(strDescription_Original, '') <> ISNULL(strDescription_New, '')

	) auditLog
	WHERE auditLog.strJsonData IS NOT NULL 
END 