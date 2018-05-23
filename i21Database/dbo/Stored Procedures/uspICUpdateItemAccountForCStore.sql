CREATE PROCEDURE [dbo].[uspICUpdateItemAccountForCStore]
	-- filter params
	@strUpcCode AS NVARCHAR(50) = NULL 
	,@strDescription AS NVARCHAR(250) = NULL 
	,@dblRetailPriceFrom AS NUMERIC(38, 20) = NULL  
	,@dblRetailPriceTo AS NUMERIC(38, 20) = NULL 
	-- update params
	,@intGLAccountCOGS INT = NULL
	,@intGLAccountSalesRevenue INT = NULL
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
IF OBJECT_ID('tempdb..#tmpUpdateItemAccountForCStore_itemAuditLog') IS NULL  
	CREATE TABLE #tmpUpdateItemAccountForCStore_itemAuditLog (
		intItemId INT
		, intItemAccountId INT		
		, intAccountCategoryId INT 
		, strAction NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
		-- Original Fields		
		, intAccountId_Original INT NULL		
		-- Modified Fields
		, intAccountId_New INT NULL		
	)
;

-- Update or Add the account id for COGS
IF @intGLAccountCOGS IS NOT NULL 
BEGIN 
	INSERT INTO #tmpUpdateItemAccountForCStore_itemAuditLog (
		strAction
		, intItemId 
		, intItemAccountId
		, intAccountCategoryId		
		-- Original Fields
		, intAccountId_Original		
		-- Modified Fields
		, intAccountId_New 
	)
	SELECT	[Changes].Action 
			, [Changes].intItemId 
			, [Changes].intItemAccountId 
			, [Changes].intAccountCategoryId 			
			, [Changes].intAccountId_Original
			, [Changes].intAccountId_New 
	FROM	(
				-- Merge will help us build the audit log and update the records at the same time. 
				MERGE	
					INTO	dbo.tblICItemAccount   
					WITH	(HOLDLOCK) 
					AS		itemAccount	
					USING (
						SELECT	ia.intItemAccountId
								, i.intItemId
								, ia.intAccountCategoryId 
								, category = gaSource.strAccountCategory
								, categoryId = gaSource.intAccountCategoryId
						FROM	tblICItem i LEFT JOIN (
									tblICItemAccount ia INNER JOIN tblGLAccountCategory ga
										ON ia.intAccountCategoryId = ga.intAccountCategoryId
								)
									ON i.intItemId = ia.intItemId 
								LEFT JOIN tblGLAccountCategory gaSource
									ON gaSource.strAccountCategory = 'Cost of Goods'
								CROSS APPLY (
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
											AND 
											ga.strAccountCategory = 'Cost of Goods'

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
						ON itemAccount.intItemAccountId = Source_Query.intItemAccountId
						AND itemAccount.intAccountCategoryId = Source_Query.intAccountCategoryId
					
					WHEN MATCHED THEN 
						UPDATE 
						SET		
							intAccountId = ISNULL(@intGLAccountCOGS, itemAccount.intAccountId) 
							,dtmDateModified = GETUTCDATE()
							,intModifiedByUserId = @intEntityUserSecurityId

					WHEN NOT MATCHED BY TARGET THEN 
						INSERT (
							intItemId
							,intAccountCategoryId
							,intAccountId
							,intSort
							,intConcurrencyId
							,dtmDateCreated
							,dtmDateModified
							,intCreatedByUserId
							,intModifiedByUserId
						)
						VALUES (
							Source_Query.intItemId
							,Source_Query.categoryId
							,@intGLAccountCOGS
							, 1
							, 1
							, GETUTCDATE()
							, GETUTCDATE()
							, @intEntityUserSecurityId
							, @intEntityUserSecurityId						
						)

					OUTPUT 
						$action
						, inserted.intItemId
						, inserted.intItemAccountId 						
						, inserted.intAccountCategoryId
						-- Original values
						, deleted.intAccountId
						-- Modified values 
						, inserted.intAccountId

			) AS [Changes] (
				Action
				, intItemId 
				, intItemAccountId
				, intAccountCategoryId
				-- Original values
				, intAccountId_Original
				-- Modified values 
				, intAccountId_New 
			)
	WHERE	[Changes].Action IN ('UPDATE', 'INSERT') 
	;
END


-- Update or Add the account id for Sales Account 
IF @intGLAccountSalesRevenue IS NOT NULL 
BEGIN 
	INSERT INTO #tmpUpdateItemAccountForCStore_itemAuditLog (
		strAction
		, intItemId 
		, intItemAccountId
		, intAccountCategoryId		
		-- Original Fields
		, intAccountId_Original		
		-- Modified Fields
		, intAccountId_New 
	)
	SELECT	[Changes].Action 
			, [Changes].intItemId 
			, [Changes].intItemAccountId 
			, [Changes].intAccountCategoryId 			
			, [Changes].intAccountId_Original
			, [Changes].intAccountId_New 
	FROM	(
				-- Merge will help us build the audit log and update the records at the same time. 
				MERGE	
					INTO	dbo.tblICItemAccount   
					WITH	(HOLDLOCK) 
					AS		itemAccount	
					USING (
						SELECT	ia.intItemAccountId
								, i.intItemId
								, ia.intAccountCategoryId 
								, category = gaSource.strAccountCategory
								, categoryId = gaSource.intAccountCategoryId
						FROM	tblICItem i LEFT JOIN (
									tblICItemAccount ia INNER JOIN tblGLAccountCategory ga
										ON ia.intAccountCategoryId = ga.intAccountCategoryId
								)
									ON i.intItemId = ia.intItemId 
								LEFT JOIN tblGLAccountCategory gaSource
									ON gaSource.strAccountCategory = 'Sales Account'
								CROSS APPLY (
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
											AND 
											ga.strAccountCategory = 'Sales Account'

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
						ON itemAccount.intItemAccountId = Source_Query.intItemAccountId
						AND itemAccount.intAccountCategoryId = Source_Query.intAccountCategoryId
					
					WHEN MATCHED THEN 
						UPDATE 
						SET		
							intAccountId = ISNULL(@intGLAccountSalesRevenue, itemAccount.intAccountId) 
							,dtmDateModified = GETUTCDATE()
							,intModifiedByUserId = @intEntityUserSecurityId

					WHEN NOT MATCHED BY TARGET THEN 
						INSERT (
							intItemId
							,intAccountCategoryId
							,intAccountId
							,intSort
							,intConcurrencyId
							,dtmDateCreated
							,dtmDateModified
							,intCreatedByUserId
							,intModifiedByUserId
						)
						VALUES (
							Source_Query.intItemId
							,Source_Query.categoryId
							,@intGLAccountSalesRevenue
							, 1
							, 1
							, GETUTCDATE()
							, GETUTCDATE()
							, @intEntityUserSecurityId
							, @intEntityUserSecurityId						
						)

					OUTPUT 
						$action
						, inserted.intItemId
						, inserted.intItemAccountId 						
						, inserted.intAccountCategoryId
						-- Original values
						, deleted.intAccountId
						-- Modified values 
						, inserted.intAccountId

			) AS [Changes] (
				Action
				, intItemId 
				, intItemAccountId
				, intAccountCategoryId
				-- Original values
				, intAccountId_Original
				-- Modified values 
				, intAccountId_New 
			)
	WHERE	[Changes].Action IN ('UPDATE', 'INSERT') 
	;
END

IF EXISTS (SELECT TOP 1 1 FROM #tmpUpdateItemAccountForCStore_itemAuditLog)
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
							, 'C-Store adds a new GL Account Id for ' + ga.strAccountCategory 
							, fromAccount.strAccountId
							, toAccount.strAccountId
							, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT
						) 
						, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT
					) 
		FROM	#tmpUpdateItemAccountForCStore_itemAuditLog auditLog LEFT JOIN tblGLAccountCategory ga
					ON auditLog.intAccountCategoryId = ga.intAccountCategoryId 
				LEFT JOIN tblGLAccount fromAccount 
					ON fromAccount.intAccountId = intAccountId_Original
				LEFT JOIN tblGLAccount toAccount 
					ON toAccount.intAccountId = intAccountId_New
		WHERE	ISNULL(intAccountId_Original, 0) <> ISNULL(intAccountId_New, 0)
				AND auditLog.strAction = 'INSERT'

		UNION ALL
		SELECT	intItemId
				,strJsonData = 
					dbo.fnFormatMessage(
						@json1
						, CAST(intItemId AS NVARCHAR(20)) 
						, dbo.fnFormatMessage(
							@json2_string
							, 'C-Store updates the GL Account Id for ' + ga.strAccountCategory 
							, fromAccount.strAccountId
							, toAccount.strAccountId
							, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT
						) 
						, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT
					) 
		FROM	#tmpUpdateItemAccountForCStore_itemAuditLog auditLog LEFT JOIN tblGLAccountCategory ga
					ON auditLog.intAccountCategoryId = ga.intAccountCategoryId 
				LEFT JOIN tblGLAccount fromAccount 
					ON fromAccount.intAccountId = intAccountId_Original
				LEFT JOIN tblGLAccount toAccount 
					ON toAccount.intAccountId = intAccountId_New
		WHERE	ISNULL(intAccountId_Original, 0) <> ISNULL(intAccountId_New, 0)
				AND auditLog.strAction = 'UPDATE'

	) auditLog
	WHERE auditLog.strJsonData IS NOT NULL 
END 