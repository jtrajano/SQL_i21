CREATE PROCEDURE uspMFGetActualItemCountByProduct (
	@intItemId INT
	,@intLocationId INT
	,@strItemNo nvarchar(MAX)='%'
	,@intWorkOrderId int
	)
AS
BEGIN
	SELECT Count(*) As ActualItemCount
	FROM dbo.tblMFWorkOrderRecipe R
	JOIN dbo.tblMFWorkOrderRecipeItem RI on RI.intRecipeId=R.intRecipeId and RI.intRecipeItemTypeId=2 and R.intWorkOrderId =@intWorkOrderId 
	LEFT JOIN dbo.tblMFWorkOrderRecipeSubstituteItem SI ON SI.intRecipeItemId = RI.intRecipeItemId
	JOIN dbo.tblICItem I ON (I.intItemId = RI.intItemId OR I.intItemId = SI.intSubstituteItemId)
	JOIN dbo.tblICItemUOM IU ON IU.intItemId = I.intItemId and IU.ysnStockUnit=1
	JOIN dbo.tblICUnitMeasure U ON U.intUnitMeasureId = IU.intUnitMeasureId
		AND R.intLocationId = @intLocationId
		AND R.ysnActive = 1
		AND R.intItemId=@intItemId
		AND I.strItemNo LIKE @strItemNo+'%'
END
