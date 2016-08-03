CREATE PROCEDURE uspMFGetProductBySubLocation (
	@intSubLocationId INT
	,@strItemNo NVARCHAR(50) = '%'
	,@intItemId INT = 0
	,@intManufacturingProcessId INT = 0
	)
AS
BEGIN
	DECLARE @intLocationId INT

	SELECT @intLocationId = intCompanyLocationId
	FROM tblSMCompanyLocationSubLocation
	WHERE intCompanyLocationSubLocationId = @intSubLocationId

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
		AND R.intLocationId = @intLocationId
		AND R.ysnActive = 1
		AND IU.ysnStockUnit = 1
		AND I.strStatus = 'Active'
		AND I.strItemNo LIKE @strItemNo + '%'
		AND I.intItemId = (
			CASE 
				WHEN @intItemId > 0
					THEN @intItemId
				ELSE I.intItemId
				END
			)
		AND R.intManufacturingProcessId = (
			CASE 
				WHEN @intManufacturingProcessId > 0
					THEN @intManufacturingProcessId
				ELSE R.intManufacturingProcessId
				END
			)
	ORDER BY I.strItemNo
END
