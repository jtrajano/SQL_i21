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
		,@ItemsToReserve AS dbo.ItemReservationTableType
		,@intInventoryTransactionType AS INT = 8
		,@intRecipeItemUOMId INT

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
		,@strWorkOrderNo NVARCHAR(50)
		,@dtmProductionDate DATETIME

	SELECT @strWorkOrderNo = strWorkOrderNo
	FROM dbo.tblMFWorkOrder
	WHERE intWorkOrderId = @intWorkOrderId

	SELECT @intLotId = intLotId
		,@intInputItemId = intItemId
		,@dblNewWeight = dblQuantity
		,@intNewItemUOMId = intItemUOMId
		,@intNewStorageLocationId = intStorageLocationId
		,@intMachineId = intMachineId
		,@dtmProductionDate = dtmProductionDate
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
			,@intItemUOMId = intItemUOMId
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

		SELECT @dblAdjustByQuantity = - @dblNewWeight

		IF @dblWeightPerQty = 0
			OR @dblNewWeight % @dblWeightPerQty > 0
		BEGIN
			SELECT @dblAdjustByQuantity = - @dblNewWeight
				,@intNewItemUOMId = @intNewItemUOMId
		END
		ELSE
		BEGIN
			SELECT @dblAdjustByQuantity = - @dblNewWeight / @dblWeightPerQty
				,@intNewItemUOMId = @intItemUOMId
		END

		IF NOT EXISTS (
				SELECT *
				FROM tblICLot
				WHERE strLotNumber = @strLotNumber
					AND intStorageLocationId = @intStorageLocationId
					AND (
						intItemUOMId = @intNewItemUOMId
						OR IsNULL(intWeightUOMId, intItemUOMId) = @intNewItemUOMId
						)
				)
		BEGIN
			SELECT @dblAdjustByQuantity = - dbo.fnMFConvertQuantityToTargetItemUOM(@intNewItemUOMId, @intItemUOMId, @dblNewWeight)

			SELECT @intNewItemUOMId = @intItemUOMId
		END

		EXEC dbo.uspICCreateStockReservation @ItemsToReserve
			,@intWorkOrderId
			,@intInventoryTransactionType

		EXEC uspICInventoryAdjustment_CreatePostLotMerge
			-- Parameters for filtering:
			@intItemId = @intInputItemId
			,@dtmDate = @dtmProductionDate
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
			,@dblNewSplitLotQuantity = NULL
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

	SELECT @intRecipeItemUOMId = RI.intItemUOMId
	FROM tblMFWorkOrderRecipeItem RI
	WHERE RI.intWorkOrderId = @intWorkOrderId
		AND RI.intItemId = @intInputItemId

	IF @intRecipeItemUOMId IS NULL
	BEGIN
		SELECT @intRecipeItemUOMId = RS.intItemUOMId
		FROM tblMFWorkOrderRecipeSubstituteItem RS
		WHERE RS.intWorkOrderId = @intWorkOrderId
			AND RS.intSubstituteItemId = @intInputItemId
	END

	SELECT @dblAdjustByQuantity = abs(@dblAdjustByQuantity)

	UPDATE tblMFProductionSummary
	SET dblInputQuantity = dblInputQuantity - IsNULL(dbo.fnMFConvertQuantityToTargetItemUOM(@intNewItemUOMId, @intRecipeItemUOMId, @dblAdjustByQuantity), 0)
	WHERE intWorkOrderId = @intWorkOrderId
		AND intItemId = @intInputItemId
		AND IsNULL(intMachineId, 0) = CASE 
			WHEN intMachineId IS NOT NULL
				THEN IsNULL(@intMachineId, 0)
			ELSE IsNULL(intMachineId, 0)
			END

	SELECT @intLotId = NULL

	SELECT TOP 1 @intLotId = intLotId
	FROM tblICLot
	WHERE strLotNumber = @strNewLotNumber
		AND intStorageLocationId = @intNewStorageLocationId

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
	SELECT intItemId = WI.intItemId
		,intItemLocationId = IL.intItemLocationId
		,intItemUOMId = WI.intItemIssuedUOMId
		,intLotId = (
			SELECT TOP 1 intLotId
			FROM tblICLot L1
			WHERE L1.strLotNumber = L.strLotNumber
				AND L1.intStorageLocationId = @intStorageLocationId
			)
		,intSubLocationId = @intSubLocationId
		,intStorageLocationId = @intStorageLocationId
		,dblQty = SUM(WI.dblIssuedQuantity)
		,intTransactionId = @intWorkOrderId
		,strTransactionId = @strWorkOrderNo
		,intTransactionTypeId = @intInventoryTransactionType
	FROM tblMFWorkOrderInputLot WI
	JOIN tblICItemLocation IL ON IL.intItemId = WI.intItemId
		AND IL.intLocationId = @intLocationId
		AND WI.ysnConsumptionReversed = 0
	JOIN tblICLot L ON L.intLotId = WI.intLotId
	WHERE intWorkOrderId = @intWorkOrderId
	GROUP BY WI.intItemId
		,IL.intItemLocationId
		,WI.intItemIssuedUOMId
		,L.strLotNumber

	EXEC dbo.uspICCreateStockReservation @ItemsToReserve
		,@intWorkOrderId
		,@intInventoryTransactionType

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
