-- This function recalculates the average cost of an item from positive stock records
CREATE FUNCTION [dbo].[fnGRGetitemAverageCostAsOfDate]
(
	@intItemId AS INT 
	,@intItemLocationId AS INT
	,@dtmDate DATETIME
)
RETURNS NUMERIC(38,20)
AS
BEGIN
	DECLARE @dblTotalQty AS NUMERIC(38, 20)
			,@dblTotalInventoryValue AS NUMERIC(38, 20) 
			,@newAverageCost AS NUMERIC(38, 20) 
	 
	SELECT	@dblTotalQty = 
				ROUND(
					SUM(dbo.fnCalculateStockUnitQty(dblQty, dblUOMQty))
					, 6
				) 
			,@dblTotalInventoryValue = 
				ROUND(
					--SUM(dbo.fnMultiply(dblQty, dblCost) + ISNULL(dblValue, 0))	
					SUM(dblComputedValue) 
					,6
				)
	FROM	dbo.tblICInventoryTransaction
	WHERE	intItemId = @intItemId
			AND intItemLocationId = @intItemLocationId
            AND dtmDate <= @dtmDate

	SET @newAverageCost = 
		CASE	WHEN @dblTotalQty <> 0 AND @dblTotalInventoryValue > 0 THEN 
					dbo.fnDivide(@dblTotalInventoryValue, @dblTotalQty) 
				WHEN @dblTotalInventoryValue <= 0 THEN 
					NULL 
				ELSE 
					NULL 
		END 
	
	IF @newAverageCost < 0 SET @newAverageCost = NULL 
	RETURN @newAverageCost;
END