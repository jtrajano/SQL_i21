CREATE PROCEDURE [dbo].[uspSTReportInventoryMassMaintenancePreview]
	@intItemUOMId INT
	, @intItemId INT
	, @intItemLocationId INT
	, @intItemPricingId INT

	, @intEntityVendorId INT
	, @intItemVendorXrefId INT
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

	DECLARE @VendorXrefCount INT
	SET @VendorXrefCount = 0

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
					  --+ ' WHERE adj5.intCompanyLocationId = ' + CAST(@intCompanyLocationId as NVARCHAR(50)) + '' + CHAR(13)
					  + ' WHERE adj6.intItemUOMId = ' + CAST(@intItemUOMId as NVARCHAR(50)) + '' + CHAR(13)
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
					  --+ ' WHERE adj5.intCompanyLocationId = ' + CAST(@intCompanyLocationId as NVARCHAR(50)) + '' + CHAR(13)
					  + ' WHERE adj6.intItemUOMId = ' + CAST(@intItemUOMId as NVARCHAR(50)) + '' + CHAR(13)
					  + ' AND adj7.intItemId = ' + CAST(@intItemId as NVARCHAR(50)) + '' + CHAR(13)
					  + ' AND adj2.intItemLocationId = ' + CAST(@intItemLocationId as NVARCHAR(50)) + '' + CHAR(13)
					  + ' AND adj1.intItemPricingId = ' + CAST(@intItemPricingId as NVARCHAR(50)) + '' + CHAR(13)

		INSERT @tblInventoryMassMaintenancePreview
		EXEC (@SqlQuery1)
	END

	--PosDescription
		IF (@strPosDescription != '' AND @strPosDescription != 'null')
		BEGIN
		
			SET @SqlQuery1 = 'SELECT' + CHAR(13)
									+ ' adj5.strLocationName AS strLocation' + CHAR(13)
									+ ', adj6.strUpcCode AS strUpc' + CHAR(13)
									+ ', adj7.strDescription AS strItemDescription' + CHAR(13)
									+ ', ''Pos Description'' AS strChangeDescription' + CHAR(13)
									+ ', adj2.strDescription AS strOldData' + CHAR(13)
									+ ', ''' + @strPosDescription + ''' AS strNewData' + CHAR(13)
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
						  --+ ' WHERE adj5.intCompanyLocationId = ' + CAST(@intCompanyLocationId as NVARCHAR(50)) + '' + CHAR(13)
						  + ' WHERE adj6.intItemUOMId = ' + CAST(@intItemUOMId as NVARCHAR(50)) + '' + CHAR(13)
						  + ' AND adj7.intItemId = ' + CAST(@intItemId as NVARCHAR(50)) + '' + CHAR(13)
						  + ' AND adj2.intItemLocationId = ' + CAST(@intItemLocationId as NVARCHAR(50)) + '' + CHAR(13)
						  + ' AND adj1.intItemPricingId = ' + CAST(@intItemPricingId as NVARCHAR(50)) + '' + CHAR(13)

			INSERT @tblInventoryMassMaintenancePreview
			EXEC (@SqlQuery1)
		END

	--intEntityId
	IF (@intEntityVendorId IS NOT NULL AND @intEntityVendorId <> 0)
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
					  --+ ' WHERE adj5.intCompanyLocationId = ' + CAST(@intCompanyLocationId as NVARCHAR(50)) + '' + CHAR(13)
					  + ' WHERE adj6.intItemUOMId = ' + CAST(@intItemUOMId as NVARCHAR(50)) + '' + CHAR(13)
					  + ' AND adj7.intItemId = ' + CAST(@intItemId as NVARCHAR(50)) + '' + CHAR(13)
					  + ' AND adj2.intItemLocationId = ' + CAST(@intItemLocationId as NVARCHAR(50)) + '' + CHAR(13)
					  + ' AND adj1.intItemPricingId = ' + CAST(@intItemPricingId as NVARCHAR(50)) + '' + CHAR(13)

		INSERT @tblInventoryMassMaintenancePreview
		EXEC (@SqlQuery1)
	END

	--@intItemVendorXrefId
	--@intItemVendorXrefId IS NOT NULL AND @intItemVendorXrefId <> 0 AND 
	IF (@strVendorProduct != '' AND @strVendorProduct IS NOT NULL AND @strVendorProduct != 'null')
	BEGIN
		  
         SELECT @VendorXrefCount = COUNT(*) FROM tblICItemVendorXref WHERE intItemVendorXrefId = @intItemVendorXrefId 

		 DECLARE @ItemVendorProductChangeType NVARCHAR(50)
		 SET @ItemVendorProductChangeType = ''

		 --DECLARE @VendorProductExistCount INT
		 --SET @VendorProductExistCount = 0
		 --SELECT @VendorProductExistCount = COUNT(*) FROM tblICItemVendorXref WHERE intItemId = @intItemId AND intItemLocationId = @intItemLocationId AND intVendorId = @intEntityVendorId AND strVendorProduct = @strVendorProduct
		 --IF(@VendorProductExistCount >= 1)
		 --BEGIN
			--IF(@VendorXrefCount = 0)
			--BEGIN
			--	--Update table 
			--END
		 --END

		 IF ((@VendorXrefCount = 0)
				 AND (@intItemId IS NOT NULL AND @intItemId != 0)
				 AND (@intItemLocationId IS NOT NULL AND @intItemLocationId != 0)
				 AND (@intEntityVendorId IS NOT NULL AND @intEntityVendorId != 0))
		 BEGIN
			SET @ItemVendorProductChangeType = 'Added Vendor Item'
		 END
		 ELSE IF (@VendorXrefCount > 0)
		 BEGIN
			SET @ItemVendorProductChangeType = 'Updated Vendor Item'
		 END
		 

		 IF(@ItemVendorProductChangeType != '' AND @ItemVendorProductChangeType IS NOT NULL)
		 BEGIN
			SET @SqlQuery1 = 'SELECT' + CHAR(13)
									+ ' adj5.strLocationName AS strLocation' + CHAR(13)
									+ ', adj6.strUpcCode AS strUpc' + CHAR(13)
									+ ', adj7.strDescription AS strItemDescription' + CHAR(13)
									+ ', ''' + @ItemVendorProductChangeType + ''' AS strChangeDescription' + CHAR(13)
									+ ', ISNULL(adj10.strVendorProduct, '''') AS strOldData' + CHAR(13)
									+ ', ''' + @strVendorProduct + ''' AS strNewData' + CHAR(13)
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
						  --+ ' WHERE adj5.intCompanyLocationId = ' + CAST(@intCompanyLocationId as NVARCHAR(50)) + '' + CHAR(13)
						  + ' WHERE adj6.intItemUOMId = ' + CAST(@intItemUOMId as NVARCHAR(50)) + '' + CHAR(13)
						  + ' AND adj7.intItemId = ' + CAST(@intItemId as NVARCHAR(50)) + '' + CHAR(13)
						  + ' AND adj2.intItemLocationId = ' + CAST(@intItemLocationId as NVARCHAR(50)) + '' + CHAR(13)
						  + ' AND adj1.intItemPricingId = ' + CAST(@intItemPricingId as NVARCHAR(50)) + '' + CHAR(13)

			INSERT @tblInventoryMassMaintenancePreview
			EXEC (@SqlQuery1)
		 END	
	END

	--dblSalePrice
	IF (@dblSalePrice IS NOT NULL)
	BEGIN

		SET @SqlQuery1 = 'SELECT' + CHAR(13)
								+ ' CL.strLocationName AS strLocation' + CHAR(13)
								+ ', UOM.strUpcCode AS strUpc' + CHAR(13)
								+ ', I.strDescription AS strItemDescription' + CHAR(13)
								+ ', ''Sale Price'' AS strChangeDescription' + CHAR(13)
								+ ', CAST(IP.dblSalePrice AS DECIMAL(18, ' + @CompanyCurrencyDecimal + ')) AS strOldData' + CHAR(13)
								+ ', CAST(' + CAST(@dblSalePrice AS NVARCHAR(250)) + ' AS DECIMAL(18, ' + @CompanyCurrencyDecimal + '))' + CHAR(13)
					  + ' FROM dbo.tblICItemPricing IP' + CHAR(13)
					  + ' JOIN dbo.tblICItem I ON IP.intItemId = I.intItemId' + CHAR(13)
					  + ' JOIN dbo.tblICItemUOM UOM ON I.intItemId = UOM.intItemId' + CHAR(13)
					  + ' JOIN dbo.tblICItemLocation IL ON IP.intItemLocationId = IL.intItemLocationId' + CHAR(13)
					  + ' JOIN dbo.tblSMCompanyLocation CL ON IL.intLocationId = CL.intCompanyLocationId' + CHAR(13)
					  + ' WHERE intItemPricingId = ' + CAST(@intItemPricingId as NVARCHAR(50)) + '' + CHAR(13)

		INSERT @tblInventoryMassMaintenancePreview
		EXEC (@SqlQuery1)
	END

	--dblLastCost
	IF (@dblLastCost IS NOT NULL)
	BEGIN
		
		SET @SqlQuery1 = 'SELECT' + CHAR(13)
								+ ' CL.strLocationName AS strLocation' + CHAR(13)
								+ ', UOM.strUpcCode AS strUpc' + CHAR(13)
								+ ', I.strDescription AS strItemDescription' + CHAR(13)
								+ ', ''Last Cost'' AS strChangeDescription' + CHAR(13)
								+ ', CAST(IP.dblLastCost AS DECIMAL(18, ' + @CompanyCurrencyDecimal + ')) AS strOldData' + CHAR(13)
								+ ', CAST(' + CAST(@dblLastCost AS NVARCHAR(250)) + ' AS DECIMAL(18, ' + @CompanyCurrencyDecimal + '))' + CHAR(13)
					  + ' FROM dbo.tblICItemPricing IP' + CHAR(13)
					  + ' JOIN dbo.tblICItem I ON IP.intItemId = I.intItemId' + CHAR(13)
					  + ' JOIN dbo.tblICItemUOM UOM ON I.intItemId = UOM.intItemId' + CHAR(13)
					  + ' JOIN dbo.tblICItemLocation IL ON IP.intItemLocationId = IL.intItemLocationId' + CHAR(13)
					  + ' JOIN dbo.tblSMCompanyLocation CL ON IL.intLocationId = CL.intCompanyLocationId' + CHAR(13)
					  + ' WHERE intItemPricingId = ' + CAST(@intItemPricingId as NVARCHAR(50)) + '' + CHAR(13)

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
					  --+ ' WHERE adj5.intCompanyLocationId = ' + CAST(@intCompanyLocationId as NVARCHAR(50)) + '' + CHAR(13)
					  + ' WHERE adj6.intItemUOMId = ' + CAST(@intItemUOMId as NVARCHAR(50)) + '' + CHAR(13)
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
					  --+ ' WHERE adj5.intCompanyLocationId = ' + CAST(@intCompanyLocationId as NVARCHAR(50)) + '' + CHAR(13)
					  + ' WHERE adj6.intItemUOMId = ' + CAST(@intItemUOMId as NVARCHAR(50)) + '' + CHAR(13)
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
					  --+ ' WHERE adj5.intCompanyLocationId = ' + CAST(@intCompanyLocationId as NVARCHAR(50)) + '' + CHAR(13)
					  + ' WHERE adj6.intItemUOMId = ' + CAST(@intItemUOMId as NVARCHAR(50)) + '' + CHAR(13)
					  + ' AND adj7.intItemId = ' + CAST(@intItemId as NVARCHAR(50)) + '' + CHAR(13)
					  + ' AND adj2.intItemLocationId = ' + CAST(@intItemLocationId as NVARCHAR(50)) + '' + CHAR(13)
					  + ' AND adj1.intItemPricingId = ' + CAST(@intItemPricingId as NVARCHAR(50)) + '' + CHAR(13)

		INSERT @tblInventoryMassMaintenancePreview
		EXEC (@SqlQuery1)
	END


   DELETE FROM @tblInventoryMassMaintenancePreview WHERE strOldData = strNewData

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