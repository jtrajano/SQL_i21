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
				@NewQuantityCase           INT,
				@NewCountCode              NVARCHAR(50),     
				@NewItemSize               INT,
				@NewItemUOM                INT,
				@NewMinAge                 INT,
				@NewItemType               NVARCHAR(1),     
				@NewMinVendorOrderQty      DECIMAL(18,6),
				@NewVendorSuggestedQty     DECIMAL(18,6),
				@NewMinQtyOnHand           DECIMAL(18,6),
				@NewBinLocation            INT,
				@NewGLPurchaseAccount      INT,
			    @NewGLSalesAccount         INT,
				@NewGLVarianceAccount      INT,
				@UpdateReportTable         NVARCHAR(1)
				

	                  
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
				@NewQuantityCase  =  NewQuantityCase,
				@NewCountCode       = NewCountCode,
				@NewItemSize        = NewItemSize,
				@NewItemUOM         = NewItemUOM,
				@NewMinAge          = NewMinAge,
				@NewItemType        = NewItemType,
				@NewMinVendorOrderQty = NewMinVendorOrderQty,
				@NewVendorSuggestedQty = NewVendorSuggestedQty,
				@NewMinQtyOnHand     = NewMinQtyOnHand,
				@NewBinLocation      = NewBinLocation,
				@NewGLPurchaseAccount  = NewGLPurchaseAccount,
			    @NewGLSalesAccount     = NewGLSalesAccount,
			    @NewGLVarianceAccount  = NewGLVarianceAccount,
				@UpdateReportTable     = UpdateReportTable
	
		
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
				NewQuantityCase           INT,
				NewCountCode              NVARCHAR(50),     
				NewItemSize               INT,
				NewItemUOM                INT,
				NewMinAge                 INT,
				NewItemType               NVARCHAR(1),     
				NewMinVendorOrderQty      DECIMAL(18,6),
				NewVendorSuggestedQty     DECIMAL(18,6),
				NewMinQtyOnHand           DECIMAL(18,6),
				NewBinLocation            INT,
				NewGLPurchaseAccount      INT,
			    NewGLSalesAccount         INT,
				NewGLVarianceAccount      INT,
				UpdateReportTable         NVARCHAR(1)
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

	      set @UpdateCount = 0
			      
IF(@UpdateReportTable != 'Y')
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
			   OR (@NewVendorSuggestedQty IS NOT NULL) OR (@NewInventoryGroup IS NOT NULL))
      BEGIN 

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

IF(@UpdateReportTable != 'Y')
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
  
IF (@UpdateReportTable = 'Y')
BEGIN
     DELETE FROM tblSTMassUpdateReportMaster

	 IF (@TaxFlag1ysn IS NOT NULL)
     BEGIN

	       SET @SQL1 =  'INSERT INTO tblSTMassUpdateReportMaster(strLocationName,UpcCode,ItemDescription,
				               ChangeDescription,OldData,NewData)
							   select c.strLocationName, b.strUpcCode, 
							   d.strDescription, ''Tax Flag1'',
							   case when a.ysnTaxFlag1 = 0 then ''No'' else ''Yes'' end,
							   ''' + case when @TaxFlag1ysn = 0 then 'No' else 'Yes' end +'''
							   from tblICItemLocation a JOIN 
							   tblICItemUOM b ON a.intItemId = b.intItemId JOIN
							   tblSMCompanyLocation c ON a.intLocationId = c.intCompanyLocationId JOIN
							   tblICItem d ON a.intItemId = d.intItemId '

           SET @SQL1 = @SQL1 + ' where 1=1 ' 

	       IF (@Location IS NOT NULL)
	       BEGIN 
		        SET @SQL1 = @SQL1 + ' and c.intCompanyLocationId IN (' + CAST(@Location as NVARCHAR) + ')'
		   END
			 
	       IF (@Vendor IS NOT NULL)
	       BEGIN 
               SET @SQL1 = @SQL1 + ' and a.intVendorId IN (' + CAST(@Vendor as NVARCHAR) + ')'
		   END

           IF (@Category IS NOT NULL)
	       BEGIN
                SET @SQL1 = @SQL1 +  ' and a.intItemId  
		          IN (select intItemId from tblICItem where intCategoryId IN
		          (select intCategoryId from tblICCategory where intCategoryId 
				 IN (' + CAST(@Category as NVARCHAR) + ')' + '))'
		   END

           IF (@Family IS NOT NULL)
		   BEGIN
  		         SET @SQL1 = @SQL1 + ' and  a.intFamilyId IN (' + CAST(@Family as NVARCHAR) + ')'
		   END

           IF (@Class IS NOT NULL)
		   BEGIN
  		         SET @SQL1 = @SQL1 + ' and  a.intClassId IN (' + CAST(@Class as NVARCHAR) + ')'
		   END
		    
	       IF (@UpcCode IS NOT NULL)
   	       BEGIN
			   SET @SQL1 = @SQL1 + ' and b.intItemUOMId IN (' + CAST(@UpcCode as NVARCHAR) + ')'
		   END

           IF ((@Description IS NOT NULL)
	       and (@Description != ''))
	       BEGIN
   		        SET @SQL1 = @SQL1 +  ' and  d.strDescription like ''%' + LTRIM(@Description) + '%'' '
           END

           IF (@PriceBetween1 IS NOT NULL) 
	       BEGIN
			      set @SQL1 = @SQL1 +  ' and a.intItemId IN 
					   (select intItemId from tblICItemPricing where dblSalePrice >= 
					   ''' + CONVERT(NVARCHAR,(@PriceBetween1)) + '''' + ')'
	       END 
		      
           IF (@PriceBetween2 IS NOT NULL) 
	       BEGIN
			        set @SQL1 = @SQL1 +  ' and a.intItemId IN 
					   (select intItemId from tblICItemPricing where dblSalePrice <= 
					   ''' + CONVERT(NVARCHAR,(@PriceBetween2)) + '''' + ')'
	       END     
     EXEC (@SQL1) 
     END 
 
	 IF (@TaxFlag2ysn IS NOT NULL)
     BEGIN
	       
	       SET @SQL1 =  'INSERT INTO tblSTMassUpdateReportMaster(strLocationName,UpcCode,ItemDescription,
				               ChangeDescription,OldData,NewData)
							   select c.strLocationName, b.strUpcCode, 
							   d.strDescription, ''Tax Flag2'',
							   case when a.ysnTaxFlag2 = 0 then ''No'' else ''Yes'' end,
							   ''' + case when @TaxFlag2ysn = 0 then 'No' else 'Yes' end +'''
							   from tblICItemLocation a JOIN 
							   tblICItemUOM b ON a.intItemId = b.intItemId JOIN
							   tblSMCompanyLocation c ON a.intLocationId = c.intCompanyLocationId JOIN
							   tblICItem d ON a.intItemId = d.intItemId '

           SET @SQL1 = @SQL1 + ' where 1=1 ' 

	       IF (@Location IS NOT NULL)
	       BEGIN 
		        SET @SQL1 = @SQL1 + ' and c.intCompanyLocationId IN (' + CAST(@Location as NVARCHAR) + ')'
		   END
			 
	       IF (@Vendor IS NOT NULL)
	       BEGIN 
               SET @SQL1 = @SQL1 + ' and a.intVendorId IN (' + CAST(@Vendor as NVARCHAR) + ')'
		   END

           IF (@Category IS NOT NULL)
	       BEGIN
                SET @SQL1 = @SQL1 +  ' and a.intItemId  
		          IN (select intItemId from tblICItem where intCategoryId IN
		          (select intCategoryId from tblICCategory where intCategoryId 
				 IN (' + CAST(@Category as NVARCHAR) + ')' + '))'
		   END

           IF (@Family IS NOT NULL)
		   BEGIN
  		         SET @SQL1 = @SQL1 + ' and  a.intFamilyId IN (' + CAST(@Family as NVARCHAR) + ')'
		   END

           IF (@Class IS NOT NULL)
		   BEGIN
  		         SET @SQL1 = @SQL1 + ' and  a.intClassId IN (' + CAST(@Class as NVARCHAR) + ')'
		   END
		    
	       IF (@UpcCode IS NOT NULL)
   	       BEGIN
			   SET @SQL1 = @SQL1 + ' and b.intItemUOMId IN (' + CAST(@UpcCode as NVARCHAR) + ')'
		   END

           IF ((@Description IS NOT NULL)
	       and (@Description != ''))
	       BEGIN
   		        SET @SQL1 = @SQL1 +  ' and  d.strDescription like ''%' + LTRIM(@Description) + '%'' '
           END

           IF (@PriceBetween1 IS NOT NULL) 
	       BEGIN
			      set @SQL1 = @SQL1 +  ' and a.intItemId IN 
					   (select intItemId from tblICItemPricing where dblSalePrice >= 
					   ''' + CONVERT(NVARCHAR,(@PriceBetween1)) + '''' + ')'
	       END 
		      
           IF (@PriceBetween2 IS NOT NULL) 
	       BEGIN
			        set @SQL1 = @SQL1 +  ' and a.intItemId IN 
					   (select intItemId from tblICItemPricing where dblSalePrice <= 
					   ''' + CONVERT(NVARCHAR,(@PriceBetween2)) + '''' + ')'
	       END     
     EXEC (@SQL1)
     END 
 

	 IF (@TaxFlag3ysn IS NOT NULL)
     BEGIN

	       SET @SQL1 =  'INSERT INTO tblSTMassUpdateReportMaster(strLocationName,UpcCode,ItemDescription,
				               ChangeDescription,OldData,NewData)
							   select c.strLocationName, b.strUpcCode, 
							   d.strDescription, ''Tax Flag3'',
							   case when a.ysnTaxFlag3 = 0 then ''No'' else ''Yes'' end,
							   ''' + case when @TaxFlag3ysn = 0 then 'No' else 'Yes' end +'''
							   from tblICItemLocation a JOIN 
							   tblICItemUOM b ON a.intItemId = b.intItemId JOIN
							   tblSMCompanyLocation c ON a.intLocationId = c.intCompanyLocationId JOIN
							   tblICItem d ON a.intItemId = d.intItemId '

           SET @SQL1 = @SQL1 + ' where 1=1 ' 

	       IF (@Location IS NOT NULL)
	       BEGIN 
		        SET @SQL1 = @SQL1 + ' and c.intCompanyLocationId IN (' + CAST(@Location as NVARCHAR) + ')'
		   END
			 
	       IF (@Vendor IS NOT NULL)
	       BEGIN 
               SET @SQL1 = @SQL1 + ' and a.intVendorId IN (' + CAST(@Vendor as NVARCHAR) + ')'
		   END

           IF (@Category IS NOT NULL)
	       BEGIN
                SET @SQL1 = @SQL1 +  ' and a.intItemId  
		          IN (select intItemId from tblICItem where intCategoryId IN
		          (select intCategoryId from tblICCategory where intCategoryId 
				 IN (' + CAST(@Category as NVARCHAR) + ')' + '))'
		   END

           IF (@Family IS NOT NULL)
		   BEGIN
  		         SET @SQL1 = @SQL1 + ' and  a.intFamilyId IN (' + CAST(@Family as NVARCHAR) + ')'
		   END

           IF (@Class IS NOT NULL)
		   BEGIN
  		         SET @SQL1 = @SQL1 + ' and  a.intClassId IN (' + CAST(@Class as NVARCHAR) + ')'
		   END
		    
	       IF (@UpcCode IS NOT NULL)
   	       BEGIN
			   SET @SQL1 = @SQL1 + ' and b.intItemUOMId IN (' + CAST(@UpcCode as NVARCHAR) + ')'
		   END

           IF ((@Description IS NOT NULL)
	       and (@Description != ''))
	       BEGIN
   		        SET @SQL1 = @SQL1 +  ' and  d.strDescription like ''%' + LTRIM(@Description) + '%'' '
           END

           IF (@PriceBetween1 IS NOT NULL) 
	       BEGIN
			      set @SQL1 = @SQL1 +  ' and a.intItemId IN 
					   (select intItemId from tblICItemPricing where dblSalePrice >= 
					   ''' + CONVERT(NVARCHAR,(@PriceBetween1)) + '''' + ')'
	       END 
		      
           IF (@PriceBetween2 IS NOT NULL) 
	       BEGIN
			        set @SQL1 = @SQL1 +  ' and a.intItemId IN 
					   (select intItemId from tblICItemPricing where dblSalePrice <= 
					   ''' + CONVERT(NVARCHAR,(@PriceBetween2)) + '''' + ')'
	       END     
	 EXEC (@SQL1)
     END 

	 IF (@TaxFlag4ysn IS NOT NULL)
     BEGIN

	       SET @SQL1 =  'INSERT INTO tblSTMassUpdateReportMaster(strLocationName,UpcCode,ItemDescription,
				               ChangeDescription,OldData,NewData)
							   select c.strLocationName, b.strUpcCode, 
							   d.strDescription, ''Tax Flag4'',
							   case when a.ysnTaxFlag4 = 0 then ''No'' else ''Yes'' end,
							   ''' + case when @TaxFlag4ysn = 0 then 'No' else 'Yes' end +'''
							   from tblICItemLocation a JOIN 
							   tblICItemUOM b ON a.intItemId = b.intItemId JOIN
							   tblSMCompanyLocation c ON a.intLocationId = c.intCompanyLocationId JOIN
							   tblICItem d ON a.intItemId = d.intItemId '

           SET @SQL1 = @SQL1 + ' where 1=1 ' 

	       IF (@Location IS NOT NULL)
	       BEGIN 
		        SET @SQL1 = @SQL1 + ' and c.intCompanyLocationId IN (' + CAST(@Location as NVARCHAR) + ')'
		   END
			 
	       IF (@Vendor IS NOT NULL)
	       BEGIN 
               SET @SQL1 = @SQL1 + ' and a.intVendorId IN (' + CAST(@Vendor as NVARCHAR) + ')'
		   END

           IF (@Category IS NOT NULL)
	       BEGIN
                SET @SQL1 = @SQL1 +  ' and a.intItemId  
		          IN (select intItemId from tblICItem where intCategoryId IN
		          (select intCategoryId from tblICCategory where intCategoryId 
				 IN (' + CAST(@Category as NVARCHAR) + ')' + '))'
		   END

           IF (@Family IS NOT NULL)
		   BEGIN
  		         SET @SQL1 = @SQL1 + ' and  a.intFamilyId IN (' + CAST(@Family as NVARCHAR) + ')'
		   END

           IF (@Class IS NOT NULL)
		   BEGIN
  		         SET @SQL1 = @SQL1 + ' and  a.intClassId IN (' + CAST(@Class as NVARCHAR) + ')'
		   END
		    
	       IF (@UpcCode IS NOT NULL)
   	       BEGIN
			   SET @SQL1 = @SQL1 + ' and b.intItemUOMId IN (' + CAST(@UpcCode as NVARCHAR) + ')'
		   END

           IF ((@Description IS NOT NULL)
	       and (@Description != ''))
	       BEGIN
   		        SET @SQL1 = @SQL1 +  ' and  d.strDescription like ''%' + LTRIM(@Description) + '%'' '
           END

           IF (@PriceBetween1 IS NOT NULL) 
	       BEGIN
			      set @SQL1 = @SQL1 +  ' and a.intItemId IN 
					   (select intItemId from tblICItemPricing where dblSalePrice >= 
					   ''' + CONVERT(NVARCHAR,(@PriceBetween1)) + '''' + ')'
	       END 
		      
           IF (@PriceBetween2 IS NOT NULL) 
	       BEGIN
			        set @SQL1 = @SQL1 +  ' and a.intItemId IN 
					   (select intItemId from tblICItemPricing where dblSalePrice <= 
					   ''' + CONVERT(NVARCHAR,(@PriceBetween2)) + '''' + ')'
	       END    
	 EXEC (@SQL1) 
     END 

	 IF (@DepositRequiredysn  IS NOT NULL)
     BEGIN

	       SET @SQL1 =  'INSERT INTO tblSTMassUpdateReportMaster(strLocationName,UpcCode,ItemDescription,
				               ChangeDescription,OldData,NewData)
							   select c.strLocationName, b.strUpcCode, 
							   d.strDescription, ''Deposit Required'',
							   case when a.ysnDepositRequired = 0 then ''No'' else ''Yes'' end,
							   ''' + case when @DepositRequiredysn = 0 then 'No' else 'Yes' end +'''
							   from tblICItemLocation a JOIN 
							   tblICItemUOM b ON a.intItemId = b.intItemId JOIN
							   tblSMCompanyLocation c ON a.intLocationId = c.intCompanyLocationId JOIN
							   tblICItem d ON a.intItemId = d.intItemId '

           SET @SQL1 = @SQL1 + ' where 1=1 ' 

	       IF (@Location IS NOT NULL)
	       BEGIN 
		        SET @SQL1 = @SQL1 + ' and c.intCompanyLocationId IN (' + CAST(@Location as NVARCHAR) + ')'
		   END
			 
	       IF (@Vendor IS NOT NULL)
	       BEGIN 
               SET @SQL1 = @SQL1 + ' and a.intVendorId IN (' + CAST(@Vendor as NVARCHAR) + ')'
		   END

           IF (@Category IS NOT NULL)
	       BEGIN
                SET @SQL1 = @SQL1 +  ' and a.intItemId  
		          IN (select intItemId from tblICItem where intCategoryId IN
		          (select intCategoryId from tblICCategory where intCategoryId 
				 IN (' + CAST(@Category as NVARCHAR) + ')' + '))'
		   END

           IF (@Family IS NOT NULL)
		   BEGIN
  		         SET @SQL1 = @SQL1 + ' and  a.intFamilyId IN (' + CAST(@Family as NVARCHAR) + ')'
		   END

           IF (@Class IS NOT NULL)
		   BEGIN
  		         SET @SQL1 = @SQL1 + ' and  a.intClassId IN (' + CAST(@Class as NVARCHAR) + ')'
		   END
		    
	       IF (@UpcCode IS NOT NULL)
   	       BEGIN
			   SET @SQL1 = @SQL1 + ' and b.intItemUOMId IN (' + CAST(@UpcCode as NVARCHAR) + ')'
		   END

           IF ((@Description IS NOT NULL)
	       and (@Description != ''))
	       BEGIN
   		        SET @SQL1 = @SQL1 +  ' and  d.strDescription like ''%' + LTRIM(@Description) + '%'' '
           END

           IF (@PriceBetween1 IS NOT NULL) 
	       BEGIN
			      set @SQL1 = @SQL1 +  ' and a.intItemId IN 
					   (select intItemId from tblICItemPricing where dblSalePrice >= 
					   ''' + CONVERT(NVARCHAR,(@PriceBetween1)) + '''' + ')'
	       END 
		      
           IF (@PriceBetween2 IS NOT NULL) 
	       BEGIN
			        set @SQL1 = @SQL1 +  ' and a.intItemId IN 
					   (select intItemId from tblICItemPricing where dblSalePrice <= 
					   ''' + CONVERT(NVARCHAR,(@PriceBetween2)) + '''' + ')'
	       END    
	 EXEC (@SQL1)
     END 

	 IF (@DepositPLU  IS NOT NULL)
     BEGIN


	       SELECT @NewDepositPluId = strUpcCode from tblICItemUOM where intItemUOMId = @DepositPLU

	       SET @SQL1 =  'INSERT INTO tblSTMassUpdateReportMaster(strLocationName,UpcCode,ItemDescription,
				               ChangeDescription,OldData,NewData)
							   select c.strLocationName, b.strUpcCode, 
							   d.strDescription, ''Deposit PLU'', 
							   (select strUpcCode from tblICItemUOM where intItemUOMId = a.intDepositPLUId), 
							   ''' + @NewDepositPluId + '''
							   from tblICItemLocation a JOIN 
							   tblICItemUOM b ON a.intItemId = b.intItemId JOIN
							   tblSMCompanyLocation c ON a.intLocationId = c.intCompanyLocationId JOIN
							   tblICItem d ON a.intItemId = d.intItemId '

           SET @SQL1 = @SQL1 + ' where 1=1 ' 

	       IF (@Location IS NOT NULL)
	       BEGIN 
		        SET @SQL1 = @SQL1 + ' and a.intLocationId IN (' + CAST(@Location as NVARCHAR) + ')'
		   END
			 
	       IF (@Vendor IS NOT NULL)
	       BEGIN 
               SET @SQL1 = @SQL1 + ' and a.intVendorId IN (' + CAST(@Vendor as NVARCHAR) + ')'
		   END

           IF (@Category IS NOT NULL)
	       BEGIN
                SET @SQL1 = @SQL1 +  ' and a.intItemId  
		          IN (select intItemId from tblICItem where intCategoryId IN
		          (select intCategoryId from tblICCategory where intCategoryId 
				 IN (' + CAST(@Category as NVARCHAR) + ')' + '))'
		   END

           IF (@Family IS NOT NULL)
		   BEGIN
  		         SET @SQL1 = @SQL1 + ' and  a.intFamilyId IN (' + CAST(@Family as NVARCHAR) + ')'
		   END

           IF (@Class IS NOT NULL)
		   BEGIN
  		         SET @SQL1 = @SQL1 + ' and  a.intClassId IN (' + CAST(@Class as NVARCHAR) + ')'
		   END
		    
	       IF (@UpcCode IS NOT NULL)
   	       BEGIN
			   SET @SQL1 = @SQL1 + ' and b.intItemUOMId IN (' + CAST(@UpcCode as NVARCHAR) + ')'
		   END

           IF ((@Description IS NOT NULL)
	       and (@Description != ''))
	       BEGIN
   		        SET @SQL1 = @SQL1 +  ' and  d.strDescription like ''%' + LTRIM(@Description) + '%'' '
           END

           IF (@PriceBetween1 IS NOT NULL) 
	       BEGIN
			      set @SQL1 = @SQL1 +  ' and a.intItemId IN 
					   (select intItemId from tblICItemPricing where dblSalePrice >= 
					   ''' + CONVERT(NVARCHAR,(@PriceBetween1)) + '''' + ')'
	       END 
		      
           IF (@PriceBetween2 IS NOT NULL) 
	       BEGIN
			        set @SQL1 = @SQL1 +  ' and a.intItemId IN 
					   (select intItemId from tblICItemPricing where dblSalePrice <= 
					   ''' + CONVERT(NVARCHAR,(@PriceBetween2)) + '''' + ')'
	       END    
	 EXEC (@SQL1)
     END 

	 IF (@QuantityRequiredysn  IS NOT NULL)
     BEGIN

	       SET @SQL1 =  'INSERT INTO tblSTMassUpdateReportMaster(strLocationName,UpcCode,ItemDescription,
				               ChangeDescription,OldData,NewData)
							   select c.strLocationName, b.strUpcCode, 
							   d.strDescription, ''Quantity Required'',
							   case when a.ysnQuantityRequired = 0 then ''No'' else ''Yes'' end,
							   ''' + case when @QuantityRequiredysn = 0 then 'No' else 'Yes' end +'''
							   from tblICItemLocation a JOIN 
							   tblICItemUOM b ON a.intItemId = b.intItemId JOIN
							   tblSMCompanyLocation c ON a.intLocationId = c.intCompanyLocationId JOIN
							   tblICItem d ON a.intItemId = d.intItemId '

           SET @SQL1 = @SQL1 + ' where 1=1 ' 

	       IF (@Location IS NOT NULL)
	       BEGIN 
		        SET @SQL1 = @SQL1 + ' and c.intCompanyLocationId IN (' + CAST(@Location as NVARCHAR) + ')'
		   END
			 
	       IF (@Vendor IS NOT NULL)
	       BEGIN 
               SET @SQL1 = @SQL1 + ' and a.intVendorId IN (' + CAST(@Vendor as NVARCHAR) + ')'
		   END

           IF (@Category IS NOT NULL)
	       BEGIN
                SET @SQL1 = @SQL1 +  ' and a.intItemId  
		          IN (select intItemId from tblICItem where intCategoryId IN
		          (select intCategoryId from tblICCategory where intCategoryId 
				 IN (' + CAST(@Category as NVARCHAR) + ')' + '))'
		   END

           IF (@Family IS NOT NULL)
		   BEGIN
  		         SET @SQL1 = @SQL1 + ' and  a.intFamilyId IN (' + CAST(@Family as NVARCHAR) + ')'
		   END

           IF (@Class IS NOT NULL)
		   BEGIN
  		         SET @SQL1 = @SQL1 + ' and  a.intClassId IN (' + CAST(@Class as NVARCHAR) + ')'
		   END
		    
	       IF (@UpcCode IS NOT NULL)
   	       BEGIN
			   SET @SQL1 = @SQL1 + ' and b.intItemUOMId IN (' + CAST(@UpcCode as NVARCHAR) + ')'
		   END

           IF ((@Description IS NOT NULL)
	       and (@Description != ''))
	       BEGIN
   		        SET @SQL1 = @SQL1 +  ' and  d.strDescription like ''%' + LTRIM(@Description) + '%'' '
           END

           IF (@PriceBetween1 IS NOT NULL) 
	       BEGIN
			      set @SQL1 = @SQL1 +  ' and a.intItemId IN 
					   (select intItemId from tblICItemPricing where dblSalePrice >= 
					   ''' + CONVERT(NVARCHAR,(@PriceBetween1)) + '''' + ')'
	       END 
		      
           IF (@PriceBetween2 IS NOT NULL) 
	       BEGIN
			        set @SQL1 = @SQL1 +  ' and a.intItemId IN 
					   (select intItemId from tblICItemPricing where dblSalePrice <= 
					   ''' + CONVERT(NVARCHAR,(@PriceBetween2)) + '''' + ')'
	       END     
	 EXEC (@SQL1)
     END 

	 IF (@ScaleItemysn  IS NOT NULL)
     BEGIN

	       SET @SQL1 =  'INSERT INTO tblSTMassUpdateReportMaster(strLocationName,UpcCode,ItemDescription,
				               ChangeDescription,OldData,NewData)
							   select c.strLocationName, b.strUpcCode, 
							   d.strDescription, ''Scale Item'',
							   case when a.ysnScaleItem = 0 then ''No'' else ''Yes'' end,
							   ''' + case when @ScaleItemysn = 0 then 'No' else 'Yes' end +'''
							   from tblICItemLocation a JOIN 
							   tblICItemUOM b ON a.intItemId = b.intItemId JOIN
							   tblSMCompanyLocation c ON a.intLocationId = c.intCompanyLocationId JOIN
							   tblICItem d ON a.intItemId = d.intItemId '

           SET @SQL1 = @SQL1 + ' where 1=1 ' 

	       IF (@Location IS NOT NULL)
	       BEGIN 
		        SET @SQL1 = @SQL1 + ' and c.intCompanyLocationId IN (' + CAST(@Location as NVARCHAR) + ')'
		   END
			 
	       IF (@Vendor IS NOT NULL)
	       BEGIN 
               SET @SQL1 = @SQL1 + ' and a.intVendorId IN (' + CAST(@Vendor as NVARCHAR) + ')'
		   END

           IF (@Category IS NOT NULL)
	       BEGIN
                SET @SQL1 = @SQL1 +  ' and a.intItemId  
		          IN (select intItemId from tblICItem where intCategoryId IN
		          (select intCategoryId from tblICCategory where intCategoryId 
				 IN (' + CAST(@Category as NVARCHAR) + ')' + '))'
		   END

           IF (@Family IS NOT NULL)
		   BEGIN
  		         SET @SQL1 = @SQL1 + ' and  a.intFamilyId IN (' + CAST(@Family as NVARCHAR) + ')'
		   END

           IF (@Class IS NOT NULL)
		   BEGIN
  		         SET @SQL1 = @SQL1 + ' and  a.intClassId IN (' + CAST(@Class as NVARCHAR) + ')'
		   END
		    
	       IF (@UpcCode IS NOT NULL)
   	       BEGIN
			   SET @SQL1 = @SQL1 + ' and b.intItemUOMId IN (' + CAST(@UpcCode as NVARCHAR) + ')'
		   END

           IF ((@Description IS NOT NULL)
	       and (@Description != ''))
	       BEGIN
   		        SET @SQL1 = @SQL1 +  ' and  d.strDescription like ''%' + LTRIM(@Description) + '%'' '
           END

           IF (@PriceBetween1 IS NOT NULL) 
	       BEGIN
			      set @SQL1 = @SQL1 +  ' and a.intItemId IN 
					   (select intItemId from tblICItemPricing where dblSalePrice >= 
					   ''' + CONVERT(NVARCHAR,(@PriceBetween1)) + '''' + ')'
	       END 
		      
           IF (@PriceBetween2 IS NOT NULL) 
	       BEGIN
			        set @SQL1 = @SQL1 +  ' and a.intItemId IN 
					   (select intItemId from tblICItemPricing where dblSalePrice <= 
					   ''' + CONVERT(NVARCHAR,(@PriceBetween2)) + '''' + ')'
	       END     
	 EXEC (@SQL1)
     END 

	 IF (@FoodStampableysn  IS NOT NULL)
     BEGIN

	       SET @SQL1 =  'INSERT INTO tblSTMassUpdateReportMaster(strLocationName,UpcCode,ItemDescription,
				               ChangeDescription,OldData,NewData)
							   select c.strLocationName, b.strUpcCode, 
							   d.strDescription, ''Food Stampable'',
							   case when a.ysnFoodStampable = 0 then ''No'' else ''Yes'' end,
							   ''' + case when @FoodStampableysn = 0 then 'No' else 'Yes' end +'''
							   from tblICItemLocation a JOIN 
							   tblICItemUOM b ON a.intItemId = b.intItemId JOIN
							   tblSMCompanyLocation c ON a.intLocationId = c.intCompanyLocationId JOIN
							   tblICItem d ON a.intItemId = d.intItemId '

           SET @SQL1 = @SQL1 + ' where 1=1 ' 

	       IF (@Location IS NOT NULL)
	       BEGIN 
		        SET @SQL1 = @SQL1 + ' and c.intCompanyLocationId IN (' + CAST(@Location as NVARCHAR) + ')'
		   END
			 
	       IF (@Vendor IS NOT NULL)
	       BEGIN 
               SET @SQL1 = @SQL1 + ' and a.intVendorId IN (' + CAST(@Vendor as NVARCHAR) + ')'
		   END

           IF (@Category IS NOT NULL)
	       BEGIN
                SET @SQL1 = @SQL1 +  ' and a.intItemId  
		          IN (select intItemId from tblICItem where intCategoryId IN
		          (select intCategoryId from tblICCategory where intCategoryId 
				 IN (' + CAST(@Category as NVARCHAR) + ')' + '))'
		   END

           IF (@Family IS NOT NULL)
		   BEGIN
  		         SET @SQL1 = @SQL1 + ' and  a.intFamilyId IN (' + CAST(@Family as NVARCHAR) + ')'
		   END

           IF (@Class IS NOT NULL)
		   BEGIN
  		         SET @SQL1 = @SQL1 + ' and  a.intClassId IN (' + CAST(@Class as NVARCHAR) + ')'
		   END
		    
	       IF (@UpcCode IS NOT NULL)
   	       BEGIN
			   SET @SQL1 = @SQL1 + ' and b.intItemUOMId IN (' + CAST(@UpcCode as NVARCHAR) + ')'
		   END

           IF ((@Description IS NOT NULL)
	       and (@Description != ''))
	       BEGIN
   		        SET @SQL1 = @SQL1 +  ' and  d.strDescription like ''%' + LTRIM(@Description) + '%'' '
           END

           IF (@PriceBetween1 IS NOT NULL) 
	       BEGIN
			      set @SQL1 = @SQL1 +  ' and a.intItemId IN 
					   (select intItemId from tblICItemPricing where dblSalePrice >= 
					   ''' + CONVERT(NVARCHAR,(@PriceBetween1)) + '''' + ')'
	       END 
		      
           IF (@PriceBetween2 IS NOT NULL) 
	       BEGIN
			        set @SQL1 = @SQL1 +  ' and a.intItemId IN 
					   (select intItemId from tblICItemPricing where dblSalePrice <= 
					   ''' + CONVERT(NVARCHAR,(@PriceBetween2)) + '''' + ')'
	       END     
	 EXEC (@SQL1)
     END 

	 IF (@Returnableysn  IS NOT NULL)
     BEGIN

	       SET @SQL1 =  'INSERT INTO tblSTMassUpdateReportMaster(strLocationName,UpcCode,ItemDescription,
				               ChangeDescription,OldData,NewData)
							   select c.strLocationName, b.strUpcCode, 
							   d.strDescription, ''Returnable '',
							   case when a.ysnReturnable = 0 then ''No'' else ''Yes'' end,
							   ''' + case when @Returnableysn = 0 then 'No' else 'Yes' end +'''
							   from tblICItemLocation a JOIN 
							   tblICItemUOM b ON a.intItemId = b.intItemId JOIN
							   tblSMCompanyLocation c ON a.intLocationId = c.intCompanyLocationId JOIN
							   tblICItem d ON a.intItemId = d.intItemId '

           SET @SQL1 = @SQL1 + ' where 1=1 ' 

	       IF (@Location IS NOT NULL)
	       BEGIN 
		        SET @SQL1 = @SQL1 + ' and c.intCompanyLocationId IN (' + CAST(@Location as NVARCHAR) + ')'
		   END
			 
	       IF (@Vendor IS NOT NULL)
	       BEGIN 
               SET @SQL1 = @SQL1 + ' and a.intVendorId IN (' + CAST(@Vendor as NVARCHAR) + ')'
		   END

           IF (@Category IS NOT NULL)
	       BEGIN
                SET @SQL1 = @SQL1 +  ' and a.intItemId  
		          IN (select intItemId from tblICItem where intCategoryId IN
		          (select intCategoryId from tblICCategory where intCategoryId 
				 IN (' + CAST(@Category as NVARCHAR) + ')' + '))'
		   END

           IF (@Family IS NOT NULL)
		   BEGIN
  		         SET @SQL1 = @SQL1 + ' and  a.intFamilyId IN (' + CAST(@Family as NVARCHAR) + ')'
		   END

           IF (@Class IS NOT NULL)
		   BEGIN
  		         SET @SQL1 = @SQL1 + ' and  a.intClassId IN (' + CAST(@Class as NVARCHAR) + ')'
		   END
		    
	       IF (@UpcCode IS NOT NULL)
   	       BEGIN
			   SET @SQL1 = @SQL1 + ' and b.intItemUOMId IN (' + CAST(@UpcCode as NVARCHAR) + ')'
		   END

           IF ((@Description IS NOT NULL)
	       and (@Description != ''))
	       BEGIN
   		        SET @SQL1 = @SQL1 +  ' and  d.strDescription like ''%' + LTRIM(@Description) + '%'' '
           END

           IF (@PriceBetween1 IS NOT NULL) 
	       BEGIN
			      set @SQL1 = @SQL1 +  ' and a.intItemId IN 
					   (select intItemId from tblICItemPricing where dblSalePrice >= 
					   ''' + CONVERT(NVARCHAR,(@PriceBetween1)) + '''' + ')'
	       END 
		      
           IF (@PriceBetween2 IS NOT NULL) 
	       BEGIN
			        set @SQL1 = @SQL1 +  ' and a.intItemId IN 
					   (select intItemId from tblICItemPricing where dblSalePrice <= 
					   ''' + CONVERT(NVARCHAR,(@PriceBetween2)) + '''' + ')'
	       END     
	 EXEC (@SQL1)
     END 

	 IF (@Saleableysn  IS NOT NULL)
     BEGIN

	       SET @SQL1 =  'INSERT INTO tblSTMassUpdateReportMaster(strLocationName,UpcCode,ItemDescription,
				               ChangeDescription,OldData,NewData)
							   select c.strLocationName, b.strUpcCode, 
							   d.strDescription, ''Saleable '',
							   case when a.ysnSaleable = 0 then ''No'' else ''Yes'' end,
							   ''' + case when @Saleableysn = 0 then 'No' else 'Yes' end +'''
							   from tblICItemLocation a JOIN 
							   tblICItemUOM b ON a.intItemId = b.intItemId JOIN
							   tblSMCompanyLocation c ON a.intLocationId = c.intCompanyLocationId JOIN
							   tblICItem d ON a.intItemId = d.intItemId '

           SET @SQL1 = @SQL1 + ' where 1=1 ' 

	       IF (@Location IS NOT NULL)
	       BEGIN 
		        SET @SQL1 = @SQL1 + ' and c.intCompanyLocationId IN (' + CAST(@Location as NVARCHAR) + ')'
		   END
			 
	       IF (@Vendor IS NOT NULL)
	       BEGIN 
               SET @SQL1 = @SQL1 + ' and a.intVendorId IN (' + CAST(@Vendor as NVARCHAR) + ')'
		   END

           IF (@Category IS NOT NULL)
	       BEGIN
                SET @SQL1 = @SQL1 +  ' and a.intItemId  
		          IN (select intItemId from tblICItem where intCategoryId IN
		          (select intCategoryId from tblICCategory where intCategoryId 
				 IN (' + CAST(@Category as NVARCHAR) + ')' + '))'
		   END

           IF (@Family IS NOT NULL)
		   BEGIN
  		         SET @SQL1 = @SQL1 + ' and  a.intFamilyId IN (' + CAST(@Family as NVARCHAR) + ')'
		   END

           IF (@Class IS NOT NULL)
		   BEGIN
  		         SET @SQL1 = @SQL1 + ' and  a.intClassId IN (' + CAST(@Class as NVARCHAR) + ')'
		   END
		    
	       IF (@UpcCode IS NOT NULL)
   	       BEGIN
			   SET @SQL1 = @SQL1 + ' and b.intItemUOMId IN (' + CAST(@UpcCode as NVARCHAR) + ')'
		   END

           IF ((@Description IS NOT NULL)
	       and (@Description != ''))
	       BEGIN
   		        SET @SQL1 = @SQL1 +  ' and  d.strDescription like ''%' + LTRIM(@Description) + '%'' '
           END

           IF (@PriceBetween1 IS NOT NULL) 
	       BEGIN
			      set @SQL1 = @SQL1 +  ' and a.intItemId IN 
					   (select intItemId from tblICItemPricing where dblSalePrice >= 
					   ''' + CONVERT(NVARCHAR,(@PriceBetween1)) + '''' + ')'
	       END 
		      
           IF (@PriceBetween2 IS NOT NULL) 
	       BEGIN
			        set @SQL1 = @SQL1 +  ' and a.intItemId IN 
					   (select intItemId from tblICItemPricing where dblSalePrice <= 
					   ''' + CONVERT(NVARCHAR,(@PriceBetween2)) + '''' + ')'
	       END     
	 EXEC (@SQL1)
     END 

	 IF (@ID1Requiredysn  IS NOT NULL)
     BEGIN

	       SET @SQL1 =  'INSERT INTO tblSTMassUpdateReportMaster(strLocationName,UpcCode,ItemDescription,
				               ChangeDescription,OldData,NewData)
							   select c.strLocationName, b.strUpcCode, 
							   d.strDescription, ''Liquor Id Required '',
							   case when a.ysnIdRequiredLiquor = 0 then ''No'' else ''Yes'' end,
							   ''' + case when @ID1Requiredysn = 0 then 'No' else 'Yes' end +'''
							   from tblICItemLocation a JOIN 
							   tblICItemUOM b ON a.intItemId = b.intItemId JOIN
							   tblSMCompanyLocation c ON a.intLocationId = c.intCompanyLocationId JOIN
							   tblICItem d ON a.intItemId = d.intItemId '

           SET @SQL1 = @SQL1 + ' where 1=1 ' 

	       IF (@Location IS NOT NULL)
	       BEGIN 
		        SET @SQL1 = @SQL1 + ' and c.intCompanyLocationId IN (' + CAST(@Location as NVARCHAR) + ')'
		   END
			 
	       IF (@Vendor IS NOT NULL)
	       BEGIN 
               SET @SQL1 = @SQL1 + ' and a.intVendorId IN (' + CAST(@Vendor as NVARCHAR) + ')'
		   END

           IF (@Category IS NOT NULL)
	       BEGIN
                SET @SQL1 = @SQL1 +  ' and a.intItemId  
		          IN (select intItemId from tblICItem where intCategoryId IN
		          (select intCategoryId from tblICCategory where intCategoryId 
				 IN (' + CAST(@Category as NVARCHAR) + ')' + '))'
		   END

           IF (@Family IS NOT NULL)
		   BEGIN
  		         SET @SQL1 = @SQL1 + ' and  a.intFamilyId IN (' + CAST(@Family as NVARCHAR) + ')'
		   END

           IF (@Class IS NOT NULL)
		   BEGIN
  		         SET @SQL1 = @SQL1 + ' and  a.intClassId IN (' + CAST(@Class as NVARCHAR) + ')'
		   END
		    
	       IF (@UpcCode IS NOT NULL)
   	       BEGIN
			   SET @SQL1 = @SQL1 + ' and b.intItemUOMId IN (' + CAST(@UpcCode as NVARCHAR) + ')'
		   END

           IF ((@Description IS NOT NULL)
	       and (@Description != ''))
	       BEGIN
   		        SET @SQL1 = @SQL1 +  ' and  d.strDescription like ''%' + LTRIM(@Description) + '%'' '
           END

           IF (@PriceBetween1 IS NOT NULL) 
	       BEGIN
			      set @SQL1 = @SQL1 +  ' and a.intItemId IN 
					   (select intItemId from tblICItemPricing where dblSalePrice >= 
					   ''' + CONVERT(NVARCHAR,(@PriceBetween1)) + '''' + ')'
	       END 
		      
           IF (@PriceBetween2 IS NOT NULL) 
	       BEGIN
			        set @SQL1 = @SQL1 +  ' and a.intItemId IN 
					   (select intItemId from tblICItemPricing where dblSalePrice <= 
					   ''' + CONVERT(NVARCHAR,(@PriceBetween2)) + '''' + ')'
	       END     
	 EXEC (@SQL1)
     END 

	 IF (@ID2Requiredysn  IS NOT NULL)
     BEGIN

	       SET @SQL1 =  'INSERT INTO tblSTMassUpdateReportMaster(strLocationName,UpcCode,ItemDescription,
				               ChangeDescription,OldData,NewData)
							   select c.strLocationName, b.strUpcCode, 
							   d.strDescription, ''Cigarette Id Required '',
							   case when a.ysnIdRequiredCigarette = 0 then ''No'' else ''Yes'' end,
							   ''' + case when @ID2Requiredysn = 0 then 'No' else 'Yes' end +'''
							   from tblICItemLocation a JOIN 
							   tblICItemUOM b ON a.intItemId = b.intItemId JOIN
							   tblSMCompanyLocation c ON a.intLocationId = c.intCompanyLocationId JOIN
							   tblICItem d ON a.intItemId = d.intItemId '

           SET @SQL1 = @SQL1 + ' where 1=1 ' 

	       IF (@Location IS NOT NULL)
	       BEGIN 
		        SET @SQL1 = @SQL1 + ' and c.intCompanyLocationId IN (' + CAST(@Location as NVARCHAR) + ')'
		   END
			 
	       IF (@Vendor IS NOT NULL)
	       BEGIN 
               SET @SQL1 = @SQL1 + ' and a.intVendorId IN (' + CAST(@Vendor as NVARCHAR) + ')'
		   END

           IF (@Category IS NOT NULL)
	       BEGIN
                SET @SQL1 = @SQL1 +  ' and a.intItemId  
		          IN (select intItemId from tblICItem where intCategoryId IN
		          (select intCategoryId from tblICCategory where intCategoryId 
				 IN (' + CAST(@Category as NVARCHAR) + ')' + '))'
		   END

           IF (@Family IS NOT NULL)
		   BEGIN
  		         SET @SQL1 = @SQL1 + ' and  a.intFamilyId IN (' + CAST(@Family as NVARCHAR) + ')'
		   END

           IF (@Class IS NOT NULL)
		   BEGIN
  		         SET @SQL1 = @SQL1 + ' and  a.intClassId IN (' + CAST(@Class as NVARCHAR) + ')'
		   END
		    
	       IF (@UpcCode IS NOT NULL)
   	       BEGIN
			   SET @SQL1 = @SQL1 + ' and b.intItemUOMId IN (' + CAST(@UpcCode as NVARCHAR) + ')'
		   END

           IF ((@Description IS NOT NULL)
	       and (@Description != ''))
	       BEGIN
   		        SET @SQL1 = @SQL1 +  ' and  d.strDescription like ''%' + LTRIM(@Description) + '%'' '
           END

           IF (@PriceBetween1 IS NOT NULL) 
	       BEGIN
			      set @SQL1 = @SQL1 +  ' and a.intItemId IN 
					   (select intItemId from tblICItemPricing where dblSalePrice >= 
					   ''' + CONVERT(NVARCHAR,(@PriceBetween1)) + '''' + ')'
	       END 
		      
           IF (@PriceBetween2 IS NOT NULL) 
	       BEGIN
			        set @SQL1 = @SQL1 +  ' and a.intItemId IN 
					   (select intItemId from tblICItemPricing where dblSalePrice <= 
					   ''' + CONVERT(NVARCHAR,(@PriceBetween2)) + '''' + ')'
	       END     
	 EXEC (@SQL1)
     END 

	 IF (@PromotionalItemysn  IS NOT NULL)
     BEGIN

	       SET @SQL1 =  'INSERT INTO tblSTMassUpdateReportMaster(strLocationName,UpcCode,ItemDescription,
				               ChangeDescription,OldData,NewData)
							   select c.strLocationName, b.strUpcCode, 
							   d.strDescription, ''Promotional Item'',
							   case when a.ysnPromotionalItem = 0 then ''No'' else ''Yes'' end,
							   ''' + case when @PromotionalItemysn = 0 then 'No' else 'Yes' end +'''
							   from tblICItemLocation a JOIN 
							   tblICItemUOM b ON a.intItemId = b.intItemId JOIN
							   tblSMCompanyLocation c ON a.intLocationId = c.intCompanyLocationId JOIN
							   tblICItem d ON a.intItemId = d.intItemId '

           SET @SQL1 = @SQL1 + ' where 1=1 ' 

	       IF (@Location IS NOT NULL)
	       BEGIN 
		        SET @SQL1 = @SQL1 + ' and c.intCompanyLocationId IN (' + CAST(@Location as NVARCHAR) + ')'
		   END
			 
	       IF (@Vendor IS NOT NULL)
	       BEGIN 
               SET @SQL1 = @SQL1 + ' and a.intVendorId IN (' + CAST(@Vendor as NVARCHAR) + ')'
		   END

           IF (@Category IS NOT NULL)
	       BEGIN
                SET @SQL1 = @SQL1 +  ' and a.intItemId  
		          IN (select intItemId from tblICItem where intCategoryId IN
		          (select intCategoryId from tblICCategory where intCategoryId 
				 IN (' + CAST(@Category as NVARCHAR) + ')' + '))'
		   END

           IF (@Family IS NOT NULL)
		   BEGIN
  		         SET @SQL1 = @SQL1 + ' and  a.intFamilyId IN (' + CAST(@Family as NVARCHAR) + ')'
		   END

           IF (@Class IS NOT NULL)
		   BEGIN
  		         SET @SQL1 = @SQL1 + ' and  a.intClassId IN (' + CAST(@Class as NVARCHAR) + ')'
		   END
		    
	       IF (@UpcCode IS NOT NULL)
   	       BEGIN
			   SET @SQL1 = @SQL1 + ' and b.intItemUOMId IN (' + CAST(@UpcCode as NVARCHAR) + ')'
		   END

           IF ((@Description IS NOT NULL)
	       and (@Description != ''))
	       BEGIN
   		        SET @SQL1 = @SQL1 +  ' and  d.strDescription like ''%' + LTRIM(@Description) + '%'' '
           END

           IF (@PriceBetween1 IS NOT NULL) 
	       BEGIN
			      set @SQL1 = @SQL1 +  ' and a.intItemId IN 
					   (select intItemId from tblICItemPricing where dblSalePrice >= 
					   ''' + CONVERT(NVARCHAR,(@PriceBetween1)) + '''' + ')'
	       END 
		      
           IF (@PriceBetween2 IS NOT NULL) 
	       BEGIN
			        set @SQL1 = @SQL1 +  ' and a.intItemId IN 
					   (select intItemId from tblICItemPricing where dblSalePrice <= 
					   ''' + CONVERT(NVARCHAR,(@PriceBetween2)) + '''' + ')'
	       END     
	 EXEC (@SQL1)
     END 

	 IF (@PrePricedysn  IS NOT NULL)
     BEGIN

	       SET @SQL1 =  'INSERT INTO tblSTMassUpdateReportMaster(strLocationName,UpcCode,ItemDescription,
				               ChangeDescription,OldData,NewData)
							   select c.strLocationName, b.strUpcCode, 
							   d.strDescription, ''Pre Priced'',
							   case when a.ysnPrePriced = 0 then ''No'' else ''Yes'' end,
							   ''' + case when @PrePricedysn = 0 then 'No' else 'Yes' end +'''
							   from tblICItemLocation a JOIN 
							   tblICItemUOM b ON a.intItemId = b.intItemId JOIN
							   tblSMCompanyLocation c ON a.intLocationId = c.intCompanyLocationId JOIN
							   tblICItem d ON a.intItemId = d.intItemId '

           SET @SQL1 = @SQL1 + ' where 1=1 ' 

	       IF (@Location IS NOT NULL)
	       BEGIN 
		        SET @SQL1 = @SQL1 + ' and c.intCompanyLocationId IN (' + CAST(@Location as NVARCHAR) + ')'
		   END
			 
	       IF (@Vendor IS NOT NULL)
	       BEGIN 
               SET @SQL1 = @SQL1 + ' and a.intVendorId IN (' + CAST(@Vendor as NVARCHAR) + ')'
		   END

           IF (@Category IS NOT NULL)
	       BEGIN
                SET @SQL1 = @SQL1 +  ' and a.intItemId  
		          IN (select intItemId from tblICItem where intCategoryId IN
		          (select intCategoryId from tblICCategory where intCategoryId 
				 IN (' + CAST(@Category as NVARCHAR) + ')' + '))'
		   END

           IF (@Family IS NOT NULL)
		   BEGIN
  		         SET @SQL1 = @SQL1 + ' and  a.intFamilyId IN (' + CAST(@Family as NVARCHAR) + ')'
		   END

           IF (@Class IS NOT NULL)
		   BEGIN
  		         SET @SQL1 = @SQL1 + ' and  a.intClassId IN (' + CAST(@Class as NVARCHAR) + ')'
		   END
		    
	       IF (@UpcCode IS NOT NULL)
   	       BEGIN
			   SET @SQL1 = @SQL1 + ' and b.intItemUOMId IN (' + CAST(@UpcCode as NVARCHAR) + ')'
		   END

           IF ((@Description IS NOT NULL)
	       and (@Description != ''))
	       BEGIN
   		        SET @SQL1 = @SQL1 +  ' and  d.strDescription like ''%' + LTRIM(@Description) + '%'' '
           END

           IF (@PriceBetween1 IS NOT NULL) 
	       BEGIN
			      set @SQL1 = @SQL1 +  ' and a.intItemId IN 
					   (select intItemId from tblICItemPricing where dblSalePrice >= 
					   ''' + CONVERT(NVARCHAR,(@PriceBetween1)) + '''' + ')'
	       END 
		      
           IF (@PriceBetween2 IS NOT NULL) 
	       BEGIN
			        set @SQL1 = @SQL1 +  ' and a.intItemId IN 
					   (select intItemId from tblICItemPricing where dblSalePrice <= 
					   ''' + CONVERT(NVARCHAR,(@PriceBetween2)) + '''' + ')'
	       END     
	 EXEC (@SQL1)
     END 

	 IF (@BlueLaw1ysn  IS NOT NULL)
     BEGIN

	       SET @SQL1 =  'INSERT INTO tblSTMassUpdateReportMaster(strLocationName,UpcCode,ItemDescription,
				               ChangeDescription,OldData,NewData)
							   select c.strLocationName, b.strUpcCode, 
							   d.strDescription, ''Blue Law1'',
							   case when a.ysnApplyBlueLaw1 = 0 then ''No'' else ''Yes'' end,
							   ''' + case when @BlueLaw1ysn = 0 then 'No' else 'Yes' end +'''
							   from tblICItemLocation a JOIN 
							   tblICItemUOM b ON a.intItemId = b.intItemId JOIN
							   tblSMCompanyLocation c ON a.intLocationId = c.intCompanyLocationId JOIN
							   tblICItem d ON a.intItemId = d.intItemId '

           SET @SQL1 = @SQL1 + ' where 1=1 ' 

	       IF (@Location IS NOT NULL)
	       BEGIN 
		        SET @SQL1 = @SQL1 + ' and c.intCompanyLocationId IN (' + CAST(@Location as NVARCHAR) + ')'
		   END
			 
	       IF (@Vendor IS NOT NULL)
	       BEGIN 
               SET @SQL1 = @SQL1 + ' and a.intVendorId IN (' + CAST(@Vendor as NVARCHAR) + ')'
		   END

           IF (@Category IS NOT NULL)
	       BEGIN
                SET @SQL1 = @SQL1 +  ' and a.intItemId  
		          IN (select intItemId from tblICItem where intCategoryId IN
		          (select intCategoryId from tblICCategory where intCategoryId 
				 IN (' + CAST(@Category as NVARCHAR) + ')' + '))'
		   END

           IF (@Family IS NOT NULL)
		   BEGIN
  		         SET @SQL1 = @SQL1 + ' and  a.intFamilyId IN (' + CAST(@Family as NVARCHAR) + ')'
		   END

           IF (@Class IS NOT NULL)
		   BEGIN
  		         SET @SQL1 = @SQL1 + ' and  a.intClassId IN (' + CAST(@Class as NVARCHAR) + ')'
		   END
		    
	       IF (@UpcCode IS NOT NULL)
   	       BEGIN
			   SET @SQL1 = @SQL1 + ' and b.intItemUOMId IN (' + CAST(@UpcCode as NVARCHAR) + ')'
		   END

           IF ((@Description IS NOT NULL)
	       and (@Description != ''))
	       BEGIN
   		        SET @SQL1 = @SQL1 +  ' and  d.strDescription like ''%' + LTRIM(@Description) + '%'' '
           END

           IF (@PriceBetween1 IS NOT NULL) 
	       BEGIN
			      set @SQL1 = @SQL1 +  ' and a.intItemId IN 
					   (select intItemId from tblICItemPricing where dblSalePrice >= 
					   ''' + CONVERT(NVARCHAR,(@PriceBetween1)) + '''' + ')'
	       END 
		      
           IF (@PriceBetween2 IS NOT NULL) 
	       BEGIN
			        set @SQL1 = @SQL1 +  ' and a.intItemId IN 
					   (select intItemId from tblICItemPricing where dblSalePrice <= 
					   ''' + CONVERT(NVARCHAR,(@PriceBetween2)) + '''' + ')'
	       END     
	 EXEC (@SQL1)
     END 
 

	 IF (@BlueLaw2ysn  IS NOT NULL)
     BEGIN

	       SET @SQL1 =  'INSERT INTO tblSTMassUpdateReportMaster(strLocationName,UpcCode,ItemDescription,
				               ChangeDescription,OldData,NewData)
							   select c.strLocationName, b.strUpcCode, 
							   d.strDescription, ''Blue Law2'',
							   case when a.ysnApplyBlueLaw2 = 0 then ''No'' else ''Yes'' end,
							   ''' + case when @BlueLaw2ysn = 0 then 'No' else 'Yes' end +'''
							   from tblICItemLocation a JOIN 
							   tblICItemUOM b ON a.intItemId = b.intItemId JOIN
							   tblSMCompanyLocation c ON a.intLocationId = c.intCompanyLocationId JOIN
							   tblICItem d ON a.intItemId = d.intItemId '

           SET @SQL1 = @SQL1 + ' where 1=1 ' 

	       IF (@Location IS NOT NULL)
	       BEGIN 
		        SET @SQL1 = @SQL1 + ' and c.intCompanyLocationId IN (' + CAST(@Location as NVARCHAR) + ')'
		   END
			 
	       IF (@Vendor IS NOT NULL)
	       BEGIN 
               SET @SQL1 = @SQL1 + ' and a.intVendorId IN (' + CAST(@Vendor as NVARCHAR) + ')'
		   END

           IF (@Category IS NOT NULL)
	       BEGIN
                SET @SQL1 = @SQL1 +  ' and a.intItemId  
		          IN (select intItemId from tblICItem where intCategoryId IN
		          (select intCategoryId from tblICCategory where intCategoryId 
				 IN (' + CAST(@Category as NVARCHAR) + ')' + '))'
		   END

           IF (@Family IS NOT NULL)
		   BEGIN
  		         SET @SQL1 = @SQL1 + ' and  a.intFamilyId IN (' + CAST(@Family as NVARCHAR) + ')'
		   END

           IF (@Class IS NOT NULL)
		   BEGIN
  		         SET @SQL1 = @SQL1 + ' and  a.intClassId IN (' + CAST(@Class as NVARCHAR) + ')'
		   END
		    
	       IF (@UpcCode IS NOT NULL)
   	       BEGIN
			   SET @SQL1 = @SQL1 + ' and b.intItemUOMId IN (' + CAST(@UpcCode as NVARCHAR) + ')'
		   END

           IF ((@Description IS NOT NULL)
	       and (@Description != ''))
	       BEGIN
   		        SET @SQL1 = @SQL1 +  ' and  d.strDescription like ''%' + LTRIM(@Description) + '%'' '
           END

           IF (@PriceBetween1 IS NOT NULL) 
	       BEGIN
			      set @SQL1 = @SQL1 +  ' and a.intItemId IN 
					   (select intItemId from tblICItemPricing where dblSalePrice >= 
					   ''' + CONVERT(NVARCHAR,(@PriceBetween1)) + '''' + ')'
	       END 
		      
           IF (@PriceBetween2 IS NOT NULL) 
	       BEGIN
			        set @SQL1 = @SQL1 +  ' and a.intItemId IN 
					   (select intItemId from tblICItemPricing where dblSalePrice <= 
					   ''' + CONVERT(NVARCHAR,(@PriceBetween2)) + '''' + ')'
	       END     
	 EXEC (@SQL1)
     END 

	 IF (@CountedDailyysn  IS NOT NULL)
     BEGIN

	       SET @SQL1 =  'INSERT INTO tblSTMassUpdateReportMaster(strLocationName,UpcCode,ItemDescription,
				               ChangeDescription,OldData,NewData)
							   select c.strLocationName, b.strUpcCode, 
							   d.strDescription, ''Counted Daily'',
							   case when a.ysnCountedDaily = 0 then ''No'' else ''Yes'' end,
							   ''' + case when @CountedDailyysn = 0 then 'No' else 'Yes' end +'''
							   from tblICItemLocation a JOIN 
							   tblICItemUOM b ON a.intItemId = b.intItemId JOIN
							   tblSMCompanyLocation c ON a.intLocationId = c.intCompanyLocationId JOIN
							   tblICItem d ON a.intItemId = d.intItemId '

           SET @SQL1 = @SQL1 + ' where 1=1 ' 

	       IF (@Location IS NOT NULL)
	       BEGIN 
		        SET @SQL1 = @SQL1 + ' and c.intCompanyLocationId IN (' + CAST(@Location as NVARCHAR) + ')'
		   END
			 
	       IF (@Vendor IS NOT NULL)
	       BEGIN 
               SET @SQL1 = @SQL1 + ' and a.intVendorId IN (' + CAST(@Vendor as NVARCHAR) + ')'
		   END

           IF (@Category IS NOT NULL)
	       BEGIN
                SET @SQL1 = @SQL1 +  ' and a.intItemId  
		          IN (select intItemId from tblICItem where intCategoryId IN
		          (select intCategoryId from tblICCategory where intCategoryId 
				 IN (' + CAST(@Category as NVARCHAR) + ')' + '))'
		   END

           IF (@Family IS NOT NULL)
		   BEGIN
  		         SET @SQL1 = @SQL1 + ' and  a.intFamilyId IN (' + CAST(@Family as NVARCHAR) + ')'
		   END

           IF (@Class IS NOT NULL)
		   BEGIN
  		         SET @SQL1 = @SQL1 + ' and  a.intClassId IN (' + CAST(@Class as NVARCHAR) + ')'
		   END
		    
	       IF (@UpcCode IS NOT NULL)
   	       BEGIN
			   SET @SQL1 = @SQL1 + ' and b.intItemUOMId IN (' + CAST(@UpcCode as NVARCHAR) + ')'
		   END

           IF ((@Description IS NOT NULL)
	       and (@Description != ''))
	       BEGIN
   		        SET @SQL1 = @SQL1 +  ' and  d.strDescription like ''%' + LTRIM(@Description) + '%'' '
           END

           IF (@PriceBetween1 IS NOT NULL) 
	       BEGIN
			      set @SQL1 = @SQL1 +  ' and a.intItemId IN 
					   (select intItemId from tblICItemPricing where dblSalePrice >= 
					   ''' + CONVERT(NVARCHAR,(@PriceBetween1)) + '''' + ')'
	       END 
		      
           IF (@PriceBetween2 IS NOT NULL) 
	       BEGIN
			        set @SQL1 = @SQL1 +  ' and a.intItemId IN 
					   (select intItemId from tblICItemPricing where dblSalePrice <= 
					   ''' + CONVERT(NVARCHAR,(@PriceBetween2)) + '''' + ')'
	       END     
	 EXEC (@SQL1)
     END 
 
	 IF (@Counted  IS NOT NULL)
     BEGIN

	       SET @SQL1 =  'INSERT INTO tblSTMassUpdateReportMaster(strLocationName,UpcCode,ItemDescription,
				               ChangeDescription,OldData,NewData)
							   select c.strLocationName, b.strUpcCode, 
							   d.strDescription, ''Counted '', a.strCounted, 
							   ''' + CAST(@Counted AS NVARCHAR(250))  +'''
							   from tblICItemLocation a JOIN 
							   tblICItemUOM b ON a.intItemId = b.intItemId JOIN
							   tblSMCompanyLocation c ON a.intLocationId = c.intCompanyLocationId JOIN
							   tblICItem d ON a.intItemId = d.intItemId '

           SET @SQL1 = @SQL1 + ' where 1=1 ' 

	       IF (@Location IS NOT NULL)
	       BEGIN 
		        SET @SQL1 = @SQL1 + ' and c.intCompanyLocationId IN (' + CAST(@Location as NVARCHAR) + ')'
		   END
			 
	       IF (@Vendor IS NOT NULL)
	       BEGIN 
               SET @SQL1 = @SQL1 + ' and a.intVendorId IN (' + CAST(@Vendor as NVARCHAR) + ')'
		   END

           IF (@Category IS NOT NULL)
	       BEGIN
                SET @SQL1 = @SQL1 +  ' and a.intItemId  
		          IN (select intItemId from tblICItem where intCategoryId IN
		          (select intCategoryId from tblICCategory where intCategoryId 
				 IN (' + CAST(@Category as NVARCHAR) + ')' + '))'
		   END

           IF (@Family IS NOT NULL)
		   BEGIN
  		         SET @SQL1 = @SQL1 + ' and  a.intFamilyId IN (' + CAST(@Family as NVARCHAR) + ')'
		   END

           IF (@Class IS NOT NULL)
		   BEGIN
  		         SET @SQL1 = @SQL1 + ' and  a.intClassId IN (' + CAST(@Class as NVARCHAR) + ')'
		   END
		    
	       IF (@UpcCode IS NOT NULL)
   	       BEGIN
			   SET @SQL1 = @SQL1 + ' and b.intItemUOMId IN (' + CAST(@UpcCode as NVARCHAR) + ')'
		   END

           IF ((@Description IS NOT NULL)
	       and (@Description != ''))
	       BEGIN
   		        SET @SQL1 = @SQL1 +  ' and  d.strDescription like ''%' + LTRIM(@Description) + '%'' '
           END

           IF (@PriceBetween1 IS NOT NULL) 
	       BEGIN
			      set @SQL1 = @SQL1 +  ' and a.intItemId IN 
					   (select intItemId from tblICItemPricing where dblSalePrice >= 
					   ''' + CONVERT(NVARCHAR,(@PriceBetween1)) + '''' + ')'
	       END 
		      
           IF (@PriceBetween2 IS NOT NULL) 
	       BEGIN
			        set @SQL1 = @SQL1 +  ' and a.intItemId IN 
					   (select intItemId from tblICItemPricing where dblSalePrice <= 
					   ''' + CONVERT(NVARCHAR,(@PriceBetween2)) + '''' + ')'
	       END     
	 EXEC (@SQL1)
     END 

	 IF (@CountSerialysn  IS NOT NULL)
     BEGIN

	       SET @SQL1 =  'INSERT INTO tblSTMassUpdateReportMaster(strLocationName,UpcCode,ItemDescription,
				               ChangeDescription,OldData,NewData)
							   select c.strLocationName, b.strUpcCode, 
							   d.strDescription, ''Count By Serial No'',
							   case when a.ysnCountBySINo = 0 then ''No'' else ''Yes'' end,
							   ''' + case when @CountSerialysn = 0 then 'No' else 'Yes' end +'''
							   from tblICItemLocation a JOIN 
							   tblICItemUOM b ON a.intItemId = b.intItemId JOIN
							   tblSMCompanyLocation c ON a.intLocationId = c.intCompanyLocationId JOIN
							   tblICItem d ON a.intItemId = d.intItemId '

           SET @SQL1 = @SQL1 + ' where 1=1 ' 

	       IF (@Location IS NOT NULL)
	       BEGIN 
		        SET @SQL1 = @SQL1 + ' and c.intCompanyLocationId IN (' + CAST(@Location as NVARCHAR) + ')'
		   END
			 
	       IF (@Vendor IS NOT NULL)
	       BEGIN 
               SET @SQL1 = @SQL1 + ' and a.intVendorId IN (' + CAST(@Vendor as NVARCHAR) + ')'
		   END

           IF (@Category IS NOT NULL)
	       BEGIN
                SET @SQL1 = @SQL1 +  ' and a.intItemId  
		          IN (select intItemId from tblICItem where intCategoryId IN
		          (select intCategoryId from tblICCategory where intCategoryId 
				 IN (' + CAST(@Category as NVARCHAR) + ')' + '))'
		   END

           IF (@Family IS NOT NULL)
		   BEGIN
  		         SET @SQL1 = @SQL1 + ' and  a.intFamilyId IN (' + CAST(@Family as NVARCHAR) + ')'
		   END

           IF (@Class IS NOT NULL)
		   BEGIN
  		         SET @SQL1 = @SQL1 + ' and  a.intClassId IN (' + CAST(@Class as NVARCHAR) + ')'
		   END
		    
	       IF (@UpcCode IS NOT NULL)
   	       BEGIN
			   SET @SQL1 = @SQL1 + ' and b.intItemUOMId IN (' + CAST(@UpcCode as NVARCHAR) + ')'
		   END

           IF ((@Description IS NOT NULL)
	       and (@Description != ''))
	       BEGIN
   		        SET @SQL1 = @SQL1 +  ' and  d.strDescription like ''%' + LTRIM(@Description) + '%'' '
           END

           IF (@PriceBetween1 IS NOT NULL) 
	       BEGIN
			      set @SQL1 = @SQL1 +  ' and a.intItemId IN 
					   (select intItemId from tblICItemPricing where dblSalePrice >= 
					   ''' + CONVERT(NVARCHAR,(@PriceBetween1)) + '''' + ')'
	       END 
		      
           IF (@PriceBetween2 IS NOT NULL) 
	       BEGIN
			        set @SQL1 = @SQL1 +  ' and a.intItemId IN 
					   (select intItemId from tblICItemPricing where dblSalePrice <= 
					   ''' + CONVERT(NVARCHAR,(@PriceBetween2)) + '''' + ')'
	       END     
	 EXEC (@SQL1)
     END 
 
	 IF (@NewFamily  IS NOT NULL)
     BEGIN
	        
           SELECT @FamilyId = strSubcategoryId from tblSTSubcategory where intSubcategoryId = @NewFamily  

	       SET @SQL1 =  'INSERT INTO tblSTMassUpdateReportMaster(strLocationName,UpcCode,ItemDescription,
				               ChangeDescription,OldData,NewData)
							   select c.strLocationName, b.strUpcCode, 
							   d.strDescription, ''Family '', 
							   ( select strSubcategoryId from tblSTSubcategory where intSubcategoryId = a.intFamilyId ),
							   ''' + @FamilyId +'''
							   from tblICItemLocation a JOIN 
							   tblICItemUOM b ON a.intItemId = b.intItemId JOIN
							   tblSMCompanyLocation c ON a.intLocationId = c.intCompanyLocationId JOIN
							   tblICItem d ON a.intItemId = d.intItemId '

           SET @SQL1 = @SQL1 + ' where 1=1 ' 

	       IF (@Location IS NOT NULL)
	       BEGIN 
		        SET @SQL1 = @SQL1 + ' and c.intCompanyLocationId IN (' + CAST(@Location as NVARCHAR) + ')'
		   END
			 
	       IF (@Vendor IS NOT NULL)
	       BEGIN 
               SET @SQL1 = @SQL1 + ' and a.intVendorId IN (' + CAST(@Vendor as NVARCHAR) + ')'
		   END

           IF (@Category IS NOT NULL)
	       BEGIN
                SET @SQL1 = @SQL1 +  ' and a.intItemId  
		          IN (select intItemId from tblICItem where intCategoryId IN
		          (select intCategoryId from tblICCategory where intCategoryId 
				 IN (' + CAST(@Category as NVARCHAR) + ')' + '))'
		   END

           IF (@Family IS NOT NULL)
		   BEGIN
  		         SET @SQL1 = @SQL1 + ' and  a.intFamilyId IN (' + CAST(@Family as NVARCHAR) + ')'
		   END

           IF (@Class IS NOT NULL)
		   BEGIN
  		         SET @SQL1 = @SQL1 + ' and  a.intClassId IN (' + CAST(@Class as NVARCHAR) + ')'
		   END
		    
	       IF (@UpcCode IS NOT NULL)
   	       BEGIN
			   SET @SQL1 = @SQL1 + ' and b.intItemUOMId IN (' + CAST(@UpcCode as NVARCHAR) + ')'
		   END

           IF ((@Description IS NOT NULL)
	       and (@Description != ''))
	       BEGIN
   		        SET @SQL1 = @SQL1 +  ' and  d.strDescription like ''%' + LTRIM(@Description) + '%'' '
           END

           IF (@PriceBetween1 IS NOT NULL) 
	       BEGIN
			      set @SQL1 = @SQL1 +  ' and a.intItemId IN 
					   (select intItemId from tblICItemPricing where dblSalePrice >= 
					   ''' + CONVERT(NVARCHAR,(@PriceBetween1)) + '''' + ')'
	       END 
		      
           IF (@PriceBetween2 IS NOT NULL) 
	       BEGIN
			        set @SQL1 = @SQL1 +  ' and a.intItemId IN 
					   (select intItemId from tblICItemPricing where dblSalePrice <= 
					   ''' + CONVERT(NVARCHAR,(@PriceBetween2)) + '''' + ')'
	       END
     EXEC (@SQL1)     
     END 
 

	 IF (@NewClass  IS NOT NULL)
     BEGIN
	       
		   SELECT @ClassId = strSubcategoryId from tblSTSubcategory where intSubcategoryId = @NewClass

	       SET @SQL1 =  'INSERT INTO tblSTMassUpdateReportMaster(strLocationName,UpcCode,ItemDescription,
				               ChangeDescription,OldData,NewData)
							   select c.strLocationName, b.strUpcCode, 
							   d.strDescription, ''Class '',
							   ( select strSubcategoryId from tblSTSubcategory where intSubcategoryId = a.intClassId ),
							   ''' + @ClassId  +'''
							   from tblICItemLocation a JOIN 
							   tblICItemUOM b ON a.intItemId = b.intItemId JOIN
							   tblSMCompanyLocation c ON a.intLocationId = c.intCompanyLocationId JOIN
							   tblICItem d ON a.intItemId = d.intItemId JOIN 
							   tblSTSubcategory e ON a.intFamilyId = e.intSubcategoryId'

           SET @SQL1 = @SQL1 + ' where 1=1 ' 

	       IF (@Location IS NOT NULL)
	       BEGIN 
		        SET @SQL1 = @SQL1 + ' and c.intCompanyLocationId IN (' + CAST(@Location as NVARCHAR) + ')'
		   END
			 
	       IF (@Vendor IS NOT NULL)
	       BEGIN 
               SET @SQL1 = @SQL1 + ' and a.intVendorId IN (' + CAST(@Vendor as NVARCHAR) + ')'
		   END

           IF (@Category IS NOT NULL)
	       BEGIN
                SET @SQL1 = @SQL1 +  ' and a.intItemId  
		          IN (select intItemId from tblICItem where intCategoryId IN
		          (select intCategoryId from tblICCategory where intCategoryId 
				 IN (' + CAST(@Category as NVARCHAR) + ')' + '))'
		   END

           IF (@Family IS NOT NULL)
		   BEGIN
  		         SET @SQL1 = @SQL1 + ' and  a.intFamilyId IN (' + CAST(@Family as NVARCHAR) + ')'
		   END

           IF (@Class IS NOT NULL)
		   BEGIN
  		         SET @SQL1 = @SQL1 + ' and  a.intClassId IN (' + CAST(@Class as NVARCHAR) + ')'
		   END
		    
	       IF (@UpcCode IS NOT NULL)
   	       BEGIN
			   SET @SQL1 = @SQL1 + ' and b.intItemUOMId IN (' + CAST(@UpcCode as NVARCHAR) + ')'
		   END

           IF ((@Description IS NOT NULL)
	       and (@Description != ''))
	       BEGIN
   		        SET @SQL1 = @SQL1 +  ' and  d.strDescription like ''%' + LTRIM(@Description) + '%'' '
           END

           IF (@PriceBetween1 IS NOT NULL) 
	       BEGIN
			      set @SQL1 = @SQL1 +  ' and a.intItemId IN 
					   (select intItemId from tblICItemPricing where dblSalePrice >= 
					   ''' + CONVERT(NVARCHAR,(@PriceBetween1)) + '''' + ')'
	       END 
		      
           IF (@PriceBetween2 IS NOT NULL) 
	       BEGIN
			        set @SQL1 = @SQL1 +  ' and a.intItemId IN 
					   (select intItemId from tblICItemPricing where dblSalePrice <= 
					   ''' + CONVERT(NVARCHAR,(@PriceBetween2)) + '''' + ')'
	       END    
	 EXEC (@SQL1) 
     END 
 

	 IF (@NewProductCode  IS NOT NULL)
     BEGIN
	  
           SELECT @ProductCode = strRegProdCode from tblSTSubcategoryRegProd where intRegProdId = @NewProductCode
		     
           SET @SQL1 =  'INSERT INTO tblSTMassUpdateReportMaster(strLocationName,UpcCode,ItemDescription,
				               ChangeDescription,OldData,NewData)
							   select c.strLocationName, b.strUpcCode, 
							   d.strDescription, ''Product Code '', 
							   ( select strRegProdCode from tblSTSubcategoryRegProd where intRegProdId = a.intProductCodeId ),
							   ''' + @ProductCode +'''
							   from tblICItemLocation a JOIN 
							   tblICItemUOM b ON a.intItemId = b.intItemId JOIN
							   tblSMCompanyLocation c ON a.intLocationId = c.intCompanyLocationId JOIN
							   tblICItem d ON a.intItemId = d.intItemId '
							   

           SET @SQL1 = @SQL1 + ' where 1=1 ' 

	       IF (@Location IS NOT NULL)
	       BEGIN 
		        SET @SQL1 = @SQL1 + ' and c.intCompanyLocationId IN (' + CAST(@Location as NVARCHAR) + ')'
		   END
			 
	       IF (@Vendor IS NOT NULL)
	       BEGIN 
               SET @SQL1 = @SQL1 + ' and a.intVendorId IN (' + CAST(@Vendor as NVARCHAR) + ')'
		   END

           IF (@Category IS NOT NULL)
	       BEGIN
                SET @SQL1 = @SQL1 +  ' and a.intItemId  
		          IN (select intItemId from tblICItem where intCategoryId IN
		          (select intCategoryId from tblICCategory where intCategoryId 
				 IN (' + CAST(@Category as NVARCHAR) + ')' + '))'
		   END

           IF (@Family IS NOT NULL)
		   BEGIN
  		         SET @SQL1 = @SQL1 + ' and  a.intFamilyId IN (' + CAST(@Family as NVARCHAR) + ')'
		   END

           IF (@Class IS NOT NULL)
		   BEGIN
  		         SET @SQL1 = @SQL1 + ' and  a.intClassId IN (' + CAST(@Class as NVARCHAR) + ')'
		   END
		    
	       IF (@UpcCode IS NOT NULL)
   	       BEGIN
			   SET @SQL1 = @SQL1 + ' and b.intItemUOMId IN (' + CAST(@UpcCode as NVARCHAR) + ')'
		   END

           IF ((@Description IS NOT NULL)
	       and (@Description != ''))
	       BEGIN
   		        SET @SQL1 = @SQL1 +  ' and  d.strDescription like ''%' + LTRIM(@Description) + '%'' '
           END

           IF (@PriceBetween1 IS NOT NULL) 
	       BEGIN
			      set @SQL1 = @SQL1 +  ' and a.intItemId IN 
					   (select intItemId from tblICItemPricing where dblSalePrice >= 
					   ''' + CONVERT(NVARCHAR,(@PriceBetween1)) + '''' + ')'
	       END 
		      
           IF (@PriceBetween2 IS NOT NULL) 
	       BEGIN
			        set @SQL1 = @SQL1 +  ' and a.intItemId IN 
					   (select intItemId from tblICItemPricing where dblSalePrice <= 
					   ''' + CONVERT(NVARCHAR,(@PriceBetween2)) + '''' + ')'
	       END      
	 EXEC (@SQL1)
     END 

	 IF (@NewVendor  IS NOT NULL)
     BEGIN
	       
		    SELECT @VendorId = strName from tblEntity where intEntityId = @NewVendor

            SET @SQL1 =  'INSERT INTO tblSTMassUpdateReportMaster(strLocationName,UpcCode,ItemDescription,
				               ChangeDescription,OldData,NewData)
							   select c.strLocationName, b.strUpcCode, 
							   d.strDescription, ''Vendor '', 
							   ( select strName from tblEntity where intEntityId = a.intVendorId ),
							   ''' + @VendorId +'''
							   from tblICItemLocation a JOIN 
							   tblICItemUOM b ON a.intItemId = b.intItemId JOIN
							   tblSMCompanyLocation c ON a.intLocationId = c.intCompanyLocationId JOIN
							   tblICItem d ON a.intItemId = d.intItemId '

           SET @SQL1 = @SQL1 + ' where 1=1 ' 

	       IF (@Location IS NOT NULL)
	       BEGIN 
		        SET @SQL1 = @SQL1 + ' and c.intCompanyLocationId IN (' + CAST(@Location as NVARCHAR) + ')'
		   END
			 
	       IF (@Vendor IS NOT NULL)
	       BEGIN 
               SET @SQL1 = @SQL1 + ' and a.intVendorId IN (' + CAST(@Vendor as NVARCHAR) + ')'
		   END

           IF (@Category IS NOT NULL)
	       BEGIN
                SET @SQL1 = @SQL1 +  ' and a.intItemId  
		          IN (select intItemId from tblICItem where intCategoryId IN
		          (select intCategoryId from tblICCategory where intCategoryId 
				 IN (' + CAST(@Category as NVARCHAR) + ')' + '))'
		   END

           IF (@Family IS NOT NULL)
		   BEGIN
  		         SET @SQL1 = @SQL1 + ' and  a.intFamilyId IN (' + CAST(@Family as NVARCHAR) + ')'
		   END

           IF (@Class IS NOT NULL)
		   BEGIN
  		         SET @SQL1 = @SQL1 + ' and  a.intClassId IN (' + CAST(@Class as NVARCHAR) + ')'
		   END
		    
	       IF (@UpcCode IS NOT NULL)
   	       BEGIN
			   SET @SQL1 = @SQL1 + ' and b.intItemUOMId IN (' + CAST(@UpcCode as NVARCHAR) + ')'
		   END

           IF ((@Description IS NOT NULL)
	       and (@Description != ''))
	       BEGIN
   		        SET @SQL1 = @SQL1 +  ' and  d.strDescription like ''%' + LTRIM(@Description) + '%'' '
           END

           IF (@PriceBetween1 IS NOT NULL) 
	       BEGIN
			      set @SQL1 = @SQL1 +  ' and a.intItemId IN 
					   (select intItemId from tblICItemPricing where dblSalePrice >= 
					   ''' + CONVERT(NVARCHAR,(@PriceBetween1)) + '''' + ')'
	       END 
		      
           IF (@PriceBetween2 IS NOT NULL) 
	       BEGIN
			        set @SQL1 = @SQL1 +  ' and a.intItemId IN 
					   (select intItemId from tblICItemPricing where dblSalePrice <= 
					   ''' + CONVERT(NVARCHAR,(@PriceBetween2)) + '''' + ')'
	       END     
	 EXEC (@SQL1)
     END 
 

	 IF (@NewMinAge  IS NOT NULL)
     BEGIN

	       SET @SQL1 =  'INSERT INTO tblSTMassUpdateReportMaster(strLocationName,UpcCode,ItemDescription,
				               ChangeDescription,OldData,NewData)
							   select c.strLocationName, b.strUpcCode, 
							   d.strDescription, ''Minimum Age '', a.intMinimumAge, 
							   ''' + CAST(@NewMinAge AS NVARCHAR(250))  +'''
							   from tblICItemLocation a JOIN 
							   tblICItemUOM b ON a.intItemId = b.intItemId JOIN
							   tblSMCompanyLocation c ON a.intLocationId = c.intCompanyLocationId JOIN
							   tblICItem d ON a.intItemId = d.intItemId '

           SET @SQL1 = @SQL1 + ' where 1=1 ' 

	       IF (@Location IS NOT NULL)
	       BEGIN 
		        SET @SQL1 = @SQL1 + ' and c.intCompanyLocationId IN (' + CAST(@Location as NVARCHAR) + ')'
		   END
			 
	       IF (@Vendor IS NOT NULL)
	       BEGIN 
               SET @SQL1 = @SQL1 + ' and a.intVendorId IN (' + CAST(@Vendor as NVARCHAR) + ')'
		   END

           IF (@Category IS NOT NULL)
	       BEGIN
                SET @SQL1 = @SQL1 +  ' and a.intItemId  
		          IN (select intItemId from tblICItem where intCategoryId IN
		          (select intCategoryId from tblICCategory where intCategoryId 
				 IN (' + CAST(@Category as NVARCHAR) + ')' + '))'
		   END

           IF (@Family IS NOT NULL)
		   BEGIN
  		         SET @SQL1 = @SQL1 + ' and  a.intFamilyId IN (' + CAST(@Family as NVARCHAR) + ')'
		   END

           IF (@Class IS NOT NULL)
		   BEGIN
  		         SET @SQL1 = @SQL1 + ' and  a.intClassId IN (' + CAST(@Class as NVARCHAR) + ')'
		   END
		    
	       IF (@UpcCode IS NOT NULL)
   	       BEGIN
			   SET @SQL1 = @SQL1 + ' and b.intItemUOMId IN (' + CAST(@UpcCode as NVARCHAR) + ')'
		   END

           IF ((@Description IS NOT NULL)
	       and (@Description != ''))
	       BEGIN
   		        SET @SQL1 = @SQL1 +  ' and  d.strDescription like ''%' + LTRIM(@Description) + '%'' '
           END

           IF (@PriceBetween1 IS NOT NULL) 
	       BEGIN
			      set @SQL1 = @SQL1 +  ' and a.intItemId IN 
					   (select intItemId from tblICItemPricing where dblSalePrice >= 
					   ''' + CONVERT(NVARCHAR,(@PriceBetween1)) + '''' + ')'
	       END 
		      
           IF (@PriceBetween2 IS NOT NULL) 
	       BEGIN
			        set @SQL1 = @SQL1 +  ' and a.intItemId IN 
					   (select intItemId from tblICItemPricing where dblSalePrice <= 
					   ''' + CONVERT(NVARCHAR,(@PriceBetween2)) + '''' + ')'
	       END     
	 EXEC (@SQL1)
     END 

	 IF (@NewMinVendorOrderQty  IS NOT NULL)
     BEGIN

	       SET @SQL1 =  'INSERT INTO tblSTMassUpdateReportMaster(strLocationName,UpcCode,ItemDescription,
				               ChangeDescription,OldData,NewData)
							   select c.strLocationName, b.strUpcCode, 
							   d.strDescription, ''Vendor Minimum Order Qty'', a.dblMinOrder, 
							   ''' + CAST(@NewMinVendorOrderQty AS NVARCHAR(250))  +'''
							   from tblICItemLocation a JOIN 
							   tblICItemUOM b ON a.intItemId = b.intItemId JOIN
							   tblSMCompanyLocation c ON a.intLocationId = c.intCompanyLocationId JOIN
							   tblICItem d ON a.intItemId = d.intItemId '

           SET @SQL1 = @SQL1 + ' where 1=1 ' 

	       IF (@Location IS NOT NULL)
	       BEGIN 
		        SET @SQL1 = @SQL1 + ' and c.intCompanyLocationId IN (' + CAST(@Location as NVARCHAR) + ')'
		   END
			 
	       IF (@Vendor IS NOT NULL)
	       BEGIN 
               SET @SQL1 = @SQL1 + ' and a.intVendorId IN (' + CAST(@Vendor as NVARCHAR) + ')'
		   END

           IF (@Category IS NOT NULL)
	       BEGIN
                SET @SQL1 = @SQL1 +  ' and a.intItemId  
		          IN (select intItemId from tblICItem where intCategoryId IN
		          (select intCategoryId from tblICCategory where intCategoryId 
				 IN (' + CAST(@Category as NVARCHAR) + ')' + '))'
		   END

           IF (@Family IS NOT NULL)
		   BEGIN
  		         SET @SQL1 = @SQL1 + ' and  a.intFamilyId IN (' + CAST(@Family as NVARCHAR) + ')'
		   END

           IF (@Class IS NOT NULL)
		   BEGIN
  		         SET @SQL1 = @SQL1 + ' and  a.intClassId IN (' + CAST(@Class as NVARCHAR) + ')'
		   END
		    
	       IF (@UpcCode IS NOT NULL)
   	       BEGIN
			   SET @SQL1 = @SQL1 + ' and b.intItemUOMId IN (' + CAST(@UpcCode as NVARCHAR) + ')'
		   END

           IF ((@Description IS NOT NULL)
	       and (@Description != ''))
	       BEGIN
   		        SET @SQL1 = @SQL1 +  ' and  d.strDescription like ''%' + LTRIM(@Description) + '%'' '
           END

           IF (@PriceBetween1 IS NOT NULL) 
	       BEGIN
			      set @SQL1 = @SQL1 +  ' and a.intItemId IN 
					   (select intItemId from tblICItemPricing where dblSalePrice >= 
					   ''' + CONVERT(NVARCHAR,(@PriceBetween1)) + '''' + ')'
	       END 
		      
           IF (@PriceBetween2 IS NOT NULL) 
	       BEGIN
			        set @SQL1 = @SQL1 +  ' and a.intItemId IN 
					   (select intItemId from tblICItemPricing where dblSalePrice <= 
					   ''' + CONVERT(NVARCHAR,(@PriceBetween2)) + '''' + ')'
	       END    
     EXEC (@SQL1)		    
     END 

	 IF (@NewVendorSuggestedQty  IS NOT NULL)
     BEGIN

	       SET @SQL1 =  'INSERT INTO tblSTMassUpdateReportMaster(strLocationName,UpcCode,ItemDescription,
				               ChangeDescription,OldData,NewData)
							   select c.strLocationName, b.strUpcCode, 
							   d.strDescription, ''Vendor Suggested Qty'', a.dblSuggestedQty, 
							   ''' + CAST(@NewVendorSuggestedQty AS NVARCHAR(250))  +'''
							   from tblICItemLocation a JOIN 
							   tblICItemUOM b ON a.intItemId = b.intItemId JOIN
							   tblSMCompanyLocation c ON a.intLocationId = c.intCompanyLocationId JOIN
							   tblICItem d ON a.intItemId = d.intItemId '

           SET @SQL1 = @SQL1 + ' where 1=1 ' 

	       IF (@Location IS NOT NULL)
	       BEGIN 
		        SET @SQL1 = @SQL1 + ' and c.intCompanyLocationId IN (' + CAST(@Location as NVARCHAR) + ')'
		   END
			 
	       IF (@Vendor IS NOT NULL)
	       BEGIN 
               SET @SQL1 = @SQL1 + ' and a.intVendorId IN (' + CAST(@Vendor as NVARCHAR) + ')'
		   END

           IF (@Category IS NOT NULL)
	       BEGIN
                SET @SQL1 = @SQL1 +  ' and a.intItemId  
		          IN (select intItemId from tblICItem where intCategoryId IN
		          (select intCategoryId from tblICCategory where intCategoryId 
				 IN (' + CAST(@Category as NVARCHAR) + ')' + '))'
		   END

           IF (@Family IS NOT NULL)
		   BEGIN
  		         SET @SQL1 = @SQL1 + ' and  a.intFamilyId IN (' + CAST(@Family as NVARCHAR) + ')'
		   END

           IF (@Class IS NOT NULL)
		   BEGIN
  		         SET @SQL1 = @SQL1 + ' and  a.intClassId IN (' + CAST(@Class as NVARCHAR) + ')'
		   END
		    
	       IF (@UpcCode IS NOT NULL)
   	       BEGIN
			   SET @SQL1 = @SQL1 + ' and b.intItemUOMId IN (' + CAST(@UpcCode as NVARCHAR) + ')'
		   END

           IF ((@Description IS NOT NULL)
	       and (@Description != ''))
	       BEGIN
   		        SET @SQL1 = @SQL1 +  ' and  d.strDescription like ''%' + LTRIM(@Description) + '%'' '
           END

           IF (@PriceBetween1 IS NOT NULL) 
	       BEGIN
			      set @SQL1 = @SQL1 +  ' and a.intItemId IN 
					   (select intItemId from tblICItemPricing where dblSalePrice >= 
					   ''' + CONVERT(NVARCHAR,(@PriceBetween1)) + '''' + ')'
	       END 
		      
           IF (@PriceBetween2 IS NOT NULL) 
	       BEGIN
			        set @SQL1 = @SQL1 +  ' and a.intItemId IN 
					   (select intItemId from tblICItemPricing where dblSalePrice <= 
					   ''' + CONVERT(NVARCHAR,(@PriceBetween2)) + '''' + ')'
	       END     
	 EXEC (@SQL1)
     END 

	 IF (@NewInventoryGroup  IS NOT NULL)
     BEGIN

	       SELECT @NewInventoryCountGroupId = strCountGroup FROM tblICCountGroup WHERE intCountGroupId = @NewInventoryGroup

	       SET @SQL1 =  'INSERT INTO tblSTMassUpdateReportMaster(strLocationName,UpcCode,ItemDescription,
				               ChangeDescription,OldData,NewData)
							   select c.strLocationName, b.strUpcCode, 
							   d.strDescription, ''Inventory Group'', 
							   ( select strCountGroup from tblICCountGroup where intCountGroupId = a.intCountGroupId ),
							   ''' + CAST(@NewInventoryCountGroupId AS NVARCHAR(250))  +'''
							   from tblICItemLocation a JOIN 
							   tblICItemUOM b ON a.intItemId = b.intItemId JOIN
							   tblSMCompanyLocation c ON a.intLocationId = c.intCompanyLocationId JOIN
							   tblICItem d ON a.intItemId = d.intItemId '

           SET @SQL1 = @SQL1 + ' where 1=1 ' 

	       IF (@Location IS NOT NULL)
	       BEGIN 
		        SET @SQL1 = @SQL1 + ' and c.intCompanyLocationId IN (' + CAST(@Location as NVARCHAR) + ')'
		   END
			 
	       IF (@Vendor IS NOT NULL)
	       BEGIN 
               SET @SQL1 = @SQL1 + ' and a.intVendorId IN (' + CAST(@Vendor as NVARCHAR) + ')'
		   END

           IF (@Category IS NOT NULL)
	       BEGIN
                SET @SQL1 = @SQL1 +  ' and a.intItemId  
		          IN (select intItemId from tblICItem where intCategoryId IN
		          (select intCategoryId from tblICCategory where intCategoryId 
				 IN (' + CAST(@Category as NVARCHAR) + ')' + '))'
		   END

           IF (@Family IS NOT NULL)
		   BEGIN
  		         SET @SQL1 = @SQL1 + ' and  a.intFamilyId IN (' + CAST(@Family as NVARCHAR) + ')'
		   END

           IF (@Class IS NOT NULL)
		   BEGIN
  		         SET @SQL1 = @SQL1 + ' and  a.intClassId IN (' + CAST(@Class as NVARCHAR) + ')'
		   END
		    
	       IF (@UpcCode IS NOT NULL)
   	       BEGIN
			   SET @SQL1 = @SQL1 + ' and b.intItemUOMId IN (' + CAST(@UpcCode as NVARCHAR) + ')'
		   END

           IF ((@Description IS NOT NULL)
	       and (@Description != ''))
	       BEGIN
   		        SET @SQL1 = @SQL1 +  ' and  d.strDescription like ''%' + LTRIM(@Description) + '%'' '
           END

           IF (@PriceBetween1 IS NOT NULL) 
	       BEGIN
			      set @SQL1 = @SQL1 +  ' and a.intItemId IN 
					   (select intItemId from tblICItemPricing where dblSalePrice >= 
					   ''' + CONVERT(NVARCHAR,(@PriceBetween1)) + '''' + ')'
	       END 
		      
           IF (@PriceBetween2 IS NOT NULL) 
	       BEGIN
			        set @SQL1 = @SQL1 +  ' and a.intItemId IN 
					   (select intItemId from tblICItemPricing where dblSalePrice <= 
					   ''' + CONVERT(NVARCHAR,(@PriceBetween2)) + '''' + ')'
	       END     
	 EXEC (@SQL1)
     END 

	 SELECT @UpdateCount = count(*) from tblSTMassUpdateReportMaster 
   
END
     
SELECT @UpdateCount as UpdateItemDataCount	


END TRY

BEGIN CATCH       
	 SET @ErrMsg = ERROR_MESSAGE()      
	 IF @idoc <> 0 EXEC sp_xml_removedocument @idoc      
	 RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')      
END CATCH