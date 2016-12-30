CREATE PROCEDURE uspMFLotOwnerUpdate @intLotId INT
	,@intNewItemOwnerId INT
	,@intUserId INT
AS
BEGIN TRY
	DECLARE @intItemId INT
		,@dtmDate DATETIME
		,@intLocationId INT
		,@strLotNumber NVARCHAR(50)
		,@TransactionCount INT
		,@ErrMsg NVARCHAR(MAX)
		,@intOldItemOwnerId INT

	SELECT @strLotNumber = strLotNumber
		,@intItemId = intItemId
		,@intLocationId = intLocationId
		,@dtmDate = GETDATE()
	FROM tblICLot
	WHERE intLotId = @intLotId

	SELECT @intOldItemOwnerId = intItemOwnerId
	FROM tblMFLotInventory
	WHERE intLotId = @intLotId

	IF ISNULL(@strLotNumber, '') = ''
	BEGIN
		RAISERROR (
				51192
				,11
				,1
				)
	END

	IF NOT EXISTS (
			SELECT 1
			FROM tblMFLotInventory
			WHERE intLotId = @intLotId
			)
	BEGIN
		INSERT INTO tblMFLotInventory (
			intConcurrencyId
			,intLotId
			,intItemOwnerId
			)
		SELECT 1
			,@intLotId
			,@intNewItemOwnerId

		EXEC uspMFAdjustInventory @dtmDate = @dtmDate
			,@intTransactionTypeId = 41
			,@intItemId = @intItemId
			,@intSourceLotId = @intLotId
			,@intDestinationLotId = NULL
			,@dblQty = NULL
			,@intItemUOMId = NULL
			,@intOldItemId = NULL
			,@dtmOldExpiryDate = NULL
			,@dtmNewExpiryDate = NULL
			,@intOldLotStatusId = NULL
			,@intNewLotStatusId = NULL
			,@intUserId = @intUserId
			,@strNote = NULL
			,@strReason = NULL
			,@intLocationId = @intLocationId
			,@intInventoryAdjustmentId = NULL
			,@intOldItemOwnerId = NULL
			,@intNewItemOwnerId = @intNewItemOwnerId
	END
	ELSE
	BEGIN
		IF @intNewItemOwnerId <> @intOldItemOwnerId
		BEGIN
			UPDATE tblMFLotInventory
			SET intItemOwnerId = @intNewItemOwnerId
				,intConcurrencyId = (intConcurrencyId + 1)
			WHERE intLotId = @intLotId

			EXEC uspMFAdjustInventory @dtmDate = @dtmDate
				,@intTransactionTypeId = 41
				,@intItemId = @intItemId
				,@intSourceLotId = @intLotId
				,@intDestinationLotId = NULL
				,@dblQty = NULL
				,@intItemUOMId = NULL
				,@intOldItemId = NULL
				,@dtmOldExpiryDate = NULL
				,@dtmNewExpiryDate = NULL
				,@intOldLotStatusId = NULL
				,@intNewLotStatusId = NULL
				,@intUserId = @intUserId
				,@strNote = NULL
				,@strReason = NULL
				,@intLocationId = @intLocationId
				,@intInventoryAdjustmentId = NULL
				,@intOldItemOwnerId = @intOldItemOwnerId
				,@intNewItemOwnerId = @intNewItemOwnerId
		END
	END
END TRY

BEGIN CATCH
	IF XACT_STATE() != 0
		AND @TransactionCount = 0
		AND @@TRANCOUNT > 0
		ROLLBACK TRANSACTION

	SET @ErrMsg = ERROR_MESSAGE()

	RAISERROR (
			@ErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH
