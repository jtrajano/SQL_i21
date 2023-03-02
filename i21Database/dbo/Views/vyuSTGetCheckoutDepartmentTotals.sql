CREATE VIEW [dbo].[vyuSTGetCheckoutDepartmentTotals]
AS
SELECT CDT.*
	, StoreDepartments.strRegisterCode
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
INNER JOIN  (	SELECT		x.intStoreDepartmentId, 
							x.intStoreId, 
							CASE 
								WHEN x.intCategoryId IS NULL
								THEN (SELECT intCategoryId FROM tblSTSubCategories y WHERE y.intSubcategoriesId = x.intSubcategoriesId)
								ELSE intCategoryId
								END AS intCategoryId,
							x.intSubcategoriesId,
							x.strRegisterCode
				FROM		tblSTStoreDepartments x) StoreDepartments
	ON Cat.intCategoryId = StoreDepartments.intCategoryId AND ST.intStoreId = StoreDepartments.intStoreId
INNER JOIN dbo.tblSMCompanyLocation AS CL 
	ON CL.intCompanyLocationId = ST.intCompanyLocationId
LEFT JOIN dbo.tblICItem I
	ON CDT.intItemId = I.intItemId