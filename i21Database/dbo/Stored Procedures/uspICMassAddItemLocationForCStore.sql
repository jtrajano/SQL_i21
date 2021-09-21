--	This Stored Procedure will copy location to multiple locations
CREATE PROCEDURE [dbo].[uspICMassAddItemLocationForCStore]
	-- filter params
	@intItemLocationId AS INT = NULL 

	-- update params 
	,@intLocationToUpdateId AS INT = NULL
	,@intEntityUserSecurityId AS INT 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

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
		,dblTransactionQtyLimit_Original NUMERIC(18, 6) NULL 
		,ysnDepositRequired_Original BIT NULL
		,intDepositPLUId_Original INT NULL 
		,intBottleDepositNo_Original INT NULL 
		,ysnQuantityRequired_Original BIT NULL 
		,ysnScaleItem_Original BIT NULL 
		,ysnFoodStampable_Original BIT NULL 
		,ysnReturnable_Original BIT NULL 
		,ysnSaleable_Original BIT NULL 
		,ysnIdRequiredLiquor_Original BIT NULL 
		,ysnIdRequiredCigarette_Original BIT NULL 
		,ysnPromotionalItem_Original BIT NULL 
		,ysnPrePriced_Original BIT NULL 
		,ysnOpenPricePLU_Original BIT NULL 
		,ysnLinkedItem_Original BIT NULL 
		,ysnApplyBlueLaw1_Original BIT NULL 
		,ysnApplyBlueLaw2_Original BIT NULL 
		,ysnCarWash_Original BIT NULL 
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
		,dblTransactionQtyLimit_New NUMERIC(18, 6) NULL 
		,ysnDepositRequired_New BIT NULL
		,intDepositPLUId_New INT NULL 
		,intBottleDepositNo_New INT NULL
		,ysnQuantityRequired_New BIT NULL 
		,ysnScaleItem_New BIT NULL 
		,ysnFoodStampable_New BIT NULL 
		,ysnReturnable_New BIT NULL 
		,ysnSaleable_New BIT NULL 
		,ysnIdRequiredLiquor_New BIT NULL 
		,ysnIdRequiredCigarette_New BIT NULL 
		,ysnPromotionalItem_New BIT NULL 
		,ysnPrePriced_New BIT NULL 
		,ysnOpenPricePLU_New BIT NULL 
		,ysnLinkedItem_New BIT NULL 
		,ysnApplyBlueLaw1_New BIT NULL 
		,ysnApplyBlueLaw2_New BIT NULL 
		,ysnCarWash_New BIT NULL 
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
		, dblTransactionQtyLimit_Original
		, ysnDepositRequired_Original
		, intDepositPLUId_Original 
		, intBottleDepositNo_Original
		, ysnQuantityRequired_Original
		, ysnScaleItem_Original
		, ysnFoodStampable_Original
		, ysnReturnable_Original
		, ysnSaleable_Original
		, ysnIdRequiredLiquor_Original
		, ysnIdRequiredCigarette_Original
		, ysnPromotionalItem_Original
		, ysnPrePriced_Original
		, ysnOpenPricePLU_Original
		, ysnLinkedItem_Original
		, ysnApplyBlueLaw1_Original
		, ysnApplyBlueLaw2_Original
		, ysnCarWash_Original
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
		, dblTransactionQtyLimit_New
		, ysnDepositRequired_New
		, intDepositPLUId_New 
		, intBottleDepositNo_New
		, ysnQuantityRequired_New
		, ysnScaleItem_New
		, ysnFoodStampable_New
		, ysnReturnable_New
		, ysnSaleable_New
		, ysnIdRequiredLiquor_New
		, ysnIdRequiredCigarette_New
		, ysnPromotionalItem_New
		, ysnPrePriced_New
		, ysnOpenPricePLU_New
		, ysnLinkedItem_New
		, ysnApplyBlueLaw1_New
		, ysnApplyBlueLaw2_New
		, ysnCarWash_New
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
			, [Changes].dblTransactionQtyLimit_Original
			, [Changes].ysnDepositRequired_Original
			, [Changes].intDepositPLUId_Original
			, [Changes].intBottleDepositNo_Original
			, [Changes].ysnQuantityRequired_Original
			, [Changes].ysnScaleItem_Original
			, [Changes].ysnFoodStampable_Original
			, [Changes].ysnReturnable_Original
			, [Changes].ysnSaleable_Original
			, [Changes].ysnIdRequiredLiquor_Original
			, [Changes].ysnIdRequiredCigarette_Original
			, [Changes].ysnPromotionalItem_Original
			, [Changes].ysnPrePriced_Original
			, [Changes].ysnOpenPricePLU_Original
			, [Changes].ysnLinkedItem_Original
			, [Changes].ysnApplyBlueLaw1_Original
			, [Changes].ysnApplyBlueLaw2_Original
			, [Changes].ysnCarWash_Original
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
			, [Changes].dblTransactionQtyLimit_New
			, [Changes].ysnDepositRequired_New
			, [Changes].intDepositPLUId_New
			, [Changes].intBottleDepositNo_New
			, [Changes].ysnQuantityRequired_New
			, [Changes].ysnScaleItem_New
			, [Changes].ysnFoodStampable_New
			, [Changes].ysnReturnable_New
			, [Changes].ysnSaleable_New
			, [Changes].ysnIdRequiredLiquor_New
			, [Changes].ysnIdRequiredCigarette_New
			, [Changes].ysnPromotionalItem_New
			, [Changes].ysnPrePriced_New
			, [Changes].ysnOpenPricePLU_New
			, [Changes].ysnLinkedItem_New
			, [Changes].ysnApplyBlueLaw1_New
			, [Changes].ysnApplyBlueLaw2_New
			, [Changes].ysnCarWash_New
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
					
						SELECT	intItemId
								,intLocationId = @intLocationToUpdateId
								,ysnTaxFlag1				
								,ysnTaxFlag2			
								,ysnTaxFlag3			
								,ysnTaxFlag4			
								,dblTransactionQtyLimit 
								,ysnDepositRequired		
								,intDepositPLUId	
								,intBottleDepositNo
								,ysnQuantityRequired	
								,ysnScaleItem			
								,ysnFoodStampable		
								,ysnReturnable			
								,ysnSaleable			
								,ysnIdRequiredLiquor	
								,ysnIdRequiredCigarette 
								,ysnPromotionalItem		
								,ysnPrePriced			
								,ysnOpenPricePLU			
								,ysnLinkedItem			
								,ysnApplyBlueLaw1		
								,ysnApplyBlueLaw2	
								,ysnCarWash			
								,ysnCountedDaily		
								,strCounted				
								,ysnCountBySINo			
								,intFamilyId			
								,intClassId				
								,intProductCodeId		
								,intVendorId			
								,intMinimumAge			
								,dblMinOrder			
								,dblSuggestedQty		
								,intCountGroupId		
								,intStorageLocationId	
								,dblReorderPoint		
								,strDescription			
						FROM	tblICItemLocation 
						WHERE intItemLocationId = @intItemLocationId

					) AS Source_Query  
						ON itemLocation.intLocationId = Source_Query.intLocationId
						AND itemLocation.intItemId = Source_Query.intItemId
					
					-- If matched, update the Standard Cost and Retail Price. 
					WHEN MATCHED THEN 
						UPDATE 
						SET		
							ysnTaxFlag1				= Source_Query.ysnTaxFlag1
							,ysnTaxFlag2			= Source_Query.ysnTaxFlag2
							,ysnTaxFlag3			= Source_Query.ysnTaxFlag3
							,ysnTaxFlag4			= Source_Query.ysnTaxFlag4
							,dblTransactionQtyLimit = Source_Query.dblTransactionQtyLimit
							,ysnDepositRequired		= Source_Query.ysnDepositRequired
							,intDepositPLUId		= Source_Query.intDepositPLUId
							,intBottleDepositNo		= Source_Query.intBottleDepositNo
							,ysnQuantityRequired	= Source_Query.ysnQuantityRequired
							,ysnScaleItem			= Source_Query.ysnScaleItem
							,ysnFoodStampable		= Source_Query.ysnFoodStampable
							,ysnReturnable			= Source_Query.ysnReturnable
							,ysnSaleable			= Source_Query.ysnSaleable
							,ysnIdRequiredLiquor	= Source_Query.ysnIdRequiredLiquor
							,ysnIdRequiredCigarette = Source_Query.ysnIdRequiredCigarette
							,ysnPromotionalItem		= Source_Query.ysnPromotionalItem
							,ysnPrePriced			= Source_Query.ysnPrePriced
							,ysnOpenPricePLU		= Source_Query.ysnOpenPricePLU
							,ysnLinkedItem			= Source_Query.ysnLinkedItem
							,ysnApplyBlueLaw1		= Source_Query.ysnApplyBlueLaw1
							,ysnApplyBlueLaw2		= Source_Query.ysnApplyBlueLaw2
							,ysnCarWash				= Source_Query.ysnCarWash
							,ysnCountedDaily		= Source_Query.ysnCountedDaily
							,strCounted				= Source_Query.strCounted
							,ysnCountBySINo			= Source_Query.ysnCountBySINo
							,intFamilyId			= Source_Query.intFamilyId
							,intClassId				= Source_Query.intClassId
							,intProductCodeId		= Source_Query.intProductCodeId
							,intVendorId			= Source_Query.intVendorId
							,intMinimumAge			= Source_Query.intMinimumAge
							,dblMinOrder			= Source_Query.dblMinOrder
							,dblSuggestedQty		= Source_Query.dblSuggestedQty
							,intCountGroupId		= Source_Query.intCountGroupId
							,intStorageLocationId	= Source_Query.intStorageLocationId
							,dblReorderPoint		= Source_Query.dblReorderPoint
							,strDescription			= Source_Query.strDescription
							,dtmDateModified = GETUTCDATE()
							,intModifiedByUserId = @intEntityUserSecurityId
							
					WHEN NOT MATCHED THEN 
						INSERT (
								intItemId
								,intLocationId
								,ysnTaxFlag1				
								,ysnTaxFlag2			
								,ysnTaxFlag3			
								,ysnTaxFlag4			
								,dblTransactionQtyLimit 
								,ysnDepositRequired		
								,intDepositPLUId	
								,intBottleDepositNo
								,ysnQuantityRequired	
								,ysnScaleItem			
								,ysnFoodStampable		
								,ysnReturnable			
								,ysnSaleable			
								,ysnIdRequiredLiquor	
								,ysnIdRequiredCigarette 
								,ysnPromotionalItem		
								,ysnPrePriced			
								,ysnOpenPricePLU			
								,ysnLinkedItem			
								,ysnApplyBlueLaw1		
								,ysnApplyBlueLaw2		
								,ysnCarWash	
								,ysnCountedDaily		
								,strCounted				
								,ysnCountBySINo			
								,intFamilyId			
								,intClassId				
								,intProductCodeId		
								,intVendorId			
								,intMinimumAge			
								,dblMinOrder			
								,dblSuggestedQty		
								,intCountGroupId		
								,intStorageLocationId	
								,dblReorderPoint		
								,strDescription			
								,dtmDateModified 
								,intModifiedByUserId 
							)
							VALUES
							(
								Source_Query.intItemId
								, Source_Query.intLocationId
								, Source_Query.ysnTaxFlag1
								, Source_Query.ysnTaxFlag2
								, Source_Query.ysnTaxFlag3
								, Source_Query.ysnTaxFlag4
								, Source_Query.dblTransactionQtyLimit
								, Source_Query.ysnDepositRequired
								, Source_Query.intDepositPLUId
								, Source_Query.intBottleDepositNo
								, Source_Query.ysnQuantityRequired
								, Source_Query.ysnScaleItem
								, Source_Query.ysnFoodStampable
								, Source_Query.ysnReturnable
								, Source_Query.ysnSaleable
								, Source_Query.ysnIdRequiredLiquor
								, Source_Query.ysnIdRequiredCigarette
								, Source_Query.ysnPromotionalItem
								, Source_Query.ysnPrePriced
								, Source_Query.ysnOpenPricePLU
								, Source_Query.ysnLinkedItem
								, Source_Query.ysnApplyBlueLaw1
								, Source_Query.ysnApplyBlueLaw2
								, Source_Query.ysnCarWash
								, Source_Query.ysnCountedDaily
								, Source_Query.strCounted
								, Source_Query.ysnCountBySINo
								, Source_Query.intFamilyId
								, Source_Query.intClassId
								, Source_Query.intProductCodeId
								, Source_Query.intVendorId
								, Source_Query.intMinimumAge
								, Source_Query.dblMinOrder
								, Source_Query.dblSuggestedQty
								, Source_Query.intCountGroupId
								, Source_Query.intStorageLocationId
								, Source_Query.dblReorderPoint
								, Source_Query.strDescription
								, GETUTCDATE()
								, @intEntityUserSecurityId
							)
					OUTPUT 
						$action
						, inserted.intItemId 
						, inserted.intItemLocationId
						-- Original values
						, deleted.ysnTaxFlag1
						, deleted.ysnTaxFlag2
						, deleted.ysnTaxFlag3
						, deleted.ysnTaxFlag4
						, deleted.dblTransactionQtyLimit
						, deleted.ysnDepositRequired
						, deleted.intDepositPLUId
						, deleted.intBottleDepositNo
						, deleted.ysnQuantityRequired
						, deleted.ysnScaleItem
						, deleted.ysnFoodStampable
						, deleted.ysnReturnable
						, deleted.ysnSaleable
						, deleted.ysnIdRequiredLiquor
						, deleted.ysnIdRequiredCigarette
						, deleted.ysnPromotionalItem
						, deleted.ysnPrePriced
						, deleted.ysnOpenPricePLU
						, deleted.ysnLinkedItem
						, deleted.ysnApplyBlueLaw1
						, deleted.ysnApplyBlueLaw2
						, deleted.ysnCarWash
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
						, inserted.dblTransactionQtyLimit
						, inserted.ysnDepositRequired
						, inserted.intDepositPLUId
						, inserted.intBottleDepositNo
						, inserted.ysnQuantityRequired
						, inserted.ysnScaleItem
						, inserted.ysnFoodStampable
						, inserted.ysnReturnable
						, inserted.ysnSaleable
						, inserted.ysnIdRequiredLiquor
						, inserted.ysnIdRequiredCigarette
						, inserted.ysnPromotionalItem
						, inserted.ysnPrePriced
						, inserted.ysnOpenPricePLU
						, inserted.ysnLinkedItem
						, inserted.ysnApplyBlueLaw1
						, inserted.ysnApplyBlueLaw2
						, inserted.ysnCarWash
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
				action
				, intItemId 
				, intItemLocationId
				-- Original values
				, ysnTaxFlag1_Original
				, ysnTaxFlag2_Original
				, ysnTaxFlag3_Original
				, ysnTaxFlag4_Original
				, dblTransactionQtyLimit_Original
				, ysnDepositRequired_Original
				, intDepositPLUId_Original
				, intBottleDepositNo_Original
				, ysnQuantityRequired_Original
				, ysnScaleItem_Original
				, ysnFoodStampable_Original
				, ysnReturnable_Original
				, ysnSaleable_Original
				, ysnIdRequiredLiquor_Original
				, ysnIdRequiredCigarette_Original
				, ysnPromotionalItem_Original
				, ysnPrePriced_Original
				, ysnOpenPricePLU_Original
				, ysnLinkedItem_Original
				, ysnApplyBlueLaw1_Original
				, ysnApplyBlueLaw2_Original
				, ysnCarWash_Original
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
				, dblTransactionQtyLimit_New
				, ysnDepositRequired_New
				, intDepositPLUId_New
				, intBottleDepositNo_New
				, ysnQuantityRequired_New
				, ysnScaleItem_New
				, ysnFoodStampable_New
				, ysnReturnable_New
				, ysnSaleable_New
				, ysnIdRequiredLiquor_New
				, ysnIdRequiredCigarette_New
				, ysnPromotionalItem_New
				, ysnPrePriced_New
				, ysnOpenPricePLU_New
				, ysnLinkedItem_New
				, ysnApplyBlueLaw1_New
				, ysnApplyBlueLaw2_New
				, ysnCarWash_New
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
	;
END

IF EXISTS (SELECT TOP 1 1 FROM #tmpUpdateItemLocationForCStore_itemLocationAuditLog)
BEGIN 
	DECLARE @strLocationFrom AS VARCHAR(100) = (SELECT TOP 1 strLocationName FROM tblSMCompanyLocation cl 
																		INNER JOIN tblICItemLocation il
																		ON cl.intCompanyLocationId = il.intLocationId
																		WHERE il.intItemLocationId = @intItemLocationId)
	DECLARE @strLocationTo   AS VARCHAR(100) =  (SELECT TOP 1 strLocationName FROM tblSMCompanyLocation cl 
																		INNER JOIN tblICItemLocation il
																		ON cl.intCompanyLocationId = il.intLocationId
																		WHERE il.intItemLocationId = @intLocationToUpdateId)
																		
	DECLARE @auditLog_actionType AS NVARCHAR(50) = 'Updated'
			,@auditLog_intItemId INT = (SELECT TOP 1 intItemId FROM #tmpUpdateItemLocationForCStore_itemLocationAuditLog)
	
	IF ISNULL(@strLocationFrom, '') <> ISNULL(@strLocationTo, '')
	BEGIN 
		EXEC dbo.uspSMAuditLog 
			@keyValue = @auditLog_intItemId
			,@screenName = 'Store.view.InventoryMassMaintenance'
			,@entityId = @intEntityUserSecurityId
			,@actionType = @auditLog_actionType
			,@changeDescription = 'C-Store Executes Mass Add of Location'
			,@fromValue = @strLocationFrom
			,@toValue = @strLocationTo
			
	END

END