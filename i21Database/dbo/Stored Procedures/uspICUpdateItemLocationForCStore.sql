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
	,@strStorageUnitNo NVARCHAR(1000) = NULL
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
SET ANSI_WARNINGS ON

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
		,strStorageUnitNo_Original NVARCHAR(1000) NULL
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
		,strStorageUnitNo_New NVARCHAR(1000) NULL
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
		, strStorageUnitNo_Original
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
		, strStorageUnitNo_New
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
			, [Changes].strStorageUnitNo_Original
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
			, [Changes].strStorageUnitNo_New
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
						SELECT	
								DISTINCT itemLocation.intItemLocationId
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
							,intFamilyId = CASE WHEN @intFamilyId = 0
													THEN NULL
												ELSE 
													ISNULL(@intFamilyId, itemLocation.intFamilyId) 
												END
							,intClassId = CASE WHEN @intClassId = 0	
													THEN NULL
												ELSE 
													ISNULL(@intClassId, itemLocation.intClassId) 
												END
							,intProductCodeId = ISNULL(@intProductCodeId, itemLocation.intProductCodeId) 
							,intVendorId = CASE WHEN @intVendorId = 0	
													THEN NULL
												ELSE 
													ISNULL(@intVendorId, itemLocation.intVendorId) 
												END
							,intMinimumAge = ISNULL(@intMinimumAge, itemLocation.intMinimumAge) 
							,dblMinOrder = ISNULL(@dblMinOrder, itemLocation.dblMinOrder) 
							,dblSuggestedQty = ISNULL(@dblSuggestedQty, itemLocation.dblSuggestedQty) 
							,strStorageUnitNo = ISNULL(@strStorageUnitNo, itemLocation.strStorageUnitNo) 
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
						, deleted.strStorageUnitNo
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
						, inserted.strStorageUnitNo
						, inserted.intCountGroupId
						, inserted.intStorageLocationId
						, inserted.dblReorderPoint
						, inserted.strDescription
			) AS [Changes] (
				action
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
				, strStorageUnitNo_Original
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
				, strStorageUnitNo_New
				, intCountGroupId_New
				, intStorageLocationId_New
				, dblReorderPoint_New
				, strDescription_New
			)
	WHERE	[Changes].action = 'UPDATE'
	;
END

IF EXISTS (SELECT TOP 1 1 FROM #tmpUpdateItemLocationForCStore_itemLocationAuditLog)
BEGIN 
	DECLARE @auditLog_strDescription AS NVARCHAR(255) 
			,@auditLog_actionType AS NVARCHAR(50) = 'Updated'

	DECLARE 
		@auditLog_intItemId INT
		,@auditLog_intItemLocationId INT 
		-- Original Fields
		,@auditLog_ysnTaxFlag1_Original BIT
		,@auditLog_ysnTaxFlag2_Original BIT
		,@auditLog_ysnTaxFlag3_Original BIT
		,@auditLog_ysnTaxFlag4_Original BIT
		,@auditLog_ysnDepositRequired_Original BIT
		,@auditLog_intDepositPLUId_Original INT
		,@auditLog_ysnQuantityRequired_Original BIT 
		,@auditLog_ysnScaleItem_Original BIT 
		,@auditLog_ysnFoodStampable_Original BIT 
		,@auditLog_ysnReturnable_Original BIT 
		,@auditLog_ysnSaleable_Original BIT 
		,@auditLog_ysnIdRequiredLiquor_Original BIT
		,@auditLog_ysnIdRequiredCigarette_Original BIT 
		,@auditLog_ysnPromotionalItem_Original BIT
		,@auditLog_ysnPrePriced_Original BIT
		,@auditLog_ysnApplyBlueLaw1_Original BIT
		,@auditLog_ysnApplyBlueLaw2_Original BIT
		,@auditLog_ysnCountedDaily_Original BIT
		,@auditLog_strCounted_Original NVARCHAR(50)
		,@auditLog_ysnCountBySINo_Original BIT
		,@auditLog_intFamilyId_Original INT
		,@auditLog_intClassId_Original INT
		,@auditLog_intProductCodeId_Original INT
		,@auditLog_intVendorId_Original INT
		,@auditLog_intMinimumAge_Original INT
		,@auditLog_dblMinOrder_Original NUMERIC(18, 6)
		,@auditLog_dblSuggestedQty_Original NUMERIC(18, 6)
		,@auditLog_strStorageUnitNo_Original NVARCHAR(1000)
		,@auditLog_intCountGroupId_Original INT
		,@auditLog_intStorageLocationId_Original INT
		,@auditLog_dblReorderPoint_Original NUMERIC(18, 6)
		,@auditLog_strDescription_Original NVARCHAR(1000)
		-- Modified Fields
		,@auditLog_ysnTaxFlag1_New BIT
		,@auditLog_ysnTaxFlag2_New BIT
		,@auditLog_ysnTaxFlag3_New BIT
		,@auditLog_ysnTaxFlag4_New BIT
		,@auditLog_ysnDepositRequired_New BIT
		,@auditLog_intDepositPLUId_New INT
		,@auditLog_ysnQuantityRequired_New BIT
		,@auditLog_ysnScaleItem_New BIT
		,@auditLog_ysnFoodStampable_New BIT
		,@auditLog_ysnReturnable_New BIT
		,@auditLog_ysnSaleable_New BIT
		,@auditLog_ysnIdRequiredLiquor_New BIT
		,@auditLog_ysnIdRequiredCigarette_New BIT
		,@auditLog_ysnPromotionalItem_New BIT
		,@auditLog_ysnPrePriced_New BIT
		,@auditLog_ysnApplyBlueLaw1_New BIT
		,@auditLog_ysnApplyBlueLaw2_New BIT
		,@auditLog_ysnCountedDaily_New BIT
		,@auditLog_strCounted_New NVARCHAR(50)
		,@auditLog_ysnCountBySINo_New BIT
		,@auditLog_intFamilyId_New INT
		,@auditLog_intClassId_New INT
		,@auditLog_intProductCodeId_New INT
		,@auditLog_intVendorId_New INT
		,@auditLog_intMinimumAge_New INT 
		,@auditLog_dblMinOrder_New NUMERIC(18, 6)
		,@auditLog_dblSuggestedQty_New NUMERIC(18, 6)
		,@auditLog_strStorageUnitNo_New NVARCHAR(1000)
		,@auditLog_intCountGroupId_New INT
		,@auditLog_intStorageLocationId_New INT
		,@auditLog_dblReorderPoint_New NUMERIC(18, 6)
		,@auditLog_strDescription_New NVARCHAR(1000)


	DECLARE loopAuditLog CURSOR LOCAL FAST_FORWARD
	FOR 	
	SELECT	
			intItemId
			,intItemLocationId
			-- Original Fields
			,ysnTaxFlag1_Original
			,ysnTaxFlag2_Original
			,ysnTaxFlag3_Original
			,ysnTaxFlag4_Original
			,ysnDepositRequired_Original
			,intDepositPLUId_Original
			,ysnQuantityRequired_Original
			,ysnScaleItem_Original
			,ysnFoodStampable_Original
			,ysnReturnable_Original
			,ysnSaleable_Original
			,ysnIdRequiredLiquor_Original
			,ysnIdRequiredCigarette_Original
			,ysnPromotionalItem_Original
			,ysnPrePriced_Original
			,ysnApplyBlueLaw1_Original
			,ysnApplyBlueLaw2_Original
			,ysnCountedDaily_Original
			,strCounted_Original
			,ysnCountBySINo_Original
			,intFamilyId_Original
			,intClassId_Original
			,intProductCodeId_Original
			,intVendorId_Original
			,intMinimumAge_Original 
			,dblMinOrder_Original 
			,dblSuggestedQty_Original 
			,strStorageUnitNo_Original 
			,intCountGroupId_Original 
			,intStorageLocationId_Original 
			,dblReorderPoint_Original 
			,strDescription_Original 
			-- Modified Fields
			,ysnTaxFlag1_New 
			,ysnTaxFlag2_New
			,ysnTaxFlag3_New
			,ysnTaxFlag4_New
			,ysnDepositRequired_New
			,intDepositPLUId_New 
			,ysnQuantityRequired_New 
			,ysnScaleItem_New 
			,ysnFoodStampable_New 
			,ysnReturnable_New 
			,ysnSaleable_New 
			,ysnIdRequiredLiquor_New 
			,ysnIdRequiredCigarette_New 
			,ysnPromotionalItem_New 
			,ysnPrePriced_New 
			,ysnApplyBlueLaw1_New 
			,ysnApplyBlueLaw2_New 
			,ysnCountedDaily_New 
			,strCounted_New 
			,ysnCountBySINo_New 
			,intFamilyId_New 
			,intClassId_New 
			,intProductCodeId_New 
			,intVendorId_New 
			,intMinimumAge_New 
			,dblMinOrder_New 
			,dblSuggestedQty_New 
			,strStorageUnitNo_New 
			,intCountGroupId_New 
			,intStorageLocationId_New 
			,dblReorderPoint_New 
			,strDescription_New 
	FROM	#tmpUpdateItemLocationForCStore_itemLocationAuditLog 

	OPEN loopAuditLog;

	FETCH NEXT FROM loopAuditLog INTO 
		@auditLog_intItemId 
		,@auditLog_intItemLocationId 
		-- Original Fields
		,@auditLog_ysnTaxFlag1_Original 
		,@auditLog_ysnTaxFlag2_Original 
		,@auditLog_ysnTaxFlag3_Original 
		,@auditLog_ysnTaxFlag4_Original 
		,@auditLog_ysnDepositRequired_Original 
		,@auditLog_intDepositPLUId_Original 
		,@auditLog_ysnQuantityRequired_Original 
		,@auditLog_ysnScaleItem_Original 
		,@auditLog_ysnFoodStampable_Original 
		,@auditLog_ysnReturnable_Original 
		,@auditLog_ysnSaleable_Original 
		,@auditLog_ysnIdRequiredLiquor_Original 
		,@auditLog_ysnIdRequiredCigarette_Original 
		,@auditLog_ysnPromotionalItem_Original 
		,@auditLog_ysnPrePriced_Original 
		,@auditLog_ysnApplyBlueLaw1_Original 
		,@auditLog_ysnApplyBlueLaw2_Original 
		,@auditLog_ysnCountedDaily_Original 
		,@auditLog_strCounted_Original 
		,@auditLog_ysnCountBySINo_Original 
		,@auditLog_intFamilyId_Original 
		,@auditLog_intClassId_Original 
		,@auditLog_intProductCodeId_Original 
		,@auditLog_intVendorId_Original 
		,@auditLog_intMinimumAge_Original 
		,@auditLog_dblMinOrder_Original 
		,@auditLog_dblSuggestedQty_Original 
		,@auditLog_strStorageUnitNo_Original 
		,@auditLog_intCountGroupId_Original 
		,@auditLog_intStorageLocationId_Original 
		,@auditLog_dblReorderPoint_Original 
		,@auditLog_strDescription_Original 
		-- Modified Fields
		,@auditLog_ysnTaxFlag1_New 
		,@auditLog_ysnTaxFlag2_New 
		,@auditLog_ysnTaxFlag3_New 
		,@auditLog_ysnTaxFlag4_New 
		,@auditLog_ysnDepositRequired_New 
		,@auditLog_intDepositPLUId_New 
		,@auditLog_ysnQuantityRequired_New 
		,@auditLog_ysnScaleItem_New 
		,@auditLog_ysnFoodStampable_New 
		,@auditLog_ysnReturnable_New 
		,@auditLog_ysnSaleable_New 
		,@auditLog_ysnIdRequiredLiquor_New 
		,@auditLog_ysnIdRequiredCigarette_New 
		,@auditLog_ysnPromotionalItem_New 
		,@auditLog_ysnPrePriced_New 
		,@auditLog_ysnApplyBlueLaw1_New 
		,@auditLog_ysnApplyBlueLaw2_New 
		,@auditLog_ysnCountedDaily_New 
		,@auditLog_strCounted_New 
		,@auditLog_ysnCountBySINo_New 
		,@auditLog_intFamilyId_New 
		,@auditLog_intClassId_New 
		,@auditLog_intProductCodeId_New 
		,@auditLog_intVendorId_New 
		,@auditLog_intMinimumAge_New 
		,@auditLog_dblMinOrder_New 
		,@auditLog_dblSuggestedQty_New 
		,@auditLog_strStorageUnitNo_New 
		,@auditLog_intCountGroupId_New 
		,@auditLog_intStorageLocationId_New 
		,@auditLog_dblReorderPoint_New 
		,@auditLog_strDescription_New 
	;
	WHILE @@FETCH_STATUS = 0
	BEGIN 
		IF ISNULL(@auditLog_ysnTaxFlag1_Original, 0) <> ISNULL(@auditLog_ysnTaxFlag1_New, 0)
		BEGIN 
			EXEC dbo.uspSMAuditLog 
				@keyValue = @auditLog_intItemLocationId
				,@screenName = 'Inventory.view.ItemLocation'
				,@entityId = @intEntityUserSecurityId
				,@actionType = @auditLog_actionType
				,@changeDescription = 'C-Store updates the Tax Flag 1'
				,@fromValue = @auditLog_ysnTaxFlag1_Original
				,@toValue = @auditLog_ysnTaxFlag1_New
		END

		IF ISNULL(@auditLog_ysnTaxFlag2_Original, 0) <> ISNULL(@auditLog_ysnTaxFlag2_New, 0)
		BEGIN 
			EXEC dbo.uspSMAuditLog 
				@keyValue = @auditLog_intItemLocationId
				,@screenName = 'Inventory.view.ItemLocation'
				,@entityId = @intEntityUserSecurityId
				,@actionType = @auditLog_actionType
				,@changeDescription = 'C-Store updates the Tax Flag 2'
				,@fromValue = @auditLog_ysnTaxFlag2_Original
				,@toValue = @auditLog_ysnTaxFlag2_New
		END

		IF ISNULL(@auditLog_ysnTaxFlag3_Original, 0) <> ISNULL(@auditLog_ysnTaxFlag3_New, 0)
		BEGIN 
			EXEC dbo.uspSMAuditLog 
				@keyValue = @auditLog_intItemLocationId
				,@screenName = 'Inventory.view.ItemLocation'
				,@entityId = @intEntityUserSecurityId
				,@actionType = @auditLog_actionType
				,@changeDescription = 'C-Store updates the Tax Flag 3'
				,@fromValue = @auditLog_ysnTaxFlag3_Original
				,@toValue = @auditLog_ysnTaxFlag3_New
		END

		IF ISNULL(@auditLog_ysnTaxFlag4_Original, 0) <> ISNULL(@auditLog_ysnTaxFlag4_New, 0)
		BEGIN 
			EXEC dbo.uspSMAuditLog 
				@keyValue = @auditLog_intItemLocationId
				,@screenName = 'Inventory.view.ItemLocation'
				,@entityId = @intEntityUserSecurityId
				,@actionType = @auditLog_actionType
				,@changeDescription = 'C-Store updates the Tax Flag 4'
				,@fromValue = @auditLog_ysnTaxFlag4_Original
				,@toValue = @auditLog_ysnTaxFlag4_New
		END

		IF ISNULL(@auditLog_ysnDepositRequired_Original, 0) <> ISNULL(@auditLog_ysnDepositRequired_New, 0)
		BEGIN 
			EXEC dbo.uspSMAuditLog 
				@keyValue = @auditLog_intItemLocationId
				,@screenName = 'Inventory.view.ItemLocation'
				,@entityId = @intEntityUserSecurityId
				,@actionType = @auditLog_actionType
				,@changeDescription = 'C-Store updates the Deposit Required'
				,@fromValue = @auditLog_ysnDepositRequired_Original
				,@toValue = @auditLog_ysnDepositRequired_New
		END

		IF ISNULL(@auditLog_intDepositPLUId_Original, 0) <> ISNULL(@auditLog_intDepositPLUId_New, 0)
		BEGIN 
			EXEC dbo.uspSMAuditLog 
				@keyValue = @auditLog_intItemLocationId
				,@screenName = 'Inventory.view.ItemLocation'
				,@entityId = @intEntityUserSecurityId
				,@actionType = @auditLog_actionType
				,@changeDescription = 'C-Store updates the Deposit PLU Id'
				,@fromValue = @auditLog_intDepositPLUId_Original
				,@toValue = @auditLog_intDepositPLUId_New
		END

		IF ISNULL(@auditLog_ysnQuantityRequired_Original, 0) <> ISNULL(@auditLog_ysnQuantityRequired_New, 0)
		BEGIN 
			EXEC dbo.uspSMAuditLog 
				@keyValue = @auditLog_intItemLocationId
				,@screenName = 'Inventory.view.ItemLocation'
				,@entityId = @intEntityUserSecurityId
				,@actionType = @auditLog_actionType
				,@changeDescription = 'C-Store updates the Quantity Required'
				,@fromValue = @auditLog_ysnQuantityRequired_Original
				,@toValue = @auditLog_ysnQuantityRequired_New
		END

		IF ISNULL(@auditLog_ysnScaleItem_Original, 0) <> ISNULL(@auditLog_ysnScaleItem_New, 0)
		BEGIN 
			EXEC dbo.uspSMAuditLog 
				@keyValue = @auditLog_intItemLocationId
				,@screenName = 'Inventory.view.ItemLocation'
				,@entityId = @intEntityUserSecurityId
				,@actionType = @auditLog_actionType
				,@changeDescription = 'C-Store updates the Scale Item'
				,@fromValue = @auditLog_ysnScaleItem_Original
				,@toValue = @auditLog_ysnScaleItem_New
		END

		IF ISNULL(@auditLog_ysnFoodStampable_Original, 0) <> ISNULL(@auditLog_ysnFoodStampable_New, 0)
		BEGIN 
			EXEC dbo.uspSMAuditLog 
				@keyValue = @auditLog_intItemLocationId
				,@screenName = 'Inventory.view.ItemLocation'
				,@entityId = @intEntityUserSecurityId
				,@actionType = @auditLog_actionType
				,@changeDescription = 'C-Store updates the Food Stampable'
				,@fromValue = @auditLog_ysnFoodStampable_Original
				,@toValue = @auditLog_ysnFoodStampable_New
		END

		IF ISNULL(@auditLog_ysnReturnable_Original, 0) <> ISNULL(@auditLog_ysnReturnable_New, 0)
		BEGIN 
			EXEC dbo.uspSMAuditLog 
				@keyValue = @auditLog_intItemLocationId
				,@screenName = 'Inventory.view.ItemLocation'
				,@entityId = @intEntityUserSecurityId
				,@actionType = @auditLog_actionType
				,@changeDescription = 'C-Store updates the Returnable'
				,@fromValue = @auditLog_ysnReturnable_Original
				,@toValue = @auditLog_ysnReturnable_New
		END

		IF ISNULL(@auditLog_ysnSaleable_Original, 0) <> ISNULL(@auditLog_ysnSaleable_New, 0)
		BEGIN 
			EXEC dbo.uspSMAuditLog 
				@keyValue = @auditLog_intItemLocationId
				,@screenName = 'Inventory.view.ItemLocation'
				,@entityId = @intEntityUserSecurityId
				,@actionType = @auditLog_actionType
				,@changeDescription = 'C-Store updates the Saleable'
				,@fromValue = @auditLog_ysnSaleable_Original
				,@toValue = @auditLog_ysnSaleable_New
		END

		IF ISNULL(@auditLog_ysnIdRequiredLiquor_Original, 0) <> ISNULL(@auditLog_ysnIdRequiredLiquor_New, 0)
		BEGIN 
			EXEC dbo.uspSMAuditLog 
				@keyValue = @auditLog_intItemLocationId
				,@screenName = 'Inventory.view.ItemLocation'
				,@entityId = @intEntityUserSecurityId
				,@actionType = @auditLog_actionType
				,@changeDescription = 'C-Store updates the Required Liquor'
				,@fromValue = @auditLog_ysnIdRequiredLiquor_Original
				,@toValue = @auditLog_ysnIdRequiredLiquor_New
		END


		IF ISNULL(@auditLog_ysnIdRequiredCigarette_Original, 0) <> ISNULL(@auditLog_ysnIdRequiredCigarette_New, 0)
		BEGIN 
			EXEC dbo.uspSMAuditLog 
				@keyValue = @auditLog_intItemLocationId
				,@screenName = 'Inventory.view.ItemLocation'
				,@entityId = @intEntityUserSecurityId
				,@actionType = @auditLog_actionType
				,@changeDescription = 'C-Store updates the Required Cigarette'
				,@fromValue = @auditLog_ysnIdRequiredCigarette_Original
				,@toValue = @auditLog_ysnIdRequiredCigarette_New
		END

		IF ISNULL(@auditLog_ysnPromotionalItem_Original, 0) <> ISNULL(@auditLog_ysnPromotionalItem_New, 0)
		BEGIN 
			EXEC dbo.uspSMAuditLog 
				@keyValue = @auditLog_intItemLocationId
				,@screenName = 'Inventory.view.ItemLocation'
				,@entityId = @intEntityUserSecurityId
				,@actionType = @auditLog_actionType
				,@changeDescription = 'C-Store updates the Promotional Item'
				,@fromValue = @auditLog_ysnPromotionalItem_Original
				,@toValue = @auditLog_ysnPromotionalItem_New
		END

		IF ISNULL(@auditLog_ysnPrePriced_Original, 0) <> ISNULL(@auditLog_ysnPrePriced_New, 0)
		BEGIN 
			EXEC dbo.uspSMAuditLog 
				@keyValue = @auditLog_intItemLocationId
				,@screenName = 'Inventory.view.ItemLocation'
				,@entityId = @intEntityUserSecurityId
				,@actionType = @auditLog_actionType
				,@changeDescription = 'C-Store updates the Pre Priced'
				,@fromValue = @auditLog_ysnPrePriced_Original
				,@toValue = @auditLog_ysnPrePriced_New
		END

		IF ISNULL(@auditLog_ysnApplyBlueLaw1_Original, 0) <> ISNULL(@auditLog_ysnApplyBlueLaw1_New, 0)
		BEGIN 
			EXEC dbo.uspSMAuditLog 
				@keyValue = @auditLog_intItemLocationId
				,@screenName = 'Inventory.view.ItemLocation'
				,@entityId = @intEntityUserSecurityId
				,@actionType = @auditLog_actionType
				,@changeDescription = 'C-Store updates the Apply Blue Law 1'
				,@fromValue = @auditLog_ysnApplyBlueLaw1_Original
				,@toValue = @auditLog_ysnApplyBlueLaw1_New
		END

		IF ISNULL(@auditLog_ysnApplyBlueLaw2_Original, 0) <> ISNULL(@auditLog_ysnApplyBlueLaw2_New, 0)
		BEGIN 
			EXEC dbo.uspSMAuditLog 
				@keyValue = @auditLog_intItemLocationId
				,@screenName = 'Inventory.view.ItemLocation'
				,@entityId = @intEntityUserSecurityId
				,@actionType = @auditLog_actionType
				,@changeDescription = 'C-Store updates the Apply Blue Law 2'
				,@fromValue = @auditLog_ysnApplyBlueLaw2_Original
				,@toValue = @auditLog_ysnApplyBlueLaw2_New
		END

		IF ISNULL(@auditLog_ysnCountedDaily_Original, 0) <> ISNULL(@auditLog_ysnCountedDaily_New, 0)
		BEGIN 
			EXEC dbo.uspSMAuditLog 
				@keyValue = @auditLog_intItemLocationId
				,@screenName = 'Inventory.view.ItemLocation'
				,@entityId = @intEntityUserSecurityId
				,@actionType = @auditLog_actionType
				,@changeDescription = 'C-Store updates the Counted Daily'
				,@fromValue = @auditLog_ysnCountedDaily_Original
				,@toValue = @auditLog_ysnCountedDaily_New
		END

		IF ISNULL(@auditLog_strCounted_Original, 0) <> ISNULL(@auditLog_strCounted_New, 0)
		BEGIN 
			EXEC dbo.uspSMAuditLog 
				@keyValue = @auditLog_intItemLocationId
				,@screenName = 'Inventory.view.ItemLocation'
				,@entityId = @intEntityUserSecurityId
				,@actionType = @auditLog_actionType
				,@changeDescription = 'C-Store updates the Counted'
				,@fromValue = @auditLog_strCounted_Original
				,@toValue = @auditLog_strCounted_New
		END


		IF ISNULL(@auditLog_ysnCountBySINo_Original, 0) <> ISNULL(@auditLog_ysnCountBySINo_New, 0)
		BEGIN 
			EXEC dbo.uspSMAuditLog 
				@keyValue = @auditLog_intItemLocationId
				,@screenName = 'Inventory.view.ItemLocation'
				,@entityId = @intEntityUserSecurityId
				,@actionType = @auditLog_actionType
				,@changeDescription = 'C-Store updates the Count By Serial No.'
				,@fromValue = @auditLog_ysnCountBySINo_Original
				,@toValue = @auditLog_ysnCountBySINo_New
		END

		IF ISNULL(@auditLog_intFamilyId_Original, 0) <> ISNULL(@auditLog_intFamilyId_New, 0)
		BEGIN 
			EXEC dbo.uspSMAuditLog 
				@keyValue = @auditLog_intItemLocationId
				,@screenName = 'Inventory.view.ItemLocation'
				,@entityId = @intEntityUserSecurityId
				,@actionType = @auditLog_actionType
				,@changeDescription = 'C-Store updates the Family Id'
				,@fromValue = @auditLog_intFamilyId_Original
				,@toValue = @auditLog_intFamilyId_New
		END
		
		IF ISNULL(@auditLog_intClassId_Original, 0) <> ISNULL(@auditLog_intClassId_New, 0)
		BEGIN 
			EXEC dbo.uspSMAuditLog 
				@keyValue = @auditLog_intItemLocationId
				,@screenName = 'Inventory.view.ItemLocation'
				,@entityId = @intEntityUserSecurityId
				,@actionType = @auditLog_actionType
				,@changeDescription = 'C-Store updates the Class Id'
				,@fromValue = @auditLog_intClassId_Original
				,@toValue = @auditLog_intClassId_New
		END

		IF ISNULL(@auditLog_intProductCodeId_Original, 0) <> ISNULL(@auditLog_intProductCodeId_New, 0)
		BEGIN 
			EXEC dbo.uspSMAuditLog 
				@keyValue = @auditLog_intItemLocationId
				,@screenName = 'Inventory.view.ItemLocation'
				,@entityId = @intEntityUserSecurityId
				,@actionType = @auditLog_actionType
				,@changeDescription = 'C-Store updates the Product Code Id'
				,@fromValue = @auditLog_intProductCodeId_Original
				,@toValue = @auditLog_intProductCodeId_New
		END

		IF ISNULL(@auditLog_intVendorId_Original, 0) <> ISNULL(@auditLog_intVendorId_New, 0)
		BEGIN 
			EXEC dbo.uspSMAuditLog 
				@keyValue = @auditLog_intItemLocationId
				,@screenName = 'Inventory.view.ItemLocation'
				,@entityId = @intEntityUserSecurityId
				,@actionType = @auditLog_actionType
				,@changeDescription = 'C-Store updates the Vendor Id'
				,@fromValue = @auditLog_intVendorId_Original
				,@toValue = @auditLog_intVendorId_New
		END

		IF ISNULL(@auditLog_intMinimumAge_Original, 0) <> ISNULL(@auditLog_intMinimumAge_Original, 0)
		BEGIN 
			EXEC dbo.uspSMAuditLog 
				@keyValue = @auditLog_intItemLocationId
				,@screenName = 'Inventory.view.ItemLocation'
				,@entityId = @intEntityUserSecurityId
				,@actionType = @auditLog_actionType
				,@changeDescription = 'C-Store updates the Minimum Age'
				,@fromValue = @auditLog_intMinimumAge_Original
				,@toValue = @auditLog_intMinimumAge_New
		END

		IF ISNULL(@auditLog_dblMinOrder_Original, 0) <> ISNULL(@auditLog_dblMinOrder_New, 0)
		BEGIN 
			EXEC dbo.uspSMAuditLog 
				@keyValue = @auditLog_intItemLocationId
				,@screenName = 'Inventory.view.ItemLocation'
				,@entityId = @intEntityUserSecurityId
				,@actionType = @auditLog_actionType
				,@changeDescription = 'C-Store updates the Minimum Order'
				,@fromValue = @auditLog_dblMinOrder_Original
				,@toValue = @auditLog_dblMinOrder_New
		END

		IF ISNULL(@auditLog_dblSuggestedQty_Original, 0) <> ISNULL(@auditLog_dblSuggestedQty_New, 0)
		BEGIN 
			EXEC dbo.uspSMAuditLog 
				@keyValue = @auditLog_intItemLocationId
				,@screenName = 'Inventory.view.ItemLocation'
				,@entityId = @intEntityUserSecurityId
				,@actionType = @auditLog_actionType
				,@changeDescription = 'C-Store updates the Suggested Qty'
				,@fromValue = @auditLog_dblSuggestedQty_Original
				,@toValue = @auditLog_dblSuggestedQty_New
		END
		
		IF ISNULL(@auditLog_strStorageUnitNo_Original, 0) <> ISNULL(@auditLog_strStorageUnitNo_New, 0)
		BEGIN 
			EXEC dbo.uspSMAuditLog 
				@keyValue = @auditLog_intItemLocationId
				,@screenName = 'Inventory.view.ItemLocation'
				,@entityId = @intEntityUserSecurityId
				,@actionType = @auditLog_actionType
				,@changeDescription = 'C-Store updates the Storage Unit No'
				,@fromValue = @auditLog_strStorageUnitNo_Original
				,@toValue = @auditLog_strStorageUnitNo_New
		END

		IF ISNULL(@auditLog_intCountGroupId_Original, 0) <> ISNULL(@auditLog_intCountGroupId_New, 0)
		BEGIN 
			EXEC dbo.uspSMAuditLog 
				@keyValue = @auditLog_intItemLocationId
				,@screenName = 'Inventory.view.ItemLocation'
				,@entityId = @intEntityUserSecurityId
				,@actionType = @auditLog_actionType
				,@changeDescription = 'C-Store updates the Count Group Id'
				,@fromValue = @auditLog_intCountGroupId_Original
				,@toValue = @auditLog_intCountGroupId_New
		END
		
		IF ISNULL(@auditLog_intStorageLocationId_Original, 0) <> ISNULL(@auditLog_intStorageLocationId_New, 0)
		BEGIN 
			EXEC dbo.uspSMAuditLog 
				@keyValue = @auditLog_intItemLocationId
				,@screenName = 'Inventory.view.ItemLocation'
				,@entityId = @intEntityUserSecurityId
				,@actionType = @auditLog_actionType
				,@changeDescription = 'C-Store updates the Storage Location Id'
				,@fromValue = @auditLog_intStorageLocationId_Original
				,@toValue = @auditLog_intStorageLocationId_New
		END
		
		IF ISNULL(@auditLog_dblReorderPoint_Original, 0) <> ISNULL(@auditLog_dblReorderPoint_New, 0)
		BEGIN 
			EXEC dbo.uspSMAuditLog 
				@keyValue = @auditLog_intItemLocationId
				,@screenName = 'Inventory.view.ItemLocation'
				,@entityId = @intEntityUserSecurityId
				,@actionType = @auditLog_actionType
				,@changeDescription = 'C-Store updates the Reorder Point'
				,@fromValue = @auditLog_dblReorderPoint_Original
				,@toValue = @auditLog_dblReorderPoint_New
		END

		IF ISNULL(@auditLog_strDescription_Original, '') <> ISNULL(@auditLog_strDescription_New, '')
		BEGIN 
			EXEC dbo.uspSMAuditLog 
				@keyValue = @auditLog_intItemLocationId
				,@screenName = 'Inventory.view.ItemLocation'
				,@entityId = @intEntityUserSecurityId
				,@actionType = @auditLog_actionType
				,@changeDescription = 'C-Store updates the Description'
				,@fromValue = @auditLog_strDescription_Original
				,@toValue = @auditLog_strDescription_New
		END


		FETCH NEXT FROM loopAuditLog INTO 
			@auditLog_intItemId 
			,@auditLog_intItemLocationId 
			-- Original Fields
			,@auditLog_ysnTaxFlag1_Original 
			,@auditLog_ysnTaxFlag2_Original 
			,@auditLog_ysnTaxFlag3_Original 
			,@auditLog_ysnTaxFlag4_Original 
			,@auditLog_ysnDepositRequired_Original 
			,@auditLog_intDepositPLUId_Original 
			,@auditLog_ysnQuantityRequired_Original 
			,@auditLog_ysnScaleItem_Original 
			,@auditLog_ysnFoodStampable_Original 
			,@auditLog_ysnReturnable_Original 
			,@auditLog_ysnSaleable_Original 
			,@auditLog_ysnIdRequiredLiquor_Original 
			,@auditLog_ysnIdRequiredCigarette_Original 
			,@auditLog_ysnPromotionalItem_Original 
			,@auditLog_ysnPrePriced_Original 
			,@auditLog_ysnApplyBlueLaw1_Original 
			,@auditLog_ysnApplyBlueLaw2_Original 
			,@auditLog_ysnCountedDaily_Original 
			,@auditLog_strCounted_Original 
			,@auditLog_ysnCountBySINo_Original 
			,@auditLog_intFamilyId_Original 
			,@auditLog_intClassId_Original 
			,@auditLog_intProductCodeId_Original 
			,@auditLog_intVendorId_Original 
			,@auditLog_intMinimumAge_Original 
			,@auditLog_dblMinOrder_Original 
			,@auditLog_dblSuggestedQty_Original 
			,@auditLog_strStorageUnitNo_Original 
			,@auditLog_intCountGroupId_Original 
			,@auditLog_intStorageLocationId_Original 
			,@auditLog_dblReorderPoint_Original 
			,@auditLog_strDescription_Original 
			-- Modified Fields
			,@auditLog_ysnTaxFlag1_New 
			,@auditLog_ysnTaxFlag2_New 
			,@auditLog_ysnTaxFlag3_New 
			,@auditLog_ysnTaxFlag4_New 
			,@auditLog_ysnDepositRequired_New 
			,@auditLog_intDepositPLUId_New 
			,@auditLog_ysnQuantityRequired_New 
			,@auditLog_ysnScaleItem_New 
			,@auditLog_ysnFoodStampable_New 
			,@auditLog_ysnReturnable_New 
			,@auditLog_ysnSaleable_New 
			,@auditLog_ysnIdRequiredLiquor_New 
			,@auditLog_ysnIdRequiredCigarette_New 
			,@auditLog_ysnPromotionalItem_New 
			,@auditLog_ysnPrePriced_New 
			,@auditLog_ysnApplyBlueLaw1_New 
			,@auditLog_ysnApplyBlueLaw2_New 
			,@auditLog_ysnCountedDaily_New 
			,@auditLog_strCounted_New 
			,@auditLog_ysnCountBySINo_New 
			,@auditLog_intFamilyId_New 
			,@auditLog_intClassId_New 
			,@auditLog_intProductCodeId_New 
			,@auditLog_intVendorId_New 
			,@auditLog_intMinimumAge_New 
			,@auditLog_dblMinOrder_New 
			,@auditLog_dblSuggestedQty_New 
			,@auditLog_strStorageUnitNo_New 
			,@auditLog_intCountGroupId_New 
			,@auditLog_intStorageLocationId_New 
			,@auditLog_dblReorderPoint_New 
			,@auditLog_strDescription_New 
		;
	END 
	CLOSE loopAuditLog;
	DEALLOCATE loopAuditLog;
END