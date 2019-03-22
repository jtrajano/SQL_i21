CREATE PROCEDURE uspWHLotSplit @intLotId INT
	,@intSplitSubLocationId INT
	,@intSplitStorageLocationId INT
	,@dblSplitQty NUMERIC(38, 20)
	,@intUserId INT
	,@strSplitLotNumber NVARCHAR(100) = NULL OUTPUT
	,@strNewLotNumber NVARCHAR(100) = NULL
	,@strNote NVARCHAR(1024) = NULL
	,@intInventoryAdjustmentId INT = NULL OUTPUT
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
		,@intItemUOMId INT
		,@TransactionCount INT
		,@ErrMsg NVARCHAR(MAX)
		,@intNewLocationId INT
		,@intNewSubLocationId INT
		,@intNewStorageLocationId INT
		,@intNewItemUOMId INT
		,@dblAdjustByQuantity NUMERIC(38, 20)
		,@strLotTracking NVARCHAR(50)
		,@dblWeightPerQty NUMERIC(38, 20)
		,@intWeightUOMId INT
		,@intItemStockUOMId INT
		,@dblLotReservedQty NUMERIC(38, 20)
		,@dblWeight NUMERIC(38, 20)
		,@dblLotQty NUMERIC(38, 20)
		,@dblLotAvailableQty NUMERIC(38, 20)
		,@dblOldDestinationQty NUMERIC(38, 20)
		,@dblOldSourceQty NUMERIC(38, 20)
		,@intNewLotId INT
		,@dblDefaultResidueQty NUMERIC(38, 20)
		,@intParentLotId INT
		,@strParentLotNumber NVARCHAR(50)
		,@intCategoryId int

	SELECT TOP 1 @dblDefaultResidueQty = ISNULL(dblDefaultResidueQty, 0.00001)
	FROM tblMFCompanyPreference

	SELECT @intNewLocationId = intCompanyLocationId
	FROM tblSMCompanyLocationSubLocation
	WHERE intCompanyLocationSubLocationId = @intSplitSubLocationId

	SELECT @intItemId = intItemId
		,@intLocationId = intLocationId
		,@intSubLocationId = intSubLocationId
		,@intStorageLocationId = intStorageLocationId
		,@strLotNumber = strLotNumber
		,@dblLotQty = dblQty
		,@intLotStatusId = intLotStatusId
		,@intItemUOMId = intItemUOMId
		,@dblWeightPerQty = dblWeightPerQty
		,@intWeightUOMId = intWeightUOMId
		,@dblWeight = dblWeight
		,@dblOldSourceQty = dblQty
		,@intParentLotId = intParentLotId
	FROM tblICLot
	WHERE intLotId = @intLotId

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

	SELECT @dblAdjustByQuantity = - @dblSplitQty
		,@intNewItemUOMId = @intItemUOMId
		,@dtmDate = GETDATE()
		,@intSourceId = 1
		,@intSourceTransactionTypeId = 8

	SELECT @dblLotReservedQty = SUM(dbo.fnMFConvertQuantityToTargetItemUOM(intItemUOMId, ISNULL(@intWeightUOMId, @intItemUOMId), ISNULL(dblQty, 0)))
	FROM tblICStockReservation
	WHERE intLotId = @intLotId
		AND ISNULL(ysnPosted, 0) = 0

	IF (
			@dblLotAvailableQty + (
				@dblAdjustByQuantity * (
					CASE 
						WHEN @dblWeightPerQty = 0
							THEN 1
						ELSE @dblWeightPerQty
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

	SELECT @strLotTracking = strLotTracking
			,@intCategoryId = intCategoryId
	FROM dbo.tblICItem
	WHERE intItemId = @intItemId

	IF (ISNULL(@strNewLotNumber, '') <> '')
	BEGIN
		IF EXISTS (
				SELECT 1
				FROM tblICLot
				WHERE strLotNumber = @strNewLotNumber
					AND intItemId <> @intItemId
				)
		BEGIN
			RAISERROR (
					'Supplied lot number already exists for a lot with a different item. Please provide a different lot number to continue.'
					,11
					,1
					)
		END
	END

	IF (
			@strNewLotNumber = ''
			OR @strNewLotNumber IS NULL
			)
	BEGIN
		IF (@strLotTracking = 'Yes - Manual')
		BEGIN
			SET @strNewLotNumber = 'Split Lot Serial Number'

			RAISERROR (
					'Lot tracking for the item is set as manual. Please supply the split lot number.'
					,11
					,1
					)
		END
		ELSE
		BEGIN
			SELECT @strParentLotNumber = strParentLotNumber
			FROM tblICParentLot
			WHERE intParentLotId = @intParentLotId

			EXEC dbo.uspMFGeneratePatternId @intCategoryId = @intCategoryId
				,@intItemId = @intItemId
				,@intManufacturingId = NULL
				,@intSubLocationId = @intSubLocationId
				,@intLocationId = @intLocationId
				,@intOrderTypeId = NULL
				,@intBlendRequirementId = NULL
				,@intPatternCode = 24
				,@ysnProposed = 0
				,@strPatternString = @strNewLotNumber OUTPUT
				,@intShiftId = NULL
				,@dtmDate = @dtmDate
				,@strParentLotNumber = @strParentLotNumber
		END
	END

	BEGIN TRANSACTION

	EXEC uspICInventoryAdjustment_CreatePostSplitLot @intItemId = @intItemId
		,@dtmDate = @dtmDate
		,@intLocationId = @intLocationId
		,@intSubLocationId = @intSubLocationId
		,@intStorageLocationId = @intStorageLocationId
		,@strLotNumber = @strLotNumber
		,@intNewLocationId = @intNewLocationId
		,@intNewSubLocationId = @intSplitSubLocationId
		,@intNewStorageLocationId = @intSplitStorageLocationId
		,@strNewLotNumber = @strNewLotNumber
		,@dblAdjustByQuantity = @dblAdjustByQuantity
		,@intItemUOMId = @intItemUOMId
		,@dblNewSplitLotQuantity = NULL
		,@dblNewWeight = NULL
		,@intNewItemUOMId = @intNewItemUOMId
		,@intNewWeightUOMId = NULL
		,@dblNewUnitCost = NULL
		,@intSourceId = @intSourceId
		,@intSourceTransactionTypeId = @intSourceTransactionTypeId
		,@intEntityUserSecurityId = @intUserId
		,@intInventoryAdjustmentId = @intInventoryAdjustmentId OUTPUT

	SELECT TOP 1 @strSplitLotNumber = strLotNumber
		,@intNewLotId = intLotId
	FROM tblICLot
	ORDER BY intLotId DESC

	SELECT @strSplitLotNumber AS strSplitLotNumber

	EXEC dbo.uspMFAdjustInventory @dtmDate = @dtmDate
		,@intTransactionTypeId = 17
		,@intItemId = @intItemId
		,@intSourceLotId = @intLotId
		,@intDestinationLotId = @intNewLotId
		,@dblQty = @dblAdjustByQuantity
		,@intItemUOMId = @intItemUOMId
		,@intOldItemId = NULL
		,@dtmOldExpiryDate = NULL
		,@dtmNewExpiryDate = NULL
		,@intOldLotStatusId = NULL
		,@intNewLotStatusId = NULL
		,@intUserId = @intUserId
		,@strNote = @strNote
		,@strReason = NULL
		,@intLocationId = @intLocationId
		,@intInventoryAdjustmentId = @intInventoryAdjustmentId

	IF EXISTS (
			SELECT 1
			FROM tblICLot
			WHERE dblQty <> dblWeight
				AND intItemUOMId = intWeightUOMId
				AND intLotId = @intLotId
			)
	BEGIN
		SELECT @dblLotQty = NULL

		SELECT @dblLotQty = CASE 
				WHEN intWeightUOMId IS NULL
					THEN dblQty
				ELSE dblWeight
				END
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

	EXEC uspQMSampleCopy @intOldLotId = @intLotId
		,@intNewLotId = @intNewLotId
		,@intLocationId = @intLocationId
		,@intUserId = @intUserId

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
