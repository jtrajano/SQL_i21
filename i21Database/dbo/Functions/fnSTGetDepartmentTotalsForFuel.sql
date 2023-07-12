CREATE FUNCTION [dbo].[fnSTGetDepartmentTotalsForFuel] 
(
	@intCheckoutId AS INT
)
RETURNS DECIMAL(18,2)
AS BEGIN

	DECLARE     @dblDepartmentTotalsForFuel DECIMAL(18,2) = 0

	SELECT      @dblDepartmentTotalsForFuel = ISNULL(SUM(dblTotalSalesAmountComputed),0)
	FROM        tblSTCheckoutDepartmetTotals a
	JOIN		tblSTCheckoutHeader ch
	ON			a.intCheckoutId = ch.intCheckoutId
	LEFT JOIN	tblICItem b
	ON          a.intItemId = b.intItemId
	JOIN		tblSTStoreDepartments sdc
	ON			(a.intCategoryId = sdc.intCategoryId OR a.intSubcategoriesId = sdc.intSubcategoriesId)
	AND			ch.intStoreId = sdc.intStoreId
	AND			a.strRegisterCode = sdc.strRegisterCode
	WHERE       a.intCheckoutId = @intCheckoutId 
	AND         sdc.ysnFuelCategory = 1

    RETURN      @dblDepartmentTotalsForFuel

END