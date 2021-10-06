/*
	This stored procedure will update the Sales Price in the Item Pricing and Item Pricing Level. 
*/
CREATE PROCEDURE [dbo].[uspICUpdateItemPricingForCStore]
	-- filter params
	@strUpcCode AS NVARCHAR(50) = NULL 
	,@strDescription AS NVARCHAR(250) = NULL 
	,@intItemId AS INT = NULL 
	,@intItemPricingId AS INT = NULL 
	-- update params
	,@dblStandardCost AS NUMERIC(38, 20) = NULL 
	,@dblRetailPrice AS NUMERIC(38, 20) = NULL 
	,@dblLastCost AS NUMERIC(38, 20) = NULL
	,@intEntityUserSecurityId AS INT 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS ON

-- Create the temp table 
IF OBJECT_ID('tempdb..#tmpUpdateItemPricingForCStore_Location') IS NULL  
	CREATE TABLE #tmpUpdateItemPricingForCStore_Location (
		intLocationId INT 
	)

IF OBJECT_ID('tempdb..#tmpUpdateItemPricingForCStore_Vendor') IS NULL  
	CREATE TABLE #tmpUpdateItemPricingForCStore_Vendor (
		intVendorId INT 
	)

IF OBJECT_ID('tempdb..#tmpUpdateItemPricingForCStore_Category') IS NULL  
	CREATE TABLE #tmpUpdateItemPricingForCStore_Category (
		intCategoryId INT 
	)

IF OBJECT_ID('tempdb..#tmpUpdateItemPricingForCStore_Family') IS NULL  
	CREATE TABLE #tmpUpdateItemPricingForCStore_Family (
		intFamilyId INT 
	)

IF OBJECT_ID('tempdb..#tmpUpdateItemPricingForCStore_Class') IS NULL  
	CREATE TABLE #tmpUpdateItemPricingForCStore_Class (
		intClassId INT 
	)

-- Create the temp table for the audit log. 
IF OBJECT_ID('tempdb..#tmpUpdateItemPricingForCStore_ItemPricingAuditLog') IS NULL  
	CREATE TABLE #tmpUpdateItemPricingForCStore_ItemPricingAuditLog (
		intItemId INT
		,intItemPricingId INT 
		,dblOldStandardCost NUMERIC(38, 20) NULL
		,dblOldSalePrice NUMERIC(38, 20) NULL
		,dblOldLastCost NUMERIC(38, 20) NULL
		,dblNewStandardCost NUMERIC(38, 20) NULL
		,dblNewSalePrice NUMERIC(38, 20) NULL
		,dblNewLastCost NUMERIC(38, 20) NULL
	)
;

-- Update the Standard Cost and Retail Price in the Item Pricing table. 
BEGIN 
	INSERT INTO #tmpUpdateItemPricingForCStore_ItemPricingAuditLog (
		intItemId 
		,intItemPricingId 
		,dblOldStandardCost 
		,dblOldSalePrice 
		,dblOldLastCost
		,dblNewStandardCost 
		,dblNewSalePrice 
		,dblNewLastCost
	)
	SELECT	[Changes].intItemId 
			,[Changes].intItemPricingId
			,[Changes].dblOldStandardCost
			,[Changes].dblOldSalePrice
			,[Changes].dblOldLastCost
			,[Changes].dblNewStandardCost
			,[Changes].dblNewSalePrice
			,[Changes].dblNewLastCost
	FROM	(
				-- Merge will help us build the audit log and update the records at the same time. 
				MERGE	
					INTO	dbo.tblICItemPricing 
					WITH	(HOLDLOCK) 
					AS		itemPricing	
					USING (
						SELECT	ItemPricing.intItemPricingId
						FROM	tblICItemPricing ItemPricing INNER JOIN tblICItemLocation il
									ON ItemPricing.intItemLocationId = il.intItemLocationId 
									AND il.intLocationId IS NOT NULL 									
								INNER JOIN tblICItem i
									ON i.intItemId = ItemPricing.intItemId 									
						WHERE	
								ItemPricing.intItemPricingId = ISNULL(@intItemPricingId, ItemPricing.intItemPricingId) 
								AND i.intItemId = ISNULL(@intItemId, i.intItemId)
								AND (
									NOT EXISTS (SELECT TOP 1 1 FROM #tmpUpdateItemPricingForCStore_Location)
									OR EXISTS (SELECT TOP 1 1 FROM #tmpUpdateItemPricingForCStore_Location WHERE intLocationId = il.intLocationId) 			
								)
								AND (
									NOT EXISTS (SELECT TOP 1 1 FROM #tmpUpdateItemPricingForCStore_Vendor)
									OR EXISTS (SELECT TOP 1 1 FROM #tmpUpdateItemPricingForCStore_Vendor WHERE intVendorId = il.intVendorId) 			
								)
								AND (
									NOT EXISTS (SELECT TOP 1 1 FROM #tmpUpdateItemPricingForCStore_Category)
									OR EXISTS (SELECT TOP 1 1 FROM #tmpUpdateItemPricingForCStore_Category WHERE intCategoryId = i.intCategoryId)			
								)
								AND (
									NOT EXISTS (SELECT TOP 1 1 FROM #tmpUpdateItemPricingForCStore_Family)
									OR EXISTS (SELECT TOP 1 1 FROM #tmpUpdateItemPricingForCStore_Family WHERE intFamilyId = il.intFamilyId)			
								)
								AND (
									NOT EXISTS (SELECT TOP 1 1 FROM #tmpUpdateItemPricingForCStore_Class)
									OR EXISTS (SELECT TOP 1 1 FROM #tmpUpdateItemPricingForCStore_Class WHERE intClassId = il.intClassId )			
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
								AND ISNULL(ItemPricing.strPricingMethod, 0) = 'None'
					) AS Source_Query  
						ON itemPricing.intItemPricingId = Source_Query.intItemPricingId					
					
					-- If matched, update the Standard Cost and Retail Price. 
					WHEN MATCHED THEN 
						UPDATE 
						SET		dblStandardCost = ISNULL(@dblStandardCost, itemPricing.dblStandardCost)
								,dblSalePrice = ISNULL(@dblRetailPrice, itemPricing.dblSalePrice)
								,dblLastCost = ISNULL(@dblLastCost, itemPricing.dblLastCost)
								,dtmDateModified = GETUTCDATE()
								,intModifiedByUserId = @intEntityUserSecurityId
					OUTPUT 
						$action
						, inserted.intItemId 
						, inserted.intItemPricingId
						, deleted.dblStandardCost 
						, deleted.dblSalePrice
						, deleted.dblLastCost
						, inserted.dblStandardCost
						, inserted.dblSalePrice
						, inserted.dblLastCost
			) AS [Changes] (
				Action
				, intItemId 
				, intItemPricingId
				, dblOldStandardCost
				, dblOldSalePrice
				, dblOldLastCost
				, dblNewStandardCost
				, dblNewSalePrice
				, dblNewLastCost 
			)
	WHERE	[Changes].Action = 'UPDATE'
	;
END

IF EXISTS (SELECT TOP 1 1 FROM #tmpUpdateItemPricingForCStore_ItemPricingAuditLog)
BEGIN 
	
	DECLARE @auditLog_strDescription AS NVARCHAR(255) 
			,@auditLog_actionType AS NVARCHAR(50) = 'Updated'
			,@auditLog_id AS INT 
			,@auditLog_Old AS NVARCHAR(255)
			,@auditLog_New AS NVARCHAR(255)

	DECLARE loopAuditLog CURSOR LOCAL FAST_FORWARD
	FOR 	
	SELECT	intItemId
			,strDescription = 'C-Store updates the Standard Cost'
			,strOld = dblOldStandardCost
			,strNew = dblNewStandardCost
	FROM	#tmpUpdateItemPricingForCStore_ItemPricingAuditLog
	WHERE	ISNULL(dblOldStandardCost, 0) <> ISNULL(dblNewStandardCost, 0)
	UNION ALL 
	SELECT	intItemId
			,strDescription = 'C-Store updates the Retail Price'
			,strOld = dblOldSalePrice
			,strNew = dblNewSalePrice
	FROM	#tmpUpdateItemPricingForCStore_ItemPricingAuditLog
	WHERE	ISNULL(dblOldSalePrice, 0) <> ISNULL(dblNewSalePrice, 0)
	UNION ALL 
	SELECT	intItemId
			,strDescription = 'C-Store updates the Last Cost'
			,strOld = dblOldLastCost
			,strNew = dblNewLastCost
	FROM	#tmpUpdateItemPricingForCStore_ItemPricingAuditLog
	WHERE	ISNULL(dblOldLastCost, 0) <> ISNULL(dblNewLastCost, 0)

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