
/**
* This function will centralize the validation for each items. This is used prior to posting a transaction. 
* 
* Sample usage: 
*
*	SELECT	B.*
*	FROM	tblICItemLocation A CROSS APPLY dbo.fnGetItemCostingOnPostErrors(A.intItemId, A.intLocationId, (A.dblUnitQty * A.dblUOMQty)) B
* 
*/
CREATE FUNCTION fnGetItemCostingOnPostErrors (@intItemId AS INT, @intLocationId AS INT, @dblQty AS NUMERIC(18,6) = 0)
RETURNS TABLE 
AS
RETURN (
	
	SELECT * FROM (
		-- Check for any invalid item.
		SELECT	intItemId = @intItemId
				,intLocationId = @intLocationId
				,strText = FORMATMESSAGE(50027)
				,intErrorCode = 50027
		WHERE	NOT EXISTS (
					SELECT TOP 1 1 
					FROM	tblICItem 
					WHERE	intItemId = @intItemId
				)	

		-- Check for any invalid item-location
		UNION ALL 
		SELECT	intItemId = @intItemId
				,intLocationId = @intLocationId
				,strText = FORMATMESSAGE(50028)
				,intErrorCode = 50028
		WHERE	NOT EXISTS (
					SELECT TOP 1 1 
					FROM	tblICItemStock Stock INNER JOIN tblICItemLocation Location
								ON Stock.intItemId = Location.intItemId
								AND	Stock.intLocationId = Location.intLocationId
					WHERE	Stock.intItemId = @intItemId 
							AND Stock.intLocationId = @intLocationId
				)	

		-- Check for negative stock and if negative stock is NOT allowed. 
		UNION ALL 
		SELECT	intItemId = @intItemId
				,intLocationId = @intLocationId
				,strText = FORMATMESSAGE(50029)
				,intErrorCode = 50029
		WHERE	EXISTS (
					SELECT	TOP 1 1 
					FROM	tblICItemStock Stock INNER JOIN tblICItemLocation Location
								ON Stock.intItemId = Location.intItemId
								AND	Stock.intLocationId = Location.intLocationId
					WHERE	Stock.intItemId = @intItemId 
							AND Stock.intLocationId = @intLocationId 
							AND ISNULL(@dblQty, 0) + ISNULL(Stock.dblUnitOnHand, 0) < 0 -- Check if the incoming or outgoing stock is going to be negative. 							
							AND Location.intAllowNegativeInventory = 3 -- Value 3 means "NO", Negative stock is NOT allowed. 
				)

	) AS Query		
)

GO