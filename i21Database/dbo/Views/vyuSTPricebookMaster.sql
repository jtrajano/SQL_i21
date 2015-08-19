CREATE VIEW [dbo].[vyuSTPricebookMaster]
AS 

SELECT 
adj5.intCompanyLocationId,
adj5.strLocationName,
adj6.intItemUOMId,
adj6.strUpcCode,
adj7.intItemId,
adj7.strDescription,
adj2.intItemLocationId,
adj2.strDescription as PosDescription,
adj1.intItemPricingId,
adj1.dblSalePrice,
adj2.intVendorId,
adj9.strVendorId,
adj8.intCategoryId,
adj8.strCategoryCode,
adj10.intItemVendorXrefId,
adj10.strVendorProduct,
adj3.intSubcategoryId as FamilyId,
adj3.strSubcategoryId as Family,
adj4.intSubcategoryId as ClassId,
adj4.strSubcategoryId as Class


from tblICItemPricing adj1 LEFT JOIN tblICItemLocation adj2
ON adj1.intItemId = adj2.intItemId  AND adj2.intItemLocationId IS NOT NULL LEFT JOIN tblSTSubcategory adj3
ON adj2.intFamilyId = adj3.intSubcategoryId LEFT JOIN tblSTSubcategory adj4
ON adj2.intClassId = adj4.intSubcategoryId LEFT JOIN tblSMCompanyLocation adj5
ON adj2.intLocationId = adj5.intCompanyLocationId LEFT JOIN tblICItemUOM adj6
ON adj1.intItemId = adj6.intItemId AND adj6.strUpcCode IS NOT NULL 
AND adj6.strUpcCode <> '' LEFT JOIN tblICItem adj7
ON adj1.intItemId = adj7.intItemId 
LEFT JOIN tblICCategory adj8 ON adj7.intCategoryId = adj8.intCategoryId 
LEFT JOIN tblAPVendor adj9 ON adj2.intVendorId = adj9.intEntityVendorId 
LEFT JOIN tblICItemVendorXref adj10 ON adj2.intItemLocationId = adj10.intItemLocationId
