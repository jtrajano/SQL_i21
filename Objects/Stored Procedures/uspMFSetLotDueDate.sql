﻿CREATE PROCEDURE uspMFSetLotDueDate @intLotId INT
	,@dtmNewDueDate DATETIME
	,@intUserId INT
	,@strReasonCode NVARCHAR(MAX) = NULL
	,@strNotes NVARCHAR(MAX) = NULL
	,@dtmDate DATETIME = NULL
	,@ysnBulkChange BIT = 0
AS
BEGIN TRY
	DECLARE @intItemId INT
		,@intLocationId INT
		,@intInventoryAdjustmentId INT
		,@TransactionCount INT
		,@ErrMsg NVARCHAR(MAX)
		,@intParentLotId INT
		,@intChildLotCount INT
		,@intLotRecordId INT
		,@strDescription NVARCHAR(MAX)
		,@intTransactionCount INT
		,@ysnApplyTransactionByParentLot BIT
		,@dtmOldDueDate DATETIME

	SELECT @intTransactionCount = @@TRANCOUNT

	SELECT @strDescription = Ltrim(isNULL(@strReasonCode, '') + ' ' + isNULL(@strNotes, ''))

	DECLARE @tblLotsWithSameParentLot TABLE (
		intLotRecordId INT Identity(1, 1)
		,intLotId INT
		)

	SELECT @intItemId = intItemId
		,@intLocationId = intLocationId
		,@intParentLotId = intParentLotId
	FROM tblICLot
	WHERE intLotId = @intLotId

	SELECT @dtmOldDueDate = dtmDueDate
	FROM tblMFLotInventory
	WHERE intLotId = @intLotId

	SELECT @ysnApplyTransactionByParentLot = IsNULL(ysnApplyTransactionByParentLot, 0)
	FROM tblMFLotTransactionType
	WHERE intTransactionTypeId = 103 --Inventory Adjustment - Lot Due Date

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

	IF @dtmDate IS NULL
		SELECT @dtmDate = GETDATE()

	IF @dtmOldDueDate = @dtmNewDueDate
	BEGIN
		IF @ysnBulkChange = 1
		BEGIN
			RETURN
		END

		RAISERROR (
				'Old and new lot due date cannot be same.'
				,11
				,1
				)
	END

	IF @intTransactionCount = 0
		BEGIN TRANSACTION

	IF (@intChildLotCount > 1)
	BEGIN
		UPDATE LI
		SET dtmDueDate = @dtmNewDueDate
		FROM tblMFLotInventory LI
		JOIN tblICLot L ON L.intLotId = LI.intLotId
		WHERE L.intParentLotId = @intParentLotId
			AND L.intItemId = @intItemId
			AND L.intLocationId = @intLocationId

		INSERT INTO @tblLotsWithSameParentLot
		SELECT intLotId
		FROM tblICLot
		WHERE intParentLotId = @intParentLotId
			AND intItemId = @intItemId
			AND intLocationId = @intLocationId

		SELECT @intLotRecordId = MIN(intLotRecordId)
		FROM @tblLotsWithSameParentLot

		WHILE (@intLotRecordId IS NOT NULL)
		BEGIN
			SELECT @intLotId = intLotId
			FROM @tblLotsWithSameParentLot
			WHERE intLotRecordId = @intLotRecordId

			EXEC dbo.uspMFAdjustInventory @dtmDate = @dtmDate
				,@intTransactionTypeId = 103
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
				,@strNote = @strNotes
				,@strReason = @strReasonCode
				,@intLocationId = @intLocationId
				,@intInventoryAdjustmentId = @intInventoryAdjustmentId
				,@strOldLotAlias = NULL
				,@strNewLotAlias = NULL
				,@strOldVendorLotNumber = NULL
				,@strNewVendorLotNumber = NULL
				,@dtmOldDueDate = @dtmOldDueDate
				,@dtmNewDueDate = @dtmNewDueDate

			SELECT @intLotRecordId = MIN(intLotRecordId)
			FROM @tblLotsWithSameParentLot
			WHERE intLotRecordId > @intLotRecordId
		END
	END
	ELSE
	BEGIN
		UPDATE tblMFLotInventory
		SET dtmDueDate = @dtmNewDueDate
		WHERE intLotId = @intLotId

		EXEC dbo.uspMFAdjustInventory @dtmDate = @dtmDate
			,@intTransactionTypeId = 103
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
			,@strNote = @strNotes
			,@strReason = @strReasonCode
			,@intLocationId = @intLocationId
			,@intInventoryAdjustmentId = @intInventoryAdjustmentId
			,@strOldLotAlias = NULL
			,@strNewLotAlias = NULL
			,@strOldVendorLotNumber = NULL
			,@strNewVendorLotNumber = NULL
			,@dtmOldDueDate = @dtmOldDueDate
			,@dtmNewDueDate = @dtmNewDueDate
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

