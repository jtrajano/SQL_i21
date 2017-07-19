CREATE PROCEDURE [dbo].[uspSTUpdatePricebookItem]
@intUniqueId Int
, @intEntityId Int
, @intCompanyLocationId Int
, @intItemUOMId int
, @intItemId int
, @intItemLocationId int
, @intItemPricingId int
, @intCategoryId int

, @strDescription nvarchar(250)
, @PosDescription nvarchar(250)
, @dblSalePrice decimal(18,6)
, @dblLastCost decimal(18,6)
, @intEntityVendorId int
, @strVendorId nvarchar(100)
, @Family nvarchar(100)
, @FamilyId int
, @Class nvarchar(100)
, @ClassId int
, @strStatusMsg NVARCHAR(1000) OUTPUT
AS
BEGIN

	IF EXISTS(SELECT * FROM dbo.tblSTSubcategory WHERE strSubcategoryType = 'C' AND strSubcategoryId = @Class AND intSubcategoryId <> @ClassId)
	BEGIN
		SET @strStatusMsg = 'Class category ' + @Class + ' already exists'
		RETURN
	END

	ELSE IF EXISTS(SELECT * FROM dbo.tblSTSubcategory WHERE strSubcategoryType = 'F' AND strSubcategoryId = @Family AND intSubcategoryId <> @FamilyId)
	BEGIN
		SET @strStatusMsg = 'Family category ' + @Family + ' already exists'
		RETURN
	END

	ELSE
	BEGIN
	   --CHECK @tempTable
	   --Declare table temp holder
	   DECLARE @tblTemp TABLE 
	   (
			strLocation NVARCHAR(250)
			, strUpc NVARCHAR(50)
			, strItemDescription NVARCHAR(250)
			, strChangeDescription NVARCHAR(100)
			, strOldData NVARCHAR(MAX)
			, strNewData NVARCHAR(MAX)
	   )

	   --Get decimal setting
		DECLARE @CompanyCurrencyDecimal NVARCHAR(1)
		SET @CompanyCurrencyDecimal = 0
		SELECT @CompanyCurrencyDecimal = intCurrencyDecimal from tblSMCompanyPreference

	   DECLARE @changeDescription NVARCHAR(50)
	   SET @changeDescription = ''

	   DECLARE @oldData NVARCHAR(50)
	   SET @oldData = ''

	   DECLARE @newData NVARCHAR(50)
	   SET @newData = ''

	   DECLARE @children NVARCHAR(MAX)
	   SET @children = ''

	   DECLARE @SqlQuery1 as NVARCHAR(MAX)

	   ----intCategoryId
		IF (@intCategoryId IS NOT NULL AND @intCategoryId <> 0)
		BEGIN
		
			DECLARE @strCategoryCode NVARCHAR(100)
			SELECT @strCategoryCode = strCategoryCode FROM tblICCategory WHERE intCategoryId = @intCategoryId

			SET @SqlQuery1 = 'SELECT' + CHAR(13)
									+ ' adj5.strLocationName AS strLocation' + CHAR(13)
									+ ', adj6.strUpcCode AS strUpc' + CHAR(13)
									+ ', adj7.strDescription AS strItemDescription' + CHAR(13)
									+ ', ''Category'' AS strChangeDescription' + CHAR(13)
									+ ', adj8.strCategoryCode AS strOldData' + CHAR(13)
									+ ', ''' + @strCategoryCode + ''' AS strNewData' + CHAR(13)
						  + ' FROM dbo.tblICItemPricing AS adj1 LEFT OUTER JOIN' + CHAR(13)
							  + ' dbo.tblICItemLocation AS adj2 ON adj1.intItemId = adj2.intItemId AND adj2.intItemLocationId IS NOT NULL LEFT OUTER JOIN' + CHAR(13)
							  + ' dbo.tblSTSubcategory AS adj3 ON adj2.intFamilyId = adj3.intSubcategoryId LEFT OUTER JOIN' + CHAR(13)
							  + ' dbo.tblSTSubcategory AS adj4 ON adj2.intClassId = adj4.intSubcategoryId LEFT OUTER JOIN' + CHAR(13)
							  + ' dbo.tblSMCompanyLocation AS adj5 ON adj2.intLocationId = adj5.intCompanyLocationId LEFT OUTER JOIN' + CHAR(13)
							  + ' dbo.tblICItemUOM AS adj6 ON adj1.intItemId = adj6.intItemId LEFT OUTER JOIN' + CHAR(13)
							  + ' dbo.tblICItem AS adj7 ON adj1.intItemId = adj7.intItemId LEFT OUTER JOIN' + CHAR(13)
							  + ' dbo.tblICCategory AS adj8 ON adj7.intCategoryId = adj8.intCategoryId LEFT OUTER JOIN' + CHAR(13)
							  + ' dbo.tblAPVendor AS adj9 ON adj2.intVendorId = adj9.[intEntityId] LEFT OUTER JOIN' + CHAR(13)
							  + ' dbo.tblICItemVendorXref AS adj10 ON adj2.intItemLocationId = adj10.intItemLocationId LEFT OUTER JOIN' + CHAR(13)
							  + ' dbo.tblEMEntity AS adj11 ON adj11.intEntityId = adj2.intVendorId' + CHAR(13)
						  + ' WHERE adj5.intCompanyLocationId = ' + CAST(@intCompanyLocationId as NVARCHAR(50)) + '' + CHAR(13)
						  + ' AND adj6.intItemUOMId = ' + CAST(@intItemUOMId as NVARCHAR(50)) + '' + CHAR(13)
						  + ' AND adj7.intItemId = ' + CAST(@intItemId as NVARCHAR(50)) + '' + CHAR(13)
						  + ' AND adj2.intItemLocationId = ' + CAST(@intItemLocationId as NVARCHAR(50)) + '' + CHAR(13)
						  + ' AND adj1.intItemPricingId = ' + CAST(@intItemPricingId as NVARCHAR(50)) + '' + CHAR(13)

			INSERT @tblTemp
			EXEC (@SqlQuery1)
		END

		--strDescription
		IF (@strDescription != '' AND @strDescription != 'null')
		BEGIN
		
			SET @SqlQuery1 = 'SELECT' + CHAR(13)
									+ ' adj5.strLocationName AS strLocation' + CHAR(13)
									+ ', adj6.strUpcCode AS strUpc' + CHAR(13)
									+ ', adj7.strDescription AS strItemDescription' + CHAR(13)
									+ ', ''Description'' AS strChangeDescription' + CHAR(13)
									+ ', adj7.strDescription AS strOldData' + CHAR(13)
									+ ', ''' + @strDescription + ''' AS strNewData' + CHAR(13)
						  + ' FROM dbo.tblICItemPricing AS adj1 LEFT OUTER JOIN' + CHAR(13)
							  + ' dbo.tblICItemLocation AS adj2 ON adj1.intItemId = adj2.intItemId AND adj2.intItemLocationId IS NOT NULL LEFT OUTER JOIN' + CHAR(13)
							  + ' dbo.tblSTSubcategory AS adj3 ON adj2.intFamilyId = adj3.intSubcategoryId LEFT OUTER JOIN' + CHAR(13)
							  + ' dbo.tblSTSubcategory AS adj4 ON adj2.intClassId = adj4.intSubcategoryId LEFT OUTER JOIN' + CHAR(13)
							  + ' dbo.tblSMCompanyLocation AS adj5 ON adj2.intLocationId = adj5.intCompanyLocationId LEFT OUTER JOIN' + CHAR(13)
							  + ' dbo.tblICItemUOM AS adj6 ON adj1.intItemId = adj6.intItemId LEFT OUTER JOIN' + CHAR(13)
							  + ' dbo.tblICItem AS adj7 ON adj1.intItemId = adj7.intItemId LEFT OUTER JOIN' + CHAR(13)
							  + ' dbo.tblICCategory AS adj8 ON adj7.intCategoryId = adj8.intCategoryId LEFT OUTER JOIN' + CHAR(13)
							  + ' dbo.tblAPVendor AS adj9 ON adj2.intVendorId = adj9.[intEntityId] LEFT OUTER JOIN' + CHAR(13)
							  + ' dbo.tblICItemVendorXref AS adj10 ON adj2.intItemLocationId = adj10.intItemLocationId LEFT OUTER JOIN' + CHAR(13)
							  + ' dbo.tblEMEntity AS adj11 ON adj11.intEntityId = adj2.intVendorId' + CHAR(13)
						  + ' WHERE adj5.intCompanyLocationId = ' + CAST(@intCompanyLocationId as NVARCHAR(50)) + '' + CHAR(13)
						  + ' AND adj6.intItemUOMId = ' + CAST(@intItemUOMId as NVARCHAR(50)) + '' + CHAR(13)
						  + ' AND adj7.intItemId = ' + CAST(@intItemId as NVARCHAR(50)) + '' + CHAR(13)
						  + ' AND adj2.intItemLocationId = ' + CAST(@intItemLocationId as NVARCHAR(50)) + '' + CHAR(13)
						  + ' AND adj1.intItemPricingId = ' + CAST(@intItemPricingId as NVARCHAR(50)) + '' + CHAR(13)

			INSERT @tblTemp
			EXEC (@SqlQuery1)
		END

		--PosDescription
		IF (@strDescription != '' AND @strDescription != 'null')
		BEGIN
		
			SET @SqlQuery1 = 'SELECT' + CHAR(13)
									+ ' adj5.strLocationName AS strLocation' + CHAR(13)
									+ ', adj6.strUpcCode AS strUpc' + CHAR(13)
									+ ', adj7.strDescription AS strItemDescription' + CHAR(13)
									+ ', ''Pos Description'' AS strChangeDescription' + CHAR(13)
									+ ', adj2.strDescription AS strOldData' + CHAR(13)
									+ ', ''' + @PosDescription + ''' AS strNewData' + CHAR(13)
						  + ' FROM dbo.tblICItemPricing AS adj1 LEFT OUTER JOIN' + CHAR(13)
							  + ' dbo.tblICItemLocation AS adj2 ON adj1.intItemId = adj2.intItemId AND adj2.intItemLocationId IS NOT NULL LEFT OUTER JOIN' + CHAR(13)
							  + ' dbo.tblSTSubcategory AS adj3 ON adj2.intFamilyId = adj3.intSubcategoryId LEFT OUTER JOIN' + CHAR(13)
							  + ' dbo.tblSTSubcategory AS adj4 ON adj2.intClassId = adj4.intSubcategoryId LEFT OUTER JOIN' + CHAR(13)
							  + ' dbo.tblSMCompanyLocation AS adj5 ON adj2.intLocationId = adj5.intCompanyLocationId LEFT OUTER JOIN' + CHAR(13)
							  + ' dbo.tblICItemUOM AS adj6 ON adj1.intItemId = adj6.intItemId LEFT OUTER JOIN' + CHAR(13)
							  + ' dbo.tblICItem AS adj7 ON adj1.intItemId = adj7.intItemId LEFT OUTER JOIN' + CHAR(13)
							  + ' dbo.tblICCategory AS adj8 ON adj7.intCategoryId = adj8.intCategoryId LEFT OUTER JOIN' + CHAR(13)
							  + ' dbo.tblAPVendor AS adj9 ON adj2.intVendorId = adj9.[intEntityId] LEFT OUTER JOIN' + CHAR(13)
							  + ' dbo.tblICItemVendorXref AS adj10 ON adj2.intItemLocationId = adj10.intItemLocationId LEFT OUTER JOIN' + CHAR(13)
							  + ' dbo.tblEMEntity AS adj11 ON adj11.intEntityId = adj2.intVendorId' + CHAR(13)
						  + ' WHERE adj5.intCompanyLocationId = ' + CAST(@intCompanyLocationId as NVARCHAR(50)) + '' + CHAR(13)
						  + ' AND adj6.intItemUOMId = ' + CAST(@intItemUOMId as NVARCHAR(50)) + '' + CHAR(13)
						  + ' AND adj7.intItemId = ' + CAST(@intItemId as NVARCHAR(50)) + '' + CHAR(13)
						  + ' AND adj2.intItemLocationId = ' + CAST(@intItemLocationId as NVARCHAR(50)) + '' + CHAR(13)
						  + ' AND adj1.intItemPricingId = ' + CAST(@intItemPricingId as NVARCHAR(50)) + '' + CHAR(13)

			INSERT @tblTemp
			EXEC (@SqlQuery1)
		END

		--intEntityId
		IF (@intEntityId IS NOT NULL AND @intEntityId <> 0)
		BEGIN
		
			DECLARE @strVendorName NVARCHAR(100)
			SELECT @strVendorName = strName FROM tblEMEntity WHERE intEntityId = @intEntityVendorId
		
			SELECT @strVendorId = strVendorId FROM tblAPVendor WHERE intEntityId = @intEntityVendorId

			SET @SqlQuery1 = 'SELECT' + CHAR(13)
									+ ' adj5.strLocationName AS strLocation' + CHAR(13)
									+ ', adj6.strUpcCode AS strUpc' + CHAR(13)
									+ ', adj7.strDescription AS strItemDescription' + CHAR(13)
									+ ', ''Vendor'' AS strChangeDescription' + CHAR(13)
									+ ', adj11.strName AS strOldData' + CHAR(13)
									+ ', ''' + @strVendorName + ''' AS strNewData' + CHAR(13)
						  + ' FROM dbo.tblICItemPricing AS adj1 LEFT OUTER JOIN' + CHAR(13)
							  + ' dbo.tblICItemLocation AS adj2 ON adj1.intItemId = adj2.intItemId AND adj2.intItemLocationId IS NOT NULL LEFT OUTER JOIN' + CHAR(13)
							  + ' dbo.tblSTSubcategory AS adj3 ON adj2.intFamilyId = adj3.intSubcategoryId LEFT OUTER JOIN' + CHAR(13)
							  + ' dbo.tblSTSubcategory AS adj4 ON adj2.intClassId = adj4.intSubcategoryId LEFT OUTER JOIN' + CHAR(13)
							  + ' dbo.tblSMCompanyLocation AS adj5 ON adj2.intLocationId = adj5.intCompanyLocationId LEFT OUTER JOIN' + CHAR(13)
							  + ' dbo.tblICItemUOM AS adj6 ON adj1.intItemId = adj6.intItemId LEFT OUTER JOIN' + CHAR(13)
							  + ' dbo.tblICItem AS adj7 ON adj1.intItemId = adj7.intItemId LEFT OUTER JOIN' + CHAR(13)
							  + ' dbo.tblICCategory AS adj8 ON adj7.intCategoryId = adj8.intCategoryId LEFT OUTER JOIN' + CHAR(13)
							  + ' dbo.tblAPVendor AS adj9 ON adj2.intVendorId = adj9.[intEntityId] LEFT OUTER JOIN' + CHAR(13)
							  + ' dbo.tblICItemVendorXref AS adj10 ON adj2.intItemLocationId = adj10.intItemLocationId LEFT OUTER JOIN' + CHAR(13)
							  + ' dbo.tblEMEntity AS adj11 ON adj11.intEntityId = adj2.intVendorId' + CHAR(13)
						  + ' WHERE adj5.intCompanyLocationId = ' + CAST(@intCompanyLocationId as NVARCHAR(50)) + '' + CHAR(13)
						  + ' AND adj6.intItemUOMId = ' + CAST(@intItemUOMId as NVARCHAR(50)) + '' + CHAR(13)
						  + ' AND adj7.intItemId = ' + CAST(@intItemId as NVARCHAR(50)) + '' + CHAR(13)
						  + ' AND adj2.intItemLocationId = ' + CAST(@intItemLocationId as NVARCHAR(50)) + '' + CHAR(13)
						  + ' AND adj1.intItemPricingId = ' + CAST(@intItemPricingId as NVARCHAR(50)) + '' + CHAR(13)

			INSERT @tblTemp
			EXEC (@SqlQuery1)
		END

		--dblSalePrice
		IF (@dblSalePrice IS NOT NULL)
		BEGIN
		
			SET @SqlQuery1 = 'SELECT' + CHAR(13)
									+ ' adj5.strLocationName AS strLocation' + CHAR(13)
									+ ', adj6.strUpcCode AS strUpc' + CHAR(13)
									+ ', adj7.strDescription AS strItemDescription' + CHAR(13)
									+ ', ''Sale Price'' AS strChangeDescription' + CHAR(13)
									+ ', CAST(adj1.dblSalePrice AS DECIMAL(18, ' + @CompanyCurrencyDecimal + ')) AS strOldData' + CHAR(13)
									+ ', CAST(' + CAST(@dblSalePrice AS NVARCHAR(250)) + ' AS DECIMAL(18, ' + @CompanyCurrencyDecimal + '))' + CHAR(13)
						  + ' FROM dbo.tblICItemPricing AS adj1 LEFT OUTER JOIN' + CHAR(13)
							  + ' dbo.tblICItemLocation AS adj2 ON adj1.intItemId = adj2.intItemId AND adj2.intItemLocationId IS NOT NULL LEFT OUTER JOIN' + CHAR(13)
							  + ' dbo.tblSTSubcategory AS adj3 ON adj2.intFamilyId = adj3.intSubcategoryId LEFT OUTER JOIN' + CHAR(13)
							  + ' dbo.tblSTSubcategory AS adj4 ON adj2.intClassId = adj4.intSubcategoryId LEFT OUTER JOIN' + CHAR(13)
							  + ' dbo.tblSMCompanyLocation AS adj5 ON adj2.intLocationId = adj5.intCompanyLocationId LEFT OUTER JOIN' + CHAR(13)
							  + ' dbo.tblICItemUOM AS adj6 ON adj1.intItemId = adj6.intItemId LEFT OUTER JOIN' + CHAR(13)
							  + ' dbo.tblICItem AS adj7 ON adj1.intItemId = adj7.intItemId LEFT OUTER JOIN' + CHAR(13)
							  + ' dbo.tblICCategory AS adj8 ON adj7.intCategoryId = adj8.intCategoryId LEFT OUTER JOIN' + CHAR(13)
							  + ' dbo.tblAPVendor AS adj9 ON adj2.intVendorId = adj9.[intEntityId] LEFT OUTER JOIN' + CHAR(13)
							  + ' dbo.tblICItemVendorXref AS adj10 ON adj2.intItemLocationId = adj10.intItemLocationId LEFT OUTER JOIN' + CHAR(13)
							  + ' dbo.tblEMEntity AS adj11 ON adj11.intEntityId = adj2.intVendorId' + CHAR(13)
						  + ' WHERE adj5.intCompanyLocationId = ' + CAST(@intCompanyLocationId as NVARCHAR(50)) + '' + CHAR(13)
						  + ' AND adj6.intItemUOMId = ' + CAST(@intItemUOMId as NVARCHAR(50)) + '' + CHAR(13)
						  + ' AND adj7.intItemId = ' + CAST(@intItemId as NVARCHAR(50)) + '' + CHAR(13)
						  + ' AND adj2.intItemLocationId = ' + CAST(@intItemLocationId as NVARCHAR(50)) + '' + CHAR(13)
						  + ' AND adj1.intItemPricingId = ' + CAST(@intItemPricingId as NVARCHAR(50)) + '' + CHAR(13)

			INSERT @tblTemp
			EXEC (@SqlQuery1)
		END

		--dblLastCost
		IF (@dblLastCost IS NOT NULL)
		BEGIN
		
			SET @SqlQuery1 = 'SELECT' + CHAR(13)
									+ ' adj5.strLocationName AS strLocation' + CHAR(13)
									+ ', adj6.strUpcCode AS strUpc' + CHAR(13)
									+ ', adj7.strDescription AS strItemDescription' + CHAR(13)
									+ ', ''Last Cost'' AS strChangeDescription' + CHAR(13)
									+ ', CAST(adj1.dblLastCost AS DECIMAL(18, ' + @CompanyCurrencyDecimal + ')) AS strOldData' + CHAR(13)
									+ ', CAST(' + CAST(@dblLastCost AS NVARCHAR(250)) + ' AS DECIMAL(18, ' + @CompanyCurrencyDecimal + '))' + CHAR(13)
						  + ' FROM dbo.tblICItemPricing AS adj1 LEFT OUTER JOIN' + CHAR(13)
							  + ' dbo.tblICItemLocation AS adj2 ON adj1.intItemId = adj2.intItemId AND adj2.intItemLocationId IS NOT NULL LEFT OUTER JOIN' + CHAR(13)
							  + ' dbo.tblSTSubcategory AS adj3 ON adj2.intFamilyId = adj3.intSubcategoryId LEFT OUTER JOIN' + CHAR(13)
							  + ' dbo.tblSTSubcategory AS adj4 ON adj2.intClassId = adj4.intSubcategoryId LEFT OUTER JOIN' + CHAR(13)
							  + ' dbo.tblSMCompanyLocation AS adj5 ON adj2.intLocationId = adj5.intCompanyLocationId LEFT OUTER JOIN' + CHAR(13)
							  + ' dbo.tblICItemUOM AS adj6 ON adj1.intItemId = adj6.intItemId LEFT OUTER JOIN' + CHAR(13)
							  + ' dbo.tblICItem AS adj7 ON adj1.intItemId = adj7.intItemId LEFT OUTER JOIN' + CHAR(13)
							  + ' dbo.tblICCategory AS adj8 ON adj7.intCategoryId = adj8.intCategoryId LEFT OUTER JOIN' + CHAR(13)
							  + ' dbo.tblAPVendor AS adj9 ON adj2.intVendorId = adj9.[intEntityId] LEFT OUTER JOIN' + CHAR(13)
							  + ' dbo.tblICItemVendorXref AS adj10 ON adj2.intItemLocationId = adj10.intItemLocationId LEFT OUTER JOIN' + CHAR(13)
							  + ' dbo.tblEMEntity AS adj11 ON adj11.intEntityId = adj2.intVendorId' + CHAR(13)
						  + ' WHERE adj5.intCompanyLocationId = ' + CAST(@intCompanyLocationId as NVARCHAR(50)) + '' + CHAR(13)
						  + ' AND adj6.intItemUOMId = ' + CAST(@intItemUOMId as NVARCHAR(50)) + '' + CHAR(13)
						  + ' AND adj7.intItemId = ' + CAST(@intItemId as NVARCHAR(50)) + '' + CHAR(13)
						  + ' AND adj2.intItemLocationId = ' + CAST(@intItemLocationId as NVARCHAR(50)) + '' + CHAR(13)
						  + ' AND adj1.intItemPricingId = ' + CAST(@intItemPricingId as NVARCHAR(50)) + '' + CHAR(13)

			INSERT @tblTemp
			EXEC (@SqlQuery1)
		END

		--strVendorId, 
		IF (@strVendorId != '')
		BEGIN
		
			SET @SqlQuery1 = 'SELECT' + CHAR(13)
									+ ' adj5.strLocationName AS strLocation' + CHAR(13)
									+ ', adj6.strUpcCode AS strUpc' + CHAR(13)
									+ ', adj7.strDescription AS strItemDescription' + CHAR(13)
									+ ', ''Vendor Id'' AS strChangeDescription' + CHAR(13)
									+ ', adj9.strVendorId AS strOldData' + CHAR(13)
									+ ', ''' + CAST(@strVendorId AS NVARCHAR(50)) + ''' AS strNewData' + CHAR(13)
						  + ' FROM dbo.tblICItemPricing AS adj1 LEFT OUTER JOIN' + CHAR(13)
							  + ' dbo.tblICItemLocation AS adj2 ON adj1.intItemId = adj2.intItemId AND adj2.intItemLocationId IS NOT NULL LEFT OUTER JOIN' + CHAR(13)
							  + ' dbo.tblSTSubcategory AS adj3 ON adj2.intFamilyId = adj3.intSubcategoryId LEFT OUTER JOIN' + CHAR(13)
							  + ' dbo.tblSTSubcategory AS adj4 ON adj2.intClassId = adj4.intSubcategoryId LEFT OUTER JOIN' + CHAR(13)
							  + ' dbo.tblSMCompanyLocation AS adj5 ON adj2.intLocationId = adj5.intCompanyLocationId LEFT OUTER JOIN' + CHAR(13)
							  + ' dbo.tblICItemUOM AS adj6 ON adj1.intItemId = adj6.intItemId LEFT OUTER JOIN' + CHAR(13)
							  + ' dbo.tblICItem AS adj7 ON adj1.intItemId = adj7.intItemId LEFT OUTER JOIN' + CHAR(13)
							  + ' dbo.tblICCategory AS adj8 ON adj7.intCategoryId = adj8.intCategoryId LEFT OUTER JOIN' + CHAR(13)
							  + ' dbo.tblAPVendor AS adj9 ON adj2.intVendorId = adj9.[intEntityId] LEFT OUTER JOIN' + CHAR(13)
							  + ' dbo.tblICItemVendorXref AS adj10 ON adj2.intItemLocationId = adj10.intItemLocationId LEFT OUTER JOIN' + CHAR(13)
							  + ' dbo.tblEMEntity AS adj11 ON adj11.intEntityId = adj2.intVendorId' + CHAR(13)
						  + ' WHERE adj5.intCompanyLocationId = ' + CAST(@intCompanyLocationId as NVARCHAR(50)) + '' + CHAR(13)
						  + ' AND adj6.intItemUOMId = ' + CAST(@intItemUOMId as NVARCHAR(50)) + '' + CHAR(13)
						  + ' AND adj7.intItemId = ' + CAST(@intItemId as NVARCHAR(50)) + '' + CHAR(13)
						  + ' AND adj2.intItemLocationId = ' + CAST(@intItemLocationId as NVARCHAR(50)) + '' + CHAR(13)
						  + ' AND adj1.intItemPricingId = ' + CAST(@intItemPricingId as NVARCHAR(50)) + '' + CHAR(13)

			INSERT @tblTemp
			EXEC (@SqlQuery1)
		END

		--@intFamilyId, 
		IF (@FamilyId IS NOT NULL AND @FamilyId <> 0)
		BEGIN
		
			DECLARE @strFamily NVARCHAR(50)
			SELECT @strFamily = strSubcategoryId FROM tblSTSubcategory WHERE strSubcategoryType = 'F' AND intSubcategoryId = @FamilyId

			SET @SqlQuery1 = 'SELECT' + CHAR(13)
									+ ' adj5.strLocationName AS strLocation' + CHAR(13)
									+ ', adj6.strUpcCode AS strUpc' + CHAR(13)
									+ ', adj7.strDescription AS strItemDescription' + CHAR(13)
									+ ', ''Family'' AS strChangeDescription' + CHAR(13)
									+ ', adj3.strSubcategoryId AS strOldData' + CHAR(13)
									+ ', ''' + CAST(@strFamily AS NVARCHAR(50)) + ''' AS strNewData' + CHAR(13)
						  + ' FROM dbo.tblICItemPricing AS adj1 LEFT OUTER JOIN' + CHAR(13)
							  + ' dbo.tblICItemLocation AS adj2 ON adj1.intItemId = adj2.intItemId AND adj2.intItemLocationId IS NOT NULL LEFT OUTER JOIN' + CHAR(13)
							  + ' dbo.tblSTSubcategory AS adj3 ON adj2.intFamilyId = adj3.intSubcategoryId LEFT OUTER JOIN' + CHAR(13)
							  + ' dbo.tblSTSubcategory AS adj4 ON adj2.intClassId = adj4.intSubcategoryId LEFT OUTER JOIN' + CHAR(13)
							  + ' dbo.tblSMCompanyLocation AS adj5 ON adj2.intLocationId = adj5.intCompanyLocationId LEFT OUTER JOIN' + CHAR(13)
							  + ' dbo.tblICItemUOM AS adj6 ON adj1.intItemId = adj6.intItemId LEFT OUTER JOIN' + CHAR(13)
							  + ' dbo.tblICItem AS adj7 ON adj1.intItemId = adj7.intItemId LEFT OUTER JOIN' + CHAR(13)
							  + ' dbo.tblICCategory AS adj8 ON adj7.intCategoryId = adj8.intCategoryId LEFT OUTER JOIN' + CHAR(13)
							  + ' dbo.tblAPVendor AS adj9 ON adj2.intVendorId = adj9.[intEntityId] LEFT OUTER JOIN' + CHAR(13)
							  + ' dbo.tblICItemVendorXref AS adj10 ON adj2.intItemLocationId = adj10.intItemLocationId LEFT OUTER JOIN' + CHAR(13)
							  + ' dbo.tblEMEntity AS adj11 ON adj11.intEntityId = adj2.intVendorId' + CHAR(13)
						  + ' WHERE adj5.intCompanyLocationId = ' + CAST(@intCompanyLocationId as NVARCHAR(50)) + '' + CHAR(13)
						  + ' AND adj6.intItemUOMId = ' + CAST(@intItemUOMId as NVARCHAR(50)) + '' + CHAR(13)
						  + ' AND adj7.intItemId = ' + CAST(@intItemId as NVARCHAR(50)) + '' + CHAR(13)
						  + ' AND adj2.intItemLocationId = ' + CAST(@intItemLocationId as NVARCHAR(50)) + '' + CHAR(13)
						  + ' AND adj1.intItemPricingId = ' + CAST(@intItemPricingId as NVARCHAR(50)) + '' + CHAR(13)

			INSERT @tblTemp
			EXEC (@SqlQuery1)
		END

		--@intClassId, 
		IF (@ClassId IS NOT NULL AND @ClassId <> 0)
		BEGIN
		
			DECLARE @strClass NVARCHAR(50)
			SELECT @strClass = strSubcategoryId FROM tblSTSubcategory WHERE strSubcategoryType = 'C' AND intSubcategoryId = @ClassId

			SET @SqlQuery1 = 'SELECT' + CHAR(13)
									+ ' adj5.strLocationName AS strLocation' + CHAR(13)
									+ ', adj6.strUpcCode AS strUpc' + CHAR(13)
									+ ', adj7.strDescription AS strItemDescription' + CHAR(13)
									+ ', ''Class'' AS strChangeDescription' + CHAR(13)
									+ ', adj4.strSubcategoryId AS strOldData' + CHAR(13)
									+ ', ''' + CAST(@strClass AS NVARCHAR(50)) + ''' AS strNewData' + CHAR(13)
						  + ' FROM dbo.tblICItemPricing AS adj1 LEFT OUTER JOIN' + CHAR(13)
							  + ' dbo.tblICItemLocation AS adj2 ON adj1.intItemId = adj2.intItemId AND adj2.intItemLocationId IS NOT NULL LEFT OUTER JOIN' + CHAR(13)
							  + ' dbo.tblSTSubcategory AS adj3 ON adj2.intFamilyId = adj3.intSubcategoryId LEFT OUTER JOIN' + CHAR(13)
							  + ' dbo.tblSTSubcategory AS adj4 ON adj2.intClassId = adj4.intSubcategoryId LEFT OUTER JOIN' + CHAR(13)
							  + ' dbo.tblSMCompanyLocation AS adj5 ON adj2.intLocationId = adj5.intCompanyLocationId LEFT OUTER JOIN' + CHAR(13)
							  + ' dbo.tblICItemUOM AS adj6 ON adj1.intItemId = adj6.intItemId LEFT OUTER JOIN' + CHAR(13)
							  + ' dbo.tblICItem AS adj7 ON adj1.intItemId = adj7.intItemId LEFT OUTER JOIN' + CHAR(13)
							  + ' dbo.tblICCategory AS adj8 ON adj7.intCategoryId = adj8.intCategoryId LEFT OUTER JOIN' + CHAR(13)
							  + ' dbo.tblAPVendor AS adj9 ON adj2.intVendorId = adj9.[intEntityId] LEFT OUTER JOIN' + CHAR(13)
							  + ' dbo.tblICItemVendorXref AS adj10 ON adj2.intItemLocationId = adj10.intItemLocationId LEFT OUTER JOIN' + CHAR(13)
							  + ' dbo.tblEMEntity AS adj11 ON adj11.intEntityId = adj2.intVendorId' + CHAR(13)
						  + ' WHERE adj5.intCompanyLocationId = ' + CAST(@intCompanyLocationId as NVARCHAR(50)) + '' + CHAR(13)
						  + ' AND adj6.intItemUOMId = ' + CAST(@intItemUOMId as NVARCHAR(50)) + '' + CHAR(13)
						  + ' AND adj7.intItemId = ' + CAST(@intItemId as NVARCHAR(50)) + '' + CHAR(13)
						  + ' AND adj2.intItemLocationId = ' + CAST(@intItemLocationId as NVARCHAR(50)) + '' + CHAR(13)
						  + ' AND adj1.intItemPricingId = ' + CAST(@intItemPricingId as NVARCHAR(50)) + '' + CHAR(13)

			INSERT @tblTemp
			EXEC (@SqlQuery1)
		END

		--Remove data
	    DELETE FROM @tblTemp WHERE strOldData = strNewData








		--strDescription
		IF EXISTS (SELECT * FROM @tblTemp WHERE strChangeDescription = 'Description')
		BEGIN
			UPDATE dbo.tblICItem
			SET strDescription = @strDescription
			FROM dbo.tblICItemPricing AS adj1 LEFT OUTER JOIN
				 dbo.tblICItemLocation AS adj2 ON adj1.intItemId = adj2.intItemId AND adj2.intItemLocationId IS NOT NULL LEFT OUTER JOIN
				 dbo.tblSTSubcategory AS adj3 ON adj2.intFamilyId = adj3.intSubcategoryId LEFT OUTER JOIN
				 dbo.tblSTSubcategory AS adj4 ON adj2.intClassId = adj4.intSubcategoryId LEFT OUTER JOIN
				 dbo.tblSMCompanyLocation AS adj5 ON adj2.intLocationId = adj5.intCompanyLocationId LEFT OUTER JOIN
				 dbo.tblICItemUOM AS adj6 ON adj1.intItemId = adj6.intItemId LEFT OUTER JOIN
				 dbo.tblICItem AS adj7 ON adj1.intItemId = adj7.intItemId LEFT OUTER JOIN
				 dbo.tblICCategory AS adj8 ON adj7.intCategoryId = adj8.intCategoryId LEFT OUTER JOIN
				 dbo.tblAPVendor AS adj9 ON adj2.intVendorId = adj9.[intEntityId] LEFT OUTER JOIN
				 dbo.tblICItemVendorXref AS adj10 ON adj2.intItemLocationId = adj10.intItemLocationId
			 WHERE adj5.intCompanyLocationId = @intCompanyLocationId
			 AND adj6.intItemUOMId = @intItemUOMId
			 AND adj7.intItemId = @intItemId
			 AND adj2.intItemLocationId = @intItemLocationId
			 AND adj1.intItemPricingId = @intItemPricingId

			 
			 ----SET @changeDescription = 'Updated - Record: ' + cast(@intUniqueId as nvarchar) + '';
			 ----SET @children = '{"change":"strDescription","from":' + @oldData + ',"to":"' + @strDescription + '","leaf":true,"iconCls":"small-gear","isField":true,"keyValue":' + CAST(@intUniqueId AS NVARCHAR(10)) + ',"changeDescription":"Description","hidden":false}'
			 ----exec uspSMAuditLog 'Store.view.InventoryMassMaintenance', @intUniqueId, @intEntityId, 'Updated', 'small-tree-modified', 'Description', @oldData, @strDescription, ''

			 ----INSERT to AuditLog
			 --INSERT INTO tblSMAuditLog(strActionType, strTransactionType, strRecordNo, strDescription, strRoute, strJsonData, dtmDate, intEntityId, intConcurrencyId)
			 --VALUES(
				--		'Updated'
				--		, 'Store.view.InventoryMassMaintenance'
				--		, @intUniqueId
				--		, ''
				--		, null
				--		, '{"action":"Updated","change":"Updated - Record: 1158","iconCls":"small-tree-modified","children":[{"change":"Description","iconCls":"small-gear","from":"' + @oldData + '","to":"' + @strDescription + '","leaf":true}]}'
				--		, GETUTCDATE()
				--		, 1
				--		, 1
			 --)

			 --Constract child
			 SELECT @oldData = strOldData, @newData = strNewData FROM @tblTemp WHERE strChangeDescription = 'Description'
			 SET @children = '{"change":"Description","iconCls":"small-gear","from":"' + @oldData + '","to":"' + @newData + '","leaf":true},'
		END
		


		 --intCategoryId
		 IF EXISTS (SELECT * FROM @tblTemp WHERE strChangeDescription = 'Category')
		BEGIN
			UPDATE dbo.tblICItem
			SET intCategoryId = @intCategoryId
			FROM dbo.tblICItemPricing AS adj1 LEFT OUTER JOIN
				 dbo.tblICItemLocation AS adj2 ON adj1.intItemId = adj2.intItemId AND adj2.intItemLocationId IS NOT NULL LEFT OUTER JOIN
				 dbo.tblSTSubcategory AS adj3 ON adj2.intFamilyId = adj3.intSubcategoryId LEFT OUTER JOIN
				 dbo.tblSTSubcategory AS adj4 ON adj2.intClassId = adj4.intSubcategoryId LEFT OUTER JOIN
				 dbo.tblSMCompanyLocation AS adj5 ON adj2.intLocationId = adj5.intCompanyLocationId LEFT OUTER JOIN
				 dbo.tblICItemUOM AS adj6 ON adj1.intItemId = adj6.intItemId LEFT OUTER JOIN
				 dbo.tblICItem AS adj7 ON adj1.intItemId = adj7.intItemId LEFT OUTER JOIN
				 dbo.tblICCategory AS adj8 ON adj7.intCategoryId = adj8.intCategoryId LEFT OUTER JOIN
				 dbo.tblAPVendor AS adj9 ON adj2.intVendorId = adj9.[intEntityId] LEFT OUTER JOIN
				 dbo.tblICItemVendorXref AS adj10 ON adj2.intItemLocationId = adj10.intItemLocationId
			 WHERE adj5.intCompanyLocationId = @intCompanyLocationId
			 AND adj6.intItemUOMId = @intItemUOMId
			 AND adj7.intItemId = @intItemId
			 AND adj2.intItemLocationId = @intItemLocationId
			 AND adj1.intItemPricingId = @intItemPricingId

			 ----INSERT to AuditLog
			 --SELECT @oldData = strOldData, @newData = strNewData FROM @tblTemp WHERE strChangeDescription = 'Category'
			 --INSERT INTO tblSMAuditLog(strActionType, strTransactionType, strRecordNo, strDescription, strRoute, strJsonData, dtmDate, intEntityId, intConcurrencyId)
			 --VALUES(
				--		'Updated'
				--		, 'Store.view.InventoryMassMaintenance'
				--		, @intUniqueId
				--		, ''
				--		, null
				--		, '{"action":"Updated","change":"Updated - Record: 1158","iconCls":"small-tree-modified","children":[{"change":"Category","iconCls":"small-gear","from":"' + @oldData + '","to":"' + @newData + '","leaf":true}]}'
				--		, GETUTCDATE()
				--		, 1
				--		, 1
			 --)

			 --Constract child
			 SELECT @oldData = strOldData, @newData = strNewData FROM @tblTemp WHERE strChangeDescription = 'Category'
			 SET @children = @children + '{"change":"Category","iconCls":"small-gear","from":"' + @oldData + '","to":"' + @newData + '","leaf":true},'
		END
		


		 --@PosDescription
		 IF EXISTS (SELECT * FROM @tblTemp WHERE strChangeDescription = 'Pos Description')
		BEGIN
			UPDATE dbo.tblICItemLocation
			SET strDescription = @PosDescription
			FROM dbo.tblICItemPricing AS adj1 LEFT OUTER JOIN
				 dbo.tblICItemLocation AS adj2 ON adj1.intItemId = adj2.intItemId AND adj2.intItemLocationId IS NOT NULL LEFT OUTER JOIN
				 dbo.tblSTSubcategory AS adj3 ON adj2.intFamilyId = adj3.intSubcategoryId LEFT OUTER JOIN
				 dbo.tblSTSubcategory AS adj4 ON adj2.intClassId = adj4.intSubcategoryId LEFT OUTER JOIN
				 dbo.tblSMCompanyLocation AS adj5 ON adj2.intLocationId = adj5.intCompanyLocationId LEFT OUTER JOIN
				 dbo.tblICItemUOM AS adj6 ON adj1.intItemId = adj6.intItemId LEFT OUTER JOIN
				 dbo.tblICItem AS adj7 ON adj1.intItemId = adj7.intItemId LEFT OUTER JOIN
				 dbo.tblICCategory AS adj8 ON adj7.intCategoryId = adj8.intCategoryId LEFT OUTER JOIN
				 dbo.tblAPVendor AS adj9 ON adj2.intVendorId = adj9.[intEntityId] LEFT OUTER JOIN
				 dbo.tblICItemVendorXref AS adj10 ON adj2.intItemLocationId = adj10.intItemLocationId
			 WHERE adj5.intCompanyLocationId = @intCompanyLocationId
			 AND adj6.intItemUOMId = @intItemUOMId
			 AND adj7.intItemId = @intItemId
			 AND adj2.intItemLocationId = @intItemLocationId
			 AND adj1.intItemPricingId = @intItemPricingId

			 ----INSERT to AuditLog
			 --SELECT @oldData = strOldData, @newData = strNewData FROM @tblTemp WHERE strChangeDescription = 'Pos Description'
			 --INSERT INTO tblSMAuditLog(strActionType, strTransactionType, strRecordNo, strDescription, strRoute, strJsonData, dtmDate, intEntityId, intConcurrencyId)
			 --VALUES(
				--		'Updated'
				--		, 'Store.view.InventoryMassMaintenance'
				--		, @intUniqueId
				--		, ''
				--		, null
				--		, '{"action":"Updated","change":"Updated - Record: 1158","iconCls":"small-tree-modified","children":[{"change":"Pos Description","iconCls":"small-gear","from":"' + @oldData + '","to":"' + @newData + '","leaf":true}]}'
				--		, GETUTCDATE()
				--		, 1
				--		, 1
			 --)

			 --Constract child
			 SELECT @oldData = strOldData, @newData = strNewData FROM @tblTemp WHERE strChangeDescription = 'Pos Description'
			 SET @children = @children + '{"change":"Pos Description","iconCls":"small-gear","from":"' + @oldData + '","to":"' + @newData + '","leaf":true},'
		END
		

		--intVendorId
		 IF EXISTS (SELECT * FROM @tblTemp WHERE strChangeDescription = 'Vendor')
		BEGIN
			IF(@intEntityVendorId IS NOT NULL AND @intEntityVendorId <> 0)
			BEGIN
			UPDATE dbo.tblICItemLocation
			SET intVendorId = @intEntityVendorId
			FROM dbo.tblICItemPricing AS adj1 LEFT OUTER JOIN
				 dbo.tblICItemLocation AS adj2 ON adj1.intItemId = adj2.intItemId AND adj2.intItemLocationId IS NOT NULL LEFT OUTER JOIN
				 dbo.tblSTSubcategory AS adj3 ON adj2.intFamilyId = adj3.intSubcategoryId LEFT OUTER JOIN
				 dbo.tblSTSubcategory AS adj4 ON adj2.intClassId = adj4.intSubcategoryId LEFT OUTER JOIN
				 dbo.tblSMCompanyLocation AS adj5 ON adj2.intLocationId = adj5.intCompanyLocationId LEFT OUTER JOIN
				 dbo.tblICItemUOM AS adj6 ON adj1.intItemId = adj6.intItemId LEFT OUTER JOIN
				 dbo.tblICItem AS adj7 ON adj1.intItemId = adj7.intItemId LEFT OUTER JOIN
				 dbo.tblICCategory AS adj8 ON adj7.intCategoryId = adj8.intCategoryId LEFT OUTER JOIN
				 dbo.tblAPVendor AS adj9 ON adj2.intVendorId = adj9.[intEntityId] LEFT OUTER JOIN
				 dbo.tblICItemVendorXref AS adj10 ON adj2.intItemLocationId = adj10.intItemLocationId
			 WHERE adj5.intCompanyLocationId = @intCompanyLocationId
			 AND adj6.intItemUOMId = @intItemUOMId
			 AND adj7.intItemId = @intItemId
			 AND adj2.intItemLocationId = @intItemLocationId
			 AND adj1.intItemPricingId = @intItemPricingId

			 ----INSERT to AuditLog
			 --SELECT @oldData = strOldData, @newData = strNewData FROM @tblTemp WHERE strChangeDescription = 'Vendor'
			 --INSERT INTO tblSMAuditLog(strActionType, strTransactionType, strRecordNo, strDescription, strRoute, strJsonData, dtmDate, intEntityId, intConcurrencyId)
			 --VALUES(
				--		'Updated'
				--		, 'Store.view.InventoryMassMaintenance'
				--		, @intUniqueId
				--		, ''
				--		, null
				--		, '{"action":"Updated","change":"Updated - Record: 1158","iconCls":"small-tree-modified","children":[{"change":"Vendor","iconCls":"small-gear","from":"' + @oldData + '","to":"' + @newData + '","leaf":true}]}'
				--		, GETUTCDATE()
				--		, 1
				--		, 1
			 --)

			 --Constract child
			 SELECT @oldData = strOldData, @newData = strNewData FROM @tblTemp WHERE strChangeDescription = 'Vendor'
			 SET @children = @children + '{"change":"Vendor","iconCls":"small-gear","from":"' + @oldData + '","to":"' + @newData + '","leaf":true},'

			END
		END
		
		

		--dblSalePrice
		 IF EXISTS (SELECT * FROM @tblTemp WHERE strChangeDescription = 'Sale Price')
		BEGIN
			UPDATE dbo.tblICItemPricing
			SET dblSalePrice = @dblSalePrice
			FROM dbo.tblICItemPricing AS adj1 LEFT OUTER JOIN
				 dbo.tblICItemLocation AS adj2 ON adj1.intItemId = adj2.intItemId AND adj2.intItemLocationId IS NOT NULL LEFT OUTER JOIN
				 dbo.tblSTSubcategory AS adj3 ON adj2.intFamilyId = adj3.intSubcategoryId LEFT OUTER JOIN
				 dbo.tblSTSubcategory AS adj4 ON adj2.intClassId = adj4.intSubcategoryId LEFT OUTER JOIN
				 dbo.tblSMCompanyLocation AS adj5 ON adj2.intLocationId = adj5.intCompanyLocationId LEFT OUTER JOIN
				 dbo.tblICItemUOM AS adj6 ON adj1.intItemId = adj6.intItemId LEFT OUTER JOIN
				 dbo.tblICItem AS adj7 ON adj1.intItemId = adj7.intItemId LEFT OUTER JOIN
				 dbo.tblICCategory AS adj8 ON adj7.intCategoryId = adj8.intCategoryId LEFT OUTER JOIN
				 dbo.tblAPVendor AS adj9 ON adj2.intVendorId = adj9.[intEntityId] LEFT OUTER JOIN
				 dbo.tblICItemVendorXref AS adj10 ON adj2.intItemLocationId = adj10.intItemLocationId
			 WHERE adj5.intCompanyLocationId = @intCompanyLocationId
			 AND adj6.intItemUOMId = @intItemUOMId
			 AND adj7.intItemId = @intItemId
			 AND adj2.intItemLocationId = @intItemLocationId
			 AND adj1.intItemPricingId = @intItemPricingId

			 ----INSERT to AuditLog
			 --SELECT @oldData = strOldData, @newData = strNewData FROM @tblTemp WHERE strChangeDescription = 'Sale Price'
			 --INSERT INTO tblSMAuditLog(strActionType, strTransactionType, strRecordNo, strDescription, strRoute, strJsonData, dtmDate, intEntityId, intConcurrencyId)
			 --VALUES(
				--		'Updated'
				--		, 'Store.view.InventoryMassMaintenance'
				--		, @intUniqueId
				--		, ''
				--		, null
				--		, '{"action":"Updated","change":"Updated - Record: 1158","iconCls":"small-tree-modified","children":[{"change":"Sale Price","iconCls":"small-gear","from":"' + @oldData + '","to":"' + @newData + '","leaf":true}]}'
				--		, GETUTCDATE()
				--		, 1
				--		, 1
			 --)

			 --Constract child
			 SELECT @oldData = strOldData, @newData = strNewData FROM @tblTemp WHERE strChangeDescription = 'Sale Price'
			 SET @children = @children + '{"change":"Sale Price","iconCls":"small-gear","from":"' + @oldData + '","to":"' + @newData + '","leaf":true},'

		END
		



		--dblLastCost
		IF EXISTS (SELECT * FROM @tblTemp WHERE strChangeDescription = 'Last Cost')
		BEGIN
			UPDATE dbo.tblICItemPricing
			SET dblLastCost = @dblLastCost
			FROM dbo.tblICItemPricing AS adj1 LEFT OUTER JOIN
				 dbo.tblICItemLocation AS adj2 ON adj1.intItemId = adj2.intItemId AND adj2.intItemLocationId IS NOT NULL LEFT OUTER JOIN
				 dbo.tblSTSubcategory AS adj3 ON adj2.intFamilyId = adj3.intSubcategoryId LEFT OUTER JOIN
				 dbo.tblSTSubcategory AS adj4 ON adj2.intClassId = adj4.intSubcategoryId LEFT OUTER JOIN
				 dbo.tblSMCompanyLocation AS adj5 ON adj2.intLocationId = adj5.intCompanyLocationId LEFT OUTER JOIN
				 dbo.tblICItemUOM AS adj6 ON adj1.intItemId = adj6.intItemId LEFT OUTER JOIN
				 dbo.tblICItem AS adj7 ON adj1.intItemId = adj7.intItemId LEFT OUTER JOIN
				 dbo.tblICCategory AS adj8 ON adj7.intCategoryId = adj8.intCategoryId LEFT OUTER JOIN
				 dbo.tblAPVendor AS adj9 ON adj2.intVendorId = adj9.[intEntityId] LEFT OUTER JOIN
				 dbo.tblICItemVendorXref AS adj10 ON adj2.intItemLocationId = adj10.intItemLocationId
			 WHERE adj5.intCompanyLocationId = @intCompanyLocationId
			 AND adj6.intItemUOMId = @intItemUOMId
			 AND adj7.intItemId = @intItemId
			 AND adj2.intItemLocationId = @intItemLocationId
			 AND adj1.intItemPricingId = @intItemPricingId

			 ----INSERT to AuditLog
			 --SELECT @oldData = strOldData, @newData = strNewData FROM @tblTemp WHERE strChangeDescription = 'Last Cost'
			 --INSERT INTO tblSMAuditLog(strActionType, strTransactionType, strRecordNo, strDescription, strRoute, strJsonData, dtmDate, intEntityId, intConcurrencyId)
			 --VALUES(
				--		'Updated'
				--		, 'Store.view.InventoryMassMaintenance'
				--		, @intUniqueId
				--		, ''
				--		, null
				--		, '{"action":"Updated","change":"Updated - Record: 1158","iconCls":"small-tree-modified","children":[{"change":"Last Cost","iconCls":"small-gear","from":"' + @oldData + '","to":"' + @newData + '","leaf":true}]}'
				--		, GETUTCDATE()
				--		, 1
				--		, 1
			 --)

			 --Constract child
			 SELECT @oldData = strOldData, @newData = strNewData FROM @tblTemp WHERE strChangeDescription = 'Last Cost'
			 SET @children = @children + '{"change":"Last Cost","iconCls":"small-gear","from":"' + @oldData + '","to":"' + @newData + '","leaf":true},'

		END
		



		--strVendorId
		IF EXISTS (SELECT * FROM @tblTemp WHERE strChangeDescription = 'Vendor Id')
		BEGIN
			UPDATE dbo.tblAPVendor
			SET strVendorId = @strVendorId
			FROM dbo.tblICItemPricing AS adj1 LEFT OUTER JOIN
				 dbo.tblICItemLocation AS adj2 ON adj1.intItemId = adj2.intItemId AND adj2.intItemLocationId IS NOT NULL LEFT OUTER JOIN
				 dbo.tblSTSubcategory AS adj3 ON adj2.intFamilyId = adj3.intSubcategoryId LEFT OUTER JOIN
				 dbo.tblSTSubcategory AS adj4 ON adj2.intClassId = adj4.intSubcategoryId LEFT OUTER JOIN
				 dbo.tblSMCompanyLocation AS adj5 ON adj2.intLocationId = adj5.intCompanyLocationId LEFT OUTER JOIN
				 dbo.tblICItemUOM AS adj6 ON adj1.intItemId = adj6.intItemId LEFT OUTER JOIN
				 dbo.tblICItem AS adj7 ON adj1.intItemId = adj7.intItemId LEFT OUTER JOIN
				 dbo.tblICCategory AS adj8 ON adj7.intCategoryId = adj8.intCategoryId LEFT OUTER JOIN
				 dbo.tblAPVendor AS adj9 ON adj2.intVendorId = adj9.[intEntityId] LEFT OUTER JOIN
				 dbo.tblICItemVendorXref AS adj10 ON adj2.intItemLocationId = adj10.intItemLocationId
			 WHERE adj5.intCompanyLocationId = @intCompanyLocationId
			 AND adj6.intItemUOMId = @intItemUOMId
			 AND adj7.intItemId = @intItemId
			 AND adj2.intItemLocationId = @intItemLocationId
			 AND adj1.intItemPricingId = @intItemPricingId

			 ----INSERT to AuditLog
			 --SELECT @oldData = strOldData, @newData = strNewData FROM @tblTemp WHERE strChangeDescription = 'Vendor Id'
			 --INSERT INTO tblSMAuditLog(strActionType, strTransactionType, strRecordNo, strDescription, strRoute, strJsonData, dtmDate, intEntityId, intConcurrencyId)
			 --VALUES(
				--		'Updated'
				--		, 'Store.view.InventoryMassMaintenance'
				--		, @intUniqueId
				--		, ''
				--		, null
				--		, '{"action":"Updated","change":"Updated - Record: 1158","iconCls":"small-tree-modified","children":[{"change":"Vendor Id","iconCls":"small-gear","from":"' + @oldData + '","to":"' + @newData + '","leaf":true}]}'
				--		, GETUTCDATE()
				--		, 1
				--		, 1
			 --)

			 --Constract child
			 SELECT @oldData = strOldData, @newData = strNewData FROM @tblTemp WHERE strChangeDescription = 'Vendor Id'
			 SET @children = @children + '{"change":"Vendor Id","iconCls":"small-gear","from":"' + @oldData + '","to":"' + @newData + '","leaf":true},'

		END
		

		

		--FamilyId
		IF EXISTS (SELECT * FROM @tblTemp WHERE strChangeDescription = 'Family')
		BEGIN
			IF(@FamilyId IS NOT NULL AND @FamilyId <> 0)
			BEGIN
				UPDATE dbo.tblICItemLocation
				SET intFamilyId = @FamilyId
				FROM dbo.tblICItemPricing AS adj1 LEFT OUTER JOIN
					 dbo.tblICItemLocation AS adj2 ON adj1.intItemId = adj2.intItemId AND adj2.intItemLocationId IS NOT NULL LEFT OUTER JOIN
					 dbo.tblSTSubcategory AS adj3 ON adj2.intFamilyId = adj3.intSubcategoryId LEFT OUTER JOIN
					 dbo.tblSTSubcategory AS adj4 ON adj2.intClassId = adj4.intSubcategoryId LEFT OUTER JOIN
					 dbo.tblSMCompanyLocation AS adj5 ON adj2.intLocationId = adj5.intCompanyLocationId LEFT OUTER JOIN
					 dbo.tblICItemUOM AS adj6 ON adj1.intItemId = adj6.intItemId LEFT OUTER JOIN
					 dbo.tblICItem AS adj7 ON adj1.intItemId = adj7.intItemId LEFT OUTER JOIN
					 dbo.tblICCategory AS adj8 ON adj7.intCategoryId = adj8.intCategoryId LEFT OUTER JOIN
					 dbo.tblAPVendor AS adj9 ON adj2.intVendorId = adj9.[intEntityId] LEFT OUTER JOIN
					 dbo.tblICItemVendorXref AS adj10 ON adj2.intItemLocationId = adj10.intItemLocationId
				 WHERE adj5.intCompanyLocationId = @intCompanyLocationId
				 AND adj6.intItemUOMId = @intItemUOMId
				 AND adj7.intItemId = @intItemId
				 AND adj2.intItemLocationId = @intItemLocationId
				 AND adj1.intItemPricingId = @intItemPricingId
			END
		

			--Family
			IF(@Family <> '' AND @FamilyId IS NOT NULL AND @FamilyId <> 0)
			BEGIN
				UPDATE dbo.tblSTSubcategory
				SET strSubcategoryId = @Family
				FROM dbo.tblICItemPricing AS adj1 LEFT OUTER JOIN
					 dbo.tblICItemLocation AS adj2 ON adj1.intItemId = adj2.intItemId AND adj2.intItemLocationId IS NOT NULL LEFT OUTER JOIN
					 dbo.tblSTSubcategory AS adj3 ON adj2.intFamilyId = adj3.intSubcategoryId LEFT OUTER JOIN
					 --dbo.tblSTSubcategory AS adj4 ON adj2.intClassId = adj4.intSubcategoryId LEFT OUTER JOIN
					 dbo.tblSMCompanyLocation AS adj5 ON adj2.intLocationId = adj5.intCompanyLocationId LEFT OUTER JOIN
					 dbo.tblICItemUOM AS adj6 ON adj1.intItemId = adj6.intItemId LEFT OUTER JOIN
					 dbo.tblICItem AS adj7 ON adj1.intItemId = adj7.intItemId LEFT OUTER JOIN
					 dbo.tblICCategory AS adj8 ON adj7.intCategoryId = adj8.intCategoryId LEFT OUTER JOIN
					 dbo.tblAPVendor AS adj9 ON adj2.intVendorId = adj9.[intEntityId] LEFT OUTER JOIN
					 dbo.tblICItemVendorXref AS adj10 ON adj2.intItemLocationId = adj10.intItemLocationId
				 WHERE adj5.intCompanyLocationId = @intCompanyLocationId
				 AND adj6.intItemUOMId = @intItemUOMId
				 AND adj7.intItemId = @intItemId
				 AND adj2.intItemLocationId = @intItemLocationId
				 AND adj1.intItemPricingId = @intItemPricingId
				 AND strSubcategoryType = 'F'
				 AND intSubcategoryId = @FamilyId
			END


			----INSERT to AuditLog
			-- SELECT @oldData = strOldData, @newData = strNewData FROM @tblTemp WHERE strChangeDescription = 'Family'
			-- INSERT INTO tblSMAuditLog(strActionType, strTransactionType, strRecordNo, strDescription, strRoute, strJsonData, dtmDate, intEntityId, intConcurrencyId)
			-- VALUES(
			--			'Updated'
			--			, 'Store.view.InventoryMassMaintenance'
			--			, @intUniqueId
			--			, ''
			--			, null
			--			, '{"action":"Updated","change":"Updated - Record: 1158","iconCls":"small-tree-modified","children":[{"change":"Family","iconCls":"small-gear","from":"' + @oldData + '","to":"' + @newData + '","leaf":true}]}'
			--			, GETUTCDATE()
			--			, 1
			--			, 1
			-- )

			--Constract child
			 SELECT @oldData = strOldData, @newData = strNewData FROM @tblTemp WHERE strChangeDescription = 'Family'
			 SET @children = @children + '{"change":"Family","iconCls":"small-gear","from":"' + @oldData + '","to":"' + @newData + '","leaf":true},'

		END
		
		

		--ClassId
		IF EXISTS (SELECT * FROM @tblTemp WHERE strChangeDescription = 'Class')
		BEGIN
			IF(@ClassId IS NOT NULL AND @ClassId <> 0)
			BEGIN
				UPDATE dbo.tblICItemLocation
				SET intClassId = @ClassId
				FROM dbo.tblICItemPricing AS adj1 LEFT OUTER JOIN
					 dbo.tblICItemLocation AS adj2 ON adj1.intItemId = adj2.intItemId AND adj2.intItemLocationId IS NOT NULL LEFT OUTER JOIN
					 dbo.tblSTSubcategory AS adj3 ON adj2.intFamilyId = adj3.intSubcategoryId LEFT OUTER JOIN
					 dbo.tblSTSubcategory AS adj4 ON adj2.intClassId = adj4.intSubcategoryId LEFT OUTER JOIN
					 dbo.tblSMCompanyLocation AS adj5 ON adj2.intLocationId = adj5.intCompanyLocationId LEFT OUTER JOIN
					 dbo.tblICItemUOM AS adj6 ON adj1.intItemId = adj6.intItemId LEFT OUTER JOIN
					 dbo.tblICItem AS adj7 ON adj1.intItemId = adj7.intItemId LEFT OUTER JOIN
					 dbo.tblICCategory AS adj8 ON adj7.intCategoryId = adj8.intCategoryId LEFT OUTER JOIN
					 dbo.tblAPVendor AS adj9 ON adj2.intVendorId = adj9.[intEntityId] LEFT OUTER JOIN
					 dbo.tblICItemVendorXref AS adj10 ON adj2.intItemLocationId = adj10.intItemLocationId
				 WHERE adj5.intCompanyLocationId = @intCompanyLocationId
				 AND adj6.intItemUOMId = @intItemUOMId
				 AND adj7.intItemId = @intItemId
				 AND adj2.intItemLocationId = @intItemLocationId
				 AND adj1.intItemPricingId = @intItemPricingId
			END
		

			 --Class
			IF(@Class <> '' AND @ClassId IS NOT NULL AND @ClassId <> 0)
			BEGIN
				UPDATE dbo.tblSTSubcategory
				SET strSubcategoryId = @Class
				FROM dbo.tblICItemPricing AS adj1 LEFT OUTER JOIN
					 dbo.tblICItemLocation AS adj2 ON adj1.intItemId = adj2.intItemId AND adj2.intItemLocationId IS NOT NULL LEFT OUTER JOIN
					 --dbo.tblSTSubcategory AS adj3 ON adj2.intFamilyId = adj3.intSubcategoryId LEFT OUTER JOIN
					 dbo.tblSTSubcategory AS adj4 ON adj2.intClassId = adj4.intSubcategoryId LEFT OUTER JOIN
					 dbo.tblSMCompanyLocation AS adj5 ON adj2.intLocationId = adj5.intCompanyLocationId LEFT OUTER JOIN
					 dbo.tblICItemUOM AS adj6 ON adj1.intItemId = adj6.intItemId LEFT OUTER JOIN
					 dbo.tblICItem AS adj7 ON adj1.intItemId = adj7.intItemId LEFT OUTER JOIN
					 dbo.tblICCategory AS adj8 ON adj7.intCategoryId = adj8.intCategoryId LEFT OUTER JOIN
					 dbo.tblAPVendor AS adj9 ON adj2.intVendorId = adj9.[intEntityId] LEFT OUTER JOIN
					 dbo.tblICItemVendorXref AS adj10 ON adj2.intItemLocationId = adj10.intItemLocationId
				 WHERE adj5.intCompanyLocationId = @intCompanyLocationId
				 AND adj6.intItemUOMId = @intItemUOMId
				 AND adj7.intItemId = @intItemId
				 AND adj2.intItemLocationId = @intItemLocationId
				 AND adj1.intItemPricingId = @intItemPricingId
				 AND strSubcategoryType = 'C'
				 AND intSubcategoryId = @ClassId
			END

			--Constract child
			 SELECT @oldData = strOldData, @newData = strNewData FROM @tblTemp WHERE strChangeDescription = 'Class'
			 SET @children = @children + '{"change":"Class","iconCls":"small-gear","from":"' + @oldData + '","to":"' + @newData + '","leaf":true},'

		END
		

		--CHECK if temTable has record
		DECLARE @countRecord INT
		SELECT @countRecord = COUNT(*) from @tblTemp


		IF(@countRecord >= 1)
		BEGIN

			--INSERT to AuditLog
			--IF NOT EXISTS (SELECT * FROM tblSMAuditLog WHERE strActionType = 'Created' AND strTransactionType = 'Store.view.InventoryMassMaintenance' AND strRecordNo = @intUniqueId)
			--BEGIN
			--	 INSERT INTO tblSMAuditLog(strActionType, strTransactionType, strRecordNo, strDescription, strRoute, strJsonData, dtmDate, intEntityId, intConcurrencyId)
			--	 VALUES(
			--				'Created'
			--				, 'Store.view.InventoryMassMaintenance'
			--				, @intUniqueId
			--				, ''
			--				, '#/ST/InventoryMassMaintenance/SearchInventoryMassMaintenance?action=edit&filters%5B0%5D%5Bcolumn%5D=intUniqueId&filters%5B0%5D%5Bvalue%5D=' + CAST(@intUniqueId AS NVARCHAR(50)) + '&activeTab=Audit%20Log&searchTab=InventoryMassMaintenance&searchCommand=SearchInventoryMassMaintenance'
			--				, '{"action":"Created","change":"Created - Record: ' + CAST(@intUniqueId AS NVARCHAR(50)) + '","keyValue":' + CAST(@intUniqueId AS NVARCHAR(50)) + ', "iconCls":"small-new-plus","leaf":true}'
			--				, GETUTCDATE()
			--				, @intEntityId
			--				, 1
			--	 )
			--END

			--DECLARE @intAuditLogId INT
			--SET @intAuditLogId = 0
			--IF EXISTS (SELECT * FROM tblSMAuditLog WHERE strActionType = '' AND strJsonData = '{}' AND strTransactionType = 'Store.view.InventoryMassMaintenance' AND strRecordNo = @intUniqueId)
			--BEGIN
				 
			--	 SELECT @intAuditLogId = intAuditLogId FROM tblSMAuditLog WHERE strActionType = '' AND strJsonData = '{}' AND strTransactionType = 'Store.view.InventoryMassMaintenance' AND strRecordNo = @intUniqueId

			--	 UPDATE tblSMAuditLog
			--	 SET strActionType = 'Created'
			--	     , strJsonData = '{"action":"Created","change":"Created - Record: ' + CAST(@intUniqueId AS NVARCHAR(50)) + '","keyValue":' + CAST(@intUniqueId AS NVARCHAR(50)) + ', "iconCls":"small-new-plus","leaf":true}'
			--	 WHERE intAuditLogId = @intAuditLogId

			--END


			--Remove last character comma(,)
			SET @children = left(@children, len(@children)-1)

			--INSERT changes
			SELECT @oldData = strOldData, @newData = strNewData FROM @tblTemp WHERE strChangeDescription = 'Class'
			INSERT INTO tblSMAuditLog(strActionType, strTransactionType, strRecordNo, strDescription, strRoute, strJsonData, dtmDate, intEntityId, intConcurrencyId)
			VALUES(
					'Updated'
					, 'Store.view.InventoryMassMaintenance'
					, @intUniqueId
					, ''
					, '#/ST/InventoryMassMaintenance/SearchInventoryMassMaintenance?action=edit&filters%5B0%5D%5Bcolumn%5D=intUniqueId&filters%5B0%5D%5Bvalue%5D=' + CAST(@intUniqueId AS NVARCHAR(50)) + '&activeTab=Audit%20Log&searchTab=InventoryMassMaintenance&searchCommand=SearchInventoryMassMaintenance'
					, '{"action":"Updated","change":"Updated - Record: 1158","iconCls":"small-tree-modified","children":[' + @children + ']}'
					, GETUTCDATE()
					, @intEntityId
					, 1
			)
			 
		END


		 SET @strStatusMsg = 'Success'
	 END
END