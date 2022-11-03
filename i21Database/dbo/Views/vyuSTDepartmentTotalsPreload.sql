CREATE VIEW [dbo].[vyuSTDepartmentTotalsPreload]
AS
SELECT DISTINCT 
 Cat.intCategoryId
, ST.intStoreId
, Cat.strCategoryCode
, Cat.strDescription
, CatLoc.intGeneralItemId AS intItemId
, Item.strItemNo
, Item.strDescription AS strItemDescription
, CatLoc.strCashRegisterDepartment
, Item.strLotTracking
FROM dbo.tblICCategory AS Cat 
INNER JOIN dbo.tblICCategoryLocation AS CatLoc 
	ON CatLoc.intCategoryId = Cat.intCategoryId 
INNER JOIN dbo.tblSMCompanyLocation AS L 
	ON L.intCompanyLocationId = CatLoc.intLocationId 
INNER JOIN dbo.tblICItem AS Item 
	ON CatLoc.intGeneralItemId = Item.intItemId
INNER JOIN dbo.tblICItemLocation AS ItemLoc
	ON ItemLoc.intItemId = Item.intItemId
INNER JOIN dbo.tblSTStore AS ST 
	ON ST.intCompanyLocationId = L.intCompanyLocationId
	AND ItemLoc.intLocationId = ST.intCompanyLocationId