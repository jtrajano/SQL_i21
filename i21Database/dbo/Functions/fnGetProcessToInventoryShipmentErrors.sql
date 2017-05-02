
/**
* This function will centralize the validation for each items. 
* It is used prior to converting a Sales Order to Inventory Shipment. 
* 
* Sample usage: 
*
*	SELECT	B.*
*	FROM	tblICItemLocation A CROSS APPLY dbo.fnGetProcessToInventoryShipmentErrors(A.intItemId, A.intLocationId, A.dblQty, A.dblUOMQty) B
* 
*/
CREATE FUNCTION fnGetProcessToInventoryShipmentErrors (@intItemId AS INT, @intItemLocationId AS INT, @dblQty AS NUMERIC(18,6) = 0, @dblUOMQty AS NUMERIC(18,6) = 0)
RETURNS TABLE 
AS
RETURN (
	
	SELECT * FROM (
		-- Check for any invalid item.
		SELECT	intItemId = @intItemId
				,intItemLocationId = @intItemLocationId
				,strText = dbo.fnICGetErrorMessage(80001) -- 'Item id is invalid or missing.'
				,intErrorCode = 80001
		WHERE	NOT EXISTS (
					SELECT TOP 1 1 
					FROM	tblICItem 
					WHERE	intItemId = @intItemId
				)	
	) AS Query		
)

GO