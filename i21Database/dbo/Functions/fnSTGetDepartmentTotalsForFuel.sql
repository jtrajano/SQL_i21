CREATE FUNCTION [dbo].[fnSTGetDepartmentTotalsForFuel] 
(
	@intCheckoutId AS INT
)
RETURNS DECIMAL(18,2)
AS BEGIN

	DECLARE     @dblDepartmentTotalsForFuel DECIMAL(18,2)	= 0
	DECLARE     @dblOutsideDiscount			DECIMAL(18,2)	= (SELECT dblEditableOutsideFuelDiscount FROM tblSTCheckoutHeader WHERE intCheckoutId = @intCheckoutId)
	DECLARE     @intStoreId					INT				= (SELECT intStoreId FROM tblSTCheckoutHeader WHERE intCheckoutId = @intCheckoutId)	
	DECLARE     @intRegisterId				INT				= (SELECT intRegisterId FROM tblSTStore WHERE intStoreId = @intStoreId)
	DECLARE     @strRegisterClass			NVARCHAR(250)	= (SELECT strRegisterClass FROM tblSTRegister WHERE intRegisterId = @intRegisterId)

	IF @strRegisterClass = 'PASSPORT'
	BEGIN
		SELECT      @dblDepartmentTotalsForFuel = (ISNULL(SUM(dblTotalSalesAmountComputed),0) - ISNULL(SUM(@dblOutsideDiscount),0))
		FROM        tblSTCheckoutDepartmetTotals a
		JOIN		tblSTCheckoutHeader ch
		ON			a.intCheckoutId = ch.intCheckoutId
		LEFT JOIN	tblICItem b
		ON          a.intItemId = b.intItemId
		-- CS-668
		JOIN		tblSTStoreDepartments sdc
		ON			(a.intCategoryId = sdc.intCategoryId OR a.intSubcategoriesId = sdc.intSubcategoriesId)
		AND			ch.intStoreId = sdc.intStoreId
		AND			a.strRegisterCode = sdc.strRegisterCode
		WHERE       a.intCheckoutId = @intCheckoutId 
		AND         sdc.ysnFuelCategory = 1
		-- CS-668
	END
	ELSE
	BEGIN
		SELECT      @dblDepartmentTotalsForFuel = ISNULL(SUM(dblTotalSalesAmountComputed),0)
		FROM        tblSTCheckoutDepartmetTotals a
		JOIN		tblSTCheckoutHeader ch
		ON			a.intCheckoutId = ch.intCheckoutId
		LEFT JOIN	tblICItem b
		ON          a.intItemId = b.intItemId
		-- CS-668
		JOIN		tblSTStoreDepartments sdc
		ON			(a.intCategoryId = sdc.intCategoryId OR a.intSubcategoriesId = sdc.intSubcategoriesId)
		AND			ch.intStoreId = sdc.intStoreId
		AND			a.strRegisterCode = sdc.strRegisterCode
		WHERE       a.intCheckoutId = @intCheckoutId 
		AND         sdc.ysnFuelCategory = 1
		-- CS-668
	END	

    RETURN      @dblDepartmentTotalsForFuel

END