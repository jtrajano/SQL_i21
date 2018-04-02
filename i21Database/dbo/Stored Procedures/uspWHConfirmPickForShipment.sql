CREATE PROCEDURE uspWHConfirmPickForShipment 
					@strShipmentNo NVARCHAR(100), 
					@intUserId INT,
					@intCompanyLocationId INT
AS
BEGIN TRY
	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @intMinId INT
	DECLARE @intLotId INT
	DECLARE @intShipmentItemId INT
	DECLARE @intLotItemId INT
	DECLARE @dblLotQty NUMERIC(18, 6)
	DECLARE @dblLotWeight NUMERIC(18, 6)
	DECLARE @ItemsToReserve AS dbo.ItemReservationTableType
	DECLARE @intInventoryTransactionType AS INT = 5
	DECLARE @intInventoryShipmentId INT
	DECLARE @ysnGenerateInvShipmentStagingOrder BIT

	DECLARE @strErrMsg NVARCHAR(MAX)
	DECLARE @intNewSubLocationId INT
	DECLARE @intNewStorageLocationId INT
	DECLARE @dblMoveQty NUMERIC(38, 20)
	DECLARE @intMoveItemUOMId INT
	DECLARE @blnValidateLotReservation BIT = 0
	DECLARE @blnInventoryMove BIT = 0
	DECLARE @intNewLotId INT
	DECLARE @strLotNumber NVARCHAR(100)
	DECLARE @intItemId INT
	DECLARE @intLotLocationId INT
	DECLARE @intMinTaskRecordId INT
	DECLARE @strOrderNo NVARCHAR(100)
	DECLARE @intRemainingTasks INT
	DECLARE @intOrderDetailId INT
	DECLARE @intOrderHeaderId INT
	DECLARE @intTaskId INT
	DECLARE @tblTasks TABLE (
		intTaskRecordId INT Identity(1, 1)
		,intTaskId INT
		,intOrderHeaderId INT
		)

	IF NOT EXISTS (SELECT 1 FROM tblWHPickForShipment WHERE strShipmentNo = @strShipmentNo)
	BEGIN
		RAISERROR ('NO LOT HAS BEEN STAGED FOR THIS SHIPMENT NO',11,1)
	END

	SELECT @intInventoryShipmentId = intInventoryShipmentId
	FROM tblICInventoryShipment
	WHERE strShipmentNumber = @strShipmentNo
		AND intShipFromLocationId = @intCompanyLocationId

	SELECT @ysnGenerateInvShipmentStagingOrder = ysnGenerateInvShipmentStagingOrder
	FROM tblMFCompanyPreference

	IF (@ysnGenerateInvShipmentStagingOrder = 0)
	BEGIN
		SELECT @intMinId = MIN(id)
		FROM tblWHPickForShipment
		WHERE strShipmentNo = @strShipmentNo

		WHILE (@intMinId IS NOT NULL)
		BEGIN
			SET @intLotId = 0
			SET @intShipmentItemId = NULL
			SET @dblLotQty = 0
			SET @intLotItemId = 0

			SELECT @intLotId = intLotId
			FROM tblWHPickForShipment
			WHERE id = @intMinId

			SELECT @dblLotQty = dblQty
				  ,@intLotItemId = intItemId
				  ,@dblLotWeight = dblWeight
			FROM tblICLot
			WHERE intLotId = @intLotId

			SELECT @intShipmentItemId = intInventoryShipmentItemId
			FROM tblICInventoryShipmentItem i
			JOIN tblICInventoryShipment s ON i.intInventoryShipmentId = s.intInventoryShipmentId
			WHERE s.strShipmentNumber = @strShipmentNo
				AND intItemId = @intLotItemId

			INSERT INTO tblICInventoryShipmentItemLot (
				 intInventoryShipmentItemId
				,intLotId
				,dblQuantityShipped
				,dblGrossWeight
				,dblTareWeight
				)
			VALUES (
				 @intShipmentItemId
				,@intLotId
				,@dblLotQty
				,@dblLotWeight
				,0
				)

			DELETE
			FROM tblWHPickForShipment
			WHERE id = @intMinId

			SELECT @intMinId = MIN(id)
			FROM tblWHPickForShipment
			WHERE strShipmentNo = @strShipmentNo
				AND id > @intMinId
		END

		--Delete existing reservation against the shipment
		IF EXISTS (SELECT 1 FROM tblICStockReservation WHERE intTransactionId = @intInventoryShipmentId)
		BEGIN
			DELETE
			FROM tblICStockReservation
			WHERE intTransactionId = @intInventoryShipmentId
		END

		--Create new reservation against all the lots attached in the shipment.
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
		SELECT intItemId = L.intItemId
			,intItemLocationId = L.intItemLocationId
			,intItemUOMId = L.intItemUOMId
			,intLotId = L.intLotId
			,intSubLocationId = L.intSubLocationId
			,intStorageLocationId = L.intStorageLocationId
			,dblQty = L.dblQty
			,intTransactionId = SHP.intInventoryShipmentId
			,strTransactionId = SHP.strShipmentNumber
			,intTransactionTypeId = @intInventoryTransactionType
		FROM tblICInventoryShipment SHP
		JOIN tblICInventoryShipmentItem SHI ON SHI.intInventoryShipmentId = SHP.intInventoryShipmentId
		JOIN tblICInventoryShipmentItemLot SHL ON SHL.intInventoryShipmentItemId = SHI.intInventoryShipmentItemId
		JOIN tblICLot L ON L.intLotId = SHL.intLotId
		WHERE SHP.intInventoryShipmentId = @intInventoryShipmentId

		EXEC dbo.uspICCreateStockReservation @ItemsToReserve
			,@intInventoryShipmentId
			,@intInventoryTransactionType
	END
	ELSE
	BEGIN
		SELECT @intOrderHeaderId = intOrderHeaderId
		FROM tblMFOrderHeader
		WHERE strReferenceNo = @strShipmentNo

		INSERT INTO @tblTasks (
			intTaskId
			,intOrderHeaderId
			)
		SELECT intTaskId
			,intOrderHeaderId
		FROM tblMFTask T
		JOIN tblWHPickForShipment PFS ON PFS.intLotId = T.intLotId
		WHERE PFS.strShipmentNo = @strShipmentNo
			AND T.intOrderHeaderId = @intOrderHeaderId

		SELECT @intMinTaskRecordId = MIN(intTaskRecordId)
		FROM @tblTasks

		WHILE ISNULL(@intMinTaskRecordId, 0) <> 0
		BEGIN
			SET @intTaskId = NULL

			SELECT @intTaskId = intTaskId
			FROM @tblTasks
			WHERE intTaskRecordId = @intMinTaskRecordId

			SELECT @intNewSubLocationId = SL.intSubLocationId
				,@intNewStorageLocationId = T.intToStorageLocationId
				,@dblMoveQty = T.dblPickQty
				,@intMoveItemUOMId = T.intItemUOMId
				,@blnValidateLotReservation = 1
				,@blnInventoryMove = 0
				,@intLotId = intLotId
			FROM tblMFTask T
			JOIN tblICStorageLocation SL ON T.intToStorageLocationId = SL.intStorageLocationId
			WHERE T.intTaskId = @intTaskId

			SELECT @strLotNumber = strLotNumber
				,@intItemId = intItemId
				,@intLotLocationId = intLocationId
			FROM tblICLot
			WHERE intLotId = @intLotId

			SELECT @intOrderDetailId = intOrderDetailId
			FROM tblMFOrderDetail
			WHERE intOrderHeaderId = @intOrderHeaderId
				AND intItemId = @intItemId

			EXEC uspMFLotMove @intLotId = @intLotId
				,@intNewSubLocationId = @intNewSubLocationId
				,@intNewStorageLocationId = @intNewStorageLocationId
				,@dblMoveQty = @dblMoveQty
				,@intMoveItemUOMId = @intMoveItemUOMId
				,@intUserId = @blnValidateLotReservation
				,@blnValidateLotReservation = 1
				,@blnInventoryMove = @blnInventoryMove

			SELECT TOP 1 @intNewLotId = intLotId
			FROM tblICLot
			WHERE strLotNumber = @strLotNumber
				AND intItemId = @intItemId
				AND intLocationId = @intLotLocationId
				AND intSubLocationId = @intNewSubLocationId
				AND intStorageLocationId = @intNewStorageLocationId

			UPDATE tblMFTask
			SET intTaskStateId = 4
				,intLotId = @intNewLotId
				,intFromStorageLocationId = @intNewStorageLocationId
			WHERE intTaskId = @intTaskId

			INSERT INTO tblMFOrderManifest (
				intConcurrencyId
				,intOrderDetailId
				,intOrderHeaderId
				,intLotId
				,strManifestItemNote
				,intLastUpdateId
				,dtmLastUpdateOn
				)
			VALUES (
				1
				,@intOrderDetailId
				,@intOrderHeaderId
				,@intNewLotId
				,'Order Staged'
				,@intUserId
				,GetDate()
				)


			---	INSERT RECORD IN INVENTORY SHIPMENT TABLES
			--- ===========================================
					SELECT @intMinId = MIN(id)
					FROM tblWHPickForShipment
					WHERE strShipmentNo = @strShipmentNo

					WHILE (@intMinId IS NOT NULL)
					BEGIN
						SET @intLotId = 0
						SET @intShipmentItemId = NULL
						SET @dblLotQty = 0
						SET @intLotItemId = 0
						SET @dblLotWeight = 0

						SELECT @intLotId = intLotId
						FROM tblWHPickForShipment
						WHERE id = @intMinId

						SELECT @dblLotQty = dblQty
							,@intLotItemId = intItemId
							,@dblLotWeight = dbo.fnCTConvertQtyToTargetItemUOM(intItemUOMId,intWeightUOMId,@dblMoveQty)
						FROM tblICLot
						WHERE intLotId = @intNewLotId

						SELECT @intShipmentItemId = intInventoryShipmentItemId
						FROM tblICInventoryShipmentItem i
						JOIN tblICInventoryShipment s ON i.intInventoryShipmentId = s.intInventoryShipmentId
						WHERE s.strShipmentNumber = @strShipmentNo
							AND intItemId = @intLotItemId

						INSERT INTO tblICInventoryShipmentItemLot (
							intInventoryShipmentItemId
							,intLotId
							,dblQuantityShipped
							,dblGrossWeight
							,dblTareWeight
							)
						VALUES (
							@intShipmentItemId
							,@intNewLotId
							,@dblMoveQty
							,@dblLotWeight
							,0
							)

						DELETE
						FROM tblWHPickForShipment
						WHERE id = @intMinId

						SELECT @intMinId = MIN(id)
						FROM tblWHPickForShipment
						WHERE strShipmentNo = @strShipmentNo
							AND id > @intMinId
					END

			SELECT @intMinTaskRecordId = MIN(intTaskRecordId)
			FROM @tblTasks
			WHERE intTaskRecordId > @intMinTaskRecordId
		END

		--Delete existing reservation against the shipment
		IF EXISTS (
				SELECT *
				FROM tblICStockReservation
				WHERE intTransactionId = @intInventoryShipmentId
				)
		BEGIN
			DELETE
			FROM tblICStockReservation
			WHERE intTransactionId = @intInventoryShipmentId
		END

		--Create new reservation against all the lots attached in the shipment.
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
		SELECT intItemId = L.intItemId
			,intItemLocationId = L.intItemLocationId
			,intItemUOMId = L.intItemUOMId
			,intLotId = L.intLotId
			,intSubLocationId = L.intSubLocationId
			,intStorageLocationId = L.intStorageLocationId
			,dblQty = L.dblQty
			,intTransactionId = SHP.intInventoryShipmentId
			,strTransactionId = SHP.strShipmentNumber
			,intTransactionTypeId = @intInventoryTransactionType
		FROM tblICInventoryShipment SHP
		JOIN tblICInventoryShipmentItem SHI ON SHI.intInventoryShipmentId = SHP.intInventoryShipmentId
		JOIN tblICInventoryShipmentItemLot SHL ON SHL.intInventoryShipmentItemId = SHI.intInventoryShipmentItemId
		JOIN tblICLot L ON L.intLotId = SHL.intLotId
		WHERE SHP.intInventoryShipmentId = @intInventoryShipmentId

		EXEC dbo.uspICCreateStockReservation @ItemsToReserve
			,@intInventoryShipmentId
			,@intInventoryTransactionType

		SELECT @intRemainingTasks = COUNT(*)
		FROM tblMFTask
		WHERE intOrderHeaderId = @intOrderHeaderId
			AND intTaskStateId <> 4

		IF @intRemainingTasks = 0
		BEGIN
			UPDATE tblMFOrderHeader
			SET intOrderStatusId = 6
			WHERE intOrderHeaderId = @intOrderHeaderId
		END
	END
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	RAISERROR (
			@ErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH