
-- Returns the equivalent item uom id for an item using item UOM Id of another item. 
CREATE FUNCTION [dbo].[fnGetMatchingItemUOMId] (
	@intTargetItemId AS INT,
	@intItemUOMIdFromSourceItem AS INT
)
RETURNS INT 
AS
BEGIN 
	DECLARE @result AS INT

	SELECT	TOP 1 
			@result = TargetItem.intItemUOMId
	FROM	dbo.tblICItemUOM TargetItem INNER JOIN dbo.tblICItemUOM SourceItem
				ON TargetItem.intUnitMeasureId = SourceItem.intUnitMeasureId
	WHERE	TargetItem.intItemId = @intTargetItemId
			AND SourceItem.intItemUOMId = @intItemUOMIdFromSourceItem

	RETURN @result;
END