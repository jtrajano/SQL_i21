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

	IF LTRIM(RTRIM(@xmlParam)) = ''
		SET @xmlParam = NULL

	--Declare xmlParam holder
	DECLARE @temp_xml_table TABLE 
	(  
			[fieldname]		NVARCHAR(50),  
			condition		NVARCHAR(20),        
			[from]			NVARCHAR(50), 
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
				[fieldname]		NVARCHAR(50),  
				condition		NVARCHAR(20),        
				[from]			NVARCHAR(50), 
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
	--END Handle xml Param

   --Declare UpdatePreview holder
   DECLARE @tblMassUpdatePreview TABLE 
   (
		strLocation NVARCHAR(250)
		, strUpc NVARCHAR(50)
		, strItemDescription NVARCHAR(250)
		, strChangeDescription NVARCHAR(MAX)
		, strOldData NVARCHAR(MAX)
		, strNewData NVARCHAR(MAX)
   )

	
	DECLARE @UpdateCount INT
	DECLARE @RecCount INT

	SET @UpdateCount = 0
	SET @RecCount = 0

	DECLARE @CompanyCurrencyDecimal NVARCHAR(1)
	SET @CompanyCurrencyDecimal = 0
	SELECT @CompanyCurrencyDecimal = intCurrencyDecimal from tblSMCompanyPreference

	DECLARE @SqlQuery1 as NVARCHAR(MAX)
	-----------------------------------Handle Dynamic Query 1
	IF (@dtmBeginDate IS NOT NULL)
    BEGIN
			SET @dtmBeginDate = CONVERT(VARCHAR(10),@dtmBeginDate,111)
			SET @SqlQuery1 = 'SELECT' + CHAR(13)
		                 + ' e.strLocationName' + CHAR(13)
		                 + ', b.strUpcCode' + CHAR(13)
		                 + ', c.strDescription' + CHAR(13)
		                 + ', ''Begining Date'',' + CHAR(13)
		                 + ' REPLACE(CONVERT(NVARCHAR(10),a.dtmBeginDate,111), ''/'', ''-'')' + CHAR(13)
		                 + ', ''' + CAST(@dtmBeginDate as NVARCHAR(250)) + '''' + CHAR(13)
		                 + ' FROM tblICItemSpecialPricing a' + CHAR(13)
		                 + ' JOIN tblICItemUOM b ON a.intItemUnitMeasureId = b.intItemUOMId' + CHAR(13)
		                 + ' JOIN tblICItem c ON a.intItemId = c.intItemId' + CHAR(13)
		                 + ' JOIN tblICItemLocation d ON a.intItemId = d.intItemId' + CHAR(13)
		                 + ' JOIN tblSMCompanyLocation e ON d.intLocationId = e.intCompanyLocationId '

			SET @SqlQuery1 = @SqlQuery1 + ' WHERE 1=1 ' 

          IF (@strCompanyLocationId <> '')
          BEGIN 
             SET @SqlQuery1 = @SqlQuery1 + ' and d.intLocationId IN (' + CAST(@strCompanyLocationId as NVARCHAR) + ')'
          END

          IF (@strVendorId <> '')
          BEGIN 
            SET @SqlQuery1 = @SqlQuery1 +  ' and  a.intItemLocationId
            IN (select intItemLocationId from tblICItemLocation where intVendorId
            IN (select intEntityId from tblEMEntity where intEntityId 
	      IN (' + CAST(@strVendorId as NVARCHAR) + ')' + '))'
          END

          IF (@strCategoryId <> '')
          BEGIN
             SET @SqlQuery1 = @SqlQuery1 +  ' and a.intItemId  
             IN (select intItemId from tblICItem where intCategoryId IN
             (select intCategoryId from tblICCategory where intCategoryId
             IN (' + CAST(@strCategoryId as NVARCHAR) + ')' + '))'
          END

          IF (@strFamilyId <> '')
          BEGIN
            SET @SqlQuery1 = @SqlQuery1 +  ' and a.intItemLocationId IN 
            (select intItemLocationId from tblICItemLocation where intFamilyId IN
            (select intFamilyId from tblICItemLocation where intFamilyId 
		    IN (' + CAST(@strFamilyId as NVARCHAR) + ')' + '))'
          END

          IF (@strClassId <> '')
          BEGIN
              SET @SqlQuery1 = @SqlQuery1 +  ' and a.intItemLocationId IN 
              (select intItemLocationId from tblICItemLocation where intClassId IN
              (select intClassId from tblICItemLocation where intClassId 
			  IN (' + CAST(@strClassId as NVARCHAR) + ')' + '))'
          END

			IF(@strPromotionType = 'Vendor Rebate')
			BEGIN
				 SET @SqlQuery1 = @SqlQuery1 + ' and  a.strPromotionType = ''Rebate''' 
			END
			IF (@strPromotionType = 'Vendor Discount')
			BEGIN
				 SET @SqlQuery1 = @SqlQuery1 + ' and  a.strPromotionType = ''Vendor Discount''' 
			END

		INSERT @tblMassUpdatePreview
		EXEC (@SqlQuery1)
	END


	-----------------------------------Handle Dynamic Query 2
    IF (@dtmEndDate IS NOT NULL)
    BEGIN
         SET @dtmEndDate = CONVERT(VARCHAR(10),@dtmEndDate,111)
         SET @SqlQuery1 = 'SELECT' + CHAR(13)
								+ ' e.strLocationName' + CHAR(13)
								+ ', b.strUpcCode' + CHAR(13)
								+ ', c.strDescription' + CHAR(13)
								+ ', ''Ending Date''' + CHAR(13)
								+ ', REPLACE(CONVERT(NVARCHAR(10),a.dtmEndDate,111), ''/'', ''-'')' + CHAR(13)
								+ ', ''' + CAST(@dtmEndDate as NVARCHAR(250)) + '''' + CHAR(13)
							+ ' FROM tblICItemSpecialPricing a' + CHAR(13)
		                + ' JOIN tblICItemUOM b ON a.intItemUnitMeasureId = b.intItemUOMId' + CHAR(13)
		                + ' JOIN tblICItem c ON a.intItemId = c.intItemId' + CHAR(13)
		                + ' JOIN tblICItemLocation d ON a.intItemId = d.intItemId' + CHAR(13)
		                + ' JOIN tblSMCompanyLocation e ON d.intLocationId = e.intCompanyLocationId '

	    SET @SqlQuery1 = @SqlQuery1 + ' WHERE 1=1 ' 

          IF (@strCompanyLocationId <> '')
          BEGIN 
             SET @SqlQuery1 = @SqlQuery1 + ' and d.intLocationId IN (' + CAST(@strCompanyLocationId as NVARCHAR) + ')'
          END

          IF (@strVendorId <> '')
          BEGIN 
            SET @SqlQuery1 = @SqlQuery1 +  ' and  a.intItemLocationId
            IN (select intItemLocationId from tblICItemLocation where intVendorId
            IN (select intEntityId from tblEMEntity where intEntityId 
	      IN (' + CAST(@strVendorId as NVARCHAR) + ')' + '))'
          END

          IF (@strCategoryId <> '')
          BEGIN
             SET @SqlQuery1 = @SqlQuery1 +  ' and a.intItemId  
             IN (select intItemId from tblICItem where intCategoryId IN
             (select intCategoryId from tblICCategory where intCategoryId
             IN (' + CAST(@strCategoryId as NVARCHAR) + ')' + '))'
          END

          IF (@strFamilyId <> '')
          BEGIN
             SET @SqlQuery1 = @SqlQuery1 +  ' and a.intItemLocationId IN 
             (select intItemLocationId from tblICItemLocation where intFamilyId IN
             (select intFamilyId from tblICItemLocation where intFamilyId 
		     IN (' + CAST(@strFamilyId as NVARCHAR) + ')' + '))'
          END

          IF (@strClassId <> '')
          BEGIN
              SET @SqlQuery1 = @SqlQuery1 +  ' and a.intItemLocationId IN 
              (select intItemLocationId from tblICItemLocation where intClassId IN
              (select intClassId from tblICItemLocation where intClassId 
			  IN (' + CAST(@strClassId as NVARCHAR) + ')' + '))'
          END

	    IF(@strPromotionType = 'Vendor Rebate')
		BEGIN
             SET @SqlQuery1 = @SqlQuery1 + ' and  a.strPromotionType = ''Rebate''' 
	    END
		IF (@strPromotionType = 'Vendor Discount')
		BEGIN
		     SET @SqlQuery1 = @SqlQuery1 + ' and  a.strPromotionType = ''Vendor Discount''' 
		END

		INSERT @tblMassUpdatePreview
		EXEC (@SqlQuery1)
     END


    -----------------------------------Handle Dynamic Query 3
	IF (@strPromotionType = 'Vendor Rebate')
	 BEGIN
		 IF (@dblRebateAmount <> 0)
		 BEGIN

			SET @SqlQuery1 = 'SELECT' + CHAR(13)
								   + ' e.strLocationName' + CHAR(13)
								   + ', b.strUpcCode' + CHAR(13)
								   + ', c.strDescription' + CHAR(13)
								   + ', ''Rebate Amount''' + CHAR(13)
								   + ', CAST(a.dblDiscount AS DECIMAL(18, ' + @CompanyCurrencyDecimal + '))' + CHAR(13)
								   + ', CAST(' + CAST(@dblRebateAmount AS NVARCHAR(250)) + ' AS DECIMAL(18, ' + @CompanyCurrencyDecimal + '))' + CHAR(13)
								   --+ ', STR(a.dblDiscount, 25, ' + CAST(@CompanyCurrencyDecimal as NVARCHAR(1)) + ')' + CHAR(13)
								   --+ ', CAST(a.dblDiscount as NVARCHAR(250))' + CHAR(13)
								   --+ ', ''' + STR(@dblRebateAmount, 25, @CompanyCurrencyDecimal) + '''' + CHAR(13)
								   --+ ', ''' + CAST(@dblRebateAmount as NVARCHAR(250)) + '''' + CHAR(13)
			               + ' FROM tblICItemSpecialPricing a' + CHAR(13)
			               + ' JOIN tblICItemUOM b ON a.intItemUnitMeasureId = b.intItemUOMId' + CHAR(13)
			               + ' JOIN tblICItem c ON a.intItemId = c.intItemId' + CHAR(13)
			               + ' JOIN tblICItemLocation d ON a.intItemId = d.intItemId' + CHAR(13)
			               + ' JOIN tblSMCompanyLocation e ON d.intLocationId = e.intCompanyLocationId '

			SET @SqlQuery1 = @SqlQuery1 + ' WHERE 1=1 ' 

			  IF (@strCompanyLocationId <> '')
			  BEGIN 
				 SET @SqlQuery1 = @SqlQuery1 + ' and d.intLocationId IN (' + CAST(@strCompanyLocationId as NVARCHAR) + ')'
			  END

			  IF (@strVendorId <> '')
			  BEGIN 
				SET @SqlQuery1 = @SqlQuery1 +  ' and  a.intItemLocationId
				IN (select intItemLocationId from tblICItemLocation where intVendorId
				IN (select intEntityId from tblEMEntity where intEntityId 
				IN (' + CAST(@strVendorId as NVARCHAR) + ')' + '))'
			  END

			  IF (@strCategoryId <> '')
			  BEGIN
				 SET @SqlQuery1 = @SqlQuery1 +  ' and a.intItemId  
				 IN (select intItemId from tblICItem where intCategoryId IN
			     (select intCategoryId from tblICCategory where intCategoryId
			     IN (' + CAST(@strCategoryId as NVARCHAR) + ')' + '))'
			  END

			  IF (@strFamilyId <> '')
			  BEGIN
				SET @SqlQuery1 = @SqlQuery1 +  ' and a.intItemLocationId IN 
				(select intItemLocationId from tblICItemLocation where intFamilyId IN
				(select intFamilyId from tblICItemLocation where intFamilyId 
				IN (' + CAST(@strFamilyId as NVARCHAR) + ')' + '))'
			  END

			  IF (@strClassId <> '')
			  BEGIN
				SET @SqlQuery1 = @SqlQuery1 +  ' and a.intItemLocationId IN 
				  (select intItemLocationId from tblICItemLocation where intClassId IN
				  (select intClassId from tblICItemLocation where intClassId 
				  IN (' + CAST(@strClassId as NVARCHAR) + ')' + '))'
			  END

			  SET @SqlQuery1 = @SqlQuery1 + ' and  a.strPromotionType = ''Rebate''' 

			  INSERT @tblMassUpdatePreview
			  EXEC (@SqlQuery1)
		 END

		 IF (@dblAccumAmount <> 0)
		 BEGIN

			SET @SqlQuery1 = 'SELECT' + CHAR(13)
								   + ' e.strLocationName' + CHAR(13)
								   + ', b.strUpcCode' + CHAR(13)
								   + ', c.strDescription' + CHAR(13)
								   + ', ''Accumlated Amount''' + CHAR(13)
								   + ', CAST(a.dblAccumulatedAmount AS DECIMAL(18, ' + @CompanyCurrencyDecimal + '))' + CHAR(13)
								   + ', CAST(' + CAST(@dblAccumAmount AS NVARCHAR(250)) + ' AS DECIMAL(18, ' + @CompanyCurrencyDecimal + '))' + CHAR(13)
								   --+ ', CAST(a.dblAccumulatedAmount as NVARCHAR(250))' + CHAR(13)
								   --+ ', ''' + CAST(@dblAccumAmount as NVARCHAR(250)) + '''' + CHAR(13)
			               + ' FROM tblICItemSpecialPricing a' + CHAR(13)
			               + ' JOIN tblICItemUOM b ON a.intItemUnitMeasureId = b.intItemUOMId' + CHAR(13)
			               + ' JOIN tblICItem c ON a.intItemId = c.intItemId' + CHAR(13)
			               + ' JOIN tblICItemLocation d ON a.intItemId = d.intItemId' + CHAR(13)
			               + ' JOIN tblSMCompanyLocation e ON d.intLocationId = e.intCompanyLocationId '

			SET @SqlQuery1 = @SqlQuery1 + ' WHERE 1=1 ' 

			  IF (@strCompanyLocationId <> '')
			  BEGIN 
					SET @SqlQuery1 = @SqlQuery1 + ' and d.intLocationId IN (' + CAST(@strCompanyLocationId as NVARCHAR) + ')'
			  END

			  IF (@strVendorId <> '')
			  BEGIN 
					SET @SqlQuery1 = @SqlQuery1 +  ' and  a.intItemLocationId
					IN (select intItemLocationId from tblICItemLocation where intVendorId
					IN (select intEntityId from tblEMEntity where intEntityId 
					IN (' + CAST(@strVendorId as NVARCHAR) + ')' + '))'
			  END

			  IF (@strCategoryId <> '')
			  BEGIN
					SET @SqlQuery1 = @SqlQuery1 +  ' and a.intItemId  
					IN (select intItemId from tblICItem where intCategoryId IN
					(select intCategoryId from tblICCategory where intCategoryId
					IN (' + CAST(@strCategoryId as NVARCHAR) + ')' + '))'
			  END

			  IF (@strFamilyId <> '')
			  BEGIN
					SET @SqlQuery1 = @SqlQuery1 +  ' and a.intItemLocationId IN 
					(select intItemLocationId from tblICItemLocation where intFamilyId IN
					(select intFamilyId from tblICItemLocation where intFamilyId 
					IN (' + CAST(@strFamilyId as NVARCHAR) + ')' + '))'
			  END

			  IF (@strClassId <> '')
			  BEGIN
					SET @SqlQuery1 = @SqlQuery1 +  ' and a.intItemLocationId IN 
					(select intItemLocationId from tblICItemLocation where intClassId IN
					(select intClassId from tblICItemLocation where intClassId 
					IN (' + CAST(@strClassId as NVARCHAR) + ')' + '))'
			  END

			SET @SqlQuery1 = @SqlQuery1 + ' and  a.strPromotionType = ''Rebate''' 

			INSERT @tblMassUpdatePreview
			EXEC (@SqlQuery1)

		 END

		 IF (@dblAccumlatedQty <> 0)
		 BEGIN

			 SET @SqlQuery1 = 'SELECT' + CHAR(13)
									+ ' e.strLocationName' + CHAR(13)
									+ ', b.strUpcCode' + CHAR(13)
									+ ', c.strDescription' + CHAR(13)
									+ ', ''Accumlated Quantity''' + CHAR(13)
									+ ', CAST(a.dblAccumulatedQty AS DECIMAL(18, ' + @CompanyCurrencyDecimal + '))' + CHAR(13)
								    + ', CAST(' + CAST(@dblAccumlatedQty AS NVARCHAR(250)) + ' AS DECIMAL(18, ' + @CompanyCurrencyDecimal + '))' + CHAR(13)
									--+ ', CAST(a.dblAccumulatedQty as NVARCHAR(250))' + CHAR(13)
									--+ ', ''' + CAST(@dblAccumlatedQty as NVARCHAR(250)) + '''' + CHAR(13)
			                + ' FROM tblICItemSpecialPricing a' + CHAR(13)
			                + ' JOIN tblICItemUOM b ON a.intItemUnitMeasureId = b.intItemUOMId' + CHAR(13)
			                + ' JOIN tblICItem c ON a.intItemId = c.intItemId' + CHAR(13)
			                + ' JOIN tblICItemLocation d ON a.intItemId = d.intItemId' + CHAR(13)
			                + ' JOIN tblSMCompanyLocation e ON d.intLocationId = e.intCompanyLocationId '

			 SET @SqlQuery1 = @SqlQuery1 + ' where 1=1 ' 

			  IF (@strCompanyLocationId <> '')
			  BEGIN 
					SET @SqlQuery1 = @SqlQuery1 + ' and d.intLocationId IN (' + CAST(@strCompanyLocationId as NVARCHAR) + ')'
			  END				    

			  IF (@strVendorId <> '')
			  BEGIN 
					SET @SqlQuery1 = @SqlQuery1 +  ' and  a.intItemLocationId
					IN (select intItemLocationId from tblICItemLocation where intVendorId
					IN (select intEntityId from tblEMEntity where intEntityId 
					IN (' + CAST(@strVendorId as NVARCHAR) + ')' + '))'
			  END

			  IF (@strCategoryId <> '')
			  BEGIN
				    SET @SqlQuery1 = @SqlQuery1 +  ' and a.intItemId  
				    IN (select intItemId from tblICItem where intCategoryId IN
			        (select intCategoryId from tblICCategory where intCategoryId
			        IN (' + CAST(@strCategoryId as NVARCHAR) + ')' + '))'
			  END

			  IF (@strFamilyId <> '')
			  BEGIN
					SET @SqlQuery1 = @SqlQuery1 +  ' and a.intItemLocationId IN 
					(select intItemLocationId from tblICItemLocation where intFamilyId IN
					(select intFamilyId from tblICItemLocation where intFamilyId 
					IN (' + CAST(@strFamilyId as NVARCHAR) + ')' + '))'
			  END

			  IF (@strClassId <> '')
			  BEGIN
				    SET @SqlQuery1 = @SqlQuery1 +  ' and a.intItemLocationId IN 
				    (select intItemLocationId from tblICItemLocation where intClassId IN
				    (select intClassId from tblICItemLocation where intClassId 
				    IN (' + CAST(@strClassId as NVARCHAR) + ')' + '))'
			  END

			SET @SqlQuery1 = @SqlQuery1 + ' and  a.strPromotionType = ''Rebate''' 

			INSERT @tblMassUpdatePreview
			EXEC (@SqlQuery1)
		 END
	 END


	-----------------------------------Handle Dynamic Query 4
	IF (@strPromotionType = 'Vendor Discount')
	BEGIN

		 IF (@dblDiscAmountUnit <> 0)
		 BEGIN

			  SET @SqlQuery1 = 'SELECT' + CHAR(13)
									 + ' e.strLocationName' + CHAR(13)
									 + ', b.strUpcCode' + CHAR(13)
									 + ', c.strDescription' + CHAR(13)
									 + ', ''Discount Amount''' + CHAR(13)
									 + ', CAST(a.dblDiscount AS DECIMAL(18, ' + @CompanyCurrencyDecimal + '))' + CHAR(13)
								     + ', CAST(' + CAST(@dblDiscAmountUnit AS NVARCHAR(250)) + ' AS DECIMAL(18, ' + @CompanyCurrencyDecimal + '))' + CHAR(13)
									 --+ ', STR(a.dblDiscount, 25, ' + CAST(@CompanyCurrencyDecimal as NVARCHAR(1)) + ')' + CHAR(13)
									 --+ ', CAST(a.dblDiscount as NVARCHAR(250))' + CHAR(13)
									 --+ ', ''' + STR(@dblDiscAmountUnit, 25, @CompanyCurrencyDecimal) + '''' + CHAR(13)
									 --+ ', ''' + CAST(@dblDiscAmountUnit as NVARCHAR(250)) + '''' + CHAR(13)
			                 + ' FROM tblICItemSpecialPricing a' + CHAR(13)
			                 + ' JOIN tblICItemUOM b ON a.intItemUnitMeasureId = b.intItemUOMId' + CHAR(13)
			                 + ' JOIN tblICItem c ON a.intItemId = c.intItemId' + CHAR(13)
			                 + ' JOIN tblICItemLocation d ON a.intItemId = d.intItemId' + CHAR(13)
						     + ' JOIN tblSMCompanyLocation e ON d.intLocationId = e.intCompanyLocationId '

			  SET @SqlQuery1 = @SqlQuery1 + ' WHERE 1=1 ' 

			  IF (@strCompanyLocationId <> '')
			  BEGIN 
					SET @SqlQuery1 = @SqlQuery1 + ' and d.intLocationId IN (' + CAST(@strCompanyLocationId as NVARCHAR) + ')'
			  END				    				   

			  IF (@strVendorId <> '')
			  BEGIN 
					SET @SqlQuery1 = @SqlQuery1 +  ' and  a.intItemLocationId
					IN (select intItemLocationId from tblICItemLocation where intVendorId
					IN (select intEntityId from tblEMEntity where intEntityId 
					IN (' + CAST(@strVendorId as NVARCHAR) + ')' + '))'
			  END

			  IF (@strCategoryId <> '')
			  BEGIN
					SET @SqlQuery1 = @SqlQuery1 +  ' and a.intItemId  
					IN (select intItemId from tblICItem where intCategoryId IN
					(select intCategoryId from tblICCategory where intCategoryId
					IN (' + CAST(@strCategoryId as NVARCHAR) + ')' + '))'
			  END

			  IF (@strFamilyId <> '')
			  BEGIN
					SET @SqlQuery1 = @SqlQuery1 +  ' and a.intItemLocationId IN 
					(select intItemLocationId from tblICItemLocation where intFamilyId IN
					(select intFamilyId from tblICItemLocation where intFamilyId 
					IN (' + CAST(@strFamilyId as NVARCHAR) + ')' + '))'
			  END

			  IF (@strClassId <> '')
			  BEGIN
					SET @SqlQuery1 = @SqlQuery1 +  ' and a.intItemLocationId IN 
					(select intItemLocationId from tblICItemLocation where intClassId IN
					(select intClassId from tblICItemLocation where intClassId 
					IN (' + CAST(@strClassId as NVARCHAR) + ')' + '))'
			  END

			SET @SqlQuery1 = @SqlQuery1 + ' and  a.strPromotionType = ''Vendor Discount''' 

			INSERT @tblMassUpdatePreview
			EXEC (@SqlQuery1)
		 END

		 IF (@dblDiscThroughAmount <> 0)
		 BEGIN
			SET @SqlQuery1 = 'SELECT' + CHAR(13)
								   + ' e.strLocationName' + CHAR(13)
								   + ', b.strUpcCode' + CHAR(13)
								   + ', c.strDescription' + CHAR(13)
								   + ', ''Discoount through amount''' + CHAR(13)
								   + ', CAST(a.dblDiscountThruAmount AS DECIMAL(18, ' + @CompanyCurrencyDecimal + '))' + CHAR(13)
								   + ', CAST(' + CAST(@dblDiscThroughAmount AS NVARCHAR(250)) + ' AS DECIMAL(18, ' + @CompanyCurrencyDecimal + '))' + CHAR(13)
								   --+ ', CAST(a.dblDiscountThruAmount as NVARCHAR(250))' + CHAR(13)
								   --+ ', ''' + CAST(@dblDiscThroughAmount as NVARCHAR(250)) + '''' + CHAR(13)
			               + ' FROM tblICItemSpecialPricing a' + CHAR(13)
			               + ' JOIN tblICItemUOM b ON a.intItemUnitMeasureId = b.intItemUOMId' + CHAR(13)
			               + ' JOIN tblICItem c ON a.intItemId = c.intItemId' + CHAR(13)
			               + ' JOIN tblICItemLocation d ON a.intItemId = d.intItemId' + CHAR(13)
			               + ' JOIN tblSMCompanyLocation e ON d.intLocationId = e.intCompanyLocationId '

			SET @SqlQuery1 = @SqlQuery1 + ' WHERE 1=1 ' 

			  IF (@strCompanyLocationId <> '')
			  BEGIN 
					SET @SqlQuery1 = @SqlQuery1 + ' and d.intLocationId IN (' + CAST(@strCompanyLocationId as NVARCHAR) + ')'
			  END				    				   
			
			  IF (@strVendorId IS NOT NULL)
			  BEGIN 
					SET @SqlQuery1 = @SqlQuery1 +  ' and  a.intItemLocationId
					IN (select intItemLocationId from tblICItemLocation where intVendorId
					IN (select intEntityId from tblEMEntity where intEntityId 
					IN (' + CAST(@strVendorId as NVARCHAR) + ')' + '))'
			  END

			  IF (@strCategoryId <> '')
			  BEGIN
					SET @SqlQuery1 = @SqlQuery1 +  ' and a.intItemId  
					IN (select intItemId from tblICItem where intCategoryId IN
					(select intCategoryId from tblICCategory where intCategoryId
					IN (' + CAST(@strCategoryId as NVARCHAR) + ')' + '))'
			  END

			  IF (@strFamilyId <> '')
			  BEGIN
					SET @SqlQuery1 = @SqlQuery1 +  ' and a.intItemLocationId IN 
					(select intItemLocationId from tblICItemLocation where intFamilyId IN
					(select intFamilyId from tblICItemLocation where intFamilyId 
					IN (' + CAST(@strFamilyId as NVARCHAR) + ')' + '))'
			  END

			  IF (@strClassId <> '')
			  BEGIN
					SET @SqlQuery1 = @SqlQuery1 +  ' and a.intItemLocationId IN 
					(select intItemLocationId from tblICItemLocation where intClassId IN
					(select intClassId from tblICItemLocation where intClassId 
					IN (' + CAST(@strClassId as NVARCHAR) + ')' + '))'
			  END

			SET @SqlQuery1 = @SqlQuery1 + ' and  a.strPromotionType = ''Vendor Discount''' 

			INSERT @tblMassUpdatePreview
			EXEC (@SqlQuery1)
		 END

		 IF (@dblDiscThroughQty <> 0)
		 BEGIN
	    
			 SET @SqlQuery1 = 'SELECT' + CHAR(13)
									+ ' e.strLocationName' + CHAR(13)
									+ ', b.strUpcCode' + CHAR(13)
									+ ', c.strDescription' + CHAR(13)
									+ ', ''Discoount through quantity''' + CHAR(13)
									+ ', CAST(a.dblDiscountThruQty AS DECIMAL(18, ' + @CompanyCurrencyDecimal + '))' + CHAR(13)
								    + ', CAST(' + CAST(@dblDiscThroughQty AS NVARCHAR(250)) + ' AS DECIMAL(18, ' + @CompanyCurrencyDecimal + '))' + CHAR(13)
									--+ ', CAST(a.dblDiscountThruQty as NVARCHAR(250))' + CHAR(13)
									--+ ', ''' + CAST(@dblDiscThroughQty as NVARCHAR(250)) + '''' + CHAR(13)
			                + ' FROM tblICItemSpecialPricing a' + CHAR(13)
			                + ' JOIN tblICItemUOM b ON a.intItemUnitMeasureId = b.intItemUOMId' + CHAR(13)
			                + ' JOIN tblICItem c ON a.intItemId = c.intItemId' + CHAR(13)
			                + ' JOIN tblICItemLocation d ON a.intItemId = d.intItemId' + CHAR(13)
			                + ' JOIN tblSMCompanyLocation e ON d.intLocationId = e.intCompanyLocationId '

			SET @SqlQuery1 = @SqlQuery1 + ' WHERE 1=1 ' 

			  IF (@strCompanyLocationId <> '')
			  BEGIN 
					SET @SqlQuery1 = @SqlQuery1 + ' and d.intLocationId IN (' + CAST(@strCompanyLocationId as NVARCHAR) + ')'
			  END				    	

			  IF (@strVendorId <> '')
			  BEGIN 
					SET @SqlQuery1 = @SqlQuery1 +  ' and  a.intItemLocationId
					IN (select intItemLocationId from tblICItemLocation where intVendorId
					IN (select intEntityId from tblEMEntity where intEntityId 
					IN (' + CAST(@strVendorId as NVARCHAR) + ')' + '))'
			  END

			  IF (@strCategoryId <> '')
			  BEGIN
					SET @SqlQuery1 = @SqlQuery1 +  ' and a.intItemId  
					IN (select intItemId from tblICItem where intCategoryId IN
					(select intCategoryId from tblICCategory where intCategoryId
					IN (' + CAST(@strCategoryId as NVARCHAR) + ')' + '))'
			  END

			  IF (@strFamilyId <> '')
			  BEGIN
					SET @SqlQuery1 = @SqlQuery1 +  ' and a.intItemLocationId IN 
					(select intItemLocationId from tblICItemLocation where intFamilyId IN
					(select intFamilyId from tblICItemLocation where intFamilyId 
					IN (' + CAST(@strFamilyId as NVARCHAR) + ')' + '))'
			  END

			  IF (@strClassId <> '')
			  BEGIN
					SET @SqlQuery1 = @SqlQuery1 +  ' and a.intItemLocationId IN 
					(select intItemLocationId from tblICItemLocation where intClassId IN
					(select intClassId from tblICItemLocation where intClassId 
					IN (' + CAST(@strClassId as NVARCHAR) + ')' + '))'
			  END

			SET @SqlQuery1 = @SqlQuery1 + ' and  a.strPromotionType = ''Vendor Discount''' 

			INSERT @tblMassUpdatePreview
			EXEC (@SqlQuery1)
		 END
	 END

	 
	SELECT @RecCount  = count(*) from tblSTMassUpdateReportMaster 
	DELETE FROM @tblMassUpdatePreview WHERE strOldData = strNewData
	SELECT @UpdateCount = count(*) from @tblMassUpdatePreview WHERE strOldData !=  strNewData



	-----------------------------------Handle Dynamic Query 5
	--select * from tblSTMassUpdateReportMaster
	--select * from tblICItemSpecialPricing

	--Get Change Description
	DECLARE @strChangeDescription as NVARCHAR(MAX)
	SET @strChangeDescription = ''
	IF(@dtmBeginDate IS NOT NULL)
	BEGIN
		SET @strChangeDescription = @strChangeDescription + ' Sales start date'' + CHAR(13) + '''
	END
	IF(@dtmEndDate IS NOT NULL)
	BEGIN
		SET @strChangeDescription = @strChangeDescription + ' Sales end date'' + CHAR(13) + '''
	END
	
	IF (@strPromotionType = 'Vendor Rebate')
	BEGIN
		IF(@dblRebateAmount <> 0)
		BEGIN
			SET @strChangeDescription = @strChangeDescription + ' Rebate amount'' + CHAR(13) + '''
		END
		IF(@dblAccumAmount <> 0)
		BEGIN
			SET @strChangeDescription = @strChangeDescription + ' Accumulated amount'' + CHAR(13) + '''
		END
		IF(@dblAccumlatedQty <> 0)
		BEGIN
			SET @strChangeDescription = @strChangeDescription + ' Accumulated quantity'' + CHAR(13) + '''
		END
	END
	ELSE IF (@strPromotionType = 'Vendor Discount')
	BEGIN
		IF(@dblDiscAmountUnit <> 0)
		BEGIN
			SET @strChangeDescription = @strChangeDescription + ' Discount amount unit'' + CHAR(13) + '''
		END
		IF(@dblDiscThroughAmount <> 0)
		BEGIN
			SET @strChangeDescription = @strChangeDescription + ' Discount through amount'' + CHAR(13) + '''
		END
		IF(@dblDiscThroughQty <> 0)
		BEGIN
			SET @strChangeDescription = @strChangeDescription + ' Discount through quantity'' + CHAR(13) + '''
		END
	END


	--+ ', CAST(a.dblDiscountThruQty AS DECIMAL(18, ' + @CompanyCurrencyDecimal + '))' + CHAR(13)
	--							    + ', CAST(' + CAST(@dblDiscThroughQty AS NVARCHAR(250)) + ' AS DECIMAL(18, ' + @CompanyCurrencyDecimal + '))' + CHAR(13)

	--Get Old Data
	DECLARE @strOldData as NVARCHAR(MAX)
	SET @strOldData = ''
	IF(@dtmBeginDate IS NOT NULL)
	BEGIN
		SET @strOldData = @strOldData + ' IP.dtmBeginDate, CHAR(13),'
	END
	IF(@dtmEndDate IS NOT NULL)
	BEGIN
		SET @strOldData = @strOldData + ' IP.dtmEndDate, CHAR(13),'
	END
	IF (@strPromotionType = 'Vendor Rebate')
	BEGIN
		IF(@dblRebateAmount <> 0)
		BEGIN
			--SET @strOldData = @strOldData + ' IP.dblDiscount, CHAR(13),'
			SET @strOldData = @strOldData + ' CAST(IP.dblDiscount AS DECIMAL(18, ' + @CompanyCurrencyDecimal + ')), CHAR(13),'
		END
		IF(@dblAccumAmount <> 0)
		BEGIN
			--SET @strOldData = @strOldData + ' IP.dblAccumulatedAmount, CHAR(13),'
			SET @strOldData = @strOldData + ' CAST(IP.dblAccumulatedAmount AS DECIMAL(18, ' + @CompanyCurrencyDecimal + ')), CHAR(13),'
		END
		IF(@dblAccumlatedQty <> 0)
		BEGIN
			--SET @strOldData = @strOldData + ' IP.dblAccumulatedQty, CHAR(13),'
			SET @strOldData = @strOldData + ' CAST(IP.dblAccumulatedQty AS DECIMAL(18, ' + @CompanyCurrencyDecimal + ')), CHAR(13),'
		END
	END
	ELSE IF (@strPromotionType = 'Vendor Discount')
	BEGIN
		IF(@dblDiscAmountUnit <> 0)
		BEGIN
			--SET @strOldData = @strOldData + ' IP.dblDiscount, CHAR(13),'
			SET @strOldData = @strOldData + ' CAST(IP.dblDiscount AS DECIMAL(18, ' + @CompanyCurrencyDecimal + ')), CHAR(13),'
		END
		IF(@dblDiscThroughAmount <> 0)
		BEGIN
			--SET @strOldData = @strOldData + ' IP.dblDiscountThruAmount, CHAR(13),'
			SET @strOldData = @strOldData + ' CAST(IP.dblDiscountThruAmount AS DECIMAL(18, ' + @CompanyCurrencyDecimal + ')), CHAR(13),'
		END
		IF(@dblDiscThroughQty <> 0)
		BEGIN
			--SET @strOldData = @strOldData + ' IP.dblDiscountThruQty, CHAR(13),'
			SET @strOldData = @strOldData + ' CAST(IP.dblDiscountThruQty AS DECIMAL(18, ' + @CompanyCurrencyDecimal + ')), CHAR(13),'
		END
	END
	SET @strOldData = SUBSTRING(@strOldData, 0, LEN(@strOldData))




	--Get New Data
	DECLARE @strNewData as NVARCHAR(MAX)
	SET @strNewData = ''
	IF(@dtmBeginDate IS NOT NULL)
	BEGIN
		SET @strNewData = @strNewData + ' ' + CAST(@dtmBeginDate as NVARCHAR) + ''' + CHAR(13) + '''
	END
	IF(@dtmEndDate IS NOT NULL)
	BEGIN
		SET @strNewData = @strNewData + ' ' + CAST(@dtmEndDate as NVARCHAR) + ''' + CHAR(13) + '''
	END
	
	IF (@strPromotionType = 'Vendor Rebate')
	BEGIN
		IF(@dblRebateAmount <> 0)
		BEGIN
			SET @strNewData = @strNewData + ' ' + CAST(@dblRebateAmount as NVARCHAR) + ''' + CHAR(13) + '''
		END
		IF(@dblAccumAmount <> 0)
		BEGIN
			SET @strNewData = @strNewData + ' ' + CAST(@dblAccumAmount as NVARCHAR) + ''' + CHAR(13) + '''
		END
		IF(@dblAccumlatedQty <> 0)
		BEGIN
			SET @strNewData = @strNewData + ' ' + CAST(@dblAccumlatedQty as NVARCHAR) + ''' + CHAR(13) + '''
		END
	END
	ELSE IF (@strPromotionType = 'Vendor Discount')
	BEGIN
		IF(@dblDiscAmountUnit <> 0)
		BEGIN
			SET @strNewData = @strNewData + ' ' + CAST(@dblDiscAmountUnit as NVARCHAR) + ''' + CHAR(13) + '''
		END
		IF(@dblDiscThroughAmount <> 0)
		BEGIN
			SET @strNewData = @strNewData + ' ' + CAST(@dblDiscThroughAmount as NVARCHAR) + ''' + CHAR(13) + '''
		END
		IF(@dblDiscThroughQty <> 0)
		BEGIN
			SET @strNewData = @strNewData + ' ' + CAST(@dblDiscThroughQty as NVARCHAR) + ''' + CHAR(13) + '''
		END
	END

	IF((@ysnPreview != 'Y') AND(@UpdateCount > 0))
	BEGIN
		IF (@strPromotionType = 'Vendor Rebate')
		BEGIN
				SET @SqlQuery1 = '--QUERY1' + CHAR(13)
								+ ' SELECT' + CHAR(13)
										+ ' CL.strLocationName as strLocation' + CHAR(13)
										+ ', UOM.strUpcCode as strUpc' + CHAR(13)
										+ ', I.strDescription as strItemDescription' + CHAR(13)
										+ ', ''' + CAST(@strChangeDescription as NVARCHAR(MAX)) + ''' as strChangeDescription' + CHAR(13)
										+ ', CONCAT(' + CAST(@strOldData as NVARCHAR(MAX)) + ') as strOldData' + CHAR(13)
										+ ', ''' + CAST(@strNewData as NVARCHAR(MAX)) + ''' as strNewData' + CHAR(13)
								+ ' FROM tblICItemSpecialPricing IP' + CHAR(13)
								+ ' JOIN dbo.tblICItemLocation IL ON IL.intItemLocationId = IP.intItemLocationId' + CHAR(13)
								+ ' JOIN dbo.tblSMCompanyLocation CL ON CL.intCompanyLocationId = IL.intLocationId' + CHAR(13)
								+ ' JOIN dbo.tblICItem I ON I.intItemId = IP.intItemId' + CHAR(13)
								+ ' JOIN dbo.tblICItemUOM UOM ON UOM.intItemId = IP.intItemId' + CHAR(13)

		END

		ELSE IF (@strPromotionType = 'Vendor Discount')
		BEGIN
				SET @SqlQuery1 = '--QUERY2' + CHAR(13)
								+ ' SELECT' + CHAR(13)
										+ ' CL.strLocationName as strLocation' + CHAR(13)
										+ ', UOM.strUpcCode as strUpc' + CHAR(13)
										+ ', I.strDescription as strItemDescription' + CHAR(13)
										+ ', ''' + CAST(@strChangeDescription as NVARCHAR(MAX)) + ''' as strChangeDescription' + CHAR(13)
										+ ', CONCAT(' + CAST(@strOldData as NVARCHAR(MAX)) + ') as strOldData' + CHAR(13)
										+ ', ''' + CAST(@strNewData as NVARCHAR(MAX)) + ''' as strNewData' + CHAR(13)
								+ ' FROM tblICItemSpecialPricing IP' + CHAR(13)
								+ ' JOIN dbo.tblICItemLocation IL ON IL.intItemLocationId = IP.intItemLocationId' + CHAR(13)
								+ ' JOIN dbo.tblSMCompanyLocation CL ON CL.intCompanyLocationId = IL.intLocationId' + CHAR(13)
								+ ' JOIN dbo.tblICItem I ON I.intItemId = IP.intItemId' + CHAR(13)
								+ ' JOIN dbo.tblICItemUOM UOM ON UOM.intItemId = IP.intItemId' + CHAR(13)

		END

		SET @SqlQuery1 = @SqlQuery1 + ' WHERE 1=1 ' 

		IF (@strCompanyLocationId <> '')
		    BEGIN 
		         SET @SqlQuery1 = @SqlQuery1 +  ' and  tblICItemSpecialPricing.intItemLocationId
		         IN (select intItemLocationId from tblICItemLocation where intLocationId
		         IN (select intLocationId from tblICItemLocation where intLocationId
		   	     IN (' + CAST(@strCompanyLocationId as NVARCHAR) + ')' + '))'
		     END

	     IF (@strVendorId <> '')
		     BEGIN 
		           SET @SqlQuery1 = @SqlQuery1 +  ' and  tblICItemSpecialPricing.intItemLocationId
		           IN (select intItemLocationId from tblICItemLocation where intVendorId
		           IN (select intEntityId from tblEMEntity where intEntityId 
			       IN (' + CAST(@strVendorId as NVARCHAR) + ')' + '))'
		     END

	     IF (@strCategoryId <> '')
		      BEGIN
     	             SET @SqlQuery1 = @SqlQuery1 +  ' and tblICItemSpecialPricing.intItemId  
		              IN (select intItemId from tblICItem where intCategoryId IN
			          (select intCategoryId from tblICCategory where intCategoryId
			          IN (' + CAST(@strCategoryId as NVARCHAR) + ')' + '))'
		       END

		 IF (@strFamilyId <> '')
		     BEGIN
  			        SET @SqlQuery1 = @SqlQuery1 +  ' and tblICItemSpecialPricing.intItemLocationId IN 
			        (select intItemLocationId from tblICItemLocation where intFamilyId IN
			        (select intFamilyId from tblICItemLocation where intFamilyId 
			        IN (' + CAST(@strFamilyId as NVARCHAR) + ')' + '))'
		      END

		 IF (@strClassId <> '')
		     BEGIN
		           SET @SqlQuery1 = @SqlQuery1 +  ' and tblICItemSpecialPricing.intItemLocationId IN 
		           (select intItemLocationId from tblICItemLocation where intClassId IN
		 	       (select intClassId from tblICItemLocation where intClassId 
			       IN (' + CAST(@strClassId as NVARCHAR) + ')' + '))'
		     END

         IF (@strPromotionType = 'Vendor Rebate')
		     BEGIN
                 SET @SqlQuery1 = @SqlQuery1 + ' and  strPromotionType = ''Rebate''' 
			 END
              
         IF (@strPromotionType = 'Vendor Discount')
		     BEGIN
                 SET @SqlQuery1 = @SqlQuery1 + ' and  strPromotionType = ''Vendor Discount''' 
			 END

		 
		INSERT @tblMassUpdatePreview
		EXEC (@SqlQuery1)
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



   select @strCompanyName as CompanyName
		  , FORMAT(GETDATE(), 'D', 'en-US' ) as DateToday
		  , RIGHT('0' + LTRIM(STUFF(RIGHT(CONVERT(CHAR(26), CURRENT_TIMESTAMP, 109), 14),9, 4, ' ')),11) as TimeToday
		  , strLocation
		  , strUpc
		  , strItemDescription
		  , strChangeDescription
		  , strOldData
		  , strNewData
   from @tblMassUpdatePreview
    
   DELETE FROM @tblMassUpdatePreview
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
END CATCH