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
	-- Declare the costing methods
	DECLARE @AVERAGECOST AS INT = 1
			,@FIFO AS INT = 2
			,@LIFO AS INT = 3
			,@LOTCOST AS INT = 4 	
			,@ACTUALCOST AS INT = 5	

	DECLARE @TotalQty AS NUMERIC(18,6)
	DECLARE @TotalValue AS NUMERIC(18,6)

	DECLARE @ActualCostQty AS NUMERIC(18,6)
	DECLARE @ActualCostValue AS NUMERIC(18,6)

	
	IF EXISTS (SELECT 1 WHERE dbo.fnGetCostingMethod(@intItemId, @intItemLocationId) IN (@AVERAGECOST, @FIFO))
	BEGIN 
		-- Recalculate the average cost from the fifo table 	
		SELECT	@TotalQty = SUM (
					dbo.fnCalculateStockUnitQty(fifo.dblStockIn, ItemUOM.dblUnitQty)
					- dbo.fnCalculateStockUnitQty(fifo.dblStockOut, ItemUOM.dblUnitQty)
				)					
				,@TotalValue = SUM (
					(
						dbo.fnCalculateStockUnitQty(fifo.dblStockIn, ItemUOM.dblUnitQty)
						- dbo.fnCalculateStockUnitQty(fifo.dblStockOut, ItemUOM.dblUnitQty)
					)
					* dbo.fnCalculateUnitCost(fifo.dblCost, ItemUOM.dblUnitQty)				
				)

		FROM	dbo.tblICInventoryFIFO fifo INNER JOIN dbo.tblICItemUOM ItemUOM
					ON fifo.intItemUOMId = ItemUOM.intItemUOMId
		WHERE	fifo.intItemId = @intItemId
				AND fifo.intItemLocationId = @intItemLocationId
				AND ISNULL(fifo.dblStockIn, 0) - ISNULL(fifo.dblStockOut, 0) > 0	

		-- Recalculate the average cost from the actual cost table 	
		SELECT	@ActualCostQty = SUM (
					dbo.fnCalculateStockUnitQty(actualCost.dblStockIn, ItemUOM.dblUnitQty)
					- dbo.fnCalculateStockUnitQty(actualCost.dblStockOut, ItemUOM.dblUnitQty)
				)					
				,@ActualCostValue = SUM (
					(
						dbo.fnCalculateStockUnitQty(actualCost.dblStockIn, ItemUOM.dblUnitQty)
						- dbo.fnCalculateStockUnitQty(actualCost.dblStockOut, ItemUOM.dblUnitQty)
					)
					* dbo.fnCalculateUnitCost(actualCost.dblCost, ItemUOM.dblUnitQty)				
				)

		FROM	dbo.tblICInventoryActualCost actualCost INNER JOIN dbo.tblICItemUOM ItemUOM
					ON actualCost.intItemUOMId = ItemUOM.intItemUOMId
		WHERE	actualCost.intItemId = @intItemId
				AND actualCost.intItemLocationId = @intItemLocationId
				AND ISNULL(actualCost.dblStockIn, 0) - ISNULL(actualCost.dblStockOut, 0) > 0	

		SET @TotalQty = ISNULL(@TotalQty, 0) + ISNULL(@ActualCostQty, 0)
		SET @TotalValue = ISNULL(@TotalValue, 0) + ISNULL(@ActualCostValue, 0)

	END 
	ELSE IF EXISTS (SELECT 1 WHERE dbo.fnGetCostingMethod(@intItemId, @intItemLocationId) IN (@LIFO))
	BEGIN 
		-- Recalculate the average cost from the lifo table
		SELECT	
				@TotalQty = SUM (
					dbo.fnCalculateStockUnitQty(lifo.dblStockIn, ItemUOM.dblUnitQty)
					- dbo.fnCalculateStockUnitQty(lifo.dblStockOut, ItemUOM.dblUnitQty)
				)					
				,@TotalValue = SUM (
					(
						dbo.fnCalculateStockUnitQty(lifo.dblStockIn, ItemUOM.dblUnitQty)
						- dbo.fnCalculateStockUnitQty(lifo.dblStockOut, ItemUOM.dblUnitQty)
					)
					* dbo.fnCalculateUnitCost(lifo.dblCost, ItemUOM.dblUnitQty)				
				)

		FROM	dbo.tblICInventoryLIFO lifo	INNER JOIN dbo.tblICItemUOM ItemUOM
					ON lifo.intItemUOMId = ItemUOM.intItemUOMId
		WHERE	lifo.intItemId = @intItemId
				AND lifo.intItemLocationId = @intItemLocationId
				AND ISNULL(lifo.dblStockIn, 0) - ISNULL(lifo.dblStockOut, 0) > 0	

		-- Recalculate the average cost from the actual cost table 	
		SELECT	@ActualCostQty = SUM (
					dbo.fnCalculateStockUnitQty(actualCost.dblStockIn, ItemUOM.dblUnitQty)
					- dbo.fnCalculateStockUnitQty(actualCost.dblStockOut, ItemUOM.dblUnitQty)
				)					
				,@ActualCostValue = SUM (
					(
						dbo.fnCalculateStockUnitQty(actualCost.dblStockIn, ItemUOM.dblUnitQty)
						- dbo.fnCalculateStockUnitQty(actualCost.dblStockOut, ItemUOM.dblUnitQty)
					)
					* dbo.fnCalculateUnitCost(actualCost.dblCost, ItemUOM.dblUnitQty)				
				)

		FROM	dbo.tblICInventoryActualCost actualCost INNER JOIN dbo.tblICItemUOM ItemUOM
					ON actualCost.intItemUOMId = ItemUOM.intItemUOMId
		WHERE	actualCost.intItemId = @intItemId
				AND actualCost.intItemLocationId = @intItemLocationId
				AND ISNULL(actualCost.dblStockIn, 0) - ISNULL(actualCost.dblStockOut, 0) > 0	

		SET @TotalQty = ISNULL(@TotalQty, 0) + ISNULL(@ActualCostQty, 0)
		SET @TotalValue = ISNULL(@TotalValue, 0) + ISNULL(@ActualCostValue, 0)

	END 
	ELSE 
	BEGIN 
		-- Recalculate the average cost from the lot table
		SELECT	
				@TotalQty = SUM (
					dbo.fnCalculateStockUnitQty(Lot.dblStockIn, ItemUOM.dblUnitQty)
					- dbo.fnCalculateStockUnitQty(Lot.dblStockOut, ItemUOM.dblUnitQty)
				)					
				,@TotalValue = SUM (
					(
						dbo.fnCalculateStockUnitQty(Lot.dblStockIn, ItemUOM.dblUnitQty)
						- dbo.fnCalculateStockUnitQty(Lot.dblStockOut, ItemUOM.dblUnitQty)
					)
					* dbo.fnCalculateUnitCost(Lot.dblCost, ItemUOM.dblUnitQty)				
				)

		FROM	dbo.tblICInventoryLot Lot INNER JOIN dbo.tblICItemUOM ItemUOM
					ON Lot.intItemUOMId = ItemUOM.intItemUOMId
		WHERE	Lot.intItemId = @intItemId
				AND Lot.intItemLocationId = @intItemLocationId
				AND ISNULL(Lot.dblStockIn, 0) - ISNULL(Lot.dblStockOut, 0) > 0	
	END 

	-- Return recalculated average cost. 
	RETURN ISNULL(@TotalValue / @TotalQty, @StockAverageCost);
END