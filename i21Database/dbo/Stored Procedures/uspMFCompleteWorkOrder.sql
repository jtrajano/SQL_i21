CREATE PROCEDURE [dbo].[uspMFCompleteWorkOrder] (@strXML NVARCHAR(MAX),@strOutputLotNumber nvarchar(50) Output)
AS
BEGIN TRY
	DECLARE @idoc INT
		,@ErrMsg NVARCHAR(MAX)
		,@intWorkOrderId INT
		,@dblProduceQty NUMERIC(18, 6)
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
		,@dblTareWeight NUMERIC(18, 6)
		,@dblUnitQty NUMERIC(18, 6)
		,@dblPhysicalCount NUMERIC(18, 6)
		,@intPhysicalItemUOMId INT
		,@ysnEmptyOutSource BIT
		,@intExecutionOrder INT
		,@dblInputWeight NUMERIC(18, 6)
		,@intBatchId INT
		,@dtmCurrentDate DATETIME
		,@intSubLocationId INT
		,@ysnNegativeQtyAllowed BIT
		,@ysnSubLotAllowed BIT
		,@strRetBatchId NVARCHAR(40)
		,@intLotId INT
		,@strLotTracking NVARCHAR(50)
		,@ysnProductionOnly BIT
		,@ysnAllowMultipleItem BIT
		,@ysnAllowMultipleLot BIT
		,@ysnMergeOnMove BIT
		,@intMachineId int
		,@ysnLotAlias bit
		,@strLotAlias nvarchar(50)
		,@strReferenceNo nvarchar(50)

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
		,@dblPhysicalCount = dblPhysicalCount
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
		,@dblInputWeight = dblInputWeight
		,@intLocationId = intLocationId
		,@intSubLocationId = intSubLocationId
		,@intStorageLocationId = intStorageLocationId
		,@intContainerId = intContainerId
		,@ysnEmptyOutSource = ysnEmptyOutSource
		,@ysnNegativeQtyAllowed = ysnNegativeQtyAllowed
		,@ysnSubLotAllowed = ysnSubLotAllowed
		,@ysnProductionOnly = Isnull(ysnProductionOnly,0)
		,@intMachineId =intMachineId
		,@ysnLotAlias =ysnLotAlias
		,@strLotAlias =strLotAlias
		,@strReferenceNo=strReferenceNo
	FROM OPENXML(@idoc, 'root', 2) WITH (
			intWorkOrderId INT
			,intManufacturingProcessId INT
			,dtmPlannedDate DATETIME
			,intPlannedShiftId INT
			,intStatusId int
			,intItemId INT
			,dblProduceQty NUMERIC(18, 6)
			,intProduceUnitMeasureId INT
			,dblTareWeight NUMERIC(18, 6)
			,dblUnitQty NUMERIC(18, 6)
			,dblPhysicalCount NUMERIC(18, 6)
			,intPhysicalItemUOMId INT
			,strVesselNo NVARCHAR(50)
			,intUserId INT
			,strOutputLotNumber NVARCHAR(50)
			,strVendorLotNo NVARCHAR(50)
			,intInputLotId INT
			,dblInputWeight NUMERIC(18, 6)
			,intLocationId INT
			,intSubLocationId INT
			,intStorageLocationId INT
			,intContainerId INT
			,ysnEmptyOutSource BIT
			,ysnNegativeQtyAllowed BIT
			,ysnSubLotAllowed BIT
			,ysnProductionOnly BIT
			,intMachineId int
			,ysnLotAlias bit
			,strLotAlias nvarchar(50)
			,strReferenceNo nvarchar(50)
			)

	BEGIN TRANSACTION

	--IF @intPhysicalItemUOMId IS NULL
	--BEGIN
	--	SELECT @intPhysicalItemUOMId = intItemUOMId
	--	FROM dbo.tblICItemUOM
	--	WHERE intItemId = @intItemId
	--		AND intUnitMeasureId IN (
	--			SELECT intUnitMeasureId
	--			FROM dbo.tblICUnitMeasure
	--			WHERE strUnitMeasure LIKE '%bag%'
	--			)
	--END

	--UPDATE tblMFWorkOrder
	--SET intStatusId = 10
	--WHERE intWorkOrderId = @intWorkOrderId

	SELECT @dtmCurrentDate = GetDate()

	--IF @intSubLocationId IS NULL
	--	OR @intSubLocationId = 0
	--	SELECT @intSubLocationId = intSubLocationId
	--	FROM dbo.tblICStorageLocation
	--	WHERE intStorageLocationId = @intStorageLocationId

	SELECT @strLotTracking = strLotTracking
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
			AND dblWeight > 0
			AND intLotStatusId = 1
			AND dtmExpiryDate > Getdate()

	END
	ELSE IF EXISTS (
			SELECT *
			FROM tblICLot
			WHERE intStorageLocationId = @intStorageLocationId
				AND dblWeight > 0
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
			EXEC dbo.uspSMGetStartingNumber 24
				,@strOutputLotNumber OUTPUT
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

	EXEC dbo.uspSMGetStartingNumber 33
		,@intBatchId OUTPUT

	IF @intWorkOrderId IS NULL
		OR @intWorkOrderId = 0
	BEGIN
		EXEC dbo.uspSMGetStartingNumber 34
			,@strWorkOrderNo OUTPUT

		SELECT @intManufacturingCellId = intManufacturingCellId
		FROM dbo.tblMFRecipe
		WHERE intItemId = @intItemId
			AND intLocationId = @intLocationId
			AND ysnActive = 1

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
			)
		SELECT @strWorkOrderNo
			,@intManufacturingProcessId
			,@intItemId
			,@dblProduceQty
			,@intItemUOMId
			,10
			,@intManufacturingCellId
			,@intStorageLocationId
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

		SET @intWorkOrderId = SCOPE_IDENTITY()

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
			,@intItemId
			,intLotId
			,CASE 
				WHEN @dblInputWeight = 0
					THEN dblWeight
				ELSE @dblInputWeight
				END
			,intWeightUOMId
			,CASE 
				WHEN @dblInputWeight = 0
					THEN dblWeight
				ELSE @dblInputWeight
				END
			,intWeightUOMId
			,@intBatchId
			,1
			,@dtmCurrentDate
			,@intUserId
			,@dtmCurrentDate
			,@intUserId
		FROM dbo.tblICLot
		WHERE intLotId = @intInputLotId
	END

	IF @ysnProductionOnly = 0--Consumption will happen during true up.
	BEGIN
		EXEC dbo.uspMFPickWorkOrder @intWorkOrderId = @intWorkOrderId
			,@dblProduceQty = @dblProduceQty
			,@intProduceUOMKey = @intProduceUnitMeasureId
			,@intBatchId = @intBatchId
			,@intUserId = @intUserId

		EXEC dbo.uspMFConsumeWorkOrder @intWorkOrderId = @intWorkOrderId
			,@dblProduceQty = @dblProduceQty
			,@intProduceUOMKey = @intProduceUnitMeasureId
			,@intUserId = @intUserId
			,@ysnNegativeQtyAllowed = @ysnNegativeQtyAllowed
			,@strRetBatchId = @strRetBatchId OUTPUT
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
		,@ysnIgnoreTolerance = 1
		,@intMachineId =@intMachineId
		,@ysnLotAlias =@ysnLotAlias
		,@strLotAlias =@strLotAlias
		,@ysnProductionOnly=@ysnProductionOnly

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

	UPDATE dbo.tblICLot
	SET intLotStatusId = 3
	WHERE intLotId = @intLotId

	SELECT @strOutputLotNumber = strLotNumber
	FROM dbo.tblICLot
	WHERE intLotId = @intLotId

	SELECT @strOutputLotNumber AS strOutputLotNumber

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
GO


