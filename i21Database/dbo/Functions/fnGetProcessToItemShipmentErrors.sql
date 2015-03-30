
/**
* This function will centralize the validation for each items. This is used prior to converting a Sales Order to Inventory Receipt.
* 
* Sample usage: 
*
*	SELECT	B.*
*	FROM	tblICItemLocation A CROSS APPLY dbo.fnGetProcessToItemShipmentErrors(A.intItemId, A.intLocationId, A.dblQty, A.dblUOMQty) B
* 
*/
CREATE FUNCTION fnGetProcessToItemShipmentErrors (@intItemId AS INT, @intItemLocationId AS INT, @dblQty AS NUMERIC(18,6) = 0, @dblUOMQty AS NUMERIC(18,6) = 0)
RETURNS TABLE 
AS
RETURN (
	
	SELECT * FROM (
		-- Check for any invalid item.
		SELECT	intItemId = @intItemId
				,intItemLocationId = @intItemLocationId
				,strText = FORMATMESSAGE(50027)
				,intErrorCode = 50027
		WHERE	NOT EXISTS (
					SELECT TOP 1 1 
					FROM	tblICItem 
					WHERE	intItemId = @intItemId
				)	
	) AS Query		
)

GO