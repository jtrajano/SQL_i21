CREATE PROCEDURE uspMFGetActualItemCountByProduct (
	@intItemId INT
	,@intLocationId INT
	,@strItemNo NVARCHAR(MAX) = '%'
	,@intWorkOrderId INT
	,@intActualItemId INT = 0
	)
AS
BEGIN
	SELECT Count(*) AS ActualItemCount
	FROM dbo.tblMFWorkOrderRecipe R
	JOIN dbo.tblMFWorkOrderRecipeItem RI ON RI.intRecipeId = R.intRecipeId
		AND RI.intWorkOrderId = R.intWorkOrderId
		AND RI.intRecipeItemTypeId = 2
		AND R.intWorkOrderId = @intWorkOrderId
	LEFT JOIN dbo.tblMFWorkOrderRecipeSubstituteItem SI ON SI.intRecipeItemId = RI.intRecipeItemId
		AND SI.intWorkOrderId = RI.intWorkOrderId
	JOIN dbo.tblICItem I ON (
			I.intItemId = RI.intItemId
			OR I.intItemId = SI.intSubstituteItemId
			)
	JOIN dbo.tblICItemUOM IU ON IU.intUnitMeasureId = I.intWeightUOMId
		AND IU.intItemId = I.intItemId
	JOIN dbo.tblICUnitMeasure U ON U.intUnitMeasureId = IU.intUnitMeasureId
		AND R.intLocationId = @intLocationId
		AND R.ysnActive = 1
		AND R.intItemId = @intItemId
		AND I.strItemNo LIKE @strItemNo + '%'
		AND I.intItemId = (
			CASE 
				WHEN @intActualItemId > 0
					THEN @intActualItemId
				ELSE I.intItemId
				END
			)
END
