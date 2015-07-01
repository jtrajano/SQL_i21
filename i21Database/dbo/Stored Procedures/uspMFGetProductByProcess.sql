CREATE PROCEDURE uspMFGetProductByProcess (
	@intManufacturingProcessId INT
	,@intLocationID INT
	,@strItemNo nvarchar(50)='%'
	)
AS
BEGIN
	SELECT I.intItemId
		,I.strItemNo
		,I.strDescription
		,IU.intItemUOMId
		,U.intUnitMeasureId
		,U.strUnitMeasure
	FROM dbo.tblMFRecipe R
	JOIN dbo.tblICItem I ON I.intItemId = R.intItemId
	JOIN dbo.tblICItemUOM IU ON IU.intItemId = I.intItemId
	JOIN dbo.tblICUnitMeasure U ON U.intUnitMeasureId = IU.intUnitMeasureId
		AND R.intLocationId = @intLocationID
		AND R.ysnActive = 1
		AND R.intManufacturingProcessId = @intManufacturingProcessId
		AND IU.ysnStockUnit=1
		AND I.strStatus='Active'
		AND I.strItemNo LIKE @strItemNo+'%' 
END