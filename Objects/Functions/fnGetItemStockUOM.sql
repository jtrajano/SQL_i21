
-- Returns the stock UOM Id of an item
CREATE FUNCTION [dbo].[fnGetItemStockUOM] (
	@intItemId AS INT
)
RETURNS INT 
AS
BEGIN 
	DECLARE @result AS INT

	SELECT	TOP 1 
			@result = intItemUOMId
	FROM	dbo.tblICItemUOM
	WHERE	intItemId = @intItemId
			AND ISNULL(ysnStockUnit, 0) = 1

	RETURN @result;
END