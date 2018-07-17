CREATE VIEW [dbo].[vyuSTGetCheckoutDepartmentTotals]
AS
SELECT CDT.*
	, CatLoc.intRegisterDepartmentId
	, Cat.strCategoryCode
	, Cat.strDescription AS strCategoryDesc
	, I.strDescription AS strItemDescription
	, I.strItemNo
FROM tblSTCheckoutDepartmetTotals CDT
INNER JOIN dbo.tblSTCheckoutHeader CH
	ON CDT.intCheckoutId = CH.intCheckoutId
INNER JOIN dbo.tblSTStore AS ST 
	ON CH.intStoreId = ST.intStoreId
INNER JOIN tblICCategory Cat
	ON CDT.intCategoryId = Cat.intCategoryId
INNER JOIN tblICCategoryLocation CatLoc
	ON Cat.intCategoryId = CatLoc.intCategoryId
		AND ST.intCompanyLocationId = CatLoc.intLocationId
INNER JOIN dbo.tblSMCompanyLocation AS CL 
	ON CL.intCompanyLocationId = ST.intCompanyLocationId
LEFT JOIN dbo.tblICItem I
	ON CDT.intItemId = I.intItemId