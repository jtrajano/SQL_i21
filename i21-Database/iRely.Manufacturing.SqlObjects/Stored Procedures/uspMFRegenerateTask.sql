CREATE PROCEDURE uspMFRegenerateTask @intLotId INT
	,@strAlternateLotNo NVARCHAR(50)
	,@strLotSourceLocation NVARCHAR(50)
	,@intOrderHeaderId INT
	,@intTaskId INT
	,@dblQty NUMERIC(18, 6)
	,@intUserId INT
	,@intLocationId INT
AS
BEGIN TRY
	DECLARE @intAlternateLotId INT
		,@intStorageLocationId INT
		,@dblAlternateLotQty NUMERIC(38, 20)
		,@dtmAlternateLotExpiryDate DATETIME
		,@intTransactionCount INT
		,@strErrMsg NVARCHAR(MAX)
		,@intItemId INT
		,@intAlternateItemId INT
		,@intLotStatusId INT
		,@intBondStatusId INT
		,@strPrimaryStatus NVARCHAR(50)
		,@intCustomerLabelTypeId INT
		,@intEntityCustomerId INT
		,@strReferenceNo NVARCHAR(50)
		,@intAlternateParentLotId INT
		,@intParentLotId INT
		,@ysnPickByLotCode BIT
		,@intLotCodeStartingPosition INT
		,@intLotCodeNoOfDigits INT
		,@intLotCode INT
		,@intAlternateLotCode INT
		,@intAllowablePickDayRange INT
		,@dblAlternatePickQty NUMERIC(18, 6)
		,@dblShort NUMERIC(18, 6)
		,@dblAlternateTaskQty NUMERIC(18, 6)
		,@intAlternateOrderHeaderId INT
		,@intAlternateTaskId INT
		,@dblTaskQty NUMERIC(18, 6)
		,@dblMore NUMERIC(18, 6)
		,@intOrderTaskId INT
		,@dblOrderTaskQty NUMERIC(18, 6)
		,@strOrderType NVARCHAR(50)
		,@strPickByFullPallet NVARCHAR(50)
		,@intWorkOrderId INT
		,@intManufacturingProcessId INT
		,@intAlternateOwnershipType INT
		,@intOwnershipType INT
		,@ItemsToReserve AS dbo.ItemReservationTableType
		,@intInventoryTransactionType AS INT = 5
		,@intTransactionId INT
		,@strTransactionId NVARCHAR(50)
		,@strWorkOrderNo NVARCHAR(50)
		,@intOrderId INT
		,@intInventoryShipmentId INT
		,@strOrderNo NVARCHAR(50)
		,@ysnReservationRequired BIT

	SELECT @ysnReservationRequired = 1

	SELECT @strOrderType = OT.strOrderType
		,@intOrderId = intOrderHeaderId
		,@strOrderNo = strOrderNo
		,@strReferenceNo = oh.strReferenceNo
	FROM tblMFOrderHeader oh
	JOIN tblMFOrderType OT ON OT.intOrderTypeId = oh.intOrderTypeId
	WHERE intOrderHeaderId = @intOrderHeaderId

	SELECT @intTransactionCount = @@TranCount

	DECLARE @tblMFTask TABLE (
		intAlternateTaskId INT
		,dblAlternateTaskQty NUMERIC(18, 6)
		,intAlternateOrderHeaderId INT
		)
	DECLARE @tblMFOrderTask TABLE (
		intOrderTaskId INT
		,dblOrderTaskQty NUMERIC(18, 6)
		,intOrderHeaderId INT
		)

	SELECT @intStorageLocationId = intStorageLocationId
	FROM tblICStorageLocation
	WHERE strName = @strLotSourceLocation
		AND intLocationId = @intLocationId

	SELECT @intAlternateLotId = intLotId
		,@dblAlternateLotQty = dblQty
		,@intLotStatusId = intLotStatusId
		,@intAlternateItemId = intItemId
		,@dtmAlternateLotExpiryDate = dtmExpiryDate
		,@intAlternateParentLotId = intParentLotId
		,@intAlternateOwnershipType = intOwnershipType
	FROM tblICLot
	WHERE strLotNumber = @strAlternateLotNo
		AND intStorageLocationId = @intStorageLocationId
		AND dblQty > 0

	SELECT @dblTaskQty = dblPickQty
	FROM tblMFTask
	WHERE intTaskId = @intTaskId

	IF @intLotId = @intAlternateLotId
		AND @dblTaskQty = @dblQty
	BEGIN
		RETURN
	END

	IF ISNULL(@dblAlternateLotQty, 0) <= 0
	BEGIN
		SET @strErrMsg = 'QTY NOT AVAILABLE FOR LOT ' + @strAlternateLotNo + ' ON LOCATION ' + @strLotSourceLocation + '.'

		RAISERROR (
				@strErrMsg
				,16
				,1
				)
	END

	IF ISNULL(@intAlternateLotId, 0) = 0
	BEGIN
		RAISERROR (
				'ALTERNATE LOT DOES NOT EXISTS IN THE SCANNED LOCATION'
				,16
				,1
				)
	END

	IF (GETDATE() > @dtmAlternateLotExpiryDate)
	BEGIN
		RAISERROR (
				'SCANNED LOT HAS EXPIRED.'
				,16
				,1
				)
	END

	SELECT @intItemId = intItemId
		,@intParentLotId = intParentLotId
		,@intOwnershipType = intOwnershipType
	FROM tblICLot
	WHERE intLotId = @intLotId

	IF (@intItemId <> @intAlternateItemId)
	BEGIN
		RAISERROR (
				'ALTERNATE LOT BELONGS TO A DIFFERENT ITEM. CANNOT CONTINUE.'
				,16
				,1
				)
	END

	IF @intOwnershipType <> @intAlternateOwnershipType
	BEGIN
		RAISERROR (
				'ALTERNATE LOT BELONGS TO A DIFFERENT OWNERSHIP TYPE. CANNOT CONTINUE.'
				,16
				,1
				)
	END

	SELECT @strPrimaryStatus = strPrimaryStatus
	FROM tblICLotStatus
	WHERE intLotStatusId = @intLotStatusId

	IF (@strPrimaryStatus <> 'Active')
	BEGIN
		RAISERROR (
				'SCANNED LOT IS NOT ACTIVE. PLEASE SCAN AN ACTIVE LOT TO CONTINUE.'
				,16
				,1
				)
	END

	SELECT @ysnPickByLotCode = ysnPickByLotCode
		,@intLotCodeStartingPosition = intLotCodeStartingPosition
		,@intLotCodeNoOfDigits = intLotCodeNoOfDigits
	FROM tblMFCompanyPreference

	SELECT @intAllowablePickDayRange = intAllowablePickDayRange
	FROM tblWHCompanyPreference

	IF @intLotId <> @intAlternateLotId
		AND @ysnPickByLotCode = 1
	BEGIN
		SELECT @intLotCode = CONVERT(INT, Substring(strParentLotNumber, @intLotCodeStartingPosition, @intLotCodeNoOfDigits))
		FROM tblICParentLot
		WHERE intParentLotId = @intParentLotId

		SELECT @intAlternateLotCode = CONVERT(INT, Substring(strParentLotNumber, @intLotCodeStartingPosition, @intLotCodeNoOfDigits))
		FROM tblICParentLot
		WHERE intParentLotId = @intAlternateParentLotId

		IF @intAlternateLotCode - @intLotCode > @intAllowablePickDayRange
		BEGIN
			RAISERROR (
					'ALTERNATE PALLET IS NOT ALLOWABLE PICK DAY RANGE.'
					,16
					,1
					)
		END
	END

	SELECT @intBondStatusId = intBondStatusId
	FROM tblMFLotInventory
	WHERE intLotId = @intAlternateLotId

	IF @intBondStatusId = 5
	BEGIN
		RAISERROR (
				'SCANNED LOT IS NOT BOND RELEASED. PLEASE SCAN BOND RELEASED LOT TO CONTINUE.'
				,16
				,1
				)
	END

	SELECT @intEntityCustomerId = intEntityCustomerId
		,@intInventoryShipmentId = intInventoryShipmentId
	FROM tblICInventoryShipment
	WHERE strShipmentNumber = @strReferenceNo

	SELECT @intCustomerLabelTypeId = intCustomerLabelTypeId
	FROM tblMFItemOwner
	WHERE intOwnerId = @intEntityCustomerId
		AND intCustomerLabelTypeId IS NOT NULL

	IF @intCustomerLabelTypeId IS NULL
	BEGIN
		SELECT @intCustomerLabelTypeId = 0
	END

	IF @intTransactionCount = 0
		BEGIN TRANSACTION

	IF @intOrderHeaderId IS NOT NULL
		AND EXISTS (
			SELECT *
			FROM tblMFOrderHeader
			WHERE intOrderHeaderId = @intOrderHeaderId
				AND intOrderTypeId = 1
			)
		AND EXISTS (
			SELECT 1
			FROM tblMFTask
			WHERE intLotId = @intLotId
				AND intTaskId = @intTaskId
			)
	BEGIN
		DECLARE @dblPickQty NUMERIC(38, 20)
			,@intPickItemUOMId INT

		SELECT @dblPickQty = NULL
			,@intPickItemUOMId = NULL

		SELECT @dblPickQty = dblQty
			,@intPickItemUOMId = intItemUOMId
		FROM tblICLot
		WHERE intLotId = @intAlternateLotId

		UPDATE tblMFTask
		SET intLotId = @intAlternateLotId
			,intFromStorageLocationId = @intStorageLocationId
			,dblPickQty = @dblPickQty
			,intItemUOMId = @intPickItemUOMId
		WHERE intLotId = @intLotId
			AND intTaskId = @intTaskId

		IF @intCustomerLabelTypeId = 2
		BEGIN
			UPDATE tblMFOrderManifest
			SET intLotId = @intAlternateLotId
			WHERE intOrderHeaderId = @intOrderHeaderId
				AND intLotId = @intLotId
		END
	END
	ELSE
	BEGIN
		IF EXISTS (
				SELECT 1
				FROM tblMFTask
				WHERE intLotId = @intLotId
					AND intTaskId = @intTaskId
				)
		BEGIN
			UPDATE tblMFTask
			SET intLotId = @intAlternateLotId
				,intFromStorageLocationId = @intStorageLocationId
				,dblPickQty = @dblQty
				,dblQty = @dblQty
				,dblWeight = @dblQty * dblWeightPerQty
			WHERE intLotId = @intLotId
				AND intTaskId = @intTaskId

			IF @intCustomerLabelTypeId = 2
			BEGIN
				UPDATE tblMFOrderManifest
				SET intLotId = @intAlternateLotId
				WHERE intOrderHeaderId = @intOrderHeaderId
					AND intLotId = @intLotId
			END
		END
	END

	SELECT @dblMore = @dblQty - @dblTaskQty

	IF @dblMore > 0 --Remove the unnecessary task.
	BEGIN
		DELETE
		FROM @tblMFOrderTask

		INSERT INTO @tblMFOrderTask (
			intOrderTaskId
			,dblOrderTaskQty
			)
		SELECT intTaskId
			,dblPickQty
		FROM tblMFTask
		WHERE intOrderHeaderId = @intOrderHeaderId
			AND intItemId = @intItemId
			AND intTaskStateId = 1
			AND intTaskId <> @intTaskId

		SELECT @intOrderTaskId = MAX(intOrderTaskId)
		FROM @tblMFOrderTask

		WHILE @intOrderTaskId IS NOT NULL
		BEGIN
			SELECT @dblOrderTaskQty = NULL

			SELECT @dblOrderTaskQty = dblOrderTaskQty
			FROM @tblMFOrderTask
			WHERE intOrderTaskId = @intOrderTaskId

			DELETE
			FROM tblMFTask
			WHERE intTaskId = @intOrderTaskId

			SELECT @dblMore = @dblMore - @dblOrderTaskQty

			IF @dblMore <= 0
			BEGIN
				BREAK
			END

			SELECT @intOrderTaskId = MAX(intOrderTaskId)
			FROM @tblMFOrderTask
			WHERE intOrderTaskId < @intOrderTaskId
		END

		EXEC uspMFGenerateTask @intOrderHeaderId = @intOrderHeaderId
			,@intEntityUserSecurityId = @intUserId
			,@ysnAllTasksNotGenerated = 0

		SELECT @ysnReservationRequired = 0
	END

	SELECT @dblAlternatePickQty = SUM(dblPickQty)
	FROM tblMFTask
	WHERE intLotId = @intAlternateLotId
		AND intTaskStateId <> 4
		AND intTaskId <> @intTaskId

	IF EXISTS (
			SELECT 1
			FROM tblMFTask
			WHERE intLotId = @intAlternateLotId
				AND intTaskStateId <> 4
				AND intTaskId <> @intTaskId
			)
		AND (@dblAlternateLotQty - @dblAlternatePickQty) - @dblQty < 0
	BEGIN
		SELECT @dblShort = abs((@dblAlternateLotQty - @dblAlternatePickQty) - @dblQty)

		INSERT INTO @tblMFTask (
			intAlternateTaskId
			,dblAlternateTaskQty
			,intAlternateOrderHeaderId
			)
		SELECT intTaskId
			,dblPickQty
			,intOrderHeaderId
		FROM tblMFTask
		WHERE intLotId = @intAlternateLotId
			AND intTaskStateId <> 4
			AND intTaskId <> @intTaskId

		SELECT @intAlternateTaskId = MAX(intAlternateTaskId)
		FROM @tblMFTask

		WHILE @intAlternateTaskId IS NOT NULL
		BEGIN
			SELECT @dblAlternateTaskQty = NULL
				,@intAlternateOrderHeaderId = NULL

			SELECT @dblAlternateTaskQty = dblAlternateTaskQty
				,@intAlternateOrderHeaderId = intAlternateOrderHeaderId
			FROM @tblMFTask
			WHERE intAlternateTaskId = @intAlternateTaskId

			DELETE
			FROM tblMFTask
			WHERE intTaskId = @intAlternateTaskId

			EXEC uspMFGenerateTask @intOrderHeaderId = @intAlternateOrderHeaderId
				,@intEntityUserSecurityId = @intUserId
				,@ysnAllTasksNotGenerated = 0

			SELECT @ysnReservationRequired = 0

			SELECT @dblShort = @dblShort - @dblAlternateTaskQty

			IF @dblShort <= 0
			BEGIN
				BREAK
			END

			SELECT @intAlternateTaskId = MAX(intAlternateTaskId)
			FROM @tblMFTask
			WHERE intAlternateTaskId < @intAlternateTaskId
		END
	END

	IF @dblQty - @dblTaskQty < 0 --To generate to additional task
	BEGIN
		EXEC uspMFGenerateTask @intOrderHeaderId = @intOrderHeaderId
			,@intEntityUserSecurityId = @intUserId
			,@ysnAllTasksNotGenerated = 0

		SELECT @ysnReservationRequired = 0
	END

	IF @strOrderType = 'INVENTORY SHIPMENT STAGING'
	BEGIN
		SELECT @intTransactionId = @intInventoryShipmentId

		SELECT @strTransactionId = @strReferenceNo

		SELECT @intInventoryTransactionType = 5

		IF EXISTS (
				SELECT 1
				FROM tblMFOrderDetail OD
				LEFT JOIN tblMFTask T ON OD.intItemId = T.intItemId
					AND OD.intOrderHeaderId = T.intOrderHeaderId
				WHERE OD.intOrderHeaderId = @intOrderHeaderId
					AND OD.intItemId = @intItemId
					AND OD.dblQty > 0
				GROUP BY OD.dblQty
				HAVING ISNULL(SUM(dbo.fnMFConvertQuantityToTargetItemUOM(T.intItemUOMId, OD.intItemUOMId, T.dblQty)), 0) > OD.dblQty
				)
		BEGIN
			RAISERROR (
					'Task Qty cannot be greater than required Qty.'
					,16
					,1
					)

			RETURN
		END
	END
	ELSE IF @strOrderType = 'WO PROD STAGING'
	BEGIN
		SELECT @intWorkOrderId = intWorkOrderId
		FROM tblMFStageWorkOrder
		WHERE intOrderHeaderId = @intOrderHeaderId

		SELECT @intManufacturingProcessId = intManufacturingProcessId
			,@strWorkOrderNo = strWorkOrderNo
		FROM tblMFWorkOrder
		WHERE intWorkOrderId = @intWorkOrderId

		SELECT @intTransactionId = @intWorkOrderId

		SELECT @strTransactionId = @strWorkOrderNo

		SELECT @intInventoryTransactionType = 9

		SELECT @strPickByFullPallet = strAttributeValue
		FROM tblMFManufacturingProcessAttribute
		WHERE intManufacturingProcessId = @intManufacturingProcessId
			AND intLocationId = @intLocationId
			AND intAttributeId = 92 --Pick By Full Pallet

		IF @strPickByFullPallet IS NULL
		BEGIN
			SELECT @strPickByFullPallet = 'False'
		END

		IF @strPickByFullPallet = 'False'
		BEGIN
			IF EXISTS (
					SELECT 1
					FROM tblMFOrderDetail OD
					LEFT JOIN tblMFTask T ON OD.intItemId = T.intItemId
						AND OD.intOrderHeaderId = T.intOrderHeaderId
					WHERE OD.intOrderHeaderId = @intOrderHeaderId
						AND OD.intItemId = @intItemId
						AND OD.dblQty > 0
					GROUP BY OD.dblWeight
					HAVING ISNULL(SUM(dbo.fnMFConvertQuantityToTargetItemUOM(T.intWeightUOMId, OD.intWeightUOMId, T.dblWeight)), 0) > OD.dblWeight
					)
			BEGIN
				RAISERROR (
						'Task Qty cannot be greater than required Qty.'
						,16
						,1
						)

				RETURN
			END
		END
	END

	IF (
			@strOrderType = 'INVENTORY SHIPMENT STAGING'
			OR @strOrderType = 'WO PROD STAGING'
			)
		AND @ysnReservationRequired = 1
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

	IF @intTransactionCount = 0
		COMMIT TRANSACTION
END TRY

BEGIN CATCH
	IF XACT_STATE() != 0
		AND @intTransactionCount = 0
		ROLLBACK TRANSACTION

	SET @strErrMsg = ERROR_MESSAGE()

	RAISERROR (
			@strErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH
