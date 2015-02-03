CREATE FUNCTION [dbo].[fnGetItemTotalValueFromTransactions]
(
	@intItemId INT
	,@intItemLocationId INT
)
RETURNS NUMERIC(18,6)
AS 
BEGIN 
	DECLARE @Value AS NUMERIC(18,6)

	-- Get the total transaction value of an item per location. 
	SELECT	@Value = SUM(ISNULL(A.dblUnitQty, 0) * ISNULL(A.dblCost, 0) + ISNULL(A.dblValue, 0)) 
	FROM	[dbo].[tblICInventoryTransaction] A
	WHERE	A.intItemId = @intItemId
			AND A.intItemLocationId = @intItemLocationId

	RETURN ISNULL(@Value, 0)
END
GO