﻿CREATE PROCEDURE [uspMFLotAdjustQty] @intLotId INT
	,@dblNewLotQty NUMERIC(38, 20)
	,@intAdjustItemUOMId INT
	,@intUserId INT
	,@strReasonCode NVARCHAR(1000)
	,@blnValidateLotReservation BIT = 0
	,@strNotes NVARCHAR(MAX) = NULL
AS
BEGIN TRY
	DECLARE @intItemId INT
		,@dtmDate DATETIME
		,@intLocationId INT
		,@intSubLocationId INT
		,@intStorageLocationId INT
		,@strLotNumber NVARCHAR(50)
		,@intSourceId INT
		,@intSourceTransactionTypeId INT
		,@dblLotQty NUMERIC(38, 20)
		,@dblAdjustByQuantity NUMERIC(38, 20)
		,@dblNewUnitCost NUMERIC(38, 20)
		,@intInventoryAdjustmentId INT
		,@TransactionCount INT
		,@ErrMsg NVARCHAR(MAX)
		,@intItemUOMId INT
		,@intShiftId INT
		,@dblWeightPerQty NUMERIC(38, 20)
		,@intWeightUOMId INT
		,@intItemStockUOMId INT
		,@dblWeight NUMERIC(38, 20)
		,@dblLotReservedQty NUMERIC(38, 20)
		,@dblLotAvailableQty NUMERIC(38, 20)
		,@dblResidueWeight NUMERIC(38, 20)
		,@dblDefaultResidueQty NUMERIC(18, 6)

	SELECT @intItemId = intItemId
		,@intLocationId = intLocationId
		,@intSubLocationId = intSubLocationId
		,@intStorageLocationId = intStorageLocationId
		,@strLotNumber = strLotNumber
		,@dblLotQty = dblQty
		,@dblWeight = dblWeight
		,@dblWeightPerQty = dblWeightPerQty
		,@intWeightUOMId = intWeightUOMId
		,@intItemUOMId = intItemUOMId
	FROM tblICLot
	WHERE intLotId = @intLotId

	SELECT @dblLotAvailableQty = (
			CASE 
				WHEN ISNULL(@dblWeight, 0) = 0
					THEN ISNULL(@dblLotQty, 0)
				ELSE ISNULL(@dblWeight, 0)
				END
			)

	IF @intItemUOMId = @intAdjustItemUOMId
		AND @intWeightUOMId IS NOT NULL
	BEGIN
		SELECT @dblAdjustByQuantity = @dblNewLotQty - @dblLotQty
	END
	ELSE
	BEGIN
		SELECT @dblAdjustByQuantity = @dblNewLotQty - @dblLotAvailableQty
	END

	SELECT @intItemStockUOMId = intItemUOMId
	FROM dbo.tblICItemUOM
	WHERE intItemId = @intItemId
		AND ysnStockUnit = 1

	SELECT @dblLotReservedQty = SUM(dbo.fnMFConvertQuantityToTargetItemUOM(intItemUOMId, ISNULL(@intWeightUOMId, @intItemUOMId), ISNULL(dblQty, 0)))
	FROM tblICStockReservation
	WHERE intLotId = @intLotId
		AND ISNULL(ysnPosted, 0) = 0

	IF @blnValidateLotReservation = 1
	BEGIN
		IF (
				@dblLotAvailableQty + (
					CASE 
						WHEN @intItemUOMId = @intAdjustItemUOMId
							AND @intWeightUOMId IS NOT NULL
							THEN @dblAdjustByQuantity * @dblWeightPerQty
						ELSE @dblAdjustByQuantity
						END
					)
				) < @dblLotReservedQty
		BEGIN
			RAISERROR (
					'There is reservation against this lot. Cannot proceed.'
					,16
					,1
					)
		END
	END

	IF @dblNewLotQty = 0
	BEGIN
		SELECT @dblAdjustByQuantity = - @dblLotQty

		SELECT @intAdjustItemUOMId = @intItemUOMId
	END

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

	IF (Case When @intItemUOMId = @intAdjustItemUOMId
		AND @intWeightUOMId IS NOT NULL Then  @dblLotQty Else @dblLotAvailableQty End) = @dblNewLotQty
		AND @blnValidateLotReservation = 0
	BEGIN
		RETURN
	END

	IF (Case When @intItemUOMId = @intAdjustItemUOMId
		AND @intWeightUOMId IS NOT NULL Then  @dblLotQty Else @dblLotAvailableQty End) = @dblNewLotQty
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

	BEGIN TRANSACTION

	EXEC uspICInventoryAdjustment_CreatePostQtyChange @intItemId
		,@dtmDate
		,@intLocationId
		,@intSubLocationId
		,@intStorageLocationId
		,@strLotNumber
		,@dblAdjustByQuantity
		,@dblNewUnitCost
		,@intAdjustItemUOMId
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

	SELECT @dblDefaultResidueQty = dblDefaultResidueQty
	FROM dbo.tblMFCompanyPreference

	IF (
			(
				SELECT dblWeight
				FROM dbo.tblICLot
				WHERE intLotId = @intLotId
				) < @dblDefaultResidueQty
			AND (
				SELECT dblWeight
				FROM dbo.tblICLot
				WHERE intLotId = @intLotId
				) > 0
			)
		OR (
			(
				SELECT dblQty
				FROM dbo.tblICLot
				WHERE intLotId = @intLotId
				) < @dblDefaultResidueQty
			AND (
				SELECT dblQty
				FROM dbo.tblICLot
				WHERE intLotId = @intLotId
				) > 0
			)
		AND @dblDefaultResidueQty IS NOT NULL
	BEGIN
		SELECT @dblResidueWeight = CASE 
				WHEN intWeightUOMId IS NULL
					THEN dblQty
				ELSE dblWeight
				END
			,@intAdjustItemUOMId = CASE 
				WHEN intWeightUOMId IS NULL
					THEN intItemUOMId
				ELSE intWeightUOMId
				END
		FROM tblICLot
		WHERE intLotId = @intLotId

		SELECT @dblAdjustByQuantity = - @dblResidueWeight

		EXEC uspICInventoryAdjustment_CreatePostQtyChange @intItemId
			,@dtmDate
			,@intLocationId
			,@intSubLocationId
			,@intStorageLocationId
			,@strLotNumber
			,@dblAdjustByQuantity
			,@dblNewUnitCost
			,@intAdjustItemUOMId
			,@intSourceId
			,@intSourceTransactionTypeId
			,@intUserId
			,@intInventoryAdjustmentId OUTPUT
	END

	COMMIT TRANSACTION
END TRY

BEGIN CATCH
	IF XACT_STATE() != 0
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
