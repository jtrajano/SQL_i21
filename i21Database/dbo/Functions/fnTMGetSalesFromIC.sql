CREATE FUNCTION [dbo].[fnTMGetSalesFromIC]
(
	@dtmDate				DATETIME,
	@intSiteId				INT
)
RETURNS DECIMAL(18,6)
BEGIN
	DECLARE		@dblReturnValue DECIMAL(18,6) = 0
	DECLARE		@intItemId INT = 0
	DECLARE		@intLocationId INT = 0

	SELECT		@intItemId = intProduct,
				@intLocationId = intLocationId
	FROM		tblTMSite
	WHERE		intSiteID = @intSiteId

	SELECT		@dblReturnValue = SUM(dblQuantity) 
	FROM		vyuICGetInventoryValuation
	WHERE		intItemId = @intItemId AND
				intLocationId = @intLocationId AND
				dblQuantity < 0 AND --meaning outgoing
				(dtmCreated >= @dtmDate AND dtmCreated < DATEADD(DAY, 1, @dtmDate))

	RETURN @dblReturnValue
END
GO