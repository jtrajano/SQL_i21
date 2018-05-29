CREATE PROCEDURE [dbo].[uspSTUpdateItemData]
		-- Add the parameters for the stored procedure here
		@XML varchar(max),
		@strResultMsg NVARCHAR(1000) OUTPUT
	AS
BEGIN TRY
	    
		DECLARE @ErrMsg					   NVARCHAR(MAX),
				@idoc					   INT,
				@strCompanyLocationId 	   NVARCHAR(MAX),
				@strVendorId               NVARCHAR(MAX),
				@strCategoryId             NVARCHAR(MAX),
				@strFamilyId			   NVARCHAR(MAX),
				@strClassId                NVARCHAR(MAX),
				@intUpcCode                INT,
				@strDescription            NVARCHAR(250),
				@dblPriceBetween1          DECIMAL (18,6),
				@dblPriceBetween2          DECIMAL (18,6),
				@strTaxFlag1ysn            NVARCHAR(1),
				@strTaxFlag2ysn            NVARCHAR(1),
				@strTaxFlag3ysn            NVARCHAR(1),
				@strTaxFlag4ysn            NVARCHAR(1),
				@strDepositRequiredysn     NVARCHAR(1),
				@intDepositPLU             INT,
				@strQuantityRequiredysn    NVARCHAR(1),
				@strScaleItemysn           NVARCHAR(1),
				@strFoodStampableysn       NVARCHAR(1),
				@strReturnableysn          NVARCHAR(1),
				@strSaleableysn            NVARCHAR(1),
				@strID1Requiredysn         NVARCHAR(1),
				@strID2Requiredysn         NVARCHAR(1),
				@strPromotionalItemysn     NVARCHAR(1),
				@strPrePricedysn           NVARCHAR(1),
				@strActiveysn              NVARCHAR(1),
				@strBlueLaw1ysn            NVARCHAR(1),
				@strBlueLaw2ysn            NVARCHAR(1),
				@strCountedDailyysn        NVARCHAR(1),
				@strCounted                NVARCHAR(50),
				@strCountSerialysn         NVARCHAR(1),
				@strStickReadingysn        NVARCHAR(1),
				@intNewFamily              INT,
				@intNewClass               INT,
				@intNewProductCode         INT,
				@intNewCategory            INT,
				@intNewVendor              INT,
				@intNewInventoryGroup      INT,
				@strNewCountCode           NVARCHAR(50),     
				@intNewMinAge              INT,
				@dblNewMinVendorOrderQty   DECIMAL(18,6),
				@dblNewVendorSuggestedQty  DECIMAL(18,6),
				@dblNewMinQtyOnHand        DECIMAL(18,6),
				@intNewBinLocation         INT,
				@intNewGLPurchaseAccount   INT,
				@intNewGLSalesAccount      INT,
				--@intNewGLVarianceAccount      INT,
				@strYsnPreview             NVARCHAR(1),
				@currentUserId			   INT
		SET @strResultMsg = 'success'

	                  
		EXEC sp_xml_preparedocument @idoc OUTPUT, @XML 
	
		SELECT	
				@strCompanyLocationId	   	 =	 Location,
				@strVendorId          =   Vendor,
				@strCategoryId        =   Category,
				@strFamilyId          =   Family,
				@strClassId           =   Class,
				@intUpcCode         =   UPCCode,
				@strDescription     =   ItmDescription,

				@dblPriceBetween1   =   PriceBetween1,
				@dblPriceBetween2   =   PriceBetween2,
				@strTaxFlag1ysn     =   TaxFlag1ysn,
				@strTaxFlag2ysn     =   TaxFlag2ysn ,           
				@strTaxFlag3ysn     =   TaxFlag3ysn,          
				@strTaxFlag4ysn     =   TaxFlag4ysn,           
				@strDepositRequiredysn = DepositRequiredysn, 
				@intDepositPLU       =  DepositPLU,
				@strQuantityRequiredysn = QuantityRequiredysn,
				@strScaleItemysn     =  ScaleItemysn,
				@strFoodStampableysn =  FoodStampableysn,
				@strReturnableysn    =  Returnableysn,
				@strSaleableysn      =  Saleableysn,
				@strID1Requiredysn   =  ID1Requiredysn,                  
				@strID2Requiredysn   =  ID2Requiredysn,
				@strPromotionalItemysn = PromotionalItemysn,
				@strPrePricedysn     =  PrePricedysn,
				@strActiveysn        =  Activeysn,
				@strBlueLaw1ysn      =  BlueLaw1ysn,
				@strBlueLaw2ysn      =  BlueLaw2ysn,
				@strCountedDailyysn  =  CountedDailyysn,
				@strCounted          =  Counted,
				@strCountSerialysn   =  CountSerialysn,
				@strStickReadingysn  =  StickReadingysn,
				@intNewFamily        =  NewFamily,
				@intNewClass         =  NewClass,
				@intNewProductCode   =  NewProductCode,
				@intNewCategory      =  NewCategory,
				@intNewVendor        =  NewVendor,
				@intNewInventoryGroup = NewInventoryGroup,
				@strNewCountCode       = NewCountCode,
				@intNewMinAge          = NewMinAge,
				@dblNewMinVendorOrderQty = NewMinVendorOrderQty,
				@dblNewVendorSuggestedQty = NewVendorSuggestedQty,
				@dblNewMinQtyOnHand     = NewMinQtyOnHand,
				@intNewBinLocation      = NewBinLocation,
				@intNewGLPurchaseAccount  = NewGLPurchaseAccount,
			    @intNewGLSalesAccount     = NewGLSalesAccount,
			    --@NewGLVarianceAccount  = NewGLVarianceAccount,
				@strYsnPreview     = ysnPreview,
		        @currentUserId   =   currentUserId
		
		FROM	OPENXML(@idoc, 'root',2)
		WITH
		(
				Location 			      NVARCHAR(MAX),
				Vendor                    NVARCHAR(MAX),
				Category                  NVARCHAR(MAX),
				Family                    NVARCHAR(MAX),
				Class                     NVARCHAR(MAX),
				UPCCode                   INT,
				ItmDescription            NVARCHAR(250),

				PriceBetween1             DECIMAL (18,6),
				PriceBetween2             DECIMAL (18,6),
				TaxFlag1ysn               NVARCHAR(1),
				TaxFlag2ysn               NVARCHAR(1),
				TaxFlag3ysn               NVARCHAR(1),
				TaxFlag4ysn               NVARCHAR(1),
				DepositRequiredysn        NVARCHAR(1),
				DepositPLU                INT,
				QuantityRequiredysn       NVARCHAR(1),
				ScaleItemysn              NVARCHAR(1),
				FoodStampableysn          NVARCHAR(1),
				Returnableysn             NVARCHAR(1),
				Saleableysn               NVARCHAR(1),
				ID1Requiredysn            NVARCHAR(1),
				ID2Requiredysn            NVARCHAR(1),
				PromotionalItemysn        NVARCHAR(1),
				PrePricedysn              NVARCHAR(1),
				Activeysn                 NVARCHAR(1),
				BlueLaw1ysn               NVARCHAR(1),
				BlueLaw2ysn               NVARCHAR(1),
				CountedDailyysn           NVARCHAR(1),
				Counted                   NVARCHAR(50),
				CountSerialysn            NVARCHAR(1),
				StickReadingysn           NVARCHAR(1),
				NewFamily                 INT,
				NewClass                  INT,
				NewProductCode            INT,
				NewCategory               INT,
				NewVendor                 INT,
				NewInventoryGroup         INT,
				NewCountCode              NVARCHAR(50),     
				NewMinAge                 INT,
				NewMinVendorOrderQty      DECIMAL(18,6),
				NewVendorSuggestedQty     DECIMAL(18,6),
				NewMinQtyOnHand           DECIMAL(18,6),
				NewBinLocation            INT,
				NewGLPurchaseAccount      INT,
			    NewGLSalesAccount         INT,
				--NewGLVarianceAccount      INT,
				ysnPreview                NVARCHAR(1),
				currentUserId			  INT
			)  
		-- Insert statements for procedure here


		-- Create the temp table used for filtering. 
		BEGIN
			
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
		END 


		-- Item Audit Log
		IF OBJECT_ID('tempdb..#tmpUpdateItemForCStore_itemAuditLog') IS NULL  
			CREATE TABLE #tmpUpdateItemForCStore_itemAuditLog (
				intItemId INT
				-- Original Fields
				,intCategoryId_Original INT NULL
				,strCountCode_Original NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
				,strDescription_Original NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL
				-- Modified Fields
				,intCategoryId_New INT NULL
				,strCountCode_New NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
				,strDescription_New NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL
			)
		;

		-- Item Account Audit Log
		IF OBJECT_ID('tempdb..#tmpUpdateItemAccountForCStore_itemAuditLog') IS NULL  
			CREATE TABLE #tmpUpdateItemAccountForCStore_itemAuditLog (
				intItemId INT
				, intItemAccountId INT		
				, intAccountCategoryId INT 
				, strAction NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL	
				-- Original Fields	
				, intAccountId_Original INT NULL	
				-- Modified Fields	
				, intAccountId_New INT NULL		
			)
		;

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


		-- Add the filter records
		BEGIN
			IF(@strCompanyLocationId IS NOT NULL AND @strCompanyLocationId != '')
				BEGIN
					INSERT INTO #tmpUpdateItemForCStore_Location (
						intLocationId
					)
					--SELECT intLocationId = CAST(@strCompanyLocationId AS INT)
					SELECT [intID] AS intLocationId
					FROM [dbo].[fnGetRowsFromDelimitedValues](@strCompanyLocationId)
				END
		
			IF(@strVendorId IS NOT NULL AND @strVendorId != '')
				BEGIN
					INSERT INTO #tmpUpdateItemForCStore_Vendor (
						intVendorId
					)
					--SELECT intVendorId = CAST(@strVendorId AS INT)
					SELECT [intID] AS intVendorId
					FROM [dbo].[fnGetRowsFromDelimitedValues](@strVendorId)
				END

			IF(@strCategoryId IS NOT NULL AND @strCategoryId != '')
				BEGIN
					INSERT INTO #tmpUpdateItemForCStore_Category (
						intCategoryId
					)
					--SELECT intCategoryId = CAST(@strCategoryId AS INT)
					SELECT [intID] AS intCategoryId
					FROM [dbo].[fnGetRowsFromDelimitedValues](@strCategoryId)
				END

			IF(@strFamilyId IS NOT NULL AND @strFamilyId != '')
				BEGIN
					INSERT INTO #tmpUpdateItemForCStore_Family (
						intFamilyId
					)
					--SELECT intFamilyId = CAST(@strFamilyId AS INT)
					SELECT [intID] AS intFamilyId
					FROM [dbo].[fnGetRowsFromDelimitedValues](@strFamilyId)
				END

			IF(@strClassId IS NOT NULL AND @strClassId != '')
				BEGIN
					INSERT INTO #tmpUpdateItemForCStore_Class (
						intClassId
					)
					--SELECT intClassId = CAST(@strClassId AS INT)
					SELECT [intID] AS intClassId
					FROM [dbo].[fnGetRowsFromDelimitedValues](@strClassId)
				END
		END


		-- Get strUpcCode
		DECLARE @strUpcCode AS NVARCHAR(20) = (
												SELECT CASE
															WHEN strLongUPCCode IS NOT NULL AND strLongUPCCode != '' THEN strLongUPCCode ELSE strUpcCode
													   END AS strUpcCode
												FROM tblICItemUOM 
												WHERE intItemUOMId = @intUpcCode
											  )

		BEGIN 
			-- Item Update
			EXEC [dbo].[uspICUpdateItemForCStore]
					@strUpcCode = @strUpcCode 
					,@strDescription = @strDescription 
					,@dblRetailPriceFrom = NULL  
					,@dblRetailPriceTo = NULL 

					,@intCategoryId = @intNewCategory
					,@strCountCode = @strNewCountCode
					,@strItemDescription = NULL

					,@intEntityUserSecurityId = @currentUserId
		END


		BEGIN 
			-- Item Account
			EXEC [dbo].[uspICUpdateItemAccountForCStore]
				-- filter params
				@strUpcCode = @strUpcCode 
				,@strDescription = @strDescription 
				,@dblRetailPriceFrom = NULL  
				,@dblRetailPriceTo = NULL 
				-- update params
				,@intGLAccountCOGS = @intNewGLPurchaseAccount		-- If 'Cost of Goods'
				,@intGLAccountSalesRevenue = @intNewGLSalesAccount	-- If 'Sales Account'

				,@intEntityUserSecurityId = @currentUserId
		END


		BEGIN 
			-- Item Location

			DECLARE @ysnTaxFlag1 AS BIT = CAST(@strTaxFlag1ysn AS BIT)
			DECLARE @ysnTaxFlag2 AS BIT = CAST(@strTaxFlag2ysn AS BIT)
			DECLARE @ysnTaxFlag3 AS BIT = CAST(@strTaxFlag3ysn AS BIT)
			DECLARE @ysnTaxFlag4 AS BIT = CAST(@strTaxFlag4ysn AS BIT)
			DECLARE @ysnDepositRequired AS BIT = CAST(@strDepositRequiredysn AS BIT)
			--@intDepositPLU
			DECLARE @ysnQuantityRequired AS BIT = CAST(@strQuantityRequiredysn AS BIT)
			DECLARE @ysnScaleItem AS BIT = CAST(@strScaleItemysn AS BIT)
			DECLARE @ysnFoodStampable AS BIT = CAST(@strFoodStampableysn AS BIT)
			DECLARE @ysnReturnable AS BIT = CAST(@strReturnableysn AS BIT)
			DECLARE @ysnSaleable AS BIT = CAST(@strSaleableysn AS BIT)
			DECLARE @ysnIdRequiredCigarette AS BIT = CAST(@strID1Requiredysn AS BIT)
			DECLARE @ysnIdRequiredLiquor AS BIT = CAST(@strID2Requiredysn AS BIT)
			DECLARE @ysnPromotionalItem AS BIT = CAST(@strPromotionalItemysn AS BIT)
			DECLARE @ysnPrePriced AS BIT = CAST(@strPrePricedysn AS BIT)
			DECLARE @ysnApplyBlueLaw1 AS BIT = CAST(@strBlueLaw1ysn AS BIT)
			DECLARE @ysnApplyBlueLaw2 AS BIT = CAST(@strBlueLaw2ysn AS BIT)
			DECLARE @ysnCountedDaily AS BIT = CAST(@strCountedDailyysn AS BIT)
			DECLARE @ysnCountBySINo AS BIT = CAST(@strCountSerialysn AS BIT)
			DECLARE @intFamilyId AS INT = CAST(@intNewFamily AS INT)
			DECLARE @intClassId AS INT = CAST(@intNewClass AS INT)
			DECLARE @intVendorId AS INT = CAST(@intNewVendor AS INT)


			EXEC [dbo].[uspICUpdateItemLocationForCStore]
			    -- filter params
				@strUpcCode = @strUpcCode 
				,@strDescription = @strDescription 
				,@dblRetailPriceFrom = NULL  
				,@dblRetailPriceTo = NULL 
				,@intItemLocationId = NULL 
				-- update params 
				,@ysnTaxFlag1 = @ysnTaxFlag1
				,@ysnTaxFlag2 = @ysnTaxFlag2
				,@ysnTaxFlag3 = @ysnTaxFlag3
				,@ysnTaxFlag4 = @ysnTaxFlag4
				,@ysnDepositRequired = @ysnDepositRequired
				,@intDepositPLUId = @intDepositPLU 
				,@ysnQuantityRequired = @ysnQuantityRequired 
				,@ysnScaleItem = @ysnScaleItem 
				,@ysnFoodStampable = @ysnFoodStampable 
				,@ysnReturnable = @ysnReturnable 
				,@ysnSaleable = @ysnSaleable 
				,@ysnIdRequiredLiquor = @ysnIdRequiredLiquor 
				,@ysnIdRequiredCigarette = @ysnIdRequiredCigarette 
				,@ysnPromotionalItem = @ysnPromotionalItem 
				,@ysnPrePriced = @ysnPrePriced 
				,@ysnApplyBlueLaw1 = @ysnApplyBlueLaw1 
				,@ysnApplyBlueLaw2 = @ysnApplyBlueLaw2 
				,@ysnCountedDaily = @ysnCountedDaily 
				,@strCounted = @strCounted
				,@ysnCountBySINo = @ysnCountBySINo 
				,@intFamilyId = @intFamilyId 
				,@intClassId = @intClassId 
				,@intProductCodeId = @intNewProductCode 
				,@intVendorId =  @intVendorId
				,@intMinimumAge = @intNewMinAge 
				,@dblMinOrder = @dblNewMinVendorOrderQty 
				,@dblSuggestedQty  = @dblNewVendorSuggestedQty
				,@intCountGroupId =  NULL
				,@intStorageLocationId = @intNewBinLocation 
				,@dblReorderPoint = NULL
				,@strItemLocationDescription = NULL 

				,@intEntityUserSecurityId = @currentUserId
		END


	DECLARE @RecCount AS INT = 0
	DECLARE @UpdateCount AS INT = 0

	SET @RecCount = @RecCount + (SELECT DISTINCT COUNT(intItemId) FROM #tmpUpdateItemForCStore_itemAuditLog)
	SET @RecCount = @RecCount + (SELECT DISTINCT COUNT(intItemAccountId) FROM #tmpUpdateItemAccountForCStore_itemAuditLog)
	SET @RecCount = @RecCount + (SELECT DISTINCT COUNT(intItemLocationId) FROM #tmpUpdateItemLocationForCStore_itemLocationAuditLog)
	SET @UpdateCount = @RecCount
	--SET @UpdateCount = @UpdateCount + (SELECT COUNT(DISTINCT intItemPricingId) FROM #tmpUpdateItemPricingForCStore_ItemPricingAuditLog)
	--SET @UpdateCount = @UpdateCount + (SELECT COUNT(DISTINCT intItemSpecialPricingId) FROM #tmpUpdateItemPricingForCStore_ItemSpecialPricingAuditLog)

	--SELECT @UpdateCount as UpdateItemPrcicingCount, @RecCount as RecCount
	SELECT  @RecCount as RecCount,  @UpdateCount as UpdateItemDataCount	


		-- Clean up 
		BEGIN
			IF OBJECT_ID('tempdb..#tmpUpdateItemForCStore_Location') IS NULL  
				DROP TABLE #tmpUpdateItemForCStore_Location 

			IF OBJECT_ID('tempdb..#tmpUpdateItemForCStore_Vendor') IS NULL  
				DROP TABLE #tmpUpdateItemForCStore_Vendor 

			IF OBJECT_ID('tempdb..#tmpUpdateItemForCStore_Category') IS NULL  
				DROP TABLE #tmpUpdateItemForCStore_Category 

			IF OBJECT_ID('tempdb..#tmpUpdateItemForCStore_Family') IS NULL  
				DROP TABLE #tmpUpdateItemForCStore_Family 

			IF OBJECT_ID('tempdb..#tmpUpdateItemForCStore_Class') IS NULL  
				DROP TABLE #tmpUpdateItemForCStore_Class 

			IF OBJECT_ID('tempdb..#tmpUpdateItemForCStore_itemAuditLog') IS NOT NULL  
				DROP TABLE #tmpUpdateItemForCStore_itemAuditLog 

			IF OBJECT_ID('tempdb..#tmpUpdateItemAccountForCStore_itemAuditLog') IS NOT NULL  
				DROP TABLE #tmpUpdateItemAccountForCStore_itemAuditLog 

			IF OBJECT_ID('tempdb..#tmpUpdateItemLocationForCStore_itemLocationAuditLog') IS NOT NULL  
				DROP TABLE #tmpUpdateItemLocationForCStore_itemLocationAuditLog 
		END

END TRY

BEGIN CATCH       
	 SET @ErrMsg = ERROR_MESSAGE()     
	 --SET @strResultMsg = ERROR_MESSAGE()
	 SET @strResultMsg = 'Error Message: ' + ERROR_MESSAGE() --+ '<\BR>' + 
	 IF @idoc <> 0 EXEC sp_xml_removedocument @idoc      
	 --RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')      
END CATCH