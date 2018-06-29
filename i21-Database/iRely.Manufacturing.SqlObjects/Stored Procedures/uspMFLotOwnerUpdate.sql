CREATE PROCEDURE uspMFLotOwnerUpdate @intLotId INT
	,@intNewItemOwnerId INT
	,@intUserId INT
	,@strParentLotNumber NVARCHAR(50)
	,@strVendorRefNo NVARCHAR(50)
	,@strWarehouseRefNo NVARCHAR(50)
	,@strContainerNo NVARCHAR(50)
	,@strNotes NVARCHAR(MAX)
	,@ysnUpdateOwnerOnly BIT = 0
	,@strReasonCode NVARCHAR(MAX) = NULL
	,@dtmDate DATETIME = NULL
	,@ysnBulkChange BIT = 0
	,@strNewLotAlias NVARCHAR(50) = NULL
	,@strNewVendorLotNumber NVARCHAR(50) = NULL
	,@dtmNewDueDate DATETime=NULL
AS
BEGIN TRY
	DECLARE @intItemId INT
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
		,@strOldVendorRefNo NVARCHAR(50)
		,@strOldWarehouseRefNo NVARCHAR(50)
		,@intOldLotItemOwnerId INT
		,@strReceiptNumber NVARCHAR(50)
		,@strOldContainerNo NVARCHAR(50)
		,@strOldNotes NVARCHAR(MAX)
		,@intTransactionCount INT
		,@strDescription NVARCHAR(MAX)
		,@strLotAlias NVARCHAR(50)
		,@strVendorLotNumber NVARCHAR(50)
		,@dtmOldDueDate datetime

	SELECT @intTransactionCount = @@TRANCOUNT

	SELECT @strDescription = Ltrim(isNULL(@strReasonCode, '') + ' ' + isNULL(@strNotes, ''))

	SELECT @strLotNumber = strLotNumber
		,@intItemId = intItemId
		,@intStorageLocationId = intStorageLocationId
		,@intSubLocationId = intSubLocationId
		,@intLocationId = intLocationId
		,@intLotStatusId = intLotStatusId
		,@dtmExpiryDate = dtmExpiryDate
		,@strLotAlias = strLotAlias
		,@strVendorLotNumber = strVendorLotNo
	FROM tblICLot
	WHERE intLotId = @intLotId

	IF @dtmDate IS NULL
		SELECT @dtmDate = GETDATE()

	SELECT @strReceiptNumber = strReceiptNumber
	FROM tblMFLotInventory
	WHERE intLotId = @intLotId

	SELECT @intOldLotItemOwnerId = intItemOwnerId
		,@intOldItemOwnerId = intItemOwnerId
	FROM tblICLot
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

	IF @intTransactionCount = 0
		BEGIN TRANSACTION

	IF NOT EXISTS (
			SELECT 1
			FROM tblMFLotInventory
			WHERE intLotId = @intLotId
			)
	BEGIN
		INSERT INTO tblMFLotInventory (
			intConcurrencyId
			,intLotId
			)
		SELECT 1
			,@intLotId

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
			,@strNote = @strNotes
			,@strReason = @strReasonCode
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
			,@strDescription = @strDescription
	END
	ELSE
	BEGIN
		IF @intNewItemOwnerId <> ISNULL(@intOldItemOwnerId, 0)
		BEGIN
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
				,@strNote = @strNotes
				,@strReason = @strReasonCode
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
				,@strDescription = @strDescription
		END
	END

	IF @ysnUpdateOwnerOnly = 0
	BEGIN
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

		-- Vendor & Warehouse ref no update
		SELECT @strOldVendorRefNo = strVendorRefNo
			,@strOldWarehouseRefNo = strWarehouseRefNo
			,@dtmOldDueDate=dtmDueDate
		FROM tblMFLotInventory
		WHERE intLotId = @intLotId

		IF ISNULL(@strOldVendorRefNo, '') <> ISNULL(@strVendorRefNo, '')
		BEGIN
			IF ISNULL(@strReceiptNumber, '') = ''
			BEGIN
				UPDATE tblMFLotInventory
				SET strVendorRefNo = @strVendorRefNo
				WHERE intLotId = @intLotId
			END
			ELSE
			BEGIN
				UPDATE tblMFLotInventory
				SET strVendorRefNo = @strVendorRefNo
				WHERE strReceiptNumber = @strReceiptNumber
			END
		END

		IF ISNULL(@strOldWarehouseRefNo, '') <> ISNULL(@strWarehouseRefNo, '')
		BEGIN
			IF ISNULL(@strReceiptNumber, '') = ''
			BEGIN
				UPDATE tblMFLotInventory
				SET strWarehouseRefNo = @strWarehouseRefNo
				WHERE intLotId = @intLotId
			END
			ELSE
			BEGIN
				UPDATE tblMFLotInventory
				SET strWarehouseRefNo = @strWarehouseRefNo
				WHERE strReceiptNumber = @strReceiptNumber
			END
		END

		-- Container No & Notes(Remarks) update
		SELECT @strOldNotes = strNotes
			,@strOldContainerNo = strContainerNo
		FROM tblICLot
		WHERE intLotId = @intLotId

		IF ISNULL(@strOldNotes, '') <> ISNULL(@strNotes, '')
		BEGIN
			UPDATE tblICLot
			SET strNotes = @strNotes
			WHERE intLotId = @intLotId
		END

		IF ISNULL(@strOldContainerNo, '') <> ISNULL(@strContainerNo, '')
		BEGIN
			UPDATE tblICLot
			SET strContainerNo = @strContainerNo
			WHERE intLotId = @intLotId
		END

		IF IsNULL(@strLotAlias, '') <> IsNULL(@strNewLotAlias, '')
		BEGIN
			EXEC dbo.uspMFSetLotAlias @intLotId = @intLotId
				,@strNewLotAlias = @strNewLotAlias
				,@intUserId = @intUserId
				,@strReasonCode = NULL
				,@strNotes = NULL
				,@dtmDate = NULL
				,@ysnBulkChange = 0
		END

		IF IsNULL(@strVendorLotNumber, '') <> IsNULL(@strNewVendorLotNumber, '')
		BEGIN
			EXEC dbo.uspMFSetVendorLotNumber @intLotId = @intLotId
				,@strNewVendorLotNumber = @strNewVendorLotNumber
				,@intUserId = @intUserId
				,@strReasonCode = NULL
				,@strNotes = NULL
				,@dtmDate = NULL
				,@ysnBulkChange = 0
		END
		IF IsNULL(@dtmOldDueDate, '1900-01-01') <> IsNULL(@dtmNewDueDate, '1900-01-01')
		BEGIN
			EXEC dbo.uspMFSetLotDueDate @intLotId = @intLotId
				,@dtmNewDueDate = @dtmNewDueDate
				,@intUserId = @intUserId
				,@strReasonCode = NULL
				,@strNotes = NULL
				,@dtmDate = NULL
				,@ysnBulkChange = 0
		END
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
