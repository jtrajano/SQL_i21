CREATE PROCEDURE [dbo].[uspSTUpdatePricebookItem]
@intCompanyLocationId Int
, @intItemUOMId int
, @intItemId int
, @intItemLocationId int
, @intItemPricingId int

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
		--strDescription
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
			 dbo.tblAPVendor AS adj9 ON adj2.intVendorId = adj9.intEntityVendorId LEFT OUTER JOIN
			 dbo.tblICItemVendorXref AS adj10 ON adj2.intItemLocationId = adj10.intItemLocationId
		 WHERE adj5.intCompanyLocationId = @intCompanyLocationId
		 AND adj6.intItemUOMId = @intItemUOMId
		 AND adj7.intItemId = @intItemId
		 AND adj2.intItemLocationId = @intItemLocationId
		 AND adj1.intItemPricingId = @intItemPricingId

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
				 dbo.tblAPVendor AS adj9 ON adj2.intVendorId = adj9.intEntityVendorId LEFT OUTER JOIN
				 dbo.tblICItemVendorXref AS adj10 ON adj2.intItemLocationId = adj10.intItemLocationId
			 WHERE adj5.intCompanyLocationId = @intCompanyLocationId
			 AND adj6.intItemUOMId = @intItemUOMId
			 AND adj7.intItemId = @intItemId
			 AND adj2.intItemLocationId = @intItemLocationId
			 AND adj1.intItemPricingId = @intItemPricingId

		--PosDescription, intVendorId
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
				 dbo.tblAPVendor AS adj9 ON adj2.intVendorId = adj9.intEntityVendorId LEFT OUTER JOIN
				 dbo.tblICItemVendorXref AS adj10 ON adj2.intItemLocationId = adj10.intItemLocationId
			 WHERE adj5.intCompanyLocationId = @intCompanyLocationId
			 AND adj6.intItemUOMId = @intItemUOMId
			 AND adj7.intItemId = @intItemId
			 AND adj2.intItemLocationId = @intItemLocationId
			 AND adj1.intItemPricingId = @intItemPricingId
		END
		

		--dblSalePrice, dblLastCost
		UPDATE dbo.tblICItemPricing
		SET dblSalePrice = @dblSalePrice
			, dblLastCost = @dblLastCost
		FROM dbo.tblICItemPricing AS adj1 LEFT OUTER JOIN
			 dbo.tblICItemLocation AS adj2 ON adj1.intItemId = adj2.intItemId AND adj2.intItemLocationId IS NOT NULL LEFT OUTER JOIN
			 dbo.tblSTSubcategory AS adj3 ON adj2.intFamilyId = adj3.intSubcategoryId LEFT OUTER JOIN
			 dbo.tblSTSubcategory AS adj4 ON adj2.intClassId = adj4.intSubcategoryId LEFT OUTER JOIN
			 dbo.tblSMCompanyLocation AS adj5 ON adj2.intLocationId = adj5.intCompanyLocationId LEFT OUTER JOIN
			 dbo.tblICItemUOM AS adj6 ON adj1.intItemId = adj6.intItemId LEFT OUTER JOIN
			 dbo.tblICItem AS adj7 ON adj1.intItemId = adj7.intItemId LEFT OUTER JOIN
			 dbo.tblICCategory AS adj8 ON adj7.intCategoryId = adj8.intCategoryId LEFT OUTER JOIN
			 dbo.tblAPVendor AS adj9 ON adj2.intVendorId = adj9.intEntityVendorId LEFT OUTER JOIN
			 dbo.tblICItemVendorXref AS adj10 ON adj2.intItemLocationId = adj10.intItemLocationId
		 WHERE adj5.intCompanyLocationId = @intCompanyLocationId
		 AND adj6.intItemUOMId = @intItemUOMId
		 AND adj7.intItemId = @intItemId
		 AND adj2.intItemLocationId = @intItemLocationId
		 AND adj1.intItemPricingId = @intItemPricingId

		--strVendorId
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
			 dbo.tblAPVendor AS adj9 ON adj2.intVendorId = adj9.intEntityVendorId LEFT OUTER JOIN
			 dbo.tblICItemVendorXref AS adj10 ON adj2.intItemLocationId = adj10.intItemLocationId
		 WHERE adj5.intCompanyLocationId = @intCompanyLocationId
		 AND adj6.intItemUOMId = @intItemUOMId
		 AND adj7.intItemId = @intItemId
		 AND adj2.intItemLocationId = @intItemLocationId
		 AND adj1.intItemPricingId = @intItemPricingId

		--FamilyId
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
				 dbo.tblAPVendor AS adj9 ON adj2.intVendorId = adj9.intEntityVendorId LEFT OUTER JOIN
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
				 dbo.tblAPVendor AS adj9 ON adj2.intVendorId = adj9.intEntityVendorId LEFT OUTER JOIN
				 dbo.tblICItemVendorXref AS adj10 ON adj2.intItemLocationId = adj10.intItemLocationId
			 WHERE adj5.intCompanyLocationId = @intCompanyLocationId
			 AND adj6.intItemUOMId = @intItemUOMId
			 AND adj7.intItemId = @intItemId
			 AND adj2.intItemLocationId = @intItemLocationId
			 AND adj1.intItemPricingId = @intItemPricingId
			 AND strSubcategoryType = 'F'
			 AND intSubcategoryId = @FamilyId
		END
		

		--ClassId
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
				 dbo.tblAPVendor AS adj9 ON adj2.intVendorId = adj9.intEntityVendorId LEFT OUTER JOIN
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
				 dbo.tblAPVendor AS adj9 ON adj2.intVendorId = adj9.intEntityVendorId LEFT OUTER JOIN
				 dbo.tblICItemVendorXref AS adj10 ON adj2.intItemLocationId = adj10.intItemLocationId
			 WHERE adj5.intCompanyLocationId = @intCompanyLocationId
			 AND adj6.intItemUOMId = @intItemUOMId
			 AND adj7.intItemId = @intItemId
			 AND adj2.intItemLocationId = @intItemLocationId
			 AND adj1.intItemPricingId = @intItemPricingId
			 AND strSubcategoryType = 'C'
			 AND intSubcategoryId = @ClassId
		END
		

		 SET @strStatusMsg = 'Success'
	 END
END