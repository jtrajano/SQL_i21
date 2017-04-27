CREATE PROCEDURE [dbo].[uspMFCompleteWorkOrder] (
	@strXML NVARCHAR(MAX)
	,@strOutputLotNumber NVARCHAR(50) = '' OUTPUT
	,@intParentLotId INT = 0 OUTPUT
	)
AS
BEGIN TRY
	DECLARE @idoc INT
		,@ErrMsg NVARCHAR(MAX)
		,@intWorkOrderId INT
		,@dblProduceQty NUMERIC(38, 20)
		,@intProduceUnitMeasureId INT
		,@strVesselNo NVARCHAR(50)
		,@intUserId INT
		,@intItemId INT
		,@strVendorLotNo NVARCHAR(50)
		,@strWorkOrderNo NVARCHAR(50)
		,@intItemUOMId INT
		,@intInputLotId INT
		,@intManufacturingCellId INT
		,@intLocationId INT
		,@dtmPlannedDate DATETIME
		,@intPlannedShiftId INT
		,@intStatusId INT
		,@intManufacturingProcessId INT
		,@intStorageLocationId INT
		,@intContainerId INT
		,@dblTareWeight NUMERIC(38, 20)
		,@dblUnitQty NUMERIC(38, 20)
		,@dblPhysicalCount NUMERIC(38, 20)
		,@intPhysicalItemUOMId INT
		,@ysnEmptyOutSource BIT
		,@intExecutionOrder INT
		,@dblInputWeight NUMERIC(38, 20)
		,@intBatchId INT
		,@dtmCurrentDate DATETIME
		,@intSubLocationId INT
		,@ysnNegativeQtyAllowed BIT
		,@ysnSubLotAllowed BIT
		,@strRetBatchId NVARCHAR(40)
		,@intLotId INT
		,@strLotTracking NVARCHAR(50)
		,@intProductionTypeId INT
		,@ysnAllowMultipleItem BIT
		,@ysnAllowMultipleLot BIT
		,@ysnMergeOnMove BIT
		,@intMachineId INT
		,@ysnLotAlias BIT
		,@strLotAlias NVARCHAR(50)
		,@strReferenceNo NVARCHAR(50)
		,@ysnPostProduction BIT
		,@STARTING_NUMBER_BATCH AS INT = 3
		,@intDepartmentId INT
		,@dblWeight NUMERIC(18, 6)
		,@ysnExcessConsumptionAllowed BIT
		,@strInputLotNumber NVARCHAR(50)
		,@intInputLotItemUOMId INT
		,@intInputLotStorageLocationId INT
		,@intInputLotSubLocationId INT
		,@dblInputLotWeight NUMERIC(18, 6)
		,@intInputLotWeightUOMId INT
		,@dblInputLotWeightPerQty NUMERIC(18, 6)
		,@dblAdjustByQuantity NUMERIC(18, 6)
		,@intInventoryAdjustmentId INT
		,@intInputLotItemId INT
		,@intTransactionCount INT
		,@intLotStatusId INT
		,@intAttributeId INT
		,@strYieldAdjustmentAllowed NVARCHAR(50)
		,@strComment NVARCHAR(MAX)
		,@strParentLotNumber NVARCHAR(50)
		,@ysnIgnoreTolerance BIT
		,@intCategoryId INT
		,@dtmBusinessDate DATETIME
		,@strInstantConsumption NVARCHAR(50)
		,@ysnConsumptionRequired BIT
		,@ysnPostConsumption BIT
		,@strInputQuantityReadOnly NVARCHAR(50)
		,@intInputItemId INT
		,@strInputItemLotTracking NVARCHAR(50)
		,@intInputItemUOMId INT
		,@strCreateMultipleLots NVARCHAR(50)
		,@intBusinessShiftId INT
		,@ysnFillPartialPallet bit
		,@intSpecialPalletLotId int
		,@strComputeGrossWeight nvarchar(50)

	SELECT @intTransactionCount = @@TRANCOUNT

	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@strXML

	SELECT @intWorkOrderId = intWorkOrderId
		,@intManufacturingProcessId = intManufacturingProcessId
		,@dtmPlannedDate = dtmPlannedDate
		,@intPlannedShiftId = intPlannedShiftId
		,@intStatusId = intStatusId
		,@intItemId = intItemId
		,@dblProduceQty = dblProduceQty
		,@intProduceUnitMeasureId = intProduceUnitMeasureId
		,@dblTareWeight = dblTareWeight
		,@dblUnitQty = dblUnitQty
		,@dblPhysicalCount = (
			CASE 
				WHEN @intWorkOrderId = 0
					THEN dbo.fnDivide(dblProduceQty, dblUnitQty)
				ELSE dblPhysicalCount
				END
			)
		,@intPhysicalItemUOMId = (
			CASE 
				WHEN intPhysicalItemUOMId = 0
					THEN NULL
				ELSE intPhysicalItemUOMId
				END
			)
		,@strVesselNo = strVesselNo
		,@intUserId = intUserId
		,@strOutputLotNumber = strOutputLotNumber
		,@strVendorLotNo = strVendorLotNo
		,@intInputLotId = intInputLotId
		,@intInputItemId = intInputItemId
		,@dblInputWeight = dblInputWeight
		,@intInputItemUOMId = intInputItemUOMId
		,@intLocationId = intLocationId
		,@intSubLocationId = intSubLocationId
		,@intStorageLocationId = intStorageLocationId
		,@intContainerId = intContainerId
		,@ysnEmptyOutSource = ysnEmptyOutSource
		,@ysnNegativeQtyAllowed = ysnNegativeQtyAllowed
		,@ysnSubLotAllowed = ysnSubLotAllowed
		,@intProductionTypeId = intProductionTypeId
		,@intMachineId = intMachineId
		,@ysnLotAlias = ysnLotAlias
		,@strLotAlias = strLotAlias
		,@strReferenceNo = strReferenceNo
		,@ysnPostProduction = ysnPostProduction
		,@intDepartmentId = intDepartmentId
		,@ysnExcessConsumptionAllowed = ysnExcessConsumptionAllowed
		,@intLotStatusId = intLotStatusId
		,@strComment = strComment
		,@strParentLotNumber = strParentLotNumber
		,@ysnIgnoreTolerance = ysnIgnoreTolerance
		,@ysnFillPartialPallet=ysnFillPartialPallet
		,@intSpecialPalletLotId=intSpecialPalletLotId
	FROM OPENXML(@idoc, 'root', 2) WITH (
			intWorkOrderId INT
			,intManufacturingProcessId INT
			,dtmPlannedDate DATETIME
			,intPlannedShiftId INT
			,intStatusId INT
			,intItemId INT
			,dblProduceQty NUMERIC(38, 20)
			,intProduceUnitMeasureId INT
			,dblTareWeight NUMERIC(38, 20)
			,dblUnitQty NUMERIC(38, 20)
			,dblPhysicalCount NUMERIC(38, 20)
			,intPhysicalItemUOMId INT
			,strVesselNo NVARCHAR(50)
			,intUserId INT
			,strOutputLotNumber NVARCHAR(50)
			,strVendorLotNo NVARCHAR(50)
			,intInputLotId INT
			,intInputItemId INT
			,dblInputWeight NUMERIC(38, 20)
			,intInputItemUOMId INT
			,intLocationId INT
			,intSubLocationId INT
			,intStorageLocationId INT
			,intContainerId INT
			,ysnEmptyOutSource BIT
			,ysnNegativeQtyAllowed BIT
			,ysnSubLotAllowed BIT
			,intProductionTypeId INT
			,intMachineId INT
			,ysnLotAlias BIT
			,strLotAlias NVARCHAR(50)
			,strReferenceNo NVARCHAR(50)
			,ysnPostProduction BIT
			,intDepartmentId INT
			,ysnExcessConsumptionAllowed BIT
			,intLotStatusId INT
			,strComment NVARCHAR(MAX)
			,strParentLotNumber NVARCHAR(50)
			,ysnIgnoreTolerance BIT
			,ysnFillPartialPallet bit
			,intSpecialPalletLotId int
			)

	SELECT @strComputeGrossWeight = strAttributeValue
	FROM tblMFManufacturingProcessAttribute
	WHERE intManufacturingProcessId = @intManufacturingProcessId
		AND intLocationId = @intLocationId
		AND intAttributeId = 89

	if @strComputeGrossWeight='True'
	Begin
		Select @dblProduceQty =@dblPhysicalCount *@dblUnitQty 
	end


	IF @ysnIgnoreTolerance IS NULL
		SELECT @ysnIgnoreTolerance = 1

	SELECT @intAttributeId = intAttributeId
	FROM tblMFAttribute
	WHERE strAttributeName = 'Is Yield Adjustment Allowed'

	SELECT @strYieldAdjustmentAllowed = strAttributeValue
	FROM tblMFManufacturingProcessAttribute
	WHERE intManufacturingProcessId = @intManufacturingProcessId
		AND intLocationId = @intLocationId
		AND intAttributeId = @intAttributeId

	SELECT @ysnExcessConsumptionAllowed = 0

	IF @strYieldAdjustmentAllowed = 'True'
	BEGIN
		SELECT @ysnExcessConsumptionAllowed = 1
	END

	IF @intTransactionCount = 0
		BEGIN TRANSACTION

	SELECT @dtmCurrentDate = GetDate()

	SELECT @dtmBusinessDate = dbo.fnGetBusinessDate(@dtmCurrentDate, @intLocationId)

	SELECT @intBusinessShiftId = intShiftId
	FROM dbo.tblMFShift
	WHERE intLocationId = @intLocationId
		AND @dtmCurrentDate BETWEEN @dtmBusinessDate + dtmShiftStartTime + intStartOffset
			AND @dtmBusinessDate + dtmShiftEndTime + intEndOffset

	IF @dtmPlannedDate IS NULL
		SELECT @dtmPlannedDate = @dtmBusinessDate

	SELECT @strLotTracking = strLotTracking
		,@intCategoryId = intCategoryId
	FROM dbo.tblICItem
	WHERE intItemId = @intItemId

	SELECT @ysnAllowMultipleItem = ysnAllowMultipleItem
		,@ysnAllowMultipleLot = ysnAllowMultipleLot
		,@ysnMergeOnMove = ysnMergeOnMove
	FROM dbo.tblICStorageLocation
	WHERE intStorageLocationId = @intStorageLocationId

	IF @ysnAllowMultipleLot = 0
		AND @ysnMergeOnMove = 1
	BEGIN
		SELECT @strOutputLotNumber = strLotNumber
		FROM tblICLot
		WHERE intStorageLocationId = @intStorageLocationId
			AND intItemId = @intItemId
			AND dblQty > 0
			AND intLotStatusId = 1
			AND ISNULL(dtmExpiryDate, @dtmCurrentDate) >= @dtmCurrentDate
	END
	ELSE IF EXISTS (
			SELECT *
			FROM tblICLot
			WHERE intStorageLocationId = @intStorageLocationId
				AND dblQty > 0
			)
		AND EXISTS (
			SELECT *
			FROM dbo.tblICStorageLocation
			WHERE intStorageLocationId = @intStorageLocationId
				AND ysnAllowMultipleItem = 0
				AND ysnAllowMultipleLot = 0
				AND ysnMergeOnMove = 0
			)
	BEGIN
		PRINT 'Call Lot Move'
	END

	IF (
			@strOutputLotNumber = ''
			OR @strOutputLotNumber IS NULL
			)
		AND @strLotTracking = 'Yes - Manual'
	BEGIN
		--EXEC dbo.uspSMGetStartingNumber 24
		--	,@strOutputLotNumber OUTPUT
		EXEC dbo.uspMFGeneratePatternId @intCategoryId = @intCategoryId
			,@intItemId = @intItemId
			,@intManufacturingId = @intManufacturingCellId
			,@intSubLocationId = @intSubLocationId
			,@intLocationId = @intLocationId
			,@intOrderTypeId = NULL
			,@intBlendRequirementId = NULL
			,@intPatternCode = 24
			,@ysnProposed = 0
			,@strPatternString = @strOutputLotNumber OUTPUT
			,@intShiftId = @intPlannedShiftId
			,@dtmDate = @dtmPlannedDate
	END

	IF EXISTS (
			SELECT *
			FROM dbo.tblICContainer C
			JOIN dbo.tblICContainerType CT ON C.intContainerTypeId = CT.intContainerTypeId
				AND CT.ysnAllowMultipleLots = 0
				AND CT.ysnAllowMultipleItems = 0
				AND CT.ysnMergeOnMove = 0
				AND C.intContainerId = @intContainerId
				AND EXISTS (
					SELECT 1
					FROM dbo.tblICLot L
					WHERE intContainerId = @intContainerId
						AND L.dblQty > 0
					)
			)
	BEGIN
		PRINT 'Move the selected lot''s container to Audit container'
	END

	SELECT @intAttributeId = intAttributeId
	FROM tblMFAttribute
	WHERE strAttributeName = 'Is Instant Consumption'

	SELECT @strInstantConsumption = strAttributeValue
	FROM tblMFManufacturingProcessAttribute
	WHERE intManufacturingProcessId = @intManufacturingProcessId
		AND intLocationId = @intLocationId
		AND intAttributeId = @intAttributeId

	IF @strInstantConsumption = 'False'
	BEGIN
		SELECT @intBatchId = intBatchID
		FROM tblMFWorkOrder
		WHERE intWorkOrderId = @intWorkOrderId
	END

	IF @intBatchId IS NULL
		OR @intBatchId = 0
	BEGIN
		EXEC dbo.uspMFGeneratePatternId @intCategoryId = @intCategoryId
			,@intItemId = @intItemId
			,@intManufacturingId = @intManufacturingCellId
			,@intSubLocationId = @intSubLocationId
			,@intLocationId = @intLocationId
			,@intOrderTypeId = NULL
			,@intBlendRequirementId = NULL
			,@intPatternCode = 33
			,@ysnProposed = 0
			,@strPatternString = @intBatchId OUTPUT
	END

	IF @intWorkOrderId IS NULL
		OR @intWorkOrderId = 0
	BEGIN
		SELECT @dblInputLotWeight = (
				CASE 
					WHEN L.intWeightUOMId IS NOT NULL
						THEN L.dblWeight
					ELSE L.dblQty
					END
				)
			,@strInputLotNumber = strLotNumber
			,@intInputLotItemId = intItemId
			,@intInputLotStorageLocationId = intStorageLocationId
			,@intInputLotSubLocationId = intSubLocationId
			,@intInputLotWeightUOMId = intWeightUOMId
			,@dblInputLotWeightPerQty = dblWeightPerQty
			,@intItemUOMId = intItemUOMId
		FROM dbo.tblICLot L
		WHERE intLotId = @intInputLotId

		IF @dblInputWeight > @dblInputLotWeight --and @ysnEmptyOutSource=0
		BEGIN
			IF @ysnExcessConsumptionAllowed = 0
			BEGIN
				RAISERROR (
						'The quantity to be consumed must not exceed the selected lot quantity.'
						,14
						,1
						)
			END

			SELECT @dblAdjustByQuantity = (@dblInputWeight - @dblInputLotWeight) / (
					CASE 
						WHEN @intInputLotWeightUOMId IS NULL
							THEN 1
						ELSE @dblInputLotWeightPerQty
						END
					)

			EXEC [uspICInventoryAdjustment_CreatePostQtyChange]
				-- Parameters for filtering:
				@intItemId = @intInputLotItemId
				,@dtmDate = @dtmCurrentDate
				,@intLocationId = @intLocationId
				,@intSubLocationId = @intInputLotSubLocationId
				,@intStorageLocationId = @intInputLotStorageLocationId
				,@strLotNumber = @strInputLotNumber
				-- Parameters for the new values: 
				,@dblAdjustByQuantity = @dblAdjustByQuantity
				,@dblNewUnitCost = NULL
				,@intItemUOMId = @intItemUOMId
				-- Parameters used for linking or FK (foreign key) relationships
				,@intSourceId = 1
				,@intSourceTransactionTypeId = 8
				,@intEntityUserSecurityId = @intUserId
				,@intInventoryAdjustmentId = @intInventoryAdjustmentId OUTPUT
		END

		--EXEC dbo.uspSMGetStartingNumber 59
		--	,@strWorkOrderNo OUTPUT
		EXEC dbo.uspMFGeneratePatternId @intCategoryId = @intCategoryId
			,@intItemId = @intItemId
			,@intManufacturingId = @intManufacturingCellId
			,@intSubLocationId = @intSubLocationId
			,@intLocationId = @intLocationId
			,@intOrderTypeId = NULL
			,@intBlendRequirementId = NULL
			,@intPatternCode = 59
			,@ysnProposed = 0
			,@strPatternString = @strWorkOrderNo OUTPUT

		--SELECT @intManufacturingCellId = intManufacturingCellId
		--FROM dbo.tblMFRecipe
		--WHERE intItemId = @intItemId
		--	AND intLocationId = @intLocationId
		--	AND ysnActive = 1
		DECLARE @intItemFactoryId INT

		SELECT @intItemFactoryId = intItemFactoryId
		FROM tblICItemFactory
		WHERE intItemId = @intItemId
			AND intFactoryId = @intLocationId

		SELECT @intManufacturingCellId = intManufacturingCellId
		FROM tblICItemFactoryManufacturingCell
		WHERE intItemFactoryId = @intItemFactoryId
			AND ysnDefault = 1

		IF @intSubLocationId IS NULL
			SELECT @intSubLocationId = intSubLocationId
			FROM tblMFManufacturingCell
			WHERE intManufacturingCellId = @intManufacturingCellId

		SELECT @intItemUOMId = @intProduceUnitMeasureId

		--IF NOT EXISTS (
		--		SELECT *
		--		FROM dbo.tblICItemUOM
		--		WHERE intItemId = @intItemId
		--			AND intItemUOMId = @intItemUOMId
		--			AND ysnStockUnit = 1
		--		)
		--BEGIN
		--	RAISERROR (
		--			51094
		--			,11
		--			,1
		--			)
		--END
		SELECT @intExecutionOrder = Max(intExecutionOrder) + 1
		FROM dbo.tblMFWorkOrder
		WHERE dtmExpectedDate = @dtmPlannedDate

		INSERT INTO dbo.tblMFWorkOrder (
			strWorkOrderNo
			,intManufacturingProcessId
			,intItemId
			,dblQuantity
			,intItemUOMId
			,intStatusId
			,intManufacturingCellId
			,intStorageLocationId
			,intSubLocationId
			,intLocationId
			,dtmCreated
			,intCreatedUserId
			,dtmLastModified
			,intLastModifiedUserId
			,strVendorLotNo
			,dtmPlannedDate
			,intPlannedShiftId
			,dtmExpectedDate
			,intExecutionOrder
			,dtmActualProductionStartDate
			,intProductionTypeId
			,intBatchID
			,intDepartmentId
			)
		SELECT @strWorkOrderNo
			,@intManufacturingProcessId
			,@intItemId
			,@dblProduceQty
			,@intItemUOMId
			,10
			,@intManufacturingCellId
			,@intStorageLocationId
			,@intSubLocationId
			,@intLocationId
			,@dtmCurrentDate
			,@intUserId
			,@dtmCurrentDate
			,@intUserId
			,@strVendorLotNo
			,@dtmPlannedDate
			,@intPlannedShiftId
			,@dtmPlannedDate
			,ISNULL(@intExecutionOrder, 1)
			,@dtmCurrentDate
			,1
			,@intBatchId
			,@intDepartmentId

		SET @intWorkOrderId = SCOPE_IDENTITY()

		SELECT @intAttributeId = NULL

		SELECT @intAttributeId = intAttributeId
		FROM dbo.tblMFAttribute
		WHERE strAttributeName = 'Is Input Quantity Read Only'

		SELECT @strInputQuantityReadOnly = strAttributeValue
		FROM tblMFManufacturingProcessAttribute
		WHERE intManufacturingProcessId = @intManufacturingProcessId
			AND intLocationId = @intLocationId
			AND intAttributeId = @intAttributeId

		IF @strInputQuantityReadOnly = 'True'
		BEGIN
			SELECT @dblInputWeight = ri.dblCalculatedQuantity * (
					(
						CASE 
							WHEN r.intItemUOMId = @intProduceUnitMeasureId
								THEN @dblProduceQty
							ELSE @dblPhysicalCount
							END
						) / r.dblQuantity
					)
			FROM dbo.tblMFRecipeItem ri
			JOIN dbo.tblMFRecipe r ON r.intRecipeId = ri.intRecipeId
			LEFT JOIN dbo.tblMFRecipeSubstituteItem rs ON rs.intRecipeItemId = ri.intRecipeItemId
			WHERE r.intItemId = @intItemId
				AND r.intLocationId = @intLocationId
				AND r.ysnActive = 1
				AND (
					ri.intItemId = @intInputLotItemId
					OR rs.intSubstituteItemId = @intInputLotItemId
					)
		END

		SELECT @strInputItemLotTracking = strInventoryTracking
		FROM dbo.tblICItem
		WHERE intItemId = @intInputItemId

		IF @strInputItemLotTracking = 'Lot Level'
		BEGIN
			INSERT INTO dbo.tblMFWorkOrderConsumedLot (
				intWorkOrderId
				,intItemId
				,intLotId
				,dblQuantity
				,intItemUOMId
				,dblIssuedQuantity
				,intItemIssuedUOMId
				,intBatchId
				,intSequenceNo
				,dtmCreated
				,intCreatedUserId
				,dtmLastModified
				,intLastModifiedUserId
				)
			SELECT @intWorkOrderId
				,intItemId
				,intLotId
				,CASE 
					WHEN @dblInputWeight = 0
						THEN (
								CASE 
									WHEN L.intWeightUOMId IS NOT NULL
										THEN L.dblWeight
									ELSE L.dblQty
									END
								)
					ELSE @dblInputWeight
					END
				,ISNULL(intWeightUOMId, intItemUOMId)
				,CASE 
					WHEN @dblInputWeight = 0
						THEN (
								CASE 
									WHEN L.intWeightUOMId IS NOT NULL
										THEN L.dblWeight
									ELSE L.dblQty
									END
								)
					ELSE @dblInputWeight
					END
				,ISNULL(intWeightUOMId, intItemUOMId)
				,@intBatchId
				,1
				,@dtmCurrentDate
				,@intUserId
				,@dtmCurrentDate
				,@intUserId
			FROM dbo.tblICLot L
			WHERE intLotId = @intInputLotId
		END
		ELSE
		BEGIN
			INSERT INTO dbo.tblMFWorkOrderConsumedLot (
				intWorkOrderId
				,intItemId
				,intLotId
				,dblQuantity
				,intItemUOMId
				,dblIssuedQuantity
				,intItemIssuedUOMId
				,intBatchId
				,intSequenceNo
				,dtmCreated
				,intCreatedUserId
				,dtmLastModified
				,intLastModifiedUserId
				)
			SELECT @intWorkOrderId
				,@intInputItemId
				,NULL
				,@dblInputWeight
				,@intInputItemUOMId
				,@dblInputWeight
				,@intInputItemUOMId
				,@intBatchId
				,1
				,@dtmCurrentDate
				,@intUserId
				,@dtmCurrentDate
				,@intUserId
		END

		EXEC dbo.uspMFCopyRecipe @intItemId = @intItemId
			,@intLocationId = @intLocationId
			,@intUserId = @intUserId
			,@intWorkOrderId = @intWorkOrderId

		SELECT @strLotAlias = @strWorkOrderNo
	END

	SELECT @intAttributeId = intAttributeId
	FROM tblMFAttribute
	WHERE strAttributeName = 'Is Instant Consumption'

	SELECT @strInstantConsumption = strAttributeValue
	FROM tblMFManufacturingProcessAttribute
	WHERE intManufacturingProcessId = @intManufacturingProcessId
		AND intLocationId = @intLocationId
		AND intAttributeId = @intAttributeId

	IF @strInstantConsumption = 'False'
		AND @intProductionTypeId = 3
	BEGIN
		SELECT @intProductionTypeId = 2
	END

	IF @strInstantConsumption = 'True'
		AND @intProductionTypeId = 2
	BEGIN
		SELECT @intProductionTypeId = 3

		SELECT @ysnPostProduction = 0
	END

	SELECT @ysnConsumptionRequired = ysnConsumptionRequired
	FROM dbo.tblMFWorkOrderRecipeItem
	WHERE intRecipeItemTypeId = 2
		AND intItemId = @intItemId
		AND intWorkOrderId = @intWorkOrderId

	IF @intProductionTypeId IN (
			1
			,3
			)
		AND @ysnConsumptionRequired = 1
	BEGIN
		IF EXISTS (
				SELECT *
				FROM tblMFWorkOrderRecipe
				WHERE intWorkOrderId = @intWorkOrderId
					AND intItemUOMId = @intProduceUnitMeasureId
				)
		BEGIN
			EXEC dbo.uspMFPickWorkOrder @intWorkOrderId = @intWorkOrderId
				,@dblProduceQty = @dblProduceQty
				,@intProduceUOMId = @intProduceUnitMeasureId
				,@intBatchId = @intBatchId
				,@intUserId = @intUserId
				,@dblUnitQty = @dblUnitQty
				,@ysnProducedQtyByWeight = 1
				,@ysnFillPartialPallet=@ysnFillPartialPallet

			EXEC dbo.uspMFConsumeWorkOrder @intWorkOrderId = @intWorkOrderId
				,@dblProduceQty = @dblProduceQty
				,@intProduceUOMKey = @intProduceUnitMeasureId
				,@intUserId = @intUserId
				,@ysnNegativeQtyAllowed = @ysnNegativeQtyAllowed
				,@strRetBatchId = @strRetBatchId OUTPUT
				,@intBatchId = @intBatchId
				,@ysnPostConsumption = @ysnPostConsumption
		END
		ELSE
		BEGIN
			EXEC dbo.uspMFPickWorkOrder @intWorkOrderId = @intWorkOrderId
				,@dblProduceQty = @dblPhysicalCount
				,@intProduceUOMId = @intPhysicalItemUOMId
				,@intBatchId = @intBatchId
				,@intUserId = @intUserId
				,@dblUnitQty = @dblUnitQty
				,@ysnProducedQtyByWeight = 0
				,@ysnFillPartialPallet=@ysnFillPartialPallet

			EXEC dbo.uspMFConsumeWorkOrder @intWorkOrderId = @intWorkOrderId
				,@dblProduceQty = @dblPhysicalCount
				,@intProduceUOMKey = @intPhysicalItemUOMId
				,@intUserId = @intUserId
				,@ysnNegativeQtyAllowed = @ysnNegativeQtyAllowed
				,@strRetBatchId = @strRetBatchId OUTPUT
				,@intBatchId = @intBatchId
				,@ysnPostConsumption = @ysnPostConsumption
				
		END

		EXEC uspMFConsumeSKU @intWorkOrderId = @intWorkOrderId
	END

	IF @intProductionTypeId IN (
			2
			,3
			)
	BEGIN
		IF @strInstantConsumption = 'False'
		BEGIN
			SELECT @strRetBatchId = strBatchId
			FROM tblMFWorkOrder
			WHERE intWorkOrderId = @intWorkOrderId
		END

		IF @strRetBatchId IS NULL
		BEGIN
			-- Get the next batch number
			EXEC dbo.uspSMGetStartingNumber @STARTING_NUMBER_BATCH
				,@strRetBatchId OUTPUT
		END

		EXEC dbo.uspMFValidateCreateLot @strLotNumber = @strOutputLotNumber
			,@dtmCreated = @dtmPlannedDate
			,@intShiftId = @intPlannedShiftId
			,@intItemId = @intItemId
			,@intStorageLocationId = @intStorageLocationId
			,@intSubLocationId = @intSubLocationId
			,@intLocationId = @intLocationId
			,@dblQuantity = @dblProduceQty
			,@intItemUOMId = @intProduceUnitMeasureId
			,@dblUnitCount = @dblPhysicalCount
			,@intItemUnitCountUOMId = @intPhysicalItemUOMId
			,@ysnNegativeQtyAllowed = @ysnNegativeQtyAllowed
			,@ysnSubLotAllowed = @ysnSubLotAllowed
			,@intWorkOrderId = @intWorkOrderId
			,@intLotTransactionTypeId = 3
			,@ysnCreateNewLot = 1
			,@ysnFGProduction = 0
			,@ysnIgnoreTolerance = @ysnIgnoreTolerance
			,@intMachineId = @intMachineId
			,@ysnLotAlias = @ysnLotAlias
			,@strLotAlias = @strLotAlias
			,@intProductionTypeId = @intProductionTypeId
			,@ysnFillPartialPallet=@ysnFillPartialPallet

		SELECT @strCreateMultipleLots = strAttributeValue
		FROM tblMFManufacturingProcessAttribute
		WHERE intManufacturingProcessId = @intManufacturingProcessId
			AND intLocationId = @intLocationId
			AND intAttributeId = 82

		IF @strCreateMultipleLots = 'True'
			AND @dblPhysicalCount > 0
			AND @intProduceUnitMeasureId <> @intPhysicalItemUOMId
		BEGIN
			WHILE @dblPhysicalCount > 0
			BEGIN
				IF Ceiling(@dblPhysicalCount) = 1
					AND @dblProduceQty % @dblUnitQty > 0
				BEGIN
					SELECT @dblUnitQty = @dblProduceQty % @dblUnitQty
				END

				EXEC dbo.uspMFProduceWorkOrder @intWorkOrderId = @intWorkOrderId
					,@intItemId = @intItemId
					,@dblProduceQty = @dblUnitQty
					,@intProduceUOMKey = @intProduceUnitMeasureId
					,@strVesselNo = @strVesselNo
					,@intUserId = @intUserId
					,@intStorageLocationId = @intStorageLocationId
					,@strLotNumber = @strOutputLotNumber
					,@intContainerId = @intContainerId
					,@dblTareWeight = @dblTareWeight
					,@dblUnitQty = @dblUnitQty
					,@dblPhysicalCount = 1
					,@intPhysicalItemUOMId = @intPhysicalItemUOMId
					,@intBatchId = @intBatchId
					,@strBatchId = @strRetBatchId
					,@intShiftId = @intPlannedShiftId
					,@strReferenceNo = @strReferenceNo
					,@intStatusId = @intStatusId
					,@intLotId = @intLotId OUTPUT
					,@ysnPostProduction = @ysnPostProduction
					,@strLotAlias = @strLotAlias
					,@intLocationId = @intLocationId
					,@intMachineId = @intMachineId
					,@dtmProductionDate = @dtmPlannedDate
					,@strVendorLotNo = @strVendorLotNo
					,@strComment = @strComment
					,@strParentLotNumber = @strParentLotNumber
					,@intInputLotId = @intInputLotId
					,@intInputStorageLocationId = @intInputLotStorageLocationId
					,@ysnFillPartialPallet=@ysnFillPartialPallet
					,@intSpecialPalletLotId=@intSpecialPalletLotId

				IF @intLotStatusId IS NOT NULL
					AND NOT EXISTS (
						SELECT *
						FROM dbo.tblICLot
						WHERE intLotId = @intLotId
							AND intLotStatusId = @intLotStatusId
						)
					AND @strLotTracking = 'Yes'
				BEGIN
					EXEC uspMFSetLotStatus @intLotId
						,@intLotStatusId
						,@intUserId
				END

				EXEC uspQMSampleCreateBySystem @intWorkOrderId = @intWorkOrderId
					,@intItemId = @intItemId
					,@intOutputLotId = @intLotId
					,@intLocationId = @intLocationId
					,@intUserId = @intUserId

				SELECT @dblPhysicalCount = @dblPhysicalCount - 1

				IF @strLotTracking = 'Yes - Manual'
					AND @dblPhysicalCount > 0
				BEGIN
					--EXEC dbo.uspSMGetStartingNumber 24
					--	,@strOutputLotNumber OUTPUT
					EXEC dbo.uspMFGeneratePatternId @intCategoryId = @intCategoryId
						,@intItemId = @intItemId
						,@intManufacturingId = @intManufacturingCellId
						,@intSubLocationId = @intSubLocationId
						,@intLocationId = @intLocationId
						,@intOrderTypeId = NULL
						,@intBlendRequirementId = NULL
						,@intPatternCode = 24
						,@ysnProposed = 0
						,@strPatternString = @strOutputLotNumber OUTPUT
						,@intShiftId = @intPlannedShiftId
						,@dtmDate = @dtmPlannedDate
				END
			END
		END
		ELSE
		BEGIN
			EXEC dbo.uspMFProduceWorkOrder @intWorkOrderId = @intWorkOrderId
				,@intItemId = @intItemId
				,@dblProduceQty = @dblProduceQty
				,@intProduceUOMKey = @intProduceUnitMeasureId
				,@strVesselNo = @strVesselNo
				,@intUserId = @intUserId
				,@intStorageLocationId = @intStorageLocationId
				,@strLotNumber = @strOutputLotNumber
				,@intContainerId = @intContainerId
				,@dblTareWeight = @dblTareWeight
				,@dblUnitQty = @dblUnitQty
				,@dblPhysicalCount = @dblPhysicalCount
				,@intPhysicalItemUOMId = @intPhysicalItemUOMId
				,@intBatchId = @intBatchId
				,@strBatchId = @strRetBatchId
				,@intShiftId = @intPlannedShiftId
				,@strReferenceNo = @strReferenceNo
				,@intStatusId = @intStatusId
				,@intLotId = @intLotId OUTPUT
				,@ysnPostProduction = @ysnPostProduction
				,@strLotAlias = @strLotAlias
				,@intLocationId = @intLocationId
				,@intMachineId = @intMachineId
				,@dtmProductionDate = @dtmPlannedDate
				,@strVendorLotNo = @strVendorLotNo
				,@strComment = @strComment
				,@strParentLotNumber = @strParentLotNumber
				,@intInputLotId = @intInputLotId
				,@intInputStorageLocationId = @intInputLotStorageLocationId
				,@ysnFillPartialPallet=@ysnFillPartialPallet
				,@intSpecialPalletLotId=@intSpecialPalletLotId

			IF @intLotStatusId IS NOT NULL
				AND NOT EXISTS (
					SELECT *
					FROM dbo.tblICLot
					WHERE intLotId = @intLotId
						AND intLotStatusId = @intLotStatusId
					)
				AND @strLotTracking <> 'No'
			BEGIN
				--UPDATE dbo.tblICLot
				--SET intLotStatusId = @intLotStatusId
				--WHERE intLotId = @intLotId
				EXEC uspMFSetLotStatus @intLotId
					,@intLotStatusId
					,@intUserId
			END

			EXEC uspQMSampleCreateBySystem @intWorkOrderId = @intWorkOrderId
				,@intItemId = @intItemId
				,@intOutputLotId = @intLotId
				,@intLocationId = @intLocationId
				,@intUserId = @intUserId
		END

		SELECT @strOutputLotNumber = strLotNumber
			,@intParentLotId = intParentLotId
		FROM dbo.tblICLot
		WHERE intLotId = @intLotId

		IF @strOutputLotNumber IS NULL
			SELECT @strOutputLotNumber = ''

		IF @intParentLotId IS NULL
			SELECT @intParentLotId = 0

		SELECT @strOutputLotNumber AS strOutputLotNumber
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


