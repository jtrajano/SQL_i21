CREATE PROCEDURE uspMFCompleteTask @intOrderHeaderId INT
	,@intUserId INT
	,@strTaskId NVARCHAR(MAX) = NULL
	,@ysnLoad BIT = 0
AS
BEGIN TRY
	DECLARE @strErrMsg NVARCHAR(MAX)
		,@intNewSubLocationId INT
		,@intNewStorageLocationId INT
		,@dblMoveQty NUMERIC(38, 20)
		,@intMoveItemUOMId INT
		,@blnValidateLotReservation BIT = 0
		,@blnInventoryMove BIT = 0
		,@intLotId INT
		,@intNewLotId INT
		,@strLotNumber NVARCHAR(100)
		,@intItemId INT
		,@intLotLocationId INT
		,@intMinTaskRecordId INT
		,@strOrderNo NVARCHAR(100)
		,@intRemainingTasks INT
		,@intOrderDetailId INT
		,@dblAllocatedQty NUMERIC(38, 20)
		,@dblQty NUMERIC(38, 20)
		,@ysnLoadProcessEnabled BIT
		,@intDockDoorId INT
		,@ItemsToReserve AS dbo.ItemReservationTableType
		,@intInventoryTransactionType AS INT = 5
		,@intTransactionId INT
		,@strTransactionId NVARCHAR(50)
		,@intInventoryShipmentId INT
		,@intLocationId INT
		,@dtmDate DATETIME
		,@intStorageLocationId INT
		,@intSubLocationId INT
		,@intTransferId INT
		,@strShipmentNo NVARCHAR(100)
		,@intShipmentItemId INT
		,@intLotItemId INT
		,@dblLotQty NUMERIC(18, 6)
		,@dblLotWeight NUMERIC(18, 6)
		,@strOrderType NVARCHAR(50)
		,@intStagingLocationId INT
		,@intDefaultShipmentDockDoorLocation INT
		,@intCustomerLabelTypeId INT
		,@intEntityCustomerId INT
		,@strReferenceNo NVARCHAR(50)
		,@dblWeightPerQty NUMERIC(18, 6)
		,@intOrderId INT
		,@strDescription NVARCHAR(50)
		,@strInventoryTracking NVARCHAR(50)
		,@intTransactionCount INT
		,@intTaskId INT
		,@intOrderDirectionId INT
		,@strWorkOrderNo NVARCHAR(MAX)
		,@intWorkOrderId INT

	IF @strTaskId = ''
		SELECT @strTaskId = NULL

	IF @strTaskId = ''
		SELECT @strTaskId = NULL

	SELECT @dtmDate = GETDATE()

	DECLARE @tblTasks TABLE (
		intTaskRecordId INT Identity(1, 1)
		,intTaskId INT
		,intOrderHeaderId INT
		)
	DECLARE @TransferEntries AS InventoryTransferStagingTable

	SELECT @ysnLoadProcessEnabled = ysnLoadProcessEnabled
		,@intDefaultShipmentDockDoorLocation = intDefaultShipmentDockDoorLocation
	FROM tblMFCompanyPreference

	IF @ysnLoadProcessEnabled IS NULL
	BEGIN
		SELECT @ysnLoadProcessEnabled = 0
	END

	SELECT @strOrderNo = OH.strOrderNo
		,@strOrderType = OT.strOrderType
		,@intStagingLocationId = OH.intStagingLocationId
		,@strReferenceNo = strReferenceNo
		,@intOrderId = intOrderHeaderId
		,@intLocationId = intLocationId
		,@intOrderDirectionId = intOrderDirectionId
	FROM tblMFOrderHeader OH
	JOIN tblMFOrderType OT ON OT.intOrderTypeId = OH.intOrderTypeId
	WHERE intOrderHeaderId = @intOrderHeaderId

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

	SELECT @intTransactionCount = @@TRANCOUNT

	IF @intTransactionCount = 0
		BEGIN TRANSACTION

	--EXEC [dbo].[uspICPostStockReservation] @intTransactionId = @intOrderHeaderId
	--	,@intTransactionTypeId = 34
	--	,@ysnPosted = 1
	EXEC dbo.uspICCreateStockReservation @ItemsToReserve
			,@intOrderHeaderId
			,34

	IF NOT EXISTS (
			SELECT 1
			FROM tempdb..sysobjects
			WHERE id = OBJECT_ID('tempdb..##tmpAddInventoryTransferResult')
			)
	BEGIN
		CREATE TABLE #tmpAddInventoryTransferResult (
			intSourceId INT
			,intInventoryTransferId INT
			)
	END

	IF @strTaskId IS NOT NULL
	BEGIN
		IF @ysnLoad = 0
		BEGIN
			INSERT INTO @tblTasks (
				intTaskId
				,intOrderHeaderId
				)
			SELECT intTaskId
				,intOrderHeaderId
			FROM tblMFTask
			WHERE intOrderHeaderId = @intOrderHeaderId
				AND intTaskStateId NOT IN (
					3
					,4
					)
				AND intTaskId IN (
					SELECT Item Collate Latin1_General_CI_AS
					FROM [dbo].[fnSplitString](@strTaskId, ',')
					)
		END
		ELSE
		BEGIN
			INSERT INTO @tblTasks (
				intTaskId
				,intOrderHeaderId
				)
			SELECT intTaskId
				,intOrderHeaderId
			FROM tblMFTask
			WHERE intOrderHeaderId = @intOrderHeaderId
				AND intTaskStateId <> 4
				AND intTaskId IN (
					SELECT Item Collate Latin1_General_CI_AS
					FROM [dbo].[fnSplitString](@strTaskId, ',')
					)
		END
	END
	ELSE
	BEGIN
		IF @ysnLoad = 0
		BEGIN
			INSERT INTO @tblTasks (
				intTaskId
				,intOrderHeaderId
				)
			SELECT intTaskId
				,intOrderHeaderId
			FROM tblMFTask
			WHERE intOrderHeaderId = @intOrderHeaderId
				AND intTaskStateId NOT IN (
					3
					,4
					)
		END
		ELSE
		BEGIN
			INSERT INTO @tblTasks (
				intTaskId
				,intOrderHeaderId
				)
			SELECT intTaskId
				,intOrderHeaderId
			FROM tblMFTask
			WHERE intOrderHeaderId = @intOrderHeaderId
				AND intTaskStateId <> 4
		END
	END

	SELECT @intMinTaskRecordId = MIN(intTaskRecordId)
	FROM @tblTasks

	WHILE ISNULL(@intMinTaskRecordId, 0) <> 0
	BEGIN
		SELECT @intTaskId = NULL

		SELECT @intNewLotId = NULL

		SELECT @intTaskId = intTaskId
		FROM @tblTasks
		WHERE intTaskRecordId = @intMinTaskRecordId

		SELECT @intNewSubLocationId = NULL
			,@intNewStorageLocationId = NULL
			,@dblMoveQty = NULL
			,@intMoveItemUOMId = NULL
			,@blnValidateLotReservation = 1
			,@blnInventoryMove = 0
			,@intLotId = NULL

		IF @strOrderType = 'INVENTORY SHIPMENT STAGING'
		BEGIN
			SELECT @intNewSubLocationId = SL.intSubLocationId
				,@intNewStorageLocationId = T.intToStorageLocationId
				,@dblMoveQty = T.dblPickQty
				,@blnValidateLotReservation = 1
				,@blnInventoryMove = 0
				,@intLotId = intLotId
				,@intItemId = T.intItemId
				,@intStorageLocationId = T.intFromStorageLocationId
				,@intMoveItemUOMId = T.intItemUOMId
			FROM tblMFTask T
			JOIN tblICStorageLocation SL ON T.intToStorageLocationId = SL.intStorageLocationId
			WHERE T.intTaskId = @intTaskId

			SELECT @strLotNumber = strLotNumber
				,@intLotLocationId = intLocationId
			FROM tblICLot
			WHERE intLotId = @intLotId

			SELECT @intDockDoorId = NULL

			SELECT @intDockDoorId = IsNULL(InvSI.intDockDoorId, @intDefaultShipmentDockDoorLocation)
				,@strDescription = @strOrderNo + ' / ' + InvS.strShipmentNumber
			FROM tblICInventoryShipment InvS
			JOIN tblICInventoryShipmentItem InvSI ON InvS.intInventoryShipmentId = InvSI.intInventoryShipmentId
			WHERE strShipmentNumber = @strReferenceNo
				AND InvSI.intItemId = @intItemId

			SELECT @strDescription = @strOrderNo + ' / ' + @strReferenceNo

			SELECT @intTransactionId = @intInventoryShipmentId

			SELECT @strTransactionId = @strReferenceNo

			EXEC dbo.uspICCreateStockReservation @ItemsToReserve
				,@intTransactionId
				,@intInventoryTransactionType

			EXEC dbo.uspICCreateStockReservation @ItemsToReserve
				,@intOrderId
				,34
			SELECT @intInventoryTransactionType = 5
		END
		ELSE
		BEGIN
			SELECT @intNewSubLocationId = SL.intSubLocationId
				,@intNewStorageLocationId = T.intToStorageLocationId
				,@dblMoveQty = T.dblPickQty
				,@intMoveItemUOMId = T.intItemUOMId
				,@blnValidateLotReservation = 1
				,@blnInventoryMove = 0
				,@intLotId = intLotId
				,@intItemId = T.intItemId
				,@intStorageLocationId = T.intFromStorageLocationId
			FROM tblMFTask T
			JOIN tblICStorageLocation SL ON T.intToStorageLocationId = SL.intStorageLocationId
			WHERE T.intTaskId = @intTaskId

			SELECT @intSubLocationId = intSubLocationId
			FROM tblICStorageLocation
			WHERE intStorageLocationId = @intStorageLocationId

			SELECT @strLotNumber = strLotNumber
				,@intLotLocationId = intLocationId
			FROM tblICLot
			WHERE intLotId = @intLotId

			SELECT @strDescription = @strOrderNo + ' / ' + W.strWorkOrderNo
				,@strWorkOrderNo = W.strWorkOrderNo
				,@intWorkOrderId = W.intWorkOrderId
			FROM tblMFStageWorkOrder SW
			JOIN tblMFWorkOrder W ON W.intWorkOrderId = SW.intWorkOrderId
			WHERE SW.intOrderHeaderId = @intOrderHeaderId

			SELECT @intTransactionId = @intWorkOrderId

			SELECT @strTransactionId = @strWorkOrderNo

			SELECT @intInventoryTransactionType = 9
		END

		SELECT @strInventoryTracking = strInventoryTracking
		FROM tblICItem
		WHERE intItemId = @intItemId

		SELECT @intOrderDetailId = intOrderDetailId
		FROM tblMFOrderDetail
		WHERE intOrderHeaderId = @intOrderHeaderId
			AND intItemId = @intItemId

		IF @intNewStorageLocationId = @intStorageLocationId
		BEGIN
			SELECT @intNewLotId = @intLotId
		END
		ELSE
		BEGIN
			IF @strInventoryTracking = 'Lot Level'
			BEGIN
				EXEC uspMFLotMove @intLotId = @intLotId
					,@intNewSubLocationId = @intNewSubLocationId
					,@intNewStorageLocationId = @intNewStorageLocationId
					,@dblMoveQty = @dblMoveQty
					,@intMoveItemUOMId = @intMoveItemUOMId
					,@intUserId = @intUserId
					,@blnValidateLotReservation = 0
					,@blnInventoryMove = @blnInventoryMove
					,@strNotes = @strDescription

				SELECT TOP 1 @intNewLotId = intLotId
				FROM tblICLot
				WHERE strLotNumber = @strLotNumber
					AND intItemId = @intItemId
					AND intLocationId = @intLotLocationId
					AND intSubLocationId = @intNewSubLocationId
					AND intStorageLocationId = @intNewStorageLocationId
			END
			ELSE
			BEGIN
				DELETE
				FROM @TransferEntries

				-- Insert the data needed to create the inventory transfer.
				INSERT INTO @TransferEntries (
					-- Header
					[dtmTransferDate]
					,[strTransferType]
					,[intSourceType]
					,[strDescription]
					,[intFromLocationId]
					,[intToLocationId]
					,[ysnShipmentRequired]
					,[intStatusId]
					,[intShipViaId]
					,[intFreightUOMId]
					-- Detail
					,[intItemId]
					,[intLotId]
					,[intItemUOMId]
					,[dblQuantityToTransfer]
					,[strNewLotId]
					,[intFromSubLocationId]
					,[intToSubLocationId]
					,[intFromStorageLocationId]
					,[intToStorageLocationId]
					-- Integration Field
					,[intInventoryTransferId]
					,[intSourceId]
					,[strSourceId]
					,[strSourceScreenName]
					)
				SELECT -- Header
					[dtmTransferDate] = @dtmDate
					,[strTransferType] = 'Storage to Storage'
					,[intSourceType] = 0
					,[strDescription] = NULL
					,[intFromLocationId] = @intLocationId
					,[intToLocationId] = @intLocationId
					,[ysnShipmentRequired] = 0
					,[intStatusId] = 3
					,[intShipViaId] = NULL
					,[intFreightUOMId] = NULL
					-- Detail
					,[intItemId] = @intItemId
					,[intLotId] = NULL
					,[intItemUOMId] = @intMoveItemUOMId
					,[dblQuantityToTransfer] = @dblMoveQty
					,[strNewLotId] = NULL
					,[intFromSubLocationId] = @intSubLocationId
					,[intToSubLocationId] = @intNewSubLocationId
					,[intFromStorageLocationId] = @intStorageLocationId
					,[intToStorageLocationId] = @intNewStorageLocationId
					-- Integration Field
					,[intInventoryTransferId] = NULL
					,[intSourceId] = @intTaskId
					,[strSourceId] = @strDescription
					,[strSourceScreenName] = 'Pick List'

				-- Call uspICAddInventoryTransfer stored procedure.
				EXEC dbo.uspICAddInventoryTransfer @TransferEntries
					,@intUserId

				WHILE EXISTS (
						SELECT TOP 1 1
						FROM #tmpAddInventoryTransferResult
						)
				BEGIN
					SELECT @intTransferId = NULL
						,@strTransactionId = NULL

					SELECT TOP 1 @intTransferId = intInventoryTransferId
					FROM #tmpAddInventoryTransferResult

					-- Post the Inventory Transfer that was created
					SELECT @strTransactionId = strTransferNo
					FROM tblICInventoryTransfer
					WHERE intInventoryTransferId = @intTransferId

					EXEC dbo.uspICPostInventoryTransfer 1
						,0
						,@strTransactionId
						,@intUserId;

					DELETE
					FROM #tmpAddInventoryTransferResult
					WHERE intInventoryTransferId = @intTransferId
				END;
			END
		END

		IF @ysnLoadProcessEnabled = 0
			OR @strOrderType <> 'INVENTORY SHIPMENT STAGING'
		BEGIN
			UPDATE tblMFTask
			SET intTaskStateId = 4
				,intLotId = @intNewLotId
				,intFromStorageLocationId = @intNewStorageLocationId
			WHERE intTaskId = @intTaskId
		END
		ELSE IF @ysnLoadProcessEnabled = 1
			AND @ysnLoad = 0 --Staging is completed.
		BEGIN
			UPDATE tblMFTask
			SET intTaskStateId = 3
				,intLotId = @intNewLotId
				,intFromStorageLocationId = @intNewStorageLocationId
				,intToStorageLocationId = @intDockDoorId
			WHERE intTaskId = @intTaskId
		END
		ELSE IF @ysnLoadProcessEnabled = 1
			AND @ysnLoad = 1
		BEGIN
			UPDATE tblMFTask
			SET intTaskStateId = 4
				,intLotId = @intNewLotId
				,intFromStorageLocationId = @intNewStorageLocationId
			WHERE intTaskId = @intTaskId

			UPDATE tblMFOrderManifest
			SET intLotId = @intNewLotId
			WHERE intOrderHeaderId = @intOrderHeaderId
				AND intOrderDetailId = @intOrderDetailId
				AND intLotId = @intLotId
		END

		INSERT INTO tblMFPickForWOStaging (
			intOrderHeaderId
			,strOrderNo
			,intTaskId
			,intOrderLotId
			,intPickedLotId
			,dblOrderQty
			,dblPickedQty
			,intUserId
			,strPickedFrom
			,ysnLoad
			)
		VALUES (
			@intOrderHeaderId
			,@strOrderNo
			,@intTaskId
			,@intLotId
			,@intNewLotId
			,@dblMoveQty
			,@dblMoveQty
			,@intUserId
			,'Desktop'
			,@ysnLoad
			)

		IF @ysnLoad = 0
			AND @intCustomerLabelTypeId <> 2
			AND @intOrderDirectionId = 2
		BEGIN
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
		END
		ELSE IF @intCustomerLabelTypeId = 2
		BEGIN
			UPDATE tblMFOrderManifest
			SET intLotId = @intNewLotId
			WHERE intOrderHeaderId = @intOrderHeaderId
				AND intOrderDetailId = @intOrderDetailId
				AND intLotId = @intLotId
		END

		IF @strOrderType = 'INVENTORY SHIPMENT STAGING'
			AND (
				(
					@ysnLoadProcessEnabled = 1
					AND @ysnLoad = 1
					)
				OR (
					@ysnLoadProcessEnabled = 0
					AND @ysnLoad = 0
					)
				)
			AND @strInventoryTracking = 'Lot Level'
		BEGIN
			SELECT @strShipmentNo = NULL
				,@intShipmentItemId = NULL
				,@intLotItemId = NULL
				,@dblLotQty = NULL
				,@dblLotWeight = NULL

			SELECT @intLotItemId = intItemId
				,@dblWeightPerQty = dblWeightPerQty
			FROM tblICLot
			WHERE intLotId = @intNewLotId

			SELECT @strShipmentNo = strReferenceNo
			FROM dbo.tblMFOrderHeader
			WHERE intOrderHeaderId = @intOrderHeaderId

			SELECT @intShipmentItemId = intInventoryShipmentItemId
			FROM tblICInventoryShipmentItem i
			JOIN tblICInventoryShipment s ON i.intInventoryShipmentId = s.intInventoryShipmentId
			WHERE s.strShipmentNumber = @strShipmentNo
				AND intItemId = @intLotItemId

			IF EXISTS (
					SELECT *
					FROM dbo.tblICInventoryShipmentItem
					WHERE intInventoryShipmentItemId = @intShipmentItemId
						AND (
							intSubLocationId IS NULL
							OR intStorageLocationId IS NULL
							OR intDockDoorId IS NULL
							)
					)
			BEGIN
				UPDATE tblICInventoryShipmentItem
				SET intSubLocationId = @intNewSubLocationId
					,intStorageLocationId = @intNewStorageLocationId
					,intDockDoorId = @intNewStorageLocationId
				WHERE intInventoryShipmentItemId = @intShipmentItemId
			END

			IF NOT EXISTS (
					SELECT *
					FROM tblICInventoryShipmentItemLot
					WHERE intInventoryShipmentItemId = @intShipmentItemId
						AND intLotId = @intNewLotId
					)
			BEGIN
				INSERT INTO tblICInventoryShipmentItemLot (
					intInventoryShipmentItemId
					,intLotId
					,dblQuantityShipped
					,dblGrossWeight
					,dblTareWeight
					,dblWeightPerQty
					,intConcurrencyId
					)
				VALUES (
					@intShipmentItemId
					,@intNewLotId
					,@dblMoveQty
					,@dblMoveQty * @dblWeightPerQty
					,0
					,@dblWeightPerQty
					,1
					)
			END
			ELSE
			BEGIN
				UPDATE tblICInventoryShipmentItemLot
				SET dblQuantityShipped = dblQuantityShipped + @dblMoveQty
					,dblGrossWeight = dblGrossWeight + (@dblMoveQty * @dblWeightPerQty)
				WHERE intInventoryShipmentItemId = @intShipmentItemId
					AND intLotId = @intNewLotId
			END

			SELECT @dblAllocatedQty = NULL

			SELECT @dblAllocatedQty = dblQuantityShipped
			FROM tblICInventoryShipmentItemLot
			WHERE intInventoryShipmentItemId = @intShipmentItemId
				AND intLotId = @intNewLotId

			IF @dblAllocatedQty IS NULL
			BEGIN
				SELECT @dblAllocatedQty = 0
			END

			SELECT @dblQty = NULL

			SELECT @dblQty = dblQty
			FROM tblICLot
			WHERE intLotId = @intNewLotId

			IF @dblAllocatedQty > @dblQty
			BEGIN
				RAISERROR (
						'QUANTITY IS NOT AVAILABLE TO COMPLETE PICK TASK.'
						,16
						,1
						)

				RETURN
			END
		END

		SELECT @intMinTaskRecordId = MIN(intTaskRecordId)
		FROM @tblTasks
		WHERE intTaskRecordId > @intMinTaskRecordId
	END

	--EXEC [dbo].[uspICPostStockReservation] @intTransactionId = @intOrderHeaderId
	--	,@intTransactionTypeId = 34
	--	,@ysnPosted = 0

	IF @ysnLoad = 0
	BEGIN
		SELECT @intRemainingTasks = COUNT(*)
		FROM tblMFTask
		WHERE intOrderHeaderId = @intOrderHeaderId
			AND intTaskStateId NOT IN (
				3
				,4
				)
	END
	ELSE
	BEGIN
		SELECT @intRemainingTasks = COUNT(*)
		FROM tblMFTask
		WHERE intOrderHeaderId = @intOrderHeaderId
			AND intTaskStateId <> 4
	END

	IF @intRemainingTasks = 0
		AND @strOrderType = 'WO PROD RETURN'
	BEGIN
		UPDATE tblMFOrderHeader
		SET intOrderStatusId = 10
		WHERE intOrderHeaderId = @intOrderHeaderId
	END
	ELSE IF (
			@intRemainingTasks = 0
			AND (
				@ysnLoadProcessEnabled = 0
				OR @strOrderType <> 'INVENTORY SHIPMENT STAGING'
				)
			)
	BEGIN
		UPDATE tblMFOrderHeader
		SET intOrderStatusId = 6
		WHERE intOrderHeaderId = @intOrderHeaderId
	END
	ELSE IF @intRemainingTasks = 0
		AND @ysnLoadProcessEnabled = 1
		AND @ysnLoad = 0
	BEGIN
		UPDATE tblMFOrderHeader
		SET intOrderStatusId = 6
		WHERE intOrderHeaderId = @intOrderHeaderId
	END
	ELSE IF @intRemainingTasks = 0
		AND @ysnLoadProcessEnabled = 1
		AND @ysnLoad = 1
	BEGIN
		UPDATE tblMFOrderHeader
		SET intOrderStatusId = 7
		WHERE intOrderHeaderId = @intOrderHeaderId
	END

	IF (
			@strOrderType = 'INVENTORY SHIPMENT STAGING'
			OR @strOrderType = 'WO PROD STAGING'
			)
	BEGIN
		SELECT @intTransactionId = @intInventoryShipmentId

		SELECT @strTransactionId = @strReferenceNo
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
			--AND @strOrderType = 'INVENTORY SHIPMENT STAGING'

		EXEC dbo.uspICCreateStockReservation @ItemsToReserve
			,@intTransactionId
			,@intInventoryTransactionType

		DELETE
		FROM @ItemsToReserve

		--EXEC dbo.uspICCreateStockReservation @ItemsToReserve
		--	,@intOrderId
		--	,34

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
