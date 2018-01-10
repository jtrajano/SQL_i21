CREATE PROCEDURE uspMFLotItemChange @intLotId INT
	,@intNewItemId INT
	,@intUserId INT
	,@strNewLotNumber NVARCHAR(100) = NULL OUTPUT
	,@dtmDate DATETIME
	,@strReasonCode NVARCHAR(MAX) = NULL
	,@strNotes NVARCHAR(MAX) = NULL
	,@ysnBulkChange BIT = 0
AS
BEGIN TRY
	DECLARE @intItemId INT
		,@intLocationId INT
		,@intStorageLocationId INT
		,@intSubLocationId INT
		,@strLotNumber NVARCHAR(50)
		,@intSourceId INT
		,@intSourceTransactionTypeId INT
		,@intLotStatusId INT
		,@intItemUOMId INT
		,@dblLotWeightPerUnit NUMERIC(38, 20)
		,@dblLotQty NUMERIC(38, 20)
		,@intInventoryAdjustmentId INT
		,@intTransactionCount INT
		,@strErrMsg NVARCHAR(MAX)
		,@intAdjustItemUOMId INT
		,@intUnitMeasureId INT
		,@strUnitMeasure NVARCHAR(50)
		,@strItemNo NVARCHAR(50)
		,@intFromItemCategory INT
		,@intToItemCategory INT
		,@strFromItemCategory NVARCHAR(50)
		,@strToItemCategory NVARCHAR(50)
		,@intNewLotId INT
		,@dblAdjustByQuantity NUMERIC(16, 8)
		,@dblLotReservedQty NUMERIC(16, 8)
		,@ysnGenerateNewParentLotOnChangeItem BIT
		,@intParentLotId INT
		,@strDescription NVARCHAR(MAX)

	SELECT @intTransactionCount = @@TRANCOUNT

	SELECT @strDescription = Ltrim(isNULL(@strReasonCode, '') + ' ' + isNULL(@strNotes, ''))

	SELECT @intItemId = intItemId
		,@intLocationId = intLocationId
		,@intSubLocationId = intSubLocationId
		,@intStorageLocationId = intStorageLocationId
		,@strLotNumber = strLotNumber
		,@intItemUOMId = intItemUOMId
		,@dblAdjustByQuantity = - dblQty
		,@intAdjustItemUOMId = intItemUOMId
		,@intParentLotId = intParentLotId
	FROM tblICLot
	WHERE intLotId = @intLotId

	SELECT @ysnGenerateNewParentLotOnChangeItem = ysnGenerateNewParentLotOnChangeItem
	FROM tblMFCompanyPreference

	IF @ysnGenerateNewParentLotOnChangeItem IS NULL
		SELECT @ysnGenerateNewParentLotOnChangeItem = 1

	SELECT @dblLotReservedQty = dblQty
	FROM tblICStockReservation
	WHERE intLotId = @intLotId
		AND ISNULL(ysnPosted, 0) = 0

	IF (ISNULL(@dblLotReservedQty, 0) > 0)
	BEGIN
		RAISERROR (
				'There is reservation against this lot. Cannot proceed.'
				,16
				,1
				)
	END

	SELECT @strFromItemCategory = C.strCategoryCode
		,@intFromItemCategory = C.intCategoryId
	FROM dbo.tblICItem I
	JOIN tblICCategory C ON C.intCategoryId = I.intCategoryId
	WHERE I.intItemId = @intItemId

	SELECT @strToItemCategory = C.strCategoryCode
		,@intToItemCategory = C.intCategoryId
	FROM dbo.tblICItem I
	JOIN tblICCategory C ON C.intCategoryId = I.intCategoryId
	WHERE I.intItemId = @intNewItemId

	IF @intItemId = @intNewItemId
	BEGIN
		IF @ysnBulkChange = 1
		BEGIN
			SELECT @strNewLotNumber = ''

			RETURN
		END
	END

	IF NOT EXISTS (
			SELECT 1
			FROM tblMFItemChangeMap
			WHERE intFromItemCategoryId = @intFromItemCategory
				AND intToItemCategoryId = @intToItemCategory
			)
		AND @intFromItemCategory <> @intToItemCategory
	BEGIN
		SET @strErrMsg = 'Item change not allowed from category ' + @strFromItemCategory + ' to ' + @strToItemCategory + '.'

		RAISERROR (
				@strErrMsg
				,16
				,1
				)
	END

	SELECT @intUnitMeasureId = intUnitMeasureId
	FROM tblICItemUOM
	WHERE intItemUOMId = @intItemUOMId

	IF NOT EXISTS (
			SELECT *
			FROM dbo.tblICItemUOM
			WHERE intItemId = @intNewItemId
				AND intUnitMeasureId = @intUnitMeasureId
			)
	BEGIN
		SELECT @strUnitMeasure = strUnitMeasure
		FROM dbo.tblICUnitMeasure
		WHERE intUnitMeasureId = @intUnitMeasureId

		SELECT @strItemNo = strItemNo
		FROM dbo.tblICItem
		WHERE intItemId = @intNewItemId

		RAISERROR (
				'Source Lot''s UOM %s is not configured as one of the UOM in destination item %s.'
				,11
				,1
				,@strUnitMeasure
				,@strItemNo
				)
	END

	IF @dtmDate = NULL
		SELECT @dtmDate = GETDATE()

	SELECT @intSourceId = 1
		,@intSourceTransactionTypeId = 8

	IF @intTransactionCount = 0
		BEGIN TRANSACTION

	EXEC uspICInventoryAdjustment_CreatePostItemChange @intItemId = @intItemId
		,@dtmDate = @dtmDate
		,@intLocationId = @intLocationId
		,@intSubLocationId = @intSubLocationId
		,@intStorageLocationId = @intStorageLocationId
		,@strLotNumber = @strLotNumber
		,@dblAdjustByQuantity = @dblAdjustByQuantity
		,@intNewItemId = @intNewItemId
		,@intNewSubLocationId = @intSubLocationId
		,@intNewStorageLocationId = @intStorageLocationId
		,@intItemUOMId = @intAdjustItemUOMId
		,@intSourceId = @intSourceId
		,@intSourceTransactionTypeId = @intSourceTransactionTypeId
		,@intEntityUserSecurityId = @intUserId
		,@intInventoryAdjustmentId = @intInventoryAdjustmentId OUTPUT
		,@strDescription = @strDescription

	SELECT TOP 1 @strNewLotNumber = strLotNumber
		,@intNewLotId = intLotId
	FROM tblICLot
	WHERE intSplitFromLotId = @intLotId
	ORDER BY intLotId DESC

	EXEC dbo.uspMFAdjustInventory @dtmDate = @dtmDate
		,@intTransactionTypeId = 15
		,@intItemId = @intNewItemId
		,@intSourceLotId = @intLotId
		,@intDestinationLotId = @intNewLotId
		,@dblQty = @dblAdjustByQuantity
		,@intItemUOMId = @intAdjustItemUOMId
		,@intOldItemId = @intItemId
		,@dtmOldExpiryDate = NULL
		,@dtmNewExpiryDate = NULL
		,@intOldLotStatusId = NULL
		,@intNewLotStatusId = NULL
		,@intUserId = @intUserId
		,@strNote = @strNotes
		,@strReason = @strReasonCode
		,@intLocationId = @intLocationId
		,@intInventoryAdjustmentId = @intInventoryAdjustmentId

	IF @ysnGenerateNewParentLotOnChangeItem = 0
	BEGIN
		UPDATE tblICLot
		SET intParentLotId = @intParentLotId
		WHERE intLotId = @intNewLotId
	END

	IF @intTransactionCount = 0
		COMMIT TRANSACTION

	SELECT @strNewLotNumber AS strNewLotNumber
END TRY

BEGIN CATCH
	IF XACT_STATE() != 0
		AND @intTransactionCount = 0
		ROLLBACK TRANSACTION

	SET @strErrMsg = ERROR_MESSAGE()

	RAISERROR (
			@strErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH
