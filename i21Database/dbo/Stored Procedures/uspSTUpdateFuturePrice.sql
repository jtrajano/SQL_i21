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
	        @UPCCode          INT,
			@DblFactor        DECIMAL(18,6),
	        @DblSalePrice     DECIMAL(18,6),
			@DblLastCost      DECIMAL(18,6),
			@SalesStartDate   DATETIME,
			@SalesEndDate     DATETIME,
		    @Location         INT,
			@Vendor           INT,
			@Category         INT,
			@Family           INT,
			@Class            INT,
			@Region           NVARCHAR(6),
			@Destrict         NVARCHAR(6),
			@PriceType        NVARCHAR(1),
			@PriceMethod      NVARCHAR(1),
			@DetailID         INT,
            @SQL1             NVARCHAR(MAX)


	set @TodaysDate = (SELECT CONVERT(NVARCHAR(12), CONVERT(DATETIME,GetDate()),112))

	select @RecCount = count(*) from tblSTRetailPriceAdjustment where dtmEffectiveDate = @TodaysDate


	if (@RecCount > 0)
	BEGIN

    DECLARE @UPCData TABLE (
	        DataKey INT IDENTITY(1, 1)
		   ,UPCCode INT
		   ,DblFactor    DECIMAL(18,6)  
		   ,DblSalePrice DECIMAL(18,6)
		   ,dblLastCost  DECIMAL(18,6)
		   ,SalesStartDate DATETIME
		   ,SalesEndDate   DATETIME
		   ,Location    INT
		   ,Vendor      INT
		   ,Category    INT
		   ,Family      INT
		   ,Class       INT
		   ,Region      NVARCHAR(6)
		   ,Destrict    NVARCHAR(6)
		   ,PriceType   NVARCHAR(1)
		   ,PriceMethod NVARCHAR(1)
		   ,DetailID    INT
	       ) 

     	INSERT INTO @UPCData (
	 	UPCCode,DblFactor,DblSalePrice,dblLastCost,
		SalesStartDate,SalesEndDate,
		Location,Vendor,Category,
		Family,Class,Region,Destrict,PriceType, PriceMethod ,DetailID
		)
		select adj1.intItemUOMId, adj1.dblFactor, adj1.dblPrice,adj1.dblLastCost,
		adj1.dtmSalesStartDate,adj1.dtmSalesEndDate,
		adj1.intCompanyLocationId,adj1.intEntityId,adj1.intCategoryId,adj1.intFamilyId,
		adj1.intClassId,adj1.strRegion,adj1.strDistrict,adj1.strPriceType, 
		adj1.strPriceMethod, adj1.intRetailPriceAdjustmentDetailId
		from tblSTRetailPriceAdjustmentDetail adj1 inner join tblSTRetailPriceAdjustment adj2
	    on adj1.intRetailPriceAdjustmentId = adj2.intRetailPriceAdjustmentId where 
	    adj2.dtmEffectiveDate = @TodaysDate and adj1.ysnPosted = 0 
	
	    Declare @DataKey int

	    SELECT @DataKey = MIN(DataKey)
	    FROM @UPCData
	    WHILE (@DataKey > 0)
	       BEGIN
		       SELECT @UPCCode=UPCCode, @DblFactor = DblFactor,
			   @DblSalePrice = DblSalePrice, @DblLastCost = dblLastCost,
			   @SalesStartDate = SalesStartDate, @SalesEndDate = SalesEndDate,
			   @Location  = Location, @Vendor = Vendor,
			   @Category  = Category, @Family = Family, @Class = Class,
			   @Region    = Region, @Destrict = Destrict,@PriceType = PriceType, 
			   @PriceMethod = PriceMethod, @DetailID = DetailID
      		   FROM @UPCData
		       WHERE DataKey = @DataKey

			   if ((@PriceMethod = 'C')
			   OR (@PriceMethod = 'E'))
			       BEGIN
			          set @DblFactor = @DblFactor * -1 
				   END

			   if (@PriceType = 'S')
			       BEGIN
				        set @SQL1 = ' update tblICItemSpecialPricing set '

    		   	        set @SQL1 = @SQL1 + '  dblUnitAfterDiscount = ''' + LTRIM(@DblSalePrice) + ''''
						+ ', dtmBeginDate = ''' + LTRIM(@SalesStartDate) + '''' 
						+ ', dtmEndDate = ''' + LTRIM(@SalesEndDate) + ''''

						if (@PriceMethod = 'A' )
						BEGIN
						   set @SQL1 = @SQL1 + ', dblDiscount = NULL, strDiscountBy = NULL '
						END

						if ((@PriceMethod = 'B' )
						OR (@PriceMethod = 'C'))
						BEGIN
						   set @SQL1 = @SQL1 + ', strDiscountBy = ''Amount'' '
						END

						if ((@PriceMethod = 'D' )
						OR (@PriceMethod = 'E'))
						BEGIN
						   set @SQL1 = @SQL1 + ', strDiscountBy = ''Percent'' '
						END

						if (@DblFactor IS NOT NULL)
						BEGIN
						  set @SQL1 = @SQL1 + ',  dblDiscount = ''' + LTRIM(@DblFactor) + ''''
						END

	                    set @SQL1 = @SQL1 + ' where 1=1 ' 

   					    if (@Location IS NOT NULL)
		                BEGIN 
		                      set @SQL1 = @SQL1 +  ' and  tblICItemSpecialPricing.intItemLocationId
		                      IN (select intItemLocationId from tblICItemLocation where intLocationId
		                      IN (select intLocationId from tblICItemLocation 
							  where intLocationId IN (' + CAST(@Location as NVARCHAR) + ')' + '))'
		                END

						if (@Vendor IS NOT NULL)
		                BEGIN 
		                      set @SQL1 = @SQL1 +  ' and  tblICItemSpecialPricing.intItemLocationId
		                      IN (select intItemLocationId from tblICItemLocation where intVendorId
		                      IN (select intEntityId from tblEMEntity 
							  where intEntityId IN (' + CAST(@Vendor as NVARCHAR) + ')' + '))'
		                END

					    if (@Category IS NOT NULL)
		                BEGIN
     	                  set @SQL1 = @SQL1 +  ' and tblICItemSpecialPricing.intItemId  
		                  IN (select intItemId from tblICItem where intCategoryId IN
			              (select intCategoryId from tblICCategory where 
						  intCategoryId IN (' + CAST(@Category as NVARCHAR) + ')' + '))'
		                END

					    if (@Family IS NOT NULL)
		                BEGIN
  			              set @SQL1 = @SQL1 +  ' and tblICItemSpecialPricing.intItemLocationId IN 
			              (select intItemLocationId from tblICItemLocation where intFamilyId IN
			              (select intFamilyId from tblICItemLocation 
						  where intFamilyId IN (' + CAST(@Family as NVARCHAR) + ')' + '))'
		                END

					    if (@Class IS NOT NULL)
		                BEGIN
		                   set @SQL1 = @SQL1 +  ' and tblICItemSpecialPricing.intItemLocationId IN 
			               (select intItemLocationId from tblICItemLocation where intClassId IN
			               (select intClassId from tblICItemLocation 
						   where intClassId IN (' + CAST(@Class as NVARCHAR) + ')' + '))'
		                END

					    if (@UPCCode IS NOT NULL)
			            BEGIN
				            set @SQL1 = @SQL1 +  ' and tblICItemSpecialPricing.intItemId  
                            IN (select intItemId from tblICItemUOM where  intItemUOMId IN
		                    (select intItemUOMId from tblICItemUOM  
							where intItemUOMId IN (' + CAST(@UPCCode as NVARCHAR) + ')' + '))'
			            END

						if ((@Region IS NOT NULL)
						and(@Region != ''))
						BEGIN
						 set @SQL1 = @SQL1 +  ' and tblICItemSpecialPricing.intItemLocationId IN 
						 (select intItemLocationId from tblICItemLocation where intLocationId IN 
						 (select intCompanyLocationId from tblSTStore 
						 where strRegion IN ( ''' + (@Region) + ''')' + '))'
						END

						if ((@Destrict IS NOT NULL)
						and(@Destrict != ''))
						BEGIN
						 set @SQL1 = @SQL1 +  ' and tblICItemSpecialPricing.intItemLocationId IN 
						 (select intItemLocationId from tblICItemLocation where intLocationId IN 
						 (select intCompanyLocationId from tblSTStore 
						 where strDistrict IN ( ''' + (@Destrict) + ''')' + '))'
						END

						set @SQL1 = @SQL1 + ' and  strPromotionType = ''Discount'''   
		           END

              if (@PriceType = 'R')
		          BEGIN
   		              set @SQL1 = ' update tblICItemPricing set '

    		   	      set @SQL1 = @SQL1 + '  dblSalePrice = ''' + LTRIM(@DblSalePrice) + ''''
					  + ', dblLastCost = ''' + LTRIM(@DblLastCost) + '''' 

					  set @SQL1 = @SQL1 + ' where 1=1 ' 

   					  if (@Location IS NOT NULL)
		              BEGIN 
		                      set @SQL1 = @SQL1 +  ' and  tblICItemPricing.intItemLocationId
		                      IN (select intItemLocationId from tblICItemLocation where intLocationId
		                      IN (select intLocationId from tblICItemLocation 
							  where intLocationId IN (' + CAST(@Location as NVARCHAR) + ')' + '))'
		              END

					  if (@Vendor IS NOT NULL)
		                BEGIN 
		                      set @SQL1 = @SQL1 +  ' and  tblICItemPricing.intItemLocationId
		                      IN (select intItemLocationId from tblICItemLocation where intVendorId
		                      IN (select intEntityId from tblEMEntity 
							  where intEntityId IN (' + CAST(@Vendor as NVARCHAR) + ')' + '))'
		                END

					  if (@Category IS NOT NULL)
		              BEGIN
     	                  set @SQL1 = @SQL1 +  ' and tblICItemPricing.intItemId  
		                  IN (select intItemId from tblICItem where intCategoryId IN
			              (select intCategoryId from tblICCategory 
						  where intCategoryId IN (' + CAST(@Category as NVARCHAR) + ')' + '))'
		              END

					  if (@Family IS NOT NULL)
		              BEGIN
  			              set @SQL1 = @SQL1 +  ' and tblICItemPricing.intItemLocationId IN 
			              (select intItemLocationId from tblICItemLocation where intFamilyId IN
			              (select intFamilyId from tblICItemLocation 
						  where intFamilyId IN (' + CAST(@Family as NVARCHAR) + ')' + '))'
		              END

					  if (@Class  IS NOT NULL)
		              BEGIN
		                  set @SQL1 = @SQL1 +  ' and tblICItemPricing.intItemLocationId IN 
			              (select intItemLocationId from tblICItemLocation where intClassId IN
			              (select intClassId from tblICItemLocation 
						  where intClassId IN (' + CAST(@Class as NVARCHAR) + ')' + '))'
		              END

					  if (@UPCCode IS NOT NULL)
			          BEGIN
				          set @SQL1 = @SQL1 +  ' and tblICItemPricing.intItemId  
                          IN (select intItemId from tblICItemUOM where  intItemUOMId IN
		                  (select intItemUOMId from tblICItemUOM  
						  where intItemUOMId IN (' + CAST(@UPCCode as NVARCHAR) + ')' + '))'
			          END

					  if ((@Region IS NOT NULL)
					  and(@Region != ''))
					  BEGIN
						 set @SQL1 = @SQL1 +  ' and tblICItemPricing.intItemLocationId IN 
						 (select intItemLocationId from tblICItemLocation where intLocationId IN 
						 (select intCompanyLocationId from tblSTStore
						  where strRegion IN ( ''' + (@Region) + ''')' + '))'
				      END

					  if ((@Destrict IS NOT NULL)
					  and(@Destrict != ''))
					  BEGIN
						 set @SQL1 = @SQL1 +  ' and tblICItemPricing.intItemLocationId IN 
						 (select intItemLocationId from tblICItemLocation where intLocationId IN 
						 (select intCompanyLocationId from tblSTStore 
						 where strDistrict IN ( ''' + (@Destrict) + ''')' + '))'
					  END
			      END

			   EXEC (@SQL1)
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