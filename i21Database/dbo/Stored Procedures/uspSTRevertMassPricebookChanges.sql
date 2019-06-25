﻿CREATE PROCEDURE [dbo].[uspSTRevertMassPricebookChanges]
		@intRevertHolderId		INT,
		@intEntityId			INT,
		@ysnDebug				BIT,
		@ysnSuccess				BIT OUTPUT,
		@strResultMsg			NVARCHAR(1000) OUTPUT
	AS
BEGIN TRY
	    
		BEGIN TRANSACTION




		SET @strResultMsg = ''    
		SET @ysnSuccess = CAST(1 AS BIT)



		-- ITEM
		IF EXISTS(SELECT TOP 1 1 FROM tblSTRevertHolderDetail WHERE strTableName = N'tblICItem' AND intRevertHolderId = @intRevertHolderId)
			BEGIN

				-- =========================================================================
				-- [START] - Revert ITEM
				-- =========================================================================

				-- Create
				DECLARE @tempITEM TABLE (
						intItemId			INT NULL
						, intCategoryId		INT NULL
						, strCountCode		NVARCHAR(50)  COLLATE Latin1_General_CI_AS NULL
				)


				-- Insert
				INSERT INTO @tempITEM
				(
					intItemId
					, intCategoryId
					, strCountCode
				)
				SELECT DISTINCT
					intItemId			= piv.intItemId
					, intCategoryId		= piv.intCategoryId
					, strCountCode		= piv.strCountCode
				FROM (
					SELECT detail.intItemId
						 , detail.strTableColumnName
						 , detail.strOldData
					FROM tblSTRevertHolderDetail detail
					WHERE detail.strTableName = N'tblICItem'
				) src
				PIVOT (
					MAX(strOldData) FOR strTableColumnName IN (intCategoryId, strCountCode)
				) piv




				-----------------------------------------------------------------------------
				-- [START] - ITEM DEBUG MODE
				-----------------------------------------------------------------------------
				IF (@ysnDebug = 1)
					BEGIN
						SELECT 'tblICItem temp table', * FROM @tempITEM

						SELECT DISTINCT
						       'tblICItem - Before Update'
								 , Item.intItemId
								 , Item.strItemNo
								 , Item.strDescription
								 , Item.intCategoryId
								 , Item.strCountCode
						FROM tblICItem Item
						INNER JOIN tblSTRevertHolderDetail detail
							ON Item.intItemId = detail.intItemId	
						WHERE detail.strTableName = N'tblICItem'
						ORDER BY Item.intItemId ASC
					END
				-----------------------------------------------------------------------------
				-- [END] - ITEM DEBUG MODE
				-----------------------------------------------------------------------------




				-- LOOP ITEM's
				WHILE EXISTS(SELECT TOP 1 1 FROM @tempITEM)
					BEGIN			
	
						DECLARE  @intItemId			INT
								, @intCategoryId	INT
								, @strCountCode		NVARCHAR(50)

				
				

						SELECT TOP 1 
								@intItemId			=  temp.intItemId
								, @intCategoryId	=  CASE 
															WHEN temp.intCategoryId IS NULL
																THEN Item.intCategoryId
															ELSE temp.intCategoryId
													END
								, @strCountCode		=  CASE 
															WHEN temp.strCountCode IS NULL
																THEN Item.strCountCode
															ELSE temp.strCountCode
													END
						FROM @tempITEM temp
						INNER JOIN tblICItem Item
							ON temp.intItemId = Item.intItemId
						ORDER BY temp.intItemId ASC

		
						-- UPDATE ITEM
						EXEC [dbo].[uspICUpdateItemForCStore]
							 @strUpcCode				= NULL 
							 ,@strDescription			= NULL 
							 ,@dblRetailPriceFrom		= NULL  
							 ,@dblRetailPriceTo			= NULL 
							 ,@intItemId				= @intItemId

							 ,@intCategoryId			= @intCategoryId
							 ,@strCountCode				= @strCountCode
							 ,@strItemDescription		= NULL
							 ,@intEntityUserSecurityId	= @intEntityId -- *** ADD EntityId of the user who commited the revert ***

			
						-- Remove
						DELETE FROM @tempITEM WHERE intItemId = @intItemId
		
					END




					-----------------------------------------------------------------------------
					-- [START] - ITEM DEBUG MODE
					-----------------------------------------------------------------------------
					IF (@ysnDebug = 1)
						BEGIN
							SELECT DISTINCT 
							     'tblICItem - After Update'
								 , Item.intItemId
								 , Item.strItemNo
								 , Item.strDescription
								 , Item.intCategoryId
								 , Item.strCountCode
							FROM tblICItem Item
							INNER JOIN tblSTRevertHolderDetail detail
								ON Item.intItemId = detail.intItemId	
							WHERE detail.strTableName = N'tblICItem'
							ORDER BY Item.intItemId ASC
						END
					-----------------------------------------------------------------------------
					-- [END] - ITEM DEBUG MODE
					-----------------------------------------------------------------------------



				-- =========================================================================
				-- [END] - Revert ITEM
				-- =========================================================================

			END



		

		-- ITEM LOCATION
		IF EXISTS(SELECT TOP 1 1 FROM tblSTRevertHolderDetail WHERE strTableName = N'tblICItemLocation' AND intRevertHolderId = @intRevertHolderId)
			BEGIN
				
				-- =========================================================================
				-- [START] - Revert ITEM LOCATION
				-- =========================================================================

				-- Create
				DECLARE @tempITEMLOCATION TABLE (
						intItemLocationId			INT		NOT NULL,
						ysnTaxFlag1					BIT		NULL,
						ysnTaxFlag2					BIT		NULL,
						ysnTaxFlag3					BIT		NULL,
						ysnTaxFlag4					BIT		NULL,
						ysnDepositRequired			BIT		NULL,
						intDepositPLUId				INT		NULL,
						ysnQuantityRequired			BIT		NULL,	
						ysnScaleItem				BIT		NULL,
						ysnFoodStampable			BIT		NULL,
						ysnReturnable				BIT		NULL,
						ysnSaleable					BIT		NULL,
						ysnIdRequiredLiquor			BIT		NULL,
						ysnIdRequiredCigarette		BIT		NULL,
						ysnPromotionalItem			BIT		NULL,
						ysnPrePriced				BIT		NULL,
						ysnApplyBlueLaw1			BIT		NULL,
						ysnApplyBlueLaw2			BIT		NULL,
						ysnCountedDaily				BIT		NULL,
						strCounted					NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
						ysnCountBySINo				BIT		NULL,
						intFamilyId					INT		NULL,
						intClassId					INT		NULL,
						intProductCodeId			INT		NULL,
						intVendorId					INT		NULL,
						intMinimumAge				INT		NULL,
						dblMinOrder					NUMERIC(18, 6) NULL,
						dblSuggestedQty				NUMERIC(18, 6) NULL,
						intStorageLocationId		INT		NULL
				)


				-- Insert
				INSERT INTO @tempITEMLOCATION
				(
					intItemLocationId,
					ysnTaxFlag1,
					ysnTaxFlag2,
					ysnTaxFlag3,
					ysnTaxFlag4,
					ysnDepositRequired,
					intDepositPLUId,
					ysnQuantityRequired,	
					ysnScaleItem,
					ysnFoodStampable,
					ysnReturnable,
					ysnSaleable,
					ysnIdRequiredLiquor,
					ysnIdRequiredCigarette,
					ysnPromotionalItem,
					ysnPrePriced,
					ysnApplyBlueLaw1,
					ysnApplyBlueLaw2,
					ysnCountedDaily,
					strCounted,
					ysnCountBySINo,
					intFamilyId,
					intClassId,
					intProductCodeId,
					intVendorId,
					intMinimumAge,
					dblMinOrder,
					dblSuggestedQty,
					intStorageLocationId
				)
				SELECT DISTINCT
					intItemLocationId		= piv.intItemLocationId,
					ysnTaxFlag1				= piv.ysnTaxFlag1,
					ysnTaxFlag2				= piv.ysnTaxFlag2,
					ysnTaxFlag3				= piv.ysnTaxFlag3,
					ysnTaxFlag4				= piv.ysnTaxFlag4,
					ysnDepositRequired		= piv.ysnDepositRequired,
					intDepositPLUId			= piv.intDepositPLUId,
					ysnQuantityRequired		= piv.ysnQuantityRequired,	
					ysnScaleItem			= piv.ysnScaleItem,
					ysnFoodStampable		= piv.ysnFoodStampable,
					ysnReturnable			= piv.ysnReturnable,
					ysnSaleable				= piv.ysnSaleable,
					ysnIdRequiredLiquor		= piv.ysnIdRequiredLiquor,
					ysnIdRequiredCigarette	= piv.ysnIdRequiredCigarette,
					ysnPromotionalItem		= piv.ysnPromotionalItem,
					ysnPrePriced			= piv.ysnPrePriced,
					ysnApplyBlueLaw1		= piv.ysnApplyBlueLaw1,
					ysnApplyBlueLaw2		= piv.ysnApplyBlueLaw2,
					ysnCountedDaily			= piv.ysnCountedDaily,
					strCounted				= piv.strCounted,
					ysnCountBySINo			= piv.ysnCountBySINo,
					intFamilyId				= piv.intFamilyId,
					intClassId				= piv.intClassId,
					intProductCodeId		= piv.intProductCodeId,
					intVendorId				= piv.intVendorId,
					intMinimumAge			= piv.intMinimumAge,
					dblMinOrder				= piv.dblMinOrder,
					dblSuggestedQty			= piv.dblSuggestedQty,
					intStorageLocationId	= piv.intStorageLocationId
				FROM (
					SELECT detail.intItemLocationId
						 , detail.strTableColumnName
						 , detail.strOldData
					FROM tblSTRevertHolderDetail detail
					INNER JOIN tblICItemLocation ItemLoc
						ON detail.intItemLocationId = ItemLoc.intItemLocationId
					WHERE detail.strTableName = N'tblICItemLocation'
				) src
				PIVOT (
					MAX(strOldData) FOR strTableColumnName IN (ysnTaxFlag1,ysnTaxFlag2, ysnTaxFlag3, ysnTaxFlag4, ysnDepositRequired, intDepositPLUId, ysnQuantityRequired, ysnScaleItem, ysnFoodStampable,
																ysnReturnable, ysnSaleable, ysnIdRequiredLiquor, ysnIdRequiredCigarette, ysnPromotionalItem, ysnPrePriced, ysnApplyBlueLaw1, ysnApplyBlueLaw2,
																ysnCountedDaily, strCounted, ysnCountBySINo, intFamilyId, intClassId, intProductCodeId, intVendorId, intMinimumAge, dblMinOrder, dblSuggestedQty, intStorageLocationId)
				) piv



				-----------------------------------------------------------------------------
				-- [START] - ITEM DEBUG MODE
				-----------------------------------------------------------------------------
				IF (@ysnDebug = 1)
					BEGIN
						SELECT 'tblICItemLocation temp table', * FROM @tempITEMLOCATION

						SELECT DISTINCT
						     Item.intItemId,
						     'tblICItemLocation - Before Update',
							 Item.strItemNo,
							 Item.strDescription,
							 ItemLoc.intItemLocationId,
							 ItemLoc.ysnTaxFlag1,
							 ItemLoc.ysnTaxFlag2,
							 ItemLoc.ysnTaxFlag3,
							 ItemLoc.ysnTaxFlag4,
							 ItemLoc.ysnDepositRequired,
							 ItemLoc.intDepositPLUId,
							 ItemLoc.ysnQuantityRequired,	
							 ItemLoc.ysnScaleItem,
							 ItemLoc.ysnFoodStampable,
							 ItemLoc.ysnReturnable,
							 ItemLoc.ysnSaleable,
							 ItemLoc.ysnIdRequiredLiquor,
							 ItemLoc.ysnIdRequiredCigarette,
							 ItemLoc.ysnPromotionalItem,
							 ItemLoc.ysnPrePriced,
							 ItemLoc.ysnApplyBlueLaw1,
							 ItemLoc.ysnApplyBlueLaw2,
							 ItemLoc.ysnCountedDaily,
							 ItemLoc.strCounted,
							 ItemLoc.ysnCountBySINo,
							 ItemLoc.intFamilyId,
							 ItemLoc.intClassId,
							 ItemLoc.intProductCodeId,
							 ItemLoc.intVendorId,
							 ItemLoc.intMinimumAge,
							 ItemLoc.dblMinOrder,
							 ItemLoc.dblSuggestedQty,
							 ItemLoc.intStorageLocationId
						FROM tblICItemLocation ItemLoc
						INNER JOIN tblSTRevertHolderDetail detail
							ON ItemLoc.intItemLocationId = detail.intItemLocationId	
						INNER JOIN tblICItem Item
							ON ItemLoc.intItemId = Item.intItemId
						WHERE detail.strTableName = N'tblICItemLocation'
						ORDER BY Item.intItemId ASC
					END
				-----------------------------------------------------------------------------
				-- [END] - ITEM DEBUG MODE
				-----------------------------------------------------------------------------



				-- LOOP ITEM LOCATIONS's
				WHILE EXISTS(SELECT TOP 1 1 FROM @tempITEMLOCATION)
					BEGIN			
	
						DECLARE		@intItemLocationId			INT,
									@ysnTaxFlag1				BIT,
									@ysnTaxFlag2				BIT,
									@ysnTaxFlag3				BIT,
									@ysnTaxFlag4				BIT,
									@ysnDepositRequired			BIT,
									@intDepositPLUId			INT,
									@ysnQuantityRequired		BIT,	
									@ysnScaleItem				BIT,
									@ysnFoodStampable			BIT,
									@ysnReturnable				BIT,
									@ysnSaleable				BIT,
									@ysnIdRequiredLiquor		BIT,
									@ysnIdRequiredCigarette		BIT,
									@ysnPromotionalItem			BIT,
									@ysnPrePriced				BIT,
									@ysnApplyBlueLaw1			BIT,
									@ysnApplyBlueLaw2			BIT,
									@ysnCountedDaily			BIT,
									@strCounted					NVARCHAR(50),
									@ysnCountBySINo				BIT,
									@intFamilyId				INT,
									@intClassId					INT,
									@intProductCodeId			INT,
									@intVendorId				INT,
									@intMinimumAge				INT,
									@dblMinOrder				NUMERIC(18, 6),
									@dblSuggestedQty			NUMERIC(18, 6),
									@intStorageLocationId		INT
				
				

						SELECT TOP 1 
									@intItemLocationId			= temp.intItemLocationId,
									@ysnTaxFlag1				= ISNULL(temp.ysnTaxFlag1, ItemLoc.ysnTaxFlag1),
									@ysnTaxFlag2				= ISNULL(temp.ysnTaxFlag2, ItemLoc.ysnTaxFlag2),
									@ysnTaxFlag3				= ISNULL(temp.ysnTaxFlag3, ItemLoc.ysnTaxFlag3),
									@ysnTaxFlag4				= ISNULL(temp.ysnTaxFlag4, ItemLoc.ysnTaxFlag4),
									@ysnDepositRequired			= ISNULL(temp.ysnDepositRequired, ItemLoc.ysnDepositRequired),
									@intDepositPLUId			= temp.intDepositPLUId,
									@ysnQuantityRequired		= ISNULL(temp.ysnQuantityRequired, ItemLoc.ysnQuantityRequired),
									@ysnScaleItem				= ISNULL(temp.ysnScaleItem, ItemLoc.ysnScaleItem),
									@ysnFoodStampable			= ISNULL(temp.ysnFoodStampable, ItemLoc.ysnFoodStampable),
									@ysnReturnable				= ISNULL(temp.ysnReturnable, ItemLoc.ysnReturnable),
									@ysnSaleable				= ISNULL(temp.ysnSaleable, ItemLoc.ysnSaleable),
									@ysnIdRequiredLiquor		= ISNULL(temp.ysnIdRequiredLiquor, ItemLoc.ysnIdRequiredLiquor),
									@ysnIdRequiredCigarette		= ISNULL(temp.ysnIdRequiredCigarette, ItemLoc.ysnIdRequiredCigarette),
									@ysnPromotionalItem			= ISNULL(temp.ysnPromotionalItem, ItemLoc.ysnPromotionalItem),
									@ysnPrePriced				= ISNULL(temp.ysnPrePriced, ItemLoc.ysnPrePriced),
									@ysnApplyBlueLaw1			= ISNULL(temp.ysnApplyBlueLaw1, ItemLoc.ysnApplyBlueLaw1),
									@ysnApplyBlueLaw2			= ISNULL(temp.ysnApplyBlueLaw2, ItemLoc.ysnApplyBlueLaw2),
									@ysnCountedDaily			= ISNULL(temp.ysnCountedDaily, ItemLoc.ysnCountedDaily),
									@strCounted					= temp.strCounted,
									@ysnCountBySINo				= ISNULL(temp.ysnCountBySINo, ItemLoc.ysnCountBySINo),
									@intFamilyId				= temp.intFamilyId,
									@intClassId					= temp.intClassId,
									@intProductCodeId			= temp.intProductCodeId,
									@intVendorId				= temp.intVendorId,
									@intMinimumAge				= temp.intMinimumAge,
									@dblMinOrder				= temp.dblMinOrder,
									@dblSuggestedQty			= temp.dblSuggestedQty,
									@intStorageLocationId		= temp.intStorageLocationId
						FROM @tempITEMLOCATION temp
						INNER JOIN tblICItemLocation ItemLoc
							ON temp.intItemLocationId = ItemLoc.intItemLocationId
						ORDER BY temp.intItemLocationId ASC

		
						-- UPDATE ITEM LOCATION
						EXEC [dbo].[uspICUpdateItemLocationForCStore]
								-- filter params
								@strUpcCode									= NULL 
								,@strDescription							= NULL 
								,@dblRetailPriceFrom						= NULL  
								,@dblRetailPriceTo							= NULL 
								,@intItemLocationId							= @intItemLocationId                -- *** SET VALUE TO UPDATE SPECIFIC RECORD ***
								-- update params 
								,@ysnTaxFlag1								= @ysnTaxFlag1
								,@ysnTaxFlag2								= @ysnTaxFlag2
								,@ysnTaxFlag3								= @ysnTaxFlag3
								,@ysnTaxFlag4								= @ysnTaxFlag4
								,@ysnDepositRequired						= @ysnDepositRequired
								,@intDepositPLUId							= @intDepositPLUId 
								,@ysnQuantityRequired						= @ysnQuantityRequired 
								,@ysnScaleItem								= @ysnScaleItem 
								,@ysnFoodStampable							= @ysnFoodStampable 
								,@ysnReturnable								= @ysnReturnable 
								,@ysnSaleable								= @ysnSaleable 
								,@ysnIdRequiredLiquor						= @ysnIdRequiredLiquor 
								,@ysnIdRequiredCigarette					= @ysnIdRequiredCigarette 
								,@ysnPromotionalItem						= @ysnPromotionalItem
								,@ysnPrePriced								= @ysnPrePriced 
								,@ysnApplyBlueLaw1							= @ysnApplyBlueLaw1 
								,@ysnApplyBlueLaw2							= @ysnApplyBlueLaw2 
								,@ysnCountedDaily							= @ysnCountedDaily 
								,@strCounted								= @strCounted
								,@ysnCountBySINo							= @ysnCountBySINo 
								,@intFamilyId								= @intFamilyId 
								,@intClassId								= @intClassId 
								,@intProductCodeId							= @intProductCodeId 
								,@intVendorId								= @intVendorId
								,@intMinimumAge								= @intMinimumAge 
								,@dblMinOrder								= @dblMinOrder 
								,@dblSuggestedQty							= @dblSuggestedQty
								,@intCountGroupId							=  NULL
								,@intStorageLocationId						= @intStorageLocationId 
								,@dblReorderPoint							= NULL
								,@strItemLocationDescription				= NULL 

								,@intEntityUserSecurityId					= @intEntityId -- *** ADD EntityId of the user who commited the revert ***

			
						-- Remove
						DELETE FROM @tempITEMLOCATION WHERE intItemLocationId = @intItemLocationId
		
					END




				-----------------------------------------------------------------------------
				-- [START] - ITEM DEBUG MODE
				-----------------------------------------------------------------------------
				IF (@ysnDebug = 1)
					BEGIN
						SELECT DISTINCT 
						     Item.intItemId,
						     'tblICItemLocation - After Update',
							 Item.strItemNo,
							 Item.strDescription,
							 ItemLoc.intItemLocationId,
							 ItemLoc.ysnTaxFlag1,
							 ItemLoc.ysnTaxFlag2,
							 ItemLoc.ysnTaxFlag3,
							 ItemLoc.ysnTaxFlag4,
							 ItemLoc.ysnDepositRequired,
							 ItemLoc.intDepositPLUId,
							 ItemLoc.ysnQuantityRequired,	
							 ItemLoc.ysnScaleItem,
							 ItemLoc.ysnFoodStampable,
							 ItemLoc.ysnReturnable,
							 ItemLoc.ysnSaleable,
							 ItemLoc.ysnIdRequiredLiquor,
							 ItemLoc.ysnIdRequiredCigarette,
							 ItemLoc.ysnPromotionalItem,
							 ItemLoc.ysnPrePriced,
							 ItemLoc.ysnApplyBlueLaw1,
							 ItemLoc.ysnApplyBlueLaw2,
							 ItemLoc.ysnCountedDaily,
							 ItemLoc.strCounted,
							 ItemLoc.ysnCountBySINo,
							 ItemLoc.intFamilyId,
							 ItemLoc.intClassId,
							 ItemLoc.intProductCodeId,
							 ItemLoc.intVendorId,
							 ItemLoc.intMinimumAge,
							 ItemLoc.dblMinOrder,
							 ItemLoc.dblSuggestedQty,
							 ItemLoc.intStorageLocationId
						FROM tblICItemLocation ItemLoc
						INNER JOIN tblSTRevertHolderDetail detail
							ON ItemLoc.intItemLocationId = detail.intItemLocationId	
						INNER JOIN tblICItem Item
							ON ItemLoc.intItemId = Item.intItemId
						WHERE detail.strTableName = N'tblICItemLocation'
						ORDER BY Item.intItemId ASC
					END
				-----------------------------------------------------------------------------
				-- [END] - ITEM DEBUG MODE
				-----------------------------------------------------------------------------


				-- =========================================================================
				-- [END] - Revert ITEM LOCATION
				-- =========================================================================

			END



				





		IF(@ysnDebug = 0)
			BEGIN
				GOTO ExitWithCommit
			END
		ELSE IF(@ysnDebug = 1)
			BEGIN
				PRINT 'Will Rollback and exit'
				GOTO ExitWithRollback
			END

END TRY

BEGIN CATCH      	   
	 SET @strResultMsg = 'Error Message: ' + ERROR_MESSAGE()    
	 SET @ysnSuccess = CAST(0 AS BIT)

	 GOTO ExitWithRollback
END CATCH



ExitWithCommit:
	COMMIT TRANSACTION
	GOTO ExitPost
	


ExitWithRollback:
	IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRANSACTION 
		END
	

		
ExitPost:
