
CREATE PROCEDURE [dbo].[uspMFCompleteBlendsheet] (@XML NVARCHAR(MAX))
AS
BEGIN TRY
	DECLARE @idoc INT
		,@ErrMsg NVARCHAR(MAX)
		,@intWorkOrderId INT
		,@intItemId int
		,@dblProduceQty NUMERIC(18, 6)
		,@intProduceUOMKey INT
		,@strVesselNo NVARCHAR(50)
		,@intUserId INT,
		@intStorageLocationId int

	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@XML

	SELECT @intWorkOrderId = intWorkOrderId
		,@dblProduceQty = dblProduceQty
		,@intProduceUOMKey = intProduceUOMKey
		,@strVesselNo = strVesselNo
		,@intUserId = intUserId,
		@intStorageLocationId=intStorageLocationId

	FROM OPENXML(@idoc, 'root', 2) WITH (
			intWorkOrderId INT
			,dblProduceQty NUMERIC(18, 6)
			,intProduceUOMKey INT
			,strVesselNo NVARCHAR(50)
			,intUserId INT,
			intStorageLocationId int
			)

	Declare @strRetBatchId nVarchar(40)

	Select @intItemId=intItemId
	From dbo.tblMFWorkOrder 
	Where intWorkOrderId=@intWorkOrderId

	Begin Transaction

	EXEC dbo.uspMFConsumeWorkOrder @intWorkOrderId = @intWorkOrderId
		,@dblProduceQty = @dblProduceQty
		,@intProduceUOMKey = @intProduceUOMKey
		,@intUserId = @intUserId
		,@strRetBatchId=@strRetBatchId  OUT

	-- Lot Number batch number in the starting numbers table. 
	DECLARE @STARTING_NUMBER_BATCH_LOT AS INT = 24 
	DECLARE @strLotNumber NVARCHAR(50)

	--Get Lot Number
	EXEC dbo.uspSMGetStartingNumber @STARTING_NUMBER_BATCH_LOT, @strLotNumber OUTPUT 

	IF ISNULL(@strLotNumber,'')='' RAISERROR('Unable to generate Lot Number.',16,1)
		
	EXEC dbo.uspMFProduceWorkOrder @intWorkOrderId = @intWorkOrderId
		,@intItemId=@intItemId
		,@dblProduceQty = @dblProduceQty
		,@intProduceUOMKey = @intProduceUOMKey
		,@strVesselNo = @strVesselNo
		,@intUserId = @intUserId
		,@intStorageLocationId=@intStorageLocationId
		,@strBatchId=@strRetBatchId
		,@strLotNumber=@strLotNumber
		,@intContainerId=NULL
		,@dblTareWeight=NULL
		,@dblPhysicalCount=@dblProduceQty
		,@intPhysicalItemUOMId=@intProduceUOMKey
		,@intBatchId=NULL
		,@intLotId=NULL

	Commit Transaction
	EXEC sp_xml_removedocument @idoc
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()
	IF XACT_STATE() != 0 ROLLBACK TRANSACTION
	IF @idoc <> 0
		EXEC sp_xml_removedocument @idoc

	RAISERROR (
			@ErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH
