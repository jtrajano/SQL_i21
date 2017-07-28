CREATE PROCEDURE [dbo].[uspSTUpdateItemData]
		-- Add the parameters for the stored procedure here
		@XML varchar(max)
	
	AS
	BEGIN TRY
    
	    
		DECLARE @ErrMsg					   NVARCHAR(MAX),
				@idoc					   INT,
				@Location 			       NVARCHAR(MAX),
				@Vendor                    NVARCHAR(MAX),
				@Category                  NVARCHAR(MAX),
				@Family                    NVARCHAR(MAX),
				@Class                     NVARCHAR(MAX),
				@UpcCode                   INT,
				@Description               NVARCHAR(250),
				@PriceBetween1             DECIMAL (18,6),
				@PriceBetween2             DECIMAL (18,6),
				@TaxFlag1ysn               NVARCHAR(1),
				@TaxFlag2ysn               NVARCHAR(1),
				@TaxFlag3ysn               NVARCHAR(1),
				@TaxFlag4ysn               NVARCHAR(1),
				@DepositRequiredysn        NVARCHAR(1),
				@DepositPLU                INT,
				@QuantityRequiredysn       NVARCHAR(1),
				@ScaleItemysn              NVARCHAR(1),
				@FoodStampableysn          NVARCHAR(1),
				@Returnableysn             NVARCHAR(1),
				@Saleableysn               NVARCHAR(1),
				@ID1Requiredysn            NVARCHAR(1),
				@ID2Requiredysn            NVARCHAR(1),
				@PromotionalItemysn        NVARCHAR(1),
				@PrePricedysn              NVARCHAR(1),
				@Activeysn                 NVARCHAR(1),
				@BlueLaw1ysn               NVARCHAR(1),
				@BlueLaw2ysn               NVARCHAR(1),
				@CountedDailyysn           NVARCHAR(1),
				@Counted                   NVARCHAR(50),
				@CountSerialysn            NVARCHAR(1),
				@StickReadingysn           NVARCHAR(1),
				@NewFamily                 INT,
				@NewClass                  INT,
				@NewProductCode            INT,
				@NewCategory               INT,
				@NewVendor                 INT,
				@NewInventoryGroup         INT,
				@NewCountCode              NVARCHAR(50),     
				@NewMinAge                 INT,
				@NewMinVendorOrderQty      DECIMAL(18,6),
				@NewVendorSuggestedQty     DECIMAL(18,6),
				@NewMinQtyOnHand           DECIMAL(18,6),
				@NewBinLocation            INT,
				@NewGLPurchaseAccount      INT,
			    @NewGLSalesAccount         INT,
				@NewGLVarianceAccount      INT,
				@ysnPreview				   NVARCHAR(1),
				@currentUserId			   INT
				

	                  
		EXEC sp_xml_preparedocument @idoc OUTPUT, @XML 
	
		SELECT	
				@Location	   	 =	 Location,
				@Vendor          =   Vendor,
				@Category        =   Category,
				@Family          =   Family,
				@Class           =   Class,
				@UpcCode         =   UPCCode,
				@Description     =   ItmDescription,
				@PriceBetween1   =   PriceBetween1,
				@PriceBetween2   =   PriceBetween2,
				@TaxFlag1ysn     =   TaxFlag1ysn,
				@TaxFlag2ysn     =   TaxFlag2ysn ,           
				@TaxFlag3ysn     =   TaxFlag3ysn,          
				@TaxFlag4ysn     =   TaxFlag4ysn,           
				@DepositRequiredysn = DepositRequiredysn, 
				@DepositPLU       =  DepositPLU,
				@QuantityRequiredysn = QuantityRequiredysn,
				@ScaleItemysn     =  ScaleItemysn,
				@FoodStampableysn =  FoodStampableysn,
				@Returnableysn    =  Returnableysn,
				@Saleableysn      =  Saleableysn,
				@ID1Requiredysn   =  ID1Requiredysn,                  
				@ID2Requiredysn   =  ID2Requiredysn,
				@PromotionalItemysn = PromotionalItemysn,
				@PrePricedysn     =  PrePricedysn,
				@Activeysn        =  Activeysn,
				@BlueLaw1ysn      =  BlueLaw1ysn,
				@BlueLaw2ysn      =  BlueLaw2ysn,
				@CountedDailyysn  =  CountedDailyysn,
				@Counted          =  Counted,
				@CountSerialysn   =  CountSerialysn,
				@StickReadingysn  =  StickReadingysn,
				@NewFamily        =  NewFamily,
				@NewClass         =  NewClass,
				@NewProductCode   =  NewProductCode,
				@NewCategory      =  NewCategory,
				@NewVendor        =  NewVendor,
				@NewInventoryGroup = NewInventoryGroup,
				@NewCountCode       = NewCountCode,
				@NewMinAge          = NewMinAge,
				@NewMinVendorOrderQty = NewMinVendorOrderQty,
				@NewVendorSuggestedQty = NewVendorSuggestedQty,
				@NewMinQtyOnHand     = NewMinQtyOnHand,
				@NewBinLocation      = NewBinLocation,
				@NewGLPurchaseAccount  = NewGLPurchaseAccount,
			    @NewGLSalesAccount     = NewGLSalesAccount,
			    @NewGLVarianceAccount  = NewGLVarianceAccount,
				@ysnPreview     = ysnPreview,
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
				NewGLVarianceAccount      INT,
				ysnPreview                NVARCHAR(1),
				currentUserId			  INT
			)  
		-- Insert statements for procedure here

		  DECLARE @SQL1 NVARCHAR(MAX)

		  DECLARE @FamilyId NVARCHAR(250)
		  DECLARE @ClassId  NVARCHAR(250)
		  DECLARE @ProductCode NVARCHAR(250)
		  DECLARE @VendorId NVARCHAR(250)
		  DECLARE @NewDepositPluId NVARCHAR(250)
		  DECLARE @NewInventoryCountGroupId NVARCHAR(250)

		  DECLARE @UpdateCount INT
		  DECLARE @RecCount INT

	      SET @UpdateCount = 0
		  SET @RecCount = 0

		  --============================================================
			-- AUDIT LOGS
			DECLARE @ParentTableAuditLog NVARCHAR(MAX)
			SET @ParentTableAuditLog = ''

			DECLARE @ChildTableAuditLog NVARCHAR(MAX)
			SET @ChildTableAuditLog = ''

			DECLARE @JsonStringAuditLog NVARCHAR(MAX)
			SET @JsonStringAuditLog = ''

			DECLARE @checkComma bit
		 --============================================================

			--Declare temp01 table holder
			DECLARE @tblTempOne TABLE 
			(
				strLocation NVARCHAR(250)
				, strUpc NVARCHAR(50)
				, strItemDescription NVARCHAR(250)
				, strChangeDescription NVARCHAR(100)
				, strOldData NVARCHAR(MAX)
				, strNewData NVARCHAR(MAX)
				, intParentId INT
				, intChildId INT
			)

			--Declare temp02 table holder (w/ distinct)
			DECLARE @tblTempTwo TABLE 
			(
				strUpc NVARCHAR(50)
				, strItemDescription NVARCHAR(250)
				, strChangeDescription NVARCHAR(100)
				, strOldData NVARCHAR(MAX)
				, strNewData NVARCHAR(MAX)
				, intParentId INT
				, intChildId INT
			)

			--Declare ParentId holder
			DECLARE @tblId TABLE 
			(
				intId INT
			)

			--=======================================================
			--Use in while loop
			DECLARE @RowCountMax INT
			SET @RowCountMax = 0

			DECLARE @RowCountMin INT
			SET @RowCountMin = 0

			DECLARE @strChangeDescription NVARCHAR(100)
			SET @strChangeDescription = ''

			DECLARE @strOldData NVARCHAR(100)
			SET @strOldData = ''

			DECLARE @strNewData NVARCHAR(100)
			SET @strNewData = ''

			DECLARE @intParentId INT
			SET @intParentId = 0

			DECLARE @intChildId INT
			SET @intChildId = 0
			--=======================================================

			--Get currency decimal
			DECLARE @CompanyCurrencyDecimal NVARCHAR(1)
			SET @CompanyCurrencyDecimal = 0
			SELECT @CompanyCurrencyDecimal = intCurrencyDecimal from tblSMCompanyPreference

	 --PRINT '@strTaxFlag1ysn'
	 -----------------------------------Handle Dynamic Query 1
	 IF (@TaxFlag1ysn IS NOT NULL)
	 BEGIN
		 --IF (@strDepositRequiredysn IS NOT NULL)
		 --BEGIN
		 --END
		 SET @SQL1 = dbo.fnSTDynamicQueryItemData
				(
					'Tax Flag1'
					, 'CASE WHEN a.ysnTaxFlag1 = 0 THEN ''No'' ELSE ''Yes'' END'
					, 'CASE WHEN ' + CAST(@TaxFlag1ysn AS NVARCHAR(50)) + ' = 0 THEN ''No'' ELSE ''Yes'' END'
					, @Location
					, @Vendor
					, @Category
					, @Family
					, @Class
					, @UpcCode
					, @Description
					, @PriceBetween1
					, @PriceBetween2
					, 'd.intItemId'
					, 'a.intItemLocationId' 
				)

				----TEST
				--INSERT INTO TestDatabase.dbo.tblPerson(strFirstName, strLastName)
				--VALUES(@SQL1, 'Tax Flag1')

			INSERT @tblTempOne
			EXEC (@SQL1) 
	 END 


	 --PRINT '@strTaxFlag2ysn'
	 -----------------------------------Handle Dynamic Query 2
	 IF (@TaxFlag2ysn IS NOT NULL)
	 BEGIN
		 --IF (@strDepositRequiredysn IS NOT NULL)
		 --BEGIN
		 --END
		 SET @SQL1 = dbo.fnSTDynamicQueryItemData
				(
					'Tax Flag2'
					, 'CASE WHEN a.ysnTaxFlag2 = 0 THEN ''No'' ELSE ''Yes'' END'
					, 'CASE WHEN ' + CAST(@TaxFlag2ysn AS NVARCHAR(50)) + ' = 0 THEN ''No'' ELSE ''Yes'' END'
					, @Location
					, @Vendor
					, @Category
					, @Family
					, @Class
					, @UpcCode
					, @Description
					, @PriceBetween1
					, @PriceBetween2
					, 'd.intItemId'
					, 'a.intItemLocationId'
				)

			INSERT @tblTempOne
			EXEC (@SQL1) 
	 END 


	 --PRINT '@strTaxFlag3ysn'
	 -----------------------------------Handle Dynamic Query 3
	 IF (@TaxFlag3ysn IS NOT NULL)
	 BEGIN
		 --IF (@strDepositRequiredysn IS NOT NULL)
		 --BEGIN
		 --END
		 SET @SQL1 = dbo.fnSTDynamicQueryItemData
				(
					'Tax Flag3'
					, 'CASE WHEN a.ysnTaxFlag3 = 0 THEN ''No'' ELSE ''Yes'' END'
					, 'CASE WHEN ' + CAST(@TaxFlag3ysn AS NVARCHAR(50)) + ' = 0 THEN ''No'' ELSE ''Yes'' END'
					, @Location
					, @Vendor
					, @Category
					, @Family
					, @Class
					, @UpcCode
					, @Description
					, @PriceBetween1
					, @PriceBetween2
					, 'd.intItemId'
					, 'a.intItemLocationId'
				)

			INSERT @tblTempOne
			EXEC (@SQL1) 
	 END 


	 --PRINT '@strTaxFlag4ysn'
	 -----------------------------------Handle Dynamic Query 4
	 IF (@TaxFlag4ysn IS NOT NULL)
	 BEGIN
		 --IF (@strDepositRequiredysn IS NOT NULL)
		 --BEGIN
		 --END  
		 SET @SQL1 = dbo.fnSTDynamicQueryItemData
				(
					'Tax Flag4'
					, 'CASE WHEN a.ysnTaxFlag4 = 0 THEN ''No'' ELSE ''Yes'' END'
					, 'CASE WHEN ' + CAST(@TaxFlag4ysn AS NVARCHAR(50)) + ' = 0 THEN ''No'' ELSE ''Yes'' END'
					, @Location
					, @Vendor
					, @Category
					, @Family
					, @Class
					, @UpcCode
					, @Description
					, @PriceBetween1
					, @PriceBetween2
					, 'd.intItemId'
					, 'a.intItemLocationId'
				)

			INSERT @tblTempOne
			EXEC (@SQL1) 
	 END


	 --PRINT '@strDepositRequiredysn'
	 -----------------------------------Handle Dynamic Query 5
	 IF (@DepositRequiredysn IS NOT NULL)
	 BEGIN
		    SET @SQL1 = dbo.fnSTDynamicQueryItemData
			(
				'Deposit Required'
				, 'CASE WHEN a.ysnDepositRequired = 0 THEN ''No'' ELSE ''Yes'' END'
				, 'CASE WHEN ' + CAST(@DepositRequiredysn AS NVARCHAR(50)) + ' = 0 THEN ''No'' ELSE ''Yes'' END'
				, @Location
				, @Vendor
				, @Category
				, @Family
				, @Class
				, @UpcCode
				, @Description
				, @PriceBetween1
				, @PriceBetween2
				, 'd.intItemId'
				, 'a.intItemLocationId'
			)

		INSERT @tblTempOne
		EXEC (@SQL1) 
	 END 


	 --PRINT '@intDepositPLU'
	 -----------------------------------Handle Dynamic Query 6
	 IF (@DepositPLU IS NOT NULL)
	 BEGIN

			SELECT @NewDepositPluId = strUpcCode from tblICItemUOM where intItemUOMId = @DepositPLU

		    SET @SQL1 = dbo.fnSTDynamicQueryItemData
			(
				'Deposit PLU'
				, '(select strUpcCode from tblICItemUOM where intItemUOMId = a.intDepositPLUId)'
				, 'CAST(' + CAST(@NewDepositPluId AS NVARCHAR(50)) + ' AS NVARCHAR(50))'
				, @Location
				, @Vendor
				, @Category
				, @Family
				, @Class
				, @UpcCode
				, @Description
				, @PriceBetween1
				, @PriceBetween2
				, 'd.intItemId'
				, 'a.intItemLocationId'
			)


		INSERT @tblTempOne
		EXEC (@SQL1) 
	 END 


	 --PRINT '@strQuantityRequiredysn'
	 -----------------------------------Handle Dynamic Query 7
	 IF (@QuantityRequiredysn IS NOT NULL)
	 BEGIN
		    SET @SQL1 = dbo.fnSTDynamicQueryItemData
			(
				'Quantity Required'
				, 'CASE WHEN a.ysnQuantityRequired = 0 THEN ''No'' ELSE ''Yes'' END'
				, 'CASE WHEN ' + CAST(@QuantityRequiredysn AS NVARCHAR(50)) + ' = 0 THEN ''No'' ELSE ''Yes'' END'
				, @Location
				, @Vendor
				, @Category
				, @Family
				, @Class
				, @UpcCode
				, @Description
				, @PriceBetween1
				, @PriceBetween2
				, 'd.intItemId'
				, 'a.intItemLocationId'
			)

		INSERT @tblTempOne
		EXEC (@SQL1) 
	 END 


	 --PRINT 'strScaleItemysn'
	 -----------------------------------Handle Dynamic Query 8
	 IF (@ScaleItemysn IS NOT NULL)
	 BEGIN
		    SET @SQL1 = dbo.fnSTDynamicQueryItemData
			(
				'Scale Item'
				, 'CASE WHEN a.ysnScaleItem = 0 THEN ''No'' ELSE ''Yes'' END'
				, 'CASE WHEN ' + CAST(@ScaleItemysn AS NVARCHAR(50)) + ' = 0 THEN ''No'' ELSE ''Yes'' END'
				, @Location
				, @Vendor
				, @Category
				, @Family
				, @Class
				, @UpcCode
				, @Description
				, @PriceBetween1
				, @PriceBetween2
				, 'd.intItemId'
				, 'a.intItemLocationId'
			)

		INSERT @tblTempOne
		EXEC (@SQL1) 
	 END 


	 --PRINT '@strFoodStampableysn'
	 -----------------------------------Handle Dynamic Query 9
	 IF (@FoodStampableysn IS NOT NULL)
	 BEGIN
		    SET @SQL1 = dbo.fnSTDynamicQueryItemData
			(
				'Food Stampable'
				, 'CASE WHEN a.ysnFoodStampable = 0 THEN ''No'' ELSE ''Yes'' END'
				, 'CASE WHEN ' + CAST(@FoodStampableysn AS NVARCHAR(50)) + ' = 0 THEN ''No'' ELSE ''Yes'' END'
				, @Location
				, @Vendor
				, @Category
				, @Family
				, @Class
				, @UpcCode
				, @Description
				, @PriceBetween1
				, @PriceBetween2
				, 'd.intItemId'
				, 'a.intItemLocationId'
			)

		INSERT @tblTempOne
		EXEC (@SQL1) 
	 END 


	 --PRINT '@strReturnableysn'
	 -----------------------------------Handle Dynamic Query 10
	 IF (@Returnableysn IS NOT NULL)
	 BEGIN
		    SET @SQL1 = dbo.fnSTDynamicQueryItemData
			(
				'Returnable'
				, 'CASE WHEN a.ysnReturnable = 0 THEN ''No'' ELSE ''Yes'' END'
				, 'CASE WHEN ' + CAST(@Returnableysn AS NVARCHAR(50)) + ' = 0 THEN ''No'' ELSE ''Yes'' END'
				, @Location
				, @Vendor
				, @Category
				, @Family
				, @Class
				, @UpcCode
				, @Description
				, @PriceBetween1
				, @PriceBetween2
				, 'd.intItemId'
				, 'a.intItemLocationId'
			)

		INSERT @tblTempOne
		EXEC (@SQL1) 
	 END 


	 --PRINT '@strSaleableysn'
	 -----------------------------------Handle Dynamic Query 11
	 IF (@Saleableysn IS NOT NULL)
	 BEGIN
		    SET @SQL1 = dbo.fnSTDynamicQueryItemData
			(
				'Saleable'
				, 'CASE WHEN a.ysnSaleable = 0 THEN ''No'' ELSE ''Yes'' END'
				, 'CASE WHEN ' + CAST(@Saleableysn AS NVARCHAR(50)) + ' = 0 THEN ''No'' ELSE ''Yes'' END'
				, @Location
				, @Vendor
				, @Category
				, @Family
				, @Class
				, @UpcCode
				, @Description
				, @PriceBetween1
				, @PriceBetween2
				, 'd.intItemId'
				, 'a.intItemLocationId'
			)

		INSERT @tblTempOne
		EXEC (@SQL1) 
	 END 


	 --PRINT '@strID1Requiredysn'
	 -----------------------------------Handle Dynamic Query 12
	 IF (@ID1Requiredysn IS NOT NULL)
	 BEGIN
		    SET @SQL1 = dbo.fnSTDynamicQueryItemData
			(
				'Liquor Id Required'
				, 'CASE WHEN a.ysnIdRequiredLiquor = 0 THEN ''No'' ELSE ''Yes'' END'
				, 'CASE WHEN ' + CAST(@ID1Requiredysn AS NVARCHAR(50)) + ' = 0 THEN ''No'' ELSE ''Yes'' END'
				, @Location
				, @Vendor
				, @Category
				, @Family
				, @Class
				, @UpcCode
				, @Description
				, @PriceBetween1
				, @PriceBetween2
				, 'd.intItemId'
				, 'a.intItemLocationId'
			)

		INSERT @tblTempOne
		EXEC (@SQL1) 
	 END 


	 --PRINT '@strID2Requiredysn'
	 -----------------------------------Handle Dynamic Query 13
	 IF (@ID2Requiredysn IS NOT NULL)
	 BEGIN

		    SET @SQL1 = dbo.fnSTDynamicQueryItemData
			(
				'Cigarette Id Required'
				, 'CASE WHEN a.ysnIdRequiredCigarette = 0 THEN ''No'' ELSE ''Yes'' END'
				, 'CASE WHEN ' + CAST(@ID2Requiredysn AS NVARCHAR(50)) + ' = 0 THEN ''No'' ELSE ''Yes'' END'
				, @Location
				, @Vendor
				, @Category
				, @Family
				, @Class
				, @UpcCode
				, @Description
				, @PriceBetween1
				, @PriceBetween2
				, 'd.intItemId'
				, 'a.intItemLocationId'
			)

		INSERT @tblTempOne
		EXEC (@SQL1) 
	 END 


	 --PRINT '@strPromotionalItemysn'
	 -----------------------------------Handle Dynamic Query 14
	 IF (@PromotionalItemysn IS NOT NULL)
	 BEGIN

		    SET @SQL1 = dbo.fnSTDynamicQueryItemData
			(
				'Promotional Item'
				, 'CASE WHEN a.ysnPromotionalItem = 0 THEN ''No'' ELSE ''Yes'' END'
				, 'CASE WHEN ' + CAST(@PromotionalItemysn AS NVARCHAR(50)) + ' = 0 THEN ''No'' ELSE ''Yes'' END'
				, @Location
				, @Vendor
				, @Category
				, @Family
				, @Class
				, @UpcCode
				, @Description
				, @PriceBetween1
				, @PriceBetween2
				, 'd.intItemId'
				, 'a.intItemLocationId'
			)

		INSERT @tblTempOne
		EXEC (@SQL1) 
	 END 


	 --PRINT '@strPrePricedysn'
	 -----------------------------------Handle Dynamic Query 15
	 IF (@PrePricedysn IS NOT NULL)
	 BEGIN

		    SET @SQL1 = dbo.fnSTDynamicQueryItemData
			(
				'Pre Priced'
				, 'CASE WHEN a.ysnPrePriced = 0 THEN ''No'' ELSE ''Yes'' END'
				, 'CASE WHEN ' + CAST(@PrePricedysn AS NVARCHAR(50)) + ' = 0 THEN ''No'' ELSE ''Yes'' END'
				, @Location
				, @Vendor
				, @Category
				, @Family
				, @Class
				, @UpcCode
				, @Description
				, @PriceBetween1
				, @PriceBetween2
				, 'd.intItemId'
				, 'a.intItemLocationId'
			)

		INSERT @tblTempOne
		EXEC (@SQL1) 
	 END 


	 --PRINT '@strBlueLaw1ysn'
	 -----------------------------------Handle Dynamic Query 16
	 IF (@BlueLaw1ysn IS NOT NULL)
	 BEGIN

		    SET @SQL1 = dbo.fnSTDynamicQueryItemData
			(
				'Blue Law1'
				, 'CASE WHEN a.ysnApplyBlueLaw1 = 0 THEN ''No'' ELSE ''Yes'' END'
				, 'CASE WHEN ' + CAST(@BlueLaw1ysn AS NVARCHAR(50)) + ' = 0 THEN ''No'' ELSE ''Yes'' END'
				, @Location
				, @Vendor
				, @Category
				, @Family
				, @Class
				, @UpcCode
				, @Description
				, @PriceBetween1
				, @PriceBetween2
				, 'd.intItemId'
				, 'a.intItemLocationId'
			)

		INSERT @tblTempOne
		EXEC (@SQL1) 
	 END 


	 --PRINT '@strBlueLaw2ysn'
	 -----------------------------------Handle Dynamic Query 17
	 IF (@BlueLaw2ysn IS NOT NULL)
	 BEGIN

		    SET @SQL1 = dbo.fnSTDynamicQueryItemData
			(
				'Blue Law2'
				, 'CASE WHEN a.ysnApplyBlueLaw2 = 0 THEN ''No'' ELSE ''Yes'' END'
				, 'CASE WHEN ' + CAST(@BlueLaw2ysn AS NVARCHAR(50)) + ' = 0 THEN ''No'' ELSE ''Yes'' END'
				, @Location
				, @Vendor
				, @Category
				, @Family
				, @Class
				, @UpcCode
				, @Description
				, @PriceBetween1
				, @PriceBetween2
				, 'd.intItemId'
				, 'a.intItemLocationId'
			)

		INSERT @tblTempOne
		EXEC (@SQL1) 
	 END 


	 --PRINT '@strCountedDailyysn'
	 -----------------------------------Handle Dynamic Query 18
	 IF (@CountedDailyysn IS NOT NULL)
	 BEGIN

		    SET @SQL1 = dbo.fnSTDynamicQueryItemData
			(
				'Counted Daily'
				, 'CASE WHEN a.ysnCountedDaily = 0 THEN ''No'' ELSE ''Yes'' END'
				, 'CASE WHEN ' + CAST(@CountedDailyysn AS NVARCHAR(50)) + ' = 0 THEN ''No'' ELSE ''Yes'' END'
				, @Location
				, @Vendor
				, @Category
				, @Family
				, @Class
				, @UpcCode
				, @Description
				, @PriceBetween1
				, @PriceBetween2
				, 'd.intItemId'
				, 'a.intItemLocationId'
			)

		INSERT @tblTempOne
		EXEC (@SQL1) 
	 END 


	 --PRINT '@strCounted'
	 -----------------------------------Handle Dynamic Query 19
	 IF (@Counted IS NOT NULL)
	 BEGIN

		    SET @SQL1 = dbo.fnSTDynamicQueryItemData
			(
				'Counted'
				, 'a.strCounted'
				, 'CAST(''' + CAST(@Counted AS NVARCHAR(50)) + ''' AS NVARCHAR(250))'
				, @Location
				, @Vendor
				, @Category
				, @Family
				, @Class
				, @UpcCode
				, @Description
				, @PriceBetween1
				, @PriceBetween2
				, 'd.intItemId'
				, 'a.intItemLocationId'
			)

		INSERT @tblTempOne
		EXEC (@SQL1) 
	 END 


	 --PRINT '@strCountSerialysn'
	 -----------------------------------Handle Dynamic Query 20
	 IF (@CountSerialysn IS NOT NULL)
	 BEGIN

		    SET @SQL1 = dbo.fnSTDynamicQueryItemData
			(
				'Count By Serial No'
				, 'CASE WHEN a.ysnCountBySINo = 0 THEN ''No'' ELSE ''Yes'' END'
				, 'CASE WHEN ' + CAST(@CountSerialysn AS NVARCHAR(50)) + ' = 0 THEN ''No'' ELSE ''Yes'' END'
				, @Location
				, @Vendor
				, @Category
				, @Family
				, @Class
				, @UpcCode
				, @Description
				, @PriceBetween1
				, @PriceBetween2
				, 'd.intItemId'
				, 'a.intItemLocationId'
			)

		INSERT @tblTempOne
		EXEC (@SQL1) 
	 END 


	 --PRINT '@intNewFamily'
	 -----------------------------------Handle Dynamic Query 21
	 IF (@NewFamily IS NOT NULL)
	 BEGIN

		SELECT @FamilyId = strSubcategoryId FROM tblSTSubcategory WHERE intSubcategoryId = @NewFamily

		    SET @SQL1 = dbo.fnSTDynamicQueryItemData
			(
				'Family'
				, '(SELECT strSubcategoryId FROM tblSTSubcategory WHERE intSubcategoryId = a.intFamilyId)'
				, 'CAST(''' + CAST(@FamilyId AS NVARCHAR(50)) + ''' AS NVARCHAR(250))'
				, @Location
				, @Vendor
				, @Category
				, @Family
				, @Class
				, @UpcCode
				, @Description
				, @PriceBetween1
				, @PriceBetween2
				, 'd.intItemId'
				, 'a.intItemLocationId'
			)

		INSERT @tblTempOne
		EXEC (@SQL1) 
	 END 


	 --PRINT '@intNewClass'
	 -----------------------------------Handle Dynamic Query 22
	 IF (@NewClass IS NOT NULL)
	 BEGIN

		SELECT @ClassId = strSubcategoryId from tblSTSubcategory where intSubcategoryId = @NewClass

		    SET @SQL1 = dbo.fnSTDynamicQueryItemData
			(
				'Class'
				, '(SELECT strSubcategoryId FROM tblSTSubcategory WHERE intSubcategoryId = a.intClassId )'
				, 'CAST(''' + CAST(@ClassId AS NVARCHAR(50)) + ''' AS NVARCHAR(250))'
				, @Location
				, @Vendor
				, @Category
				, @Family
				, @Class
				, @UpcCode
				, @Description
				, @PriceBetween1
				, @PriceBetween2
				, 'd.intItemId'
				, 'a.intItemLocationId'
			)

		INSERT @tblTempOne
		EXEC (@SQL1) 
	 END 


	 --PRINT '@intNewProductCode'
	 -----------------------------------Handle Dynamic Query 23
	 IF (@NewProductCode IS NOT NULL)
	 BEGIN

		SELECT @ProductCode = strRegProdCode from tblSTSubcategoryRegProd where intRegProdId = @NewProductCode

		    SET @SQL1 = dbo.fnSTDynamicQueryItemData
			(
				'Product Code'
				, '( select strRegProdCode from tblSTSubcategoryRegProd where intRegProdId = a.intProductCodeId )'
				, 'CAST(' + CAST(@ProductCode AS NVARCHAR(50)) + ' AS NVARCHAR(250))'
				, @Location
				, @Vendor
				, @Category
				, @Family
				, @Class
				, @UpcCode
				, @Description
				, @PriceBetween1
				, @PriceBetween2
				, 'd.intItemId'
				, 'a.intItemLocationId'
			)

		INSERT @tblTempOne
		EXEC (@SQL1) 
	 END 


	 --PRINT '@intNewVendor'
	 -----------------------------------Handle Dynamic Query 24
	 IF (@NewVendor IS NOT NULL)
	 BEGIN

		SELECT @VendorId = strName from tblEMEntity where intEntityId = @NewVendor

		    SET @SQL1 = dbo.fnSTDynamicQueryItemData
			(
				'Vendor'
				, '( select strName from tblEMEntity where intEntityId = a.intVendorId )'
				, 'CAST(''' + CAST(@VendorId AS NVARCHAR(50)) + ''' AS NVARCHAR(50))'
				, @Location
				, @Vendor
				, @Category
				, @Family
				, @Class
				, @UpcCode
				, @Description
				, @PriceBetween1
				, @PriceBetween2
				, 'd.intItemId'
				, 'a.intItemLocationId'
			)

		INSERT @tblTempOne
		EXEC (@SQL1) 
	 END 


	 --PRINT '@intNewMinAge'
	 -----------------------------------Handle Dynamic Query 25
	 IF (@NewMinAge IS NOT NULL)
	 BEGIN

		    SET @SQL1 = dbo.fnSTDynamicQueryItemData
			(
				'Minimum Age'
				, 'a.intMinimumAge'
				, 'CAST(' + CAST(@NewMinAge AS NVARCHAR(50)) + ' AS NVARCHAR(250))'
				, @Location
				, @Vendor
				, @Category
				, @Family
				, @Class
				, @UpcCode
				, @Description
				, @PriceBetween1
				, @PriceBetween2
				, 'd.intItemId'
				, 'a.intItemLocationId'
			)

		INSERT @tblTempOne
		EXEC (@SQL1) 
	 END


	 --PRINT '@dblNewMinVendorOrderQty'
	 -----------------------------------Handle Dynamic Query 26
	 IF (@NewMinVendorOrderQty IS NOT NULL)
	 BEGIN

		    SET @SQL1 = dbo.fnSTDynamicQueryItemData
			(
				'Vendor Minimum Order Qty'
				, 'a.dblMinOrder'
				, 'CAST(' + CAST(@NewMinVendorOrderQty AS NVARCHAR(50)) + ' AS NVARCHAR(250))'
				, @Location
				, @Vendor
				, @Category
				, @Family
				, @Class
				, @UpcCode
				, @Description
				, @PriceBetween1
				, @PriceBetween2
				, 'd.intItemId'
				, 'a.intItemLocationId'
			)

		INSERT @tblTempOne
		EXEC (@SQL1) 
	 END


	 --PRINT '@dblNewVendorSuggestedQty'
	 -----------------------------------Handle Dynamic Query 27
	 IF (@NewVendorSuggestedQty IS NOT NULL)
	 BEGIN

		    SET @SQL1 = dbo.fnSTDynamicQueryItemData
			(
				'Vendor Suggested Qty'
				, 'a.dblSuggestedQty'
				, 'CAST(' + CAST(@NewVendorSuggestedQty AS NVARCHAR(50)) + ' AS NVARCHAR(250))'
				, @Location
				, @Vendor
				, @Category
				, @Family
				, @Class
				, @UpcCode
				, @Description
				, @PriceBetween1
				, @PriceBetween2
				, 'd.intItemId'
				, 'a.intItemLocationId'
			)

		INSERT @tblTempOne
		EXEC (@SQL1) 
	 END


	 --PRINT '@dblNewMinQtyOnHand'
	 -----------------------------------Handle Dynamic Query 28
	 IF (@NewMinQtyOnHand IS NOT NULL)
	 BEGIN
		    SET @SQL1 = dbo.fnSTDynamicQueryItemData
			(
				'Min Qty On Hand'
				, 'a.dblReorderPoint'
				, 'CAST(' + CAST(@NewMinQtyOnHand AS NVARCHAR(50)) + ' AS NVARCHAR(250))'
				, @Location
				, @Vendor
				, @Category
				, @Family
				, @Class
				, @UpcCode
				, @Description
				, @PriceBetween1
				, @PriceBetween2
				, 'd.intItemId'
				, 'a.intItemLocationId'
			)

		INSERT @tblTempOne
		EXEC (@SQL1) 
	 END


	 --PRINT '@intNewInventoryGroup'
	 -----------------------------------Handle Dynamic Query 29
	 IF (@NewInventoryGroup IS NOT NULL)
	 BEGIN

		    SET @SQL1 = dbo.fnSTDynamicQueryItemData
			(
				'Inventory Group'
				, '( SELECT strCountGroup FROM tblICCountGroup WHERE intCountGroupId = a.intCountGroupId )'
				, 'CAST(' + CAST(@NewInventoryGroup AS NVARCHAR(50)) + ' AS NVARCHAR(250))'
				, @Location
				, @Vendor
				, @Category
				, @Family
				, @Class
				, @UpcCode
				, @Description
				, @PriceBetween1
				, @PriceBetween2
				, 'd.intItemId'
				, 'a.intItemLocationId'
			)

		INSERT @tblTempOne
		EXEC (@SQL1) 
	 END


	 --PRINT '@strNewCountCode'
	 -----------------------------------Handle Dynamic Query 30
	 IF (@NewCountCode IS NOT NULL)
	 BEGIN

		    SET @SQL1 = dbo.fnSTDynamicQueryItemData
			(
				'Count Code'
				, 'd.strCountCode'
				, 'CAST(''' + CAST(@NewCountCode AS NVARCHAR(50)) + ''' AS NVARCHAR(250))'
				, @Location
				, @Vendor
				, @Category
				, @Family
				, @Class
				, @UpcCode
				, @Description
				, @PriceBetween1
				, @PriceBetween2
				, 'd.intItemId'
				, 'a.intItemLocationId'
			)

		INSERT @tblTempOne
		EXEC (@SQL1) 
	 END


	 --PRINT '@intNewCategory'
	 -----------------------------------Handle Dynamic Query 31
	 IF (@NewCategory IS NOT NULL)
	 BEGIN
		    SET @SQL1 = dbo.fnSTDynamicQueryItemData
			(
				'Category'
				, '(select strCategoryCode from tblICCategory where intCategoryId = d.intCategoryId)'
				, '(select strCategoryCode from tblICCategory where intCategoryId = ' + CAST(@NewCategory AS NVARCHAR(50)) + ')'
				, @Location
				, @Vendor
				, @Category
				, @Family
				, @Class
				, @UpcCode
				, @Description
				, @PriceBetween1
				, @PriceBetween2
				, 'd.intItemId'
				, 'd.intItemId'
			)

		INSERT @tblTempOne
		EXEC (@SQL1) 
	 END


	 --PRINT '@intNewBinLocation'
	 -----------------------------------Handle Dynamic Query 32
	 IF (@NewBinLocation IS NOT NULL)
	 BEGIN

		    SET @SQL1 = dbo.fnSTDynamicQueryItemData
			(
				'Storage Location'
				, '( select strName from tblICStorageLocation where intStorageLocationId = a.intStorageLocationId )'
				, '( select strName from tblICStorageLocation where intStorageLocationId =  CAST( ' +  LTRIM(CAST(@NewBinLocation AS NVARCHAR(50))) +' AS INT))'
				, @Location
				, @Vendor
				, @Category
				, @Family
				, @Class
				, @UpcCode
				, @Description
				, @PriceBetween1
				, @PriceBetween2
				, 'd.intItemId'
				, 'a.intItemLocationId'
			)

		INSERT @tblTempOne
		EXEC (@SQL1) 
	 END


	 --PRINT '@intNewGLPurchaseAccount'
	 -----------------------------------Handle Dynamic Query 33
	 IF (@NewGLPurchaseAccount IS NOT NULL)
	 BEGIN
	 --, '''( select strAccountId from tblGLAccount where intAccountId =  CAST( ' +  LTRIM(@intNewGLPurchaseAccount) +' AS INT))'''
		    SET @SQL1 = dbo.fnSTDynamicQueryItemData
			(
				'Purchase Account'
				, '( select strAccountId from tblGLAccount where intAccountId = e.intAccountId )'
				, '( select strAccountId from tblGLAccount where intAccountId =  CAST( ' +  CAST(LTRIM(@NewGLPurchaseAccount) AS NVARCHAR(50)) +' AS INT))'
				--, (select strAccountId from tblGLAccount where intAccountId = @intNewGLPurchaseAccount)
				, @Location
				, @Vendor
				, @Category
				, @Family
				, @Class
				, @UpcCode
				, @Description
				, @PriceBetween1
				, @PriceBetween2
				, 'd.intItemId'
				, 'e.intItemAccountId'
			)

		INSERT @tblTempOne
		EXEC (@SQL1) 
	 END


	 --PRINT '@intNewGLSalesAccount'
	 -----------------------------------Handle Dynamic Query 34
	 IF (@NewGLSalesAccount IS NOT NULL)
	 BEGIN

		    SET @SQL1 = dbo.fnSTDynamicQueryItemData
			(
				'Sales Account'
				, '( select strAccountId from tblGLAccount where intAccountId = e.intAccountId )'
				, '( select strAccountId from tblGLAccount where intAccountId =  CAST( ' +  CAST(LTRIM(@NewGLSalesAccount) AS NVARCHAR(50)) +' AS INT))'
				, @Location
				, @Vendor
				, @Category
				, @Family
				, @Class
				, @UpcCode
				, @Description
				, @PriceBetween1
				, @PriceBetween2
				, 'd.intItemId'
				, 'e.intItemAccountId'
			)

		INSERT @tblTempOne
		EXEC (@SQL1) 
	 END


	 --PRINT '@intNewGLVarianceAccount'
	 -----------------------------------Handle Dynamic Query 35
	 IF (@NewGLVarianceAccount IS NOT NULL)
	 BEGIN

		    SET @SQL1 = dbo.fnSTDynamicQueryItemData
			(
				'Variance Account'
				, '( select strAccountId from tblGLAccount where intAccountId = e.intAccountId )'
				, '( select strAccountId from tblGLAccount where intAccountId =  CAST( ' +  CAST(LTRIM(@NewGLVarianceAccount) AS NVARCHAR(50)) +' AS INT))'
				, @Location
				, @Vendor
				, @Category
				, @Family
				, @Class
				, @UpcCode
				, @Description
				, @PriceBetween1
				, @PriceBetween2
				, 'd.intItemId'
				, 'e.intItemAccountId'
			)

		INSERT @tblTempOne
		EXEC (@SQL1) 
	 END


 --NEW
 SELECT @RecCount  = count(*) from @tblTempOne 
 DELETE FROM @tblTempOne WHERE strOldData = strNewData
 SELECT @UpdateCount = count(*) from @tblTempOne WHERE strOldData != strNewData

 --OLD
 --SELECT @RecCount  = count(*) from tblSTMassUpdateReportMaster 
 --DELETE FROM tblSTMassUpdateReportMaster WHERE OldData =  NewData
 --SELECT @UpdateCount = count(*) from tblSTMassUpdateReportMaster WHERE OldData !=  NewData



---Update Logic-------
--PRINT 'Update01'	      
IF((@ysnPreview != 'Y')
AND(@UpdateCount > 0))
   BEGIN

     IF ((@TaxFlag1ysn IS NOT NULL) OR (@TaxFlag2ysn IS NOT NULL)
			   OR (@TaxFlag3ysn IS NOT NULL) OR (@TaxFlag4ysn IS NOT NULL) 
			   OR (@DepositRequiredysn IS NOT NULL) OR (@DepositPLU IS NOT NULL)
			   OR (@QuantityRequiredysn IS NOT NULL) OR (@ScaleItemysn IS NOT NULL)
			   OR (@FoodStampableysn IS NOT NULL) OR (@Returnableysn IS NOT NULL)
			   OR (@Saleableysn IS NOT NULL) OR (@ID1Requiredysn IS NOT NULL)
			   OR (@ID2Requiredysn IS NOT NULL) OR (@PromotionalItemysn IS NOT NULL)
			   OR (@PrePricedysn IS NOT NULL) OR (@BlueLaw1ysn IS NOT NULL)
			   OR (@BlueLaw2ysn IS NOT NULL) OR(@CountedDailyysn IS NOT NULL)
			   OR (@Counted IS NOT NULL) OR (@CountSerialysn IS NOT NULL)
			   OR (@NewFamily IS NOT NULL) OR (@NewClass IS NOT NULL)
			   OR (@NewProductCode IS NOT NULL) OR (@NewVendor IS NOT NULL)
			   OR (@NewMinAge IS NOT NULL) OR (@NewMinVendorOrderQty IS NOT NULL)
			   OR (@NewVendorSuggestedQty IS NOT NULL) OR (@NewInventoryGroup IS NOT NULL)
			   OR (@NewBinLocation IS NOT NULL) OR (@NewMinQtyOnHand IS NOT NULL))
      BEGIN 
	     
		  SET @UpdateCount = 0

          SET @SQL1 = ' update tblICItemLocation set '

		  IF (@TaxFlag1ysn IS NOT NULL)
			  BEGIN
				set @SQL1 = @SQL1 + 'ysnTaxFlag1 = ''' + LTRIM(@TaxFlag1ysn) + ''''
			  END

		  IF (@TaxFlag2ysn IS NOT NULL)  
			  BEGIN
			  if (@TaxFlag1ysn IS NOT NULL)
 				 set @SQL1 = @SQL1 + ' , ysnTaxFlag2 = ''' + LTRIM(@TaxFlag2ysn) + ''''
			  else
				 set @SQL1 = @SQL1 + ' ysnTaxFlag2 = ''' + LTRIM(@TaxFlag2ysn) + '''' 
			  END

		  IF (@TaxFlag3ysn IS NOT NULL)  
			  BEGIN
			  if ((@TaxFlag1ysn IS NOT NULL) OR (@TaxFlag2ysn IS NOT NULL))   
 				 set @SQL1 = @SQL1 + ' , ysnTaxFlag3 = ''' + LTRIM(@TaxFlag3ysn) + ''''
			  else
				 set @SQL1 = @SQL1 + ' ysnTaxFlag3 = ''' + LTRIM(@TaxFlag3ysn) + '''' 
			  END

		  IF (@TaxFlag4ysn IS NOT NULL)  
			  BEGIN
			  if ((@TaxFlag1ysn IS NOT NULL) OR (@TaxFlag2ysn IS NOT NULL)
			  OR (@TaxFlag3ysn IS NOT NULL))   
 				 set @SQL1 = @SQL1 + ' , ysnTaxFlag4 = ''' + LTRIM(@TaxFlag4ysn) + ''''
			  else
				 set @SQL1 = @SQL1 + ' ysnTaxFlag4 = ''' + LTRIM(@TaxFlag4ysn) + '''' 
			  END

          IF (@DepositRequiredysn IS NOT NULL)  
			  BEGIN
			  if ((@TaxFlag1ysn IS NOT NULL) OR (@TaxFlag2ysn IS NOT NULL)
			  OR (@TaxFlag3ysn IS NOT NULL) OR (@TaxFlag4ysn IS NOT NULL))   
 				 set @SQL1 = @SQL1 + ' , ysnDepositRequired = ''' + LTRIM(@DepositRequiredysn) + ''''
			  else
				 set @SQL1 = @SQL1 + ' ysnDepositRequired = ''' + LTRIM(@DepositRequiredysn) + '''' 
			  END

           IF(@DepositPLU IS NOT NULL)
		     BEGIN
			   if ((@TaxFlag1ysn IS NOT NULL) OR (@TaxFlag2ysn IS NOT NULL)
			  OR (@TaxFlag3ysn IS NOT NULL) OR (@TaxFlag4ysn IS NOT NULL) 
			  OR (@DepositRequiredysn IS NOT NULL))   
 				 set @SQL1 = @SQL1 + ' , intDepositPLUId = ''' + LTRIM(@DepositPLU) + ''''
			  else
				 set @SQL1 = @SQL1 + ' intDepositPLUId = ''' + LTRIM(@DepositPLU) + '''' 
			 END

           IF(@QuantityRequiredysn IS NOT NULL)
		     BEGIN
			   if ((@TaxFlag1ysn IS NOT NULL) OR (@TaxFlag2ysn IS NOT NULL)
			   OR (@TaxFlag3ysn IS NOT NULL) OR (@TaxFlag4ysn IS NOT NULL) 
			   OR (@DepositRequiredysn IS NOT NULL) OR (@DepositPLU IS NOT NULL))   
 				  set @SQL1 = @SQL1 + ' , ysnQuantityRequired = ''' + LTRIM(@QuantityRequiredysn) + ''''
			   else
				  set @SQL1 = @SQL1 + ' ysnQuantityRequired = ''' + LTRIM(@QuantityRequiredysn) + '''' 
			 END

           IF(@ScaleItemysn IS NOT NULL)
		     BEGIN
			   if ((@TaxFlag1ysn IS NOT NULL) OR (@TaxFlag2ysn IS NOT NULL)
			   OR (@TaxFlag3ysn IS NOT NULL) OR (@TaxFlag4ysn IS NOT NULL) 
			   OR (@DepositRequiredysn IS NOT NULL) OR (@DepositPLU IS NOT NULL)
			   OR (@QuantityRequiredysn IS NOT NULL))   
 				  set @SQL1 = @SQL1 + ' , ysnScaleItem = ''' + LTRIM(@ScaleItemysn) + ''''
			   else
				  set @SQL1 = @SQL1 + ' ysnScaleItem = ''' + LTRIM(@ScaleItemysn) + '''' 
			 END

           IF(@FoodStampableysn IS NOT NULL)
		     BEGIN
			   if ((@TaxFlag1ysn IS NOT NULL) OR (@TaxFlag2ysn IS NOT NULL)
			   OR (@TaxFlag3ysn IS NOT NULL) OR (@TaxFlag4ysn IS NOT NULL) 
			   OR (@DepositRequiredysn IS NOT NULL) OR (@DepositPLU IS NOT NULL)
			   OR (@QuantityRequiredysn IS NOT NULL) OR (@ScaleItemysn IS NOT NULL))   
 				  set @SQL1 = @SQL1 + ' , ysnFoodStampable = ''' + LTRIM(@FoodStampableysn) + ''''
			   else
				  set @SQL1 = @SQL1 + ' ysnFoodStampable = ''' + LTRIM(@FoodStampableysn) + '''' 
			 END

           IF(@Returnableysn IS NOT NULL)
		     BEGIN
			   if ((@TaxFlag1ysn IS NOT NULL) OR (@TaxFlag2ysn IS NOT NULL)
			   OR (@TaxFlag3ysn IS NOT NULL) OR (@TaxFlag4ysn IS NOT NULL) 
			   OR (@DepositRequiredysn IS NOT NULL) OR (@DepositPLU IS NOT NULL)
			   OR (@QuantityRequiredysn IS NOT NULL) OR (@ScaleItemysn IS NOT NULL)
			   OR (@FoodStampableysn IS NOT NULL))   
 				  set @SQL1 = @SQL1 + ' , ysnReturnable = ''' + LTRIM(@Returnableysn) + ''''
			   else
				  set @SQL1 = @SQL1 + ' ysnReturnable = ''' + LTRIM(@Returnableysn) + '''' 
			 END

          IF(@Saleableysn IS NOT NULL)
		     BEGIN
			   if ((@TaxFlag1ysn IS NOT NULL) OR (@TaxFlag2ysn IS NOT NULL)
			   OR (@TaxFlag3ysn IS NOT NULL) OR (@TaxFlag4ysn IS NOT NULL) 
			   OR (@DepositRequiredysn IS NOT NULL) OR (@DepositPLU IS NOT NULL)
			   OR (@QuantityRequiredysn IS NOT NULL) OR (@ScaleItemysn IS NOT NULL)
			   OR (@FoodStampableysn IS NOT NULL) OR (@Returnableysn IS NOT NULL))   
 				  set @SQL1 = @SQL1 + ' , ysnSaleable = ''' + LTRIM(@Saleableysn) + ''''
			   else
				  set @SQL1 = @SQL1 + ' ysnSaleable = ''' + LTRIM(@Saleableysn) + '''' 
			 END

          IF(@ID1Requiredysn IS NOT NULL)
		     BEGIN
			   if ((@TaxFlag1ysn IS NOT NULL) OR (@TaxFlag2ysn IS NOT NULL)
			   OR (@TaxFlag3ysn IS NOT NULL) OR (@TaxFlag4ysn IS NOT NULL) 
			   OR (@DepositRequiredysn IS NOT NULL) OR (@DepositPLU IS NOT NULL)
			   OR (@QuantityRequiredysn IS NOT NULL) OR (@ScaleItemysn IS NOT NULL)
			   OR (@FoodStampableysn IS NOT NULL) OR (@Returnableysn IS NOT NULL)
			   OR (@Saleableysn IS NOT NULL))   
 				  set @SQL1 = @SQL1 + ' , ysnIdRequiredLiquor = ''' + LTRIM(@ID1Requiredysn) + ''''
			   else
				  set @SQL1 = @SQL1 + ' ysnIdRequiredLiquor = ''' + LTRIM(@ID1Requiredysn) + '''' 
			 END

          IF(@ID2Requiredysn IS NOT NULL)
		     BEGIN
			   if ((@TaxFlag1ysn IS NOT NULL) OR (@TaxFlag2ysn IS NOT NULL)
			   OR (@TaxFlag3ysn IS NOT NULL) OR (@TaxFlag4ysn IS NOT NULL) 
			   OR (@DepositRequiredysn IS NOT NULL) OR (@DepositPLU IS NOT NULL)
			   OR (@QuantityRequiredysn IS NOT NULL) OR (@ScaleItemysn IS NOT NULL)
			   OR (@FoodStampableysn IS NOT NULL) OR (@Returnableysn IS NOT NULL)
			   OR (@Saleableysn IS NOT NULL) OR (@ID1Requiredysn IS NOT NULL))   
 				  set @SQL1 = @SQL1 + ' , ysnIdRequiredCigarette = ''' + LTRIM(@ID2Requiredysn) + ''''
			   else
				  set @SQL1 = @SQL1 + ' ysnIdRequiredCigarette = ''' + LTRIM(@ID2Requiredysn) + '''' 
			 END

         IF(@PromotionalItemysn IS NOT NULL)
		     BEGIN
			   if ((@TaxFlag1ysn IS NOT NULL) OR (@TaxFlag2ysn IS NOT NULL)
			   OR (@TaxFlag3ysn IS NOT NULL) OR (@TaxFlag4ysn IS NOT NULL) 
			   OR (@DepositRequiredysn IS NOT NULL) OR (@DepositPLU IS NOT NULL)
			   OR (@QuantityRequiredysn IS NOT NULL) OR (@ScaleItemysn IS NOT NULL)
			   OR (@FoodStampableysn IS NOT NULL) OR (@Returnableysn IS NOT NULL)
			   OR (@Saleableysn IS NOT NULL) OR (@ID1Requiredysn IS NOT NULL)
			   OR (@ID2Requiredysn IS NOT NULL))   
 				  set @SQL1 = @SQL1 + ' , ysnPromotionalItem = ''' + LTRIM(@PromotionalItemysn) + ''''
			   else
				  set @SQL1 = @SQL1 + ' ysnPromotionalItem = ''' + LTRIM(@PromotionalItemysn) + '''' 
			 END

         IF(@PrePricedysn IS NOT NULL)
		     BEGIN
			   if ((@TaxFlag1ysn IS NOT NULL) OR (@TaxFlag2ysn IS NOT NULL)
			   OR (@TaxFlag3ysn IS NOT NULL) OR (@TaxFlag4ysn IS NOT NULL) 
			   OR (@DepositRequiredysn IS NOT NULL) OR (@DepositPLU IS NOT NULL)
			   OR (@QuantityRequiredysn IS NOT NULL) OR (@ScaleItemysn IS NOT NULL)
			   OR (@FoodStampableysn IS NOT NULL) OR (@Returnableysn IS NOT NULL)
			   OR (@Saleableysn IS NOT NULL) OR (@ID1Requiredysn IS NOT NULL)
			   OR (@ID2Requiredysn IS NOT NULL) OR (@PromotionalItemysn IS NOT NULL))   
 				  set @SQL1 = @SQL1 + ' , ysnPrePriced = ''' + LTRIM(@PrePricedysn) + ''''
			   else
				  set @SQL1 = @SQL1 + ' ysnPrePriced = ''' + LTRIM(@PrePricedysn) + '''' 
			 END

         IF(@BlueLaw1ysn IS NOT NULL)
		     BEGIN
			   if ((@TaxFlag1ysn IS NOT NULL) OR (@TaxFlag2ysn IS NOT NULL)
			   OR (@TaxFlag3ysn IS NOT NULL) OR (@TaxFlag4ysn IS NOT NULL) 
			   OR (@DepositRequiredysn IS NOT NULL) OR (@DepositPLU IS NOT NULL)
			   OR (@QuantityRequiredysn IS NOT NULL) OR (@ScaleItemysn IS NOT NULL)
			   OR (@FoodStampableysn IS NOT NULL) OR (@Returnableysn IS NOT NULL)
			   OR (@Saleableysn IS NOT NULL) OR (@ID1Requiredysn IS NOT NULL)
			   OR (@ID2Requiredysn IS NOT NULL) OR (@PromotionalItemysn IS NOT NULL)
			   OR (@PrePricedysn IS NOT NULL))   
 				  set @SQL1 = @SQL1 + ' , ysnApplyBlueLaw1 = ''' + LTRIM(@BlueLaw1ysn) + ''''
			   else
				  set @SQL1 = @SQL1 + ' ysnApplyBlueLaw1 = ''' + LTRIM(@BlueLaw1ysn) + '''' 
			 END

          IF(@BlueLaw2ysn IS NOT NULL)
		     BEGIN
			   if ((@TaxFlag1ysn IS NOT NULL) OR (@TaxFlag2ysn IS NOT NULL)
			   OR (@TaxFlag3ysn IS NOT NULL) OR (@TaxFlag4ysn IS NOT NULL) 
			   OR (@DepositRequiredysn IS NOT NULL) OR (@DepositPLU IS NOT NULL)
			   OR (@QuantityRequiredysn IS NOT NULL) OR (@ScaleItemysn IS NOT NULL)
			   OR (@FoodStampableysn IS NOT NULL) OR (@Returnableysn IS NOT NULL)
			   OR (@Saleableysn IS NOT NULL) OR (@ID1Requiredysn IS NOT NULL)
			   OR (@ID2Requiredysn IS NOT NULL) OR (@PromotionalItemysn IS NOT NULL)
			   OR (@PrePricedysn IS NOT NULL) OR (@BlueLaw1ysn IS NOT NULL))   
 				  set @SQL1 = @SQL1 + ' , ysnApplyBlueLaw2 = ''' + LTRIM(@BlueLaw2ysn) + ''''
			   else
				  set @SQL1 = @SQL1 + ' ysnApplyBlueLaw2 = ''' + LTRIM(@BlueLaw2ysn) + '''' 
			 END

          IF(@CountedDailyysn IS NOT NULL)
		     BEGIN
			   if ((@TaxFlag1ysn IS NOT NULL) OR (@TaxFlag2ysn IS NOT NULL)
			   OR (@TaxFlag3ysn IS NOT NULL) OR (@TaxFlag4ysn IS NOT NULL) 
			   OR (@DepositRequiredysn IS NOT NULL) OR (@DepositPLU IS NOT NULL)
			   OR (@QuantityRequiredysn IS NOT NULL) OR (@ScaleItemysn IS NOT NULL)
			   OR (@FoodStampableysn IS NOT NULL) OR (@Returnableysn IS NOT NULL)
			   OR (@Saleableysn IS NOT NULL) OR (@ID1Requiredysn IS NOT NULL)
			   OR (@ID2Requiredysn IS NOT NULL) OR (@PromotionalItemysn IS NOT NULL)
			   OR (@PrePricedysn IS NOT NULL) OR (@BlueLaw1ysn IS NOT NULL)
			   OR (@BlueLaw2ysn IS NOT NULL))   
 				  set @SQL1 = @SQL1 + ' , ysnCountedDaily = ''' + LTRIM(@CountedDailyysn) + ''''
			   else
				  set @SQL1 = @SQL1 + ' ysnCountedDaily = ''' + LTRIM(@CountedDailyysn) + '''' 
			 END

          IF(@Counted IS NOT NULL)
		     BEGIN
			   if ((@TaxFlag1ysn IS NOT NULL) OR (@TaxFlag2ysn IS NOT NULL)
			   OR (@TaxFlag3ysn IS NOT NULL) OR (@TaxFlag4ysn IS NOT NULL) 
			   OR (@DepositRequiredysn IS NOT NULL) OR (@DepositPLU IS NOT NULL)
			   OR (@QuantityRequiredysn IS NOT NULL) OR (@ScaleItemysn IS NOT NULL)
			   OR (@FoodStampableysn IS NOT NULL) OR (@Returnableysn IS NOT NULL)
			   OR (@Saleableysn IS NOT NULL) OR (@ID1Requiredysn IS NOT NULL)
			   OR (@ID2Requiredysn IS NOT NULL) OR (@PromotionalItemysn IS NOT NULL)
			   OR (@PrePricedysn IS NOT NULL) OR (@BlueLaw1ysn IS NOT NULL)
			   OR (@BlueLaw2ysn IS NOT NULL) OR(@CountedDailyysn IS NOT NULL))   
 				  set @SQL1 = @SQL1 + ' , strCounted = ''' + LTRIM(@Counted) + ''''
			   else
				  set @SQL1 = @SQL1 + ' strCounted = ''' + LTRIM(@Counted) + '''' 
			 END

          IF(@CountSerialysn IS NOT NULL)
		     BEGIN
			   if ((@TaxFlag1ysn IS NOT NULL) OR (@TaxFlag2ysn IS NOT NULL)
			   OR (@TaxFlag3ysn IS NOT NULL) OR (@TaxFlag4ysn IS NOT NULL) 
			   OR (@DepositRequiredysn IS NOT NULL) OR (@DepositPLU IS NOT NULL)
			   OR (@QuantityRequiredysn IS NOT NULL) OR (@ScaleItemysn IS NOT NULL)
			   OR (@FoodStampableysn IS NOT NULL) OR (@Returnableysn IS NOT NULL)
			   OR (@Saleableysn IS NOT NULL) OR (@ID1Requiredysn IS NOT NULL)
			   OR (@ID2Requiredysn IS NOT NULL) OR (@PromotionalItemysn IS NOT NULL)
			   OR (@PrePricedysn IS NOT NULL) OR (@BlueLaw1ysn IS NOT NULL)
			   OR (@BlueLaw2ysn IS NOT NULL) OR(@CountedDailyysn IS NOT NULL)
			   OR (@Counted IS NOT NULL))   
 				  set @SQL1 = @SQL1 + ' , ysnCountBySINo = ''' + LTRIM(@CountSerialysn) + ''''
			   else
				  set @SQL1 = @SQL1 + ' ysnCountBySINo = ''' + LTRIM(@CountSerialysn) + '''' 
			 END

          IF(@NewFamily IS NOT NULL)
		     BEGIN
			   if ((@TaxFlag1ysn IS NOT NULL) OR (@TaxFlag2ysn IS NOT NULL)
			   OR (@TaxFlag3ysn IS NOT NULL) OR (@TaxFlag4ysn IS NOT NULL) 
			   OR (@DepositRequiredysn IS NOT NULL) OR (@DepositPLU IS NOT NULL)
			   OR (@QuantityRequiredysn IS NOT NULL) OR (@ScaleItemysn IS NOT NULL)
			   OR (@FoodStampableysn IS NOT NULL) OR (@Returnableysn IS NOT NULL)
			   OR (@Saleableysn IS NOT NULL) OR (@ID1Requiredysn IS NOT NULL)
			   OR (@ID2Requiredysn IS NOT NULL) OR (@PromotionalItemysn IS NOT NULL)
			   OR (@PrePricedysn IS NOT NULL) OR (@BlueLaw1ysn IS NOT NULL)
			   OR (@BlueLaw2ysn IS NOT NULL) OR(@CountedDailyysn IS NOT NULL)
			   OR (@Counted IS NOT NULL) OR (@CountSerialysn IS NOT NULL))   
 				  set @SQL1 = @SQL1 + ' , intFamilyId = ''' + LTRIM(@NewFamily) + ''''
			   else
				  set @SQL1 = @SQL1 + ' intFamilyId = ''' + LTRIM(@NewFamily) + '''' 
			 END

          IF(@NewClass IS NOT NULL)
		     BEGIN
			   if ((@TaxFlag1ysn IS NOT NULL) OR (@TaxFlag2ysn IS NOT NULL)
			   OR (@TaxFlag3ysn IS NOT NULL) OR (@TaxFlag4ysn IS NOT NULL) 
			   OR (@DepositRequiredysn IS NOT NULL) OR (@DepositPLU IS NOT NULL)
			   OR (@QuantityRequiredysn IS NOT NULL) OR (@ScaleItemysn IS NOT NULL)
			   OR (@FoodStampableysn IS NOT NULL) OR (@Returnableysn IS NOT NULL)
			   OR (@Saleableysn IS NOT NULL) OR (@ID1Requiredysn IS NOT NULL)
			   OR (@ID2Requiredysn IS NOT NULL) OR (@PromotionalItemysn IS NOT NULL)
			   OR (@PrePricedysn IS NOT NULL) OR (@BlueLaw1ysn IS NOT NULL)
			   OR (@BlueLaw2ysn IS NOT NULL) OR(@CountedDailyysn IS NOT NULL)
			   OR (@Counted IS NOT NULL) OR (@CountSerialysn IS NOT NULL)
			   OR (@NewFamily IS NOT NULL))   
 				  set @SQL1 = @SQL1 + ' , intClassId = ''' + LTRIM(@NewClass) + ''''
			   else
				  set @SQL1 = @SQL1 + ' intClassId = ''' + LTRIM(@NewClass) + '''' 
			 END

         IF(@NewProductCode IS NOT NULL)
		     BEGIN
			   if ((@TaxFlag1ysn IS NOT NULL) OR (@TaxFlag2ysn IS NOT NULL)
			   OR (@TaxFlag3ysn IS NOT NULL) OR (@TaxFlag4ysn IS NOT NULL) 
			   OR (@DepositRequiredysn IS NOT NULL) OR (@DepositPLU IS NOT NULL)
			   OR (@QuantityRequiredysn IS NOT NULL) OR (@ScaleItemysn IS NOT NULL)
			   OR (@FoodStampableysn IS NOT NULL) OR (@Returnableysn IS NOT NULL)
			   OR (@Saleableysn IS NOT NULL) OR (@ID1Requiredysn IS NOT NULL)
			   OR (@ID2Requiredysn IS NOT NULL) OR (@PromotionalItemysn IS NOT NULL)
			   OR (@PrePricedysn IS NOT NULL) OR (@BlueLaw1ysn IS NOT NULL)
			   OR (@BlueLaw2ysn IS NOT NULL) OR(@CountedDailyysn IS NOT NULL)
			   OR (@Counted IS NOT NULL) OR (@CountSerialysn IS NOT NULL)
			   OR (@NewFamily IS NOT NULL) OR (@NewClass IS NOT NULL))   
 				  set @SQL1 = @SQL1 + ' , intProductCodeId = ''' + LTRIM(@NewProductCode) + ''''
			   else
				  set @SQL1 = @SQL1 + ' intProductCodeId = ''' + LTRIM(@NewProductCode) + '''' 
			 END

         IF(@NewVendor IS NOT NULL)
		     BEGIN
			   if ((@TaxFlag1ysn IS NOT NULL) OR (@TaxFlag2ysn IS NOT NULL)
			   OR (@TaxFlag3ysn IS NOT NULL) OR (@TaxFlag4ysn IS NOT NULL) 
			   OR (@DepositRequiredysn IS NOT NULL) OR (@DepositPLU IS NOT NULL)
			   OR (@QuantityRequiredysn IS NOT NULL) OR (@ScaleItemysn IS NOT NULL)
			   OR (@FoodStampableysn IS NOT NULL) OR (@Returnableysn IS NOT NULL)
			   OR (@Saleableysn IS NOT NULL) OR (@ID1Requiredysn IS NOT NULL)
			   OR (@ID2Requiredysn IS NOT NULL) OR (@PromotionalItemysn IS NOT NULL)
			   OR (@PrePricedysn IS NOT NULL) OR (@BlueLaw1ysn IS NOT NULL)
			   OR (@BlueLaw2ysn IS NOT NULL) OR(@CountedDailyysn IS NOT NULL)
			   OR (@Counted IS NOT NULL) OR (@CountSerialysn IS NOT NULL)
			   OR (@NewFamily IS NOT NULL) OR (@NewClass IS NOT NULL)
			   OR (@NewProductCode IS NOT NULL))   
 				  set @SQL1 = @SQL1 + ' , intVendorId = ''' + LTRIM(@NewVendor) + ''''
			   else
				  set @SQL1 = @SQL1 + ' intVendorId = ''' + LTRIM(@NewVendor) + '''' 
			 END

          IF(@NewMinAge IS NOT NULL)
		     BEGIN
			   if ((@TaxFlag1ysn IS NOT NULL) OR (@TaxFlag2ysn IS NOT NULL)
			   OR (@TaxFlag3ysn IS NOT NULL) OR (@TaxFlag4ysn IS NOT NULL) 
			   OR (@DepositRequiredysn IS NOT NULL) OR (@DepositPLU IS NOT NULL)
			   OR (@QuantityRequiredysn IS NOT NULL) OR (@ScaleItemysn IS NOT NULL)
			   OR (@FoodStampableysn IS NOT NULL) OR (@Returnableysn IS NOT NULL)
			   OR (@Saleableysn IS NOT NULL) OR (@ID1Requiredysn IS NOT NULL)
			   OR (@ID2Requiredysn IS NOT NULL) OR (@PromotionalItemysn IS NOT NULL)
			   OR (@PrePricedysn IS NOT NULL) OR (@BlueLaw1ysn IS NOT NULL)
			   OR (@BlueLaw2ysn IS NOT NULL) OR(@CountedDailyysn IS NOT NULL)
			   OR (@Counted IS NOT NULL) OR (@CountSerialysn IS NOT NULL)
			   OR (@NewFamily IS NOT NULL) OR (@NewClass IS NOT NULL)
			   OR (@NewProductCode IS NOT NULL) OR (@NewVendor IS NOT NULL))   
 				  set @SQL1 = @SQL1 + ' , intMinimumAge = ''' + LTRIM(@NewMinAge) + ''''
			   else
				  set @SQL1 = @SQL1 + ' intMinimumAge = ''' + LTRIM(@NewMinAge) + '''' 
			 END

          IF(@NewMinVendorOrderQty IS NOT NULL)
		     BEGIN
			   if ((@TaxFlag1ysn IS NOT NULL) OR (@TaxFlag2ysn IS NOT NULL)
			   OR (@TaxFlag3ysn IS NOT NULL) OR (@TaxFlag4ysn IS NOT NULL) 
			   OR (@DepositRequiredysn IS NOT NULL) OR (@DepositPLU IS NOT NULL)
			   OR (@QuantityRequiredysn IS NOT NULL) OR (@ScaleItemysn IS NOT NULL)
			   OR (@FoodStampableysn IS NOT NULL) OR (@Returnableysn IS NOT NULL)
			   OR (@Saleableysn IS NOT NULL) OR (@ID1Requiredysn IS NOT NULL)
			   OR (@ID2Requiredysn IS NOT NULL) OR (@PromotionalItemysn IS NOT NULL)
			   OR (@PrePricedysn IS NOT NULL) OR (@BlueLaw1ysn IS NOT NULL)
			   OR (@BlueLaw2ysn IS NOT NULL) OR(@CountedDailyysn IS NOT NULL)
			   OR (@Counted IS NOT NULL) OR (@CountSerialysn IS NOT NULL)
			   OR (@NewFamily IS NOT NULL) OR (@NewClass IS NOT NULL)
			   OR (@NewProductCode IS NOT NULL) OR (@NewVendor IS NOT NULL)
			   OR (@NewMinAge IS NOT NULL))   
 				  set @SQL1 = @SQL1 + ' , dblMinOrder = ''' + LTRIM(@NewMinVendorOrderQty) + ''''
			   else
				  set @SQL1 = @SQL1 + ' dblMinOrder = ''' + LTRIM(@NewMinVendorOrderQty) + '''' 
			 END

          IF(@NewVendorSuggestedQty IS NOT NULL)
		     BEGIN
			   if ((@TaxFlag1ysn IS NOT NULL) OR (@TaxFlag2ysn IS NOT NULL)
			   OR (@TaxFlag3ysn IS NOT NULL) OR (@TaxFlag4ysn IS NOT NULL) 
			   OR (@DepositRequiredysn IS NOT NULL) OR (@DepositPLU IS NOT NULL)
			   OR (@QuantityRequiredysn IS NOT NULL) OR (@ScaleItemysn IS NOT NULL)
			   OR (@FoodStampableysn IS NOT NULL) OR (@Returnableysn IS NOT NULL)
			   OR (@Saleableysn IS NOT NULL) OR (@ID1Requiredysn IS NOT NULL)
			   OR (@ID2Requiredysn IS NOT NULL) OR (@PromotionalItemysn IS NOT NULL)
			   OR (@PrePricedysn IS NOT NULL) OR (@BlueLaw1ysn IS NOT NULL)
			   OR (@BlueLaw2ysn IS NOT NULL) OR(@CountedDailyysn IS NOT NULL)
			   OR (@Counted IS NOT NULL) OR (@CountSerialysn IS NOT NULL)
			   OR (@NewFamily IS NOT NULL) OR (@NewClass IS NOT NULL)
			   OR (@NewProductCode IS NOT NULL) OR (@NewVendor IS NOT NULL)
			   OR (@NewMinAge IS NOT NULL) OR (@NewMinVendorOrderQty IS NOT NULL))   
 				  set @SQL1 = @SQL1 + ' , dblSuggestedQty = ''' + LTRIM(@NewVendorSuggestedQty) + ''''
			   else
				  set @SQL1 = @SQL1 + ' dblSuggestedQty = ''' + LTRIM(@NewVendorSuggestedQty) + '''' 
			 END

             IF(@NewInventoryGroup IS NOT NULL)
		     BEGIN
			   if ((@TaxFlag1ysn IS NOT NULL) OR (@TaxFlag2ysn IS NOT NULL)
			   OR (@TaxFlag3ysn IS NOT NULL) OR (@TaxFlag4ysn IS NOT NULL) 
			   OR (@DepositRequiredysn IS NOT NULL) OR (@DepositPLU IS NOT NULL)
			   OR (@QuantityRequiredysn IS NOT NULL) OR (@ScaleItemysn IS NOT NULL)
			   OR (@FoodStampableysn IS NOT NULL) OR (@Returnableysn IS NOT NULL)
			   OR (@Saleableysn IS NOT NULL) OR (@ID1Requiredysn IS NOT NULL)
			   OR (@ID2Requiredysn IS NOT NULL) OR (@PromotionalItemysn IS NOT NULL)
			   OR (@PrePricedysn IS NOT NULL) OR (@BlueLaw1ysn IS NOT NULL)
			   OR (@BlueLaw2ysn IS NOT NULL) OR(@CountedDailyysn IS NOT NULL)
			   OR (@Counted IS NOT NULL) OR (@CountSerialysn IS NOT NULL)
			   OR (@NewFamily IS NOT NULL) OR (@NewClass IS NOT NULL)
			   OR (@NewProductCode IS NOT NULL) OR (@NewVendor IS NOT NULL)
			   OR (@NewMinAge IS NOT NULL) OR (@NewMinVendorOrderQty IS NOT NULL)
			   OR (@NewVendorSuggestedQty IS NOT NULL))   
 				  set @SQL1 = @SQL1 + ' , intCountGroupId = ''' + LTRIM(@NewInventoryGroup) + ''''
			   else
				  set @SQL1 = @SQL1 + ' intCountGroupId = ''' + LTRIM(@NewInventoryGroup) + '''' 
			 END


			 IF(@NewBinLocation IS NOT NULL)
		     BEGIN
			   if ((@TaxFlag1ysn IS NOT NULL) OR (@TaxFlag2ysn IS NOT NULL)
			   OR (@TaxFlag3ysn IS NOT NULL) OR (@TaxFlag4ysn IS NOT NULL) 
			   OR (@DepositRequiredysn IS NOT NULL) OR (@DepositPLU IS NOT NULL)
			   OR (@QuantityRequiredysn IS NOT NULL) OR (@ScaleItemysn IS NOT NULL)
			   OR (@FoodStampableysn IS NOT NULL) OR (@Returnableysn IS NOT NULL)
			   OR (@Saleableysn IS NOT NULL) OR (@ID1Requiredysn IS NOT NULL)
			   OR (@ID2Requiredysn IS NOT NULL) OR (@PromotionalItemysn IS NOT NULL)
			   OR (@PrePricedysn IS NOT NULL) OR (@BlueLaw1ysn IS NOT NULL)
			   OR (@BlueLaw2ysn IS NOT NULL) OR(@CountedDailyysn IS NOT NULL)
			   OR (@Counted IS NOT NULL) OR (@CountSerialysn IS NOT NULL)
			   OR (@NewFamily IS NOT NULL) OR (@NewClass IS NOT NULL)
			   OR (@NewProductCode IS NOT NULL) OR (@NewVendor IS NOT NULL)
			   OR (@NewMinAge IS NOT NULL) OR (@NewMinVendorOrderQty IS NOT NULL)
			   OR (@NewVendorSuggestedQty IS NOT NULL) OR (@NewInventoryGroup IS NOT NULL))   
 				  set @SQL1 = @SQL1 + ' , intStorageLocationId = ''' + LTRIM(@NewBinLocation) + ''''
			   else
				  set @SQL1 = @SQL1 + ' intStorageLocationId = ''' + LTRIM(@NewBinLocation) + '''' 
			 END

			 IF(@NewMinQtyOnHand IS NOT NULL)
		     BEGIN
			   if ((@TaxFlag1ysn IS NOT NULL) OR (@TaxFlag2ysn IS NOT NULL)
			   OR (@TaxFlag3ysn IS NOT NULL) OR (@TaxFlag4ysn IS NOT NULL) 
			   OR (@DepositRequiredysn IS NOT NULL) OR (@DepositPLU IS NOT NULL)
			   OR (@QuantityRequiredysn IS NOT NULL) OR (@ScaleItemysn IS NOT NULL)
			   OR (@FoodStampableysn IS NOT NULL) OR (@Returnableysn IS NOT NULL)
			   OR (@Saleableysn IS NOT NULL) OR (@ID1Requiredysn IS NOT NULL)
			   OR (@ID2Requiredysn IS NOT NULL) OR (@PromotionalItemysn IS NOT NULL)
			   OR (@PrePricedysn IS NOT NULL) OR (@BlueLaw1ysn IS NOT NULL)
			   OR (@BlueLaw2ysn IS NOT NULL) OR(@CountedDailyysn IS NOT NULL)
			   OR (@Counted IS NOT NULL) OR (@CountSerialysn IS NOT NULL)
			   OR (@NewFamily IS NOT NULL) OR (@NewClass IS NOT NULL)
			   OR (@NewProductCode IS NOT NULL) OR (@NewVendor IS NOT NULL)
			   OR (@NewMinAge IS NOT NULL) OR (@NewMinVendorOrderQty IS NOT NULL)
			   OR (@NewVendorSuggestedQty IS NOT NULL) OR (@NewInventoryGroup IS NOT NULL)
			   OR (@NewBinLocation IS NOT NULL))   
 				  set @SQL1 = @SQL1 + ' , dblReorderPoint = ''' + LTRIM(@NewMinQtyOnHand) + ''''
			   else
				  set @SQL1 = @SQL1 + ' dblReorderPoint = ''' + LTRIM(@NewMinQtyOnHand) + '''' 
			 END

			 SET @SQL1 = @SQL1 + ' where 1=1 ' 

			 IF (@Location IS NOT NULL)
		         BEGIN 
		               set @SQL1 = @SQL1 +  ' and  tblICItemLocation.intLocationId
		             	       IN (' + CAST(@Location as NVARCHAR) + ')' 
		         END
			 
			 IF (@Vendor IS NOT NULL)
		         BEGIN 
		               set @SQL1 = @SQL1 +  ' and  tblICItemLocation.intVendorId
		             	       IN (' + CAST(@Vendor as NVARCHAR) + ')' 
		         END

             IF (@Category IS NOT NULL)
		         BEGIN
     	               set @SQL1 = @SQL1 +  ' and tblICItemLocation.intItemId  
		               IN (select intItemId from tblICItem where intCategoryId IN
			           (select intCategoryId from tblICCategory where intCategoryId 
					 IN (' + CAST(@Category as NVARCHAR) + ')' + '))'
		         END

             IF (@Family IS NOT NULL)
		         BEGIN
  			            set @SQL1 = @SQL1 +  ' and  tblICItemLocation.intFamilyId
		             	       IN (' + CAST(@Family as NVARCHAR) + ')' 
		          END

             IF (@Class IS NOT NULL)
		         BEGIN
  			            set @SQL1 = @SQL1 +  ' and  tblICItemLocation.intClassId
		             	       IN (' + CAST(@Class as NVARCHAR) + ')' 
		          END
		    
			 IF (@UpcCode IS NOT NULL)
			      BEGIN
				        set @SQL1 = @SQL1 +  ' and tblICItemLocation.intItemId  
                        IN (select intItemId from tblICItemUOM where  intItemUOMId IN
				   	    (' + CAST(@UpcCode as NVARCHAR) + ')' + ')'
			      END

             IF ((@Description IS NOT NULL)
				   and (@Description != ''))
					BEGIN
					   set @SQL1 = @SQL1 +  ' and tblICItemLocation.intItemId IN 
					   (select intItemId from tblICItem where strDescription 
					    like ''%' + LTRIM(@Description) + '%'' )'
					END

             IF (@PriceBetween1 IS NOT NULL) 
		      BEGIN
			      set @SQL1 = @SQL1 +  ' and tblICItemLocation.intItemId IN 
					   (select intItemId from tblICItemPricing where dblSalePrice >= 
					   ''' + CONVERT(NVARCHAR,(@PriceBetween1)) + '''' + ')'
		      END 
		      
             IF (@PriceBetween2 IS NOT NULL) 
		        BEGIN
			        set @SQL1 = @SQL1 +  ' and tblICItemLocation.intItemId IN 
					   (select intItemId from tblICItemPricing where dblSalePrice <= 
					   ''' + CONVERT(NVARCHAR,(@PriceBetween2)) + '''' + ')'
		        END  

		  EXEC (@SQL1)

		  SELECT  @UpdateCount =   @UpdateCount + (@@ROWCOUNT)   
	 END	  
END
--PRINT 'Update02'
IF((@ysnPreview != 'Y')
AND(@UpdateCount > 0))
BEGIN
    IF ((@NewCategory IS NOT NULL)
	OR (@NewCountCode IS NOT NULL))    
    BEGIN    
		 SET @SQL1 = ' update tblICItem set '
		 
         IF(@NewCategory IS NOT NULL)
		    BEGIN
			 	  SET @SQL1 = @SQL1 + ' intCategoryId = ''' + LTRIM(@NewCategory) + '''' 
			END
           
		 IF(@NewCountCode IS NOT NULL)
		    BEGIN
			     IF (@NewCategory IS NOT NULL)
				      SET @SQL1 = @SQL1 + ', strCountCode = ''' + LTRIM(@NewCountCode) + '''' 
	   	         ELSE
			          SET @SQL1 = @SQL1 + ' strCountCode = ''' + LTRIM(@NewCountCode) + '''' 
            END
	
		 SET @SQL1 = @SQL1 + ' where 1=1 ' 

		 IF (@Location IS NOT NULL)
		 BEGIN

		      SET @SQL1 = @SQL1 +  ' and tblICItem.intItemId IN 
			              (select intItemId from tblICItemLocation where intLocationId IN
					      (' + CAST(@Location as NVARCHAR) + ')' + ')'
		 END

		 IF (@Vendor IS NOT NULL)
		     BEGIN 
		           SET @SQL1 = @SQL1 +  ' and tblICItem.intItemId IN 
			              (select intItemId from tblICItemLocation where intVendorId IN
					       (' + CAST(@Vendor as NVARCHAR) + ')' + ')'
		     END

         IF (@Category IS NOT NULL)
		     BEGIN
     	           SET @SQL1 = @SQL1 +  ' and  tblICItem.intCategoryId
		             	       IN (' + CAST(@Category as NVARCHAR) + ')' 
		     END

         IF (@Family IS NOT NULL)
		     BEGIN
  		           SET @SQL1 = @SQL1 +  ' and tblICItem.intItemId IN 
			              (select intItemId from tblICItemLocation where intFamilyId IN
					       (' + CAST(@Family as NVARCHAR) + ')' + ')'
		     END

         IF (@Class IS NOT NULL)
		     BEGIN
  			       SET @SQL1 = @SQL1 +  ' and tblICItem.intItemId IN 
			           (select intItemId from tblICItemLocation where intClassId IN
					    (' + CAST(@Class as NVARCHAR) + ')' + ')'
		     END
		    
         IF (@UpcCode IS NOT NULL)
		     BEGIN
		           SET @SQL1 = @SQL1 +  ' and tblICItem.intItemId  
                        IN (select intItemId from tblICItemUOM where  intItemUOMId IN
				   	    (' + CAST(@UpcCode as NVARCHAR) + ')' + ')'
			 END

         IF ((@Description IS NOT NULL)
		 and (@Description != ''))
		 	 BEGIN
			      SET @SQL1 = @SQL1 +  ' and tblICItem.strDescription like ''%' + LTRIM(@Description) + '%'' '
			 END

         IF (@PriceBetween1 IS NOT NULL) 
		     BEGIN
			      SET @SQL1 = @SQL1 +  ' and tblICItem.intItemId IN 
					   (select intItemId from tblICItemPricing where dblSalePrice >= 
					   ''' + CONVERT(NVARCHAR,(@PriceBetween1)) + '''' + ')'
		      END 
		      
          IF (@PriceBetween2 IS NOT NULL) 
		      BEGIN
			        set @SQL1 = @SQL1 +  ' and tblICItem.intItemId IN 
					   (select intItemId from tblICItemPricing where dblSalePrice <= 
				   ''' + CONVERT(NVARCHAR,(@PriceBetween2)) + '''' + ')'
		      END     

          EXEC (@SQL1)
		  SELECT  @UpdateCount =   @UpdateCount + (@@ROWCOUNT)   	  
	END
END

--PRINT 'Update03'
IF((@ysnPreview != 'Y')
AND(@UpdateCount > 0))
BEGIN
      IF ((@NewGLPurchaseAccount IS NOT NULL)
	  OR (@NewGLSalesAccount IS NOT NULL)    
	  OR (@NewGLVarianceAccount IS NOT NULL))
	  BEGIN
	         

	         IF (@NewGLPurchaseAccount IS NOT NULL)
			 BEGIN
			    
				SET @SQL1 = ' UPDATE IA '  
			    SET @SQL1 = @SQL1 + ' SET IA.intAccountId = ''' + LTRIM(@NewGLPurchaseAccount) + '''' 
				SET @SQL1 = @SQL1 + ' FROM dbo.tblICItemAccount AS IA'
				SET @SQL1 = @SQL1 + ' JOIN dbo.tblICItem AS I ON IA.intItemId = I.intItemId'
				SET @SQL1 = @SQL1 + ' JOIN dbo.tblICItemLocation IL ON IA.intItemId = IL.intItemId'
				SET @SQL1 = @SQL1 + ' JOIN dbo.tblICItemUOM UOM ON IA.intItemId = UOM.intItemId'
				SET @SQL1 = @SQL1 + ' JOIN dbo.tblSMCompanyLocation CL ON IL.intLocationId = CL.intCompanyLocationId'
				SET @SQL1 = @SQL1 + ' WHERE 1=1 ' 

				   IF (@Location <> '')
				   BEGIN 
						SET @SQL1 = @SQL1 + ' AND CL.intCompanyLocationId IN (' + CAST(@Location as NVARCHAR) + ')'
				   END
		 
				   IF (@Vendor <> '')
				   BEGIN 
					   SET @SQL1 = @SQL1 + ' AND IL.intVendorId IN (' + CAST(@Vendor as NVARCHAR) + ')'
				   END

				   IF (@Category <> '')
				   BEGIN
						SET @SQL1 = @SQL1 +  ' AND IL.intItemId IN (select intItemId from tblICItem where intCategoryId IN (select intCategoryId from tblICCategory where intCategoryId IN (' + CAST(@Category as NVARCHAR) + ')' + '))'
				   END

				   IF (@Family <> '')
				   BEGIN
						 SET @SQL1 = @SQL1 + ' AND IL.intFamilyId IN (' + CAST(@Family as NVARCHAR) + ')'
				   END

				   IF (@Class <> '')
				   BEGIN
						 SET @SQL1 = @SQL1 + ' AND IL.intClassId IN (' + CAST(@Class as NVARCHAR) + ')'
				   END
	    
				   IF (@UpcCode IS NOT NULL)
				   BEGIN
					   SET @SQL1 = @SQL1 + ' AND UOM.intItemUOMId IN (' + CAST(@UpcCode as NVARCHAR) + ')'
				   END

				   IF ((@Description != '') AND (@Description IS NOT NULL))
				   BEGIN
						SET @SQL1 = @SQL1 +  ' AND I.strDescription like ''%' + LTRIM(@Description) + '%'' '
				   END

				   IF (@PriceBetween1 IS NOT NULL) 
				   BEGIN
						SET @SQL1 = @SQL1 +  ' AND IL.intItemId IN (select intItemId from tblICItemPricing where dblSalePrice >= ''' + CONVERT(NVARCHAR,(@PriceBetween1)) + '''' + ')'
				   END 
	      
				   IF (@PriceBetween2 IS NOT NULL) 
				   BEGIN
						SET @SQL1 = @SQL1 +  ' AND IL.intItemId IN (select intItemId from tblICItemPricing where dblSalePrice <= ''' + CONVERT(NVARCHAR,(@PriceBetween2)) + '''' + ')'
				   END

				   SET @SQL1 = @SQL1 + ' AND IA.intAccountCategoryId = 30 '

                EXEC (@SQL1)
				
		        SELECT  @UpdateCount =   @UpdateCount + (@@ROWCOUNT)   	  
			 END

             IF (@NewGLSalesAccount IS NOT NULL)
			 BEGIN
			    
				SET @SQL1 = ' UPDATE IA '  
			    SET @SQL1 = @SQL1 + ' SET IA.intAccountId = ''' + LTRIM(@NewGLSalesAccount) + '''' 
				SET @SQL1 = @SQL1 + ' FROM dbo.tblICItemAccount AS IA'
				SET @SQL1 = @SQL1 + ' JOIN dbo.tblICItem AS I ON IA.intItemId = I.intItemId'
				SET @SQL1 = @SQL1 + ' JOIN dbo.tblICItemLocation IL ON IA.intItemId = IL.intItemId'
				SET @SQL1 = @SQL1 + ' JOIN dbo.tblICItemUOM UOM ON IA.intItemId = UOM.intItemId'
				SET @SQL1 = @SQL1 + ' JOIN dbo.tblSMCompanyLocation CL ON IL.intLocationId = CL.intCompanyLocationId'
				SET @SQL1 = @SQL1 + ' WHERE 1=1 ' 

				   IF (@Location <> '')
				   BEGIN 
						SET @SQL1 = @SQL1 + ' AND CL.intCompanyLocationId IN (' + CAST(@Location as NVARCHAR) + ')'
				   END
		 
				   IF (@Vendor <> '')
				   BEGIN 
					   SET @SQL1 = @SQL1 + ' AND IL.intVendorId IN (' + CAST(@Vendor as NVARCHAR) + ')'
				   END

				   IF (@Category <> '')
				   BEGIN
						SET @SQL1 = @SQL1 +  ' AND IL.intItemId IN (select intItemId from tblICItem where intCategoryId IN (select intCategoryId from tblICCategory where intCategoryId IN (' + CAST(@Category as NVARCHAR) + ')' + '))'
				   END

				   IF (@Family <> '')
				   BEGIN
						 SET @SQL1 = @SQL1 + ' AND IL.intFamilyId IN (' + CAST(@Family as NVARCHAR) + ')'
				   END

				   IF (@Class <> '')
				   BEGIN
						 SET @SQL1 = @SQL1 + ' AND IL.intClassId IN (' + CAST(@Class as NVARCHAR) + ')'
				   END
	    
				   IF (@UpcCode IS NOT NULL)
				   BEGIN
					   SET @SQL1 = @SQL1 + ' AND UOM.intItemUOMId IN (' + CAST(@UpcCode as NVARCHAR) + ')'
				   END

				   IF ((@Description != '') AND (@Description IS NOT NULL))
				   BEGIN
						SET @SQL1 = @SQL1 +  ' AND I.strDescription like ''%' + LTRIM(@Description) + '%'' '
				   END

				   IF (@PriceBetween1 IS NOT NULL) 
				   BEGIN
						SET @SQL1 = @SQL1 +  ' AND IL.intItemId IN (select intItemId from tblICItemPricing where dblSalePrice >= ''' + CONVERT(NVARCHAR,(@PriceBetween1)) + '''' + ')'
				   END 
	      
				   IF (@PriceBetween2 IS NOT NULL) 
				   BEGIN
						SET @SQL1 = @SQL1 +  ' AND IL.intItemId IN (select intItemId from tblICItemPricing where dblSalePrice <= ''' + CONVERT(NVARCHAR,(@PriceBetween2)) + '''' + ')'
				   END

				   SET @SQL1 = @SQL1 + ' and  intAccountCategoryId = 33 '

				
                EXEC (@SQL1)
				
		        SELECT  @UpdateCount =   @UpdateCount + (@@ROWCOUNT)   	  
			 END
             
			 IF (@NewGLVarianceAccount IS NOT NULL)
			 BEGIN
			    
				SET @SQL1 = ' UPDATE IA '  
			    SET @SQL1 = @SQL1 + ' SET IA.intAccountId = ''' + LTRIM(@NewGLVarianceAccount) + '''' 
				SET @SQL1 = @SQL1 + ' FROM dbo.tblICItemAccount AS IA'
				SET @SQL1 = @SQL1 + ' JOIN dbo.tblICItem AS I ON IA.intItemId = I.intItemId'
				SET @SQL1 = @SQL1 + ' JOIN dbo.tblICItemLocation IL ON IA.intItemId = IL.intItemId'
				SET @SQL1 = @SQL1 + ' JOIN dbo.tblICItemUOM UOM ON IA.intItemId = UOM.intItemId'
				SET @SQL1 = @SQL1 + ' JOIN dbo.tblSMCompanyLocation CL ON IL.intLocationId = CL.intCompanyLocationId'
				SET @SQL1 = @SQL1 + ' WHERE 1=1 ' 

				   IF (@Location <> '')
				   BEGIN 
						SET @SQL1 = @SQL1 + ' AND CL.intCompanyLocationId IN (' + CAST(@Location as NVARCHAR) + ')'
				   END
		 
				   IF (@Vendor <> '')
				   BEGIN 
					   SET @SQL1 = @SQL1 + ' AND IL.intVendorId IN (' + CAST(@Vendor as NVARCHAR) + ')'
				   END

				   IF (@Category <> '')
				   BEGIN
						SET @SQL1 = @SQL1 +  ' AND IL.intItemId IN (select intItemId from tblICItem where intCategoryId IN (select intCategoryId from tblICCategory where intCategoryId IN (' + CAST(@Category as NVARCHAR) + ')' + '))'
				   END

				   IF (@Family <> '')
				   BEGIN
						 SET @SQL1 = @SQL1 + ' AND IL.intFamilyId IN (' + CAST(@Family as NVARCHAR) + ')'
				   END

				   IF (@Class <> '')
				   BEGIN
						 SET @SQL1 = @SQL1 + ' AND IL.intClassId IN (' + CAST(@Class as NVARCHAR) + ')'
				   END
	    
				   IF (@UpcCode IS NOT NULL)
				   BEGIN
					   SET @SQL1 = @SQL1 + ' AND UOM.intItemUOMId IN (' + CAST(@UpcCode as NVARCHAR) + ')'
				   END

				   IF ((@Description != '') AND (@Description IS NOT NULL))
				   BEGIN
						SET @SQL1 = @SQL1 +  ' AND I.strDescription like ''%' + LTRIM(@Description) + '%'' '
				   END

				   IF (@PriceBetween1 IS NOT NULL) 
				   BEGIN
						SET @SQL1 = @SQL1 +  ' AND IL.intItemId IN (select intItemId from tblICItemPricing where dblSalePrice >= ''' + CONVERT(NVARCHAR,(@PriceBetween1)) + '''' + ')'
				   END 
	      
				   IF (@PriceBetween2 IS NOT NULL) 
				   BEGIN
						SET @SQL1 = @SQL1 +  ' AND IL.intItemId IN (select intItemId from tblICItemPricing where dblSalePrice <= ''' + CONVERT(NVARCHAR,(@PriceBetween2)) + '''' + ')'
				   END

				   SET @SQL1 = @SQL1 + ' and  intAccountCategoryId = 40 '

                EXEC (@SQL1)
				
		        SELECT  @UpdateCount =   @UpdateCount + (@@ROWCOUNT)   	  
			 END
	  END
END
  

    IF (@NewCountCode IS NOT NULL OR @NewCategory IS NOT NULL OR @NewGLPurchaseAccount IS NOT NULL OR @NewGLSalesAccount IS NOT NULL OR @NewGLVarianceAccount IS NOT NULL)
	BEGIN
			--AUDIT LOG

			--use distinct to table Id's
			INSERT INTO @tblId(intId)
			SELECT DISTINCT intChildId 
			FROM @tblTempOne
			ORDER BY intChildId ASC

			--==========================================================================================================================================
			WHILE EXISTS (SELECT TOP (1) 1 FROM @tblId)
			BEGIN
				SELECT TOP 1 @intChildId = intId FROM @tblId

				--use distinct to table tempOne
				DELETE FROM @tblTempTwo
				INSERT INTO @tblTempTwo(strUpc, strItemDescription, strChangeDescription, strOldData, strNewData, intParentId, intChildId)
				SELECT DISTINCT strUpc
								, strItemDescription
								, strChangeDescription
								, strOldData
								, strNewData
								, intParentId
								, intChildId 
				--FROM tblSTMassUpdateReportMaster
				FROM @tblTempOne
				WHERE intChildId = @intChildId
				ORDER BY intChildId ASC

				SET @RowCountMin = 1
				SELECT @RowCountMax = Count(*) FROM @tblTempTwo

					WHILE(@RowCountMin <= @RowCountMax)
					BEGIN
						SELECT TOP(1) @strChangeDescription = strChangeDescription, @strOldData = strOldData, @strNewData = strNewData, @intParentId = intParentId from @tblTempTwo
			    


						IF(@strChangeDescription = 'Count Code')
						BEGIN
							SET @ParentTableAuditLog = @ParentTableAuditLog + '{"change":"strCountCode","from":"' + @strOldData + '","to":"' + @strNewData + '","leaf":true,"iconCls":"small-gear","isField":true,"keyValue":' + CAST(@intParentId AS NVARCHAR(50)) + ',"changeDescription":"' + @strChangeDescription + '","hidden":false},'
						END
						ELSE IF(@strChangeDescription = 'Category')
						BEGIN
							SET @ParentTableAuditLog = @ParentTableAuditLog + '{"change":"intCategoryId","from":"' + @strOldData + '","to":"' + @strNewData + '","leaf":true,"iconCls":"small-gear","isField":true,"keyValue":' + CAST(@intParentId AS NVARCHAR(50)) + ',"changeDescription":"' + @strChangeDescription + '","hidden":false},'
						END

						ELSE IF(@strChangeDescription = 'Purchase Account' OR @strChangeDescription = 'Sales Account' OR @strChangeDescription = 'Variance Account')
						BEGIN
							SET @ChildTableAuditLog = @ChildTableAuditLog + '{"change":"intAccountId","from":"' + @strOldData + '","to":"' + @strNewData + '","leaf":true,"iconCls":"small-gear","isField":true,"keyValue":' + CAST(@intChildId AS NVARCHAR(50)) + ',"associationKey":"tblICItemAccounts","changeDescription":"' + @strChangeDescription + '","hidden":false},'
						END



						SET @RowCountMin = @RowCountMin + 1
						DELETE TOP (1) FROM @tblTempTwo
					END


				--INSERT to AUDITLOG
				--=================================================================================================
				----tblICItem
				--IF (@ParentTableAuditLog != '')
				--BEGIN
				--	--Remove last character comma(,)
				--	SET @ParentTableAuditLog = left(@ParentTableAuditLog, len(@ParentTableAuditLog)-1)

				--	SET @ParentTableAuditLog = '{"change":"tblICItems","children":[{"action":"Updated","change":"Updated - Record: ' + CAST(@intParentId AS NVARCHAR(50)) + '","keyValue":' + CAST(@intChildId AS NVARCHAR(50)) + ',"iconCls":"small-tree-modified","children":[' + @ParentTableAuditLog + ']}],"iconCls":"small-tree-grid","changeDescription":"Pricing"},'
				--END


				--tblICItemAccount
				IF (@ChildTableAuditLog != '')
				BEGIN
					--Remove last character comma(,)
					SET @ChildTableAuditLog = left(@ChildTableAuditLog, len(@ChildTableAuditLog)-1)

					SET @ChildTableAuditLog = '{"change":"tblICItemPricings","children":[{"action":"Updated","change":"Updated - Record: ' + CAST(@intChildId AS NVARCHAR(50)) + '","keyValue":' + CAST(@intChildId AS NVARCHAR(50)) + ',"iconCls":"small-tree-modified","children":[' + @ChildTableAuditLog + ']}],"iconCls":"small-tree-grid","changeDescription":"GL Accounts"},'
				END


				SET @JsonStringAuditLog = @ParentTableAuditLog + @ChildTableAuditLog


				SELECT @checkComma = CASE WHEN RIGHT(@JsonStringAuditLog, 1) IN (',') THEN 1 ELSE 0 END
				IF(@checkComma = 1)
				BEGIN
					--Remove last character comma(,)
					SET @JsonStringAuditLog = left(@JsonStringAuditLog, len(@JsonStringAuditLog)-1)
				END

				SET @JsonStringAuditLog = '{"action":"Updated","change":"Updated - Record: ' + CAST(@intParentId AS NVARCHAR(50)) + '","keyValue":' + CAST(@intParentId AS NVARCHAR(50)) + ',"iconCls":"small-tree-modified","children":[' + @JsonStringAuditLog + ']}'
				INSERT INTO tblSMAuditLog(strActionType, strTransactionType, strRecordNo, strDescription, strRoute, strJsonData, dtmDate, intEntityId, intConcurrencyId)
				VALUES(
						'Updated'
						, 'Inventory.view.Item'
						, @intParentId
						, ''
						, null
						, @JsonStringAuditLog
						, GETUTCDATE()
						, @currentUserId
						, 1
				)
				--=================================================================================================

				--Clear
				SET @ParentTableAuditLog = ''
				SET @ChildTableAuditLog = ''

				DELETE TOP (1) FROM @tblId
			END
			--==========================================================================================================================================


			SELECT @UpdateCount = COUNT(*)
			FROM 
			(
			  SELECT DISTINCT intChildId FROM @tblTempOne --tblSTMassUpdateReportMaster
			) T1
	END
    



--NEW
SELECT  @RecCount as RecCount,  @UpdateCount as UpdateItemDataCount

DELETE FROM tblSTMassUpdateReportMaster

INSERT INTO tblSTMassUpdateReportMaster(strLocationName, UpcCode, ItemDescription, ChangeDescription, OldData, NewData)
SELECT strLocation
	  , strUpc
	  , strItemDescription
	  , strChangeDescription
	  , strOldData
	  , strNewData 
FROM @tblTempOne



--OLD
--SELECT  @RecCount as RecCount,  @UpdateCount as UpdateItemDataCount	

END TRY

BEGIN CATCH       
	 SET @ErrMsg = ERROR_MESSAGE()      
	 IF @idoc <> 0 EXEC sp_xml_removedocument @idoc      
	 RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')      
END CATCH