CREATE PROCEDURE [dbo].[uspSTReportUpdateRebateOrDiscountPreview]
	@xmlParam NVARCHAR(MAX) = NULL  
	
AS

BEGIN TRY

	DECLARE @ErrMsg NVARCHAR(MAX)

	--START Handle xml Param
	DECLARE @strCompanyLocationId	NVARCHAR(MAX)
			, @strVendorId			NVARCHAR(MAX)
			, @strCategoryId		NVARCHAR(MAX)
			, @strFamilyId			NVARCHAR(MAX)
			, @strClassId			NVARCHAR(MAX)
			, @strPromotionType     NVARCHAR(50)
			, @dtmBeginDate   	    NVARCHAR(50)   
			, @dtmEndDate		 	NVARCHAR(50)    
		    , @dblRebateAmount      DECIMAL (18,6)
			, @dblAccumlatedQty     DECIMAL (18,6)
			, @dblAccumAmount       DECIMAL (18,6)
			, @dblDiscThroughAmount DECIMAL (18,6)
			, @dblDiscThroughQty    DECIMAL (18,6)
			, @dblDiscAmountUnit    DECIMAL (18,6)
			, @ysnPreview           NVARCHAR(1)
			, @intCurrentUserId		INT

	IF LTRIM(RTRIM(@xmlParam)) = ''
		SET @xmlParam = NULL

	--Declare xmlParam holder
	DECLARE @temp_xml_table TABLE 
	(  
			[fieldname]		NVARCHAR(MAX),  
			condition		NVARCHAR(20),        
			[from]			NVARCHAR(MAX), 
			[to]			NVARCHAR(50),  
			[join]			NVARCHAR(10),  
			[begingroup]	NVARCHAR(50),  
			[endgroup]		NVARCHAR(50),  
			[datatype]		NVARCHAR(50) 
	)  

	DECLARE @xmlDocumentId INT

	EXEC sp_xml_preparedocument @xmlDocumentId OUTPUT ,@xmlParam

	INSERT INTO @temp_xml_table  
	SELECT	*  
	FROM	OPENXML(@xmlDocumentId, 'xmlparam/filters/filter', 2)  
	WITH (  
				[fieldname]		NVARCHAR(MAX),  
				condition		NVARCHAR(20),        
				[from]			NVARCHAR(MAX), 
				[to]			NVARCHAR(50),  
				[join]			NVARCHAR(10),  
				[begingroup]	NVARCHAR(50),  
				[endgroup]		NVARCHAR(50),  
				[datatype]		NVARCHAR(50)  
	)  

	--strCompanyLocationId
	SELECT @strCompanyLocationId = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'strCompanyLocationId'
	
	--strVendorId
	SELECT @strVendorId = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'strVendorId'

	--strCategoryId
	SELECT @strCategoryId = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'strCategoryId'

	--strFamilyId
	SELECT @strFamilyId = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'strFamilyId'

	--strClassId
	SELECT @strClassId = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'strClassId'

	--strPromotionType
	SELECT @strPromotionType = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'strPromotionType'

	--dtmBeginDate
	SELECT @dtmBeginDate = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'dtmBeginDate'

	--dtmEndDate
	SELECT @dtmEndDate = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'dtmEndDate'

	--dblRebateAmount
	SELECT @dblRebateAmount = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'dblRebateAmount'

	--dblAccumlatedQty
	SELECT @dblAccumlatedQty = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'dblAccumlatedQty'

	--dblAccumAmount
	SELECT @dblAccumAmount = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'dblAccumAmount'

	--dblDiscThroughAmount
	SELECT @dblDiscThroughAmount = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'dblDiscThroughAmount'

	--dblDiscThroughQty
	SELECT @dblDiscThroughQty = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'dblDiscThroughQty'

	--dblDiscAmountUnit
	SELECT @dblDiscAmountUnit = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'dblDiscAmountUnit'

	--ysnPreview
	SELECT @ysnPreview = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'ysnPreview'

	--intCurrentUserId
	SELECT @intCurrentUserId = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'intCurrentUserId'
	--END Handle xml Param

	
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



	DECLARE @CompanyCurrencyDecimal NVARCHAR(1)
	SET @CompanyCurrencyDecimal = 0
	SELECT @CompanyCurrencyDecimal = intCurrencyDecimal from tblSMCompanyPreference

	DECLARE @SqlQuery1 as NVARCHAR(MAX)
	-----------------------------------Handle Dynamic Query 1
	IF (@dtmBeginDate IS NOT NULL)
    BEGIN
			SET @dtmBeginDate = CONVERT(VARCHAR(10),@dtmBeginDate,111)

			SET @SqlQuery1 = dbo.fnSTDynamicQueryRebateOrDiscount
				(
					'Begining Date'
					, 'REPLACE(CONVERT(NVARCHAR(10),IP.dtmBeginDate,111), ''/'', ''-'')'
					, '''' + CAST(@dtmBeginDate as NVARCHAR(250)) + ''''
					, @strCompanyLocationId
					, @strVendorId
					, @strCategoryId
					, @strFamilyId
					, @strClassId
					, 'I.intItemId'
					, 'IP.intItemSpecialPricingId'
					, @strPromotionType 
				)

		INSERT @tblTempOne
		EXEC (@SqlQuery1)
	END


	-----------------------------------Handle Dynamic Query 2
    IF (@dtmEndDate IS NOT NULL)
    BEGIN
         SET @dtmEndDate = CONVERT(VARCHAR(10),@dtmEndDate,111)

		 SET @SqlQuery1 = dbo.fnSTDynamicQueryRebateOrDiscount
				(
					'Ending Date'
					, 'REPLACE(CONVERT(NVARCHAR(10),IP.dtmEndDate,111), ''/'', ''-'')'
					, '''' + CAST(@dtmEndDate as NVARCHAR(250)) + ''''
					, @strCompanyLocationId
					, @strVendorId
					, @strCategoryId
					, @strFamilyId
					, @strClassId
					, 'I.intItemId'
					, 'IP.intItemSpecialPricingId'
					, @strPromotionType 
				)

		INSERT @tblTempOne
		EXEC (@SqlQuery1)
     END


    -----------------------------------Handle Dynamic Query 3
	IF (@strPromotionType = 'Vendor Rebate')
	 BEGIN
		 IF (@dblRebateAmount <> 0)
		 BEGIN
		    
			SET @SqlQuery1 = dbo.fnSTDynamicQueryRebateOrDiscount
				(
					'Rebate Amount'
					, 'CAST(IP.dblDiscount AS DECIMAL(18, ' + @CompanyCurrencyDecimal + '))'
					, 'CAST(' + CAST(@dblRebateAmount AS NVARCHAR(250)) + ' AS DECIMAL(18, ' + @CompanyCurrencyDecimal + '))'
					, @strCompanyLocationId
					, @strVendorId
					, @strCategoryId
					, @strFamilyId
					, @strClassId
					, 'I.intItemId'
					, 'IP.intItemSpecialPricingId'
					, @strPromotionType 
				)

			  INSERT @tblTempOne
			  EXEC (@SqlQuery1)
		 END

		 IF (@dblAccumAmount <> 0)
		 BEGIN
		    
			SET @SqlQuery1 = dbo.fnSTDynamicQueryRebateOrDiscount
				(
					'Accumulated Amount'
					, 'CAST(IP.dblAccumulatedAmount AS DECIMAL(18, ' + @CompanyCurrencyDecimal + '))'
					, 'CAST(' + CAST(@dblAccumAmount AS NVARCHAR(250)) + ' AS DECIMAL(18, ' + @CompanyCurrencyDecimal + '))'
					, @strCompanyLocationId
					, @strVendorId
					, @strCategoryId
					, @strFamilyId
					, @strClassId
					, 'I.intItemId'
					, 'IP.intItemSpecialPricingId'
					, @strPromotionType 
				)

			INSERT @tblTempOne
			EXEC (@SqlQuery1)

		 END

		 IF (@dblAccumlatedQty <> 0)
		 BEGIN

		    SET @SqlQuery1 = dbo.fnSTDynamicQueryRebateOrDiscount
				(
					'Accumulated Quantity'
					, 'CAST(IP.dblAccumulatedQty AS DECIMAL(18, ' + @CompanyCurrencyDecimal + '))'
					, 'CAST(' + CAST(@dblAccumlatedQty AS NVARCHAR(250)) + ' AS DECIMAL(18, ' + @CompanyCurrencyDecimal + '))'
					, @strCompanyLocationId
					, @strVendorId
					, @strCategoryId
					, @strFamilyId
					, @strClassId
					, 'I.intItemId'
					, 'IP.intItemSpecialPricingId'
					, @strPromotionType 
				)

			INSERT @tblTempOne
			EXEC (@SqlQuery1)
		 END
	 END


	-----------------------------------Handle Dynamic Query 4
	IF (@strPromotionType = 'Vendor Discount')
	BEGIN

		 IF (@dblDiscAmountUnit <> 0)
		 BEGIN
		    
			SET @SqlQuery1 = dbo.fnSTDynamicQueryRebateOrDiscount
				(
					'Discount Amount'
					, 'CAST(IP.dblDiscount AS DECIMAL(18, ' + @CompanyCurrencyDecimal + '))'
					, 'CAST(' + CAST(@dblDiscAmountUnit AS NVARCHAR(250)) + ' AS DECIMAL(18, ' + @CompanyCurrencyDecimal + '))'
					, @strCompanyLocationId
					, @strVendorId
					, @strCategoryId
					, @strFamilyId
					, @strClassId
					, 'I.intItemId'
					, 'IP.intItemSpecialPricingId'
					, @strPromotionType 
				)

			INSERT @tblTempOne
			EXEC (@SqlQuery1)
		 END

		 IF (@dblDiscThroughAmount IS NOT NULL)
		 BEGIN

		    SET @SqlQuery1 = dbo.fnSTDynamicQueryRebateOrDiscount
				(
					'Discount through amount'
					, 'CAST(IP.dblDiscountThruAmount AS DECIMAL(18, ' + @CompanyCurrencyDecimal + '))'
					, 'CAST(' + CAST(@dblDiscThroughAmount AS NVARCHAR(250)) + ' AS DECIMAL(18, ' + @CompanyCurrencyDecimal + '))'
					, @strCompanyLocationId
					, @strVendorId
					, @strCategoryId
					, @strFamilyId
					, @strClassId
					, 'I.intItemId'
					, 'IP.intItemSpecialPricingId'
					, @strPromotionType 
				)

			INSERT @tblTempOne
			EXEC (@SqlQuery1)
		 END

		 IF (@dblDiscThroughQty IS NOT NULL)
		 BEGIN

			SET @SqlQuery1 = dbo.fnSTDynamicQueryRebateOrDiscount
				(
					'Discount through quantity'
					, 'CAST(IP.dblDiscountThruQty AS DECIMAL(18, ' + @CompanyCurrencyDecimal + '))'
					, 'CAST(' + CAST(@dblDiscThroughQty AS NVARCHAR(250)) + ' AS DECIMAL(18, ' + @CompanyCurrencyDecimal + '))'
					, @strCompanyLocationId
					, @strVendorId
					, @strCategoryId
					, @strFamilyId
					, @strClassId
					, 'I.intItemId'
					, 'IP.intItemSpecialPricingId'
					, @strPromotionType 
				)

			INSERT @tblTempOne
			EXEC (@SqlQuery1)
		 END
	 END

	 
	SELECT @RecCount  = count(*) from tblSTMassUpdateReportMaster 
	DELETE FROM @tblTempOne WHERE strOldData = strNewData
	SELECT @UpdateCount = count(*) from @tblTempOne WHERE strOldData !=  strNewData


	IF((@ysnPreview != 'Y')
	AND(@UpdateCount > 0))	  
		BEGIN
	       
			  SET @UpdateCount = 0

			  IF (@strPromotionType = 'Vendor Rebate')
			  BEGIN
				   set @SqlQuery1 = ' update tblICItemSpecialPricing set '    
	  
				   IF (@dtmBeginDate IS NOT NULL)
				   BEGIN
						 set @SqlQuery1 = @SqlQuery1 + ' dtmBeginDate = ''' + LTRIM(@dtmBeginDate) + '''' 
				   END

				   IF (@dtmEndDate IS NOT NULL)
				   BEGIN
   					  IF (@dtmBeginDate IS NOT NULL)
						set @SqlQuery1 = @SqlQuery1 + ' , dtmEndDate = ''' + LTRIM(@dtmEndDate) + ''''
					  else
						 set @SqlQuery1 = @SqlQuery1 + ' dtmEndDate = ''' + LTRIM(@dtmEndDate) + '''' 
				   END

				   IF (@dblRebateAmount IS NOT NULL)
				   BEGIN
					   IF ((@dtmBeginDate IS NOT NULL)
					   OR (@dtmEndDate IS NOT NULL))
						   set @SqlQuery1 = @SqlQuery1 + ' , dblDiscount = ''' + LTRIM(@dblRebateAmount) + ''''
					   else
						   set @SqlQuery1 = @SqlQuery1 + ' dblDiscount = ''' + LTRIM(@dblRebateAmount) + '''' 
				   END

				   IF (@dblAccumAmount IS NOT NULL)
				   BEGIN
					  IF ((@dtmBeginDate IS NOT NULL)
					  OR (@dtmEndDate IS NOT NULL)
					  OR (@dblRebateAmount IS NOT NULL))
						  set @SqlQuery1 = @SqlQuery1 + ' , dblAccumulatedAmount = ''' + LTRIM(@dblAccumAmount) + ''''
					  else
						  set @SqlQuery1 = @SqlQuery1 + ' dblAccumulatedAmount = ''' + LTRIM(@dblAccumAmount) + '''' 
				   END

				   IF (@dblAccumlatedQty IS NOT NULL)
				   BEGIN
					  IF ((@dtmBeginDate IS NOT NULL)
					  OR (@dtmEndDate IS NOT NULL)
					  OR (@dblRebateAmount IS NOT NULL)
					  OR (@dblAccumAmount IS NOT NULL))
						  set @SqlQuery1 = @SqlQuery1 + ' , dblAccumulatedQty = ''' + LTRIM(@dblAccumlatedQty) + ''''
					  else
						 set @SqlQuery1 = @SqlQuery1 + ' dblAccumulatedQty = ''' + LTRIM(@dblAccumlatedQty) + '''' 
				   END
			  END

			  IF (@strPromotionType = 'Vendor Discount')
			  BEGIN
				  set @SqlQuery1 = ' update tblICItemSpecialPricing set '    
	  
				   IF (@dtmBeginDate IS NOT NULL)
				   BEGIN
					 set @SqlQuery1 = @SqlQuery1 + ' dtmBeginDate = ''' + LTRIM(@dtmBeginDate) + '''' 
				   END

				   IF (@dtmEndDate IS NOT NULL)
				   BEGIN
   					  IF (@dtmBeginDate IS NOT NULL)
						 set @SqlQuery1 = @SqlQuery1 + ' , dtmEndDate = ''' + LTRIM(@dtmEndDate) + ''''
					  else
						 set @SqlQuery1 = @SqlQuery1 + ' dtmEndDate = ''' + LTRIM(@dtmEndDate) + '''' 
				   END

				   IF (@dblDiscAmountUnit IS NOT NULL)
				   BEGIN
					  IF ((@dtmBeginDate IS NOT NULL)
					  OR (@dtmEndDate IS NOT NULL))
						  set @SqlQuery1 = @SqlQuery1 + ' , dblDiscount = ''' + LTRIM(@dblDiscAmountUnit) + ''''
					  else
						  set @SqlQuery1 = @SqlQuery1 + ' dblDiscount = ''' + LTRIM(@dblDiscAmountUnit) + '''' 
				   END

				   IF (@dblDiscThroughAmount IS NOT NULL)
				   BEGIN
					  IF ((@dtmBeginDate IS NOT NULL)
					  OR (@dtmEndDate IS NOT NULL)
					  OR (@dblDiscAmountUnit IS NOT NULL))
						  set @SqlQuery1 = @SqlQuery1 + ' , dblDiscountThruAmount = ''' + LTRIM(@dblDiscThroughAmount) + ''''
					  else
						  set @SqlQuery1 = @SqlQuery1 + ' dblDiscountThruAmount = ''' + LTRIM(@dblDiscThroughAmount) + '''' 
				   END

				   IF (@dblDiscThroughQty IS NOT NULL)
				   BEGIN
					  IF ((@dtmBeginDate IS NOT NULL)
					  OR (@dtmEndDate IS NOT NULL)
					  OR (@dblDiscAmountUnit IS NOT NULL)
					  OR (@dblDiscThroughAmount IS NOT NULL))
						 set @SqlQuery1 = @SqlQuery1 + ' , dblDiscountThruQty = ''' + LTRIM(@dblDiscThroughQty) + ''''
					  else
						 set @SqlQuery1 = @SqlQuery1 + ' dblDiscountThruQty = ''' + LTRIM(@dblDiscThroughQty) + '''' 
				   END
			END

			set @SqlQuery1 = @SqlQuery1 + ' where 1=1 ' 

			IF (@strCompanyLocationId IS NOT NULL)
				BEGIN 
					 set @SqlQuery1 = @SqlQuery1 +  ' and  tblICItemSpecialPricing.intItemLocationId
					 IN (select intItemLocationId from tblICItemLocation where intLocationId
					 IN (select intLocationId from tblICItemLocation where intLocationId
		   			 IN (' + CAST(@strCompanyLocationId as NVARCHAR) + ')' + '))'
				 END

			 IF (@strVendorId IS NOT NULL)
				 BEGIN 
					   set @SqlQuery1 = @SqlQuery1 +  ' and  tblICItemSpecialPricing.intItemLocationId
					   IN (select intItemLocationId from tblICItemLocation where intVendorId
					   IN (select intEntityId from tblEMEntity where intEntityId 
					   IN (' + CAST(@strVendorId as NVARCHAR) + ')' + '))'
				 END

			 IF (@strCategoryId IS NOT NULL)
				  BEGIN
     					 set @SqlQuery1 = @SqlQuery1 +  ' and tblICItemSpecialPricing.intItemId  
						  IN (select intItemId from tblICItem where intCategoryId IN
						  (select intCategoryId from tblICCategory where intCategoryId
						  IN (' + CAST(@strCategoryId as NVARCHAR) + ')' + '))'
				   END

			 IF (@strFamilyId IS NOT NULL)
				 BEGIN
  						set @SqlQuery1 = @SqlQuery1 +  ' and tblICItemSpecialPricing.intItemLocationId IN 
						(select intItemLocationId from tblICItemLocation where intFamilyId IN
						(select intFamilyId from tblICItemLocation where intFamilyId 
						IN (' + CAST(@strFamilyId as NVARCHAR) + ')' + '))'
				  END

			 IF (@strClassId IS NOT NULL)
				 BEGIN
						set @SqlQuery1 = @SqlQuery1 +  ' and tblICItemSpecialPricing.intItemLocationId IN 
					   (select intItemLocationId from tblICItemLocation where intClassId IN
		 			   (select intClassId from tblICItemLocation where intClassId 
						IN (' + CAST(@strClassId as NVARCHAR) + ')' + '))'
				 END

			 IF (@strPromotionType = 'Vendor Rebate')
				 BEGIN
					 set @SqlQuery1 = @SqlQuery1 + ' and  strPromotionType = ''Rebate''' 
				 END
              
			 IF (@strPromotionType = 'Vendor Discount')
				 BEGIN
					 set @SqlQuery1 = @SqlQuery1 + ' and  strPromotionType = ''Vendor Discount''' 
				 END


			 EXEC (@SqlQuery1)
			 SELECT  @UpdateCount = (@@ROWCOUNT)  
			 
			 
			 
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
				ELSE IF(@strChangeDescription = 'Accumulated Amount')
				BEGIN
					SET @ItemSpecialPricingAuditLog = @ItemSpecialPricingAuditLog + '{"change":"dblAccumulatedAmount","from":"' + @strOldData + '","to":"' + @strNewData + '","leaf":true,"iconCls":"small-gear","isField":true,"keyValue":' + CAST(@intChildId AS NVARCHAR(50)) + ',"associationKey":"tblICItemSpecialPricings","changeDescription":"' + @strChangeDescription + '","hidden":false},'
				END
				ELSE IF(@strChangeDescription = 'Accumulated Quantity')
				BEGIN
					SET @ItemSpecialPricingAuditLog = @ItemSpecialPricingAuditLog + '{"change":"dblAccumulatedQty","from":"' + @strOldData + '","to":"' + @strNewData + '","leaf":true,"iconCls":"small-gear","isField":true,"keyValue":' + CAST(@intChildId AS NVARCHAR(50)) + ',"associationKey":"tblICItemSpecialPricings","changeDescription":"' + @strChangeDescription + '","hidden":false},'
				END
				ELSE IF(@strChangeDescription = 'Discount through amount')
				BEGIN
					SET @ItemSpecialPricingAuditLog = @ItemSpecialPricingAuditLog + '{"change":"dblDiscountThruAmount","from":"' + @strOldData + '","to":"' + @strNewData + '","leaf":true,"iconCls":"small-gear","isField":true,"keyValue":' + CAST(@intChildId AS NVARCHAR(50)) + ',"associationKey":"tblICItemSpecialPricings","changeDescription":"' + @strChangeDescription + '","hidden":false},'
				END
				ELSE IF(@strChangeDescription = 'Discount through quantity')
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
				, @intCurrentUserId
				, 1
		)
		--=================================================================================================

		--Clear
		SET @ItemSpecialPricingAuditLog = ''

		DELETE TOP (1) FROM @tblId
	END
	--==========================================================================================================================================
	 
	END


	-- Get CompanyName
	DECLARE @strCompanyName as NVARCHAR(250)
	IF EXISTS (SELECT * FROM dbo.tblSMCompanySetup)
	BEGIN
		SELECT @strCompanyName = strCompanyName FROM tblSMCompanySetup
	END
	ELSE IF NOT EXISTS (SELECT * FROM dbo.tblSMCompanySetup)
	BEGIN
		SET @strCompanyName = 'Not Set'
	END

	DELETE FROM @tblTempOne WHERE strOldData = strNewData

   SELECT @strCompanyName as CompanyName
		  , LEFT(DATENAME(DW,GETDATE()),10) + ' ' + DATENAME(MONTH, SYSDATETIME())+ ' ' + RIGHT('0' + DATENAME(DAY, SYSDATETIME()), 2) + ', ' + DATENAME(YEAR, SYSDATETIME()) as DateToday
		  , RIGHT('0' + LTRIM(STUFF(RIGHT(CONVERT(CHAR(26), CURRENT_TIMESTAMP, 109), 14),9, 4, ' ')),11) as TimeToday
		  , strLocation
		  , strUpc
		  , strItemDescription
		  , strChangeDescription
		  , strOldData
		  , strNewData
   FROM @tblTempOne
   ORDER BY strItemDescription, strChangeDescription ASC
    
   DELETE FROM @tblTempOne
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
END CATCH