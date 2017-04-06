CREATE VIEW [dbo].[vyuSTPricebookMaster]
AS 
SELECT        
adj5.intCompanyLocationId
, adj5.strLocationName
, adj6.intItemUOMId
, adj6.strUpcCode
, adj6.strLongUPCCode
, adj7.intItemId
, adj7.strDescription
, adj2.intItemLocationId
, adj2.strDescription AS PosDescription
, adj1.intItemPricingId
, adj1.dblSalePrice
, adj2.intVendorId AS intEntityVendorId
, adj11.strName
, adj9.strVendorId
, adj8.intCategoryId
, adj8.strCategoryCode
, adj10.intItemVendorXrefId
, adj10.strVendorProduct
, adj1.dblLastCost
, adj3.intSubcategoryId AS FamilyId
, adj3.strSubcategoryId AS Family
, adj4.intSubcategoryId AS ClassId
, adj4.strSubcategoryId AS Class
FROM            
dbo.tblICItemPricing AS adj1 LEFT OUTER JOIN
dbo.tblICItemLocation AS adj2 ON adj1.intItemId = adj2.intItemId AND adj2.intItemLocationId IS NOT NULL LEFT OUTER JOIN
dbo.tblSTSubcategory AS adj3 ON adj2.intFamilyId = adj3.intSubcategoryId LEFT OUTER JOIN
dbo.tblSTSubcategory AS adj4 ON adj2.intClassId = adj4.intSubcategoryId LEFT OUTER JOIN
dbo.tblSMCompanyLocation AS adj5 ON adj2.intLocationId = adj5.intCompanyLocationId LEFT OUTER JOIN
dbo.tblICItemUOM AS adj6 ON adj1.intItemId = adj6.intItemId LEFT OUTER JOIN
dbo.tblICItem AS adj7 ON adj1.intItemId = adj7.intItemId LEFT OUTER JOIN
dbo.tblICCategory AS adj8 ON adj7.intCategoryId = adj8.intCategoryId LEFT OUTER JOIN
dbo.tblAPVendor AS adj9 ON adj2.intVendorId = adj9.intEntityVendorId LEFT OUTER JOIN
dbo.tblICItemVendorXref AS adj10 ON adj2.intItemLocationId = adj10.intItemLocationId LEFT OUTER JOIN
dbo.tblEMEntity AS adj11 ON adj11.intEntityId = adj2.intVendorId





