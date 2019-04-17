/*
	This stored procedure will update the Sales Price in the Item Pricing and Item Pricing Level. 
*/
CREATE PROCEDURE [dbo].[uspICUpdateItemPromotionalPricingForCStore]
	@dblPromotionalSalesPrice AS NUMERIC(38, 20) = NULL 
	,@dtmBeginDate AS DATETIME = NULL 
	,@dtmEndDate AS DATETIME = NULL 
	,@intEntityUserSecurityId AS INT 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

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
IF OBJECT_ID('tempdb..#tmpUpdateItemPricingForCStore_ItemSpecialPricingAuditLog') IS NULL  
	CREATE TABLE #tmpUpdateItemPricingForCStore_ItemSpecialPricingAuditLog (
		intItemId INT 
		,intItemSpecialPricingId INT 
		,dblOldUnitAfterDiscount NUMERIC(38, 20) NULL 
		,dtmOldBeginDate DATETIME NULL 
		,dtmOldEndDate DATETIME NULL 
		,dblNewUnitAfterDiscount NUMERIC(38, 20) NULL 
		,dtmNewBeginDate DATETIME NULL
		,dtmNewEndDate DATETIME NULL 		
	)
;

-- Update the Promotional Pricing 
BEGIN 
	INSERT INTO #tmpUpdateItemPricingForCStore_ItemSpecialPricingAuditLog (
		intItemId
		,intItemSpecialPricingId 
		,dblOldUnitAfterDiscount
		,dtmOldBeginDate
		,dtmOldEndDate
		,dblNewUnitAfterDiscount
		,dtmNewBeginDate
		,dtmNewEndDate
	)
	SELECT	[Changes].intItemId
			,[Changes].intItemSpecialPricingId
			,[Changes].dblOldUnitAfterDiscount
			,[Changes].dtmOldBeginDate
			,[Changes].dtmOldEndDate
			,[Changes].dblNewUnitAfterDiscount
			,[Changes].dtmNewBeginDate
			,[Changes].dtmNewEndDate
	FROM	(
				-- Merge will help us build the audit log and update the records at the same time. 
				MERGE	
					INTO	dbo.tblICItemSpecialPricing 
					WITH	(HOLDLOCK) 
					AS		itemSpecialPricing	
					USING (
						SELECT	itemSpecialPricing.intItemSpecialPricingId
						FROM	tblICItemSpecialPricing itemSpecialPricing INNER JOIN tblICItemLocation il
									ON itemSpecialPricing.intItemLocationId = il.intItemLocationId 
								INNER JOIN tblICItem i
									ON i.intItemId = itemSpecialPricing.intItemId 
						WHERE	(
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
					) AS Source_Query  
						ON itemSpecialPricing.intItemSpecialPricingId = Source_Query.intItemSpecialPricingId					
					
					-- If matched, update the Promotional Retail Price. 
					WHEN MATCHED THEN 
						UPDATE 
						SET		dblUnitAfterDiscount = ISNULL(@dblPromotionalSalesPrice, itemSpecialPricing.dblUnitAfterDiscount)
								,dtmBeginDate = ISNULL(@dtmBeginDate, itemSpecialPricing.dtmBeginDate)
								,dtmEndDate = ISNULL(@dtmEndDate, itemSpecialPricing.dtmEndDate)
								,dtmDateModified = GETUTCDATE()
								,intModifiedByUserId = @intEntityUserSecurityId
					OUTPUT 
						$action
						, inserted.intItemId
						, inserted.intItemSpecialPricingId
						, deleted.dblUnitAfterDiscount
						, deleted.dtmBeginDate
						, deleted.dtmEndDate
						, inserted.dblUnitAfterDiscount
						, inserted.dtmBeginDate
						, inserted.dtmEndDate
			) AS [Changes] (
				Action
				, intItemId
				, intItemSpecialPricingId
				, dblOldUnitAfterDiscount
				, dtmOldBeginDate
				, dtmOldEndDate
				, dblNewUnitAfterDiscount
				, dtmNewBeginDate
				, dtmNewEndDate
			)
	WHERE	[Changes].Action = 'UPDATE'
	;
END

IF EXISTS (SELECT TOP 1 1 FROM #tmpUpdateItemPricingForCStore_ItemSpecialPricingAuditLog)
BEGIN 
	
	--INSERT INTO tblSMAuditLog(
	--		strActionType
	--		, strTransactionType
	--		, strRecordNo
	--		, strDescription
	--		, strRoute
	--		, strJsonData
	--		, dtmDate
	--		, intEntityId
	--		, intConcurrencyId
	--)
	---- Add audit logs for Promotional Retail Price
	--SELECT 
	--		strActionType = 'Updated'
	--		, strTransactionType = 'Inventory.view.Item'
	--		, strRecordNo = intItemId
	--		, strDescription = ''
	--		, strRoute = null 
	--		, strJsonData = 
	--			dbo.fnFormatMessage(
	--				'{"action":"Updated","change":"Updated - Record: %s","iconCls":"small-menu-maintenance","children":[%s]}'
	--				, CAST(intItemId AS NVARCHAR(20)) 
	--				, dbo.fnFormatMessage(
	--					'{"change":"%s","iconCls":"small-menu-maintenance","from":"%f","to":"%f","leaf":true}'
	--					, 'C-Store updates the Promotional Retail Price'
	--					, dblOldUnitAfterDiscount
	--					, dblNewUnitAfterDiscount
	--					, DEFAULT
	--					, DEFAULT
	--					, DEFAULT
	--					, DEFAULT
	--					, DEFAULT
	--					, DEFAULT
	--					, DEFAULT
	--				) 
	--				, DEFAULT
	--				, DEFAULT
	--				, DEFAULT
	--				, DEFAULT
	--				, DEFAULT
	--				, DEFAULT
	--				, DEFAULT
	--				, DEFAULT
	--			) 
	--		, dtmDate = GETUTCDATE()
	--		, intEntityId = @intEntityUserSecurityId 
	--		, intConcurrencyId = 1
	--FROM	#tmpUpdateItemPricingForCStore_ItemSpecialPricingAuditLog 
	--WHERE	ISNULL(dblOldUnitAfterDiscount, 0) <> ISNULL(dblNewUnitAfterDiscount, 0)
	---- Add audit logs for Promotional Begin Date
	--UNION ALL 
	--SELECT 
	--		strActionType = 'Updated'
	--		, strTransactionType = 'Inventory.view.Item'
	--		, strRecordNo = intItemId
	--		, strDescription = ''
	--		, strRoute = null 
	--		, strJsonData = 
	--			dbo.fnFormatMessage(
	--				'{"action":"Updated","change":"Updated - Record: %s","iconCls":"small-menu-maintenance","children":[%s]}'
	--				, CAST(intItemId AS NVARCHAR(20)) 
	--				, dbo.fnFormatMessage(
	--					'{"change":"%s","iconCls":"small-menu-maintenance","from":"%d","to":"%d","leaf":true}'
	--					, 'C-Store updates the Promotional Begin Date'
	--					, dtmOldBeginDate
	--					, dtmNewBeginDate
	--					, DEFAULT
	--					, DEFAULT
	--					, DEFAULT
	--					, DEFAULT
	--					, DEFAULT
	--					, DEFAULT
	--					, DEFAULT
	--				) 
	--				, DEFAULT
	--				, DEFAULT
	--				, DEFAULT
	--				, DEFAULT
	--				, DEFAULT
	--				, DEFAULT
	--				, DEFAULT
	--				, DEFAULT
	--			) 
	--		, dtmDate = GETUTCDATE()
	--		, intEntityId = @intEntityUserSecurityId 
	--		, intConcurrencyId = 1
	--FROM	#tmpUpdateItemPricingForCStore_ItemSpecialPricingAuditLog 
	--WHERE	ISNULL(dtmOldBeginDate, 0) <> ISNULL(dtmNewBeginDate, 0)
	---- Add audit logs for Promotional End Date
	--UNION ALL 
	--SELECT 
	--		strActionType = 'Updated'
	--		, strTransactionType = 'Inventory.view.Item'
	--		, strRecordNo = intItemId
	--		, strDescription = ''
	--		, strRoute = null 
	--		, strJsonData = 
	--			dbo.fnFormatMessage(
	--				'{"action":"Updated","change":"Updated - Record: %s","iconCls":"small-menu-maintenance","children":[%s]}'
	--				, CAST(intItemId AS NVARCHAR(20)) 
	--				, dbo.fnFormatMessage(
	--					'{"change":"%s","iconCls":"small-menu-maintenance","from":"%d","to":"%d","leaf":true}'
	--					, 'C-Store updates the Promotional End Date'
	--					, dtmOldEndDate
	--					, dtmNewEndDate
	--					, DEFAULT
	--					, DEFAULT
	--					, DEFAULT
	--					, DEFAULT
	--					, DEFAULT
	--					, DEFAULT
	--					, DEFAULT
	--				) 
	--				, DEFAULT
	--				, DEFAULT
	--				, DEFAULT
	--				, DEFAULT
	--				, DEFAULT
	--				, DEFAULT
	--				, DEFAULT
	--				, DEFAULT
	--			) 
	--		, dtmDate = GETUTCDATE()
	--		, intEntityId = @intEntityUserSecurityId 
	--		, intConcurrencyId = 1
	--FROM	#tmpUpdateItemPricingForCStore_ItemSpecialPricingAuditLog 
	--WHERE	ISNULL(dtmOldEndDate, 0) <> ISNULL(dtmNewEndDate, 0)


	DECLARE @auditLog_strDescription AS NVARCHAR(255) 
			,@auditLog_actionType AS NVARCHAR(50) = 'Updated'
			,@auditLog_id AS INT 
			,@auditLog_Old AS NVARCHAR(255)
			,@auditLog_New AS NVARCHAR(255)

	DECLARE loopAuditLog CURSOR LOCAL FAST_FORWARD
	FOR 	
	SELECT	intItemId
			,strDescription = 
				CASE 
					WHEN ISNULL(dblOldUnitAfterDiscount, 0) <> ISNULL(dblNewUnitAfterDiscount, 0) THEN 
						'C-Store updates the Promotional Retail Price'
					WHEN ISNULL(dtmOldBeginDate, 0) <> ISNULL(dtmNewBeginDate, 0) THEN 
						'C-Store updates the Promotional Begin Date'
					WHEN ISNULL(dtmOldEndDate, 0) <> ISNULL(dtmNewEndDate, 0) THEN 
						'C-Store updates the Promotional End Date'
				END 
			,strOld = 
				CASE 
					WHEN ISNULL(dblOldUnitAfterDiscount, 0) <> ISNULL(dblNewUnitAfterDiscount, 0) THEN 
						dblOldUnitAfterDiscount
					WHEN ISNULL(dtmOldBeginDate, 0) <> ISNULL(dtmNewBeginDate, 0) THEN 
						dtmOldBeginDate
					WHEN ISNULL(dtmOldEndDate, 0) <> ISNULL(dtmNewEndDate, 0) THEN 
						dtmOldEndDate
				END  
			,strNew = 
				CASE 
					WHEN ISNULL(dblOldUnitAfterDiscount, 0) <> ISNULL(dblNewUnitAfterDiscount, 0) THEN 
						dblNewUnitAfterDiscount
					WHEN ISNULL(dtmOldBeginDate, 0) <> ISNULL(dtmNewBeginDate, 0) THEN 
						dtmNewBeginDate
					WHEN ISNULL(dtmOldEndDate, 0) <> ISNULL(dtmNewEndDate, 0) THEN 
						dtmNewEndDate
				END 
	FROM	#tmpUpdateItemPricingForCStore_ItemSpecialPricingAuditLog auditLog
			LEFT JOIN tblICCategory category_Original
				ON auditLog.intCategoryId_Original = category_Original.intCategoryId
			LEFT JOIN tblICCategory category_New
				ON auditLog.intCategoryId_New = category_New.intCategoryId
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