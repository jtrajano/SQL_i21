CREATE FUNCTION [dbo].[fnTMGetSalesFromStoreEOD]
(
	@dtmDate				DATETIME,
	@intSiteId				INT
)
RETURNS DECIMAL(18,6)
BEGIN
	DECLARE		@dblReturnValue DECIMAL(18,6) = 0
	DECLARE		@intItemId INT = 0
	DECLARE		@intItemUOMId INT = 0
	DECLARE		@intLocationId INT = 0

	SELECT		@intItemId = z.intProduct,
				@intLocationId = z.intLocationId
	FROM		tblSTStore x
	INNER JOIN	tblSTStoreFuelTanks y
	ON			x.intStoreId = y.intStoreId
	INNER JOIN	tblTMSite z
	ON			x.intCompanyLocationId = z.intLocationId AND 
				z.intSiteID = @intSiteId AND
				z.ysnCompanySite = 1

	--GET ITEM UOM ID 
	SELECT		@intItemUOMId = intItemUOMId
	FROM		tblICItemUOM
	WHERE		intItemId = @intItemId AND
				intUnitMeasureId = 2 --2 means gallons

	SELECT		@dblReturnValue = c.dblQuantity
	FROM		tblSTStore a
	INNER JOIN	tblSTCheckoutHeader b
	ON			a.intStoreId = b.intStoreId
	INNER JOIN	tblSTCheckoutPumpTotals c
	ON			b.intCheckoutId = c.intCheckoutId
	WHERE		c.intPumpCardCouponId = @intItemUOMId AND
				b.dtmCheckoutDate = @dtmDate AND
				a.intCompanyLocationId = @intLocationId
	
	RETURN @dblReturnValue
END
GO