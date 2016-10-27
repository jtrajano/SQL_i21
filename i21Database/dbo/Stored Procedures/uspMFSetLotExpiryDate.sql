CREATE PROCEDURE [uspMFSetLotExpiryDate] @intLotId INT
	,@dtmNewExpiryDate DATETIME
	,@intUserId INT
AS
BEGIN TRY
	DECLARE @intItemId INT
		,@dtmDate DATETIME
		,@intLocationId INT
		,@intSubLocationId INT
		,@intStorageLocationId INT
		,@strLotNumber NVARCHAR(50)
		,@intSourceId INT
		,@intSourceTransactionTypeId INT
		,@intLotStatusId INT
		,@dtmLotExpiryDate DATETIME
		,@dtmLotCreateDate DATETIME
		,@intInventoryAdjustmentId INT
		,@TransactionCount INT
		,@ErrMsg NVARCHAR(MAX)
		,@intParentLotId INT
		,@intChildLotCount INT
		,@intLotRecordId INT
	DECLARE @tblLotsWithSameParentLot TABLE (
		intLotRecordId INT Identity(1, 1)
		,strLotNumber NVARCHAR(100)
		,intLotId INT
		,intParentLotId INT
		,intSubLocationId INT
		,intStorageLocationId INT
		,intLocationId INT
		)

	SELECT @intItemId = intItemId
		,@intLocationId = intLocationId
		,@intSubLocationId = intSubLocationId
		,@intStorageLocationId = intStorageLocationId
		,@strLotNumber = strLotNumber
		,@dtmLotExpiryDate = dtmExpiryDate
		,@dtmLotCreateDate = dtmDateCreated
		,@intParentLotId = intParentLotId
	FROM tblICLot
	WHERE intLotId = @intLotId

	SELECT @intChildLotCount = COUNT(*)
	FROM tblICLot
	WHERE intParentLotId = @intParentLotId

	SELECT @dtmDate = GETDATE()

	SELECT @intSourceId = 1
		,@intSourceTransactionTypeId = 8

	IF ISNULL(@strLotNumber, '') = ''
	BEGIN
		RAISERROR (
				51192
				,11
				,1
				)
	END

	IF @dtmLotExpiryDate = @dtmNewExpiryDate
	BEGIN
		RAISERROR (
				51180
				,11
				,1
				)
	END

	IF @dtmLotCreateDate > @dtmNewExpiryDate
	BEGIN
		RAISERROR (
				51193
				,11
				,1
				)
	END

	IF EXISTS (
			SELECT 1
			FROM tblWHSKU
			WHERE intLotId = @intLotId
			)
	BEGIN
		RAISERROR (
				90008
				,11
				,1
				)
	END

	IF (@intChildLotCount > 1)
	BEGIN
		INSERT INTO @tblLotsWithSameParentLot
		SELECT strLotNumber
			,intLotId
			,intParentLotId
			,intSubLocationId
			,intStorageLocationId
			,intLocationId
		FROM tblICLot
		WHERE intParentLotId = @intParentLotId

		SELECT @intLotRecordId = MIN(intLotRecordId)
		FROM @tblLotsWithSameParentLot

		WHILE (@intLotRecordId IS NOT NULL)
		BEGIN
			SET @strLotNumber = NULL
			SET @intSubLocationId = NULL
			SET @intStorageLocationId = NULL
			SET @intLocationId = NULL

			SELECT @strLotNumber = strLotNumber
				,@intSubLocationId = intSubLocationId
				,@intStorageLocationId = intStorageLocationId
				,@intLocationId = intLocationId
			FROM @tblLotsWithSameParentLot
			WHERE intLotRecordId = @intLotRecordId

			EXEC uspICInventoryAdjustment_CreatePostExpiryDateChange @intItemId
				,@dtmDate
				,@intLocationId
				,@intSubLocationId
				,@intStorageLocationId
				,@strLotNumber
				,@dtmNewExpiryDate
				,@intSourceId
				,@intSourceTransactionTypeId
				,@intUserId
				,@intInventoryAdjustmentId OUTPUT

			EXEC dbo.uspMFAdjustInventory @dtmDate = @dtmDate
				,@intTransactionTypeId = 18
				,@intItemId = @intItemId
				,@intSourceLotId = @intLotId
				,@intDestinationLotId = NULL
				,@dblQty = NULL
				,@intItemUOMId = NULL
				,@intOldItemId = NULL
				,@dtmOldExpiryDate = @dtmLotExpiryDate
				,@dtmNewExpiryDate = @dtmNewExpiryDate
				,@intOldLotStatusId = NULL
				,@intNewLotStatusId = NULL
				,@intUserId = @intUserId
				,@strNote = NULL
				,@strReason = NULL
				,@intLocationId = @intLocationId
				,@intInventoryAdjustmentId = @intInventoryAdjustmentId

			SELECT @intLotRecordId = MIN(intLotRecordId)
			FROM @tblLotsWithSameParentLot
			WHERE intLotRecordId > @intLotRecordId
		END
	END
	ELSE
	BEGIN
		EXEC uspICInventoryAdjustment_CreatePostExpiryDateChange @intItemId
			,@dtmDate
			,@intLocationId
			,@intSubLocationId
			,@intStorageLocationId
			,@strLotNumber
			,@dtmNewExpiryDate
			,@intSourceId
			,@intSourceTransactionTypeId
			,@intUserId
			,@intInventoryAdjustmentId OUTPUT

		EXEC dbo.uspMFAdjustInventory @dtmDate = @dtmDate
			,@intTransactionTypeId = 18
			,@intItemId = @intItemId
			,@intSourceLotId = @intLotId
			,@intDestinationLotId = NULL
			,@dblQty = NULL
			,@intItemUOMId = NULL
			,@intOldItemId = NULL
			,@dtmOldExpiryDate = @dtmLotExpiryDate
			,@dtmNewExpiryDate = @dtmNewExpiryDate
			,@intOldLotStatusId = NULL
			,@intNewLotStatusId = NULL
			,@intUserId = @intUserId
			,@strNote = NULL
			,@strReason = NULL
			,@intLocationId = @intLocationId
			,@intInventoryAdjustmentId = @intInventoryAdjustmentId
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
