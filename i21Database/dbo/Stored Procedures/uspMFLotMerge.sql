CREATE PROCEDURE [uspMFLotMerge] @intLotId INT
	,@intNewLotId INT
	,@dblMergeQty NUMERIC(38, 20)
	,@intMergeItemUOMId INT
	,@intUserId INT
	,@blnValidateLotReservation BIT = 0
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
		,@dblLotWeightPerUnit NUMERIC(38, 20)
		,@intInventoryAdjustmentId INT
		,@TransactionCount INT
		,@ErrMsg NVARCHAR(MAX)
		,@intNewLocationId INT
		,@intNewSubLocationId INT
		,@intNewStorageLocationId INT
		,@intNewItemUOMId INT
		,@intNewLotStatusId INT
		,@dblNewLotWeightPerUnit NUMERIC(38, 20)
		,@strNewLotNumber NVARCHAR(100)
		,@intSourceLotWeightUOM INT
		,@intDestinationLotWeightUOM INT
		,@dblAdjustByQuantity NUMERIC(38, 20)
		,@intWeightUOMId INT
		,@dblLotReservedQty NUMERIC(38, 20)
		,@dblWeight NUMERIC(38, 20)
		,@dblOldDestinationWeight NUMERIC(38, 20)
		,@dblOldSourceWeight NUMERIC(38, 20)
		,@dblMergeWeight NUMERIC(38, 20)
		,@strStorageLocationName NVARCHAR(50)
		,@strItemNumber NVARCHAR(50)
		,@strUnitMeasure NVARCHAR(50)
		,@intItemUOMId INT

	SELECT @dblMergeWeight = @dblMergeQty

	SELECT @intItemId = intItemId
		,@intLocationId = intLocationId
		,@intSubLocationId = intSubLocationId
		,@intStorageLocationId = intStorageLocationId
		,@strLotNumber = strLotNumber
		,@intLotStatusId = intLotStatusId
		,@intNewLocationId = intLocationId
		,@dblLotWeightPerUnit = dblWeightPerQty
		,@intWeightUOMId = intWeightUOMId
		,@intSourceLotWeightUOM = intWeightUOMId
		,@dblWeight = dblWeight
		,@dblOldSourceWeight = CASE 
			WHEN intWeightUOMId IS NULL
				THEN dblQty
			ELSE dblWeight
			END
		,@intItemUOMId = intItemUOMId
	FROM tblICLot
	WHERE intLotId = @intLotId

	IF (
			CASE 
				WHEN @intItemUOMId = @intMergeItemUOMId
					AND @intWeightUOMId IS NOT NULL
					THEN - @dblMergeQty * @dblLotWeightPerUnit
				ELSE - @dblMergeQty
				END
			) > @dblOldSourceWeight
	BEGIN
		SELECT @strStorageLocationName = strName
		FROM tblICStorageLocation
		WHERE intStorageLocationId = @intStorageLocationId

		SELECT @strItemNumber = strItemNo
		FROM tblICItem
		WHERE intItemId = @intItemId

		SELECT @strUnitMeasure = UM.strUnitMeasure
		FROM tblICItemUOM U
		JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = U.intUnitMeasureId
		WHERE U.intItemUOMId = IsNULL(@intWeightUOMId, @intItemUOMId)

		SET @ErrMsg = 'Merge qty ' + LTRIM(CONVERT(NUMERIC(38, 4), @dblMergeQty)) + ' ' + @strUnitMeasure + ' is not available for lot ''' + @strLotNumber + ''' having item ''' + @strItemNumber + ''' in location ''' + @strStorageLocationName + '''.'

		RAISERROR (
				@ErrMsg
				,11
				,1
				)
	END

	SELECT @dblLotReservedQty = SUM(dbo.fnMFConvertQuantityToTargetItemUOM(intItemUOMId, ISNULL(@intWeightUOMId, @intItemUOMId), ISNULL(dblQty, 0)))
	FROM tblICStockReservation
	WHERE intLotId = @intLotId
		AND ISNULL(ysnPosted, 0) = 0

	IF @blnValidateLotReservation = 1
	BEGIN
		IF (
				@dblOldSourceWeight + (
					CASE 
						WHEN @intItemUOMId = @intMergeItemUOMId
							AND @intWeightUOMId IS NOT NULL
							THEN - @dblMergeQty * @dblLotWeightPerUnit
						ELSE - @dblMergeQty
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

	SELECT @dblAdjustByQuantity = - @dblMergeQty

	SELECT @intNewLocationId = intLocationId
		,@intNewSubLocationId = intSubLocationId
		,@intNewStorageLocationId = intStorageLocationId
		,@intNewItemUOMId = intItemUOMId
		,@strNewLotNumber = strLotNumber
		,@intNewLotStatusId = intLotStatusId
		,@dblNewLotWeightPerUnit = dblWeightPerQty
		,@intDestinationLotWeightUOM = intWeightUOMId
		,@dblOldDestinationWeight = CASE 
			WHEN intWeightUOMId IS NULL
				THEN dblQty
			ELSE dblWeight
			END
	FROM tblICLot
	WHERE intLotId = @intNewLotId

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

	IF @intNewLotStatusId <> @intLotStatusId
	BEGIN
		RAISERROR (
				'The status of the source and the destination lot differs, cannot merge'
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

	IF @intDestinationLotWeightUOM <> @intSourceLotWeightUOM
	BEGIN
		RAISERROR (
				'Lots with different unit of measure cannot be merged.'
				,11
				,1
				)
	END

	BEGIN TRANSACTION

	EXEC uspICInventoryAdjustment_CreatePostLotMerge @intItemId = @intItemId
		,@dtmDate = @dtmDate
		,@intLocationId = @intLocationId
		,@intSubLocationId = @intSubLocationId
		,@intStorageLocationId = @intStorageLocationId
		,@strLotNumber = @strLotNumber
		,@intNewLocationId = @intNewLocationId
		,@intNewSubLocationId = @intNewSubLocationId
		,@intNewStorageLocationId = @intNewStorageLocationId
		,@strNewLotNumber = @strNewLotNumber
		,@dblAdjustByQuantity = @dblAdjustByQuantity
		,@intItemUOMId = @intMergeItemUOMId
		,@dblNewSplitLotQuantity = NULL
		,@dblNewWeight = NULL
		,@intNewItemUOMId = NULL
		,@intNewWeightUOMId = NULL
		,@dblNewUnitCost = NULL
		,@intSourceId = @intSourceId
		,@intSourceTransactionTypeId = @intSourceTransactionTypeId
		,@intEntityUserSecurityId = @intUserId
		,@intInventoryAdjustmentId = @intInventoryAdjustmentId OUTPUT

	EXEC dbo.uspMFAdjustInventory @dtmDate = @dtmDate
		,@intTransactionTypeId = 19
		,@intItemId = @intItemId
		,@intSourceLotId = @intLotId
		,@intDestinationLotId = @intNewLotId
		,@dblQty = @dblAdjustByQuantity
		,@intItemUOMId = @intMergeItemUOMId
		,@intOldItemId = NULL
		,@dtmOldExpiryDate = NULL
		,@dtmNewExpiryDate = NULL
		,@intOldLotStatusId = NULL
		,@intNewLotStatusId = NULL
		,@intUserId = @intUserId
		,@strNote = NULL
		,@strReason = NULL
		,@intLocationId = @intLocationId
		,@intInventoryAdjustmentId=@intInventoryAdjustmentId

	IF EXISTS (
			SELECT 1
			FROM tblICLot
			WHERE dblQty <> dblWeight
				AND intItemUOMId = intWeightUOMId
				AND intLotId = @intLotId
			)
	BEGIN
		DECLARE @dblLotQty NUMERIC(38, 20)

		SELECT @dblLotQty = dblQty
		FROM tblICLot
		WHERE intLotId = @intLotId

		EXEC dbo.uspMFLotAdjustQty @intLotId = @intLotId
			,@dblNewLotQty = @dblLotQty
			,@intAdjustItemUOMId = @intItemUOMId
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
			,@intAdjustItemUOMId = @intItemUOMId
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
