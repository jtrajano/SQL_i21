-- This function calculates the average cost of an item. 
CREATE FUNCTION [dbo].[fnCalculateAverageCost]
(
	@Qty AS NUMERIC(38, 20)
	,@Cost AS NUMERIC(38, 20)
	,@StockOnHandQty AS NUMERIC(38, 20)
	,@StockAverageCost AS NUMERIC(38, 20)
)
RETURNS NUMERIC(38,20)
AS
BEGIN
	-- If qty is negative or zero (as to reduce stock), return the same average cost. 
	IF ISNULL(@Qty, 0) <= 0
		RETURN @StockAverageCost;

	-- If qty is positive (as to increase stock) but stock qty was zero or negative, return cost as the new average cost. 
	IF ISNULL(@Qty, 0) > 0 AND ISNULL(@StockOnHandQty, 0) <= 0
		RETURN @Cost;		

	-- If qty is postive (as to increase stock) but overall stock qty will remain zero or negative, return cost as the new average cost. 
	IF ISNULL(@Qty, 0) > 0 AND ISNULL(@Qty, 0) + ISNULL(@StockOnHandQty, 0) <= 0
		RETURN @Cost;

	-- If overall stock qty will be positive, return a new average cost based on the calculations below
	RETURN dbo.fnDivide (
			dbo.fnMultiply(@Qty, @Cost) + dbo.fnMultiply(@StockOnHandQty, @StockAverageCost)
			,ISNULL(@Qty, 0) + ISNULL(@StockOnHandQty, 0)
	); 
END