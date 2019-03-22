CREATE FUNCTION [dbo].[fnSTDynamicQueryInventoryMass] 
(
	@strChangeDescription VARCHAR(250)
	, @strOldData NVARCHAR(250)
	, @strNewData NVARCHAR(250)
	, @intItemUOMId INT
	, @intItemId INT
	, @intItemLocationId INT
	, @intItemPricingId INT
)
RETURNS VARCHAR(MAX)
AS BEGIN

    DECLARE @strGeneratedSql VARCHAR(MAX) = ''

	SET @strGeneratedSql = 
	N'SELECT DISTINCT' + CHAR(13)
			+ ' CL.strLocationName AS strLocation ' + CHAR(13)
			+ ', CASE ' + CHAR(13)
			+ '       WHEN UOM.strUpcCode IS NOT NULL OR UOM.strUpcCode != '''' THEN UOM.strUpcCode ' + CHAR(13)
			+ '       WHEN UOM.strLongUPCCode IS NOT NULL OR UOM.strLongUPCCode != '''' THEN UOM.strLongUPCCode ' + CHAR(13)
			+ '  END AS strUpc ' + CHAR(13)
			+ ', I.strDescription AS strItemDescription ' + CHAR(13)
			+ ', ''' + @strChangeDescription + ''' AS strChangeDescription ' + CHAR(13)
			+ ', ' + @strOldData +  ' AS strOldData ' + CHAR(13)
			+ ', ' + @strNewData + ' AS strNewData ' + CHAR(13)
	+ ' FROM dbo.tblICItemPricing AS IP ' + CHAR(13)
	+ ' LEFT OUTER JOIN dbo.tblICItemLocation AS IL ON IP.intItemId = IL.intItemId ' + CHAR(13) 
	+ '												AND IL.intItemLocationId IS NOT NULL ' + CHAR(13)
	+ ' LEFT OUTER JOIN dbo.tblSTSubcategory AS SubCatF ON IL.intFamilyId = SubCatF.intSubcategoryId ' + CHAR(13)
	+ ' LEFT OUTER JOIN dbo.tblSTSubcategory AS SubCatC ON IL.intClassId = SubCatC.intSubcategoryId ' + CHAR(13)
	+ ' LEFT OUTER JOIN dbo.tblSMCompanyLocation AS CL ON IL.intLocationId = CL.intCompanyLocationId ' + CHAR(13)
	+ ' LEFT OUTER JOIN dbo.tblICItemUOM AS UOM ON IP.intItemId = UOM.intItemId ' + CHAR(13)
	+ ' LEFT OUTER JOIN dbo.tblICItem AS I ON IP.intItemId = I.intItemId ' + CHAR(13)
	+ ' LEFT OUTER JOIN dbo.tblICCategory AS Cat ON I.intCategoryId = Cat.intCategoryId ' + CHAR(13)
	+ ' LEFT OUTER JOIN dbo.tblAPVendor AS Vendor ON IL.intVendorId = Vendor.[intEntityId] ' + CHAR(13)
	+ ' LEFT OUTER JOIN dbo.tblICItemVendorXref AS VendorXref ON IL.intItemLocationId = VendorXref.intItemLocationId ' + CHAR(13)
	+ ' LEFT OUTER JOIN dbo.tblEMEntity AS EM ON EM.intEntityId = IL.intVendorId' + CHAR(13)
	
	+ ' WHERE UOM.intItemUOMId = ' + CAST(@intItemUOMId as NVARCHAR(50)) + '' + CHAR(13)
	+ ' AND I.intItemId = ' + CAST(@intItemId as NVARCHAR(50)) + '' + CHAR(13)
	+ ' AND IL.intItemLocationId = ' + CAST(@intItemLocationId as NVARCHAR(50)) + '' + CHAR(13)
	+ ' AND IP.intItemPricingId = ' + CAST(@intItemPricingId as NVARCHAR(50)) + '' + CHAR(13)

    RETURN @strGeneratedSql
END