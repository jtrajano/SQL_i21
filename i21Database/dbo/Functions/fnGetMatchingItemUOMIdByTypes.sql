CREATE FUNCTION [dbo].[fnGetMatchingItemUOMIdByTypes] (
	@intTargetItemId AS INT,
	@intItemUOMIdFromSourceItem AS INT,
	@strDelimitedUomTypes NVARCHAR(300) 
)
RETURNS INT 
AS
BEGIN 
	DECLARE @result AS INT
	if NULLIF(@strDelimitedUomTypes, '') IS NULL SET @strDelimitedUomTypes = 'Area,Length,Quantity,Time,Volume,Weight'
	SELECT	TOP 1 @result = TargetItem.intItemUOMId
	FROM dbo.tblICItemUOM TargetItem
		INNER JOIN dbo.tblICItemUOM SourceItem ON TargetItem.intUnitMeasureId = SourceItem.intUnitMeasureId
		INNER JOIN tblICUnitMeasure u ON u.intUnitMeasureId = TargetItem.intUnitMeasureId
		INNER JOIN [dbo].fnSplitStringWithTrim(@strDelimitedUomTypes, ',') uoms ON uoms.Item COLLATE Latin1_General_CI_AS = u.strUnitType
	WHERE TargetItem.intItemId = @intTargetItemId
		AND SourceItem.intItemUOMId = @intItemUOMIdFromSourceItem

	RETURN @result;
END