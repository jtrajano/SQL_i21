﻿CREATE PROCEDURE uspMFGetIngredientLotCountByProduct (
	@intItemId INT
	,@intStorageLocationId INT
	,@intLocationId INT
	,@intConsumptionMethodId int=1
	,@strLotNumber nvarchar(MAX)='%'
	,@intWorkOrderId int=0
	,@intLotId int=0
	)
AS
BEGIN
	Declare @dtmCurrentDate datetime
	Select @dtmCurrentDate=Getdate()

	If @intWorkOrderId =0
	Begin
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
		JOIN dbo.tblICItem I ON I.intItemId = L.intItemId
		JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = ISNULL(L.intWeightUOMId,L.intItemUOMId)
		JOIN dbo.tblICUnitMeasure U ON U.intUnitMeasureId = IU.intUnitMeasureId
		WHERE L.intLotStatusId = 1
			AND L.dtmExpiryDate >= @dtmCurrentDate
			AND L.dblQty>0
			AND I.strStatus='Active'
			and L.strLotNumber Like @strLotNumber +'%'
			AND L.intLotId =(CASE WHEN @intLotId >0 THEN @intLotId ELSE L.intLotId END)
	End
	Else
	Begin
		SELECT Distinct Count(*) AS LotCount
		FROM dbo.tblMFWorkOrderRecipe R
		JOIN dbo.tblMFWorkOrderRecipeItem RI ON RI.intRecipeId = R.intRecipeId and RI.intWorkOrderId = R.intWorkOrderId
			AND R.intWorkOrderId = @intWorkOrderId
			AND RI.intRecipeItemTypeId = 1
			AND RI.intConsumptionMethodId = (Case When @intConsumptionMethodId=0 Then RI.intConsumptionMethodId else @intConsumptionMethodId End)
		LEFT JOIN dbo.tblMFWorkOrderRecipeSubstituteItem SI ON SI.intRecipeItemId = RI.intRecipeItemId and RI.intWorkOrderId = R.intWorkOrderId
			AND SI.intRecipeId = R.intRecipeId
		JOIN dbo.tblICLot L ON (
			L.intItemId = RI.intItemId
			OR L.intItemId = SI.intSubstituteItemId
			)
			AND L.intStorageLocationId = @intStorageLocationId
		JOIN dbo.tblICItem I ON I.intItemId = L.intItemId
		JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = ISNULL(L.intWeightUOMId,L.intItemUOMId)
		JOIN dbo.tblICUnitMeasure U ON U.intUnitMeasureId = IU.intUnitMeasureId
		WHERE L.intLotStatusId = 1
			AND L.dtmExpiryDate >= @dtmCurrentDate
			AND L.dblQty>0
			AND I.strStatus='Active'
			and L.strLotNumber Like @strLotNumber +'%'
			AND L.intLotId =(CASE WHEN @intLotId >0 THEN @intLotId ELSE L.intLotId END)
	End
	
END
