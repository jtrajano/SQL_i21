CREATE PROCEDURE [dbo].[uspSTUpdateItemPricing]
	@XML varchar(max)
	
AS
BEGIN TRY
	DECLARE @ErrMsg			    NVARCHAR(MAX),
	        @idoc			    INT,
			@Location 			NVARCHAR(MAX),
			@Vendor             NVARCHAR(MAX),
			@Category           NVARCHAR(MAX),
			@Family             NVARCHAR(MAX),
			@Class              NVARCHAR(MAX),
			@Description        NVARCHAR(250),
			@Region             NVARCHAR(6),
			@District           NVARCHAR(6),
			@State              NVARCHAR(2),
			@UpcCode            NVARCHAR(MAX),
			@StandardCost       DECIMAL (18,6),
			@RetailPrice        DECIMAL (18,6),
			@SalesPrice         DECIMAL (18,6),
		    @SalesStartDate		DATETIME,
			@SalesEndDate   	DATETIME
		
	                  
	EXEC sp_xml_preparedocument @idoc OUTPUT, @XML 
	
	SELECT	
			@Location		 =	 Location,
            @Vendor          =   Vendor,
			@Category        =   Category,
			@Family          =   Family,
            @Class           =   Class,
            @Description     =   ItmDescription,
			@Region          =   Region,
			@District        =   District,
			@State           =   States,
			@UpcCode         =   UPCCode,
			@StandardCost 	 = 	 Cost,
			@RetailPrice   	 =	 Retail,
			@SalesPrice		 =	 SalesPrice,
			@SalesStartDate	 =	 SalesStartingDate,
			@SalesEndDate	 =	 SalesEndingDate
		
	FROM	OPENXML(@idoc, 'root',2)
	WITH
	(
			Location		        NVARCHAR(MAX),
			Vendor	     	        NVARCHAR(MAX),
			Category		        NVARCHAR(MAX),
			Family	     	        NVARCHAR(MAX),
			Class	     	        NVARCHAR(MAX),
			ItmDescription		    NVARCHAR(250),
			Region                  NVARCHAR(6),
			District                NVARCHAR(6),
			States                  NVARCHAR(2),
			UPCCode		            NVARCHAR(MAX),
			Cost		            DECIMAL (18,6),
			Retail		            DECIMAL (18,6),
			SalesPrice       		DECIMAL (18,6),
			SalesStartingDate		DATETIME,
			SalesEndingDate			DATETIME
	)  
    -- Insert statements for procedure here

      DECLARE @SQL1 NVARCHAR(MAX)

	  DECLARE @UpdateCount INT

	  set @UpdateCount = 0
	  
	  IF ((@StandardCost IS NOT NULL)
      OR (@RetailPrice IS NOT NULL))
	      BEGIN

		     set @SQL1 = ' update tblICItemPricing set '

			 if (@StandardCost IS NOT NULL)
	         BEGIN
                  set @SQL1 = @SQL1 + 'dblStandardCost = ''' + LTRIM(@StandardCost) + ''''
		     END

			 if (@RetailPrice IS NOT NULL)  
	         BEGIN
	             if (@RetailPrice IS NOT NULL)
 	                 set @SQL1 = @SQL1 + ' , dblSalePrice = ''' + LTRIM(@RetailPrice) + ''''
                 else
	                set @SQL1 = @SQL1 + ' dblSalePrice = ''' + LTRIM(@RetailPrice) + '''' 
		     END

    		
             set @SQL1 = @SQL1 + ' where 1=1 ' 

			 if (@Location IS NOT NULL)
		         BEGIN 
		               set @SQL1 = @SQL1 +  ' and  tblICItemPricing.intItemLocationId
		                IN (select intItemLocationId from tblICItemLocation where intLocationId
		                IN (select intLocationId from tblICItemLocation where intLocationId 
						IN (' + CAST(@Location as NVARCHAR) + ')' + '))'
		         END

				 if (@Vendor IS NOT NULL)
		             BEGIN 
		                  set @SQL1 = @SQL1 +  ' and  tblICItemPricing.intItemLocationId
		                  IN (select intItemLocationId from tblICItemLocation where intVendorId
		                  IN (select intEntityId from tblEntity where intEntityId 
						  IN (' + CAST(@Vendor as NVARCHAR) + ')' + '))'
		             END

				 if (@Category IS NOT NULL)
		             BEGIN
     	                 set @SQL1 = @SQL1 +  ' and tblICItemPricing.intItemId  
		                 IN (select intItemId from tblICItem where intCategoryId IN
			             (select intCategoryId from tblICCategory where intCategoryId 
						 IN (' + CAST(@Category as NVARCHAR) + ')' + '))'
		             END

			      if (@Family IS NOT NULL)
		              BEGIN
  			              set @SQL1 = @SQL1 +  ' and tblICItemPricing.intItemLocationId IN 
			              (select intItemLocationId from tblICItemLocation where intFamilyId IN
			              (select intFamilyId from tblICItemLocation where intFamilyId 
						  IN (' + CAST(@Family as NVARCHAR) + ')' + '))'
		              END

				  if (@Class  IS NOT NULL)
		              BEGIN
		                  set @SQL1 = @SQL1 +  ' and tblICItemPricing.intItemLocationId IN 
			              (select intItemLocationId from tblICItemLocation where intClassId IN
			              (select intClassId from tblICItemLocation where intClassId 
						  IN (' + CAST(@Class as NVARCHAR) + ')' + '))'
		              END

				  if (@UpcCode IS NOT NULL)
			          BEGIN
				          set @SQL1 = @SQL1 +  ' and tblICItemPricing.intItemId  
                          IN (select intItemId from tblICItemUOM where  intItemUOMId IN
		                  (select intItemUOMId from tblICItemUOM  where intItemUOMId 
						  IN (' + CAST(@UpcCode as NVARCHAR) + ')' + '))'
			          END

			      if ((@Region IS NOT NULL)
				  and(@Region != ''))
				 	   BEGIN
						 set @SQL1 = @SQL1 +  ' and tblICItemPricing.intItemLocationId IN 
						 (select intItemLocationId from tblICItemLocation where intLocationId IN 
						 (select intCompanyLocationId from tblSTStore where strRegion 
						 IN ( ''' + (@Region) + ''')' + '))'
				       END

				  if ((@District IS NOT NULL)
				  and(@District != ''))
					  BEGIN
						 set @SQL1 = @SQL1 +  ' and tblICItemPricing.intItemLocationId IN 
						 (select intItemLocationId from tblICItemLocation where intLocationId IN 
						 (select intCompanyLocationId from tblSTStore where strDestrict 
						 IN ( ''' + (@District) + ''')' + '))'
					  END

                  if ((@State IS NOT NULL)
				  and(@State != ''))
					  BEGIN
						 set @SQL1 = @SQL1 +  ' and tblICItemPricing.intItemLocationId IN 
						 (select intItemLocationId from tblICItemLocation where intLocationId IN 
						 (select intCompanyLocationId from tblSTStore where strState 
						 IN ( ''' + (@State) + ''')' + '))'
					  END

                   if ((@Description IS NOT NULL)
				   and (@Description != ''))
					BEGIN
					   set @SQL1 = @SQL1 +  ' and tblICItemPricing.intItemId IN 
					   (select intItemId from tblICItem where strDescription 
					    like ''%' + LTRIM(@Description) + '%'' )'
					END
 		  END

		  exec (@SQL1)
	      select  @UpdateCount =   @UpdateCount + (@@ROWCOUNT) 

		  if ((@SalesPrice IS NOT NULL)
		  OR (@SalesStartDate IS NOT NULL)
		  OR (@SalesEndDate IS NOT NULL))
		  BEGIN
		       set @SQL1 = ' update tblICItemSpecialPricing set '

			   if (@SalesPrice IS NOT NULL)
	           BEGIN
                  set @SQL1 = @SQL1 + 'dblUnitAfterDiscount = ''' + LTRIM(@SalesPrice) + ''''
		       END

			   if (@SalesStartDate IS NOT NULL)  
	           BEGIN
	               if (@SalesPrice IS NOT NULL)
 	                   set @SQL1 = @SQL1 + ' , dtmBeginDate = ''' + LTRIM(@SalesStartDate) + ''''
                  else
	                 set @SQL1 = @SQL1 + ' dtmBeginDate = ''' + LTRIM(@SalesStartDate) + '''' 
		       END

			   if (@SalesEndDate IS NOT NULL)  
	           BEGIN
	               if ((@SalesPrice IS NOT NULL)
				   OR (@SalesStartDate IS NOT NULL))
 	                   set @SQL1 = @SQL1 + ' , dtmEndDate = ''' + LTRIM(@SalesEndDate) + ''''
                  else
	                   set @SQL1 = @SQL1 + ' dtmEndDate = ''' + LTRIM(@SalesEndDate) + '''' 
		       END

			   set @SQL1 = @SQL1 + ' where 1=1 ' 

			   if (@Location IS NOT NULL)
		          BEGIN 
		                set @SQL1 = @SQL1 +  ' and  tblICItemSpecialPricing.intItemLocationId
		                IN (select intItemLocationId from tblICItemLocation where intLocationId
		                IN (select intLocationId from tblICItemLocation where intLocationId
						IN (' + CAST(@Location as NVARCHAR) + ')' + '))'
		          END

			   if (@Vendor IS NOT NULL)
		           BEGIN 
		                 set @SQL1 = @SQL1 +  ' and  tblICItemSpecialPricing.intItemLocationId
		                 IN (select intItemLocationId from tblICItemLocation where intVendorId
		                 IN (select intEntityId from tblEntity where intEntityId 
						 IN (' + CAST(@Vendor as NVARCHAR) + ')' + '))'
		           END

				  if (@Category IS NOT NULL)
		             BEGIN
     	                  set @SQL1 = @SQL1 +  ' and tblICItemSpecialPricing.intItemId  
		                  IN (select intItemId from tblICItem where intCategoryId IN
			              (select intCategoryId from tblICCategory where intCategoryId
						   IN (' + CAST(@Category as NVARCHAR) + ')' + '))'
		             END

				  if (@Family IS NOT NULL)
		             BEGIN
  			              set @SQL1 = @SQL1 +  ' and tblICItemSpecialPricing.intItemLocationId IN 
			              (select intItemLocationId from tblICItemLocation where intFamilyId IN
			              (select intFamilyId from tblICItemLocation where intFamilyId 
						  IN (' + CAST(@Family as NVARCHAR) + ')' + '))'
		             END

				  if (@Class IS NOT NULL)
		              BEGIN
		                  set @SQL1 = @SQL1 +  ' and tblICItemSpecialPricing.intItemLocationId IN 
			              (select intItemLocationId from tblICItemLocation where intClassId IN
			              (select intClassId from tblICItemLocation where intClassId 
						  IN (' + CAST(@Class as NVARCHAR) + ')' + '))'
		               END

				   if (@UpcCode IS NOT NULL)
			           BEGIN
				           set @SQL1 = @SQL1 +  ' and tblICItemSpecialPricing.intItemId  
                           IN (select intItemId from tblICItemUOM where  intItemUOMId IN
		                   (select intItemUOMId from tblICItemUOM  where intItemUOMId 
						   IN (' + CAST(@UpcCode as NVARCHAR) + ')' + '))'
			           END

				    if ((@Region IS NOT NULL)
					and(@Region != ''))
						BEGIN
						 set @SQL1 = @SQL1 +  ' and tblICItemSpecialPricing.intItemLocationId IN 
						 (select intItemLocationId from tblICItemLocation where intLocationId IN 
						 (select intCompanyLocationId from tblSTStore where strRegion 
						 IN ( ''' + (@Region) + ''')' + '))'
						END

				    if ((@District IS NOT NULL)
					and(@District != ''))
						BEGIN
						 set @SQL1 = @SQL1 +  ' and tblICItemSpecialPricing.intItemLocationId IN 
						 (select intItemLocationId from tblICItemLocation where intLocationId IN 
						 (select intCompanyLocationId from tblSTStore where strDestrict 
						 IN ( ''' + (@District) + ''')' + '))'
						END

                    if ((@State IS NOT NULL)
					and(@State != ''))
						BEGIN
						 set @SQL1 = @SQL1 +  ' and tblICItemSpecialPricing.intItemLocationId IN 
						 (select intItemLocationId from tblICItemLocation where intLocationId IN 
						 (select intCompanyLocationId from tblSTStore where strState 
						 IN ( ''' + (@State) + ''')' + '))'
						END

                    if ((@Description IS NOT NULL)
					and (@Description != ''))
					BEGIN
					   set @SQL1 = @SQL1 +  ' and tblICItemSpecialPricing.intItemId IN 
					   (select intItemId from tblICItem where strDescription 
					    like ''%' + LTRIM(@Description) + '%'' )'
					END

					set @SQL1 = @SQL1 + ' and  strPromotionType = ''Discount''' 
					exec (@SQL1)
	                select  @UpdateCount =   @UpdateCount + (@@ROWCOUNT)   
		  END
          
		  select @UpdateCount as UpdateItemPrcicingCount		    

END TRY

BEGIN CATCH       
 SET @ErrMsg = ERROR_MESSAGE()      
 IF @idoc <> 0 EXEC sp_xml_removedocument @idoc      
 RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')      
END CATCH