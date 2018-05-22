CREATE PROCEDURE [dbo].[uspMFStageWorkOrder] (
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
		,@intRecipeTypeId INT
		,@intItemId2 INT
		,@intRecipeSubstituteItemId INT
		,@intRecipeId INT
		,@intRecipeItemId INT

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
					'Lot can not be blank.'
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
		,@intRecipeTypeId = intRecipeTypeId
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

	IF @intRecipeTypeId <> 3
	BEGIN
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

	IF @intTransactionCount = 0
		BEGIN TRANSACTION

	DECLARE @intRecipeItemUOMId2 INT
		,@intUnitMeasureId INT
		,@intInputItemUOMId2 INT

	IF NOT EXISTS (
			SELECT *
			FROM tblMFWorkOrderRecipeItem RI
			LEFT JOIN tblMFWorkOrderRecipeSubstituteItem RS ON RS.intRecipeItemId = RI.intRecipeItemId
			WHERE (
					RI.intItemId = @intInputItemId
					OR RS.intSubstituteItemId = @intInputItemId
					)
				AND RI.intWorkOrderId = @intWorkOrderId
			)
	BEGIN
		SELECT @intRecipeId = intRecipeId
			,@intRecipeItemUOMId2 = intItemUOMId
		FROM tblMFWorkOrderRecipe
		WHERE intWorkOrderId = @intWorkOrderId

		SELECT @intUnitMeasureId = intUnitMeasureId
		FROM tblICItemUOM
		WHERE intItemUOMId = @intRecipeItemUOMId2

		SELECT @intInputItemUOMId2 = intItemUOMId
		FROM tblICItemUOM
		WHERE intItemId = @intInputItemId
			AND intUnitMeasureId = @intUnitMeasureId

		IF NOT EXISTS (
				SELECT *
				FROM tblMFWorkOrderRecipeItem RI
				WHERE RI.intWorkOrderId = @intWorkOrderId
					AND RI.dblCalculatedQuantity <> 0
					AND RI.intRecipeItemTypeId = 1
				)
		BEGIN
			SELECT @intRecipeItemId = Max(intRecipeItemId) + 1
			FROM tblMFWorkOrderRecipeItem

			INSERT INTO tblMFWorkOrderRecipeItem (
				intRecipeItemId
				,intRecipeId
				,intItemId
				,dblQuantity
				,dblCalculatedQuantity
				,[intItemUOMId]
				,intRecipeItemTypeId
				,strItemGroupName
				,dblUpperTolerance
				,dblLowerTolerance
				,dblCalculatedUpperTolerance
				,dblCalculatedLowerTolerance
				,dblShrinkage
				,ysnScaled
				,intConsumptionMethodId
				,intStorageLocationId
				,dtmValidFrom
				,dtmValidTo
				,ysnYearValidationRequired
				,ysnMinorIngredient
				,intReferenceRecipeId
				,ysnOutputItemMandatory
				,dblScrap
				,ysnConsumptionRequired
				,dblPercentage
				,intMarginById
				,dblMargin
				,ysnCostAppliedAtInvoice
				,ysnPartialFillConsumption
				,intManufacturingCellId
				,intWorkOrderId
				,intCreatedUserId
				,dtmCreated
				,intLastModifiedUserId
				,dtmLastModified
				,intConcurrencyId
				,intCostDriverId
				,dblCostRate
				,ysnLock
				)
			SELECT intRecipeItemId = @intRecipeItemId
				,intRecipeId = @intRecipeId
				,intItemId = @intInputItemId
				,dblQuantity = 1
				,dblCalculatedQuantity = 1
				,[intItemUOMId] = @intInputItemUOMId2
				,intRecipeItemTypeId = 1
				,strItemGroupName = ''
				,dblUpperTolerance = 100
				,dblLowerTolerance = 100
				,dblCalculatedUpperTolerance = 2
				,dblCalculatedLowerTolerance = 1
				,dblShrinkage = 0
				,ysnScaled = 1
				,intConsumptionMethodId = 1
				,intStorageLocationId = NULL
				,dtmValidFrom = '2018-01-01'
				,dtmValidTo = '2018-12-31'
				,ysnYearValidationRequired = 0
				,ysnMinorIngredient = 0
				,intReferenceRecipeId = NULL
				,ysnOutputItemMandatory = 0
				,dblScrap = 0
				,ysnConsumptionRequired = 0
				,[dblCostAllocationPercentage] = NULL
				,intMarginById = NULL
				,dblMargin = NULL
				,ysnCostAppliedAtInvoice = NULL
				,ysnPartialFillConsumption = 1
				,intManufacturingCellId = @intManufacturingCellId
				,intWorkOrderId = @intWorkOrderId
				,intCreatedUserId = @intUserId
				,dtmCreated = @dtmCurrentDateTime
				,intLastModifiedUserId = @intUserId
				,dtmLastModified = @dtmCurrentDateTime
				,intConcurrencyId = 1
				,intCostDriverId = NULL
				,dblCostRate = NULL
				,ysnLock=1
		END
		ELSE
		BEGIN
			SELECT @intRecipeSubstituteItemId = Max(intRecipeSubstituteItemId) + 1
			FROM tblMFWorkOrderRecipeSubstituteItem

			IF @intRecipeSubstituteItemId IS NULL
			BEGIN
				SELECT @intRecipeSubstituteItemId = 1
			END

			SELECT @intItemId2 = intItemId
				,@intRecipeItemId = intRecipeItemId
			FROM tblMFWorkOrderRecipeItem RI
			WHERE RI.intWorkOrderId = @intWorkOrderId
				AND RI.dblCalculatedQuantity <> 0
				AND RI.intRecipeItemTypeId = 1

			INSERT INTO tblMFWorkOrderRecipeSubstituteItem (
				intWorkOrderId
				,intRecipeSubstituteItemId
				,intRecipeItemId
				,intRecipeId
				,intItemId
				,intSubstituteItemId
				,dblQuantity
				,intItemUOMId
				,dblSubstituteRatio
				,dblMaxSubstituteRatio
				,dblCalculatedUpperTolerance
				,dblCalculatedLowerTolerance
				,intRecipeItemTypeId
				,intCreatedUserId
				,dtmCreated
				,intLastModifiedUserId
				,dtmLastModified
				,intConcurrencyId
				,ysnLock
				)
			SELECT intWorkOrderId = @intWorkOrderId
				,intRecipeSubstituteItemId = @intRecipeSubstituteItemId
				,intRecipeItemId = @intRecipeItemId
				,intRecipeId = @intRecipeId
				,intItemId = @intItemId2
				,intSubstituteItemId = @intInputItemId
				,dblQuantity = 1
				,intItemUOMId = @intInputItemUOMId2
				,dblSubstituteRatio = 1
				,dblMaxSubstituteRatio = 100
				,dblCalculatedUpperTolerance = 2
				,dblCalculatedLowerTolerance = 0
				,intRecipeItemTypeId = 1
				,intCreatedUserId = @intUserId
				,dtmCreated = @dtmCurrentDateTime
				,intLastModifiedUserId = @intUserId
				,dtmLastModified = @dtmCurrentDateTime
				,intConcurrencyId = 1
				,ysnLock=1
		END

		IF @intRecipeTypeId = 3
		BEGIN
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
		END
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
	END

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
	JOIN tblICLot L ON L.intLotId = WI.intLotId
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
