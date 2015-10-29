CREATE FUNCTION [dbo].[fnICGetRunningQuantity]
(
	@intInventoryTransactionId INT
)
RETURNS NUMERIC(18,6)
AS
BEGIN 
	
DECLARE @returnQty AS NUMERIC(18,6)
DECLARE @intItemId AS INT,
	@intItemLocationId AS INT,
	@dtmDate DATETIME

SELECT @intItemId = intItemId,
	@intItemLocationId = intItemLocationId,
	@dtmDate = dtmDate
FROM tblICInventoryTransaction
WHERE intInventoryTransactionId = @intInventoryTransactionId

SELECT @returnQty = SUM(dblQty * dblUOMQty) FROM tblICInventoryTransaction
WHERE @intItemId = intItemId AND
	@intItemLocationId = intItemLocationId AND
	dtmDate <= @dtmDate AND
	intInventoryTransactionId <= @intInventoryTransactionId

RETURN ISNULL(@returnQty, 0)

END 
