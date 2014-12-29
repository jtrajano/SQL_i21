
-- This function calculates the average cost of an item. 
CREATE FUNCTION [dbo].[fnRecalculateAverageCost]
(
	@intItemId AS INT 
	,@intLocationId AS INT 
)
RETURNS NUMERIC(18,6)
AS
BEGIN
	-- Create the CONSTANT variables for the costing methods
	DECLARE @AVERAGECOST AS INT = 1
		,@FIFO AS INT = 2
		,@LIFO AS INT = 3
		,@STANDARDCOST AS INT = 4 	

	DECLARE @TotalQty AS NUMERIC(18,6)
	DECLARE @TotalValue AS NUMERIC(18,6)

	-- Recalculate the average cost from the fifo table 	
	BEGIN 
		SELECT	@TotalQty = SUM( CASE WHEN (ISNULL(fifo.dblStockIn, 0) - ISNULL(fifo.dblStockOut, 0)) > 0 THEN (ISNULL(fifo.dblStockIn, 0) - ISNULL(fifo.dblStockOut, 0)) ELSE 0 END )
				,@TotalValue = SUM( CASE WHEN (ISNULL(fifo.dblStockIn, 0) - ISNULL(fifo.dblStockOut, 0)) > 0 THEN (ISNULL(fifo.dblStockIn, 0) - ISNULL(fifo.dblStockOut, 0)) * ISNULL(fifo.dblCost,0) ELSE 0 END )
		FROM	dbo.tblICInventoryFIFO fifo 
		WHERE	dbo.fnGetCostingMethod(fifo.intItemId, fifo.intLocationId) IN (@AVERAGECOST, @FIFO, @STANDARDCOST)
				AND fifo.intItemId = @intItemId
				AND fifo.intLocationId = @intLocationId
	END 

	-- If the fifo table yield a null result, assume the item's costing method is LIFO. 
	-- Recaculate the average cost from the lifo table
	IF (@TotalQty IS NULL) 
	BEGIN 
		SELECT	@TotalQty = SUM( CASE WHEN (ISNULL(lifo.dblStockIn, 0) - ISNULL(lifo.dblStockOut, 0)) > 0 THEN (ISNULL(lifo.dblStockIn, 0) - ISNULL(lifo.dblStockOut, 0)) ELSE 0 END )
				,@TotalValue = SUM( CASE WHEN (ISNULL(lifo.dblStockIn, 0) - ISNULL(lifo.dblStockOut, 0)) > 0 THEN (ISNULL(lifo.dblStockIn, 0) - ISNULL(lifo.dblStockOut, 0)) * ISNULL(lifo.dblCost,0) ELSE 0 END )
		FROM	dbo.tblICInventoryLIFO lifo	
	END 

	-- Return recalculated average cost. 
	RETURN @TotalValue / @TotalQty;

END