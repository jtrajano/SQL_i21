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
		,@dblNewWeight NUMERIC(38, 20)
		,@intNewItemUOMId INT
		,@dblWeightPerQty NUMERIC(38, 20)
		,@dblAdjustByQuantity NUMERIC(38, 20)
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
		,@intItemUOMId INT
		,@strInventoryTracking NVARCHAR(50)
		,@strTransferNo NVARCHAR(50)
		,@intInventoryTransferId INT
		,@intMachineId INT
		,@intManufacturingProcessId INT
		,@intProductionStageLocationId INT
		,@intProductionStagingId INT
		,@strStagedLotNumber NVARCHAR(50)

	SELECT @intLotId = intLotId
		,@intInputItemId = intItemId
		,@dblNewWeight = dblQuantity
		,@intNewItemUOMId = intItemUOMId
		,@intNewStorageLocationId = intStorageLocationId
		,@intMachineId = intMachineId
	FROM tblMFWorkOrderInputLot
	WHERE intWorkOrderInputLotId = @intWorkOrderInputLotId

	SELECT @strStagedLotNumber = strLotNumber
	FROM tblICLot
	WHERE intLotId = @intLotId

	SELECT @strInventoryTracking = strInventoryTracking
	FROM dbo.tblICItem
	WHERE intItemId = @intInputItemId

	IF @strInventoryTracking = 'Lot Level'
	BEGIN
		SELECT @intItemId = intItemId
			,@intLocationId = intLocationId
			,@intManufacturingProcessId = intManufacturingProcessId
		FROM dbo.tblMFWorkOrder
		WHERE intWorkOrderId = @intWorkOrderId

		SELECT @intStorageLocationId = ri.intStorageLocationId
			,@intConsumptionMethodId = intConsumptionMethodId
		FROM dbo.tblMFWorkOrderRecipeItem ri
		WHERE ri.intWorkOrderId = @intWorkOrderId
			AND ri.intItemId = @intInputItemId
			AND ri.intRecipeItemTypeId = 1

		IF @intConsumptionMethodId IS NULL
		BEGIN
			SELECT @intStorageLocationId = ri.intStorageLocationId
				,@intConsumptionMethodId = ri.intConsumptionMethodId
			FROM dbo.tblMFWorkOrderRecipeSubstituteItem rs
			JOIN dbo.tblMFWorkOrderRecipeItem ri ON ri.intRecipeItemId = rs.intRecipeItemId
			WHERE rs.intWorkOrderId = @intWorkOrderId
				AND rs.intSubstituteItemId = @intInputItemId
				AND rs.intRecipeItemTypeId = 1
		END

		SELECT @strNewLotNumber = strLotNumber
			,@dblWeightPerQty = dblWeightPerQty
			,@intItemUOMId=intItemUOMId
		FROM dbo.tblICLot
		WHERE intLotId = @intLotId

		SELECT @intNewLocationId = intLocationId
			,@intNewSubLocationId = intSubLocationId
		FROM tblICStorageLocation
		WHERE intStorageLocationId = @intNewStorageLocationId

		SELECT @intProductionStageLocationId = intProductionStagingLocationId
		FROM tblMFManufacturingProcessMachine
		WHERE intManufacturingProcessId = @intManufacturingProcessId
			AND intMachineId = @intMachineId

		IF @intProductionStageLocationId IS NULL
		BEGIN
			SELECT @intProductionStagingId = intAttributeId
			FROM tblMFAttribute
			WHERE strAttributeName = 'Production Staging Location'

			SELECT @intProductionStageLocationId = strAttributeValue
			FROM tblMFManufacturingProcessAttribute
			WHERE intManufacturingProcessId = @intManufacturingProcessId
				AND intLocationId = @intLocationId
				AND intAttributeId = @intProductionStagingId
		END

		SELECT @strLotNumber = NULL

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
			AND ISNULL(dtmExpiryDate, @dtmCurrentDateTime) >= @dtmCurrentDateTime
			AND L.intStorageLocationId = (
				CASE 
					WHEN @intStorageLocationId IS NULL
						AND @intProductionStageLocationId IS NULL
						THEN L.intStorageLocationId
					ELSE (
							CASE 
								WHEN @intConsumptionMethodId = 1
									THEN @intProductionStageLocationId
								WHEN @intConsumptionMethodId = 2
									THEN @intStorageLocationId
								ELSE L.intStorageLocationId
								END
							) --By location, then apply location filter
					END
				)
			AND L.strLotNumber = @strStagedLotNumber
		ORDER BY L.dblQty DESC
			,L.dtmDateCreated ASC

		IF @strLotNumber IS NULL
		BEGIN
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
				AND ISNULL(dtmExpiryDate, @dtmCurrentDateTime) >= @dtmCurrentDateTime
				AND L.intStorageLocationId = (
					CASE 
						WHEN @intStorageLocationId IS NULL
							AND @intProductionStageLocationId IS NULL
							THEN L.intStorageLocationId
						ELSE (
								CASE 
									WHEN @intConsumptionMethodId = 1
										THEN @intProductionStageLocationId
									WHEN @intConsumptionMethodId = 2
										THEN @intStorageLocationId
									ELSE L.intStorageLocationId
									END
								) --By location, then apply location filter
						END
					)
			ORDER BY L.dblQty DESC
				,L.dtmDateCreated ASC
		END

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
			,@intNewItemUOMId = NULL
			,@intNewWeightUOMId = NULL
			,@dblNewUnitCost = NULL
			,@intItemUOMId = @intNewItemUOMId
			-- Parameters used for linking or FK (foreign key) relationships
			,@intSourceId = 1
			,@intSourceTransactionTypeId = 8
			,@intEntityUserSecurityId = @intUserId
			,@intInventoryAdjustmentId = @intInventoryAdjustmentId OUTPUT
	END
	ELSE
	BEGIN
		SELECT @intInventoryTransferId = intInventoryTransferId
		FROM dbo.tblICInventoryTransferDetail
		WHERE intSourceId = @intWorkOrderInputLotId

		SELECT @strTransferNo = strTransferNo
		FROM dbo.tblICInventoryTransfer
		WHERE intInventoryTransferId = @intInventoryTransferId

		EXEC dbo.uspICPostInventoryTransfer 0
			,0
			,@strTransferNo
			,@intUserId;
	END

	UPDATE tblMFWorkOrderInputLot
	SET ysnConsumptionReversed = 1
		,dtmLastModified = @dtmCurrentDateTime
		,intLastModifiedUserId = @intUserId
	WHERE intWorkOrderInputLotId = @intWorkOrderInputLotId

	UPDATE tblMFProductionSummary
	SET dblInputQuantity = dblInputQuantity - @dblNewWeight
	WHERE intWorkOrderId = @intWorkOrderId
		AND intItemId = @intInputItemId

	IF @intTransactionCount = 0
		COMMIT TRANSACTION

	EXEC sp_xml_removedocument @idoc
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	IF XACT_STATE() != 0
		AND @intTransactionCount = 0
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
