CREATE PROCEDURE uspMFGetProductCountByProcess (
	@intManufacturingProcessId INT
	,@intLocationID INT
	,@strItemNo NVARCHAR(50) = '%'
	,@intItemId INT = 0
	)
AS
BEGIN
	SELECT Count(*) AS ProductCount
	FROM dbo.tblMFRecipe R
	JOIN dbo.tblICItem I ON I.intItemId = R.intItemId
	JOIN dbo.tblICItemUOM IU ON IU.intItemId = I.intItemId
		AND IU.intUnitMeasureId = I.intWeightUOMId
	JOIN dbo.tblICUnitMeasure U ON U.intUnitMeasureId = IU.intUnitMeasureId
		AND R.intLocationId = @intLocationID
		AND R.ysnActive = 1
		AND R.intManufacturingProcessId = @intManufacturingProcessId
		AND I.strStatus = 'Active'
		AND I.strItemNo LIKE @strItemNo + '%'
		AND I.intItemId = (
			CASE 
				WHEN @intItemId > 0
					THEN @intItemId
				ELSE I.intItemId
				END
			)
END
