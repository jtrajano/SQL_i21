CREATE VIEW [dbo].[vyuSTDepartmentTotalsPreload]
AS
SELECT DISTINCT 
 Cat.intCategoryId
, StoreDepartments.intStoreId
, StoreDepartments.intSubcategoriesId
, Cat.strCategoryCode
, Cat.strDescription
, CASE 
	WHEN StoreDepartments.strCategoriesOrSubcategories = 'C'
	THEN StoreDepartments.intGeneralItemId 
	ELSE StoreDepartments.intSubcategoryItemId
	END AS intItemId
, CASE
	WHEN StoreDepartments.strCategoriesOrSubcategories = 'C'
	THEN StoreDepartments.strGeneralItemNo
	ELSE StoreDepartments.strSubcategoryItemNo
	END AS strItemNo
, CASE
	WHEN StoreDepartments.strCategoriesOrSubcategories = 'C'
	THEN StoreDepartments.strGeneralItemDescription
	ELSE StoreDepartments.strSubcategoryItemDescription
	END strItemDescription
, StoreDepartments.strRegisterCode as strCashRegisterDepartment
, CASE
	WHEN StoreDepartments.strCategoriesOrSubcategories = 'C'
	THEN ISNULL(StoreDepartments.strGeneralItemLotTracking, 'No')
	ELSE ISNULL(StoreDepartments.strSubcategoryLotTracking, 'No')
	END AS strLotTracking
, StoreDepartments.strRegisterCode
FROM dbo.tblICCategory AS Cat 
INNER JOIN dbo.vyuSTStoreDepartments AS StoreDepartments 
	ON StoreDepartments.intCategoryId = Cat.intCategoryId
WHERE (CASE 
	WHEN StoreDepartments.strCategoriesOrSubcategories = 'C'
	THEN StoreDepartments.intGeneralItemId 
	ELSE StoreDepartments.intSubcategoryItemId END) IS NOT NULL