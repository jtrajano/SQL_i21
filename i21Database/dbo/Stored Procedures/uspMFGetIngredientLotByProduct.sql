CREATE PROCEDURE uspMFGetIngredientLotByProduct (
	@intItemId INT
	,@intStorageLocationId INT
	,@intLocationId INT
	)
AS
BEGIN
	SELECT L.intLotId
		,L.intItemId
		,L.strLotNumber
		,I.strItemNo
		,I.strDescription
		,L.dblWeight
		,L.intWeightUOMId
		,U.strUnitMeasure
		,IU.intUnitMeasureId
	FROM dbo.tblMFRecipe R
	JOIN dbo.tblMFRecipeItem RI ON RI.intRecipeId = R.intRecipeId
		AND R.intItemId = @intItemId
		AND R.intLocationId = @intLocationId
		AND R.ysnActive = 1
		AND RI.intRecipeItemTypeId = 1
		AND RI.intConsumptionMethodId = 1
	JOIN dbo.tblICLot L ON L.intItemId = RI.intItemId
		AND L.intStorageLocationId = @intStorageLocationId
	JOIN dbo.tblICLotStatus LS ON LS.intLotStatusId = L.intLotStatusId
	JOIN dbo.tblICItem I ON I.intItemId = RI.intItemId
	JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = L.intWeightUOMId
	JOIN dbo.tblICUnitMeasure U ON U.intUnitMeasureId = IU.intUnitMeasureId
	WHERE LS.strSecondaryStatus = 'Active'
		AND L.dtmExpiryDate >= Getdate()
		AND L.dblWeight>0
	ORDER BY L.dtmDateCreated ASC
END