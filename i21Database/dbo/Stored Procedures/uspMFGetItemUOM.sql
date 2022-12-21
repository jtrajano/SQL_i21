CREATE PROCEDURE dbo.uspMFGetItemUOM 
( 
	@intItemId  INT
  , @strUPCCode VARCHAR(50) = NULL
)
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
	WHERE I.intItemId = @intItemId AND (NULLIF(RTRIM(LTRIM(@strUPCCode)),'') IS NULL OR IU.strLongUPCCode = @strUPCCode)
	ORDER BY U.strUnitMeasure
END
