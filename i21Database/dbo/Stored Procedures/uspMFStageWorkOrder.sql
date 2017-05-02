CREATE PROCEDURE [dbo].[uspMFStageWorkOrder] (@strXML NVARCHAR(MAX))
AS
BEGIN TRY
	DECLARE @idoc INT
		,@ErrMsg NVARCHAR(MAX)
		,@intLocationId INT
		,@intSubLocationId INT
		,@intManufacturingProcessId INT
		,@intMachineId INT
		,@intWorkOrderId INT
		,@dtmPlannedDate DATETIME
		,@intPlannedShiftId INT
		,@intItemId INT
		,@intStorageLocationId INT
		,@intInputLotId INT
		,@intInputItemId INT
		,@dblWeight NUMERIC(38, 20)
		,@dblInputWeight NUMERIC(38, 20)
		,@dblReadingQuantity NUMERIC(38, 20)
		,@intInputWeightUOMId INT
		,@intUserId INT
		,@ysnEmptyOut BIT
		,@intContainerId INT
		,@strReferenceNo NVARCHAR(50)
		,@dtmActualInputDateTime DATETIME
		,@intShiftId INT
		,@ysnNegativeQuantityAllowed BIT
		,@ysnExcessConsumptionAllowed BIT
		,@strItemNo NVARCHAR(50)
		,@strInputItemNo NVARCHAR(50)
		,@intConsumptionMethodId INT
		,@intConsumptionStorageLocationId INT
		,@dblDefaultResidueQty NUMERIC(38, 20)
		,@dblNewWeight NUMERIC(38, 20)
		,@intDestinationLotId INT
		,@strLotNumber NVARCHAR(50)
		,@strLotTracking NVARCHAR(50)
		,@intItemLocationId INT
		,@dtmCurrentDateTime DATETIME
		,@dblAdjustByQuantity NUMERIC(18, 6)
		,@intInventoryAdjustmentId INT
		,@intNewItemUOMId INT
		,@dblWeightPerQty NUMERIC(18, 6)
		,@strDestinationLotNumber NVARCHAR(50)
		,@intConsumptionSubLocationId INT
		,@intWeightUOMId INT
		,@intTransactionCount INT
		,@strWorkOrderNo NVARCHAR(50)
		,@strProcessName NVARCHAR(50)
		,@dtmBusinessDate DATETIME
		,@intBusinessShiftId INT
		,@intManufacturingCellId INT
		,@strInventoryTracking NVARCHAR(50)
		,@intWorkOrderInputLotId INT
		,@intProductionStagingId INT
		,@intProductionStageLocationId INT

	SELECT @intTransactionCount = @@TRANCOUNT

	SELECT @dtmCurrentDateTime = GetDate()

	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@strXML

	SELECT @intLocationId = intLocationId
		,@intSubLocationId = intSubLocationId
		,@intManufacturingProcessId = intManufacturingProcessId
		,@intMachineId = intMachineId
		,@intWorkOrderId = intWorkOrderId
		--,@dtmPlannedDate = dtmPlannedDate
		,@intPlannedShiftId = intPlannedShiftId
		,@intItemId = intItemId
		,@intStorageLocationId = intStorageLocationId
		,@intInputLotId = intInputLotId
		,@intInputItemId = intInputItemId
		,@dblInputWeight = dblInputWeight
		,@dblReadingQuantity = dblReadingQuantity
		,@intInputWeightUOMId = intInputWeightUOMId
		,@intUserId = intUserId
		,@ysnEmptyOut = ysnEmptyOut
		,@intContainerId = intContainerId
		,@strReferenceNo = strReferenceNo
		,@dtmActualInputDateTime = dtmActualInputDateTime
		,@intShiftId = intShiftId
		,@ysnNegativeQuantityAllowed = ysnNegativeQuantityAllowed
		,@ysnExcessConsumptionAllowed = ysnExcessConsumptionAllowed
		,@dblDefaultResidueQty = dblDefaultResidueQty
	FROM OPENXML(@idoc, 'root', 2) WITH (
			intLocationId INT
			,intSubLocationId INT
			,intManufacturingProcessId INT
			,intMachineId INT
			,intWorkOrderId INT
			--,dtmPlannedDate DATETIME
			,intPlannedShiftId INT
			,intItemId INT
			,intStorageLocationId INT
			,intInputLotId INT
			,intInputItemId INT
			,dblInputWeight NUMERIC(38, 20)
			,dblReadingQuantity NUMERIC(38, 20)
			,intInputWeightUOMId INT
			,intUserId INT
			,ysnEmptyOut BIT
			,intContainerId INT
			,strReferenceNo NVARCHAR(50)
			,dtmActualInputDateTime DATETIME
			,intShiftId INT
			,ysnNegativeQuantityAllowed BIT
			,ysnExcessConsumptionAllowed BIT
			,dblDefaultResidueQty NUMERIC(38, 20)
			)

	SELECT @strInventoryTracking = strInventoryTracking
	FROM dbo.tblICItem
	WHERE intItemId = @intInputItemId

	IF @strInventoryTracking = 'Lot Level'
	BEGIN
		IF @intInputLotId IS NULL
			OR @intInputLotId = 0
		BEGIN
			RAISERROR (
					51112
					,14
					,1
					)
		END

		SELECT @strLotNumber = strLotNumber
			,@intInputLotId = intLotId
			,@dblWeight = (
				CASE 
					WHEN intWeightUOMId IS NOT NULL
						THEN dblWeight
					ELSE dblQty
					END
				)
			,@intNewItemUOMId = intItemUOMId
			,@dblWeightPerQty = (
				CASE 
					WHEN dblWeightPerQty IS NULL
						OR dblWeightPerQty = 0
						THEN 1
					ELSE dblWeightPerQty
					END
				)
			,@intWeightUOMId = intWeightUOMId
		FROM tblICLot
		WHERE intLotId = @intInputLotId
		
		IF @dblInputWeight > @dblWeight
		BEGIN
			IF @ysnExcessConsumptionAllowed = 0
			BEGIN
				RAISERROR (
						'The quantity to be consumed must not exceed the selected lot quantity.'
						,14
						,1
						)
			END 
		END

		IF @intInputLotId IS NULL
			OR @intInputLotId = 0
		BEGIN
			RAISERROR (
					51113
					,14
					,1
					)
		END

		IF @dblWeight <= 0
			AND @ysnNegativeQuantityAllowed = 0
		BEGIN
			RAISERROR (
					51110
					,14
					,1
					)
		END
	END

	SELECT TOP 1 @dtmPlannedDate = dtmPlannedDate
	FROM dbo.tblMFWorkOrder
	WHERE intWorkOrderId = @intWorkOrderId

	IF @intWorkOrderId IS NULL
		OR @intWorkOrderId = 0
	BEGIN
		SELECT TOP 1 @intWorkOrderId = intWorkOrderId
		FROM dbo.tblMFWorkOrder
		WHERE intItemId = @intItemId
			AND dtmPlannedDate = @dtmPlannedDate
			AND intPlannedShiftId = @intPlannedShiftId
			AND intStatusId = 10
			AND intLocationId = @intLocationId
		ORDER BY dtmCreated

		IF @intWorkOrderId IS NULL
		BEGIN
			SELECT @strItemNo = strItemNo
			FROM dbo.tblICItem
			WHERE intItemId = @intItemId

			RAISERROR (
					51111
					,14
					,1
					,@strItemNo
					)
		END
	END

	SELECT @intProductionStagingId = intAttributeId
	FROM tblMFAttribute
	WHERE strAttributeName = 'Production Staging Location'

	SELECT @intProductionStageLocationId = strAttributeValue
	FROM tblMFManufacturingProcessAttribute
	WHERE intManufacturingProcessId = @intManufacturingProcessId
		AND intLocationId = @intLocationId
		AND intAttributeId = @intProductionStagingId

	SELECT @intConsumptionMethodId = RI.intConsumptionMethodId
		,@intConsumptionStorageLocationId = CASE 
			WHEN RI.intConsumptionMethodId = 1
				THEN @intProductionStageLocationId
			ELSE RI.intStorageLocationId
			END
	FROM dbo.tblMFWorkOrderRecipeItem RI
	LEFT JOIN dbo.tblMFWorkOrderRecipeSubstituteItem RS ON RS.intRecipeItemId = RI.intRecipeItemId
	WHERE RI.intWorkOrderId = @intWorkOrderId
		AND RI.intRecipeItemTypeId = 1
		AND (
			RI.intItemId = @intInputItemId
			OR RS.intSubstituteItemId = @intInputItemId
			)

	SELECT @intConsumptionSubLocationId = intSubLocationId
	FROM dbo.tblICStorageLocation
	WHERE intStorageLocationId = @intConsumptionStorageLocationId

	IF @intInputItemId IS NULL
		OR @intInputItemId = 0
	BEGIN
		SELECT @strItemNo = strItemNo
		FROM dbo.tblICItem
		WHERE intItemId = @intItemId

		SELECT @strInputItemNo = strItemNo
		FROM dbo.tblICItem
		WHERE intItemId = @intInputItemId

		RAISERROR (
				51114
				,14
				,1
				,@strInputItemNo
				,@strItemNo
				)
	END

	IF @intConsumptionMethodId = 1
		AND (
			@intConsumptionStorageLocationId IS NULL
			OR @intConsumptionStorageLocationId = 0
			)
	BEGIN
		RAISERROR (
				51115
				,14
				,1
				)
	END

	IF NOT EXISTS (
			SELECT *
			FROM dbo.tblMFWorkOrder W
			WHERE intWorkOrderId = @intWorkOrderId
				AND intManufacturingProcessId = @intManufacturingProcessId
			)
	BEGIN
		SELECT @strWorkOrderNo = strWorkOrderNo
			,@intManufacturingCellId = intManufacturingCellId
		FROM dbo.tblMFWorkOrder
		WHERE intWorkOrderId = @intWorkOrderId

		SELECT @strProcessName = strProcessName
		FROM dbo.tblMFManufacturingProcess
		WHERE intManufacturingProcessId = @intManufacturingProcessId

		RAISERROR (
				51155
				,11
				,1
				,@strLotNumber
				,@strWorkOrderNo
				,@strProcessName
				)
	END

	IF EXISTS (
			SELECT *
			FROM dbo.tblMFWorkOrder W
			WHERE intWorkOrderId = @intWorkOrderId
				AND W.intStatusId = 13
			)
	BEGIN
		RAISERROR (
				51079
				,11
				,1
				)
	END

	IF EXISTS (
			SELECT *
			FROM dbo.tblMFWorkOrder W
			WHERE intWorkOrderId = @intWorkOrderId
				AND W.intStatusId = 11
			)
	BEGIN
		RAISERROR (
				51080
				,11
				,1
				)
	END

	IF NOT EXISTS (
			SELECT *
			FROM dbo.tblMFWorkOrder W
			WHERE intWorkOrderId = @intWorkOrderId
				AND W.intStatusId = 10
			)
	BEGIN
		RAISERROR (
				51081
				,11
				,1
				)
	END

	IF @intTransactionCount = 0
		BEGIN TRANSACTION

	SELECT @dtmBusinessDate = dbo.fnGetBusinessDate(@dtmCurrentDateTime, @intLocationId)

	SELECT @intBusinessShiftId = intShiftId
	FROM dbo.tblMFShift
	WHERE intLocationId = @intLocationId
		AND @dtmCurrentDateTime BETWEEN @dtmBusinessDate + dtmShiftStartTime + intStartOffset
			AND @dtmBusinessDate + dtmShiftEndTime + intEndOffset

	INSERT INTO dbo.tblMFWorkOrderInputLot (
		intWorkOrderId
		,intItemId
		,intLotId
		,dblQuantity
		,intItemUOMId
		,dblIssuedQuantity
		,intItemIssuedUOMId
		,intSequenceNo
		,dtmProductionDate
		,intShiftId
		,intStorageLocationId
		,intMachineId
		,ysnConsumptionReversed
		,intContainerId
		,strReferenceNo
		,dtmActualInputDateTime
		,dtmBusinessDate
		,intBusinessShiftId
		,dtmCreated
		,intCreatedUserId
		,dtmLastModified
		,intLastModifiedUserId
		)
	SELECT @intWorkOrderId
		,@intInputItemId
		,@intInputLotId
		,@dblInputWeight
		,@intInputWeightUOMId
		,@dblInputWeight
		,@intInputWeightUOMId
		,1
		,@dtmPlannedDate
		,@intPlannedShiftId
		,@intStorageLocationId
		,@intMachineId
		,0
		,@intContainerId
		,@strReferenceNo
		,@dtmActualInputDateTime
		,@dtmBusinessDate
		,@intBusinessShiftId
		,@dtmCurrentDateTime
		,@intUserId
		,@dtmCurrentDateTime
		,@intUserId

	SELECT @intWorkOrderInputLotId = SCOPE_IDENTITY()

	IF @strInventoryTracking = 'Lot Level'
	BEGIN
		SET @dblNewWeight = CASE 
				WHEN @ysnEmptyOut = 0
					THEN CASE 
							WHEN @dblInputWeight >= @dblWeight
								THEN @dblWeight + @dblDefaultResidueQty
							ELSE @dblInputWeight
							END
				ELSE @dblInputWeight
				END

		IF @dblNewWeight > @dblWeight
		BEGIN
			IF @ysnExcessConsumptionAllowed = 0
			BEGIN
				RAISERROR (
						51116
						,14
						,1
						)
			END

			SELECT @dblAdjustByQuantity = @dblNewWeight - @dblWeight 

			EXEC [uspICInventoryAdjustment_CreatePostQtyChange]
				-- Parameters for filtering:
				@intItemId = @intInputItemId
				,@dtmDate = @dtmPlannedDate
				,@intLocationId = @intLocationId
				,@intSubLocationId = @intSubLocationId
				,@intStorageLocationId = @intStorageLocationId
				,@strLotNumber = @strLotNumber
				-- Parameters for the new values: 
				,@dblAdjustByQuantity = @dblAdjustByQuantity
				,@dblNewUnitCost = NULL
				,@intItemUOMId = @intInputWeightUOMId
				-- Parameters used for linking or FK (foreign key) relationships
				,@intSourceId = 1
				,@intSourceTransactionTypeId = 8
				,@intEntityUserSecurityId = @intUserId
				,@intInventoryAdjustmentId = @intInventoryAdjustmentId OUTPUT

			INSERT INTO dbo.tblMFWorkOrderProducedLotTransaction (
				intWorkOrderId
				,intLotId
				,dblQuantity
				,intItemUOMId
				,intItemId
				,intTransactionId
				,intTransactionTypeId
				,strTransactionType
				,dtmTransactionDate
				,intProcessId
				,intShiftId
				)
			SELECT TOP 1 WI.intWorkOrderId
				,WI.intLotId
				,@dblNewWeight - @dblWeight
				,WI.intItemUOMId
				,WI.intItemId
				,@intInventoryAdjustmentId
				,24
				,'Empty Out Adj'
				,@dtmBusinessDate
				,intManufacturingProcessId
				,@intBusinessShiftId
			FROM dbo.tblMFWorkOrderInputLot WI
			JOIN dbo.tblMFWorkOrder W ON W.intWorkOrderId = WI.intWorkOrderId
			WHERE intLotId = @intInputLotId

			PRINT 'Call Lot Adjust routine.'
		END

		SELECT @dblAdjustByQuantity = - @dblNewWeight

		EXEC uspICInventoryAdjustment_CreatePostLotMerge
			-- Parameters for filtering:
			@intItemId = @intInputItemId
			,@dtmDate = @dtmPlannedDate
			,@intLocationId = @intLocationId
			,@intSubLocationId = @intSubLocationId
			,@intStorageLocationId = @intStorageLocationId
			,@strLotNumber = @strLotNumber
			-- Parameters for the new values: 
			,@intNewLocationId = @intLocationId
			,@intNewSubLocationId = @intConsumptionSubLocationId
			,@intNewStorageLocationId = @intConsumptionStorageLocationId
			,@strNewLotNumber = @strLotNumber
			,@dblAdjustByQuantity = @dblAdjustByQuantity
			,@dblNewSplitLotQuantity = NULL
			,@dblNewWeight = NULL
			,@intNewItemUOMId = NULL --New Item UOM Id should be NULL as per Feb
			,@intNewWeightUOMId = NULL
			,@dblNewUnitCost = NULL
			,@intItemUOMId = @intInputWeightUOMId
			-- Parameters used for linking or FK (foreign key) relationships
			,@intSourceId = 1
			,@intSourceTransactionTypeId = 8
			,@intEntityUserSecurityId = @intUserId
			,@intInventoryAdjustmentId = @intInventoryAdjustmentId OUTPUT
	END

	IF @strInventoryTracking = 'Item Level'
	BEGIN
		IF NOT EXISTS (
				SELECT 1
				FROM tempdb..sysobjects
				WHERE id = OBJECT_ID('tempdb..#tmpAddInventoryTransferResult')
				)
		BEGIN
			CREATE TABLE #tmpAddInventoryTransferResult (
				intSourceId INT
				,intInventoryTransferId INT
				)
		END

		DECLARE @TransferEntries AS InventoryTransferStagingTable

		-- Insert the data needed to create the inventory transfer.
		INSERT INTO @TransferEntries (
			-- Header
			[dtmTransferDate]
			,[strTransferType]
			,[intSourceType]
			,[strDescription]
			,[intFromLocationId]
			,[intToLocationId]
			,[ysnShipmentRequired]
			,[intStatusId]
			,[intShipViaId]
			,[intFreightUOMId]
			-- Detail
			,[intItemId]
			,[intLotId]
			,[intItemUOMId]
			,[dblQuantityToTransfer]
			,[strNewLotId]
			,[intFromSubLocationId]
			,[intToSubLocationId]
			,[intFromStorageLocationId]
			,[intToStorageLocationId]
			-- Integration Field
			,[intInventoryTransferId]
			,[intSourceId]
			,[strSourceId]
			,[strSourceScreenName]
			)
		SELECT -- Header
			[dtmTransferDate] = @dtmPlannedDate
			,[strTransferType] = 'Storage to Storage'
			,[intSourceType] = 0
			,[strDescription] = NULL
			,[intFromLocationId] = @intLocationId
			,[intToLocationId] = @intLocationId
			,[ysnShipmentRequired] = 0
			,[intStatusId] = 3
			,[intShipViaId] = NULL
			,[intFreightUOMId] = NULL
			-- Detail
			,[intItemId] = @intInputItemId
			,[intLotId] = NULL
			,[intItemUOMId] = @intInputWeightUOMId
			,[dblQuantityToTransfer] = @dblInputWeight
			,[strNewLotId] = NULL
			,[intFromSubLocationId] = @intSubLocationId
			,[intToSubLocationId] = @intConsumptionSubLocationId
			,[intFromStorageLocationId] = @intStorageLocationId
			,[intToStorageLocationId] = @intConsumptionStorageLocationId
			-- Integration Field
			,[intInventoryTransferId] = NULL
			,[intSourceId] = @intWorkOrderInputLotId
			,[strSourceId] = @strWorkOrderNo
			,[strSourceScreenName] = 'Process Production Consume'

		-- Call uspICAddInventoryTransfer stored procedure.
		EXEC dbo.uspICAddInventoryTransfer @TransferEntries
			,@intUserId

		-- Post the Inventory Transfers                                            
		DECLARE @intTransferId INT
			,@strTransactionId NVARCHAR(50);

		WHILE EXISTS (
				SELECT TOP 1 1
				FROM #tmpAddInventoryTransferResult
				)
		BEGIN
			SELECT @intTransferId = NULL
				,@strTransactionId = NULL

			SELECT TOP 1 @intTransferId = intInventoryTransferId
			FROM #tmpAddInventoryTransferResult

			-- Post the Inventory Transfer that was created
			SELECT @strTransactionId = strTransferNo
			FROM tblICInventoryTransfer
			WHERE intInventoryTransferId = @intTransferId

			EXEC dbo.uspICPostInventoryTransfer 1
				,0
				,@strTransactionId
				,@intUserId;

			DELETE
			FROM #tmpAddInventoryTransferResult
			WHERE intInventoryTransferId = @intTransferId
		END;
	END

	IF NOT EXISTS (
			SELECT *
			FROM tblMFProductionSummary
			WHERE intWorkOrderId = @intWorkOrderId
				AND intItemId = @intInputItemId
			)
	BEGIN
		INSERT INTO tblMFProductionSummary (
			intWorkOrderId
			,intItemId
			,dblOpeningQuantity
			,dblOpeningOutputQuantity
			,dblOpeningConversionQuantity
			,dblInputQuantity
			,dblConsumedQuantity
			,dblOutputQuantity
			,dblOutputConversionQuantity
			,dblCountQuantity
			,dblCountOutputQuantity
			,dblCountConversionQuantity
			,dblCalculatedQuantity
			)
		SELECT @intWorkOrderId
			,@intInputItemId
			,0
			,0
			,0
			,@dblInputWeight
			,0
			,0
			,0
			,0
			,0
			,0
			,0
	END
	ELSE
	BEGIN
		UPDATE tblMFProductionSummary
		SET dblInputQuantity = dblInputQuantity + @dblInputWeight
		WHERE intWorkOrderId = @intWorkOrderId
			AND intItemId = @intInputItemId
	END

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
GO


