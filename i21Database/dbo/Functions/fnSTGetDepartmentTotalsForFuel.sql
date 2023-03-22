CREATE FUNCTION [dbo].[fnSTGetDepartmentTotalsForFuel] 
(
	@intCheckoutId AS INT
)
RETURNS DECIMAL(18,2)
AS BEGIN

    DECLARE     @dblDepartmentTotalsForFuel DECIMAL(18,2) = 0

    SELECT      @dblDepartmentTotalsForFuel = ISNULL(SUM(dblTotalSalesAmountComputed),0)
    FROM        tblSTCheckoutDepartmetTotals a
    LEFT JOIN  tblICItem b
    ON          a.intItemId = b.intItemId
    WHERE       a.intCheckoutId = @intCheckoutId AND
				(
				a.intCategoryId IN (    SELECT      intCategoryId 
                                        FROM        tblSTPumpItem
									    WHERE       intStoreId IN (SELECT intStoreId FROM tblSTCheckoutHeader WHERE intCheckoutId = @intCheckoutId))
				OR
				a.intSubcategoriesId IN (
										SELECT		intSubcategoriesId
										FROM		tblSTStoreDepartments
										WHERE		intStoreId IN (SELECT intStoreId FROM tblSTCheckoutHeader WHERE intCheckoutId = @intCheckoutId))
				)

    RETURN      @dblDepartmentTotalsForFuel
END