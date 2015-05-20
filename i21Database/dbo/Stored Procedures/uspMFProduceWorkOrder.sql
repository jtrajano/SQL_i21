CREATE PROCEDURE [dbo].[uspMFProduceWorkOrder] (
	@intWorkOrderId INT
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
	,@intLotId int OUTPUT
	)
AS
BEGIN
	DECLARE @dtmCreated DATETIME

	SELECT @dtmCreated = Getdate()

	--If exists(Select *from tblMFWorkOrder Where intWorkOrderId=@intWorkOrderId and intBlendRequirementId is not null)
	--Begin
	--	EXEC uspMFPostProduction 1
	--		,0
	--		,@intWorkOrderId
	--		,@intUserId
	--		,NULL
	--		,@intStorageLocationId
	--		,@dblProduceQty
	--		,@intProduceUOMKey
	--		,@dblUnitQty
	--		,@dblPhysicalCount
	--		,@intPhysicalItemUOMId
	--		,@strBatchId
	--		,@strLotNumber
	--		,@intLotId OUT
	--End
	--Else
	--Begin
		Exec uspMFPostConsumptionProduction 
			@intWorkOrderId =@intWorkOrderId
			,@strLotNumber=@strLotNumber
			,@dblWeight=@dblProduceQty
			,@intWeightUOMId =@intProduceUOMKey
			,@dblUnitQty =@dblUnitQty
			,@dblQty =@dblPhysicalCount
			,@intItemUOMId =@intPhysicalItemUOMId
			,@intUserId =@intUserId
			,@intLotId =@intLotId OUT
	--End

	INSERT INTO dbo.tblMFWorkOrderProducedLot (
		intWorkOrderId
		,intLotId
		,dblQuantity
		,intItemUOMId
		,dblWeightPerUnit
		,dblPhysicalCount
		,intPhysicalItemUOMId
		,dblTareWeight
		,strVesselNo
		,intContainerId
		,intBatchId
		,dtmCreated
		,intCreatedUserId
		,dtmLastModified
		,intLastModifiedUserId
		)
	SELECT @intWorkOrderId
		,@intLotId
		,@dblProduceQty
		,@intProduceUOMKey
		,(Case When @dblUnitQty is not null Then @dblUnitQty else @dblProduceQty/@dblPhysicalCount End)
		,@dblPhysicalCount
		,@intPhysicalItemUOMId
		,@dblTareWeight
		,@strVesselNo
		,@intContainerId
		,@intBatchId
		,@dtmCreated
		,@intUserId
		,@dtmCreated
		,@intUserId

	UPDATE tblMFWorkOrder
	SET intBatchID = @intWorkOrderId
		,dblProducedQuantity = isnull(dblProducedQuantity, 0) + @dblProduceQty
		,dtmActualProductionEndDate = Getdate()
		,dtmCompletedDate = Getdate()
		,intStatusId = 13
		,intStorageLocationId = @intStorageLocationId
	WHERE intWorkOrderId = @intWorkOrderId
END
