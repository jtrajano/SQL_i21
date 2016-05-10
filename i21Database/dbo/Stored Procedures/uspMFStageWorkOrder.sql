﻿CREATE PROCEDURE [dbo].[uspMFStageWorkOrder] (@strXML NVARCHAR(MAX))
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

	SELECT @intTransactionCount = @@TRANCOUNT

	SELECT @dtmCurrentDateTime = GetDate()

	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@strXML

	SELECT @intLocationId = intLocationId
		,@intSubLocationId = intSubLocationId
		,@intManufacturingProcessId = intManufacturingProcessId
		,@intMachineId = intMachineId
		,@intWorkOrderId = intWorkOrderId
		,@dtmPlannedDate = dtmPlannedDate
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
			,dtmPlannedDate DATETIME
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

	IF @intInputLotId IS NULL
		OR @intInputLotId = 0
	BEGIN
		RAISERROR (
				51113
				,14
				,1
				)
	END

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

	IF @dblWeight <= 0
		AND @ysnNegativeQuantityAllowed = 0
	BEGIN
		RAISERROR (
				51110
				,14
				,1
				)
	END

	SELECT @intConsumptionMethodId = RI.intConsumptionMethodId
		,@intConsumptionStorageLocationId = RI.intStorageLocationId
	--,@intInputItemId = ISNULL(RS.intSubstituteItemId,RI.intItemId)
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

	IF @intConsumptionMethodId = 2
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
		,intItemId
		,intLotId
		,@dblInputWeight
		,ISNULL(intWeightUOMId, intItemUOMId)
		,@dblInputWeight / (
			CASE 
				WHEN dblWeightPerQty = 0
					THEN 1
				ELSE dblWeightPerQty
				END
			)
		,intItemUOMId
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
	FROM dbo.tblICLot
	WHERE intLotId = @intInputLotId

	IF @intConsumptionMethodId = 1 --By Lot consumption
	BEGIN
		IF @dblInputWeight > @dblWeight
		BEGIN
			IF @ysnExcessConsumptionAllowed = 0
			BEGIN
				RAISERROR (
						51116
						,14
						,1
						)
			END
		END

		PRINT 'Call Lot reservation routine.'
	END

	IF @intConsumptionMethodId = 2
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

			SELECT @dblAdjustByQuantity = (@dblNewWeight - @dblWeight) / (
					CASE 
						WHEN @intWeightUOMId IS NULL
							THEN 1
						ELSE @dblWeightPerQty
						END
					)

			EXEC [uspICInventoryAdjustment_CreatePostQtyChange]
				-- Parameters for filtering:
				@intItemId = @intInputItemId
				,@dtmDate = @dtmCurrentDateTime
				,@intLocationId = @intLocationId
				,@intSubLocationId = @intSubLocationId
				,@intStorageLocationId = @intStorageLocationId
				,@strLotNumber = @strLotNumber
				-- Parameters for the new values: 
				,@dblAdjustByQuantity = @dblAdjustByQuantity
				,@dblNewUnitCost = NULL
				,@intItemUOMId = @intNewItemUOMId
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

		SELECT TOP 1 @intDestinationLotId = intLotId
			,@strDestinationLotNumber = strLotNumber
		FROM dbo.tblICLot
		WHERE intStorageLocationId = @intConsumptionStorageLocationId
			AND intItemId = @intInputItemId
			AND intLotId <> @intInputLotId
			AND dtmExpiryDate > @dtmCurrentDateTime
			AND intLotStatusId = 1
		ORDER BY dtmDateCreated DESC

		IF @intDestinationLotId IS NULL --There is no lot in the destination location
		BEGIN
			IF @dblNewWeight = @dblWeight --It is a full qty staging.
			BEGIN
				IF @intStorageLocationId <> @intConsumptionStorageLocationId --Checking whether the lot is not in the staging location.
				BEGIN
					PRINT 'Call Lot Move routine.'

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
						,@intNewLocationId = @intLocationId
						,@intNewSubLocationId = @intConsumptionSubLocationId
						,@intNewStorageLocationId = @intConsumptionStorageLocationId
						,@strNewLotNumber = @strLotNumber
						,@dblMoveQty = @dblAdjustByQuantity
						,@intItemUOMId = @intNewItemUOMId
						-- Parameters used for linking or FK (foreign key) relationships
						,@intSourceId = 1
						,@intSourceTransactionTypeId = 8
						,@intEntityUserSecurityId = @intUserId
						,@intInventoryAdjustmentId = @intInventoryAdjustmentId OUTPUT
				END
			END
			ELSE
			BEGIN
				--EXEC dbo.uspSMGetStartingNumber 55
				--	,@strDestinationLotNumber OUTPUT
				DECLARE @intCategoryId INT

				SELECT @intCategoryId = intCategoryId
				FROM tblICItem
				WHERE intItemId = @intItemId

				EXEC dbo.uspMFGeneratePatternId @intCategoryId = @intCategoryId
					,@intItemId = @intItemId
					,@intManufacturingId = @intManufacturingCellId
					,@intSubLocationId = @intSubLocationId
					,@intLocationId = @intLocationId
					,@intOrderTypeId = NULL
					,@intBlendRequirementId = NULL
					,@intPatternCode = 55
					,@ysnProposed = 0
					,@strPatternString = @strDestinationLotNumber OUTPUT

				PRINT '1.Call Lot Merge routine.'

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
					,@intNewLocationId = @intLocationId
					,@intNewSubLocationId = @intConsumptionSubLocationId
					,@intNewStorageLocationId = @intConsumptionStorageLocationId
					,@strNewLotNumber = @strDestinationLotNumber
					,@dblAdjustByQuantity = @dblAdjustByQuantity
					,@dblNewSplitLotQuantity = 0
					,@dblNewWeight = NULL
					,@intNewItemUOMId = NULL --New Item UOM Id should be NULL as per Feb
					,@intNewWeightUOMId = NULL
					,@dblNewUnitCost = NULL
					,@intItemUOMId = @intNewItemUOMId
					-- Parameters used for linking or FK (foreign key) relationships
					,@intSourceId = 1
					,@intSourceTransactionTypeId = 8
					,@intEntityUserSecurityId = @intUserId
					,@intInventoryAdjustmentId = @intInventoryAdjustmentId OUTPUT
			END
		END
		ELSE
		BEGIN
			PRINT '2.Call Lot Merge routine.'

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
				,@intNewLocationId = @intLocationId
				,@intNewSubLocationId = @intConsumptionSubLocationId
				,@intNewStorageLocationId = @intConsumptionStorageLocationId
				,@strNewLotNumber = @strDestinationLotNumber
				,@dblAdjustByQuantity = @dblAdjustByQuantity
				,@dblNewSplitLotQuantity = NULL
				,@dblNewWeight = NULL
				,@intNewItemUOMId = NULL --New Item UOM Id should be NULL as per Feb
				,@intNewWeightUOMId = NULL
				,@dblNewUnitCost = NULL
				,@intItemUOMId = @intNewItemUOMId
				-- Parameters used for linking or FK (foreign key) relationships
				,@intSourceId = 1
				,@intSourceTransactionTypeId = 8
				,@intEntityUserSecurityId = @intUserId
				,@intInventoryAdjustmentId = @intInventoryAdjustmentId OUTPUT
		END
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


