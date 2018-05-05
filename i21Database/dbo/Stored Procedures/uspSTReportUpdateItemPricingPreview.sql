CREATE PROCEDURE [dbo].[uspSTReportUpdateItemPricingPreview]
	@xmlParam NVARCHAR(MAX) = NULL
AS

BEGIN TRY

	DECLARE @ErrMsg NVARCHAR(MAX)

	DECLARE @UpdateCount INT
	SET @UpdateCount = 0

	--START Handle xml Param
	DECLARE @strCompanyLocationId NVARCHAR(MAX)
			, @strVendorId NVARCHAR(MAX)
			, @strCategoryId NVARCHAR(MAX)
			, @strFamilyId NVARCHAR(MAX)
			, @strClassId NVARCHAR(MAX)
			, @strDescription NVARCHAR(MAX)
			, @strRegion NVARCHAR(MAX)
			, @strDistrict NVARCHAR(MAX)
			, @strState NVARCHAR(MAX)
			, @intUpcCode INT
			, @dblStandardCost DECIMAL (18,6)
			, @dblRetailPrice DECIMAL (18,6)
			, @dblSalesPrice DECIMAL (18,6)
			, @dtmSalesStartingDate DATE
			, @dtmSalesEndingDate DATE
			, @ysnPreview NVARCHAR(1)
			, @intCurrentUserId INT


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

	--strDescription
	SELECT @strDescription = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'strDescription'

	--strRegion
	SELECT @strRegion = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'strRegion'

	--strDistrict
	SELECT @strDistrict = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'strDistrict'

	--strState
	SELECT @strState = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'strState'

	--intUpcCode
	SELECT @intUpcCode = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'intUpcCode'

	--dblCost
	SELECT @dblStandardCost = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'dblCost'

	--dblRetail
	SELECT @dblRetailPrice = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'dblRetail'

	--dblSalesPrice
	SELECT @dblSalesPrice = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'dblSalesPrice'

	--dtmSalesStartingDate
	SELECT @dtmSalesStartingDate = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'dtmSalesStartingDate'

	--dtmSalesEndingDate
	SELECT @dtmSalesEndingDate = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'dtmSalesEndingDate'

	--ysnPreview
	SELECT @ysnPreview = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'ysnPreview'

	--currentUserId
	SELECT @intCurrentUserId = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'intCurrentUserId'
	--END Handle xml Param

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
	
	DECLARE @CompanyCurrencyDecimal NVARCHAR(1)
	SET @CompanyCurrencyDecimal = 0
	SELECT @CompanyCurrencyDecimal = intCurrencyDecimal from tblSMCompanyPreference

	DECLARE @SqlQuery1 as NVARCHAR(MAX)

	--tblICItemPricing
	-----------------------------------Handle Dynamic Query 1
	IF (@dblStandardCost IS NOT NULL)
		BEGIN
			SET @SqlQuery1 = dbo.fnSTDynamicQueryItemPricing
				(
					'Standard Cost'
					, 'CAST(IP.dblStandardCost AS DECIMAL(18, ' + @CompanyCurrencyDecimal + '))'
					, 'CAST(' + CAST(@dblStandardCost AS NVARCHAR(250)) + ' AS DECIMAL(18, ' + @CompanyCurrencyDecimal + '))'
					, @strCompanyLocationId
					, @strVendorId
					, @strCategoryId
					, @strFamilyId
					, @strClassId
					, @intUpcCode
					, @strRegion
					, @strDistrict
					, @strState
					, @strDescription
					, 'I.intItemId'
					, 'IP.intItemPricingId'
					, 'tblICItemPricing' 
				)

		INSERT @tblTempOne
		EXEC (@SqlQuery1)
	END 


	-----------------------------------Handle Dynamic Query 2
	IF (@dblRetailPrice IS NOT NULL)
		BEGIN
			SET @SqlQuery1 = dbo.fnSTDynamicQueryItemPricing
				(
					'Retail Price'
					, 'CAST(IP.dblSalePrice AS DECIMAL(18, ' + @CompanyCurrencyDecimal + '))'
					, 'CAST(' + CAST(@dblRetailPrice AS NVARCHAR(250)) + ' AS DECIMAL(18, ' + @CompanyCurrencyDecimal + '))'
					, @strCompanyLocationId
					, @strVendorId
					, @strCategoryId
					, @strFamilyId
					, @strClassId
					, @intUpcCode
					, @strRegion
					, @strDistrict
					, @strState
					, @strDescription
					, 'I.intItemId'
					, 'IP.intItemPricingId'
					, 'tblICItemPricing' 
				)

		INSERT @tblTempOne
		EXEC (@SqlQuery1)
 END 


    --tblICItemSpecialPricing
    -----------------------------------Handle Dynamic Query 3
	IF (@dblSalesPrice IS NOT NULL)
		BEGIN
			SET @SqlQuery1 = dbo.fnSTDynamicQueryItemPricing
				(
					'Sales Price'
					, 'CAST(IP.dblUnitAfterDiscount AS DECIMAL(18, ' + @CompanyCurrencyDecimal + '))'
					, 'CAST(' + CAST(@dblSalesPrice AS NVARCHAR(250)) + ' AS DECIMAL(18, ' + @CompanyCurrencyDecimal + '))'
					, @strCompanyLocationId
					, @strVendorId
					, @strCategoryId
					, @strFamilyId
					, @strClassId
					, @intUpcCode
					, @strRegion
					, @strDistrict
					, @strState
					, @strDescription
					, 'I.intItemId'
					, 'IP.intItemSpecialPricingId'
					, 'tblICItemSpecialPricing' 
				)

		INSERT @tblTempOne
		EXEC (@SqlQuery1)
 END 


	-----------------------------------Handle Dynamic Query 4
	 IF (@dtmSalesStartingDate IS NOT NULL)
	 BEGIN
		SET @SqlQuery1 = dbo.fnSTDynamicQueryItemPricing
				(
					'Sales start date'
					, 'REPLACE(CONVERT(NVARCHAR(10),IP.dtmBeginDate,111), ''/'', ''-'')'
					, '''' + CAST(@dtmSalesStartingDate as NVARCHAR(250)) + ''''
					, @strCompanyLocationId
					, @strVendorId
					, @strCategoryId
					, @strFamilyId
					, @strClassId
					, @intUpcCode
					, @strRegion
					, @strDistrict
					, @strState
					, @strDescription
					, 'I.intItemId'
					, 'IP.intItemSpecialPricingId'
					, 'tblICItemSpecialPricing' 
				)

			INSERT @tblTempOne
			EXEC (@SqlQuery1)
	 END 


	 ----------------------------------Handle Dynamic Query 5
	 IF (@dtmSalesEndingDate IS NOT NULL)
	 BEGIN
		  SET @SqlQuery1 = dbo.fnSTDynamicQueryItemPricing
				(
					'Sales end date'
					, 'REPLACE(CONVERT(NVARCHAR(10),IP.dtmEndDate,111), ''/'', ''-'')'
					, '''' + CAST(@dtmSalesEndingDate as NVARCHAR(250)) + ''''
					, @strCompanyLocationId
					, @strVendorId
					, @strCategoryId
					, @strFamilyId
					, @strClassId
					, @intUpcCode
					, @strRegion
					, @strDistrict
					, @strState
					, @strDescription
					, 'I.intItemId'
					, 'IP.intItemSpecialPricingId'
					, 'tblICItemSpecialPricing' 
				)

			INSERT @tblTempOne
			EXEC (@SqlQuery1)
	END 

	DELETE FROM @tblTempOne WHERE strOldData = strNewData
	SELECT @UpdateCount = count(*) from @tblTempOne WHERE strOldData != strNewData


	--Update
	-----------------------------------Handle Dynamic Query 6
	 IF ((@ysnPreview != 'Y')
	 AND (@UpdateCount > 0))
	 BEGIN
       
		 SET @UpdateCount = 0 
    

		 IF ((@dblStandardCost IS NOT NULL)
		 OR (@dblRetailPrice IS NOT NULL))
		 BEGIN

				 set @SqlQuery1 = ' update tblICItemPricing set '

				 if (@dblStandardCost IS NOT NULL)
				 BEGIN
					set @SqlQuery1 = @SqlQuery1 + 'dblStandardCost = ''' + LTRIM(@dblStandardCost) + ''''
				 END

				 if (@dblRetailPrice IS NOT NULL)  
				 BEGIN
				   if (@dblStandardCost IS NOT NULL)
					  set @SqlQuery1 = @SqlQuery1 + ' , dblSalePrice = ''' + LTRIM(@dblRetailPrice) + ''''
				   else
					  set @SqlQuery1 = @SqlQuery1 + ' dblSalePrice = ''' + LTRIM(@dblRetailPrice) + '''' 
				 END

				 set @SqlQuery1 = @SqlQuery1 + ' where 1=1 ' 
	    
			   if (@strCompanyLocationId IS NOT NULL)
				  BEGIN 
						set @SqlQuery1 = @SqlQuery1 +  ' and  tblICItemPricing.intItemLocationId
						IN (select intItemLocationId from tblICItemLocation where intLocationId
						IN (select intLocationId from tblICItemLocation where intLocationId 
						IN (' + CAST(@strCompanyLocationId as NVARCHAR) + ')' + '))'
				  END

			   if (@strVendorId IS NOT NULL)
				   BEGIN 
						 set @SqlQuery1 = @SqlQuery1 +  ' and  tblICItemPricing.intItemLocationId
						 IN (select intItemLocationId from tblICItemLocation where intVendorId
						 IN (select intEntityId from tblEMEntity where intEntityId 
						 IN (' + CAST(@strVendorId as NVARCHAR) + ')' + '))'
				   END

			   if (@strCategoryId IS NOT NULL)
				   BEGIN
						 set @SqlQuery1 = @SqlQuery1 +  ' and tblICItemPricing.intItemId  
						 IN (select intItemId from tblICItem where intCategoryId IN
						 (select intCategoryId from tblICCategory where intCategoryId 
						 IN (' + CAST(@strCategoryId as NVARCHAR) + ')' + '))'
				   END

			   if (@strFamilyId IS NOT NULL)
				   BEGIN
						  set @SqlQuery1 = @SqlQuery1 +  ' and tblICItemPricing.intItemLocationId IN 
						  (select intItemLocationId from tblICItemLocation where intFamilyId IN
						  (select intFamilyId from tblICItemLocation where intFamilyId 
						  IN (' + CAST(@strFamilyId as NVARCHAR) + ')' + '))'
				   END

				if (@strClassId  IS NOT NULL)
					BEGIN
						  set @SqlQuery1 = @SqlQuery1 +  ' and tblICItemPricing.intItemLocationId IN 
						  (select intItemLocationId from tblICItemLocation where intClassId IN
						  (select intClassId from tblICItemLocation where intClassId 
						  IN (' + CAST(@strClassId as NVARCHAR) + ')' + '))'
					 END

				if (@intUpcCode IS NOT NULL)
					BEGIN
						  set @SqlQuery1 = @SqlQuery1 +  ' and tblICItemPricing.intItemId  
						 IN (select intItemId from tblICItemUOM where  intItemUOMId IN
						  (select intItemUOMId from tblICItemUOM  where intItemUOMId 
						  IN (' + CAST(@intUpcCode as NVARCHAR) + ')' + '))'
					END

				if ((@strRegion IS NOT NULL)
				and(@strRegion != ''))
			 		   BEGIN
						 set @SqlQuery1 = @SqlQuery1 +  ' and tblICItemPricing.intItemLocationId IN 
						 (select intItemLocationId from tblICItemLocation where intLocationId IN 
						 (select intCompanyLocationId from tblSTStore where strRegion 
						 IN ( ''' + (@strRegion) + ''')' + '))'
					   END

				if ((@strDistrict IS NOT NULL)
				and(@strDistrict != ''))
					BEGIN
			 			 set @SqlQuery1 = @SqlQuery1 +  ' and tblICItemPricing.intItemLocationId IN 
						 (select intItemLocationId from tblICItemLocation where intLocationId IN 
						 (select intCompanyLocationId from tblSTStore where strDistrict 
						 IN ( ''' + (@strDistrict) + ''')' + '))'
					END

			   if ((@strState IS NOT NULL)
				and(@strState != ''))
					BEGIN
					   set @SqlQuery1 = @SqlQuery1 +  ' and tblICItemPricing.intItemLocationId IN 
					   (select intItemLocationId from tblICItemLocation where intLocationId IN 
					   (select intCompanyLocationId from tblSTStore where strState 
						IN ( ''' + (@strState) + ''')' + '))'
					END

			   if ((@strDescription IS NOT NULL)
				and (@strDescription != ''))
					BEGIN
					   set @SqlQuery1 = @SqlQuery1 +  ' and tblICItemPricing.intItemId IN 
					   (select intItemId from tblICItem where strDescription 
						like ''%' + LTRIM(@strDescription) + '%'' )'
					END

				EXEC (@SqlQuery1)

		  SELECT  @UpdateCount =   @UpdateCount + (@@ROWCOUNT) 
		  END


		 IF ((@dblSalesPrice IS NOT NULL)
		  OR (@dtmSalesStartingDate IS NOT NULL)
		  OR (@dtmSalesEndingDate IS NOT NULL))
		  BEGIN
			   set @SqlQuery1 = ' update tblICItemSpecialPricing set '

			   if (@dblSalesPrice IS NOT NULL)
			   BEGIN
				 set @SqlQuery1 = @SqlQuery1 + 'dblUnitAfterDiscount = ''' + LTRIM(@dblSalesPrice) + ''''
			   END

			   if (@dtmSalesStartingDate IS NOT NULL)  
			  BEGIN
				  if (@dblSalesPrice IS NOT NULL)
					  set @SqlQuery1 = @SqlQuery1 + ' , dtmBeginDate = ''' + LTRIM(@dtmSalesStartingDate) + ''''
				 else
					set @SqlQuery1 = @SqlQuery1 + ' dtmBeginDate = ''' + LTRIM(@dtmSalesStartingDate) + '''' 
			   END

			   if (@dtmSalesEndingDate IS NOT NULL)  
			  BEGIN
				  if ((@dblSalesPrice IS NOT NULL)
				   OR (@dtmSalesStartingDate IS NOT NULL))
					  set @SqlQuery1 = @SqlQuery1 + ' , dtmEndDate = ''' + LTRIM(@dtmSalesEndingDate) + ''''
				 else
					  set @SqlQuery1 = @SqlQuery1 + ' dtmEndDate = ''' + LTRIM(@dtmSalesEndingDate) + '''' 
			   END

			   set @SqlQuery1 = @SqlQuery1 + ' where 1=1 ' 

			   if (@strCompanyLocationId IS NOT NULL)
				  BEGIN 
						set @SqlQuery1 = @SqlQuery1 +  ' and  tblICItemSpecialPricing.intItemLocationId
						IN (select intItemLocationId from tblICItemLocation where intLocationId
						IN (select intLocationId from tblICItemLocation where intLocationId
						IN (' + CAST(@strCompanyLocationId as NVARCHAR) + ')' + '))'
				  END

			   if (@strVendorId IS NOT NULL)
				   BEGIN 
						 set @SqlQuery1 = @SqlQuery1 +  ' and  tblICItemSpecialPricing.intItemLocationId
						 IN (select intItemLocationId from tblICItemLocation where intVendorId
						 IN (select intEntityId from tblEMEntity where intEntityId 
						 IN (' + CAST(@strVendorId as NVARCHAR) + ')' + '))'
				   END

				  if (@strCategoryId IS NOT NULL)
					 BEGIN
						  set @SqlQuery1 = @SqlQuery1 +  ' and tblICItemSpecialPricing.intItemId  
						  IN (select intItemId from tblICItem where intCategoryId IN
						  (select intCategoryId from tblICCategory where intCategoryId
						   IN (' + CAST(@strCategoryId as NVARCHAR) + ')' + '))'
					 END

				  if (@strFamilyId IS NOT NULL)
					 BEGIN
						  set @SqlQuery1 = @SqlQuery1 +  ' and tblICItemSpecialPricing.intItemLocationId IN 
						  (select intItemLocationId from tblICItemLocation where intFamilyId IN
						  (select intFamilyId from tblICItemLocation where intFamilyId 
						  IN (' + CAST(@strFamilyId as NVARCHAR) + ')' + '))'
					 END

				  if (@strClassId IS NOT NULL)
					  BEGIN
						  set @SqlQuery1 = @SqlQuery1 +  ' and tblICItemSpecialPricing.intItemLocationId IN 
						  (select intItemLocationId from tblICItemLocation where intClassId IN
						  (select intClassId from tblICItemLocation where intClassId 
						  IN (' + CAST(@strClassId as NVARCHAR) + ')' + '))'
					   END

				   if (@intUpcCode IS NOT NULL)
					   BEGIN
						   set @SqlQuery1 = @SqlQuery1 +  ' and tblICItemSpecialPricing.intItemId  
						  IN (select intItemId from tblICItemUOM where  intItemUOMId IN
						   (select intItemUOMId from tblICItemUOM  where intItemUOMId 
						   IN (' + CAST(@intUpcCode as NVARCHAR) + ')' + '))'
					   END

					if ((@strRegion IS NOT NULL)
					and(@strRegion != ''))
						BEGIN
						 set @SqlQuery1 = @SqlQuery1 +  ' and tblICItemSpecialPricing.intItemLocationId IN 
						 (select intItemLocationId from tblICItemLocation where intLocationId IN 
						 (select intCompanyLocationId from tblSTStore where strRegion 
						 IN ( ''' + (@strRegion) + ''')' + '))'
						END

					if ((@strDistrict IS NOT NULL)
					and(@strDistrict != ''))
						BEGIN
						 set @SqlQuery1 = @SqlQuery1 +  ' and tblICItemSpecialPricing.intItemLocationId IN 
						 (select intItemLocationId from tblICItemLocation where intLocationId IN 
						 (select intCompanyLocationId from tblSTStore where strDistrict 
						 IN ( ''' + (@strDistrict) + ''')' + '))'
						END

				   if ((@strState IS NOT NULL)
					and(@strState != ''))
						BEGIN
						 set @SqlQuery1 = @SqlQuery1 +  ' and tblICItemSpecialPricing.intItemLocationId IN 
						 (select intItemLocationId from tblICItemLocation where intLocationId IN 
						 (select intCompanyLocationId from tblSTStore where strState 
						 IN ( ''' + (@strState) + ''')' + '))'
						END

				   if ((@strDescription IS NOT NULL)
					and (@strDescription != ''))
					BEGIN
					   set @SqlQuery1 = @SqlQuery1 +  ' and tblICItemSpecialPricing.intItemId IN 
					   (select intItemId from tblICItem where strDescription 
						like ''%' + LTRIM(@strDescription) + '%'' )'
					END
			

					SET @SqlQuery1 = @SqlQuery1 + ' and  strPromotionType = ''Discount'''

					EXEC (@SqlQuery1)
					SELECT  @UpdateCount =   @UpdateCount + (@@ROWCOUNT)   
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
			    
								IF(@strChangeDescription = 'Standard Cost' OR @strChangeDescription = 'Retail Price')
								BEGIN
									SET @ItemPricingAuditLog = @ItemPricingAuditLog + '{"change":"dblStandardCost","from":"' + @strOldData + '","to":"' + @strNewData + '","leaf":true,"iconCls":"small-gear","isField":true,"keyValue":' + CAST(@intChildId AS NVARCHAR(50)) + ',"associationKey":"tblICItemPricings","changeDescription":"' + @strChangeDescription + '","hidden":false},'
								END

								ELSE IF(@strChangeDescription = 'Sales Price' OR @strChangeDescription = 'Sales start date' OR @strChangeDescription = 'Sales end date')
								BEGIN
									SET @ItemSpecialPricingAuditLog = @ItemSpecialPricingAuditLog + '{"change":"dblStandardCost","from":"' + @strOldData + '","to":"' + @strNewData + '","leaf":true,"iconCls":"small-gear","isField":true,"keyValue":' + CAST(@intChildId AS NVARCHAR(50)) + ',"associationKey":"tblICItemSpecialPricings","changeDescription":"' + @strChangeDescription + '","hidden":false},'
								END

								SET @RowCountMin = @RowCountMin + 1
								DELETE TOP (1) FROM @tblTempTwo
							END


						--INSERT to AUDITLOG
						--=================================================================================================
						--tblICItemPricing
						IF (@ItemPricingAuditLog != '')
						BEGIN
							--Remove last character comma(,)
							SET @ItemPricingAuditLog = left(@ItemPricingAuditLog, len(@ItemPricingAuditLog)-1)

							SET @ItemPricingAuditLog = '{"change":"tblICItemPricings","children":[{"action":"Updated","change":"Updated - Record: ' + CAST(@intChildId AS NVARCHAR(50)) + '","keyValue":' + CAST(@intChildId AS NVARCHAR(50)) + ',"iconCls":"small-tree-modified","children":[' + @ItemPricingAuditLog + ']}],"iconCls":"small-tree-grid","changeDescription":"Pricing"},'
						END

						--tblICItemSpecialPricing
						IF (@ItemSpecialPricingAuditLog != '')
						BEGIN
							--Remove last character comma(,)
							SET @ItemSpecialPricingAuditLog = left(@ItemSpecialPricingAuditLog, len(@ItemSpecialPricingAuditLog)-1)

							SET @ItemSpecialPricingAuditLog = '{"change":"tblICItemSpecialPricings","children":[{"action":"Updated","change":"Updated - Record: ' + CAST(@intChildId AS NVARCHAR(50)) + '","keyValue":' + CAST(@intChildId AS NVARCHAR(50)) + ',"iconCls":"small-tree-modified","children":[' + @ItemSpecialPricingAuditLog + ']}],"iconCls":"small-tree-grid","changeDescription":"Promotional Pricing"},'
						END

						SET @JsonStringAuditLog = @ItemPricingAuditLog + @ItemSpecialPricingAuditLog


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
						-- =================================================================================================

						--Clear
						SET @ItemPricingAuditLog = ''
						SET @ItemSpecialPricingAuditLog = ''

						DELETE TOP (1) FROM @tblId
					END
					-- ==========================================================================================================================================
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


   -- Query Preview display
   SELECT @strCompanyName as CompanyName
		  --, FORMAT(GETDATE(), 'D', 'en-US' ) as DateToday
		  --, CONVERT(VARCHAR(8), GETDATE(), 108) + ' ' + RIGHT(CONVERT(VARCHAR(30), GETDATE(), 9), 2) as TimeToday
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