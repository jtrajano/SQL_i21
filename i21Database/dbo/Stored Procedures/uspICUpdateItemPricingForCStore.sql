/*
	This stored procedure will update the Sales Price in the Item Pricing and Item Pricing Level. 
*/
CREATE PROCEDURE [dbo].[uspICUpdateItemPricingForCStore]
	-- filter params
	@strUpcCode AS NVARCHAR(50) = NULL 
	,@strDescription AS NVARCHAR(250) = NULL 
	,@strScreen AS NVARCHAR(50) = NULL 
	,@intItemId AS INT = NULL 
	,@intItemPricingId AS INT = NULL 
	,@intEffectiveItemCostId AS INT = NULL 
	,@intEffectiveItemPriceId AS INT = NULL 
	-- update params
	,@dblStandardCost AS NUMERIC(38, 20) = NULL 
	,@dblRetailPrice AS NUMERIC(38, 20) = NULL 
	,@dblLastCost AS NUMERIC(38, 20) = NULL
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

-- Create the temp table for Cost for the audit log. 
IF OBJECT_ID('tempdb..#tmpCostUpdateItemPricingForCStore_ItemPricingAuditLog') IS NULL  
	CREATE TABLE #tmpCostUpdateItemPricingForCStore_ItemPricingAuditLog (
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


-- Create the temp table for Retail for the audit log. 
IF OBJECT_ID('tempdb..#tmpRetailUpdateItemPricingForCStore_ItemPricingAuditLog') IS NULL  
	CREATE TABLE #tmpRetailUpdateItemPricingForCStore_ItemPricingAuditLog (
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

-- Create the temp table for the audit log. 
IF OBJECT_ID('tempdb..#tmpPricingLevelForCStore_AuditLog') IS NULL  
	CREATE TABLE #tmpPricingLevelForCStore_AuditLog (
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

-- Insert the Audit Log for the Item Pricing. 
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
				u.*
				,p.intItemLocationId
			FROM 
				#tmpUpdateItemPricingForCStore_ItemPricingAuditLog u 
				INNER JOIN tblICItemPricing p
					ON u.intItemPricingId = p.intItemPricingId 
				INNER JOIN tblICItem i	
					ON i.intItemId = u.intItemId 
				INNER JOIN tblICItemLocation il
					ON il.intItemId = p.intItemId
					AND il.intItemLocationId = p.intItemLocationId 
		) AS u
			ON e.intItemId = u.intItemId
			AND e.intItemLocationId = u.intItemLocationId
			AND e.dtmEffectiveCostDate = @dtmEffectiveDate

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
				u.intItemId
				, u.intItemLocationId
				, u.dblNewStandardCost
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
			SELECT DISTINCT
				u.*,
				p.intItemLocationId
			FROM 
				#tmpUpdateItemPricingForCStore_ItemPricingAuditLog u 
				INNER JOIN tblICItemPricing p
					ON u.intItemPricingId = p.intItemPricingId
				INNER JOIN tblICItem i	
					ON i.intItemId = u.intItemId 
				INNER JOIN tblICItemLocation il
					ON il.intItemId = i.intItemId
					AND il.intItemLocationId = p.intItemLocationId 
		) AS u
			ON e.intItemId = u.intItemId
			AND e.intItemLocationId = u.intItemLocationId
			AND e.dtmEffectiveRetailPriceDate = @dtmEffectiveDate

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
				u.intItemId
				, u.intItemLocationId
				, u.dblNewSalePrice
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

	DROP TABLE #tmpEffectivePriceForCStore_AuditLog
END

----------------------------------------------------------------------------
-- Update the Pricing Level from item pricing
----------------------------------------------------------------------------
IF EXISTS (SELECT TOP 1 1 FROM #tmpUpdateItemPricingForCStore_ItemPricingAuditLog)
BEGIN 
	UPDATE	pl
	SET		pl.dblUnitPrice = ROUND((p.dblSalePrice - (p.dblSalePrice * (pl.dblAmountRate/100))) * pl.dblUnit, 6) 
	FROM	tblICItemPricingLevel pl INNER JOIN tblICItemPricing p
				ON pl.intItemId = p.intItemId
				AND pl.intItemLocationId = p.intItemLocationId
			INNER JOIN #tmpUpdateItemPricingForCStore_ItemPricingAuditLog l
				ON l.intItemPricingId = p.intItemPricingId
	WHERE	pl.strPricingMethod = 'Discount Retail Price' 
			
	UPDATE	pl
	SET		pl.dblUnitPrice = ROUND((p.dblMSRPPrice - (p.dblMSRPPrice * (pl.dblAmountRate/100))) * pl.dblUnit, 6) 
	FROM	tblICItemPricingLevel pl INNER JOIN tblICItemPricing p
				ON pl.intItemId = p.intItemId
				AND pl.intItemLocationId = p.intItemLocationId
			INNER JOIN #tmpUpdateItemPricingForCStore_ItemPricingAuditLog l
				ON l.intItemPricingId = p.intItemPricingId
	WHERE	pl.strPricingMethod = 'MSRP Discount' 

	UPDATE	pl
	SET		pl.dblUnitPrice = ROUND(
				((p.dblMSRPPrice - p.dblStandardCost) * (pl.dblAmountRate / 100) + p.dblStandardCost) * pl.dblUnit
				, 6) 
	FROM	tblICItemPricingLevel pl INNER JOIN tblICItemPricing p
				ON pl.intItemId = p.intItemId
				AND pl.intItemLocationId = p.intItemLocationId
			INNER JOIN #tmpUpdateItemPricingForCStore_ItemPricingAuditLog l
				ON l.intItemPricingId = p.intItemPricingId
	WHERE	pl.strPricingMethod = 'Percent of Margin (MSRP)' 

	UPDATE	pl
	SET		pl.dblUnitPrice = ROUND((p.dblStandardCost + pl.dblAmountRate) * pl.dblUnit , 6) 
	FROM	tblICItemPricingLevel pl INNER JOIN tblICItemPricing p
				ON pl.intItemId = p.intItemId
				AND pl.intItemLocationId = p.intItemLocationId
			INNER JOIN #tmpUpdateItemPricingForCStore_ItemPricingAuditLog l
				ON l.intItemPricingId = p.intItemPricingId
	WHERE	pl.strPricingMethod = 'Fixed Dollar Amount' 

	UPDATE	pl
	SET		pl.dblUnitPrice = ROUND(
				((p.dblStandardCost * (pl.dblAmountRate/100)) + p.dblStandardCost) * pl.dblUnit
				, 6) 
	FROM	tblICItemPricingLevel pl INNER JOIN tblICItemPricing p
				ON pl.intItemId = p.intItemId
				AND pl.intItemLocationId = p.intItemLocationId
			INNER JOIN #tmpUpdateItemPricingForCStore_ItemPricingAuditLog l
				ON l.intItemPricingId = p.intItemPricingId
	WHERE	pl.strPricingMethod = 'Markup Standard Cost'

	UPDATE	pl
	SET		pl.dblUnitPrice = ROUND(
				(p.dblStandardCost / (1 - pl.dblAmountRate/100)) * pl.dblUnit 
				, 6) 
	FROM	tblICItemPricingLevel pl INNER JOIN tblICItemPricing p
				ON pl.intItemId = p.intItemId
				AND pl.intItemLocationId = p.intItemLocationId
			INNER JOIN #tmpUpdateItemPricingForCStore_ItemPricingAuditLog l
				ON l.intItemPricingId = p.intItemPricingId
	WHERE	pl.strPricingMethod = 'Percent of Margin'

	UPDATE	pl
	SET		pl.dblUnitPrice = ROUND(
				((p.dblLastCost * (pl.dblAmountRate/100)) + p.dblLastCost) * pl.dblUnit
				, 6) 
	FROM	tblICItemPricingLevel pl INNER JOIN tblICItemPricing p
				ON pl.intItemId = p.intItemId
				AND pl.intItemLocationId = p.intItemLocationId
			INNER JOIN #tmpUpdateItemPricingForCStore_ItemPricingAuditLog l
				ON l.intItemPricingId = p.intItemPricingId
	WHERE	pl.strPricingMethod = 'Markup Last Cost'

	UPDATE	pl
	SET		pl.dblUnitPrice = ROUND(
				((p.dblAverageCost * (pl.dblAmountRate/100)) + p.dblAverageCost) * pl.dblUnit
				, 6) 
	FROM	tblICItemPricingLevel pl INNER JOIN tblICItemPricing p
				ON pl.intItemId = p.intItemId
				AND pl.intItemLocationId = p.intItemLocationId
			INNER JOIN #tmpUpdateItemPricingForCStore_ItemPricingAuditLog l
				ON l.intItemPricingId = p.intItemPricingId
	WHERE	pl.strPricingMethod = 'Markup Avg Cost'
END 

----------------------------------------------------------------------------
-- Update the Pricing Level from Cost With Effective Date
----------------------------------------------------------------------------
IF EXISTS (SELECT TOP 1 1 FROM #tmpUpdateItemPricingForCStore_ItemPricingAuditLog)
BEGIN 
	UPDATE	pl
	SET		pl.dblUnitPrice = ROUND(
				((ep.dblCost * (pl.dblAmountRate/100)) + ep.dblCost) * pl.dblUnit
				, 6) 
	FROM	tblICItemPricingLevel pl INNER JOIN tblICItemPricing p 
				ON pl.intItemId = p.intItemId
				AND pl.intItemLocationId = p.intItemLocationId
			INNER JOIN tblICEffectiveItemCost ep
				ON ep.intItemId = p.intItemId
				AND ep.intItemLocationId = p.intItemLocationId
			INNER JOIN #tmpUpdateItemPricingForCStore_ItemPricingAuditLog l
				ON l.intItemPricingId = p.intItemPricingId	
	WHERE	pl.strPricingMethod IN ('Markup Standard Cost', 'Markup Last Cost', 'Markup Avg Cost')
			AND pl.dtmEffectiveDate >= ep.dtmEffectiveCostDate
			AND pl.dtmEffectiveDate IS NOT NULL

	UPDATE	pl
	SET		pl.dblUnitPrice = ROUND((ep.dblCost + pl.dblAmountRate) * pl.dblUnit , 6) 
	FROM	tblICItemPricingLevel pl INNER JOIN tblICItemPricing p 
				ON pl.intItemId = p.intItemId
				AND pl.intItemLocationId = p.intItemLocationId
			INNER JOIN tblICEffectiveItemCost ep
				ON ep.intItemId = p.intItemId
				AND ep.intItemLocationId = p.intItemLocationId
			INNER JOIN #tmpUpdateItemPricingForCStore_ItemPricingAuditLog l
				ON l.intItemPricingId = p.intItemPricingId		
	WHERE	pl.strPricingMethod = 'Fixed Dollar Amount' 
			AND pl.dtmEffectiveDate >= ep.dtmEffectiveCostDate
			AND pl.dtmEffectiveDate IS NOT NULL

	UPDATE	pl
	SET		pl.dblUnitPrice = ROUND(
				(ep.dblCost / (1 - pl.dblAmountRate/100)) * pl.dblUnit 
				, 6) 
	FROM	tblICItemPricingLevel pl INNER JOIN tblICItemPricing p 
				ON pl.intItemId = p.intItemId
				AND pl.intItemLocationId = p.intItemLocationId
			INNER JOIN tblICEffectiveItemCost ep
				ON ep.intItemId = p.intItemId
				AND ep.intItemLocationId = p.intItemLocationId
			INNER JOIN #tmpUpdateItemPricingForCStore_ItemPricingAuditLog l
				ON l.intItemPricingId = p.intItemPricingId	
	WHERE	pl.strPricingMethod = 'Percent of Margin'
			AND pl.dtmEffectiveDate >= ep.dtmEffectiveCostDate
			AND pl.dtmEffectiveDate IS NOT NULL
END 

----------------------------------------------------------------------------
-- Update the Pricing Level from Price With Effective Date
----------------------------------------------------------------------------
IF EXISTS (SELECT TOP 1 1 FROM #tmpUpdateItemPricingForCStore_ItemPricingAuditLog)
BEGIN 
	UPDATE	pl
	SET		pl.dblUnitPrice = ROUND(
				(ep.dblRetailPrice - (ep.dblRetailPrice * (pl.dblAmountRate/100))) * pl.dblUnit
				, 6) 
	FROM	tblICItemPricingLevel pl INNER JOIN tblICItemPricing p 
				ON pl.intItemId = p.intItemId
				AND pl.intItemLocationId = p.intItemLocationId
			INNER JOIN tblICEffectiveItemPrice ep
				ON ep.intItemId = p.intItemId
				AND ep.intItemLocationId = p.intItemLocationId
			INNER JOIN #tmpUpdateItemPricingForCStore_ItemPricingAuditLog l
				ON l.intItemPricingId = p.intItemPricingId	
	WHERE	pl.strPricingMethod = 'Discount Retail Price'
			AND pl.dtmEffectiveDate >= ep.dtmEffectiveRetailPriceDate
			AND pl.dtmEffectiveDate IS NOT NULL
	IF ISNULL(@strScreen, '') != 'UpdateItemPricing' AND ISNULL(@strScreen, '') != 'RetailPriceAdjustment'
	BEGIN
		DROP TABLE #tmpUpdateItemPricingForCStore_ItemPricingAuditLog
	END
END 