CREATE FUNCTION [dbo].[fnSTGetDepartmentTotalsForFuel] 
(
	@intCheckoutId AS INT
)
RETURNS DECIMAL(18,2)
AS BEGIN

    DECLARE     @dblDepartmentTotalsForFuel DECIMAL(18,2) = 0

	SELECT      @dblDepartmentTotalsForFuel = ISNULL(SUM(dblTotalSalesAmountComputed),0)
	FROM        tblSTCheckoutDepartmetTotals a
	LEFT JOIN	tblICItem b
	ON          a.intItemId = b.intItemId
	INNER JOIN  tblSTCheckoutHeader ch
	ON			a.intCheckoutId = ch.intCheckoutId
	INNER JOIN  tblSTStore st
	ON			ch.intStoreId = st.intStoreId
	WHERE       a.intCheckoutId = @intCheckoutId 
	AND
	a.intCategoryId IN
	(CASE WHEN st.strDepartmentOrCategory = 'C' AND st.strCategoriesOrSubcategories = 'C' 
		THEN 
			(
				SELECT		intCategoryId
				FROM		tblSTStoreDepartments
				WHERE		intStoreId IN (SELECT ISNULL(intStoreId,0) FROM tblSTCheckoutHeader WHERE intCheckoutId = @intCheckoutId)
			
			)
	WHEN st.strDepartmentOrCategory = 'D' AND st.strCategoriesOrSubcategories = 'C' 
		THEN
			(
				SELECT      intCategoryId 
				FROM        tblSTPumpItem
				WHERE       intStoreId IN (SELECT intStoreId FROM tblSTCheckoutHeader WHERE intCheckoutId = @intCheckoutId)
			)
	END)
	OR
	a.intSubcategoriesId IN
	(CASE WHEN st.strDepartmentOrCategory = 'C' AND st.strCategoriesOrSubcategories = 'S' 
		THEN 
			(
				SELECT		intSubcategoriesId
				FROM		tblSTStoreDepartments
				WHERE		intStoreId IN (SELECT ISNULL(intStoreId,0) FROM tblSTCheckoutHeader WHERE intCheckoutId = @intCheckoutId)
			
			)
	WHEN st.strDepartmentOrCategory = 'D' AND st.strCategoriesOrSubcategories = 'S' 
		THEN
			(
				SELECT      intCategoryId 
				FROM        tblSTPumpItem
				WHERE       intStoreId IN (SELECT intStoreId FROM tblSTCheckoutHeader WHERE intCheckoutId = @intCheckoutId)
			)
	END)

    RETURN      @dblDepartmentTotalsForFuel
END