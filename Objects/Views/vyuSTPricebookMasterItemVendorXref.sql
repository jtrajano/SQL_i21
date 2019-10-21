CREATE VIEW dbo.vyuSTPricebookMasterItemVendorXref
AS 
SELECT 
	xref.intItemVendorXrefId
	, Item.intItemId
	, ItemLoc.intItemLocationId
	, xref.intVendorId
	, Entity.strName AS strVendorName
	, Store.intStoreId
	, Store.intStoreNo
	, CompanyLoc.strLocationName
	, xref.strVendorProduct
	, xref.intConcurrencyId
FROM dbo.tblICItemVendorXref xref
INNER JOIN dbo.tblICItem Item
	ON xref.intItemId = Item.intItemId
LEFT JOIN dbo.tblEMEntity Entity
	ON xref.intVendorId = Entity.intEntityId
LEFT JOIN dbo.tblICItemLocation ItemLoc
	ON xref.intItemLocationId = ItemLoc.intItemLocationId
LEFT JOIN dbo.tblSTStore Store
	ON ItemLoc.intLocationId = Store.intCompanyLocationId
LEFT JOIN dbo.tblSMCompanyLocation CompanyLoc
	ON ItemLoc.intLocationId = CompanyLoc.intCompanyLocationId