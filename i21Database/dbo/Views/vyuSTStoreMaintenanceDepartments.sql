CREATE VIEW [dbo].[vyuSTStoreMaintenanceDepartments]
AS
SELECT 
intStoreDepartmentId
,sd.intStoreId
,sd.intCategoryId
,strCategoryCode
,sd.intSubcategoriesId
,sc.strSubCategory
,strSubCategoryCode
,strRegisterCode
,sd.intConcurrencyId
FROM tblSTStoreDepartments sd
LEFT JOIN vyuSTDepartmentTotalsPreloadCS plcs
ON sd.intStoreId = plcs.intStoreId
AND sd.strRegisterCode = plcs.strCashRegisterDepartment
LEFT JOIN tblSTSubCategories sc
ON sc.intSubcategoriesId = plcs.intSubcategoriesId