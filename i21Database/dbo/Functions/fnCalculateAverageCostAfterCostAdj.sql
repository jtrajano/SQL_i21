
-- This function calculates a new average cost after a cost adjustment.
CREATE FUNCTION [dbo].[fnCalculateAverageCostAfterCostAdj]
(
	@UnsoldQty AS NUMERIC(38,20)
	,@CostDifference AS NUMERIC(38,20)
	,@RunningQty AS NUMERIC(38,20)
	,@CurrentAverageCost AS NUMERIC(38,20)
)
RETURNS NUMERIC(38,20)
AS
BEGIN
	DECLARE @calculatedValue AS NUMERIC(38,20)

	IF ISNULL(@RunningQty, 0) <= 0 
		RETURN @CurrentAverageCost
	
	SET @calculatedValue = 
		dbo.fnDivide(
			dbo.fnMultiply(@UnsoldQty, @CostDifference)
			,@RunningQty
		)
		+ @CurrentAverageCost 

	RETURN @calculatedValue; 
END