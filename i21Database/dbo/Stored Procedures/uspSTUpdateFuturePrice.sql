CREATE PROCEDURE [dbo].[uspSTUpdateFuturePrice]

AS

SET QUOTED_IDENTIFIER OFF
        SET ANSI_NULLS ON
        SET NOCOUNT ON
        SET XACT_ABORT ON
        SET ANSI_WARNINGS OFF  

BEGIN
	DECLARE @RecCount         INT,
	  	    @TodaysDate       DATE,
	        @UPCCode          NVARCHAR(14),
	        @DblSalePrice     decimal(10,2),
			@SalesStartDate   DATETIME,
			@SalesEndDate     DATETIME,
		    @Location         INT,
			@LocationName     NVARCHAR(10),
			@Vendor           INT,
			@VendorName       NVARCHAR(10),
			@Category         INT,
			@Family           NVARCHAR(8),
			@Class            NVARCHAR(8),
			@Region           NVARCHAR(6),
			@Destrict         NVARCHAR(6),
			@PriceType        NVARCHAR(2),
			@DetailID         INT,
            @SQL1             NVARCHAR(MAX)


	set @TodaysDate = (SELECT CONVERT(NVARCHAR(12), CONVERT(DATETIME,GetDate()),112))
	
	select @RecCount = count(*) from tblSTRetailPriceAdjustment where dtmEffectiveDate = @TodaysDate

	if (@RecCount > 0)
	BEGIN

    DECLARE @UPCData TABLE (
	        DataKey INT IDENTITY(1, 1)
		   ,UPCCode nvarchar(14)
		   ,DblSalePrice decimal(10,2)
		   ,SalesStartDate DATETIME
		   ,SalesEndDate   DATETIME
		   ,Location    INT
		   ,Vendor      INT
		   ,Category    INT
		   ,Family      NVARCHAR(8)
		   ,Class       NVARCHAR(8)
		   ,Region      NVARCHAR(6)
		   ,Destrict    NVARCHAR(6)
		   ,PriceType   NVARCHAR(2)
		   ,DetailID    INT
	       ) 

     	INSERT INTO @UPCData (
	 	UPCCode,DblSalePrice,
		SalesStartDate,SalesEndDate,
		Location,Vendor,Category,
		Family,Class,Region,Destrict,PriceType,DetailID
		)
		select adj1.intItemUOMId, adj1.dblPrice, adj1.dtmSalesStartDate,adj1.dtmSalesEndDate,
		adj1.intCompanyLocationId,adj1.intVendorId,adj1.intCategoryId,adj1.intFamilyId,
		adj1.intClassId,adj1.strRegion,adj1.strDestrict,adj1.strPriceType,adj1.intRetailPriceAdjustmentDetailId
		from tblSTRetailPriceAdjustmentDetail adj1 inner join tblSTRetailPriceAdjustment adj2
	    on adj1.intRetailPriceAdjustmentId = adj2.intRetailPriceAdjustmentId where 
	    adj2.dtmEffectiveDate = @TodaysDate 
	
	    Declare @DataKey int

	    SELECT @DataKey = MIN(DataKey)
	    FROM @UPCData
	    WHILE (@DataKey > 0)
	       BEGIN
		       SELECT @UPCCode=UPCCode, @DblSalePrice = DblSalePrice,
			   @SalesStartDate = SalesStartDate, @SalesEndDate = SalesEndDate,
			   @Location  = Location, @Vendor = Vendor,
			   @Category  = Category, @Family = Family, @Class = Class,
			   @Region    = Region, @Destrict = Destrict,@PriceType = PriceType,
			   @DetailID = DetailID
      		   FROM @UPCData
		       WHERE DataKey = @DataKey
	
		       set @SQL1 = ' update stpbkmst set '

			   if (@PriceType = 'S')
			   BEGIN
			       if ((@DblSalePrice <> 0) OR (@DblSalePrice IS NOT NULL))
			       BEGIN
    			     set @SQL1 = @SQL1 + '  stpbk_sale_price = ''' + LTRIM(@DblSalePrice) + ''''
				   END
			   END

               if (@PriceType = 'R')
			   BEGIN
			       if ((@DblSalePrice <> 0) OR (@DblSalePrice IS NOT NULL))
			       BEGIN
    			     set @SQL1 = @SQL1 + '  stpbk_price = ''' + LTRIM(@DblSalePrice) + ''''
				   END
			   END

               if ((@SalesStartDate IS NOT NULL) 
			   OR (@SalesStartDate != '')) 
	             BEGIN
	             if ((@DblSalePrice <> 0) OR (@DblSalePrice IS NOT NULL))
 	                     set @SQL1 = @SQL1 + ', stpbk_sale_startdate = ''' 
  			             + (SELECT CONVERT(NVARCHAR(12), CONVERT(DATETIME,@SalesStartDate),112)) + ''''
		         else
		                 set @SQL1 = @SQL1 + ' stpbk_sale_startdate = ''' 
			            + (SELECT CONVERT(NVARCHAR(12), CONVERT(DATETIME,@SalesStartDate),112)) + ''''
                 END 

               if ((@SalesEndDate IS NOT NULL)  
			   OR (@SalesEndDate != '')) 
	             BEGIN
	             if ((@DblSalePrice <> 0) OR (@DblSalePrice IS NOT NULL)
				 OR (@SalesStartDate IS NOT NULL))
 	                     set @SQL1 = @SQL1 + ', stpbk_sale_enddate = ''' 
  			             + (SELECT CONVERT(NVARCHAR(12), CONVERT(DATETIME,@SalesEndDate),112)) + ''''
		         else
		                 set @SQL1 = @SQL1 + ' stpbk_sale_enddate = ''' 
			            + (SELECT CONVERT(NVARCHAR(12), CONVERT(DATETIME,@SalesEndDate),112)) + ''''
                 END 


               set @SQL1 = @SQL1 + ' where 1=1 ' 

		 	    if ((@UPCCode IS NOT NULL)
				and (@UPCCode != ''))
		           BEGIN 
		              set @SQL1 = @SQL1 +  ' and  stpbk_upcno IN 
		   	          (''' + (SELECT (CAST(@UPCCode AS NVARCHAR(MAX)))) +''')'
		           END

                if ((@Location IS NOT NULL)
				and (@Location != ''))
			        BEGIN
			         set @LocationName = (select strLocationName from tblSMCompanyLocation where intCompanyLocationId = @Location)
				     set @SQL1 = @SQL1 + ' and stpbk_store_name IN 
				      (''' + (SELECT (CAST(@LocationName AS NVARCHAR(MAX)))) +''')'
			       END

			   if ((@Vendor IS NOT NULL)
			   and (@Vendor != ''))
			       BEGIN
			         set @VendorName = (select strVendorId from tblAPVendor where intEntityVendorId = @Vendor)
				     set @SQL1 = @SQL1 + ' and stpbk_vnd_id IN 
				      (''' + (SELECT (CAST(@VendorName AS NVARCHAR(MAX)))) +''')'
			       END

               if ((@Category IS NOT NULL)
			   and (@Category != ''))
		           BEGIN
				    set @Category = (select strCategoryCode from tblICCategory where intCategoryId = @Category)
     	            set @SQL1 = @SQL1 + ' and stpbk_deptno IN 
				     (''' + (SELECT (CAST(@Category AS NVARCHAR(MAX)))) +''')'
		           END

               if ((@Family IS NOT NULL) 
			   and (@Family != ''))
		           BEGIN
     	            set @SQL1 = @SQL1 + ' and stpbk_family IN 
				     (''' + (SELECT (CAST(@Family AS NVARCHAR(MAX)))) +''')'
		           END

               if ((@Class IS NOT NULL)
			   and (@Class != ''))
		           BEGIN
     	            set @SQL1 = @SQL1 + ' and stpbk_class IN 
				      (''' + (SELECT (CAST(@Class AS NVARCHAR(MAX)))) +''')'
		           END

               if ((@Location IS NULL) OR (@Location = ''))
			   BEGIN
			      if ((@Region IS NOT NULL)
			      and(@Region != ''))
			      BEGIN
				       set @SQL1 = @SQL1 + ' and stpbk_store_name IN
				       (select ststo_store_name from ststomst where ststo_region_id = '''+ LTRIM(@Region) +''')'  
				  END
               END 
               
			   if ((@Location IS NULL) OR (@Location = ''))
			   BEGIN
			      if ((@Destrict IS NOT NULL)
				  and (@Destrict != ''))
			      BEGIN
				      set @SQL1 = @SQL1 + ' and stpbk_store_name IN
				      (select ststo_store_name from ststomst where ststo_district_id = '''+ LTRIM(@Destrict) +''')'  
				  END
			   END

               exec (@SQL1)
			   select (@@ROWCOUNT)

		       update tblSTRetailPriceAdjustmentDetail set ysnPosted = 1 
			   where intRetailPriceAdjustmentDetailId = @DetailID

     		   SELECT @DataKey = MIN(DataKey)
		       FROM @UPCData
		       Where DataKey>@DataKey
	       END
    END 

	SET NOCOUNT ON;
	
END






