CREATE FUNCTION [dbo].[fnICGetRunningBalance] (
	@intInventoryTransactionId INT
)
RETURNS NUMERIC(38,20)
AS
BEGIN 
	
	DECLARE @returnBalance AS NUMERIC(38,20)
	DECLARE @intItemId AS INT,
			@intItemLocationId AS INT,
			@dtmDate DATETIME

	SELECT	@intItemId = intItemId,
			@intItemLocationId = intItemLocationId,
			@dtmDate = dtmDate
	FROM	tblICInventoryTransaction
	WHERE	intInventoryTransactionId = @intInventoryTransactionId

	SELECT	@returnBalance = SUM (
				ISNULL(dblQty, 0) 
				* ISNULL(dblCost, 0) 
				+ ISNULL(dblValue, 0)
			) 
	FROM	tblICInventoryTransaction
	WHERE	@intItemId = intItemId 
			AND @intItemLocationId = intItemLocationId 
			AND dtmDate <= @dtmDate 
			AND intInventoryTransactionId <= @intInventoryTransactionId

	RETURN ISNULL(@returnBalance, 0)

END 