CREATE VIEW  [dbo].[vyuSTCategoriesToRegister]
AS

-- Category Should have
-- 1. Cash Register Department
-- 2. Category Description
-- 3. General Item Id on POS of category

SELECT DISTINCT 
    x.dtmDateModified
	, x.dtmDateCreated
	, Cat.intCategoryId
	, ST.intCompanyLocationId
	, ST.intStoreId
FROM tblICCategory Cat 
JOIN tblICCategoryLocation CL 
	ON Cat.intCategoryId = CL.intCategoryId
JOIN tblICItem I
	ON I.intItemId = CL.intGeneralItemId
JOIN tblICItemLocation IL
	ON I.intItemId = IL.intItemId
JOIN tblSTStore ST 
	ON CL.intLocationId = ST.intCompanyLocationId
JOIN tblSMCompanyLocation L 
	ON L.intCompanyLocationId = ST.intCompanyLocationId
JOIN tblSTRegister R 
	ON R.intStoreId = ST.intStoreId
JOIN 
(
	 SELECT intCategoryId, dtmDateModified, dtmDateCreated 
	 FROM tblICCategory
	 WHERE dtmDateModified IS NOT NULL 
	 OR dtmDateCreated IS NOT NULL

	 UNION

	 SELECT intCategoryId, dtmDateModified, dtmDateCreated 
	 FROM tblICCategoryLocation
	 WHERE dtmDateModified IS NOT NULL 
	 OR dtmDateCreated IS NOT NULL
) AS x 
	ON x.intCategoryId = Cat.intCategoryId 
JOIN (	SELECT	x.intStoreDepartmentId, 
				x.intStoreId, 
				CASE 
					WHEN x.intCategoryId IS NULL
					THEN (SELECT intCategoryId FROM tblSTSubCategories y WHERE y.intSubcategoriesId = x.intSubcategoriesId)
					ELSE intCategoryId
					END AS intCategoryId,
				x.intSubcategoriesId,
				x.strRegisterCode
		FROM		tblSTStoreDepartments x) StoreDepartments 
	ON Cat.intCategoryId = StoreDepartments.intCategoryId
WHERE StoreDepartments.strRegisterCode IS NOT NULL
AND Cat.strDescription IS NOT NULL 
AND Cat.strDescription != ''