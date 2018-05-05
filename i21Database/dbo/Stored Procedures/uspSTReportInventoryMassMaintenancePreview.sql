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

		SET @SqlQuery1 = dbo.fnSTDynamicQueryInventoryMass
						(
							'Category'
							, 'Cat.strCategoryCode'
							, '''' + @strCategoryCode +''''
							, @intItemUOMId
							, @intItemId
							, @intItemLocationId
							, @intItemPricingId
						)


		INSERT @tblInventoryMassMaintenancePreview
		EXEC (@SqlQuery1)
	END

	--strDescription
	IF (@strDescription != '' AND @strDescription != 'null')
	BEGIN
		
		SET @SqlQuery1 = dbo.fnSTDynamicQueryInventoryMass
						(
							'Description'
							, 'I.strDescription'
							, '''' + @strDescription + ''''
							, @intItemUOMId
							, @intItemId
							, @intItemLocationId
							, @intItemPricingId
						)

		INSERT @tblInventoryMassMaintenancePreview
		EXEC (@SqlQuery1)
	END

	--PosDescription
		IF (@strPosDescription != '' AND @strPosDescription != 'null')
		BEGIN
		
			SET @SqlQuery1 = dbo.fnSTDynamicQueryInventoryMass
						(
							'Pos Description'
							, 'IL.strDescription'
							, '''' + @strPosDescription + ''''
							, @intItemUOMId
							, @intItemId
							, @intItemLocationId
							, @intItemPricingId
						)

			INSERT @tblInventoryMassMaintenancePreview
			EXEC (@SqlQuery1)
		END

	--intEntityId
	IF (@intEntityVendorId IS NOT NULL AND @intEntityVendorId <> 0)
	BEGIN
		
		DECLARE @strVendorName NVARCHAR(100)
		SELECT @strVendorName = strName FROM tblEMEntity WHERE intEntityId = @intEntityVendorId
		
		SELECT @strVendorId = strVendorId FROM tblAPVendor WHERE intEntityId = @intEntityVendorId

		SET @SqlQuery1 = dbo.fnSTDynamicQueryInventoryMass
						(
							'Vendor'
							, 'EM.strName'
							, '''' + @strVendorName + ''''
							, @intItemUOMId
							, @intItemId
							, @intItemLocationId
							, @intItemPricingId
						)

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
			
			SET @SqlQuery1 = dbo.fnSTDynamicQueryInventoryMass
						(
							@ItemVendorProductChangeType
							, 'ISNULL(VendorXref.strVendorProduct, '''')'
							, '''' + @strVendorProduct + ''''
							, @intItemUOMId
							, @intItemId
							, @intItemLocationId
							, @intItemPricingId
						)

			INSERT @tblInventoryMassMaintenancePreview
			EXEC (@SqlQuery1)
		 END	
	END

	--dblSalePrice
	IF (@dblSalePrice IS NOT NULL)
	BEGIN

		SET @SqlQuery1 = dbo.fnSTDynamicQueryInventoryMass
						(
							'Sale Price'
							, 'CAST(IP.dblSalePrice AS DECIMAL(18, ' + @CompanyCurrencyDecimal + '))'
							, 'CAST(' + CAST(@dblSalePrice AS NVARCHAR(250)) + ' AS DECIMAL(18, ' + @CompanyCurrencyDecimal + '))'
							, @intItemUOMId
							, @intItemId
							, @intItemLocationId
							, @intItemPricingId
						)

		INSERT @tblInventoryMassMaintenancePreview
		EXEC (@SqlQuery1)
	END

	--dblLastCost
	IF (@dblLastCost IS NOT NULL)
	BEGIN

		SET @SqlQuery1 = dbo.fnSTDynamicQueryInventoryMass
						(
							'Last Cost'
							, 'CAST(IP.dblLastCost AS DECIMAL(18, ' + @CompanyCurrencyDecimal + '))'
							, 'CAST(' + CAST(@dblLastCost AS NVARCHAR(250)) + ' AS DECIMAL(18, ' + @CompanyCurrencyDecimal + '))'
							, @intItemUOMId
							, @intItemId
							, @intItemLocationId
							, @intItemPricingId
						)

		INSERT @tblInventoryMassMaintenancePreview
		EXEC (@SqlQuery1)
	END

	--strVendorId, 
	IF (@strVendorId != '')
	BEGIN
		
		SET @SqlQuery1 = dbo.fnSTDynamicQueryInventoryMass
						(
							'Vendor Id'
							, 'Vendor.strVendorId'
							, '''' + @strVendorId + ''''
							, @intItemUOMId
							, @intItemId
							, @intItemLocationId
							, @intItemPricingId
						)

		INSERT @tblInventoryMassMaintenancePreview
		EXEC (@SqlQuery1)
	END

	--@intFamilyId, 
	IF (@intFamilyId IS NOT NULL AND @intFamilyId <> 0)
	BEGIN
		
		DECLARE @strFamily NVARCHAR(50)
		SELECT @strFamily = strSubcategoryId FROM tblSTSubcategory WHERE strSubcategoryType = 'F' AND intSubcategoryId = @intFamilyId

		SET @SqlQuery1 = dbo.fnSTDynamicQueryInventoryMass
						(
							'Family'
							, 'SubCatF.strSubcategoryId'
							, '''' + @strFamily + ''''
							, @intItemUOMId
							, @intItemId
							, @intItemLocationId
							, @intItemPricingId
						)

		INSERT @tblInventoryMassMaintenancePreview
		EXEC (@SqlQuery1)
	END

	--@intClassId, 
	IF (@intClassId IS NOT NULL AND @intClassId <> 0)
	BEGIN
		
		DECLARE @strClass NVARCHAR(50)
		SELECT @strClass = strSubcategoryId FROM tblSTSubcategory WHERE strSubcategoryType = 'C' AND intSubcategoryId = @intClassId

		SET @SqlQuery1 = dbo.fnSTDynamicQueryInventoryMass
						(
							'Class'
							, 'SubCatC.strSubcategoryId'
							, '''' + @strClass + ''''
							, @intItemUOMId
							, @intItemId
							, @intItemLocationId
							, @intItemPricingId
						)

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