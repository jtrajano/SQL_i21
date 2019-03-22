CREATE FUNCTION [dbo].[fnICGetItemLocationIdFromDuplicateItem] (
	@ItemLocationId AS INT,
	@DuplicateItemId AS INT
)
RETURNS INT
AS
BEGIN 
	DECLARE @locationId AS INT,
		@result AS INT

	SELECT @locationId = intLocationId FROM tblICItemLocation WHERE intItemLocationId = @ItemLocationId
	SELECT @result = intItemLocationId FROM tblICItemLocation WHERE intItemId = @DuplicateItemId AND intLocationId = @locationId

	RETURN @result;
END