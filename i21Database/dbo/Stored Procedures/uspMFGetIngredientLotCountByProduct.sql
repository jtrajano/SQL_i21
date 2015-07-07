﻿CREATE PROCEDURE uspMFGetIngredientLotCountByProduct (
	@intItemId INT
	,@intStorageLocationId INT
	,@intLocationId INT
	,@intConsumptionMethodId int=1
	)
AS
BEGIN
	SELECT Distinct Count(*) AS LotCount
	FROM dbo.tblMFRecipe R
	JOIN dbo.tblMFRecipeItem RI ON RI.intRecipeId = R.intRecipeId
		AND R.intItemId = @intItemId
		AND R.intLocationId = @intLocationId
		AND R.ysnActive = 1
		AND RI.intRecipeItemTypeId = 1
		AND RI.intConsumptionMethodId = (Case When @intConsumptionMethodId=0 Then RI.intConsumptionMethodId else @intConsumptionMethodId End)
	LEFT JOIN dbo.tblMFRecipeSubstituteItem SI ON SI.intRecipeItemId = RI.intRecipeItemId
		AND SI.intRecipeId = R.intRecipeId
	JOIN dbo.tblICLot L ON (
		L.intItemId = RI.intItemId
		OR L.intItemId = SI.intSubstituteItemId
		)
		AND L.intStorageLocationId = @intStorageLocationId
	JOIN dbo.tblICLotStatus LS ON LS.intLotStatusId = L.intLotStatusId
	JOIN dbo.tblICItem I ON I.intItemId = L.intItemId
	JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = ISNULL(L.intWeightUOMId,L.intItemUOMId)
	JOIN dbo.tblICUnitMeasure U ON U.intUnitMeasureId = IU.intUnitMeasureId
	WHERE LS.strSecondaryStatus = 'Active'
		AND L.dtmExpiryDate >= Getdate()
		AND L.dblQty>0
		AND I.strStatus='Active'
	
END
