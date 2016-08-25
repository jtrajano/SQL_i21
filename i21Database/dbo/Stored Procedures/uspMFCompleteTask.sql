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
	DECLARE @tblTasks TABLE 
		(intTaskRecordId INT Identity(1, 1)
		,intTaskId INT
		,intOrderHeaderId INT)

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

			SELECT @intMinTaskRecordId = MIN(intTaskRecordId)
			FROM @tblTasks WHERE intTaskRecordId > @intMinTaskRecordId
		END
	END

END TRY
BEGIN CATCH
	SET @strErrMsg = ERROR_MESSAGE()
	IF @strErrMsg != ''
	BEGIN
		SET @strErrMsg = 'uspMFCompleteTask: ' + @strErrMsg
		RAISERROR (@strErrMsg, 16, 1, 'WITH NOWAIT')
	END
END CATCH