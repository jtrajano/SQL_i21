﻿CREATE FUNCTION dbo.fnSTDynamicQueryItemData 
(
	@strChangeDescription VARCHAR(250)
	, @strOldData NVARCHAR(250)
	, @strNewData NVARCHAR(250)

	, @strCompanyLocationId NVARCHAR(250)
	, @strVendorId NVARCHAR(250)
	, @strCategoryId NVARCHAR(250)
	, @strFamilyId NVARCHAR(250)
	, @strClassId NVARCHAR(250)
	, @intUpcCode INT
	, @strDescription NVARCHAR(250)
	, @dblPriceBetween1 DECIMAL(18, 6)
	, @dblPriceBetween2 DECIMAL(18, 6)
	, @strParentId NVARCHAR(50)
	, @strChildId NVARCHAR(50)
)
RETURNS VARCHAR(MAX)
AS BEGIN
    DECLARE @strGeneratedSql VARCHAR(MAX)

    SET @strGeneratedSql =  ' SELECT' + CHAR(13)
								   + ' c.strLocationName' + CHAR(13)
								   + '	, b.strUpcCode' + CHAR(13)
								   + '	, d.strDescription' + CHAR(13)
								   + '	,''' + @strChangeDescription + '''' + CHAR(13)
								   + '	,' + @strOldData + '' + CHAR(13)
								   + '	,' + @strNewData + '' + CHAR(13)
								   + '	,' + @strParentId + '' + CHAR(13)
								   + '	,' + @strChildId + '' + CHAR(13)
						   + ' FROM tblICItemLocation a' + CHAR(13)
						   + ' JOIN tblICItemUOM b ON a.intItemId = b.intItemId' + CHAR(13)
						   + ' JOIN tblSMCompanyLocation c ON a.intLocationId = c.intCompanyLocationId' + CHAR(13)
						   + ' JOIN tblICItem d ON a.intItemId = d.intItemId' + CHAR(13)
						   + ' JOIN tblICItemAccount e ON a.intItemId = e.intItemId ' + CHAR(13)

		   SET @strGeneratedSql = @strGeneratedSql + ' WHERE 1=1 ' 

		   IF (@strCompanyLocationId <> '')
		   BEGIN 
				SET @strGeneratedSql = @strGeneratedSql + ' and c.intCompanyLocationId IN (' + CAST(@strCompanyLocationId as NVARCHAR(250)) + ')'
		   END
		 
		   IF (@strVendorId <> '')
		   BEGIN 
			   SET @strGeneratedSql = @strGeneratedSql + ' and a.intVendorId IN (' + CAST(@strVendorId as NVARCHAR(250)) + ')'
		   END

		   IF (@strCategoryId <> '')
		   BEGIN
				SET @strGeneratedSql = @strGeneratedSql +  ' and a.intItemId  
				IN (select intItemId from tblICItem where intCategoryId IN
				(select intCategoryId from tblICCategory where intCategoryId 
				IN (' + CAST(@strCategoryId as NVARCHAR(250)) + ')' + '))'
		   END

		   IF (@strFamilyId <> '')
		   BEGIN
				 SET @strGeneratedSql = @strGeneratedSql + ' and  a.intFamilyId IN (' + CAST(@strFamilyId as NVARCHAR(250)) + ')'
		   END

		   IF (@strClassId <> '')
		   BEGIN
				 SET @strGeneratedSql = @strGeneratedSql + ' and  a.intClassId IN (' + CAST(@strClassId as NVARCHAR(250)) + ')'
		   END
	    
		   IF (@intUpcCode IS NOT NULL)
		   BEGIN
			   SET @strGeneratedSql = @strGeneratedSql + ' and b.intItemUOMId IN (' + CAST(@intUpcCode as NVARCHAR(250)) + ')'
		   END

		   IF ((@strDescription != '') AND (@strDescription IS NOT NULL))
		   BEGIN
				SET @strGeneratedSql = @strGeneratedSql +  ' and  d.strDescription like ''%' + LTRIM(@strDescription) + '%'' '
		   END

		   IF (@dblPriceBetween1 IS NOT NULL) 
		   BEGIN
				SET @strGeneratedSql = @strGeneratedSql +  ' and a.intItemId IN 
			    (select intItemId from tblICItemPricing where dblSalePrice >= 
				''' + CONVERT(NVARCHAR(250),(@dblPriceBetween1)) + '''' + ')'
		   END 
	      
		   IF (@dblPriceBetween2 IS NOT NULL) 
		   BEGIN
				SET @strGeneratedSql = @strGeneratedSql +  ' and a.intItemId IN 
			    (select intItemId from tblICItemPricing where dblSalePrice <= 
				''' + CONVERT(NVARCHAR(250),(@dblPriceBetween2)) + '''' + ')'
		   END


		   --In some cases
		   IF(@strChangeDescription = 'Purchase Account')
		   BEGIN
				SET @strGeneratedSql = @strGeneratedSql +  ' and e.intAccountCategoryId = 30 ' 
		   END
		   ELSE IF(@strChangeDescription = '''Sales Account''')
		   BEGIN
				SET @strGeneratedSql = @strGeneratedSql +  ' and e.intAccountCategoryId = 33 ' 
		   END
		   ELSE IF(@strChangeDescription = '''Variance Account''')
		   BEGIN
				SET @strGeneratedSql = @strGeneratedSql +  ' and e.intAccountCategoryId = 40 ' 
		   END

    RETURN @strGeneratedSql
END