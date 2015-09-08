CREATE PROCEDURE [dbo].[uspMFProduceWorkOrder] (
	@intWorkOrderId INT
	,@intItemId int =NULL
	,@dblProduceQty NUMERIC(18, 6)
	,@intProduceUOMKey INT = NULL
	,@strVesselNo NVARCHAR(50)
	,@intUserId INT
	,@intStorageLocationId INT
	,@strBatchId NVARCHAR(40) = NULL
	,@strLotNumber NVARCHAR(50)
	,@intContainerId INT
	,@dblTareWeight NUMERIC(18, 6) = NULL
	,@dblUnitQty  NUMERIC(18, 6) = NULL
	,@dblPhysicalCount NUMERIC(18, 6) = NULL
	,@intPhysicalItemUOMId INT = NULL
	,@intBatchId INT
	,@intShiftId int=NULL
	,@strReferenceNo nvarchar(50)=NULL
	,@intStatusId int=NULL
	,@intLotId int OUTPUT
	,@ysnPostProduction bit=0
	,@strLotAlias nvarchar(50)
	,@intLocationId int=NULL
	,@intMachineId int =NULL
	,@dtmProductionDate datetime=NULL
	,@strVendorLotNo nvarchar(50)=NULL
	)
AS
BEGIN
	DECLARE @dtmCreated DATETIME
			,@dtmBusinessDate datetime
			,@intBusinessShiftId int

	SELECT @dtmCreated = Getdate()

	If @intStatusId=0 or @intStatusId is null
	Select @intStatusId=13--Complete Work Order

	If exists(Select *from tblMFWorkOrder Where intWorkOrderId=@intWorkOrderId and intBlendRequirementId is not null) or @ysnPostProduction=1
	Begin
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
	End
	Else
	Begin
		Exec uspMFPostConsumptionProduction 
			@intWorkOrderId =@intWorkOrderId
			,@intItemId=@intItemId
			,@strLotNumber=@strLotNumber
			,@dblWeight=@dblProduceQty
			,@intWeightUOMId =@intProduceUOMKey
			,@dblUnitQty =@dblUnitQty
			,@dblQty =@dblPhysicalCount
			,@intItemUOMId =@intPhysicalItemUOMId
			,@intUserId =@intUserId
			,@intBatchId=@intBatchId
			,@intLotId =@intLotId OUT
			,@strLotAlias=@strLotAlias
			,@strVendorLotNo=@strVendorLotNo
	End

	SELECT @dtmBusinessDate = dbo.fnGetBusinessDate(@dtmCreated,@intLocationId) 

	SELECT @intBusinessShiftId = intShiftId
	FROM dbo.tblMFShift
	WHERE intLocationId = @intLocationId
		AND @dtmCreated BETWEEN @dtmBusinessDate+dtmShiftStartTime+intStartOffset
					AND @dtmBusinessDate+dtmShiftEndTime + intEndOffset

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
		)
	SELECT @intWorkOrderId
		,@intItemId
		,@intLotId
		,@dblProduceQty
		,@intProduceUOMKey
		,(Case When @dblUnitQty is not null Then @dblUnitQty else @dblProduceQty/@dblPhysicalCount End)
		,@dblPhysicalCount
		,@intPhysicalItemUOMId
		,@dblTareWeight
		,@strVesselNo
		,(Case When @intContainerId=0 Then NULL Else @intContainerId End)
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

	UPDATE tblMFWorkOrder
	SET intBatchID = @intWorkOrderId
		,dblProducedQuantity = isnull(dblProducedQuantity, 0) + (Case When intItemId=@intItemId Then (Case When intItemUOMId=@intProduceUOMKey Then @dblProduceQty Else @dblPhysicalCount End) Else 0 End)
		,dtmActualProductionEndDate = @dtmCreated
		,dtmCompletedDate = @dtmCreated
		,intStatusId = @intStatusId
		,intStorageLocationId = @intStorageLocationId
	WHERE intWorkOrderId = @intWorkOrderId

	IF NOT EXISTS(SELECT *FROM tblMFProductionSummary WHERE intWorkOrderId=@intWorkOrderId AND intItemId=@intItemId)
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
		UPDATE tblMFProductionSummary SET dblOutputQuantity=dblOutputQuantity+@dblProduceQty WHERE intWorkOrderId=@intWorkOrderId AND intItemId=@intItemId
	END
END
