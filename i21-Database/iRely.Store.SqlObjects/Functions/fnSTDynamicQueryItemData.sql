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

	--a. = IL
	--b. = UOM
	--c. = CL
	--d = I
	--e = IA

    SET @strGeneratedSql =  ' SELECT DISTINCT' + CHAR(13)
								   + ' CL.strLocationName' + CHAR(13)
								   --+ '	, UOM.strUpcCode' + CHAR(13)
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
						   + ' FROM tblICItemLocation IL' + CHAR(13)
						   + ' JOIN tblICItemUOM UOM ON IL.intItemId = UOM.intItemId' + CHAR(13)
						   + ' JOIN tblSMCompanyLocation CL ON IL.intLocationId = CL.intCompanyLocationId' + CHAR(13)
						   + ' JOIN tblICItem I ON IL.intItemId = I.intItemId' + CHAR(13)
						   + ' LEFT JOIN tblICItemAccount IA ON IL.intItemId = IA.intItemId ' + CHAR(13) --Will use left join, not all items has GL Account

		   SET @strGeneratedSql = @strGeneratedSql + ' WHERE 1=1 AND UOM.ysnStockUnit = CAST(1 AS BIT) ' 

		   IF (@strCompanyLocationId <> '')
		   BEGIN 
				SET @strGeneratedSql = @strGeneratedSql + ' and CL.intCompanyLocationId IN (' + CAST(@strCompanyLocationId as NVARCHAR(MAX)) + ')'
		   END
		 
		   IF (@strVendorId <> '')
		   BEGIN 
			   SET @strGeneratedSql = @strGeneratedSql + ' and IL.intVendorId IN (' + CAST(@strVendorId as NVARCHAR(MAX)) + ')'
		   END

		   IF (@strCategoryId <> '')
		   BEGIN
				SET @strGeneratedSql = @strGeneratedSql +  ' and IL.intItemId  
				IN (select intItemId from tblICItem where intCategoryId IN
				(select intCategoryId from tblICCategory where intCategoryId 
				IN (' + CAST(@strCategoryId as NVARCHAR(MAX)) + ')' + '))'
		   END

		   IF (@strFamilyId <> '')
		   BEGIN
				 SET @strGeneratedSql = @strGeneratedSql + ' and  IL.intFamilyId IN (' + CAST(@strFamilyId as NVARCHAR(MAX)) + ')'
		   END

		   IF (@strClassId <> '')
		   BEGIN
				 SET @strGeneratedSql = @strGeneratedSql + ' and  IL.intClassId IN (' + CAST(@strClassId as NVARCHAR(MAX)) + ')'
		   END
	    
		   IF (@intUpcCode IS NOT NULL)
		   BEGIN
			   SET @strGeneratedSql = @strGeneratedSql + ' and UOM.intItemUOMId IN (' + CAST(@intUpcCode as NVARCHAR(250)) + ')'
		   END

		   IF ((@strDescription != '') AND (@strDescription IS NOT NULL))
		   BEGIN
				SET @strGeneratedSql = @strGeneratedSql +  ' and  I.strDescription like ''%' + LTRIM(@strDescription) + '%'' '
		   END

		   IF (@dblPriceBetween1 IS NOT NULL) 
		   BEGIN
				SET @strGeneratedSql = @strGeneratedSql +  ' and IL.intItemId IN 
			    (select intItemId from tblICItemPricing where dblSalePrice >= 
				''' + CONVERT(NVARCHAR(250),(@dblPriceBetween1)) + '''' + ')'
		   END 
	      
		   IF (@dblPriceBetween2 IS NOT NULL) 
		   BEGIN
				SET @strGeneratedSql = @strGeneratedSql +  ' and IL.intItemId IN 
			    (select intItemId from tblICItemPricing where dblSalePrice <= 
				''' + CONVERT(NVARCHAR(250),(@dblPriceBetween2)) + '''' + ')'
		   END


		   --In some cases
		   IF(@strChangeDescription = 'Cost of Goods Sold Account')
		   BEGIN
				SET @strAccountCategory = 'Cost of Goods'
				IF EXISTS(SELECT * FROM dbo.tblGLAccountCategory WHERE strAccountCategory = @strAccountCategory)
				BEGIN
					--SET @strGeneratedSql = @strGeneratedSql +  ' and IA.intAccountCategoryId = 30 '

					SELECT @intAccountCategoryId = intAccountCategoryId FROM dbo.tblGLAccountCategory WHERE strAccountCategory = @strAccountCategory
					SET @strGeneratedSql = @strGeneratedSql +  ' and IA.intAccountCategoryId = ' + CAST(@intAccountCategoryId AS NVARCHAR(50)) + ' '
				END 
		   END
		   ELSE IF(@strChangeDescription = 'Sales Account')
		   BEGIN
				SET @strAccountCategory = 'Sales Account'
				IF EXISTS(SELECT * FROM dbo.tblGLAccountCategory WHERE strAccountCategory = @strAccountCategory)
				BEGIN
					--SET @strGeneratedSql = @strGeneratedSql +  ' and IA.intAccountCategoryId = 33 '

					SELECT @intAccountCategoryId = intAccountCategoryId FROM dbo.tblGLAccountCategory WHERE strAccountCategory = @strAccountCategory
					SET @strGeneratedSql = @strGeneratedSql +  ' and IA.intAccountCategoryId = ' + CAST(@intAccountCategoryId AS NVARCHAR(50)) + ' '
				END 
		   END
		   ELSE IF(@strChangeDescription = 'Add New Cost of Goods Sold Account')
		   BEGIN
				SET @strAccountCategory = 'Cost of Goods'
				IF EXISTS(SELECT * FROM dbo.tblGLAccountCategory WHERE strAccountCategory = @strAccountCategory)
				BEGIN
					SELECT @intAccountCategoryId = intAccountCategoryId FROM dbo.tblGLAccountCategory WHERE strAccountCategory = @strAccountCategory
					SET @strGeneratedSql = @strGeneratedSql +  ' and (IA.intAccountCategoryId IS NULL OR IA.intAccountCategoryId != ' + CAST(@intAccountCategoryId AS NVARCHAR(50)) + ') '
				END 
		   END
		   ELSE IF(@strChangeDescription = 'Add New Sales Account')
		   BEGIN
				SET @strAccountCategory = 'Sales Account'
				IF EXISTS(SELECT * FROM dbo.tblGLAccountCategory WHERE strAccountCategory = @strAccountCategory)
				BEGIN
					SELECT @intAccountCategoryId = intAccountCategoryId FROM dbo.tblGLAccountCategory WHERE strAccountCategory = @strAccountCategory
					SET @strGeneratedSql = @strGeneratedSql +  ' and (IA.intAccountCategoryId IS NULL OR IA.intAccountCategoryId != ' + CAST(@intAccountCategoryId AS NVARCHAR(50)) + ') '
				END 
		   END
		   --For now Variance account will be remove
		  -- ELSE IF(@strChangeDescription = 'Variance Account')
		  -- BEGIN
				--SET @strGeneratedSql = @strGeneratedSql +  ' and IA.intAccountCategoryId = 40 ' 
		  -- END

    RETURN @strGeneratedSql
END