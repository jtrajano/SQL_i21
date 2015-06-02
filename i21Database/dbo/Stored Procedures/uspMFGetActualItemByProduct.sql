CREATE PROCEDURE uspMFGetActualItemByProduct (
	@intItemId INT
	,@intLocationId INT
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
	JOIN dbo.tblMFRecipeItem RI on RI.intRecipeId=R.intRecipeId and RI.intRecipeItemTypeId=2
	LEFT JOIN dbo.tblMFRecipeSubstituteItem SI ON SI.intRecipeItemId = RI.intRecipeItemId
	JOIN dbo.tblICItem I ON (I.intItemId = RI.intItemId OR I.intItemId = SI.intSubstituteItemId)
	JOIN dbo.tblICItemUOM IU ON IU.intItemId = I.intItemId and IU.ysnStockUnit=1
	JOIN dbo.tblICUnitMeasure U ON U.intUnitMeasureId = IU.intUnitMeasureId
		AND R.intLocationId = @intLocationId
		AND R.ysnActive = 1
		AND R.intItemId=@intItemId
END
