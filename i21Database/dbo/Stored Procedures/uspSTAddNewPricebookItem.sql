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
											SET @intNewItemUOMId = NULL

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

			
			-- temp table for ItemPricing
			BEGIN
				DECLARE @tblItemCostPricing TABLE (
					intItemPricingId			INT
					, intEffectiveItemCostId	INT
					, intStoreNo				INT
					, intItemId					INT
					, dblCost					NUMERIC(38,20)
					, intCompanyLocationId		INT
					, intItemLocationId			INT
					, dtmCostEffectiveDate		DATETIME
				)
			END
			
			-- temp table for ItemPricing
			BEGIN
				DECLARE @tblItemRetailPricing TABLE (
					intItemPricingId			INT
					, intEffectiveItemPriceId	INT
					, intStoreNo				INT
					, intItemId					INT
					, dblRetailPrice			NUMERIC(38,20)
					, intCompanyLocationId		INT
					, intItemLocationId			INT
					, dtmRetailEffectiveDate	DATETIME
				)
			END

			-- ============================================================================================================================
			-- [START] - ITEM PRICING UPDATE - COST 
			-- ============================================================================================================================
			BEGIN
					IF EXISTS(SELECT TOP 1 1 FROM @UDTItemCostPricing)
						BEGIN

							INSERT INTO @tblItemCostPricing
							(
								intEffectiveItemCostId	
								, intStoreNo	
								, intItemId	
								, dblCost	
								, dtmCostEffectiveDate
								, intCompanyLocationId
								, intItemLocationId

							)
							SELECT DISTINCT
								intEffectiveItemCostId	= udt.intEffectiveItemCostId
								, intStoreNo				= st.intStoreNo
								, intItemId					= @intNewItemId
								, dblCost					= udt.dblCost
								, dtmCostEffectiveDate		= udt.dtmEffectiveCostDate
								, intCompanyLocationId		= st.intCompanyLocationId
								, intItemLocationId			= ISNULL(til.intItemLocationId, 0)
							FROM @UDTItemCostPricing udt
								INNER JOIN tblSTStore st
									ON udt.intStoreNo = st.intStoreNo
								LEFT JOIN tblICItemLocation til
									ON til.intLocationId = st.intCompanyLocationId
									AND til.intItemId = @intNewItemId

							DECLARE @intLoopEffectiveItemCostId	AS INT
							        , @intLoopStoreNo				AS INT
							        , @intLoopItemId				AS INT
									, @dblLoopCost					AS NUMERIC(38,20)
									, @dtmLoopCostEffectiveDate		AS DATETIME
									, @intLoopCompanyLocationId		AS INT
									, @intLoopItemLocationId		AS INT
									
							WHILE EXISTS(SELECT TOP 1 1 FROM @tblItemCostPricing)
								BEGIN
						
									SELECT TOP 1
										@intLoopEffectiveItemCostId	= temp.intEffectiveItemCostId
										, @intLoopStoreNo				= temp.intStoreNo
										, @intLoopItemId				= temp.intItemId
										, @dblLoopCost					= CAST(temp.dblCost AS NUMERIC(38, 20))
										, @dtmLoopCostEffectiveDate		= temp.dtmCostEffectiveDate
										, @intLoopCompanyLocationId		= temp.intCompanyLocationId
										, @intLoopItemLocationId		= temp.intItemLocationId
									FROM @tblItemCostPricing temp
									
										BEGIN TRY
											IF NOT EXISTS(SELECT TOP 1 1 FROM tblICItemLocation WHERE intItemLocationId = @intLoopItemLocationId AND intItemId = @intLoopItemId)
											BEGIN
											
											
												-- temp table for ItemPricing
												BEGIN
													DECLARE @tblCStoreItemPricing TABLE (
														intItemId					INT
														, dblStandardCost			NUMERIC(38,20)
														, dblLastCost				NUMERIC(38,20)
														, dblSalePrice				NUMERIC(38,20)
														, intCompanyLocationId		INT
													)
												END


												-- ============================================================================================================================
												-- [START] - ADD ITEM LOCATION
												-- ============================================================================================================================
												BEGIN
													BEGIN TRY
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
														SELECT TOP 1
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
														FROM tblSTStore st
														LEFT JOIN tblICCategoryLocation catLoc
															ON st.intCompanyLocationId = catLoc.intLocationId
														WHERE st.intCompanyLocationId IS NOT NULL
															AND st.intStoreNo = @intLoopStoreNo
													END TRY
													BEGIN CATCH
														SET @strResultMessage = 'Error creating location table: ' + ERROR_MESSAGE() 

														GOTO ExitWithRollback
													END CATCH

													INSERT INTO @tblCStoreItemPricing 
													(
														intItemId
														, dblStandardCost
														, intCompanyLocationId
													)
													SELECT intItemId				= @intLoopItemId
														, dblStandardCost		= @dblLoopCost
														, intCompanyLocationId  = @intLoopCompanyLocationId

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
																				

																IF EXISTS(SELECT TOP 1 1 FROM @tblCStoreItemPricing WHERE intCompanyLocationId = @intCompanyLocationId_New)
																	BEGIN
																		SELECT TOP 1
																			@dblStandardCost_New	= dblStandardCost
																		FROM @tblCStoreItemPricing 
																		WHERE intCompanyLocationId = @intCompanyLocationId_New

																		IF(@intNewItemId IS NOT NULL AND @intNewItemLocationId IS NOT NULL)
																			BEGIN
																						
																				-- ITEM PRICING
																				EXEC [uspICUpdateEffectivePricingForCStore]
																					@intItemId					= @intNewItemId
																					,@intItemLocationId			= @intNewItemLocationId

																					,@dblStandardCost			= @dblStandardCost_New 
																					,@dtmEffectiveDate			= @dtmLoopCostEffectiveDate 
																					,@intEntityUserSecurityId	= @intEntityId

																			END
																	END
															END TRY
															BEGIN CATCH
																SET @strResultMessage = 'Error Adding new Item Location: ' + ERROR_MESSAGE()  

																GOTO ExitWithRollback
															END CATCH


															SET @intNewItemLocationId		= NULL

														END
													END

												END
											
											--If item pricing is existing
											IF EXISTS(SELECT TOP 1 1 FROM tblICItemLocation WHERE intItemLocationId = @intLoopItemLocationId AND intItemId = @intLoopItemId)
											BEGIN
												
												EXEC [uspICUpdateEffectivePricingForCStore]
													-- filter params
													@strUpcCode					= NULL 
													, @strDescription			= NULL 
													, @intItemId				= @intLoopItemId 
													, @intItemLocationId		= @intLoopItemLocationId 

													-- update params
													, @dblStandardCost			= @dblLoopCost 
													, @dtmEffectiveDate			= @dtmLoopCostEffectiveDate 
													, @intEntityUserSecurityId	= @intEntityId
											END


										END TRY
										BEGIN CATCH
											SET @ysnResultSuccess = 0
											SET @strResultMessage = 'Error updating Item Pricing: ' + ERROR_MESSAGE()  

											GOTO ExitWithRollback
										END CATCH

									DELETE FROM @tempCStoreLocation

									DELETE FROM @tblItemCostPricing 
									WHERE intStoreNo = @intLoopStoreNo
										AND intItemId = @intLoopItemId 
										AND dblCost = @dblLoopCost 
										AND dtmCostEffectiveDate = @dtmLoopCostEffectiveDate 
										AND intItemLocationId = @intLoopItemLocationId
								END
						END 
			END
			-- ============================================================================================================================
			-- [END] - ITEM PRICING UPDATE - COST 
			-- ============================================================================================================================
			
			
			-- ============================================================================================================================
			-- [START] - ITEM PRICING UPDATE - PRICE 
			-- ============================================================================================================================
			BEGIN
					IF EXISTS(SELECT TOP 1 1 FROM @UDTItemRetailPricing)
						BEGIN
						
							INSERT INTO @tblItemRetailPricing
							(
								intEffectiveItemPriceId	
								, intStoreNo	
								, intItemId	
								, dblRetailPrice	
								, dtmRetailEffectiveDate
								, intCompanyLocationId
								, intItemLocationId

							)
							SELECT DISTINCT
								intEffectiveItemPriceId		= udt.intEffectiveItemPriceId
								, intStoreNo				= st.intStoreNo
								, intItemId					= @intNewItemId
								, dblRetailPrice			= udt.dblRetailPrice
								, dtmCostEffectiveDate		= udt.dtmEffectiveRetailPriceDate
								, intCompanyLocationId		= st.intCompanyLocationId
								, intItemLocationId			= ISNULL(til.intItemLocationId, 0)
							FROM @UDTItemRetailPricing udt
								INNER JOIN tblSTStore st
									ON udt.intStoreNo = st.intStoreNo
								LEFT JOIN tblICItemLocation til
									ON til.intLocationId = st.intCompanyLocationId
									AND til.intItemId = @intNewItemId

							DECLARE @intLoopRetailEffectiveItemCostId		AS INT
							        , @intLoopRetailStoreNo					AS INT
							        , @intLoopRetailItemId					AS INT
									, @dblLoopRetail						AS NUMERIC(38,20)
									, @dtmLoopRetailEffectiveDate			AS DATETIME
									, @intLoopRetailCompanyLocationId		AS INT
									, @intLoopRetailItemLocationId			AS INT
									
							WHILE EXISTS(SELECT TOP 1 1 FROM @tblItemRetailPricing)
								BEGIN

									SELECT TOP 1 @intLoopRetailEffectiveItemCostId		= temp.intEffectiveItemPriceId
										, @intLoopRetailStoreNo							= temp.intStoreNo
										, @intLoopRetailItemId							= temp.intItemId
										, @dblLoopRetail								= CAST(temp.dblRetailPrice AS NUMERIC(38, 20))
										, @dtmLoopRetailEffectiveDate					= temp.dtmRetailEffectiveDate
										, @intLoopRetailCompanyLocationId				= temp.intCompanyLocationId
										, @intLoopRetailItemLocationId					= temp.intItemLocationId
									FROM @tblItemRetailPricing temp
										BEGIN TRY
										

											IF NOT EXISTS(SELECT TOP 1 1 FROM tblICItemLocation WHERE intItemLocationId = @intLoopRetailItemLocationId AND intItemId = @intLoopRetailItemId)
											BEGIN
											
												DECLARE @intNewItemRetailLocationId	AS INT
											

												-- temp table for ItemPricing
												BEGIN
													DECLARE @tblCStoreItemRetailPricing TABLE (
														intItemId					INT
														, dblStandardCost			NUMERIC(38,20)
														, dblLastCost				NUMERIC(38,20)
														, dblSalePrice				NUMERIC(38,20)
														, intCompanyLocationId		INT
													)
												END
												

												-- temp table for ItemLocations
												BEGIN
													DECLARE @tempCStoreRetailLocation TABLE
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
												-- [START] - ADD ITEM LOCATION
												-- ============================================================================================================================
												BEGIN
													BEGIN TRY
														INSERT INTO @tempCStoreRetailLocation
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
														SELECT TOP 1
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
														FROM tblSTStore st
														LEFT JOIN tblICCategoryLocation catLoc
															ON st.intCompanyLocationId = catLoc.intLocationId
														WHERE st.intCompanyLocationId IS NOT NULL
															AND st.intStoreNo = @intLoopRetailStoreNo
															--AND catLoc.intCategoryId = @intCategoryId

															
													END TRY
													BEGIN CATCH
														SET @strResultMessage = 'Error creating location table: ' + ERROR_MESSAGE() 

														GOTO ExitWithRollback
													END CATCH

													

													--Truncate table before insert
													DELETE FROM @tblCStoreItemPricing

													INSERT INTO @tblCStoreItemPricing 
													(
														intItemId
														, dblSalePrice
														, intCompanyLocationId
													)
													SELECT 
														intItemId				= @intLoopRetailItemId
														, dblSalePrice			= @dblLoopRetail
														, intCompanyLocationId  = @intLoopRetailCompanyLocationId

													IF EXISTS(SELECT TOP 1 1 FROM @tempCStoreRetailLocation)
														BEGIN
							
															DECLARE @intRetailStoreId_New					INT,
																	@intRetailCompanyLocationId_New			INT,
																	@ysnRetailUseTaxFlag1_New				BIT,
																	@ysnRetailUseTaxFlag2_New				BIT,
																	@ysnRetailUseTaxFlag3_New				BIT,
																	@ysnRetailUseTaxFlag4_New				BIT,
																	@ysnRetailBlueLaw1_New				BIT,
																	@ysnRetailBlueLaw2_New				BIT,
																	@ysnRetailFoodStampable_New			BIT,
																	@ysnRetailReturnable_New				BIT,
																	@ysnRetailSaleable_New				BIT,
																	@ysnRetailPrePriced_New				BIT,
																	@ysnRetailIdRequiredLiquor_New		BIT,
																	@ysnRetailIdRequiredCigarette_New		BIT,
																	@intRetailProductCodeId_New			INT,
																	@intRetailFamilyId_New				INT,
																	@intRetailClassId_New					INT,
																	@intRetailMinimumAge_New				INT,
																		
																	@dblRetailStandardCost_New			NUMERIC(18, 6),
																	@dblRetailLastCost_New				NUMERIC(18, 6),
																	@dblRetailSalePrice_New				NUMERIC(18, 6)

															SELECT TOP 1
																	@intRetailStoreId_New				= intStoreId,
																	@intRetailCompanyLocationId_New	= intCompanyLocationId,
																	@ysnRetailUseTaxFlag1_New			= ysnUseTaxFlag1,
																	@ysnRetailUseTaxFlag2_New			= ysnUseTaxFlag2,
																	@ysnRetailUseTaxFlag3_New			= ysnUseTaxFlag3,
																	@ysnRetailUseTaxFlag4_New			= ysnUseTaxFlag4,
																	@ysnRetailBlueLaw1_New			= ysnBlueLaw1,
																	@ysnRetailBlueLaw2_New			= ysnBlueLaw2,
																	@ysnRetailFoodStampable_New		= ysnFoodStampable,
																	@ysnRetailReturnable_New			= ysnReturnable,
																	@ysnRetailSaleable_New			= ysnSaleable,
																	@ysnRetailPrePriced_New			= ysnPrePriced,
																	@ysnRetailIdRequiredLiquor_New	= ysnIdRequiredLiquor,
																	@ysnRetailIdRequiredCigarette_New	= ysnIdRequiredCigarette,
																	@intRetailProductCodeId_New		= intProductCodeId,
																	@intRetailFamilyId_New			= intFamilyId,
																	@intRetailClassId_New				= intClassId,
																	@intRetailMinimumAge_New			= intMinimumAge
															FROM @tempCStoreRetailLocation

									
															-- =================================================================================
															-- [START] - ADD ITEM LOCATION DEBUG
															-- =================================================================================
															IF(@ysnDebug = 1)
																BEGIN
																		SELECT 'LOOP', @intStoreId_New, @intRetailCompanyLocationId_New, @ysnUseTaxFlag1_New, @ysnUseTaxFlag2_New, @ysnUseTaxFlag3_New, @ysnUseTaxFlag4_New, @ysnBlueLaw1_New, @ysnBlueLaw2_New, @ysnFoodStampable_New,
																						@ysnReturnable_New, @ysnSaleable_New, @ysnPrePriced_New, @ysnIdRequiredLiquor_New, @ysnIdRequiredCigarette_New, @intProductCodeId_New, @intFamilyId_New, @intClassId_New, @intMinimumAge_New
																END
															-- =================================================================================
															-- [END] - ADD ITEM LOCATION DEBUG
															-- =================================================================================

	
															-- ITEM LOCATION
															BEGIN TRY
										

															EXEC [uspICAddItemLocationForCStore]
																@intLocationId				= @intRetailCompanyLocationId_New 
																,@intItemId					= @intNewItemId
																								  
																,@ysnTaxFlag1				= @ysnRetailUseTaxFlag1_New 
																,@ysnTaxFlag2				= @ysnRetailUseTaxFlag2_New
																,@ysnTaxFlag3				= @ysnRetailUseTaxFlag3_New
																,@ysnTaxFlag4				= @ysnRetailUseTaxFlag4_New
																,@ysnApplyBlueLaw1			= @ysnRetailBlueLaw1_New
																,@ysnApplyBlueLaw2			= @ysnRetailBlueLaw2_New
																,@intProductCodeId			= @intRetailProductCodeId_New
																,@intFamilyId				= @intRetailFamilyId_New
																,@intClassId				= @intRetailClassId_New
																,@ysnFoodStampable			= @ysnRetailFoodStampable_New
																,@ysnReturnable				= @ysnRetailReturnable_New
																,@ysnSaleable				= @ysnRetailSaleable_New
																,@ysnPrePriced				= @ysnRetailPrePriced_New
																,@ysnIdRequiredLiquor		= @ysnRetailIdRequiredLiquor_New
																,@ysnIdRequiredCigarette	= @ysnRetailIdRequiredCigarette_New
																,@intMinimumAge				= @intRetailMinimumAge_New
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
																		

																IF EXISTS(SELECT TOP 1 1 FROM @tblCStoreItemPricing WHERE intCompanyLocationId = @intRetailCompanyLocationId_New)
																	BEGIN
																		SELECT TOP 1
																			@dblSalePrice_New	= dblSalePrice
																		FROM @tblCStoreItemPricing 
																		WHERE intCompanyLocationId = @intCompanyLocationId_New
																		

																		IF(@intNewItemId IS NOT NULL AND @intNewItemLocationId IS NOT NULL)
																			BEGIN
																				-- To add Effective Dates on IC
																				EXEC [uspICUpdateEffectivePricingForCStore]
																					-- filter params
																					@strUpcCode					= NULL 
																					, @strDescription			= NULL 
																					, @intItemId				= @intNewItemId 
																					, @intItemLocationId		= @intNewItemLocationId 

																					-- update params
																					, @dblRetailPrice			= @dblLoopRetail 
																					, @dtmEffectiveDate			= @dtmLoopRetailEffectiveDate 
																					, @intEntityUserSecurityId	= @intEntityId
																			END
																	END
															END TRY
															BEGIN CATCH
																SET @strResultMessage = 'Error Adding new Item Location: ' + ERROR_MESSAGE()  

																GOTO ExitWithRollback
															END CATCH


															SET @intNewItemLocationId		= NULL

														END
													END

												END
											
											

											--If item effective pricing PRICE is existing
											IF EXISTS(SELECT TOP 1 1 FROM tblICItemLocation WHERE intItemLocationId = @intLoopRetailItemLocationId AND intItemId = @intLoopRetailItemId)
											BEGIN				

												EXEC [uspICUpdateEffectivePricingForCStore]
													-- filter params
													@strUpcCode					= NULL 
													, @strDescription			= NULL 
													, @intItemId				= @intLoopRetailItemId 
													, @intItemLocationId		= @intLoopRetailItemLocationId 

													-- update params
													, @dblRetailPrice			= @dblLoopRetail 
													, @dtmEffectiveDate			= @dtmLoopRetailEffectiveDate 
													, @intEntityUserSecurityId	= @intEntityId
											END
											

										END TRY
										BEGIN CATCH
											SET @ysnResultSuccess = 0
											SET @strResultMessage = 'Error updating Item Pricing: ' + ERROR_MESSAGE()  

											GOTO ExitWithRollback
										END CATCH
										
									DELETE FROM @tempCStoreRetailLocation 

									DELETE FROM @tblItemRetailPricing 
									WHERE intStoreNo = @intLoopRetailStoreNo
										AND intItemId = @intLoopRetailItemId 
										AND dtmRetailEffectiveDate = @dtmLoopRetailEffectiveDate 
										AND intItemLocationId = @intLoopRetailItemLocationId
								END
						END 
			END
			
			-- ============================================================================================================================
			-- [END] - ITEM PRICING UPDATE - PRICE 
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
		

