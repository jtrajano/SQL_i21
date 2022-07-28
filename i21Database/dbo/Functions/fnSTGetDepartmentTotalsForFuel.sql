CREATE FUNCTION [dbo].[fnSTGetDepartmentTotalsForFuel] 
(
	@intCheckoutId AS INT
)
RETURNS DECIMAL(18,2)
AS BEGIN

    DECLARE     @dblDepartmentTotalsForFuel DECIMAL(18,2) = 0

    SELECT      @dblDepartmentTotalsForFuel = ISNULL(SUM(dblTotalSalesAmountComputed),0)
    FROM        tblSTCheckoutDepartmetTotals a
    INNER JOIN  tblICItem b
    ON          a.intItemId = b.intItemId
    WHERE       a.intCheckoutId = @intCheckoutId AND
                b.ysnFuelItem = 1

    RETURN      @dblDepartmentTotalsForFuel
END