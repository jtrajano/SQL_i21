-- This function recalculates the average cost of an item from positive stock records
CREATE FUNCTION [dbo].[fnRecalculateAverageCost]
(
	@intItemId AS INT 
	,@intItemLocationId AS INT 
)
RETURNS NUMERIC(38,20)
AS
BEGIN
	DECLARE @dblTotalQty AS NUMERIC(38, 20)
			,@dblTotalInventoryValue AS NUMERIC(38, 20) 
	 
	SELECT	@dblTotalQty = SUM(dbo.fnCalculateStockUnitQty(dblQty, dblUOMQty)) 
			,@dblTotalInventoryValue = SUM(
					dbo.fnMultiply(
						dbo.fnCalculateStockUnitQty(dblQty, dblUOMQty)
						,dbo.fnCalculateUnitCost(dblCost, dblUOMQty)
					)
					+ ISNULL(dblValue, 0)			
				)
	FROM	dbo.tblICInventoryTransaction
	WHERE	intItemId = @intItemId
			AND intItemLocationId = @intItemLocationId

	RETURN (
		CASE	WHEN @dblTotalQty <> 0 AND @dblTotalInventoryValue > 0 THEN 
					dbo.fnDivide(@dblTotalInventoryValue, @dblTotalQty) 
				WHEN @dblTotalInventoryValue <= 0 THEN 
					NULL 
				ELSE 
					NULL 
		END 	
		
	)

END