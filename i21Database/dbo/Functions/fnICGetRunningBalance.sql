CREATE FUNCTION [dbo].[fnICGetRunningBalance]
(
	@intInventoryTransactionId INT
)
RETURNS NUMERIC(18,6)
AS
BEGIN 
	
DECLARE @returnBalance AS NUMERIC(18,6)
DECLARE @intItemId AS INT,
	@intItemLocationId AS INT,
	@dtmDate DATETIME

SELECT @intItemId = intItemId,
	@intItemLocationId = intItemLocationId,
	@dtmDate = dtmDate
FROM tblICInventoryTransaction
WHERE intInventoryTransactionId = @intInventoryTransactionId

SELECT @returnBalance = SUM((dblQty * dblUOMQty * dblCost) + dblValue) FROM tblICInventoryTransaction
WHERE @intItemId = intItemId AND
	@intItemLocationId = intItemLocationId AND
	dtmDate <= @dtmDate AND
	intInventoryTransactionId <= @intInventoryTransactionId

RETURN ISNULL(@returnBalance, 0)

END 