CREATE FUNCTION [dbo].[fnICGetItemUOMIdFromDuplicateItem] (
	@ItemUOMId AS INT,
	@DuplicateItemId AS INT
)
RETURNS INT
AS
BEGIN 
	DECLARE @uomId AS INT,
		@result AS INT

	SELECT @uomId = intUnitMeasureId FROM tblICItemUOM WHERE intItemUOMId = @ItemUOMId
	SELECT @result = intItemUOMId FROM tblICItemUOM WHERE intItemId = @DuplicateItemId AND intUnitMeasureId = @uomId

	RETURN @result;
END