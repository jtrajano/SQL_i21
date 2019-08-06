﻿CREATE PROCEDURE [dbo].[uspSTAddNewPricebookItem]			
	@strDescription						NVARCHAR(250)
	, @intCategoryId					INT	
	, @strItemNo						NVARCHAR(100)
	, @strShortName						NVARCHAR(100)		= NULL

	, @intUnitMeasureId					INT					
	, @strUpcCode						NVARCHAR(100)		= NULL
	, @strLongUpcCode					NVARCHAR(100)

	, @intFamilyId						INT		
	, @intClassId						INT	
	, @intVendorId						INT

	, @strVendorProduct					NVARCHAR(100)		= NULL

	, @UDTItemPricing StoreItemPricing	READONLY

	, @intEntityId						INT
	, @intNewUniqueId					INT				OUTPUT
	, @intNewItemId						INT				OUTPUT
	, @ysnResultSuccess					BIT				OUTPUT
	, @strResultMessage					NVARCHAR(1000)	OUTPUT
AS
BEGIN

	SET ANSI_WARNINGS ON -- Since uspICUpdateItemForCStore is using 'ANSI_WARNINGS' set to 'ON'
	SET NOCOUNT ON;
    DECLARE @InitTranCount INT;
    SET @InitTranCount = @@TRANCOUNT
	DECLARE @Savepoint NVARCHAR(32) = SUBSTRING(('uspSTUpdatePricebookItem' + CONVERT(VARCHAR, @InitTranCount)), 1, 32)
	
	BEGIN TRY
		
			IF @InitTranCount = 0
				BEGIN
					BEGIN TRANSACTION
				END
				
			ELSE
				BEGIN
					SAVE TRANSACTION @Savepoint
				END



			DECLARE @intRecordsCount		AS INT = 0
			DECLARE @strRecordsCount		AS NVARCHAR(50) = ''
			DECLARE @intNewItemUOMId		AS INT
			DECLARE @intNewItemLocationId	AS INT
			DECLARE @intNewItemPricingId	AS INT
			DECLARE @intNewItemVendorXrefId AS INT

			SET @ysnResultSuccess = CAST(1 AS BIT)
			SET @strResultMessage = ''
			SET @intNewItemId = 0
			SET @intNewItemUOMId = 0
			SET @intNewUniqueId = 0
			SET @intNewItemLocationId = 0
			SET @intNewItemPricingId = 0
			SET @intNewItemVendorXrefId = 0


			-- ITEM AuditLog temp table
			BEGIN
				-- Create the temp table for the audit log. 
				IF OBJECT_ID('tempdb..#tmpUpdateItemForCStore_itemAuditLog') IS NULL  
					CREATE TABLE #tmpUpdateItemForCStore_itemAuditLog (
						intItemId INT
						-- Original Fields
						,intCategoryId_Original INT NULL
						,strCountCode_Original NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
						,strDescription_Original NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL
						,strItemNo_Original NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL
						,strShortName_Original NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL
						-- Modified Fields
						,intCategoryId_New INT NULL
						,strCountCode_New NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
						,strDescription_New NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL
						,strItemNo_New NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL
						,strShortName_New NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL
					)
				;
			END

			-- Create the temp table for the audit log. 
			IF OBJECT_ID('tempdb..#tmpUpdateItemUOMForCStore_itemAuditLog') IS NULL  
				CREATE TABLE #tmpUpdateItemUOMForCStore_itemAuditLog (
					intItemUOMId INT 
					,intItemId INT 
					-- Original Fields
					,strUPCCode_Original NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
					,strLongUPCCode_Original NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
					-- Modified Fields
					,strUPCCode_New NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
					,strLongUPCCode_New NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
				)
			;

			-- ITEM PRICING AuditLog temp table
			BEGIN
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
			END 


			-- ITEM VendorXref AuditLog temp table
			BEGIN
				IF OBJECT_ID('tempdb..#tmpUpdateItemVendorXrefForCStore_itemAuditLog') IS NULL  
					CREATE TABLE #tmpUpdateItemVendorXrefForCStore_itemAuditLog (
					intItemId INT
					, intItemLocationId INT		
					, intItemVendorXrefId INT		
					, strAction NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
					-- Original Fields		
					, strVendorProduct_Original NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
					, strVendorProductDescription_Original NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL
					-- Modified Fields
					, strVendorProduct_New NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
					, strVendorProductDescription_New NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL
				)
			END


			-- ITEM LOCATION AuditLog temp table
			BEGIN
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
			END


			-- temp table for ItemPricing
			BEGIN
				DECLARE @tblCStoreItemPricing TABLE (
					intItemPricingId			INT
					, intItemId					INT
					, dblStandardCost			NUMERIC(38,20)
					, dblLastCost				NUMERIC(38,20)
					, intCompanyLocationId		INT
				)
			END


			-- temp table for ItemLocations
			BEGIN
				DECLARE @tempCStoreLocation TABLE
				(
					intStoreId				INT,
					intCompanyLocationId	INT,

					-- Item Location
					ysnUseTaxFlag1			BIT,
					ysnUseTaxFlag2			BIT,
					ysnUseTaxFlag3			BIT,
					ysnUseTaxFlag4			BIT,
					ysnBlueLaw1				BIT,
					ysnBlueLaw2				BIT,
					ysnFoodStampable		BIT,
					ysnReturnable			BIT,
					ysnSaleable				BIT,
					ysnPrePriced			BIT,
					ysnIdRequiredLiquor		BIT,
					ysnIdRequiredCigarette	BIT,
					intProductCodeId		INT,
					intFamilyId				INT,
					intClassId				INT,
					intMinimumAge			INT
				)
			END


			-- ============================================================================================================================
			-- [START] - ADD ITEM
			-- ============================================================================================================================
			BEGIN
					-- ITEM
					BEGIN TRY
						
						EXEC [uspICAddItemForCStore]
							@intCategoryId				= @intCategoryId
							,@strItemNo					= @strItemNo 
							,@strShortName				= @strShortName 
							,@strDescription			= @strDescription
							,@intEntityUserSecurityId	= @intEntityId
							,@intItemId					= @intNewItemId OUTPUT 

					END TRY
					BEGIN CATCH
						SET @ysnResultSuccess = 0
						SET @strResultMessage = 'Error Adding new Item: ' + ERROR_MESSAGE()  

						GOTO ExitWithRollback
					END CATCH

			END
			-- ============================================================================================================================
			-- [END] - ADD ITEM
			-- ============================================================================================================================
		


			
			-- ============================================================================================================================
			-- [START] - ADD ITEM UOM
			-- ============================================================================================================================
			BEGIN
					-- ITEM UOM
					BEGIN TRY
						
						EXEC [uspICAddItemUOMForCStore]
							@intUnitMeasureId			= @intUnitMeasureId
							,@intItemId					= @intNewItemId
							,@strLongUPCCode			= @strLongUpcCode
							,@ysnStockUnit				= 1
							,@intEntityUserSecurityId	= @intEntityId 
							,@intItemUOMId				= @intNewItemUOMId OUTPUT 

					END TRY
					BEGIN CATCH
						SET @ysnResultSuccess = 0
						SET @strResultMessage = 'Error Adding new Item UOM: ' + ERROR_MESSAGE()  

						GOTO ExitWithRollback
					END CATCH
			END
			-- ============================================================================================================================
			-- [END] - ADD ITEM UOM
			-- ============================================================================================================================




			-- ============================================================================================================================
			-- [START] - ADD ITEM LOCATION
			-- ============================================================================================================================
			BEGIN
					INSERT INTO @tempCStoreLocation
					(
						intStoreId,
						intCompanyLocationId,

						-- Item Location
						ysnUseTaxFlag1,
						ysnUseTaxFlag2,
						ysnUseTaxFlag3,
						ysnUseTaxFlag4,
						ysnBlueLaw1,
						ysnBlueLaw2,
						ysnFoodStampable,
						ysnReturnable,
						ysnSaleable,
						ysnPrePriced,
						ysnIdRequiredLiquor,
						ysnIdRequiredCigarette,
						intProductCodeId,
						intFamilyId,
						intClassId,
						intMinimumAge
					)
					SELECT 
						intStoreId					= st.intStoreId,
						intCompanyLocationId		= st.intCompanyLocationId,

						-- Item Location
						ysnUseTaxFlag1				= ISNULL(catLoc.ysnUseTaxFlag1, 0),
						ysnUseTaxFlag2				= ISNULL(catLoc.ysnUseTaxFlag2, 0),
						ysnUseTaxFlag3				= ISNULL(catLoc.ysnUseTaxFlag3, 0),
						ysnUseTaxFlag4				= ISNULL(catLoc.ysnUseTaxFlag4, 0),
						ysnBlueLaw1					= ISNULL(catLoc.ysnBlueLaw1, 0),
						ysnBlueLaw2					= ISNULL(catLoc.ysnBlueLaw2, 0),
						ysnFoodStampable			= ISNULL(catLoc.ysnFoodStampable, 0),
						ysnReturnable				= ISNULL(catLoc.ysnReturnable, 0),
						ysnSaleable					= ISNULL(catLoc.ysnSaleable, 0),
						ysnPrePriced				= ISNULL(catLoc.ysnPrePriced, 0),
						ysnIdRequiredLiquor			= ISNULL(catLoc.ysnIdRequiredLiquor, 0),
						ysnIdRequiredCigarette		= ISNULL(catLoc.ysnIdRequiredCigarette, 0),
						intProductCodeId			= catLoc.intProductCodeId,
						intFamilyId					= ISNULL(@intFamilyId, catLoc.intFamilyId),
						intClassId					= ISNULL(@intClassId, catLoc.intClassId),
						intMinimumAge				= catLoc.intMinimumAge
					FROM tblSTStore st
					LEFT JOIN tblICCategoryLocation catLoc
						ON st.intCompanyLocationId = catLoc.intLocationId
					WHERE st.intCompanyLocationId IS NOT NULL
						AND catLoc.intCategoryId = @intCategoryId
					


					INSERT INTO @tblCStoreItemPricing 
					(
						intItemPricingId
						, intItemId
						, dblStandardCost
						, dblLastCost
						, intCompanyLocationId
					)
					SELECT 
						intItemPricingId		= NULL
						, intItemId				= udt.intItemId
						, dblStandardCost		= udt.dblStandardCost
						, dblLastCost			= udt.dblLastCost
						, intCompanyLocationId  = st.intCompanyLocationId
					FROM @UDTItemPricing udt
					INNER JOIN tblSTStore st
						ON udt.intStoreId = st.intStoreId




					IF EXISTS(SELECT TOP 1 1 FROM @tempCStoreLocation)
						BEGIN
							
							DECLARE @intStoreId_New				INT,
									@intCompanyLocationId_New	INT,
									@ysnUseTaxFlag1_New			BIT,
									@ysnUseTaxFlag2_New			BIT,
									@ysnUseTaxFlag3_New			BIT,
									@ysnUseTaxFlag4_New			BIT,
									@ysnBlueLaw1_New			BIT,
									@ysnBlueLaw2_New			BIT,
									@ysnFoodStampable_New		BIT,
									@ysnReturnable_New			BIT,
									@ysnSaleable_New			BIT,
									@ysnPrePriced_New			BIT,
									@ysnIdRequiredLiquor_New	BIT,
									@ysnIdRequiredCigarette_New	BIT,
									@intProductCodeId_New		INT,
									@intFamilyId_New			INT,
									@intClassId_New				INT,
									@intMinimumAge_New			INT,

									@dblStandardCost_New		NUMERIC(18, 6),
									@dblLastCost_New			NUMERIC(18, 6),
									@dblSalePrice_New			NUMERIC(18, 6)


							WHILE EXISTS(SELECT TOP 1 1 FROM @tempCStoreLocation)
								BEGIN
									
									SELECT TOP 1
											@intStoreId_New				= intStoreId,
											@intCompanyLocationId_New	= intCompanyLocationId,
											@ysnUseTaxFlag1_New			= ysnUseTaxFlag1,
											@ysnUseTaxFlag2_New			= ysnUseTaxFlag2,
											@ysnUseTaxFlag3_New			= ysnUseTaxFlag3,
											@ysnUseTaxFlag4_New			= ysnUseTaxFlag4,
											@ysnBlueLaw1_New			= ysnBlueLaw1,
											@ysnBlueLaw2_New			= ysnBlueLaw2,
											@ysnFoodStampable_New		= ysnFoodStampable,
											@ysnReturnable_New			= ysnReturnable,
											@ysnSaleable_New			= ysnSaleable,
											@ysnPrePriced_New			= ysnPrePriced,
											@ysnIdRequiredLiquor_New	= ysnIdRequiredLiquor,
											@ysnIdRequiredCigarette_New	= ysnIdRequiredCigarette,
											@intProductCodeId_New		= intProductCodeId,
											@intFamilyId_New			= intFamilyId,
											@intClassId_New				= intClassId,
											@intMinimumAge_New			= intMinimumAge
									FROM @tempCStoreLocation


									-- ITEM LOCATION
									BEGIN TRY
										
										EXEC [uspICAddItemLocationForCStore]
											@intLocationId				= @intCompanyLocationId_New 
											,@intItemId					= @intNewItemId

											,@ysnTaxFlag1				= @ysnUseTaxFlag1_New 
											,@ysnTaxFlag2				= @ysnUseTaxFlag2_New
											,@ysnTaxFlag3				= @ysnUseTaxFlag3_New
											,@ysnTaxFlag4				= @ysnUseTaxFlag4_New
											,@ysnApplyBlueLaw1			= @ysnBlueLaw1_New
											,@ysnApplyBlueLaw2			= @ysnBlueLaw2_New
											,@intProductCodeId			= @intProductCodeId_New
											,@intFamilyId				= @intFamilyId_New
											,@intClassId				= @intClassId_New
											,@ysnFoodStampable			= @ysnFoodStampable_New
											,@ysnReturnable				= @ysnReturnable_New
											,@ysnSaleable				= @ysnSaleable_New
											,@ysnPrePriced				= @ysnPrePriced_New
											,@ysnIdRequiredLiquor		= @ysnIdRequiredLiquor_New
											,@ysnIdRequiredCigarette	= @ysnIdRequiredCigarette_New
											,@intMinimumAge				= @intMinimumAge_New
											,@intVendorId				= @intVendorId
											,@intEntityUserSecurityId	= @intEntityId
											,@intItemLocationId			= @intNewItemLocationId OUTPUT 
						
										
										IF(@intVendorId IS NOT NULL AND @intNewItemId IS NOT NULL AND @intNewItemLocationId IS NOT NULL)
											BEGIN

												-- ITEM VENDOR
												EXEC [uspICAddItemVendorXrefForCStore]
													@intItemId					= @intNewItemId
													,@intItemLocationId			= @intNewItemLocationId
													,@intVendorId				= @intVendorId
													,@strVendorProduct			= @strVendorProduct
													,@intEntityUserSecurityId	= @intEntityId 
													,@intItemVendorXrefId		= @intNewItemVendorXrefId OUTPUT 
											END
										


										IF EXISTS(SELECT TOP 1 1 FROM @tblCStoreItemPricing WHERE intCompanyLocationId = @intCompanyLocationId_New)
											BEGIN
												
												SELECT TOP 1
													@dblStandardCost_New	= dblStandardCost,
													@dblLastCost_New		= dblLastCost,
													@dblSalePrice_New		= NULL
												FROM @tblCStoreItemPricing 
												WHERE intCompanyLocationId = @intCompanyLocationId_New

												IF(@intNewItemId IS NOT NULL AND @intNewItemLocationId IS NOT NULL)
													BEGIN
														-- ITEM PRICING
														EXEC [uspICAddItemPricingForCStore]
															@intItemId					= @intNewItemId
															,@intItemLocationId			= @intNewItemLocationId

															,@dblStandardCost			= @dblStandardCost_New 
															,@dblLastCost				= @dblLastCost_New 
															,@dblSalePrice				= @dblSalePrice_New
															,@intEntityUserSecurityId	= @intEntityId
															,@intItemPricingId			= @intNewItemPricingId OUTPUT
													END
												

											END

									END TRY
									BEGIN CATCH
										SET @ysnResultSuccess = 0
										SET @strResultMessage = 'Error Adding new Item Location: ' + ERROR_MESSAGE()  

										GOTO ExitWithRollback
									END CATCH




									DELETE @tempCStoreLocation WHERE intStoreId = @intStoreId_New
								END
						END

			END
			-- ============================================================================================================================
			-- [END] - ADD ITEM LOCATION
			-- ============================================================================================================================

			



			-- Clean up (ITEM, ITEM UOM, ITEM LOCATION, VendorXref)
			BEGIN
					IF OBJECT_ID('tempdb..#tmpUpdateItemForCStore_itemAuditLog') IS NOT NULL  
						DROP TABLE #tmpUpdateItemForCStore_itemAuditLog 

					IF OBJECT_ID('tempdb..#tmpUpdateItemUOMForCStore_itemAuditLog') IS NOT NULL  
						DROP TABLE #tmpUpdateItemUOMForCStore_itemAuditLog 

					IF OBJECT_ID('tempdb..#tmpUpdateItemPricingForCStore_ItemPricingAuditLog') IS NOT NULL  
						DROP TABLE #tmpUpdateItemPricingForCStore_ItemPricingAuditLog 

					IF OBJECT_ID('tempdb..#tmpUpdateItemVendorXrefForCStore_itemAuditLog') IS NOT NULL  
						DROP TABLE #tmpUpdateItemVendorXrefForCStore_itemAuditLog 

					IF OBJECT_ID('tempdb..#tmpUpdateItemLocationForCStore_itemLocationAuditLog') IS NOT NULL  
						DROP TABLE #tmpUpdateItemLocationForCStore_itemLocationAuditLog 
			END


		
			
			GOTO ExitWithCommit

	END TRY

	BEGIN CATCH
		SET @ysnResultSuccess = CAST(0 AS BIT)
		SET @strResultMessage = ERROR_MESSAGE()  

		GOTO ExitWithRollback
	END CATCH
END







ExitWithCommit:
	IF @InitTranCount = 0
		BEGIN
			COMMIT TRANSACTION
		END

	GOTO ExitPost
	


ExitWithRollback:
		IF @InitTranCount = 0
			BEGIN
				IF ((XACT_STATE()) <> 0)
				BEGIN
					PRINT 'Will Rollback Transaction.'
					SET @strResultMessage = @strResultMessage + '. Will Rollback Transaction.'

					ROLLBACK TRANSACTION
				END
			END
			
		ELSE
			BEGIN
				IF ((XACT_STATE()) <> 0)
					BEGIN
						PRINT 'Will Rollback to Save point.'
						SET @strResultMessage = @strResultMessage + '. Will Rollback to Save point.'

						ROLLBACK TRANSACTION @Savepoint
					END
			END
			
				
		
		
	

		
ExitPost:
		

