
-- This function calculates the average cost of an item. 
CREATE FUNCTION [dbo].[fnCalculateAverageCost]
(
	@Qty AS FLOAT
	,@Cost AS FLOAT
	,@StockOnHandQty AS FLOAT
	,@StockAverageCost AS FLOAT
)
RETURNS NUMERIC(18,6)
AS
BEGIN
	-- If qty is negative (reduce stock), return the same average cost. 
	IF ISNULL(@Qty, 0) < 0
		RETURN @StockAverageCost;

	-- If qty is postive (increase stock) but overall stock qty is remain zero or negative, return cost. 
	IF ISNULL(@Qty, 0) > 0 AND ISNULL(@Qty, 0) + ISNULL(@StockOnHandQty, 0) <= 0
		RETURN @Cost;

	-- If overall stock qty will be positive, return a new average cost based on the calculations below
	RETURN 
		(
			(ISNULL(@Qty, 0) * ISNULL(@Cost, 0)) + (ISNULL(@StockOnHandQty, 0) * ISNULL(@StockAverageCost, 0)) 
		)		
		/ (
			ISNULL(@Qty, 0) + ISNULL(@StockOnHandQty, 0)
		); 
END