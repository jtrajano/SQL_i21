CREATE PROCEDURE [dbo].[uspSTReportInventoryMassMaintenancePreview]
	@intCompanyLocationId INT
	, @intItemUOMId INT
	, @intItemId INT
	, @intItemLocationId INT
	, @intItemPricingId INT

	, @intEntityId INT
	, @strVendorProduct NVARCHAR(250)
	, @strDescription NVARCHAR(250)
	, @strPosDescription NVARCHAR(250)
	, @dblSalePrice DECIMAL(18, 6)
	, @dblLastCost DECIMAL(18, 6)

	, @intCategoryId INT
	, @intFamilyId INT
	, @intClassId INT
AS

BEGIN TRY

	DECLARE @ErrMsg NVARCHAR(MAX)

   --Declare UpdatePreview holder
   DECLARE @tblInventoryMassMaintenancePreview TABLE 
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

	DECLARE @strVendorId NVARCHAR(100)
	SET @strVendorId = ''

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

		INSERT @tblInventoryMassMaintenancePreview
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

		INSERT @tblInventoryMassMaintenancePreview
		EXEC (@SqlQuery1)
	END

	--intEntityId
	IF (@intEntityId IS NOT NULL AND @intEntityId <> 0)
	BEGIN
		
		DECLARE @strVendorName NVARCHAR(100)
		SELECT @strVendorName = strName FROM tblEMEntity WHERE intEntityId = @intEntityId
		
		SELECT @strVendorId = strVendorId FROM tblAPVendor WHERE intEntityId = @intEntityId

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

		INSERT @tblInventoryMassMaintenancePreview
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
								--+ ', adj1.dblSalePrice AS strOldData' + CHAR(13)
								--+ ', ''' + CAST(@dblSalePrice AS NVARCHAR(50)) + ''' AS strNewData' + CHAR(13)
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

		INSERT @tblInventoryMassMaintenancePreview
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
								--+ ', adj1.dblLastCost AS strOldData' + CHAR(13)
								--+ ', ''' + CAST(@dblLastCost AS NVARCHAR(50)) + ''' AS strNewData' + CHAR(13)
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

		INSERT @tblInventoryMassMaintenancePreview
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

		INSERT @tblInventoryMassMaintenancePreview
		EXEC (@SqlQuery1)
	END

	--@intFamilyId, 
	IF (@intFamilyId IS NOT NULL AND @intFamilyId <> 0)
	BEGIN
		
		DECLARE @strFamily NVARCHAR(50)
		SELECT @strFamily = strSubcategoryId FROM tblSTSubcategory WHERE strSubcategoryType = 'F' AND intSubcategoryId = @intFamilyId

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

		INSERT @tblInventoryMassMaintenancePreview
		EXEC (@SqlQuery1)
	END

	--@intClassId, 
	IF (@intClassId IS NOT NULL AND @intClassId <> 0)
	BEGIN
		
		DECLARE @strClass NVARCHAR(50)
		SELECT @strClass = strSubcategoryId FROM tblSTSubcategory WHERE strSubcategoryType = 'C' AND intSubcategoryId = @intClassId

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

		INSERT @tblInventoryMassMaintenancePreview
		EXEC (@SqlQuery1)
	END




   select strLocation
		  , strUpc
		  , strItemDescription
		  , strChangeDescription
		  , strOldData
		  , strNewData
   from @tblInventoryMassMaintenancePreview
    
   DELETE FROM @tblInventoryMassMaintenancePreview
END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
END CATCH