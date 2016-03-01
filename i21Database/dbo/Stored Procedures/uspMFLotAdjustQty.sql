CREATE PROCEDURE [uspMFLotAdjustQty]
 @intLotId INT,       
 @dblNewLotQty numeric(38,20),
 @intUserId INT ,
 @strReasonCode NVARCHAR(1000),
 @strNotes NVARCHAR(MAX)=NULL

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
	DECLARE @dblLotQty NUMERIC(38,20)
	DECLARE @dblAdjustByQuantity NUMERIC(38,20)
	DECLARE @dblNewUnitCost NUMERIC(38,20)
	DECLARE @intInventoryAdjustmentId INT
	DECLARE @TransactionCount INT
	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @intItemUOMId INT
	DECLARE @intShiftId INT
	DECLARE @dblWeightPerQty NUMERIC(38, 20)
	DECLARE @intWeightUOMId INT
	DECLARE @intItemStockUOMId INT
	DECLARE @dblWeight NUMERIC(38, 20)
	DECLARE @dblLotReservedQty NUMERIC(38, 20)
	
	SELECT @intItemId = intItemId, 
		   @intLocationId = intLocationId,
		   @intSubLocationId = intSubLocationId,
		   @intStorageLocationId = intStorageLocationId, 
		   @strLotNumber = strLotNumber,
		   @dblLotQty = dblQty,
		   @dblWeight=dblWeight,
		   @dblWeightPerQty = dblWeightPerQty,
		   @intWeightUOMId = intWeightUOMId
	FROM tblICLot WHERE intLotId = @intLotId
	
	SELECT @dblAdjustByQuantity = @dblNewLotQty - @dblWeight

	SELECT @intItemStockUOMId = intItemUOMId
	FROM dbo.tblICItemUOM
	WHERE intItemId = @intItemId
		AND ysnStockUnit = 1

	SELECT @dblLotReservedQty = ISNULL(SUM(dblQty),0) FROM tblICStockReservation WHERE intLotId = @intLotId 
	
	IF (@dblWeight + @dblAdjustByQuantity) < @dblLotReservedQty
	BEGIN
		RAISERROR('There is reservation against this lot. Cannot proceed.',16,1)
	END
		
	--IF @intItemStockUOMId = @intWeightUOMId
	--BEGIN
		SELECT @dblAdjustByQuantity = dbo.fnDivide(@dblAdjustByQuantity, @dblWeightPerQty)
	--END
	
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
	IF (
			SELECT dblWeight
			FROM dbo.tblICLot
			WHERE intLotId = @intLotId
			) < 0.01
	BEGIN
		--EXEC dbo.uspMFLotAdjustQty
		-- @intLotId =@intLotId,       
		-- @dblNewLotQty =0,
		-- @intUserId=@intUserId ,
		-- @strReasonCode ='Residue qty clean up',
		-- @strNotes ='Residue qty clean up'
		UPDATE tblICLot
		SET dblWeight = 0
			,dblQty = 0
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
