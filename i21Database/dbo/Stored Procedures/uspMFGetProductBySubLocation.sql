CREATE PROCEDURE uspMFGetProductBySubLocation (@intSubLocationId INT)
AS
BEGIN
	SELECT I.intItemId
		,I.strItemNo
		,I.strDescription
		,IU.intItemUOMId
		,U.intUnitMeasureId
		,U.strUnitMeasure
		,R.intManufacturingProcessId
	FROM dbo.tblMFRecipe R
	JOIN dbo.tblICItem I ON I.intItemId = R.intItemId
	JOIN dbo.tblICItemUOM IU ON IU.intItemId = I.intItemId
	JOIN dbo.tblICUnitMeasure U ON U.intUnitMeasureId = IU.intUnitMeasureId
	JOIN dbo.tblSMCompanyLocationSubLocationCategory C ON C.intCategoryId = I.intCategoryId
		AND C.intCompanyLocationSubLocationId = @intSubLocationId
		AND R.ysnActive = 1
		AND IU.ysnStockUnit = 1
END