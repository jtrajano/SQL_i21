CREATE PROCEDURE uspMFGenerateTask @intOrderHeaderId INT
	,@intEntityUserSecurityId INT
	,@ysnAllTasksNotGenerated BIT = 0 OUTPUT
AS
BEGIN TRY
	DECLARE @intAllowablePickDayRange INT
		,@RequiredQty NUMERIC(18, 6)
		,@strOrderNo NVARCHAR(100)
		,@strOrderType NVARCHAR(50)
		,@strOrderDirection NVARCHAR(50)
		,@strErrMsg NVARCHAR(MAX)
		,@intTransactionCount INT
		,@dtmCurrentDateTime DATETIME
		,@dtmCurrentDate DATETIME
		,@intDayOfYear INT
		,@intLotRecordId INT
		,@intItemRecordId INT
		,@intOrderDetailId INT
		,@intItemId INT
		,@dblRequiredQty NUMERIC(18, 6)
		,@dblRequiredWeight NUMERIC(18, 6)
		,@ysnStrictTracking BIT
		,@intUserSecurityId INT
		,@intTaskTypeId INT
		,@intLineItemLotId INT
		,@dblPutbackQty NUMERIC(18, 6)
		,@dblPutbackWeight NUMERIC(18, 6)
		,@dblQty NUMERIC(18, 6)
		,@dblRemainingLotQty NUMERIC(18, 6)
		,@dblWeight NUMERIC(18, 6)
		,@dblRemainingLotWeight NUMERIC(18, 6)
		,@intLotId INT
		,@intTaskCount INT
		,@ysnPickByLotCode BIT
		,@intLotCodeStartingPosition INT
		,@intLotCodeNoOfDigits INT
		,@intTaskRecordId INT
		,@dblTotalTaskWeight NUMERIC(18, 6)
		,@dblLineItemWeight NUMERIC(18, 6)
		,@intCategoryId INT
		,@ysnAllowPartialPallet BIT
		,@dblSplitAndPickQty NUMERIC(18, 6)
		,@ysnPickByQty BIT
		,@intRequiredUOMId INT
		,@intLotItemUOMId INT
		,@intPreferenceId INT
		,@intParentLotId INT
		,@ItemsToReserve AS dbo.ItemReservationTableType
		,@intInventoryTransactionType AS INT = 5
		,@intTransactionId INT
		,@strTransactionId NVARCHAR(50)
		,@intInventoryShipmentId INT
		,@intUnitPerPallet INT
		,@intLotCode1 INT
		,@intLotCode2 INT
		,@dtmDateCreated1 DATETIME
		,@dtmDateCreated2 DATETIME
		,@intPartialPickSubLocationId INT
		,@intUnitPerPallet2 INT
		,@intStorageLocationId INT
		,@intWorkOrderId INT
		,@intManufacturingProcessId INT
		,@intOwnershipType INT
		,@intDefaultConsumptionLocationId INT

	SELECT @ysnPickByQty = 1

	DECLARE @tblTaskGenerated TABLE (
		intTaskRecordId INT Identity(1, 1)
		,intItemId INT
		,dblTotalTaskWeight NUMERIC(18, 6)
		,dblLineItemWeight NUMERIC(18, 6)
		)
	DECLARE @intReceivedLife INT
		,@strReferenceNo NVARCHAR(50)
		,@intEntityCustomerId INT
		,@intItemOwnerId INT
		,@ysnPickByItemOwner BIT
		,@intPackagingCategoryId INT
		,@strPackagingCategory NVARCHAR(50)
		,@intPMCategoryId INT
		,@strPickByFullPallet NVARCHAR(50)
		,@intCustomerLabelTypeId INT
		,@intOrderId INT
		,@intLocationId INT
		,@strInventoryTracking NVARCHAR(50)
		,@strWorkOrderNo NVARCHAR(50)

	SELECT @strOrderType = OT.strOrderType
		,@strOrderNo = OH.strOrderNo
		,@strOrderDirection = OD.strOrderDirection
		,@strReferenceNo = OH.strReferenceNo
		,@intOrderId = intOrderHeaderId
		,@intLocationId = intLocationId
	FROM tblMFOrderHeader OH
	JOIN tblMFOrderType OT ON OT.intOrderTypeId = OH.intOrderTypeId
	JOIN tblMFOrderDirection OD ON OD.intOrderDirectionId = OH.intOrderDirectionId
	WHERE OH.intOrderHeaderId = @intOrderHeaderId

	SELECT @intWorkOrderId = intWorkOrderId
	FROM tblMFStageWorkOrder SW
	WHERE SW.intOrderHeaderId = @intOrderHeaderId

	SELECT @intManufacturingProcessId = intManufacturingProcessId
		,@strWorkOrderNo = strWorkOrderNo
	FROM tblMFWorkOrder
	WHERE intWorkOrderId = @intWorkOrderId

	SELECT @intPackagingCategoryId = intAttributeId
	FROM tblMFAttribute
	WHERE strAttributeName = 'Packaging Category'

	SELECT @intPMCategoryId = strAttributeValue
	FROM tblMFManufacturingProcessAttribute
	WHERE intAttributeId = @intPackagingCategoryId
		AND intManufacturingProcessId = @intManufacturingProcessId
		AND intLocationId = @intLocationId

	IF @intPMCategoryId IS NULL
	BEGIN
		SELECT @intPMCategoryId = 0
	END

	SELECT @strPickByFullPallet = strAttributeValue
	FROM tblMFManufacturingProcessAttribute
	WHERE intAttributeId = 92
		AND intManufacturingProcessId = @intManufacturingProcessId
		AND intLocationId = @intLocationId

	IF @strPickByFullPallet IS NULL
		OR @strPickByFullPallet = ''
		SELECT @strPickByFullPallet = 'False'

	SELECT @intPartialPickSubLocationId = strAttributeValue
	FROM tblMFManufacturingProcessAttribute
	WHERE intAttributeId = 43
		AND intManufacturingProcessId = @intManufacturingProcessId
		AND intLocationId = @intLocationId

	IF @intPartialPickSubLocationId IS NULL
	BEGIN
		SELECT @intPartialPickSubLocationId = 0
	END

	SELECT @intReceivedLife = 0
		,@ysnPickByItemOwner = 0
		,@intItemOwnerId = 0

	SELECT @intTransactionCount = @@TRANCOUNT

	SELECT @dtmCurrentDateTime = GETDATE()

	SELECT @ysnPickByLotCode = ysnPickByLotCode
		,@intLotCodeStartingPosition = intLotCodeStartingPosition
		,@intLotCodeNoOfDigits = intLotCodeNoOfDigits
		,@ysnPickByItemOwner = ysnPickByItemOwner
	FROM tblMFCompanyPreference

	SELECT @intAllowablePickDayRange = intAllowablePickDayRange
	FROM tblMFCompanyPreference

	IF @intAllowablePickDayRange IS NULL
		SELECT @intAllowablePickDayRange = 60

	IF @intLotCodeStartingPosition IS NULL
		SELECT @intLotCodeStartingPosition = 2

	IF @intLotCodeNoOfDigits IS NULL
		SELECT @intLotCodeNoOfDigits = 5

	SELECT @dtmCurrentDate = CONVERT(DATETIME, CONVERT(CHAR, @dtmCurrentDateTime, 101))

	SELECT @intDayOfYear = DATEPART(dy, @dtmCurrentDateTime)

	IF @intTransactionCount = 0
		BEGIN TRANSACTION

	IF (@strOrderDirection = 'OUTBOUND')
	BEGIN
		DECLARE @tblLineItem TABLE (
			intItemRecordId INT Identity(1, 1)
			,intOrderHeaderId INT
			,intOrderDetailId INT
			,intItemId INT
			,dblRequiredQty NUMERIC(18, 6)
			,intItemUOMId INT
			,dblRequiredWeight NUMERIC(18, 6)
			,intWeightUOMId INT
			,ysnStrictTracking BIT
			,intLotId INT
			,intCategoryId INT
			,intPreferenceId INT
			,intParentLotId INT
			,intUnitPerPallet INT
			,strInventoryTracking NVARCHAR(50)
			,intOwnershipType INT
			,intStorageLocationId INT
			)
		DECLARE @tblLot TABLE (
			intLotRecordId INT Identity(1, 1)
			,intLotId INT
			,intItemId INT
			,dblQty NUMERIC(18, 6)
			,intItemUOMId INT
			,dblWeight NUMERIC(18, 6)
			,intWeightUOMId INT
			,dblRemainingLotQty NUMERIC(18, 6)
			,dblRemainingLotWeight NUMERIC(18, 6)
			,dtmProductionDate DATETIME
			,intGroupId INT
			,intSubLocationId INT
			,intStorageLocationId INT
			)

		UPDATE tblMFOrderDetail
		SET dblWeight = dblQty
		WHERE dblQty > 0
			AND (
				dblWeight = 0
				OR dblWeight IS NULL
				)

		INSERT INTO @tblLineItem (
			intOrderHeaderId
			,intOrderDetailId
			,intItemId
			,dblRequiredQty
			,intItemUOMId
			,dblRequiredWeight
			,intWeightUOMId
			,ysnStrictTracking
			,intLotId
			,intCategoryId
			,intPreferenceId
			,intParentLotId
			,intUnitPerPallet
			,strInventoryTracking
			,intOwnershipType
			,intStorageLocationId
			)
		SELECT DISTINCT oh.intOrderHeaderId
			,oli.intOrderDetailId
			,i.intItemId
			,oli.dblQty - ISNULL((
					SELECT SUM(CASE 
								WHEN t.intTaskTypeId = 13
									THEN l.dblQty - t.dblQty
								ELSE t.dblQty
								END)
					FROM tblMFTask t
					JOIN tblICLot l ON l.intLotId = t.intLotId
					WHERE t.intOrderHeaderId = oh.intOrderHeaderId
						AND t.intItemId = oli.intItemId
					), 0) dblRemainingLineItemQty
			,oli.intItemUOMId
			,oli.dblWeight - ISNULL((
					SELECT SUM(CASE 
								WHEN t.intTaskTypeId = 13
									THEN l.dblWeight - t.dblWeight
								ELSE t.dblWeight
								END)
					FROM tblMFTask t
					JOIN tblICLot l ON l.intLotId = t.intLotId
					WHERE t.intOrderHeaderId = oh.intOrderHeaderId
						AND t.intItemId = oli.intItemId
					), 0)
			,oli.intWeightUOMId
			,i.ysnStrictFIFO
			,oli.intLotId
			,i.intCategoryId
			,oli.intPreferenceId
			,oli.intParentLotId
			,IsNULL(i.intUnitPerLayer * i.intLayerPerPallet, 0)
			,i.strInventoryTracking
			,oli.intOwnershipType
			,oli.intStorageLocationId
		FROM tblMFOrderHeader oh
		JOIN tblMFOrderDetail oli ON oh.intOrderHeaderId = oli.intOrderHeaderId
		JOIN tblICItem i ON i.intItemId = oli.intItemId
		WHERE oh.intOrderHeaderId = @intOrderHeaderId
			AND oli.dblQty > 0

		DELETE
		FROM @tblLineItem
		WHERE dblRequiredQty <= 0

		SELECT @intItemRecordId = MIN(intItemRecordId)
		FROM @tblLineItem

		WHILE (@intItemRecordId IS NOT NULL)
		BEGIN
			SELECT @intLotRecordId = NULL

			SELECT @intItemId = NULL

			SELECT @dblRequiredQty = NULL

			SELECT @dblRequiredWeight = NULL

			SELECT @dblPutbackQty = NULL

			SELECT @dblPutbackWeight = NULL

			SELECT @ysnStrictTracking = NULL

			SELECT @dblQty = NULL

			SELECT @intLineItemLotId = NULL

			SELECT @intRequiredUOMId = NULL

			SELECT @intCategoryId = NULL

			SELECT @intPreferenceId = NULL

			SELECT @intParentLotId = NULL

			SELECT @intUnitPerPallet = NULL

			SELECT @intUnitPerPallet2 = NULL

			SELECT @strInventoryTracking = NULL

			SELECT @intOwnershipType = NULL

			SELECT @intDefaultConsumptionLocationId = NULL

			DELETE
			FROM @tblLot

			SELECT @intOrderDetailId = intOrderDetailId
				,@intItemId = intItemId
				,@dblRequiredQty = dblRequiredQty
				,@dblRequiredWeight = dblRequiredWeight
				,@intRequiredUOMId = intItemUOMId
				,@ysnStrictTracking = ysnStrictTracking
				,@intLineItemLotId = intLotId
				,@intCategoryId = intCategoryId
				,@intPreferenceId = intPreferenceId
				,@intParentLotId = intParentLotId
				,@intUnitPerPallet = intUnitPerPallet
				,@intUnitPerPallet2 = intUnitPerPallet
				,@strInventoryTracking = strInventoryTracking
				,@intOwnershipType = intOwnershipType
				,@intDefaultConsumptionLocationId = intStorageLocationId
			FROM @tblLineItem I
			WHERE intItemRecordId = @intItemRecordId

			IF @intUnitPerPallet > @dblRequiredQty
			BEGIN
				SELECT @intUnitPerPallet = @dblRequiredQty
			END

			IF @strOrderType = 'INVENTORY SHIPMENT STAGING'
			BEGIN
				SELECT @intEntityCustomerId = intEntityCustomerId
					,@intInventoryShipmentId = intInventoryShipmentId
				FROM tblICInventoryShipment
				WHERE strShipmentNumber = @strReferenceNo

				SELECT @intReceivedLife = intReceivedLife
					,@ysnAllowPartialPallet = ysnAllowPartialPallet
					,@intCustomerLabelTypeId = intCustomerLabelTypeId
				FROM tblMFItemOwner
				WHERE intOwnerId = @intEntityCustomerId
					AND intItemId = @intItemId

				IF @intReceivedLife = 0
					OR @intReceivedLife IS NULL
				BEGIN
					SELECT @intReceivedLife = intReceivedLife
						,@ysnAllowPartialPallet = ysnAllowPartialPallet
						,@intCustomerLabelTypeId = intCustomerLabelTypeId
					FROM tblMFItemOwner
					WHERE intOwnerId = @intEntityCustomerId
				END

				IF @ysnAllowPartialPallet IS NULL
				BEGIN
					SELECT @ysnAllowPartialPallet = ysnAllowPartialPallet
						,@intCustomerLabelTypeId = intCustomerLabelTypeId
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

				SELECT @intTransactionId = @intInventoryShipmentId

				SELECT @strTransactionId = @strReferenceNo

				SELECT @intInventoryTransactionType = 5
			END
			ELSE
			BEGIN
				SELECT @intTransactionId = @intWorkOrderId

				SELECT @strTransactionId = @strWorkOrderNo

				SELECT @intInventoryTransactionType = 9
			END

			--- INSERT ALL THE LOTS WITHIN THE ALLOWABLE PICK DAY RANGE
			--IF @ysnPickByLotCode = 1
			--BEGIN
			--	SELECT @intLotCode1 = MIN(Substring(PL.strParentLotNumber, @intLotCodeStartingPosition, @intLotCodeNoOfDigits))
			--	FROM tblICLot L
			--	JOIN tblICParentLot PL ON PL.intParentLotId = L.intParentLotId
			--	WHERE L.intItemId = @intItemId
			--		AND dblQty > 0
			--	SELECT @dtmDateCreated1 = DATEADD(day, CAST(RIGHT(@intLotCode1, 3) AS INT) - 1, CONVERT(DATETIME, LEFT(@intLotCode1, 2) + '0101', 112))
			--	SELECT @dtmDateCreated2 = @dtmDateCreated1 + @intAllowablePickDayRange
			--	SELECT @intLotCode2 = RIGHT(CAST(YEAR(@dtmDateCreated2) AS CHAR(4)), 2) + RIGHT('000' + CAST(DATEPART(dy, @dtmDateCreated2) AS VARCHAR(3)), 3)
			--END
			--ELSE
			BEGIN
				SELECT @dtmDateCreated1 = MIN(dtmDateCreated)
				FROM tblICLot
				WHERE intItemId = @intItemId
					AND dblQty > 0

				SELECT @dtmDateCreated2 = @dtmDateCreated1 + @intAllowablePickDayRange
			END

			IF @strInventoryTracking = 'Item Level'
			BEGIN
				INSERT INTO @tblLot (
					intLotId
					,intItemId
					,dblQty
					,intItemUOMId
					,dblWeight
					,intWeightUOMId
					,dblRemainingLotQty
					,dblRemainingLotWeight
					,dtmProductionDate
					,intGroupId
					,intSubLocationId
					,intStorageLocationId
					)
				SELECT NULL
					,S.intItemId
					,S.dblOnHand
					,S.intItemUOMId
					,S.dblOnHand
					,S.intItemUOMId
					,S.dblOnHand - (SUM(ISNULL(dbo.fnMFConvertQuantityToTargetItemUOM(SR.intItemUOMId, S.intItemUOMId, SR.dblQty), 0))) AS dblRemainingLotQty
					,S.dblOnHand - (SUM(ISNULL(dbo.fnMFConvertQuantityToTargetItemUOM(SR.intItemUOMId, S.intItemUOMId, SR.dblQty), 0))) AS dblRemainingLotWeight
					,NULL
					,1
					,S.intSubLocationId
					,S.intStorageLocationId
				FROM tblICItemStockUOM S
				JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = S.intItemUOMId
					AND IU.ysnStockUnit = 1
				JOIN dbo.tblICItemLocation IL ON IL.intItemLocationId = S.intItemLocationId
					AND IL.intLocationId = IsNULL(@intLocationId, IL.intLocationId)
					AND IL.intItemId = @intItemId
				LEFT JOIN tblICStockReservation SR ON SR.intItemId = S.intItemId
				JOIN dbo.tblICItem I ON I.intItemId = S.intItemId
				WHERE S.intItemId = @intItemId
					AND S.dblOnHand > 0
					AND IsNULL(S.intStorageLocationId, 0) = (
						CASE 
							WHEN S.intStorageLocationId IS NOT NULL
								AND @intDefaultConsumptionLocationId IS NOT NULL
								THEN @intDefaultConsumptionLocationId
							ELSE IsNULL(S.intStorageLocationId, 0)
							END
						)
				GROUP BY S.intItemId
					,S.dblOnHand
					,S.intItemUOMId
					,S.dblOnHand
					,S.intItemUOMId
					,S.dblOnHand
					,S.intSubLocationId
					,S.intStorageLocationId
					,I.ysnStrictFIFO
					,I.intUnitPerLayer
					,I.intLayerPerPallet
				HAVING S.dblOnHand - (SUM(ISNULL(dbo.fnMFConvertQuantityToTargetItemUOM(SR.intItemUOMId, S.intItemUOMId, SR.dblQty), 0))) > 0
					AND (
						CASE 
							WHEN IsNULL(@ysnAllowPartialPallet, 1) = 0
								THEN (
										CAST(CASE 
												WHEN (
														(I.intUnitPerLayer * I.intLayerPerPallet > 0)
														AND ((S.dblOnHand - (SUM(ISNULL(dbo.fnMFConvertQuantityToTargetItemUOM(SR.intItemUOMId, S.intItemUOMId, SR.dblQty), 0)))) % (I.intUnitPerLayer * I.intLayerPerPallet) > 0)
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
							AND @ysnPickByLotCode = 1
							THEN CAST(CASE 
										WHEN (
												(IsNULL(I.intUnitPerLayer, 0) * IsNULL(I.intLayerPerPallet, 0) > 0)
												AND (S.dblOnHand % (I.intUnitPerLayer * I.intLayerPerPallet) > 0)
												)
											THEN 0
										ELSE 1
										END AS BIT)
						ELSE '1'
						END ASC
					,CASE 
						WHEN I.ysnStrictFIFO = 0
							AND @intPreferenceId = 2
							THEN S.dblOnHand
						WHEN I.ysnStrictFIFO = 0
							AND @intPreferenceId = 3
							THEN ABS(S.dblOnHand - (SUM(ISNULL(dbo.fnMFConvertQuantityToTargetItemUOM(SR.intItemUOMId, S.intItemUOMId, SR.dblQty), 0))) - @intUnitPerPallet)
						ELSE 0
						END ASC
			END
			ELSE
			BEGIN
				INSERT INTO @tblLot (
					intLotId
					,intItemId
					,dblQty
					,intItemUOMId
					,dblWeight
					,intWeightUOMId
					,dblRemainingLotQty
					,dblRemainingLotWeight
					,dtmProductionDate
					,intGroupId
					,intSubLocationId
					,intStorageLocationId
					)
				SELECT L.intLotId
					,L.intItemId
					,L.dblQty
					,L.intItemUOMId
					,L.dblWeight
					,L.intWeightUOMId
					,L.dblQty - (SUM(ISNULL(dbo.fnMFConvertQuantityToTargetItemUOM(SR.intItemUOMId, L.intItemUOMId, SR.dblQty), 0))) AS dblRemainingLotQty
					,L.dblWeight - (SUM(ISNULL(dbo.fnMFConvertQuantityToTargetItemUOM(SR.intItemUOMId, L.intWeightUOMId, SR.dblQty), 0))) AS dblRemainingLotWeight
					,L.dtmDateCreated
					,1
					,L.intSubLocationId
					,L.intStorageLocationId
				FROM tblICLot L
				JOIN tblICStorageLocation SL ON SL.intStorageLocationId = L.intStorageLocationId
				JOIN tblICStorageUnitType UT ON UT.intStorageUnitTypeId = SL.intStorageUnitTypeId
					AND UT.ysnAllowPick = 1
				LEFT JOIN tblICStockReservation SR ON SR.intLotId = L.intLotId and SR.ysnPosted =0
				LEFT JOIN dbo.tblMFLotInventory LI ON LI.intLotId = L.intLotId
				JOIN dbo.tblICParentLot PL ON PL.intParentLotId = L.intParentLotId
				JOIN dbo.tblICLotStatus BS ON BS.intLotStatusId = ISNULL(LI.intBondStatusId, 1)
					AND BS.strPrimaryStatus = 'Active'
				JOIN dbo.tblICLotStatus LS ON LS.intLotStatusId = L.intLotStatusId
				JOIN dbo.tblICItem I ON I.intItemId = L.intItemId
				WHERE L.intLocationId = IsNULL(@intLocationId, L.intLocationId)
					AND IsNULL(L.intStorageLocationId, 0) = (
						CASE 
							WHEN L.intStorageLocationId IS NOT NULL
								AND @intDefaultConsumptionLocationId IS NOT NULL
								THEN @intDefaultConsumptionLocationId
							ELSE IsNULL(L.intStorageLocationId, 0)
							END
						)
					AND L.intItemId = @intItemId
					AND L.dblQty > 0
					AND LS.strPrimaryStatus = 'Active'
					AND ISNULL(L.dtmExpiryDate - @intReceivedLife, @dtmCurrentDateTime) >= @dtmCurrentDateTime
					AND (
						(
							@ysnPickByLotCode = 0
							AND L.dtmDateCreated BETWEEN @dtmDateCreated1
								AND @dtmDateCreated2
							)
						OR (
							@ysnPickByLotCode = 1
							AND Substring(PL.strParentLotNumber, @intLotCodeStartingPosition, @intLotCodeNoOfDigits) BETWEEN @intLotCode1
								AND @intLotCode2
							)
						)
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
					AND SL.intRestrictionId NOT IN (
						SELECT RT.intRestrictionId
						FROM tblMFInventoryShipmentRestrictionType RT
						)
					AND LI.ysnPickAllowed = 1
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
					,L.intSubLocationId
					,L.intStorageLocationId
				HAVING (
						CASE 
							WHEN L.intWeightUOMId IS NULL
								THEN L.dblQty
							ELSE L.dblWeight
							END
						) - (SUM(ISNULL(dbo.fnMFConvertQuantityToTargetItemUOM(SR.intItemUOMId, IsNULL(L.intWeightUOMId, L.intItemUOMId), SR.dblQty), 0))) > 0
					AND (
						CASE 
							WHEN IsNULL(@ysnAllowPartialPallet, 1) = 0
								THEN (
										CAST(CASE 
												WHEN (
														(I.intUnitPerLayer * I.intLayerPerPallet > 0)
														AND ((L.dblQty - (SUM(ISNULL(dbo.fnMFConvertQuantityToTargetItemUOM(SR.intItemUOMId, L.intItemUOMId, SR.dblQty), 0)))) % (I.intUnitPerLayer * I.intLayerPerPallet) > 0)
														)
													THEN 1
												ELSE 0
												END AS BIT)
										)
							ELSE 1
							END
						) = IsNULL(@ysnAllowPartialPallet, 1)
					AND (
						CASE 
							WHEN I.ysnStrictFIFO = 0
								AND @intPreferenceId = 1
								THEN L.dblQty - (SUM(ISNULL(dbo.fnMFConvertQuantityToTargetItemUOM(SR.intItemUOMId, L.intItemUOMId, SR.dblQty), 0)))
							ELSE 0
							END
						) = (
						CASE 
							WHEN I.ysnStrictFIFO = 0
								AND @intPreferenceId = 1
								THEN @intUnitPerPallet
							ELSE 0
							END
						)
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
							AND @intPreferenceId = 3
							THEN ABS(L.dblQty - (SUM(ISNULL(dbo.fnMFConvertQuantityToTargetItemUOM(SR.intItemUOMId, L.intItemUOMId, SR.dblQty), 0))) - @intUnitPerPallet)
						ELSE 0
						END ASC
					,L.dtmDateCreated ASC

				--- INSERT ALL THE LOTS OUTSIDE ALLOWABLE PICK DAY RANGE
				INSERT INTO @tblLot (
					intLotId
					,intItemId
					,dblQty
					,intItemUOMId
					,dblWeight
					,intWeightUOMId
					,dblRemainingLotQty
					,dblRemainingLotWeight
					,dtmProductionDate
					,intGroupId
					,intSubLocationId
					,intStorageLocationId
					)
				SELECT L.intLotId
					,L.intItemId
					,L.dblQty
					,L.intItemUOMId
					,L.dblWeight
					,L.intWeightUOMId
					,L.dblQty - (SUM(ISNULL(dbo.fnMFConvertQuantityToTargetItemUOM(SR.intItemUOMId, L.intItemUOMId, SR.dblQty), 0))) AS dblRemainingLotQty
					,L.dblWeight - (SUM(ISNULL(dbo.fnMFConvertQuantityToTargetItemUOM(SR.intItemUOMId, L.intWeightUOMId, SR.dblQty), 0))) AS dblRemainingLotWeight
					,L.dtmDateCreated
					,2
					,L.intSubLocationId
					,L.intStorageLocationId
				FROM tblICLot L
				JOIN tblICStorageLocation SL ON SL.intStorageLocationId = L.intStorageLocationId
				JOIN tblICStorageUnitType UT ON UT.intStorageUnitTypeId = SL.intStorageUnitTypeId
					AND UT.ysnAllowPick = 1
				LEFT JOIN tblICStockReservation SR ON SR.intLotId = L.intLotId and SR.ysnPosted =0
				LEFT JOIN dbo.tblMFLotInventory LI ON LI.intLotId = L.intLotId
				JOIN dbo.tblICLotStatus BS ON BS.intLotStatusId = ISNULL(LI.intBondStatusId, 1)
					AND BS.strPrimaryStatus = 'Active'
				JOIN dbo.tblICParentLot PL ON PL.intParentLotId = L.intParentLotId
				JOIN dbo.tblICLotStatus LS ON LS.intLotStatusId = L.intLotStatusId
				JOIN dbo.tblICItem I ON I.intItemId = L.intItemId
				WHERE L.intLocationId = IsNULL(@intLocationId, L.intLocationId)
					AND IsNULL(L.intStorageLocationId, 0) = (
						CASE 
							WHEN L.intStorageLocationId IS NOT NULL
								AND @intDefaultConsumptionLocationId IS NOT NULL
								THEN @intDefaultConsumptionLocationId
							ELSE IsNULL(L.intStorageLocationId, 0)
							END
						)
					AND L.intItemId = @intItemId
					AND L.dblQty > 0
					AND LS.strPrimaryStatus = 'Active'
					AND ISNULL(L.dtmExpiryDate - @intReceivedLife, @dtmCurrentDateTime) >= @dtmCurrentDateTime
					AND NOT EXISTS (
						SELECT *
						FROM @tblLot
						WHERE intLotId = L.intLotId
						)
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
					AND SL.intRestrictionId NOT IN (
						SELECT RT.intRestrictionId
						FROM tblMFInventoryShipmentRestrictionType RT
						)
					AND LI.ysnPickAllowed = 1
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
					,L.intSubLocationId
					,L.intStorageLocationId
				HAVING (
						CASE 
							WHEN L.intWeightUOMId IS NULL
								THEN L.dblQty
							ELSE L.dblWeight
							END
						) - (SUM(ISNULL(dbo.fnMFConvertQuantityToTargetItemUOM(SR.intItemUOMId, IsNULL(L.intWeightUOMId, L.intItemUOMId), SR.dblQty), 0))) > 0
					AND (
						CASE 
							WHEN IsNULL(@ysnAllowPartialPallet, 1) = 0
								THEN (
										CAST(CASE 
												WHEN (
														(I.intUnitPerLayer * I.intLayerPerPallet > 0)
														AND ((L.dblQty - (SUM(ISNULL(dbo.fnMFConvertQuantityToTargetItemUOM(SR.intItemUOMId, L.intItemUOMId, SR.dblQty), 0)))) % (I.intUnitPerLayer * I.intLayerPerPallet) > 0)
														)
													THEN 1
												ELSE 0
												END AS BIT)
										)
							ELSE 1
							END
						) = IsNULL(@ysnAllowPartialPallet, 1)
				ORDER BY CASE 
						WHEN @ysnPickByLotCode = 0
							THEN ISNULL(L.dtmManufacturedDate, L.dtmDateCreated)
						ELSE '1900-01-01'
						END ASC
					,CASE 
						WHEN @ysnPickByLotCode = 1
							THEN Substring(PL.strParentLotNumber, @intLotCodeStartingPosition, @intLotCodeNoOfDigits)
						ELSE '1'
						END ASC
					,L.dtmDateCreated ASC
			END

			SET @intLotRecordId = NULL

			SELECT TOP 1 @intLotRecordId = intLotRecordId
			FROM @tblLot s
			WHERE intGroupId = 1
				AND intSubLocationId = (
					CASE 
						WHEN @intPartialPickSubLocationId IS NOT NULL
							AND @intUnitPerPallet2 > 0
							AND @intUnitPerPallet2 <> @intUnitPerPallet
							THEN @intPartialPickSubLocationId
						ELSE intSubLocationId
						END
					)
			ORDER BY (
					CASE 
						WHEN @ysnStrictTracking = 0
							AND @intPreferenceId = 3
							THEN ABS(dblRemainingLotQty - @intUnitPerPallet)
						ELSE intLotRecordId
						END
					) ASC

			IF @intLotRecordId IS NULL
			BEGIN
				SELECT TOP 1 @intLotRecordId = intLotRecordId
				FROM @tblLot s
				WHERE intGroupId = 2
					AND intSubLocationId = (
						CASE 
							WHEN @intPartialPickSubLocationId IS NOT NULL
								AND @intUnitPerPallet2 > 0
								AND @intUnitPerPallet2 <> @intUnitPerPallet
								THEN @intPartialPickSubLocationId
							ELSE intSubLocationId
							END
						)
				ORDER BY intLotRecordId ASC
			END

			IF @intLotRecordId IS NULL
			BEGIN
				SELECT TOP 1 @intLotRecordId = intLotRecordId
				FROM @tblLot s
				WHERE intGroupId = 1
				ORDER BY (
						CASE 
							WHEN @ysnStrictTracking = 0
								AND @intPreferenceId = 3
								THEN ABS(dblRemainingLotQty - @intUnitPerPallet)
							ELSE intLotRecordId
							END
						) ASC
			END

			IF @intLotRecordId IS NULL
			BEGIN
				SELECT TOP 1 @intLotRecordId = intLotRecordId
				FROM @tblLot s
				WHERE intGroupId = 2
				ORDER BY intLotRecordId ASC
			END

			WHILE (@intLotRecordId IS NOT NULL)
			BEGIN
				SELECT @intLotItemUOMId = NULL

				SELECT @intStorageLocationId = NULL

				SELECT @dblQty = NULL

				SELECT @intLotId = NULL

				SELECT @dblRemainingLotQty = NULL

				SELECT @dblWeight = NULL

				SELECT @dblRemainingLotWeight = NULL

				SELECT @intLotItemUOMId = NULL

				SELECT @dblQty = dblQty
					,@intLotId = intLotId
					,@dblRemainingLotQty = dblRemainingLotQty
					,@dblWeight = (
						CASE 
							WHEN intWeightUOMId IS NULL
								THEN dblQty
							ELSE dblWeight
							END
						)
					,@dblRemainingLotWeight = (
						CASE 
							WHEN intWeightUOMId IS NULL
								THEN dblRemainingLotQty
							ELSE dblRemainingLotWeight
							END
						)
					,@intLotItemUOMId = intItemUOMId
					,@intStorageLocationId = intStorageLocationId
				FROM @tblLot
				WHERE intLotRecordId = @intLotRecordId

				IF @strPickByFullPallet = 'True'
					AND @strOrderType = 'WO PROD STAGING'
				BEGIN
					EXEC [uspMFCreatePickTask] @intOrderHeaderId = @intOrderHeaderId
						,@intLotId = @intLotId
						,@intEntityUserSecurityId = @intEntityUserSecurityId
						,@intItemId = @intItemId
						,@intOrderDetailId = @intOrderDetailId
						,@intFromStorageLocationId = @intStorageLocationId
						,@dblLotQty = @dblWeight
						,@intItemUOMId = @intLotItemUOMId

					SET @dblRequiredWeight = @dblRequiredWeight - @dblWeight

					IF @dblRequiredWeight <= 0
					BEGIN
						BREAK;
					END
				END
				ELSE IF (
						@strOrderType = 'INVENTORY SHIPMENT STAGING'
						AND @ysnPickByQty = 1
						)
					OR (
						@strPickByFullPallet = 'False'
						AND @strOrderType = 'WO PROD STAGING'
						)
				BEGIN
					SELECT @dblSplitAndPickQty = NULL

					SELECT @dblSplitAndPickQty = (
							CASE 
								WHEN dbo.fnMFConvertQuantityToTargetItemUOM(@intLotItemUOMId, @intRequiredUOMId, @dblRemainingLotQty) >= @dblRequiredQty
									THEN dbo.fnMFConvertQuantityToTargetItemUOM(@intRequiredUOMId, @intLotItemUOMId, @dblRequiredQty)
								ELSE @dblRemainingLotQty
								END
							)

					EXEC [uspMFCreateSplitAndPickTaskO1] @intOrderHeaderId = @intOrderHeaderId
						,@intLotId = @intLotId
						,@intEntityUserSecurityId = @intEntityUserSecurityId
						,@dblSplitAndPickQty = @dblSplitAndPickQty
						,@intTaskTypeId = 2
						,@intItemId = @intItemId
						,@intOrderDetailId = @intOrderDetailId
						,@intFromStorageLocationId = @intStorageLocationId
						,@intItemUOMId = @intLotItemUOMId

					SET @dblRequiredQty = @dblRequiredQty - (
							CASE 
								WHEN dbo.fnMFConvertQuantityToTargetItemUOM(@intLotItemUOMId, @intRequiredUOMId, @dblRemainingLotQty) >= @dblRequiredQty
									THEN @dblRequiredQty
								ELSE dbo.fnMFConvertQuantityToTargetItemUOM(@intLotItemUOMId, @intRequiredUOMId, @dblRemainingLotQty)
								END
							)

					IF @dblRequiredQty <= 0
					BEGIN
						BREAK;
					END
				END
				ELSE IF (@dblRemainingLotWeight > @dblRequiredWeight)
					AND (@dblRequiredWeight > (@dblRemainingLotWeight / 2))
				BEGIN
					SET @dblPutbackQty = @dblRemainingLotQty - @dblRequiredQty
					SET @dblPutbackWeight = @dblRemainingLotWeight - @dblRequiredWeight

					EXEC [uspMFCreateSplitAndPickTask] @intOrderHeaderId = @intOrderHeaderId
						,@intLotId = @intLotId
						,@intEntityUserSecurityId = @intEntityUserSecurityId
						,@dblSplitAndPickWeight = @dblRequiredWeight
						,@intTaskTypeId = 2
						,@intItemId = @intItemId
						,@intOrderDetailId = @intOrderDetailId
						,@intFromStorageLocationId = @intStorageLocationId
						,@intItemUOMId = @intLotItemUOMId

					SET @dblRequiredWeight = @dblRequiredWeight - @dblRemainingLotWeight

					IF @dblRequiredWeight <= 0
					BEGIN
						BREAK;
					END
				END
				ELSE IF (@dblRemainingLotWeight <= @dblRequiredWeight)
					AND @dblWeight = @dblRemainingLotWeight
				BEGIN
					EXEC [uspMFCreatePickTask] @intOrderHeaderId = @intOrderHeaderId
						,@intLotId = @intLotId
						,@intEntityUserSecurityId = @intEntityUserSecurityId
						,@intItemId = @intItemId
						,@intOrderDetailId = @intOrderDetailId
						,@intFromStorageLocationId = @intStorageLocationId
						,@dblLotQty = @dblWeight
						,@intItemUOMId = @intLotItemUOMId

					SET @dblRequiredWeight = @dblRequiredWeight - @dblWeight

					IF @dblRequiredWeight <= 0
					BEGIN
						BREAK;
					END
				END
				ELSE
				BEGIN
					IF @dblRequiredWeight <= 0
					BEGIN
						BREAK;
					END

					IF (@dblRemainingLotWeight <= @dblRequiredWeight)
					BEGIN
						EXEC [uspMFCreateSplitAndPickTask] @intOrderHeaderId = @intOrderHeaderId
							,@intLotId = @intLotId
							,@intEntityUserSecurityId = @intEntityUserSecurityId
							,@dblSplitAndPickWeight = @dblRemainingLotWeight
							,@intTaskTypeId = 2
							,@intItemId = @intItemId
							,@intOrderDetailId = @intOrderDetailId
							,@intFromStorageLocationId = @intStorageLocationId
							,@intItemUOMId = @intLotItemUOMId

						SET @dblRequiredWeight = @dblRequiredWeight - @dblRemainingLotWeight
					END
					ELSE
					BEGIN
						EXEC [uspMFCreateSplitAndPickTask] @intOrderHeaderId = @intOrderHeaderId
							,@intLotId = @intLotId
							,@intEntityUserSecurityId = @intEntityUserSecurityId
							,@dblSplitAndPickWeight = @dblRequiredWeight
							,@intTaskTypeId = 2
							,@intItemId = @intItemId
							,@intOrderDetailId = @intOrderDetailId
							,@intFromStorageLocationId = @intStorageLocationId
							,@intItemUOMId = @intLotItemUOMId

						SET @dblRequiredWeight = @dblRequiredWeight - @dblWeight
					END

					IF @dblRequiredWeight <= 0
					BEGIN
						BREAK;
					END
				END

				DELETE
				FROM @tblLot
				WHERE intLotRecordId = @intLotRecordId

				IF @intUnitPerPallet > @dblRequiredQty
				BEGIN
					SELECT @intUnitPerPallet = @dblRequiredQty
				END

				SET @intLotRecordId = NULL

				SELECT TOP 1 @intLotRecordId = intLotRecordId
				FROM @tblLot s
				WHERE intGroupId = 1
					AND intSubLocationId = (
						CASE 
							WHEN @intPartialPickSubLocationId IS NOT NULL
								AND @intUnitPerPallet2 > 0
								AND @intUnitPerPallet2 <> @intUnitPerPallet
								THEN @intPartialPickSubLocationId
							ELSE intSubLocationId
							END
						)
				ORDER BY (
						CASE 
							WHEN @ysnStrictTracking = 0
								AND @intPreferenceId = 3
								THEN ABS(dblRemainingLotQty - @intUnitPerPallet)
							ELSE intLotRecordId
							END
						) ASC

				IF @intLotRecordId IS NULL
				BEGIN
					SELECT TOP 1 @intLotRecordId = intLotRecordId
					FROM @tblLot s
					WHERE intGroupId = 2
						AND intSubLocationId = (
							CASE 
								WHEN @intPartialPickSubLocationId IS NOT NULL
									AND @intUnitPerPallet2 > 0
									AND @intUnitPerPallet2 <> @intUnitPerPallet
									THEN @intPartialPickSubLocationId
								ELSE intSubLocationId
								END
							)
					ORDER BY intLotRecordId ASC
				END

				IF @intLotRecordId IS NULL
				BEGIN
					SELECT TOP 1 @intLotRecordId = intLotRecordId
					FROM @tblLot s
					WHERE intGroupId = 1
					ORDER BY (
							CASE 
								WHEN @ysnStrictTracking = 0
									AND @intPreferenceId = 3
									THEN ABS(dblRemainingLotQty - @intUnitPerPallet)
								ELSE intLotRecordId
								END
							) ASC
				END

				IF @intLotRecordId IS NULL
				BEGIN
					SELECT TOP 1 @intLotRecordId = intLotRecordId
					FROM @tblLot s
					WHERE intGroupId = 2
					ORDER BY intLotRecordId ASC
				END
			END

			SELECT @intItemRecordId = MIN(intItemRecordId)
			FROM @tblLineItem
			WHERE intItemRecordId > @intItemRecordId
		END

		SELECT @intTaskCount = COUNT(*)
		FROM tblMFTask
		WHERE intOrderHeaderId = @intOrderHeaderId

		IF @intTaskCount <= 0
		BEGIN
			SET @ysnAllTasksNotGenerated = 1
				--RAISERROR (
				--		'System was unable to generate task for one or more item(s).'
				--		,16
				--		,1
				--		)
		END
	END
	ELSE
	BEGIN
		DELETE
		FROM tblMFTask
		WHERE intOrderHeaderId = @intOrderHeaderId

		DECLARE @tblPutAwayLot TABLE (
			intLotRecordId INT Identity(1, 1)
			,intLotId INT
			,intItemId INT
			,dblQty NUMERIC(18, 6)
			)

		INSERT INTO @tblPutAwayLot
		SELECT OM.intLotId
			,L.intItemId
			,L.dblQty
		FROM tblMFOrderManifest OM
		JOIN tblICLot L ON L.intLotId = OM.intLotId
		WHERE intOrderHeaderId = @intOrderHeaderId

		SELECT @intLotRecordId = MIN(intLotRecordId)
		FROM @tblPutAwayLot

		WHILE (@intLotRecordId IS NOT NULL)
		BEGIN
			SET @intLotId = NULL

			SELECT @intLotId = intLotId
			FROM @tblPutAwayLot
			WHERE intLotRecordId = @intLotRecordId

			EXEC uspMFGeneratePutAwayTask @intOrderHeaderId = @intOrderHeaderId
				,@intLotId = @intLotId
				,@intEntityUserSecurityId = @intEntityUserSecurityId
				,@intAssigneeId = 0

			SELECT @intLotRecordId = MIN(intLotRecordId)
			FROM @tblPutAwayLot
			WHERE intLotRecordId > @intLotRecordId
		END
	END

	IF @intTransactionCount = 0
		COMMIT TRANSACTION

	IF @strOrderType = 'INVENTORY SHIPMENT STAGING'
		AND @ysnPickByQty = 1
	BEGIN
		INSERT INTO @tblTaskGenerated
		SELECT OD.intItemId
			,ISNULL(SUM(dbo.fnMFConvertQuantityToTargetItemUOM(T.intItemUOMId, OD.intItemUOMId, T.dblQty)), 0) dblTotalTaskQty
			,OD.dblQty
		FROM tblMFOrderDetail OD
		LEFT JOIN tblMFTask T ON OD.intItemId = T.intItemId
			AND OD.intOrderHeaderId = T.intOrderHeaderId
		WHERE OD.intOrderHeaderId = @intOrderHeaderId
			AND OD.dblQty > 0
		GROUP BY OD.intItemId
			,OD.dblQty

		SELECT @intTaskRecordId = MIN(intTaskRecordId)
		FROM @tblTaskGenerated

		WHILE (ISNULL(@intTaskRecordId, 0) <> 0)
		BEGIN
			SET @dblTotalTaskWeight = NULL
			SET @dblLineItemWeight = NULL
			SET @ysnAllTasksNotGenerated = 0

			SELECT @dblTotalTaskWeight = dblTotalTaskWeight
				,@dblLineItemWeight = dblLineItemWeight
			FROM @tblTaskGenerated
			WHERE intTaskRecordId = @intTaskRecordId

			IF (@dblTotalTaskWeight < @dblLineItemWeight)
			BEGIN
				SET @ysnAllTasksNotGenerated = 1

				BREAK;
			END

			SELECT @intTaskRecordId = MIN(intTaskRecordId)
			FROM @tblTaskGenerated
			WHERE intTaskRecordId > @intTaskRecordId
		END
	END
	ELSE
	BEGIN
		INSERT INTO @tblTaskGenerated
		SELECT OD.intItemId
			,ISNULL(SUM(dbo.fnMFConvertQuantityToTargetItemUOM(T.intWeightUOMId, OD.intWeightUOMId, T.dblWeight)), 0) dblTotalTaskWeight
			,OD.dblWeight
		FROM tblMFOrderDetail OD
		LEFT JOIN tblMFTask T ON OD.intItemId = T.intItemId
			AND OD.intOrderHeaderId = T.intOrderHeaderId
		WHERE OD.intOrderHeaderId = @intOrderHeaderId
			AND OD.dblQty > 0
		GROUP BY OD.intItemId
			,OD.dblWeight

		SELECT @intTaskRecordId = MIN(intTaskRecordId)
		FROM @tblTaskGenerated

		WHILE (ISNULL(@intTaskRecordId, 0) <> 0)
		BEGIN
			SET @dblTotalTaskWeight = NULL
			SET @dblLineItemWeight = NULL
			SET @ysnAllTasksNotGenerated = 0

			SELECT @dblTotalTaskWeight = dblTotalTaskWeight
				,@dblLineItemWeight = dblLineItemWeight
			FROM @tblTaskGenerated
			WHERE intTaskRecordId = @intTaskRecordId

			IF (@dblTotalTaskWeight < @dblLineItemWeight)
			BEGIN
				SET @ysnAllTasksNotGenerated = 1

				BREAK;
			END

			SELECT @intTaskRecordId = MIN(intTaskRecordId)
			FROM @tblTaskGenerated
			WHERE intTaskRecordId > @intTaskRecordId
		END
	END

	IF @intCustomerLabelTypeId = 2
	BEGIN
		DELETE M
		FROM tblMFOrderManifest M
		WHERE intOrderHeaderId = @intOrderHeaderId
			AND (
				intLotId IN (
					SELECT intLotId
					FROM tblMFTask
					WHERE intOrderHeaderId = @intOrderHeaderId
						AND intTaskStateId <> 4
					)
				AND NOT EXISTS (
					SELECT *
					FROM tblMFOrderManifestLabel M1
					WHERE M1.intOrderManifestId = M.intOrderManifestId
					)
				)

		INSERT INTO tblMFOrderManifest (
			intConcurrencyId
			,intOrderDetailId
			,intOrderHeaderId
			,intLotId
			,strManifestItemNote
			,intLastUpdateId
			,dtmLastUpdateOn
			)
		SELECT 1
			,intOrderDetailId
			,intOrderHeaderId
			,intLotId
			,'Order Staged'
			,@intEntityUserSecurityId
			,GetDate()
		FROM tblMFTask T
		WHERE intOrderHeaderId = @intOrderHeaderId
			AND intTaskStateId <> 4
			AND NOT EXISTS (
				SELECT *
				FROM tblMFOrderManifest OM
				WHERE OM.intLotId = T.intLotId
					AND OM.intOrderHeaderId = T.intOrderHeaderId
				)
	END

	IF (
			(
				@strOrderType = 'INVENTORY SHIPMENT STAGING'
				AND @intInventoryShipmentId IS NOT NULL
				)
			OR @strOrderType = 'WO PROD STAGING'
			)
	BEGIN
		EXEC dbo.uspICCreateStockReservation @ItemsToReserve
			,@intTransactionId
			,@intInventoryTransactionType

		INSERT INTO @ItemsToReserve (
			intItemId
			,intItemLocationId
			,intItemUOMId
			,intLotId
			,intSubLocationId
			,intStorageLocationId
			,dblQty
			,intTransactionId
			,strTransactionId
			,intTransactionTypeId
			)
		SELECT intItemId = T.intItemId
			,intItemLocationId = IL.intItemLocationId
			,intItemUOMId = T.intItemUOMId
			,intLotId = T.intLotId
			,intSubLocationId = SL.intSubLocationId
			,intStorageLocationId = NULL --We need to set this to NULL otherwise available Qty becomes zero in the inventoryshipment screen
			,dblQty = T.dblPickQty
			,intTransactionId = @intTransactionId
			,strTransactionId = @strTransactionId
			,intTransactionTypeId = @intInventoryTransactionType
		FROM tblMFTask T
		JOIN tblICStorageLocation SL ON SL.intStorageLocationId = T.intFromStorageLocationId
		JOIN tblICItemLocation IL ON IL.intItemId = T.intItemId
			AND IL.intLocationId = SL.intLocationId
		WHERE T.intOrderHeaderId = @intOrderHeaderId
			AND T.intTaskStateId = 4

		EXEC dbo.uspICCreateStockReservation @ItemsToReserve
			,@intTransactionId
			,@intInventoryTransactionType

		DELETE
		FROM @ItemsToReserve

		EXEC dbo.uspICCreateStockReservation @ItemsToReserve
			,@intOrderId
			,34

		INSERT INTO @ItemsToReserve (
			intItemId
			,intItemLocationId
			,intItemUOMId
			,intLotId
			,intSubLocationId
			,intStorageLocationId
			,dblQty
			,intTransactionId
			,strTransactionId
			,intTransactionTypeId
			)
		SELECT intItemId = T.intItemId
			,intItemLocationId = IL.intItemLocationId
			,intItemUOMId = T.intItemUOMId
			,intLotId = T.intLotId
			,intSubLocationId = SL.intSubLocationId
			,intStorageLocationId = T.intFromStorageLocationId
			,dblQty = T.dblPickQty
			,intTransactionId = @intOrderId
			,strTransactionId = @strTransactionId + ' / ' + @strOrderNo
			,intTransactionTypeId = 34
		FROM tblMFTask T
		JOIN tblICStorageLocation SL ON SL.intStorageLocationId = T.intFromStorageLocationId
		JOIN tblICItemLocation IL ON IL.intItemId = T.intItemId
			AND IL.intLocationId = SL.intLocationId
		WHERE T.intOrderHeaderId = @intOrderHeaderId
			AND T.intTaskStateId <> 4

		EXEC dbo.uspICCreateStockReservation @ItemsToReserve
			,@intOrderId
			,34
	END

	IF EXISTS (
			SELECT 1
			FROM tblMFTask
			WHERE intOrderHeaderId = @intOrderHeaderId
			)
	BEGIN
		UPDATE tblMFOrderHeader
		SET intOrderStatusId = 2
		WHERE intOrderHeaderId = @intOrderHeaderId
	END
END TRY

BEGIN CATCH
	SET @strErrMsg = ERROR_MESSAGE()

	IF @strErrMsg != ''
	BEGIN
		SET @strErrMsg = @strErrMsg

		RAISERROR (
				@strErrMsg
				,16
				,1
				,'WITH NOWAIT'
				)
	END
END CATCH
