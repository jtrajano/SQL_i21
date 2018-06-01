CREATE PROCEDURE [uspMFLotMove] @intLotId INT
	,@intNewSubLocationId INT
	,@intNewStorageLocationId INT
	,@dblMoveQty NUMERIC(38, 20)
	,@intMoveItemUOMId INT
	,@intUserId INT
	,@blnValidateLotReservation BIT = 0
	,@blnInventoryMove BIT = 0
	,@dtmDate DATETIME = NULL
	,@strReasonCode NVARCHAR(MAX) = NULL
	,@strNotes NVARCHAR(MAX) = NULL
	,@ysnBulkChange BIT = 0
	,@ysnSourceLotEmptyOut BIT = 0
	,@ysnDestinationLotEmptyOut BIT = 0
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
		,@intNewLocationId INT
		,@strNewLotNumber NVARCHAR(50)
		,@intInventoryAdjustmentId INT
		,@TransactionCount INT
		,@ErrMsg NVARCHAR(MAX)
		,@dblWeightPerQty NUMERIC(38, 20)
		,@intWeightUOMId INT
		,@intItemStockUOMId INT
		,@dblLotReservedQty NUMERIC(38, 20)
		,@dblWorkOrderReservedQty NUMERIC(38, 20)
		,@dblWeight NUMERIC(38, 20)
		,@dblLotQty NUMERIC(38, 20)
		,@dblLotAvailableQty NUMERIC(38, 20)
		,@intNewLotId INT
		,@blnIsPartialMove BIT
		,@strStorageLocationName NVARCHAR(50)
		,@strItemNumber NVARCHAR(50)
		,@strUnitMeasure NVARCHAR(50)
		,@dblMoveWeight NUMERIC(38, 20)
		,@dblOldWeight NUMERIC(38, 20)
		,@dblOldSourceWeight NUMERIC(38, 20)
		,@intItemUOMId INT
		,@ysnAllowMultipleLots INT
		,@ysnAllowMultipleItems INT
		,@intDestinationLotStatusId INT
		,@intCategoryId INT
		,@dblDefaultResidueQty NUMERIC(38, 20)
		,@dblDestinationLotQty NUMERIC(38, 20)
		,@intTransactionCount INT
		,@strDescription NVARCHAR(MAX)
		,@intSourceLocationRestrictionId INT
		,@intDestinatinLocationRestrictionId INT
		,@ysnChangeLotStatusOnLotMoveByStorageLocationRestrictionType BIT
		,@strSubLocationName NVARCHAR(50)
		,@strName NVARCHAR(50)
		,@intBondStatusId INT
		,@intStorageUnitTypeId INT
		,@strInternalCode NVARCHAR(50)
		,@intDestinationLotId INT
		,@intDestinationItemUOMId int
		,@intTransactionId INT
		,@intInventoryTransactionType INT
		,@ItemsToReserve AS dbo.ItemReservationTableType
		,@ItemsToUnReserve AS dbo.ItemReservationTableType

	SELECT @intTransactionCount = @@TRANCOUNT

	SELECT @strDescription = Ltrim(isNULL(@strReasonCode, '') + ' ' + isNULL(@strNotes, ''))

	SELECT TOP 1 @dblDefaultResidueQty = ISNULL(dblDefaultResidueQty, 0.00001)
		,@ysnChangeLotStatusOnLotMoveByStorageLocationRestrictionType = isNULL(ysnChangeLotStatusOnLotMoveByStorageLocationRestrictionType, 0)
	FROM tblMFCompanyPreference

	SELECT @intItemId = intItemId
		,@intLocationId = intLocationId
		,@intSubLocationId = intSubLocationId
		,@intStorageLocationId = intStorageLocationId
		,@strLotNumber = strLotNumber
		,@dblLotQty = dblQty
		,@intLotStatusId = intLotStatusId
		,@dblWeightPerQty = dblWeightPerQty
		,@intWeightUOMId = intWeightUOMId
		,@dblWeight = dblWeight
		,@intItemUOMId = intItemUOMId
	FROM tblICLot
	WHERE intLotId = @intLotId

	SELECT @intSourceLocationRestrictionId = intRestrictionId
	FROM tblICStorageLocation
	WHERE intStorageLocationId = @intStorageLocationId

	IF @intSourceLocationRestrictionId IS NULL
		SELECT @intSourceLocationRestrictionId = 0

	SELECT @intDestinatinLocationRestrictionId = intRestrictionId
		,@intNewLocationId = intLocationId
	FROM tblICStorageLocation
	WHERE intStorageLocationId = @intNewStorageLocationId

	IF @intDestinatinLocationRestrictionId IS NULL
		SELECT @intDestinatinLocationRestrictionId = 0

	SELECT @intDestinationLotStatusId = intLotStatusId
		,@dblDestinationLotQty = dblQty
	FROM tblICLot
	WHERE strLotNumber = @strLotNumber
		AND intStorageLocationId = @intNewStorageLocationId

	SELECT @strStorageLocationName = strName
	FROM tblICStorageLocation
	WHERE intStorageLocationId = @intStorageLocationId

	SELECT @strItemNumber = strItemNo
		,@intCategoryId = intCategoryId
	FROM tblICItem
	WHERE intItemId = @intItemId

	SELECT @dblMoveWeight = @dblMoveQty

	SELECT @strUnitMeasure = UM.strUnitMeasure
	FROM tblICLot l
	JOIN tblICItemUOM U ON U.intItemUOMId = IsNULL(l.intWeightUOMId, l.intItemUOMId)
	JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = U.intUnitMeasureId
	WHERE intLotId = @intLotId

	SELECT @intItemStockUOMId = intItemUOMId
	FROM dbo.tblICItemUOM
	WHERE intItemId = @intItemId
		AND ysnStockUnit = 1

	SELECT @ysnAllowMultipleLots = ysnAllowMultipleLot
		,@ysnAllowMultipleItems = ysnAllowMultipleItem
	FROM tblICStorageLocation
	WHERE intStorageLocationId = @intNewStorageLocationId

	SELECT @dblLotAvailableQty = (
			CASE 
				WHEN @intWeightUOMId IS NULL
					THEN ISNULL(@dblLotQty, 0)
				ELSE ISNULL(@dblWeight, 0)
				END
			)

	IF Convert(DECIMAL(24, 3), (
				CASE 
					WHEN @intItemUOMId = @intMoveItemUOMId
						AND @intWeightUOMId IS NOT NULL
						THEN @dblMoveQty * @dblWeightPerQty
					ELSE @dblMoveQty
					END
				)) > Convert(DECIMAL(24, 3), @dblLotAvailableQty)
	BEGIN
		SET @ErrMsg = 'Move qty ' + LTRIM(CONVERT(NUMERIC(38, 4), @dblMoveQty)) + ' ' + @strUnitMeasure + ' is not available for lot ''' + @strLotNumber + ''' having item ''' + @strItemNumber + ''' in location ''' + @strStorageLocationName + '''.'

		RAISERROR (
				@ErrMsg
				,11
				,1
				)
	END

	IF @ysnAllowMultipleLots = 0
		AND @ysnAllowMultipleItems = 0
	BEGIN
		IF EXISTS (
				SELECT intLotId
				FROM tblICLot
				WHERE intStorageLocationId = @intNewStorageLocationId
					AND (
						dblQty > 0
						OR dblWeight > 0
						)
				)
		BEGIN
			RAISERROR (
					'The storage location is already used by another lot .'
					,16
					,1
					)
		END
	END
	ELSE IF @ysnAllowMultipleLots = 0
		AND @ysnAllowMultipleItems = 1
	BEGIN
		IF EXISTS (
				SELECT intLotId
				FROM tblICLot
				WHERE intStorageLocationId = @intNewStorageLocationId
					AND intItemId = @intItemId
					AND (
						dblQty > 0
						OR dblWeight > 0
						)
				)
		BEGIN
			SET @ErrMsg = 'The storage location is already used by other lot of item ' + @strItemNumber + '.'

			RAISERROR (
					@ErrMsg
					,16
					,1
					)
		END
	END
	ELSE IF @ysnAllowMultipleLots = 1
		AND @ysnAllowMultipleItems = 0
	BEGIN
		IF EXISTS (
				SELECT intLotId
				FROM tblICLot
				WHERE intStorageLocationId = @intNewStorageLocationId
					AND intItemId = @intItemId
					AND (
						dblQty > 0
						OR dblWeight > 0
						)
				)
		BEGIN
			SET @ErrMsg = 'The storage location is already used by another item.'

			RAISERROR (
					@ErrMsg
					,16
					,1
					)
		END
	END

	SELECT @strNewLotNumber = @strLotNumber

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

	IF (ISNULL(@intDestinationLotStatusId, 0) <> 0)
	BEGIN
		IF ISNULL(@intLotStatusId, 0) <> ISNULL(@intDestinationLotStatusId, 0)
			AND @dblDestinationLotQty > 0
		BEGIN
			SET @ErrMsg = 'The status of the source and the destination lot differs. Cannot move.'

			RAISERROR (
					@ErrMsg
					,11
					,1
					)
		END
	END

	IF (
			CASE 
				WHEN @intItemUOMId = @intMoveItemUOMId
					AND @intWeightUOMId IS NOT NULL
					THEN @dblMoveQty * @dblWeightPerQty
				ELSE @dblMoveQty
				END
			) = @dblLotAvailableQty
	BEGIN
		SET @blnIsPartialMove = 0
	END
	ELSE
	BEGIN
		SET @blnIsPartialMove = 1
	END

	IF @intNewStorageLocationId = @intStorageLocationId
		AND @intNewSubLocationId = @intSubLocationId
	BEGIN
		IF @ysnBulkChange = 1
		BEGIN
			RETURN
		END

		RAISERROR (
				'The Lot already exists in the selected destination storage location. Please select a different destination storage location.'
				,11
				,1
				)
	END

	IF NOT EXISTS (
			SELECT *
			FROM tblICStorageLocation
			WHERE intStorageLocationId = @intNewStorageLocationId
				AND intSubLocationId = @intNewSubLocationId
			)
	BEGIN
		SELECT @strName = strName
		FROM tblICStorageLocation
		WHERE intStorageLocationId = @intNewStorageLocationId

		SELECT @strSubLocationName = strSubLocationName
		FROM tblSMCompanyLocationSubLocation
		WHERE intCompanyLocationSubLocationId = @intNewSubLocationId

		SET @ErrMsg = 'The selected storage location ' + @strName + ' does not belong to selected sub location ' + @strSubLocationName + '.'

		RAISERROR (
				@ErrMsg
				,16
				,1
				)

		RETURN
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
						CASE 
							WHEN @intItemUOMId = @intMoveItemUOMId
								AND @intWeightUOMId IS NOT NULL
								THEN - @dblMoveQty * @dblWeightPerQty
							ELSE - @dblMoveQty
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
	END

	SELECT @dblWorkOrderReservedQty = SUM(dblQuantity)
	FROM tblMFWorkOrderInputLot
	WHERE intDestinationLotId = @intLotId
		AND ysnConsumptionReversed = 0

	IF @dblWorkOrderReservedQty IS NULL
	BEGIN
		SELECT @dblWorkOrderReservedQty = 0
	END

	IF (
			@dblLotAvailableQty + (
				CASE 
					WHEN @intItemUOMId = @intMoveItemUOMId
						AND @intWeightUOMId IS NOT NULL
						THEN - @dblMoveQty * @dblWeightPerQty
					ELSE - @dblMoveQty
					END
				)
			) < @dblWorkOrderReservedQty
	BEGIN
		RAISERROR (
				'There is reservation against this lot. Cannot proceed.'
				,16
				,1
				)
	END

	SELECT @intBondStatusId = intBondStatusId
	FROM tblMFLotInventory
	WHERE intLotId = @intLotId

	IF @intBondStatusId = 5
	BEGIN
		SELECT @intStorageUnitTypeId = intStorageUnitTypeId
		FROM tblICStorageLocation
		WHERE intStorageLocationId = @intNewStorageLocationId

		SELECT @strInternalCode = strInternalCode
		FROM tblICStorageUnitType
		WHERE intStorageUnitTypeId = @intStorageUnitTypeId

		IF @strInternalCode IN (
				'STAGING'
				,'PROD_STAGING'
				)
		BEGIN
			RAISERROR (
					'Scanned lot/pallet is not bond released. Please scan bond released lot/pallet to continue.'
					,16
					,1
					)
		END
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

	SELECT @intTransactionCount = @@TRANCOUNT

	IF @intTransactionCount = 0
		BEGIN TRANSACTION

	IF @blnInventoryMove = 1
		AND EXISTS (
			SELECT *
			FROM tblICStockReservation
			WHERE intLotId = @intLotId
				AND ysnPosted = 0
				AND dbo.fnMFConvertQuantityToTargetItemUOM(intItemUOMId, @intMoveItemUOMId, dblQty) = @dblMoveQty
			)
	BEGIN
		SELECT @intTransactionId = intTransactionId
			,@intInventoryTransactionType = intInventoryTransactionType
		FROM tblICStockReservation
		WHERE intLotId = @intLotId
			AND ysnPosted = 0
			AND dbo.fnMFConvertQuantityToTargetItemUOM(intItemUOMId, @intMoveItemUOMId, dblQty) = @dblMoveQty

		INSERT INTO @ItemsToReserve (
			intItemId
			,intItemLocationId
			,intItemUOMId
			,intLotId
			,intSubLocationId
			,intStorageLocationId
			,dblQty
			,intTransactionId
			,strTransactionId
			,intTransactionTypeId
			)
		SELECT intItemId
			,intItemLocationId
			,intItemUOMId
			,intLotId
			,intSubLocationId
			,intStorageLocationId
			,dblQty
			,intTransactionId
			,strTransactionId
			,intInventoryTransactionType
		FROM tblICStockReservation
		WHERE intTransactionId = @intTransactionId
			AND intInventoryTransactionType = @intInventoryTransactionType

		EXEC dbo.uspICCreateStockReservation @ItemsToUnReserve
			,@intTransactionId
			,@intInventoryTransactionType
	END

	IF @ysnDestinationLotEmptyOut = 1
		AND (
			SELECT dblQty
			FROM dbo.tblICLot
			WHERE intStorageLocationId = @intNewStorageLocationId
				AND dblQty > 0
			) > 0
	BEGIN
		SELECT @intDestinationLotId = intLotId,@intDestinationItemUOMId =intItemUOMId
		FROM dbo.tblICLot
		WHERE intStorageLocationId = @intNewStorageLocationId
			AND dblQty > 0

		EXEC dbo.uspMFLotAdjustQty @intLotId = @intDestinationLotId
			,@dblNewLotQty = 0
			,@intAdjustItemUOMId = @intDestinationItemUOMId
			,@intUserId = @intUserId
			,@strReasonCode = 'Destination Empty out'
			,@strNotes = NULL
	END

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
		,@intMoveItemUOMId
		,@intSourceId
		,@intSourceTransactionTypeId
		,@intUserId
		,@intInventoryAdjustmentId OUTPUT
		,@strDescription

	SELECT @intNewLotId = intLotId
	FROM dbo.tblICLot
	WHERE strLotNumber = @strNewLotNumber
		AND intStorageLocationId = @intNewStorageLocationId

	IF @blnInventoryMove = 1
		AND @intTransactionId IS NOT NULL
	BEGIN
		UPDATE @ItemsToReserve
		SET intLotId = @intNewLotId
			,intStorageLocationId = @intNewStorageLocationId
			,intSubLocationId = @intSubLocationId
		WHERE intLotId = @intLotId

		EXEC dbo.uspICCreateStockReservation @ItemsToReserve
			,@intTransactionId
			,@intInventoryTransactionType
	END

	EXEC dbo.uspMFAdjustInventory @dtmDate = @dtmDate
		,@intTransactionTypeId = 20
		,@intItemId = @intItemId
		,@intSourceLotId = @intLotId
		,@intDestinationLotId = @intNewLotId
		,@dblQty = @dblMoveQty
		,@intItemUOMId = @intMoveItemUOMId
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

	IF ISNULL(@intLotStatusId, 0) <> ISNULL(@intDestinationLotStatusId, 0)
		AND @dblDestinationLotQty = 0
		AND NOT EXISTS (
			SELECT *
			FROM dbo.tblICLot
			WHERE intLotId = @intNewLotId
				AND intLotStatusId = @intLotStatusId
			)
	BEGIN
		EXEC uspMFSetLotStatus @intNewLotId
			,@intLotStatusId
			,@intUserId
	END

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

	IF EXISTS (
			SELECT 1
			FROM tblICLot
			WHERE dblQty <> dblWeight
				AND intItemUOMId = intWeightUOMId
				AND intLotId = @intLotId
			)
	BEGIN
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
	BEGIN
		EXEC dbo.uspMFLotAdjustQty @intLotId = @intLotId
			,@dblNewLotQty = 0
			,@intAdjustItemUOMId = @intItemUOMId
			,@intUserId = @intUserId
			,@strReasonCode = 'Residue qty clean up'
			,@strNotes = 'Residue qty clean up'
	END

	IF @intSourceLocationRestrictionId <> @intDestinatinLocationRestrictionId
		AND @ysnChangeLotStatusOnLotMoveByStorageLocationRestrictionType = 1
	BEGIN
		SELECT @intLotStatusId = NULL

		SELECT @intLotStatusId = intLotStatusId
		FROM tblMFStorageLocationRestrictionTypeLotStatus
		WHERE intRestrictionId = @intDestinatinLocationRestrictionId

		IF @intLotStatusId IS NOT NULL
			AND NOT EXISTS (
				SELECT *
				FROM tblICLot
				WHERE intLotId = @intNewLotId
					AND intLotStatusId = @intLotStatusId
				)
		BEGIN
			EXEC uspMFSetLotStatus @intLotId = @intNewLotId
				,@intNewLotStatusId = @intLotStatusId
				,@intUserId = @intUserId
				,@strNotes = ''
		END
	END

	IF @ysnSourceLotEmptyOut = 1
		AND (
			SELECT dblQty
			FROM dbo.tblICLot
			WHERE intLotId = @intLotId
			) > 0
	BEGIN
		EXEC dbo.uspMFLotAdjustQty @intLotId = @intLotId
			,@dblNewLotQty = 0
			,@intAdjustItemUOMId = @intItemUOMId
			,@intUserId = @intUserId
			,@strReasonCode = 'Source Empty out'
			,@strNotes = NULL
	END

	IF @intTransactionCount = 0
		COMMIT TRANSACTION
END TRY

BEGIN CATCH
	IF XACT_STATE() != 0
		AND @intTransactionCount = 0
		ROLLBACK TRANSACTION

	SET @ErrMsg = ERROR_MESSAGE()

	RAISERROR (
			@ErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH
