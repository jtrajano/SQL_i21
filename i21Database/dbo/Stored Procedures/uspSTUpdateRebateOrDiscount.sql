CREATE PROCEDURE [dbo].[uspSTUpdateRebateOrDiscount]
	@XML varchar(max)
	
AS
BEGIN TRY

	DECLARE @ErrMsg					NVARCHAR(MAX),
	        @idoc					INT,
	    	@Location 			    NVARCHAR(MAX),
			@Vendor                 NVARCHAR(MAX),
			@Category               NVARCHAR(MAX),
			@Family                 NVARCHAR(MAX),
			@Class                  NVARCHAR(MAX),
			@PromotionType          NVARCHAR(50),
			@BeginDate   			DATETIME,
			@EndDate		 	    DATETIME,
		    @RebateAmount           DECIMAL (18,6),
			@AccumlatedQty          INT,
			@AccumAmount            DECIMAL (18,6),
			@DiscThroughAmount      DECIMAL (18,6),
			@DiscThroughQty         INT,
			@DiscAmountUnit         DECIMAL (18,6)
		
	                  
	EXEC sp_xml_preparedocument @idoc OUTPUT, @XML 
	
	SELECT	
			@Location	   	    =	Location,
            @Vendor             =   Vendor,
			@Category           =   Category,
			@Family             =   Family,
            @Class              =   Class,
			@PromotionType      =   PromotionTypeValue, 
			@BeginDate          =   BeginingDate,
			@EndDate            =   EndingDate,
			@RebateAmount 	    =	RebateAmount,
			@AccumlatedQty	    =	AccumlatedQuantity,
			@AccumAmount	    =	AccumlatedAmount,
		    @DiscThroughAmount  =   DiscThroughAmount,
			@DiscThroughQty     =   DiscThroughQty,
			@DiscAmountUnit     =   DiscAmountUnit
		
	FROM	OPENXML(@idoc, 'root',2)
	WITH
	(
			Location		        NVARCHAR(MAX),
			Vendor	     	        NVARCHAR(MAX),
			Category		        NVARCHAR(MAX),
			Family	     	        NVARCHAR(MAX),
			Class	     	        NVARCHAR(MAX),
			PromotionTypeValue      NVARCHAR(50),
			BeginingDate            DATETIME,     
			EndingDate              DATETIME,
			RebateAmount		    DECIMAL (18,6),
			AccumlatedQuantity		INT,
			AccumlatedAmount        DECIMAL (18,6),
			DiscThroughAmount       DECIMAL (18,6),
			DiscThroughQty          INT,
			DiscAmountUnit          DECIMAL (18,6)
	)  
    -- Insert statements for procedure here

      DECLARE @SQL1 NVARCHAR(MAX)

	  DECLARE @UpdateCount INT

	  set @UpdateCount = 0
      
	  IF (@PromotionType = 'Vendor Rebate')
	  BEGIN
	       set @SQL1 = ' update tblICItemSpecialPricing set '    
	  
	       IF (@BeginDate IS NOT NULL)
	       BEGIN
	         set @SQL1 = @SQL1 + ' dtmBeginDate = ''' + LTRIM(@BeginDate) + '''' 
	       END

	       IF (@EndDate IS NOT NULL)
	       BEGIN
   	           IF (@BeginDate IS NOT NULL)
                   set @SQL1 = @SQL1 + ' , dtmEndDate = ''' + LTRIM(@EndDate) + ''''
               else
                   set @SQL1 = @SQL1 + ' dtmEndDate = ''' + LTRIM(@EndDate) + '''' 
	       END

	       IF (@RebateAmount IS NOT NULL)
	       BEGIN
	            IF ((@BeginDate IS NOT NULL)
		        OR (@EndDate IS NOT NULL))
                    set @SQL1 = @SQL1 + ' , dblDiscount = ''' + LTRIM(@RebateAmount) + ''''
                else
                     set @SQL1 = @SQL1 + ' dblDiscount = ''' + LTRIM(@RebateAmount) + '''' 
	       END

	       IF (@AccumAmount IS NOT NULL)
	       BEGIN
	           IF ((@BeginDate IS NOT NULL)
		       OR (@EndDate IS NOT NULL)
		       OR (@RebateAmount IS NOT NULL))
                  set @SQL1 = @SQL1 + ' , dblAccumulatedAmount = ''' + LTRIM(@AccumAmount) + ''''
               else
                  set @SQL1 = @SQL1 + ' dblAccumulatedAmount = ''' + LTRIM(@AccumAmount) + '''' 
	       END

	       IF (@AccumlatedQty IS NOT NULL)
	       BEGIN
	           IF ((@BeginDate IS NOT NULL)
		       OR (@EndDate IS NOT NULL)
		       OR (@RebateAmount IS NOT NULL)
		       OR (@AccumAmount IS NOT NULL))
                   set @SQL1 = @SQL1 + ' , dblAccumulatedQty = ''' + LTRIM(@AccumlatedQty) + ''''
               else
                   set @SQL1 = @SQL1 + ' dblAccumulatedQty = ''' + LTRIM(@AccumlatedQty) + '''' 
	       END
        END

        IF (@PromotionType = 'Vendor Discount')
	    BEGIN
	       set @SQL1 = ' update tblICItemSpecialPricing set '    
	  
	       IF (@BeginDate IS NOT NULL)
	       BEGIN
	         set @SQL1 = @SQL1 + ' dtmBeginDate = ''' + LTRIM(@BeginDate) + '''' 
	       END

	       IF (@EndDate IS NOT NULL)
	       BEGIN
   	           IF (@BeginDate IS NOT NULL)
                   set @SQL1 = @SQL1 + ' , dtmEndDate = ''' + LTRIM(@EndDate) + ''''
               else
                   set @SQL1 = @SQL1 + ' dtmEndDate = ''' + LTRIM(@EndDate) + '''' 
	       END

	       IF (@DiscAmountUnit IS NOT NULL)
	       BEGIN
	            IF ((@BeginDate IS NOT NULL)
		        OR (@EndDate IS NOT NULL))
                    set @SQL1 = @SQL1 + ' , dblDiscount = ''' + LTRIM(@DiscAmountUnit) + ''''
                else
                     set @SQL1 = @SQL1 + ' dblDiscount = ''' + LTRIM(@DiscAmountUnit) + '''' 
	       END

	       IF (@DiscThroughAmount IS NOT NULL)
	       BEGIN
	           IF ((@BeginDate IS NOT NULL)
		       OR (@EndDate IS NOT NULL)
		       OR (@DiscAmountUnit IS NOT NULL))
                  set @SQL1 = @SQL1 + ' , dblDiscountThruAmount = ''' + LTRIM(@DiscThroughAmount) + ''''
               else
                  set @SQL1 = @SQL1 + ' dblDiscountThruAmount = ''' + LTRIM(@DiscThroughAmount) + '''' 
	       END

	       IF (@DiscThroughQty IS NOT NULL)
	       BEGIN
	           IF ((@BeginDate IS NOT NULL)
		       OR (@EndDate IS NOT NULL)
		       OR (@DiscAmountUnit IS NOT NULL)
		       OR (@DiscThroughAmount IS NOT NULL))
                   set @SQL1 = @SQL1 + ' , dblDiscountThruQty = ''' + LTRIM(@DiscThroughQty) + ''''
               else
                   set @SQL1 = @SQL1 + ' dblDiscountThruQty = ''' + LTRIM(@DiscThroughQty) + '''' 
	       END
        END

		set @SQL1 = @SQL1 + ' where 1=1 ' 

		IF (@Location IS NOT NULL)
		    BEGIN 
		         set @SQL1 = @SQL1 +  ' and  tblICItemSpecialPricing.intItemLocationId
		         IN (select intItemLocationId from tblICItemLocation where intLocationId
		         IN (select intLocationId from tblICItemLocation where intLocationId
		   	     IN (' + CAST(@Location as NVARCHAR) + ')' + '))'
		     END

	     IF (@Vendor IS NOT NULL)
		     BEGIN 
		           set @SQL1 = @SQL1 +  ' and  tblICItemSpecialPricing.intItemLocationId
		           IN (select intItemLocationId from tblICItemLocation where intVendorId
		           IN (select intEntityId from tblEntity where intEntityId 
			       IN (' + CAST(@Vendor as NVARCHAR) + ')' + '))'
		     END

	     IF (@Category IS NOT NULL)
		      BEGIN
     	             set @SQL1 = @SQL1 +  ' and tblICItemSpecialPricing.intItemId  
		              IN (select intItemId from tblICItem where intCategoryId IN
			          (select intCategoryId from tblICCategory where intCategoryId
			          IN (' + CAST(@Category as NVARCHAR) + ')' + '))'
		       END

		 IF (@Family IS NOT NULL)
		     BEGIN
  			        set @SQL1 = @SQL1 +  ' and tblICItemSpecialPricing.intItemLocationId IN 
			        (select intItemLocationId from tblICItemLocation where intFamilyId IN
			        (select intFamilyId from tblICItemLocation where intFamilyId 
			        IN (' + CAST(@Family as NVARCHAR) + ')' + '))'
		      END

		 IF (@Class IS NOT NULL)
		     BEGIN
		            set @SQL1 = @SQL1 +  ' and tblICItemSpecialPricing.intItemLocationId IN 
		           (select intItemLocationId from tblICItemLocation where intClassId IN
		 	       (select intClassId from tblICItemLocation where intClassId 
			        IN (' + CAST(@Class as NVARCHAR) + ')' + '))'
		     END

         IF (@PromotionType = 'Vendor Rebate')
		     BEGIN
                 set @SQL1 = @SQL1 + ' and  strPromotionType = ''Rebate''' 
			 END
              
         IF (@PromotionType = 'Vendor Discount')
		     BEGIN
                 set @SQL1 = @SQL1 + ' and  strPromotionType = ''Vendor Discount''' 
			 END
             

		 exec (@SQL1)
	     select  @UpdateCount = (@@ROWCOUNT)   
		 select @UpdateCount as UpdateRebateOrDiscountCount

END TRY

BEGIN CATCH       
 SET @ErrMsg = ERROR_MESSAGE()      
 IF @idoc <> 0 EXEC sp_xml_removedocument @idoc      
 RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')      
END CATCH