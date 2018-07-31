Create PROCEDURE uspMFGetIngredientLotByProduct (
	@intItemId INT
	,@intStorageLocationId INT
	,@intLocationId INT
	,@intConsumptionMethodId INT = 1
	,@strLotNumber NVARCHAR(MAX) = '%'
	,@intWorkOrderId INT = 0
	,@intLotId INT = 0
	,@intInputItemId INT = 0
	,@strLotId NVARCHAR(MAX) = ''
	,@strItemStockUOMId NVARCHAR(MAX) = ''
	)
AS
BEGIN
	DECLARE @dtmCurrentDate DATETIME
		,@intManufacturingProcessId INT
		,@strDefaultConsumptionUOM NVARCHAR(50)

	IF @strLotId IS NULL
		SELECT @strLotId = ''

	IF @strItemStockUOMId IS NULL
		SELECT @strItemStockUOMId = ''

	SELECT @intManufacturingProcessId = intManufacturingProcessId
	FROM tblMFWorkOrder
	WHERE intWorkOrderId = @intWorkOrderId

	SELECT @strDefaultConsumptionUOM = strAttributeValue
	FROM tblMFManufacturingProcessAttribute
	WHERE intManufacturingProcessId = @intManufacturingProcessId
		AND intLocationId = @intLocationId
		AND intAttributeId = 99

	IF ISNULL(@strDefaultConsumptionUOM, '') = ''
		SELECT @strDefaultConsumptionUOM = '1'

	SELECT @dtmCurrentDate = Getdate()

	IF @intWorkOrderId = 0
	BEGIN
		SELECT DISTINCT L.intLotId
			,L.intItemId
			,L.strLotNumber
			,I.strItemNo
			,I.strDescription
			,(
				CASE 
					WHEN L.intWeightUOMId IS NOT NULL
						THEN L.dblWeight
					ELSE L.dblQty
					END
				) - IsNULL(SR.dblWeight, 0) AS dblWeight
			,ISNULL(L.intWeightUOMId, L.intItemUOMId) AS intWeightUOMId
			,U.strUnitMeasure
			,IU.intUnitMeasureId
			,L.dtmDateCreated
			,L.strLotAlias
			,SL.intStorageLocationId
			,SL.strName
			,L.dblQty - IsNULL(SR.dblQty, 0) AS dblQty
			,L.intItemUOMId AS intQtyUOMId
			,U1.strUnitMeasure AS strQtyUOM
			,CASE 
				WHEN @strDefaultConsumptionUOM = 1
					THEN ISNULL(RUOM.intItemUOMId, SUOM.intItemUOMId)
				WHEN @strDefaultConsumptionUOM = 2
					THEN L.intItemUOMId
				WHEN @strDefaultConsumptionUOM = 3
					THEN SIU.intItemUOMId
				END AS intRecipeItemUOMId
			,CASE 
				WHEN @strDefaultConsumptionUOM = 1
					THEN RU.intUnitMeasureId
				WHEN @strDefaultConsumptionUOM = 2
					THEN U1.intUnitMeasureId
				WHEN @strDefaultConsumptionUOM = 3
					THEN SU.intUnitMeasureId
				END AS intRecipeUnitMeasureId
			,CASE 
				WHEN @strDefaultConsumptionUOM = 1
					THEN RU.strUnitMeasure
				WHEN @strDefaultConsumptionUOM = 2
					THEN U1.strUnitMeasure
				WHEN @strDefaultConsumptionUOM = 3
					THEN SU.strUnitMeasure
				END AS strRecipeUnitMeasure
			,0 AS intItemStockUOMId
		FROM dbo.tblMFRecipe R
		LEFT JOIN dbo.tblMFRecipeItem RI ON RI.intRecipeId = R.intRecipeId
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
		LEFT JOIN dbo.tblMFRecipeCategory RC ON RC.intRecipeId = R.intRecipeId
			AND RC.intRecipeItemTypeId = 1
		JOIN dbo.tblICItem I ON (
				I.intItemId = RI.intItemId
				OR I.intItemId = SI.intSubstituteItemId
				OR (
					I.intCategoryId = IsNULL(RC.intCategoryId, I.intCategoryId)
					AND R.intRecipeTypeId = 3
					)
				)
			AND I.strInventoryTracking = 'Lot Level'
		JOIN dbo.tblICLot L ON I.intItemId = L.intItemId
			AND R.intItemId = @intItemId
			AND R.intLocationId = @intLocationId
			AND R.ysnActive = 1
			AND L.intStorageLocationId = @intStorageLocationId
			AND L.intItemId = (
				CASE 
					WHEN @intInputItemId = 0
						THEN L.intItemId
					ELSE @intInputItemId
					END
				)
		JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = ISNULL(L.intWeightUOMId, L.intItemUOMId)
		JOIN dbo.tblICUnitMeasure U ON U.intUnitMeasureId = IU.intUnitMeasureId
		JOIN dbo.tblICStorageLocation SL ON SL.intStorageLocationId = L.intStorageLocationId
		JOIN dbo.tblICRestriction R1 ON R1.intRestrictionId = IsNULL(SL.intRestrictionId, R1.intRestrictionId)
			AND R1.strInternalCode = 'STOCK'
		JOIN dbo.tblMFLotInventory LI ON LI.intLotId = L.intLotId
		JOIN dbo.tblICLotStatus BS ON BS.intLotStatusId = ISNULL(LI.intBondStatusId, 1)
			AND BS.strPrimaryStatus = 'Active'
		JOIN dbo.tblICLotStatus LS ON LS.intLotStatusId = L.intLotStatusId
		JOIN dbo.tblICItemUOM IU1 ON IU1.intItemUOMId = L.intItemUOMId
		JOIN dbo.tblICUnitMeasure U1 ON U1.intUnitMeasureId = IU1.intUnitMeasureId
		LEFT JOIN dbo.tblICItemUOM RUOM ON RUOM.intItemUOMId = RI.intItemUOMId
			AND RUOM.intItemId = I.intItemId
		LEFT JOIN dbo.tblICItemUOM SUOM ON SUOM.intItemUOMId = SI.intItemUOMId
			AND SUOM.intItemId = I.intItemId
		JOIN dbo.tblICUnitMeasure RU ON RU.intUnitMeasureId = ISNULL(RUOM.intUnitMeasureId, SUOM.intUnitMeasureId)
		JOIN dbo.tblICItemUOM SIU ON SIU.intItemId = I.intItemId
			AND SIU.ysnStockUnit = 1
		JOIN dbo.tblICUnitMeasure SU ON SU.intUnitMeasureId = SIU.intUnitMeasureId
		LEFT JOIN vyuMFStockReservation SR ON SR.intLotId = L.intLotId
		WHERE LS.strPrimaryStatus = 'Active'
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
			AND L.dblQty - IsNULL(SR.dblQty, 0) > 0
			AND (
				CASE 
					WHEN L.intWeightUOMId IS NOT NULL
						THEN L.dblWeight
					ELSE L.dblQty
					END
				) - IsNULL(SR.dblWeight, 0) > 0
				AND LI.ysnPickAllowed = 1
		
		UNION
		
		SELECT DISTINCT 0 AS intLotId
			,S.intItemId
			,NULL AS strLotNumber
			,I.strItemNo
			,I.strDescription
			,S.dblOnHand - S.dblUnitReserved AS dblWeight
			,IU.intItemUOMId AS intWeightUOMId
			,U.strUnitMeasure
			,IU.intUnitMeasureId
			,NULL AS dtmDateCreated
			,NULL AS strLotAlias
			,SL.intStorageLocationId
			,SL.strName
			,S.dblOnHand - S.dblUnitReserved AS dblQty
			,IU.intItemUOMId AS intQtyUOMId
			,U.strUnitMeasure AS strQtyUOM
			,CASE 
				WHEN @strDefaultConsumptionUOM = 3
					THEN IU.intItemUOMId
				ELSE ISNULL(RUOM.intItemUOMId, SUOM.intItemUOMId)
				END AS intRecipeItemUOMId
			,CASE 
				WHEN @strDefaultConsumptionUOM = 3
					THEN U.intUnitMeasureId
				ELSE RU.intUnitMeasureId
				END AS intRecipeUnitMeasureId
			,CASE 
				WHEN @strDefaultConsumptionUOM = 3
					THEN U.strUnitMeasure
				ELSE RU.strUnitMeasure
				END AS strRecipeUnitMeasure
			,S.intItemStockUOMId
		FROM dbo.tblMFRecipe R
		LEFT JOIN dbo.tblMFRecipeItem RI ON RI.intRecipeId = R.intRecipeId
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
		LEFT JOIN tblMFRecipeCategory RC ON RC.intRecipeId = R.intRecipeId
		JOIN dbo.tblICItem I ON (
				I.intItemId = RI.intItemId
				OR I.intItemId = SI.intSubstituteItemId
				OR (
					I.intCategoryId = IsNULL(RC.intCategoryId, I.intCategoryId)
					AND R.intRecipeTypeId = 3
					))
			AND I.strInventoryTracking = 'Item Level'
		JOIN dbo.tblICItemStockUOM S ON I.intItemId = S.intItemId
			AND IsNULL(S.intStorageLocationId,0) = @intStorageLocationId
			AND S.intItemId = (
				CASE 
					WHEN @intInputItemId = 0
						THEN S.intItemId
					ELSE @intInputItemId
					END
				)
			AND R.intItemId = @intItemId
			AND R.intLocationId = @intLocationId
			AND R.ysnActive = 1
		JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = S.intItemUOMId
			AND IU.ysnStockUnit = 1
		JOIN dbo.tblICUnitMeasure U ON U.intUnitMeasureId = IU.intUnitMeasureId
		LEFT JOIN dbo.tblICStorageLocation SL ON SL.intStorageLocationId = S.intStorageLocationId
		LEFT JOIN dbo.tblICItemUOM RUOM ON RUOM.intItemUOMId = RI.intItemUOMId
			AND RUOM.intItemId = I.intItemId
		LEFT JOIN dbo.tblICItemUOM SUOM ON SUOM.intItemUOMId = SI.intItemUOMId
			AND SUOM.intItemId = I.intItemId
		JOIN dbo.tblICUnitMeasure RU ON RU.intUnitMeasureId = ISNULL(RUOM.intUnitMeasureId, SUOM.intUnitMeasureId)
		WHERE S.dblOnHand - S.dblUnitReserved > 0
			AND I.strStatus = 'Active'
		ORDER BY dtmDateCreated
	END
	ELSE
	BEGIN
		SELECT DISTINCT L.intLotId
			,L.intItemId
			,L.strLotNumber
			,I.strItemNo
			,I.strDescription
			,(
				CASE 
					WHEN L.intWeightUOMId IS NOT NULL
						THEN L.dblWeight
					ELSE L.dblQty
					END
				) - IsNULL(SR.dblWeight, 0) AS dblWeight
			,ISNULL(L.intWeightUOMId, L.intItemUOMId) AS intWeightUOMId
			,U.strUnitMeasure
			,IU.intUnitMeasureId
			,L.dtmDateCreated
			,L.strLotAlias
			,SL.intStorageLocationId
			,SL.strName
			,L.dblQty - IsNULL(SR.dblQty, 0) AS dblQty
			,L.intItemUOMId AS intQtyUOMId
			,U1.strUnitMeasure AS strQtyUOM
			,CASE 
				WHEN @strDefaultConsumptionUOM = 1
					THEN ISNULL(RUOM.intItemUOMId, SUOM.intItemUOMId)
				WHEN @strDefaultConsumptionUOM = 2
					THEN L.intItemUOMId
				WHEN @strDefaultConsumptionUOM = 3
					THEN SIU.intItemUOMId
				END AS intRecipeItemUOMId
			,CASE 
				WHEN @strDefaultConsumptionUOM = 1
					THEN RU.intUnitMeasureId
				WHEN @strDefaultConsumptionUOM = 2
					THEN U1.intUnitMeasureId
				WHEN @strDefaultConsumptionUOM = 3
					THEN SU.intUnitMeasureId
				END AS intRecipeUnitMeasureId
			,CASE 
				WHEN @strDefaultConsumptionUOM = 1
					THEN RU.strUnitMeasure
				WHEN @strDefaultConsumptionUOM = 2
					THEN U1.strUnitMeasure
				WHEN @strDefaultConsumptionUOM = 3
					THEN SU.strUnitMeasure
				END AS strRecipeUnitMeasure
			,0 AS intItemStockUOMId
		FROM dbo.tblMFWorkOrderRecipe R
		LEFT JOIN dbo.tblMFWorkOrderRecipeItem RI ON RI.intRecipeId = R.intRecipeId
			AND RI.intWorkOrderId = R.intWorkOrderId
			AND RI.intRecipeItemTypeId = 1
			AND RI.intConsumptionMethodId = (
				CASE 
					WHEN @intConsumptionMethodId = 0
						THEN RI.intConsumptionMethodId
					ELSE @intConsumptionMethodId
					END
				)
		LEFT JOIN tblMFRecipeCategory RC ON RC.intRecipeId = R.intRecipeId
		LEFT JOIN dbo.tblMFWorkOrderRecipeSubstituteItem SI ON SI.intRecipeItemId = RI.intRecipeItemId
			AND SI.intRecipeId = R.intRecipeId
		JOIN dbo.tblICItem I ON (
				I.intItemId = RI.intItemId
				OR I.intItemId = SI.intSubstituteItemId
				OR (
					I.intCategoryId = IsNULL(RC.intCategoryId, I.intCategoryId)
					AND R.intRecipeTypeId = 3
					)
				)
			AND I.strInventoryTracking = 'Lot Level'
			AND R.intWorkOrderId = @intWorkOrderId
		JOIN dbo.tblICLot L ON I.intItemId = L.intItemId
			AND L.intStorageLocationId = @intStorageLocationId
			AND L.intItemId = (
				CASE 
					WHEN @intInputItemId = 0
						THEN L.intItemId
					ELSE @intInputItemId
					END
				)
		JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = ISNULL(L.intWeightUOMId, L.intItemUOMId)
		JOIN dbo.tblICUnitMeasure U ON U.intUnitMeasureId = IU.intUnitMeasureId
		JOIN dbo.tblICStorageLocation SL ON SL.intStorageLocationId = L.intStorageLocationId
		JOIN dbo.tblICRestriction R1 ON R1.intRestrictionId = IsNULL(SL.intRestrictionId, R1.intRestrictionId)
			AND R1.strInternalCode = 'STOCK'
		JOIN dbo.tblMFLotInventory LI ON LI.intLotId = L.intLotId
		JOIN dbo.tblICLotStatus BS ON BS.intLotStatusId = ISNULL(LI.intBondStatusId, 1)
			AND BS.strPrimaryStatus = 'Active'
		JOIN dbo.tblICLotStatus LS ON LS.intLotStatusId = L.intLotStatusId
		JOIN dbo.tblICItemUOM IU1 ON IU1.intItemUOMId = L.intItemUOMId
		JOIN dbo.tblICUnitMeasure U1 ON U1.intUnitMeasureId = IU1.intUnitMeasureId
		LEFT JOIN dbo.tblICItemUOM RUOM ON RUOM.intItemUOMId = RI.intItemUOMId
			AND RUOM.intItemId = I.intItemId
		LEFT JOIN dbo.tblICItemUOM SUOM ON SUOM.intItemUOMId = SI.intItemUOMId
			AND SUOM.intItemId = I.intItemId
		LEFT JOIN dbo.tblICUnitMeasure RU ON RU.intUnitMeasureId = ISNULL(RUOM.intUnitMeasureId, SUOM.intUnitMeasureId)
		JOIN dbo.tblICItemUOM SIU ON SIU.intItemId = I.intItemId
			AND SIU.ysnStockUnit = 1
		JOIN dbo.tblICUnitMeasure SU ON SU.intUnitMeasureId = SIU.intUnitMeasureId
		LEFT JOIN vyuMFStockReservationByWorkOrder SR ON SR.intLotId = L.intLotId
			AND SR.intWorkOrderId <> R.intWorkOrderId
		WHERE LS.strPrimaryStatus = 'Active'
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
			AND L.dblQty - IsNULL(SR.dblQty, 0) > 0
			AND (
				CASE 
					WHEN L.intWeightUOMId IS NOT NULL
						THEN L.dblWeight
					ELSE L.dblQty
					END
				) - IsNULL(SR.dblWeight, 0) > 0
			AND L.intLotId NOT IN (
				SELECT Item Collate Latin1_General_CI_AS
				FROM [dbo].[fnSplitString](@strLotId, ',')
				)
				AND LI.ysnPickAllowed = 1
		
		UNION
		
		SELECT DISTINCT 0 AS intLotId
			,I.intItemId
			,NULL AS strLotNumber
			,I.strItemNo
			,I.strDescription
			,S.dblOnHand - S.dblUnitReserved AS dblWeight
			,S.intItemUOMId AS intWeightUOMId
			,U.strUnitMeasure
			,IU.intUnitMeasureId
			,NULL AS dtmDateCreated
			,NULL strLotAlias
			,SL.intStorageLocationId
			,SL.strName
			,S.dblOnHand - S.dblUnitReserved AS dblQty
			,S.intItemUOMId AS intQtyUOMId
			,U.strUnitMeasure AS strQtyUOM
			,CASE 
				WHEN @strDefaultConsumptionUOM = 3
					THEN IU.intItemUOMId
				ELSE ISNULL(RUOM.intItemUOMId, SUOM.intItemUOMId)
				END AS intRecipeItemUOMId
			,CASE 
				WHEN @strDefaultConsumptionUOM = 3
					THEN U.intUnitMeasureId
				ELSE RU.intUnitMeasureId
				END AS intRecipeUnitMeasureId
			,CASE 
				WHEN @strDefaultConsumptionUOM = 3
					THEN U.strUnitMeasure
				ELSE RU.strUnitMeasure
				END AS strRecipeUnitMeasure
			,S.intItemStockUOMId
		FROM dbo.tblMFWorkOrderRecipe R
		LEFT JOIN dbo.tblMFWorkOrderRecipeItem RI ON RI.intRecipeId = R.intRecipeId
			AND RI.intWorkOrderId = R.intWorkOrderId
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
		LEFT JOIN tblMFRecipeCategory RC ON RC.intRecipeId = R.intRecipeId
		JOIN dbo.tblICItem I ON (
				I.intItemId = RI.intItemId
				OR I.intItemId = SI.intSubstituteItemId
				OR (
					I.intCategoryId = IsNULL(RC.intCategoryId, I.intCategoryId)
					AND R.intRecipeTypeId = 3
					)
				)
			AND I.strInventoryTracking = 'Item Level'
			AND R.intWorkOrderId = @intWorkOrderId

		JOIN dbo.tblICItemStockUOM S ON I.intItemId = S.intItemId
			AND IsNULL(S.intStorageLocationId,0) = @intStorageLocationId
			AND S.intItemId = (
				CASE 
					WHEN @intInputItemId = 0
						THEN S.intItemId
					ELSE @intInputItemId
					END
				)
		JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = S.intItemUOMId
			AND IU.ysnStockUnit = 1
		JOIN dbo.tblICUnitMeasure U ON U.intUnitMeasureId = IU.intUnitMeasureId
		Left JOIN dbo.tblICStorageLocation SL ON SL.intStorageLocationId = S.intStorageLocationId
		LEFT JOIN dbo.tblICItemUOM RUOM ON RUOM.intItemUOMId = RI.intItemUOMId
			AND RUOM.intItemId = I.intItemId
		LEFT JOIN dbo.tblICItemUOM SUOM ON SUOM.intItemUOMId = SI.intItemUOMId
			AND SUOM.intItemId = I.intItemId
		LEFT JOIN dbo.tblICUnitMeasure RU ON RU.intUnitMeasureId = ISNULL(RUOM.intUnitMeasureId, SUOM.intUnitMeasureId)
		WHERE S.dblOnHand - S.dblUnitReserved > 0
			AND I.strStatus = 'Active'
			AND S.intItemStockUOMId NOT IN (
				SELECT Item Collate Latin1_General_CI_AS
				FROM [dbo].[fnSplitString](@strItemStockUOMId, ',')
				)
		ORDER BY dtmDateCreated ASC
	END
END
