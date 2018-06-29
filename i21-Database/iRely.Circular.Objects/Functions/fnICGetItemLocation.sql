CREATE FUNCTION [dbo].[fnICGetItemLocation]
(
	@ItemId AS INT,
	@LocationId AS INT
)
RETURNS INT
AS
BEGIN 
	DECLARE @result AS INT

	SELECT TOP 1 @result = intItemLocationId FROM tblICItemLocation WHERE intItemId = @ItemId AND intLocationId = @LocationId

	RETURN @result;
END