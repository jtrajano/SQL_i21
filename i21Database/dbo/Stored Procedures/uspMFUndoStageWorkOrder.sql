CREATE PROCEDURE uspMFUndoStageWorkOrder (@strXML NVARCHAR(MAX))
AS
BEGIN TRY
	DECLARE @idoc INT
		,@ErrMsg NVARCHAR(MAX)
		,@intWorkOrderId INT
		,@intWorkOrderInputLotId INT
		,@ysnNegativeQtyAllowed BIT
		,@intUserId INT
		,@dtmCurrentDateTime DATETIME
		,@intTransactionCount INT

	SELECT @intTransactionCount = @@TRANCOUNT

	SELECT @dtmCurrentDateTime = Getdate()

	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@strXML

	SELECT @intWorkOrderId = intWorkOrderId
		,@intWorkOrderInputLotId = intWorkOrderInputLotId
		,@ysnNegativeQtyAllowed = ysnNegativeQtyAllowed
		,@intUserId = intUserId
	FROM OPENXML(@idoc, 'root', 2) WITH (
			intWorkOrderId INT
			,intWorkOrderInputLotId INT
			,ysnNegativeQtyAllowed BIT
			,intUserId INT
			)
	IF @intTransactionCount = 0
	BEGIN TRANSACTION

	DECLARE @RecordKey INT
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
		,@intRecipeId INT
		,@intStorageLocationId INT
		,@intInputItemId INT
		,@strLotNumber NVARCHAR(50)
		,@intSubLocationId INT
		,@intConsumptionMethodId INT
		,@intWeightUOMId INT

	SELECT @intLotId = intLotId
		,@intInputItemId = intItemId
		,@dblNewWeight = dblQuantity
		,@intNewItemUOMId = intItemUOMId
		,@intNewStorageLocationId = intStorageLocationId
	FROM tblMFWorkOrderInputLot
	WHERE intWorkOrderInputLotId = @intWorkOrderInputLotId

	SELECT @intItemId = intItemId
		,@intLocationId = intLocationId
	FROM dbo.tblMFWorkOrder
	WHERE intWorkOrderId = @intWorkOrderId

	SELECT @intRecipeId = intRecipeId
	FROM dbo.tblMFRecipe a
	WHERE a.intItemId = @intItemId
		AND a.intLocationId = @intLocationId
		AND ysnActive = 1

	SELECT @intStorageLocationId = ri.intStorageLocationId
		,@intConsumptionMethodId = intConsumptionMethodId
	FROM dbo.tblMFRecipeItem ri
	WHERE ri.intRecipeId = @intRecipeId
		AND ri.intItemId = @intInputItemId
		AND ri.intRecipeItemTypeId = 1

	SELECT @strNewLotNumber = strLotNumber
		,@dblWeightPerQty = dblWeightPerQty
	FROM dbo.tblICLot
	WHERE intLotId = @intLotId

	SELECT @intNewLocationId = intLocationId
		,@intNewSubLocationId = intSubLocationId
	FROM tblICStorageLocation
	WHERE intStorageLocationId = @intNewStorageLocationId

	SELECT TOP 1 @strLotNumber = L.strLotNumber
		,@intLocationId = L.intLocationId
		,@intSubLocationId = L.intSubLocationId
		,@intStorageLocationId = L.intStorageLocationId
		,@intWeightUOMId = L.intWeightUOMId
	FROM dbo.tblICLot L
	JOIN dbo.tblICStorageLocation SL ON SL.intStorageLocationId = L.intStorageLocationId
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
	ORDER BY L.dblQty
		,L.dtmDateCreated ASC

	SELECT @dblAdjustByQuantity = - @dblNewWeight / (
			CASE 
				WHEN @intWeightUOMId IS NULL
					THEN 1
				ELSE @dblWeightPerQty
				END
			)

	EXEC uspICInventoryAdjustment_CreatePostLotMerge
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
		,@dblNewWeight = NULL
		,@intNewItemUOMId = @intNewItemUOMId
		,@intNewWeightUOMId = NULL
		,@dblNewUnitCost = NULL
		-- Parameters used for linking or FK (foreign key) relationships
		,@intSourceId = 1
		,@intSourceTransactionTypeId = 8
		,@intUserId = @intUserId
		,@intInventoryAdjustmentId = @intInventoryAdjustmentId OUTPUT

	UPDATE tblMFWorkOrderInputLot
	SET ysnConsumptionReversed = 1
		,dtmLastModified = @dtmCurrentDateTime
		,intLastModifiedUserId = @intUserId
	WHERE intWorkOrderInputLotId = @intWorkOrderId
	
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
