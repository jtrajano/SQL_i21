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
	,@dblPhysicalCount NUMERIC(18, 6) = NULL
	,@intPhysicalItemUOMId INT = NULL
	,@intBatchId INT
	,@intLotId int OUTPUT
	)
AS
BEGIN
	DECLARE @intLotTransactionId INT
		,@dtmCreated DATETIME
		,@strWorkOrderNo NVARCHAR(50)
		,@intItemId INT
		,@intSubLocationId INT
		,@intLocationId INT
		,@intItemLocationId INT
		,@intLotStatusId INT

	SELECT @dtmCreated = Getdate()

	SELECT @strWorkOrderNo = strWorkOrderNo
		,@intItemId = intItemId
		,@intLocationId = intLocationId
	FROM dbo.tblMFWorkOrder
	WHERE intWorkOrderId = @intWorkOrderId

	SELECT @intSubLocationId = intSubLocationId
	FROM dbo.tblICStorageLocation
	WHERE intStorageLocationId = @intStorageLocationId

	SELECT @intItemLocationId = intItemLocationId
	FROM dbo.tblICItemLocation
	WHERE intItemId = @intItemId
		AND intLocationId = @intLocationId

	SELECT @intLotStatusId = intLotStatusId
	FROM tblICLotStatus
	WHERE strPrimaryStatus = 'Active'

	--EXEC uspICCreateLot @strLotNumber = @strWorkOrderNo    
	-- ,@strLotAlias = @strWorkOrderNo    
	-- ,@dtmCreated = @dtmCreated    
	-- ,@intCreatedUserId = @intUserId    
	-- ,@intItemId = @intItemId    
	-- ,@intItemLocationId = @intItemLocationId    
	-- ,@intStorageLocationId = @intStorageLocationId    
	-- ,@intSubLocationId = @intSubLocationId    
	-- ,@intLocationId = @intLocationId    
	-- ,@dblQuantity = @dblProduceQty    
	-- ,@intItemUOMId = @intProduceUOMKey    
	-- ,@dtmExpiryDate = NULL    
	-- ,@intLotStatusId = @intLotStatusId    
	-- ,@strParentLotId = NULL    
	-- ,@strParentLotAlias = NULL    
	-- ,@dblWeightPerUnit = 1    
	-- ,@dblUnitCount = @dblProduceQty    
	-- ,@intItemUnitCountUOMId = @intProduceUOMKey    
	-- ,@dtmManufacturedDate=@dtmCreated    
	-- ,@ysnProduced = 1    
	-- ,@ysnReceiptCompleted=1    
	-- ,@intLotTransactionTypeId = 9    
	-- ,@intBatchId = @intWorkOrderId    
	-- ,@intLotTransactionId = @intLotTransactionId OUTPUT    
	-- ,@intLotId = @intLotId OUTPUT    
	EXEC uspMFPostProduction 1
		,0
		,@intWorkOrderId
		,@intUserId
		,NULL
		,@intStorageLocationId
		,@dblProduceQty
		,@intProduceUOMKey
		,@dblPhysicalCount
		,@intPhysicalItemUOMId
		,@strBatchId
		,@strLotNumber
		,@intLotId OUT

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
		,@dblProduceQty/@dblPhysicalCount
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
