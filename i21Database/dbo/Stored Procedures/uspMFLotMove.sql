﻿CREATE PROCEDURE [uspMFLotMove] @intLotId INT
	,@intNewSubLocationId INT
	,@intNewStorageLocationId INT
	,@dblMoveQty NUMERIC(38, 20)
	,@intUserId INT
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

	SELECT @intItemId = intItemId
		,@intLocationId = intLocationId
		,@intSubLocationId = intSubLocationId
		,@intStorageLocationId = intStorageLocationId
		,@strLotNumber = strLotNumber
		,@intLotStatusId = intLotStatusId
		,@intNewLocationId = intLocationId
		,@dblWeightPerQty = dblWeightPerQty
		,@intWeightUOMId = intWeightUOMId
	FROM tblICLot
	WHERE intLotId = @intLotId

	SELECT @intItemStockUOMId = intItemUOMId
	FROM dbo.tblICItemUOM
	WHERE intItemId = @intItemId
		AND ysnStockUnit = 1

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

	IF EXISTS (SELECT 1 FROM tblWHSKU WHERE intLotId = @intLotId)
	BEGIN
		RAISERROR(90008,11,1)
	END

	IF @intItemStockUOMId = @intWeightUOMId
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
