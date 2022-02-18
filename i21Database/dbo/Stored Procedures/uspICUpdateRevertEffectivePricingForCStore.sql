/*
	This stored procedure will update the With REVERT Effective Date in the Item Pricing 
*/
CREATE PROCEDURE [dbo].[uspICUpdateRevertEffectivePricingForCStore]
	-- filter params
	@intItemId					AS INT = NULL 
	,@intEffectiveItemCostId	AS INT = NULL 
	,@intEffectiveItemPriceId	AS INT = NULL 
	,@strAction					AS NVARCHAR(50) = NULL 
	,@dtmEffectiveDate			AS DATETIME = NULL 
	,@strScreen					AS NVARCHAR(50) = NULL 
	-- update params
	,@dblCost					AS NUMERIC(38, 20) = NULL 
	,@dblRetailPrice			AS NUMERIC(38, 20) = NULL 
	,@intEntityUserSecurityId	AS INT 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF
	   
-- Create the temp table for the audit log. 
IF OBJECT_ID('tempdb..#tmpEffectiveCostForCStore_AuditLog') IS NULL  
	CREATE TABLE #tmpEffectiveCostForCStore_AuditLog (
		intEffectiveItemCostId INT
		,intNewItemId INT
		,intOldItemId INT
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
		,intNewItemId INT
		,intOldItemId INT
		,intItemLocationId INT 
		,dblOldPrice NUMERIC(38, 20) NULL
		,dblNewPrice NUMERIC(38, 20) NULL
		,dtmOldEffectiveDate DATETIME NULL
		,dtmNewEffectiveDate DATETIME NULL
		,strAction NVARCHAR(50) NULL
	)
;

DECLARE @auditLogCost_id AS INT 
		,@auditLogCost_Old AS NVARCHAR(255)
		,@auditLogCost_New AS NVARCHAR(255)
		,@auditLogAction AS NVARCHAR(50)
		,@auditLogDescription AS NVARCHAR(255)

----------------------------------------------------------------------------
-- Update the Item Cost with Effective Date
----------------------------------------------------------------------------
IF @intEffectiveItemCostId IS NOT NULL
BEGIN 	
	INSERT INTO #tmpEffectiveCostForCStore_AuditLog (
		strAction 
		, intEffectiveItemCostId 
		, intNewItemId 
		, intOldItemId 
		, intItemLocationId
		, dblOldCost
		, dblNewCost
		, dtmOldEffectiveDate
		, dtmNewEffectiveDate				
	)
	SELECT 
		strAction 
		, intEffectiveItemCostId 
		, intNewItemId 
		, intOldItemId 
		, intItemLocationId
		, dblOldCost
		, dblNewCost
		, dtmOldEffectiveDate
		, dtmNewEffectiveDate		
	FROM (
		MERGE	
		INTO	dbo.tblICEffectiveItemCost 
		WITH	(HOLDLOCK) 
		AS		e
		USING (
			SELECT	*
			FROM	tblICEffectiveItemCost 								
			WHERE	intEffectiveItemCostId = @intEffectiveItemCostId
		) AS u
			ON e.intItemId = u.intItemId
			AND e.intItemLocationId = u.intItemLocationId
			AND e.dtmEffectiveCostDate = @dtmEffectiveDate

		-- If matched, update the effective cost.
		WHEN MATCHED 
			AND @strAction IN ('UPDATE', 'INSERT')
			AND u.dtmEffectiveCostDate = @dtmEffectiveDate 
			AND @dblCost IS NOT NULL
			THEN 
			UPDATE 
			SET 
				e.dblCost = @dblCost
				,e.dtmDateModified = GETDATE()
				,e.intModifiedByUserId = @intEntityUserSecurityId
		
		-- If matched with the same effective date on Revert Mass Pricebook Change
		-- AND if Cost from Revert Mass Pricebook change is NULL
		-- Delete Effective Item Cost
		WHEN MATCHED 
			AND @strAction = 'INSERT'
			AND u.dtmEffectiveCostDate = @dtmEffectiveDate 
			AND @dblCost IS NULL
			THEN DELETE 
			
		-- If not matched on or mismatch specifically on effective date pricing vs effective date on Revert Mass Pricebook 
		-- Create a new effective date
		WHEN NOT MATCHED 
			AND @strAction IN ('INSERT', 'UPDATE')
			THEN 
			INSERT (intItemId, intItemLocationId, dblCost, dtmEffectiveCostDate, intConcurrencyId, dtmDateCreated, intCreatedByUserId)
			VALUES (u.intItemId, u.intItemLocationId, @dblCost, @dtmEffectiveDate, 1, GETDATE(), @intEntityUserSecurityId)

		OUTPUT 
			$action
			, inserted.intEffectiveItemCostId 
			, inserted.intItemId 
			, deleted.intItemId 
			, inserted.intItemLocationId 
			, deleted.dblCost 
			, inserted.dblCost
			, deleted.dtmEffectiveCostDate
			, inserted.dtmEffectiveCostDate
	) AS [Changes] (
			strAction 
			, intEffectiveItemCostId 
			, intNewItemId 
			, intOldItemId 
			, intItemLocationId
			, dblOldCost
			, dblNewCost
			, dtmOldEffectiveDate
			, dtmNewEffectiveDate				
	);
END

-- Audit log for the Item Cost with Effective Date.
IF EXISTS (SELECT TOP 1 1 FROM #tmpEffectiveCostForCStore_AuditLog)
BEGIN 

	DECLARE loopAuditLog CURSOR LOCAL FAST_FORWARD
	FOR 	
	SELECT	intOldItemId
			,strOld = dblOldCost
			,strNew = dblNewCost
			,strAction 
			,strDescription = 
				dbo.fnFormatMessage(
					'C-Store %s an Item Cost with Effective Date on %d.' -- C-Store {creates|updates} an Item Cost with Effective Date on {Date}.
					,LOWER(REPLACE(strAction, 'UPDATE', 'DELETE')) + 's'
					,ISNULL(dtmOldEffectiveDate, dtmNewEffectiveDate) 
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
		@auditLogCost_id
		,@auditLogCost_Old
		,@auditLogCost_New
		,@auditLogAction
		,@auditLogDescription
	;
	WHILE @@FETCH_STATUS = 0
	BEGIN 
		IF @auditLogAction = 'UPDATE'
		BEGIN 
			EXEC dbo.uspSMAuditLog 
				@keyValue = @auditLogCost_id
				,@screenName = 'Inventory.view.Item'
				,@entityId = @intEntityUserSecurityId
				,@actionType = 'Updated'
				,@changeDescription = @auditLogDescription
				,@fromValue = @auditLogCost_Old
				,@toValue = @auditLogCost_New
		END

		ELSE IF @auditLogAction = 'DELETE'
		BEGIN 
			EXEC dbo.uspSMAuditLog 
				@keyValue = @auditLogCost_id
				,@screenName = 'Inventory.view.Item'
				,@entityId = @intEntityUserSecurityId
				,@actionType = 'Updated'
				,@changeDescription = @auditLogDescription
				,@fromValue = ''
				,@toValue = @auditLogCost_New
		END

		FETCH NEXT FROM loopAuditLog INTO 
			@auditLogCost_id
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
IF @intEffectiveItemPriceId IS NOT NULL
BEGIN 	
	INSERT INTO #tmpEffectivePriceForCStore_AuditLog (
		strAction 
		, intEffectiveItemPriceId 
		, intNewItemId 
		, intOldItemId 
		, intItemLocationId
		, dblOldPrice
		, dblNewPrice
		, dtmOldEffectiveDate
		, dtmNewEffectiveDate				
	)
	SELECT 
		strAction 
		, intEffectiveItemPriceId 
		, intNewItemId 
		, intOldItemId 
		, intItemLocationId
		, dblOldPrice
		, dblNewPrice
		, dtmOldEffectiveDate
		, dtmNewEffectiveDate		
	FROM (
		MERGE	
		INTO	dbo.tblICEffectiveItemPrice 
		WITH	(HOLDLOCK) 
		AS		e
		USING (
			SELECT	*
			FROM	tblICEffectiveItemPrice 								
			WHERE	intEffectiveItemPriceId = @intEffectiveItemPriceId
		) AS u
			ON e.intItemId = u.intItemId
			AND e.intItemLocationId = u.intItemLocationId
			AND e.intItemUOMId = u.intItemUOMId
			AND e.dtmEffectiveRetailPriceDate = @dtmEffectiveDate

		-- If matched, update the effective price.
		WHEN MATCHED 
			AND @strAction IN ('UPDATE', 'INSERT')
			AND u.dtmEffectiveRetailPriceDate = @dtmEffectiveDate
			AND @dblRetailPrice IS NOT NULL
			THEN 
			UPDATE 
			SET 
				e.dblRetailPrice = @dblRetailPrice
				,e.dtmDateModified = GETDATE()
				,e.intModifiedByUserId = @intEntityUserSecurityId
		
		-- If matched with the same effective date on Revert Mass Pricebook Change
		-- AND if Retail Price from Revert Mass Pricebook change is NULL
		-- Delete Effective Item price
		WHEN MATCHED 
			AND @strAction = 'INSERT'
			AND u.dtmEffectiveRetailPriceDate = @dtmEffectiveDate
			AND @dblRetailPrice IS NULL
			THEN DELETE
			
		-- If not matched on or mismatch specifically on effective date pricing vs effective date on Revert Mass Pricebook 
		-- Create a new effective date
		WHEN NOT MATCHED 
			AND @strAction IN ('INSERT', 'UPDATE')
			THEN 
			INSERT (intItemId, intItemLocationId, dblRetailPrice, dtmEffectiveRetailPriceDate, intConcurrencyId, dtmDateCreated, intCreatedByUserId)
			VALUES (u.intItemId, u.intItemLocationId, @dblRetailPrice, @dtmEffectiveDate, 1, GETDATE(), @intEntityUserSecurityId)

		OUTPUT 
			$action
			, inserted.intEffectiveItemPriceId 
			, inserted.intItemId 
			, deleted.intItemId 
			, inserted.intItemLocationId 
			, deleted.dblRetailPrice 
			, inserted.dblRetailPrice
			, deleted.dtmEffectiveRetailPriceDate
			, inserted.dtmEffectiveRetailPriceDate
	) AS [Changes] (
			strAction 
			, intEffectiveItemPriceId 
			, intNewItemId 
			, intOldItemId 
			, intItemLocationId
			, dblOldPrice
			, dblNewPrice 
			, dtmOldEffectiveDate
			, dtmNewEffectiveDate				
	);
END

-- Audit log for the Item Price with Effective Date.
IF EXISTS (SELECT TOP 1 1 FROM #tmpEffectivePriceForCStore_AuditLog)
BEGIN 
	DECLARE loopAuditLog CURSOR LOCAL FAST_FORWARD
	FOR 	
	SELECT	intOldItemId
			,strOld = dblOldPrice
			,strNew = dblNewPrice 
			,strAction 
			,strDescription = 
				dbo.fnFormatMessage(
					'C-Store %s an Item Price with Effective Date on %d.' -- C-Store {creates|updates} an Item Price with Effective Date on {Date}.
					,LOWER(REPLACE(strAction, 'INSERT', 'CREATE')) + 's'
					,ISNULL(dtmOldEffectiveDate, dtmNewEffectiveDate) 
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
		@auditLogCost_id
		,@auditLogCost_Old
		,@auditLogCost_New
		,@auditLogAction
		,@auditLogDescription
	;
	WHILE @@FETCH_STATUS = 0
	BEGIN 
		IF @auditLogAction = 'UPDATE'
		BEGIN 
			EXEC dbo.uspSMAuditLog 
				@keyValue = @auditLogCost_id
				,@screenName = 'Inventory.view.Item'
				,@entityId = @intEntityUserSecurityId
				,@actionType = 'Updated'
				,@changeDescription = @auditLogDescription
				,@fromValue = @auditLogCost_Old
				,@toValue = @auditLogCost_New
		END

		ELSE IF @auditLogAction = 'DELETE'
		BEGIN 
			EXEC dbo.uspSMAuditLog 
				@keyValue = @auditLogCost_id
				,@screenName = 'Inventory.view.Item'
				,@entityId = @intEntityUserSecurityId
				,@actionType = 'Updated'
				,@changeDescription = @auditLogDescription
				,@fromValue = ''
				,@toValue = @auditLogCost_New
		END

		FETCH NEXT FROM loopAuditLog INTO 
			@auditLogCost_id
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