
/*
*/

CREATE FUNCTION [dbo].[fnGetInventoryTransactionId] (
	@strId AS NVARCHAR(50)
	,@intId AS INT
)
RETURNS TABLE 
AS 

RETURN 
SELECT	intInventoryTransactionId
FROM	dbo.tblICInventoryTransaction
WHERE	strTransactionId = @strId
		AND intTransactionId = @intId
