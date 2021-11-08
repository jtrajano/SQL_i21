CREATE PROCEDURE [dbo].[uspMFStageWorkOrderByLot] (
	@strXML NVARCHAR(MAX)
	,@intWorkOrderInputLotId INT = NULL OUTPUT
	)
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
		,@intProductionStagingId INT
		,@intProductionStageLocationId INT
		,@intCategoryId INT
		,@intItemTypeId INT
		,@ItemsToReserve AS dbo.ItemReservationTableType
		,@intInventoryTransactionType AS INT = 8
		,@intAdjustItemUOMId INT
		,@intRecipeItemUOMId INT
		,@dblEnteredQty NUMERIC(38, 20)
		,@intEnteredItemUOMId INT
		,@intItemStockUOMId INT
		,@strMultipleMachinesShareCommonStagingLocation NVARCHAR(50)
		,@intOrderHeaderId INT
		,@dblQty NUMERIC(38, 20)
		,@strErr NVARCHAR(MAX)
		,@intSwapToWorkOrderId INT
		,@intSwapToLotId INT
		,@intSwapToOrderHeaderId INT
		,@strSwapToWorkOrderNo NVARCHAR(50)
		,@intRecordId INT
		,@dblSwapToQty NUMERIC(18, 6)
		,@dblLotQty NUMERIC(38, 20)
		,@dblReservedQty NUMERIC(18, 6)
		,@dblInputWeight2 NUMERIC(18, 6)
		,@dblRequiredQty NUMERIC(18, 6)
		,@dblSwapToQty2 NUMERIC(18, 6)
		,@intMainItemId INT
		,@strConsumeSourceLocation NVARCHAR(50)
	DECLARE @tblMFSwapto TABLE (
		intSwapTo INT identity(1, 1)
		,intWorkOrderId INT
		,strWorkOrderNo NVARCHAR(50)
		,dblQty NUMERIC(18, 6)
		)
	DECLARE @tblMFReservation TABLE (
		intRecordId INT identity(1, 1)
		,intWorkOrderId INT
		,strWorkOrderNo NVARCHAR(50)
		,dblQty NUMERIC(18, 6)
		)
	DECLARE @tblMFLot TABLE (
		intSwapToLotId INT
		,dblQty NUMERIC(38, 20)
		)
	DECLARE @tblMFPickedLot TABLE (
		intLotId INT
		,dblQty NUMERIC(38, 20)
		)

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
		,@intMainItemId = intMainItemId
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
			,intMainItemId INT
			)

	IF @dtmActualInputDateTime > GETDATE()
	BEGIN
		RAISERROR (
				'Feed time cannot be greater than current date and time.'
				,14
				,1
				)
	END

	SELECT @dblEnteredQty = @dblInputWeight
		,@intEnteredItemUOMId = @intInputWeightUOMId

	SELECT @strInventoryTracking = strInventoryTracking
		,@intCategoryId = intCategoryId
	FROM dbo.tblICItem
	WHERE intItemId = @intInputItemId

	IF @strInventoryTracking = 'Lot Level'
	BEGIN
		IF @intInputLotId IS NULL
			OR @intInputLotId = 0
		BEGIN
			RAISERROR (
					'Lot cannot be blank.'
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
			,@dblQty = dblQty
		FROM tblICLot
		WHERE intLotId = @intInputLotId

		IF @intNewItemUOMId <> @intInputWeightUOMId
			AND IsNULL(@intWeightUOMId, @intNewItemUOMId) <> @intInputWeightUOMId
		BEGIN
			SELECT @dblInputWeight = dbo.fnMFConvertQuantityToTargetItemUOM(@intInputWeightUOMId, @intNewItemUOMId, @dblInputWeight)

			SELECT @intInputWeightUOMId = @intNewItemUOMId
		END

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
					'Please select a valid lot'
					,14
					,1
					)
		END

		IF @dblWeight <= 0
			AND @ysnNegativeQuantityAllowed = 0
		BEGIN
			RAISERROR (
					'Lot quantity should be greater than zero.'
					,14
					,1
					)
		END
	END

	SELECT TOP 1 --@dtmPlannedDate = dtmPlannedDate
		@strWorkOrderNo = strWorkOrderNo
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
					'No open runs for the target item ''%s''. Cannot consume.'
					,14
					,1
					,@strItemNo
					)
		END
	END

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

	SELECT @intConsumptionMethodId = RI.intConsumptionMethodId
		,@intConsumptionStorageLocationId = CASE 
			WHEN RI.intConsumptionMethodId = 1
				THEN @intProductionStageLocationId
			ELSE RI.intStorageLocationId
			END
		,@intItemTypeId = (
			CASE 
				WHEN RS.intSubstituteItemId IS NOT NULL
					AND RS.intSubstituteItemId = @intInputItemId
					THEN 3
				ELSE 1
				END
			)
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
				'Input item ''%s'' does not belong to recipe of ''%s'' , Cannot proceed.'
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
				'No mapped staging location found, cannot stage.'
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
				'Lot %s you are trying to consume for Work order %s is not associated with the selected process %s.'
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
				'The work order that you clicked on is already completed.'
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
				'The work order has been paused. Please re-start the WO to resume.'
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
				'Work order is not in started state. Please start the work order.'
				,11
				,1
				)
	END

	SELECT @strMultipleMachinesShareCommonStagingLocation = strAttributeValue
	FROM tblMFManufacturingProcessAttribute
	WHERE intManufacturingProcessId = @intManufacturingProcessId
		AND intLocationId = @intLocationId
		AND intAttributeId = 102 --Multiple machines share common staging location

	IF @strMultipleMachinesShareCommonStagingLocation IS NULL
	BEGIN
		SELECT @strMultipleMachinesShareCommonStagingLocation = 'False'
	END

	SELECT @strConsumeSourceLocation = strAttributeValue
	FROM tblMFManufacturingProcessAttribute
	WHERE intManufacturingProcessId = @intManufacturingProcessId
		AND intLocationId = @intLocationId
		AND intAttributeId = 124

	IF @strConsumeSourceLocation = ''
		OR @strConsumeSourceLocation IS NULL
	BEGIN
		SELECT @strConsumeSourceLocation = 'False'
	END

	--*************************************
	-- Reservation validation
	--*************************************
	SELECT @dblReservedQty = dblQty
	FROM vyuMFStockReservationByWorkOrder
	WHERE intWorkOrderId <> @intWorkOrderId
		AND intLotId = @intInputLotId

	IF @dblReservedQty IS NULL
		SELECT @dblReservedQty = 0

	SELECT @dblInputWeight2 = dbo.fnMFConvertQuantityToTargetItemUOM(@intInputWeightUOMId, @intNewItemUOMId, @dblInputWeight)

	IF @dblInputWeight2 > @dblQty - @dblReservedQty
	BEGIN
		SELECT @dblRequiredQty = ABS((@dblQty - @dblReservedQty) - @dblInputWeight2)

		SELECT @dblReservedQty = NULL

		SELECT @dblReservedQty = SUM(dblQty)
		FROM vyuMFStockReservationByWorkOrder
		WHERE intWorkOrderId = @intWorkOrderId
			AND intItemId = @intInputItemId
			AND intInventoryTransactionType = 9

		IF @dblReservedQty IS NULL
			SELECT @dblReservedQty = 0

		IF @dblReservedQty - @dblInputWeight2 < 0
		BEGIN
			SELECT @strErr = 'There is reservation against this lot. Cannot proceed.'

			RAISERROR (
					@strErr
					,16
					,1
					)

			RETURN
		END
		ELSE
		BEGIN
			WHILE @dblRequiredQty > 0
			BEGIN
				INSERT INTO @tblMFSwapto (
					intWorkOrderId
					,strWorkOrderNo
					,dblQty
					)
				SELECT intWorkOrderId
					,strWorkOrderNo
					,dblQty
				FROM vyuMFStockReservationByWorkOrder
				WHERE intWorkOrderId <> @intWorkOrderId
					AND intLotId = @intInputLotId

				SELECT @intRecordId = MIN(intSwapTo)
				FROM @tblMFSwapto

				WHILE @intRecordId IS NOT NULL
				BEGIN
					SELECT @intSwapToWorkOrderId = NULL
						,@strSwapToWorkOrderNo = NULL
						,@dblSwapToQty = NULL

					SELECT @intSwapToWorkOrderId = intWorkOrderId
						,@strSwapToWorkOrderNo = strWorkOrderNo
						,@dblSwapToQty = dblQty
					FROM @tblMFSwapto
					WHERE intSwapTo = @intRecordId

					IF @dblRequiredQty > @dblSwapToQty
					BEGIN
						INSERT INTO @tblMFReservation
						SELECT @intSwapToWorkOrderId
							,@strSwapToWorkOrderNo
							,@dblSwapToQty

						SELECT @dblRequiredQty = @dblRequiredQty - @dblSwapToQty
					END
					ELSE
					BEGIN
						INSERT INTO @tblMFReservation
						SELECT @intSwapToWorkOrderId
							,@strSwapToWorkOrderNo
							,@dblRequiredQty

						SELECT @dblRequiredQty = 0
					END

					IF @dblRequiredQty = 0
					BEGIN
						BREAK
					END

					SELECT @intRecordId = MIN(intSwapTo)
					FROM @tblMFSwapto
					WHERE intSwapTo > @intRecordId
				END
			END
		END
	END

	--*************************************
	-- End Reservation validation
	--*************************************
	IF @intTransactionCount = 0
		BEGIN TRANSACTION

	SELECT @intOrderHeaderId = intOrderHeaderId
	FROM tblMFStageWorkOrder
	WHERE intWorkOrderId = @intWorkOrderId

	SELECT @intRecordId = NULL

	SELECT @intRecordId = MIN(intRecordId)
	FROM @tblMFReservation

	WHILE @intRecordId IS NOT NULL
	BEGIN
		SELECT @intSwapToWorkOrderId = NULL
			,@strSwapToWorkOrderNo = NULL
			,@dblSwapToQty = NULL
			,@dblSwapToQty2 = NULL

		SELECT @intSwapToWorkOrderId = intWorkOrderId
			,@strSwapToWorkOrderNo = strWorkOrderNo
			,@dblSwapToQty = dblQty
			,@dblSwapToQty2 = dblQty
		FROM @tblMFReservation
		WHERE intRecordId = @intRecordId

		SELECT @intSwapToOrderHeaderId = intOrderHeaderId
		FROM tblMFStageWorkOrder
		WHERE intWorkOrderId = @intSwapToWorkOrderId

		SELECT @intSwapToLotId = NULL

		SELECT @intSwapToLotId = intLotId
		FROM vyuMFStockReservationByWorkOrder
		WHERE intWorkOrderId = @intWorkOrderId
			AND intItemId = @intInputItemId
			AND intInventoryTransactionType = 9
			AND dblQty = @dblSwapToQty2

		IF @intSwapToLotId IS NOT NULL
			AND EXISTS (
				SELECT *
				FROM tblMFTask
				WHERE intOrderHeaderId = @intSwapToOrderHeaderId
					AND intLotId = @intInputLotId
					AND dblQty = @dblSwapToQty2
				)
		BEGIN
			UPDATE tblMFTask
			SET intLotId = @intSwapToLotId
			WHERE intOrderHeaderId = @intSwapToOrderHeaderId
				AND intLotId = @intInputLotId

			DELETE
			FROM tblMFTask
			WHERE intOrderHeaderId = @intOrderHeaderId
				AND intLotId = @intSwapToLotId

			INSERT INTO @tblMFPickedLot
			SELECT @intSwapToLotId
				,@dblSwapToQty2
		END
		ELSE
		BEGIN
			DELETE
			FROM @tblMFLot

			INSERT INTO @tblMFLot (
				intSwapToLotId
				,dblQty
				)
			SELECT SR.intLotId
				,SR.dblQty - IsNULL(L.dblQty, 0)
			FROM vyuMFStockReservationByWorkOrder SR
			LEFT JOIN @tblMFPickedLot L ON L.intLotId = SR.intLotId
			WHERE SR.intWorkOrderId = @intWorkOrderId
				AND SR.intItemId = @intInputItemId
				AND SR.intInventoryTransactionType = 9
				AND SR.dblQty - IsNULL(L.dblQty, 0) > 0

			SELECT @intSwapToLotId = NULL

			SELECT @intSwapToLotId = MIN(intSwapToLotId)
			FROM @tblMFLot

			WHILE @intSwapToLotId IS NOT NULL
			BEGIN
				SELECT @dblLotQty = NULL

				SELECT @dblLotQty = dblQty
				FROM @tblMFLot
				WHERE intSwapToLotId = @intSwapToLotId

				IF @dblSwapToQty > @dblLotQty
				BEGIN
					INSERT INTO tblMFTask (
						intConcurrencyId
						,strTaskNo
						,intTaskTypeId
						,intTaskStateId
						,intAssigneeId
						,intOrderHeaderId
						,intOrderDetailId
						,intTaskPriorityId
						,dtmReleaseDate
						,intFromStorageLocationId
						,intToStorageLocationId
						,intItemId
						,intLotId
						,dblQty
						,intItemUOMId
						,dblWeight
						,intWeightUOMId
						,dblWeightPerQty
						,intCreatedUserId
						,dtmCreated
						,intLastModifiedUserId
						,dtmLastModified
						,dblPickQty
						)
					SELECT intConcurrencyId
						,strTaskNo
						,intTaskTypeId
						,intTaskStateId
						,intAssigneeId
						,intOrderHeaderId
						,intOrderDetailId
						,intTaskPriorityId
						,dtmReleaseDate
						,intFromStorageLocationId
						,intToStorageLocationId
						,intItemId
						,@intSwapToLotId
						,@dblLotQty
						,intItemUOMId
						,@dblLotQty
						,intItemUOMId
						,1
						,intCreatedUserId
						,dtmCreated
						,intLastModifiedUserId
						,dtmLastModified
						,@dblLotQty
					FROM tblMFTask
					WHERE intOrderHeaderId = @intSwapToOrderHeaderId
						AND intLotId = @intInputLotId

					SELECT @dblSwapToQty = @dblSwapToQty - @dblLotQty

					UPDATE dbo.tblMFTask
					SET dblQty = dblQty - @dblLotQty
						,dblWeight = (dblQty - @dblLotQty) / dblWeightPerQty
						,dblPickQty = dblQty - @dblLotQty
					WHERE intOrderHeaderId = @intOrderHeaderId
						AND intLotId = @intSwapToLotId

					INSERT INTO @tblMFPickedLot
					SELECT @intSwapToLotId
						,@dblLotQty

					DELETE
					FROM tblMFTask
					WHERE intOrderHeaderId = @intOrderHeaderId
						AND intLotId = @intSwapToLotId
						AND dblQty = 0
				END
				ELSE
				BEGIN
					INSERT INTO tblMFTask (
						intConcurrencyId
						,strTaskNo
						,intTaskTypeId
						,intTaskStateId
						,intAssigneeId
						,intOrderHeaderId
						,intOrderDetailId
						,intTaskPriorityId
						,dtmReleaseDate
						,intFromStorageLocationId
						,intToStorageLocationId
						,intItemId
						,intLotId
						,dblQty
						,intItemUOMId
						,dblWeight
						,intWeightUOMId
						,dblWeightPerQty
						,intCreatedUserId
						,dtmCreated
						,intLastModifiedUserId
						,dtmLastModified
						,dblPickQty
						)
					SELECT intConcurrencyId
						,strTaskNo
						,intTaskTypeId
						,intTaskStateId
						,intAssigneeId
						,intOrderHeaderId
						,intOrderDetailId
						,intTaskPriorityId
						,dtmReleaseDate
						,intFromStorageLocationId
						,intToStorageLocationId
						,intItemId
						,@intSwapToLotId
						,@dblSwapToQty
						,intItemUOMId
						,@dblSwapToQty
						,intItemUOMId
						,1
						,intCreatedUserId
						,dtmCreated
						,intLastModifiedUserId
						,dtmLastModified
						,@dblSwapToQty
					FROM dbo.tblMFTask
					WHERE intOrderHeaderId = @intSwapToOrderHeaderId
						AND intLotId = @intInputLotId

					UPDATE dbo.tblMFTask
					SET dblQty = dblQty - @dblSwapToQty
						,dblWeight = (dblQty - @dblSwapToQty) / dblWeightPerQty
						,dblPickQty = dblQty - @dblSwapToQty
					WHERE intOrderHeaderId = @intOrderHeaderId
						AND intLotId = @intSwapToLotId

					DELETE
					FROM tblMFTask
					WHERE intOrderHeaderId = @intOrderHeaderId
						AND intLotId = @intSwapToLotId
						AND dblQty = 0

					INSERT INTO @tblMFPickedLot
					SELECT @intSwapToLotId
						,@dblSwapToQty

					SELECT @dblSwapToQty = 0
				END

				IF @dblSwapToQty <= 0
				BEGIN
					IF EXISTS (
							SELECT *
							FROM dbo.tblMFTask
							WHERE intOrderHeaderId = @intSwapToOrderHeaderId
								AND intLotId = @intInputLotId
								AND dblQty = @dblSwapToQty2
							)
					BEGIN
						DELETE
						FROM dbo.tblMFTask
						WHERE intOrderHeaderId = @intSwapToOrderHeaderId
							AND intLotId = @intInputLotId
					END
					ELSE
					BEGIN
						UPDATE dbo.tblMFTask
						SET dblQty = dblQty - @dblSwapToQty2
							,dblWeight = (dblQty - @dblSwapToQty2) / dblWeightPerQty
							,dblPickQty = dblQty - @dblSwapToQty2
						WHERE intOrderHeaderId = @intSwapToOrderHeaderId
							AND intLotId = @intInputLotId
					END

					BREAK
				END

				SELECT @intSwapToLotId = MIN(intSwapToLotId)
				FROM @tblMFLot
				WHERE intSwapToLotId > @intSwapToLotId
			END
		END

		EXEC dbo.uspICCreateStockReservation @ItemsToReserve
			,@intSwapToWorkOrderId
			,9

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
		SELECT intItemId = T.intItemId
			,intItemLocationId = IL.intItemLocationId
			,intItemUOMId = T.intItemUOMId
			,intLotId = T.intLotId
			,intSubLocationId = SL.intSubLocationId
			,intStorageLocationId = NULL --We need to set this to NULL otherwise available Qty becomes zero in the inventoryshipment screen
			,dblQty = T.dblPickQty
			,intTransactionId = @intSwapToWorkOrderId
			,strTransactionId = @strSwapToWorkOrderNo
			,intTransactionTypeId = 9
		FROM tblMFTask T
		JOIN tblICStorageLocation SL ON SL.intStorageLocationId = T.intFromStorageLocationId
		JOIN tblICItemLocation IL ON IL.intItemId = T.intItemId
			AND IL.intLocationId = SL.intLocationId
		WHERE T.intOrderHeaderId = @intSwapToOrderHeaderId
			AND T.intTaskStateId = 4

		EXEC dbo.uspICCreateStockReservation @ItemsToReserve
			,@intSwapToWorkOrderId
			,9

		DELETE
		FROM @ItemsToReserve

		SELECT @intRecordId = MIN(intRecordId)
		FROM @tblMFReservation
		WHERE intRecordId > @intRecordId
	END

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
		,dblEnteredQty
		,intEnteredItemUOMId
		,intMainItemId
		)
	SELECT @intWorkOrderId
		,@intInputItemId
		,@intInputLotId
		,(
			CASE 
				WHEN @intInputWeightUOMId = IsNULL(@intNewItemUOMId, 0)
					THEN @dblInputWeight * @dblWeightPerQty
				ELSE @dblInputWeight
				END
			)
		,IsNULL(Isnull(@intWeightUOMId, @intNewItemUOMId), @intInputWeightUOMId)
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
		,@dblEnteredQty
		,@intEnteredItemUOMId
		,@intMainItemId

	SELECT @intWorkOrderInputLotId = SCOPE_IDENTITY()

	IF @strInventoryTracking = 'Lot Level'
		AND @strConsumeSourceLocation = 'False'
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
						'The quantity to be consumed must not exceed the selected lot quantity.'
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
				,@strDescription = @strWorkOrderNo

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

		IF @dblWeightPerQty = 0
			OR @dblNewWeight % @dblWeightPerQty > 0
		BEGIN
			SELECT @dblAdjustByQuantity = - @dblNewWeight
				,@intAdjustItemUOMId = @intInputWeightUOMId
		END
		ELSE
		BEGIN
			SELECT @dblAdjustByQuantity = - @dblNewWeight / @dblWeightPerQty
				,@intAdjustItemUOMId = @intNewItemUOMId
		END

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
			,@intItemUOMId = @intAdjustItemUOMId
			-- Parameters used for linking or FK (foreign key) relationships
			,@intSourceId = 1
			,@intSourceTransactionTypeId = 8
			,@intEntityUserSecurityId = @intUserId
			,@intInventoryAdjustmentId = @intInventoryAdjustmentId OUTPUT
			,@strDescription = @strWorkOrderNo
	END

	IF @strInventoryTracking = 'Item Level'
	BEGIN
		SELECT @intItemStockUOMId = intItemUOMId
		FROM tblICItemUOM
		WHERE intItemId = @intInputItemId
			AND ysnStockUnit = 1

		IF @intItemStockUOMId <> @intInputWeightUOMId
		BEGIN
			SELECT @dblInputWeight = dbo.fnMFConvertQuantityToTargetItemUOM(@intInputWeightUOMId, @intItemStockUOMId, @dblInputWeight)

			SELECT @intInputWeightUOMId = @intItemStockUOMId
		END

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

	SELECT @intRecipeItemUOMId = RI.intItemUOMId
	FROM tblMFWorkOrderRecipeItem RI
	WHERE RI.intWorkOrderId = @intWorkOrderId
		AND RI.intItemId = @intInputItemId
		AND RI.intRecipeItemTypeId = 1

	IF @intRecipeItemUOMId IS NULL
	BEGIN
		SELECT @intRecipeItemUOMId = RS.intItemUOMId
		FROM tblMFWorkOrderRecipeSubstituteItem RS
		WHERE RS.intWorkOrderId = @intWorkOrderId
			AND RS.intSubstituteItemId = @intInputItemId
	END

	IF @strMultipleMachinesShareCommonStagingLocation = 'True'
	BEGIN
		SELECT @intMachineId = NULL
	END

	IF @intMainItemId IS NOT NULL
	BEGIN
		UPDATE tblMFProductionSummary
		SET intMainItemId = @intMainItemId
		WHERE intWorkOrderId = @intWorkOrderId
			AND intItemId = @intInputItemId
			AND IsNULL(intMachineId, 0) = (
				CASE 
					WHEN intMachineId IS NOT NULL
						THEN IsNULL(@intMachineId, 0)
					ELSE IsNULL(intMachineId, 0)
					END
				)
			AND intItemTypeId IN (
				1
				,3
				)
			AND intMainItemId IS NULL
	END

	IF NOT EXISTS (
			SELECT *
			FROM tblMFProductionSummary
			WHERE intWorkOrderId = @intWorkOrderId
				AND intItemId = @intInputItemId
				AND IsNULL(intMachineId, 0) = (
					CASE 
						WHEN intMachineId IS NOT NULL
							THEN IsNULL(@intMachineId, 0)
						ELSE IsNULL(intMachineId, 0)
						END
					)
				AND intItemTypeId IN (
					1
					,3
					)
				AND IsNULL(intMainItemId, IsNULL(@intMainItemId, 0)) = IsNULL(@intMainItemId, 0)
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
			,intCategoryId
			,intItemTypeId
			,intMachineId
			,intMainItemId
			)
		SELECT @intWorkOrderId
			,@intInputItemId
			,0
			,0
			,0
			,dbo.fnMFConvertQuantityToTargetItemUOM(@intInputWeightUOMId, @intRecipeItemUOMId, @dblInputWeight)
			,0
			,0
			,0
			,0
			,0
			,0
			,0
			,@intCategoryId
			,@intItemTypeId
			,@intMachineId
			,@intMainItemId
	END
	ELSE
	BEGIN
		UPDATE tblMFProductionSummary
		SET dblInputQuantity = dblInputQuantity + IsNULL(dbo.fnMFConvertQuantityToTargetItemUOM(@intInputWeightUOMId, @intRecipeItemUOMId, @dblInputWeight), 0)
		WHERE intWorkOrderId = @intWorkOrderId
			AND intItemId = @intInputItemId
			AND IsNULL(intMachineId, 0) = (
				CASE 
					WHEN intMachineId IS NOT NULL
						THEN IsNULL(@intMachineId, 0)
					ELSE IsNULL(intMachineId, 0)
					END
				)
			AND intItemTypeId IN (
				1
				,3
				)
			AND IsNULL(intMainItemId, IsNULL(@intMainItemId, 0)) = IsNULL(@intMainItemId, 0)
	END

	---************************************
	--IF @intSwapToLotId IS NOT NULL
	--BEGIN
	DELETE
	FROM @ItemsToReserve

	EXEC dbo.uspICCreateStockReservation @ItemsToReserve
		,@intWorkOrderId
		,9

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
	SELECT intItemId = T.intItemId
		,intItemLocationId = IL.intItemLocationId
		,intItemUOMId = T.intItemUOMId
		,intLotId = T.intLotId
		,intSubLocationId = SL.intSubLocationId
		,intStorageLocationId = NULL --We need to set this to NULL otherwise available Qty becomes zero in the inventoryshipment screen
		,dblQty = T.dblPickQty
		,intTransactionId = @intWorkOrderId
		,strTransactionId = @strWorkOrderNo
		,intTransactionTypeId = 9
	FROM tblMFTask T
	JOIN tblICStorageLocation SL ON SL.intStorageLocationId = T.intFromStorageLocationId
	JOIN tblICItemLocation IL ON IL.intItemId = T.intItemId
		AND IL.intLocationId = SL.intLocationId
	WHERE T.intOrderHeaderId = @intOrderHeaderId
		AND T.intTaskStateId = 4
		AND T.intLotId NOT IN (
			SELECT WI.intLotId
			FROM tblMFWorkOrderInputLot WI
			WHERE WI.intWorkOrderId = @intWorkOrderId
				AND WI.ysnConsumptionReversed = 0
			)

	EXEC dbo.uspICCreateStockReservation @ItemsToReserve
		,@intWorkOrderId
		,9

	--END
	---************************************
	DELETE
	FROM @ItemsToReserve

	EXEC dbo.uspICCreateStockReservation @ItemsToReserve
		,@intWorkOrderId
		,@intInventoryTransactionType

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
				AND L1.intStorageLocationId = @intConsumptionStorageLocationId
			)
		,intSubLocationId = @intConsumptionSubLocationId
		,intStorageLocationId = @intConsumptionStorageLocationId
		,dblQty = SUM(WI.dblIssuedQuantity)
		,intTransactionId = @intWorkOrderId
		,strTransactionId = @strWorkOrderNo
		,intTransactionTypeId = @intInventoryTransactionType
	FROM tblMFWorkOrderInputLot WI
	JOIN tblICItemLocation IL ON IL.intItemId = WI.intItemId
		AND IL.intLocationId = @intLocationId
		AND WI.ysnConsumptionReversed = 0
	LEFT JOIN tblICLot L ON L.intLotId = WI.intLotId
	WHERE intWorkOrderId = @intWorkOrderId
	GROUP BY WI.intItemId
		,IL.intItemLocationId
		,WI.intItemIssuedUOMId
		,L.strLotNumber

	EXEC dbo.uspICCreateStockReservation @ItemsToReserve
		,@intWorkOrderId
		,@intInventoryTransactionType

	SELECT @intDestinationLotId = intLotId
	FROM tblICLot L
	WHERE L.strLotNumber = @strLotNumber
		AND L.intStorageLocationId = @intConsumptionStorageLocationId

	UPDATE tblMFWorkOrderInputLot
	SET intDestinationLotId = @intDestinationLotId
	WHERE intWorkOrderInputLotId = @intWorkOrderInputLotId

	EXEC dbo.uspMFAdjustInventory @dtmDate = @dtmPlannedDate
		,@intTransactionTypeId = 104 --Stage
		,@intItemId = @intInputItemId
		,@intSourceLotId = @intInputLotId
		,@intDestinationLotId = @intDestinationLotId
		,@dblQty = @dblInputWeight
		,@intItemUOMId = @intInputWeightUOMId
		,@intOldItemId = NULL
		,@dtmOldExpiryDate = NULL
		,@dtmNewExpiryDate = NULL
		,@intOldLotStatusId = NULL
		,@intNewLotStatusId = NULL
		,@intUserId = @intUserId
		,@strNote = NULL
		,@strReason = NULL
		,@intLocationId = @intLocationId
		,@intInventoryAdjustmentId = NULL
		,@intStorageLocationId = @intStorageLocationId
		,@intDestinationStorageLocationId = @intConsumptionStorageLocationId
		,@intWorkOrderInputLotId = @intWorkOrderInputLotId
		,@intWorkOrderProducedLotId = NULL
		,@intWorkOrderId = @intWorkOrderId

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
