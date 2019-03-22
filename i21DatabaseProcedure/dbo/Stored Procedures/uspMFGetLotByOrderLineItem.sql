CREATE PROCEDURE uspMFGetLotByOrderLineItem (
	@intOrderHeaderId INT
	,@intLocationId INT
	,@intItemId INT
	,@intTaskId INT = 0
	,@intLotId INT = 0
	,@strLotNumber NVARCHAR(50) = '%'
	)
AS
DECLARE @ysnStrictTracking BIT
	,@intLineItemLotId INT
	,@intPreferenceId INT
	,@intParentLotId INT
	,@strOrderType NVARCHAR(50)
	,@intReceivedLife INT
	,@strReferenceNo NVARCHAR(50)
	,@intEntityCustomerId INT
	,@intItemOwnerId INT
	,@ysnPickByItemOwner BIT
	,@intInventoryShipmentId INT
	,@ysnAllowPartialPallet BIT
	,@dtmCurrentDateTime DATETIME
	,@intAllowablePickDayRange INT
	,@ysnPickByLotCode BIT
	,@intLotCodeStartingPosition INT
	,@intLotCodeNoOfDigits INT
	,@dblRequiredWeight NUMERIC(18, 6)
	,@intTaskLotId INT
	,@dtmDateCreated DATETIME
	,@intOwnershipType INT

SELECT @intOwnershipType = NULL

SELECT @dtmCurrentDateTime = GETDATE()

SELECT @ysnStrictTracking = i.ysnStrictFIFO
	,@intLineItemLotId = oli.intLotId
	,@intPreferenceId = oli.intPreferenceId
	,@intParentLotId = oli.intParentLotId
	,@strOrderType = OT.strOrderType
	,@strReferenceNo = oh.strReferenceNo
	,@dblRequiredWeight = oli.dblQty - ISNULL((
			SELECT SUM(CASE 
						WHEN t.intTaskTypeId = 13
							THEN l.dblQty - t.dblQty
						ELSE t.dblQty
						END)
			FROM tblMFTask t
			JOIN tblICLot l ON l.intLotId = t.intLotId
			WHERE t.intOrderHeaderId = oh.intOrderHeaderId
				AND t.intItemId = oli.intItemId
			), 0)
	,@intOwnershipType = intOwnershipType
FROM tblMFOrderHeader oh
JOIN tblMFOrderDetail oli ON oh.intOrderHeaderId = oli.intOrderHeaderId
JOIN tblICItem i ON i.intItemId = oli.intItemId
JOIN tblMFOrderType OT ON OT.intOrderTypeId = oh.intOrderTypeId
WHERE oh.intOrderHeaderId = @intOrderHeaderId
	AND oli.intItemId = @intItemId

SELECT @intAllowablePickDayRange = intAllowablePickDayRange
FROM tblMFCompanyPreference

IF @strOrderType = 'INVENTORY SHIPMENT STAGING'
BEGIN
	SELECT @intEntityCustomerId = intEntityCustomerId
		,@intInventoryShipmentId = intInventoryShipmentId
	FROM tblICInventoryShipment
	WHERE strShipmentNumber = @strReferenceNo

	SELECT @intReceivedLife = intReceivedLife
		,@ysnAllowPartialPallet = ysnAllowPartialPallet
	FROM tblMFItemOwner
	WHERE intOwnerId = @intEntityCustomerId
		AND intItemId = @intItemId

	IF @intReceivedLife = 0
		OR @intReceivedLife IS NULL
	BEGIN
		SELECT @intReceivedLife = intReceivedLife
			,@ysnAllowPartialPallet = ysnAllowPartialPallet
		FROM tblMFItemOwner
		WHERE intOwnerId = @intEntityCustomerId
	END

	IF @ysnAllowPartialPallet IS NULL
	BEGIN
		SELECT @ysnAllowPartialPallet = ysnAllowPartialPallet
		FROM tblMFItemOwner
		WHERE intOwnerId = @intEntityCustomerId
	END

	IF @intReceivedLife = 0
		OR @intReceivedLife IS NULL
	BEGIN
		SELECT @intReceivedLife = intReceiveLife
		FROM tblICItem
		WHERE intItemId = @intItemId
	END

	IF @intReceivedLife IS NULL
	BEGIN
		SELECT @intReceivedLife = 0
	END

	SELECT @intItemOwnerId = intItemOwnerId
	FROM tblICItemOwner
	WHERE intOwnerId = @intEntityCustomerId
		AND intItemId = @intItemId
END

IF @intTaskId > 0 --Edit task
BEGIN
	SELECT @intTaskLotId = intLotId
	FROM tblMFTask
	WHERE intTaskId = @intTaskId

	SELECT @dtmDateCreated = dtmDateCreated
	FROM tblICLot
	WHERE intLotId = @intTaskLotId

	SELECT L.intLotId
		,I.strItemNo
		,I.strDescription
		,PL.strParentLotNumber
		,L.strLotNumber
		,L.strLotAlias
		,L.intItemUOMId AS intQtyUOMId
		,UM.strUnitMeasure AS strQtyUOM
		,L.intWeightUOMId
		,UM1.strUnitMeasure AS strWeightUOM
		,SL.strName
		,L.dblQty
		,CASE 
			WHEN L.intWeightUOMId IS NULL
				THEN L.dblQty
			ELSE L.dblWeight
			END AS dblWeight
		,(
			SUM(ISNULL(dbo.fnMFConvertQuantityToTargetItemUOM(SR.intItemUOMId, L.intItemUOMId, SR.dblQty), 0))
			) AS dblReservedQty
		,CASE 
			WHEN L.intWeightUOMId IS NULL
				THEN (
						SUM(ISNULL(dbo.fnMFConvertQuantityToTargetItemUOM(SR.intItemUOMId, L.intItemUOMId, SR.dblQty), 0))
						)
			ELSE (
					SUM(ISNULL(dbo.fnMFConvertQuantityToTargetItemUOM(SR.intItemUOMId, L.intWeightUOMId, SR.dblQty), 0))
					)
			END AS dblReservedWeight
		,L.dblQty - (
			SUM(ISNULL(dbo.fnMFConvertQuantityToTargetItemUOM(SR.intItemUOMId, L.intItemUOMId, SR.dblQty), 0))
			) AS dblAvailableQty
		,CASE 
			WHEN L.intWeightUOMId IS NULL
				THEN L.dblQty - (
						SUM(ISNULL(dbo.fnMFConvertQuantityToTargetItemUOM(SR.intItemUOMId, L.intItemUOMId, SR.dblQty), 0))
						)
			ELSE L.dblWeight - (
					SUM(ISNULL(dbo.fnMFConvertQuantityToTargetItemUOM(SR.intItemUOMId, L.intWeightUOMId, SR.dblQty), 0))
					)
			END AS dblAvailableWeight
	FROM tblICLot L
	JOIN tblICStorageLocation SL ON SL.intStorageLocationId = L.intStorageLocationId
	JOIN tblICStorageUnitType UT ON UT.intStorageUnitTypeId = SL.intStorageUnitTypeId
		AND UT.ysnAllowPick = 1
	LEFT JOIN tblICStockReservation SR ON SR.intLotId = L.intLotId and SR.ysnPosted =0 and SR.intTransactionId<>@intOrderHeaderId
	JOIN dbo.tblICRestriction R ON R.intRestrictionId = IsNULL(SL.intRestrictionId, R.intRestrictionId)
		AND R.strInternalCode = 'STOCK'
	LEFT JOIN dbo.tblMFLotInventory LI ON LI.intLotId = L.intLotId
	JOIN dbo.tblICParentLot PL ON PL.intParentLotId = L.intParentLotId
	JOIN dbo.tblICLotStatus BS ON BS.intLotStatusId = ISNULL(LI.intBondStatusId, 1)
		AND BS.strPrimaryStatus = 'Active'
	JOIN dbo.tblICLotStatus LS ON LS.intLotStatusId = L.intLotStatusId
	JOIN dbo.tblICItem I ON I.intItemId = L.intItemId
	JOIN tblICItemUOM IU ON IU.intItemUOMId = L.intItemUOMId
	JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
	JOIN tblICItemUOM IU1 ON IU1.intItemUOMId = IsNULL(L.intWeightUOMId, L.intItemUOMId)
	JOIN tblICUnitMeasure UM1 ON UM1.intUnitMeasureId = IU1.intUnitMeasureId
	WHERE L.intItemId = @intItemId
		AND L.dblQty > 0
		AND L.intLocationId = @intLocationId
		AND LS.strPrimaryStatus = 'Active'
		AND ISNULL(L.dtmExpiryDate - @intReceivedLife, @dtmCurrentDateTime) >= @dtmCurrentDateTime
		AND L.dtmDateCreated BETWEEN @dtmDateCreated
			AND @dtmDateCreated + @intAllowablePickDayRange
		AND ISNULL(L.intLotId, 0) = ISNULL((
				CASE 
					WHEN @intLineItemLotId IS NULL
						THEN L.intLotId
					ELSE @intLineItemLotId
					END
				), 0)
		AND ISNULL(L.intParentLotId, 0) = ISNULL((
				CASE 
					WHEN @intParentLotId IS NULL
						THEN L.intParentLotId
					ELSE @intParentLotId
					END
				), 0)
		AND IsNULL(L.intItemOwnerId, 0) = (
			CASE 
				WHEN @ysnPickByItemOwner = 1
					THEN @intItemOwnerId
				ELSE IsNULL(L.intItemOwnerId, 0)
				END
			)
		AND L.strLotNumber LIKE '%' + @strLotNumber + '%'
		AND L.intLotId = (
			CASE 
				WHEN @intLotId > 0
					THEN @intLotId
				ELSE L.intLotId
				END
			)
		AND L.intOwnershipType = IsNULL(@intOwnershipType, L.intOwnershipType)
	GROUP BY L.intLotId
		,L.intItemId
		,L.dblQty
		,L.intItemUOMId
		,L.dblWeight
		,L.intWeightUOMId
		,L.dtmDateCreated
		,L.dtmManufacturedDate
		,PL.strParentLotNumber
		,I.ysnStrictFIFO
		,I.intUnitPerLayer
		,I.intLayerPerPallet
		,I.strItemNo
		,I.strDescription
		,PL.strParentLotNumber
		,L.strLotNumber
		,L.strLotAlias
		,UM.strUnitMeasure
		,UM1.strUnitMeasure
		,SL.strName
	HAVING (
			CASE 
				WHEN IsNULL(@ysnAllowPartialPallet, 1) = 0
					THEN (
							CAST(CASE 
									WHEN (
											(I.intUnitPerLayer * I.intLayerPerPallet > 0)
											AND (
												(
													L.dblQty - (
														SUM(ISNULL(dbo.fnMFConvertQuantityToTargetItemUOM(SR.intItemUOMId, L.intItemUOMId, SR.dblQty), 0))
														)
													) % (I.intUnitPerLayer * I.intLayerPerPallet) > 0
												)
											)
										THEN 1
									ELSE 0
									END AS BIT)
							)
				ELSE 1
				END
			) = IsNULL(@ysnAllowPartialPallet, 1)
	ORDER BY CASE 
			WHEN I.ysnStrictFIFO = 1
				AND @ysnPickByLotCode = 0
				THEN ISNULL(L.dtmManufacturedDate, L.dtmDateCreated)
			ELSE '1900-01-01'
			END ASC
		,CASE 
			WHEN I.ysnStrictFIFO = 1
				AND @ysnPickByLotCode = 1
				THEN CAST(CASE 
							WHEN (
									(IsNULL(I.intUnitPerLayer, 0) * IsNULL(I.intLayerPerPallet, 0) > 0)
									AND (L.dblQty % (I.intUnitPerLayer * I.intLayerPerPallet) > 0)
									)
								THEN 0
							ELSE 1
							END AS BIT)
			ELSE '1'
			END ASC
		,CASE 
			WHEN I.ysnStrictFIFO = 1
				AND @ysnPickByLotCode = 1
				THEN Substring(PL.strParentLotNumber, @intLotCodeStartingPosition, @intLotCodeNoOfDigits)
			ELSE '1'
			END ASC
		,CASE 
			WHEN I.ysnStrictFIFO = 0
				AND @intPreferenceId = 2
				THEN L.dblQty
			WHEN I.ysnStrictFIFO = 0
				AND @intPreferenceId IN (
					1
					,3
					)
				THEN ABS((
							(
								CASE 
									WHEN L.intWeightUOMId IS NULL
										THEN L.dblQty
									ELSE L.dblWeight
									END
								) - (
								SUM(ISNULL(dbo.fnMFConvertQuantityToTargetItemUOM(SR.intItemUOMId,IsNULL(L.intWeightUOMId,L.intItemUOMId), SR.dblQty), 0))
								)
							) - @dblRequiredWeight)
			ELSE 0
			END ASC
		,L.dtmDateCreated ASC
END
ELSE
BEGIN
	SELECT L.intLotId
		,I.strItemNo
		,I.strDescription
		,PL.strParentLotNumber
		,L.strLotNumber
		,L.strLotAlias
		,L.intItemUOMId AS intQtyUOMId
		,UM.strUnitMeasure AS strQtyUOM
		,L.intWeightUOMId
		,UM1.strUnitMeasure AS strWeightUOM
		,SL.strName
		,L.dblQty
		,CASE 
			WHEN L.intWeightUOMId IS NULL
				THEN L.dblQty
			ELSE L.dblWeight
			END AS dblWeight
		,(
			SUM(ISNULL(dbo.fnMFConvertQuantityToTargetItemUOM(SR.intItemUOMId, L.intItemUOMId, SR.dblQty), 0))
			) AS dblReservedQty
		,CASE 
			WHEN L.intWeightUOMId IS NULL
				THEN (
						SUM(ISNULL(dbo.fnMFConvertQuantityToTargetItemUOM(SR.intItemUOMId, L.intItemUOMId, SR.dblQty), 0))
						)
			ELSE (
					SUM(ISNULL(dbo.fnMFConvertQuantityToTargetItemUOM(SR.intItemUOMId, L.intWeightUOMId, SR.dblQty), 0))
					)
			END AS dblReservedWeight
		,L.dblQty - (
			SUM(ISNULL(dbo.fnMFConvertQuantityToTargetItemUOM(SR.intItemUOMId, L.intItemUOMId, SR.dblQty), 0))
			) AS dblAvailableQty
		,CASE 
			WHEN L.intWeightUOMId IS NULL
				THEN L.dblQty - (
						SUM(ISNULL(dbo.fnMFConvertQuantityToTargetItemUOM(SR.intItemUOMId, L.intItemUOMId, SR.dblQty), 0))
						)
			ELSE L.dblWeight - (
					SUM(ISNULL(dbo.fnMFConvertQuantityToTargetItemUOM(SR.intItemUOMId, L.intWeightUOMId, SR.dblQty), 0))
					)
			END AS dblAvailableWeight
	FROM tblICLot L
	JOIN tblICStorageLocation SL ON SL.intStorageLocationId = L.intStorageLocationId
	JOIN tblICStorageUnitType UT ON UT.intStorageUnitTypeId = SL.intStorageUnitTypeId
		AND UT.ysnAllowPick = 1
	LEFT JOIN tblICStockReservation SR ON SR.intLotId = L.intLotId and SR.ysnPosted =0 and SR.intTransactionId<>@intOrderHeaderId
	JOIN dbo.tblICRestriction R ON R.intRestrictionId = IsNULL(SL.intRestrictionId, R.intRestrictionId)
		AND R.strInternalCode = 'STOCK'
	LEFT JOIN dbo.tblMFLotInventory LI ON LI.intLotId = L.intLotId
	JOIN dbo.tblICParentLot PL ON PL.intParentLotId = L.intParentLotId
	JOIN dbo.tblICLotStatus BS ON BS.intLotStatusId = ISNULL(LI.intBondStatusId, 1)
		AND BS.strPrimaryStatus = 'Active'
	JOIN dbo.tblICLotStatus LS ON LS.intLotStatusId = L.intLotStatusId
	JOIN dbo.tblICItem I ON I.intItemId = L.intItemId
	JOIN tblICItemUOM IU ON IU.intItemUOMId = L.intItemUOMId
	JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
	JOIN tblICItemUOM IU1 ON IU1.intItemUOMId = IsNULL(L.intWeightUOMId, L.intItemUOMId)
	JOIN tblICUnitMeasure UM1 ON UM1.intUnitMeasureId = IU1.intUnitMeasureId
	LEFT JOIN tblMFTask T ON T.intLotId = L.intLotId
		AND T.intTaskTypeId NOT IN (
			5
			,6
			,8
			,9
			,10
			,11
			)
	WHERE L.intItemId = @intItemId
		AND L.dblQty > 0
		AND L.intLocationId = @intLocationId
		AND LS.strPrimaryStatus = 'Active'
		AND ISNULL(L.dtmExpiryDate - @intReceivedLife, @dtmCurrentDateTime) >= @dtmCurrentDateTime
		AND ISNULL(L.intLotId, 0) = ISNULL((
				CASE 
					WHEN @intLineItemLotId IS NULL
						THEN L.intLotId
					ELSE @intLineItemLotId
					END
				), 0)
		AND ISNULL(L.intParentLotId, 0) = ISNULL((
				CASE 
					WHEN @intParentLotId IS NULL
						THEN L.intParentLotId
					ELSE @intParentLotId
					END
				), 0)
		AND IsNULL(L.intItemOwnerId, 0) = (
			CASE 
				WHEN @ysnPickByItemOwner = 1
					THEN @intItemOwnerId
				ELSE IsNULL(L.intItemOwnerId, 0)
				END
			)
		AND L.strLotNumber LIKE '%' + @strLotNumber + '%'
		AND L.intLotId = (
			CASE 
				WHEN @intLotId > 0
					THEN @intLotId
				ELSE L.intLotId
				END
			)
		AND L.intOwnershipType = IsNULL(@intOwnershipType, L.intOwnershipType)
		AND L.intLotId NOT IN (Select IsNULL(T.intLotId,0) from tblMFTask Where intOrderHeaderId=@intOrderHeaderId)
	GROUP BY L.intLotId
		,L.intItemId
		,L.dblQty
		,L.intItemUOMId
		,L.dblWeight
		,L.intWeightUOMId
		,L.dtmDateCreated
		,L.dtmManufacturedDate
		,PL.strParentLotNumber
		,I.ysnStrictFIFO
		,I.intUnitPerLayer
		,I.intLayerPerPallet
		,I.strItemNo
		,I.strDescription
		,PL.strParentLotNumber
		,L.strLotNumber
		,L.strLotAlias
		,UM.strUnitMeasure
		,UM1.strUnitMeasure
		,SL.strName
	HAVING (
			CASE 
				WHEN IsNULL(@ysnAllowPartialPallet, 1) = 0
					THEN (
							CAST(CASE 
									WHEN (
											(I.intUnitPerLayer * I.intLayerPerPallet > 0)
											AND (
												(
													L.dblQty - (
														SUM(ISNULL(dbo.fnMFConvertQuantityToTargetItemUOM(SR.intItemUOMId, L.intItemUOMId, SR.dblQty), 0))
														)
													) % (I.intUnitPerLayer * I.intLayerPerPallet) > 0
												)
											)
										THEN 1
									ELSE 0
									END AS BIT)
							)
				ELSE 1
				END
			) = IsNULL(@ysnAllowPartialPallet, 1)
	ORDER BY CASE 
			WHEN I.ysnStrictFIFO = 1
				AND @ysnPickByLotCode = 0
				THEN ISNULL(L.dtmManufacturedDate, L.dtmDateCreated)
			ELSE '1900-01-01'
			END ASC
		,CASE 
			WHEN I.ysnStrictFIFO = 1
				AND @ysnPickByLotCode = 1
				THEN CAST(CASE 
							WHEN (
									(IsNULL(I.intUnitPerLayer, 0) * IsNULL(I.intLayerPerPallet, 0) > 0)
									AND (L.dblQty % (I.intUnitPerLayer * I.intLayerPerPallet) > 0)
									)
								THEN 0
							ELSE 1
							END AS BIT)
			ELSE '1'
			END ASC
		,CASE 
			WHEN I.ysnStrictFIFO = 1
				AND @ysnPickByLotCode = 1
				THEN Substring(PL.strParentLotNumber, @intLotCodeStartingPosition, @intLotCodeNoOfDigits)
			ELSE '1'
			END ASC
		,CASE 
			WHEN I.ysnStrictFIFO = 0
				AND @intPreferenceId = 2
				THEN L.dblQty
			WHEN I.ysnStrictFIFO = 0
				AND @intPreferenceId IN (
					1
					,3
					)
				THEN ABS((
							(
								CASE 
									WHEN L.intWeightUOMId IS NULL
										THEN L.dblQty
									ELSE L.dblWeight
									END
								) - (
								SUM(ISNULL(dbo.fnMFConvertQuantityToTargetItemUOM(SR.intItemUOMId,IsNULL(L.intWeightUOMId,L.intItemUOMId), SR.dblQty), 0))
								)
							) - @dblRequiredWeight)
			ELSE 0
			END ASC
		,L.dtmDateCreated ASC
END
