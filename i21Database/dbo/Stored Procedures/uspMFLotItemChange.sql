CREATE PROCEDURE uspMFLotItemChange @intLotId INT
	,@intNewItemId INT
	,@intUserId INT
	,@strNewLotNumber NVARCHAR(100) = NULL OUTPUT
AS
BEGIN TRY
	DECLARE @intItemId INT
		,@dtmDate DATETIME
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
		,@intNewLotId INT
		,@dblAdjustByQuantity NUMERIC(16, 8)
		,@dblLotReservedQty NUMERIC(16, 8)

	SELECT @intItemId = intItemId
		,@intLocationId = intLocationId
		,@intSubLocationId = intSubLocationId
		,@intStorageLocationId = intStorageLocationId
		,@strLotNumber = strLotNumber
		,@intItemUOMId = intItemUOMId
		,@dblAdjustByQuantity = - dblQty
		,@intAdjustItemUOMId = intItemUOMId
	FROM tblICLot
	WHERE intLotId = @intLotId

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
				90016
				,11
				,1
				,@strUnitMeasure
				,@strItemNo
				)
	END

	SELECT @dtmDate = GETDATE()
		,@intSourceId = 1
		,@intSourceTransactionTypeId = 8

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
		,@strNote = NULL
		,@strReason = NULL
		,@intLocationId = @intLocationId
		,@intInventoryAdjustmentId = @intInventoryAdjustmentId

	SELECT @strNewLotNumber AS strNewLotNumber
END TRY

BEGIN CATCH
	IF XACT_STATE() != 0
		AND @intTransactionCount = 0
		AND @@TRANCOUNT > 0
		ROLLBACK TRANSACTION

	SET @strErrMsg = ERROR_MESSAGE()

	RAISERROR (
			@strErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH
