CREATE PROCEDURE [dbo].[uspMFProduceWorkOrder] (
	@intWorkOrderId INT
	,@intItemId INT = NULL
	,@dblProduceQty NUMERIC(38, 20)
	,@intProduceUOMKey INT = NULL
	,@strVesselNo NVARCHAR(50)
	,@intUserId INT
	,@intStorageLocationId INT
	,@strBatchId NVARCHAR(40) = NULL
	,@strLotNumber NVARCHAR(50)
	,@intContainerId INT
	,@dblTareWeight NUMERIC(38, 20) = NULL
	,@dblUnitQty NUMERIC(38, 20) = NULL
	,@dblPhysicalCount NUMERIC(38, 20) = NULL
	,@intPhysicalItemUOMId INT = NULL
	,@intBatchId INT
	,@intShiftId INT = NULL
	,@strReferenceNo NVARCHAR(50) = NULL
	,@intStatusId INT = NULL
	,@intLotId INT OUTPUT
	,@ysnPostProduction BIT = 0
	,@strLotAlias NVARCHAR(50)
	,@intLocationId INT = NULL
	,@intMachineId INT = NULL
	,@dtmProductionDate DATETIME = NULL
	,@strVendorLotNo NVARCHAR(50) = NULL
	,@strComment NVARCHAR(MAX) = NULL
	,@strParentLotNumber NVARCHAR(50) = NULL
	,@intInputLotId INT = NULL
	,@intInputStorageLocationId INT = NULL
	)
AS
BEGIN
	DECLARE @dtmCreated DATETIME
		,@dtmBusinessDate DATETIME
		,@intBusinessShiftId INT
		,@intWorkOrderProducedLotId INT

	SELECT @dtmCreated = Getdate()

	IF @intStatusId = 0
		OR @intStatusId IS NULL
		SELECT @intStatusId = 13 --Complete Work Order

	IF EXISTS (
			SELECT *
			FROM dbo.tblICLot
			WHERE intLotId = @intLotId
				AND intWeightUOMId IS NULL
			)
	BEGIN
		UPDATE dbo.tblICLot
		SET dblWeight = dblQty
			,intWeightUOMId = intItemUOMId
			,dblWeightPerQty = 1
		WHERE intLotId = @intLotId
	END

	SELECT @dtmBusinessDate = dbo.fnGetBusinessDate(@dtmCreated, @intLocationId)

	SELECT @intBusinessShiftId = intShiftId
	FROM dbo.tblMFShift
	WHERE intLocationId = @intLocationId
		AND @dtmCreated BETWEEN @dtmBusinessDate + dtmShiftStartTime + intStartOffset
			AND @dtmBusinessDate + dtmShiftEndTime + intEndOffset

	IF @intShiftId = 0
		SELECT @intShiftId = NULL

	INSERT INTO dbo.tblMFWorkOrderProducedLot (
		intWorkOrderId
		,intItemId
		,intLotId
		,dblQuantity
		,intItemUOMId
		,dblWeightPerUnit
		,dblPhysicalCount
		,intPhysicalItemUOMId
		,dblTareWeight
		,strVesselNo
		,intContainerId
		,intStorageLocationId
		,dtmBusinessDate
		,intBusinessShiftId
		,dtmProductionDate
		,intShiftId
		,strReferenceNo
		,intBatchId
		,intMachineId
		,dtmCreated
		,intCreatedUserId
		,dtmLastModified
		,intLastModifiedUserId
		,strComment
		,strParentLotNumber
		,intInputLotId
		,intInputStorageLocationId
		)
	SELECT @intWorkOrderId
		,@intItemId
		,@intLotId
		,@dblProduceQty
		,@intProduceUOMKey
		,(
			CASE 
				WHEN @dblUnitQty IS NOT NULL
					THEN @dblUnitQty
				ELSE @dblProduceQty / @dblPhysicalCount
				END
			)
		,@dblPhysicalCount
		,@intPhysicalItemUOMId
		,@dblTareWeight
		,@strVesselNo
		,(
			CASE 
				WHEN @intContainerId = 0
					THEN NULL
				ELSE @intContainerId
				END
			)
		,@intStorageLocationId
		,@dtmBusinessDate
		,@intBusinessShiftId
		,@dtmProductionDate
		,@intShiftId
		,@strReferenceNo
		,@intBatchId
		,@intMachineId
		,@dtmCreated
		,@intUserId
		,@dtmCreated
		,@intUserId
		,@strComment
		,@strParentLotNumber
		,@intInputLotId
		,@intInputStorageLocationId

	SELECT @intWorkOrderProducedLotId = SCOPE_IDENTITY()

	UPDATE tblMFWorkOrder
	SET dblProducedQuantity = isnull(dblProducedQuantity, 0) + (
			CASE 
				WHEN intItemId = @intItemId
					THEN (
							CASE 
								WHEN intItemUOMId = @intProduceUOMKey
									THEN @dblProduceQty
								ELSE @dblPhysicalCount
								END
							)
				ELSE 0
				END
			)
		,dtmActualProductionEndDate = @dtmCreated
		,dtmCompletedDate = @dtmCreated
		,intStatusId = @intStatusId
		,intStorageLocationId = @intStorageLocationId
	WHERE intWorkOrderId = @intWorkOrderId

	UPDATE dbo.tblMFWorkOrder
	SET dtmLastProducedDate = @dtmCreated
	WHERE intItemId = @intItemId

	IF NOT EXISTS (
			SELECT *
			FROM tblMFProductionSummary
			WHERE intWorkOrderId = @intWorkOrderId
				AND intItemId = @intItemId
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
			,@intItemId
			,0
			,0
			,0
			,0
			,0
			,@dblProduceQty
			,0
			,0
			,0
			,0
			,0
	END
	ELSE
	BEGIN
		UPDATE tblMFProductionSummary
		SET dblOutputQuantity = dblOutputQuantity + @dblProduceQty
		WHERE intWorkOrderId = @intWorkOrderId
			AND intItemId = @intItemId
	END
	Declare @intAttributeTypeId int, @intManufacturingProcessId int

	Select @intManufacturingProcessId=intManufacturingProcessId from tblMFWorkOrder Where intWorkOrderId =@intWorkOrderId 

	Select @intAttributeTypeId=intAttributeTypeId
	from dbo.tblMFManufacturingProcess 
	Where intManufacturingProcessId=@intManufacturingProcessId

	IF @intAttributeTypeId=2
		OR @ysnPostProduction = 1
	BEGIN
		EXEC uspMFPostProduction 1
			,0
			,@intWorkOrderId
			,@intItemId
			,@intUserId
			,NULL
			,@intStorageLocationId
			,@dblProduceQty
			,@intProduceUOMKey
			,@dblUnitQty
			,@dblPhysicalCount
			,@intPhysicalItemUOMId
			,@strBatchId
			,@strLotNumber
			,@intBatchId
			,@intLotId OUT
			,@strLotAlias
			,@strVendorLotNo
			,@strParentLotNumber
			,@strVesselNo
			,@dtmProductionDate
			,@intWorkOrderProducedLotId
	END
	ELSE
	BEGIN
		EXEC uspMFPostConsumptionProduction @intWorkOrderId = @intWorkOrderId
			,@intItemId = @intItemId
			,@strLotNumber = @strLotNumber
			,@dblWeight = @dblProduceQty
			,@intWeightUOMId = @intProduceUOMKey
			,@dblUnitQty = @dblUnitQty
			,@dblQty = @dblPhysicalCount
			,@intItemUOMId = @intPhysicalItemUOMId
			,@intUserId = @intUserId
			,@intBatchId = @intBatchId
			,@intLotId = @intLotId OUT
			,@strLotAlias = @strLotAlias
			,@strVendorLotNo = @strVendorLotNo
			,@strParentLotNumber = @strParentLotNumber
			,@intStorageLocationId = @intStorageLocationId
			,@dtmProductionDate = @dtmProductionDate
			,@intTransactionDetailId = @intWorkOrderProducedLotId
	END

	UPDATE tblMFWorkOrderProducedLot
	SET intLotId = @intLotId
	WHERE intWorkOrderProducedLotId = @intWorkOrderProducedLotId
END
