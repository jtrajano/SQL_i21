CREATE FUNCTION [dbo].[fnGetItemTotalValueFromAVGTransactions]
(
	@intItemId INT
	,@intItemLocationId INT
)
RETURNS NUMERIC(38,20)
AS 
BEGIN 
	DECLARE @totalItemValuation AS NUMERIC(38,20)

	DECLARE 
		@AVERAGE_COST AS INT = 1
		,@FIFO AS INT = 2
		,@LIFO AS INT = 3
		,@LOT_COST AS INT = 4
		,@ACTUAL_COST AS INT = 5

	-- Get the total transaction value of an item per location. 
	SELECT	@totalItemValuation = SUM(
				dbo.fnCalculateStockUnitQty(A.dblQty, A.dblUOMQty) 
				* dbo.fnCalculateUnitCost(A.dblCost, A.dblUOMQty)
				+ ISNULL(A.dblValue, 0)
			) 
	FROM	[dbo].[tblICInventoryTransaction] A
	WHERE	A.intItemId = @intItemId
			AND A.intItemLocationId = @intItemLocationId
			AND (A.strActualCostId IS NULL OR A.intCostingMethod = @AVERAGE_COST)

	RETURN ISNULL(@totalItemValuation, 0)
END
GO