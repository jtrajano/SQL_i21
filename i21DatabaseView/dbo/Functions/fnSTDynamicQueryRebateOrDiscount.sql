CREATE FUNCTION [dbo].[fnSTDynamicQueryRebateOrDiscount] 
(
	@strChangeDescription VARCHAR(250)
	, @strOldData NVARCHAR(250)
	, @strNewData NVARCHAR(250)

	, @strCompanyLocationId NVARCHAR(MAX)
	, @strVendorId NVARCHAR(MAX)
	, @strCategoryId NVARCHAR(MAX)
	, @strFamilyId NVARCHAR(MAX)
	, @strClassId NVARCHAR(MAX)
	
	, @strParentId NVARCHAR(50)
	, @strChildId NVARCHAR(50)

	, @strPromotionType NVARCHAR(50)
)
RETURNS VARCHAR(MAX)
AS BEGIN

    DECLARE @strGeneratedSql VARCHAR(MAX)



    --SET @strGeneratedSql =  ' SELECT' + CHAR(13)
				--				   + ' CL.strLocationName' + CHAR(13)
				--				   --+ '	, UOM.strUpcCode' + CHAR(13)
				--				   + '  , CASE ' + CHAR(13)
				--				   + '		WHEN UOM.strUpcCode IS NOT NULL OR UOM.strUpcCode != '''' THEN UOM.strUpcCode ' + CHAR(13)
				--				   + '		WHEN UOM.strLongUPCCode IS NOT NULL OR UOM.strLongUPCCode != '''' THEN UOM.strLongUPCCode ' + CHAR(13)
				--				   + '    END AS strUpcCode ' + CHAR(13)
				--				   + '	, I.strDescription' + CHAR(13)
				--				   + '	,''' + @strChangeDescription + '''' + CHAR(13)
				--				   + '	,' + @strOldData + '' + CHAR(13)
				--				   + '	,' + @strNewData + '' + CHAR(13)
				--				   + '	,' + @strParentId + '' + CHAR(13)
				--				   + '	,' + @strChildId + '' + CHAR(13)
				--		   + ' FROM tblICItemSpecialPricing IP' + CHAR(13)
				--		   + ' JOIN tblICItemUOM UOM ON IP.intItemUnitMeasureId = UOM.intItemUOMId' + CHAR(13)
				--		   + ' JOIN tblICItem I ON IP.intItemId = I.intItemId' + CHAR(13)
				--		   + ' JOIN tblICItemLocation IL ON IP.intItemId = IL.intItemId' + CHAR(13)
				--		   + ' JOIN tblSMCompanyLocation CL ON IL.intLocationId = CL.intCompanyLocationId ' + CHAR(13)

	 SET @strGeneratedSql =  ' SELECT' + CHAR(13)
								   + ' CL.strLocationName' + CHAR(13)
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
						   + ' FROM tblICItemSpecialPricing IP' + CHAR(13)
						   + ' JOIN tblICItem I ON IP.intItemId = I.intItemId' + CHAR(13)
						   + ' JOIN tblICItemUOM UOM ON I.intItemId = UOM.intItemId ' + CHAR(13)
						   + '                      AND IP.intItemUnitMeasureId = UOM.intItemUOMId ' + CHAR(13)
						   + ' JOIN tblICItemLocation IL ON IP.intItemLocationId = IL.intItemLocationId  ' + CHAR(13)
						   + ' JOIN tblSMCompanyLocation CL ON IL.intLocationId = CL.intCompanyLocationId   ' + CHAR(13)


		   SET @strGeneratedSql = @strGeneratedSql + ' WHERE 1=1 ' 

		   IF ((@strCompanyLocationId != '') AND (@strCompanyLocationId IS NOT NULL))
		   BEGIN 
				SET @strGeneratedSql = @strGeneratedSql + ' and IL.intLocationId IN (' + CAST(@strCompanyLocationId as NVARCHAR(MAX)) + ')'
		   END
		 
		   IF ((@strVendorId != '') AND (@strVendorId IS NOT NULL))
		   BEGIN 
			   SET @strGeneratedSql = @strGeneratedSql + ' and IP.intItemLocationId
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
	    

		   --In some cases
		   IF(@strChangeDescription = 'Begining Date' OR @strChangeDescription = 'Ending Date')
		   BEGIN
				IF(@strPromotionType = 'Vendor Rebate')
				BEGIN
					 SET @strGeneratedSql = @strGeneratedSql + ' and  IP.strPromotionType = ''Rebate''' 
				END
				IF (@strPromotionType = 'Vendor Discount')
				BEGIN
					 SET @strGeneratedSql = @strGeneratedSql + ' and  IP.strPromotionType = ''Vendor Discount''' 
				END
		   END

		   ELSE IF(@strChangeDescription = 'Rebate Amount' OR @strChangeDescription = 'Accumulated Amount' OR @strChangeDescription = 'Accumulated Quantity')
		   BEGIN
				IF(@strPromotionType = 'Vendor Rebate')
				BEGIN
					 SET @strGeneratedSql = @strGeneratedSql + ' and  IP.strPromotionType = ''Rebate''' 
				END	
		   END

		   ELSE IF(@strChangeDescription = 'Discount Amount' OR @strChangeDescription = 'Discount through amount' OR @strChangeDescription = 'Discount through quantity')
		   BEGIN
				IF(@strPromotionType = 'Vendor Discount')
				BEGIN
					 SET @strGeneratedSql = @strGeneratedSql + ' and  IP.strPromotionType = ''Vendor Discount''' 
				END	
		   END

    RETURN @strGeneratedSql
END