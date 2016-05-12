CREATE PROCEDURE uspMFGetIngredientLotCountByProduct (
	@intItemId INT
	,@intStorageLocationId INT
	,@intLocationId INT
	,@intConsumptionMethodId INT = 1
	,@strLotNumber NVARCHAR(MAX) = '%'
	,@intWorkOrderId INT = 0
	,@intLotId INT = 0
	)
AS
BEGIN
	DECLARE @dtmCurrentDate DATETIME

	SELECT @dtmCurrentDate = Getdate()

	IF @intWorkOrderId = 0
	BEGIN
		SELECT Count(*) AS LotCount
		FROM (
			SELECT L.intLotId AS LotCount
			FROM dbo.tblMFRecipe R
			JOIN dbo.tblMFRecipeItem RI ON RI.intRecipeId = R.intRecipeId
				AND R.intItemId = @intItemId
				AND R.intLocationId = @intLocationId
				AND R.ysnActive = 1
				AND RI.intRecipeItemTypeId = 1
				AND RI.intConsumptionMethodId = (
					CASE 
						WHEN @intConsumptionMethodId = 0
							THEN RI.intConsumptionMethodId
						ELSE @intConsumptionMethodId
						END
					)
			LEFT JOIN dbo.tblMFRecipeSubstituteItem SI ON SI.intRecipeItemId = RI.intRecipeItemId
				AND SI.intRecipeId = R.intRecipeId
			JOIN dbo.tblICLot L ON (
					L.intItemId = RI.intItemId
					OR L.intItemId = SI.intSubstituteItemId
					)
				AND L.intStorageLocationId = @intStorageLocationId
			JOIN dbo.tblICItem I ON I.intItemId = L.intItemId
				AND I.strInventoryTracking = 'Lot Level'
			JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = ISNULL(L.intWeightUOMId, L.intItemUOMId)
			JOIN dbo.tblICUnitMeasure U ON U.intUnitMeasureId = IU.intUnitMeasureId
			WHERE L.intLotStatusId = 1
				AND ISNULL(dtmExpiryDate, @dtmCurrentDate) >= @dtmCurrentDate
				AND L.dblQty > 0
				AND I.strStatus = 'Active'
				AND L.strLotNumber LIKE @strLotNumber + '%'
				AND L.intLotId = (
					CASE 
						WHEN @intLotId > 0
							THEN @intLotId
						ELSE L.intLotId
						END
					)
			
			UNION
			
			SELECT DISTINCT Ltrim(I.intItemId)+Ltrim(SL.intStorageLocationId)  AS LotCount
			FROM dbo.tblMFRecipe R
			JOIN dbo.tblMFRecipeItem RI ON RI.intRecipeId = R.intRecipeId
				AND R.intItemId = @intItemId
				AND R.intLocationId = @intLocationId
				AND R.ysnActive = 1
				AND RI.intRecipeItemTypeId = 1
				AND RI.intConsumptionMethodId = (
					CASE 
						WHEN @intConsumptionMethodId = 0
							THEN RI.intConsumptionMethodId
						ELSE @intConsumptionMethodId
						END
					)
			LEFT JOIN dbo.tblMFRecipeSubstituteItem SI ON SI.intRecipeItemId = RI.intRecipeItemId
				AND SI.intRecipeId = R.intRecipeId
			JOIN dbo.tblICItemStockUOM S ON (
					S.intItemId = RI.intItemId
					OR S.intItemId = SI.intSubstituteItemId
					)
				AND S.intStorageLocationId = @intStorageLocationId
			JOIN dbo.tblICItem I ON I.intItemId = S.intItemId
				AND I.strInventoryTracking = 'Item Level'
			JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = S.intItemUOMId
				AND IU.ysnStockUnit = 1
			JOIN dbo.tblICUnitMeasure U ON U.intUnitMeasureId = IU.intUnitMeasureId
			JOIN dbo.tblICStorageLocation SL ON SL.intStorageLocationId = S.intStorageLocationId
			WHERE S.dblOnHand - S.dblUnitReserved > 0
				AND I.strStatus = 'Active'
			) AS DT
	END
	ELSE
	BEGIN
		SELECT Count(*) AS LotCount
		FROM (
			SELECT L.intLotId AS LotCount
			FROM dbo.tblMFWorkOrderRecipe R
			JOIN dbo.tblMFWorkOrderRecipeItem RI ON RI.intRecipeId = R.intRecipeId
				AND RI.intWorkOrderId = R.intWorkOrderId
				AND R.intWorkOrderId = @intWorkOrderId
				AND RI.intRecipeItemTypeId = 1
				AND RI.intConsumptionMethodId = (
					CASE 
						WHEN @intConsumptionMethodId = 0
							THEN RI.intConsumptionMethodId
						ELSE @intConsumptionMethodId
						END
					)
			LEFT JOIN dbo.tblMFWorkOrderRecipeSubstituteItem SI ON SI.intRecipeItemId = RI.intRecipeItemId
				AND RI.intWorkOrderId = R.intWorkOrderId
				AND SI.intRecipeId = R.intRecipeId
			JOIN dbo.tblICLot L ON (
					L.intItemId = RI.intItemId
					OR L.intItemId = SI.intSubstituteItemId
					)
				AND L.intStorageLocationId = @intStorageLocationId
			JOIN dbo.tblICItem I ON I.intItemId = L.intItemId AND I.strInventoryTracking = 'Lot Level'
			JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = ISNULL(L.intWeightUOMId, L.intItemUOMId)
			JOIN dbo.tblICUnitMeasure U ON U.intUnitMeasureId = IU.intUnitMeasureId
			WHERE L.intLotStatusId = 1
				AND ISNULL(dtmExpiryDate, @dtmCurrentDate) >= @dtmCurrentDate
				AND L.dblQty > 0
				AND I.strStatus = 'Active'
				AND L.strLotNumber LIKE @strLotNumber + '%'
				AND L.intLotId = (
					CASE 
						WHEN @intLotId > 0
							THEN @intLotId
						ELSE L.intLotId
						END
					)
			
			UNION
			
			SELECT DISTINCT Ltrim(I.intItemId)+Ltrim(SL.intStorageLocationId)  AS LotCount
			FROM dbo.tblMFWorkOrderRecipe R
			JOIN dbo.tblMFWorkOrderRecipeItem RI ON RI.intRecipeId = R.intRecipeId
				AND RI.intWorkOrderId = R.intWorkOrderId
				AND R.intWorkOrderId = @intWorkOrderId
				AND RI.intRecipeItemTypeId = 1
				AND RI.intConsumptionMethodId = (
					CASE 
						WHEN @intConsumptionMethodId = 0
							THEN RI.intConsumptionMethodId
						ELSE @intConsumptionMethodId
						END
					)
			LEFT JOIN dbo.tblMFWorkOrderRecipeSubstituteItem SI ON SI.intRecipeItemId = RI.intRecipeItemId
				AND SI.intRecipeId = R.intRecipeId
			JOIN dbo.tblICItemStockUOM S ON (
					S.intItemId = RI.intItemId
					OR S.intItemId = SI.intSubstituteItemId
					)
				AND S.intStorageLocationId = @intStorageLocationId
			JOIN dbo.tblICItem I ON I.intItemId = S.intItemId
				AND I.strInventoryTracking = 'Item Level'
			JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = S.intItemUOMId
				AND IU.ysnStockUnit = 1
			JOIN dbo.tblICUnitMeasure U ON U.intUnitMeasureId = IU.intUnitMeasureId
			JOIN dbo.tblICStorageLocation SL ON SL.intStorageLocationId = S.intStorageLocationId
			WHERE S.dblOnHand - S.dblUnitReserved > 0
				AND I.strStatus = 'Active'
			) AS DT
	END
END
