CREATE PROCEDURE uspMFUnpostCycleCount (@strXML NVARCHAR(MAX))
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
		,@intYieldCostId INT
		,@strYieldCostValue NVARCHAR(50)
		,@intLocationId INT

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
		,@intLocationId = intLocationId
	FROM tblMFWorkOrder
	WHERE intWorkOrderId = @intWorkOrderId

	SELECT @strAttributeValue = strAttributeValue
	FROM tblMFManufacturingProcessAttribute
	WHERE intManufacturingProcessId = @intManufacturingProcessId
		AND intAttributeId = 20--Is Instant Consumption
		AND intLocationId =@intLocationId

	SELECT @intTransactionCount = @@TRANCOUNT

	IF @intTransactionCount = 0
		BEGIN TRANSACTION

	IF @strCostAdjustmentBatchId IS NOT NULL
	BEGIN
		SELECT @intTransactionId = intTransactionId
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
			,strRateType
			)
		EXEC dbo.uspICUnpostCostAdjustment @intTransactionId
			,@strTransactionId
			,@strCostAdjustmentBatchId
			,@intUserId
			,0

		EXEC dbo.uspGLBookEntries @GLEntries
			,0
	END

	UPDATE tblMFWorkOrder
	SET intCountStatusId = 10
	WHERE intWorkOrderId = @intWorkOrderId

	SELECT @intYieldCostId = intAttributeId
	FROM tblMFAttribute
	WHERE strAttributeName = 'Add yield cost to output item'

	SELECT @strYieldCostValue = strAttributeValue
	FROM tblMFManufacturingProcessAttribute
	WHERE intManufacturingProcessId = @intManufacturingProcessId
		AND intLocationId = @intLocationId
		AND intAttributeId = @intYieldCostId

	SELECT @intWorkOrderProducedLotTransactionId = MIN(intWorkOrderProducedLotTransactionId)
	FROM tblMFWorkOrderProducedLotTransaction PL
	WHERE intWorkOrderId = @intWorkOrderId

	WHILE @intWorkOrderProducedLotTransactionId IS NOT NULL
		AND @strYieldCostValue = 'False'
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
			,[strRateType]
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
			,[strRateType]
		)
		EXEC dbo.uspICUnpostCosting @intBatchId
			,@strWorkOrderNo
			,@strBatchId
			,@intUserId
			,0

		IF EXISTS(SELECT *FROM @GLEntries)
		BEGIN
			EXEC dbo.uspGLBookEntries @GLEntries
				,0
		END

		DELETE
		FROM dbo.tblMFWorkOrderConsumedLot
		WHERE intWorkOrderId = @intWorkOrderId
			AND intBatchId = @intBatchId
			AND intItemId NOT IN (Select intItemId from tblMFWorkOrderProducedLot Where intWorkOrderId = @intWorkOrderId and intSpecialPalletLotId is not null)

		UPDATE tblMFProductionSummary
		SET dblConsumedQuantity = 0
		WHERE intWorkOrderId = @intWorkOrderId
		And intItemTypeId IN (1,3)

		DELETE FROM dbo.tblMFWorkOrderProducedLotTransaction WHERE intWorkOrderId=@intWorkOrderId
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


