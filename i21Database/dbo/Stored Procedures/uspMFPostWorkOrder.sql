CREATE PROCEDURE uspMFPostWorkOrder (@strXML NVARCHAR(MAX))
AS
BEGIN TRY
	DECLARE @idoc INT
		,@ErrMsg NVARCHAR(MAX)
		,@dblProduceQty NUMERIC(18, 6)
		,@intItemUOMId INT
		,@strRetBatchId NVARCHAR(40)
		,@intBatchId INT
		,@intWorkOrderId INT
		,@ysnNegativeQtyAllowed BIT
		,@intUserId INT
		,@dtmCurrentDateTime DATETIME
		,@intTransactionCount INT

	SELECT @intTransactionCount = @@TRANCOUNT

	SELECT @dtmCurrentDateTime = Getdate()

	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@strXML

	SELECT @intWorkOrderId = intWorkOrderId
		,@ysnNegativeQtyAllowed = ysnNegativeQtyAllowed
		,@intUserId = intUserId
	FROM OPENXML(@idoc, 'root', 2) WITH (
			intWorkOrderId INT
			,ysnNegativeQtyAllowed BIT
			,intUserId INT
			)

	SELECT @dblProduceQty = SUM(dblQuantity)
		,@intItemUOMId = MIN(intItemUOMId)
	FROM dbo.tblMFWorkOrderProducedLot
	WHERE intWorkOrderId = @intWorkOrderId
		AND ysnProductionReversed = 0

	IF @intTransactionCount = 0
	BEGIN TRANSACTION

	EXEC dbo.uspMFValidatePostWorkOrder @intWorkOrderId = @intWorkOrderId
		,@ysnYieldAdjustmentAllowed = @ysnNegativeQtyAllowed
		,@intUserId = @intUserId

	DECLARE @ConsumptionReversal TABLE (
		RecordKey INT identity(1, 1)
		,intWorkOrderInputLotId INT
		)

	INSERT INTO @ConsumptionReversal (intWorkOrderInputLotId)
	SELECT IL.intWorkOrderInputLotId
	FROM dbo.tblMFWorkOrderInputLot IL
	WHERE IL.intWorkOrderId = @intWorkOrderId
		AND ysnConsumptionReversed = 1

	DECLARE @RecordKey INT
		,@intWorkOrderInputLotId INT
		,@intLotId INT
		,@strNewLotNumber NVARCHAR(50)
		,@intNewLocationId INT
		,@intNewSubLocationId INT
		,@intNewStorageLocationId INT
		,@dblNewWeight NUMERIC(18, 6)
		,@intNewItemUOMId INT
		,@dblWeightPerQty NUMERIC(18, 6)
		,@dblAdjustByQuantity NUMERIC(18, 6)
		,@intInventoryAdjustmentId INT
		,@intItemId INT
		,@intLocationId INT
		,@intStorageLocationId INT
		,@intInputItemId INT
		,@strLotNumber NVARCHAR(50)
		,@intSubLocationId INT
		,@intConsumptionMethodId INT
		,@intWeightUOMId INT

	SELECT @RecordKey = MIN(RecordKey)
	FROM @ConsumptionReversal

	WHILE @RecordKey IS NOT NULL
	BEGIN
		SELECT @intWorkOrderInputLotId = intWorkOrderInputLotId
		FROM @ConsumptionReversal
		WHERE RecordKey = @RecordKey

		SELECT @intLotId = intLotId
			,@intInputItemId = intItemId
			,@dblNewWeight = dblQuantity
			,@intNewItemUOMId = intItemUOMId
		FROM tblMFWorkOrderInputLot
		WHERE intWorkOrderInputLotId = @intWorkOrderInputLotId

		SELECT @intItemId = intItemId
			,@intLocationId = intLocationId
		FROM dbo.tblMFWorkOrder
		WHERE intWorkOrderId = @intWorkOrderId

		SELECT @intStorageLocationId = ri.intStorageLocationId
			,@intConsumptionMethodId = intConsumptionMethodId
		FROM dbo.tblMFWorkOrderRecipeItem ri
		WHERE ri.intWorkOrderId = @intWorkOrderId
			AND ri.intItemId = @intInputItemId
			AND ri.intRecipeItemTypeId = 1

		SELECT @strNewLotNumber = strLotNumber
			,@intNewLocationId = intLocationId
			,@intNewSubLocationId = intSubLocationId
			,@intNewStorageLocationId = intStorageLocationId
			,@dblWeightPerQty = dblWeightPerQty
		FROM dbo.tblICLot
		WHERE intLotId = @intLotId

		SELECT @strLotNumber = L.strLotNumber
			,@intLocationId = L.intLocationId
			,@intSubLocationId = L.intSubLocationId
			,@intStorageLocationId = L.intStorageLocationId
			,@intWeightUOMId = L.intWeightUOMId
		FROM dbo.tblICLot L
		JOIN dbo.tblICStorageLocation SL ON SL.intStorageLocationId = L.intStorageLocationId
			AND SL.ysnAllowConsume = 1
		WHERE L.intItemId = @intInputItemId
			AND L.intLocationId = @intLocationId
			AND L.intLotStatusId = 1
			AND dtmExpiryDate >= @dtmCurrentDateTime
			AND L.intStorageLocationId = (
				CASE 
					WHEN @intStorageLocationId IS NULL
						THEN L.intStorageLocationId
					ELSE (
							CASE 
								WHEN @intConsumptionMethodId = 2
									THEN @intStorageLocationId
								ELSE L.intStorageLocationId
								END
							) --By location, then apply location filter
					END
				)
			AND L.dblQty > 0
		ORDER BY L.dtmDateCreated ASC

		SELECT @dblAdjustByQuantity = - @dblNewWeight / (
				CASE 
					WHEN @intWeightUOMId IS NULL
						THEN 1
					ELSE @dblWeightPerQty
					END
				)

		EXEC uspICInventoryAdjustment_CreatePostLotMove
			-- Parameters for filtering:
			@intItemId = @intInputItemId
			,@dtmDate = @dtmCurrentDateTime
			,@intLocationId = @intLocationId
			,@intSubLocationId = @intSubLocationId
			,@intStorageLocationId = @intStorageLocationId
			,@strLotNumber = @strLotNumber
			-- Parameters for the new values: 
			,@intNewLocationId = @intNewLocationId
			,@intNewSubLocationId = @intNewSubLocationId
			,@intNewStorageLocationId = @intNewStorageLocationId
			,@strNewLotNumber = @strNewLotNumber
			,@dblMoveQty = @dblAdjustByQuantity
			-- Parameters used for linking or FK (foreign key) relationships
			,@intSourceId = 1
			,@intSourceTransactionTypeId = 8
			,@intUserId = @intUserId
			,@intInventoryAdjustmentId = @intInventoryAdjustmentId OUTPUT

		SELECT @RecordKey = MIN(RecordKey)
		FROM @ConsumptionReversal
		WHERE RecordKey > @RecordKey
	END

	EXEC dbo.uspMFPickWorkOrder @intWorkOrderId = @intWorkOrderId
		,@dblProduceQty = @dblProduceQty
		,@intProduceUOMKey = @intItemUOMId
		,@intBatchId = @intBatchId
		,@intUserId = @intUserId

	EXEC dbo.uspMFConsumeWorkOrder @intWorkOrderId = @intWorkOrderId
		,@dblProduceQty = @dblProduceQty
		,@intProduceUOMKey = @intItemUOMId
		,@intUserId = @intUserId
		,@ysnNegativeQtyAllowed = @ysnNegativeQtyAllowed
		,@strRetBatchId = @strRetBatchId OUTPUT
		,@ysnPostConsumption = 1

	EXEC dbo.uspMFCalculateYield @intWorkOrderId = @intWorkOrderId
		,@ysnYieldAdjustmentAllowed = @ysnNegativeQtyAllowed
		,@intUserId = @intUserId
	
	IF @intTransactionCount = 0
	COMMIT TRANSACTION

	EXEC sp_xml_removedocument @idoc
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	IF XACT_STATE() != 0 AND @intTransactionCount = 0
		ROLLBACK TRANSACTION

	IF @idoc <> 0
		EXEC sp_xml_removedocument @idoc

	RAISERROR (
			@ErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH
