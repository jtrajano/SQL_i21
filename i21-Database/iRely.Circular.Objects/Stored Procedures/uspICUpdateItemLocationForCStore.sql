CREATE PROCEDURE [dbo].[uspICUpdateItemLocationForCStore]
	-- filter params
	@strUpcCode AS NVARCHAR(50) = NULL 
	,@strDescription AS NVARCHAR(250) = NULL 
	,@dblRetailPriceFrom AS NUMERIC(38, 20) = NULL  
	,@dblRetailPriceTo AS NUMERIC(38, 20) = NULL 
	,@intItemLocationId AS INT = NULL 
	-- update params 
	,@ysnTaxFlag1 BIT = NULL
	,@ysnTaxFlag2 BIT = NULL
	,@ysnTaxFlag3 BIT = NULL
	,@ysnTaxFlag4 BIT = NULL
	,@ysnDepositRequired BIT = NULL
	,@intDepositPLUId INT = NULL 
	,@ysnQuantityRequired BIT = NULL 
	,@ysnScaleItem BIT = NULL 
	,@ysnFoodStampable BIT = NULL 
	,@ysnReturnable BIT = NULL 
	,@ysnSaleable BIT = NULL 
	,@ysnIdRequiredLiquor BIT = NULL 
	,@ysnIdRequiredCigarette BIT = NULL 
	,@ysnPromotionalItem BIT = NULL 
	,@ysnPrePriced BIT = NULL 
	,@ysnApplyBlueLaw1 BIT = NULL 
	,@ysnApplyBlueLaw2 BIT = NULL 
	,@ysnCountedDaily BIT = NULL 
	,@strCounted NVARCHAR(50) = NULL
	,@ysnCountBySINo BIT = NULL 
	,@intFamilyId INT = NULL 
	,@intClassId INT = NULL 
	,@intProductCodeId INT = NULL 
	,@intVendorId INT = NULL 
	,@intMinimumAge INT = NULL 
	,@dblMinOrder NUMERIC(18, 6) = NULL 
	,@dblSuggestedQty NUMERIC(18, 6) = NULL
	,@intCountGroupId INT = NULL 
	,@intStorageLocationId INT = NULL 
	,@dblReorderPoint NUMERIC(18, 6) = NULL
	,@strItemLocationDescription NVARCHAR(1000) = NULL 
	,@intEntityUserSecurityId AS INT 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

-- Create the temp table used for filtering. 
IF OBJECT_ID('tempdb..#tmpUpdateItemForCStore_Location') IS NULL  
	CREATE TABLE #tmpUpdateItemForCStore_Location (
		intLocationId INT 
	)

IF OBJECT_ID('tempdb..#tmpUpdateItemForCStore_Vendor') IS NULL  
	CREATE TABLE #tmpUpdateItemForCStore_Vendor (
		intVendorId INT 
	)

IF OBJECT_ID('tempdb..#tmpUpdateItemForCStore_Category') IS NULL  
	CREATE TABLE #tmpUpdateItemForCStore_Category (
		intCategoryId INT 
	)

IF OBJECT_ID('tempdb..#tmpUpdateItemForCStore_Family') IS NULL  
	CREATE TABLE #tmpUpdateItemForCStore_Family (
		intFamilyId INT 
	)

IF OBJECT_ID('tempdb..#tmpUpdateItemForCStore_Class') IS NULL  
	CREATE TABLE #tmpUpdateItemForCStore_Class (
		intClassId INT 
	)

-- Create the temp table for the audit log. 
IF OBJECT_ID('tempdb..#tmpUpdateItemLocationForCStore_itemLocationAuditLog') IS NULL  
	CREATE TABLE #tmpUpdateItemLocationForCStore_itemLocationAuditLog (
		intItemId INT
		,intItemLocationId INT 
		-- Original Fields
		,ysnTaxFlag1_Original BIT NULL
		,ysnTaxFlag2_Original BIT NULL
		,ysnTaxFlag3_Original BIT NULL
		,ysnTaxFlag4_Original BIT NULL
		,ysnDepositRequired_Original BIT NULL
		,intDepositPLUId_Original INT NULL 
		,ysnQuantityRequired_Original BIT NULL 
		,ysnScaleItem_Original BIT NULL 
		,ysnFoodStampable_Original BIT NULL 
		,ysnReturnable_Original BIT NULL 
		,ysnSaleable_Original BIT NULL 
		,ysnIdRequiredLiquor_Original BIT NULL 
		,ysnIdRequiredCigarette_Original BIT NULL 
		,ysnPromotionalItem_Original BIT NULL 
		,ysnPrePriced_Original BIT NULL 
		,ysnApplyBlueLaw1_Original BIT NULL 
		,ysnApplyBlueLaw2_Original BIT NULL 
		,ysnCountedDaily_Original BIT NULL 
		,strCounted_Original NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
		,ysnCountBySINo_Original BIT NULL 
		,intFamilyId_Original INT NULL 
		,intClassId_Original INT NULL 
		,intProductCodeId_Original INT NULL 
		,intVendorId_Original INT NULL 
		,intMinimumAge_Original INT NULL 
		,dblMinOrder_Original NUMERIC(18, 6) NULL 
		,dblSuggestedQty_Original NUMERIC(18, 6) NULL
		,intCountGroupId_Original INT NULL 
		,intStorageLocationId_Original INT NULL 
		,dblReorderPoint_Original NUMERIC(18, 6) NULL
		,strDescription_Original NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL
		-- Modified Fields
		,ysnTaxFlag1_New BIT NULL
		,ysnTaxFlag2_New BIT NULL
		,ysnTaxFlag3_New BIT NULL
		,ysnTaxFlag4_New BIT NULL
		,ysnDepositRequired_New BIT NULL
		,intDepositPLUId_New INT NULL 
		,ysnQuantityRequired_New BIT NULL 
		,ysnScaleItem_New BIT NULL 
		,ysnFoodStampable_New BIT NULL 
		,ysnReturnable_New BIT NULL 
		,ysnSaleable_New BIT NULL 
		,ysnIdRequiredLiquor_New BIT NULL 
		,ysnIdRequiredCigarette_New BIT NULL 
		,ysnPromotionalItem_New BIT NULL 
		,ysnPrePriced_New BIT NULL 
		,ysnApplyBlueLaw1_New BIT NULL 
		,ysnApplyBlueLaw2_New BIT NULL 
		,ysnCountedDaily_New BIT NULL 
		,strCounted_New NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
		,ysnCountBySINo_New BIT NULL 
		,intFamilyId_New INT NULL 
		,intClassId_New INT NULL 
		,intProductCodeId_New INT NULL 
		,intVendorId_New INT NULL 
		,intMinimumAge_New INT NULL 
		,dblMinOrder_New NUMERIC(18, 6) NULL 
		,dblSuggestedQty_New NUMERIC(18, 6) NULL
		,intCountGroupId_New INT NULL 
		,intStorageLocationId_New INT NULL 
		,dblReorderPoint_New NUMERIC(18, 6) NULL
		,strDescription_New NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL
	)
;

-- Update the Standard Cost and Retail Price in the Item Pricing table. 
BEGIN 
	INSERT INTO #tmpUpdateItemLocationForCStore_itemLocationAuditLog (
		intItemId 
		,intItemLocationId 
		-- Original values
		, ysnTaxFlag1_Original
		, ysnTaxFlag2_Original
		, ysnTaxFlag3_Original
		, ysnTaxFlag4_Original
		, ysnDepositRequired_Original
		, intDepositPLUId_Original
		, ysnQuantityRequired_Original
		, ysnScaleItem_Original
		, ysnFoodStampable_Original
		, ysnReturnable_Original
		, ysnSaleable_Original
		, ysnIdRequiredLiquor_Original
		, ysnIdRequiredCigarette_Original
		, ysnPromotionalItem_Original
		, ysnPrePriced_Original
		, ysnApplyBlueLaw1_Original
		, ysnApplyBlueLaw2_Original
		, ysnCountedDaily_Original
		, strCounted_Original
		, ysnCountBySINo_Original
		, intFamilyId_Original
		, intClassId_Original
		, intProductCodeId_Original
		, intVendorId_Original
		, intMinimumAge_Original
		, dblMinOrder_Original
		, dblSuggestedQty_Original
		, intCountGroupId_Original
		, intStorageLocationId_Original
		, dblReorderPoint_Original
		, strDescription_Original
		-- Modified values 
		, ysnTaxFlag1_New
		, ysnTaxFlag2_New
		, ysnTaxFlag3_New
		, ysnTaxFlag4_New
		, ysnDepositRequired_New
		, intDepositPLUId_New
		, ysnQuantityRequired_New
		, ysnScaleItem_New
		, ysnFoodStampable_New
		, ysnReturnable_New
		, ysnSaleable_New
		, ysnIdRequiredLiquor_New
		, ysnIdRequiredCigarette_New
		, ysnPromotionalItem_New
		, ysnPrePriced_New
		, ysnApplyBlueLaw1_New
		, ysnApplyBlueLaw2_New
		, ysnCountedDaily_New
		, strCounted_New
		, ysnCountBySINo_New
		, intFamilyId_New
		, intClassId_New
		, intProductCodeId_New
		, intVendorId_New
		, intMinimumAge_New
		, dblMinOrder_New
		, dblSuggestedQty_New
		, intCountGroupId_New
		, intStorageLocationId_New
		, dblReorderPoint_New
		, strDescription_New
	)
	SELECT	[Changes].intItemId 
			,[Changes].intItemLocationId
			-- Original values
			, [Changes].ysnTaxFlag1_Original
			, [Changes].ysnTaxFlag2_Original
			, [Changes].ysnTaxFlag3_Original
			, [Changes].ysnTaxFlag4_Original
			, [Changes].ysnDepositRequired_Original
			, [Changes].intDepositPLUId_Original
			, [Changes].ysnQuantityRequired_Original
			, [Changes].ysnScaleItem_Original
			, [Changes].ysnFoodStampable_Original
			, [Changes].ysnReturnable_Original
			, [Changes].ysnSaleable_Original
			, [Changes].ysnIdRequiredLiquor_Original
			, [Changes].ysnIdRequiredCigarette_Original
			, [Changes].ysnPromotionalItem_Original
			, [Changes].ysnPrePriced_Original
			, [Changes].ysnApplyBlueLaw1_Original
			, [Changes].ysnApplyBlueLaw2_Original
			, [Changes].ysnCountedDaily_Original
			, [Changes].strCounted_Original
			, [Changes].ysnCountBySINo_Original
			, [Changes].intFamilyId_Original
			, [Changes].intClassId_Original
			, [Changes].intProductCodeId_Original
			, [Changes].intVendorId_Original
			, [Changes].intMinimumAge_Original
			, [Changes].dblMinOrder_Original
			, [Changes].dblSuggestedQty_Original
			, [Changes].intCountGroupId_Original
			, [Changes].intStorageLocationId_Original
			, [Changes].dblReorderPoint_Original
			, [Changes].strDescription_Original
			-- Modified values 
			, [Changes].ysnTaxFlag1_New
			, [Changes].ysnTaxFlag2_New
			, [Changes].ysnTaxFlag3_New
			, [Changes].ysnTaxFlag4_New
			, [Changes].ysnDepositRequired_New
			, [Changes].intDepositPLUId_New
			, [Changes].ysnQuantityRequired_New
			, [Changes].ysnScaleItem_New
			, [Changes].ysnFoodStampable_New
			, [Changes].ysnReturnable_New
			, [Changes].ysnSaleable_New
			, [Changes].ysnIdRequiredLiquor_New
			, [Changes].ysnIdRequiredCigarette_New
			, [Changes].ysnPromotionalItem_New
			, [Changes].ysnPrePriced_New
			, [Changes].ysnApplyBlueLaw1_New
			, [Changes].ysnApplyBlueLaw2_New
			, [Changes].ysnCountedDaily_New
			, [Changes].strCounted_New
			, [Changes].ysnCountBySINo_New
			, [Changes].intFamilyId_New
			, [Changes].intClassId_New
			, [Changes].intProductCodeId_New
			, [Changes].intVendorId_New
			, [Changes].intMinimumAge_New
			, [Changes].dblMinOrder_New
			, [Changes].dblSuggestedQty_New
			, [Changes].intCountGroupId_New
			, [Changes].intStorageLocationId_New
			, [Changes].dblReorderPoint_New
			, [Changes].strDescription_New
	FROM	(
				-- Merge will help us build the audit log and update the records at the same time. 
				MERGE	
					INTO	dbo.tblICItemLocation  
					WITH	(HOLDLOCK) 
					AS		itemLocation	
					USING (
						SELECT	itemLocation.intItemLocationId
						FROM	tblICItemLocation itemLocation INNER JOIN tblICItem i
									ON i.intItemId = itemLocation.intItemId 
									AND itemLocation.intLocationId IS NOT NULL 
									AND itemLocation.intItemLocationId = ISNULL(@intItemLocationId, itemLocation.intItemLocationId)
								LEFT JOIN tblICItemPricing itemPricing
									ON itemPricing.intItemLocationId = itemLocation.intItemLocationId
						WHERE	(
									NOT EXISTS (SELECT TOP 1 1 FROM #tmpUpdateItemForCStore_Location)
									OR EXISTS (SELECT TOP 1 1 FROM #tmpUpdateItemForCStore_Location WHERE intLocationId = itemLocation.intLocationId) 			
								)
								AND (
									NOT EXISTS (SELECT TOP 1 1 FROM #tmpUpdateItemForCStore_Vendor)
									OR EXISTS (SELECT TOP 1 1 FROM #tmpUpdateItemForCStore_Vendor WHERE intVendorId = itemLocation.intVendorId) 			
								)
								AND (
									NOT EXISTS (SELECT TOP 1 1 FROM #tmpUpdateItemForCStore_Category)
									OR EXISTS (SELECT TOP 1 1 FROM #tmpUpdateItemForCStore_Category WHERE intCategoryId = i.intCategoryId)			
								)
								AND (
									NOT EXISTS (SELECT TOP 1 1 FROM #tmpUpdateItemForCStore_Family)
									OR EXISTS (SELECT TOP 1 1 FROM #tmpUpdateItemForCStore_Family WHERE intFamilyId = itemLocation.intFamilyId)			
								)
								AND (
									NOT EXISTS (SELECT TOP 1 1 FROM #tmpUpdateItemForCStore_Class)
									OR EXISTS (SELECT TOP 1 1 FROM #tmpUpdateItemForCStore_Class WHERE intClassId = itemLocation.intClassId )			
								)
								AND (
									@strDescription IS NULL 
									OR i.strDescription = @strDescription 
								)
								AND (
									@dblRetailPriceFrom IS NULL 
									OR ISNULL(itemPricing.dblSalePrice, 0) >= @dblRetailPriceFrom 
								)
								AND (
									@dblRetailPriceTo IS NULL 
									OR ISNULL(itemPricing.dblSalePrice, 0) <= @dblRetailPriceTo
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
						ON itemLocation.intItemLocationId = Source_Query.intItemLocationId					
					
					-- If matched, update the Standard Cost and Retail Price. 
					WHEN MATCHED THEN 
						UPDATE 
						SET		
							ysnTaxFlag1 = ISNULL(@ysnTaxFlag1, itemLocation.ysnTaxFlag1) 
							,ysnTaxFlag2 = ISNULL(@ysnTaxFlag2, itemLocation.ysnTaxFlag2) 
							,ysnTaxFlag3 = ISNULL(@ysnTaxFlag3, itemLocation.ysnTaxFlag3) 
							,ysnTaxFlag4 = ISNULL(@ysnTaxFlag4, itemLocation.ysnTaxFlag4) 
							,ysnDepositRequired = ISNULL(@ysnDepositRequired, itemLocation.ysnDepositRequired) 
							,intDepositPLUId = ISNULL(@intDepositPLUId, itemLocation.intDepositPLUId) 
							,ysnQuantityRequired = ISNULL(@ysnQuantityRequired, itemLocation.ysnQuantityRequired) 
							,ysnScaleItem = ISNULL(@ysnScaleItem, itemLocation.ysnScaleItem) 
							,ysnFoodStampable = ISNULL(@ysnFoodStampable, itemLocation.ysnFoodStampable) 
							,ysnReturnable = ISNULL(@ysnReturnable, itemLocation.ysnReturnable) 
							,ysnSaleable = ISNULL(@ysnSaleable, itemLocation.ysnSaleable) 
							,ysnIdRequiredLiquor = ISNULL(@ysnIdRequiredLiquor, itemLocation.ysnIdRequiredLiquor) 
							,ysnIdRequiredCigarette = ISNULL(@ysnIdRequiredCigarette, itemLocation.ysnIdRequiredCigarette) 
							,ysnPromotionalItem = ISNULL(@ysnPromotionalItem, itemLocation.ysnPromotionalItem) 
							,ysnPrePriced = ISNULL(@ysnPrePriced, itemLocation.ysnPrePriced) 
							,ysnApplyBlueLaw1 = ISNULL(@ysnApplyBlueLaw1, itemLocation.ysnApplyBlueLaw1) 
							,ysnApplyBlueLaw2 = ISNULL(@ysnApplyBlueLaw2, itemLocation.ysnApplyBlueLaw2) 
							,ysnCountedDaily = ISNULL(@ysnCountedDaily, itemLocation.ysnCountedDaily) 
							,strCounted = ISNULL(@strCounted, itemLocation.strCounted) 
							,ysnCountBySINo = ISNULL(@ysnCountBySINo, itemLocation.ysnCountBySINo) 
							,intFamilyId = ISNULL(@intFamilyId, itemLocation.intFamilyId) 
							,intClassId = ISNULL(@intClassId, itemLocation.intClassId) 
							,intProductCodeId = ISNULL(@intProductCodeId, itemLocation.intProductCodeId) 
							,intVendorId = ISNULL(@intVendorId, itemLocation.intVendorId) 
							,intMinimumAge = ISNULL(@intMinimumAge, itemLocation.intMinimumAge) 
							,dblMinOrder = ISNULL(@dblMinOrder, itemLocation.dblMinOrder) 
							,dblSuggestedQty = ISNULL(@dblSuggestedQty, itemLocation.dblSuggestedQty) 
							,intCountGroupId = ISNULL(@intCountGroupId, itemLocation.intCountGroupId) 
							,intStorageLocationId = ISNULL(@intStorageLocationId, itemLocation.intStorageLocationId) 
							,dblReorderPoint = ISNULL(@dblReorderPoint, itemLocation.dblReorderPoint) 
							,strDescription = ISNULL(@strItemLocationDescription, itemLocation.strDescription)
							,dtmDateModified = GETUTCDATE()
							,intModifiedByUserId = @intEntityUserSecurityId
					OUTPUT 
						$action
						, inserted.intItemId 
						, inserted.intItemLocationId
						-- Original values
						, deleted.ysnTaxFlag1
						, deleted.ysnTaxFlag2
						, deleted.ysnTaxFlag3
						, deleted.ysnTaxFlag4
						, deleted.ysnDepositRequired
						, deleted.intDepositPLUId
						, deleted.ysnQuantityRequired
						, deleted.ysnScaleItem
						, deleted.ysnFoodStampable
						, deleted.ysnReturnable
						, deleted.ysnSaleable
						, deleted.ysnIdRequiredLiquor
						, deleted.ysnIdRequiredCigarette
						, deleted.ysnPromotionalItem
						, deleted.ysnPrePriced
						, deleted.ysnApplyBlueLaw1
						, deleted.ysnApplyBlueLaw2
						, deleted.ysnCountedDaily
						, deleted.strCounted
						, deleted.ysnCountBySINo
						, deleted.intFamilyId
						, deleted.intClassId
						, deleted.intProductCodeId
						, deleted.intVendorId
						, deleted.intMinimumAge
						, deleted.dblMinOrder
						, deleted.dblSuggestedQty
						, deleted.intCountGroupId
						, deleted.intStorageLocationId
						, deleted.dblReorderPoint
						, deleted.strDescription
						-- Modified values 
						, inserted.ysnTaxFlag1
						, inserted.ysnTaxFlag2
						, inserted.ysnTaxFlag3
						, inserted.ysnTaxFlag4
						, inserted.ysnDepositRequired
						, inserted.intDepositPLUId
						, inserted.ysnQuantityRequired
						, inserted.ysnScaleItem
						, inserted.ysnFoodStampable
						, inserted.ysnReturnable
						, inserted.ysnSaleable
						, inserted.ysnIdRequiredLiquor
						, inserted.ysnIdRequiredCigarette
						, inserted.ysnPromotionalItem
						, inserted.ysnPrePriced
						, inserted.ysnApplyBlueLaw1
						, inserted.ysnApplyBlueLaw2
						, inserted.ysnCountedDaily
						, inserted.strCounted
						, inserted.ysnCountBySINo
						, inserted.intFamilyId
						, inserted.intClassId
						, inserted.intProductCodeId
						, inserted.intVendorId
						, inserted.intMinimumAge
						, inserted.dblMinOrder
						, inserted.dblSuggestedQty
						, inserted.intCountGroupId
						, inserted.intStorageLocationId
						, inserted.dblReorderPoint
						, inserted.strDescription
			) AS [Changes] (
				Action
				, intItemId 
				, intItemLocationId
				-- Original values
				, ysnTaxFlag1_Original
				, ysnTaxFlag2_Original
				, ysnTaxFlag3_Original
				, ysnTaxFlag4_Original
				, ysnDepositRequired_Original
				, intDepositPLUId_Original
				, ysnQuantityRequired_Original
				, ysnScaleItem_Original
				, ysnFoodStampable_Original
				, ysnReturnable_Original
				, ysnSaleable_Original
				, ysnIdRequiredLiquor_Original
				, ysnIdRequiredCigarette_Original
				, ysnPromotionalItem_Original
				, ysnPrePriced_Original
				, ysnApplyBlueLaw1_Original
				, ysnApplyBlueLaw2_Original
				, ysnCountedDaily_Original
				, strCounted_Original
				, ysnCountBySINo_Original
				, intFamilyId_Original
				, intClassId_Original
				, intProductCodeId_Original
				, intVendorId_Original
				, intMinimumAge_Original
				, dblMinOrder_Original
				, dblSuggestedQty_Original
				, intCountGroupId_Original
				, intStorageLocationId_Original
				, dblReorderPoint_Original
				, strDescription_Original
				-- Modified values 
				, ysnTaxFlag1_New
				, ysnTaxFlag2_New
				, ysnTaxFlag3_New
				, ysnTaxFlag4_New
				, ysnDepositRequired_New
				, intDepositPLUId_New
				, ysnQuantityRequired_New
				, ysnScaleItem_New
				, ysnFoodStampable_New
				, ysnReturnable_New
				, ysnSaleable_New
				, ysnIdRequiredLiquor_New
				, ysnIdRequiredCigarette_New
				, ysnPromotionalItem_New
				, ysnPrePriced_New
				, ysnApplyBlueLaw1_New
				, ysnApplyBlueLaw2_New
				, ysnCountedDaily_New
				, strCounted_New
				, ysnCountBySINo_New
				, intFamilyId_New
				, intClassId_New
				, intProductCodeId_New
				, intVendorId_New
				, intMinimumAge_New
				, dblMinOrder_New
				, dblSuggestedQty_New
				, intCountGroupId_New
				, intStorageLocationId_New
				, dblReorderPoint_New
				, strDescription_New
			)
	WHERE	[Changes].Action = 'UPDATE'
	;
END

IF EXISTS (SELECT TOP 1 1 FROM #tmpUpdateItemLocationForCStore_itemLocationAuditLog)
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
			, strTransactionType =  'Inventory.view.ItemLocation'
			, strRecordNo = auditLog.intItemLocationId
			, strDescription = ''
			, strRoute = null 
			, strJsonData = auditLog.strJsonData
			, dtmDate = GETUTCDATE()
			, intEntityId = @intEntityUserSecurityId 
			, intConcurrencyId = 1
	FROM	(
		SELECT	intItemLocationId
				,strJsonData = 
					dbo.fnFormatMessage(
						@json1
						, CAST(intItemLocationId AS NVARCHAR(20)) 
						, dbo.fnFormatMessage(
							@json2_int
							, 'C-Store updates the Tax Flag 1'
							, ysnTaxFlag1_Original
							, ysnTaxFlag1_New
							, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT
						) 
						, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT
					) 
		FROM	#tmpUpdateItemLocationForCStore_itemLocationAuditLog 
		WHERE	ISNULL(ysnTaxFlag1_Original, 0) <> ISNULL(ysnTaxFlag1_New, 0)
		UNION ALL
		SELECT	intItemLocationId
				, strJsonData = 
					dbo.fnFormatMessage(
						@json1
						, CAST(intItemLocationId AS NVARCHAR(20)) 
						, dbo.fnFormatMessage(
							@json2_int
							, 'C-Store updates the Tax Flag 2'
							, ysnTaxFlag2_Original
							, ysnTaxFlag2_New
							, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT
						) 
						, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT
					)
		FROM	#tmpUpdateItemLocationForCStore_itemLocationAuditLog 
		WHERE	ISNULL(ysnTaxFlag2_Original, 0) <> ISNULL(ysnTaxFlag2_New, 0)
		UNION ALL
		SELECT	intItemLocationId
				, strJsonData = 
					dbo.fnFormatMessage(
						@json1
						, CAST(intItemLocationId AS NVARCHAR(20)) 
						, dbo.fnFormatMessage(
							@json2_int
							, 'C-Store updates the Tax Flag 3'
							, ysnTaxFlag3_Original
							, ysnTaxFlag3_New
							, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT
						) 
						, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT
					)
		FROM	#tmpUpdateItemLocationForCStore_itemLocationAuditLog 
		WHERE	ISNULL(ysnTaxFlag3_Original, 0) <> ISNULL(ysnTaxFlag3_New, 0)	
		UNION ALL
		SELECT	intItemLocationId
				, strJsonData = 
					dbo.fnFormatMessage(
						@json1
						, CAST(intItemLocationId AS NVARCHAR(20)) 
						, dbo.fnFormatMessage(
							@json2_int
							, 'C-Store updates the Tax Flag 4'
							, ysnTaxFlag4_Original
							, ysnTaxFlag4_New
							, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT
						) 
						, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT
					)
		FROM	#tmpUpdateItemLocationForCStore_itemLocationAuditLog 
		WHERE	ISNULL(ysnTaxFlag4_Original, 0) <> ISNULL(ysnTaxFlag4_New, 0)	

		UNION ALL
		SELECT	intItemLocationId
				, strJsonData = 
					dbo.fnFormatMessage(
						@json1
						, CAST(intItemLocationId AS NVARCHAR(20)) 
						, dbo.fnFormatMessage(
							@json2_int
							, 'C-Store updates the Deposit Required'
							, ysnDepositRequired_Original
							, ysnDepositRequired_New
							, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT
						) 
						, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT
					)
		FROM	#tmpUpdateItemLocationForCStore_itemLocationAuditLog 
		WHERE	ISNULL(ysnDepositRequired_Original, 0) <> ISNULL(ysnDepositRequired_New, 0)	

		UNION ALL
		SELECT	intItemLocationId
				, strJsonData = 
					dbo.fnFormatMessage(
						@json1
						, CAST(intItemLocationId AS NVARCHAR(20)) 
						, dbo.fnFormatMessage(
							@json2_int
							, 'C-Store updates the Deposit PLU Id'
							, intDepositPLUId_Original
							, intDepositPLUId_New
							, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT
						) 
						, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT
					)
		FROM	#tmpUpdateItemLocationForCStore_itemLocationAuditLog 
		WHERE	ISNULL(intDepositPLUId_Original, 0) <> ISNULL(intDepositPLUId_New, 0)	

		UNION ALL
		SELECT	intItemLocationId
				, strJsonData = 
					dbo.fnFormatMessage(
						@json1
						, CAST(intItemLocationId AS NVARCHAR(20)) 
						, dbo.fnFormatMessage(
							@json2_int
							, 'C-Store updates the Quantity Required'
							, ysnQuantityRequired_Original
							, ysnQuantityRequired_New
							, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT
						) 
						, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT
					)
		FROM	#tmpUpdateItemLocationForCStore_itemLocationAuditLog 
		WHERE	ISNULL(ysnQuantityRequired_Original, 0) <> ISNULL(ysnQuantityRequired_New, 0)	

		UNION ALL
		SELECT	intItemLocationId
				, strJsonData = 
					dbo.fnFormatMessage(
						@json1
						, CAST(intItemLocationId AS NVARCHAR(20)) 
						, dbo.fnFormatMessage(
							@json2_int
							, 'C-Store updates the Scale Item'
							, ysnScaleItem_Original
							, ysnScaleItem_New
							, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT
						) 
						, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT
					)
		FROM	#tmpUpdateItemLocationForCStore_itemLocationAuditLog 
		WHERE	ISNULL(ysnScaleItem_Original, 0) <> ISNULL(ysnScaleItem_New, 0)	

		UNION ALL
		SELECT	intItemLocationId
				, strJsonData = 
					dbo.fnFormatMessage(
						@json1
						, CAST(intItemLocationId AS NVARCHAR(20)) 
						, dbo.fnFormatMessage(
							@json2_int
							, 'C-Store updates the Food Stampable'
							, ysnFoodStampable_Original
							, ysnFoodStampable_New
							, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT
						) 
						, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT
					)
		FROM	#tmpUpdateItemLocationForCStore_itemLocationAuditLog 
		WHERE	ISNULL(ysnFoodStampable_Original, 0) <> ISNULL(ysnFoodStampable_New, 0)	

		UNION ALL
		SELECT	intItemLocationId
				, strJsonData = 
					dbo.fnFormatMessage(
						@json1
						, CAST(intItemLocationId AS NVARCHAR(20)) 
						, dbo.fnFormatMessage(
							@json2_int
							, 'C-Store updates the Returnable'
							, ysnReturnable_Original
							, ysnReturnable_New
							, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT
						) 
						, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT
					)
		FROM	#tmpUpdateItemLocationForCStore_itemLocationAuditLog 
		WHERE	ISNULL(ysnReturnable_Original, 0) <> ISNULL(ysnReturnable_New, 0)	

		UNION ALL
		SELECT	intItemLocationId
				, strJsonData = 
					dbo.fnFormatMessage(
						@json1
						, CAST(intItemLocationId AS NVARCHAR(20)) 
						, dbo.fnFormatMessage(
							@json2_int
							, 'C-Store updates the Saleable'
							, ysnSaleable_Original
							, ysnSaleable_New
							, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT
						) 
						, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT
					)
		FROM	#tmpUpdateItemLocationForCStore_itemLocationAuditLog 
		WHERE	ISNULL(ysnSaleable_Original, 0) <> ISNULL(ysnSaleable_New, 0)	

		UNION ALL
		SELECT	intItemLocationId
				, strJsonData = 
					dbo.fnFormatMessage(
						@json1
						, CAST(intItemLocationId AS NVARCHAR(20)) 
						, dbo.fnFormatMessage(
							@json2_int
							, 'C-Store updates the Required Liquor'
							, ysnIdRequiredLiquor_Original
							, ysnIdRequiredLiquor_New
							, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT
						) 
						, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT
					)
		FROM	#tmpUpdateItemLocationForCStore_itemLocationAuditLog 
		WHERE	ISNULL(ysnIdRequiredLiquor_Original, 0) <> ISNULL(ysnIdRequiredLiquor_New, 0)	

		UNION ALL
		SELECT	intItemLocationId
				, strJsonData = 
					dbo.fnFormatMessage(
						@json1
						, CAST(intItemLocationId AS NVARCHAR(20)) 
						, dbo.fnFormatMessage(
							@json2_int
							, 'C-Store updates the Required Cigarette'
							, ysnIdRequiredCigarette_Original
							, ysnIdRequiredCigarette_New
							, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT
						) 
						, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT
					)
		FROM	#tmpUpdateItemLocationForCStore_itemLocationAuditLog 
		WHERE	ISNULL(ysnIdRequiredCigarette_Original, 0) <> ISNULL(ysnIdRequiredCigarette_New, 0)	

		UNION ALL
		SELECT	intItemLocationId
				, strJsonData = 
					dbo.fnFormatMessage(
						@json1
						, CAST(intItemLocationId AS NVARCHAR(20)) 
						, dbo.fnFormatMessage(
							@json2_int
							, 'C-Store updates the Promotional Item'
							, ysnPromotionalItem_Original
							, ysnPromotionalItem_New
							, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT
						) 
						, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT
					)
		FROM	#tmpUpdateItemLocationForCStore_itemLocationAuditLog 
		WHERE	ISNULL(ysnPromotionalItem_Original, 0) <> ISNULL(ysnPromotionalItem_New, 0)	

		UNION ALL
		SELECT	intItemLocationId
				, strJsonData = 
					dbo.fnFormatMessage(
						@json1
						, CAST(intItemLocationId AS NVARCHAR(20)) 
						, dbo.fnFormatMessage(
							@json2_int
							, 'C-Store updates the Pre Priced'
							, ysnPrePriced_Original
							, ysnPrePriced_New
							, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT
						) 
						, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT
					)
		FROM	#tmpUpdateItemLocationForCStore_itemLocationAuditLog 
		WHERE	ISNULL(ysnPrePriced_Original, 0) <> ISNULL(ysnPrePriced_New, 0)	
	
		UNION ALL
		SELECT	intItemLocationId
				, strJsonData = 
					dbo.fnFormatMessage(
						@json1
						, CAST(intItemLocationId AS NVARCHAR(20)) 
						, dbo.fnFormatMessage(
							@json2_int
							, 'C-Store updates the Apply Blue Law 1'
							, ysnApplyBlueLaw1_Original
							, ysnApplyBlueLaw1_New
							, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT
						) 
						, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT
					)
		FROM	#tmpUpdateItemLocationForCStore_itemLocationAuditLog 
		WHERE	ISNULL(ysnApplyBlueLaw1_Original, 0) <> ISNULL(ysnApplyBlueLaw1_New, 0)	

		UNION ALL
		SELECT	intItemLocationId
				, strJsonData = 
					dbo.fnFormatMessage(
						@json1
						, CAST(intItemLocationId AS NVARCHAR(20)) 
						, dbo.fnFormatMessage(
							@json2_int
							, 'C-Store updates the Apply Blue Law 2'
							, ysnApplyBlueLaw2_Original
							, ysnApplyBlueLaw2_New
							, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT
						) 
						, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT
					)
		FROM	#tmpUpdateItemLocationForCStore_itemLocationAuditLog 
		WHERE	ISNULL(ysnApplyBlueLaw2_Original, 0) <> ISNULL(ysnApplyBlueLaw2_New, 0)	

		UNION ALL
		SELECT	intItemLocationId
				, strJsonData = 
					dbo.fnFormatMessage(
						@json1
						, CAST(intItemLocationId AS NVARCHAR(20)) 
						, dbo.fnFormatMessage(
							@json2_int
							, 'C-Store updates the Counted Daily'
							, ysnCountedDaily_Original
							, ysnCountedDaily_New
							, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT
						) 
						, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT
					)
		FROM	#tmpUpdateItemLocationForCStore_itemLocationAuditLog 
		WHERE	ISNULL(ysnCountedDaily_Original, 0) <> ISNULL(ysnCountedDaily_New, 0)	

		UNION ALL
		SELECT	intItemLocationId
				, strJsonData = 
					dbo.fnFormatMessage(
						@json1
						, CAST(intItemLocationId AS NVARCHAR(20)) 
						, dbo.fnFormatMessage(
							@json2_string
							, 'C-Store updates Counted'
							, strCounted_Original
							, strCounted_New
							, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT
						) 
						, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT
					)
		FROM	#tmpUpdateItemLocationForCStore_itemLocationAuditLog 
		WHERE	ISNULL(strCounted_Original, '') <> ISNULL(strCounted_New, '')	

		UNION ALL
		SELECT	intItemLocationId
				, strJsonData = 
					dbo.fnFormatMessage(
						@json1
						, CAST(intItemLocationId AS NVARCHAR(20)) 
						, dbo.fnFormatMessage(
							@json2_int
							, 'C-Store updates the Count By Serial No.'
							, ysnCountBySINo_Original
							, ysnCountBySINo_New
							, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT
						) 
						, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT
					)
		FROM	#tmpUpdateItemLocationForCStore_itemLocationAuditLog 
		WHERE	ISNULL(ysnCountBySINo_Original, 0) <> ISNULL(ysnCountBySINo_New, 0)	

		UNION ALL
		SELECT	intItemLocationId
				, strJsonData = 
					dbo.fnFormatMessage(
						@json1
						, CAST(intItemLocationId AS NVARCHAR(20)) 
						, dbo.fnFormatMessage(
							@json2_int
							, 'C-Store updates the Family Id'
							, intFamilyId_Original
							, intFamilyId_New
							, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT
						) 
						, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT
					)
		FROM	#tmpUpdateItemLocationForCStore_itemLocationAuditLog 
		WHERE	ISNULL(intFamilyId_Original, 0) <> ISNULL(intFamilyId_New, 0)	

		UNION ALL
		SELECT	intItemLocationId
				, strJsonData = 
					dbo.fnFormatMessage(
						@json1
						, CAST(intItemLocationId AS NVARCHAR(20)) 
						, dbo.fnFormatMessage(
							@json2_int
							, 'C-Store updates the Class Id'
							, intClassId_Original
							, intClassId_New
							, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT
						) 
						, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT
					)
		FROM	#tmpUpdateItemLocationForCStore_itemLocationAuditLog 
		WHERE	ISNULL(intClassId_Original, 0) <> ISNULL(intClassId_New, 0)

		UNION ALL
		SELECT	intItemLocationId
				, strJsonData = 
					dbo.fnFormatMessage(
						@json1
						, CAST(intItemLocationId AS NVARCHAR(20)) 
						, dbo.fnFormatMessage(
							@json2_int
							, 'C-Store updates the Product Code Id'
							, intProductCodeId_Original
							, intProductCodeId_New
							, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT
						) 
						, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT
					)
		FROM	#tmpUpdateItemLocationForCStore_itemLocationAuditLog 
		WHERE	ISNULL(intProductCodeId_Original, 0) <> ISNULL(intProductCodeId_New, 0)

		UNION ALL
		SELECT	intItemLocationId
				, strJsonData = 
					dbo.fnFormatMessage(
						@json1
						, CAST(intItemLocationId AS NVARCHAR(20)) 
						, dbo.fnFormatMessage(
							@json2_string
							, 'C-Store updates the Vendor Id'
							, vendor_Original.strVendorId
							, vendor_New.strVendorId
							, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT
						) 
						, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT
					)
		FROM	#tmpUpdateItemLocationForCStore_itemLocationAuditLog auditLog 
				LEFT JOIN tblAPVendor vendor_Original
					ON auditLog.intVendorId_Original = vendor_Original.intEntityId 
				LEFT JOIN tblAPVendor vendor_New
					ON auditLog.intVendorId_New = vendor_New.intEntityId 
		WHERE	ISNULL(intVendorId_Original, 0) <> ISNULL(intVendorId_New, 0)

		UNION ALL
		SELECT	intItemLocationId
				, strJsonData = 
					dbo.fnFormatMessage(
						@json1
						, CAST(intItemLocationId AS NVARCHAR(20)) 
						, dbo.fnFormatMessage(
							@json2_int
							, 'C-Store updates the Minimum Age'
							, intMinimumAge_Original
							, intMinimumAge_New
							, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT
						) 
						, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT
					)
		FROM	#tmpUpdateItemLocationForCStore_itemLocationAuditLog 
		WHERE	ISNULL(intMinimumAge_Original, 0) <> ISNULL(intMinimumAge_New, 0)

		UNION ALL
		SELECT	intItemLocationId
				, strJsonData = 
					dbo.fnFormatMessage(
						@json1
						, CAST(intItemLocationId AS NVARCHAR(20)) 
						, dbo.fnFormatMessage(
							@json2_float
							, 'C-Store updates the Minimum Order'
							, dblMinOrder_Original
							, dblMinOrder_New
							, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT
						) 
						, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT
					)
		FROM	#tmpUpdateItemLocationForCStore_itemLocationAuditLog 
		WHERE	ISNULL(dblMinOrder_Original, 0) <> ISNULL(dblMinOrder_New, 0)

		UNION ALL
		SELECT	intItemLocationId
				, strJsonData = 
					dbo.fnFormatMessage(
						@json1
						, CAST(intItemLocationId AS NVARCHAR(20)) 
						, dbo.fnFormatMessage(
							@json2_float
							, 'C-Store updates the Suggested Qty'
							, dblSuggestedQty_Original
							, dblSuggestedQty_New
							, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT
						) 
						, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT
					)
		FROM	#tmpUpdateItemLocationForCStore_itemLocationAuditLog 
		WHERE	ISNULL(dblSuggestedQty_Original, 0) <> ISNULL(dblSuggestedQty_New, 0)

		UNION ALL
		SELECT	intItemLocationId
				, strJsonData = 
					dbo.fnFormatMessage(
						@json1
						, CAST(intItemLocationId AS NVARCHAR(20)) 
						, dbo.fnFormatMessage(
							@json2_int
							, 'C-Store updates the Suggested Qty'
							, intCountGroupId_Original
							, intCountGroupId_New
							, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT
						) 
						, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT
					)
		FROM	#tmpUpdateItemLocationForCStore_itemLocationAuditLog 
		WHERE	ISNULL(intCountGroupId_Original, 0) <> ISNULL(intCountGroupId_New, 0)

		UNION ALL
		SELECT	intItemLocationId
				, strJsonData = 
					dbo.fnFormatMessage(
						@json1
						, CAST(intItemLocationId AS NVARCHAR(20)) 
						, dbo.fnFormatMessage(
							@json2_int
							, 'C-Store updates the Storage Location Id'
							, intStorageLocationId_Original
							, intStorageLocationId_New
							, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT
						) 
						, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT
					)
		FROM	#tmpUpdateItemLocationForCStore_itemLocationAuditLog 
		WHERE	ISNULL(intStorageLocationId_Original, 0) <> ISNULL(intStorageLocationId_New, 0)

		UNION ALL
		SELECT	intItemLocationId
				, strJsonData = 
					dbo.fnFormatMessage(
						@json1
						, CAST(intItemLocationId AS NVARCHAR(20)) 
						, dbo.fnFormatMessage(
							@json2_float
							, 'C-Store updates the Reorder Point'
							, dblReorderPoint_Original
							, dblReorderPoint_New
							, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT
						) 
						, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT
					)
		FROM	#tmpUpdateItemLocationForCStore_itemLocationAuditLog 
		WHERE	ISNULL(dblReorderPoint_Original, 0) <> ISNULL(dblReorderPoint_New, 0)

		UNION ALL
		SELECT	intItemLocationId
				, strJsonData = 
					dbo.fnFormatMessage(
						@json1
						, CAST(intItemLocationId AS NVARCHAR(20)) 
						, dbo.fnFormatMessage(
							@json2_string
							, 'C-Store updates the Description'
							, strDescription_Original
							, strDescription_New
							, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT
						) 
						, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT
					)
		FROM	#tmpUpdateItemLocationForCStore_itemLocationAuditLog 
		WHERE	ISNULL(strDescription_Original, '') <> ISNULL(strDescription_New, '')


	) auditLog
	WHERE auditLog.strJsonData IS NOT NULL 
END 