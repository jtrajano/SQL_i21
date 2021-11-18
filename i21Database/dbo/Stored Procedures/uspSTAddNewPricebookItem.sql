CREATE PROCEDURE [dbo].[uspSTAddNewPricebookItem]			
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

	--, @UDTItemPricing StoreItemPricing	READONLY
	
	, @UDTItemCostPricing StoreItemCostPricing	READONLY
	, @UDTItemRetailPricing StoreItemPricePricing	READONLY

	, @ysnDebug							BIT
	, @intEntityId						INT
	, @intNewItemId						INT				OUTPUT
	, @ysnResultSuccess					BIT				OUTPUT
	, @strResultMessage					NVARCHAR(1000)	OUTPUT
	, @intUniqueId						INT				OUTPUT
AS
BEGIN

	SET ANSI_WARNINGS ON -- Since uspICUpdateItemForCStore is using 'ANSI_WARNINGS' set to 'ON'
	SET NOCOUNT ON;
    DECLARE @InitTranCount INT;
    SET @InitTranCount = @@TRANCOUNT
	DECLARE @Savepoint NVARCHAR(32) = SUBSTRING(('uspSTAddNewPricebookItem' + CONVERT(VARCHAR, @InitTranCount)), 1, 32)
	
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
			DECLARE @strLongUpcCode_Entry	AS NVARCHAR(100)

			
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
					intMinimumAge			INT,
					intCost					INT
				)
			END

			SET @ysnResultSuccess	= CAST(1 AS BIT)
			SET @strResultMessage	= ''
			SET @strLongUpcCode_Entry = @strLongUpcCode

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
						,strStatus_Original NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL
						-- Modified Fields
						,intCategoryId_New INT NULL
						,strCountCode_New NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
						,strDescription_New NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL
						,strItemNo_New NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL
						,strShortName_New NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL
						,strStatus_New NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL
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

			-- ============================================================================================================================
			-- [START] - ADD ITEM
			-- ============================================================================================================================
			BEGIN

				IF(@intCategoryId IS NOT NULL AND @strItemNo IS NOT NULL AND @strDescription IS NOT NULL)
					BEGIN
						
						IF NOT EXISTS(SELECT TOP 1 1 FROM tblICItem WHERE strItemNo = @strItemNo)
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
									
									-- =================================================================================
									-- [START] - ADD ITEM DEBUG
									-- =================================================================================
									IF(@ysnDebug = 1)
										BEGIN
											SELECT 'New Added Item', * FROM tblICItem WHERE intItemId = @intNewItemId
										END
									-- =================================================================================
									-- [END] - ADD ITEM DEBUG
									-- =================================================================================

									IF NOT EXISTS(SELECT TOP 1 1 FROM tblICItem WHERE intItemId = @intNewItemId)
										BEGIN

											SET @strResultMessage	= 'Item is not created successfully'  

											GOTO ExitWithRollback
										END

								END TRY
								BEGIN CATCH
									SET @strResultMessage	= 'Error Adding new Item: ' + ERROR_MESSAGE()  

									GOTO ExitWithRollback
								END CATCH

							END
						ELSE
							BEGIN
								SET @strResultMessage	= 'Item number of ' + @strItemNo + ' already exists.'  

								GOTO ExitWithRollback
							END

						

					END
			END
			-- ============================================================================================================================
			-- [END] - ADD ITEM
			-- ============================================================================================================================
		

		

			-- ============================================================================================================================
			-- [START] - ADD ITEM UOM
			-- ============================================================================================================================
			BEGIN
				IF(@intUnitMeasureId IS NOT NULL AND @intNewItemId IS NOT NULL AND @strLongUpcCode IS NOT NULL)
					BEGIN		
						IF NOT EXISTS(SELECT TOP 1 1 FROM tblICItemUOM WHERE strLongUPCCode = @strLongUpcCode OR intUpcCode = CONVERT(NUMERIC(32, 0), CAST(@strLongUpcCode AS FLOAT)))
							BEGIN
								SET @strUpcCode = CASE WHEN @strUpcCode = '' 
														THEN NULL
													ELSE @strUpcCode
													END
								IF NOT EXISTS(SELECT TOP 1 1 FROM tblICItemUOM WHERE strUpcCode = @strUpcCode)	
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

											-- =================================================================================
											-- [START] - ADD ITEM UOM DEBUG
											-- =================================================================================
											IF(@ysnDebug = 1)
												BEGIN
													SELECT 'New Added Item Uom', * FROM tblICItemUOM WHERE intItemUOMId = @intNewItemUOMId
												END
											-- =================================================================================
											-- [END] - ADD ITEM UOM DEBUG
											-- =================================================================================

											IF NOT EXISTS(SELECT TOP 1 1 FROM tblICItemUOM WHERE intItemUOMId = @intNewItemUOMId)
												BEGIN
													SET @strResultMessage = 'Item UOM is not created successfully'  

													GOTO ExitWithRollback
												END
											ELSE
												BEGIN
													--TEST
													IF(@ysnDebug = 1)
														BEGIN
															SELECT 'New Item', *  FROM tblICItem WHERE intItemId = @intNewItemId
															SELECT 'New Item OUM', * FROM tblICItemUOM WHERE intItemId = @intNewItemId AND ysnStockUnit = 1
														END


													IF(@strUpcCode IS NOT NULL OR ISNULL(@strUpcCode, '') != '')
														BEGIN
													
															DECLARE @intItemUOMId INT = (SELECT TOP 1 intItemUOMId FROM tblICItemUOM WHERE intItemUOMId = @intNewItemUOMId)

															EXEC [dbo].[uspICUpdateItemForCStore]
																-- filter params	
																@strDescription				= NULL 
																,@dblRetailPriceFrom		= NULL  
																,@dblRetailPriceTo			= NULL 
																,@intItemId					= @intNewItemId 
																,@intItemUOMId				= @intItemUOMId 
																-- update params
																,@intCategoryId				= NULL
																,@strCountCode				= NULL
																,@strItemDescription		= NULL 	
																,@strItemNo					= NULL
																,@strShortName				= NULL 
																,@strUpcCode				= @strUpcCode 
																,@strLongUpcCode			= NULL 
																,@intEntityUserSecurityId	= @intEntityId

														END
												END
										END TRY
										BEGIN CATCH
											SET @strResultMessage = 'Error Adding new Item UOM: ' + ERROR_MESSAGE()  

											GOTO ExitWithRollback
										END CATCH

									END
								ELSE
									BEGIN
										SET @strResultMessage = 'Short UPC of ' + dbo.fnUPCAtoUPCE(@strLongUpcCode_Entry) + ' already exists.'  

										GOTO ExitWithRollback
									END

							END
						ELSE
							BEGIN
								SET @strResultMessage = 'Long UPC of ' + @strLongUpcCode_Entry + ' already exists.'  

								GOTO ExitWithRollback
							END
						

					END			
			END
			-- ============================================================================================================================
			-- [END] - ADD ITEM UOM
			-- ============================================================================================================================

			

			-- ============================================================================================================================
			-- [START] - ADD ITEM LOCATION
			-- ============================================================================================================================
			BEGIN
	
					BEGIN TRY
					
						-- [START] - ADD ITEM LOCATION

						--Cost
						SELECT st.intStoreId, st.intCompanyLocationId
						INTO #tmpEffectiveDate 
						FROM  @UDTItemCostPricing cp
							LEFT JOIN tblSTStore st
								ON cp.intStoreNo = st.intStoreNo
								
						--Retail
						INSERT INTO #tmpEffectiveDate (intStoreId, intCompanyLocationId)
						SELECT st.intStoreId, st.intCompanyLocationId
						FROM  @UDTItemRetailPricing rp
							LEFT JOIN tblSTStore st
								ON rp.intStoreNo = st.intStoreNo
						WHERE rp.intStoreNo NOT IN (SELECT intStoreNo FROM @UDTItemCostPricing) 

						-- [END] - ADD ITEM LOCATION

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
							ysnUseTaxFlag1				= ISNULL(catLoc.ysnUseTaxFlag1, CAST(0 AS BIT)),
							ysnUseTaxFlag2				= ISNULL(catLoc.ysnUseTaxFlag2, CAST(0 AS BIT)),
							ysnUseTaxFlag3				= ISNULL(catLoc.ysnUseTaxFlag3, CAST(0 AS BIT)),
							ysnUseTaxFlag4				= ISNULL(catLoc.ysnUseTaxFlag4, CAST(0 AS BIT)),
							ysnBlueLaw1					= ISNULL(catLoc.ysnBlueLaw1, CAST(0 AS BIT)),
							ysnBlueLaw2					= ISNULL(catLoc.ysnBlueLaw2, CAST(0 AS BIT)),
							ysnFoodStampable			= ISNULL(catLoc.ysnFoodStampable, CAST(0 AS BIT)),
							ysnReturnable				= ISNULL(catLoc.ysnReturnable, CAST(0 AS BIT)),
							ysnSaleable					= ISNULL(catLoc.ysnSaleable, CAST(0 AS BIT)),
							ysnPrePriced				= ISNULL(catLoc.ysnPrePriced, CAST(0 AS BIT)),
							ysnIdRequiredLiquor			= ISNULL(catLoc.ysnIdRequiredLiquor, CAST(0 AS BIT)),
							ysnIdRequiredCigarette		= ISNULL(catLoc.ysnIdRequiredCigarette, CAST(0 AS BIT)),
							intProductCodeId			= catLoc.intProductCodeId,
							intFamilyId					= ISNULL(@intFamilyId, catLoc.intFamilyId),
							intClassId					= ISNULL(@intClassId, catLoc.intClassId),
							intMinimumAge				= catLoc.intMinimumAge
						FROM #tmpEffectiveDate cp
						LEFT JOIN tblSTStore st
							ON cp.intStoreId = st.intStoreId
						LEFT JOIN tblICCategoryLocation catLoc
							ON st.intCompanyLocationId = catLoc.intLocationId
						WHERE st.intCompanyLocationId IS NOT NULL
							
							
							
						IF NOT EXISTS(SELECT TOP 1 1 FROM @tempCStoreLocation)
							BEGIN
								SET @strResultMessage = 'Category Selected does not have POS config setup for 1 or more store locations'

								GOTO ExitWithRollback
							END
					END TRY
					BEGIN CATCH
						SET @strResultMessage = 'Error creating location table: ' + ERROR_MESSAGE() 

						GOTO ExitWithRollback
					END CATCH

					-- =================================================================================
					-- [START] - ADD ITEM LOCATION DEBUG
					-- =================================================================================
					IF(@ysnDebug = 1)
						BEGIN
								SELECT '@tempCStoreLocation', * FROM @tempCStoreLocation
						END
					-- =================================================================================
					-- [END] - ADD ITEM LOCATION DEBUG
					-- =================================================================================
					


					IF EXISTS(SELECT TOP 1 1 FROM @tempCStoreLocation)
						BEGIN
							
							DECLARE @intStoreId_New					INT,
									@intCompanyLocationId_New		INT,
									@ysnUseTaxFlag1_New				BIT,
									@ysnUseTaxFlag2_New				BIT,
									@ysnUseTaxFlag3_New				BIT,
									@ysnUseTaxFlag4_New				BIT,
									@ysnBlueLaw1_New				BIT,
									@ysnBlueLaw2_New				BIT,
									@ysnFoodStampable_New			BIT,
									@ysnReturnable_New				BIT,
									@ysnSaleable_New				BIT,
									@ysnPrePriced_New				BIT,
									@ysnIdRequiredLiquor_New		BIT,
									@ysnIdRequiredCigarette_New		BIT,
									@intProductCodeId_New			INT,
									@intFamilyId_New				INT,
									@intClassId_New					INT,
									@intMinimumAge_New				INT,

									@dblStandardCost_New			NUMERIC(18, 6),
									@dblLastCost_New				NUMERIC(18, 6),
									@dblSalePrice_New				NUMERIC(18, 6)

							DECLARE @tmp_CostEffectiveDate AS StoreItemCostPricing
							DECLARE @tmp_RetailEffectiveDate AS StoreItemPricePricing

							INSERT INTO @tmp_CostEffectiveDate
							   SELECT *
							   FROM @UDTItemCostPricing;
							   
							INSERT INTO @tmp_RetailEffectiveDate
							   SELECT *
							   FROM @UDTItemRetailPricing;
							   

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
									
									-- =================================================================================
									-- [START] - ADD ITEM LOCATION DEBUG
									-- =================================================================================
									IF(@ysnDebug = 1)
										BEGIN
												SELECT 'LOOP', @intStoreId_New, @intCompanyLocationId_New, @ysnUseTaxFlag1_New, @ysnUseTaxFlag2_New, @ysnUseTaxFlag3_New, @ysnUseTaxFlag4_New, @ysnBlueLaw1_New, @ysnBlueLaw2_New, @ysnFoodStampable_New,
															   @ysnReturnable_New, @ysnSaleable_New, @ysnPrePriced_New, @ysnIdRequiredLiquor_New, @ysnIdRequiredCigarette_New, @intProductCodeId_New, @intFamilyId_New, @intClassId_New, @intMinimumAge_New
										END
									-- =================================================================================
									-- [END] - ADD ITEM LOCATION DEBUG
									-- =================================================================================

	
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

										
										-- =================================================================================
										-- [START] - ADD ITEM UOM DEBUG
										-- =================================================================================
										IF(@ysnDebug = 1)
											BEGIN
												SELECT 'New Added Item Location', * FROM tblICItemLocation WHERE intItemLocationId = @intNewItemLocationId
											END
										-- =================================================================================
										-- [END] - ADD ITEM UOM DEBUG
										-- =================================================================================

										IF NOT EXISTS(SELECT TOP 1 1 FROM tblICItemLocation WHERE intItemLocationId = @intNewItemLocationId)
											BEGIN
												SET @strResultMessage = 'Item Location is not created successfully'  

												GOTO ExitWithRollback
											END
										ELSE
											BEGIN
												
												-- Fill @intUniqueId to return to client side
												SET @intUniqueId = @intNewItemLocationId
											END

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
												
												-- =================================================================================
												-- [START] - ADD ITEM VENDOR DEBUG
												-- =================================================================================
												IF(@ysnDebug = 1)
													BEGIN
														SELECT 'New Added Item Vendor', * FROM tblICItemVendorXref WHERE intItemVendorXrefId = @intNewItemVendorXrefId
													END
												-- =================================================================================
												-- [END] - ADD ITEM VENDOR DEBUG
												-- =================================================================================

												IF NOT EXISTS(SELECT TOP 1 1 FROM tblICItemVendorXref WHERE intItemVendorXrefId = @intNewItemVendorXrefId)
													BEGIN

														SET @ysnResultSuccess = 0
														SET @strResultMessage = 'Item Vendor is not created successfully'  

														GOTO ExitWithRollback
													END
											END
										


											SELECT TOP 1
												@dblStandardCost_New	= dblCost
											FROM  @UDTItemCostPricing cp
												LEFT JOIN tblSTStore st
													ON cp.intStoreNo = st.intStoreNo
											WHERE st.intStoreId = @intStoreId_New
											
											SELECT TOP 1
												@dblSalePrice_New	= dblRetailPrice
											FROM  @UDTItemRetailPricing rp
												LEFT JOIN tblSTStore st
													ON rp.intStoreNo = st.intStoreNo
											WHERE st.intStoreId = @intStoreId_New

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
													
													-- =================================================================================
													-- [START] - ADD ITEM PRICING DEBUG
													-- =================================================================================
													IF(@ysnDebug = 1)
														BEGIN
															SELECT 'New Added Item Pricing', * FROM tblICItemPricing WHERE intItemPricingId = @intNewItemPricingId
														END
													-- =================================================================================
													-- [END] - ADD ITEM PRICING DEBUG
													-- =================================================================================

													IF NOT EXISTS(SELECT TOP 1 1 FROM tblICItemPricing WHERE intItemPricingId = @intNewItemPricingId)
														BEGIN
															SET @strResultMessage = 'Item Pricing is not created successfully'  

															GOTO ExitWithRollback
														END
														
													--Cost Loop
													WHILE EXISTS(SELECT TOP 1 1 FROM @tmp_CostEffectiveDate ce
																				INNER JOIN tblSTStore st
																					ON st.intStoreId = @intStoreId_New
																						AND ce.intStoreNo = st.intStoreNo)
														BEGIN

															DECLARE @intItemId_new					INT,
																	@intEffectiveItemCostId_new		INT,
																	@intPricingId_New				INT,
																	@intStoreNoCost_New				INT,
																	@dblCost_new					NUMERIC(18, 6),
																	@dtmEffectiveDate_new			DATETIME

									
															SELECT TOP 1
																	@intItemId_new					= @intNewItemId,
																	@intEffectiveItemCostId_new		= ce.intEffectiveItemCostId,
																	@intPricingId_New				= @intNewItemPricingId,
																	@intStoreNoCost_New				= ce.intStoreNo,
																	@dblCost_new					= ce.dblCost,
																	@dtmEffectiveDate_new			= ce.dtmEffectiveCostDate
															FROM @tmp_CostEffectiveDate ce

															-- ITEM LOCATION
															BEGIN TRY
										

																	EXEC [uspICUpdateItemPricingForCStore]
																		@intItemId						= @intItemId_new 
																		,@intItemPricingId				= @intPricingId_New
																		,@dblStandardCost				= @dblCost_new 
																		,@dtmEffectiveDate				= @dtmEffectiveDate_new
																		,@intEntityUserSecurityId		= @intEntityId
										
															END TRY
															BEGIN CATCH
																SET @strResultMessage = 'Error Adding Cost new Item Location: ' + ERROR_MESSAGE()  

																GOTO ExitWithRollback
															END CATCH
															
															DELETE @tmp_CostEffectiveDate 
															WHERE intStoreNo = @intStoreNoCost_New
																AND dtmEffectiveCostDate = @dtmEffectiveDate_new

														END
													
													--Retail Loop
													WHILE EXISTS(SELECT TOP 1 1 FROM @tmp_RetailEffectiveDate rp
																				INNER JOIN tblSTStore st
																					ON st.intStoreId = @intStoreId_New
																						AND rp.intStoreNo = st.intStoreNo)
														BEGIN

															DECLARE @intItemIdRetail_new				INT,
																	@intPricingIdRetail_New				INT,
																	@intStoreNoRetail_New				INT,
																	@dblRetail_new						NUMERIC(18, 6),
																	@dtmEffectiveDateRetail_new			DATETIME

									
															SELECT TOP 1
																	@intItemIdRetail_new		= @intNewItemId,
																	@intPricingIdRetail_New		= @intNewItemPricingId,
																	@intStoreNoRetail_New		= rp.intStoreNo,
																	@dblRetail_new				= rp.dblRetailPrice,
																	@dtmEffectiveDateRetail_new	= rp.dtmEffectiveRetailPriceDate
															FROM @tmp_RetailEffectiveDate rp

															-- ITEM LOCATION
															BEGIN TRY
																	EXEC [uspICUpdateItemPricingForCStore]
																		@intItemId						= @intItemIdRetail_new  
																		,@intItemPricingId				= @intPricingIdRetail_New
																		,@dblRetailPrice				= @dblRetail_new 
																		,@dtmEffectiveDate				= @dtmEffectiveDateRetail_new
																		,@intEntityUserSecurityId		= @intEntityId
										
															END TRY
															BEGIN CATCH
																SET @strResultMessage = 'Error Adding Retail new Item Location: ' + ERROR_MESSAGE()  

																GOTO ExitWithRollback
															END CATCH
															
															DELETE @tmp_RetailEffectiveDate 
															WHERE intStoreNo = @intStoreNoRetail_New
																AND dtmEffectiveRetailPriceDate = @dtmEffectiveDateRetail_new

														END
												END
												

									END TRY
									BEGIN CATCH
										SET @strResultMessage = 'Error Adding new Item Location: ' + ERROR_MESSAGE()  

										GOTO ExitWithRollback
									END CATCH


									SET @intNewItemLocationId		= NULL
									SET @intNewItemPricingId		= NULL
									SET @intNewItemVendorXrefId		= NULL


									DELETE @tempCStoreLocation 
									WHERE intStoreId = @intStoreId_New
										AND intCompanyLocationId = @intCompanyLocationId_New
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
						
					IF OBJECT_ID('tempdb..#tmpUpdateItemCostForCStoreEffectiveDate_AuditLog') IS NOT NULL  
						DROP TABLE #tmpUpdateItemCostForCStoreEffectiveDate_AuditLog 
						
					IF OBJECT_ID('tempdb..#tmpUpdateItemRetailForCStoreEffectiveDate_AuditLog') IS NOT NULL  
						DROP TABLE #tmpUpdateItemRetailForCStoreEffectiveDate_AuditLog 
						
					IF OBJECT_ID('tempdb..#tmpEffectiveDate') IS NOT NULL  
						DROP TABLE #tmpEffectiveDate 
						 
			END

			GOTO ExitWithCommit

	END TRY

	BEGIN CATCH
		SET @ysnResultSuccess = CAST(0 AS BIT)
		SET @strResultMessage = 'End script error: ' + ERROR_MESSAGE()  

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
		SET @intNewItemId		= 0
		SET @ysnResultSuccess	= 0
		SET @intUniqueId		= 0

		IF @InitTranCount = 0
			BEGIN
				IF ((XACT_STATE()) <> 0)
				BEGIN
					SET @strResultMessage = @strResultMessage + '. Will Rollback Transaction.'

					ROLLBACK TRANSACTION
				END
			END
			
		ELSE
			BEGIN
				IF ((XACT_STATE()) <> 0)
					BEGIN
						SET @strResultMessage = @strResultMessage + '. Will Rollback to Save point.'

						ROLLBACK TRANSACTION @Savepoint
					END
			END
			
				
		
		
	

		
ExitPost:
		

