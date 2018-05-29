/*
	This stored procedure will update the Item Special Pricing table (Promotional Pricing & Exemptions) 
*/
CREATE PROCEDURE [dbo].[uspICUpdateItemSpecialPricingForCStore]
	-- filter params
	@strUpcCode AS NVARCHAR(50) = NULL 
	,@strDescription AS NVARCHAR(250) = NULL 
	,@intItemId AS INT = NULL 
	-- update params
	,@dtmBeginDate AS DATETIME = NULL
	,@dtmEndDate AS DATETIME = NULL
	,@dblDiscount AS NUMERIC(18, 6) = NULL
	,@dblAccumulatedAmount AS NUMERIC(18, 6) = NULL
	,@dblAccumulatedQty AS NUMERIC(18, 6) = NULL
	,@dblDiscountThruAmount AS NUMERIC(18, 6) = NULL
	,@dblDiscountThruQty AS NUMERIC(18, 6) = NULL

	,@intEntityUserSecurityId AS INT 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

-- Create the temp table 
IF OBJECT_ID('tempdb..#tmpUpdateItemSpecialPricingForCStore_Location') IS NULL  
	CREATE TABLE #tmpUpdateItemSpecialPricingForCStore_Location (
		intLocationId INT 
	)

IF OBJECT_ID('tempdb..#tmpUpdateItemSpecialPricingForCStore_Vendor') IS NULL  
	CREATE TABLE #tmpUpdateItemSpecialPricingForCStore_Vendor (
		intVendorId INT 
	)

IF OBJECT_ID('tempdb..#tmpUpdateItemSpecialPricingForCStore_Category') IS NULL  
	CREATE TABLE #tmpUpdateItemSpecialPricingForCStore_Category (
		intCategoryId INT 
	)

IF OBJECT_ID('tempdb..#tmpUpdateItemSpecialPricingForCStore_Family') IS NULL  
	CREATE TABLE #tmpUpdateItemSpecialPricingForCStore_Family (
		intFamilyId INT 
	)

IF OBJECT_ID('tempdb..#tmpUpdateItemSpecialPricingForCStore_Class') IS NULL  
	CREATE TABLE #tmpUpdateItemSpecialPricingForCStore_Class (
		intClassId INT 
	)

-- Create the temp table for the audit log. 
IF OBJECT_ID('tempdb..#tmpUpdateItemSpecialPricingForCStore_AuditLog') IS NULL  
	CREATE TABLE #tmpUpdateItemSpecialPricingForCStore_AuditLog (
		intItemId INT
		,intItemSpecialPricingId INT 
		,dtmBeginDate_Original DATETIME 
		,dtmEndDate_Original DATETIME 
		,dblDiscount_Original NUMERIC(18, 6) 
		,dblAccumulatedAmount_Original NUMERIC(18, 6) 
		,dblAccumulatedQty_Original NUMERIC(18, 6) 
		,dblDiscountThruAmount_Original NUMERIC(18, 6) 
		,dblDiscountThruQty_Original NUMERIC(18, 6) 

		,dtmBeginDate_New DATETIME 
		,dtmEndDate_New DATETIME 
		,dblDiscount_New NUMERIC(18, 6) 
		,dblAccumulatedAmount_New NUMERIC(18, 6) 
		,dblAccumulatedQty_New NUMERIC(18, 6) 
		,dblDiscountThruAmount_New NUMERIC(18, 6) 
		,dblDiscountThruQty_New NUMERIC(18, 6) 
	)
;

-- Update the Standard Cost and Retail Price in the Item Pricing table. 
BEGIN 
	INSERT INTO #tmpUpdateItemSpecialPricingForCStore_AuditLog (
		intItemId 
		,intItemSpecialPricingId
		-- Original
		,dtmBeginDate_Original
		,dtmEndDate_Original
		,dblDiscount_Original
		,dblAccumulatedAmount_Original
		,dblAccumulatedQty_Original
		,dblDiscountThruAmount_Original
		,dblDiscountThruQty_Original
		-- New
		,dtmBeginDate_New
		,dtmEndDate_New
		,dblDiscount_New
		,dblAccumulatedAmount_New
		,dblAccumulatedQty_New
		,dblDiscountThruAmount_New
		,dblDiscountThruQty_New
	)
	SELECT	[Changes].intItemId 
			,[Changes].intItemSpecialPricingId
			,[Changes].dtmBeginDate_Original
			,[Changes].dtmEndDate_Original
			,[Changes].dblDiscount_Original
			,[Changes].dblAccumulatedAmount_Original
			,[Changes].dblAccumulatedQty_Original
			,[Changes].dblDiscountThruAmount_Original
			,[Changes].dblDiscountThruQty_Original
			-- New
			,[Changes].dtmBeginDate_New
			,[Changes].dtmEndDate_New
			,[Changes].dblDiscount_New
			,[Changes].dblAccumulatedAmount_New
			,[Changes].dblAccumulatedQty_New
			,[Changes].dblDiscountThruAmount_New
			,[Changes].dblDiscountThruQty_New
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
									AND il.intLocationId IS NOT NULL 
								INNER JOIN tblICItem i
									ON i.intItemId = itemSpecialPricing.intItemId 
									AND i.intItemId = ISNULL(@intItemId, i.intItemId)
						WHERE	(
									NOT EXISTS (SELECT TOP 1 1 FROM #tmpUpdateItemSpecialPricingForCStore_Location)
									OR EXISTS (SELECT TOP 1 1 FROM #tmpUpdateItemSpecialPricingForCStore_Location WHERE intLocationId = il.intLocationId) 			
								)
								AND (
									NOT EXISTS (SELECT TOP 1 1 FROM #tmpUpdateItemSpecialPricingForCStore_Vendor)
									OR EXISTS (SELECT TOP 1 1 FROM #tmpUpdateItemSpecialPricingForCStore_Vendor WHERE intVendorId = il.intVendorId) 			
								)
								AND (
									NOT EXISTS (SELECT TOP 1 1 FROM #tmpUpdateItemSpecialPricingForCStore_Category)
									OR EXISTS (SELECT TOP 1 1 FROM #tmpUpdateItemSpecialPricingForCStore_Category WHERE intCategoryId = i.intCategoryId)			
								)
								AND (
									NOT EXISTS (SELECT TOP 1 1 FROM #tmpUpdateItemSpecialPricingForCStore_Family)
									OR EXISTS (SELECT TOP 1 1 FROM #tmpUpdateItemSpecialPricingForCStore_Family WHERE intFamilyId = il.intFamilyId)			
								)
								AND (
									NOT EXISTS (SELECT TOP 1 1 FROM #tmpUpdateItemSpecialPricingForCStore_Class)
									OR EXISTS (SELECT TOP 1 1 FROM #tmpUpdateItemSpecialPricingForCStore_Class WHERE intClassId = il.intClassId )			
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
						ON itemSpecialPricing.intItemSpecialPricingId = Source_Query.intItemSpecialPricingId
					
					-- If matched, update the Standard Cost and Retail Price. 
					WHEN MATCHED THEN 
						UPDATE 
						SET		dtmBeginDate = ISNULL(@dtmBeginDate, itemSpecialPricing.dtmBeginDate)
								,dtmEndDate = ISNULL(@dtmEndDate, itemSpecialPricing.dtmEndDate)
								,dblDiscount = ISNULL(@dblDiscount, itemSpecialPricing.dblDiscount)
								,dblAccumulatedAmount = ISNULL(@dblAccumulatedAmount, itemSpecialPricing.dblAccumulatedAmount)
								,dblAccumulatedQty = ISNULL(@dblAccumulatedQty, itemSpecialPricing.dblAccumulatedQty)
								,dblDiscountThruAmount = ISNULL(@dblDiscountThruAmount, itemSpecialPricing.dblDiscountThruAmount)
								,dblDiscountThruQty = ISNULL(@dblDiscountThruQty, itemSpecialPricing.dblDiscountThruQty)
								,dtmDateModified = GETUTCDATE()
								,intModifiedByUserId = @intEntityUserSecurityId
					OUTPUT 
						$action
						, inserted.intItemId 
						, inserted.intItemSpecialPricingId
						-- Original
						, deleted.dtmBeginDate
						, deleted.dtmEndDate
						, deleted.dblDiscount
						, deleted.dblAccumulatedAmount
						, deleted.dblAccumulatedQty
						, deleted.dblDiscountThruAmount
						, deleted.dblDiscountThruQty
						-- New
						, inserted.dtmBeginDate
						, inserted.dtmEndDate
						, inserted.dblDiscount
						, inserted.dblAccumulatedAmount
						, inserted.dblAccumulatedQty
						, inserted.dblDiscountThruAmount
						, inserted.dblDiscountThruQty
			) AS [Changes] (
				Action
				,intItemId 
				,intItemSpecialPricingId
				,dtmBeginDate_Original
				,dtmEndDate_Original
				,dblDiscount_Original
				,dblAccumulatedAmount_Original
				,dblAccumulatedQty_Original
				,dblDiscountThruAmount_Original
				,dblDiscountThruQty_Original
				,dtmBeginDate_New
				,dtmEndDate_New
				,dblDiscount_New
				,dblAccumulatedAmount_New
				,dblAccumulatedQty_New
				,dblDiscountThruAmount_New
				,dblDiscountThruQty_New
			)
	WHERE	[Changes].Action = 'UPDATE'
	;
END

IF EXISTS (SELECT TOP 1 1 FROM #tmpUpdateItemSpecialPricingForCStore_AuditLog)
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
							@json2_date
							, 'C-Store updates the Begin Date in Promotional Pricing and Exemptions Grid'
							, dtmBeginDate_Original
							, dtmBeginDate_New
							, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT
						) 
						, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT
					) 
		FROM	#tmpUpdateItemSpecialPricingForCStore_AuditLog 
		WHERE	ISNULL(dtmBeginDate_Original, 0) <> ISNULL(dtmBeginDate_New, 0)
		UNION ALL 
		SELECT	intItemId
				,strJsonData = 
					dbo.fnFormatMessage(
						@json1
						, CAST(intItemId AS NVARCHAR(20)) 
						, dbo.fnFormatMessage(
							@json2_date
							, 'C-Store updates the End Date in Promotional Pricing and Exemptions Grid'
							, dtmEndDate_Original
							, dtmEndDate_New
							, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT
						) 
						, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT
					) 
		FROM	#tmpUpdateItemSpecialPricingForCStore_AuditLog 
		WHERE	ISNULL(dtmEndDate_Original, 0) <> ISNULL(dtmEndDate_New, 0)
		UNION ALL 
		SELECT	intItemId
				,strJsonData = 
					dbo.fnFormatMessage(
						@json1
						, CAST(intItemId AS NVARCHAR(20)) 
						, dbo.fnFormatMessage(
							@json2_float
							, 'C-Store updates the Discount Amount/Percent in Promotional Pricing and Exemptions Grid'
							, dblDiscount_Original
							, dblDiscount_New
							, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT
						) 
						, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT
					) 
		FROM	#tmpUpdateItemSpecialPricingForCStore_AuditLog 
		WHERE	ISNULL(dblDiscount_Original, 0) <> ISNULL(dblDiscount_New, 0)
		UNION ALL 
		SELECT	intItemId
				,strJsonData = 
					dbo.fnFormatMessage(
						@json1
						, CAST(intItemId AS NVARCHAR(20)) 
						, dbo.fnFormatMessage(
							@json2_float
							, 'C-Store updates the Accumulated Amount in Promotional Pricing and Exemptions Grid'
							, dblAccumulatedAmount_Original
							, dblAccumulatedAmount_New
							, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT
						) 
						, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT
					) 
		FROM	#tmpUpdateItemSpecialPricingForCStore_AuditLog 
		WHERE	ISNULL(dblAccumulatedAmount_Original, 0) <> ISNULL(dblAccumulatedAmount_New, 0)
		UNION ALL 
		SELECT	intItemId
				,strJsonData = 
					dbo.fnFormatMessage(
						@json1
						, CAST(intItemId AS NVARCHAR(20)) 
						, dbo.fnFormatMessage(
							@json2_float
							, 'C-Store updates the Accumulated Qty in Promotional Pricing and Exemptions Grid'
							, dblAccumulatedQty_Original
							, dblAccumulatedQty_New
							, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT
						) 
						, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT
					) 
		FROM	#tmpUpdateItemSpecialPricingForCStore_AuditLog 
		WHERE	ISNULL(dblAccumulatedQty_Original, 0) <> ISNULL(dblAccumulatedQty_New, 0)
		UNION ALL 
		SELECT	intItemId
				,strJsonData = 
					dbo.fnFormatMessage(
						@json1
						, CAST(intItemId AS NVARCHAR(20)) 
						, dbo.fnFormatMessage(
							@json2_float
							, 'C-Store updates the Discount thru Amount in Promotional Pricing and Exemptions Grid'
							, dblDiscountThruAmount_Original
							, dblDiscountThruAmount_New
							, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT
						) 
						, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT
					) 
		FROM	#tmpUpdateItemSpecialPricingForCStore_AuditLog 
		WHERE	ISNULL(dblDiscountThruAmount_Original, 0) <> ISNULL(dblDiscountThruAmount_New, 0)
		UNION ALL 
		SELECT	intItemId
				,strJsonData = 
					dbo.fnFormatMessage(
						@json1
						, CAST(intItemId AS NVARCHAR(20)) 
						, dbo.fnFormatMessage(
							@json2_float
							, 'C-Store updates the Discount thru Qty in Promotional Pricing and Exemptions Grid'
							, dblDiscountThruQty_Original
							, dblDiscountThruQty_New
							, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT
						) 
						, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT
					) 
		FROM	#tmpUpdateItemSpecialPricingForCStore_AuditLog 
		WHERE	ISNULL(dblDiscountThruQty_Original, 0) <> ISNULL(dblDiscountThruQty_New, 0)
	) auditLog
	WHERE auditLog.strJsonData IS NOT NULL 
END 