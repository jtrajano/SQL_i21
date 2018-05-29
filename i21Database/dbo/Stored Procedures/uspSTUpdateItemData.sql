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



		---------------------------------------------------------------
		---------- Table to handle different data types ---------------
		---------------------------------------------------------------
		-- ITEM
		DECLARE @tblUpdateItemForCStore TABLE (
				intItemId INT
				-- Original Fields
				,strCategoryCode_Original NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL
				,strCountCode_Original NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL
				,strDescription_Original NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL
				-- Modified Fields
				,strCategoryCode_New NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL
				,strCountCode_New NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL
				,strDescription_New NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL
		)

		-- ITEM ACCOUNT
		DECLARE @tblItemAccountForCStore TABLE (
				intItemId INT
				, intItemAccountId INT		
				, intAccountCategoryId INT 
				, strAction NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL	
				-- Original Fields	
				, strAccountId_Original NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL	
				, intAccountId_Original INT NULL	
				-- Modified Fields	
				, strAccountId_New NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL	
				, intAccountId_New INT NULL	
		)

		-- ITEM LOCATION
		DECLARE @tblItemLocationForCStore TABLE (
				intItemId INT
				,intItemLocationId INT 
				-- Original Fields
				,strTaxFlag1_Original NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL
				,strTaxFlag2_Original NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL
				,strTaxFlag3_Original NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL
				,strTaxFlag4_Original NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL
				,strDepositRequired_Original NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL
				,intDepositPLUId_Original INT NULL 
				,strDepositPLUId_Original NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL
				,strQuantityRequired_Original NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL
				,strScaleItem_Original NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL
				,strFoodStampable_Original NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL
				,strReturnable_Original NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL
				,strSaleable_Original NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL
				,strIdRequiredLiquor_Original NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL
				,strIdRequiredCigarette_Original NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL 
				,strPromotionalItem_Original NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL 
				,strPrePriced_Original NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL 
				,strApplyBlueLaw1_Original NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL 
				,strApplyBlueLaw2_Original NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL
				,strCountedDaily_Original NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL
				,strCounted_Original NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL
				,strCountBySINo_Original NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL
				,intFamilyId_Original INT NULL 
				,strFamilyId_Original NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL
				,intClassId_Original INT NULL 
				,strClassId_Original NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL
				,intProductCodeId_Original INT NULL 
				,strProductCodeId_Original NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL
				,intVendorId_Original INT NULL 
				,strVendorId_Original NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL
				,strMinimumAge_Original NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL
				,strMinOrder_Original NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL
				,strSuggestedQty_Original NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL
				,intCountGroupId_Original INT NULL 
				,intStorageLocationId_Original INT NULL 
				,strStorageLocationId_Original NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL
				,dblReorderPoint_Original NUMERIC(18, 6) NULL
				,strDescription_Original NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL
				-- Modified Fields
				,strTaxFlag1_New NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL
				,strTaxFlag2_New NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL
				,strTaxFlag3_New NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL
				,strTaxFlag4_New NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL
				,strDepositRequired_New NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL
				,intDepositPLUId_New INT NULL 
				,strDepositPLUId_New NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL
				,strQuantityRequired_New NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL
				,strScaleItem_New NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL 
				,strFoodStampable_New NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL
				,strReturnable_New NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL
				,strSaleable_New NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL 
				,strIdRequiredLiquor_New NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL
				,strIdRequiredCigarette_New NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL 
				,strPromotionalItem_New NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL 
				,strPrePriced_New NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL 
				,strApplyBlueLaw1_New NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL 
				,strApplyBlueLaw2_New NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL
				,strCountedDaily_New NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL
				,strCounted_New NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL
				,strCountBySINo_New NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL 
				,intFamilyId_New INT NULL 
				,strFamilyId_New NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL
				,intClassId_New INT NULL 
				,strClassId_New NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL
				,intProductCodeId_New INT NULL 
				,strProductCodeId_New NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL
				,intVendorId_New INT NULL 
				,strVendorId_New NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL
				,strMinimumAge_New NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL
				,strMinOrder_New NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL
				,strSuggestedQty_New NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL
				,intCountGroupId_New INT NULL 
				,intStorageLocationId_New INT NULL 
				,strStorageLocationId_New NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL
				,dblReorderPoint_New NUMERIC(18, 6) NULL
				,strDescription_New NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL
		)
		---------------------------------------------------------------
		------- END Table to handle different data types --------------
		---------------------------------------------------------------




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



		---------------------------------------------------------------
		-------- Insert to temp Table handle all Data types -----------
		---------------------------------------------------------------
		-- ITEM
		INSERT INTO @tblUpdateItemForCStore
		(
			intItemId 
			-- Original Fields
			,strCategoryCode_Original
			,strCountCode_Original
			,strDescription_Original
			-- Modified Fields
			,strCategoryCode_New 
			,strCountCode_New 
			,strDescription_New
		)
		SELECT  
			I.intItemId
			-- Original Fields
			, CatOld.strCategoryCode AS strCategoryCode_Original
			, [Changes].strCountCode_Original
			, [Changes].strDescription_Original
			-- Modified Fields
			, CatNew.strCategoryCode AS  strCategoryCode_New
			, [Changes].strCountCode_New
			, [Changes].strDescription_New
		FROM #tmpUpdateItemForCStore_itemAuditLog [Changes]
		JOIN tblICCategory CatOld ON [Changes].intCategoryId_Original = CatOld.intCategoryId
		JOIN tblICCategory CatNew ON [Changes].intCategoryId_New = CatNew.intCategoryId
		JOIN tblICItem I ON [Changes].intItemId = I.intItemId
		JOIN tblICItemLocation IL ON I.intItemId = IL.intItemId 
		JOIN tblICItemUOM UOM ON IL.intItemId = UOM.intItemId
		JOIN tblSMCompanyLocation CL ON IL.intLocationId = CL.intCompanyLocationId


		-- ITEM ACCOUNT
		INSERT INTO @tblItemAccountForCStore
		(
				intItemId 
				, intItemAccountId 		
				, intAccountCategoryId  
				, strAction
				-- Original Fields	
				, strAccountId_Original	
				, intAccountId_Original
				-- Modified Fields	
				, strAccountId_New
				, intAccountId_New
		)
		SELECT 
			I.intItemId
			, IA.intItemAccountId
			, AC.intAccountCategoryId
			, ''
			-- Original Fields
			, GL_Old.strAccountId
			, GL_Old.intAccountId
			-- Modified Fields
			, GL_New.strAccountId
			, GL_New.intAccountId
		FROM #tmpUpdateItemAccountForCStore_itemAuditLog [Changes]
		JOIN tblICItem I ON [Changes].intItemId = I.intItemId
		JOIN tblICItemAccount IA ON [Changes].intItemAccountId = IA.intItemAccountId
		JOIN tblGLAccountCategory AC ON IA.intAccountCategoryId = AC.intAccountCategoryId
		JOIN tblGLAccount GL_Old ON [Changes].intAccountId_Original = GL_Old.intAccountId
		JOIN tblGLAccount GL_New ON [Changes].intAccountId_New = GL_New.intAccountId
		JOIN tblICItemLocation IL ON I.intItemId = IL.intItemId 
		JOIN tblICItemUOM UOM ON IL.intItemId = UOM.intItemId
		JOIN tblSMCompanyLocation CL ON IL.intLocationId = CL.intCompanyLocationId


		-- ITEM LOCATION
		INSERT INTO @tblItemLocationForCStore
		(
				intItemId 
				,intItemLocationId 
				-- Original Fields
				,strTaxFlag1_Original
				,strTaxFlag2_Original
				,strTaxFlag3_Original
				,strTaxFlag4_Original
				,strDepositRequired_Original
				,intDepositPLUId_Original
				,strDepositPLUId_Original
				,strQuantityRequired_Original
				,strScaleItem_Original
				,strFoodStampable_Original
				,strReturnable_Original
				,strSaleable_Original
				,strIdRequiredLiquor_Original
				,strIdRequiredCigarette_Original
				,strPromotionalItem_Original
				,strPrePriced_Original
				,strApplyBlueLaw1_Original
				,strApplyBlueLaw2_Original
				,strCountedDaily_Original
				,strCounted_Original
				,strCountBySINo_Original
				,intFamilyId_Original
				,strFamilyId_Original
				,intClassId_Original
				,strClassId_Original
				,intProductCodeId_Original
				,strProductCodeId_Original
				,intVendorId_Original
				,strVendorId_Original
				,strMinimumAge_Original
				,strMinOrder_Original
				,strSuggestedQty_Original
				,strStorageLocationId_Original
				-- Modified Fields
				,strTaxFlag1_New
				,strTaxFlag2_New
				,strTaxFlag3_New
				,strTaxFlag4_New
				,strDepositRequired_New
				,intDepositPLUId_New
				,strDepositPLUId_New
				,strQuantityRequired_New
				,strScaleItem_New
				,strFoodStampable_New
				,strReturnable_New
				,strSaleable_New
				,strIdRequiredLiquor_New
				,strIdRequiredCigarette_New
				,strPromotionalItem_New
				,strPrePriced_New
				,strApplyBlueLaw1_New
				,strApplyBlueLaw2_New
				,strCountedDaily_New
				,strCounted_New
				,strCountBySINo_New
				,intFamilyId_New
				,strFamilyId_New
				,intClassId_New
				,strClassId_New
				,intProductCodeId_New
				,strProductCodeId_New
				,intVendorId_New
				,strVendorId_New
				,strMinimumAge_New
				,strMinOrder_New
				,strSuggestedQty_New
				,strStorageLocationId_New
		)
		SELECT 
			I.intItemId
			, IL.intItemLocationId

			-- Original Fields
			, CASE 
					WHEN [Changes].ysnTaxFlag1_Original = 1 THEN 'true' ELSE 'false'
			  END
			, CASE 
					WHEN [Changes].ysnTaxFlag2_Original = 1 THEN 'true' ELSE 'false'
			  END
			, CASE 
					WHEN [Changes].ysnTaxFlag3_Original = 1 THEN 'true' ELSE 'false'
			  END
			, CASE 
					WHEN [Changes].ysnTaxFlag4_Original = 1 THEN 'true' ELSE 'false'
			  END
			, CASE 
					WHEN [Changes].ysnDepositRequired_Original = 1 THEN 'true' ELSE 'false'
			  END
			, CAST([Changes].intDepositPLUId_Original AS NVARCHAR(1000))
			, ISNULL((SELECT strUpcCode FROM tblICItemUOM WHERE intItemUOMId = [Changes].intDepositPLUId_Original), '')
			, CASE 
					WHEN [Changes].ysnQuantityRequired_Original = 1 THEN 'true' ELSE 'false'
			  END
			, CASE 
					WHEN [Changes].ysnScaleItem_Original = 1 THEN 'true' ELSE 'false'
			  END
			, CASE 
					WHEN [Changes].ysnFoodStampable_Original = 1 THEN 'true' ELSE 'false'
			  END
			, CASE 
					WHEN [Changes].ysnReturnable_Original = 1 THEN 'true' ELSE 'false'
			  END
			, CASE 
					WHEN [Changes].ysnSaleable_Original = 1 THEN 'true' ELSE 'false'
			  END
			, CASE 
					WHEN [Changes].ysnIdRequiredLiquor_Original = 1 THEN 'true' ELSE 'false'
			  END
			, CASE 
					WHEN [Changes].ysnIdRequiredCigarette_Original = 1 THEN 'true' ELSE 'false'
			  END
			, CASE 
					WHEN [Changes].ysnPromotionalItem_Original = 1 THEN 'true' ELSE 'false'
			  END
			, CASE 
					WHEN [Changes].ysnPrePriced_Original = 1 THEN 'true' ELSE 'false'
			  END
			, CASE 
					WHEN [Changes].ysnApplyBlueLaw1_Original = 1 THEN 'true' ELSE 'false'
			  END
			, CASE 
					WHEN [Changes].ysnApplyBlueLaw2_Original = 1 THEN 'true' ELSE 'false'
			  END
			, CASE 
					WHEN [Changes].ysnCountedDaily_Original = 1 THEN 'true' ELSE 'false'
			  END
			, strCounted_Original
			, CASE 
					WHEN [Changes].ysnCountBySINo_Original = 1 THEN 'true' ELSE 'false'
			  END
			, CAST([Changes].intFamilyId_Original AS NVARCHAR(1000))
			, ISNULL((SELECT strSubcategoryId FROM tblSTSubcategory WHERE intSubcategoryId = [Changes].intFamilyId_Original), '')
			, CAST([Changes].intClassId_Original AS NVARCHAR(1000))
			, ISNULL((SELECT strSubcategoryId FROM tblSTSubcategory WHERE intSubcategoryId = [Changes].intClassId_Original), '')
			, [Changes].intProductCodeId_Original
			, ISNULL((SELECT strRegProdCode FROM tblSTSubcategoryRegProd WHERE intRegProdId = [Changes].intProductCodeId_Original), '')
			, [Changes].intVendorId_Original
			, ISNULL((SELECT strName FROM tblEMEntity WHERE intEntityId = [Changes].intVendorId_Original), '')
			, CAST((ISNULL([Changes].intMinimumAge_Original, '')) AS NVARCHAR(1000))--ISNULL((, '')
			, ISNULL(CAST([Changes].dblMinOrder_Original AS NVARCHAR(1000)), '')
			, ISNULL(CAST([Changes].dblSuggestedQty_Original AS NVARCHAR(1000)), '')
			, ISNULL((SELECT strSubLocationName FROM tblSMCompanyLocationSubLocation WHERE intCompanyLocationSubLocationId = [Changes].intStorageLocationId_Original), '')


			-- Modified Fields
			, CASE 
					WHEN [Changes].ysnTaxFlag1_New = 1 THEN 'true' ELSE 'false'
			  END
			, CASE 
					WHEN [Changes].ysnTaxFlag2_New = 1 THEN 'true' ELSE 'false'
			  END
			, CASE 
					WHEN [Changes].ysnTaxFlag3_New = 1 THEN 'true' ELSE 'false'
			  END
			, CASE 
					WHEN [Changes].ysnTaxFlag4_New = 1 THEN 'true' ELSE 'false'
			  END
			, CASE 
					WHEN [Changes].ysnDepositRequired_New = 1 THEN 'true' ELSE 'false'
			  END
			, CAST([Changes].intDepositPLUId_New AS NVARCHAR(1000))
			, ISNULL((SELECT strUpcCode FROM tblICItemUOM WHERE intItemUOMId = [Changes].intDepositPLUId_New), '')
			, CASE 
					WHEN [Changes].ysnQuantityRequired_New = 1 THEN 'true' ELSE 'false'
			  END
			, CASE 
					WHEN [Changes].ysnScaleItem_New = 1 THEN 'true' ELSE 'false'
			  END
			, CASE 
					WHEN [Changes].ysnFoodStampable_New = 1 THEN 'true' ELSE 'false'
			  END
			, CASE 
					WHEN [Changes].ysnReturnable_New = 1 THEN 'true' ELSE 'false'
			  END
			, CASE 
					WHEN [Changes].ysnSaleable_New = 1 THEN 'true' ELSE 'false'
			  END
			, CASE 
					WHEN [Changes].ysnIdRequiredLiquor_New = 1 THEN 'true' ELSE 'false'
			  END
			, CASE 
					WHEN [Changes].ysnIdRequiredCigarette_New = 1 THEN 'true' ELSE 'false'
			  END
			, CASE 
					WHEN [Changes].ysnPromotionalItem_New = 1 THEN 'true' ELSE 'false'
			  END
			, CASE 
					WHEN [Changes].ysnPrePriced_New = 1 THEN 'true' ELSE 'false'
			  END
			, CASE 
					WHEN [Changes].ysnApplyBlueLaw1_New = 1 THEN 'true' ELSE 'false'
			  END
			, CASE 
					WHEN [Changes].ysnApplyBlueLaw2_New = 1 THEN 'true' ELSE 'false'
			  END
			, CASE 
					WHEN [Changes].ysnCountedDaily_New = 1 THEN 'true' ELSE 'false'
			  END
			,strCounted_New
			, CASE 
					WHEN [Changes].ysnCountBySINo_New = 1 THEN 'true' ELSE 'false'
			  END
			, CAST([Changes].intFamilyId_New AS NVARCHAR(1000))
			, ISNULL((SELECT strSubcategoryId FROM tblSTSubcategory WHERE intSubcategoryId = [Changes].intFamilyId_New), '')
			, CAST([Changes].intClassId_New AS NVARCHAR(1000))
			, ISNULL((SELECT strRegProdCode FROM tblSTSubcategoryRegProd WHERE intRegProdId = [Changes].intClassId_New), '')
			, [Changes].intProductCodeId_New
			, ISNULL((SELECT strRegProdCode FROM tblSTSubcategoryRegProd WHERE intRegProdId = [Changes].intProductCodeId_New), '')
			, [Changes].intVendorId_New
			, ISNULL((SELECT strName FROM tblEMEntity WHERE intEntityId = [Changes].intVendorId_New), '')
			, CAST((ISNULL([Changes].intMinimumAge_New, '')) AS NVARCHAR(1000))
			, ISNULL(CAST([Changes].dblMinOrder_New AS NVARCHAR(1000)), '')
			, ISNULL(CAST([Changes].dblSuggestedQty_New AS NVARCHAR(1000)), '')
			, ISNULL((SELECT strSubLocationName FROM tblSMCompanyLocationSubLocation WHERE intCompanyLocationSubLocationId = [Changes].intStorageLocationId_New), '')

		FROM #tmpUpdateItemLocationForCStore_itemLocationAuditLog [Changes]
		JOIN tblICItem I ON [Changes].intItemId = I.intItemId
		JOIN 
		(
			SELECT TOP 1 UOMM.strUpcCode, ILL.intItemId, ILL.intLocationId, ILL.intItemLocationId, ILL.intDepositPLUId, ILL.intFamilyId
			FROM tblICItemLocation ILL
			JOIN tblICItemUOM UOMM ON ILL.intDepositPLUId = UOMM.intItemUOMId
		) IL ON I.intItemId = IL.intItemId 
		JOIN tblICItemUOM UOM ON IL.intItemId = UOM.intItemId
		JOIN tblSMCompanyLocation CL ON IL.intLocationId = CL.intCompanyLocationId
		---------------------------------------------------------------
		------ END Insert to temp Table handle all Data types ---------
		---------------------------------------------------------------



	
		-- Handle preview using Table variable
		DECLARE @tblPreview TABLE (
			intCompanyLocationId INT
			, strLocation NVARCHAR(250)
			, strUpc NVARCHAR(50)
			, strItemDescription NVARCHAR(250)
			, strChangeDescription NVARCHAR(100)
			, strOldData NVARCHAR(MAX)
			, strNewData NVARCHAR(MAX)
			, intParentId INT
			, intChildId INT
		)



		-- ITEM Preview
		DECLARE @strCategoryCode_New AS NVARCHAR(50) = (SELECT strCategoryCode FROM tblICCategory WHERE intCategoryId = @intNewCategory)
		INSERT INTO @tblPreview (
			intCompanyLocationId
			, strLocation
			, strUpc
			, strItemDescription
			, strChangeDescription
			, strOldData
			, strNewData 
			, intParentId
			, intChildId
		)
		SELECT	CL.intCompanyLocationId
				,CL.strLocationName
				,CASE
					  WHEN UOM.strLongUPCCode IS NOT NULL AND UOM.strLongUPCCode != '' THEN UOM.strLongUPCCode ELSE UOM.strUpcCode
				END
				,I.strDescription
				,CASE
					WHEN [Changes].oldColumnName = 'strCategoryCode_Original' THEN 'Category'
					WHEN [Changes].oldColumnName = 'strCountCode_Original' THEN 'Count Code'
					WHEN [Changes].oldColumnName = 'strDescription_Original' THEN 'Description'
				 END
				,[Changes].strOldData
				,[Changes].strNewData
				,[Changes].intItemId 
				,[Changes].intItemId
		FROM 
		(
			SELECT DISTINCT intItemId, oldColumnName, strOldData, strNewData
			FROM @tblUpdateItemForCStore
			unpivot
			(
				strOldData for oldColumnName in (strCategoryCode_Original, strCountCode_Original, strDescription_Original)
			) o
			unpivot
			(
				strNewData for newColumnName in (strCategoryCode_New, strCountCode_New, strDescription_New)
			) n
			WHERE  REPLACE(oldColumnName, '_Original', '') = REPLACE(newColumnName, '_New', '')
		) [Changes]
		--FROM #tmpUpdateItemForCStore_itemAuditLog [Changes]
		JOIN tblICItem I ON [Changes].intItemId = I.intItemId
		JOIN tblICItemLocation IL ON I.intItemId = IL.intItemId 
		JOIN tblICItemUOM UOM ON IL.intItemId = UOM.intItemId
		JOIN tblSMCompanyLocation CL ON IL.intLocationId = CL.intCompanyLocationId
		JOIN tblICCategory Cat ON I.intCategoryId = Cat.intCategoryId
		WHERE 
		(
			NOT EXISTS (SELECT TOP 1 1 FROM #tmpUpdateItemForCStore_Location)
			OR EXISTS (SELECT TOP 1 1 FROM #tmpUpdateItemForCStore_Location WHERE intLocationId = CL.intCompanyLocationId) 			
		)
		AND 
		(
			NOT EXISTS (SELECT TOP 1 1 FROM tblICItemUOM WHERE intItemUOMId = @intUpcCode)
			OR EXISTS (SELECT TOP 1 1 FROM tblICItemUOM WHERE intItemUOMId = @intUpcCode AND intItemUOMId = UOM.intItemUOMId) 		
		)




		-- ITEM ACCOUNT Preview
		INSERT INTO @tblPreview (
			intCompanyLocationId
			, strLocation
			, strUpc
			, strItemDescription
			, strChangeDescription
			, strOldData
			, strNewData
			, intParentId
			, intChildId
		)
		SELECT	CL.intCompanyLocationId
				,CL.strLocationName
				,CASE
					  WHEN UOM.strLongUPCCode IS NOT NULL AND UOM.strLongUPCCode != '' THEN UOM.strLongUPCCode ELSE UOM.strUpcCode
				END
				,I.strDescription
				,AC.strAccountCategory
				,[Changes].strOldData
				,[Changes].strNewData
				,[Changes].intItemId 
				,[Changes].intItemAccountId
		--FROM #tmpUpdateItemAccountForCStore_itemAuditLog [Changes]
		FROM 
		(
			SELECT DISTINCT intItemId,intItemAccountId,intAccountId_Original,intAccountId_New, oldColumnName, strOldData, strNewData
			FROM @tblItemAccountForCStore
			unpivot
			(
				strOldData for oldColumnName in (strAccountId_Original)
			) o
			unpivot
			(
				strNewData for newColumnName in (strAccountId_New)
			) n
			WHERE  REPLACE(oldColumnName, '_Original', '') = REPLACE(newColumnName, '_New', '')
		) [Changes]
		JOIN tblICItem I ON [Changes].intItemId = I.intItemId
		JOIN tblICItemAccount IA ON [Changes].intItemAccountId = IA.intItemAccountId
		JOIN tblGLAccountCategory AC ON IA.intAccountCategoryId = AC.intAccountCategoryId
		JOIN tblGLAccount GL_Old ON [Changes].intAccountId_Original = GL_Old.intAccountId
		JOIN tblGLAccount GL_New ON [Changes].intAccountId_New = GL_New.intAccountId
		JOIN tblICItemLocation IL ON I.intItemId = IL.intItemId 
		JOIN tblICItemUOM UOM ON IL.intItemId = UOM.intItemId
		JOIN tblSMCompanyLocation CL ON IL.intLocationId = CL.intCompanyLocationId
		WHERE 
		(
			NOT EXISTS (SELECT TOP 1 1 FROM #tmpUpdateItemForCStore_Location)
			OR EXISTS (SELECT TOP 1 1 FROM #tmpUpdateItemForCStore_Location WHERE intLocationId = CL.intCompanyLocationId) 			
		)
		AND 
		(
			NOT EXISTS (SELECT TOP 1 1 FROM tblICItemUOM WHERE intItemUOMId = @intUpcCode)
			OR EXISTS (SELECT TOP 1 1 FROM tblICItemUOM WHERE intItemUOMId = @intUpcCode AND intItemUOMId = UOM.intItemUOMId) 		
		)




		-- ITEM LOCATION Preview
		INSERT INTO @tblPreview (
			intCompanyLocationId
			, strLocation
			, strUpc
			, strItemDescription
			, strChangeDescription
			, strOldData
			, strNewData
			, intParentId
			, intChildId
		)
		SELECT	CL.intCompanyLocationId
				,CL.strLocationName
				,CASE
					  WHEN UOM.strLongUPCCode IS NOT NULL AND UOM.strLongUPCCode != '' THEN UOM.strLongUPCCode ELSE UOM.strUpcCode
				END
				,I.strDescription
				,CASE
					WHEN [Changes].oldColumnName = 'strTaxFlag1_Original' THEN 'Tax Flag 1'
					WHEN [Changes].oldColumnName = 'strTaxFlag2_Original' THEN 'Tax Flag 2'
					WHEN [Changes].oldColumnName = 'strTaxFlag3_Original' THEN 'Tax Flag 3'
					WHEN [Changes].oldColumnName = 'strTaxFlag4_Original' THEN 'Tax Flag 4'
					WHEN [Changes].oldColumnName = 'strDepositRequired_Original' THEN 'Deposit Required'
					WHEN [Changes].oldColumnName = 'strDepositPLUId_Original' THEN 'Deposit PLU'
					WHEN [Changes].oldColumnName = 'strQuantityRequired_Original' THEN 'Quantity Required' 
					WHEN [Changes].oldColumnName = 'strScaleItem_Original' THEN 'Scale Item' 
					WHEN [Changes].oldColumnName = 'strFoodStampable_Original' THEN 'Stampable' 
					WHEN [Changes].oldColumnName = 'strReturnable_Original' THEN 'Returnable' 
					WHEN [Changes].oldColumnName = 'strSaleable_Original' THEN 'Saleable'
					WHEN [Changes].oldColumnName = 'strIdRequiredLiquor_Original' THEN 'Required Liquor' 
					WHEN [Changes].oldColumnName = 'strIdRequiredCigarette_Original' THEN 'Required Cigarette' 
					WHEN [Changes].oldColumnName = 'strPromotionalItem_Original' THEN 'Promotional Item'
					WHEN [Changes].oldColumnName = 'strPrePriced_Original' THEN 'Pre Priced'
					WHEN [Changes].oldColumnName = 'strApplyBlueLaw1_Original' THEN 'Apply Blue Law 1'
					WHEN [Changes].oldColumnName = 'strApplyBlueLaw2_Original' THEN 'Apply Blue Law 2'
					WHEN [Changes].oldColumnName = 'strCountedDaily_Original' THEN 'Counted Daily' 
					WHEN [Changes].oldColumnName = 'strCounted_Original' THEN 'Counted'
					WHEN [Changes].oldColumnName = 'strCountBySINo_Original' THEN 'Count by SI No'
					WHEN [Changes].oldColumnName = 'strFamilyId_Original' THEN 'Family'
					WHEN [Changes].oldColumnName = 'strClassId_Original' THEN 'Class'
					WHEN [Changes].oldColumnName = 'strProductCodeId_Original' THEN 'Product Code'
					WHEN [Changes].oldColumnName = 'strVendorId_Original' THEN 'Vendor' 
					WHEN [Changes].oldColumnName = 'strMinimumAge_Original' THEN 'Minimum Age' 
					WHEN [Changes].oldColumnName = 'strMinOrder_Original' THEN 'Minimum Order' 
					WHEN [Changes].oldColumnName = 'strSuggestedQty_Original' THEN 'Suggested Quantity' 
					WHEN [Changes].oldColumnName = 'strStorageLocationId_Original' THEN 'Storage Location'
				 END
				,[Changes].strOldData
				,[Changes].strNewData
				,[Changes].intItemId 
				,[Changes].intItemLocationId
		FROM 
		(
			SELECT DISTINCT intItemId,intItemLocationId, oldColumnName, strOldData, strNewData
			FROM @tblItemLocationForCStore
			unpivot
			(
				strOldData for oldColumnName in (strTaxFlag1_Original, strTaxFlag2_Original, strTaxFlag3_Original, strTaxFlag4_Original, strDepositRequired_Original, strDepositPLUId_Original, strQuantityRequired_Original, strScaleItem_Original, strFoodStampable_Original
				                                 ,strReturnable_Original, strSaleable_Original, strIdRequiredLiquor_Original,strIdRequiredCigarette_Original, strPromotionalItem_Original, strPrePriced_Original, strApplyBlueLaw1_Original, strApplyBlueLaw2_Original
												 , strCountedDaily_Original, strCounted_Original, strCountBySINo_Original, strFamilyId_Original, strClassId_Original, strProductCodeId_Original, strVendorId_Original, strMinimumAge_Original, strMinOrder_Original
												 , strSuggestedQty_Original, strStorageLocationId_Original)
			) o
			unpivot
			(
				strNewData for newColumnName in (strTaxFlag1_New, strTaxFlag2_New, strTaxFlag3_New, strTaxFlag4_New, strDepositRequired_New, strDepositPLUId_New, strQuantityRequired_New, strScaleItem_New, strFoodStampable_New
				                                 ,strReturnable_New, strSaleable_New, strIdRequiredLiquor_New,strIdRequiredCigarette_New, strPromotionalItem_New, strPrePriced_New, strApplyBlueLaw1_New, strApplyBlueLaw2_New
												 , strCountedDaily_New, strCounted_New, strCountBySINo_New, strFamilyId_New,strClassId_New, strProductCodeId_New, strVendorId_New, strMinimumAge_New, strMinOrder_New
												 ,strSuggestedQty_New, strStorageLocationId_New)
			) n
			WHERE  REPLACE(oldColumnName, '_Original', '') = REPLACE(newColumnName, '_New', '')
		) [Changes]
		JOIN tblICItem I ON [Changes].intItemId = I.intItemId
		JOIN tblICItemLocation IL ON I.intItemId = IL.intItemId 
		JOIN tblICItemUOM UOM ON IL.intItemId = UOM.intItemId
		JOIN tblSMCompanyLocation CL ON IL.intLocationId = CL.intCompanyLocationId
		WHERE 
		(
			NOT EXISTS (SELECT TOP 1 1 FROM #tmpUpdateItemForCStore_Location)
			OR EXISTS (SELECT TOP 1 1 FROM #tmpUpdateItemForCStore_Location WHERE intLocationId = CL.intCompanyLocationId) 			
		)
		AND 
		(
			NOT EXISTS (SELECT TOP 1 1 FROM tblICItemUOM WHERE intItemUOMId = @intUpcCode)
			OR EXISTS (SELECT TOP 1 1 FROM tblICItemUOM WHERE intItemUOMId = @intUpcCode AND intItemUOMId = UOM.intItemUOMId) 		
		)






	   DELETE FROM @tblPreview WHERE ISNULL(strOldData, '') = ISNULL(strNewData, '')

	   -- Query Preview display
	   SELECT DISTINCT 
	          strLocation
			  , strUpc
			  , strItemDescription
			  , strChangeDescription
			  , strOldData
			  , strNewData
	   FROM @tblPreview
	   ORDER BY strItemDescription, strChangeDescription ASC
    
	   DELETE FROM @tblPreview

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