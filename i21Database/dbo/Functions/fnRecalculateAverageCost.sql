-- This function recalculates the average cost of an item from positive stock records
CREATE FUNCTION [dbo].[fnRecalculateAverageCost]
(
	@intItemId AS INT 
	,@intItemLocationId AS INT 
	,@StockAverageCost AS FLOAT
)
RETURNS NUMERIC(18,6)
AS
BEGIN
	-- Create the CONSTANT variables for the costing methods
	DECLARE @AVERAGECOST AS INT = 1
		,@FIFO AS INT = 2
		,@LIFO AS INT = 3
		,@STANDARDCOST AS INT = 4 	
		,@LOTCOST AS INT = 5

	DECLARE @TotalQty AS NUMERIC(18,6)
	DECLARE @TotalValue AS NUMERIC(18,6)
	
	IF EXISTS (SELECT 1 WHERE dbo.fnGetCostingMethod(@intItemId, @intItemLocationId) IN (@AVERAGECOST, @FIFO, @STANDARDCOST))
	BEGIN 
		-- Recalculate the average cost from the fifo table 	
		SELECT	@TotalQty = SUM(ISNULL(fifo.dblStockIn, 0) - ISNULL(fifo.dblStockOut, 0))
				,@TotalValue = SUM( (ISNULL(fifo.dblStockIn, 0) - ISNULL(fifo.dblStockOut, 0)) * ISNULL(fifo.dblCost,0))
		FROM	dbo.tblICInventoryFIFO fifo 
		WHERE	fifo.intItemId = @intItemId
				AND fifo.intItemLocationId = @intItemLocationId
				AND ISNULL(fifo.dblStockIn, 0) - ISNULL(fifo.dblStockOut, 0) > 0	
	END 
	ELSE IF EXISTS (SELECT 1 WHERE dbo.fnGetCostingMethod(@intItemId, @intItemLocationId) IN (@LIFO))
	BEGIN 
		-- Recalculate the average cost from the lifo table
		SELECT	@TotalQty = SUM(ISNULL(lifo.dblStockIn, 0) - ISNULL(lifo.dblStockOut, 0))
				,@TotalValue = SUM( (ISNULL(lifo.dblStockIn, 0) - ISNULL(lifo.dblStockOut, 0)) * ISNULL(lifo.dblCost,0))
		FROM	dbo.tblICInventoryLIFO lifo	
		WHERE	lifo.intItemId = @intItemId
				AND lifo.intItemLocationId = @intItemLocationId
				AND ISNULL(lifo.dblStockIn, 0) - ISNULL(lifo.dblStockOut, 0) > 0	
	END 
	ELSE 
	BEGIN 
		-- Recalculate the average cost from the lot table
		SELECT	@TotalQty = SUM(ISNULL(Lot.dblStockIn, 0) - ISNULL(Lot.dblStockOut, 0))
				,@TotalValue = SUM( (ISNULL(Lot.dblStockIn, 0) - ISNULL(Lot.dblStockOut, 0)) * ISNULL(Lot.dblCost,0))
		FROM	dbo.tblICInventoryLot Lot
		WHERE	Lot.intItemId = @intItemId
				AND Lot.intItemLocationId = @intItemLocationId
				AND ISNULL(Lot.dblStockIn, 0) - ISNULL(Lot.dblStockOut, 0) > 0	
	END 

	-- Return recalculated average cost. 
	RETURN ISNULL(@TotalValue / @TotalQty, @StockAverageCost);
END