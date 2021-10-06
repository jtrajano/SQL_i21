CREATE PROCEDURE [dbo].[uspICUpdateItemVendorXrefForCStore]
	-- filter params
	@intItemId AS INT = NULL 
	-- update params
	,@strVendorProduct NVARCHAR(50) = NULL 
	,@strVendorProductDescription NVARCHAR(1000) = NULL 
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
IF OBJECT_ID('tempdb..#tmpUpdateItemVendorXrefForCStore_itemAuditLog') IS NULL  
	CREATE TABLE #tmpUpdateItemVendorXrefForCStore_itemAuditLog (
		intItemId INT
		, intItemLocationId INT		
		, intItemVendorXrefId INT		
		, strAction NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
		-- Original Fields		
		, strVendorProduct_Original NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
		, strVendorProductDescription_Original NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL
		-- Modified Fields
		, strVendorProduct_New NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
		, strVendorProductDescription_New NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL
	)
;

-- Update or Add the account id for Sales Account 
IF @strVendorProduct IS NOT NULL AND LTRIM(RTRIM(@strVendorProduct)) <> ''
BEGIN 
	INSERT INTO #tmpUpdateItemVendorXrefForCStore_itemAuditLog (
		strAction
		, intItemId 
		, intItemLocationId
		, intItemVendorXrefId
		-- Original Fields
		, strVendorProduct_Original		
		, strVendorProductDescription_Original
		-- Modified Fields
		, strVendorProduct_New
		, strVendorProductDescription_New
	)
	SELECT	[Changes].Action 
			, [Changes].intItemId 
			, [Changes].intItemLocationId 
			, [Changes].intItemVendorXrefId 
			, [Changes].strVendorProduct_Original
			, [Changes].strVendorProductDescription_Original
			, [Changes].strVendorProduct_New
			, [Changes].strVendorProductDescription_New
	FROM	(
				-- Merge will help us build the audit log and update the records at the same time. 
				MERGE	
					INTO	dbo.tblICItemVendorXref   
					WITH	(HOLDLOCK) 
					AS		itemVendorXref	
					USING (
						SELECT	i.intItemId
								,itemLocation.intItemLocationId
								,itemLocation.intVendorId
						FROM	tblICItem i INNER JOIN tblICItemLocation itemLocation 
									ON i.intItemId = itemLocation.intItemId
									AND i.intItemId = ISNULL(@intItemId, i.intItemId)
						WHERE	
								(
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
									NOT EXISTS (SELECT TOP 1 1 FROM #tmpUpdateItemForCStore_Category)
									OR EXISTS (SELECT TOP 1 1 FROM #tmpUpdateItemForCStore_Category WHERE intCategoryId = i.intCategoryId)			
								)
								AND itemLocation.intLocationId IS NOT NULL 
					) AS Source_Query  
						ON itemVendorXref.intItemId = Source_Query.intItemId		
						AND itemVendorXref.intItemLocationId = Source_Query.intItemLocationId		
					
					WHEN MATCHED THEN 
						UPDATE 
						SET		
							strVendorProduct = ISNULL(@strVendorProduct, itemVendorXref.strVendorProduct) 
							,strProductDescription = ISNULL(@strVendorProductDescription, itemVendorXref.strProductDescription)
							,dtmDateModified = GETUTCDATE()
							,intModifiedByUserId = @intEntityUserSecurityId

					WHEN NOT MATCHED BY TARGET AND Source_Query.intVendorId IS NOT NULL THEN 
						INSERT (
							intItemId
							,intItemLocationId
							,intVendorId
							,intVendorSetupId
							,strVendorProduct
							,strProductDescription
							,dblConversionFactor
							,intItemUnitMeasureId
							,intConcurrencyId
							,dtmDateCreated
							,dtmDateModified
							,intCreatedByUserId
							,intModifiedByUserId
						)
						VALUES (
							Source_Query.intItemId
							,Source_Query.intItemLocationId
							,Source_Query.intVendorId
							, NULL -- intVendorSetupId
							, @strVendorProduct -- strVendorProduct
							, ISNULL(@strVendorProductDescription, '') -- strProductDescription
							, 1 -- dblConversionFactor
							, NULL -- intItemUnitMeasureId
							, 1							
							, GETUTCDATE()
							, GETUTCDATE()
							, @intEntityUserSecurityId
							, @intEntityUserSecurityId						
						)

					OUTPUT 
						$action
						, inserted.intItemId
						, inserted.intItemLocationId
						, inserted.intItemVendorXrefId 						
						-- Original values
						, deleted.strVendorProduct
						, deleted.strProductDescription
						-- Modified values 
						, inserted.strVendorProduct
						, inserted.strProductDescription

			) AS [Changes] (
				Action
				, intItemId 
				, intItemLocationId 
				, intItemVendorXrefId
				-- Original values
				, strVendorProduct_Original
				, strVendorProductDescription_Original
				-- Modified values 
				, strVendorProduct_New 
				, strVendorProductDescription_New
			)
	WHERE	[Changes].Action IN ('UPDATE', 'INSERT') 
	;
END

IF EXISTS (SELECT TOP 1 1 FROM #tmpUpdateItemVendorXrefForCStore_itemAuditLog)
BEGIN 
	DECLARE @auditLog_strDescription AS NVARCHAR(255) 
			,@auditLog_actionType AS NVARCHAR(50) = 'Updated'
			,@auditLog_id AS INT 
			,@auditLog_Old AS NVARCHAR(255)
			,@auditLog_New AS NVARCHAR(255)

	DECLARE loopAuditLog CURSOR LOCAL FAST_FORWARD
	FOR 	
	SELECT	auditLog.intItemId
			,strDescription = 'C-Store adds a Vendor Product in the Vendor Item Cross Reference Grid'
			,strOld = strVendorProduct_Original
			,strNew = strVendorProduct_New
	FROM	#tmpUpdateItemVendorXrefForCStore_itemAuditLog auditLog 
	WHERE	ISNULL(strVendorProduct_Original, '') <> ISNULL(strVendorProduct_New, '')
			AND auditLog.strAction = 'INSERT'
	UNION ALL 
	SELECT	auditLog.intItemId
			,strDescription = 'C-Store updates the Vendor Product in the Vendor Item Cross Reference Grid'
			,strOld = strVendorProduct_Original
			,strNew = strVendorProduct_New
	FROM	#tmpUpdateItemVendorXrefForCStore_itemAuditLog auditLog 
	WHERE	ISNULL(strVendorProduct_Original, '') <> ISNULL(strVendorProduct_New, '')
			AND auditLog.strAction = 'UPDATE'
	UNION ALL 
	SELECT	auditLog.intItemId
			,strDescription = 'C-Store updates the Product Description in the Vendor Item Cross Reference Grid'
			,strOld = strVendorProductDescription_Original
			,strNew = strVendorProductDescription_New
	FROM	#tmpUpdateItemVendorXrefForCStore_itemAuditLog auditLog 
	WHERE	ISNULL(strVendorProductDescription_Original, '') <> ISNULL(strVendorProductDescription_New, '')
			AND auditLog.strAction = 'UPDATE'

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