CREATE PROCEDURE [uspMFLotAdjustQty] @intLotId INT
	,@dblNewLotQty NUMERIC(18, 6)
	,@intUserId INT
	,@strReasonCode NVARCHAR(1000)
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
	DECLARE @dblLotQty NUMERIC(18, 6)
	DECLARE @dblAdjustByQuantity NUMERIC(18, 6)
	DECLARE @dblNewUnitCost NUMERIC(18, 6)
	DECLARE @intInventoryAdjustmentId INT
	DECLARE @TransactionCount INT
	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @intItemUOMId INT
	DECLARE @intShiftId INT

	SELECT @intItemId = intItemId
		,@intLocationId = intLocationId
		,@intSubLocationId = intSubLocationId
		,@intStorageLocationId = intStorageLocationId
		,@strLotNumber = strLotNumber
		,@dblLotQty = dblQty
		,@intItemUOMId = intItemUOMId
	FROM tblICLot
	WHERE intLotId = @intLotId

	SELECT @dblAdjustByQuantity = @dblNewLotQty - @dblLotQty

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

	IF @dblLotQty = @dblNewLotQty
	BEGIN
		RAISERROR (
				51190
				,11
				,1
				)
	END

	IF @strReasonCode IS NULL
		OR @strReasonCode = ''
	BEGIN
		RAISERROR (
				51191
				,16
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

	EXEC uspICInventoryAdjustment_CreatePostQtyChange @intItemId
		,@dtmDate
		,@intLocationId
		,@intSubLocationId
		,@intStorageLocationId
		,@strLotNumber
		,@dblAdjustByQuantity
		,@dblNewUnitCost
		,@intSourceId
		,@intSourceTransactionTypeId
		,@intUserId
		,@intInventoryAdjustmentId OUTPUT

	IF EXISTS (
			SELECT TOP 1 *
			FROM tblMFWorkOrderProducedLot
			WHERE intLotId = @intLotId
			)
	BEGIN
		SELECT @intShiftId = intShiftId
		FROM dbo.tblMFShift
		WHERE intLocationId = @intLocationId
			AND Convert(CHAR, GetDate(), 108) BETWEEN dtmShiftStartTime
				AND dtmShiftEndTime + intEndOffset

		INSERT INTO dbo.tblMFWorkOrderProducedLotTransaction (
			intWorkOrderId
			,intLotId
			,dblQuantity
			,intItemUOMId
			,intItemId
			,intTransactionId
			,intTransactionTypeId
			,strTransactionType
			,dtmTransactionDate
			,intProcessId
			,intShiftId
			)
		SELECT TOP 1 WP.intWorkOrderId
			,WP.intLotId
			,@dblNewLotQty - @dblLotQty
			,@intItemUOMId
			,WP.intItemId
			,@intInventoryAdjustmentId
			,10
			,'Queued Qty Adj'
			,GetDate()
			,intManufacturingProcessId
			,@intShiftId
		FROM dbo.tblMFWorkOrderProducedLot WP
		JOIN dbo.tblMFWorkOrder W ON W.intWorkOrderId = WP.intWorkOrderId
		WHERE intLotId = @intLotId
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
