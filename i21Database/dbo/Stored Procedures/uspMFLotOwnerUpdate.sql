CREATE PROCEDURE uspMFLotOwnerUpdate @intLotId INT
	,@intNewItemOwnerId INT
	,@intUserId INT
	,@strParentLotNumber NVARCHAR(50)
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
		,@intLotStatusId INT
		,@dtmExpiryDate DATETIME
		,@intParentLotId INT
		,@strOldParentLotNumber NVARCHAR(50)

	SELECT @strLotNumber = strLotNumber
		,@intItemId = intItemId
		,@intStorageLocationId = intStorageLocationId
		,@intSubLocationId = intSubLocationId
		,@intLocationId = intLocationId
		,@dtmDate = GETDATE()
		,@intLotStatusId = intLotStatusId
		,@dtmExpiryDate = dtmExpiryDate
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
				'Supplied lot is not available.'
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
		END
	END

	-- Parent Lot No. Update
	SELECT @strOldParentLotNumber = PL.strParentLotNumber
	FROM tblICLot L
	JOIN tblICParentLot PL ON PL.intParentLotId = L.intParentLotId
	WHERE L.intLotId = @intLotId

	IF ISNULL(@strOldParentLotNumber, '') <> ISNULL(@strParentLotNumber, '')
	BEGIN
		EXEC uspMFCreateUpdateParentLotNumber @strParentLotNumber = @strParentLotNumber
			,@strParentLotAlias = NULL
			,@intItemId = @intItemId
			,@dtmExpiryDate = @dtmExpiryDate
			,@intLotStatusId = @intLotStatusId
			,@intEntityUserSecurityId = @intUserId
			,@intLotId = @intLotId
			,@intParentLotId = @intParentLotId OUTPUT
			,@intSubLocationId = @intSubLocationId
			,@intLocationId = @intLocationId
			,@dtmDate = NULL
			,@intShiftId = NULL
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
