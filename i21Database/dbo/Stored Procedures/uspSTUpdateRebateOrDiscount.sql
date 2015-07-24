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
			@BeginDate   			NVARCHAR(50),     
			@EndDate		 	    NVARCHAR(50),     
		    @RebateAmount           DECIMAL (18,6),
			@AccumlatedQty          DECIMAL (18,6),
			@AccumAmount            DECIMAL (18,6),
			@DiscThroughAmount      DECIMAL (18,6),
			@DiscThroughQty         DECIMAL (18,6),
			@DiscAmountUnit         DECIMAL (18,6),
			@ysnPreview             NVARCHAR(1)
		
	                  
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
			@DiscAmountUnit     =   DiscAmountUnit,
			@ysnPreview = ysnPreview
		
	FROM	OPENXML(@idoc, 'root',2)
	WITH
	(
			Location		        NVARCHAR(MAX),
			Vendor	     	        NVARCHAR(MAX),
			Category		        NVARCHAR(MAX),
			Family	     	        NVARCHAR(MAX),
			Class	     	        NVARCHAR(MAX),
			PromotionTypeValue      NVARCHAR(50),
			BeginingDate            NVARCHAR(50),     
			EndingDate              NVARCHAR(50),     
			RebateAmount		    DECIMAL (18,6),
			AccumlatedQuantity		DECIMAL (18,6),
			AccumlatedAmount        DECIMAL (18,6),
			DiscThroughAmount       DECIMAL (18,6),
			DiscThroughQty          DECIMAL (18,6),
			DiscAmountUnit          DECIMAL (18,6),
			ysnPreview       NVARCHAR(1)
	)  
    -- Insert statements for procedure here

      DECLARE @SQL1 NVARCHAR(MAX)

	  DECLARE @UpdateCount INT
	  DECLARE @RecCount INT

	  SET @UpdateCount = 0
	  SET @RecCount = 0

	  
       
 DELETE FROM tblSTMassUpdateReportMaster

 IF (@BeginDate IS NOT NULL)
   BEGIN
	    SET @BeginDate = CONVERT(VARCHAR(10),@BeginDate,111)
          SET @SQL1 = 'INSERT INTO tblSTMassUpdateReportMaster(strLocationName,UpcCode,ItemDescription,
	               ChangeDescription,OldData,NewData)
                      select e.strLocationName, b.strUpcCode, c.strDescription, ''Begining Date'',
		            REPLACE(CONVERT(NVARCHAR(10),a.dtmBeginDate,111), ''/'', ''-''),
		            ''' + CAST(@BeginDate as NVARCHAR(250)) + ''' from 
					tblICItemSpecialPricing a JOIN tblICItemUOM b ON
                      a.intItemUnitMeasureId = b.intItemUOMId JOIN tblICItem c ON a.intItemId = c.intItemId 
					JOIN tblICItemLocation d ON a.intItemId = d.intItemId JOIN tblSMCompanyLocation e
					ON d.intLocationId = e.intCompanyLocationId '

	    SET @SQL1 = @SQL1 + ' where 1=1 ' 

          IF (@Location IS NOT NULL)
          BEGIN 
             SET @SQL1 = @SQL1 + ' and d.intLocationId IN (' + CAST(@Location as NVARCHAR) + ')'
          END

          IF (@Vendor IS NOT NULL)
          BEGIN 
            SET @SQL1 = @SQL1 +  ' and  a.intItemLocationId
            IN (select intItemLocationId from tblICItemLocation where intVendorId
            IN (select intEntityId from tblEntity where intEntityId 
	      IN (' + CAST(@Vendor as NVARCHAR) + ')' + '))'
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
            SET @SQL1 = @SQL1 +  ' and a.intItemLocationId IN 
            (select intItemLocationId from tblICItemLocation where intFamilyId IN
            (select intFamilyId from tblICItemLocation where intFamilyId 
		    IN (' + CAST(@Family as NVARCHAR) + ')' + '))'
          END

          IF (@Class IS NOT NULL)
          BEGIN
            SET @SQL1 = @SQL1 +  ' and a.intItemLocationId IN 
              (select intItemLocationId from tblICItemLocation where intClassId IN
              (select intClassId from tblICItemLocation where intClassId 
			  IN (' + CAST(@Class as NVARCHAR) + ')' + '))'
          END
		IF(@PromotionType = 'Vendor Rebate')
		BEGIN
             SET @SQL1 = @SQL1 + ' and  a.strPromotionType = ''Rebate''' 
	    END
		IF (@PromotionType = 'Vendor Discount')
		BEGIN
		     SET @SQL1 = @SQL1 + ' and  a.strPromotionType = ''Vendor Discount''' 
		END
        EXEC (@SQL1)
	END
     
     
 IF (@EndDate IS NOT NULL)
   BEGIN
       SET @EndDate = CONVERT(VARCHAR(10),@EndDate,111)
         SET @SQL1 = 'INSERT INTO tblSTMassUpdateReportMaster(strLocationName,UpcCode,ItemDescription,
	               ChangeDescription,OldData,NewData)
                      select e.strLocationName, b.strUpcCode, c.strDescription, ''Ending Date'',
		            REPLACE(CONVERT(NVARCHAR(10),a.dtmEndDate,111), ''/'', ''-''),
		            ''' + CAST(@EndDate as NVARCHAR(250)) + ''' from 
					tblICItemSpecialPricing a JOIN tblICItemUOM b ON
                      a.intItemUnitMeasureId = b.intItemUOMId JOIN tblICItem c ON a.intItemId = c.intItemId 
					JOIN tblICItemLocation d ON a.intItemId = d.intItemId JOIN tblSMCompanyLocation e
					ON d.intLocationId = e.intCompanyLocationId '

	    SET @SQL1 = @SQL1 + ' where 1=1 ' 

          IF (@Location IS NOT NULL)
          BEGIN 
             SET @SQL1 = @SQL1 + ' and d.intLocationId IN (' + CAST(@Location as NVARCHAR) + ')'
          END

          IF (@Vendor IS NOT NULL)
          BEGIN 
            SET @SQL1 = @SQL1 +  ' and  a.intItemLocationId
            IN (select intItemLocationId from tblICItemLocation where intVendorId
            IN (select intEntityId from tblEntity where intEntityId 
	      IN (' + CAST(@Vendor as NVARCHAR) + ')' + '))'
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
            SET @SQL1 = @SQL1 +  ' and a.intItemLocationId IN 
            (select intItemLocationId from tblICItemLocation where intFamilyId IN
            (select intFamilyId from tblICItemLocation where intFamilyId 
		    IN (' + CAST(@Family as NVARCHAR) + ')' + '))'
          END

          IF (@Class IS NOT NULL)
          BEGIN
            SET @SQL1 = @SQL1 +  ' and a.intItemLocationId IN 
              (select intItemLocationId from tblICItemLocation where intClassId IN
              (select intClassId from tblICItemLocation where intClassId 
			  IN (' + CAST(@Class as NVARCHAR) + ')' + '))'
          END

	    IF(@PromotionType = 'Vendor Rebate')
		BEGIN
             SET @SQL1 = @SQL1 + ' and  a.strPromotionType = ''Rebate''' 
	    END
		IF (@PromotionType = 'Vendor Discount')
		BEGIN
		     SET @SQL1 = @SQL1 + ' and  a.strPromotionType = ''Vendor Discount''' 
		END

        EXEC (@SQL1)
     END


 IF (@PromotionType = 'Vendor Rebate')
 BEGIN
	 IF (@RebateAmount IS NOT NULL)
	 BEGIN
	   
	    SET @SQL1 = 'INSERT INTO tblSTMassUpdateReportMaster(strLocationName,UpcCode,ItemDescription,
	               ChangeDescription,OldData,NewData)
                      select e.strLocationName, b.strUpcCode, c.strDescription, ''Rebate Amount'',
		            CAST(a.dblUnitAfterDiscount as NVARCHAR(250)),
		            ''' + CAST(@RebateAmount as NVARCHAR(250)) + ''' from 
					tblICItemSpecialPricing a JOIN tblICItemUOM b ON
                      a.intItemUnitMeasureId = b.intItemUOMId JOIN tblICItem c ON a.intItemId = c.intItemId 
					JOIN tblICItemLocation d ON a.intItemId = d.intItemId JOIN tblSMCompanyLocation e
					ON d.intLocationId = e.intCompanyLocationId '

	    SET @SQL1 = @SQL1 + ' where 1=1 ' 

          IF (@Location IS NOT NULL)
          BEGIN 
             SET @SQL1 = @SQL1 + ' and d.intLocationId IN (' + CAST(@Location as NVARCHAR) + ')'
          END

          IF (@Vendor IS NOT NULL)
          BEGIN 
            SET @SQL1 = @SQL1 +  ' and  a.intItemLocationId
            IN (select intItemLocationId from tblICItemLocation where intVendorId
            IN (select intEntityId from tblEntity where intEntityId 
	      IN (' + CAST(@Vendor as NVARCHAR) + ')' + '))'
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
            SET @SQL1 = @SQL1 +  ' and a.intItemLocationId IN 
            (select intItemLocationId from tblICItemLocation where intFamilyId IN
            (select intFamilyId from tblICItemLocation where intFamilyId 
		    IN (' + CAST(@Family as NVARCHAR) + ')' + '))'
          END

          IF (@Class IS NOT NULL)
          BEGIN
            SET @SQL1 = @SQL1 +  ' and a.intItemLocationId IN 
              (select intItemLocationId from tblICItemLocation where intClassId IN
              (select intClassId from tblICItemLocation where intClassId 
			  IN (' + CAST(@Class as NVARCHAR) + ')' + '))'
          END

        SET @SQL1 = @SQL1 + ' and  a.strPromotionType = ''Rebate''' 

        EXEC (@SQL1)
	 END

	 IF (@AccumAmount IS NOT NULL)
	 BEGIN

	    SET @SQL1 = 'INSERT INTO tblSTMassUpdateReportMaster(strLocationName,UpcCode,ItemDescription,
	               ChangeDescription,OldData,NewData)
                      select e.strLocationName, b.strUpcCode, c.strDescription, ''Accumlated Amount'',
		            CAST(a.dblAccumulatedAmount as NVARCHAR(250)),
		            ''' + CAST(@AccumAmount as NVARCHAR(250)) + ''' from 
					tblICItemSpecialPricing a JOIN tblICItemUOM b ON
                      a.intItemUnitMeasureId = b.intItemUOMId JOIN tblICItem c ON a.intItemId = c.intItemId 
					JOIN tblICItemLocation d ON a.intItemId = d.intItemId JOIN tblSMCompanyLocation e
					ON d.intLocationId = e.intCompanyLocationId '

	    SET @SQL1 = @SQL1 + ' where 1=1 ' 

          IF (@Location IS NOT NULL)
          BEGIN 
             SET @SQL1 = @SQL1 + ' and d.intLocationId IN (' + CAST(@Location as NVARCHAR) + ')'
          END

          IF (@Vendor IS NOT NULL)
          BEGIN 
            SET @SQL1 = @SQL1 +  ' and  a.intItemLocationId
            IN (select intItemLocationId from tblICItemLocation where intVendorId
            IN (select intEntityId from tblEntity where intEntityId 
	      IN (' + CAST(@Vendor as NVARCHAR) + ')' + '))'
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
            SET @SQL1 = @SQL1 +  ' and a.intItemLocationId IN 
            (select intItemLocationId from tblICItemLocation where intFamilyId IN
            (select intFamilyId from tblICItemLocation where intFamilyId 
		    IN (' + CAST(@Family as NVARCHAR) + ')' + '))'
          END

          IF (@Class IS NOT NULL)
          BEGIN
            SET @SQL1 = @SQL1 +  ' and a.intItemLocationId IN 
              (select intItemLocationId from tblICItemLocation where intClassId IN
              (select intClassId from tblICItemLocation where intClassId 
			  IN (' + CAST(@Class as NVARCHAR) + ')' + '))'
          END

        SET @SQL1 = @SQL1 + ' and  a.strPromotionType = ''Rebate''' 

        EXEC (@SQL1)

	 END

	 IF (@AccumlatedQty IS NOT NULL)
	 BEGIN

         SET @SQL1 = 'INSERT INTO tblSTMassUpdateReportMaster(strLocationName,UpcCode,ItemDescription,
	               ChangeDescription,OldData,NewData)
                      select e.strLocationName, b.strUpcCode, c.strDescription, ''Accumlated Quantity'',
		            CAST(a.dblAccumulatedQty as NVARCHAR(250)),
		            ''' + CAST(@AccumlatedQty as NVARCHAR(250)) + ''' from 
					tblICItemSpecialPricing a JOIN tblICItemUOM b ON
                      a.intItemUnitMeasureId = b.intItemUOMId JOIN tblICItem c ON a.intItemId = c.intItemId 
					JOIN tblICItemLocation d ON a.intItemId = d.intItemId JOIN tblSMCompanyLocation e
					ON d.intLocationId = e.intCompanyLocationId '

	    SET @SQL1 = @SQL1 + ' where 1=1 ' 

          IF (@Location IS NOT NULL)
          BEGIN 
             SET @SQL1 = @SQL1 + ' and d.intLocationId IN (' + CAST(@Location as NVARCHAR) + ')'
          END				    

          IF (@Vendor IS NOT NULL)
          BEGIN 
            SET @SQL1 = @SQL1 +  ' and  a.intItemLocationId
            IN (select intItemLocationId from tblICItemLocation where intVendorId
            IN (select intEntityId from tblEntity where intEntityId 
	      IN (' + CAST(@Vendor as NVARCHAR) + ')' + '))'
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
            SET @SQL1 = @SQL1 +  ' and a.intItemLocationId IN 
            (select intItemLocationId from tblICItemLocation where intFamilyId IN
            (select intFamilyId from tblICItemLocation where intFamilyId 
		    IN (' + CAST(@Family as NVARCHAR) + ')' + '))'
          END

          IF (@Class IS NOT NULL)
          BEGIN
            SET @SQL1 = @SQL1 +  ' and a.intItemLocationId IN 
              (select intItemLocationId from tblICItemLocation where intClassId IN
              (select intClassId from tblICItemLocation where intClassId 
			  IN (' + CAST(@Class as NVARCHAR) + ')' + '))'
          END
        SET @SQL1 = @SQL1 + ' and  a.strPromotionType = ''Rebate''' 
        EXEC (@SQL1)
	 END
 END

 IF (@PromotionType = 'Vendor Discount')
 BEGIN

	 IF (@DiscAmountUnit  IS NOT NULL)
	 BEGIN

          SET @SQL1 = 'INSERT INTO tblSTMassUpdateReportMaster(strLocationName,UpcCode,ItemDescription,
	               ChangeDescription,OldData,NewData)
                     select e.strLocationName, b.strUpcCode, c.strDescription, ''Discount Amount'',
		           CAST(a.dblDiscount as NVARCHAR(250)),
		           ''' + CAST(@DiscAmountUnit as NVARCHAR(250)) + ''' from 
				   tblICItemSpecialPricing a JOIN tblICItemUOM b ON
                     a.intItemUnitMeasureId = b.intItemUOMId JOIN tblICItem c ON a.intItemId = c.intItemId 
				   JOIN tblICItemLocation d ON a.intItemId = d.intItemId JOIN tblSMCompanyLocation e
				   ON d.intLocationId = e.intCompanyLocationId '

	    SET @SQL1 = @SQL1 + ' where 1=1 ' 

          IF (@Location IS NOT NULL)
          BEGIN 
             SET @SQL1 = @SQL1 + ' and d.intLocationId IN (' + CAST(@Location as NVARCHAR) + ')'
          END				    				   

          IF (@Vendor IS NOT NULL)
          BEGIN 
            SET @SQL1 = @SQL1 +  ' and  a.intItemLocationId
            IN (select intItemLocationId from tblICItemLocation where intVendorId
            IN (select intEntityId from tblEntity where intEntityId 
	      IN (' + CAST(@Vendor as NVARCHAR) + ')' + '))'
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
            SET @SQL1 = @SQL1 +  ' and a.intItemLocationId IN 
            (select intItemLocationId from tblICItemLocation where intFamilyId IN
            (select intFamilyId from tblICItemLocation where intFamilyId 
		    IN (' + CAST(@Family as NVARCHAR) + ')' + '))'
          END

          IF (@Class IS NOT NULL)
          BEGIN
            SET @SQL1 = @SQL1 +  ' and a.intItemLocationId IN 
              (select intItemLocationId from tblICItemLocation where intClassId IN
              (select intClassId from tblICItemLocation where intClassId 
			  IN (' + CAST(@Class as NVARCHAR) + ')' + '))'
          END

        SET @SQL1 = @SQL1 + ' and  a.strPromotionType = ''Vendor Discount''' 

        EXEC (@SQL1)
	 END

	 IF (@DiscThroughAmount IS NOT NULL)
	 BEGIN

	    SET @SQL1 = 'INSERT INTO tblSTMassUpdateReportMaster(strLocationName,UpcCode,ItemDescription,
	               ChangeDescription,OldData,NewData)
                      select e.strLocationName, b.strUpcCode, c.strDescription, ''Discoount through amount'',
		            CAST(a.dblDiscountThruAmount as NVARCHAR(250)),
		            ''' + CAST(@DiscThroughAmount as NVARCHAR(250)) + ''' from 
					tblICItemSpecialPricing a JOIN tblICItemUOM b ON
                      a.intItemUnitMeasureId = b.intItemUOMId JOIN tblICItem c ON a.intItemId = c.intItemId 
					JOIN tblICItemLocation d ON a.intItemId = d.intItemId JOIN tblSMCompanyLocation e
					ON d.intLocationId = e.intCompanyLocationId '

	    SET @SQL1 = @SQL1 + ' where 1=1 ' 

          IF (@Location IS NOT NULL)
          BEGIN 
             SET @SQL1 = @SQL1 + ' and d.intLocationId IN (' + CAST(@Location as NVARCHAR) + ')'
          END				    				   
			
          IF (@Vendor IS NOT NULL)
          BEGIN 
            SET @SQL1 = @SQL1 +  ' and  a.intItemLocationId
            IN (select intItemLocationId from tblICItemLocation where intVendorId
            IN (select intEntityId from tblEntity where intEntityId 
	      IN (' + CAST(@Vendor as NVARCHAR) + ')' + '))'
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
            SET @SQL1 = @SQL1 +  ' and a.intItemLocationId IN 
            (select intItemLocationId from tblICItemLocation where intFamilyId IN
            (select intFamilyId from tblICItemLocation where intFamilyId 
		    IN (' + CAST(@Family as NVARCHAR) + ')' + '))'
          END

          IF (@Class IS NOT NULL)
          BEGIN
            SET @SQL1 = @SQL1 +  ' and a.intItemLocationId IN 
              (select intItemLocationId from tblICItemLocation where intClassId IN
              (select intClassId from tblICItemLocation where intClassId 
			  IN (' + CAST(@Class as NVARCHAR) + ')' + '))'
          END

        SET @SQL1 = @SQL1 + ' and  a.strPromotionType = ''Vendor Discount''' 

        EXEC (@SQL1)
	 END

	 IF (@DiscThroughQty IS NOT NULL)
	 BEGIN
	    
         SET @SQL1 = 'INSERT INTO tblSTMassUpdateReportMaster(strLocationName,UpcCode,ItemDescription,
	               ChangeDescription,OldData,NewData)
                     select e.strLocationName, b.strUpcCode, c.strDescription, ''Discoount through quantity'',
		           CAST(a.dblDiscountThruQty as NVARCHAR(250)),
		           ''' + CAST(@DiscThroughQty as NVARCHAR(250)) + ''' from 
				   tblICItemSpecialPricing a JOIN tblICItemUOM b ON
                     a.intItemUnitMeasureId = b.intItemUOMId JOIN tblICItem c ON a.intItemId = c.intItemId 
				   JOIN tblICItemLocation d ON a.intItemId = d.intItemId JOIN tblSMCompanyLocation e
				   ON d.intLocationId = e.intCompanyLocationId '

	    SET @SQL1 = @SQL1 + ' where 1=1 ' 

          IF (@Location IS NOT NULL)
          BEGIN 
             SET @SQL1 = @SQL1 + ' and d.intLocationId IN (' + CAST(@Location as NVARCHAR) + ')'
          END				    	

          IF (@Vendor IS NOT NULL)
          BEGIN 
            SET @SQL1 = @SQL1 +  ' and  a.intItemLocationId
            IN (select intItemLocationId from tblICItemLocation where intVendorId
            IN (select intEntityId from tblEntity where intEntityId 
	      IN (' + CAST(@Vendor as NVARCHAR) + ')' + '))'
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
            SET @SQL1 = @SQL1 +  ' and a.intItemLocationId IN 
            (select intItemLocationId from tblICItemLocation where intFamilyId IN
            (select intFamilyId from tblICItemLocation where intFamilyId 
		    IN (' + CAST(@Family as NVARCHAR) + ')' + '))'
          END

          IF (@Class IS NOT NULL)
          BEGIN
            SET @SQL1 = @SQL1 +  ' and a.intItemLocationId IN 
              (select intItemLocationId from tblICItemLocation where intClassId IN
              (select intClassId from tblICItemLocation where intClassId 
			  IN (' + CAST(@Class as NVARCHAR) + ')' + '))'
          END

        SET @SQL1 = @SQL1 + ' and  a.strPromotionType = ''Vendor Discount''' 

        EXEC (@SQL1)
	 END
 END

 SELECT @RecCount  = count(*) from tblSTMassUpdateReportMaster 

 DELETE FROM tblSTMassUpdateReportMaster WHERE OldData =  NewData

 SELECT @UpdateCount = count(*) from tblSTMassUpdateReportMaster WHERE OldData !=  NewData


      
IF((@ysnPreview != 'Y')
AND(@UpdateCount > 0))	  
	BEGIN
	       
          SET @UpdateCount = 0

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
                       set @SQL1 = @SQL1 + ' , dblUnitAfterDiscount = ''' + LTRIM(@RebateAmount) + ''''
                   else
                       set @SQL1 = @SQL1 + ' dblUnitAfterDiscount = ''' + LTRIM(@RebateAmount) + '''' 
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

		 EXEC (@SQL1)
	     SELECT  @UpdateCount = (@@ROWCOUNT)   
END
     
    
SELECT  @RecCount as RecCount,  @UpdateCount as UpdateRebateOrDiscountCount	
	  

END TRY

BEGIN CATCH       
 SET @ErrMsg = ERROR_MESSAGE()      
 IF @idoc <> 0 EXEC sp_xml_removedocument @idoc      
 RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')      
END CATCH