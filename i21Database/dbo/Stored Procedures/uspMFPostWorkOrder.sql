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
		,@dtmCurrentDateTime datetime

	Select @dtmCurrentDateTime=Getdate()

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

	BEGIN TRANSACTION

	EXEC dbo.uspMFValidatePostWorkOrder @intWorkOrderId = @intWorkOrderId
		,@ysnYieldAdjustmentAllowed = @ysnNegativeQtyAllowed
		,@intUserId = @intUserId

	Declare @ConsumptionReversal table(RecordKey int identity(1,1),intWorkOrderInputLotId int)

	Insert into @ConsumptionReversal(intWorkOrderInputLotId)
	Select IL.intWorkOrderInputLotId 
	From dbo.tblMFWorkOrderInputLot IL
	Where IL.intWorkOrderId=@intWorkOrderId AND ysnConsumptionReversed=1

	Declare @RecordKey int,@intWorkOrderInputLotId int,@intLotId int,@strNewLotNumber nvarchar(50),@intNewLocationId int,@intNewSubLocationId int,@intNewStorageLocationId int
			,@dblNewWeight numeric(18,6),@intNewItemUOMId int,@dblWeightPerQty numeric(18,6),@dblAdjustByQuantity numeric(18,6),@intInventoryAdjustmentId int,@intItemId int
			,@intLocationId int,@intRecipeId int,@intStorageLocationId int,@intInputItemId int,@strLotNumber nvarchar(50),@intSubLocationId int,@intConsumptionMethodId int

	Select @RecordKey=MIN(RecordKey) from @ConsumptionReversal
	While @RecordKey is not null
	Begin
		Select @intWorkOrderInputLotId=intWorkOrderInputLotId from @ConsumptionReversal Where RecordKey=@RecordKey

		Select @intLotId=intLotId,
			@intInputItemId=intItemId,
			@dblNewWeight=dblQuantity,
			@intNewItemUOMId=intItemUOMId
		From tblMFWorkOrderInputLot
		Where intWorkOrderInputLotId=@intWorkOrderInputLotId

		SELECT @intItemId = intItemId
			,@intLocationId = intLocationId
		FROM dbo.tblMFWorkOrder
		WHERE intWorkOrderId = @intWorkOrderId

		SELECT @intRecipeId = intRecipeId
		FROM dbo.tblMFRecipe a
		WHERE a.intItemId = @intItemId
		AND a.intLocationId = @intLocationId
		AND ysnActive = 1

		SELECT @intStorageLocationId=ri.intStorageLocationId,
				@intConsumptionMethodId=intConsumptionMethodId
		FROM dbo.tblMFRecipeItem ri
		JOIN dbo.tblMFRecipe r ON r.intRecipeId = ri.intRecipeId
		WHERE ri.intRecipeId = @intRecipeId and ri.intItemId =@intInputItemId 
		AND ri.intRecipeItemTypeId = 1

		Select @strNewLotNumber=strLotNumber,
			@intNewLocationId=intLocationId,
			@intNewSubLocationId=intSubLocationId,
			@intNewStorageLocationId=intStorageLocationId,
			@dblWeightPerQty=dblWeightPerQty
		From dbo.tblICLot 
		Where intLotId=@intLotId

		Select 
			@strLotNumber=L.strLotNumber,
			@intLocationId=L.intLocationId,
			@intSubLocationId=L.intSubLocationId,
			@intStorageLocationId=L.intStorageLocationId
		FROM dbo.tblICLot L
		JOIN dbo.tblICStorageLocation SL ON SL.intStorageLocationId =L.intStorageLocationId  and SL.ysnAllowConsume =1
		WHERE L.intItemId = @intInputItemId
			AND L.intLocationId=@intLocationId
			AND L.intLotStatusId=1
			AND dtmExpiryDate >= @dtmCurrentDateTime
			AND L.intStorageLocationId = (
				CASE 
					WHEN @intStorageLocationId IS NULL
						THEN L.intStorageLocationId
					ELSE (Case When @intConsumptionMethodId=2 Then @intStorageLocationId Else L.intStorageLocationId End)--By location, then apply location filter
					END
				)
			AND L.dblWeight > 0
		ORDER BY L.dtmDateCreated ASC

		Select @dblAdjustByQuantity = -@dblNewWeight/(Case When @dblWeightPerQty=0 Then 1 Else @dblWeightPerQty End)

		EXEC [uspICInventoryAdjustment_CreatePostSplitLot]
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
			,@dblAdjustByQuantity = @dblAdjustByQuantity
			,@dblNewSplitLotQuantity = 0
			,@dblNewWeight = @dblNewWeight
			,@intNewItemUOMId = @intNewItemUOMId
			,@intNewWeightUOMId = @intNewItemUOMId
			,@dblNewUnitCost = NULL
			-- Parameters used for linking or FK (foreign key) relationships
			,@intSourceId = 1
			,@intSourceTransactionTypeId = 8
			,@intUserId = @intUserId
			,@intInventoryAdjustmentId = @intInventoryAdjustmentId OUTPUT

		Select @RecordKey=MIN(RecordKey) from @ConsumptionReversal Where RecordKey>@RecordKey
	End	

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

	EXEC dbo.uspMFCalculateYield @intWorkOrderId = @intWorkOrderId
		,@ysnYieldAdjustmentAllowed = @ysnNegativeQtyAllowed
		,@intUserId = @intUserId

	COMMIT TRANSACTION

	EXEC sp_xml_removedocument @idoc
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	IF XACT_STATE() != 0
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
