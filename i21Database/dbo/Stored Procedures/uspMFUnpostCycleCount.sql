﻿CREATE PROCEDURE uspMFUnpostCycleCount (@strXML NVARCHAR(MAX))
AS
BEGIN TRY
	DECLARE @intWorkOrderId INT
		,@GLEntries AS RecapTableType
		,@idoc INT
		,@ErrMsg NVARCHAR(MAX)
		,@intUserId INT
		,@intTransactionCount INT
		,@intManufacturingProcessId INT
		,@intTransaction INT
		,@strTransactionId NVARCHAR(50)
		,@strCostAdjustmentBatchId NVARCHAR(50)
		,@strAttributeValue NVARCHAR(50)
		,@intWorkOrderProducedLotTransactionId INT
		,@intInventoryAdjustmentId INT
		,@strAdjustmentNo NVARCHAR(50)
		,@intTransactionId INT
		,@strWorkOrderNo NVARCHAR(50)
		,@strBatchId NVARCHAR(50)
		,@intBatchId INT

	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@strXML

	SELECT @intWorkOrderId = intWorkOrderId
		,@intUserId = intUserId
	FROM OPENXML(@idoc, 'root', 2) WITH (
			intWorkOrderId INT
			,intUserId INT
			)

	SELECT @intManufacturingProcessId = intManufacturingProcessId
		,@strCostAdjustmentBatchId = strCostAdjustmentBatchId
	FROM tblMFWorkOrder
	WHERE intWorkOrderId = @intWorkOrderId

	SELECT @strAttributeValue = strAttributeValue
	FROM tblMFManufacturingProcessAttribute
	WHERE intManufacturingProcessId = @intManufacturingProcessId
		AND intAttributeId = 20

	SELECT @intTransactionCount = @@TRANCOUNT

	IF @intTransactionCount = 0
		BEGIN TRANSACTION

	IF @strCostAdjustmentBatchId IS NOT NULL
	BEGIN
		SELECT @intTransaction = intTransactionId
			,@strTransactionId = strTransactionId
		FROM tblICInventoryTransaction
		WHERE strBatchId = @strCostAdjustmentBatchId

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

		EXEC dbo.uspGLBookEntries @GLEntries
			,0
	END

	UPDATE tblMFWorkOrder
	SET intCountStatusId = 10
	WHERE intWorkOrderId = @intWorkOrderId

	SELECT @intWorkOrderProducedLotTransactionId = MIN(intWorkOrderProducedLotTransactionId)
	FROM tblMFWorkOrderProducedLotTransaction PL
	WHERE intWorkOrderId = @intWorkOrderId

	WHILE @intWorkOrderProducedLotTransactionId IS NOT NULL
	BEGIN
		SELECT @strAdjustmentNo = NULL
			,@intTransactionId = NULL
			,@strBatchId = NULL
			,@intInventoryAdjustmentId = NULL

		SELECT @intInventoryAdjustmentId = intTransactionId
		FROM tblMFWorkOrderProducedLotTransaction PL
		WHERE intWorkOrderId = @intWorkOrderId
			AND intWorkOrderProducedLotTransactionId = @intWorkOrderProducedLotTransactionId

		SELECT @strAdjustmentNo = strAdjustmentNo
		FROM tblICInventoryAdjustment
		WHERE intInventoryAdjustmentId = @intInventoryAdjustmentId

		SELECT @intTransactionId = intTransactionId
			,@strBatchId = strBatchId
		FROM tblICInventoryTransaction
		WHERE strTransactionId = @strAdjustmentNo

		DELETE
		FROM @GLEntries

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
			,@strAdjustmentNo
			,@strBatchId
			,@intUserId
			,0

		EXEC dbo.uspGLBookEntries @GLEntries
			,0

		SELECT @intWorkOrderProducedLotTransactionId = MIN(intWorkOrderProducedLotTransactionId)
		FROM tblMFWorkOrderProducedLotTransaction PL
		WHERE intWorkOrderId = @intWorkOrderId
			AND intWorkOrderProducedLotTransactionId > @intWorkOrderProducedLotTransactionId
	END

	IF @strAttributeValue = 'False'
	BEGIN
		SELECT @strBatchId = NULL
			,@intBatchId = NULL
			,@strWorkOrderNo = NULL

		SELECT @strBatchId = strBatchId
			,@intBatchId = intBatchId
		FROM tblMFWorkOrderConsumedLot
		WHERE intWorkOrderId = @intWorkOrderId

		SELECT @strWorkOrderNo = strWorkOrderNo
		FROM tblMFWorkOrder
		WHERE intWorkOrderId = @intWorkOrderId

		DELETE
		FROM @GLEntries

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
		EXEC dbo.uspICUnpostCosting @intBatchId
			,@strWorkOrderNo
			,@strBatchId
			,@intUserId
			,0

		EXEC dbo.uspGLBookEntries @GLEntries
			,0
	END

	IF @intTransactionCount = 0
		COMMIT TRANSACTION

	EXEC sp_xml_removedocument @idoc
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	IF XACT_STATE() != 0
		AND @intTransactionCount = 0
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


