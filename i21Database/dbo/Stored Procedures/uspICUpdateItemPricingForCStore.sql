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


-- Create the temp table for the Cost Effective Date audit log. 
IF OBJECT_ID('tempdb..#tmpUpdateItemCostForCStoreEffectiveDate_AuditLog') IS NULL  
	CREATE TABLE #tmpUpdateItemCostForCStoreEffectiveDate_AuditLog (
		intItemId INT
		,dblOldCost NUMERIC(38, 20) NULL
		,dblNewCost NUMERIC(38, 20) NULL
	);

	
------------------ COST ADJUSTMENT ------------------

DECLARE @intItemLocationId AS INT = NULL;
DECLARE @strOldPriceData AS FLOAT = 0.00;

IF @dtmEffectiveDate IS NOT NULL AND @dblStandardCost IS NOT NULL 
-- Update the Retail Price with Effective Date
BEGIN 


	SELECT @intItemLocationId = intItemLocationId
	FROM tblICItemPricing 
	WHERE intItemPricingId = @intItemPricingId


	--Feature on this IF statement is designed for Update Item Pricing and Revert Mass Pricebook Changes screens only
	IF @strScreen = 'UpdateItemPricing' 
		BEGIN

			-- Copy logs of modified fields on #tmpCostUpdateItemPricingForCStore_ItemPricingAuditLog 
			INSERT INTO #tmpCostUpdateItemPricingForCStore_ItemPricingAuditLog 
			SELECT * FROM #tmpUpdateItemPricingForCStore_ItemPricingAuditLog

			SELECT TOP 1 @strOldPriceData = dblCost 
			FROM tblICEffectiveItemCost 
			WHERE intItemId = (SELECT intItemId FROM #tmpCostUpdateItemPricingForCStore_ItemPricingAuditLog) 
					AND intItemLocationId IN (SELECT intItemLocationId FROM #tmpCostUpdateItemPricingForCStore_ItemPricingAuditLog) 
					AND dtmEffectiveCostDate = @dtmEffectiveDate 

			UPDATE tblICEffectiveItemCost
			SET dblCost = @dblStandardCost,
				dtmDateModified = GETDATE(),
				intModifiedByUserId = @intEntityUserSecurityId
			WHERE intItemId IN (SELECT intItemId FROM #tmpCostUpdateItemPricingForCStore_ItemPricingAuditLog) 
					AND intItemLocationId IN (SELECT intItemLocationId FROM #tmpCostUpdateItemPricingForCStore_ItemPricingAuditLog) 
					AND dtmEffectiveCostDate = @dtmEffectiveDate 
					
			DECLARE @intCostItemId_New				INT,
					@intCostItemLocationId_New		INT,
					@intCostItemPricingId_New		INT,
					@dblCost_New					NUMERIC(18, 6)

--			--INSERT IF NOT EXISTING
			WHILE EXISTS (SELECT TOP 1 1 FROM #tmpCostUpdateItemPricingForCStore_ItemPricingAuditLog
							WHERE intItemPricingId NOT IN (SELECT intItemPricingId FROM tblICItemPricing cp
																							INNER JOIN tblICEffectiveItemCost ec
																								ON cp.intItemLocationId = ec.intItemLocationId
																									AND cp.intItemId = ec.intItemId
																							WHERE ec.dtmEffectiveCostDate = @dtmEffectiveDate)

							)
							BEGIN 
							
								SET  @strOldPriceData = 0 

								SELECT @intCostItemId_New			= auditlog.intItemId
									  ,@intCostItemLocationId_New	= il.intItemLocationId
									  ,@intCostItemPricingId_New	= auditlog.intItemPricingId
									  ,@dblCost_New					= auditlog.dblNewStandardCost
								FROM #tmpCostUpdateItemPricingForCStore_ItemPricingAuditLog auditlog
									INNER JOIN tblICItemPricing cp
										ON auditlog.intItemPricingId = cp.intItemPricingId
									INNER JOIN tblICItemLocation il
										ON cp.intItemLocationId = il.intItemLocationId

								IF EXISTS (SELECT TOP 1 1 
											FROM #tmpCostUpdateItemPricingForCStore_ItemPricingAuditLog auditlog
												INNER JOIN tblICItemPricing cp
													ON auditlog.intItemPricingId = cp.intItemPricingId
												INNER JOIN tblICItemLocation il
													ON cp.intItemLocationId = il.intItemLocationId
												) AND NOT EXISTS (SELECT TOP 1 1 FROM tblICEffectiveItemCost WHERE intItemId = @intCostItemId_New AND intItemLocationId = @intCostItemLocationId_New AND dtmEffectiveCostDate = @dtmEffectiveDate)
									BEGIN
										INSERT INTO tblICEffectiveItemCost (intItemId, intItemLocationId, dblCost, dtmDateCreated, dtmEffectiveCostDate, intCreatedByUserId)
										VALUES (@intCostItemId_New, @intCostItemLocationId_New, @dblCost_New, GETUTCDATE(), @dtmEffectiveDate, @intEntityUserSecurityId)
									END
									
								INSERT INTO #tmpUpdateItemCostForCStoreEffectiveDate_AuditLog (intItemId, dblOldCost, dblNewCost) VALUES (@intCostItemId_New, @strOldPriceData, @dblCost_New)
									
								DELETE FROM #tmpCostUpdateItemPricingForCStore_ItemPricingAuditLog
								WHERE intItemId = @intCostItemId_New 
									AND intItemPricingId = @intCostItemPricingId_New
									AND dblNewStandardCost = @dblCost_New
							END
		END
	ELSE
		BEGIN
			IF EXISTS (SELECT TOP 1 1 FROM tblICEffectiveItemCost WHERE intItemId = @intItemId AND intItemLocationId = @intItemLocationId AND dtmEffectiveCostDate = @dtmEffectiveDate)
				BEGIN
					SELECT TOP 1 @strOldPriceData = dblCost 
					FROM tblICEffectiveItemCost 
					WHERE intItemId = @intItemId AND intItemLocationId = @intItemLocationId AND dtmEffectiveCostDate = @dtmEffectiveDate

					UPDATE tblICEffectiveItemCost
					SET dblCost = @dblStandardCost,
						dtmDateModified = GETDATE(),
						intModifiedByUserId = @intEntityUserSecurityId
					WHERE intItemId = @intItemId AND intItemLocationId = @intItemLocationId AND dtmEffectiveCostDate = @dtmEffectiveDate 
				END
			ELSE IF EXISTS (SELECT TOP 1 1 FROM tblICEffectiveItemCost WHERE intEffectiveItemCostId = @intEffectiveItemCostId)
				BEGIN
					SELECT TOP 1 @strOldPriceData = dblCost 
					FROM tblICEffectiveItemCost 
					WHERE intItemId = @intItemId AND intItemLocationId = @intItemLocationId AND dtmEffectiveCostDate = @dtmEffectiveDate

					UPDATE tblICEffectiveItemCost
					SET dblCost = @dblStandardCost,
						dtmDateModified = GETDATE(),
						dtmEffectiveCostDate = @dtmEffectiveDate,
						intModifiedByUserId = @intEntityUserSecurityId
					WHERE intEffectiveItemCostId = @intEffectiveItemCostId
				END
			ELSE
				BEGIN
					INSERT INTO tblICEffectiveItemCost (intItemId, intItemLocationId, dblCost, dtmDateCreated, dtmEffectiveCostDate, intCreatedByUserId)
					VALUES (@intItemId, @intItemLocationId, @dblStandardCost, GETUTCDATE(), @dtmEffectiveDate, @intEntityUserSecurityId)
				END
			INSERT INTO #tmpUpdateItemCostForCStoreEffectiveDate_AuditLog (intItemId, dblOldCost, dblNewCost) VALUES (@intItemId, @strOldPriceData, @dblStandardCost)
		END
   
END

-- Audit log for Effective Date Cost -- 
IF EXISTS (SELECT TOP 1 1 FROM #tmpUpdateItemCostForCStoreEffectiveDate_AuditLog)
BEGIN 
	
	DECLARE @auditLogCost_strDescription AS NVARCHAR(255) 
			,@auditLogCost_actionType AS NVARCHAR(50) = 'Updated'
			,@auditLogCost_id AS INT 
			,@auditLogCost_Old AS NVARCHAR(255)
			,@auditLogCost_New AS NVARCHAR(255)

	DECLARE loopAuditLog CURSOR LOCAL FAST_FORWARD
	FOR 	
	SELECT	intItemId
			,strDescription = 'C-Store updates the Standard Cost with Effective Date'
			,strOld = dblOldCost
			,strNew = dblNewCost
	FROM	#tmpUpdateItemCostForCStoreEffectiveDate_AuditLog
	WHERE	ISNULL(dblOldCost, 0) <> ISNULL(dblNewCost, 0)

	OPEN loopAuditLog;

	FETCH NEXT FROM loopAuditLog INTO 
		@auditLogCost_id
		,@auditLogCost_strDescription
		,@auditLogCost_Old
		,@auditLogCost_New
	;
	WHILE @@FETCH_STATUS = 0
	BEGIN 
		IF @auditLogCost_strDescription IS NOT NULL 
		BEGIN 
			EXEC dbo.uspSMAuditLog 
				@keyValue = @auditLogCost_id
				,@screenName = 'Inventory.view.Item'
				,@entityId = @intEntityUserSecurityId
				,@actionType = @auditLogCost_actionType
				,@changeDescription = @auditLogCost_strDescription
				,@fromValue = @auditLogCost_Old
				,@toValue = @auditLogCost_New
		END
		FETCH NEXT FROM loopAuditLog INTO 
			@auditLogCost_id
			,@auditLogCost_strDescription
			,@auditLogCost_Old
			,@auditLogCost_New
		;
	END 
	CLOSE loopAuditLog;
	DEALLOCATE loopAuditLog;
END



-- Create the temp table for the Cost Effective Date audit log. 
IF OBJECT_ID('tempdb..#tmpUpdateItemRetailForCStoreEffectiveDate_AuditLog') IS NULL  
	CREATE TABLE #tmpUpdateItemRetailForCStoreEffectiveDate_AuditLog (
		intItemId INT
		,dblOldRetailPrice NUMERIC(38, 20) NULL
		,dblNewRetailPrice NUMERIC(38, 20) NULL
	);
	
------------------ RETAIL PRICE ADJUSTMENT ------------------

DECLARE @intItemRetailLocationId AS INT = NULL;
DECLARE @strOldRetailPriceData AS FLOAT = 0.00;

IF @dtmEffectiveDate IS NOT NULL AND @dblRetailPrice IS NOT NULL 
-- Update the Retail Price with Effective Date
BEGIN 


	SELECT @intItemRetailLocationId = intItemLocationId
	FROM tblICItemPricing 
	WHERE intItemPricingId = @intItemPricingId


	IF @strScreen = 'UpdateItemPricing'
		BEGIN
		
			INSERT INTO #tmpRetailUpdateItemPricingForCStore_ItemPricingAuditLog 
			SELECT * FROM #tmpUpdateItemPricingForCStore_ItemPricingAuditLog
		
			SELECT TOP 1 @strOldRetailPriceData = dblRetailPrice 
			FROM tblICEffectiveItemPrice 
			WHERE intItemId = (SELECT intItemId FROM #tmpRetailUpdateItemPricingForCStore_ItemPricingAuditLog) 
					AND intItemLocationId IN (SELECT intItemLocationId FROM #tmpRetailUpdateItemPricingForCStore_ItemPricingAuditLog) 
					AND dtmEffectiveRetailPriceDate = @dtmEffectiveDate 

			UPDATE tblICEffectiveItemPrice
			SET dblRetailPrice = @dblRetailPrice,
				dtmDateModified = GETDATE(),
				intModifiedByUserId = @intEntityUserSecurityId
			WHERE intItemId = (SELECT intItemId FROM #tmpRetailUpdateItemPricingForCStore_ItemPricingAuditLog) 
					AND intItemLocationId IN (SELECT intItemLocationId FROM #tmpRetailUpdateItemPricingForCStore_ItemPricingAuditLog) 
					AND dtmEffectiveRetailPriceDate = @dtmEffectiveDate 
					
		DECLARE @intRetailItemId_New			INT,
				@intRetailItemLocationId_New	INT,
				@intRetailItemPricingId_New		INT,
				@dblRetail_New					NUMERIC(18, 6)

--			--INSERT IF NOT EXISTING
			WHILE EXISTS (SELECT TOP 1 1 FROM #tmpRetailUpdateItemPricingForCStore_ItemPricingAuditLog 
							WHERE intItemPricingId NOT IN (SELECT intItemPricingId FROM tblICItemPricing cp
																							INNER JOIN tblICEffectiveItemPrice ec
																								ON cp.intItemLocationId = ec.intItemLocationId
																									AND cp.intItemId = ec.intItemId
																							WHERE ec.dtmEffectiveRetailPriceDate = @dtmEffectiveDate)

							)
							BEGIN 
							
								SET  @strOldPriceData = 0 

								SELECT @intRetailItemId_New			= auditlog.intItemId
									  ,@intRetailItemLocationId_New	= il.intItemLocationId
									  ,@intRetailItemPricingId_New	= auditlog.intItemPricingId
									  ,@dblRetail_New				= auditlog.dblNewSalePrice
								FROM #tmpRetailUpdateItemPricingForCStore_ItemPricingAuditLog auditlog
									INNER JOIN tblICItemPricing cp
										ON auditlog.intItemPricingId = cp.intItemPricingId
									INNER JOIN tblICItemLocation il
										ON cp.intItemLocationId = il.intItemLocationId

								IF EXISTS (SELECT TOP 1 1 
											FROM #tmpRetailUpdateItemPricingForCStore_ItemPricingAuditLog auditlog
												INNER JOIN tblICItemPricing cp
													ON auditlog.intItemPricingId = cp.intItemPricingId
												INNER JOIN tblICItemLocation il
													ON cp.intItemLocationId = il.intItemLocationId
												) AND NOT EXISTS (SELECT TOP 1 1 FROM tblICEffectiveItemPrice WHERE intItemId = @intRetailItemId_New AND intItemLocationId = @intRetailItemLocationId_New AND dtmEffectiveRetailPriceDate = @dtmEffectiveDate)
									BEGIN
										INSERT INTO tblICEffectiveItemPrice (intItemId, intItemLocationId, dblRetailPrice, dtmDateCreated, dtmEffectiveRetailPriceDate, intCreatedByUserId)
										VALUES (@intRetailItemId_New, @intRetailItemLocationId_New, @dblRetail_New, GETUTCDATE(), @dtmEffectiveDate, @intEntityUserSecurityId)
									END
									
								INSERT INTO #tmpUpdateItemRetailForCStoreEffectiveDate_AuditLog (intItemId, dblOldRetailPrice, dblNewRetailPrice) VALUES (@intRetailItemId_New, @strOldRetailPriceData, @dblRetail_New)
									
								DELETE FROM #tmpRetailUpdateItemPricingForCStore_ItemPricingAuditLog
								WHERE intItemId = @intRetailItemId_New 
									AND intItemPricingId = @intRetailItemPricingId_New
									AND dblNewSalePrice = @dblRetail_New
							END
		END
	ELSE
		BEGIN
		IF EXISTS (SELECT TOP 1 1 FROM tblICEffectiveItemPrice WHERE intItemId = @intItemId AND intItemLocationId = @intItemRetailLocationId AND dtmEffectiveRetailPriceDate = @dtmEffectiveDate)
			BEGIN
				SELECT TOP 1 @strOldRetailPriceData = @dblRetailPrice 
				FROM tblICEffectiveItemPrice 
				WHERE intItemId = @intItemId AND intItemLocationId = @intItemRetailLocationId AND dtmEffectiveRetailPriceDate = @dtmEffectiveDate

				UPDATE tblICEffectiveItemPrice
				SET dblRetailPrice = @dblRetailPrice,
					dtmDateModified = GETDATE(),
					intModifiedByUserId = @intEntityUserSecurityId
				WHERE intItemId = @intItemId AND intItemLocationId = @intItemRetailLocationId AND dtmEffectiveRetailPriceDate = @dtmEffectiveDate 
			END
		ELSE IF EXISTS (SELECT TOP 1 1 FROM tblICEffectiveItemPrice WHERE intEffectiveItemPriceId = @intEffectiveItemPriceId)
			BEGIN
				SELECT TOP 1 @strOldRetailPriceData = @dblRetailPrice 
				FROM tblICEffectiveItemPrice 
				WHERE intItemId = @intItemId AND intItemLocationId = @intItemRetailLocationId AND dtmEffectiveRetailPriceDate = @dtmEffectiveDate
			
				UPDATE tblICEffectiveItemPrice
				SET dblRetailPrice = @dblRetailPrice,
					dtmEffectiveRetailPriceDate = @dtmEffectiveDate,
					dtmDateModified = GETDATE(),
					intModifiedByUserId = @intEntityUserSecurityId
				WHERE intEffectiveItemPriceId = @intEffectiveItemPriceId
			END
		ELSE
			BEGIN
				INSERT INTO tblICEffectiveItemPrice (intItemId, intItemLocationId, dblRetailPrice, dtmDateCreated, dtmEffectiveRetailPriceDate, intCreatedByUserId)
				VALUES (@intItemId, @intItemRetailLocationId, @dblRetailPrice, GETUTCDATE(), @dtmEffectiveDate, @intEntityUserSecurityId)
			END

		INSERT INTO #tmpUpdateItemRetailForCStoreEffectiveDate_AuditLog VALUES (@intItemId, @strOldRetailPriceData, @dblRetailPrice)
	END
END

-- Audit log for Effective Date Retail -- 
IF EXISTS (SELECT TOP 1 1 FROM #tmpUpdateItemRetailForCStoreEffectiveDate_AuditLog)
BEGIN 
	
	DECLARE @auditLogRetail_strDescription AS NVARCHAR(255) 
			,@auditLogRetail_actionType AS NVARCHAR(50) = 'Updated'
			,@auditLogRetail_id AS INT 
			,@auditLogRetail_Old AS NVARCHAR(255)
			,@auditLogRetail_New AS NVARCHAR(255)

	DECLARE loopAuditLog CURSOR LOCAL FAST_FORWARD
	FOR 	
	SELECT	intItemId
			,strDescription = 'C-Store updates the Retail Price with Effective Date'
			,strOld = dblOldRetailPrice
			,strNew = dblNewRetailPrice
	FROM	#tmpUpdateItemRetailForCStoreEffectiveDate_AuditLog
	WHERE	ISNULL(dblOldRetailPrice, 0) <> ISNULL(dblNewRetailPrice, 0)

	OPEN loopAuditLog;

	FETCH NEXT FROM loopAuditLog INTO 
		@auditLogRetail_id
		,@auditLogRetail_strDescription
		,@auditLogRetail_Old
		,@auditLogRetail_New
	;
	WHILE @@FETCH_STATUS = 0
	BEGIN 
		IF @auditLogRetail_strDescription IS NOT NULL 
		BEGIN 
			EXEC dbo.uspSMAuditLog 
				@keyValue = @auditLogRetail_id
				,@screenName = 'Inventory.view.Item'
				,@entityId = @intEntityUserSecurityId
				,@actionType = @auditLogRetail_actionType
				,@changeDescription = @auditLogRetail_strDescription
				,@fromValue = @auditLogRetail_Old
				,@toValue = @auditLogRetail_New
		END
		FETCH NEXT FROM loopAuditLog INTO 
			@auditLogRetail_id
			,@auditLogRetail_strDescription
			,@auditLogRetail_Old
			,@auditLogRetail_New
		;
	END 
	CLOSE loopAuditLog;
	DEALLOCATE loopAuditLog;
END