
-- This function calculates a new average cost after a cost adjustment.
CREATE FUNCTION [dbo].[fnCalculateAverageCostAfterCostAdj]
(
	@UnsoldQty AS NUMERIC(38,20)
	,@CostDifference AS NUMERIC(38,20)
	,@RunningQty AS NUMERIC(18,6)
	,@CurrentAverageCost AS NUMERIC(38,20)
)
RETURNS NUMERIC(38,20)
AS
BEGIN
	DECLARE @calculatedValue AS FLOAT 

	IF ISNULL(@RunningQty, 0) <= 0 
		RETURN @CurrentAverageCost
	
	SET @calculatedValue = 
		CAST(@UnsoldQty AS FLOAT) * 
		CAST(@CostDifference AS FLOAT) / 
		CAST(@RunningQty AS FLOAT) 
		+ CAST(@CurrentAverageCost AS FLOAT) 

	RETURN dbo.fnConvertFloatToNumeric(@calculatedValue); 
END