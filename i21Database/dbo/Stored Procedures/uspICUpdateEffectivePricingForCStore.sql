/*
	This stored procedure will update the With Effective Date Sales Price and Cost in the Item Pricing 
*/
CREATE PROCEDURE [dbo].[uspICUpdateEffectivePricingForCStore]
	-- filter params
	@strUpcCode AS NVARCHAR(50) = NULL 
	,@strDescription AS NVARCHAR(250) = NULL 
	,@strScreen AS NVARCHAR(50) = NULL 
	,@intItemId AS INT = NULL 
	,@intItemLocationId AS INT = NULL 
	,@intEffectiveItemCostId AS INT = NULL 
	,@intEffectiveItemPriceId AS INT = NULL 
	-- update params
	,@dblStandardCost AS NUMERIC(38, 20) = NULL 
	,@dblRetailPrice AS NUMERIC(38, 20) = NULL 
	,@dtmEffectiveDate AS DATETIME = NULL
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
IF OBJECT_ID('tempdb..#tmpEffectiveCostForCStore_AuditLog') IS NULL  
	CREATE TABLE #tmpEffectiveCostForCStore_AuditLog (
		intEffectiveItemCostId INT
		,intItemId INT
		,intItemLocationId INT 
		,dblOldCost NUMERIC(38, 20) NULL
		,dblNewCost NUMERIC(38, 20) NULL
		,dtmOldEffectiveDate DATETIME NULL
		,dtmNewEffectiveDate DATETIME NULL
		,strAction NVARCHAR(50) NULL
	)
;

-- Create the temp table for the audit log. 
IF OBJECT_ID('tempdb..#tmpEffectivePriceForCStore_AuditLog') IS NULL  
	CREATE TABLE #tmpEffectivePriceForCStore_AuditLog (
		intEffectiveItemPriceId INT
		,intItemId INT
		,intItemLocationId INT 
		,dblOldPrice NUMERIC(38, 20) NULL
		,dblNewPrice NUMERIC(38, 20) NULL
		,dtmOldEffectiveDate DATETIME NULL
		,dtmNewEffectiveDate DATETIME NULL
		,strAction NVARCHAR(50) NULL
	)
;

DECLARE @auditLogItem_id AS INT 
		,@auditLogCost_Old AS NVARCHAR(255)
		,@auditLogCost_New AS NVARCHAR(255)
		,@auditLogAction AS NVARCHAR(50)
		,@auditLogDescription AS NVARCHAR(255)

----------------------------------------------------------------------------
-- Update the Item Cost with Effective Date
----------------------------------------------------------------------------
IF @dtmEffectiveDate IS NOT NULL AND @dblStandardCost IS NOT NULL 
BEGIN 	
	INSERT INTO #tmpEffectiveCostForCStore_AuditLog (
		strAction 
		, intEffectiveItemCostId 
		, intItemId 
		, intItemLocationId
		, dblOldCost
		, dblNewCost
		, dtmOldEffectiveDate
		, dtmNewEffectiveDate				
	)
	SELECT 
		strAction 
		, intEffectiveItemCostId 
		, intItemId 
		, intItemLocationId
		, dblOldCost
		, dblNewCost
		, dblOldEffectiveDate
		, dblNewEffectiveDate		
	FROM (
		MERGE	
		INTO	dbo.tblICEffectiveItemCost 
		WITH	(HOLDLOCK) 
		AS		e
		USING (
			SELECT	i.intItemId, il.intItemLocationId, @dtmEffectiveDate AS dtmEffectiveDate, @dblStandardCost AS dblNewStandardCost
			FROM	tblICItemLocation il								
						INNER JOIN tblICItem i
							ON i.intItemId = il.intItemId 									
			WHERE	
					i.intItemId = ISNULL(@intItemId, i.intItemId)
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
						@intItemLocationId IS NULL 
						OR il.intItemLocationId = @intItemLocationId 
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
		) AS u
			ON e.intItemId = u.intItemId
			AND e.intItemLocationId = u.intItemLocationId
			AND CONVERT(DATE, e.dtmEffectiveCostDate) = CONVERT(DATE, u.dtmEffectiveDate)
			AND e.intEffectiveItemCostId = ISNULL(@intEffectiveItemCostId, e.intEffectiveItemCostId)

		-- If matched, update the effective cost.
		WHEN MATCHED THEN 
			UPDATE 
			SET 
				e.dblCost = @dblStandardCost
				,e.dtmDateModified = GETDATE()
				,e.intModifiedByUserId = @intEntityUserSecurityId
		
		-- If none found, insert a new Effective Item Cost
		WHEN NOT MATCHED THEN 
			INSERT (
				intItemId
				, intItemLocationId
				, dblCost
				, dtmDateCreated
				, dtmEffectiveCostDate
				, intCreatedByUserId
				, intConcurrencyId
			)
			VALUES (
				u.intItemId
				, u.intItemLocationId
				, u.dblNewStandardCost
				, GETUTCDATE()
				, @dtmEffectiveDate
				, @intEntityUserSecurityId
				, 1
			)

		OUTPUT 
			$action
			, inserted.intEffectiveItemCostId 
			, inserted.intItemId 
			, inserted.intItemLocationId 
			, deleted.dblCost 
			, inserted.dblCost
			, deleted.dtmEffectiveCostDate
			, inserted.dtmEffectiveCostDate
	) AS [Changes] (
			strAction 
			, intEffectiveItemCostId 
			, intItemId 
			, intItemLocationId
			, dblOldCost
			, dblNewCost
			, dblOldEffectiveDate
			, dblNewEffectiveDate				
	);
END

-- Audit log for the Item Cost with Effective Date.
IF EXISTS (SELECT TOP 1 1 FROM #tmpEffectiveCostForCStore_AuditLog)
BEGIN 

	DECLARE loopAuditLog CURSOR LOCAL FAST_FORWARD
	FOR 	
	SELECT	intItemId
			,strOld = dblOldCost
			,strNew = dblNewCost
			,strAction 
			,strDescription = 
				dbo.fnFormatMessage(
					'C-Store %s an Item Cost with Effective Date on %d.' -- C-Store {creates|updates} an Item Cost with Effective Date on {Date}.
					,LOWER(REPLACE(strAction, 'INSERT', 'CREATE')) + 's'
					,ISNULL(dtmOldEffectiveDate, @dtmEffectiveDate) 
					,DEFAULT 
					,DEFAULT 
					,DEFAULT 
					,DEFAULT 
					,DEFAULT 
					,DEFAULT 
					,DEFAULT 
					,DEFAULT 				
				)
	FROM	#tmpEffectiveCostForCStore_AuditLog
	WHERE	ISNULL(dblOldCost, 0) <> ISNULL(dblNewCost, 0)

	OPEN loopAuditLog;

	FETCH NEXT FROM loopAuditLog INTO 
		@auditLogItem_id
		,@auditLogCost_Old
		,@auditLogCost_New
		,@auditLogAction
		,@auditLogDescription
	;
	WHILE @@FETCH_STATUS = 0
	BEGIN 
		--For Inventory -> Item audit log
		EXEC dbo.uspSMAuditLog 
			@keyValue = @auditLogItem_id
			,@screenName = 'Inventory.view.Item'
			,@entityId = @intEntityUserSecurityId
			,@actionType = 'Updated'
			,@changeDescription = @auditLogDescription
			,@fromValue = @auditLogCost_Old
			,@toValue = @auditLogCost_New

		--For Store -> Item Quick Entry audit log
		EXEC dbo.uspSMAuditLog 
			@keyValue = @auditLogItem_id
			,@screenName = 'Store.view.InventoryMassMaintenance'
			,@entityId = @intEntityUserSecurityId
			,@actionType = 'Updated'
			,@changeDescription = @auditLogDescription
			,@fromValue = @auditLogCost_Old
			,@toValue = @auditLogCost_New

		FETCH NEXT FROM loopAuditLog INTO 
			@auditLogItem_id
			,@auditLogCost_Old
			,@auditLogCost_New
			,@auditLogAction
			,@auditLogDescription
		;
	END 
	CLOSE loopAuditLog;
	DEALLOCATE loopAuditLog;
END

----------------------------------------------------------------------------
-- Update the Item Price with Effective Date
----------------------------------------------------------------------------
IF @dtmEffectiveDate IS NOT NULL AND @dblRetailPrice IS NOT NULL 
BEGIN 	
	INSERT INTO #tmpEffectivePriceForCStore_AuditLog (
		strAction 
		, intEffectiveItemPriceId 
		, intItemId 
		, intItemLocationId
		, dblOldPrice
		, dblNewPrice
		, dtmOldEffectiveDate
		, dtmNewEffectiveDate				
	)
	SELECT 
		strAction 
		, intEffectiveItemPriceId 
		, intItemId 
		, intItemLocationId
		, dblOldPrice
		, dblNewPrice
		, dblOldEffectiveDate
		, dblNewEffectiveDate		
	FROM (
		MERGE	
		INTO	dbo.tblICEffectiveItemPrice 
		WITH	(HOLDLOCK) 
		AS		e
		USING (
			SELECT	i.intItemId, il.intItemLocationId, @dtmEffectiveDate AS dtmEffectiveDate, @dblRetailPrice AS dblNewSalePrice
			FROM	tblICItemLocation il								
						INNER JOIN tblICItem i
							ON i.intItemId = il.intItemId 									
			WHERE	
					i.intItemId = ISNULL(@intItemId, i.intItemId)
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
						@intItemLocationId IS NULL 
						OR il.intItemLocationId = @intItemLocationId 
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
		) AS u
			ON e.intItemId = u.intItemId
			AND e.intItemLocationId = u.intItemLocationId
			AND CONVERT(DATE, e.dtmEffectiveRetailPriceDate) = CONVERT(DATE, u.dtmEffectiveDate)
			AND e.intEffectiveItemPriceId = ISNULL(@intEffectiveItemPriceId, e.intEffectiveItemPriceId)

		-- If matched, update the effective cost.
		WHEN MATCHED THEN 
			UPDATE 
			SET 
				e.dblRetailPrice = @dblRetailPrice
				,e.dtmDateModified = GETDATE()
				,e.intModifiedByUserId = @intEntityUserSecurityId
		
		-- If none found, insert a new Effective Item Cost
		WHEN NOT MATCHED THEN 
			INSERT (
				intItemId
				, intItemLocationId
				, dblRetailPrice
				, dtmDateCreated
				, dtmEffectiveRetailPriceDate
				, intCreatedByUserId
				, intConcurrencyId
			)
			VALUES (
				u.intItemId
				, u.intItemLocationId
				, u.dblNewSalePrice
				, GETUTCDATE()
				, @dtmEffectiveDate
				, @intEntityUserSecurityId
				, 1
			)

		OUTPUT 
			$action
			, inserted.intEffectiveItemPriceId 
			, inserted.intItemId 
			, inserted.intItemLocationId 
			, deleted.dblRetailPrice 
			, inserted.dblRetailPrice
			, deleted.dtmEffectiveRetailPriceDate
			, inserted.dtmEffectiveRetailPriceDate
	) AS [Changes] (
			strAction 
			, intEffectiveItemPriceId 
			, intItemId 
			, intItemLocationId
			, dblOldPrice
			, dblNewPrice 
			, dblOldEffectiveDate
			, dblNewEffectiveDate				
	);
END

-- Audit log for the Item Price with Effective Date.
IF EXISTS (SELECT TOP 1 1 FROM #tmpEffectivePriceForCStore_AuditLog)
BEGIN 
	DECLARE loopAuditLog CURSOR LOCAL FAST_FORWARD
	FOR 	
	SELECT	intItemId
			,strOld = dblOldPrice
			,strNew = dblNewPrice 
			,strAction 
			,strDescription = 
				dbo.fnFormatMessage(
					'C-Store %s an Item Price with Effective Date on %d.' -- C-Store {creates|updates} an Item Price with Effective Date on {Date}.
					,LOWER(REPLACE(strAction, 'INSERT', 'CREATE')) + 's'
					,ISNULL(dtmOldEffectiveDate, @dtmEffectiveDate) 
					,DEFAULT 
					,DEFAULT 
					,DEFAULT 
					,DEFAULT 
					,DEFAULT 
					,DEFAULT 
					,DEFAULT 
					,DEFAULT 				
				)
	FROM	#tmpEffectivePriceForCStore_AuditLog
	WHERE	ISNULL(dblOldPrice, 0) <> ISNULL(dblNewPrice, 0)

	OPEN loopAuditLog;

	FETCH NEXT FROM loopAuditLog INTO 
		@auditLogItem_id
		,@auditLogCost_Old
		,@auditLogCost_New
		,@auditLogAction
		,@auditLogDescription
	;
	WHILE @@FETCH_STATUS = 0
	BEGIN 
		--For Inventory -> Item audit log
		EXEC dbo.uspSMAuditLog 
			@keyValue = @auditLogItem_id
			,@screenName = 'Inventory.view.Item'
			,@entityId = @intEntityUserSecurityId
			,@actionType = 'Updated'
			,@changeDescription = @auditLogDescription
			,@fromValue = @auditLogCost_Old
			,@toValue = @auditLogCost_New
			
		--For Store -> Item Quick Entry audit log
		EXEC dbo.uspSMAuditLog 
			@keyValue = @auditLogItem_id
			,@screenName = 'Store.view.InventoryMassMaintenance'
			,@entityId = @intEntityUserSecurityId
			,@actionType = 'Updated'
			,@changeDescription = @auditLogDescription
			,@fromValue = @auditLogCost_Old
			,@toValue = @auditLogCost_New


		FETCH NEXT FROM loopAuditLog INTO 
			@auditLogItem_id
			,@auditLogCost_Old
			,@auditLogCost_New
			,@auditLogAction
			,@auditLogDescription
		;
	END 
	CLOSE loopAuditLog;
	DEALLOCATE loopAuditLog;
END


IF ISNULL(@strScreen, '') != 'UpdateItemPricing' AND ISNULL(@strScreen, '') != 'RetailPriceAdjustment'
BEGIN
	DROP TABLE #tmpEffectiveCostForCStore_AuditLog
	DROP TABLE #tmpEffectivePriceForCStore_AuditLog
END