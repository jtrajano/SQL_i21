CREATE PROCEDURE [dbo].[uspSTUpdateItemData]
		-- Add the parameters for the stored procedure here
		@XML varchar(max)
	
	AS
	BEGIN TRY
	    
        SET QUOTED_IDENTIFIER OFF
        SET ANSI_NULLS ON
        SET NOCOUNT ON
        SET XACT_ABORT ON
        SET ANSI_WARNINGS OFF  
	    
		DECLARE @ErrMsg					   NVARCHAR(MAX),
				@idoc					   INT,
				@ItemLocation 			   NVARCHAR(MAX),
				@ItemVendor                NVARCHAR(MAX),
				@ItemCategory              NVARCHAR(MAX),
				@ItemManufacturer          NVARCHAR(MAX),
				@ItemFamily                NVARCHAR(MAX),
				@ItemClass                 NVARCHAR(MAX),
				@ItemUpcCode               NVARCHAR(MAX),
				@ItemDescription           NVARCHAR(250),
				@ItemPriceBetween1         DECIMAL (18,6),
				@ItemPriceBetween2         DECIMAL (18,6),
				@ItemTaxFlag1ysn           NVARCHAR(1),
				@ItemTaxFlag2ysn           NVARCHAR(1),
				@ItemTaxFlag3ysn           NVARCHAR(1),
				@ItemTaxFlag4ysn           NVARCHAR(1),
				@ItemDepositRequiredysn    NVARCHAR(1),
				@ItemDepositPLU            BIGINT,
				@ItemQuantityRequiredysn   NVARCHAR(1),
				@ItemScaleItemysn          NVARCHAR(1),
				@ItemFoodStampableysn      NVARCHAR(1),
				@ItemReturnableysn         NVARCHAR(1),
				@ItemSaleableysn           NVARCHAR(1),
				@ItemID1Requiredysn        NVARCHAR(1),
				@ItemID2Requiredysn        NVARCHAR(1),
				@ItemPromotionalItemysn    NVARCHAR(1),
				@ItemPrePricedysn          NVARCHAR(1),
				@ItemActiveysn             NVARCHAR(1),
				@ItemBlueLaw1ysn           NVARCHAR(1),
				@ItemBlueLaw2ysn           NVARCHAR(1),
				@ItemCountedDailyysn       NVARCHAR(1),
				@ItemCountedysn            NVARCHAR(1),
				@ItemCountSerialysn        NVARCHAR(1),
				@ItemStickReadingysn       NVARCHAR(1),
				@ItemNewFamily             NVARCHAR(8), 
				@ItemNewClass              NVARCHAR(8), 
				@ItemNewProductCode        NVARCHAR(50), 
				@ItemNewCategory           NVARCHAR(50), 
				@ItemNewVendor             NVARCHAR(50), 
				@ItemNewInventoryGroup     NVARCHAR(50), 
				@ItemNewQuantityCase       INT,
				@ItemNewQuantitySellUnit   INT,
				@ItemNewCountCode          NVARCHAR(1),     
				@ItemNewItemSize           INT,
				@ItemNewItemUOM            NVARCHAR(50), 
				@ItemNewMixMatch           INT,
				@ItemNewMinAge             INT,
				@ItemNewItemType           NVARCHAR(1),     
				@ItemNewMinVendorOrderQty  INT,
				@ItemNewVendorSuggestedQty INT,
				@ItemNewMinQtyOnHand       INT,
				@ItemNewBinLocation        NVARCHAR(10), 
				@ItemNewGLPurchaseAccount  NVARCHAR(50),
				@ItemNewGLSalesAccount     NVARCHAR(50),
				@ItemNewGLVarianceAccount  NVARCHAR(50)

	                  
		EXEC sp_xml_preparedocument @idoc OUTPUT, @XML 
	
		SELECT	
				@ItemLocation	   	 =	 Location,
				@ItemVendor          =   Vendor,
				@ItemCategory        =   Category,
				@ItemManufacturer    =   Manufacturer,
				@ItemFamily          =   Family,
				@ItemClass           =   Class,
				@ItemUpcCode         =   UPCCode,
				@ItemDescription     =   ItmDescription,
				@ItemPriceBetween1   =   PriceBetween1,
				@ItemPriceBetween2   =   PriceBetween2,
				@ItemTaxFlag1ysn     =   TaxFlag1ysn,
				@ItemTaxFlag2ysn     =   TaxFlag2ysn ,           
				@ItemTaxFlag3ysn     =   TaxFlag3ysn,          
				@ItemTaxFlag4ysn     =   TaxFlag4ysn,           
				@ItemDepositRequiredysn = DepositRequiredysn, 
				@ItemDepositPLU       =  DepositPLU,
				@ItemQuantityRequiredysn = QuantityRequiredysn,
				@ItemScaleItemysn     =  ScaleItemysn,
				@ItemFoodStampableysn =  FoodStampableysn,
				@ItemReturnableysn    =  Returnableysn,
				@ItemSaleableysn      =  Saleableysn,
				@ItemID1Requiredysn   =  ID1Requiredysn,                  
				@ItemID2Requiredysn   =  ID2Requiredysn,
				@ItemPromotionalItemysn = PromotionalItemysn,
				@ItemPrePricedysn     =  PrePricedysn,
				@ItemActiveysn        =  Activeysn,
				@ItemBlueLaw1ysn      =  BlueLaw1ysn,
				@ItemBlueLaw2ysn      =  BlueLaw2ysn,
				@ItemCountedDailyysn  =  CountedDailyysn,
				@ItemCountedysn       =  Countedysn,
				@ItemCountSerialysn   =  CountSerialysn,
				@ItemStickReadingysn  =  StickReadingysn,
				@ItemNewFamily        =  NewFamily,
				@ItemNewClass         =  NewClass,
				@ItemNewProductCode   =  NewProductCode,
				@ItemNewCategory      =  NewCategory,
				@ItemNewVendor        =  NewVendor,
				@ItemNewInventoryGroup = NewInventoryGroup,
				@ItemNewQuantityCase  =  NewQuantityCase,
				@ItemNewQuantitySellUnit  = NewQuantitySellUnit,
				@ItemNewCountCode       = NewCountCode,
				@ItemNewItemSize        = NewItemSize,
				@ItemNewItemUOM         = NewItemUOM,
				@ItemNewMixMatch        = NewMixMatch,
				@ItemNewMinAge          = NewMinAge,
				@ItemNewItemType        = NewItemType,
				@ItemNewMinVendorOrderQty = NewMinVendorOrderQty,
				@ItemNewVendorSuggestedQty = NewVendorSuggestedQty,
				@ItemNewMinQtyOnHand     = NewMinQtyOnHand,
				@ItemNewBinLocation      = NewBinLocation,
				@ItemNewGLPurchaseAccount  = NewGLPurchaseAccount,
				@ItemNewGLSalesAccount     = NewGLSalesAccount,
				@ItemNewGLVarianceAccount  = NewGLVarianceAccount  
		
		
		FROM	OPENXML(@idoc, 'root',2)
		WITH
		(
				Location		        NVARCHAR(MAX),
				Vendor	     	        NVARCHAR(MAX),
				Category		        NVARCHAR(MAX),
				Manufacturer            NVARCHAR(MAX),
				Family	     	        NVARCHAR(MAX),
				Class	     	        NVARCHAR(MAX),
				UPCCode                 NVARCHAR(MAX),
				ItmDescription		    NVARCHAR(250),
				PriceBetween1		    DECIMAL (18,6),
				PriceBetween2		    DECIMAL (18,6),
				TaxFlag1ysn             NVARCHAR(1),
				TaxFlag2ysn             NVARCHAR(1),
				TaxFlag3ysn             NVARCHAR(1),
				TaxFlag4ysn             NVARCHAR(1),
				DepositRequiredysn      NVARCHAR(1),
				DepositPLU              BIGINT,
				QuantityRequiredysn     NVARCHAR(1),
				ScaleItemysn            NVARCHAR(1),
				FoodStampableysn        NVARCHAR(1),
				Returnableysn           NVARCHAR(1),
				Saleableysn             NVARCHAR(1),
				ID1Requiredysn          NVARCHAR(1),
				ID2Requiredysn          NVARCHAR(1),			    
				PromotionalItemysn      NVARCHAR(1),
				PrePricedysn            NVARCHAR(1),
				Activeysn               NVARCHAR(1),
				BlueLaw1ysn             NVARCHAR(1),
				BlueLaw2ysn             NVARCHAR(1),
				CountedDailyysn         NVARCHAR(1),
				Countedysn              NVARCHAR(1),
				CountSerialysn          NVARCHAR(1),
				StickReadingysn         NVARCHAR(1),
				NewFamily               NVARCHAR(8),  
				NewClass                NVARCHAR(8),  
				NewProductCode          NVARCHAR(50), 
				NewCategory             NVARCHAR(50), 
				NewVendor               NVARCHAR(50), 
				NewInventoryGroup       NVARCHAR(50), 
				NewQuantityCase         INT,
				NewQuantitySellUnit     INT,
				NewCountCode            NVARCHAR(1),
				NewItemSize             INT,  
				NewItemUOM              NVARCHAR(50), 
				NewMixMatch             INT,
				NewMinAge               INT,
				NewItemType             NVARCHAR(1),
				NewMinVendorOrderQty    INT,
				NewVendorSuggestedQty   INT,
				NewMinQtyOnHand         INT,              			   
				NewBinLocation          NVARCHAR(10),
				NewGLPurchaseAccount    NVARCHAR(50),
				NewGLSalesAccount       NVARCHAR(50),
				NewGLVarianceAccount    NVARCHAR(50)

			
		)  
		-- Insert statements for procedure here

		DECLARE @SQL1 NVARCHAR(MAX)

		   set @SQL1 = 'update stpbkmst set ' 
		 if (@ItemTaxFlag1ysn IS NOT NULL)
			  BEGIN
				set @SQL1 = @SQL1 + 'stpbk_taxflag1_yn = ''' + LTRIM(@ItemTaxFlag1ysn) + ''''
			  END

		 if (@ItemTaxFlag2ysn IS NOT NULL)  
			  BEGIN
			  if (@ItemTaxFlag1ysn IS NOT NULL)
 				 set @SQL1 = @SQL1 + ' , stpbk_taxflag2_yn = ''' + LTRIM(@ItemTaxFlag2ysn) + ''''
			  else
				 set @SQL1 = @SQL1 + ' stpbk_taxflag2_yn = ''' + LTRIM(@ItemTaxFlag2ysn) + '''' 
			  END

		 if (@ItemTaxFlag3ysn IS NOT NULL)  
			  BEGIN
			  if ((@ItemTaxFlag1ysn IS NOT NULL) OR (@ItemTaxFlag2ysn IS NOT NULL))   
 				 set @SQL1 = @SQL1 + ' , stpbk_taxflag3_yn = ''' + LTRIM(@ItemTaxFlag3ysn) + ''''
			  else
				 set @SQL1 = @SQL1 + ' stpbk_taxflag3_yn = ''' + LTRIM(@ItemTaxFlag3ysn) + '''' 
			  END

		  if (@ItemTaxFlag4ysn IS NOT NULL)  
			  BEGIN
			  if ((@ItemTaxFlag1ysn IS NOT NULL) OR (@ItemTaxFlag2ysn IS NOT NULL)
			  OR (@ItemTaxFlag3ysn IS NOT NULL))   
 				 set @SQL1 = @SQL1 + ' , stpbk_taxflag4_yn = ''' + LTRIM(@ItemTaxFlag4ysn) + ''''
			  else
				 set @SQL1 = @SQL1 + ' stpbk_taxflag4_yn = ''' + LTRIM(@ItemTaxFlag4ysn) + '''' 
			  END

		  if (@ItemDepositRequiredysn IS NOT NULL)  
			  BEGIN
			  if ((@ItemTaxFlag1ysn IS NOT NULL) OR (@ItemTaxFlag2ysn IS NOT NULL)
			  OR (@ItemTaxFlag3ysn IS NOT NULL) OR (@ItemTaxFlag4ysn IS NOT NULL))   
 				 set @SQL1 = @SQL1 + ' , stpbk_dep_req_yn = ''' + LTRIM(@ItemDepositRequiredysn) + ''''
			  else
				 set @SQL1 = @SQL1 + ' stpbk_dep_req_yn = ''' + LTRIM(@ItemDepositRequiredysn) + '''' 
			  END

		  if (@ItemScaleItemysn IS NOT NULL)  
			  BEGIN
			  if ((@ItemTaxFlag1ysn IS NOT NULL) OR (@ItemTaxFlag2ysn IS NOT NULL)
			  OR (@ItemTaxFlag3ysn IS NOT NULL) OR (@ItemTaxFlag4ysn IS NOT NULL)
			  OR (@ItemDepositRequiredysn IS NOT NULL))   
 				 set @SQL1 = @SQL1 + ' , stpbk_scale_yn = ''' + LTRIM(@ItemScaleItemysn) + ''''
			  else
				 set @SQL1 = @SQL1 + ' stpbk_scale_yn = ''' + LTRIM(@ItemScaleItemysn) + '''' 
			  END

		  if (@ItemFoodStampableysn IS NOT NULL)  
			  BEGIN
			  if ((@ItemTaxFlag1ysn IS NOT NULL) OR (@ItemTaxFlag2ysn IS NOT NULL)
			  OR (@ItemTaxFlag3ysn IS NOT NULL) OR (@ItemTaxFlag4ysn IS NOT NULL)
			  OR (@ItemDepositRequiredysn IS NOT NULL) OR (@ItemScaleItemysn IS NOT NULL))   
 				 set @SQL1 = @SQL1 + ' , stpbk_food_stamp_yn = ''' + LTRIM(@ItemFoodStampableysn) + ''''
			  else
				 set @SQL1 = @SQL1 + ' stpbk_food_stamp_yn = ''' + LTRIM(@ItemFoodStampableysn) + '''' 
			  END

		  if (@ItemReturnableysn IS NOT NULL)  
			  BEGIN
			  if ((@ItemTaxFlag1ysn IS NOT NULL) OR (@ItemTaxFlag2ysn IS NOT NULL)
			  OR (@ItemTaxFlag3ysn IS NOT NULL) OR (@ItemTaxFlag4ysn IS NOT NULL)
			  OR (@ItemDepositRequiredysn IS NOT NULL) OR (@ItemScaleItemysn IS NOT NULL)
			  OR (@ItemFoodStampableysn IS NOT NULL))   
 				 set @SQL1 = @SQL1 + ' , stpbk_returnable_yn = ''' + LTRIM(@ItemReturnableysn) + ''''
			  else
				 set @SQL1 = @SQL1 + ' stpbk_returnable_yn = ''' + LTRIM(@ItemReturnableysn) + '''' 
			  END

		  if (@ItemSaleableysn IS NOT NULL)  
			  BEGIN
			  if ((@ItemTaxFlag1ysn IS NOT NULL) OR (@ItemTaxFlag2ysn IS NOT NULL)
			  OR (@ItemTaxFlag3ysn IS NOT NULL) OR (@ItemTaxFlag4ysn IS NOT NULL)
			  OR (@ItemDepositRequiredysn IS NOT NULL) OR (@ItemScaleItemysn IS NOT NULL)
			  OR (@ItemFoodStampableysn IS NOT NULL) OR (@ItemReturnableysn IS NOT NULL))   
 				 set @SQL1 = @SQL1 + ' , stpbk_saleable_yn = ''' + LTRIM(@ItemSaleableysn) + ''''
			  else
				 set @SQL1 = @SQL1 + ' stpbk_saleable_yn = ''' + LTRIM(@ItemSaleableysn) + '''' 
			  END

		  if (@ItemID1Requiredysn IS NOT NULL)  
			  BEGIN
			  if ((@ItemTaxFlag1ysn IS NOT NULL) OR (@ItemTaxFlag2ysn IS NOT NULL)
			  OR (@ItemTaxFlag3ysn IS NOT NULL) OR (@ItemTaxFlag4ysn IS NOT NULL)
			  OR (@ItemDepositRequiredysn IS NOT NULL) OR (@ItemScaleItemysn IS NOT NULL)
			  OR (@ItemFoodStampableysn IS NOT NULL) OR (@ItemReturnableysn IS NOT NULL)
			  OR (@ItemSaleableysn IS NOT NULL))   
 				 set @SQL1 = @SQL1 + ' , stpbk_id1_req_yn = ''' + LTRIM(@ItemID1Requiredysn) + ''''
			  else
				 set @SQL1 = @SQL1 + ' stpbk_id1_req_yn = ''' + LTRIM(@ItemID1Requiredysn) + '''' 
			  END

		   if (@ItemID2Requiredysn IS NOT NULL)  
			  BEGIN
			  if ((@ItemTaxFlag1ysn IS NOT NULL) OR (@ItemTaxFlag2ysn IS NOT NULL)
			  OR (@ItemTaxFlag3ysn IS NOT NULL) OR (@ItemTaxFlag4ysn IS NOT NULL)
			  OR (@ItemDepositRequiredysn IS NOT NULL) OR (@ItemScaleItemysn IS NOT NULL)
			  OR (@ItemFoodStampableysn IS NOT NULL) OR (@ItemReturnableysn IS NOT NULL)
			  OR (@ItemSaleableysn IS NOT NULL) OR (@ItemID1Requiredysn IS NOT NULL))   
 				 set @SQL1 = @SQL1 + ' , stpbk_id2_req_yn = ''' + LTRIM(@ItemID2Requiredysn) + ''''
			  else
				 set @SQL1 = @SQL1 + ' stpbk_id2_req_yn = ''' + LTRIM(@ItemID2Requiredysn) + '''' 
			  END

		   if (@ItemPromotionalItemysn IS NOT NULL)  
			  BEGIN
			  if ((@ItemTaxFlag1ysn IS NOT NULL) OR (@ItemTaxFlag2ysn IS NOT NULL)
			  OR (@ItemTaxFlag3ysn IS NOT NULL) OR (@ItemTaxFlag4ysn IS NOT NULL)
			  OR (@ItemDepositRequiredysn IS NOT NULL) OR (@ItemScaleItemysn IS NOT NULL)
			  OR (@ItemFoodStampableysn IS NOT NULL) OR (@ItemReturnableysn IS NOT NULL)
			  OR (@ItemSaleableysn IS NOT NULL) OR (@ItemID1Requiredysn IS NOT NULL)
			  OR (@ItemID2Requiredysn IS NOT NULL))   
 				 set @SQL1 = @SQL1 + ' , stpbk_promo_yn = ''' + LTRIM(@ItemPromotionalItemysn) + ''''
			  else
				 set @SQL1 = @SQL1 + ' stpbk_promo_yn = ''' + LTRIM(@ItemPromotionalItemysn) + '''' 
			  END

		  if (@ItemPrePricedysn IS NOT NULL)  
			  BEGIN
			  if ((@ItemTaxFlag1ysn IS NOT NULL) OR (@ItemTaxFlag2ysn IS NOT NULL)
			  OR (@ItemTaxFlag3ysn IS NOT NULL) OR (@ItemTaxFlag4ysn IS NOT NULL)
			  OR (@ItemDepositRequiredysn IS NOT NULL) OR (@ItemScaleItemysn IS NOT NULL)
			  OR (@ItemFoodStampableysn IS NOT NULL) OR (@ItemReturnableysn IS NOT NULL)
			  OR (@ItemSaleableysn IS NOT NULL) OR (@ItemID1Requiredysn IS NOT NULL)
			  OR (@ItemID2Requiredysn IS NOT NULL) OR (@ItemPromotionalItemysn IS NOT NULL))   
 				 set @SQL1 = @SQL1 + ' , stpbk_pre_prcd_yn = ''' + LTRIM(@ItemPrePricedysn) + ''''
			  else
				 set @SQL1 = @SQL1 + ' stpbk_pre_prcd_yn = ''' + LTRIM(@ItemPrePricedysn) + '''' 
			  END

		 if (@ItemActiveysn IS NOT NULL)  
			  BEGIN
			  if ((@ItemTaxFlag1ysn IS NOT NULL) OR (@ItemTaxFlag2ysn IS NOT NULL)
			  OR (@ItemTaxFlag3ysn IS NOT NULL) OR (@ItemTaxFlag4ysn IS NOT NULL)
			  OR (@ItemDepositRequiredysn IS NOT NULL) OR (@ItemScaleItemysn IS NOT NULL)
			  OR (@ItemFoodStampableysn IS NOT NULL) OR (@ItemReturnableysn IS NOT NULL)
			  OR (@ItemSaleableysn IS NOT NULL) OR (@ItemID1Requiredysn IS NOT NULL)
			  OR (@ItemID2Requiredysn IS NOT NULL) OR (@ItemPromotionalItemysn IS NOT NULL)
			  OR (@ItemPrePricedysn IS NOT NULL))   
 				 set @SQL1 = @SQL1 + ' , stpbk_active_ynd = ''' + LTRIM(@ItemActiveysn) + ''''
			  else
				 set @SQL1 = @SQL1 + ' stpbk_active_ynd = ''' + LTRIM(@ItemActiveysn) + '''' 
			  END

		  if (@ItemBlueLaw1ysn IS NOT NULL)  
			  BEGIN
			  if ((@ItemTaxFlag1ysn IS NOT NULL) OR (@ItemTaxFlag2ysn IS NOT NULL)
			  OR (@ItemTaxFlag3ysn IS NOT NULL) OR (@ItemTaxFlag4ysn IS NOT NULL)
			  OR (@ItemDepositRequiredysn IS NOT NULL) OR (@ItemScaleItemysn IS NOT NULL)
			  OR (@ItemFoodStampableysn IS NOT NULL) OR (@ItemReturnableysn IS NOT NULL)
			  OR (@ItemSaleableysn IS NOT NULL) OR (@ItemID1Requiredysn IS NOT NULL)
			  OR (@ItemID2Requiredysn IS NOT NULL) OR (@ItemPromotionalItemysn IS NOT NULL)
			  OR (@ItemPrePricedysn IS NOT NULL) OR (@ItemActiveysn IS NOT NULL))   
 				 set @SQL1 = @SQL1 + ' , stpbk_bluelaw1_yn = ''' + LTRIM(@ItemBlueLaw1ysn) + ''''
			  else
				 set @SQL1 = @SQL1 + ' stpbk_bluelaw1_yn = ''' + LTRIM(@ItemBlueLaw1ysn) + '''' 
			  END

		 if (@ItemBlueLaw2ysn IS NOT NULL)  
			  BEGIN
			  if ((@ItemTaxFlag1ysn IS NOT NULL) OR (@ItemTaxFlag2ysn IS NOT NULL)
			  OR (@ItemTaxFlag3ysn IS NOT NULL) OR (@ItemTaxFlag4ysn IS NOT NULL)
			  OR (@ItemDepositRequiredysn IS NOT NULL) OR (@ItemScaleItemysn IS NOT NULL)
			  OR (@ItemFoodStampableysn IS NOT NULL) OR (@ItemReturnableysn IS NOT NULL)
			  OR (@ItemSaleableysn IS NOT NULL) OR (@ItemID1Requiredysn IS NOT NULL)
			  OR (@ItemID2Requiredysn IS NOT NULL) OR (@ItemPromotionalItemysn IS NOT NULL)
			  OR (@ItemPrePricedysn IS NOT NULL) OR (@ItemActiveysn IS NOT NULL)
			  OR (@ItemBlueLaw1ysn IS NOT NULL))   
 				 set @SQL1 = @SQL1 + ' , stpbk_bluelaw2_yn = ''' + LTRIM(@ItemBlueLaw2ysn) + ''''
			  else
				 set @SQL1 = @SQL1 + ' stpbk_bluelaw2_yn = ''' + LTRIM(@ItemBlueLaw2ysn) + '''' 
			  END

		 if (@ItemCountedDailyysn IS NOT NULL)  
			  BEGIN
			  if ((@ItemTaxFlag1ysn IS NOT NULL) OR (@ItemTaxFlag2ysn IS NOT NULL)
			  OR (@ItemTaxFlag3ysn IS NOT NULL) OR (@ItemTaxFlag4ysn IS NOT NULL)
			  OR (@ItemDepositRequiredysn IS NOT NULL) OR (@ItemScaleItemysn IS NOT NULL)
			  OR (@ItemFoodStampableysn IS NOT NULL) OR (@ItemReturnableysn IS NOT NULL)
			  OR (@ItemSaleableysn IS NOT NULL) OR (@ItemID1Requiredysn IS NOT NULL)
			  OR (@ItemID2Requiredysn IS NOT NULL) OR (@ItemPromotionalItemysn IS NOT NULL)
			  OR (@ItemPrePricedysn IS NOT NULL) OR (@ItemActiveysn IS NOT NULL)
			  OR (@ItemBlueLaw1ysn IS NOT NULL) OR (@ItemBlueLaw2ysn IS NOT NULL))   
 				 set @SQL1 = @SQL1 + ' , stpbk_phys_dly_yn = ''' + LTRIM(@ItemCountedDailyysn) + ''''
			  else
				 set @SQL1 = @SQL1 + ' stpbk_phys_dly_yn = ''' + LTRIM(@ItemCountedDailyysn) + '''' 
			  END

		   if (@ItemCountedysn  IS NOT NULL)  
			  BEGIN
			  if ((@ItemTaxFlag1ysn IS NOT NULL) OR (@ItemTaxFlag2ysn IS NOT NULL)
			  OR (@ItemTaxFlag3ysn IS NOT NULL) OR (@ItemTaxFlag4ysn IS NOT NULL)
			  OR (@ItemDepositRequiredysn IS NOT NULL) OR (@ItemScaleItemysn IS NOT NULL)
			  OR (@ItemFoodStampableysn IS NOT NULL) OR (@ItemReturnableysn IS NOT NULL)
			  OR (@ItemSaleableysn IS NOT NULL) OR (@ItemID1Requiredysn IS NOT NULL)
			  OR (@ItemID2Requiredysn IS NOT NULL) OR (@ItemPromotionalItemysn IS NOT NULL)
			  OR (@ItemPrePricedysn IS NOT NULL) OR (@ItemActiveysn IS NOT NULL)
			  OR (@ItemBlueLaw1ysn IS NOT NULL) OR (@ItemBlueLaw2ysn IS NOT NULL)
			  OR (@ItemCountedDailyysn IS NOT NULL))   
 				 set @SQL1 = @SQL1 + ' , stpbk_phys_inv_ynbo = ''' + LTRIM(@ItemCountedysn) + ''''
			  else
				 set @SQL1 = @SQL1 + ' stpbk_phys_inv_ynbo = ''' + LTRIM(@ItemCountedysn) + '''' 
			  END

		   if (@ItemCountSerialysn IS NOT NULL)  
			  BEGIN
			  if ((@ItemTaxFlag1ysn IS NOT NULL) OR (@ItemTaxFlag2ysn IS NOT NULL)
			  OR (@ItemTaxFlag3ysn IS NOT NULL) OR (@ItemTaxFlag4ysn IS NOT NULL)
			  OR (@ItemDepositRequiredysn IS NOT NULL) OR (@ItemScaleItemysn IS NOT NULL)
			  OR (@ItemFoodStampableysn IS NOT NULL) OR (@ItemReturnableysn IS NOT NULL)
			  OR (@ItemSaleableysn IS NOT NULL) OR (@ItemID1Requiredysn IS NOT NULL)
			  OR (@ItemID2Requiredysn IS NOT NULL) OR (@ItemPromotionalItemysn IS NOT NULL)
			  OR (@ItemPrePricedysn IS NOT NULL) OR (@ItemActiveysn IS NOT NULL)
			  OR (@ItemBlueLaw1ysn IS NOT NULL) OR (@ItemBlueLaw2ysn IS NOT NULL)
			  OR (@ItemCountedDailyysn IS NOT NULL) OR (@ItemCountedysn  IS NOT NULL))   
 				 set @SQL1 = @SQL1 + ' , stpbk_serials_yn = ''' + LTRIM(@ItemCountSerialysn) + ''''
			  else
				 set @SQL1 = @SQL1 + ' stpbk_serials_yn = ''' + LTRIM(@ItemCountSerialysn) + '''' 
			  END

		  if (@ItemStickReadingysn  IS NOT NULL)  
			  BEGIN
			  if ((@ItemTaxFlag1ysn IS NOT NULL) OR (@ItemTaxFlag2ysn IS NOT NULL)
			  OR (@ItemTaxFlag3ysn IS NOT NULL) OR (@ItemTaxFlag4ysn IS NOT NULL)
			  OR (@ItemDepositRequiredysn IS NOT NULL) OR (@ItemScaleItemysn IS NOT NULL)
			  OR (@ItemFoodStampableysn IS NOT NULL) OR (@ItemReturnableysn IS NOT NULL)
			  OR (@ItemSaleableysn IS NOT NULL) OR (@ItemID1Requiredysn IS NOT NULL)
			  OR (@ItemID2Requiredysn IS NOT NULL) OR (@ItemPromotionalItemysn IS NOT NULL)
			  OR (@ItemPrePricedysn IS NOT NULL) OR (@ItemActiveysn IS NOT NULL)
			  OR (@ItemBlueLaw1ysn IS NOT NULL) OR (@ItemBlueLaw2ysn IS NOT NULL)
			  OR (@ItemCountedDailyysn IS NOT NULL) OR (@ItemCountedysn  IS NOT NULL)
			  OR (@ItemCountSerialysn IS NOT NULL))   
 				 set @SQL1 = @SQL1 + ' , stpbk_stick_yn = ''' + LTRIM(@ItemStickReadingysn) + ''''
			  else
				 set @SQL1 = @SQL1 + ' stpbk_stick_yn = ''' + LTRIM(@ItemStickReadingysn) + '''' 
			  END

		   if (@ItemNewFamily IS NOT NULL)  
			  BEGIN
			  if ((@ItemTaxFlag1ysn IS NOT NULL) OR (@ItemTaxFlag2ysn IS NOT NULL)
			  OR (@ItemTaxFlag3ysn IS NOT NULL) OR (@ItemTaxFlag4ysn IS NOT NULL)
			  OR (@ItemDepositRequiredysn IS NOT NULL) OR (@ItemScaleItemysn IS NOT NULL)
			  OR (@ItemFoodStampableysn IS NOT NULL) OR (@ItemReturnableysn IS NOT NULL)
			  OR (@ItemSaleableysn IS NOT NULL) OR (@ItemID1Requiredysn IS NOT NULL)
			  OR (@ItemID2Requiredysn IS NOT NULL) OR (@ItemPromotionalItemysn IS NOT NULL)
			  OR (@ItemPrePricedysn IS NOT NULL) OR (@ItemActiveysn IS NOT NULL)
			  OR (@ItemBlueLaw1ysn IS NOT NULL) OR (@ItemBlueLaw2ysn IS NOT NULL)
			  OR (@ItemCountedDailyysn IS NOT NULL) OR (@ItemCountedysn  IS NOT NULL)
			  OR (@ItemCountSerialysn IS NOT NULL) OR (@ItemStickReadingysn  IS NOT NULL))   
 				 set @SQL1 = @SQL1 + ' , stpbk_family = ''' + LTRIM(@ItemNewFamily) + ''''
			  else
				 set @SQL1 = @SQL1 + ' stpbk_family = ''' + LTRIM(@ItemNewFamily) + '''' 
			  END

		   if (@ItemNewClass IS NOT NULL)  
			  BEGIN
			  if ((@ItemTaxFlag1ysn IS NOT NULL) OR (@ItemTaxFlag2ysn IS NOT NULL)
			  OR (@ItemTaxFlag3ysn IS NOT NULL) OR (@ItemTaxFlag4ysn IS NOT NULL)
			  OR (@ItemDepositRequiredysn IS NOT NULL) OR (@ItemScaleItemysn IS NOT NULL)
			  OR (@ItemFoodStampableysn IS NOT NULL) OR (@ItemReturnableysn IS NOT NULL)
			  OR (@ItemSaleableysn IS NOT NULL) OR (@ItemID1Requiredysn IS NOT NULL)
			  OR (@ItemID2Requiredysn IS NOT NULL) OR (@ItemPromotionalItemysn IS NOT NULL)
			  OR (@ItemPrePricedysn IS NOT NULL) OR (@ItemActiveysn IS NOT NULL)
			  OR (@ItemBlueLaw1ysn IS NOT NULL) OR (@ItemBlueLaw2ysn IS NOT NULL)
			  OR (@ItemCountedDailyysn IS NOT NULL) OR (@ItemCountedysn  IS NOT NULL)
			  OR (@ItemCountSerialysn IS NOT NULL) OR (@ItemStickReadingysn  IS NOT NULL)
			  OR (@ItemNewFamily IS NOT NULL))   
 				 set @SQL1 = @SQL1 + ' , stpbk_class = ''' + LTRIM(@ItemNewClass) + ''''
			  else
				 set @SQL1 = @SQL1 + ' stpbk_class = ''' + LTRIM(@ItemNewClass) + '''' 
			  END

		   if (@ItemNewProductCode IS NOT NULL)  
			  BEGIN
			  if ((@ItemTaxFlag1ysn IS NOT NULL) OR (@ItemTaxFlag2ysn IS NOT NULL)
			  OR (@ItemTaxFlag3ysn IS NOT NULL) OR (@ItemTaxFlag4ysn IS NOT NULL)
			  OR (@ItemDepositRequiredysn IS NOT NULL) OR (@ItemScaleItemysn IS NOT NULL)
			  OR (@ItemFoodStampableysn IS NOT NULL) OR (@ItemReturnableysn IS NOT NULL)
			  OR (@ItemSaleableysn IS NOT NULL) OR (@ItemID1Requiredysn IS NOT NULL)
			  OR (@ItemID2Requiredysn IS NOT NULL) OR (@ItemPromotionalItemysn IS NOT NULL)
			  OR (@ItemPrePricedysn IS NOT NULL) OR (@ItemActiveysn IS NOT NULL)
			  OR (@ItemBlueLaw1ysn IS NOT NULL) OR (@ItemBlueLaw2ysn IS NOT NULL)
			  OR (@ItemCountedDailyysn IS NOT NULL) OR (@ItemCountedysn  IS NOT NULL)
			  OR (@ItemCountSerialysn IS NOT NULL) OR (@ItemStickReadingysn  IS NOT NULL)
			  OR (@ItemNewFamily IS NOT NULL) OR (@ItemNewClass IS NOT NULL))   
 				 set @SQL1 = @SQL1 + ' , stpbk_product_cd_n = ''' + LTRIM(@ItemNewProductCode) + ''''
			  else
				 set @SQL1 = @SQL1 + ' stpbk_product_cd_n = ''' + LTRIM(@ItemNewProductCode) + '''' 
			  END

		   if (@ItemNewCategory IS NOT NULL)  
			  BEGIN
			  if ((@ItemTaxFlag1ysn IS NOT NULL) OR (@ItemTaxFlag2ysn IS NOT NULL)
			  OR (@ItemTaxFlag3ysn IS NOT NULL) OR (@ItemTaxFlag4ysn IS NOT NULL)
			  OR (@ItemDepositRequiredysn IS NOT NULL) OR (@ItemScaleItemysn IS NOT NULL)
			  OR (@ItemFoodStampableysn IS NOT NULL) OR (@ItemReturnableysn IS NOT NULL)
			  OR (@ItemSaleableysn IS NOT NULL) OR (@ItemID1Requiredysn IS NOT NULL)
			  OR (@ItemID2Requiredysn IS NOT NULL) OR (@ItemPromotionalItemysn IS NOT NULL)
			  OR (@ItemPrePricedysn IS NOT NULL) OR (@ItemActiveysn IS NOT NULL)
			  OR (@ItemBlueLaw1ysn IS NOT NULL) OR (@ItemBlueLaw2ysn IS NOT NULL)
			  OR (@ItemCountedDailyysn IS NOT NULL) OR (@ItemCountedysn  IS NOT NULL)
			  OR (@ItemCountSerialysn IS NOT NULL) OR (@ItemStickReadingysn  IS NOT NULL)
			  OR (@ItemNewFamily IS NOT NULL) OR (@ItemNewClass IS NOT NULL)
			  OR (@ItemNewProductCode IS NOT NULL))   
 				 set @SQL1 = @SQL1 + ' , stpbk_deptno = ''' + LTRIM(@ItemNewCategory) + ''''
			  else
				 set @SQL1 = @SQL1 + ' stpbk_deptno = ''' + LTRIM(@ItemNewCategory) + '''' 
			  END

		  if (@ItemNewVendor IS NOT NULL)  
			  BEGIN
			  if ((@ItemTaxFlag1ysn IS NOT NULL) OR (@ItemTaxFlag2ysn IS NOT NULL)
			  OR (@ItemTaxFlag3ysn IS NOT NULL) OR (@ItemTaxFlag4ysn IS NOT NULL)
			  OR (@ItemDepositRequiredysn IS NOT NULL) OR (@ItemScaleItemysn IS NOT NULL)
			  OR (@ItemFoodStampableysn IS NOT NULL) OR (@ItemReturnableysn IS NOT NULL)
			  OR (@ItemSaleableysn IS NOT NULL) OR (@ItemID1Requiredysn IS NOT NULL)
			  OR (@ItemID2Requiredysn IS NOT NULL) OR (@ItemPromotionalItemysn IS NOT NULL)
			  OR (@ItemPrePricedysn IS NOT NULL) OR (@ItemActiveysn IS NOT NULL)
			  OR (@ItemBlueLaw1ysn IS NOT NULL) OR (@ItemBlueLaw2ysn IS NOT NULL)
			  OR (@ItemCountedDailyysn IS NOT NULL) OR (@ItemCountedysn  IS NOT NULL)
			  OR (@ItemCountSerialysn IS NOT NULL) OR (@ItemStickReadingysn  IS NOT NULL)
			  OR (@ItemNewFamily IS NOT NULL) OR (@ItemNewClass IS NOT NULL)
			  OR (@ItemNewProductCode IS NOT NULL) OR (@ItemNewCategory IS NOT NULL))   
 				 set @SQL1 = @SQL1 + ' , stpbk_vnd_id = ''' + LTRIM(@ItemNewVendor) + ''''
			  else
				 set @SQL1 = @SQL1 + ' stpbk_vnd_id = ''' + LTRIM(@ItemNewVendor) + '''' 
			  END

		   if (@ItemNewInventoryGroup IS NOT NULL)  
			  BEGIN
			  if ((@ItemTaxFlag1ysn IS NOT NULL) OR (@ItemTaxFlag2ysn IS NOT NULL)
			  OR (@ItemTaxFlag3ysn IS NOT NULL) OR (@ItemTaxFlag4ysn IS NOT NULL)
			  OR (@ItemDepositRequiredysn IS NOT NULL) OR (@ItemScaleItemysn IS NOT NULL)
			  OR (@ItemFoodStampableysn IS NOT NULL) OR (@ItemReturnableysn IS NOT NULL)
			  OR (@ItemSaleableysn IS NOT NULL) OR (@ItemID1Requiredysn IS NOT NULL)
			  OR (@ItemID2Requiredysn IS NOT NULL) OR (@ItemPromotionalItemysn IS NOT NULL)
			  OR (@ItemPrePricedysn IS NOT NULL) OR (@ItemActiveysn IS NOT NULL)
			  OR (@ItemBlueLaw1ysn IS NOT NULL) OR (@ItemBlueLaw2ysn IS NOT NULL)
			  OR (@ItemCountedDailyysn IS NOT NULL) OR (@ItemCountedysn  IS NOT NULL)
			  OR (@ItemCountSerialysn IS NOT NULL) OR (@ItemStickReadingysn  IS NOT NULL)
			  OR (@ItemNewFamily IS NOT NULL) OR (@ItemNewClass IS NOT NULL)
			  OR (@ItemNewProductCode IS NOT NULL) OR (@ItemNewCategory IS NOT NULL)
			  OR (@ItemNewVendor IS NOT NULL))   
 				 set @SQL1 = @SQL1 + ' , stpbk_alt4_inv_upcno = ''' + LTRIM(@ItemNewInventoryGroup) + ''''
			  else
				 set @SQL1 = @SQL1 + ' stpbk_alt4_inv_upcno = ''' + LTRIM(@ItemNewInventoryGroup) + '''' 
			  END

		  if (@ItemNewQuantityCase IS NOT NULL)  
			  BEGIN
			  if ((@ItemTaxFlag1ysn IS NOT NULL) OR (@ItemTaxFlag2ysn IS NOT NULL)
			  OR (@ItemTaxFlag3ysn IS NOT NULL) OR (@ItemTaxFlag4ysn IS NOT NULL)
			  OR (@ItemDepositRequiredysn IS NOT NULL) OR (@ItemScaleItemysn IS NOT NULL)
			  OR (@ItemFoodStampableysn IS NOT NULL) OR (@ItemReturnableysn IS NOT NULL)
			  OR (@ItemSaleableysn IS NOT NULL) OR (@ItemID1Requiredysn IS NOT NULL)
			  OR (@ItemID2Requiredysn IS NOT NULL) OR (@ItemPromotionalItemysn IS NOT NULL)
			  OR (@ItemPrePricedysn IS NOT NULL) OR (@ItemActiveysn IS NOT NULL)
			  OR (@ItemBlueLaw1ysn IS NOT NULL) OR (@ItemBlueLaw2ysn IS NOT NULL)
			  OR (@ItemCountedDailyysn IS NOT NULL) OR (@ItemCountedysn  IS NOT NULL)
			  OR (@ItemCountSerialysn IS NOT NULL) OR (@ItemStickReadingysn  IS NOT NULL)
			  OR (@ItemNewFamily IS NOT NULL) OR (@ItemNewClass IS NOT NULL)
			  OR (@ItemNewProductCode IS NOT NULL) OR (@ItemNewCategory IS NOT NULL)
			  OR (@ItemNewVendor IS NOT NULL) OR (@ItemNewInventoryGroup IS NOT NULL))   
 				 set @SQL1 = @SQL1 + ' , stpbk_casesize = ''' + LTRIM(@ItemNewQuantityCase) + ''''
			  else
				 set @SQL1 = @SQL1 + ' stpbk_casesize = ''' + LTRIM(@ItemNewQuantityCase) + '''' 
			  END

		  if (@ItemNewQuantitySellUnit IS NOT NULL)  
			  BEGIN
			  if ((@ItemTaxFlag1ysn IS NOT NULL) OR (@ItemTaxFlag2ysn IS NOT NULL)
			  OR (@ItemTaxFlag3ysn IS NOT NULL) OR (@ItemTaxFlag4ysn IS NOT NULL)
			  OR (@ItemDepositRequiredysn IS NOT NULL) OR (@ItemScaleItemysn IS NOT NULL)
			  OR (@ItemFoodStampableysn IS NOT NULL) OR (@ItemReturnableysn IS NOT NULL)
			  OR (@ItemSaleableysn IS NOT NULL) OR (@ItemID1Requiredysn IS NOT NULL)
			  OR (@ItemID2Requiredysn IS NOT NULL) OR (@ItemPromotionalItemysn IS NOT NULL)
			  OR (@ItemPrePricedysn IS NOT NULL) OR (@ItemActiveysn IS NOT NULL)
			  OR (@ItemBlueLaw1ysn IS NOT NULL) OR (@ItemBlueLaw2ysn IS NOT NULL)
			  OR (@ItemCountedDailyysn IS NOT NULL) OR (@ItemCountedysn  IS NOT NULL)
			  OR (@ItemCountSerialysn IS NOT NULL) OR (@ItemStickReadingysn  IS NOT NULL)
			  OR (@ItemNewFamily IS NOT NULL) OR (@ItemNewClass IS NOT NULL)
			  OR (@ItemNewProductCode IS NOT NULL) OR (@ItemNewCategory IS NOT NULL)
			  OR (@ItemNewVendor IS NOT NULL) OR (@ItemNewInventoryGroup IS NOT NULL)
			  OR (@ItemNewQuantityCase IS NOT NULL))   
 				 set @SQL1 = @SQL1 + ' , stpbk_packsize = ''' + LTRIM(@ItemNewQuantitySellUnit) + ''''
			  else
				 set @SQL1 = @SQL1 + ' stpbk_packsize = ''' + LTRIM(@ItemNewQuantitySellUnit) + '''' 
			  END

		 if (@ItemNewCountCode  IS NOT NULL)  
			  BEGIN
			  if ((@ItemTaxFlag1ysn IS NOT NULL) OR (@ItemTaxFlag2ysn IS NOT NULL)
			  OR (@ItemTaxFlag3ysn IS NOT NULL) OR (@ItemTaxFlag4ysn IS NOT NULL)
			  OR (@ItemDepositRequiredysn IS NOT NULL) OR (@ItemScaleItemysn IS NOT NULL)
			  OR (@ItemFoodStampableysn IS NOT NULL) OR (@ItemReturnableysn IS NOT NULL)
			  OR (@ItemSaleableysn IS NOT NULL) OR (@ItemID1Requiredysn IS NOT NULL)
			  OR (@ItemID2Requiredysn IS NOT NULL) OR (@ItemPromotionalItemysn IS NOT NULL)
			  OR (@ItemPrePricedysn IS NOT NULL) OR (@ItemActiveysn IS NOT NULL)
			  OR (@ItemBlueLaw1ysn IS NOT NULL) OR (@ItemBlueLaw2ysn IS NOT NULL)
			  OR (@ItemCountedDailyysn IS NOT NULL) OR (@ItemCountedysn  IS NOT NULL)
			  OR (@ItemCountSerialysn IS NOT NULL) OR (@ItemStickReadingysn  IS NOT NULL)
			  OR (@ItemNewFamily IS NOT NULL) OR (@ItemNewClass IS NOT NULL)
			  OR (@ItemNewProductCode IS NOT NULL) OR (@ItemNewCategory IS NOT NULL)
			  OR (@ItemNewVendor IS NOT NULL) OR (@ItemNewInventoryGroup IS NOT NULL)
			  OR (@ItemNewQuantityCase IS NOT NULL) OR (@ItemNewQuantitySellUnit IS NOT NULL))   
 				 set @SQL1 = @SQL1 + ' , stpbk_cnt_what_cd = ''' + LTRIM(@ItemNewCountCode) + ''''
			  else
				 set @SQL1 = @SQL1 + ' stpbk_cnt_what_cd = ''' + LTRIM(@ItemNewCountCode) + '''' 
			  END

		 if (@ItemNewItemSize IS NOT NULL)  
			  BEGIN
			  if ((@ItemTaxFlag1ysn IS NOT NULL) OR (@ItemTaxFlag2ysn IS NOT NULL)
			  OR (@ItemTaxFlag3ysn IS NOT NULL) OR (@ItemTaxFlag4ysn IS NOT NULL)
			  OR (@ItemDepositRequiredysn IS NOT NULL) OR (@ItemScaleItemysn IS NOT NULL)
			  OR (@ItemFoodStampableysn IS NOT NULL) OR (@ItemReturnableysn IS NOT NULL)
			  OR (@ItemSaleableysn IS NOT NULL) OR (@ItemID1Requiredysn IS NOT NULL)
			  OR (@ItemID2Requiredysn IS NOT NULL) OR (@ItemPromotionalItemysn IS NOT NULL)
			  OR (@ItemPrePricedysn IS NOT NULL) OR (@ItemActiveysn IS NOT NULL)
			  OR (@ItemBlueLaw1ysn IS NOT NULL) OR (@ItemBlueLaw2ysn IS NOT NULL)
			  OR (@ItemCountedDailyysn IS NOT NULL) OR (@ItemCountedysn  IS NOT NULL)
			  OR (@ItemCountSerialysn IS NOT NULL) OR (@ItemStickReadingysn  IS NOT NULL)
			  OR (@ItemNewFamily IS NOT NULL) OR (@ItemNewClass IS NOT NULL)
			  OR (@ItemNewProductCode IS NOT NULL) OR (@ItemNewCategory IS NOT NULL)
			  OR (@ItemNewVendor IS NOT NULL) OR (@ItemNewInventoryGroup IS NOT NULL)
			  OR (@ItemNewQuantityCase IS NOT NULL) OR (@ItemNewQuantitySellUnit IS NOT NULL)
			  OR (@ItemNewCountCode  IS NOT NULL))   
 				 set @SQL1 = @SQL1 + ' , stpbk_itemsize = ''' + LTRIM(@ItemNewItemSize) + ''''
			  else
				 set @SQL1 = @SQL1 + ' stpbk_itemsize = ''' + LTRIM(@ItemNewItemSize) + '''' 
			  END

		 if (@ItemNewItemUOM IS NOT NULL)  
			  BEGIN
			  if ((@ItemTaxFlag1ysn IS NOT NULL) OR (@ItemTaxFlag2ysn IS NOT NULL)
			  OR (@ItemTaxFlag3ysn IS NOT NULL) OR (@ItemTaxFlag4ysn IS NOT NULL)
			  OR (@ItemDepositRequiredysn IS NOT NULL) OR (@ItemScaleItemysn IS NOT NULL)
			  OR (@ItemFoodStampableysn IS NOT NULL) OR (@ItemReturnableysn IS NOT NULL)
			  OR (@ItemSaleableysn IS NOT NULL) OR (@ItemID1Requiredysn IS NOT NULL)
			  OR (@ItemID2Requiredysn IS NOT NULL) OR (@ItemPromotionalItemysn IS NOT NULL)
			  OR (@ItemPrePricedysn IS NOT NULL) OR (@ItemActiveysn IS NOT NULL)
			  OR (@ItemBlueLaw1ysn IS NOT NULL) OR (@ItemBlueLaw2ysn IS NOT NULL)
			  OR (@ItemCountedDailyysn IS NOT NULL) OR (@ItemCountedysn  IS NOT NULL)
			  OR (@ItemCountSerialysn IS NOT NULL) OR (@ItemStickReadingysn  IS NOT NULL)
			  OR (@ItemNewFamily IS NOT NULL) OR (@ItemNewClass IS NOT NULL)
			  OR (@ItemNewProductCode IS NOT NULL) OR (@ItemNewCategory IS NOT NULL)
			  OR (@ItemNewVendor IS NOT NULL) OR (@ItemNewInventoryGroup IS NOT NULL)
			  OR (@ItemNewQuantityCase IS NOT NULL) OR (@ItemNewQuantitySellUnit IS NOT NULL)
			  OR (@ItemNewCountCode  IS NOT NULL) OR (@ItemNewItemSize IS NOT NULL))   
 				 set @SQL1 = @SQL1 + ' , stpbk_itemuom = ''' + LTRIM(@ItemNewItemUOM) + ''''
			  else
				 set @SQL1 = @SQL1 + ' stpbk_itemuom = ''' + LTRIM(@ItemNewItemUOM) + '''' 
			  END

		 if (@ItemNewMixMatch  IS NOT NULL)  
			  BEGIN
			  if ((@ItemTaxFlag1ysn IS NOT NULL) OR (@ItemTaxFlag2ysn IS NOT NULL)
			  OR (@ItemTaxFlag3ysn IS NOT NULL) OR (@ItemTaxFlag4ysn IS NOT NULL)
			  OR (@ItemDepositRequiredysn IS NOT NULL) OR (@ItemScaleItemysn IS NOT NULL)
			  OR (@ItemFoodStampableysn IS NOT NULL) OR (@ItemReturnableysn IS NOT NULL)
			  OR (@ItemSaleableysn IS NOT NULL) OR (@ItemID1Requiredysn IS NOT NULL)
			  OR (@ItemID2Requiredysn IS NOT NULL) OR (@ItemPromotionalItemysn IS NOT NULL)
			  OR (@ItemPrePricedysn IS NOT NULL) OR (@ItemActiveysn IS NOT NULL)
			  OR (@ItemBlueLaw1ysn IS NOT NULL) OR (@ItemBlueLaw2ysn IS NOT NULL)
			  OR (@ItemCountedDailyysn IS NOT NULL) OR (@ItemCountedysn  IS NOT NULL)
			  OR (@ItemCountSerialysn IS NOT NULL) OR (@ItemStickReadingysn  IS NOT NULL)
			  OR (@ItemNewFamily IS NOT NULL) OR (@ItemNewClass IS NOT NULL)
			  OR (@ItemNewProductCode IS NOT NULL) OR (@ItemNewCategory IS NOT NULL)
			  OR (@ItemNewVendor IS NOT NULL) OR (@ItemNewInventoryGroup IS NOT NULL)
			  OR (@ItemNewQuantityCase IS NOT NULL) OR (@ItemNewQuantitySellUnit IS NOT NULL)
			  OR (@ItemNewCountCode  IS NOT NULL) OR (@ItemNewItemSize IS NOT NULL)
			  OR (@ItemNewItemUOM IS NOT NULL))   
 				 set @SQL1 = @SQL1 + ' , stpbk_mixmatch_cd = ''' + LTRIM(@ItemNewMixMatch) + ''''
			  else
				 set @SQL1 = @SQL1 + ' stpbk_mixmatch_cd = ''' + LTRIM(@ItemNewMixMatch) + '''' 
			  END

		 if (@ItemNewMinAge IS NOT NULL)  
			  BEGIN
			  if ((@ItemTaxFlag1ysn IS NOT NULL) OR (@ItemTaxFlag2ysn IS NOT NULL)
			  OR (@ItemTaxFlag3ysn IS NOT NULL) OR (@ItemTaxFlag4ysn IS NOT NULL)
			  OR (@ItemDepositRequiredysn IS NOT NULL) OR (@ItemScaleItemysn IS NOT NULL)
			  OR (@ItemFoodStampableysn IS NOT NULL) OR (@ItemReturnableysn IS NOT NULL)
			  OR (@ItemSaleableysn IS NOT NULL) OR (@ItemID1Requiredysn IS NOT NULL)
			  OR (@ItemID2Requiredysn IS NOT NULL) OR (@ItemPromotionalItemysn IS NOT NULL)
			  OR (@ItemPrePricedysn IS NOT NULL) OR (@ItemActiveysn IS NOT NULL)
			  OR (@ItemBlueLaw1ysn IS NOT NULL) OR (@ItemBlueLaw2ysn IS NOT NULL)
			  OR (@ItemCountedDailyysn IS NOT NULL) OR (@ItemCountedysn  IS NOT NULL)
			  OR (@ItemCountSerialysn IS NOT NULL) OR (@ItemStickReadingysn  IS NOT NULL)
			  OR (@ItemNewFamily IS NOT NULL) OR (@ItemNewClass IS NOT NULL)
			  OR (@ItemNewProductCode IS NOT NULL) OR (@ItemNewCategory IS NOT NULL)
			  OR (@ItemNewVendor IS NOT NULL) OR (@ItemNewInventoryGroup IS NOT NULL)
			  OR (@ItemNewQuantityCase IS NOT NULL) OR (@ItemNewQuantitySellUnit IS NOT NULL)
			  OR (@ItemNewCountCode  IS NOT NULL) OR (@ItemNewItemSize IS NOT NULL)
			  OR (@ItemNewItemUOM IS NOT NULL) OR (@ItemNewMixMatch  IS NOT NULL))   
 				 set @SQL1 = @SQL1 + ' , stpbk_min_age = ''' + LTRIM(@ItemNewMinAge) + ''''
			  else
				 set @SQL1 = @SQL1 + ' stpbk_min_age = ''' + LTRIM(@ItemNewMinAge) + '''' 
			  END


		   if (@ItemNewItemType  IS NOT NULL)  
			  BEGIN
			  if ((@ItemTaxFlag1ysn IS NOT NULL) OR (@ItemTaxFlag2ysn IS NOT NULL)
			  OR (@ItemTaxFlag3ysn IS NOT NULL) OR (@ItemTaxFlag4ysn IS NOT NULL)
			  OR (@ItemDepositRequiredysn IS NOT NULL) OR (@ItemScaleItemysn IS NOT NULL)
			  OR (@ItemFoodStampableysn IS NOT NULL) OR (@ItemReturnableysn IS NOT NULL)
			  OR (@ItemSaleableysn IS NOT NULL) OR (@ItemID1Requiredysn IS NOT NULL)
			  OR (@ItemID2Requiredysn IS NOT NULL) OR (@ItemPromotionalItemysn IS NOT NULL)
			  OR (@ItemPrePricedysn IS NOT NULL) OR (@ItemActiveysn IS NOT NULL)
			  OR (@ItemBlueLaw1ysn IS NOT NULL) OR (@ItemBlueLaw2ysn IS NOT NULL)
			  OR (@ItemCountedDailyysn IS NOT NULL) OR (@ItemCountedysn  IS NOT NULL)
			  OR (@ItemCountSerialysn IS NOT NULL) OR (@ItemStickReadingysn  IS NOT NULL)
			  OR (@ItemNewFamily IS NOT NULL) OR (@ItemNewClass IS NOT NULL)
			  OR (@ItemNewProductCode IS NOT NULL) OR (@ItemNewCategory IS NOT NULL)
			  OR (@ItemNewVendor IS NOT NULL) OR (@ItemNewInventoryGroup IS NOT NULL)
			  OR (@ItemNewQuantityCase IS NOT NULL) OR (@ItemNewQuantitySellUnit IS NOT NULL)
			  OR (@ItemNewCountCode  IS NOT NULL) OR (@ItemNewItemSize IS NOT NULL)
			  OR (@ItemNewItemUOM IS NOT NULL) OR (@ItemNewMixMatch  IS NOT NULL)
			  OR (@ItemNewMinAge IS NOT NULL))   
 				 set @SQL1 = @SQL1 + ' , stpbk_pumped_yn = ''' + LTRIM(@ItemNewItemType) + ''''
			  else
				 set @SQL1 = @SQL1 + ' stpbk_pumped_yn = ''' + LTRIM(@ItemNewItemType) + '''' 
			  END

		   if (@ItemNewMinVendorOrderQty IS NOT NULL)  
			  BEGIN
			  if ((@ItemTaxFlag1ysn IS NOT NULL) OR (@ItemTaxFlag2ysn IS NOT NULL)
			  OR (@ItemTaxFlag3ysn IS NOT NULL) OR (@ItemTaxFlag4ysn IS NOT NULL)
			  OR (@ItemDepositRequiredysn IS NOT NULL) OR (@ItemScaleItemysn IS NOT NULL)
			  OR (@ItemFoodStampableysn IS NOT NULL) OR (@ItemReturnableysn IS NOT NULL)
			  OR (@ItemSaleableysn IS NOT NULL) OR (@ItemID1Requiredysn IS NOT NULL)
			  OR (@ItemID2Requiredysn IS NOT NULL) OR (@ItemPromotionalItemysn IS NOT NULL)
			  OR (@ItemPrePricedysn IS NOT NULL) OR (@ItemActiveysn IS NOT NULL)
			  OR (@ItemBlueLaw1ysn IS NOT NULL) OR (@ItemBlueLaw2ysn IS NOT NULL)
			  OR (@ItemCountedDailyysn IS NOT NULL) OR (@ItemCountedysn  IS NOT NULL)
			  OR (@ItemCountSerialysn IS NOT NULL) OR (@ItemStickReadingysn  IS NOT NULL)
			  OR (@ItemNewFamily IS NOT NULL) OR (@ItemNewClass IS NOT NULL)
			  OR (@ItemNewProductCode IS NOT NULL) OR (@ItemNewCategory IS NOT NULL)
			  OR (@ItemNewVendor IS NOT NULL) OR (@ItemNewInventoryGroup IS NOT NULL)
			  OR (@ItemNewQuantityCase IS NOT NULL) OR (@ItemNewQuantitySellUnit IS NOT NULL)
			  OR (@ItemNewCountCode  IS NOT NULL) OR (@ItemNewItemSize IS NOT NULL)
			  OR (@ItemNewItemUOM IS NOT NULL) OR (@ItemNewMixMatch  IS NOT NULL)
			  OR (@ItemNewMinAge IS NOT NULL) OR (@ItemNewItemType  IS NOT NULL))   
 				 set @SQL1 = @SQL1 + ' , stpbk_min_ord_qty = ''' + LTRIM(@ItemNewMinVendorOrderQty) + ''''
			  else
				 set @SQL1 = @SQL1 + ' stpbk_min_ord_qty = ''' + LTRIM(@ItemNewMinVendorOrderQty) + '''' 
			  END

		 if (@ItemNewVendorSuggestedQty IS NOT NULL)  
			  BEGIN
			  if ((@ItemTaxFlag1ysn IS NOT NULL) OR (@ItemTaxFlag2ysn IS NOT NULL)
			  OR (@ItemTaxFlag3ysn IS NOT NULL) OR (@ItemTaxFlag4ysn IS NOT NULL)
			  OR (@ItemDepositRequiredysn IS NOT NULL) OR (@ItemScaleItemysn IS NOT NULL)
			  OR (@ItemFoodStampableysn IS NOT NULL) OR (@ItemReturnableysn IS NOT NULL)
			  OR (@ItemSaleableysn IS NOT NULL) OR (@ItemID1Requiredysn IS NOT NULL)
			  OR (@ItemID2Requiredysn IS NOT NULL) OR (@ItemPromotionalItemysn IS NOT NULL)
			  OR (@ItemPrePricedysn IS NOT NULL) OR (@ItemActiveysn IS NOT NULL)
			  OR (@ItemBlueLaw1ysn IS NOT NULL) OR (@ItemBlueLaw2ysn IS NOT NULL)
			  OR (@ItemCountedDailyysn IS NOT NULL) OR (@ItemCountedysn  IS NOT NULL)
			  OR (@ItemCountSerialysn IS NOT NULL) OR (@ItemStickReadingysn  IS NOT NULL)
			  OR (@ItemNewFamily IS NOT NULL) OR (@ItemNewClass IS NOT NULL)
			  OR (@ItemNewProductCode IS NOT NULL) OR (@ItemNewCategory IS NOT NULL)
			  OR (@ItemNewVendor IS NOT NULL) OR (@ItemNewInventoryGroup IS NOT NULL)
			  OR (@ItemNewQuantityCase IS NOT NULL) OR (@ItemNewQuantitySellUnit IS NOT NULL)
			  OR (@ItemNewCountCode  IS NOT NULL) OR (@ItemNewItemSize IS NOT NULL)
			  OR (@ItemNewItemUOM IS NOT NULL) OR (@ItemNewMixMatch  IS NOT NULL)
			  OR (@ItemNewMinAge IS NOT NULL) OR (@ItemNewItemType  IS NOT NULL)
			  OR (@ItemNewMinVendorOrderQty IS NOT NULL))   
 				 set @SQL1 = @SQL1 + ' , stpbk_sug_qty = ''' + LTRIM(@ItemNewVendorSuggestedQty) + ''''
			  else
				 set @SQL1 = @SQL1 + ' stpbk_sug_qty = ''' + LTRIM(@ItemNewVendorSuggestedQty) + '''' 
			  END

		  if (@ItemNewMinQtyOnHand  IS NOT NULL)  
			  BEGIN
			  if ((@ItemTaxFlag1ysn IS NOT NULL) OR (@ItemTaxFlag2ysn IS NOT NULL)
			  OR (@ItemTaxFlag3ysn IS NOT NULL) OR (@ItemTaxFlag4ysn IS NOT NULL)
			  OR (@ItemDepositRequiredysn IS NOT NULL) OR (@ItemScaleItemysn IS NOT NULL)
			  OR (@ItemFoodStampableysn IS NOT NULL) OR (@ItemReturnableysn IS NOT NULL)
			  OR (@ItemSaleableysn IS NOT NULL) OR (@ItemID1Requiredysn IS NOT NULL)
			  OR (@ItemID2Requiredysn IS NOT NULL) OR (@ItemPromotionalItemysn IS NOT NULL)
			  OR (@ItemPrePricedysn IS NOT NULL) OR (@ItemActiveysn IS NOT NULL)
			  OR (@ItemBlueLaw1ysn IS NOT NULL) OR (@ItemBlueLaw2ysn IS NOT NULL)
			  OR (@ItemCountedDailyysn IS NOT NULL) OR (@ItemCountedysn  IS NOT NULL)
			  OR (@ItemCountSerialysn IS NOT NULL) OR (@ItemStickReadingysn  IS NOT NULL)
			  OR (@ItemNewFamily IS NOT NULL) OR (@ItemNewClass IS NOT NULL)
			  OR (@ItemNewProductCode IS NOT NULL) OR (@ItemNewCategory IS NOT NULL)
			  OR (@ItemNewVendor IS NOT NULL) OR (@ItemNewInventoryGroup IS NOT NULL)
			  OR (@ItemNewQuantityCase IS NOT NULL) OR (@ItemNewQuantitySellUnit IS NOT NULL)
			  OR (@ItemNewCountCode  IS NOT NULL) OR (@ItemNewItemSize IS NOT NULL)
			  OR (@ItemNewItemUOM IS NOT NULL) OR (@ItemNewMixMatch  IS NOT NULL)
			  OR (@ItemNewMinAge IS NOT NULL) OR (@ItemNewItemType  IS NOT NULL)
			  OR (@ItemNewMinVendorOrderQty IS NOT NULL) OR (@ItemNewVendorSuggestedQty IS NOT NULL))   
 				 set @SQL1 = @SQL1 + ' , stpbk_min_qty = ''' + LTRIM(@ItemNewMinQtyOnHand) + ''''
			  else
				 set @SQL1 = @SQL1 + ' stpbk_min_qty = ''' + LTRIM(@ItemNewMinQtyOnHand) + '''' 
			  END

		 if (@ItemNewBinLocation  IS NOT NULL)  
			  BEGIN
			  if ((@ItemTaxFlag1ysn IS NOT NULL) OR (@ItemTaxFlag2ysn IS NOT NULL)
			  OR (@ItemTaxFlag3ysn IS NOT NULL) OR (@ItemTaxFlag4ysn IS NOT NULL)
			  OR (@ItemDepositRequiredysn IS NOT NULL) OR (@ItemScaleItemysn IS NOT NULL)
			  OR (@ItemFoodStampableysn IS NOT NULL) OR (@ItemReturnableysn IS NOT NULL)
			  OR (@ItemSaleableysn IS NOT NULL) OR (@ItemID1Requiredysn IS NOT NULL)
			  OR (@ItemID2Requiredysn IS NOT NULL) OR (@ItemPromotionalItemysn IS NOT NULL)
			  OR (@ItemPrePricedysn IS NOT NULL) OR (@ItemActiveysn IS NOT NULL)
			  OR (@ItemBlueLaw1ysn IS NOT NULL) OR (@ItemBlueLaw2ysn IS NOT NULL)
			  OR (@ItemCountedDailyysn IS NOT NULL) OR (@ItemCountedysn  IS NOT NULL)
			  OR (@ItemCountSerialysn IS NOT NULL) OR (@ItemStickReadingysn  IS NOT NULL)
			  OR (@ItemNewFamily IS NOT NULL) OR (@ItemNewClass IS NOT NULL)
			  OR (@ItemNewProductCode IS NOT NULL) OR (@ItemNewCategory IS NOT NULL)
			  OR (@ItemNewVendor IS NOT NULL) OR (@ItemNewInventoryGroup IS NOT NULL)
			  OR (@ItemNewQuantityCase IS NOT NULL) OR (@ItemNewQuantitySellUnit IS NOT NULL)
			  OR (@ItemNewCountCode  IS NOT NULL) OR (@ItemNewItemSize IS NOT NULL)
			  OR (@ItemNewItemUOM IS NOT NULL) OR (@ItemNewMixMatch  IS NOT NULL)
			  OR (@ItemNewMinAge IS NOT NULL) OR (@ItemNewItemType  IS NOT NULL)
			  OR (@ItemNewMinVendorOrderQty IS NOT NULL) OR (@ItemNewVendorSuggestedQty IS NOT NULL)
			  OR (@ItemNewMinQtyOnHand  IS NOT NULL))   
 				 set @SQL1 = @SQL1 + ' , stpbk_binloc = ''' + LTRIM(@ItemNewBinLocation) + ''''
			  else
				 set @SQL1 = @SQL1 + ' stpbk_binloc = ''' + LTRIM(@ItemNewBinLocation) + '''' 
			  END

		  if (@ItemNewGLPurchaseAccount IS NOT NULL)  
			  BEGIN
			  set @ItemNewGLPurchaseAccount = REPLACE(@ItemNewGLPurchaseAccount, '-','') 
			  if ((@ItemTaxFlag1ysn IS NOT NULL) OR (@ItemTaxFlag2ysn IS NOT NULL)
			  OR (@ItemTaxFlag3ysn IS NOT NULL) OR (@ItemTaxFlag4ysn IS NOT NULL)
			  OR (@ItemDepositRequiredysn IS NOT NULL) OR (@ItemScaleItemysn IS NOT NULL)
			  OR (@ItemFoodStampableysn IS NOT NULL) OR (@ItemReturnableysn IS NOT NULL)
			  OR (@ItemSaleableysn IS NOT NULL) OR (@ItemID1Requiredysn IS NOT NULL)
			  OR (@ItemID2Requiredysn IS NOT NULL) OR (@ItemPromotionalItemysn IS NOT NULL)
			  OR (@ItemPrePricedysn IS NOT NULL) OR (@ItemActiveysn IS NOT NULL)
			  OR (@ItemBlueLaw1ysn IS NOT NULL) OR (@ItemBlueLaw2ysn IS NOT NULL)
			  OR (@ItemCountedDailyysn IS NOT NULL) OR (@ItemCountedysn  IS NOT NULL)
			  OR (@ItemCountSerialysn IS NOT NULL) OR (@ItemStickReadingysn  IS NOT NULL)
			  OR (@ItemNewFamily IS NOT NULL) OR (@ItemNewClass IS NOT NULL)
			  OR (@ItemNewProductCode IS NOT NULL) OR (@ItemNewCategory IS NOT NULL)
			  OR (@ItemNewVendor IS NOT NULL) OR (@ItemNewInventoryGroup IS NOT NULL)
			  OR (@ItemNewQuantityCase IS NOT NULL) OR (@ItemNewQuantitySellUnit IS NOT NULL)
			  OR (@ItemNewCountCode  IS NOT NULL) OR (@ItemNewItemSize IS NOT NULL)
			  OR (@ItemNewItemUOM IS NOT NULL) OR (@ItemNewMixMatch  IS NOT NULL)
			  OR (@ItemNewMinAge IS NOT NULL) OR (@ItemNewItemType  IS NOT NULL)
			  OR (@ItemNewMinVendorOrderQty IS NOT NULL) OR (@ItemNewVendorSuggestedQty IS NOT NULL)
			  OR (@ItemNewMinQtyOnHand  IS NOT NULL) OR (@ItemNewBinLocation  IS NOT NULL))   
 				 set @SQL1 = @SQL1 + ' , stpbk_gl_pur_acct = ''' + CONVERT(NVARCHAR,(@ItemNewGLPurchaseAccount)) + ''''
			  else
				 set @SQL1 = @SQL1 + ' stpbk_gl_pur_acct = ''' + CONVERT(NVARCHAR,(@ItemNewGLPurchaseAccount)) + '''' 
			  END

		  if (@ItemNewGLSalesAccount  IS NOT NULL)  
			  BEGIN
			  set @ItemNewGLSalesAccount = REPLACE(@ItemNewGLSalesAccount, '-','') 
			  if ((@ItemTaxFlag1ysn IS NOT NULL) OR (@ItemTaxFlag2ysn IS NOT NULL)
			  OR (@ItemTaxFlag3ysn IS NOT NULL) OR (@ItemTaxFlag4ysn IS NOT NULL)
			  OR (@ItemDepositRequiredysn IS NOT NULL) OR (@ItemScaleItemysn IS NOT NULL)
			  OR (@ItemFoodStampableysn IS NOT NULL) OR (@ItemReturnableysn IS NOT NULL)
			  OR (@ItemSaleableysn IS NOT NULL) OR (@ItemID1Requiredysn IS NOT NULL)
			  OR (@ItemID2Requiredysn IS NOT NULL) OR (@ItemPromotionalItemysn IS NOT NULL)
			  OR (@ItemPrePricedysn IS NOT NULL) OR (@ItemActiveysn IS NOT NULL)
			  OR (@ItemBlueLaw1ysn IS NOT NULL) OR (@ItemBlueLaw2ysn IS NOT NULL)
			  OR (@ItemCountedDailyysn IS NOT NULL) OR (@ItemCountedysn  IS NOT NULL)
			  OR (@ItemCountSerialysn IS NOT NULL) OR (@ItemStickReadingysn  IS NOT NULL)
			  OR (@ItemNewFamily IS NOT NULL) OR (@ItemNewClass IS NOT NULL)
			  OR (@ItemNewProductCode IS NOT NULL) OR (@ItemNewCategory IS NOT NULL)
			  OR (@ItemNewVendor IS NOT NULL) OR (@ItemNewInventoryGroup IS NOT NULL)
			  OR (@ItemNewQuantityCase IS NOT NULL) OR (@ItemNewQuantitySellUnit IS NOT NULL)
			  OR (@ItemNewCountCode  IS NOT NULL) OR (@ItemNewItemSize IS NOT NULL)
			  OR (@ItemNewItemUOM IS NOT NULL) OR (@ItemNewMixMatch  IS NOT NULL)
			  OR (@ItemNewMinAge IS NOT NULL) OR (@ItemNewItemType  IS NOT NULL)
			  OR (@ItemNewMinVendorOrderQty IS NOT NULL) OR (@ItemNewVendorSuggestedQty IS NOT NULL)
			  OR (@ItemNewMinQtyOnHand  IS NOT NULL) OR (@ItemNewBinLocation  IS NOT NULL)
			  OR (@ItemNewGLPurchaseAccount IS NOT NULL))   
 				 set @SQL1 = @SQL1 + ' , stpbk_gl_sls_acct = ''' + CONVERT(NVARCHAR,(@ItemNewGLSalesAccount)) + ''''
			  else
				 set @SQL1 = @SQL1 + ' stpbk_gl_sls_acct = ''' + CONVERT(NVARCHAR,(@ItemNewGLSalesAccount)) + '''' 
			  END

		 if (@ItemNewGLVarianceAccount  IS NOT NULL)  
			  BEGIN
			  set @ItemNewGLVarianceAccount = REPLACE(@ItemNewGLVarianceAccount, '-','') 
			  if ((@ItemTaxFlag1ysn IS NOT NULL) OR (@ItemTaxFlag2ysn IS NOT NULL)
			  OR (@ItemTaxFlag3ysn IS NOT NULL) OR (@ItemTaxFlag4ysn IS NOT NULL)
			  OR (@ItemDepositRequiredysn IS NOT NULL) OR (@ItemScaleItemysn IS NOT NULL)
			  OR (@ItemFoodStampableysn IS NOT NULL) OR (@ItemReturnableysn IS NOT NULL)
			  OR (@ItemSaleableysn IS NOT NULL) OR (@ItemID1Requiredysn IS NOT NULL)
			  OR (@ItemID2Requiredysn IS NOT NULL) OR (@ItemPromotionalItemysn IS NOT NULL)
			  OR (@ItemPrePricedysn IS NOT NULL) OR (@ItemActiveysn IS NOT NULL)
			  OR (@ItemBlueLaw1ysn IS NOT NULL) OR (@ItemBlueLaw2ysn IS NOT NULL)
			  OR (@ItemCountedDailyysn IS NOT NULL) OR (@ItemCountedysn  IS NOT NULL)
			  OR (@ItemCountSerialysn IS NOT NULL) OR (@ItemStickReadingysn  IS NOT NULL)
			  OR (@ItemNewFamily IS NOT NULL) OR (@ItemNewClass IS NOT NULL)
			  OR (@ItemNewProductCode IS NOT NULL) OR (@ItemNewCategory IS NOT NULL)
			  OR (@ItemNewVendor IS NOT NULL) OR (@ItemNewInventoryGroup IS NOT NULL)
			  OR (@ItemNewQuantityCase IS NOT NULL) OR (@ItemNewQuantitySellUnit IS NOT NULL)
			  OR (@ItemNewCountCode  IS NOT NULL) OR (@ItemNewItemSize IS NOT NULL)
			  OR (@ItemNewItemUOM IS NOT NULL) OR (@ItemNewMixMatch  IS NOT NULL)
			  OR (@ItemNewMinAge IS NOT NULL) OR (@ItemNewItemType  IS NOT NULL)
			  OR (@ItemNewMinVendorOrderQty IS NOT NULL) OR (@ItemNewVendorSuggestedQty IS NOT NULL)
			  OR (@ItemNewMinQtyOnHand  IS NOT NULL) OR (@ItemNewBinLocation  IS NOT NULL)
			  OR (@ItemNewGLPurchaseAccount IS NOT NULL) OR (@ItemNewGLSalesAccount  IS NOT NULL))   
 				 set @SQL1 = @SQL1 + ' , stpbk_gl_var_acct = ''' + CONVERT(NVARCHAR,(@ItemNewGLVarianceAccount)) + ''''
			  else
				 set @SQL1 = @SQL1 + ' stpbk_gl_var_acct = ''' + CONVERT(NVARCHAR,(@ItemNewGLVarianceAccount)) + '''' 
			  END
	 
	    if (@ItemDepositPLU IS NOT NULL)  
			  BEGIN
			  if ((@ItemTaxFlag1ysn IS NOT NULL) OR (@ItemTaxFlag2ysn IS NOT NULL)
			  OR (@ItemTaxFlag3ysn IS NOT NULL) OR (@ItemTaxFlag4ysn IS NOT NULL)
			  OR (@ItemDepositRequiredysn IS NOT NULL) OR (@ItemScaleItemysn IS NOT NULL)
			  OR (@ItemFoodStampableysn IS NOT NULL) OR (@ItemReturnableysn IS NOT NULL)
			  OR (@ItemSaleableysn IS NOT NULL) OR (@ItemID1Requiredysn IS NOT NULL)
			  OR (@ItemID2Requiredysn IS NOT NULL) OR (@ItemPromotionalItemysn IS NOT NULL)
			  OR (@ItemPrePricedysn IS NOT NULL) OR (@ItemActiveysn IS NOT NULL)
			  OR (@ItemBlueLaw1ysn IS NOT NULL) OR (@ItemBlueLaw2ysn IS NOT NULL)
			  OR (@ItemCountedDailyysn IS NOT NULL) OR (@ItemCountedysn  IS NOT NULL)
			  OR (@ItemCountSerialysn IS NOT NULL) OR (@ItemStickReadingysn  IS NOT NULL)
			  OR (@ItemNewFamily IS NOT NULL) OR (@ItemNewClass IS NOT NULL)
			  OR (@ItemNewProductCode IS NOT NULL) OR (@ItemNewCategory IS NOT NULL)
			  OR (@ItemNewVendor IS NOT NULL) OR (@ItemNewInventoryGroup IS NOT NULL)
			  OR (@ItemNewQuantityCase IS NOT NULL) OR (@ItemNewQuantitySellUnit IS NOT NULL)
			  OR (@ItemNewCountCode  IS NOT NULL) OR (@ItemNewItemSize IS NOT NULL)
			  OR (@ItemNewItemUOM IS NOT NULL) OR (@ItemNewMixMatch  IS NOT NULL)
			  OR (@ItemNewMinAge IS NOT NULL) OR (@ItemNewItemType  IS NOT NULL)
			  OR (@ItemNewMinVendorOrderQty IS NOT NULL) OR (@ItemNewVendorSuggestedQty IS NOT NULL)
			  OR (@ItemNewMinQtyOnHand  IS NOT NULL) OR (@ItemNewBinLocation  IS NOT NULL)
			  OR (@ItemNewGLPurchaseAccount IS NOT NULL) OR (@ItemNewGLSalesAccount  IS NOT NULL)
			  OR (@ItemNewGLVarianceAccount IS NOT NULL))   
 				 set @SQL1 = @SQL1 + ' , stpbk_lnk_upcno = ''' + CONVERT(NVARCHAR,(@ItemDepositPLU)) + ''''
			  else
				 set @SQL1 = @SQL1 + ' stpbk_lnk_upcno = ''' + CONVERT(NVARCHAR,(@ItemDepositPLU)) + '''' 
			  END
	 
	      if (@ItemQuantityRequiredysn IS NOT NULL)  
			  BEGIN
			  if ((@ItemTaxFlag1ysn IS NOT NULL) OR (@ItemTaxFlag2ysn IS NOT NULL)
			  OR (@ItemTaxFlag3ysn IS NOT NULL) OR (@ItemTaxFlag4ysn IS NOT NULL)
			  OR (@ItemDepositRequiredysn IS NOT NULL) OR (@ItemScaleItemysn IS NOT NULL)
			  OR (@ItemFoodStampableysn IS NOT NULL) OR (@ItemReturnableysn IS NOT NULL)
			  OR (@ItemSaleableysn IS NOT NULL) OR (@ItemID1Requiredysn IS NOT NULL)
			  OR (@ItemID2Requiredysn IS NOT NULL) OR (@ItemPromotionalItemysn IS NOT NULL)
			  OR (@ItemPrePricedysn IS NOT NULL) OR (@ItemActiveysn IS NOT NULL)
			  OR (@ItemBlueLaw1ysn IS NOT NULL) OR (@ItemBlueLaw2ysn IS NOT NULL)
			  OR (@ItemCountedDailyysn IS NOT NULL) OR (@ItemCountedysn  IS NOT NULL)
			  OR (@ItemCountSerialysn IS NOT NULL) OR (@ItemStickReadingysn  IS NOT NULL)
			  OR (@ItemNewFamily IS NOT NULL) OR (@ItemNewClass IS NOT NULL)
			  OR (@ItemNewProductCode IS NOT NULL) OR (@ItemNewCategory IS NOT NULL)
			  OR (@ItemNewVendor IS NOT NULL) OR (@ItemNewInventoryGroup IS NOT NULL)
			  OR (@ItemNewQuantityCase IS NOT NULL) OR (@ItemNewQuantitySellUnit IS NOT NULL)
			  OR (@ItemNewCountCode  IS NOT NULL) OR (@ItemNewItemSize IS NOT NULL)
			  OR (@ItemNewItemUOM IS NOT NULL) OR (@ItemNewMixMatch  IS NOT NULL)
			  OR (@ItemNewMinAge IS NOT NULL) OR (@ItemNewItemType  IS NOT NULL)
			  OR (@ItemNewMinVendorOrderQty IS NOT NULL) OR (@ItemNewVendorSuggestedQty IS NOT NULL)
			  OR (@ItemNewMinQtyOnHand  IS NOT NULL) OR (@ItemNewBinLocation  IS NOT NULL)
			  OR (@ItemNewGLPurchaseAccount IS NOT NULL) OR (@ItemNewGLSalesAccount  IS NOT NULL)
			  OR (@ItemNewGLVarianceAccount IS NOT NULL) OR (@ItemDepositPLU IS NOT NULL))   
 				 set @SQL1 = @SQL1 + ' , stpbk_qty_req_yn = ''' + LTRIM(@ItemQuantityRequiredysn) + '''' 
			  else
				 set @SQL1 = @SQL1 + ' stpbk_qty_req_yn = ''' + LTRIM(@ItemQuantityRequiredysn) + '''' 
			  END
	     
		  set @SQL1 = @SQL1 + ' where 1=1 ' 

		  if (@ItemLocation IS NOT NULL)
			 BEGIN 
			   set @SQL1 = @SQL1 +  ' and  stpbk_store_name IN 
				 (''' + replace((SELECT (CAST(@ItemLocation AS NVARCHAR(MAX)))),',',''',''') +''')'
			 END
       
		  if (@ItemVendor IS NOT NULL)
			  BEGIN
				set @SQL1 = @SQL1 +  ' and  stpbk_vnd_id IN 
				 (''' + replace((SELECT (CAST(@ItemVendor AS NVARCHAR(MAX)))),', ',''',''') +''')'
			  END
         
		  if (@ItemCategory IS NOT NULL)
			  BEGIN
     			set @SQL1 = @SQL1 +  ' and  stpbk_deptno IN 
				 (''' + replace((SELECT (CAST(@ItemCategory AS NVARCHAR(MAX)))),',',''',''') +''')'
			  END
           
  		  if (@ItemFamily IS NOT NULL)
			  BEGIN
  			   set @SQL1 = @SQL1 +  ' and  stpbk_family IN 
				 (''' + replace((SELECT (CAST(@ItemFamily AS NVARCHAR(MAX)))),',',''',''') +''')'
			  END
    
		  if (@ItemClass  IS NOT NULL)
			  BEGIN
			   set @SQL1 = @SQL1 +  ' and  stpbk_class IN 
				 (''' + replace((SELECT (CAST(@ItemClass AS NVARCHAR(MAX)))),',',''',''') +''')'
			  END
    
		  if (@ItemUpcCode IS NOT NULL)
			 BEGIN
				set @SQL1 = @SQL1 +  ' and  stpbk_upcno IN 
				 (''' + replace((SELECT (CAST(@ItemUpcCode AS NVARCHAR(MAX)))),',',''',''') +''')'
			  END

	    
		  if ((@ItemDescription IS NOT NULL) and (RTRIM (LTRIM(@ItemDescription)) != ''))
			   BEGIN
				 set @SQL1 = @SQL1 +  ' and  stpbk_item_desc like ''%' + LTRIM(@ItemDescription) + '%'''
			   END
			  
		  if (@ItemPriceBetween1 IS NOT NULL) 
		      BEGIN
		       set @SQL1 = @SQL1 +  ' and  stpbk_price >= ''' + CONVERT(NVARCHAR,(@ItemPriceBetween1)) + '''' 
		      END 
		      
          if (@ItemPriceBetween2 IS NOT NULL) 
		      BEGIN
		       set @SQL1 = @SQL1 +  ' and  stpbk_price <= ''' + CONVERT(NVARCHAR,(@ItemPriceBetween2)) + '''' 
		      END 		      
		    
		  exec (@SQL1)
		  select (@@ROWCOUNT)
      

	END TRY

	BEGIN CATCH       
	 SET @ErrMsg = ERROR_MESSAGE()      
	 IF @idoc <> 0 EXEC sp_xml_removedocument @idoc      
	 RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')      
	END CATCH




