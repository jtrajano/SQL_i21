
-- This function calculates a new average cost after a cost adjustment.
CREATE FUNCTION [dbo].[fnCalculateAverageCostAfterCostAdj]
(
	@UnsoldQty AS NUMERIC(18,6)
	,@CostDifference AS NUMERIC(38,20)
	,@RunningQty AS NUMERIC(18,6)
	,@CurrentAverageCost AS NUMERIC(38,20)
)
RETURNS NUMERIC(38,20)
AS
BEGIN
	IF ISNULL(@RunningQty, 0) <= 0 
		RETURN @CurrentAverageCost
	
	RETURN @UnsoldQty * @CostDifference / @RunningQty + @CurrentAverageCost
END