CREATE FUNCTION dbo.fnICIsShrinkableUOM (@intItemUOMId INT)
RETURNS BIT
AS 
BEGIN

	DECLARE @isShrinkable AS BIT = 1

	SELECT	@isShrinkable = 0
	FROM	tblICItemUOM iu INNER JOIN tblICUnitMeasure um
				ON iu.intUnitMeasureId = um.intUnitMeasureId  
	WHERE	iu.intItemUOMId = @intItemUOMId
			AND NOT (um.strUnitType = 'Weight' OR um.strUnitType = 'Volume')

	RETURN @isShrinkable
END