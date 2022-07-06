CREATE FUNCTION [dbo].[fnICGetPromotionalCostByEffectiveDate] (
	@intItemId INT,
	@intItemLocationId INT,
	@intItemUnitMeasureId INT,
	@dtmTransactionDate DATETIME
)
RETURNS NUMERIC(18, 6)
AS
BEGIN 
	
	DECLARE @dblPromotionalCost AS NUMERIC(18, 6)

	SELECT TOP 1 @dblPromotionalCost = dblCost 
	FROM tblICItemSpecialPricing
	WHERE intItemId = @intItemId
		AND intItemLocationId = @intItemLocationId
		AND intItemUnitMeasureId = @intItemUnitMeasureId
		AND 
		(
			dtmBeginDate <= @dtmTransactionDate AND
			dtmEndDate >= @dtmTransactionDate
		)

	RETURN @dblPromotionalCost

END 
