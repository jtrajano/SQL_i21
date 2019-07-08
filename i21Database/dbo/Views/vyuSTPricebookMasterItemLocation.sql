CREATE VIEW dbo.vyuSTPricebookMasterItemLocation
AS 
SELECT 
	ItemLoc.intItemLocationId
	, Item.intItemId
	, Store.intStoreId
	, Store.intStoreNo
	, CompanyLoc.strLocationName

	, ItemLoc.intFamilyId
	, ItemLoc.intClassId
	, ItemLoc.intVendorId
	, ItemLoc.strDescription

	, Family.strSubcategoryId AS strFamily
	, Class.strSubcategoryId AS strClass
	, Entity.strName AS strVendorName

	, ItemLoc.intConcurrencyId
FROM dbo.tblICItemLocation ItemLoc
INNER JOIN dbo.tblICItem Item
	ON ItemLoc.intItemId = Item.intItemId
INNER JOIN dbo.tblSMCompanyLocation CompanyLoc
	ON ItemLoc.intLocationId = CompanyLoc.intCompanyLocationId
INNER JOIN dbo.tblSTStore Store
	ON CompanyLoc.intCompanyLocationId = Store.intCompanyLocationId
LEFT OUTER JOIN dbo.tblSTSubcategory AS Family 
	ON ItemLoc.intFamilyId = Family.intSubcategoryId
LEFT OUTER JOIN dbo.tblSTSubcategory AS Class 
	ON ItemLoc.intClassId = Class.intSubcategoryId
LEFT OUTER JOIN dbo.tblEMEntity AS Entity 
	ON Entity.intEntityId = ItemLoc.intVendorId 
