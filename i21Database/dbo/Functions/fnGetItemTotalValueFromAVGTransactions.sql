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
				ROUND(
					dbo.fnMultiply(A.dblQty, A.dblCost) + ISNULL(A.dblValue, 0)
					,2 
				)
			) 
	FROM	[dbo].[tblICInventoryTransaction] A
	WHERE	A.intItemId = @intItemId
			AND A.intItemLocationId = @intItemLocationId
			AND (A.strActualCostId IS NULL OR ISNULL(A.intCostingMethod, @AVERAGE_COST) = @AVERAGE_COST)

	RETURN ISNULL(@totalItemValuation, 0)
END