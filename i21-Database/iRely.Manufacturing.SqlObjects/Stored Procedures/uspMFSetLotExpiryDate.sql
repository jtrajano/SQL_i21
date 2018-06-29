CREATE PROCEDURE [uspMFSetLotExpiryDate] @intLotId INT
	,@dtmNewExpiryDate DATETIME
	,@intUserId INT
	,@strReasonCode NVARCHAR(MAX) = NULL
	,@strNotes NVARCHAR(MAX) = NULL
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
		,@dtmLotExpiryDate DATETIME
		,@dtmLotCreateDate DATETIME
		,@intInventoryAdjustmentId INT
		,@TransactionCount INT
		,@ErrMsg NVARCHAR(MAX)
		,@intParentLotId INT
		,@intChildLotCount INT
		,@intLotRecordId INT
		,@strDescription NVARCHAR(MAX)
		,@intTransactionCount INT
		,@ysnApplyTransactionByParentLot BIT

	SELECT @intTransactionCount = @@TRANCOUNT

	SELECT @strDescription = Ltrim(isNULL(@strReasonCode, '') + ' ' + isNULL(@strNotes, ''))

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

	SELECT @ysnApplyTransactionByParentLot = IsNULL(ysnApplyTransactionByParentLot, 0)
	FROM tblMFLotTransactionType
	WHERE intTransactionTypeId = 18 --Inventory Adjustment - Expiry Date Change

	IF @ysnApplyTransactionByParentLot = 1
	BEGIN
		SELECT @intChildLotCount = COUNT(*)
		FROM tblICLot
		WHERE intParentLotId = @intParentLotId
			AND intItemId = @intItemId
			AND intLocationId=@intLocationId
	END
	ELSE
	BEGIN
		SELECT @intChildLotCount = 0
	END

	IF @dtmDate IS NULL
		SELECT @dtmDate = GETDATE()

	SELECT @intSourceId = 1
		,@intSourceTransactionTypeId = 8

	IF ISNULL(@strLotNumber, '') = ''
	BEGIN
		RAISERROR (
				'Supplied lot is not available.'
				,11
				,1
				)
	END

	IF @dtmLotExpiryDate = @dtmNewExpiryDate
	BEGIN
		IF @ysnBulkChange = 1
		BEGIN
			RETURN
		END

		RAISERROR (
				'Old and new expiry date cannot be same.'
				,11
				,1
				)
	END

	IF @dtmLotCreateDate > @dtmNewExpiryDate
	BEGIN
		RAISERROR (
				'Expiry date should be later than the create date.'
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
				'This lot is being managed in warehouse. All transactions should be done in warehouse module. You can only change the lot status from inventory view.'
				,11
				,1
				)
	END

	IF @intTransactionCount = 0
		BEGIN TRANSACTION

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
		AND intItemId = @intItemId
			AND intLocationId=@intLocationId

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
				,@strDescription

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
				,@strNote = @strNotes
				,@strReason = @strReasonCode
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
			,@strDescription

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
			,@strNote = @strNotes
			,@strReason = @strReasonCode
			,@intLocationId = @intLocationId
			,@intInventoryAdjustmentId = @intInventoryAdjustmentId
	END

	IF @intTransactionCount = 0
		COMMIT TRANSACTION
END TRY

BEGIN CATCH
	IF XACT_STATE() != 0
		AND @TransactionCount = 0
		ROLLBACK TRANSACTION

	SET @ErrMsg = ERROR_MESSAGE()

	RAISERROR (
			@ErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH
