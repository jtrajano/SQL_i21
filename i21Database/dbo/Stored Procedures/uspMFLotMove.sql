﻿CREATE PROCEDURE [uspMFLotMove] @intLotId INT
	,@intNewSubLocationId INT
	,@intNewStorageLocationId INT
	,@dblMoveQty NUMERIC(38, 20)
	,@intMoveItemUOMId int
	,@intUserId INT
	,@blnValidateLotReservation BIT = 0
	,@blnInventoryMove BIT = 0
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
	DECLARE @intLotStatusId INT
	DECLARE @intNewLocationId INT
	DECLARE @strNewLotNumber NVARCHAR(50)
	DECLARE @intInventoryAdjustmentId INT
	DECLARE @TransactionCount INT
	DECLARE @ErrMsg NVARCHAR(MAX)
		,@dblWeightPerQty NUMERIC(38, 20)
		,@intWeightUOMId INT
		,@intItemStockUOMId INT
	DECLARE @dblLotReservedQty NUMERIC(38, 20)
	DECLARE @dblWeight NUMERIC(38,20)
	DECLARE @dblLotQty NUMERIC(38,20)
	DECLARE @dblLotAvailableQty NUMERIC(38,20)
	DECLARE @intNewLotId INT
	DECLARE @blnIsPartialMove BIT
	DECLARE @strStorageLocationName NVARCHAR(50)
	DECLARE @strItemNumber NVARCHAR(50)
	DECLARE @strUnitMeasure NVARCHAR(50)
	DECLARE @dblMoveWeight NUMERIC(38,20)
			,@dblOldWeight NUMERIC(38,20)
			,@dblOldSourceWeight NUMERIC(38,20)
			,@intItemUOMId int

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
		,@intItemUOMId=intItemUOMId
	FROM tblICLot
	WHERE intLotId = @intLotId
	
	SELECT @strStorageLocationName = strName FROM tblICStorageLocation WHERE intStorageLocationId = @intStorageLocationId
	SELECT @strItemNumber = strItemNo FROM tblICItem WHERE intItemId = @intItemId
	SELECT @dblMoveWeight = @dblMoveQty
	SELECT @strUnitMeasure =  UM.strUnitMeasure
	FROM tblICLot l
	JOIN tblICItemUOM U ON U.intItemUOMId = l.intWeightUOMId
	JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = U.intUnitMeasureId
	WHERE intLotId = @intLotId

	SELECT @intItemStockUOMId = intItemUOMId
	FROM dbo.tblICItemUOM
	WHERE intItemId = @intItemId
		AND ysnStockUnit = 1

	SELECT @dblLotAvailableQty = (CASE 
	WHEN ISNULL(@dblWeight, 0) = 0
		THEN ISNULL(@dblLotQty, 0)
	ELSE ISNULL(@dblWeight, 0)
	END)

	IF (CASE WHEN @intItemUOMId=@intMoveItemUOMId AND @intWeightUOMId IS NOT NULL THEN @dblMoveQty*@dblWeightPerQty ELSE @dblMoveQty END)>@dblLotAvailableQty
	BEGIN
		SET @ErrMsg = 'Move qty '+ LTRIM(CONVERT(NUMERIC(38,4), @dblMoveQty)) + ' ' + @strUnitMeasure + ' is not available for lot ''' + @strLotNumber + ''' having item '''+ @strItemNumber + ''' in location ''' + @strStorageLocationName + '''.'
		RAISERROR (@ErrMsg,11,1)
	END

	SELECT @strNewLotNumber = @strLotNumber

	SELECT @dtmDate = GETDATE()

	SELECT @intSourceId = 1
		,@intSourceTransactionTypeId = 8

	IF ISNULL(@strLotNumber, '') = ''
	BEGIN
		RAISERROR (51192,11,1)
	END

	IF(@dblMoveQty = @dblLotAvailableQty)
	BEGIN
		SET @blnIsPartialMove = 0
	END
	ELSE 
	BEGIN
		SET @blnIsPartialMove = 1
	END

	IF @intNewStorageLocationId = @intStorageLocationId
	BEGIN
		RAISERROR (51182,11,1)
	END
	
	SELECT @dblLotReservedQty = ISNULL(SUM(dblQty),0) FROM tblICStockReservation WHERE intLotId = @intLotId AND ISNULL(ysnPosted,0)=0

	IF @blnIsPartialMove = 1
	BEGIN
		IF @blnValidateLotReservation = 1 
		BEGIN
			IF (@dblLotAvailableQty + (CASE WHEN @intItemUOMId=@intMoveItemUOMId AND @intWeightUOMId IS NOT NULL THEN -@dblMoveQty*@dblWeightPerQty ELSE -@dblMoveQty END)) < @dblLotReservedQty
			BEGIN
				RAISERROR('There is reservation against this lot. Cannot proceed.',16,1)
			END
		END
	END

	IF EXISTS (SELECT 1 FROM tblWHSKU WHERE intLotId = @intLotId)
	BEGIN
		RAISERROR(90008,11,1)
	END

	
	--IF @intItemStockUOMId = @intWeightUOMId
	--BEGIN
	--	SELECT @dblMoveQty = dbo.fnDivide(@dblMoveQty, @dblWeightPerQty)
	--END


			--IF @dblOldWeight IS NULL
			--SELECT @dblOldWeight=0

			--SELECT @dblOldSourceWeight=Case When intWeightUOMId is null Then dblQty Else dblWeight End
			--FROM dbo.tblICLot
			--WHERE strLotNumber = @strLotNumber
			--	AND intStorageLocationId = @intStorageLocationId

			--IF @dblOldSourceWeight IS NULL
			--SELECT @dblOldSourceWeight=0
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
				,@intMoveItemUOMId
				,@intSourceId
				,@intSourceTransactionTypeId
				,@intUserId
				,@intInventoryAdjustmentId

			--UPDATE dbo.tblICLot
			--SET dblWeightPerQty = @dblWeightPerQty,
			--	dblWeight = CASE WHEN @dblWeightPerQty = 0 THEN 0 ELSE @dblOldSourceWeight-@dblMoveWeight END,
			--	dblQty = (@dblOldSourceWeight-@dblMoveWeight)/CASE WHEN @dblWeightPerQty = 0 THEN 1 ELSE @dblWeightPerQty END
			--WHERE intSubLocationId =@intSubLocationId AND intStorageLocationId=@intStorageLocationId AND strLotNumber=@strLotNumber

			--UPDATE dbo.tblICLot
			--SET dblWeightPerQty = @dblWeightPerQty,
			--	dblWeight = CASE WHEN @dblWeightPerQty = 0 THEN 0 ELSE @dblOldWeight+@dblMoveWeight END,
			--	dblQty = (@dblOldWeight+@dblMoveWeight)/CASE WHEN @dblWeightPerQty = 0 THEN 1 ELSE @dblWeightPerQty END
			--WHERE intSubLocationId =@intNewSubLocationId AND intStorageLocationId=@intNewStorageLocationId AND strLotNumber=@strNewLotNumber
			--IF @dblOldWeight IS NULL
			--SELECT @dblOldWeight=0

			--SELECT @dblOldSourceWeight=Case When intWeightUOMId is null Then dblQty Else dblWeight End
			--FROM dbo.tblICLot
			--WHERE strLotNumber = @strLotNumber
			--	AND intStorageLocationId = @intStorageLocationId

			--IF @dblOldSourceWeight IS NULL
			--SELECT @dblOldSourceWeight=0

			--EXEC uspICInventoryAdjustment_CreatePostLotMove @intItemId
			--	,@dtmDate
			--	,@intLocationId
			--	,@intSubLocationId
			--	,@intStorageLocationId
			--	,@strLotNumber
			--	,@intNewLocationId
			--	,@intNewSubLocationId
			--	,@intNewStorageLocationId
			--	,@strNewLotNumber
			--	,@dblMoveQty
			--	,@intSourceId
			--	,@intSourceTransactionTypeId
			--	,@intUserId
			--	,@intInventoryAdjustmentId

			--UPDATE dbo.tblICLot
			--SET dblWeightPerQty = @dblWeightPerQty,
			--	dblWeight = CASE WHEN @dblWeightPerQty = 0 THEN 0 ELSE @dblOldSourceWeight-@dblMoveWeight END,
			--	dblQty = (@dblOldSourceWeight-@dblMoveWeight)/CASE WHEN @dblWeightPerQty = 0 THEN 1 ELSE @dblWeightPerQty END
			--WHERE intSubLocationId =@intSubLocationId AND intStorageLocationId=@intStorageLocationId AND strLotNumber=@strLotNumber

			--UPDATE dbo.tblICLot
			--SET dblWeightPerQty = @dblWeightPerQty,
			--	dblWeight = CASE WHEN @dblWeightPerQty = 0 THEN 0 ELSE @dblOldWeight+@dblMoveWeight END,
			--	dblQty = (@dblOldWeight+@dblMoveWeight)/CASE WHEN @dblWeightPerQty = 0 THEN 1 ELSE @dblWeightPerQty END
			--WHERE intSubLocationId =@intNewSubLocationId AND intStorageLocationId=@intNewStorageLocationId AND strLotNumber=@strNewLotNumber

			SELECT @intNewLotId = intLotId
			FROM dbo.tblICLot
			WHERE strLotNumber = @strNewLotNumber
				AND intStorageLocationId = @intNewStorageLocationId
		
			IF EXISTS (SELECT * FROM dbo.tblMFWorkOrderProducedLot WHERE intLotId = @intLotId AND dblPhysicalCount = @dblMoveQty)
			BEGIN
				UPDATE dbo.tblMFWorkOrderProducedLot
				SET intLotId = @intNewLotId
				WHERE intLotId = @intLotId
			END

			IF @blnIsPartialMove = 0 AND @blnInventoryMove = 1
			BEGIN
				IF EXISTS(SELECT * FROM dbo.tblMFWorkOrderConsumedLot WHERE intLotId = @intLotId)
				BEGIN
					UPDATE dbo.tblMFWorkOrderConsumedLot 
					SET intLotId = @intNewLotId
					WHERE intLotId = @intLotId
				END
	
				IF EXISTS(SELECT * FROM dbo.tblICStockReservation WHERE intLotId = @intLotId)
				BEGIN
					UPDATE dbo.tblICStockReservation 
					SET intLotId = @intNewLotId,
						intStorageLocationId = @intNewStorageLocationId,
						intSubLocationId = @intNewSubLocationId
					WHERE intLotId = @intLotId
				END
	
				IF EXISTS(SELECT * FROM dbo.tblMFPickListDetail WHERE intLotId = @intLotId AND intStageLotId = @intLotId)
				BEGIN
					UPDATE dbo.tblMFPickListDetail 
					SET intLotId = @intNewLotId,
						intStageLotId = @intNewLotId,
						intStorageLocationId = @intNewStorageLocationId
					WHERE intLotId = @intLotId AND intStageLotId = @intLotId
				END

				IF EXISTS(SELECT * FROM dbo.tblMFPickListDetail WHERE intStageLotId = @intLotId AND intLotId <> intStageLotId)
				BEGIN
					UPDATE dbo.tblMFPickListDetail 
					SET intStageLotId = @intNewLotId
					WHERE intStageLotId = @intLotId AND intLotId <> intStageLotId
				END
			END

			--UPDATE tblICLot
			--SET dblWeight = dblQty
			--WHERE dblQty <> dblWeight
			--	AND intItemUOMId = intWeightUOMId
			--and intLotId=@intLotId

			IF EXISTS (SELECT 1 FROM tblICLot WHERE dblQty <> dblWeight AND intItemUOMId = intWeightUOMId AND intLotId=@intLotId)
			BEGIN
				EXEC dbo.uspMFLotAdjustQty
					@intLotId = @intLotId,       
					@dblNewLotQty = @dblLotQty,
					@intAdjustItemUOMId=@intItemUOMId,
					@intUserId = @intUserId ,
					@strReasonCode = 'Weight qty same',
					@strNotes = 'Weight qty same'
			END

			IF ((SELECT dblWeight FROM dbo.tblICLot WHERE intLotId = @intLotId) < 0.01 AND (SELECT dblWeight FROM dbo.tblICLot WHERE intLotId = @intLotId) > 0) OR ((SELECT dblQty FROM dbo.tblICLot WHERE intLotId = @intLotId) < 0.01 AND (SELECT dblQty FROM dbo.tblICLot WHERE intLotId = @intLotId) > 0)
			BEGIN
				EXEC dbo.uspMFLotAdjustQty
				 @intLotId =@intLotId,       
				 @dblNewLotQty =0,
				 @intAdjustItemUOMId=@intItemUOMId,
				 @intUserId=@intUserId ,
				 @strReasonCode ='Residue qty clean up',
				 @strNotes ='Residue qty clean up'
				--UPDATE tblICLot
				--SET dblWeight = 0
				--	,dblQty = 0
				--WHERE intLotId = @intLotId
			END
	
	COMMIT TRANSACTION

END TRY

BEGIN CATCH
	IF XACT_STATE() != 0
		AND @@TRANCOUNT > 0
		ROLLBACK TRANSACTION

	SET @ErrMsg = ERROR_MESSAGE()

	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
END CATCH
