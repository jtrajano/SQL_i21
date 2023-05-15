/*
	This stored procedure will update the With Effective Date Sales Price and Cost in the Item Pricing 
*/
CREATE PROCEDURE [dbo].[uspICUpdateItemLocationPricingForCStore]
	-- filter params
	@strUpcCode AS NVARCHAR(50) = NULL 
	,@strScreen AS NVARCHAR(250) = NULL 
	,@strDescription AS NVARCHAR(250) = NULL 
	,@intItemLocationId AS INT = NULL 
	-- update params
	,@ysnCountedDaily AS BIT = NULL 
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

IF OBJECT_ID('tempdb..#tmpUpdateItemPricingForCStore_Subcategory') IS NULL  
	CREATE TABLE #tmpUpdateItemPricingForCStore_Subcategory (
		intSubcategoryId INT 
	)

IF OBJECT_ID('tempdb..#tmpUpdateItemPricingForCStore_Family') IS NULL  
	CREATE TABLE #tmpUpdateItemPricingForCStore_Family (
		intFamilyId INT 
	)

IF OBJECT_ID('tempdb..#tmpUpdateItemPricingForCStore_Class') IS NULL  
	CREATE TABLE #tmpUpdateItemPricingForCStore_Class (
		intClassId INT 
	)

IF OBJECT_ID('tempdb..#tmpUpdateItemPricingForCStore_UOMId') IS NULL 
BEGIN
	CREATE TABLE #tmpUpdateItemPricingForCStore_UOMId (
		intItemUOMId INT 
	)
END

-- Create the temp table for the audit log. 
IF OBJECT_ID('tempdb..#tmpItemLocationForCStore_AuditLog') IS NULL  
	CREATE TABLE #tmpItemLocationForCStore_AuditLog (
		intItemId INT
		,intItemLocationId INT 
		,ysnOldCountedDaily BIT
		,ysnNewCountedDaily BIT
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
IF @ysnCountedDaily IS NOT NULL
BEGIN 	
	INSERT INTO #tmpItemLocationForCStore_AuditLog (
		strAction 
		, intItemId 
		, intItemLocationId
		, ysnOldCountedDaily
		, ysnNewCountedDaily			
	)
	SELECT 
		strAction 
		, intItemId 
		, intItemLocationId
		, ysnOldCountedDaily
		, ysnNewCountedDaily	
	FROM (
		MERGE	
		INTO	dbo.tblICItemLocation 
		WITH	(HOLDLOCK) 
		AS		e
		USING (
			SELECT DISTINCT	i.intItemId, 
					il.intItemLocationId, 
					@ysnCountedDaily AS ysnCountedDaily
			FROM	tblICItemLocation il								
						INNER JOIN tblICItem i
							ON i.intItemId = il.intItemId				
						INNER JOIN tblICItemUOM iu
							ON i.intItemId = iu.intItemId 					
			WHERE	
					(
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
						NOT EXISTS (SELECT TOP 1 1 FROM #tmpUpdateItemPricingForCStore_Subcategory)
						OR EXISTS (SELECT TOP 1 1 FROM #tmpUpdateItemPricingForCStore_Subcategory WHERE intSubcategoryId = i.intSubcategoriesId)			
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
						NOT EXISTS (SELECT TOP 1 1 FROM #tmpUpdateItemPricingForCStore_UOMId)
						OR EXISTS (SELECT TOP 1 1 FROM #tmpUpdateItemPricingForCStore_UOMId WHERE intItemUOMId = iu.intItemUOMId )			
					)
					AND (
						@strDescription IS NULL 
						OR i.strDescription LIKE '%' + @strDescription + '%'	--ST-2074
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

		-- If matched, update the effective cost.
		WHEN MATCHED THEN 
			UPDATE 
			SET 
				e.ysnCountedDaily = u.ysnCountedDaily
				,e.dtmDateModified = GETDATE()
				,e.intModifiedByUserId = @intEntityUserSecurityId
		OUTPUT 
			$action
			, inserted.intItemId 
			, inserted.intItemLocationId 
			, deleted.ysnCountedDaily
			, inserted.ysnCountedDaily
	) AS [Changes] (
			strAction 
			, intItemId 
			, intItemLocationId
			, ysnOldCountedDaily
			, ysnNewCountedDaily			
	);
END

-- Audit log for the Item Cost with Effective Date.
IF EXISTS (SELECT TOP 1 1 FROM #tmpItemLocationForCStore_AuditLog)
BEGIN 

	DECLARE loopAuditLog CURSOR LOCAL FAST_FORWARD
	FOR 	
	SELECT	intItemId
			,strOld = ysnOldCountedDaily
			,strNew = ysnNewCountedDaily
			,strAction 
			,strDescription = 
				dbo.fnFormatMessage(
					'C-Store %s an Counted Daily to %d.' -- C-Store {creates|updates} an Item Cost with Effective Date on {Date}.
					,LOWER(REPLACE(strAction, 'INSERT', 'CREATE')) + 's'
					,ISNULL(ysnOldCountedDaily, ysnNewCountedDaily) 
					,DEFAULT 
					,DEFAULT 
					,DEFAULT 
					,DEFAULT 
					,DEFAULT 
					,DEFAULT 
					,DEFAULT 
					,DEFAULT 				
				)
	FROM	#tmpItemLocationForCStore_AuditLog
	WHERE	ISNULL(ysnOldCountedDaily, 0) <> ISNULL(ysnNewCountedDaily, 0)

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