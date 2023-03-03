CREATE VIEW [dbo].[vyuSTStoreDepartments]
	AS 
SELECT		a.intStoreDepartmentId,
			a.intStoreId,
			CASE
				WHEN a.intCategoryId IS NULL
				THEN (SELECT x.intCategoryId FROM tblSTSubCategories x WHERE x.intSubcategoriesId = a.intSubcategoriesId)
				ELSE a.intCategoryId  
				END intCategoryId,
			a.intSubcategoriesId,
			a.strRegisterCode,
			b.intCompanyLocationId,
			b.strDepartmentOrCategory,
			b.strCategoriesOrSubcategories,
			c.intGeneralItemId,
			d.strItemNo AS strGeneralItemNo,
			d.strDescription AS strGeneralItemDescription,
			d.strLotTracking AS strGeneralItemLotTracking,
			(SELECT TOP 1 x.intItemId FROM tblICItem x WHERE x.intSubcategoriesId = a.intSubcategoriesId) intSubcategoryItemId,
			(SELECT TOP 1 x.strItemNo FROM tblICItem x WHERE x.intSubcategoriesId = a.intSubcategoriesId) strSubcategoryItemNo,
			(SELECT TOP 1 x.strDescription FROM tblICItem x WHERE x.intSubcategoriesId = a.intSubcategoriesId) strSubcategoryItemDescription,
			(SELECT TOP 1 x.strLotTracking FROM tblICItem x WHERE x.intSubcategoriesId = a.intSubcategoriesId) strSubcategoryLotTracking
FROM		tblSTStoreDepartments a
INNER JOIN	tblSTStore b
ON			a.intStoreId = b.intStoreId
LEFT JOIN	tblICCategoryLocation c
ON			a.intCategoryId = c.intCategoryId AND b.intCompanyLocationId = c.intLocationId
LEFT JOIN	tblICItem d
ON			c.intGeneralItemId = d.intItemId