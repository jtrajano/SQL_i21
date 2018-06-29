CREATE VIEW [dbo].[vyuARGetCustomerSpecialTax]
AS
SELECT ST.intEntityCustomerId
	 , ST.intEntityVendorId
	 , ST.intTaxGroupId
	 , ST.intItemId
	 , ST.intEntityCustomerLocationId
	 , ITEM.intCategoryId
	 , TAXGROUP.strTaxGroup
	 , VENDOR.strVendorId
	 , ITEM.strItemNo
	 , ITEMCATEGORY.strCategoryCode
	 , ENTITYLOCATION.strLocationName
FROM dbo.tblARSpecialTax ST WITH (NOLOCK)
INNER JOIN (
	SELECT intTaxGroupId
		 , strTaxGroup
	FROM dbo.tblSMTaxGroup WITH (NOLOCK)
) TAXGROUP ON ST.intTaxGroupId = TAXGROUP.intTaxGroupId
LEFT JOIN (
	SELECT intEntityId
		 , strVendorId
	FROM dbo.tblAPVendor WITH (NOLOCK)
) VENDOR ON ST.intEntityVendorId = VENDOR.intEntityId
LEFT JOIN (
	SELECT intItemId
		 , intCategoryId
		 , strItemNo
	FROM dbo.tblICItem WITH (NOLOCK)
) ITEM ON ST.intItemId = ITEM.intItemId
LEFT JOIN (
	SELECT intCategoryId
		 , strCategoryCode
	FROM dbo.tblICCategory
) ITEMCATEGORY ON ITEM.intCategoryId = ITEMCATEGORY.intCategoryId
LEFT JOIN (
	SELECT intEntityLocationId
		 , strLocationName
	FROM dbo.tblEMEntityLocation WITH (NOLOCK)
) ENTITYLOCATION ON ST.intEntityCustomerLocationId = ENTITYLOCATION.intEntityLocationId