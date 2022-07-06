/*
	This stored procedure will update the Sales Price and Cost ONLY in with effective date and pricing level.
*/
CREATE PROCEDURE [dbo].[uspICUpdateItemWithEffectiveDatePricingForCStore]
	-- filter params
	@intItemId AS INT = NULL 
	,@intItemLocationId AS INT = NULL -- tblICItemLocation
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
SET ANSI_WARNINGS OFF

BEGIN TRY
-- Create the temp table for the audit log. 
IF OBJECT_ID('tempdb..#tmpEffectiveCostForCStore_AuditLog') IS NULL  
	CREATE TABLE #tmpEffectiveCostForCStore_AuditLog (
		intItemId INT
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
		intItemId INT
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
IF @dtmEffectiveDate IS NOT NULL AND @dblStandardCost IS NOT NULL 
BEGIN 	
	INSERT INTO #tmpEffectiveCostForCStore_AuditLog (
		strAction 
		, intItemId 
		, intItemLocationId
		, dblOldCost
		, dblNewCost
		, dtmOldEffectiveDate
		, dtmNewEffectiveDate				
	)
	SELECT 
		strAction 
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
			SELECT 
				@intItemId AS intItemId
				,@intItemLocationId AS intItemLocationId
				,@dtmEffectiveDate AS dtmEffectiveCostDate
		) AS u
			ON e.intItemId = u.intItemId
			AND  e.intItemLocationId = u.intItemLocationId
			AND  e.dtmEffectiveCostDate = u.dtmEffectiveCostDate

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
			)
			VALUES (
				@intItemId
				, @intItemLocationId
				, @dblStandardCost
				, GETUTCDATE()
				, @dtmEffectiveDate
				, @intEntityUserSecurityId
			)

		OUTPUT 
			$action
			, inserted.intItemId 
			, inserted.intItemLocationId 
			, deleted.dblCost 
			, inserted.dblCost
			, deleted.dtmEffectiveCostDate
			, inserted.dtmEffectiveCostDate
	) AS [Changes] (
			strAction 
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

		ELSE IF @auditLogAction = 'INSERT'
		BEGIN 
			EXEC dbo.uspSMAuditLog 
				@keyValue = @auditLogCost_id
				,@screenName = 'Inventory.view.Item'
				,@entityId = @intEntityUserSecurityId
				,@actionType = 'Created'
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

	DROP TABLE #tmpEffectiveCostForCStore_AuditLog
END

----------------------------------------------------------------------------
-- Update the Item Price with Effective Date
----------------------------------------------------------------------------
IF @dtmEffectiveDate IS NOT NULL AND @dblRetailPrice IS NOT NULL 
BEGIN 	
	INSERT INTO #tmpEffectivePriceForCStore_AuditLog (
		strAction 
		, intItemId 
		, intItemLocationId
		, dblOldPrice
		, dblNewPrice
		, dtmOldEffectiveDate
		, dtmNewEffectiveDate				
	)
	SELECT 
		strAction 
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
			SELECT 
				@intItemId AS intItemId
				,@intItemLocationId AS intItemLocationId
				,@dtmEffectiveDate AS dtmEffectiveRetailPriceDate
		) AS u
			ON e.intItemId = u.intItemId
			AND  e.intItemLocationId = u.intItemLocationId
			AND  e.dtmEffectiveRetailPriceDate = u.dtmEffectiveRetailPriceDate

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
			)
			VALUES (
				@intItemId
				, @intItemLocationId
				, @dblRetailPrice
				, GETUTCDATE()
				, @dtmEffectiveDate
				, @intEntityUserSecurityId
			)

		OUTPUT 
			$action
			, inserted.intItemId 
			, inserted.intItemLocationId 
			, deleted.dblRetailPrice 
			, inserted.dblRetailPrice
			, deleted.dtmEffectiveRetailPriceDate
			, inserted.dtmEffectiveRetailPriceDate
	) AS [Changes] (
			strAction 
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

		ELSE IF @auditLogAction = 'INSERT'
		BEGIN 
			EXEC dbo.uspSMAuditLog 
				@keyValue = @auditLogCost_id
				,@screenName = 'Inventory.view.Item'
				,@entityId = @intEntityUserSecurityId
				,@actionType = 'Created'
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
END TRY
BEGIN CATCH

	SELECT @@ERROR
END CATCH

----------------------------------------------------------------------------
-- Update the Pricing Level from Price With Effective Date
----------------------------------------------------------------------------
IF EXISTS (SELECT TOP 1 1 FROM #tmpEffectivePriceForCStore_AuditLog)
BEGIN 
	UPDATE	pl
	SET		pl.dblUnitPrice = ROUND(
				(ep.dblRetailPrice - (ep.dblRetailPrice * (pl.dblAmountRate/100))) * pl.dblUnit
				, 6) 
	FROM	tblICItemPricingLevel pl 
			INNER JOIN tblICItemPricing p 
				ON pl.intItemId = p.intItemId
				AND pl.intItemLocationId = p.intItemLocationId
			INNER JOIN tblICEffectiveItemPrice ep
				ON ep.intItemId = p.intItemId
				AND ep.intItemLocationId = p.intItemLocationId
			INNER JOIN #tmpEffectivePriceForCStore_AuditLog l
				ON l.intItemId = pl.intItemId
				AND l.intItemLocationId = pl.intItemLocationId
	WHERE	pl.strPricingMethod = 'Discount Retail Price'
			AND pl.dtmEffectiveDate >= ep.dtmEffectiveRetailPriceDate
			AND pl.dtmEffectiveDate IS NOT NULL
			
	DROP TABLE #tmpEffectivePriceForCStore_AuditLog
END 