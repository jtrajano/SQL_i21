
CREATE PROCEDURE [dbo].[uspMFCompleteBlendsheet] (@XML NVARCHAR(MAX))
AS
BEGIN TRY
	DECLARE @idoc INT
		,@ErrMsg NVARCHAR(MAX)
		,@intWorkOrderId INT
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

	Begin Transaction

	EXEC dbo.uspMFConsumeWorkOrder @intWorkOrderId = @intWorkOrderId
		,@dblProduceQty = @dblProduceQty
		,@intProduceUOMKey = @intProduceUOMKey
		,@intUserId = @intUserId
		,@strRetBatchId=@strRetBatchId  OUT
		
	EXEC dbo.uspMFProduceWorkOrder @intWorkOrderId = @intWorkOrderId
		,@dblProduceQty = @dblProduceQty
		,@intProduceUOMKey = @intProduceUOMKey
		,@strVesselNo = @strVesselNo
		,@intUserId = @intUserId
		,@intStorageLocationId=@intStorageLocationId
		,@strBatchId=@strRetBatchId

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
