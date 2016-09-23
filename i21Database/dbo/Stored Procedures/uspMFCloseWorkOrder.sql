CREATE PROCEDURE uspMFCloseWorkOrder (@strXML NVARCHAR(MAX))
AS
BEGIN TRY
	DECLARE @idoc INT
		,@ErrMsg NVARCHAR(MAX)
		,@intWorkOrderId INT
		,@intLotId INT
		,@intUserId INT
		,@strBatchId NVARCHAR(40)
		,@intTransactionId INT
		,@strTransactionId NVARCHAR(50)
		,@dblQuantity NUMERIC(38, 20)
		,@intRecordId INT
		,@dtmCurrentDate DATETIME
		,@strLotNumber nvarchar(50)
		,@intAttributeId int
		,@intManufacturingProcessId int
		,@intLocationId int
		,@strAttributeValue nvarchar(50)
		,@strCycleCountMandatory nvarchar(50)
		,@intExecutionOrder INT
		,@intManufacturingCellId INT
		,@dtmPlannedDate DATETIME
		,@intTransactionCount INT
		,@strInstantConsumption nvarchar(50)
		,@strWorkOrderNo nvarchar(50)
		,@intBatchId int
		,@strUndoXML nvarchar(MAX)

	SELECT @dtmCurrentDate = GetDate()

	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@strXML

	SELECT @intWorkOrderId = intWorkOrderId
		,@intUserId = intUserId
	FROM OPENXML(@idoc, 'root', 2) WITH (
			intWorkOrderId INT
			,intUserId INT
			)

	IF NOT EXISTS (
			SELECT *
			FROM tblMFWorkOrder
			WHERE intWorkOrderId = @intWorkOrderId
			)
	BEGIN
		RAISERROR (51140
				,11
				,1
				)
	END

	SELECT @intManufacturingProcessId=intManufacturingProcessId
		,@intLocationId=intLocationId
		,@strWorkOrderNo=strWorkOrderNo 
	FROM tblMFWorkOrder
	WHERE intWorkOrderId = @intWorkOrderId

	Select @intAttributeId=intAttributeId from tblMFAttribute Where strAttributeName='Is Warehouse Release Mandatory'
	
	Select @strAttributeValue=strAttributeValue
	From tblMFManufacturingProcessAttribute
	Where intManufacturingProcessId=@intManufacturingProcessId and intLocationId=@intLocationId and intAttributeId=@intAttributeId

	IF @strAttributeValue='True' AND EXISTS (
			SELECT *
			FROM dbo.tblMFWorkOrderProducedLot WP
			JOIN dbo.tblICLot L on L.intLotId=WP.intLotId
			WHERE WP.intWorkOrderId = @intWorkOrderId
				AND WP.ysnReleased = 0
				AND WP.ysnProductionReversed = 0
				AND L.intLotStatusId =3
			)
	BEGIN
		RAISERROR (
				51141
				,11
				,1
				)

		RETURN
	END

	Select @intAttributeId=intAttributeId from tblMFAttribute Where strAttributeName='Is Cycle Count Required'

	Select @strCycleCountMandatory=strAttributeValue
	From tblMFManufacturingProcessAttribute
	Where intManufacturingProcessId=@intManufacturingProcessId and intLocationId=@intLocationId and intAttributeId=@intAttributeId

	If @strCycleCountMandatory='True' and not exists(Select *from tblMFProcessCycleCountSession  Where intWorkOrderId=@intWorkOrderId) 
		and (Exists(SELECT *
			FROM dbo.tblMFWorkOrderProducedLot
			WHERE intWorkOrderId = @intWorkOrderId) 
			OR Exists(SELECT *
			FROM dbo.tblMFWorkOrderInputLot 
			WHERE intWorkOrderId = @intWorkOrderId))
	Begin
		RAISERROR (
				51131
				,11
				,1
				)
	End
	SELECT @intTransactionCount = @@TRANCOUNT

	IF @intTransactionCount = 0
	BEGIN TRANSACTION

	Select @intAttributeId=intAttributeId from tblMFAttribute Where strAttributeName='Is Instant Consumption'
	
	Select @strInstantConsumption=strAttributeValue
	From tblMFManufacturingProcessAttribute
	Where intManufacturingProcessId=@intManufacturingProcessId and intLocationId=@intLocationId and intAttributeId=@intAttributeId

	IF @strCycleCountMandatory='False' and @strInstantConsumption='False'
	BEGIN
		EXEC dbo.uspMFPostWorkOrder @strXML=@strXML
	END

	DECLARE @tblMFLot TABLE (
		intRecordId INT identity(1, 1)
		,intBatchId INT
		,intLotId int
		)

	INSERT INTO @tblMFLot (intBatchId,intLotId)
	SELECT PL.intBatchId,PL.intLotId
	FROM dbo.tblMFWorkOrderProducedLot PL
	JOIN dbo.tblICLot L ON L.intLotId = PL.intLotId
	WHERE intWorkOrderId = @intWorkOrderId
		AND L.intLotStatusId = 2
		AND ysnProductionReversed = 0

	SELECT @intRecordId = MIN(intRecordId)
	FROM @tblMFLot

	WHILE @intRecordId IS NOT NULL AND @strAttributeValue='True'
	BEGIN
		SELECT @intBatchId=NULL,@intLotId=NULL

		SELECT @intBatchId = intBatchId,@intLotId=intLotId
		FROM @tblMFLot
		WHERE intRecordId = @intRecordId

		Select @strUndoXML=N'<root><intWorkOrderId>'+Ltrim(@intWorkOrderId)+'</intWorkOrderId><intLotId>'+Ltrim(@intLotId)+'</intLotId><intBatchId>'+Ltrim(@intBatchId)+'</intBatchId><ysnForceUndo>True</ysnForceUndo><intUserId>'+Ltrim(@intUserId)+'</intUserId></root>'

		EXEC uspMFUndoPallet @strUndoXML

		SELECT @intRecordId = MIN(intRecordId)
		FROM @tblMFLot
		WHERE intRecordId > @intRecordId
	END

	SELECT @intExecutionOrder = intExecutionOrder
		,@intManufacturingCellId = intManufacturingCellId
		,@dtmPlannedDate = dtmPlannedDate
	FROM dbo.tblMFWorkOrder
	WHERE intWorkOrderId = @intWorkOrderId

	UPDATE dbo.tblMFWorkOrder
	SET intStatusId = 13
		,dtmCompletedDate = @dtmCurrentDate
		,intExecutionOrder=0
		,intConcurrencyId=intConcurrencyId+1
		,dtmLastModified = @dtmCurrentDate
		,intLastModifiedUserId = @intUserId
	WHERE intWorkOrderId = @intWorkOrderId

	UPDATE dbo.tblMFScheduleWorkOrder
	SET intStatusId = 13
		,intConcurrencyId=intConcurrencyId+1
		,dtmLastModified = @dtmCurrentDate
		,intLastModifiedUserId = @intUserId
	WHERE intWorkOrderId = @intWorkOrderId

	UPDATE dbo.tblMFWorkOrder
	SET intExecutionOrder = intExecutionOrder - 1
	WHERE intManufacturingCellId = @intManufacturingCellId
		AND dtmPlannedDate = @dtmPlannedDate
		AND intExecutionOrder > @intExecutionOrder

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


