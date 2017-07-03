CREATE FUNCTION dbo.fnSTDynamicQueryItemData 
(
	@strChangeDescription VARCHAR(250)
	, @strOldData VARCHAR(250)
	, @strNewData VARCHAR(250)

	, @strCompanyLocationId VARCHAR(250)
	, @strVendorId VARCHAR(250)
	, @strCategoryId VARCHAR(250)
	, @strFamilyId VARCHAR(250)
	, @strClassId VARCHAR(250)
	, @intUpcCode INT
	, @strDescription VARCHAR(250)
	, @dblPriceBetween1 DECIMAL(18, 6)
	, @dblPriceBetween2 DECIMAL(18, 6)
)
RETURNS VARCHAR(MAX)
AS BEGIN
    DECLARE @strGeneratedSql VARCHAR(MAX)

    SET @strGeneratedSql =  ' SELECT' + CHAR(13)
								   + '	 c.strLocationName' + CHAR(13)
								   + '	, b.strUpcCode' + CHAR(13)
								   + '	, d.strDescription' + CHAR(13)
								   + '	' + @strChangeDescription + CHAR(13)
								   + '	' + @strOldData + CHAR(13)
								   + '	' + @strNewData + CHAR(13)
						   + ' FROM tblICItemLocation a' + CHAR(13)
						   + ' JOIN tblICItemUOM b ON a.intItemId = b.intItemId' + CHAR(13)
						   + ' JOIN tblSMCompanyLocation c ON a.intLocationId = c.intCompanyLocationId' + CHAR(13)
						   + ' JOIN tblICItem d ON a.intItemId = d.intItemId ' + CHAR(13)

		   SET @strGeneratedSql = @strGeneratedSql + ' WHERE 1=1 ' 

		   IF (@strCompanyLocationId <> '')
		   BEGIN 
				SET @strGeneratedSql = @strGeneratedSql + ' and c.intCompanyLocationId IN (' + CAST(@strCompanyLocationId as NVARCHAR) + ')'
		   END
		 
		   IF (@strVendorId <> '')
		   BEGIN 
			   SET @strGeneratedSql = @strGeneratedSql + ' and a.intVendorId IN (' + CAST(@strVendorId as NVARCHAR) + ')'
		   END

		   IF (@strCategoryId <> '')
		   BEGIN
				SET @strGeneratedSql = @strGeneratedSql +  ' and a.intItemId  
				IN (select intItemId from tblICItem where intCategoryId IN
				(select intCategoryId from tblICCategory where intCategoryId 
				IN (' + CAST(@strCategoryId as NVARCHAR) + ')' + '))'
		   END

		   IF (@strFamilyId <> '')
		   BEGIN
				 SET @strGeneratedSql = @strGeneratedSql + ' and  a.intFamilyId IN (' + CAST(@strFamilyId as NVARCHAR) + ')'
		   END

		   IF (@strClassId <> '')
		   BEGIN
				 SET @strGeneratedSql = @strGeneratedSql + ' and  a.intClassId IN (' + CAST(@strClassId as NVARCHAR) + ')'
		   END
	    
		   IF (@intUpcCode IS NOT NULL)
		   BEGIN
			   SET @strGeneratedSql = @strGeneratedSql + ' and b.intItemUOMId IN (' + CAST(@intUpcCode as NVARCHAR) + ')'
		   END

		   IF ((@strDescription != '') AND (@strDescription IS NOT NULL))
		   BEGIN
				SET @strGeneratedSql = @strGeneratedSql +  ' and  d.strDescription like ''%' + LTRIM(@strDescription) + '%'' '
		   END

		   IF (@dblPriceBetween1 IS NOT NULL) 
		   BEGIN
				SET @strGeneratedSql = @strGeneratedSql +  ' and a.intItemId IN 
			    (select intItemId from tblICItemPricing where dblSalePrice >= 
				''' + CONVERT(NVARCHAR,(@dblPriceBetween1)) + '''' + ')'
		   END 
	      
		   IF (@dblPriceBetween2 IS NOT NULL) 
		   BEGIN
				SET @strGeneratedSql = @strGeneratedSql +  ' and a.intItemId IN 
			    (select intItemId from tblICItemPricing where dblSalePrice <= 
				''' + CONVERT(NVARCHAR,(@dblPriceBetween2)) + '''' + ')'
		   END

    RETURN @strGeneratedSql
END