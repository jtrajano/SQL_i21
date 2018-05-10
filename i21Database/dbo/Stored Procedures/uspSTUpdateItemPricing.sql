CREATE PROCEDURE [dbo].[uspSTUpdateItemPricing]
	@XML varchar(max)
	, @strEntityIds AS NVARCHAR(MAX) OUTPUT
AS
BEGIN TRY

	SET @strEntityIds = ''

	DECLARE @ErrMsg				NVARCHAR(MAX),
	        @idoc				INT,
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
		    @SalesStartDate		NVARCHAR(50),
			@SalesEndDate   	NVARCHAR(50),
			@ysnPreview			NVARCHAR(1),
			@currentUserId		INT
		
	                  
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
			@SalesEndDate	 =	 SalesEndingDate,
			@ysnPreview		 =   ysnPreview,
			@currentUserId   =   currentUserId
		
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
			SalesStartingDate		NVARCHAR(50),
			SalesEndingDate			NVARCHAR(50),
			ysnPreview				NVARCHAR(1),
			currentUserId			INT
	)  
    -- Insert statements for procedure here

      DECLARE @SQL1 NVARCHAR(MAX)

	  DECLARE @UpdateCount INT
	  DECLARE @RecCount INT

	  SET @UpdateCount = 0
	  SET @RecCount = 0

	--============================================================
	-- AUDIT LOGS
	DECLARE @ItemPricingAuditLog NVARCHAR(MAX)
	SET @ItemPricingAuditLog = ''

	DECLARE @ItemSpecialPricingAuditLog NVARCHAR(MAX)
	SET @ItemSpecialPricingAuditLog = ''

	DECLARE @JsonStringAuditLog NVARCHAR(MAX)
	SET @JsonStringAuditLog = ''

	DECLARE @checkComma bit
	--============================================================

	--Declare temp01 table holder
    DECLARE @tblTempOne TABLE 
    (
		intCompanyLocationId INT
		, strLocation NVARCHAR(250)
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

 


 --tblICItemPricing
 IF (@StandardCost IS NOT NULL)
 BEGIN
    SET @SQL1 = dbo.fnSTDynamicQueryItemPricing
				(
					'Standard Cost'
					, 'CAST(IP.dblStandardCost AS DECIMAL(18, ' + @CompanyCurrencyDecimal + '))'
					, 'CAST(' + CAST(@StandardCost AS NVARCHAR(250)) + ' AS DECIMAL(18, ' + @CompanyCurrencyDecimal + '))'
					, @Location
					, @Vendor
					, @Category
					, @Family
					, @Class
					, @UpcCode
					, @Region
					, @District
					, @State
					, @Description
					, 'I.intItemId'
					, 'IP.intItemPricingId'
					, 'tblICItemPricing' 
				)

	INSERT @tblTempOne
	EXEC (@SQL1)

 END 

 IF (@RetailPrice IS NOT NULL)
 BEGIN
	SET @SQL1 = dbo.fnSTDynamicQueryItemPricing
				(
					'Retail Price'
					, 'CAST(IP.dblSalePrice AS DECIMAL(18, ' + @CompanyCurrencyDecimal + '))'
					, 'CAST(' + CAST(@RetailPrice AS NVARCHAR(250)) + ' AS DECIMAL(18, ' + @CompanyCurrencyDecimal + '))'
					, @Location
					, @Vendor
					, @Category
					, @Family
					, @Class
					, @UpcCode
					, @Region
					, @District
					, @State
					, @Description
					, 'I.intItemId'
					, 'IP.intItemPricingId'
					, 'tblICItemPricing' 
				)
    

	INSERT @tblTempOne
	EXEC (@SQL1)
 END 


 --tblICItemSpecialPricing
 IF (@SalesPrice IS NOT NULL)
 BEGIN
	SET @SQL1 = dbo.fnSTDynamicQueryItemPricing
				(
					'Sales Price'
					, 'CAST(IP.dblUnitAfterDiscount AS DECIMAL(18, ' + @CompanyCurrencyDecimal + '))'
					, 'CAST(' + CAST(@SalesPrice AS NVARCHAR(250)) + ' AS DECIMAL(18, ' + @CompanyCurrencyDecimal + '))'
					, @Location
					, @Vendor
					, @Category
					, @Family
					, @Class
					, @UpcCode
					, @Region
					, @District
					, @State
					, @Description
					, 'I.intItemId'
					, 'IP.intItemSpecialPricingId'
					, 'tblICItemSpecialPricing' 
				)
     
	INSERT @tblTempOne
	EXEC (@SQL1)
 END 

 IF (@SalesStartDate IS NOT NULL)
 BEGIN
	 SET @SQL1 = dbo.fnSTDynamicQueryItemPricing
				(
					'Sales start date'
					, 'REPLACE(CONVERT(NVARCHAR(10),IP.dtmBeginDate,111), ''/'', ''-'')'
					, '''' + CAST(REPLACE(CONVERT(NVARCHAR(10),@SalesStartDate,111), '/', '-') as NVARCHAR(250)) + ''''
					, @Location
					, @Vendor
					, @Category
					, @Family
					, @Class
					, @UpcCode
					, @Region
					, @District
					, @State
					, @Description
					, 'I.intItemId'
					, 'IP.intItemSpecialPricingId'
					, 'tblICItemSpecialPricing' 
				)
      
   
     INSERT @tblTempOne
     EXEC (@SQL1)
 END 

 IF (@SalesEndDate IS NOT NULL)
 BEGIN
    SET @SQL1 = dbo.fnSTDynamicQueryItemPricing
				(
					'Sales end date'
					, 'REPLACE(CONVERT(NVARCHAR(10),IP.dtmEndDate,111), ''/'', ''-'')'
					, '''' + CAST(REPLACE(CONVERT(NVARCHAR(10),@SalesEndDate,111), '/', '-') as NVARCHAR(250)) + ''''
					, @Location
					, @Vendor
					, @Category
					, @Family
					, @Class
					, @UpcCode
					, @Region
					, @District
					, @State
					, @Description
					, 'I.intItemId'
					, 'IP.intItemSpecialPricingId'
					, 'tblICItemSpecialPricing' 
				)
     

	INSERT @tblTempOne
	EXEC (@SQL1)
END 

--NEW
DELETE FROM @tblTempOne WHERE strOldData = strNewData

-- Total records that will be Updated
SELECT @RecCount = COUNT(*) FROM @tblTempOne 

-- Total Items
SELECT @UpdateCount = COUNT(DISTINCT intParentId) FROM @tblTempOne WHERE strOldData !=  strNewData

--OLD
--SELECT @RecCount  = count(*) from tblSTMassUpdateReportMaster 
--DELETE FROM tblSTMassUpdateReportMaster WHERE OldData =  NewData
--SELECT @UpdateCount = count(*) from tblSTMassUpdateReportMaster WHERE OldData !=  NewData
	  



 IF ((@ysnPreview != 'Y')
 AND (@UpdateCount > 0))
 BEGIN
       
     SET @UpdateCount = 0 
     
	 -- UPDATE tblICItemPricing
     IF ((@StandardCost IS NOT NULL)
     OR (@RetailPrice IS NOT NULL))
		 BEGIN

				 SET @SQL1 = ' UPDATE tblICItemPricing SET '

				 IF (@StandardCost IS NOT NULL)
				 BEGIN
					SET @SQL1 = @SQL1 + ' dblStandardCost = ''' + LTRIM(@StandardCost) + ''''
				 END

				 IF (@RetailPrice IS NOT NULL)  
				 BEGIN
				   IF (@StandardCost IS NOT NULL)
					  SET @SQL1 = @SQL1 + ' , dblSalePrice = ''' + LTRIM(@RetailPrice) + ''''
				   ELSE
					  SET @SQL1 = @SQL1 + ' dblSalePrice = ''' + LTRIM(@RetailPrice) + '''' 
				 END

				 --Update dtmDateModified, intModifiedByUserId
				 SET @SQL1 = @SQL1 + ' , dtmDateModified = ''' + CAST(GETUTCDATE() AS NVARCHAR(50)) + ''' , intModifiedByUserId = ' + CAST(@currentUserId AS NVARCHAR(50)) + ''

				 SET @SQL1 = @SQL1 + ' WHERE 1=1 ' 
	    
			   if (@Location IS NOT NULL AND @Location != '')
				  BEGIN 
						set @SQL1 = @SQL1 +  ' and  tblICItemPricing.intItemLocationId
						IN (select intItemLocationId from tblICItemLocation where intLocationId
						IN (select intLocationId from tblICItemLocation where intLocationId 
						IN (' + CAST(@Location as NVARCHAR) + ')' + '))'
				  END

			   if (@Vendor IS NOT NULL AND @Vendor != '')
				   BEGIN 
						 set @SQL1 = @SQL1 +  ' and  tblICItemPricing.intItemLocationId
						 IN (select intItemLocationId from tblICItemLocation where intVendorId
						 IN (select intEntityId from tblEMEntity where intEntityId 
						 IN (' + CAST(@Vendor as NVARCHAR) + ')' + '))'
				   END

			   if (@Category IS NOT NULL AND @Category != '')
				   BEGIN
						 set @SQL1 = @SQL1 +  ' and tblICItemPricing.intItemId  
						 IN (select intItemId from tblICItem where intCategoryId IN
						 (select intCategoryId from tblICCategory where intCategoryId 
						 IN (' + CAST(@Category as NVARCHAR) + ')' + '))'
				   END

			   if (@Family IS NOT NULL AND @Family != '')
				   BEGIN
						  set @SQL1 = @SQL1 +  ' and tblICItemPricing.intItemLocationId IN 
						  (select intItemLocationId from tblICItemLocation where intFamilyId IN
						  (select intFamilyId from tblICItemLocation where intFamilyId 
						  IN (' + CAST(@Family as NVARCHAR) + ')' + '))'
				   END

				if (@Class IS NOT NULL AND @Class != '')
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
						 (select intCompanyLocationId from tblSTStore where strDistrict 
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

		  EXEC (@SQL1)
		  SELECT  @UpdateCount =   @UpdateCount + (@@ROWCOUNT) 
	  END

	 IF ((@SalesPrice IS NOT NULL)
	  OR (@SalesStartDate IS NOT NULL)
	  OR (@SalesEndDate IS NOT NULL))
	  BEGIN
	       SET @SQL1 = ' UPDATE tblICItemSpecialPricing SET '

		   IF (@SalesPrice IS NOT NULL)
           BEGIN
             SET @SQL1 = @SQL1 + 'dblUnitAfterDiscount = ''' + LTRIM(@SalesPrice) + ''''
	       END

		   IF (@SalesStartDate IS NOT NULL)  
           BEGIN
              IF (@SalesPrice IS NOT NULL)
                  SET @SQL1 = @SQL1 + ' , dtmBeginDate = ''' + LTRIM(@SalesStartDate) + ''''
             ELSE
                SET @SQL1 = @SQL1 + ' dtmBeginDate = ''' + LTRIM(@SalesStartDate) + '''' 
	       END

		   IF (@SalesEndDate IS NOT NULL)  
           BEGIN
              IF ((@SalesPrice IS NOT NULL)
			   OR (@SalesStartDate IS NOT NULL))
                  SET @SQL1 = @SQL1 + ' , dtmEndDate = ''' + LTRIM(@SalesEndDate) + ''''
              ELSE
                  SET @SQL1 = @SQL1 + ' dtmEndDate = ''' + LTRIM(@SalesEndDate) + '''' 
	       END

		   --Update dtmDateModified, intModifiedByUserId
		   SET @SQL1 = @SQL1 + ' , dtmDateModified = ''' + CAST(GETUTCDATE() AS NVARCHAR(50)) + ''' , intModifiedByUserId = ' + CAST(@currentUserId AS NVARCHAR(50)) + ''

		   SET @SQL1 = @SQL1 + ' WHERE 1=1 ' 

		   if (@Location IS NOT NULL AND @Location != '')
	          BEGIN 
	                set @SQL1 = @SQL1 +  ' and  tblICItemSpecialPricing.intItemLocationId
	                IN (select intItemLocationId from tblICItemLocation where intLocationId
	                IN (select intLocationId from tblICItemLocation where intLocationId
					IN (' + CAST(@Location as NVARCHAR) + ')' + '))'
	          END

		   if (@Vendor IS NOT NULL AND @Vendor != '')
	           BEGIN 
	                 set @SQL1 = @SQL1 +  ' and  tblICItemSpecialPricing.intItemLocationId
	                 IN (select intItemLocationId from tblICItemLocation where intVendorId
	                 IN (select intEntityId from tblEMEntity where intEntityId 
					 IN (' + CAST(@Vendor as NVARCHAR) + ')' + '))'
	           END

			if (@Category IS NOT NULL AND @Category != '')
	             BEGIN
	                  set @SQL1 = @SQL1 +  ' and tblICItemSpecialPricing.intItemId  
	                  IN (select intItemId from tblICItem where intCategoryId IN
		              (select intCategoryId from tblICCategory where intCategoryId
					   IN (' + CAST(@Category as NVARCHAR) + ')' + '))'
	             END

			if (@Family IS NOT NULL AND @Family != '')
	             BEGIN
		              set @SQL1 = @SQL1 +  ' and tblICItemSpecialPricing.intItemLocationId IN 
		              (select intItemLocationId from tblICItemLocation where intFamilyId IN
		              (select intFamilyId from tblICItemLocation where intFamilyId 
					  IN (' + CAST(@Family as NVARCHAR) + ')' + '))'
	             END

			if (@Class IS NOT NULL AND @Class != '')
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
					 (select intCompanyLocationId from tblSTStore where strDistrict 
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

				SET @SQL1 = @SQL1 + ' and  strPromotionType = ''Discount''' 

				EXEC (@SQL1)
                SELECT  @UpdateCount =   @UpdateCount + (@@ROWCOUNT)   

	  END
 END

	-- ==========================================================================
	-- Return Count result to Server side
	SELECT @UpdateCount = COUNT(*)
	FROM 
	(
	  SELECT DISTINCT intChildId 
	  FROM @tblTempOne 
	  WHERE strOldData != strNewData
	) T1

	--PRINT @strEntityIds
	--SELECT @UpdateCount as UpdateItemPrcicingCount, @RecCount as RecCount, @strEntityIds as strEntityIds
	SELECT @UpdateCount as UpdateItemPrcicingCount, @RecCount as RecCount
	-- ==========================================================================


	-- ==========================================================================
	-- Create Audit Log
	IF (@UpdateCount > 0)
	 BEGIN
		If(OBJECT_ID('tempdb..#tempAudit') Is Not Null)
		Begin
			Drop Table #tempAudit
		End

		CREATE TABLE #tempAudit (intRowCount INT NOT NULL IDENTITY
									, strUpc NVARCHAR(50)
									, strLocation NVARCHAR(250)
									, strItemDescription NVARCHAR(250)
									, strChangeDescription NVARCHAR(100)
									, strOldData NVARCHAR(MAX)
									, strNewData NVARCHAR(MAX)
									, intParentId INT
									, intChildId INT)

		INSERT INTO #tempAudit(strUpc
							, strLocation
							, strItemDescription
							, strChangeDescription
							, strOldData
							, strNewData
							, intParentId
							, intChildId)
		SELECT DISTINCT strUpc
							,strLocation
							, strItemDescription
							, strChangeDescription
							, strOldData
							, strNewData
							, intParentId
							, intChildId
		FROM @tblTempOne
		WHERE strOldData != strNewData
		ORDER BY intParentId ASC

		SELECT * FROM #tempAudit

		EXEC uspSTUpdateItemPricingInsertAuditLog @currentUserId
		DROP TABLE #tempAudit


		DELETE FROM tblSTMassUpdateReportMaster

		INSERT INTO tblSTMassUpdateReportMaster(strLocationName, UpcCode, ItemDescription, ChangeDescription, OldData, NewData, ParentId, ChildId)
		SELECT strLocation
			  , strUpc
			  , strItemDescription
			  , strChangeDescription
			  , strOldData
			  , strNewData
			  , intParentId
			  , intChildId 
		FROM @tblTempOne
		WHERE strOldData != strNewData


		--OLD
		--SELECT @UpdateCount as UpdateItemPrcicingCount, @RecCount as RecCount		    

		-- Update Register Notification
		IF EXISTS(SELECT * FROM @tblTempOne)
			BEGIN
				
				EXEC uspSTUpdateRegisterNotification @Location, @strEntityIds OUTPUT
				--TEST
				--SET @strEntityIds = '1, 2'
			END
		
	END
	-- ==========================================================================

	
END TRY

BEGIN CATCH  
	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')     
	--SET @ErrMsg = ERROR_MESSAGE()      
	--IF @idoc <> 0 EXEC sp_xml_removedocument @idoc      
	--RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')      
END CATCH