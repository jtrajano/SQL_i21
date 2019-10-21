CREATE FUNCTION [dbo].[fnICCheckAllowSale]
(
	@ItemId AS INT
)
RETURNS BIT
AS
BEGIN 
	DECLARE @result AS BIT = 0

	IF EXISTS (SELECT TOP 1  1 FROM tblICItemUOM WHERE intItemId = @ItemId AND ysnAllowSale = 1)
		SET @result = 1

	RETURN @result;
END