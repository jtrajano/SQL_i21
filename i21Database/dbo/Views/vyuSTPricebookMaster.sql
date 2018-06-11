CREATE VIEW dbo.vyuSTPricebookMaster
AS
SELECT 
	--CAST(CAST(IP.intItemPricingId AS NVARCHAR(10)) + '0' + CAST(UOM.intItemUOMId AS NVARCHAR(10)) AS BIGINT) AS intUniqueId
	ROW_NUMBER() OVER (ORDER BY IP.intItemPricingId, UOM.intItemUOMId ASC) AS intRowId 
	, CAST(IP.intItemPricingId AS NVARCHAR(1000)) + '0' + CAST(UOM.intItemUOMId AS NVARCHAR(1000)) AS strUniqueId
	, IP.intItemPricingId, IP.dblSalePrice, IP.dblLastCost, CL.intCompanyLocationId
	, CL.strLocationName, I.intItemId
	, I.strItemNo
	, I.strDescription
	, UOM.intItemUOMId
	, UOM.strUpcCode
	, UOM.strLongUPCCode
	, IL.intItemLocationId
	, IL.strDescription AS strPosDescription
	, IL.intVendorId AS intEntityVendorId
	, Entity.strName
	, Vendor.strVendorId
	, IC.intCategoryId
	, IC.strCategoryCode
	, VX.intItemVendorXrefId
	, VX.strVendorProduct
	, Family.intSubcategoryId AS FamilyId
	, Family.strSubcategoryId AS Family
	, Class.intSubcategoryId AS ClassId
	, Class.strSubcategoryId AS Class
FROM dbo.tblICItemPricing AS IP LEFT OUTER JOIN
	dbo.tblICItem AS I ON I.intItemId = IP.intItemId LEFT OUTER JOIN
	dbo.tblICItemUOM AS UOM ON IP.intItemId = UOM.intItemId LEFT OUTER JOIN
	dbo.tblICCategory AS IC ON IC.intCategoryId = I.intCategoryId LEFT OUTER JOIN
	dbo.tblICItemLocation AS IL ON IL.intItemLocationId = IP.intItemLocationId LEFT OUTER JOIN
	dbo.tblSTSubcategory AS Family ON Family.intSubcategoryId = IL.intFamilyId LEFT OUTER JOIN
	dbo.tblSTSubcategory AS Class ON Class.intSubcategoryId = IL.intClassId LEFT OUTER JOIN
	dbo.tblSMCompanyLocation AS CL ON CL.intCompanyLocationId = IL.intLocationId LEFT OUTER JOIN
	dbo.tblAPVendor AS Vendor ON Vendor.intEntityId = IL.intVendorId LEFT OUTER JOIN
	dbo.tblEMEntity AS Entity ON Entity.intEntityId = IL.intVendorId LEFT OUTER JOIN
	dbo.tblICItemVendorXref AS VX ON VX.intItemLocationId = IL.intItemLocationId





