
-- Returns the equivalent item uom id for an item using item UOM Id of another item. 
CREATE FUNCTION [dbo].[fnGetMatchingItemUOMId] (
	@intItemId AS INT,
	@intItemUOMIdFromAnotherItem AS INT
)
RETURNS INT 
AS
BEGIN 
	DECLARE @result AS INT

	SELECT	TOP 1 
			@result = SourceItem.intItemUOMId
	FROM	dbo.tblICItemUOM SourceItem INNER JOIN dbo.tblICItemUOM AnotherItem
				ON SourceItem.intUnitMeasureId = AnotherItem.intUnitMeasureId
	WHERE	SourceItem.intItemId = @intItemId
			AND AnotherItem.intItemUOMId = @intItemUOMIdFromAnotherItem

	RETURN @result;
END