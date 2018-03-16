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
			@ysnPreview             NVARCHAR(1),
			@currentUserId			INT
		
	                  
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
			@ysnPreview			=	ysnPreview,
			@currentUserId		=   currentUserId

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
	DECLARE @ItemSpecialPricingAuditLog NVARCHAR(MAX)
	SET @ItemSpecialPricingAuditLog = ''

	DECLARE @JsonStringAuditLog NVARCHAR(MAX)
	SET @JsonStringAuditLog = ''

	DECLARE @checkComma bit
	--============================================================

	--Declare temp01 table holder
    DECLARE @tblTempOne TABLE 
    (
		strLocation NVARCHAR(250)
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
       
    --DELETE FROM tblSTMassUpdateReportMaster

	--Get currency decimal
	DECLARE @CompanyCurrencyDecimal NVARCHAR(1)
	SET @CompanyCurrencyDecimal = 0
	SELECT @CompanyCurrencyDecimal = intCurrencyDecimal from tblSMCompanyPreference

 --tblICItemSpecialPricing
 IF (@BeginDate IS NOT NULL)
   BEGIN
	    SET @BeginDate = CONVERT(VARCHAR(10),@BeginDate,111)
        
		SET @SQL1 = dbo.fnSTDynamicQueryRebateOrDiscount
				(
					'Begining Date'
					, 'REPLACE(CONVERT(NVARCHAR(10),IP.dtmBeginDate,111), ''/'', ''-'')'
					, '''' + CAST(@BeginDate as NVARCHAR(250)) + ''''
					, @Location
					, @Vendor
					, @Category
					, @Family
					, @Class
					, 'I.intItemId'
					, 'IP.intItemSpecialPricingId'
					, @PromotionType 
				)

		INSERT @tblTempOne
        EXEC (@SQL1)
	END
     
 --tblICItemSpecialPricing  
 IF (@EndDate IS NOT NULL)
   BEGIN
       SET @EndDate = CONVERT(VARCHAR(10),@EndDate,111)

	   SET @SQL1 = dbo.fnSTDynamicQueryRebateOrDiscount
				(
					'Ending Date'
					, 'REPLACE(CONVERT(NVARCHAR(10),IP.dtmEndDate,111), ''/'', ''-'')'
					, '''' + CAST(@EndDate as NVARCHAR(250)) + ''''
					, @Location
					, @Vendor
					, @Category
					, @Family
					, @Class
					, 'I.intItemId'
					, 'IP.intItemSpecialPricingId'
					, @PromotionType 
				)

		INSERT @tblTempOne
        EXEC (@SQL1)
     END

 --tblICItemSpecialPricing
 IF (@PromotionType = 'Vendor Rebate')
 BEGIN

	 IF (@RebateAmount IS NOT NULL)
	 BEGIN
	   
	    SET @SQL1 = dbo.fnSTDynamicQueryRebateOrDiscount
				(
					'Rebate Amount'
					, 'CAST(IP.dblDiscount AS DECIMAL(18, ' + @CompanyCurrencyDecimal + '))'
					, 'CAST(' + CAST(@RebateAmount AS NVARCHAR(250)) + ' AS DECIMAL(18, ' + @CompanyCurrencyDecimal + '))'
					, @Location
					, @Vendor
					, @Category
					, @Family
					, @Class
					, 'I.intItemId'
					, 'IP.intItemSpecialPricingId'
					, @PromotionType 
				)

		INSERT @tblTempOne
        EXEC (@SQL1)
	 END

	 IF (@AccumAmount IS NOT NULL)
	 BEGIN
	    SET @SQL1 = dbo.fnSTDynamicQueryRebateOrDiscount
				(
					'Accumlated Amount'
					, 'CAST(IP.dblAccumulatedAmount AS DECIMAL(18, ' + @CompanyCurrencyDecimal + '))'
					, 'CAST(' + CAST(@AccumAmount AS NVARCHAR(250)) + ' AS DECIMAL(18, ' + @CompanyCurrencyDecimal + '))'
					, @Location
					, @Vendor
					, @Category
					, @Family
					, @Class
					, 'I.intItemId'
					, 'IP.intItemSpecialPricingId'
					, @PromotionType 
				)

		INSERT @tblTempOne
        EXEC (@SQL1)

	 END

	 IF (@AccumlatedQty IS NOT NULL)
	 BEGIN
	     SET @SQL1 = dbo.fnSTDynamicQueryRebateOrDiscount
				(
					'Accumlated Quantity'
					, 'CAST(IP.dblAccumulatedQty AS DECIMAL(18, ' + @CompanyCurrencyDecimal + '))'
					, 'CAST(' + CAST(@AccumlatedQty AS NVARCHAR(250)) + ' AS DECIMAL(18, ' + @CompanyCurrencyDecimal + '))'
					, @Location
					, @Vendor
					, @Category
					, @Family
					, @Class
					, 'I.intItemId'
					, 'IP.intItemSpecialPricingId'
					, @PromotionType 
				)

		INSERT @tblTempOne
        EXEC (@SQL1)
	 END
 END

 --tblICItemSpecialPricing
 IF (@PromotionType = 'Vendor Discount')
 BEGIN

	 IF (@DiscAmountUnit  IS NOT NULL)
	 BEGIN
	      
		  SET @SQL1 = dbo.fnSTDynamicQueryRebateOrDiscount
				(
					'Discount Amount'
					, 'CAST(IP.dblDiscount AS DECIMAL(18, ' + @CompanyCurrencyDecimal + '))'
					, 'CAST(' + CAST(@DiscAmountUnit AS NVARCHAR(250)) + ' AS DECIMAL(18, ' + @CompanyCurrencyDecimal + '))'
					, @Location
					, @Vendor
					, @Category
					, @Family
					, @Class
					, 'I.intItemId'
					, 'IP.intItemSpecialPricingId'
					, @PromotionType 
				)

		INSERT @tblTempOne
        EXEC (@SQL1)
	 END

	 IF (@DiscThroughAmount IS NOT NULL)
	 BEGIN
	    
		SET @SQL1 = dbo.fnSTDynamicQueryRebateOrDiscount
				(
					'Discount through amount'
					, 'CAST(IP.dblDiscountThruAmount AS DECIMAL(18, ' + @CompanyCurrencyDecimal + '))'
					, 'CAST(' + CAST(@DiscThroughAmount AS NVARCHAR(250)) + ' AS DECIMAL(18, ' + @CompanyCurrencyDecimal + '))'
					, @Location
					, @Vendor
					, @Category
					, @Family
					, @Class
					, 'I.intItemId'
					, 'IP.intItemSpecialPricingId'
					, @PromotionType 
				)

		INSERT @tblTempOne
        EXEC (@SQL1)
	 END

	 IF (@DiscThroughQty IS NOT NULL)
	 BEGIN
	     
		 SET @SQL1 = dbo.fnSTDynamicQueryRebateOrDiscount
				(
					'Discount through quantity'
					, 'CAST(IP.dblDiscountThruQty AS DECIMAL(18, ' + @CompanyCurrencyDecimal + '))'
					, 'CAST(' + CAST(@DiscThroughQty AS NVARCHAR(250)) + ' AS DECIMAL(18, ' + @CompanyCurrencyDecimal + '))'
					, @Location
					, @Vendor
					, @Category
					, @Family
					, @Class
					, 'I.intItemId'
					, 'IP.intItemSpecialPricingId'
					, @PromotionType 
				)

		INSERT @tblTempOne
        EXEC (@SQL1)
	 END
 END

 --NEW
 SELECT @RecCount  = count(*) from @tblTempOne 
 DELETE FROM @tblTempOne WHERE strOldData =  strNewData
 SELECT @UpdateCount = count(*) from @tblTempOne WHERE strOldData !=  strNewData


--OLD
 --SELECT @RecCount  = count(*) from tblSTMassUpdateReportMaster 
 --DELETE FROM tblSTMassUpdateReportMaster WHERE OldData =  NewData
 --SELECT @UpdateCount = count(*) from tblSTMassUpdateReportMaster WHERE OldData !=  NewData


      
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
		           IN (select intEntityId from tblEMEntity where intEntityId 
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
     
    --AUDIT LOG
	--use distinct to table Id's
	INSERT INTO @tblId(intId)
	SELECT DISTINCT intChildId 
	--FROM tblSTMassUpdateReportMaster
	FROM @tblTempOne
	ORDER BY intChildId ASC

	--==========================================================================================================================================
	WHILE EXISTS (SELECT TOP (1) 1 FROM @tblId)
	BEGIN
		SELECT TOP 1 @intChildId = intId FROM @tblId

		--use distinct to table tempOne
		DELETE FROM @tblTempTwo
		INSERT INTO @tblTempTwo(strUpc, strItemDescription, strChangeDescription, strOldData, strNewData, intParentId, intChildId)
		SELECT DISTINCT strUpc
						, strItemDescription
						, strChangeDescription
						, strOldData
						, strNewData
						, intParentId
						, intChildId 
		--FROM tblSTMassUpdateReportMaster 
		FROM @tblTempOne
		WHERE intChildId = @intChildId
		ORDER BY intChildId ASC

		SET @RowCountMin = 1
		SELECT @RowCountMax = Count(*) FROM @tblTempTwo

			WHILE(@RowCountMin <= @RowCountMax)
			BEGIN
				SELECT TOP(1) @strChangeDescription = strChangeDescription, @strOldData = strOldData, @strNewData = strNewData, @intParentId = intParentId from @tblTempTwo


				IF(@strChangeDescription = 'Begining Date')
				BEGIN
					SET @ItemSpecialPricingAuditLog = @ItemSpecialPricingAuditLog + '{"change":"dtmBeginDate","from":"' + @strOldData + '","to":"' + @strNewData + '","leaf":true,"iconCls":"small-gear","isField":true,"keyValue":' + CAST(@intChildId AS NVARCHAR(50)) + ',"associationKey":"tblICItemSpecialPricings","changeDescription":"' + @strChangeDescription + '","hidden":false},'
				END
				ELSE IF(@strChangeDescription = 'Ending Date')
				BEGIN
					SET @ItemSpecialPricingAuditLog = @ItemSpecialPricingAuditLog + '{"change":"dtmEndDate","from":"' + @strOldData + '","to":"' + @strNewData + '","leaf":true,"iconCls":"small-gear","isField":true,"keyValue":' + CAST(@intChildId AS NVARCHAR(50)) + ',"associationKey":"tblICItemSpecialPricings","changeDescription":"' + @strChangeDescription + '","hidden":false},'
				END
				ELSE IF(@strChangeDescription = 'Rebate Amount' OR @strChangeDescription = 'Discount Amount')
				BEGIN
					SET @ItemSpecialPricingAuditLog = @ItemSpecialPricingAuditLog + '{"change":"dblDiscount","from":"' + @strOldData + '","to":"' + @strNewData + '","leaf":true,"iconCls":"small-gear","isField":true,"keyValue":' + CAST(@intChildId AS NVARCHAR(50)) + ',"associationKey":"tblICItemSpecialPricings","changeDescription":"' + @strChangeDescription + '","hidden":false},'
				END
				ELSE IF(@strChangeDescription = 'Accumlated Amount')
				BEGIN
					SET @ItemSpecialPricingAuditLog = @ItemSpecialPricingAuditLog + '{"change":"dblAccumulatedAmount","from":"' + @strOldData + '","to":"' + @strNewData + '","leaf":true,"iconCls":"small-gear","isField":true,"keyValue":' + CAST(@intChildId AS NVARCHAR(50)) + ',"associationKey":"tblICItemSpecialPricings","changeDescription":"' + @strChangeDescription + '","hidden":false},'
				END
				ELSE IF(@strChangeDescription = 'Accumlated Quantity')
				BEGIN
					SET @ItemSpecialPricingAuditLog = @ItemSpecialPricingAuditLog + '{"change":"dblAccumulatedQty","from":"' + @strOldData + '","to":"' + @strNewData + '","leaf":true,"iconCls":"small-gear","isField":true,"keyValue":' + CAST(@intChildId AS NVARCHAR(50)) + ',"associationKey":"tblICItemSpecialPricings","changeDescription":"' + @strChangeDescription + '","hidden":false},'
				END
				ELSE IF(@strChangeDescription = 'Discoount through amount')
				BEGIN
					SET @ItemSpecialPricingAuditLog = @ItemSpecialPricingAuditLog + '{"change":"dblDiscountThruAmount","from":"' + @strOldData + '","to":"' + @strNewData + '","leaf":true,"iconCls":"small-gear","isField":true,"keyValue":' + CAST(@intChildId AS NVARCHAR(50)) + ',"associationKey":"tblICItemSpecialPricings","changeDescription":"' + @strChangeDescription + '","hidden":false},'
				END
				ELSE IF(@strChangeDescription = 'Discoount through quantity')
				BEGIN
					SET @ItemSpecialPricingAuditLog = @ItemSpecialPricingAuditLog + '{"change":"dblDiscountThruQty","from":"' + @strOldData + '","to":"' + @strNewData + '","leaf":true,"iconCls":"small-gear","isField":true,"keyValue":' + CAST(@intChildId AS NVARCHAR(50)) + ',"associationKey":"tblICItemSpecialPricings","changeDescription":"' + @strChangeDescription + '","hidden":false},'
				END



				SET @RowCountMin = @RowCountMin + 1
				DELETE TOP (1) FROM @tblTempTwo
			END


		--INSERT to AUDITLOG
		--=================================================================================================

		--tblICItemSpecialPricing
		IF (@ItemSpecialPricingAuditLog != '')
		BEGIN
			--Remove last character comma(,)
			SET @ItemSpecialPricingAuditLog = left(@ItemSpecialPricingAuditLog, len(@ItemSpecialPricingAuditLog)-1)

			SET @ItemSpecialPricingAuditLog = '{"change":"tblICItemSpecialPricings","children":[{"action":"Updated","change":"Updated - Record: ' + CAST(@intChildId AS NVARCHAR(50)) + '","keyValue":' + CAST(@intChildId AS NVARCHAR(50)) + ',"iconCls":"small-tree-modified","children":[' + @ItemSpecialPricingAuditLog + ']}],"iconCls":"small-tree-grid","changeDescription":"Promotional Pricing"},'
		END

		SET @JsonStringAuditLog = @ItemSpecialPricingAuditLog


		SELECT @checkComma = CASE WHEN RIGHT(@JsonStringAuditLog, 1) IN (',') THEN 1 ELSE 0 END
		IF(@checkComma = 1)
		BEGIN
			--Remove last character comma(,)
			SET @JsonStringAuditLog = left(@JsonStringAuditLog, len(@JsonStringAuditLog)-1)
		END

		SET @JsonStringAuditLog = '{"action":"Updated","change":"Updated - Record: ' + CAST(@intParentId AS NVARCHAR(50)) + '","keyValue":' + CAST(@intParentId AS NVARCHAR(50)) + ',"iconCls":"small-tree-modified","children":[' + @JsonStringAuditLog + ']}'
		INSERT INTO tblSMAuditLog(strActionType, strTransactionType, strRecordNo, strDescription, strRoute, strJsonData, dtmDate, intEntityId, intConcurrencyId)
		VALUES(
				'Updated'
				, 'Inventory.view.Item'
				, @intParentId
				, ''
				, null
				, @JsonStringAuditLog
				, GETUTCDATE()
				, @currentUserId
				, 1
		)
		--=================================================================================================

		--Clear
		SET @ItemSpecialPricingAuditLog = ''

		DELETE TOP (1) FROM @tblId
	END
	--==========================================================================================================================================
    

--NEW
SELECT @UpdateCount = COUNT(*)
FROM 
(
  SELECT DISTINCT intChildId FROM @tblTempOne --tblSTMassUpdateReportMaster
) T1
SELECT  @RecCount as RecCount,  @UpdateCount as UpdateRebateOrDiscountCount

DELETE FROM tblSTMassUpdateReportMaster

INSERT INTO tblSTMassUpdateReportMaster(strLocationName, UpcCode, ItemDescription, ChangeDescription, OldData, NewData)
SELECT strLocation
	  , strUpc
	  , strItemDescription
	  , strChangeDescription
	  , strOldData
	  , strNewData 
FROM @tblTempOne


--OLD
--SELECT  @RecCount as RecCount,  @UpdateCount as UpdateRebateOrDiscountCount	

-- Update Register Notification
EXEC uspSTUpdateRegisterNotification	  

END TRY

BEGIN CATCH       
 SET @ErrMsg = ERROR_MESSAGE()      
 IF @idoc <> 0 EXEC sp_xml_removedocument @idoc      
 RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')      
END CATCH