CREATE FUNCTION [dbo].[fnSTDynamicQueryItemData] 
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
	, @strDescription NVARCHAR(250)
	, @dblPriceBetween1 DECIMAL(18, 6)
	, @dblPriceBetween2 DECIMAL(18, 6)
	, @strParentId NVARCHAR(50)
	, @strChildId NVARCHAR(50)
)
RETURNS VARCHAR(MAX)
AS BEGIN
	DECLARE @intAccountCategoryId INT
	DECLARE @strAccountCategory NVARCHAR(100)

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
						   + ' LEFT JOIN tblICItemAccount e ON a.intItemId = e.intItemId ' + CHAR(13) --Will use left join, not all items has GL Account

		   SET @strGeneratedSql = @strGeneratedSql + ' WHERE 1=1 ' 

		   IF (@strCompanyLocationId <> '')
		   BEGIN 
				SET @strGeneratedSql = @strGeneratedSql + ' and c.intCompanyLocationId IN (' + CAST(@strCompanyLocationId as NVARCHAR(MAX)) + ')'
		   END
		 
		   IF (@strVendorId <> '')
		   BEGIN 
			   SET @strGeneratedSql = @strGeneratedSql + ' and a.intVendorId IN (' + CAST(@strVendorId as NVARCHAR(MAX)) + ')'
		   END

		   IF (@strCategoryId <> '')
		   BEGIN
				SET @strGeneratedSql = @strGeneratedSql +  ' and a.intItemId  
				IN (select intItemId from tblICItem where intCategoryId IN
				(select intCategoryId from tblICCategory where intCategoryId 
				IN (' + CAST(@strCategoryId as NVARCHAR(MAX)) + ')' + '))'
		   END

		   IF (@strFamilyId <> '')
		   BEGIN
				 SET @strGeneratedSql = @strGeneratedSql + ' and  a.intFamilyId IN (' + CAST(@strFamilyId as NVARCHAR(MAX)) + ')'
		   END

		   IF (@strClassId <> '')
		   BEGIN
				 SET @strGeneratedSql = @strGeneratedSql + ' and  a.intClassId IN (' + CAST(@strClassId as NVARCHAR(MAX)) + ')'
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
		   IF(@strChangeDescription = 'Cost of Goods Sold Account')
		   BEGIN
				SET @strAccountCategory = 'Cost of Goods'
				IF EXISTS(SELECT * FROM dbo.tblGLAccountCategory WHERE strAccountCategory = @strAccountCategory)
				BEGIN
					--SET @strGeneratedSql = @strGeneratedSql +  ' and e.intAccountCategoryId = 30 '

					SELECT @intAccountCategoryId = intAccountCategoryId FROM dbo.tblGLAccountCategory WHERE strAccountCategory = @strAccountCategory
					SET @strGeneratedSql = @strGeneratedSql +  ' and e.intAccountCategoryId = ' + CAST(@intAccountCategoryId AS NVARCHAR(50)) + ' '
				END 
		   END
		   ELSE IF(@strChangeDescription = 'Sales Account')
		   BEGIN
				SET @strAccountCategory = 'Sales Account'
				IF EXISTS(SELECT * FROM dbo.tblGLAccountCategory WHERE strAccountCategory = @strAccountCategory)
				BEGIN
					--SET @strGeneratedSql = @strGeneratedSql +  ' and e.intAccountCategoryId = 33 '

					SELECT @intAccountCategoryId = intAccountCategoryId FROM dbo.tblGLAccountCategory WHERE strAccountCategory = @strAccountCategory
					SET @strGeneratedSql = @strGeneratedSql +  ' and e.intAccountCategoryId = ' + CAST(@intAccountCategoryId AS NVARCHAR(50)) + ' '
				END 
		   END
		   ELSE IF(@strChangeDescription = 'Add New Cost of Goods Sold Account')
		   BEGIN
				SET @strAccountCategory = 'Cost of Goods'
				IF EXISTS(SELECT * FROM dbo.tblGLAccountCategory WHERE strAccountCategory = @strAccountCategory)
				BEGIN
					SELECT @intAccountCategoryId = intAccountCategoryId FROM dbo.tblGLAccountCategory WHERE strAccountCategory = @strAccountCategory
					SET @strGeneratedSql = @strGeneratedSql +  ' and (e.intAccountCategoryId IS NULL OR e.intAccountCategoryId != ' + CAST(@intAccountCategoryId AS NVARCHAR(50)) + ') '
				END 
		   END
		   ELSE IF(@strChangeDescription = 'Add New Sales Account')
		   BEGIN
				SET @strAccountCategory = 'Sales Account'
				IF EXISTS(SELECT * FROM dbo.tblGLAccountCategory WHERE strAccountCategory = @strAccountCategory)
				BEGIN
					SELECT @intAccountCategoryId = intAccountCategoryId FROM dbo.tblGLAccountCategory WHERE strAccountCategory = @strAccountCategory
					SET @strGeneratedSql = @strGeneratedSql +  ' and (e.intAccountCategoryId IS NULL OR e.intAccountCategoryId != ' + CAST(@intAccountCategoryId AS NVARCHAR(50)) + ') '
				END 
		   END
		   --For now Variance account will be remove
		  -- ELSE IF(@strChangeDescription = 'Variance Account')
		  -- BEGIN
				--SET @strGeneratedSql = @strGeneratedSql +  ' and e.intAccountCategoryId = 40 ' 
		  -- END

    RETURN @strGeneratedSql
END