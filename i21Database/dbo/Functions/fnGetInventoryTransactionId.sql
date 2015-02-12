
/*
	Retrieves the id from tblICInventoryTransaction table using the module's transaction id (string and int id)
*/

CREATE FUNCTION [dbo].[fnGetInventoryTransactionId] (
	@strId AS NVARCHAR(50)
	,@intId AS INT
	,@intItemId AS INT
	,@intItemLocationId AS INT 
)
RETURNS TABLE 
AS 

RETURN 
SELECT	intInventoryTransactionId
FROM	dbo.tblICInventoryTransaction
WHERE	strTransactionId = @strId
		AND intTransactionId = @intId
		AND intItemId = @intItemId
		AND intItemLocationId = @intItemLocationId
