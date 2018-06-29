CREATE FUNCTION [dbo].[fnSTDynamicQueryItemPricing] 
(
	@strChangeDescription VARCHAR(250)
	, @strOldData NVARCHAR(250)
	, @strNewData NVARCHAR(250)

	, @strCompanyLocationId NVARCHAR(MAX)
	, @strVendorId NVARCHAR(MAX)
	, @strCategoryId NVARCHAR(MAX)
	, @strFamilyId NVARCHAR(MAX)
	, @strClassId NVARCHAR(MAX)

	, @intUpcCode INT
	, @strRegion NVARCHAR(250)
	, @strDistrict NVARCHAR(250)
	, @strState NVARCHAR(250)
	, @strDescription NVARCHAR(250)
	
	, @strParentId NVARCHAR(50)
	, @strChildId NVARCHAR(50)

	, @strPrimTable NVARCHAR(50)
)
RETURNS VARCHAR(MAX)
AS BEGIN
    
	DECLARE @strItemUOM NVARCHAR(100)

    DECLARE @strGeneratedSql VARCHAR(MAX)


	--Check table
	IF(@strPrimTable = 'tblICItemPricing')
	BEGIN
		SET @strItemUOM = ' JOIN tblICItemUOM UOM ON IP.intItemId = UOM.intItemId'
	END
	ELSE IF(@strPrimTable = 'tblICItemSpecialPricing')
	BEGIN
		SET @strItemUOM = ' JOIN tblICItemUOM UOM ON IP.intItemUnitMeasureId = UOM.intItemUOMId'
	END


    SET @strGeneratedSql =  ' SELECT DISTINCT' + CHAR(13)
								   + ' CL.intCompanyLocationId' + CHAR(13)
								   + '  , CL.strLocationName' + CHAR(13)
								   + '  , CASE ' + CHAR(13)
								   + '		WHEN UOM.strUpcCode IS NOT NULL OR UOM.strUpcCode != '''' THEN UOM.strUpcCode ' + CHAR(13)
								   + '		WHEN UOM.strLongUPCCode IS NOT NULL OR UOM.strLongUPCCode != '''' THEN UOM.strLongUPCCode ' + CHAR(13)
								   + '    END AS strUpcCode ' + CHAR(13)
								   + '	, I.strDescription' + CHAR(13)
								   + '	,''' + @strChangeDescription + '''' + CHAR(13)
								   + '	,' + @strOldData + '' + CHAR(13)
								   + '	,' + @strNewData + '' + CHAR(13)
								   + '	,' + @strParentId + '' + CHAR(13)
								   + '	,' + @strChildId + '' + CHAR(13)
						   + ' FROM ' + @strPrimTable + ' IP' + CHAR(13)
						   + @strItemUOM + CHAR(13)
						   + ' JOIN tblICItem I ON IP.intItemId = I.intItemId' + CHAR(13)
						   + ' JOIN tblICItemLocation IL ON IP.intItemId = IL.intItemId' + CHAR(13)
						   + '                          AND IP.intItemLocationId = IL.intItemLocationId' + CHAR(13)
						   + ' JOIN tblSMCompanyLocation CL ON IL.intLocationId = CL.intCompanyLocationId ' + CHAR(13)

		   --SET @strGeneratedSql = @strGeneratedSql + ' WHERE 1=1 AND UOM.ysnStockUnit = CAST(1 AS BIT) ' 
		   SET @strGeneratedSql = @strGeneratedSql + ' WHERE 1=1 ' 

		   IF ((@strCompanyLocationId != '') AND (@strCompanyLocationId IS NOT NULL))
		   BEGIN 
				-- SET @strGeneratedSql = @strGeneratedSql + ' and IL.intLocationId IN (' + CAST(@strCompanyLocationId as NVARCHAR(MAX)) + ')'
				SET @strGeneratedSql = @strGeneratedSql + ' and CL.intCompanyLocationId IN (' + CAST(@strCompanyLocationId as NVARCHAR(MAX)) + ')'
		   END
		 
		   IF ((@strVendorId != '') AND (@strVendorId IS NOT NULL))
		   BEGIN 
			   SET @strGeneratedSql = @strGeneratedSql + ' and  IP.intItemLocationId 
															IN (select intItemLocationId from tblICItemLocation where intVendorId 
															IN (select intEntityId from tblEMEntity where intEntityId 
   															IN (' + CAST(@strVendorId as NVARCHAR(MAX)) + ')' + '))'
		   END

		   IF ((@strCategoryId != '') AND (@strCategoryId IS NOT NULL))
		   BEGIN
				SET @strGeneratedSql = @strGeneratedSql +  ' and IP.intItemId  
															 IN (select intItemId from tblICItem where intCategoryId 
															 IN (select intCategoryId from tblICCategory where intCategoryId 
															 IN (' + CAST(@strCategoryId as NVARCHAR(MAX)) + ')' + '))'
		   END

		   IF ((@strFamilyId != '') AND (@strFamilyId IS NOT NULL))
		   BEGIN
				 SET @strGeneratedSql = @strGeneratedSql + ' and IP.intItemLocationId 
															IN (select intItemLocationId from tblICItemLocation where intFamilyId 
															IN (select intFamilyId from tblICItemLocation where intFamilyId 
															IN (' + CAST(@strFamilyId as NVARCHAR(MAX)) + ')' + '))' 
		   END

		   IF ((@strClassId != '') AND (@strClassId IS NOT NULL))
		   BEGIN
				 SET @strGeneratedSql = @strGeneratedSql + ' and IP.intItemLocationId 
															 IN (select intItemLocationId from tblICItemLocation where intClassId 
															 IN (select intClassId from tblICItemLocation where intClassId 
															 IN (' + CAST(@strClassId as NVARCHAR(MAX)) + ')' + '))'
		   END
	    
		   IF (@intUpcCode IS NOT NULL)
		   BEGIN
				--Check table
				IF(@strPrimTable = 'tblICItemPricing')
				BEGIN
					SET @strGeneratedSql = @strGeneratedSql + ' and UOM.intItemUOMId IN (' + CAST(@intUpcCode as NVARCHAR(250)) + ')'
				END
				ELSE IF(@strPrimTable = 'tblICItemSpecialPricing')
				BEGIN
					SET @strGeneratedSql = @strGeneratedSql + ' and IP.intItemUnitMeasureId IN (' + CAST(@intUpcCode as NVARCHAR(250)) + ')'
				END
		   END

		   IF ((@strRegion != '') AND (@strRegion IS NOT NULL))
		   BEGIN
			   SET @strGeneratedSql = @strGeneratedSql + ' and IP.intItemLocationId 
														   IN (select intItemLocationId from tblICItemLocation where intLocationId 
														   IN (select intCompanyLocationId from tblSTStore where strRegion 
														   IN ( ''' + (@strRegion) + ''')' + '))'
		   END

		   IF ((@strDistrict != '') AND (@strDistrict IS NOT NULL))
		   BEGIN
			   SET @strGeneratedSql = @strGeneratedSql + ' and IP.intItemLocationId 
														   IN (select intItemLocationId from tblICItemLocation where intLocationId 
														   IN (select intCompanyLocationId from tblSTStore where strDistrict 
														   IN ( ''' + (@strDistrict) + ''')' + '))'
		   END

		   IF ((@strState != '') AND (@strState IS NOT NULL))
		   BEGIN
			   SET @strGeneratedSql = @strGeneratedSql + ' and IP.intItemLocationId 
														   IN (select intItemLocationId from tblICItemLocation where intLocationId 
														   IN (select intCompanyLocationId from tblSTStore where strState 
														   IN ( ''' + (@strState) + ''')' + '))'
		   END

		   IF ((@strDescription != '') AND (@strDescription IS NOT NULL))
		   BEGIN
				SET @strGeneratedSql = @strGeneratedSql +  ' and IP.intItemId 
															IN (select intItemId from tblICItem where strDescription 
															like ''%' + LTRIM(@strDescription) + '%'' )'
		   END

		   --In some cases
		   IF(@strChangeDescription = 'Sales Price' OR @strChangeDescription = 'Sales start date' OR @strChangeDescription = 'Sales end date')
		   BEGIN
				SET @strGeneratedSql = @strGeneratedSql + ' and IP.strPromotionType = ''Discount'''
		   END

    RETURN @strGeneratedSql
END