﻿CREATE VIEW [dbo].[vyuSTStoreMaintenanceDepartments]
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
AND ISNULL(sd.strRegisterCode, '') = ISNULL(plcs.strCashRegisterDepartment, '')
LEFT JOIN tblSTSubCategories sc
ON ISNULL(sc.intSubcategoriesId, 0) = ISNULL(plcs.intSubcategoriesId, 0)