
/**
* This function will centralize the validation for each items. This is used prior to converting a Purchase Order to Item Receipt
* 
* Sample usage: 
*
*	SELECT	B.*
*	FROM	tblICItemLocation A CROSS APPLY dbo.fnGetProcessToItemReceiptErrors(A.intItemId, A.intLocationId, A.dblQty, A.dblUOMQty) B
* 
*/
CREATE FUNCTION fnGetProcessToItemReceiptErrors (@intItemId AS INT, @intItemLocationId AS INT, @dblQty AS NUMERIC(18,6) = 0, @dblUOMQty AS NUMERIC(18,6) = 0)
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

		-- Check for any invalid item-location
		--UNION ALL 
		--SELECT	intItemId = @intItemId
		--		,intLocationId = @intLocationId
		--		,strText = FORMATMESSAGE(50028)
		--		,intErrorCode = 50028
		--WHERE	NOT EXISTS (
		--			SELECT TOP 1 1 
		--			FROM	tblICItemStock Stock INNER JOIN tblICItemLocation Location
		--						ON Stock.intItemId = Location.intItemId
		--						AND	Stock.intLocationId = Location.intLocationId
		--			WHERE	Stock.intItemId = @intItemId 
		--					AND Stock.intLocationId = @intLocationId
		--		)	

	) AS Query		
)

GO