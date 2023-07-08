GO
	PRINT N'BEGIN TAGGING FUEL DEPARTMENT ITEMS AS FUEL CATEGORY'
GO
	IF (SELECT ysnFuelCategoryDoneTagging FROM tblSTCompanyPreference) = 0
	BEGIN
		--- Categories
		UPDATE tblSTStoreDepartments SET ysnFuelCategory = 1
		WHERE intStoreDepartmentId 
		IN (SELECT sd.intStoreDepartmentId
		FROM tblSTStoreDepartments sd
		JOIN tblSTStore st
			ON sd.intStoreId = st.intStoreId
		JOIN tblICCategory cat
			ON sd.intCategoryId = cat.intCategoryId
		JOIN tblICItem i
			ON cat.intCategoryId = i.intCategoryId
		WHERE i.ysnFuelItem = 1
		GROUP BY sd.intStoreDepartmentId)

		--- Sub-Categories
		UPDATE tblSTStoreDepartments SET ysnFuelCategory = 1
		WHERE intStoreDepartmentId
		IN(SELECT sd.intStoreDepartmentId
		FROM tblSTStoreDepartments sd
		JOIN tblSTStore st
			ON sd.intStoreId = st.intStoreId
		JOIN tblSTSubCategories subcat
			ON sd.intSubcategoriesId = subcat.intSubcategoriesId
		JOIN tblICCategory cat
			ON subcat.intCategoryId = cat.intCategoryId
		JOIN tblICItem i
			ON subcat.intCategoryId = i.intCategoryId
		WHERE i.ysnFuelItem = 1
		GROUP BY sd.intStoreDepartmentId)

		UPDATE tblSTCompanyPreference SET ysnFuelCategoryDoneTagging = 1
	END	
GO
	PRINT N'END TAGGING FUEL DEPARTMENT ITEMS AS FUEL CATEGORY'
GO