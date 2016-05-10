﻿CREATE PROCEDURE [dbo].[uspMFCompleteWorkOrder] (@strXML NVARCHAR(MAX),@strOutputLotNumber nvarchar(50) Output,@intParentLotId int=NULL OUTPUT )
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
		,@intStatusId int
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
		,@intProductionTypeId int
		,@ysnAllowMultipleItem BIT
		,@ysnAllowMultipleLot BIT
		,@ysnMergeOnMove BIT
		,@intMachineId int
		,@ysnLotAlias bit
		,@strLotAlias nvarchar(50)
		,@strReferenceNo nvarchar(50)
		,@ysnPostProduction bit
		,@STARTING_NUMBER_BATCH AS INT = 3
		,@intDepartmentId int
		,@dblWeight numeric(18,6)
		,@ysnExcessConsumptionAllowed bit
		,@strInputLotNumber nvarchar(50)
		,@intInputLotItemUOMId int
		,@intInputLotStorageLocationId int
		,@intInputLotSubLocationId int
		,@dblInputLotWeight numeric(18,6)
		,@intInputLotWeightUOMId int
		,@dblInputLotWeightPerQty numeric(18,6)
		,@dblAdjustByQuantity numeric(18,6)
		,@intInventoryAdjustmentId int
		,@intInputLotItemId int
		,@intTransactionCount INT
		,@intLotStatusId int
		,@intAttributeId int
		,@strYieldAdjustmentAllowed nvarchar(50)
		,@strComment nvarchar(MAX)
		,@strParentLotNumber nvarchar(50)
		,@ysnIgnoreTolerance bit
		,@intCategoryId int
		,@dtmBusinessDate datetime
		,@strInstantConsumption nvarchar(50)
		,@ysnConsumptionRequired bit
		,@ysnPostConsumption bit
		,@strInputQuantityReadOnly nvarchar(50)
		,@intInputItemId int
		,@strInputItemLotTracking nvarchar(50)
		,@intInputItemUOMId int

	SELECT @intTransactionCount = @@TRANCOUNT

	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@strXML

	SELECT @intWorkOrderId = intWorkOrderId
		,@intManufacturingProcessId = intManufacturingProcessId
		,@dtmPlannedDate = dtmPlannedDate
		,@intPlannedShiftId = intPlannedShiftId
		,@intStatusId=intStatusId
		,@intItemId = intItemId
		,@dblProduceQty = dblProduceQty
		,@intProduceUnitMeasureId = intProduceUnitMeasureId
		,@dblTareWeight = dblTareWeight
		,@dblUnitQty = dblUnitQty
		,@dblPhysicalCount = (Case When @intWorkOrderId=0 Then dbo.fnDivide(dblProduceQty,dblUnitQty) Else dblPhysicalCount End)
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
		,@intInputItemId=intInputItemId
		,@dblInputWeight = dblInputWeight
		,@intInputItemUOMId=intInputItemUOMId
		,@intLocationId = intLocationId
		,@intSubLocationId = intSubLocationId
		,@intStorageLocationId = intStorageLocationId
		,@intContainerId = intContainerId
		,@ysnEmptyOutSource = ysnEmptyOutSource
		,@ysnNegativeQtyAllowed = ysnNegativeQtyAllowed
		,@ysnSubLotAllowed = ysnSubLotAllowed
		,@intProductionTypeId = intProductionTypeId
		,@intMachineId =intMachineId
		,@ysnLotAlias =ysnLotAlias
		,@strLotAlias =strLotAlias
		,@strReferenceNo=strReferenceNo
		,@ysnPostProduction=ysnPostProduction
		,@intDepartmentId=intDepartmentId
		,@ysnExcessConsumptionAllowed=ysnExcessConsumptionAllowed
		,@intLotStatusId=intLotStatusId
		,@strComment=strComment
		,@strParentLotNumber=strParentLotNumber
		,@ysnIgnoreTolerance=ysnIgnoreTolerance
	FROM OPENXML(@idoc, 'root', 2) WITH (
			intWorkOrderId INT
			,intManufacturingProcessId INT
			,dtmPlannedDate DATETIME
			,intPlannedShiftId INT
			,intStatusId int
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
			,intInputItemUOMId int
			,intLocationId INT
			,intSubLocationId INT
			,intStorageLocationId INT
			,intContainerId INT
			,ysnEmptyOutSource BIT
			,ysnNegativeQtyAllowed BIT
			,ysnSubLotAllowed BIT
			,intProductionTypeId int
			,intMachineId int
			,ysnLotAlias bit
			,strLotAlias nvarchar(50)
			,strReferenceNo nvarchar(50)
			,ysnPostProduction bit
			,intDepartmentId int
			,ysnExcessConsumptionAllowed bit
			,intLotStatusId int
			,strComment nvarchar(MAX)
			,strParentLotNumber nvarchar(50)
			,ysnIgnoreTolerance bit
			)

	IF @ysnIgnoreTolerance IS NULL
	SELECT @ysnIgnoreTolerance=1

	Select @intAttributeId=intAttributeId from tblMFAttribute Where strAttributeName='Is Yield Adjustment Allowed'

	Select @strYieldAdjustmentAllowed=strAttributeValue
	From tblMFManufacturingProcessAttribute
	Where intManufacturingProcessId=@intManufacturingProcessId and intLocationId=@intLocationId and intAttributeId=@intAttributeId

	Select @ysnExcessConsumptionAllowed=0
	If @strYieldAdjustmentAllowed='True'
	Begin
		Select @ysnExcessConsumptionAllowed=1
	End

	IF @intTransactionCount = 0
	BEGIN TRANSACTION

	SELECT @dtmCurrentDate = GetDate()

	SELECT @dtmBusinessDate = dbo.fnGetBusinessDate(@dtmCurrentDate, @intLocationId)

	If @dtmPlannedDate Is NULL
	Select @dtmPlannedDate=@dtmBusinessDate

	SELECT @strLotTracking = strLotTracking
			,@intCategoryId=intCategoryId
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
			AND ISNULL(dtmExpiryDate,@dtmCurrentDate) >= @dtmCurrentDate

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
			AND @strLotTracking <> 'Yes - Serial Number'
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

	--EXEC dbo.uspSMGetStartingNumber 33
	--	,@intBatchId OUTPUT

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

	IF @intWorkOrderId IS NULL
		OR @intWorkOrderId = 0
	BEGIN
		SELECT @dblInputLotWeight=(CASE WHEN L.intWeightUOMId IS NOT NULL THEN L.dblWeight ELSE L.dblQty END)
			,@strInputLotNumber = strLotNumber
			,@intInputLotItemId=intItemId
			,@intInputLotStorageLocationId=intStorageLocationId 
			,@intInputLotSubLocationId=intSubLocationId
			,@intInputLotWeightUOMId=intWeightUOMId
			,@dblInputLotWeightPerQty=dblWeightPerQty 
			,@intItemUOMId =intItemUOMId
		FROM dbo.tblICLot L
		WHERE intLotId = @intInputLotId

		IF @dblInputWeight > @dblInputLotWeight --and @ysnEmptyOutSource=0
		BEGIN

			IF @ysnExcessConsumptionAllowed = 0 
			BEGIN
				RAISERROR (
						51116
						,14
						,1
						)
			END
			Select @dblAdjustByQuantity=(@dblInputWeight-@dblInputLotWeight)/(Case When @intInputLotWeightUOMId is null Then 1 Else @dblInputLotWeightPerQty End)

			EXEC [uspICInventoryAdjustment_CreatePostQtyChange]
					-- Parameters for filtering:
					@intItemId = @intInputLotItemId
					,@dtmDate = @dtmCurrentDate
					,@intLocationId = @intLocationId
					,@intSubLocationId = @intInputLotSubLocationId
					,@intStorageLocationId = @intInputLotStorageLocationId
					,@strLotNumber = @strInputLotNumber 	
					-- Parameters for the new values: 
					,@dblAdjustByQuantity =@dblAdjustByQuantity
					,@dblNewUnitCost =NULL
					,@intItemUOMId =@intItemUOMId 
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

		DECLARE @intItemFactoryId int
		SELECT @intItemFactoryId = intItemFactoryId
		FROM tblICItemFactory
		WHERE intItemId = @intItemId AND intFactoryId = @intLocationId

		SELECT @intManufacturingCellId = intManufacturingCellId
		FROM tblICItemFactoryManufacturingCell 
		WHERE intItemFactoryId = @intItemFactoryId AND ysnDefault =1

		IF @intSubLocationId IS NULL
		SELECT @intSubLocationId=intSubLocationId FROM tblMFManufacturingCell WHERE intManufacturingCellId=@intManufacturingCellId

		SELECT @intItemUOMId = @intProduceUnitMeasureId

		IF NOT EXISTS (
				SELECT *
				FROM dbo.tblICItemUOM
				WHERE intItemId = @intItemId
					AND intItemUOMId = @intItemUOMId
					AND ysnStockUnit = 1
				)
		BEGIN
			RAISERROR (
					51094
					,11
					,1
					)
		END

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
			
			SELECT @dblInputWeight = ri.dblCalculatedQuantity * (@dblProduceQty / r.dblQuantity)
			FROM dbo.tblMFRecipeItem ri
			JOIN dbo.tblMFRecipe r ON r.intRecipeId = ri.intRecipeId
			LEFT JOIN dbo.tblMFRecipeSubstituteItem rs ON rs.intRecipeItemId = ri.intRecipeItemId
			WHERE r.intItemId = @intItemId
				AND r.intLocationId = @intLocationId
				AND r.ysnActive = 1
				AND (ri.intItemId = @intInputLotItemId OR rs.intSubstituteItemId=@intInputLotItemId)
		END

		SELECT @strInputItemLotTracking=strLotTracking
		FROM dbo.tblICItem 
		WHERE intItemId=@intInputItemId

		IF @strInputItemLotTracking='Lot Level'
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
						THEN (CASE WHEN L.intWeightUOMId IS NOT NULL THEN L.dblWeight ELSE L.dblQty END)
					ELSE @dblInputWeight
					END
				,ISNULL(intWeightUOMId,intItemUOMId)
				,CASE 
					WHEN @dblInputWeight = 0
						THEN (CASE WHEN L.intWeightUOMId IS NOT NULL THEN L.dblWeight ELSE L.dblQty END)
					ELSE @dblInputWeight
					END
				,ISNULL(intWeightUOMId,intItemUOMId)
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

		SELECT @strLotAlias=@strWorkOrderNo

	END

	Select @intAttributeId=intAttributeId from tblMFAttribute Where strAttributeName='Is Instant Consumption'
	
	Select @strInstantConsumption=strAttributeValue
	From tblMFManufacturingProcessAttribute
	Where intManufacturingProcessId=@intManufacturingProcessId and intLocationId=@intLocationId and intAttributeId=@intAttributeId

	If @strInstantConsumption='False' and @intProductionTypeId=3
	Begin
		Select @intProductionTypeId=2
	End

	If @strInstantConsumption='True' and @intProductionTypeId=2
	Begin
		Select @intProductionTypeId=3
		Select @ysnPostProduction=0
	End

	Select @ysnConsumptionRequired=ysnConsumptionRequired from dbo.tblMFWorkOrderRecipeItem Where intRecipeItemTypeId=2 and intItemId=@intItemId and intWorkOrderId=@intWorkOrderId
	
	IF @intProductionTypeId in (1,3) AND @ysnConsumptionRequired=1
	BEGIN

		If exists(Select *from tblMFWorkOrder Where intWorkOrderId = @intWorkOrderId and intItemUOMId=@intProduceUnitMeasureId)
		Begin
			EXEC dbo.uspMFPickWorkOrder @intWorkOrderId = @intWorkOrderId
				,@dblProduceQty = @dblProduceQty
				,@intProduceUOMId = @intProduceUnitMeasureId
				,@intBatchId = @intBatchId
				,@intUserId = @intUserId
				,@dblUnitQty=@dblUnitQty
				,@ysnProducedQtyByWeight=1

			EXEC dbo.uspMFConsumeWorkOrder @intWorkOrderId = @intWorkOrderId
				,@dblProduceQty = @dblProduceQty
				,@intProduceUOMKey = @intProduceUnitMeasureId
				,@intUserId = @intUserId
				,@ysnNegativeQtyAllowed = @ysnNegativeQtyAllowed
				,@strRetBatchId = @strRetBatchId OUTPUT
				,@intBatchId = @intBatchId
				,@ysnPostConsumption=@ysnPostConsumption
		End
		Else
		Begin
			EXEC dbo.uspMFPickWorkOrder @intWorkOrderId = @intWorkOrderId
				,@dblProduceQty = @dblPhysicalCount
				,@intProduceUOMId = @intPhysicalItemUOMId
				,@intBatchId = @intBatchId
				,@intUserId = @intUserId
				,@dblUnitQty=@dblUnitQty
				,@ysnProducedQtyByWeight=0

			EXEC dbo.uspMFConsumeWorkOrder @intWorkOrderId = @intWorkOrderId
				,@dblProduceQty = @dblPhysicalCount
				,@intProduceUOMKey = @intPhysicalItemUOMId
				,@intUserId = @intUserId
				,@ysnNegativeQtyAllowed = @ysnNegativeQtyAllowed
				,@strRetBatchId = @strRetBatchId OUTPUT
				,@intBatchId = @intBatchId
				,@ysnPostConsumption=@ysnPostConsumption
		End

		EXEC uspMFConsumeSKU @intWorkOrderId = @intWorkOrderId
	END
	IF @intProductionTypeId in (2,3) 
	BEGIN
		Select @strRetBatchId=strBatchId From tblMFWorkOrder Where intWorkOrderId=@intWorkOrderId

		If @strRetBatchId is null
		Begin
			-- Get the next batch number
			EXEC dbo.uspSMGetStartingNumber @STARTING_NUMBER_BATCH, @strRetBatchId OUTPUT  
		End

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
			,@intMachineId =@intMachineId
			,@ysnLotAlias =@ysnLotAlias
			,@strLotAlias =@strLotAlias
			,@intProductionTypeId=@intProductionTypeId

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
			,@intShiftId=@intPlannedShiftId 
			,@strReferenceNo=@strReferenceNo
			,@intStatusId=@intStatusId
			,@intLotId = @intLotId OUTPUT
			,@ysnPostProduction=@ysnPostProduction
			,@strLotAlias=@strLotAlias
			,@intLocationId=@intLocationId
			,@intMachineId =@intMachineId
			,@dtmProductionDate=@dtmPlannedDate
			,@strVendorLotNo =@strVendorLotNo
			,@strComment=@strComment 
			,@strParentLotNumber=@strParentLotNumber
			,@intInputLotId =@intInputLotId
			,@intInputStorageLocationId =@intInputLotStorageLocationId 
	
		IF @intLotStatusId IS NOT NULL AND NOT EXISTS(SELECT *FROM dbo.tblICLot WHERE intLotId=@intLotId AND intLotStatusId = @intLotStatusId)
		BEGIN
			--UPDATE dbo.tblICLot
			--SET intLotStatusId = @intLotStatusId
			--WHERE intLotId = @intLotId

			EXEC uspMFSetLotStatus @intLotId,@intLotStatusId,@intUserId

		END

		SELECT @strOutputLotNumber = strLotNumber,@intParentLotId=intParentLotId
		FROM dbo.tblICLot
		WHERE intLotId = @intLotId

		SELECT @strOutputLotNumber AS strOutputLotNumber
	END
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
GO


