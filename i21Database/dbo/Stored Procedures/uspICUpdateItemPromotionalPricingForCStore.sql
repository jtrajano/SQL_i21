/*
	This stored procedure will update the Promotional pricing of item. 
*/
CREATE PROCEDURE [dbo].[uspICUpdateItemPromotionalPricingForCStore]
	@dblPromotionalSalesPrice AS NUMERIC(38, 20) = NULL 
	,@dblPromotionalCost AS NUMERIC(38, 20) = NULL 
	,@dtmBeginDate AS DATETIME = NULL 
	,@dtmEndDate AS DATETIME = NULL 
	,@strUpcCode AS VARCHAR(30) = NULL 
	,@intItemId AS INT = NULL 
	,@intItemLocationId AS INT = NULL 
	,@intItemSpecialPricingId AS INT = NULL 
	,@strAction AS VARCHAR(20) = NULL
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
IF OBJECT_ID('tempdb..#tmpUpdateItemPricingForCStore_ItemSpecialPricingAuditLog') IS NULL  
	CREATE TABLE #tmpUpdateItemPricingForCStore_ItemSpecialPricingAuditLog (
		intItemId INT 
		,intItemSpecialPricingId INT 
		,dblOldUnitAfterDiscount NUMERIC(38, 20) NULL 
		,dblOldCost NUMERIC(38, 20) NULL 
		,dtmOldBeginDate DATETIME NULL 
		,dtmOldEndDate DATETIME NULL 
		,dblNewUnitAfterDiscount NUMERIC(38, 20) NULL 
		,dblNewCost NUMERIC(38, 20) NULL 
		,dtmNewBeginDate DATETIME NULL
		,dtmNewEndDate DATETIME NULL 		
		,strAction VARCHAR(20) NULL 	
	)
;

-- Update the Promotional Pricing 
BEGIN 
	INSERT INTO #tmpUpdateItemPricingForCStore_ItemSpecialPricingAuditLog (
		intItemId
		,intItemSpecialPricingId 
		,dblOldUnitAfterDiscount
		,dblOldCost
		,dtmOldBeginDate
		,dtmOldEndDate
		,dblNewUnitAfterDiscount
		,dblNewCost
		,dtmNewBeginDate
		,dtmNewEndDate
		,strAction
	)
	SELECT	[Changes].intItemId
			,[Changes].intItemSpecialPricingId
			,[Changes].dblOldUnitAfterDiscount
			,[Changes].dblOldCost
			,[Changes].dtmOldBeginDate
			,[Changes].dtmOldEndDate
			,[Changes].dblNewUnitAfterDiscount
			,[Changes].dblNewCost
			,[Changes].dtmNewBeginDate
			,[Changes].dtmNewEndDate
			,[Changes].strAction
	FROM	(
				-- Merge will help us build the audit log and update the records at the same time. 
				MERGE	
					INTO	dbo.tblICItemSpecialPricing 
					WITH	(HOLDLOCK) 
					AS		itemSpecialPricing	
					USING (
						SELECT	DISTINCT i.intItemId,
								il.intItemLocationId,
								uom.intItemUOMId,
								dtmBeginDate = @dtmBeginDate,
								dtmEndDate = @dtmEndDate
						FROM	tblICItem i 
								INNER JOIN tblICItemLocation il
									ON i.intItemId = il.intItemId 
									AND il.intItemLocationId = ISNULL(@intItemLocationId, il.intItemLocationId)
								LEFT JOIN  tblICItemSpecialPricing itemSpecialPricing 
									ON i.intItemId = itemSpecialPricing.intItemId 
									AND itemSpecialPricing.intItemLocationId = il.intItemLocationId
								INNER JOIN tblICItemUOM uom
									ON i.intItemId = uom.intItemId
									AND ysnStockUnit = 1
						WHERE	
								ISNULL(itemSpecialPricing.intItemSpecialPricingId,0) = ISNULL(@intItemSpecialPricingId, ISNULL(itemSpecialPricing.intItemSpecialPricingId, 0))
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
									@strUpcCode IS NULL 
									OR EXISTS (
										SELECT TOP 1 1 
										FROM	tblICItemUOM uom 
										WHERE	uom.intItemId = i.intItemId 
												AND (uom.strUpcCode = @strUpcCode OR uom.strLongUPCCode = @strUpcCode)
									)
								)
								AND i.intItemId = ISNULL(@intItemId, i.intItemId)
					) AS Source_Query  
						ON itemSpecialPricing.intItemLocationId = Source_Query.intItemLocationId
						AND itemSpecialPricing.intItemId = Source_Query.intItemId
						AND itemSpecialPricing.dtmBeginDate = Source_Query.dtmBeginDate
						AND itemSpecialPricing.dtmEndDate = Source_Query.dtmEndDate

					-- If matched and Action is insert, delete. the Promotional Retail Price. 
					WHEN MATCHED AND @strAction = 'INSERT' THEN 
						DELETE

					-- If matched, update the Promotional Retail Price. 
					WHEN MATCHED THEN 
						UPDATE 
						SET		dblUnitAfterDiscount = ISNULL(@dblPromotionalSalesPrice, itemSpecialPricing.dblUnitAfterDiscount)
								,dblCost = ISNULL(@dblPromotionalCost, itemSpecialPricing.dblCost)
								,dtmDateModified = GETUTCDATE()
								,intModifiedByUserId = @intEntityUserSecurityId

					-- If not matched, insert the Promotional Retail Price. 
					WHEN NOT MATCHED
						-- https://stackoverflow.com/questions/325933/determine-whether-two-date-ranges-overlap
						-- This will validate if the date range to insert does not overlap on the existing promotions
						AND (1 NOT IN  (SELECT 1 FROM tblICItemSpecialPricing 
									WHERE intItemLocationId = Source_Query.intItemLocationId
									AND intItemId = Source_Query.intItemId
									AND Source_Query.dtmBeginDate <= dtmEndDate AND dtmBeginDate <= Source_Query.dtmEndDate))
						THEN 
						INSERT (
							intItemId
							, intItemLocationId
							, strPromotionType
							, dtmBeginDate
							, dtmEndDate
							, intItemUnitMeasureId
							, dblUnit
							, dblDiscount
							, intCurrencyId
							, dblUnitAfterDiscount --Retail Price
							, dblCost --Cost
							, intCreatedByUserId
						)
						VALUES (
							Source_Query.intItemId
							, Source_Query.intItemLocationId
							, 'Vendor Discount'
							, @dtmBeginDate
							, @dtmEndDate
							, Source_Query.intItemUOMId
							, 1
							, 0
							, 3 --USD tblSMCurrency
							, @dblPromotionalSalesPrice
							, @dblPromotionalCost
							, @intEntityUserSecurityId
						)
					OUTPUT 
						inserted.intItemId
						, inserted.intItemSpecialPricingId
						, deleted.dblUnitAfterDiscount
						, deleted.dblCost
						, deleted.dtmBeginDate
						, deleted.dtmEndDate
						, inserted.dblUnitAfterDiscount
						, inserted.dblCost
						, inserted.dtmBeginDate
						, inserted.dtmEndDate
						, $action AS strAction
			) AS [Changes] (
				intItemId
				, intItemSpecialPricingId
				, dblOldUnitAfterDiscount
				, dblOldCost
				, dtmOldBeginDate
				, dtmOldEndDate
				, dblNewUnitAfterDiscount
				, dblNewCost
				, dtmNewBeginDate
				, dtmNewEndDate
				, strAction
			)
	;
END

IF EXISTS (SELECT TOP 1 1 FROM #tmpUpdateItemPricingForCStore_ItemSpecialPricingAuditLog)
BEGIN 

	DECLARE @auditLog_strDescription AS NVARCHAR(255) 
			,@auditLog_actionType AS NVARCHAR(50) 
			,@auditLog_id AS INT 
			,@auditLog_Old AS NVARCHAR(255)
			,@auditLog_New AS NVARCHAR(255)

	DECLARE loopAuditLog CURSOR LOCAL FAST_FORWARD
	FOR 	
	SELECT	intItemId
			,strDescription = 'C-Store updates the Promotional Retail Price'
			,strOld = dblOldUnitAfterDiscount
			,strNew = dblNewUnitAfterDiscount
	FROM	#tmpUpdateItemPricingForCStore_ItemSpecialPricingAuditLog auditLog
	WHERE	ISNULL(dblOldUnitAfterDiscount, 0) <> ISNULL(dblNewUnitAfterDiscount, 0) AND auditLog.strAction = 'UPDATE'
	UNION ALL 
	SELECT	intItemId
			,strDescription = 'C-Store updates the Promotional Cost'
			,strOld = dblOldCost
			,strNew = dblNewCost
	FROM	#tmpUpdateItemPricingForCStore_ItemSpecialPricingAuditLog auditLog
	WHERE	ISNULL(dblOldUnitAfterDiscount, 0) <> ISNULL(dblNewUnitAfterDiscount, 0) AND auditLog.strAction = 'UPDATE'
	UNION ALL 
	SELECT	intItemId
			,strDescription = 'C-Store updates the Promotional Begin Date'
			,strOld = dtmOldBeginDate
			,strNew = dtmNewBeginDate
	FROM	#tmpUpdateItemPricingForCStore_ItemSpecialPricingAuditLog auditLog
	WHERE	ISNULL(dtmOldBeginDate, 0) <> ISNULL(dtmNewBeginDate, 0) AND auditLog.strAction = 'UPDATE'
	UNION ALL 
	SELECT	intItemId
			,strDescription = 'C-Store updates the Promotional End Date'
			,strOld = dtmOldEndDate
			,strNew = dtmNewEndDate
	FROM	#tmpUpdateItemPricingForCStore_ItemSpecialPricingAuditLog auditLog
	WHERE	ISNULL(dtmOldEndDate, 0) <> ISNULL(dtmNewEndDate, 0) AND auditLog.strAction = 'UPDATE'
	UNION ALL 
	SELECT	intItemId
			,strDescription = 'C-Store inserts a new Promotion'
			,strOld = ''
			,strNew = ''
	FROM	#tmpUpdateItemPricingForCStore_ItemSpecialPricingAuditLog auditLog
	WHERE	auditLog.strAction = 'INSERT'

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