CREATE PROCEDURE uspMFCompleteTask
		@intOrderHeaderId INT,
		@intUserId INT,
		@intTaskId INT = NULL
AS 
BEGIN TRY
	DECLARE @strErrMsg NVARCHAR(MAX)
	DECLARE @intNewSubLocationId INT
	DECLARE @intNewStorageLocationId INT
	DECLARE @dblMoveQty NUMERIC(38, 20)
	DECLARE @intMoveItemUOMId int
	DECLARE @blnValidateLotReservation BIT = 0
	DECLARE @blnInventoryMove BIT = 0
	DECLARE @intLotId INT
	DECLARE @intNewLotId INT
	DECLARE @strLotNumber NVARCHAR(100)
	DECLARE @intItemId INT
	DECLARE @intLotLocationId INT
	DECLARE @intMinTaskRecordId INT
	DECLARE @strOrderNo NVARCHAR(100)
	DECLARE @intRemainingTasks INT
	DECLARE @intOrderDetailId INT
	DECLARE @tblTasks TABLE 
		(intTaskRecordId INT Identity(1, 1)
		,intTaskId INT
		,intOrderHeaderId INT)

BEGIN TRANSACTION

	SELECT @strOrderNo = strOrderNo
	FROM tblMFOrderHeader
	WHERE intOrderHeaderId = @intOrderHeaderId

	IF ISNULL(@intTaskId,0) <> 0 
	BEGIN
		SELECT @intNewSubLocationId = SL.intSubLocationId,
			   @intNewStorageLocationId = T.intToStorageLocationId,
			   @dblMoveQty = T.dblPickQty,
			   @intMoveItemUOMId = T.intItemUOMId,
			   @blnValidateLotReservation = 1,
			   @blnInventoryMove = 0,
			   @intLotId = intLotId
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

		EXEC uspMFLotMove  @intLotId = @intLotId
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
			,'Handheld'
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

		SELECT @intMinTaskRecordId = MIN(intTaskRecordId)
		FROM @tblTasks

		WHILE ISNULL(@intMinTaskRecordId,0) <> 0
		BEGIN
			SET @intTaskId = NULL

			SELECT @intTaskId = intTaskId
			FROM @tblTasks
			WHERE intTaskRecordId = @intMinTaskRecordId

			SELECT @intNewSubLocationId = SL.intSubLocationId,
					@intNewStorageLocationId = T.intToStorageLocationId,
					@dblMoveQty = T.dblPickQty,
					@intMoveItemUOMId = T.intItemUOMId,
					@blnValidateLotReservation = 1,
					@blnInventoryMove = 0,
					@intLotId = intLotId
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

			EXEC uspMFLotMove  @intLotId = @intLotId
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
			VALUES ( 
			     1
				,@intOrderDetailId
				,@intOrderHeaderId
				,@intNewLotId
				,'Order Staged'
				,@intUserId
				,GetDate()
				)

			SELECT @intMinTaskRecordId = MIN(intTaskRecordId)
			FROM @tblTasks WHERE intTaskRecordId > @intMinTaskRecordId
		END
	END

	
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

COMMIT TRANSACTION
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION
	SET @strErrMsg = ERROR_MESSAGE()
	IF @strErrMsg != ''
	BEGIN
		SET @strErrMsg = 'uspMFCompleteTask: ' + @strErrMsg
		RAISERROR (@strErrMsg, 16, 1, 'WITH NOWAIT')
	END
END CATCH