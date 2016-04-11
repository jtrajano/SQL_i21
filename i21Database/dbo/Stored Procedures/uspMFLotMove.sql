CREATE PROCEDURE [uspMFLotMove] @intLotId INT
	,@intNewSubLocationId INT
	,@intNewStorageLocationId INT
	,@dblMoveQty NUMERIC(38, 20)
	,@intUserId INT
	,@blnValidateLotReservation BIT = 0
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
	FROM tblICLot
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

	IF @dblMoveQty>@dblLotAvailableQty
	BEGIN
		RAISERROR (
				90015
				,11
				,1
				)
	END

	SELECT @strNewLotNumber = @strLotNumber

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

	IF @intNewStorageLocationId = @intStorageLocationId
	BEGIN
		RAISERROR (
				51182
				,11
				,1
				)
	END
	
	SELECT @dblLotReservedQty = ISNULL(SUM(dblQty),0) FROM tblICStockReservation WHERE intLotId = @intLotId 

	IF @blnValidateLotReservation = 1 
	BEGIN
		IF (@dblWeight + (-@dblMoveQty)) < @dblLotReservedQty
		BEGIN
			RAISERROR('There is reservation against this lot. Cannot proceed.',16,1)
		END
	END

	IF @dblWeightPerQty > 0 
	BEGIN
		SELECT @dblMoveQty = dbo.fnDivide(@dblMoveQty, @dblWeightPerQty)
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
		,@intSourceId
		,@intSourceTransactionTypeId
		,@intUserId
		,@intInventoryAdjustmentId

	UPDATE dbo.tblICLot
	SET dblWeightPerQty = @dblWeightPerQty
	WHERE intSubLocationId =@intNewSubLocationId AND intStorageLocationId=@intNewStorageLocationId AND strLotNumber=@strNewLotNumber
		
	IF EXISTS (
			SELECT *
			FROM dbo.tblMFWorkOrderProducedLot
			WHERE intLotId = @intLotId
				AND dblPhysicalCount = @dblMoveQty
			)
	BEGIN
		DECLARE @intNewLotId INT

		SELECT @intNewLotId = intLotId
		FROM dbo.tblICLot
		WHERE strLotNumber = @strNewLotNumber
			AND intStorageLocationId = @intNewStorageLocationId

		UPDATE dbo.tblMFWorkOrderProducedLot
		SET intLotId = @intNewLotId
		WHERE intLotId = @intLotId
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
			@intUserId = @intUserId ,
			@strReasonCode = 'Weight qty same',
			@strNotes = 'Weight qty same'
	END

	IF ((SELECT dblWeight FROM dbo.tblICLot WHERE intLotId = @intLotId) < 0.01 AND (SELECT dblWeight FROM dbo.tblICLot WHERE intLotId = @intLotId) > 0) OR ((SELECT dblQty FROM dbo.tblICLot WHERE intLotId = @intLotId) < 0.01 AND (SELECT dblQty FROM dbo.tblICLot WHERE intLotId = @intLotId) > 0)
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
