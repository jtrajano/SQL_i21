CREATE PROCEDURE [dbo].[uspSTUpdateItemPricing]
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
			@ItemManufacturer       NVARCHAR(MAX),
			@ItemDescription        NVARCHAR(250),
			@ItemRegion             NVARCHAR(6),
			@ItemDistrict           NVARCHAR(6),
			@ItemState              NVARCHAR(2),
			@ItemUpcCode            NVARCHAR(MAX),
			@ItemStandardCost       DECIMAL (7,6),
			@ItemRetailPrice        DECIMAL (7,2),
			@ItemSalesPrice         DECIMAL (5,2),
			@ItemQuantity           INT,
			@ItemUom                NVARCHAR(50),
			@SalesStartDate		    DATETIME,
			@SalesEndDate   		DATETIME
		
	                  
	EXEC sp_xml_preparedocument @idoc OUTPUT, @XML 
	
	SELECT	
			@ItemLocation		 =	Location,
            @ItemVendor          =   Vendor,
			@ItemCategory        =   Category,
			@ItemFamily          =   Family,
            @ItemClass           =   Class,
			@ItemManufacturer    =   Manufacturer,
            @ItemDescription     =   ItmDescription,
			@ItemRegion          =   Region,
			@ItemDistrict        =   District,
			@ItemState           =   States,
			@ItemUpcCode         =   UPCCode,
			@ItemStandardCost 	 = 	 Cost,
			@ItemRetailPrice   	 =	 Retail,
			@ItemSalesPrice		 =	 SalesPrice,
			@ItemQuantity		 =	 QuantityCase,
			@ItemUom		     =	 UOM,
			@SalesStartDate		 =	 SalesStartingDate,
			@SalesEndDate		 =	 SalesEndingDate
		
	FROM	OPENXML(@idoc, 'root',2)
	WITH
	(
			Location		        NVARCHAR(MAX),
			Vendor	     	        NVARCHAR(MAX),
			Category		        NVARCHAR(MAX),
			Family	     	        NVARCHAR(MAX),
			Class	     	        NVARCHAR(MAX),
			Manufacturer	     	NVARCHAR(MAX),
			ItmDescription		    NVARCHAR(250),
			Region                  NVARCHAR(6),
			District                NVARCHAR(6),
			States                  NVARCHAR(2),
			UPCCode		            NVARCHAR(MAX),
			Cost		            DECIMAL (7,6),
			Retail		            DECIMAL (7,2),
			SalesPrice       		DECIMAL (5,2),
			QuantityCase			INT,
			UOM                     NVARCHAR(50),
			SalesStartingDate		DATETIME,
			SalesEndingDate			DATETIME
	)  
    -- Insert statements for procedure here

      DECLARE @SQL1 NVARCHAR(MAX)

	  set @SQL1 = 'update stpbkmst set ' 
	  if (@ItemStandardCost IS NOT NULL)
	      BEGIN
          set @SQL1 = @SQL1 + 'stpbk_casecost = ''' + LTRIM(@ItemStandardCost) + ''''
		  END

      if (@ItemRetailPrice IS NOT NULL)  
	      BEGIN
	      if (@ItemStandardCost IS NOT NULL)
 	         set @SQL1 = @SQL1 + ' , stpbk_price = ''' + LTRIM(@ItemRetailPrice) + ''''
          else
	         set @SQL1 = @SQL1 + ' stpbk_price = ''' + LTRIM(@ItemRetailPrice) + '''' 
		  END

      if (@ItemRetailPrice IS NOT NULL)  
	      BEGIN
 	         set @SQL1 = @SQL1 + ' , stpbk_pm = 1 '
          END


      if (@ItemSalesPrice IS NOT NULL)
	     BEGIN
	     if ((@ItemStandardCost IS NOT NULL) OR (@ItemRetailPrice IS NOT NULL))
             set @SQL1 = @SQL1 + ' , stpbk_sale_price = ''' + LTRIM(@ItemSalesPrice) + ''''
         else
             set @SQL1 = @SQL1 + ' stpbk_sale_price = ''' + LTRIM(@ItemSalesPrice) + ''''		        
	     END

      if (@ItemSalesPrice IS NOT NULL)
	     BEGIN
	        set @SQL1 = @SQL1 + ' , stpbk_sale_pm = 1 '
	     END
        
      if (@SalesStartDate IS NOT NULL)
	      BEGIN
	      if ((@ItemStandardCost IS NOT NULL) OR (@ItemRetailPrice IS NOT NULL) 
		  OR (@ItemSalesPrice IS NOT NULL))
               set @SQL1 = @SQL1 + ', stpbk_sale_startdate = ''' 
			   + (SELECT CONVERT(NVARCHAR(12), CONVERT(DATETIME,@SalesStartDate),112)) + ''''
		  else
		       set @SQL1 = @SQL1 + ' stpbk_sale_startdate = ''' 
			   + (SELECT CONVERT(NVARCHAR(12), CONVERT(DATETIME,@SalesStartDate),112)) + ''''
		  END

      if (@SalesEndDate IS NOT NULL)
	      BEGIN
	      if ((@ItemStandardCost IS NOT NULL) OR (@ItemRetailPrice IS NOT NULL)
		   OR (@ItemSalesPrice IS NOT NULL) OR (@SalesStartDate IS NOT NULL))
	           set @SQL1 = @SQL1 + ' , stpbk_sale_enddate = ''' 
			   + (SELECT CONVERT(NVARCHAR(12), CONVERT(DATETIME,@SalesEndDate),112)) + ''''
          else
		       set @SQL1 = @SQL1 + ' stpbk_sale_enddate = ''' 
			   + (SELECT CONVERT(NVARCHAR(12), CONVERT(DATETIME,@SalesEndDate),112)) + ''''
		  END

      if (@ItemQuantity IS NOT NULL)
	     BEGIN
         if ((@ItemStandardCost IS NOT NULL) OR (@ItemRetailPrice IS NOT NULL)
		 OR (@ItemSalesPrice IS NOT NULL) OR (@SalesStartDate IS NOT NULL)
		 OR (@SalesEndDate IS NOT NULL))
        	    set @SQL1 = @SQL1 + ' , stpbk_casesize = ''' + LTRIM(@ItemQuantity) + ''''
		 else
		        set @SQL1 = @SQL1 + '  stpbk_casesize = ''' + LTRIM(@ItemQuantity) + ''''
		 END

      if (@ItemUom IS NOT NULL)
	     BEGIN
         if ((@ItemStandardCost IS NOT NULL) OR (@ItemRetailPrice IS NOT NULL)
		 OR (@ItemSalesPrice IS NOT NULL) OR (@SalesStartDate IS NOT NULL)
		 OR (@SalesEndDate IS NOT NULL) OR (@ItemQuantity IS NOT NULL) )
        	    set @SQL1 = @SQL1 + ' , stpbk_itemuom = ''' + LTRIM(@ItemUom) + ''''
		 else
		        set @SQL1 = @SQL1 + '  stpbk_itemuom = ''' + LTRIM(@ItemUom) + ''''
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

         if ((@ItemLocation IS NULL) OR (@ItemLocation = ''))
			  BEGIN
			  if ((@ItemRegion IS NOT NULL)
			  and(@ItemRegion != ''))
			      BEGIN
				       set @SQL1 = @SQL1 + ' and stpbk_store_name IN
				       (select ststo_store_name from ststomst where ststo_region_id = '''+ LTRIM(@ItemRegion) +''')'  
				  END
              END 

          if ((@ItemLocation IS NULL) OR (@ItemLocation = ''))
			  BEGIN
			  if ((@ItemDistrict IS NOT NULL)
			  and(@ItemDistrict != ''))
			      BEGIN
				       set @SQL1 = @SQL1 + ' and stpbk_store_name IN
				       (select ststo_store_name from ststomst where ststo_district_id = '''+ LTRIM(@ItemDistrict) +''')'  
				  END
              END 

          if ((@ItemLocation IS NULL) OR (@ItemLocation = ''))
			  BEGIN
			  if ((@ItemState IS NOT NULL)
			  and(@ItemState != ''))
			      BEGIN
				       set @SQL1 = @SQL1 + ' and stpbk_store_name IN
				       (select ststo_store_name from ststomst where ststo_state_id = '''+ LTRIM(@ItemState) +''')'  
				  END
              END 
		    
	  exec (@SQL1)
	  select (@@ROWCOUNT)
      

END TRY

BEGIN CATCH       
 SET @ErrMsg = ERROR_MESSAGE()      
 IF @idoc <> 0 EXEC sp_xml_removedocument @idoc      
 RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')      
END CATCH
