CREATE PROCEDURE [dbo].[uspICUpdateItemForCStore]
	-- filter params	
	@strDescription AS NVARCHAR(250) = NULL 
	,@dblRetailPriceFrom AS NUMERIC(38, 20) = NULL  
	,@dblRetailPriceTo AS NUMERIC(38, 20) = NULL 
	,@intItemId AS INT = NULL 
	,@intItemUOMId AS INT = NULL 
	-- update params
	,@intCategoryId INT = NULL
	,@strCountCode NVARCHAR(50) = NULL
	,@strItemDescription NVARCHAR(250) = NULL 	
	,@strItemNo AS NVARCHAR(50) = NULL 
	,@strShortName AS NVARCHAR(50) = NULL 
	,@strUpcCode AS NVARCHAR(50) = NULL 
	,@strLongUpcCode AS NVARCHAR(50) = NULL 
	,@intEntityUserSecurityId AS INT 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS ON

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
		,strItemNo_Original NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL
		,strShortName_Original NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL
		-- Modified Fields
		,intCategoryId_New INT NULL
		,strCountCode_New NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
		,strDescription_New NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL
		,strItemNo_New NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL
		,strShortName_New NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL
	)
;

-- Create the temp table for the audit log. 
IF OBJECT_ID('tempdb..#tmpUpdateItemUOMForCStore_itemAuditLog') IS NULL  
	CREATE TABLE #tmpUpdateItemUOMForCStore_itemAuditLog (
		intItemUOMId INT 
		,intItemId INT 
		-- Original Fields
		,strUPCCode_Original NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
		,strLongUPCCode_Original NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
		-- Modified Fields
		,strUPCCode_New NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
		,strLongUPCCode_New NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	)
;

-- Update selected fields in the Item table. 
BEGIN 
	INSERT INTO #tmpUpdateItemForCStore_itemAuditLog (
		intItemId 
		-- Original Fields
		,intCategoryId_Original 
		,strCountCode_Original
		,strDescription_Original
		,strItemNo_Original
		,strShortName_Original
		-- Modified Fields
		,intCategoryId_New
		,strCountCode_New 
		,strDescription_New 
		,strItemNo_New
		,strShortName_New
	)
	SELECT	[Changes].intItemId 
			, [Changes].intCategoryId_Original 
			, [Changes].strCountCode_Original 
			, [Changes].strDescription_Original 
			, [Changes].strItemNo_Original 
			, [Changes].strShortName_Original
			, [Changes].intCategoryId_New 
			, [Changes].strCountCode_New 
			, [Changes].strDescription_New 
			, [Changes].strItemNo_New 
			, [Changes].strShortName_New 
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
								-- Do not filter it by UPC code anymore. 
								--AND (
								--	@strUpcCode IS NULL 
								--	OR EXISTS (
								--		SELECT TOP 1 1 
								--		FROM	tblICItemUOM uom 
								--		WHERE	uom.intItemId = i.intItemId 
								--				AND (uom.strUpcCode = @strUpcCode OR uom.strLongUPCCode = @strUpcCode)
								--	)
								--)
					) AS Source_Query  
						ON item.intItemId = Source_Query.intItemId
						AND item.intItemId = ISNULL(@intItemId, item.intItemId) 
					
					-- If matched, update the item
					WHEN MATCHED THEN 
						UPDATE 
						SET		
							intCategoryId = ISNULL(@intCategoryId, item.intCategoryId) 
							,strCountCode = ISNULL(@strCountCode, item.strCountCode) 
							,strDescription = ISNULL(@strItemDescription, item.strDescription) 
							,dtmDateModified = GETUTCDATE()
							,intModifiedByUserId = @intEntityUserSecurityId
							,strItemNo = ISNULL(@strItemNo, item.strItemNo) 
							,strShortName = ISNULL(@strShortName, item.strShortName) 
					OUTPUT 
						$action
						, inserted.intItemId 
						-- Original values
						, deleted.intCategoryId
						, deleted.strCountCode
						, deleted.strDescription
						, deleted.strItemNo
						, deleted.strShortName
						-- Modified values 
						, inserted.intCategoryId
						, inserted.strCountCode
						, inserted.strDescription
						, inserted.strItemNo
						, inserted.strShortName 

			) AS [Changes] (
				Action
				, intItemId 
				-- Original values
				, intCategoryId_Original
				, strCountCode_Original
				, strDescription_Original
				, strItemNo_Original
				, strShortName_Original
				-- Modified values 
				, intCategoryId_New
				, strCountCode_New
				, strDescription_New
				, strItemNo_New 
				, strShortName_New
			)
	WHERE	[Changes].Action = 'UPDATE'
	;
END

-- Update the Short and Long UPC Code
BEGIN 
	INSERT INTO #tmpUpdateItemUOMForCStore_itemAuditLog (
		intItemUOMId
		,intItemId
		-- Original Fields
		,strUPCCode_Original 
		,strLongUPCCode_Original
		-- Modified Fields
		,strUPCCode_New
		,strLongUPCCode_New 
	)
	SELECT	[Changes].intItemUOMId 
			, [Changes].intItemId 
			, [Changes].strUpcCode_Original 
			, [Changes].strLongUpcCode_Original 
			, [Changes].strUpcCode_New 
			, [Changes].strLongUpcCode_New
	FROM	(
				-- Merge will help us build the audit log and update the records at the same time. 
				MERGE	
					INTO	dbo.tblICItemUOM    
					WITH	(HOLDLOCK) 
					AS		itemUom	
					USING (
						SELECT	iu.intItemUOMId 
						FROM	tblICItem i INNER JOIN tblICItemUOM iu
									ON i.intItemId = iu.intItemId
						WHERE
							iu.intItemUOMId = @intItemUOMId 
					) AS Source_Query  
						ON itemUom.intItemUOMId = Source_Query.intItemUOMId
					
					-- If matched, update the item
					WHEN MATCHED THEN 
						UPDATE 
						SET		
							strUpcCode = @strUpcCode 
							,strLongUPCCode = ISNULL(@strLongUpcCode, itemUom.strLongUPCCode) 							
					OUTPUT 
						$action
						, inserted.intItemUOMId
						, inserted.intItemId 
						-- Original values
						, deleted.strUpcCode
						, deleted.strLongUPCCode
						-- Modified values 
						, inserted.strUpcCode
						, inserted.strLongUPCCode

			) AS [Changes] (
				Action
				, intItemUOMId 
				, intItemId 
				-- Original values
				,strUpcCode_Original 
				,strLongUpcCode_Original
				-- Modified Fields
				,strUpcCode_New
				,strLongUpcCode_New 
			)
	WHERE	[Changes].Action = 'UPDATE'
	;
END

DECLARE @auditLog_strDescription AS NVARCHAR(255) 
		,@auditLog_actionType AS NVARCHAR(50) = 'Updated'
		,@auditLog_id AS INT 
		,@auditLog_Old AS NVARCHAR(255)
		,@auditLog_New AS NVARCHAR(255)

IF EXISTS (SELECT TOP 1 1 FROM #tmpUpdateItemForCStore_itemAuditLog)
BEGIN 
	DECLARE loopAuditLog CURSOR LOCAL FAST_FORWARD
	FOR 	
	SELECT	intItemId
			,strDescription = 'C-Store updates the Category'
			,strOld = category_Original.strCategoryCode
			,strNew = category_New.strCategoryCode
	FROM	#tmpUpdateItemForCStore_itemAuditLog auditLog
			LEFT JOIN tblICCategory category_Original
				ON auditLog.intCategoryId_Original = category_Original.intCategoryId
			LEFT JOIN tblICCategory category_New
				ON auditLog.intCategoryId_New = category_New.intCategoryId
	WHERE
		ISNULL(intCategoryId_Original, 0) <> ISNULL(intCategoryId_New, 0)
	UNION ALL
	SELECT	intItemId
			,strDescription = 'C-Store updates the Count Code'
			,strOld = strCountCode_Original
			,strNew = strCountCode_New
	FROM	#tmpUpdateItemForCStore_itemAuditLog auditLog
	WHERE
		ISNULL(strCountCode_Original, '') <> ISNULL(strCountCode_New, '')
	UNION ALL
	SELECT	intItemId
			,strDescription = 'C-Store updates the Description'
			,strOld = strDescription_Original
			,strNew = strDescription_New
	FROM	#tmpUpdateItemForCStore_itemAuditLog auditLog
	WHERE
		ISNULL(strDescription_Original, '') <> ISNULL(strDescription_New, '')
	UNION ALL
	SELECT	intItemId
			,strDescription = 'C-Store updates the Item No'
			,strOld = strItemNo_Original
			,strNew = strItemNo_New
	FROM	#tmpUpdateItemForCStore_itemAuditLog auditLog
	WHERE
		ISNULL(strItemNo_Original, '') <> ISNULL(strItemNo_New, '')
	UNION ALL
	SELECT	intItemId
			,strDescription = 'C-Store updates the Short Name'
			,strOld = strShortName_Original
			,strNew = strShortName_New
	FROM	#tmpUpdateItemForCStore_itemAuditLog auditLog
	WHERE
		ISNULL(strShortName_Original, '') <> ISNULL(strShortName_New, '')

	OPEN loopAuditLog;

	FETCH NEXT FROM loopAuditLog INTO 
		@auditLog_id
		,@auditLog_strDescription
		,@auditLog_Old
		,@auditLog_New
	;
	WHILE @@FETCH_STATUS = 0
	BEGIN 
		IF @auditLog_strDescription IS NOT NULL 
		BEGIN 
			EXEC dbo.uspSMAuditLog 
				@keyValue = @auditLog_id
				,@screenName = 'Inventory.view.Item'
				,@entityId = @intEntityUserSecurityId
				,@actionType = @auditLog_actionType
				,@changeDescription = @auditLog_strDescription
				,@fromValue = @auditLog_Old
				,@toValue = @auditLog_New
		END
		FETCH NEXT FROM loopAuditLog INTO 
			@auditLog_id
			,@auditLog_strDescription
			,@auditLog_Old
			,@auditLog_New
		;
	END 
	CLOSE loopAuditLog;
	DEALLOCATE loopAuditLog;
END 

IF EXISTS (SELECT TOP 1 1 FROM #tmpUpdateItemUOMForCStore_itemAuditLog)
BEGIN 
	DECLARE loopAuditLog CURSOR LOCAL FAST_FORWARD
	FOR 	
	SELECT	intItemId
			,strDescription = 'C-Store updates the Short UPC'				
			,strOld = strUPCCode_Original				
			,strNew = strUPCCode_New
	FROM	
		#tmpUpdateItemUOMForCStore_itemAuditLog auditLog
	WHERE
		ISNULL(strUPCCode_Original, '') <> ISNULL(strUPCCode_New, '')
	UNION ALL 
	SELECT	intItemId
			,strDescription = 'C-Store updates the UPC Code'
			,strOld = strLongUPCCode_Original
			,strNew = strLongUPCCode_New
	FROM	
		#tmpUpdateItemUOMForCStore_itemAuditLog auditLog
	WHERE
		ISNULL(strLongUPCCode_Original, '') <> ISNULL(strLongUPCCode_New, '')

	OPEN loopAuditLog;

	FETCH NEXT FROM loopAuditLog INTO 
		@auditLog_id
		,@auditLog_strDescription
		,@auditLog_Old
		,@auditLog_New
	;
	WHILE @@FETCH_STATUS = 0
	BEGIN 
		IF @auditLog_strDescription IS NOT NULL 
		BEGIN 
			EXEC dbo.uspSMAuditLog 
				@keyValue = @auditLog_id
				,@screenName = 'Inventory.view.Item'
				,@entityId = @intEntityUserSecurityId
				,@actionType = @auditLog_actionType
				,@changeDescription = @auditLog_strDescription
				,@fromValue = @auditLog_Old
				,@toValue = @auditLog_New
		END
		FETCH NEXT FROM loopAuditLog INTO 
			@auditLog_id
			,@auditLog_strDescription
			,@auditLog_Old
			,@auditLog_New
		;
	END 
	CLOSE loopAuditLog;
	DEALLOCATE loopAuditLog;
END 