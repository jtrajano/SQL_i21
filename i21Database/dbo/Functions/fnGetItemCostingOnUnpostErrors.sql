
/**
* This function will centralize the validation for each items. This is used prior to unposting a transaction. 
* 
* Sample usage: 
*
*	SELECT	B.*
*	FROM	tblICItemLocation A CROSS APPLY dbo.fnGetItemCostingOnUnpostErrors(A.intItemId, A.intLocationId, (A.dblUnitQty * A.dblUOMQty)) B
* 
*/
CREATE FUNCTION fnGetItemCostingOnUnpostErrors (@intItemId AS INT, @intItemLocationId AS INT, @dblQty AS NUMERIC(18,6) = 0)
RETURNS TABLE 
AS
RETURN (
	
	SELECT * FROM (
		-- Check for negative stock and if negative stock is NOT allowed. 
		SELECT	intItemId = @intItemId
				,intItemLocationId = @intItemLocationId
				,strText = FORMATMESSAGE(50029)
				,intErrorCode = 50029
		WHERE	EXISTS (
					SELECT	TOP 1 1 
					FROM	tblICItemStock Stock INNER JOIN tblICItemLocation Location
								ON Stock.intItemId = Location.intItemId
								AND	Stock.intItemLocationId = Location.intItemLocationId
					WHERE	Location.intItemId = @intItemId 
							AND Location.intItemLocationId = @intItemLocationId 
							AND @dblQty + ISNULL(Stock.dblUnitOnHand, 0) < 0 -- Check if the incoming or outgoing stock is going to be negative. 							
							AND Location.intAllowNegativeInventory = 3 -- Value 3 means "NO", Negative stock is NOT allowed. 
				)

	) AS Query		
)

GO