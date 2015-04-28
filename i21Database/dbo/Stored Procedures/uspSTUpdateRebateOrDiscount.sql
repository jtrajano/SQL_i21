CREATE PROCEDURE [dbo].[uspSTUpdateRebateOrDiscount]
	-- Add the parameters for the stored procedure here
	@XML varchar(max)
	
AS
BEGIN TRY

    SET QUOTED_IDENTIFIER OFF
    SET ANSI_NULLS ON
    SET NOCOUNT ON
    SET XACT_ABORT ON
    SET ANSI_WARNINGS OFF

	DECLARE @ErrMsg					NVARCHAR(MAX),
	        @idoc					INT,
	    	@ItemLocation 			NVARCHAR(MAX),
			@ItemVendor             NVARCHAR(MAX),
			@ItemCategory           NVARCHAR(MAX),
			@ItemFamily             NVARCHAR(MAX),
			@ItemClass              NVARCHAR(MAX),
			@PromotionType          NVARCHAR(8),
			@BeginDate   			DATETIME,
			@EndDate		 	    DATETIME,
		    @ItemRebateAmount       DECIMAL (11,6),
			@ItemAccumlatedQty      INT,
			@ItemAccumAmount        DECIMAL (7,2),
			@ItemQuantity           INT,
			@ItemUom                NVARCHAR(10),
			@SalesStartDate		    DATETIME,
			@SalesEndDate   		DATETIME,
			@ItemDiscThroughAmount  DECIMAL (7,2),
			@ItemDiscThroughQty     INT,
			@ItemDiscAmountUnit     DECIMAL (11,6)
		
	                  
	EXEC sp_xml_preparedocument @idoc OUTPUT, @XML 
	
	SELECT	
			@ItemLocation		=	Location,
            @ItemVendor         =   Vendor,
			@ItemCategory       =   Category,
			@ItemFamily         =   Family,
            @ItemClass          =   Class,
			@PromotionType      =   PromotionTypeValue, 
			@BeginDate          =   BeginingDate,
			@EndDate            =   EndingDate,
			@ItemRebateAmount	=	RebateAmount,
			@ItemAccumlatedQty	=	AccumlatedQuantity,
			@ItemAccumAmount	=	AccumlatedAmount,
			@ItemQuantity		=	QuantityCase,
			@ItemUom		    =	UOM,
			@SalesStartDate		=	SalesStartingDate,
			@SalesEndDate		=	SalesEndingDate,
			@ItemDiscThroughAmount = DiscThroughAmount,
			@ItemDiscThroughQty = DiscThroughQty,
			@ItemDiscAmountUnit = DiscAmountUnit
		
	FROM	OPENXML(@idoc, 'root',2)
	WITH
	(
			Location		        NVARCHAR(MAX),
			Vendor	     	        NVARCHAR(MAX),
			Category		        NVARCHAR(MAX),
			Family	     	        NVARCHAR(MAX),
			Class	     	        NVARCHAR(MAX),
			PromotionTypeValue      NVARCHAR(8),
			BeginingDate            DATETIME,     
			EndingDate              DATETIME,
			RebateAmount		    DECIMAL (11,6),
			AccumlatedQuantity		INT,
			AccumlatedAmount        DECIMAL (7,2),
			QuantityCase			INT,
			UOM                     NVARCHAR(10),
			SalesStartingDate		DATETIME,
			SalesEndingDate			DATETIME,
			DiscThroughAmount       DECIMAL (7,2),
			DiscThroughQty          INT,
			DiscAmountUnit          DECIMAL (11,6)
	)  
    -- Insert statements for procedure here

      DECLARE @SQL1 NVARCHAR(MAX)

	  set @SQL1 = 'update stpbkmst set ' 
	  if (@BeginDate IS NOT NULL)
	      BEGIN
            set @SQL1 = @SQL1 + ' stpbk_bd1_beg_rev_dt = ''' 
			   + (SELECT CONVERT(NVARCHAR(12), CONVERT(DATETIME,@BeginDate),112)) + ''''
		  END

      if (@EndDate IS NOT NULL)  
	      BEGIN
	      if (@BeginDate IS NOT NULL)
              set @SQL1 = @SQL1 + ' , stpbk_bd1_end_rev_dt = ''' 
			   + (SELECT CONVERT(NVARCHAR(12), CONVERT(DATETIME,@EndDate),112)) + ''''
          else
		       set @SQL1 = @SQL1 + ' stpbk_bd1_end_rev_dt = ''' 
			   + (SELECT CONVERT(NVARCHAR(12), CONVERT(DATETIME,@EndDate),112)) + ''''
		  END
		  
	  if (@PromotionType = 'Rebate')
         BEGIN
         if (@ItemRebateAmount IS NOT NULL)
	     BEGIN
	     if ((@BeginDate IS NOT NULL) OR (@EndDate IS NOT NULL))
             set @SQL1 = @SQL1 + ' , stpbk_bd1_refund_un = ''' + LTRIM(@ItemRebateAmount) + ''''
         else
             set @SQL1 = @SQL1 + ' stpbk_bd1_refund_un = ''' + LTRIM(@ItemRebateAmount) + ''''		        
	     END
		 
         if (@ItemAccumlatedQty IS NOT NULL)
	     BEGIN
	     if ((@BeginDate IS NOT NULL) OR (@EndDate IS NOT NULL)
		   OR (@ItemRebateAmount IS NOT NULL))
             set @SQL1 = @SQL1 + ' , stpbk_bd1_accum_qty = ''' + LTRIM(@ItemAccumlatedQty) + ''''
         else
             set @SQL1 = @SQL1 + ' stpbk_bd1_accum_qty = ''' + LTRIM(@ItemAccumlatedQty) + ''''		        
	     END	

         if (@ItemAccumAmount IS NOT NULL)
	     BEGIN
	     if ((@BeginDate IS NOT NULL) OR (@EndDate IS NOT NULL)
		 OR (@ItemRebateAmount IS NOT NULL) OR (@ItemAccumlatedQty IS NOT NULL))
             set @SQL1 = @SQL1 + ' , stpbk_bd1_accum_amt = ''' + LTRIM(@ItemAccumAmount) + ''''
         else
             set @SQL1 = @SQL1 + ' stpbk_bd1_accum_amt = ''' + LTRIM(@ItemAccumAmount) + ''''		        
	     END			 
        
         if (@SalesStartDate IS NOT NULL)
	      BEGIN
	      if ((@BeginDate IS NOT NULL) OR (@EndDate IS NOT NULL)
		  OR (@ItemRebateAmount IS NOT NULL) OR (@ItemAccumlatedQty IS NOT NULL)
		  OR (@ItemAccumAmount IS NOT NULL))
               set @SQL1 = @SQL1 + ', stpbk_sale_startdate = ''' 
			   + (SELECT CONVERT(NVARCHAR(12), CONVERT(DATETIME,@SalesStartDate),112)) + ''''
		  else
		       set @SQL1 = @SQL1 + ' stpbk_sale_startdate = ''' 
			   + (SELECT CONVERT(NVARCHAR(12), CONVERT(DATETIME,@SalesStartDate),112)) + ''''
		  END

         if (@SalesEndDate IS NOT NULL)
	      BEGIN
	      if ((@BeginDate IS NOT NULL) OR (@EndDate IS NOT NULL)
		  OR (@ItemRebateAmount IS NOT NULL) OR (@ItemAccumlatedQty IS NOT NULL)
		  OR (@ItemAccumAmount IS NOT NULL) OR (@SalesStartDate IS NOT NULL))
	           set @SQL1 = @SQL1 + ' , stpbk_sale_enddate = ''' 
			   + (SELECT CONVERT(NVARCHAR(12), CONVERT(DATETIME,@SalesEndDate),112)) + ''''
          else
		       set @SQL1 = @SQL1 + ' stpbk_sale_enddate = ''' 
			   + (SELECT CONVERT(NVARCHAR(12), CONVERT(DATETIME,@SalesEndDate),112)) + ''''
		  END

         if (@ItemQuantity IS NOT NULL)
	      BEGIN
          if ((@BeginDate IS NOT NULL) OR (@EndDate IS NOT NULL)
		  OR (@ItemRebateAmount IS NOT NULL) OR (@ItemAccumlatedQty IS NOT NULL)
		  OR (@ItemAccumAmount IS NOT NULL) OR (@SalesStartDate IS NOT NULL)
		  OR (@SalesEndDate IS NOT NULL))
        	    set @SQL1 = @SQL1 + ' , stpbk_casesize = ''' + LTRIM(@ItemQuantity) + ''''
		  else
		        set @SQL1 = @SQL1 + '  stpbk_casesize = ''' + LTRIM(@ItemQuantity) + ''''
		  END

         if (@ItemUom IS NOT NULL)
	     BEGIN
          if ((@BeginDate IS NOT NULL) OR (@EndDate IS NOT NULL)
	      OR (@ItemRebateAmount IS NOT NULL) OR (@ItemAccumlatedQty IS NOT NULL)
	      OR (@ItemAccumAmount IS NOT NULL) OR (@SalesStartDate IS NOT NULL)
	      OR (@SalesEndDate IS NOT NULL) OR (@ItemQuantity IS NOT NULL))
         	    set @SQL1 = @SQL1 + ' , stpbk_itemuom = ''' + LTRIM(@ItemUom) + ''''
		  else
		        set @SQL1 = @SQL1 + '  stpbk_itemuom = ''' + LTRIM(@ItemUom) + ''''
		  END
      END
	  
	  if (@PromotionType = 'Discount')
	  BEGIN
	     if (@ItemDiscThroughAmount IS NOT NULL)
		 BEGIN
	        if ((@BeginDate IS NOT NULL) OR (@EndDate IS NOT NULL))
	             set @SQL1 = @SQL1 + ' , stpbk_vnd_dsc_thru_amt = ''' + LTRIM(@ItemDiscThroughAmount) + ''''
            else
               set @SQL1 = @SQL1 + ' stpbk_vnd_dsc_thru_amt = ''' + LTRIM(@ItemDiscThroughAmount) + ''''
	     END
		 if (@ItemDiscThroughQty IS NOT NULL)
		 BEGIN
	        if ((@BeginDate IS NOT NULL) OR (@EndDate IS NOT NULL)
			OR (@ItemDiscThroughAmount IS NOT NULL))
	             set @SQL1 = @SQL1 + ' , stpbk_vnd_dsc_thru_qty = ''' + LTRIM(@ItemDiscThroughQty) + ''''
            else
               set @SQL1 = @SQL1 + ' stpbk_vnd_dsc_thru_qty = ''' + LTRIM(@ItemDiscThroughQty) + ''''
	     END
		 if (@ItemDiscAmountUnit IS NOT NULL)
		 BEGIN
	        if ((@BeginDate IS NOT NULL) OR (@EndDate IS NOT NULL)
			OR (@ItemDiscThroughAmount IS NOT NULL) OR (@ItemDiscThroughQty IS NOT NULL))
	             set @SQL1 = @SQL1 + ' , stpbk_vnd_dsc_amt_un = ''' + LTRIM(@ItemDiscAmountUnit) + ''''
            else
               set @SQL1 = @SQL1 + ' stpbk_vnd_dsc_amt_un = ''' + LTRIM(@ItemDiscAmountUnit) + ''''
	     END
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
		    
	  exec (@SQL1)
	  select (@@ROWCOUNT)
      

END TRY

BEGIN CATCH       
 SET @ErrMsg = ERROR_MESSAGE()      
 IF @idoc <> 0 EXEC sp_xml_removedocument @idoc      
 RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')      
END CATCH
