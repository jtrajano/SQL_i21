
-- Returns the selected option for an item when handling negative stocks. 
CREATE FUNCTION [dbo].[fnGetNegativeInventoryOptions] (
	@intItemId INT
)
RETURNS INT 
AS
BEGIN
	DECLARE @AllowNegativeInventoryType AS INT

	-- TODO: Replace it with the correct business rule 
	-- See: http://inet.irelyserver.com/display/INV/Inbound+Stock+Process?focusedCommentId=38209060#comment-38209060

	SELECT	@AllowNegativeInventoryType = NULL
	FROM	tblICItem
	WHERE	intItemId = @intItemId

	RETURN @AllowNegativeInventoryType
END
