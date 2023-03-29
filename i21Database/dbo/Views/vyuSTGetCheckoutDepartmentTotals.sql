CREATE VIEW [dbo].[vyuSTGetCheckoutDepartmentTotals]
AS
SELECT CDT.*
	, StoreDepartments.strRegisterCode AS strCashRegisterDepartment
	, Cat.strCategoryCode
	, Cat.strDescription AS strCategoryDesc
	, CASE
		WHEN StoreDepartments.strCategoriesOrSubcategories = 'C'
		THEN StoreDepartments.strGeneralItemDescription
		ELSE StoreDepartments.strSubcategoryItemDescription
		END strItemDescription
	, CASE
		WHEN StoreDepartments.strCategoriesOrSubcategories = 'C'
		THEN StoreDepartments.strGeneralItemNo
		ELSE StoreDepartments.strSubcategoryItemNo
		END AS strItemNo
FROM tblSTCheckoutDepartmetTotals CDT
INNER JOIN dbo.tblSTCheckoutHeader CH
	ON CDT.intCheckoutId = CH.intCheckoutId
INNER JOIN dbo.tblSTStore AS ST 
	ON CH.intStoreId = ST.intStoreId
INNER JOIN tblICCategory Cat
	ON CDT.intCategoryId = Cat.intCategoryId
INNER JOIN dbo.vyuSTStoreDepartments AS StoreDepartments 
	ON StoreDepartments.intCategoryId = Cat.intCategoryId
	AND StoreDepartments.intStoreId = ST.intStoreId