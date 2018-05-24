/*
	This stored procedure will update the Sales Price in the Item Pricing and Item Pricing Level. 
*/
CREATE PROCEDURE [dbo].[uspICUpdateItemPricingForCStore]
	-- filter params
	@strUpcCode AS NVARCHAR(50) = NULL 
	,@strDescription AS NVARCHAR(250) = NULL 
	-- update params
	,@dblStandardCost AS NUMERIC(38, 20) = NULL 
	,@dblRetailPrice AS NUMERIC(38, 20) = NULL 
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
		,dblNewStandardCost NUMERIC(38, 20) NULL
		,dblNewSalePrice NUMERIC(38, 20) NULL
	)
;

-- Update the Standard Cost and Retail Price in the Item Pricing table. 
BEGIN 
	INSERT INTO #tmpUpdateItemPricingForCStore_ItemPricingAuditLog (
		intItemId 
		,intItemPricingId 
		,dblOldStandardCost 
		,dblOldSalePrice 
		,dblNewStandardCost 
		,dblNewSalePrice 
	)
	SELECT	[Changes].intItemId 
			,[Changes].intItemPricingId
			,[Changes].dblOldStandardCost
			,[Changes].dblOldSalePrice
			,[Changes].dblNewStandardCost
			,[Changes].dblNewSalePrice
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
								INNER JOIN tblICItem i
									ON i.intItemId = ItemPricing.intItemId 
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
								,dtmDateModified = GETUTCDATE()
								,intModifiedByUserId = @intEntityUserSecurityId
					OUTPUT 
						$action
						, inserted.intItemId 
						, inserted.intItemPricingId
						, deleted.dblStandardCost 
						, deleted.dblSalePrice
						, inserted.dblStandardCost
						, inserted.dblSalePrice
			) AS [Changes] (
				Action
				, intItemId 
				, intItemPricingId
				, dblOldStandardCost
				, dblOldSalePrice
				, dblNewStandardCost
				, dblNewSalePrice
			)
	WHERE	[Changes].Action = 'UPDATE'
	;
END

IF EXISTS (SELECT TOP 1 1 FROM #tmpUpdateItemPricingForCStore_ItemPricingAuditLog)
BEGIN 
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
			, strTransactionType = 'Inventory.view.Item'
			, strRecordNo = intItemId
			, strDescription = ''
			, strRoute = null 
			, strJsonData = 
				dbo.fnFormatMessage(
					'{"action":"Updated","change":"Updated - Record: %s","iconCls":"small-menu-maintenance","children":[%s]}'
					, CAST(intItemId AS NVARCHAR(20)) 
					, dbo.fnFormatMessage(
						'{"change":"%s","iconCls":"small-menu-maintenance","from":"%f","to":"%f","leaf":true}'
						, 'C-Store updates the Standard Cost'
						, dblOldStandardCost
						, dblNewStandardCost
						, DEFAULT
						, DEFAULT
						, DEFAULT
						, DEFAULT
						, DEFAULT
						, DEFAULT
						, DEFAULT
					) 
					, DEFAULT
					, DEFAULT
					, DEFAULT
					, DEFAULT
					, DEFAULT
					, DEFAULT
					, DEFAULT
					, DEFAULT
				) 
			, dtmDate = GETUTCDATE()
			, intEntityId = @intEntityUserSecurityId 
			, intConcurrencyId = 1
	FROM	#tmpUpdateItemPricingForCStore_ItemPricingAuditLog 
	WHERE	ISNULL(dblOldStandardCost, 0) <> ISNULL(dblNewStandardCost, 0)
	-- Add audit logs for Retail Price changes. 
	UNION ALL
	SELECT 
			strActionType = 'Updated'
			, strTransactionType = 'Inventory.view.Item'
			, strRecordNo = intItemId
			, strDescription = ''
			, strRoute = null 
			, strJsonData = 
				dbo.fnFormatMessage(
					'{"action":"Updated","change":"Updated - Record: %s","iconCls":"small-menu-maintenance","children":[%s]}'
					, CAST(intItemId AS NVARCHAR(20)) 
					, dbo.fnFormatMessage(
						'{"change":"%s","iconCls":"small-menu-maintenance","from":"%f","to":"%f","leaf":true}'
						, 'C-Store updates the Retail Price'
						, dblOldSalePrice
						, dblNewSalePrice
						, DEFAULT
						, DEFAULT
						, DEFAULT
						, DEFAULT
						, DEFAULT
						, DEFAULT
						, DEFAULT
					) 
					, DEFAULT
					, DEFAULT
					, DEFAULT
					, DEFAULT
					, DEFAULT
					, DEFAULT
					, DEFAULT
					, DEFAULT
				) 
			, dtmDate = GETUTCDATE()
			, intEntityId = @intEntityUserSecurityId 
			, intConcurrencyId = 1
	FROM	#tmpUpdateItemPricingForCStore_ItemPricingAuditLog 
	WHERE	ISNULL(dblOldSalePrice, 0) <> ISNULL(dblNewSalePrice, 0)
END 