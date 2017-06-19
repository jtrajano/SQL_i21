CREATE PROCEDURE [uspWHLotMove] @intLotId INT
	,@intNewSubLocationId INT
	,@intNewStorageLocationId INT
	,@dblMoveQty NUMERIC(38, 20)
	,@intUserId INT
	,@blnValidateLotReservation BIT = 0
	,@blnInventoryMove BIT = 0
	,@intItemUOMId INT = NULL
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
		,@intLotStatusId INT
		,@intNewLocationId INT
		,@strNewLotNumber NVARCHAR(50)
		,@intInventoryAdjustmentId INT
		,@TransactionCount INT
		,@ErrMsg NVARCHAR(MAX)
		,@dblWeightPerQty NUMERIC(38, 20)
		,@intWeightUOMId INT
		,@intItemStockUOMId INT
		,@dblLotReservedQty NUMERIC(38, 20)
		,@dblWeight NUMERIC(38, 20)
		,@dblLotQty NUMERIC(38, 20)
		,@dblLotAvailableQty NUMERIC(38, 20)
		,@intNewLotId INT
		,@blnIsPartialMove BIT
		,@strStorageLocationName NVARCHAR(50)
		,@strItemNumber NVARCHAR(50)
		,@strUnitMeasure NVARCHAR(50)
		,@dblOldQty NUMERIC(38, 20)
		,@dblSourceOldQty NUMERIC(38, 20)
		,@intLotItemUOMId INT
		,@intCategoryId INT

	SELECT @intItemId = intItemId
		,@intLocationId = intLocationId
		,@intSubLocationId = intSubLocationId
		,@intStorageLocationId = intStorageLocationId
		,@strLotNumber = strLotNumber
		,@dblLotQty = dblQty
		,@intLotStatusId = intLotStatusId
		,@intNewLocationId = intLocationId
		,@dblWeightPerQty = dblWeightPerQty
		,@intWeightUOMId = intWeightUOMId
		,@dblWeight = dblWeight
		,@intItemUOMId = CASE 
			WHEN @intItemUOMId IS NULL
				THEN intItemUOMId
			ELSE @intItemUOMId
			END
		,@intLotItemUOMId = intItemUOMId
	FROM tblICLot
	WHERE intLotId = @intLotId

	SELECT @strStorageLocationName = strName
	FROM tblICStorageLocation
	WHERE intStorageLocationId = @intStorageLocationId

	SELECT @strItemNumber = strItemNo
		,@intCategoryId=intCategoryId
	FROM tblICItem
	WHERE intItemId = @intItemId

	SELECT @strUnitMeasure = UM.strUnitMeasure
	FROM tblICItemUOM U
	JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = U.intUnitMeasureId
	WHERE U.intItemUOMId = @intItemUOMId

	SELECT @intItemStockUOMId = intItemUOMId
	FROM dbo.tblICItemUOM
	WHERE intItemId = @intItemId
		AND ysnStockUnit = 1

	SELECT @dblLotAvailableQty = (
			CASE 
				WHEN ISNULL(@dblWeight, 0) = 0
					THEN ISNULL(@dblLotQty, 0)
				ELSE ISNULL(@dblWeight, 0)
				END
			)

	IF Convert(decimal(24,3),(
			CASE 
				WHEN @intLotItemUOMId = @intItemUOMId
					AND @intWeightUOMId IS NOT NULL
					THEN @dblMoveQty * @dblWeightPerQty
				ELSE @dblMoveQty
				END
			)) > Convert(decimal(24,3),@dblLotAvailableQty)
	BEGIN
		SET @ErrMsg = 'Move qty ' + LTRIM(CONVERT(NUMERIC(38, 4), @dblMoveQty)) + ' ' + @strUnitMeasure + ' is not available for lot ''' + @strLotNumber + ''' having item ''' + @strItemNumber + ''' in location ''' + @strStorageLocationName + '''.'

		RAISERROR (
				@ErrMsg
				,11
				,1
				)
	END

	if Convert(decimal(24,3),(
			CASE 
				WHEN @intLotItemUOMId = @intItemUOMId
					AND @intWeightUOMId IS NOT NULL
					THEN @dblMoveQty * @dblWeightPerQty
				ELSE @dblMoveQty
				END
			)) = Convert(decimal(24,3),@dblLotAvailableQty)
	Begin
		Select @dblMoveQty=Convert(decimal(24,3),@dblMoveQty)
	End

	SELECT @strNewLotNumber = @strLotNumber

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

	IF (@dblMoveQty = @dblLotQty)
	BEGIN
		SET @blnIsPartialMove = 0
	END
	ELSE
	BEGIN
		SET @blnIsPartialMove = 1
	END

	IF @intNewStorageLocationId = @intStorageLocationId
	BEGIN
		RAISERROR (
				'The Lot already exists in the selected destination storage location. Please select a different destination storage location.'
				,11
				,1
				)
	END

	SELECT @dblLotReservedQty = SUM(dbo.fnMFConvertQuantityToTargetItemUOM(intItemUOMId, ISNULL(@intWeightUOMId, @intItemUOMId), ISNULL(dblQty, 0)))
	FROM tblICStockReservation
	WHERE intLotId = @intLotId
		AND ISNULL(ysnPosted, 0) = 0

	IF @blnIsPartialMove = 1
	BEGIN
		IF @blnValidateLotReservation = 1
		BEGIN
			IF (
					@dblLotAvailableQty + (
						(
							CASE 
								WHEN @intLotItemUOMId = @intItemUOMId
									AND @intWeightUOMId IS NOT NULL
									THEN - @dblMoveQty * @dblWeightPerQty
								ELSE - @dblMoveQty
								END
							)
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
	END

	IF EXISTS (
			SELECT *
			FROM tblICStorageLocationCategory
			WHERE intStorageLocationId = @intNewStorageLocationId
			)
	BEGIN
		IF NOT EXISTS (
				SELECT *
				FROM tblICStorageLocationCategory
				WHERE intStorageLocationId = @intNewStorageLocationId
					AND intCategoryId = @intCategoryId
				)
		BEGIN
			RAISERROR (
					'The selected item is not allowed in the destination location.'
					,11
					,1
					)
		END
	END


	BEGIN TRANSACTION

	EXEC uspICInventoryAdjustment_CreatePostLotMove @intItemId
		,@dtmDate
		,@intLocationId
		,@intSubLocationId
		,@intStorageLocationId
		,@strLotNumber
		,@intNewLocationId
		,@intNewSubLocationId
		,@intNewStorageLocationId
		,@strNewLotNumber
		,@dblMoveQty
		,@intItemUOMId
		,@intSourceId
		,@intSourceTransactionTypeId
		,@intUserId
		,@intInventoryAdjustmentId OUTPUT

	SELECT @intNewLotId = intLotId
	FROM dbo.tblICLot
	WHERE strLotNumber = @strNewLotNumber
		AND intStorageLocationId = @intNewStorageLocationId

	EXEC dbo.uspMFAdjustInventory @dtmDate = @dtmDate
		,@intTransactionTypeId = 20
		,@intItemId = @intItemId
		,@intSourceLotId = @intLotId
		,@intDestinationLotId = @intNewLotId
		,@dblQty = @dblMoveQty
		,@intItemUOMId = @intItemUOMId
		,@intOldItemId = NULL
		,@dtmOldExpiryDate = NULL
		,@dtmNewExpiryDate = NULL
		,@intOldLotStatusId = NULL
		,@intNewLotStatusId = NULL
		,@intUserId = @intUserId
		,@strNote = NULL
		,@strReason = NULL
		,@intLocationId = @intLocationId
		,@intInventoryAdjustmentId = @intInventoryAdjustmentId

	IF EXISTS (
			SELECT *
			FROM dbo.tblMFWorkOrderProducedLot
			WHERE intLotId = @intLotId
				AND dblPhysicalCount = @dblMoveQty
			)
	BEGIN
		UPDATE dbo.tblMFWorkOrderProducedLot
		SET intLotId = @intNewLotId
		WHERE intLotId = @intLotId
	END

	IF @blnIsPartialMove = 0
		AND @blnInventoryMove = 1
	BEGIN
		IF EXISTS (
				SELECT *
				FROM dbo.tblMFWorkOrderConsumedLot
				WHERE intLotId = @intLotId
				)
		BEGIN
			UPDATE WC
			SET intLotId = @intNewLotId
			FROM tblMFWorkOrderConsumedLot WC
			JOIN tblMFWorkOrder W ON W.intWorkOrderId = WC.intWorkOrderId
				AND W.intStatusId NOT IN (
					12
					,13
					)
			WHERE intLotId = @intLotId
		END

		IF EXISTS (
				SELECT *
				FROM dbo.tblICStockReservation
				WHERE intLotId = @intLotId
				)
		BEGIN
			UPDATE dbo.tblICStockReservation
			SET intLotId = @intNewLotId
				,intStorageLocationId = @intNewStorageLocationId
				,intSubLocationId = @intNewSubLocationId
			WHERE intLotId = @intLotId
		END

		IF EXISTS (
				SELECT *
				FROM dbo.tblMFPickListDetail
				WHERE intLotId = @intLotId
					AND intStageLotId = @intLotId
				)
		BEGIN
			UPDATE dbo.tblMFPickListDetail
			SET intLotId = @intNewLotId
				,intStageLotId = @intNewLotId
				,intStorageLocationId = @intNewStorageLocationId
			WHERE intLotId = @intLotId
				AND intStageLotId = @intLotId
		END

		IF EXISTS (
				SELECT *
				FROM dbo.tblMFPickListDetail
				WHERE intStageLotId = @intLotId
					AND intLotId <> intStageLotId
				)
		BEGIN
			UPDATE dbo.tblMFPickListDetail
			SET intStageLotId = @intNewLotId
			WHERE intStageLotId = @intLotId
				AND intLotId <> intStageLotId
		END
	END

	SELECT @dblLotQty = NULL

	IF EXISTS (
			SELECT 1
			FROM tblICLot
			WHERE dblQty <> dblWeight
				AND intItemUOMId = intWeightUOMId
				AND intLotId = @intLotId
			)
	BEGIN
		SELECT @dblLotQty = dblQty
			,@intLotItemUOMId = intItemUOMId
		FROM tblICLot
		WHERE intLotId = @intLotId

		EXEC dbo.uspMFLotAdjustQty @intLotId = @intLotId
			,@dblNewLotQty = @dblLotQty
			,@intAdjustItemUOMId = @intLotItemUOMId
			,@intUserId = @intUserId
			,@strReasonCode = 'Weight qty same'
			,@strNotes = 'Weight qty same'
	END

	IF (
			(
				SELECT dblWeight
				FROM dbo.tblICLot
				WHERE intLotId = @intLotId
				) < 0.00001
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
				) < 0.00001
			AND (
				SELECT dblQty
				FROM dbo.tblICLot
				WHERE intLotId = @intLotId
				) > 0
			)
	BEGIN
		EXEC dbo.uspMFLotAdjustQty @intLotId = @intLotId
			,@dblNewLotQty = 0
			,@intAdjustItemUOMId = @intLotItemUOMId
			,@intUserId = @intUserId
			,@strReasonCode = 'Residue qty clean up'
			,@strNotes = 'Residue qty clean up'
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
