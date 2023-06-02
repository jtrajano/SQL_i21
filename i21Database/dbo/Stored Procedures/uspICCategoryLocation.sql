CREATE PROCEDURE [dbo].[uspICCategoryLocation]

		@intCategoryLocationId INT,
		@intCategoryId INT,
		@intCurrentEntityUserId INT

AS
BEGIN TRY
	BEGIN TRANSACTION

		-- String holders
		DECLARE @ErrMsg AS NVARCHAR(1000) = ''
		DECLARE @strResultMsg AS NVARCHAR(1000) = ''
		
		DECLARE @strNewUseTaxFlag1ysn NVARCHAR(1),
			@strNewUseTaxFlag2ysn NVARCHAR(1),
			@strNewUseTaxFlag3ysn NVARCHAR(1),
			@strNewUseTaxFlag4ysn NVARCHAR(1),
			@strNewBlueLaw1ysn NVARCHAR(1),
			@strNewBlueLaw2ysn NVARCHAR(1),
			@strNewSaleAbleysn NVARCHAR(1),
			@intNewProductCodeId INT,
			@strNewFoodStampableysn NVARCHAR(1),
			@strNewReturnableysn NVARCHAR(1),
			@strNewPrePricedysn NVARCHAR(1),
			@strNewRequiredLiquorysn NVARCHAR(1),
			@strNewRequiredCigaretteysn NVARCHAR(1),
			@intNewMinimumAge INT

		SELECT 
			@strNewUseTaxFlag1ysn = ysnUseTaxFlag1,
			@strNewUseTaxFlag2ysn = ysnUseTaxFlag2,
			@strNewUseTaxFlag3ysn = ysnUseTaxFlag3,
			@strNewUseTaxFlag4ysn = ysnUseTaxFlag4,
			@strNewBlueLaw1ysn = ysnBlueLaw1,
			@strNewBlueLaw2ysn = ysnBlueLaw2,
			@strNewSaleAbleysn = ysnSaleable,
			@intNewProductCodeId = ysnSaleable,
			@strNewFoodStampableysn = ysnFoodStampable,
			@strNewReturnableysn = ysnReturnable,
			@strNewPrePricedysn = ysnPrePriced,
			@strNewRequiredLiquorysn = ysnIdRequiredLiquor,
			@strNewRequiredCigaretteysn = ysnIdRequiredCigarette,
			@intNewMinimumAge = intMinimumAge
		FROM tblICCategoryLocation
		WHERE intCategoryLocationId = @intCategoryLocationId

			BEGIN
				IF OBJECT_ID('tempdb..#tmpUpdateItemForCStore_Category') IS NULL  
					CREATE TABLE #tmpUpdateItemForCStore_Category (
						intCategoryId INT 
					)
			END

			-- Item Location Audit Log
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
					,dblTransactionQtyLimit_New NUMERIC(18, 6) NULL 
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


			IF(@intCategoryId IS NOT NULL AND @intCategoryId != 0)
				BEGIN
					INSERT INTO #tmpUpdateItemForCStore_Category (
						intCategoryId
					)
					SELECT [intID] AS intCategoryId
					FROM [dbo].[fnGetRowsFromDelimitedValues](@intCategoryId)
				END
		
		BEGIN TRY

			DECLARE @ysnTaxFlag1 AS BIT = CAST(@strNewUseTaxFlag1ysn AS BIT)
			DECLARE @ysnTaxFlag2 AS BIT = CAST(@strNewUseTaxFlag2ysn AS BIT)
			DECLARE @ysnTaxFlag3 AS BIT = CAST(@strNewUseTaxFlag3ysn AS BIT) 
			DECLARE @ysnTaxFlag4 AS BIT = CAST(@strNewUseTaxFlag4ysn AS BIT)
			DECLARE @ysnFoodStampable AS BIT = CAST(@strNewFoodStampableysn AS BIT)
			DECLARE @ysnReturnable AS BIT = CAST(@strNewReturnableysn AS BIT)
			DECLARE @ysnSaleable AS BIT = CAST(@strNewSaleAbleysn AS BIT)
			DECLARE @ysnPrePriced AS BIT = CAST(@strNewPrePricedysn AS BIT)
			DECLARE @ysnApplyBlueLaw1 AS BIT = CAST(@strNewBlueLaw1ysn AS BIT)
			DECLARE @ysnApplyBlueLaw2 AS BIT = CAST(@strNewBlueLaw2ysn AS BIT)
			DECLARE @ysnIdRequiredLiquor AS BIT = CAST(@strNewRequiredLiquorysn AS BIT)
			DECLARE @ysnIdRequiredCigarette AS BIT = CAST(@strNewRequiredCigaretteysn AS BIT)

			-- Item Location
			EXEC [dbo].[uspICUpdateItemLocationForCStore]
			    -- filter params
				@strUpcCode = NULL
				,@strDescription = NULL 
				,@dblRetailPriceFrom = NULL  
				,@dblRetailPriceTo =  NULL 
				,@intItemLocationId = NULL                -- *** SET VALUE TO UPDATE SPECIFIC RECORD ***
				-- update params 
				,@ysnTaxFlag1 = @ysnTaxFlag1
				,@ysnTaxFlag2 = @ysnTaxFlag2
				,@ysnTaxFlag3 = @ysnTaxFlag3
				,@ysnTaxFlag4 = @ysnTaxFlag4
				,@dblTransactionQtyLimit = NULL
				,@ysnDepositRequired = NULL
				,@intDepositPLUId = NULL 
				,@ysnQuantityRequired = NULL 
				,@ysnScaleItem = NULL 
				,@ysnFoodStampable = @ysnFoodStampable 
				,@ysnReturnable = @ysnReturnable 
				,@ysnSaleable = @ysnSaleable 
				,@ysnIdRequiredLiquor = @ysnIdRequiredLiquor 
				,@ysnIdRequiredCigarette = @ysnIdRequiredCigarette 
				,@ysnPromotionalItem = NULL
				,@ysnPrePriced = @ysnPrePriced 
				,@ysnApplyBlueLaw1 = @ysnApplyBlueLaw1 
				,@ysnApplyBlueLaw2 = @ysnApplyBlueLaw2 
				,@ysnCountedDaily = NULL 
				,@strCounted = NULL
				,@ysnCountBySINo = NULL 
				,@intFamilyId = NULL 
				,@intClassId = NULL 
				,@intProductCodeId = NULL 
				,@intVendorId =  NULL
				,@intMinimumAge = @intNewMinimumAge 
				,@dblMinOrder = NULL 
				,@dblSuggestedQty  = NULL
				,@strStorageUnitNo  = NULL
				,@intCountGroupId =  NULL
				,@intStorageLocationId = NULL 
				,@dblReorderPoint = NULL
				,@strItemLocationDescription = NULL 

				,@intEntityUserSecurityId = @intCurrentEntityUserId
		END TRY
		BEGIN CATCH
			SELECT 'uspICUpdateItemLocationForCStore', ERROR_MESSAGE()
			SET @strResultMsg = 'Error Message: ' + ERROR_MESSAGE()

			GOTO ExitWithRollback 
		END CATCH

			--clean up
			BEGIN
				IF OBJECT_ID('tempdb..#tmpUpdateItemForCStore_Category') IS NOT NULL 
					DROP TABLE #tmpUpdateItemForCStore_Category 

				IF OBJECT_ID('tempdb..#tmpUpdateItemLocationForCStore_itemLocationAuditLog') IS NOT NULL  
					DROP TABLE #tmpUpdateItemLocationForCStore_itemLocationAuditLog 
			END
			
		END TRY

	BEGIN CATCH      
	
		 SET @ErrMsg = ERROR_MESSAGE()     
		 --SET @strResultMsg = ERROR_MESSAGE()
		 SET @strResultMsg = 'Error Message: ' + ERROR_MESSAGE() --+ '<\BR>' + 
	 
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