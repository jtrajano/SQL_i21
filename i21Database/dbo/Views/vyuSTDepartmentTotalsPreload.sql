CREATE VIEW [dbo].[vyuSTDepartmentTotalsPreload]
AS
SELECT DISTINCT 
	Cat.intCategoryId
	, ST.intStoreId
	, Cat.strCategoryCode
	, Cat.strDescription
FROM tblICCategory Cat
JOIN tblICCategoryLocation CatLoc ON CatLoc.intCategoryId = Cat.intCategoryId
JOIN tblSMCompanyLocation L ON L.intCompanyLocationId = CatLoc.intLocationId
JOIN tblSTStore ST ON ST.intCompanyLocationId = L.intCompanyLocationId