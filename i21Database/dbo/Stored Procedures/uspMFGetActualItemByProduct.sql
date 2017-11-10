CREATE PROCEDURE uspMFGetActualItemByProduct (
	@intItemId INT
	,@intRecipeItemTypeId INT
	,@intLocationId INT
	,@strItemNo NVARCHAR(MAX) = '%'
	,@intWorkOrderId INT
	,@intActualItemId INT = 0
	,@intCategoryId INT = 0
	)
AS
BEGIN
	SELECT I.intItemId
		,I.strItemNo
		,I.strDescription
		,ISNULL(IU.intItemUOMId, IU1.intItemUOMId) AS intItemUOMId
		,U.intUnitMeasureId
		,U.strUnitMeasure
		,I.intLayerPerPallet
		,I.intUnitPerLayer
	FROM dbo.tblMFWorkOrderRecipe R
	JOIN dbo.tblMFWorkOrderRecipeItem RI ON RI.intRecipeId = R.intRecipeId
		AND RI.intWorkOrderId = R.intWorkOrderId
		AND RI.intRecipeItemTypeId = @intRecipeItemTypeId
		AND R.intWorkOrderId = @intWorkOrderId
	LEFT JOIN dbo.tblMFWorkOrderRecipeSubstituteItem SI ON SI.intRecipeItemId = RI.intRecipeItemId
		AND SI.intWorkOrderId = RI.intWorkOrderId
	JOIN dbo.tblICItem I ON (
			I.intItemId = RI.intItemId
			OR I.intItemId = SI.intSubstituteItemId
			)
	LEFT JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = RI.intItemUOMId
		AND IU.intItemId = I.intItemId
	LEFT JOIN dbo.tblICItemUOM IU1 ON IU1.intItemUOMId = SI.intItemUOMId
		AND IU1.intItemId = I.intItemId
	JOIN dbo.tblICUnitMeasure U ON U.intUnitMeasureId = ISNULL(IU.intUnitMeasureId, IU1.intUnitMeasureId)
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
		AND ISNULL(I.intCategoryId, 0) <> (
			CASE 
				WHEN @intCategoryId > 0
					THEN @intCategoryId
				ELSE - 1
				END
			)
	ORDER BY I.strItemNo
END
