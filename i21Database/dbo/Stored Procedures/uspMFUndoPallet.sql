CREATE PROCEDURE uspMFUndoPallet (@strXML NVARCHAR(MAX))
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
		,@intItemId int
		,@intBatchId int
		,@ysnForceUndo bit
		,@intTransactionCount INT
		,@intItemUOMId int
		,@dblPhysicalCount NUMERIC(18,6)

	SELECT @intTransactionCount = @@TRANCOUNT
	
	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@strXML

	SELECT @intWorkOrderId = intWorkOrderId
		,@intBatchId=intBatchId
		,@intLotId = intLotId
		,@intUserId = intUserId
		,@ysnForceUndo=ysnForceUndo
	FROM OPENXML(@idoc, 'root', 2) WITH (
			intWorkOrderId INT
			,intBatchId int
			,intLotId INT
			,intUserId INT
			,ysnForceUndo bit
			)

	SELECT @intTransactionId=@intBatchId

	SELECT @strTransactionId = strWorkOrderNo 
		,@intItemId=intItemId
	FROM tblMFWorkOrder
	WHERE intWorkOrderId = @intWorkOrderId

	IF EXISTS (
			SELECT *
			FROM tblMFWorkOrderProducedLot
			WHERE intWorkOrderId = @intWorkOrderId
				AND intLotId = @intLotId
				AND ysnReleased = 1
			)
	BEGIN
		RAISERROR (
				51137
				,11
				,1
				)

		RETURN
	END

	IF EXISTS (
			SELECT *
			FROM tblMFWorkOrderProducedLot
			WHERE intWorkOrderId = @intWorkOrderId
				AND intLotId = @intLotId
				AND ysnProductionReversed = 1
			)
	BEGIN
		RAISERROR (
				51138
				,11
				,1
				)

		RETURN
	END

	IF EXISTS (
			SELECT *
			FROM dbo.tblICLot
			WHERE intLotId = @intLotId
				AND intLotStatusId = 2
			) and @ysnForceUndo=0
	BEGIN
		RAISERROR (
				51139
				,11
				,1
				)

		RETURN
	END

	IF EXISTS (
			SELECT *
			FROM dbo.tblICLot
			WHERE intLotId = @intLotId
				AND dblQty=0
			) and @ysnForceUndo=0
	BEGIN
		RAISERROR (
				90017
				,11
				,1
				)

		RETURN
	END

	IF NOT EXISTS (
			SELECT *
			FROM tblICInventoryTransaction
			WHERE intTransactionId = @intTransactionId
				AND strTransactionId = @strTransactionId
			)
	BEGIN
		SELECT @strTransactionId = strLotNumber
		FROM tblICLot
		WHERE intLotId = @intLotId
	END

	IF @intTransactionCount = 0
	BEGIN TRANSACTION

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
		,[dblDebitForeign]	
		,[dblDebitReport]	
		,[dblCreditForeign]	
		,[dblCreditReport]	
		,[dblReportingRate]	
		,[dblForeignRate]
		)
	EXEC dbo.uspICUnpostCosting @intTransactionId
		,@strTransactionId
		,@strBatchId
		,@intUserId
		,0

	EXEC dbo.uspGLBookEntries @GLEntries,0

	UPDATE dbo.tblMFWorkOrderProducedLot
	SET ysnProductionReversed = 1
		,dtmLastModified = GETDATE()
		,intLastModifiedUserId = @intUserId
	WHERE intLotId = @intLotId
		AND intWorkOrderId = @intWorkOrderId

	SELECT @dblQuantity = dblQuantity,
			@intItemUOMId=intItemUOMId,
			@dblPhysicalCount=dblPhysicalCount
	FROM tblMFWorkOrderProducedLot
	WHERE intLotId = @intLotId
		AND intWorkOrderId = @intWorkOrderId

	UPDATE tblMFWorkOrder
	SET dblProducedQuantity = isnull(dblProducedQuantity, 0) - (Case When intItemId=@intItemId Then (Case When intItemUOMId=@intItemUOMId Then @dblQuantity Else @dblPhysicalCount End) Else 0 End)
	WHERE intWorkOrderId = @intWorkOrderId

	UPDATE tblMFProductionSummary SET dblOutputQuantity=dblOutputQuantity-@dblQuantity WHERE intWorkOrderId=@intWorkOrderId AND intItemId=@intItemId
	
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


