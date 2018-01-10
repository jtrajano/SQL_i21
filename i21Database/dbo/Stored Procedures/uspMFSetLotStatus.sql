CREATE PROCEDURE [uspMFSetLotStatus] @intLotId INT
	,@intNewLotStatusId INT
	,@intUserId INT
	,@strNotes NVARCHAR(MAX) = NULL
	,@strReasonCode NVARCHAR(MAX) = NULL
	,@dtmDate DATETIME = NULL
	,@ysnBulkChange BIT = 0
AS
BEGIN TRY
	DECLARE @intItemId INT
		,@intLocationId INT
		,@intSubLocationId INT
		,@intStorageLocationId INT
		,@strLotNumber NVARCHAR(50)
		,@intSourceId INT
		,@intSourceTransactionTypeId INT
		,@intLotStatusId INT
		,@intInventoryAdjustmentId INT
		,@ErrMsg NVARCHAR(MAX)
		,@strDescription NVARCHAR(MAX)
		,@intTransactionCount INT
		,@intParentLotId INT
		,@intChildLotCount INT
		,@intLotRecordId INT
		,@ysnApplyTransactionByParentLot BIT
	DECLARE @tblLotsWithSameParentLot TABLE (
		intLotRecordId INT Identity(1, 1)
		,strLotNumber NVARCHAR(100)
		,intLotId INT
		,intParentLotId INT
		,intSubLocationId INT
		,intStorageLocationId INT
		,intLocationId INT
		)

	SELECT @intTransactionCount = @@TRANCOUNT

	SELECT @strDescription = Ltrim(isNULL(@strReasonCode, '') + ' ' + isNULL(@strNotes, ''))

	SELECT @intItemId = intItemId
		,@intLocationId = intLocationId
		,@strLotNumber = strLotNumber
		,@intLotStatusId = intLotStatusId
		,@intParentLotId = intParentLotId
	FROM tblICLot
	WHERE intLotId = @intLotId

	IF @dtmDate IS NULL
		SELECT @dtmDate = GETDATE()

	SELECT @intSourceId = 1
		,@intSourceTransactionTypeId = 8

	IF ISNULL(@strLotNumber, '') = ''
	BEGIN
		RAISERROR (
				'Supplied lot is not available.'
				,16
				,1
				)
	END

	IF @intLotStatusId = @intNewLotStatusId
	BEGIN
		IF @ysnBulkChange = 1
		BEGIN
			RETURN
		END

		RAISERROR (
				'Old and new lot status cannot be same.'
				,16
				,1
				)
	END

	-- When user change status to Active, we have to check for the permission
	IF @intNewLotStatusId = 1 -- Active
	BEGIN
		DECLARE @intLotStatusChangeRoleCount INT

		SELECT @intLotStatusChangeRoleCount = COUNT(*)
		FROM tblMFUserRoleEventMap
		WHERE strEventName = 'LotStatusChange'

		-- If no record, will allow to change the lot status
		IF @intLotStatusChangeRoleCount > 0
		BEGIN
			DECLARE @intUserRoleID INT

			SELECT @intUserRoleID = intUserRoleID
			FROM tblSMUserSecurity
			WHERE [intEntityId] = @intUserId

			IF NOT EXISTS (
					SELECT 1
					FROM tblMFUserRoleEventMap
					WHERE strEventName = 'LotStatusChange'
						AND intUserRoleID = @intUserRoleID
					)
			BEGIN
				RAISERROR (
						'You do not have enough permission(s) to change the lot status to Active. Please contact your local system administrator.'
						,16
						,1
						)
			END
		END
	END

	SELECT @ysnApplyTransactionByParentLot = IsNULL(ysnApplyTransactionByParentLot, 0)
	FROM tblMFLotTransactionType
	WHERE intTransactionTypeId = 16 --Inventory Adjustment - Lot Status Change

	IF @ysnApplyTransactionByParentLot = 1
	BEGIN
		SELECT @intChildLotCount = COUNT(*)
		FROM tblICLot
		WHERE intParentLotId = @intParentLotId
			AND intItemId = @intItemId
			AND intLocationId = @intLocationId
	END
	ELSE
	BEGIN
		SELECT @intChildLotCount = 0
	END

	IF @intChildLotCount = 0
	BEGIN
		INSERT INTO @tblLotsWithSameParentLot
		SELECT strLotNumber
			,intLotId
			,intParentLotId
			,intSubLocationId
			,intStorageLocationId
			,intLocationId
		FROM tblICLot
		WHERE intLotId = @intLotId
	END
	ELSE
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
			AND intItemId = @intItemId
			AND intLocationId = @intLocationId
	END

	IF @intTransactionCount = 0
		BEGIN TRANSACTION

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

		EXEC uspICInventoryAdjustment_CreatePostLotStatusChange @intItemId
			,@dtmDate
			,@intLocationId
			,@intSubLocationId
			,@intStorageLocationId
			,@strLotNumber
			,@intNewLotStatusId
			,@intSourceId
			,@intSourceTransactionTypeId
			,@intUserId
			,@intInventoryAdjustmentId OUTPUT
			,@strDescription

		EXEC dbo.uspMFAdjustInventory @dtmDate = @dtmDate
			,@intTransactionTypeId = 16
			,@intItemId = @intItemId
			,@intSourceLotId = @intLotId
			,@intDestinationLotId = NULL
			,@dblQty = NULL
			,@intItemUOMId = NULL
			,@intOldItemId = NULL
			,@dtmOldExpiryDate = NULL
			,@dtmNewExpiryDate = NULL
			,@intOldLotStatusId = @intLotStatusId
			,@intNewLotStatusId = @intNewLotStatusId
			,@intUserId = @intUserId
			,@strNote = @strNotes
			,@strReason = @strReasonCode
			,@intLocationId = @intLocationId
			,@intInventoryAdjustmentId = @intInventoryAdjustmentId

		SELECT @intLotRecordId = MIN(intLotRecordId)
		FROM @tblLotsWithSameParentLot
		WHERE intLotRecordId > @intLotRecordId
	END

	IF @intTransactionCount = 0
		COMMIT TRANSACTION
END TRY

BEGIN CATCH
	IF XACT_STATE() != 0
		AND @intTransactionCount = 0
		ROLLBACK TRANSACTION

	SET @ErrMsg = ERROR_MESSAGE()

	RAISERROR (
			@ErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH
