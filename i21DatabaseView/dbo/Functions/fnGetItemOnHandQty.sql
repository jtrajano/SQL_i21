
-- Returns the Item's On-Hand Qty (in Stock UOM) 
CREATE FUNCTION [dbo].[fnGetItemOnHandQty] (
	@intItemId AS INT
	,@intItemLocationId AS INT 
)
RETURNS NUMERIC(38, 20) 
AS
BEGIN 
	DECLARE @result AS NUMERIC(38, 20)

	SELECT	@result = s.dblUnitOnHand
	FROM	tblICItemStock s
	WHERE	s.intItemId = @intItemId
			AND s.intItemLocationId = @intItemLocationId

	RETURN ISNULL(@result, 0);
END