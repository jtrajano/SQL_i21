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
		,@dblQuantity NUMERIC(18, 6)
		,@RecordKey INT
		,@dtmCurrentDate DATETIME
		,@strLotNumber nvarchar(50)
		,@intAttributeId int
		,@intManufacturingProcessId int
		,@intLocationId int
		,@strAttributeValue nvarchar(50)

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
	FROM tblMFWorkOrder
	WHERE intWorkOrderId = @intWorkOrderId

	Select @intAttributeId=intAttributeId from tblMFAttribute Where strAttributeName='Is Warehouse Release Mandatory'
	
	Select @strAttributeValue=strAttributeValue
	From tblMFManufacturingProcessAttribute
	Where intManufacturingProcessId=@intManufacturingProcessId and intLocationId=@intLocationId and intAttributeId=@intAttributeId

	IF @strAttributeValue='True' AND EXISTS (
			SELECT *
			FROM dbo.tblMFWorkOrderProducedLot
			WHERE intWorkOrderId = @intWorkOrderId
				AND ysnReleased = 0
				AND ysnProductionReversed = 0
			)
	BEGIN
		RAISERROR (
				51141
				,11
				,1
				)

		RETURN
	END

	Select @intAttributeId=intAttributeId from tblMFAttribute Where strAttributeName='Is Cycle Count Mandatory'
	
	Select @strAttributeValue=strAttributeValue
	From tblMFManufacturingProcessAttribute
	Where intManufacturingProcessId=@intManufacturingProcessId and intLocationId=@intLocationId and intAttributeId=@intAttributeId

	If @strAttributeValue='True' and not exists(Select *from tblMFProcessCycleCountSession  Where intWorkOrderId=@intWorkOrderId)
	Begin
		RAISERROR (
				51131
				,11
				,1
				)
	End

	BEGIN TRANSACTION

	DECLARE @Lot TABLE (
		RecordKey INT identity(1, 1)
		,intLotId INT
		,strLotNumber nvarchar(50)
		)

	INSERT INTO @Lot (intLotId,strLotNumber)
	SELECT PL.intLotId,L.strLotNumber
	FROM dbo.tblMFWorkOrderProducedLot PL
	JOIN dbo.tblICLot L ON L.intLotId = PL.intLotId
	WHERE intWorkOrderId = @intWorkOrderId
		AND L.intLotStatusId = 3
		AND ysnProductionReversed = 0

	SELECT @RecordKey = MIN(RecordKey)
	FROM @Lot

	WHILE @RecordKey IS NOT NULL
	BEGIN
		SELECT @intLotId = intLotId,@strLotNumber=strLotNumber
		FROM @Lot
		WHERE RecordKey = @RecordKey

		DECLARE @STARTING_NUMBER_BATCH AS INT = 3

		EXEC dbo.uspSMGetStartingNumber @STARTING_NUMBER_BATCH
			,@strBatchId OUTPUT

		DECLARE @GLEntries AS RecapTableType

		INSERT INTO @GLEntries (
			[dtmDate]
			,[strBatchId]
			,[intAccountId]
			,[dblDebit]
			,[dblCredit]
			,[dblDebitUnit]
			,[dblCreditUnit]
			,[strDescription]
			,[strCode]
			,[strReference]
			,[intCurrencyId]
			,[dblExchangeRate]
			,[dtmDateEntered]
			,[dtmTransactionDate]
			,[strJournalLineDescription]
			,[intJournalLineNo]
			,[ysnIsUnposted]
			,[intUserId]
			,[intEntityId]
			,[strTransactionId]
			,[intTransactionId]
			,[strTransactionType]
			,[strTransactionForm]
			,[strModuleName]
			,[intConcurrencyId]
			)
		EXEC dbo.uspICUnpostCosting @intLotId
			,@strLotNumber
			,@strBatchId
			,@intUserId

		EXEC dbo.uspGLBookEntries @GLEntries
			,0

		UPDATE dbo.tblMFWorkOrderProducedLot
		SET ysnProductionReversed = 1
			,dtmLastModified = @dtmCurrentDate
			,intLastModifiedUserId = @intUserId
		WHERE intLotId = @intLotId
			AND intWorkOrderId = @intWorkOrderId

		SELECT @dblQuantity = dblQuantity
		FROM tblMFWorkOrderProducedLot
		WHERE intLotId = @intLotId
			AND intWorkOrderId = @intWorkOrderId

		UPDATE tblMFWorkOrder
		SET dblProducedQuantity = dblProducedQuantity - @dblQuantity
		WHERE intWorkOrderId = @intWorkOrderId

		SELECT @RecordKey = MIN(RecordKey)
		FROM @Lot
		WHERE RecordKey > @RecordKey
	END

	UPDATE dbo.tblMFWorkOrder
	SET intStatusId = 13
		,dtmCompletedDate = @dtmCurrentDate
		,dtmLastModified = @dtmCurrentDate
		,intLastModifiedUserId = @intUserId
	WHERE intWorkOrderId = @intWorkOrderId

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


