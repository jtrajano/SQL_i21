CREATE PROCEDURE dbo.uspMFGetItemUOM @intItemId INT
AS
BEGIN
	SELECT I.intItemId
		,IU.intItemUOMId
		,IU.intUnitMeasureId
		,U.strUnitMeasure
		,IU.ysnStockUnit
		,U.strUnitType
	FROM tblICItem I
	JOIN tblICItemUOM IU ON IU.intItemId = I.intItemId
	JOIN tblICUnitMeasure U ON U.intUnitMeasureId = IU.intUnitMeasureId
	WHERE I.intItemId = @intItemId
	ORDER BY U.strUnitMeasure
END
