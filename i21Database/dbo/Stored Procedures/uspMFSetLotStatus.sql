CREATE PROCEDURE [uspMFSetLotStatus]
	@intLotId INT
	,@intNewLotStatusId INT
	,@intUserId INT
	,@strNotes NVARCHAR(MAX) = NULL
AS
BEGIN TRY
	DECLARE @intItemId INT
	DECLARE @dtmDate DATETIME
	DECLARE @intLocationId INT
	DECLARE @intSubLocationId INT
	DECLARE @intStorageLocationId INT
	DECLARE @strLotNumber NVARCHAR(50)
	DECLARE @intSourceId INT
	DECLARE @intSourceTransactionTypeId INT
	DECLARE @intLotStatusId INT
	DECLARE @intInventoryAdjustmentId INT
	DECLARE @TransactionCount INT
	DECLARE @ErrMsg NVARCHAR(MAX)

	SELECT @intItemId = intItemId
		,@intLocationId = intLocationId
		,@intSubLocationId = intSubLocationId
		,@intStorageLocationId = intStorageLocationId
		,@strLotNumber = strLotNumber
		,@intLotStatusId = intLotStatusId
	FROM tblICLot
	WHERE intLotId = @intLotId

	SELECT @dtmDate = GETDATE()

	SELECT @intSourceId = 1
		,@intSourceTransactionTypeId = 8

	IF ISNULL(@strLotNumber, '') = ''
	BEGIN
		RAISERROR (
				51192
				,16
				,1
				)
	END

	IF @intLotStatusId = @intNewLotStatusId
	BEGIN
		RAISERROR (
				51181
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
			WHERE intEntityUserSecurityId = @intUserId

			IF NOT EXISTS (
					SELECT 1
					FROM tblMFUserRoleEventMap
					WHERE strEventName = 'LotStatusChange'
						AND intUserRoleID = @intUserRoleID
					)
			BEGIN
				RAISERROR (
						90021
						,16
						,1
						)
			END
		END
	END

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
