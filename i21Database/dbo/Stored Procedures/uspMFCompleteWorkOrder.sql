CREATE PROCEDURE [dbo].[uspMFCompleteWorkOrder] (@strXML NVARCHAR(MAX))
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
		,@strOutputLotNumber NVARCHAR(50)
		,@strVendorLotNo NVARCHAR(50)
		,@strWorkOrderNo NVARCHAR(50)
		,@intStatusId INT
		,@intItemUOMId INT
		,@intInputLotId INT
		,@intManufacturingCellId INT
		,@intLocationId INT
		,@dtmPlannedDate DATETIME
		,@intPlannedShiftId INT
		,@intManufacturingProcessId INT
		,@intStorageLocationId INT
		,@intContainerId INT
		,@dblTareWeight NUMERIC(18, 6)
		,@dblPhysicalCount NUMERIC(18, 6)
		,@intPhysicalItemUOMId INT
		,@ysnEmptyOutSource BIT
		,@intExecutionOrder INT
		,@dblInputWeight NUMERIC(18, 6)
		,@intBatchId INT
		,@dtmCurrentDate datetime
		,@intSubLocationId int
		,@ysnNegativeQtyAllowed BIT
		,@ysnSubLotAllowed Bit
		,@strRetBatchId nvarchar(40)

	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@strXML

	SELECT @intWorkOrderId = intWorkOrderId
		,@intManufacturingProcessId = intManufacturingProcessId
		,@dtmPlannedDate = dtmPlannedDate
		,@intPlannedShiftId = intPlannedShiftId
		,@intItemId = intItemId
		,@dblProduceQty = dblProduceQty
		,@intProduceUnitMeasureId = intProduceUnitMeasureId
		,@dblTareWeight = dblTareWeight
		,@dblPhysicalCount = dblPhysicalCount
		,@intPhysicalItemUOMId = (case When intPhysicalItemUOMId=0 Then NULL else intPhysicalItemUOMId End)
		,@strVesselNo = strVesselNo
		,@intUserId = intUserId
		,@strOutputLotNumber = strOutputLotNumber
		,@strVendorLotNo = strVendorLotNo
		,@intInputLotId = intInputLotId
		,@dblInputWeight = dblInputWeight
		,@intLocationId = intLocationId
		,@intSubLocationId=intSubLocationId
		,@intStorageLocationId = intStorageLocationId
		,@intContainerId = intContainerId
		,@ysnEmptyOutSource = ysnEmptyOutSource
		,@ysnNegativeQtyAllowed=ysnNegativeQtyAllowed
		,@ysnSubLotAllowed=ysnSubLotAllowed
	FROM OPENXML(@idoc, 'root', 2) WITH (
			intWorkOrderId INT
			,intManufacturingProcessId INT
			,dtmPlannedDate DATETIME
			,intPlannedShiftId INT
			,intItemId INT
			,dblProduceQty NUMERIC(18, 6)
			,intProduceUnitMeasureId INT
			,dblTareWeight NUMERIC(18, 6)
			,dblPhysicalCount NUMERIC(18, 6)
			,intPhysicalItemUOMId INT
			,strVesselNo NVARCHAR(50)
			,intUserId INT
			,strOutputLotNumber NVARCHAR(50)
			,strVendorLotNo NVARCHAR(50)
			,intInputLotId INT
			,dblInputWeight NUMERIC(18, 6)
			,intLocationId INT
			,intSubLocationId Int
			,intStorageLocationId INT
			,intContainerId INT
			,ysnEmptyOutSource BIT
			,ysnNegativeQtyAllowed BIT
			,ysnSubLotAllowed BIT
			)

	BEGIN TRANSACTION
	--If @intWorkOrderId is not null or @intWorkOrderId>0
	--Begin
		SELECT @intStatusId = intStatusId
			FROM dbo.tblMFWorkOrderStatus
			WHERE strName = 'Started'
		Update tblMFWorkOrder Set intStatusId =@intStatusId  Where intWorkOrderId=@intWorkOrderId
	--End

	Select @dtmCurrentDate=GetDate()

	If @intSubLocationId is null
	Select @intSubLocationId=intSubLocationId From dbo.tblICStorageLocation Where intStorageLocationId =@intStorageLocationId

	IF @strOutputLotNumber = ''
		OR @strOutputLotNumber IS NULL
	BEGIN
		EXEC dbo.uspSMGetStartingNumber 24
			,@strOutputLotNumber OUTPUT
	END

	EXEC dbo.uspSMGetStartingNumber 33
		,@intBatchId OUTPUT

	IF @intWorkOrderId IS NULL
		OR @intWorkOrderId = 0
	BEGIN
		EXEC dbo.uspSMGetStartingNumber 34
			,@strWorkOrderNo OUTPUT

		SELECT @intStatusId = intStatusId
		FROM dbo.tblMFWorkOrderStatus
		WHERE strName = 'Started'

		SELECT @intManufacturingCellId = intManufacturingCellId
		FROM dbo.tblMFRecipe
		WHERE intItemId = @intItemId
			AND intLocationId = @intLocationId
			AND ysnActive = 1

		SELECT @intItemUOMId = @intProduceUnitMeasureId
		--FROM dbo.tblICItemUOM
		--WHERE intItemId = @intItemId
		--	AND intUnitMeasureId = @intProduceUnitMeasureId

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
			,@intStatusId
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

	EXEC dbo.uspMFPickWorkOrder @intWorkOrderId = @intWorkOrderId
		,@dblProduceQty = @dblProduceQty
		,@intProduceUOMKey = @intProduceUnitMeasureId
		,@intBatchId = @intBatchId
		,@intUserId = @intUserId

	EXEC dbo.uspMFConsumeWorkOrder @intWorkOrderId = @intWorkOrderId
		,@dblProduceQty = @dblProduceQty
		,@intProduceUOMKey = @intProduceUnitMeasureId
		,@intUserId = @intUserId
		,@ysnNegativeQtyAllowed=@ysnNegativeQtyAllowed
		,@strRetBatchId=@strRetBatchId Output

	EXEC dbo.uspMFValidateCreateLot @strLotNumber = @strOutputLotNumber
		,@dtmCreated = @dtmPlannedDate
		,@intShiftId =@intPlannedShiftId
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
		
	EXEC dbo.uspMFProduceWorkOrder @intWorkOrderId = @intWorkOrderId
		,@dblProduceQty = @dblProduceQty
		,@intProduceUOMKey = @intProduceUnitMeasureId
		,@strVesselNo = @strVesselNo
		,@intUserId = @intUserId
		,@intStorageLocationId = @intStorageLocationId
		,@strLotNumber = @strOutputLotNumber
		,@intContainerId = @intContainerId
		,@dblTareWeight = @dblTareWeight
		,@dblPhysicalCount = @dblPhysicalCount
		,@intPhysicalItemUOMId = @intPhysicalItemUOMId
		,@intBatchId = @intBatchId
		,@strBatchId=@strRetBatchId

	Update dbo.tblICLot Set intLotStatusId =(Select intLotStatusId from tblICLotStatus Where strSecondaryStatus='Quarantined')Where strLotNumber =@strOutputLotNumber
		
	Select @strOutputLotNumber as strOutputLotNumber

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


