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
	DECLARE		@ysnHasBlendedItem BIT = 0
	DECLARE		@intItemUOMIdOfBlendedItem INT = 0
	DECLARE		@ysnBlendPercentage DECIMAL(18,6) = 0
	DECLARE		@ysnBlendQty DECIMAL(18,6) = 0

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

	SELECT		@ysnHasBlendedItem = 1
	FROM		tblSTStore a
	INNER JOIN	tblSTCheckoutHeader b
	ON			a.intStoreId = b.intStoreId
	INNER JOIN	tblSTCheckoutPumpTotals c
	ON			b.intCheckoutId = c.intCheckoutId
	INNER JOIN	tblICItemUOM d
	ON			c.intPumpCardCouponId = d.intItemUOMId
	INNER JOIN	tblICItem e
	ON			d.intItemId = e.intItemId
	WHERE		b.dtmCheckoutDate = @dtmDate AND
				a.intCompanyLocationId = @intLocationId AND
				e.ysnAutoBlend = 1

	IF @ysnHasBlendedItem = 1
	BEGIN
		SELECT		@intItemUOMIdOfBlendedItem = a.intItemUOMId,
					@ysnBlendPercentage = b.dblQuantity
		FROM		tblMFRecipe a
		INNER JOIN	tblMFRecipeItem b
		ON			a.intRecipeId = b.intRecipeId
		WHERE		a.intLocationId = @intLocationId AND
					b.intItemUOMId = @intItemUOMId AND
					b.intRecipeItemTypeId = 1 AND --means input
					a.ysnActive = 1

		SELECT		@ysnBlendQty = c.dblQuantity
		FROM		tblSTStore a
		INNER JOIN	tblSTCheckoutHeader b
		ON			a.intStoreId = b.intStoreId
		INNER JOIN	tblSTCheckoutPumpTotals c
		ON			b.intCheckoutId = c.intCheckoutId
		WHERE		c.intPumpCardCouponId = @intItemUOMIdOfBlendedItem AND
					b.dtmCheckoutDate = @dtmDate AND
					a.intCompanyLocationId = @intLocationId

		SET	@ysnBlendQty = @ysnBlendQty * @ysnBlendPercentage
	END

	SELECT		@dblReturnValue = c.dblQuantity
	FROM		tblSTStore a
	INNER JOIN	tblSTCheckoutHeader b
	ON			a.intStoreId = b.intStoreId
	INNER JOIN	tblSTCheckoutPumpTotals c
	ON			b.intCheckoutId = c.intCheckoutId
	WHERE		c.intPumpCardCouponId = @intItemUOMId AND
				b.dtmCheckoutDate = @dtmDate AND
				a.intCompanyLocationId = @intLocationId
	
	RETURN @dblReturnValue + @ysnBlendQty
END
GO