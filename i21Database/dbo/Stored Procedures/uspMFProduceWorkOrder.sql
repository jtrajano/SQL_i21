CREATE PROCEDURE [dbo].[uspMFProduceWorkOrder] (
	@intWorkOrderId INT
	,@dblProduceQty NUMERIC(18, 6)
	,@intProduceUOMKey INT = NULL
	,@strVesselNo NVARCHAR(50)
	,@intUserId INT
	,@intStorageLocationId int
	,@strBatchId nvarchar(40)=null
	)
AS
BEGIN
	DECLARE @intLotTransactionId INT
		,@intLotId INT
		,@dtmCreated DATETIME
		,@strWorkOrderNo NVARCHAR(50)
		,@intItemId INT
		,@intSubLocationId INT
		,@intLocationId INT
		,@intItemLocationId INT
		,@intLotStatusId int
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
	WHERE intItemId = @intItemId And intLocationId=@intLocationId

	Select @intLotStatusId=intLotStatusId from tblICLotStatus Where strPrimaryStatus ='Active'
	
	--EXEC uspICCreateLot @strLotNumber = @strWorkOrderNo
	--	,@strLotAlias = @strWorkOrderNo
	--	,@dtmCreated = @dtmCreated
	--	,@intCreatedUserId = @intUserId
	--	,@intItemId = @intItemId
	--	,@intItemLocationId = @intItemLocationId
	--	,@intStorageLocationId = @intStorageLocationId
	--	,@intSubLocationId = @intSubLocationId
	--	,@intLocationId = @intLocationId
	--	,@dblQuantity = @dblProduceQty
	--	,@intItemUOMId = @intProduceUOMKey
	--	,@dtmExpiryDate = NULL
	--	,@intLotStatusId = @intLotStatusId
	--	,@strParentLotId = NULL
	--	,@strParentLotAlias = NULL
	--	,@dblWeightPerUnit = 1
	--	,@dblUnitCount = @dblProduceQty
	--	,@intItemUnitCountUOMId = @intProduceUOMKey
	--	,@dtmManufacturedDate=@dtmCreated
	--	,@ysnProduced = 1
	--	,@ysnReceiptCompleted=1
	--	,@intLotTransactionTypeId = 9
	--	,@intBatchId = @intWorkOrderId
	--	,@intLotTransactionId = @intLotTransactionId OUTPUT
	--	,@intLotId = @intLotId OUTPUT

	-- Lot Number batch number in the starting numbers table. 
	DECLARE @STARTING_NUMBER_BATCH_LOT AS INT = 24 
	DECLARE @strLotNumber NVARCHAR(50)

	--Get Lot Number
	EXEC dbo.uspSMGetStartingNumber @STARTING_NUMBER_BATCH_LOT, @strLotNumber OUTPUT 

	IF ISNULL(@strLotNumber,'')='' RAISERROR('Unable to generate Lot Number.',16,1)

	Exec uspMFPostProduction 1,0,@intWorkOrderId,@intUserId,null,@intStorageLocationId,@dblProduceQty,@intProduceUOMKey,@strBatchId,@strLotNumber

	Select @intLotId=intLotId from tblICLot where strLotNumber=@strLotNumber and intStorageLocationId=@intStorageLocationId

	INSERT INTO dbo.tblMFWorkOrderProducedLot (
		intWorkOrderId
		,intLotId
		,dblQuantity
		,intItemUOMId
		,dblWeightPerUnit
		,dblPhysicalCount
		,intPhysicalItemUOMId
		,strVesselNo
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
		,1
		,@dblProduceQty
		,@intProduceUOMKey
		,@strVesselNo
		,@intWorkOrderId
		,@dtmCreated
		,@intUserId
		,@dtmCreated
		,@intUserId

		Update tblMFWorkOrder Set intBatchID =@intWorkOrderId,dblProducedQuantity =isnull(dblProducedQuantity,0) +@dblProduceQty
			,dtmActualProductionEndDate=Getdate(),intStatusId=13,intStorageLocationId=@intStorageLocationId Where intWorkOrderId=@intWorkOrderId
END
