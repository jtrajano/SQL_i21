﻿CREATE PROCEDURE [dbo].[uspSTUpdateItemData]
		-- Add the parameters for the stored procedure here
		@XML VARCHAR(MAX),
		@ysnRecap BIT = 1,
		@strGuid NVARCHAR(100) = '',
		@strResultMsg NVARCHAR(1000) OUTPUT
	AS
BEGIN TRY
	    
		BEGIN TRANSACTION

		DECLARE @ErrMsg					   NVARCHAR(MAX),
				@idoc					   INT,
				@strCompanyLocationId 	   NVARCHAR(MAX),
				@strVendorId               NVARCHAR(MAX),
				@strCategoryId             NVARCHAR(MAX),
				@strFamilyId			   NVARCHAR(MAX),
				@strClassId                NVARCHAR(MAX),
				@intItemUOMId              INT, -- @intUpcCode                INT,
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
				@intCurrentEntityUserId	   INT
		SET @strResultMsg = 'success'

	                  
		EXEC sp_xml_preparedocument @idoc OUTPUT, @XML 
	
		SELECT	
				@strCompanyLocationId	   	 =	 Location,
				@strVendorId          =   Vendor,
				@strCategoryId        =   Category,
				@strFamilyId          =   Family,
				@strClassId           =   Class,
				@intItemUOMId         =   intItemUOMId, --UPCCode,
				@strDescription       =   ItmDescription,

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
		        @intCurrentEntityUserId   =   currentUserId
		
		FROM	OPENXML(@idoc, 'root',2)
		WITH
		(
				Location 			      NVARCHAR(MAX),
				Vendor                    NVARCHAR(MAX),
				Category                  NVARCHAR(MAX),
				Family                    NVARCHAR(MAX),
				Class                     NVARCHAR(MAX),
				intItemUOMId              INT,
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
				, strCategoryId_Original NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL
				-- Modified Fields
				,strCategoryCode_New NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL
				,strCountCode_New NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL
				,strDescription_New NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL
				, strCategoryId_New NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL
		)

		---- ITEM ACCOUNT
		--DECLARE @tblItemAccountForCStore TABLE (
		--		intItemId INT
		--		, intItemAccountId INT		
		--		, intAccountCategoryId INT 
		--		, strAction NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL	
		--		-- Original Fields	
		--		, strAccountId_Original NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL	
		--		, intAccountId_Original INT NULL	
		--		-- Modified Fields	
		--		, strAccountId_New NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL	
		--		, intAccountId_New INT NULL	
		--)

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
				
				,strFamilyId_Original NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL
				,strFamily_Original NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL
				,strClassId_Original NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL
				,strClass_Original NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL
				,strProductCodeId_Original NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL
				,strProductCode_Original NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL
				,strVendorId_Original NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL
				,strVendor_Original NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL
				,strMinimumAge_Original NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL
				,strMinOrder_Original NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL
				,strSuggestedQty_Original NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL
				,intCountGroupId_Original INT NULL 
				,strStorageLocationId_Original NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL
				,strStorageLocation_Original NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL
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
				
				,strFamilyId_New NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL 
				,strFamily_New NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL
				,strClassId_New NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL
				,strClass_New NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL
				,strProductCodeId_New NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL 
				,strProductCode_New NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL
				,strVendorId_New NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL
				,strVendor_New NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL
				,strMinimumAge_New NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL
				,strMinOrder_New NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL
				,strSuggestedQty_New NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL
				,intCountGroupId_New INT NULL 
				,strStorageLocationId_New NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL
				,strStorageLocation_New NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL
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
												WHERE intItemUOMId = @intItemUOMId
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

					,@intEntityUserSecurityId = @intCurrentEntityUserId
		END


		--BEGIN 
		--	-- Item Account
		--	EXEC [dbo].[uspICUpdateItemAccountForCStore]
		--		-- filter params
		--		@strUpcCode = @strUpcCode 
		--		,@strDescription = @strDescription 
		--		,@dblRetailPriceFrom = NULL
		--		,@dblRetailPriceTo = NULL 
		--		-- update params
		--		,@intGLAccountCOGS = @intNewGLPurchaseAccount		-- If 'Cost of Goods'
		--		,@intGLAccountSalesRevenue = @intNewGLSalesAccount	-- If 'Sales Account'

		--		,@intEntityUserSecurityId = @intCurrentEntityUserId
		--END


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
				,@dblRetailPriceFrom = @dblPriceBetween1  
				,@dblRetailPriceTo =  @dblPriceBetween2 
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

				,@intEntityUserSecurityId = @intCurrentEntityUserId
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
			, strCategoryId_Original
			-- Modified Fields
			,strCategoryCode_New 
			,strCountCode_New 
			,strDescription_New
			, strCategoryId_New
		)
		SELECT DISTINCT
			I.intItemId
			-- Original Fields
			, ISNULL(CatOld.strCategoryCode, '') AS strCategoryCode_Original
			, ISNULL([Changes].strCountCode_Original, '')
			, ISNULL([Changes].strDescription_Original, '')
			, ISNULL(CAST([Changes].intCategoryId_Original AS NVARCHAR(50)), '')
			-- Modified Fields
			, ISNULL(CatNew.strCategoryCode, '') AS  strCategoryCode_New
			, ISNULL([Changes].strCountCode_New, '')
			, ISNULL([Changes].strDescription_New, '')
			, ISNULL(CAST([Changes].intCategoryId_New AS NVARCHAR(50)), '')
		FROM #tmpUpdateItemForCStore_itemAuditLog [Changes]
		INNER JOIN tblICCategory CatOld 
			ON [Changes].intCategoryId_Original = CatOld.intCategoryId
		INNER JOIN tblICCategory CatNew 
			ON [Changes].intCategoryId_New = CatNew.intCategoryId
		INNER JOIN tblICItem I 
			ON [Changes].intItemId = I.intItemId
		INNER JOIN tblICItemLocation IL 
			ON I.intItemId = IL.intItemId 
		INNER JOIN tblICItemUOM UOM 
			ON IL.intItemId = UOM.intItemId
		INNER JOIN tblSMCompanyLocation CL 
			ON IL.intLocationId = CL.intCompanyLocationId

---- TEST
--SELECT '#tmpUpdateItemForCStore_itemAuditLog', * FROM #tmpUpdateItemForCStore_itemAuditLog
--SELECT '@tblUpdateItemForCStore', intItemId, strCategoryId_Original, strCountCode_Original, strDescription_Original, strCategoryCode_Original 
--				-- Modified Fields
--				,strCategoryId_New
--				,strCountCode_New
--				,strDescription_New
--				,strCategoryCode_New  
--				FROM @tblUpdateItemForCStore



		---- ITEM ACCOUNT
		--INSERT INTO @tblItemAccountForCStore
		--(
		--		intItemId 
		--		, intItemAccountId 		
		--		, intAccountCategoryId  
		--		, strAction
		--		-- Original Fields	
		--		, strAccountId_Original	
		--		, intAccountId_Original
		--		-- Modified Fields	
		--		, strAccountId_New
		--		, intAccountId_New
		--)
		--SELECT 
		--	I.intItemId
		--	, IA.intItemAccountId
		--	, AC.intAccountCategoryId
		--	, ''
		--	-- Original Fields
		--	, GL_Old.strAccountId
		--	, GL_Old.intAccountId
		--	-- Modified Fields
		--	, GL_New.strAccountId
		--	, GL_New.intAccountId
		--FROM #tmpUpdateItemAccountForCStore_itemAuditLog [Changes]
		--INNER JOIN tblICItem I 
		--	ON [Changes].intItemId = I.intItemId
		--INNER JOIN tblICItemAccount IA 
		--	ON [Changes].intItemAccountId = IA.intItemAccountId
		--INNER JOIN tblGLAccountCategory AC 
		--	ON IA.intAccountCategoryId = AC.intAccountCategoryId
		--INNER JOIN tblGLAccount GL_Old 
		--	ON [Changes].intAccountId_Original = GL_Old.intAccountId
		--INNER JOIN tblGLAccount GL_New 
		--	ON [Changes].intAccountId_New = GL_New.intAccountId
		--INNER JOIN tblICItemLocation IL 
		--	ON I.intItemId = IL.intItemId 
		--INNER JOIN tblICItemUOM UOM 
		--	ON IL.intItemId = UOM.intItemId
		--INNER JOIN tblSMCompanyLocation CL 
		--	ON IL.intLocationId = CL.intCompanyLocationId


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
				
				,strFamilyId_Original
				,strFamily_Original
				,strClassId_Original
				,strClass_Original
				,strProductCodeId_Original
				,strProductCode_Original
				,strVendorId_Original
				,strVendor_Original
				,strMinimumAge_Original
				,strMinOrder_Original
				,strSuggestedQty_Original
				,strStorageLocationId_Original
				,strStorageLocation_Original
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
				
				,strFamilyId_New
				,strFamily_New
				,strClassId_New
				,strClass_New
				,strProductCodeId_New
				,strProductCode_New
				,strVendorId_New
				,strVendor_New
				,strMinimumAge_New
				,strMinOrder_New
				,strSuggestedQty_New
				,strStorageLocationId_New
				,strStorageLocation_New
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
			, ISNULL(strCounted_Original, '')
			, CASE 
					WHEN [Changes].ysnCountBySINo_Original = 1 THEN 'true' ELSE 'false'
			  END
			, strFamilyId_Original			= ISNULL(CAST([Changes].intFamilyId_Original AS NVARCHAR(1000)), '')
			, strFamily_Original			= ISNULL((SELECT strSubcategoryId FROM tblSTSubcategory WHERE intSubcategoryId = [Changes].intFamilyId_Original), '')
			, strClassId_Original			= ISNULL(CAST([Changes].intClassId_Original AS NVARCHAR(1000)), '')
			, strClass_Original				= ISNULL((SELECT strSubcategoryId FROM tblSTSubcategory WHERE intSubcategoryId = [Changes].intClassId_Original), '')
			, strProductCodeId_Original		= ISNULL(CAST([Changes].intProductCodeId_Original AS NVARCHAR(150)), '')
			, strProductCode_Original		= ISNULL((SELECT strRegProdCode FROM tblSTSubcategoryRegProd WHERE intRegProdId = [Changes].intProductCodeId_Original), '')
			, strVendorId_Original			= ISNULL(CAST([Changes].intVendorId_Original AS NVARCHAR(50)), '')
			, strVendor_Original			= ISNULL((SELECT strName FROM tblEMEntity WHERE intEntityId = [Changes].intVendorId_Original), '')
			, CAST((ISNULL([Changes].intMinimumAge_Original, '')) AS NVARCHAR(1000))--ISNULL((, '')
			, ISNULL(CAST([Changes].dblMinOrder_Original AS NVARCHAR(1000)), '')
			, ISNULL(CAST([Changes].dblSuggestedQty_Original AS NVARCHAR(1000)), '')
			, strStorageLocationId_Original = CAST([Changes].intStorageLocationId_Original AS NVARCHAR(50))
			, strStorageLocation_Original	= ISNULL((SELECT strSubLocationName FROM tblSMCompanyLocationSubLocation WHERE intCompanyLocationSubLocationId = [Changes].intStorageLocationId_Original), '')


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
			,ISNULL(strCounted_New, '')
			, CASE 
					WHEN [Changes].ysnCountBySINo_New = 1 THEN 'true' ELSE 'false'
			  END
			, strFamilyId_New				= CAST([Changes].intFamilyId_New AS NVARCHAR(1000))
			, strFamily_New					= ISNULL((SELECT strSubcategoryId FROM tblSTSubcategory WHERE intSubcategoryId = [Changes].intFamilyId_New), '')
			, strClassId_New				= CAST([Changes].intClassId_New AS NVARCHAR(1000))
			, strClass_New					= ISNULL((SELECT strSubcategoryId FROM tblSTSubcategory WHERE intSubcategoryId = [Changes].intClassId_New), '')
			, strProductCodeId_New			= CAST([Changes].intProductCodeId_New AS NVARCHAR(150))
			, strProductCode_New			= ISNULL((SELECT strRegProdCode FROM tblSTSubcategoryRegProd WHERE intRegProdId = [Changes].intProductCodeId_New), '')
			, strVendorId_New				= CAST([Changes].intVendorId_New AS NVARCHAR(50))
			, strVendor_New					= ISNULL((SELECT strName FROM tblEMEntity WHERE intEntityId = [Changes].intVendorId_New), '')
			, CAST((ISNULL([Changes].intMinimumAge_New, '')) AS NVARCHAR(1000))
			, ISNULL(CAST([Changes].dblMinOrder_New AS NVARCHAR(1000)), '')
			, ISNULL(CAST([Changes].dblSuggestedQty_New AS NVARCHAR(1000)), '')
			, strStorageLocationId_New		= CAST([Changes].intStorageLocationId_New AS NVARCHAR(50))
			, strStorageLocation_New		= ISNULL((SELECT strSubLocationName FROM tblSMCompanyLocationSubLocation WHERE intCompanyLocationSubLocationId = [Changes].intStorageLocationId_New), '')

		FROM #tmpUpdateItemLocationForCStore_itemLocationAuditLog [Changes]
		INNER JOIN tblICItem I 
			ON [Changes].intItemId = I.intItemId
		INNER JOIN tblICItemLocation IL 
			ON I.intItemId = IL.intItemId
			AND [Changes].intItemLocationId = IL.intItemLocationId

		--JOIN 
		--(
		--	SELECT TOP 1 UOMM.strUpcCode, ILL.intItemId, ILL.intLocationId, ILL.intItemLocationId, ILL.intDepositPLUId, ILL.intFamilyId
		--	FROM tblICItemLocation ILL
		--	JOIN tblICItemUOM UOMM ON ILL.intDepositPLUId = UOMM.intItemUOMId
		--) IL ON I.intItemId = IL.intItemId 
		--JOIN tblICItemUOM UOM ON IL.intItemId = UOM.intItemId
		--JOIN tblSMCompanyLocation CL ON IL.intLocationId = CL.intCompanyLocationId
		---------------------------------------------------------------
		------ END Insert to temp Table handle all Data types ---------
		---------------------------------------------------------------



	
		-- Handle preview using Table variable
		DECLARE @tblPreview TABLE (
			strTableName NVARCHAR(150)
			, strTableColumnName NVARCHAR(150)
			, strTableColumnDataType NVARCHAR(50)
			, intPrimaryKeyId INT NOT NULL
			, intParentId INT NULL
			, intChildId INT NULL
			, intCurrentEntityUserId INT NOT NULL
			, intItemId INT NULL
			, intItemUOMId INT NULL
			, intItemLocationId INT NULL

			, intCompanyLocationId INT
			, strLocation NVARCHAR(250)
			, strUpc NVARCHAR(50)
			, strItemDescription NVARCHAR(250)
			, strChangeDescription NVARCHAR(100)
			, strPreviewOldData NVARCHAR(MAX)
			, strPreviewNewData NVARCHAR(MAX)
			, ysnPreview BIT DEFAULT(1)
			, ysnForRevert BIT DEFAULT(0)
		)



		-- ITEM Preview
		DECLARE @strCategoryCode_New AS NVARCHAR(50) = (SELECT strCategoryCode FROM tblICCategory WHERE intCategoryId = @intNewCategory)
		INSERT INTO @tblPreview (
			strTableName
			, strTableColumnName
			, strTableColumnDataType
			, intPrimaryKeyId
			, intParentId
			, intChildId
			, intCurrentEntityUserId
			, intItemId
			, intItemUOMId
			, intItemLocationId

			, intCompanyLocationId
			, strLocation
			, strUpc
			, strItemDescription
			, strChangeDescription
			, strPreviewOldData
			, strPreviewNewData
			, ysnPreview
			, ysnForRevert
		)
		SELECT	
				strTableName												=	N'tblICItem'
				, strTableColumnName										= CASE
																				WHEN [Changes].oldColumnName	= 'strCategoryId_Original' THEN 'intCategoryId'
																				WHEN [Changes].oldColumnName	= 'strCategoryCode_Original' THEN 'strCategoryCode'
																				WHEN [Changes].oldColumnName	= 'strCountCode_Original' THEN 'strCountCode'
																				WHEN [Changes].oldColumnName	= 'strDescription_Original' THEN 'strDescription'
																			 END 
				, strTableColumnDataType									= CASE
																				WHEN [Changes].oldColumnName	= 'strCategoryId_Original' THEN 'INT'
																				WHEN [Changes].oldColumnName	= 'strCategoryCode_Original' THEN 'NVARCHAR(50)'
																				WHEN [Changes].oldColumnName	= 'strCountCode_Original' THEN 'NVARCHAR(50)'
																				WHEN [Changes].oldColumnName	= 'strDescription_Original' THEN 'NVARCHAR(250)'
																			 END
				, intPrimaryKeyId											= [Changes].intItemId
				, intParentId												= NULL
				, intChildId												= NULL
				, intCurrentEntityUserId									= @intCurrentEntityUserId
				, intItemId													= I.intItemId
				, intItemUOMId												= UOM.strLongUPCCode
				, intItemLocationId											= IL.intItemLocationId


				, intCompanyLocationId										= CL.intCompanyLocationId
				, strLocation												= CL.strLocationName
				, strUpc													= CASE
																				  WHEN UOM.strLongUPCCode IS NOT NULL AND UOM.strLongUPCCode != '' THEN UOM.strLongUPCCode ELSE UOM.strUpcCode
																			END
				, strItemDescription										= I.strDescription
				, strChangeDescription										= CASE
																				WHEN [Changes].oldColumnName = 'strCategoryId_Original' THEN 'Category Id'
																				WHEN [Changes].oldColumnName = 'strCategoryCode_Original' THEN 'Category'
																				WHEN [Changes].oldColumnName = 'strCountCode_Original' THEN 'Count Code'
																				WHEN [Changes].oldColumnName = 'strDescription_Original' THEN 'Description'
																			 END
				, strPreviewOldData											= [Changes].strOldData
				, strPreviewNewData											= [Changes].strNewData
				, ysnPreview												= CASE
																					WHEN [Changes].oldColumnName IN('strCategoryCode_Original', 'strCountCode_Original', 'strDescription_Original') THEN 1
																					ELSE 0
																			END 
		        , ysnForRevert												= CASE
																					WHEN [Changes].oldColumnName IN('strCategoryId_Original', 'strCountCode_Original', 'strDescription_Original') THEN 1
																					ELSE 0
																			END 
		FROM 
		(
			SELECT DISTINCT intItemId, oldColumnName, strOldData, strNewData
			FROM @tblUpdateItemForCStore
			unpivot
			(
				strOldData for oldColumnName in (strCategoryCode_Original, strCountCode_Original, strDescription_Original, strCategoryId_Original)
			) o
			unpivot
			(
				strNewData for newColumnName in (strCategoryCode_New, strCountCode_New, strDescription_New, strCategoryId_New)
			) n
			WHERE  REPLACE(oldColumnName, '_Original', '') = REPLACE(newColumnName, '_New', '')
		) [Changes]
		INNER JOIN tblICItem I 
			ON [Changes].intItemId = I.intItemId
		INNER JOIN tblICItemLocation IL 
			ON I.intItemId = IL.intItemId 
		INNER JOIN tblICItemUOM UOM 
			ON IL.intItemId = UOM.intItemId
		INNER JOIN tblSMCompanyLocation CL 
			ON IL.intLocationId = CL.intCompanyLocationId
		INNER JOIN tblICCategory Cat 
			ON I.intCategoryId = Cat.intCategoryId
		WHERE 
		(
			NOT EXISTS (SELECT TOP 1 1 FROM #tmpUpdateItemForCStore_Location)
			OR EXISTS (SELECT TOP 1 1 FROM #tmpUpdateItemForCStore_Location WHERE intLocationId = CL.intCompanyLocationId) 			
		)





		---- ITEM ACCOUNT Preview
		--INSERT INTO @tblPreview (
		--	strTableName
		--	, strTableColumnName
		--	--, strTableColumnDataType
		--	, intPrimaryKeyId
		--	, intParentId
		--	, intChildId
		--	, intCurrentEntityUserId

		--	, intCompanyLocationId
		--	, strLocation
		--	, strUpc
		--	, strItemDescription
		--	, strChangeDescription
		--	, strPreviewOldData
		--	, strPreviewNewData
		--)
		--SELECT	
		--		N'tblICItemAccount'
		--		, REPLACE([Changes].oldColumnName, '_Original', '')
		--		, [Changes].intItemAccountId
		--		, [Changes].intItemId
		--		, NULL
		--		, @intCurrentEntityUserId

		--        , CL.intCompanyLocationId
		--		, CL.strLocationName
		--		, CASE
		--			  WHEN UOM.strLongUPCCode IS NOT NULL AND UOM.strLongUPCCode != '' THEN UOM.strLongUPCCode ELSE UOM.strUpcCode
		--		END
		--		, I.strDescription
		--		, AC.strAccountCategory
		--		, [Changes].strOldData
		--		, [Changes].strNewData
		----FROM #tmpUpdateItemAccountForCStore_itemAuditLog [Changes]
		--FROM 
		--(
		--	SELECT DISTINCT intItemId,intItemAccountId,intAccountId_Original,intAccountId_New, oldColumnName, strOldData, strNewData
		--	FROM @tblItemAccountForCStore
		--	unpivot
		--	(
		--		strOldData for oldColumnName in (strAccountId_Original)
		--	) o
		--	unpivot
		--	(
		--		strNewData for newColumnName in (strAccountId_New)
		--	) n
		--	WHERE  REPLACE(oldColumnName, '_Original', '') = REPLACE(newColumnName, '_New', '')
		--) [Changes]
		--INNER JOIN tblICItem I 
		--	ON [Changes].intItemId = I.intItemId
		--INNER JOIN tblICItemAccount IA 
		--	ON [Changes].intItemAccountId = IA.intItemAccountId
		--INNER JOIN tblGLAccountCategory AC 
		--	ON IA.intAccountCategoryId = AC.intAccountCategoryId
		--INNER JOIN tblGLAccount GL_Old 
		--	ON [Changes].intAccountId_Original = GL_Old.intAccountId
		--INNER JOIN tblGLAccount GL_New 
		--	ON [Changes].intAccountId_New = GL_New.intAccountId
		--INNER JOIN tblICItemLocation IL 
		--	ON I.intItemId = IL.intItemId 
		--INNER JOIN tblICItemUOM UOM 
		--	ON IL.intItemId = UOM.intItemId
		--INNER JOIN tblSMCompanyLocation CL 
		--	ON IL.intLocationId = CL.intCompanyLocationId
		--WHERE 
		--(
		--	NOT EXISTS (SELECT TOP 1 1 FROM #tmpUpdateItemForCStore_Location)
		--	OR EXISTS (SELECT TOP 1 1 FROM #tmpUpdateItemForCStore_Location WHERE intLocationId = CL.intCompanyLocationId) 			
		--)
		--AND 
		--(
		--	-- http://jira.irelyserver.com/browse/ST-846 
		--	NOT EXISTS (SELECT TOP 1 1 FROM tblICItemUOM WHERE intItemUOMId = @intItemUOMId)
		--	OR EXISTS (SELECT TOP 1 1 FROM tblICItemUOM WHERE intItemUOMId = @intItemUOMId AND intItemUOMId = UOM.intItemUOMId) 		
		--)




		-- ITEM LOCATION Preview




		INSERT INTO @tblPreview (
			strTableName
			, strTableColumnName
			, strTableColumnDataType
			, intPrimaryKeyId
			, intParentId
			, intChildId
			, intCurrentEntityUserId
			, intItemId
			, intItemUOMId
			, intItemLocationId

			, intCompanyLocationId
			, strLocation
			, strUpc
			, strItemDescription
			, strChangeDescription
			, strPreviewOldData
			, strPreviewNewData
			, ysnPreview
			, ysnForRevert
		)
		SELECT	
		        strTableName												= N'tblICItemLocation'
				, strTableColumnName										= CASE
																				WHEN [Changes].oldColumnName = 'strTaxFlag1_Original' THEN 'ysnTaxFlag1'
																				WHEN [Changes].oldColumnName = 'strTaxFlag2_Original' THEN 'ysnTaxFlag2'
																				WHEN [Changes].oldColumnName = 'strTaxFlag3_Original' THEN 'ysnTaxFlag3'
																				WHEN [Changes].oldColumnName = 'strTaxFlag4_Original' THEN 'ysnTaxFlag4'
																				WHEN [Changes].oldColumnName = 'strDepositRequired_Original' THEN 'ysnDepositRequired'
																				WHEN [Changes].oldColumnName = 'strDepositPLUId_Original' THEN 'intDepositPLUId'
																				WHEN [Changes].oldColumnName = 'strQuantityRequired_Original' THEN 'ysnQuantityRequired' 
																				WHEN [Changes].oldColumnName = 'strScaleItem_Original' THEN 'ysnScaleItem' 
																				WHEN [Changes].oldColumnName = 'strFoodStampable_Original' THEN 'ysnFoodStampable' 
																				WHEN [Changes].oldColumnName = 'strReturnable_Original' THEN 'ysnReturnable' 
																				WHEN [Changes].oldColumnName = 'strSaleable_Original' THEN 'ysnSaleable'
																				WHEN [Changes].oldColumnName = 'strIdRequiredLiquor_Original' THEN 'ysnIdRequiredLiquor' 
																				WHEN [Changes].oldColumnName = 'strIdRequiredCigarette_Original' THEN 'ysnIdRequiredCigarette' 
																				WHEN [Changes].oldColumnName = 'strPromotionalItem_Original' THEN 'ysnPromotionalItem'
																				WHEN [Changes].oldColumnName = 'strPrePriced_Original' THEN 'ysnPrePriced'
																				WHEN [Changes].oldColumnName = 'strApplyBlueLaw1_Original' THEN 'ysnApplyBlueLaw1'
																				WHEN [Changes].oldColumnName = 'strApplyBlueLaw2_Original' THEN 'ysnApplyBlueLaw2'
																				WHEN [Changes].oldColumnName = 'strCountedDaily_Original' THEN 'ysnCountedDaily' 
																				WHEN [Changes].oldColumnName = 'strCounted_Original' THEN 'strCounted'
																				WHEN [Changes].oldColumnName = 'strCountBySINo_Original' THEN 'ysnCountBySINo'

																				WHEN [Changes].oldColumnName = 'strFamilyId_Original' THEN 'intFamilyId'
																				WHEN [Changes].oldColumnName = 'strFamily_Original' THEN 'strFamily'
																				WHEN [Changes].oldColumnName = 'strClassId_Original' THEN 'intClassId'
																				WHEN [Changes].oldColumnName = 'strClass_Original' THEN 'strClass'
																				WHEN [Changes].oldColumnName = 'strProductCodeId_Original' THEN 'intProductCodeId'
																				WHEN [Changes].oldColumnName = 'strProductCode_Original' THEN 'strProductCode'
																				WHEN [Changes].oldColumnName = 'strVendorId_Original' THEN 'intVendorId' 
																				WHEN [Changes].oldColumnName = 'strVendor_Original' THEN 'strVendor' 
																				WHEN [Changes].oldColumnName = 'strMinimumAge_Original' THEN 'intMinimumAge' 
																				WHEN [Changes].oldColumnName = 'strMinOrder_Original' THEN 'dblMinOrder' 
																				WHEN [Changes].oldColumnName = 'strSuggestedQty_Original' THEN 'dblSuggestedQty' 
																				WHEN [Changes].oldColumnName = 'strStorageLocationId_Original' THEN 'intStorageLocationId'
																				WHEN [Changes].oldColumnName = 'strStorageLocation_Original' THEN 'strStorageLocation'
																			 END
				, strTableColumnDataType										= CASE
																				WHEN [Changes].oldColumnName = 'strTaxFlag1_Original' THEN 'BIT'
																				WHEN [Changes].oldColumnName = 'strTaxFlag2_Original' THEN 'BIT'
																				WHEN [Changes].oldColumnName = 'strTaxFlag3_Original' THEN 'BIT'
																				WHEN [Changes].oldColumnName = 'strTaxFlag4_Original' THEN 'BIT'
																				WHEN [Changes].oldColumnName = 'strDepositRequired_Original' THEN 'BIT'
																				WHEN [Changes].oldColumnName = 'strDepositPLUId_Original' THEN 'INT'
																				WHEN [Changes].oldColumnName = 'strQuantityRequired_Original' THEN 'BIT' 
																				WHEN [Changes].oldColumnName = 'strScaleItem_Original' THEN 'BIT' 
																				WHEN [Changes].oldColumnName = 'strFoodStampable_Original' THEN 'BIT' 
																				WHEN [Changes].oldColumnName = 'strReturnable_Original' THEN 'BIT' 
																				WHEN [Changes].oldColumnName = 'strSaleable_Original' THEN 'BIT'
																				WHEN [Changes].oldColumnName = 'strIdRequiredLiquor_Original' THEN 'BIT' 
																				WHEN [Changes].oldColumnName = 'strIdRequiredCigarette_Original' THEN 'BIT' 
																				WHEN [Changes].oldColumnName = 'strPromotionalItem_Original' THEN 'BIT'
																				WHEN [Changes].oldColumnName = 'strPrePriced_Original' THEN 'BIT'
																				WHEN [Changes].oldColumnName = 'strApplyBlueLaw1_Original' THEN 'BIT'
																				WHEN [Changes].oldColumnName = 'strApplyBlueLaw2_Original' THEN 'BIT'
																				WHEN [Changes].oldColumnName = 'strCountedDaily_Original' THEN 'BIT' 
																				WHEN [Changes].oldColumnName = 'strCounted_Original' THEN 'BIT'
																				WHEN [Changes].oldColumnName = 'strCountBySINo_Original' THEN 'BIT'

																				WHEN [Changes].oldColumnName = 'strFamilyId_Original' THEN 'INT'
																				WHEN [Changes].oldColumnName = 'strFamily_Original' THEN 'NVARCHAR(150)'
																				WHEN [Changes].oldColumnName = 'strClassId_Original' THEN 'INT'
																				WHEN [Changes].oldColumnName = 'strClass_Original' THEN 'NVARCHAR(150)'
																				WHEN [Changes].oldColumnName = 'strProductCodeId_Original' THEN 'INT'
																				WHEN [Changes].oldColumnName = 'strProductCode_Original' THEN 'NVARCHAR(150)'
																				WHEN [Changes].oldColumnName = 'strVendorId_Original' THEN 'INT' 
																				WHEN [Changes].oldColumnName = 'strVendor_Original' THEN 'NVARCHAR(150)'
																				WHEN [Changes].oldColumnName = 'strMinimumAge_Original' THEN 'INT' 
																				WHEN [Changes].oldColumnName = 'strMinOrder_Original' THEN 'NUMERIC(18, 10)' 
																				WHEN [Changes].oldColumnName = 'strSuggestedQty_Original' THEN 'NUMERIC(18, 10)' 
																				WHEN [Changes].oldColumnName = 'strStorageLocationId_Original' THEN 'INT'
																				WHEN [Changes].oldColumnName = 'strStorageLocation_Original' THEN 'NVARCHAR(150)'
																			 END
				, intPrimaryKeyId											= [Changes].intItemLocationId
				, intParentId												= [Changes].intItemId
				, intChildId												= NULL
				, intCurrentEntityUserId									= @intCurrentEntityUserId
				, intItemId													= I.intItemId
				, intItemUOMId												= UOM.strLongUPCCode
				, intItemLocationId											= IL.intItemLocationId


		        , intCompanyLocationId										= CL.intCompanyLocationId
				, strLocation												= CL.strLocationName
				, strUpc													= CASE
																				  WHEN UOM.strLongUPCCode IS NOT NULL AND UOM.strLongUPCCode != '' THEN UOM.strLongUPCCode ELSE UOM.strUpcCode
																			END
				, strItemDescription										= I.strDescription
				, strChangeDescription										= CASE
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

																				WHEN [Changes].oldColumnName = 'strFamily_Original' THEN 'Family'
																				WHEN [Changes].oldColumnName = 'strClass_Original' THEN 'Class'
																				WHEN [Changes].oldColumnName = 'strProductCode_Original' THEN 'Product Code'
																				WHEN [Changes].oldColumnName = 'strVendor_Original' THEN 'Vendor' 
																				WHEN [Changes].oldColumnName = 'strMinimumAge_Original' THEN 'Minimum Age' 
																				WHEN [Changes].oldColumnName = 'strMinOrder_Original' THEN 'Minimum Order' 
																				WHEN [Changes].oldColumnName = 'strSuggestedQty_Original' THEN 'Suggested Quantity' 
																				WHEN [Changes].oldColumnName = 'strStorageLocation_Original' THEN 'Storage Location'
																			 END
				, strPreviewOldData											= [Changes].strOldData
				, strPreviewNewData											= [Changes].strNewData
				, ysnPreview												= CASE
																					WHEN [Changes].oldColumnName IN('strFamilyId_Original', 'strClassId_Original', 'strProductCodeId_Original', 'strVendorId_Original', 'strStorageLocationId_Original') THEN 0
																					ELSE 1
																			END 
		        , ysnForRevert												= CASE
																					WHEN [Changes].oldColumnName IN('strFamily_Original', 'strClass_Original', 'strProductCode_Original', 'strVendor_Original', 'strStorageLocation_Original') THEN 0
																					ELSE 1
																			END
		FROM 
		(
			SELECT DISTINCT intItemId,intItemLocationId, oldColumnName, strOldData, strNewData
			FROM @tblItemLocationForCStore
			unpivot
			(
				strOldData for oldColumnName in (strTaxFlag1_Original, strTaxFlag2_Original, strTaxFlag3_Original, strTaxFlag4_Original, strDepositRequired_Original, strDepositPLUId_Original, strQuantityRequired_Original, strScaleItem_Original, strFoodStampable_Original
				                                 , strReturnable_Original, strSaleable_Original, strIdRequiredLiquor_Original,strIdRequiredCigarette_Original, strPromotionalItem_Original, strPrePriced_Original, strApplyBlueLaw1_Original, strApplyBlueLaw2_Original
												 , strCountedDaily_Original, strCounted_Original, strCountBySINo_Original, strFamily_Original, strClass_Original, strProductCode_Original, strVendor_Original, strMinimumAge_Original, strMinOrder_Original
												 , strSuggestedQty_Original, strStorageLocation_Original
												 
												 , strFamilyId_Original, strClassId_Original, strProductCodeId_Original, strVendorId_Original, strStorageLocationId_Original)
			) o
			unpivot
			(
				strNewData for newColumnName in (strTaxFlag1_New, strTaxFlag2_New, strTaxFlag3_New, strTaxFlag4_New, strDepositRequired_New, strDepositPLUId_New, strQuantityRequired_New, strScaleItem_New, strFoodStampable_New
				                                 , strReturnable_New, strSaleable_New, strIdRequiredLiquor_New,strIdRequiredCigarette_New, strPromotionalItem_New, strPrePriced_New, strApplyBlueLaw1_New, strApplyBlueLaw2_New
												 , strCountedDaily_New, strCounted_New, strCountBySINo_New, strFamily_New,strClass_New, strProductCode_New, strVendor_New, strMinimumAge_New, strMinOrder_New
												 , strSuggestedQty_New, strStorageLocation_New
												 
												 , strFamilyId_New, strClassId_New, strProductCodeId_New, strVendorId_New, strStorageLocationId_New)
			) n
			WHERE  REPLACE(oldColumnName, '_Original', '') = REPLACE(newColumnName, '_New', '')
		) [Changes]
		JOIN tblICItem I 
			ON [Changes].intItemId = I.intItemId
		JOIN tblICItemPricing P
			ON I.intItemId = P.intItemId
		JOIN tblICItemLocation IL 
			ON I.intItemId = IL.intItemId 
			AND [Changes].intItemLocationId = IL.intItemLocationId
		JOIN tblICItemUOM UOM
			ON IL.intItemId = UOM.intItemId
		JOIN tblSMCompanyLocation CL 
			ON IL.intLocationId = CL.intCompanyLocationId
		WHERE 	 
		(
			@dblPriceBetween1 IS NULL 
			OR ISNULL(P.dblSalePrice, 0) >= @dblPriceBetween1
		)
		AND 
		(
			@dblPriceBetween2 IS NULL 
			OR ISNULL(P.dblSalePrice, 0) <= @dblPriceBetween2
		)
		AND
		(
			NOT EXISTS (SELECT TOP 1 1 FROM #tmpUpdateItemForCStore_Location)
			OR EXISTS (SELECT TOP 1 1 FROM #tmpUpdateItemForCStore_Location WHERE intLocationId = CL.intCompanyLocationId) 			
		)
		AND 
		(
			-- http://jira.irelyserver.com/browse/ST-846 
			NOT EXISTS (SELECT TOP 1 1 FROM tblICItemUOM WHERE intItemUOMId = @intItemUOMId)
			OR EXISTS (SELECT TOP 1 1 FROM tblICItemUOM WHERE intItemUOMId = @intItemUOMId AND intItemUOMId = UOM.intItemUOMId) 		
		)
		
		
		-- ===================================================================================
		-- [START] - Insert value to tblSTUpdateItemDataRevertHolder
		-- ===================================================================================
		IF(@ysnRecap = 0)
			BEGIN
				IF EXISTS(SELECT TOP 1 1 FROM @tblPreview WHERE ysnForRevert = 1)
					BEGIN
						DECLARE @intMassUpdatedRowCount AS INT = (SELECT COUNT(ysnForRevert) FROM @tblPreview WHERE ysnForRevert = 1)


					END
			END
		-- ===================================================================================
		-- [END] - Insert value to tblSTUpdateItemDataRevertHolder
		-- ===================================================================================




	   ---------------------------------------------------------------------------------------
	   ----------------------------- START Query Preview -------------------------------------
	   ---------------------------------------------------------------------------------------
	   DELETE FROM @tblPreview WHERE ISNULL(strPreviewOldData, '') = ISNULL(strPreviewNewData, '')

-- TEST
SELECT DISTINCT * FROM @tblPreview

	   -- Query Preview display
	   SELECT DISTINCT 
	          strLocation
			  , strUpc
			  , strItemDescription
			  , strChangeDescription
			  , strPreviewOldData AS strOldData
			  , strPreviewNewData AS strNewData
	   FROM @tblPreview
	   WHERE ysnPreview = 1
	   ORDER BY strItemDescription, strChangeDescription ASC
    
	   DELETE FROM @tblPreview
	   ---------------------------------------------------------------------------------------
	   ----------------------------- END Query Preview ---------------------------------------
	   ---------------------------------------------------------------------------------------

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







		IF(@ysnRecap = 1)
			BEGIN
				GOTO ExitWithRollback

				-- INSERT TO PREVIEW TABLE
				INSERT INTO tblSTUpdateItemDataPreview
				(
					strGuid,
					strLocation,
					strUpc,
					strDescription,
					strChangeDescription,
					strOldData,
					strNewData,

					intItemId,
					intItemUOMId,
					intItemLocationId,
					intTableIdentityId,
					strTableName,
					strColumnName,
					strColumnDataType,
					intConcurrencyId
				)
				SELECT DISTINCT 
					@strGuid
					, strLocation
					, strUpc
					, strItemDescription
					, strChangeDescription
					, strPreviewOldData
					, strPreviewNewData

					, intItemId
					, intItemUOMId
					, intItemLocationId
					, intPrimaryKeyId
					, strTableName
					, strTableColumnName
					, strTableColumnDataType
					, 1
				FROM @tblPreview
				WHERE ysnPreview = 1
				ORDER BY strItemDescription, strChangeDescription ASC
			END
		ELSE
			BEGIN
				GOTO ExitWithCommit
			END

END TRY

BEGIN CATCH      
	
	 SET @ErrMsg = ERROR_MESSAGE()     
	 --SET @strResultMsg = ERROR_MESSAGE()
	 SET @strResultMsg = 'Error Message: ' + ERROR_MESSAGE() --+ '<\BR>' + 
	 IF @idoc <> 0 EXEC sp_xml_removedocument @idoc      
	 --RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')  
	 
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