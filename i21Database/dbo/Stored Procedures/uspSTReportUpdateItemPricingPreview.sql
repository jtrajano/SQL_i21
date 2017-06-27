CREATE PROCEDURE [dbo].[uspSTReportUpdateItemPricingPreview]
	@xmlParam NVARCHAR(MAX) = NULL  
	
AS

BEGIN TRY
	
	--Insert
	INSERT INTO TestDatabase.dbo.tblPerson (strFirstName)
	VALUES (@xmlParam)

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
	, @dblStandardCost DECIMAL
	, @dblRetailPrice DECIMAL
	, @dblSalesPrice DECIMAL
	, @dtmSalesStartingDate DATE
	, @dtmSalesEndingDate DATE
	, @ysnPreview NVARCHAR(1)

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
	--END Handle xml Param

   --Declare UpdatePreview holder
   DECLARE @tblMassUpdatePreview TABLE 
   (
		strLocation NVARCHAR(250)
		, strUpc NVARCHAR(50)
		, strItemDescription NVARCHAR(250)
		, strChangeDescription NVARCHAR(100)
		, dblOldData decimal(18,6)
		, dblNewData decimal(18,6)
   )


	--INSERT INTO @tblMassUpdatePreview
	--SELECT
	--     CL.strLocationName as strLocation
	--	 , UOM.strUpcCode as strUpc
	--	 , I.strDescription as strItemDescription
	--	 , 'Standard Cost' as strChangeDescription
	--	 , dblStandardCost as dblOldData
	--	 , @dblCost as dblNewData
	--	--, IP.*
	--FROM tblICItemPricing IP
	--JOIN dbo.tblICItemLocation IL ON IL.intItemLocationId = IP.intItemLocationId
	--JOIN dbo.tblSMCompanyLocation CL ON CL.intCompanyLocationId = IL.intLocationId
	--JOIN dbo.tblICItem I ON I.intItemId = IP.intItemId
	--JOIN dbo.tblICItemUOM UOM ON UOM.intItemId = IP.intItemId
	--where IP.intItemLocationId
	--IN (select intItemLocationId from tblICItemLocation where intLocationId
	--IN 
	--(
	--	select intLocationId from tblICItemLocation where intLocationId 
	--	IN 
	--		(
	--			SELECT CAST(Item AS INTEGER)
	--			FROM dbo.fnSplitString(@strCompanyLocationId, ',')
	--		)
	--	)
	--) 
	--and IP.intItemId  
	--IN (select intItemId from tblICItemUOM where intItemUOMId 
	--IN (select intItemUOMId from tblICItemUOM  where intItemUOMId = @intUpcCode))
	
	DECLARE @SqlQuery1 as NVARCHAR(MAX)
	-----------------------------------Handle Dynamic Query 1
	IF (@dblStandardCost <> 0)
		BEGIN
   
			SET @SqlQuery1 = 'SELECT' + CHAR(13)
			                 + ' e.strLocationName' + CHAR(13)
							 + ' ,b.strUpcCode' + CHAR(13)
							 + ' ,c.strDescription' + CHAR(13)
							 + ' ,''Standard Cost''' + CHAR(13)
							 + ' ,CAST(a.dblStandardCost as NVARCHAR(250))' + CHAR(13)
							 + ' ,''' + CAST(@dblStandardCost as NVARCHAR(250)) + '''' + CHAR(13)
							 + ' FROM tblICItemPricing a' + CHAR(13)
							 + ' JOIN tblICItemUOM b ON a.intItemId = b.intItemId' + CHAR(13)
							 + ' JOIN tblICItem c ON a.intItemId = c.intItemId' + CHAR(13)
							 + ' JOIN tblICItemLocation d ON a.intItemId = d.intItemId' + CHAR(13)
							 + ' JOIN tblSMCompanyLocation e ON d.intLocationId = e.intCompanyLocationId '

			SET @SqlQuery1 = @SqlQuery1 + ' WHERE 1=1 ' 

			IF (@strCompanyLocationId <> '')
				BEGIN 
				   SET @SqlQuery1 = @SqlQuery1 + ' AND d.intLocationId IN (' + CAST(@strCompanyLocationId as NVARCHAR) + ')' + CHAR(13)
				END

			IF (@strVendorId <> '')
				BEGIN 
					 set @SqlQuery1 = @SqlQuery1 +  ' and  a.intItemLocationId
					 IN (select intItemLocationId from tblICItemLocation where intVendorId
					 IN (select intEntityId from tblEMEntity where intEntityId 
   					 IN (' + CAST(@strVendorId as NVARCHAR) + ')' + '))'  + CHAR(13)
				END

			 IF (@strCategoryId <> '')
				 BEGIN
						 set @SqlQuery1 = @SqlQuery1 +  ' and a.intItemId  
					 IN (select intItemId from tblICItem where intCategoryId IN
					 (select intCategoryId from tblICCategory where intCategoryId 
					 IN (' + CAST(@strCategoryId as NVARCHAR) + ')' + '))' + CHAR(13)
				 END

			  IF (@strFamilyId <> '')
				  BEGIN
					   set @SqlQuery1 = @SqlQuery1 +  ' and a.intItemLocationId IN 
					   (select intItemLocationId from tblICItemLocation where intFamilyId IN
					   (select intFamilyId from tblICItemLocation where intFamilyId 
						IN (' + CAST(@strFamilyId as NVARCHAR) + ')' + '))' + CHAR(13)
				   END

			   IF (@strClassId  <> '')
				  BEGIN
					  set @SqlQuery1 = @SqlQuery1 +  ' and a.intItemLocationId IN 
					  (select intItemLocationId from tblICItemLocation where intClassId IN
					  (select intClassId from tblICItemLocation where intClassId 
					  IN (' + CAST(@strClassId as NVARCHAR) + ')' + '))' + CHAR(13)
				  END

			  IF (@intUpcCode <> 0)
				   BEGIN
					   set @SqlQuery1 = @SqlQuery1 +  ' and b.intItemUOMId IN (' + CAST(@intUpcCode as NVARCHAR) + ')' + CHAR(13)
				   END


			 IF (@strRegion != '')
				 BEGIN
					 set @SqlQuery1 = @SqlQuery1 +  ' and a.intItemLocationId IN 
					 (select intItemLocationId from tblICItemLocation where intLocationId IN 
					 (select intCompanyLocationId from tblSTStore where strRegion 
					 IN ( ''' + (@strRegion) + ''')' + '))' + CHAR(13)
				  END

			  IF (@strDistrict != '')
				  BEGIN
					 set @SqlQuery1 = @SqlQuery1 +  ' and a.intItemLocationId IN 
					 (select intItemLocationId from tblICItemLocation where intLocationId IN 
					 (select intCompanyLocationId from tblSTStore where strDistrict 
					 IN ( ''' + (@strDistrict) + ''')' + '))' + CHAR(13)
				  END

			IF (@strState != '')
			  BEGIN
				 set @SqlQuery1 = @SqlQuery1 +  ' and a.intItemLocationId IN 
				 (select intItemLocationId from tblICItemLocation where intLocationId IN 
				 (select intCompanyLocationId from tblSTStore where strState 
				 IN ( ''' + (@strState) + ''')' + '))' + CHAR(13)
			  END

			 IF (@strDescription != '')
			BEGIN
			   set @SqlQuery1 = @SqlQuery1 +  ' and a.intItemId IN 
			   (select intItemId from tblICItem where strDescription 
				like ''%' + LTRIM(@strDescription) + '%'' )' + CHAR(13)
			END

		INSERT @tblMassUpdatePreview
		EXEC (@SqlQuery1)
	END 


	-----------------------------------Handle Dynamic Query 2
	IF (@dblRetailPrice <> 0)
		BEGIN

			SET @SqlQuery1 = 'SELECT' + CHAR(13)
							+ ' e.strLocationName' + CHAR(13)
							+ ' ,b.strUpcCode' + CHAR(13)
							+ ' ,c.strDescription' + CHAR(13)
							+ ' ,''Retail Price''' + CHAR(13)
							+ ' ,CAST(a.dblSalePrice as NVARCHAR(250))' + CHAR(13)
							+ ' ,''' + CAST(@dblRetailPrice as NVARCHAR(250)) + '''' + CHAR(13)
							+ ' from tblICItemPricing a' + CHAR(13)
							+ ' JOIN tblICItemUOM b ON a.intItemId = b.intItemId' + CHAR(13)
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
				 set @SqlQuery1 = @SqlQuery1 +  ' and  a.intItemLocationId
				 IN (select intItemLocationId from tblICItemLocation where intVendorId
				 IN (select intEntityId from tblEMEntity where intEntityId 
   				 IN (' + CAST(@strVendorId as NVARCHAR) + ')' + '))'
			END

		 IF (@strCategoryId <> '')
			 BEGIN
				 set @SqlQuery1 = @SqlQuery1 +  ' and a.intItemId  
				 IN (select intItemId from tblICItem where intCategoryId IN
				 (select intCategoryId from tblICCategory where intCategoryId 
				 IN (' + CAST(@strCategoryId as NVARCHAR) + ')' + '))'
			 END

		  IF (@strFamilyId <> '')
			  BEGIN
				   set @SqlQuery1 = @SqlQuery1 +  ' and a.intItemLocationId IN 
				   (select intItemLocationId from tblICItemLocation where intFamilyId IN
				   (select intFamilyId from tblICItemLocation where intFamilyId 
					IN (' + CAST(@strFamilyId as NVARCHAR) + ')' + '))'
			   END

		  IF (@strClassId <> '')
			  BEGIN
				  set @SqlQuery1 = @SqlQuery1 +  ' and a.intItemLocationId IN 
				  (select intItemLocationId from tblICItemLocation where intClassId IN
				  (select intClassId from tblICItemLocation where intClassId 
				  IN (' + CAST(@strClassId as NVARCHAR) + ')' + '))'
			  END

		  IF (@intUpcCode <> 0)
			   BEGIN
				   set @SqlQuery1 = @SqlQuery1 +  ' and b.intItemUOMId IN (' + CAST(@intUpcCode as NVARCHAR) + ')'
			   END

		 IF (@strRegion != '')
			 BEGIN
				 set @SqlQuery1 = @SqlQuery1 +  ' and a.intItemLocationId IN 
				 (select intItemLocationId from tblICItemLocation where intLocationId IN 
				 (select intCompanyLocationId from tblSTStore where strRegion 
				 IN ( ''' + (@strRegion) + ''')' + '))'
			  END

		 IF (@strDistrict != '')
			  BEGIN
				 set @SqlQuery1 = @SqlQuery1 +  ' and a.intItemLocationId IN 
				 (select intItemLocationId from tblICItemLocation where intLocationId IN 
				 (select intCompanyLocationId from tblSTStore where strDistrict 
				 IN ( ''' + (@strDistrict) + ''')' + '))'
			  END

         IF (@strState != '')
			  BEGIN
				 set @SqlQuery1 = @SqlQuery1 +  ' and a.intItemLocationId IN 
				 (select intItemLocationId from tblICItemLocation where intLocationId IN 
				 (select intCompanyLocationId from tblSTStore where strState 
				 IN ( ''' + (@strState) + ''')' + '))'
			  END

         IF (@strDescription != '')
			BEGIN
			   set @SqlQuery1 = @SqlQuery1 +  ' and a.intItemId IN 
			   (select intItemId from tblICItem where strDescription 
				like ''%' + LTRIM(@strDescription) + '%'' )'
			END

		INSERT @tblMassUpdatePreview
		EXEC (@SqlQuery1)
 END 


    -----------------------------------Handle Dynamic Query 3
	IF (@dblSalesPrice <> 0)
		BEGIN

			SET @SqlQuery1 = 'SELECT' + CHAR(13)
							+ 'e.strLocationName' + CHAR(13)
							+ ', b.strUpcCode' + CHAR(13)
							+ ', c.strDescription' + CHAR(13)
							+ ', ''Sales Price''' + CHAR(13)
							+ ', CAST(a.dblUnitAfterDiscount as NVARCHAR(250))' + CHAR(13)
							+ ', ''' + CAST(@dblSalesPrice as NVARCHAR(250)) + '''' + CHAR(13)
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
					 set @SqlQuery1 = @SqlQuery1 +  ' and  a.intItemLocationId
					 IN (select intItemLocationId from tblICItemLocation where intVendorId
					 IN (select intEntityId from tblEMEntity where intEntityId 
					 IN (' + CAST(@strVendorId as NVARCHAR) + ')' + '))'
			   END

			IF (@strCategoryId <> '')
				BEGIN
						   set @SqlQuery1 = @SqlQuery1 +  ' and a.intItemId  
						  IN (select intItemId from tblICItem where intCategoryId IN
						  (select intCategoryId from tblICCategory where intCategoryId
						   IN (' + CAST(@strCategoryId as NVARCHAR) + ')' + '))'
				END

			IF (@strFamilyId <> '')
				 BEGIN
					  set @SqlQuery1 = @SqlQuery1 +  ' and a.intItemLocationId IN 
					  (select intItemLocationId from tblICItemLocation where intFamilyId IN
					  (select intFamilyId from tblICItemLocation where intFamilyId 
					  IN (' + CAST(@strFamilyId as NVARCHAR) + ')' + '))'
				 END

			IF (@strClassId <> '')
				  BEGIN
					  set @SqlQuery1 = @SqlQuery1 +  ' and a.intItemLocationId IN 
					  (select intItemLocationId from tblICItemLocation where intClassId IN
					  (select intClassId from tblICItemLocation where intClassId 
					  IN (' + CAST(@strClassId as NVARCHAR) + ')' + '))'
				   END

			IF (@intUpcCode <> 0)
				   BEGIN
					   set @SqlQuery1 = @SqlQuery1 +  ' and a.intItemUnitMeasureId IN (' + CAST(@intUpcCode as NVARCHAR) + ')'
				   END

			IF (@strRegion != '')
					BEGIN
					 set @SqlQuery1 = @SqlQuery1 +  ' and a.intItemLocationId IN 
					 (select intItemLocationId from tblICItemLocation where intLocationId IN 
					 (select intCompanyLocationId from tblSTStore where strRegion 
					 IN ( ''' + (@strRegion) + ''')' + '))'
					END

			IF (@strDistrict != '')
					BEGIN
					 set @SqlQuery1 = @SqlQuery1 +  ' and a.intItemLocationId IN 
					 (select intItemLocationId from tblICItemLocation where intLocationId IN 
					 (select intCompanyLocationId from tblSTStore where strDistrict 
					 IN ( ''' + (@strDistrict) + ''')' + '))'
					END

			IF (@strState != '')
				BEGIN
					 set @SqlQuery1 = @SqlQuery1 +  ' and a.intItemLocationId IN 
					 (select intItemLocationId from tblICItemLocation where intLocationId IN 
					 (select intCompanyLocationId from tblSTStore where strState 
					 IN ( ''' + (@strState) + ''')' + '))'
				END

      IF (@strDescription != '')
		BEGIN
		   set @SqlQuery1 = @SqlQuery1 +  ' and a.intItemId IN 
		   (select intItemId from tblICItem where strDescription 
		    like ''%' + LTRIM(@strDescription) + '%'' )'
		END

		set @SqlQuery1 = @SqlQuery1 + ' and  a.strPromotionType = ''Discount''' 

		INSERT @tblMassUpdatePreview
		EXEC (@SqlQuery1)
 END 


	-----------------------------------Handle Dynamic Query 4
	 IF (@dtmSalesStartingDate IS NOT NULL)
	 BEGIN

		SET @dtmSalesStartingDate = CONVERT(VARCHAR(10),@dtmSalesStartingDate,111)
		  SET @SqlQuery1 = 'SELECT' + CHAR(13)
							 + ' e.strLocationName' + CHAR(13)
							 + ', b.strUpcCode' + CHAR(13)
							 + ', c.strDescription' + CHAR(13)
							 + ', ''Sales start date''' + CHAR(13)
							 + ', REPLACE(CONVERT(NVARCHAR(10),a.dtmBeginDate,111), ''/'', ''-'')' + CHAR(13)
							 + ', ''' + CAST(@dtmSalesStartingDate as NVARCHAR(250)) + '''' + CHAR(13)
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

		IF (@intUpcCode <> 0)
			  BEGIN
				  SET @SqlQuery1 = @SqlQuery1 +  ' and a.intItemUnitMeasureId IN (' + CAST(@intUpcCode as NVARCHAR) + ')'
			  END

		IF (@strRegion != '')
			  BEGIN
				 SET @SqlQuery1 = @SqlQuery1 +  ' and a.intItemLocationId IN 
				 (select intItemLocationId from tblICItemLocation where intLocationId IN 
				 (select intCompanyLocationId from tblSTStore where strRegion 
				 IN ( ''' + (@strRegion) + ''')' + '))'
			  END

		IF (@strDistrict != '')
			  BEGIN
				 SET @SqlQuery1 = @SqlQuery1 +  ' and a.intItemLocationId IN 
				 (select intItemLocationId from tblICItemLocation where intLocationId IN 
				 (select intCompanyLocationId from tblSTStore where strDistrict 
				 IN ( ''' + (@strDistrict) + ''')' + '))'
			  END

		IF (@strState != '')
			  BEGIN
				 SET @SqlQuery1 = @SqlQuery1 +  ' and a.intItemLocationId IN 
				 (select intItemLocationId from tblICItemLocation where intLocationId IN 
				 (select intCompanyLocationId from tblSTStore where strState 
				 IN ( ''' + (@strState) + ''')' + '))'
			  END

		IF (@strDescription != '')
			  BEGIN
			   set @SqlQuery1 = @SqlQuery1 +  ' and a.intItemId IN 
			   (select intItemId from tblICItem where strDescription 
				like ''%' + LTRIM(@strDescription) + '%'' )'
			  END

			set @SqlQuery1 = @SqlQuery1 + ' and  a.strPromotionType = ''Discount''' 

			INSERT @tblMassUpdatePreview
			EXEC (@SqlQuery1)
	 END 


	 -----------------------------------Handle Dynamic Query 5
	 IF (@dtmSalesEndingDate IS NOT NULL)
	 BEGIN
 
		  SET @dtmSalesEndingDate = CONVERT(VARCHAR(10),@dtmSalesEndingDate,111)
		  SET @SqlQuery1 = 'SELECT' + CHAR(13)
							 + ' e.strLocationName' + CHAR(13)
							 + ', b.strUpcCode' + CHAR(13)
							 + ', c.strDescription' + CHAR(13)
							 + ', ''Sales end date''' + CHAR(13)
							 + ', REPLACE(CONVERT(NVARCHAR(10),a.dtmEndDate,111), ''/'', ''-'')' + CHAR(13)
							 + ', ''' + CAST(@dtmSalesEndingDate as NVARCHAR(250)) + '''' + CHAR(13)
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
				  set @SqlQuery1 = @SqlQuery1 +  ' and a.intItemLocationId IN 
				  (select intItemLocationId from tblICItemLocation where intClassId IN
				  (select intClassId from tblICItemLocation where intClassId 
				  IN (' + CAST(@strClassId as NVARCHAR) + ')' + '))'
			  END

		IF (@intUpcCode <> 0)
			  BEGIN
				   set @SqlQuery1 = @SqlQuery1 +  ' and a.intItemUnitMeasureId IN (' + CAST(@intUpcCode as NVARCHAR) + ')'
			  END

		IF (@strRegion != '')
				BEGIN
					 SET @SqlQuery1 = @SqlQuery1 +  ' and a.intItemLocationId IN 
					 (select intItemLocationId from tblICItemLocation where intLocationId IN 
					 (select intCompanyLocationId from tblSTStore where strRegion 
					 IN ( ''' + (@strRegion) + ''')' + '))'
				END

		IF (@strDistrict != '')
				BEGIN
					 SET @SqlQuery1 = @SqlQuery1 +  ' and a.intItemLocationId IN 
					 (select intItemLocationId from tblICItemLocation where intLocationId IN 
					 (select intCompanyLocationId from tblSTStore where strDistrict 
					 IN ( ''' + (@strDistrict) + ''')' + '))'
				END

		IF (@strState != '')
				BEGIN
					 SET @SqlQuery1 = @SqlQuery1 +  ' and a.intItemLocationId IN 
					 (select intItemLocationId from tblICItemLocation where intLocationId IN 
					 (select intCompanyLocationId from tblSTStore where strState 
					 IN ( ''' + (@strState) + ''')' + '))'
				END

		IF (@strDescription != '')
			BEGIN
			   SET @SqlQuery1 = @SqlQuery1 +  ' and a.intItemId IN 
			   (select intItemId from tblICItem where strDescription 
				like ''%' + LTRIM(@strDescription) + '%'' )'
			END

			set @SqlQuery1 = @SqlQuery1 + ' and  a.strPromotionType = ''Discount''' 

			INSERT @tblMassUpdatePreview
			EXEC (@SqlQuery1)
	END 



	-------------------------------------Handle Dynamic Query 21
	--IF ((@dblStandardCost <> 0) OR (@dblRetailPrice <> 0))
 --   BEGIN
	--	SET @SqlQuery1 = '--QUERY1' + CHAR(13)
	--	            + ' SELECT' + CHAR(13)
	--						+ '	 CL.strLocationName as strLocation' + CHAR(13)
	--						+ '	 , UOM.strUpcCode as strUpc' + CHAR(13)
	--						+ '	 , I.strDescription as strItemDescription' + CHAR(13)
	--						+ '	 , ''Standard Cost'' as strChangeDescription' + CHAR(13)
	--						+ '	 , dblStandardCost as dblOldData' + CHAR(13)
	--						+ '	 , ' + CAST(@dblStandardCost as NVARCHAR) + ' as dblNewData' + CHAR(13)
	--				+ ' FROM tblICItemPricing IP' + CHAR(13)
	--				+ ' JOIN dbo.tblICItemLocation IL ON IL.intItemLocationId = IP.intItemLocationId' + CHAR(13)
	--				+ ' JOIN dbo.tblSMCompanyLocation CL ON CL.intCompanyLocationId = IL.intLocationId' + CHAR(13)
	--				+ ' JOIN dbo.tblICItem I ON I.intItemId = IP.intItemId' + CHAR(13)
	--				+ ' JOIN dbo.tblICItemUOM UOM ON UOM.intItemId = IP.intItemId' + CHAR(13)

	--	SET @SqlQuery1 = @SqlQuery1 + ' where 1=1 ' + CHAR(13)
	 
	--	IF (@strCompanyLocationId <> '')
	--		BEGIN 
	--			 set @SqlQuery1 = @SqlQuery1 +  ' and IP.intItemLocationId
	--			 IN (select intItemLocationId from tblICItemLocation where intLocationId
	--			 IN (select intLocationId from tblICItemLocation where intLocationId 
	--			 IN (' + CAST(@strCompanyLocationId as NVARCHAR) + ')' + '))' + CHAR(13)
	--		END
	--	IF (@strVendorId <> '')
	--		BEGIN 
	--			 SET @SqlQuery1 = @SqlQuery1 +  ' and IP.intItemLocationId
	--			 IN (select intItemLocationId from tblICItemLocation where intVendorId
	--			 IN (select intEntityId from tblEMEntity where intEntityId 
	--			 IN (' + CAST(@strVendorId as NVARCHAR) + ')' + '))' + CHAR(13)
	--		END
	--	IF (@strCategoryId <> '')
	--		BEGIN
	--			 SET @SqlQuery1 = @SqlQuery1 +  ' and IP.intItemId
	--			 IN (select intItemId from tblICItem where intCategoryId IN
	--			 (select intCategoryId from tblICCategory where intCategoryId 
	--			 IN (' + CAST(@strCategoryId as NVARCHAR) + ')' + '))' + CHAR(13)
	--		END
	--	IF (@strFamilyId <> '')
	--		BEGIN
	--			 SET @SqlQuery1 = @SqlQuery1 +  ' and IP.intItemLocationId IN 
	--			 (select intItemLocationId from tblICItemLocation where intFamilyId IN
	--			 (select intFamilyId from tblICItemLocation where intFamilyId 
	--			 IN (' + CAST(@strFamilyId as NVARCHAR) + ')' + '))' + CHAR(13)
	--		END
	--	IF (@strClassId  IS NOT NULL)
	--		BEGIN
	--			 SET @SqlQuery1 = @SqlQuery1 +  ' and IP.intItemLocationId
	--			 IN (select intItemLocationId from tblICItemLocation where intClassId IN
	--			 (select intClassId from tblICItemLocation where intClassId 
	--			 IN (' + CAST(@strClassId as NVARCHAR) + ')' + '))' + CHAR(13)
	--		END
	--	IF (@intUpcCode IS NOT NULL)
	--		BEGIN
	--			 set @SqlQuery1 = @SqlQuery1 +  ' and IP.intItemId
	--			 IN (select intItemId from tblICItemUOM where  intItemUOMId IN
	--			 (select intItemUOMId from tblICItemUOM  where intItemUOMId 
	--			 IN (' + CAST(@intUpcCode as NVARCHAR) + ')' + '))' + CHAR(13)
	--		END
	--	IF (@strRegion != '')
	--		BEGIN
	--			 SET @SqlQuery1 = @SqlQuery1 +  ' and IP.intItemLocationId
	--			 IN (select intItemLocationId from tblICItemLocation where intLocationId IN 
	--			 (select intCompanyLocationId from tblSTStore where strRegion 
	--			 IN ( ''' + (@strRegion) + ''')' + '))' + CHAR(13)
	--		END
	--	IF (@strDistrict != '')
	--		BEGIN
	--			 SET @SqlQuery1 = @SqlQuery1 +  ' and IP.intItemLocationId
	--			 IN (select intItemLocationId from tblICItemLocation where intLocationId IN 
	--			 (select intCompanyLocationId from tblSTStore where strDistrict 
	--			 IN ( ''' + (@strDistrict) + ''')' + '))' + CHAR(13)
	--		END
	--	IF (@strState != '')
	--		BEGIN
	--			 SET @SqlQuery1 = @SqlQuery1 +  ' and IP.intItemLocationId
	--			 IN (select intItemLocationId from tblICItemLocation where intLocationId IN 
	--			 (select intCompanyLocationId from tblSTStore where strState 
	--			 IN ( ''' + (@strState) + ''')' + '))' + CHAR(13)
	--		END
	--	IF (@strDescription != '')
	--		BEGIN
	--			 SET @SqlQuery1 = @SqlQuery1 +  ' and IP.intItemId
	--			 IN (select intItemId from tblICItem where strDescription 
	--			 like ''%' + LTRIM(@strDescription) + '%'' )'
	--		END

	--	INSERT @tblMassUpdatePreview
	--	EXEC (@SqlQuery1)
	--END

	----Print
	----Exec XMLDB.dbo.PrintString @SqlQuery1 @
	

	--IF ((@dblSalesPrice IS NOT NULL) OR (@dtmSalesStartingDate IS NOT NULL) OR (@dtmSalesEndingDate IS NOT NULL))
	--BEGIN
	--	DECLARE @SqlQuery2 as NVARCHAR(MAX)
	--	SET @SqlQuery2 = '--QUERY2' + CHAR(13)
	--	SET @SqlQuery2 = @SqlQuery2 + @SqlQuery1 + CHAR(13)
	--	SET @SqlQuery2 = @SqlQuery2 + ' and IP.strPromotionType = ''Discount'''

	--	SET @SqlQuery2 = REPLACE(@SqlQuery2,'tblICItemPricing','tblICItemSpecialPricing')
	--	SET @SqlQuery2 = REPLACE(@SqlQuery2,'Standard Cost','Unit After Discount')
	--	SET @SqlQuery2 = REPLACE(@SqlQuery2,'dblStandardCost as dblOldData','dblUnitAfterDiscount as dblOldData')
	--	SET @SqlQuery2 = REPLACE(@SqlQuery2,'dblStandardCost as dblOldData','dblUnitAfterDiscount as dblOldData')
	--	SET @SqlQuery2 = REPLACE(@SqlQuery2, CAST(@dblStandardCost as NVARCHAR) + ' as dblNewData',CAST(@dblSalesPrice as NVARCHAR) + ' as dblNewData')

	--	INSERT @tblMassUpdatePreview
	--	EXEC (@SqlQuery2)
	--END


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
		  --, CONVERT(VARCHAR(8), GETDATE(), 108) + ' ' + RIGHT(CONVERT(VARCHAR(30), GETDATE(), 9), 2) as TimeToday
		  , RIGHT('0' + LTRIM(STUFF(RIGHT(CONVERT(CHAR(26), CURRENT_TIMESTAMP, 109), 14),9, 4, ' ')),11) as TimeToday
		  , strLocation
		  , strUpc
		  , strItemDescription
		  , strChangeDescription
		  , dblOldData
		  , dblNewData
   from @tblMassUpdatePreview
    
   DELETE FROM @tblMassUpdatePreview
END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
END CATCH