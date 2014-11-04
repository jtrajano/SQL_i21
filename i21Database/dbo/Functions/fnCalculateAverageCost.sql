
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
	-- If overall stock qty will become zero, return the same average cost. 
	IF ISNULL(@Qty, 0) + ISNULL(@StockOnHandQty, 0) = 0 
		RETURN @StockAverageCost;  
	
	-- If qty is negative (reduce stock), return the same average cost. 
	IF ISNULL(@Qty, 0) < 0
		RETURN @StockAverageCost;  

	-- If qty is positive (increase stock), calculate a new average cost. 
	RETURN 
		(
			(ISNULL(@Qty, 0) * ISNULL(@Cost, 0)) + (ISNULL(@StockOnHandQty, 0) * ISNULL(@StockAverageCost, 0)) 
		)		
		/ (
			ISNULL(@Qty, 0) + ISNULL(@StockOnHandQty, 0)
		); 
END