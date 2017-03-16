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
		,@intOwnerId INT
		,@intSourceId INT
		,@intSourceTransactionTypeId INT
		,@intInventoryAdjustmentId INT
		,@intStorageLocationId INT
		,@intSubLocationId INT

	SELECT @strLotNumber = strLotNumber
		,@intItemId = intItemId
		,@intStorageLocationId = intStorageLocationId
		,@intSubLocationId = intSubLocationId
		,@intLocationId = intLocationId
		,@dtmDate = GETDATE()
	FROM tblICLot
	WHERE intLotId = @intLotId

	SELECT @intOldItemOwnerId = intItemOwnerId
	FROM tblMFLotInventory
	WHERE intLotId = @intLotId

	SELECT @intOwnerId = intOwnerId
	FROM tblICItemOwner
	WHERE intItemOwnerId = @intNewItemOwnerId

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

		UPDATE tblMFItemOwnerDetail
		SET dtmToDate = @dtmDate
		WHERE intLotId = @intLotId
			AND dtmToDate IS NULL

		INSERT INTO tblMFItemOwnerDetail (
			intLotId
			,intItemId
			,intOwnerId
			,dtmFromDate
			)
		SELECT @intLotId
			,@intItemId
			,@intOwnerId
			,@dtmDate

		EXEC uspMFAdjustInventory @dtmDate = @dtmDate
			,@intTransactionTypeId = 43
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
		IF @intNewItemOwnerId <> ISNULL(@intOldItemOwnerId, 0)
		BEGIN
			UPDATE tblMFLotInventory
			SET intItemOwnerId = @intNewItemOwnerId
				,intConcurrencyId = (intConcurrencyId + 1)
			WHERE intLotId = @intLotId

			UPDATE tblMFItemOwnerDetail
			SET dtmToDate = @dtmDate
			WHERE intLotId = @intLotId
				AND dtmToDate IS NULL

			INSERT INTO tblMFItemOwnerDetail (
				intLotId
				,intItemId
				,intOwnerId
				,dtmFromDate
				)
			SELECT @intLotId
				,@intItemId
				,@intOwnerId
				,@dtmDate

			EXEC uspMFAdjustInventory @dtmDate = @dtmDate
				,@intTransactionTypeId = 43
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

	SELECT @intSourceId = 1
		,@intSourceTransactionTypeId = 8

	EXEC [dbo].[uspICInventoryAdjustment_CreatePostOwnerChange] @intItemId = @intItemId
		,@dtmDate = @dtmDate
		,@intLocationId = @intLocationId
		,@intSubLocationId = @intSubLocationId
		,@intStorageLocationId = @intStorageLocationId
		,@strLotNumber = @strLotNumber
		,@intNewOwnerId = @intOwnerId
		,@intSourceId = @intSourceId
		,@intSourceTransactionTypeId = @intSourceTransactionTypeId
		,@intEntityUserSecurityId = @intUserId
		,@intInventoryAdjustmentId = @intInventoryAdjustmentId OUTPUT
		,@strDescription = NULL
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
