﻿CREATE PROCEDURE dbo.uspMFUpdateTask (@strXML NVARCHAR(MAX))
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @idoc INT
		,@strErrMsg NVARCHAR(MAX)
		,@intAssigneeId INT
		,@intOrderHeaderId INT
		,@intOrderDetailId INT
		,@dtmReleaseDate DATETIME
		,@strTaskNo NVARCHAR(40)
		,@intItemId INT
		,@intLotId INT
		,@intFromStorageLocationId INT
		,@intToStorageLocationId INT
		,@dblQty NUMERIC(18, 6)
		,@dblLotQty NUMERIC(18, 6)
		,@dblLotWeight NUMERIC(18, 6)
		,@intItemUOMId INT
		,@intWeightUOMId INT
		,@dblWeightPerQty NUMERIC(18, 6)
		,@intLocationId INT
		,@intUserId INT
		,@dtmCurrentDate DATETIME
		,@intTransactionCount INT
		,@strOrderType NVARCHAR(50)
		,@intCustomerLabelTypeId INT
		,@strReferenceNo NVARCHAR(50)
		,@intEntityCustomerId INT
		,@intInventoryShipmentId INT
		,@ItemsToReserve AS dbo.ItemReservationTableType
		,@intInventoryTransactionType AS INT = 5
		,@intTransactionId INT
		,@strTransactionId NVARCHAR(50)
		,@intOrderId INT
		,@strOrderNo NVARCHAR(50)
		,@intTaskId INT
		,@intConcurrencyId INT
		,@intTaskItemUOMId INT
		,@dblTaskQty NUMERIC(18, 6)

	SELECT @dtmCurrentDate = GETDATE()

	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@strXML

	SELECT @intTaskId = intTaskId
		,@intLotId = intLotId
		,@dblTaskQty = dblQty
		,@intTaskItemUOMId = intItemUOMId
		,@intOrderHeaderId = intOrderHeaderId
		,@intLocationId = intLocationId
		,@intUserId = intUserId
		,@intOrderDetailId =intOrderDetailId 
	FROM OPENXML(@idoc, 'root', 2) WITH (
			intTaskId INT
			,intLotId INT
			,dblQty NUMERIC(38, 20)
			,intItemUOMId INT
			,intOrderHeaderId INT
			,intLocationId INT
			,intUserId INT
			,intOrderDetailId  int
			)

	SELECT @strTaskNo = strOrderNo
		,@intToStorageLocationId = intStagingLocationId
		,@strOrderType = OT.strOrderType
		,@strReferenceNo = oh.strReferenceNo
		,@intOrderId = intOrderHeaderId
		,@strOrderNo = oh.strOrderNo
	FROM tblMFOrderHeader oh
	JOIN tblMFOrderType OT ON OT.intOrderTypeId = oh.intOrderTypeId
	WHERE intOrderHeaderId = @intOrderHeaderId

	SELECT @intFromStorageLocationId = intStorageLocationId
		,@intItemId = intItemId
		,@intItemUOMId = intItemUOMId
		,@intWeightUOMId = intWeightUOMId
		,@dblWeightPerQty = CASE 
			WHEN dblWeightPerQty = 0
				THEN 1
			ELSE dblWeightPerQty
			END
	FROM tblICLot
	WHERE intLotId = @intLotId

	IF @intTaskItemUOMId = @intItemUOMId
	BEGIN
		SELECT @dblLotQty = @dblTaskQty

		SELECT @dblLotWeight = @dblTaskQty * @dblWeightPerQty
	END
	ELSE
	BEGIN
		SELECT @dblLotQty = @dblTaskQty / @dblWeightPerQty

		SELECT @dblLotWeight = @dblTaskQty
	END

	SELECT @intToStorageLocationId = IsNULL(intStagingLocationId, @intToStorageLocationId)
	FROM tblMFOrderDetail
	WHERE intOrderHeaderId = @intOrderHeaderId
		AND intItemId = @intItemId

	IF @strOrderType = 'INVENTORY SHIPMENT STAGING'
	BEGIN
		SELECT @intEntityCustomerId = intEntityCustomerId
			,@intInventoryShipmentId = intInventoryShipmentId
		FROM tblICInventoryShipment
		WHERE strShipmentNumber = @strReferenceNo

		SELECT @intCustomerLabelTypeId = intCustomerLabelTypeId
		FROM tblMFItemOwner
		WHERE intOwnerId = @intEntityCustomerId
			AND intItemId = @intItemId

		IF @intCustomerLabelTypeId = 0
			OR @intCustomerLabelTypeId IS NULL
		BEGIN
			SELECT @intCustomerLabelTypeId = intCustomerLabelTypeId
			FROM tblMFItemOwner
			WHERE intOwnerId = @intEntityCustomerId
		END
	END

	SELECT @intTransactionCount = @@TRANCOUNT

	IF @intTransactionCount = 0
		BEGIN TRANSACTION

	IF isnull(@intTaskId, 0) = 0
	BEGIN
		INSERT INTO tblMFTask (
			intConcurrencyId
			,strTaskNo
			,intTaskTypeId
			,intTaskStateId
			,intAssigneeId
			,intOrderHeaderId
			,intOrderDetailId
			,intTaskPriorityId
			,dtmReleaseDate
			,intFromStorageLocationId
			,intToStorageLocationId
			,intItemId
			,intLotId
			,dblQty
			,intItemUOMId
			,dblWeight
			,intWeightUOMId
			,dblWeightPerQty
			,dblPickQty
			,intCreatedUserId
			,dtmCreated
			,intLastModifiedUserId
			,dtmLastModified
			,strComment
			)
		VALUES (
			0
			,@strTaskNo
			,2
			,CASE 
				WHEN @intAssigneeId > 0
					THEN 2
				ELSE 1
				END
			,@intAssigneeId
			,@intOrderHeaderId
			,@intOrderDetailId
			,2
			,ISNULL(@dtmReleaseDate, @dtmCurrentDate)
			,@intFromStorageLocationId
			,@intToStorageLocationId
			,@intItemId
			,@intLotId
			,@dblLotQty
			,@intItemUOMId
			,CASE 
				WHEN @intWeightUOMId IS NULL
					THEN @dblLotQty
				ELSE @dblLotWeight
				END
			,CASE 
				WHEN @intWeightUOMId IS NULL
					THEN @intItemUOMId
				ELSE @intWeightUOMId
				END
			,CASE 
				WHEN @intWeightUOMId IS NULL
					THEN 1
				ELSE @dblWeightPerQty
				END
			,@dblLotQty
			,@intUserId
			,@dtmCurrentDate
			,@intUserId
			,@dtmCurrentDate
			,'Manullay Created.'
			)

		SET @intTaskId = SCOPE_IDENTITY()

		SELECT @intConcurrencyId = 1
	END
	ELSE
	BEGIN
		UPDATE tblMFTask
		SET intConcurrencyId = intConcurrencyId + 1
			,intFromStorageLocationId = @intFromStorageLocationId
			,intLotId = @intLotId
			,dblQty = @dblLotQty
			,intItemUOMId = @intItemUOMId
			,dblWeight = CASE 
				WHEN @intWeightUOMId IS NULL
					THEN @dblLotQty
				ELSE @dblLotWeight
				END
			,intWeightUOMId = CASE 
				WHEN @intWeightUOMId IS NULL
					THEN @intItemUOMId
				ELSE @intWeightUOMId
				END
			,dblWeightPerQty = CASE 
				WHEN @intWeightUOMId IS NULL
					THEN 1
				ELSE @dblWeightPerQty
				END
			,dblPickQty = @dblLotQty
			,intLastModifiedUserId = @intUserId
			,dtmLastModified = @dtmCurrentDate
			,strComment = 'Manullay Updated.'
		WHERE intTaskId = @intTaskId
	END

	IF @strOrderType = 'INVENTORY SHIPMENT STAGING'
	BEGIN
		IF EXISTS (
				SELECT 1
				FROM tblMFOrderDetail OD
				LEFT JOIN tblMFTask T ON OD.intItemId = T.intItemId
					AND OD.intOrderHeaderId = T.intOrderHeaderId
				WHERE OD.intOrderHeaderId = @intOrderHeaderId
					AND OD.intOrderDetailId = @intOrderDetailId
					AND OD.dblQty > 0
				GROUP BY OD.dblQty
				HAVING ISNULL(SUM(dbo.fnMFConvertQuantityToTargetItemUOM(T.intItemUOMId, OD.intItemUOMId, T.dblQty)), 0) > OD.dblQty
				)
		BEGIN
			RAISERROR (
					'Task Qty cannot be greater than Items required Qty.'
					,16
					,1
					)

			RETURN
		END
	END
	ELSE
	BEGIN
		IF EXISTS (
				SELECT 1
				FROM tblMFOrderDetail OD
				LEFT JOIN tblMFTask T ON OD.intItemId = T.intItemId
					AND OD.intOrderHeaderId = T.intOrderHeaderId
				WHERE OD.intOrderHeaderId = @intOrderHeaderId
					AND OD.dblQty > 0
				GROUP BY OD.dblWeight
				HAVING ISNULL(SUM(dbo.fnMFConvertQuantityToTargetItemUOM(T.intWeightUOMId, OD.intWeightUOMId, T.dblWeight)), 0) > OD.dblWeight
				)
		BEGIN
			RAISERROR (
					'Task Qty cannot be greater than Items required Qty.'
					,16
					,1
					)

			RETURN
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
			,@intUserId
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

	IF @strOrderType = 'INVENTORY SHIPMENT STAGING'
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
			,strTransactionId = @strReferenceNo + ' / ' + @strOrderNo
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

	EXEC sp_xml_removedocument @idoc
END TRY

BEGIN CATCH
	SET @strErrMsg = ERROR_MESSAGE()

	IF XACT_STATE() != 0
		AND @intTransactionCount = 0
		ROLLBACK TRANSACTION

	IF @idoc <> 0
		EXEC sp_xml_removedocument @idoc

	RAISERROR (
			@strErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH
GO


