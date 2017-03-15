CREATE PROCEDURE uspMFUnpostProducedLot (@strXML NVARCHAR(MAX))
AS
BEGIN TRY
	DECLARE @intWorkOrderId INT
		,@strBatchId NVARCHAR(50)
		,@strWorkOrderNo NVARCHAR(50)
		,@dtmDate DATETIME
		,@dblWeightPerUnit NUMERIC(38, 20)
		,@GLEntries AS RecapTableType
		,@intItemId INT
		,@intStorageLocationId INT
		,@strLotNumber NVARCHAR(50)
		,@idoc INT
		,@ErrMsg NVARCHAR(MAX)
		,@intLotId INT
		,@dblQty NUMERIC(38, 20)
		,@intItemUOMId INT
		,@dblWeight NUMERIC(38, 20)
		,@intWeightUOMId INT
		,@intBatchId INT
		,@intUserId INT
		,@intTransactionCount INT
		,@intManufacturingProcessId INT
		,@intAttributeTypeId INT

	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@strXML

	SELECT @intWorkOrderId = intWorkOrderId
		,@intLotId = intLotId
		,@dblQty = dblQty
		,@intItemUOMId = intItemUOMId
		,@dblWeight = dblWeight
		,@intWeightUOMId = intWeightUOMId
		,@intBatchId = intBatchId
		,@intUserId = intUserId
	FROM OPENXML(@idoc, 'root', 2) WITH (
			intWorkOrderId INT
			,intLotId INT
			,dblQty NUMERIC(38, 20)
			,intItemUOMId INT
			,dblWeight NUMERIC(38, 20)
			,intWeightUOMId INT
			,intBatchId INT
			,intUserId INT
			)

	SELECT @intBatchId = intBatchId
		,@intWorkOrderId = intWorkOrderId
		,@strBatchId = strBatchId
		,@intItemId = intItemId
		,@intStorageLocationId = intStorageLocationId
		,@intLotId = intLotId
	FROM dbo.tblMFWorkOrderProducedLot
	WHERE intLotId = @intLotId
		OR intWorkOrderId = @intWorkOrderId

	SELECT @strLotNumber = strLotNumber
	FROM tblICLot
	WHERE intLotId = @intLotId

	IF EXISTS (
			SELECT *
			FROM tblICInventoryTransaction
			WHERE intLotId = @intLotId
				AND ysnIsUnposted = 0
				AND intTransactionTypeId <> 9
			)
	BEGIN
		RAISERROR (
				90023
				,14
				,1
				,@strLotNumber
				)
	END

	SELECT @strWorkOrderNo = strWorkOrderNo
		,@intManufacturingProcessId = intManufacturingProcessId
	FROM tblMFWorkOrder
	WHERE intWorkOrderId = @intWorkOrderId

	SELECT @intAttributeTypeId = intAttributeTypeId
	FROM tblMFManufacturingProcess
	WHERE intManufacturingProcessId = @intManufacturingProcessId

	SELECT @dtmDate = dtmDate
	FROM tblICInventoryTransaction
	WHERE intTransactionId = @intBatchId
		AND strTransactionId = @strWorkOrderNo

	IF @dtmDate IS NULL
	BEGIN
		RETURN
	END

	SELECT @intTransactionCount = @@TRANCOUNT

	IF @intTransactionCount = 0
		BEGIN TRANSACTION

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

	EXEC dbo.uspGLBookEntries @GLEntries
		,0

	IF @intAttributeTypeId = 2
	BEGIN
		UPDATE tblMFWorkOrder
		SET intStatusId = 10
		WHERE intWorkOrderId = @intWorkOrderId

		UPDATE tblMFWorkOrderProducedLot
		SET ysnProductionReversed = 1
		WHERE intWorkOrderId = @intWorkOrderId
	END

	IF @dblQty > 0
	BEGIN
		DELETE
		FROM tblMFWorkOrderConsumedLot
		WHERE intWorkOrderId = @intWorkOrderId
			AND intBatchId = @intBatchId

		UPDATE dbo.tblMFWorkOrderProducedLot
		SET dblQuantity = @dblWeight
			,intItemUOMId = @intWeightUOMId
			,dblPhysicalCount = @dblQty
			,intPhysicalItemUOMId = @intItemUOMId
			,dblWeightPerUnit = @dblWeight / @dblQty
		WHERE intWorkOrderId = @intWorkOrderId
			AND intBatchId = @intBatchId

		SELECT @dblWeightPerUnit = @dblWeight / @dblQty

		EXEC dbo.uspMFPickWorkOrder @intWorkOrderId = @intWorkOrderId
			,@dblProduceQty = @dblWeight
			,@intProduceUOMId = @intWeightUOMId
			,@intBatchId = @intBatchId
			,@intUserId = @intUserId
			,@dblUnitQty = @dblWeightPerUnit
			,@ysnProducedQtyByWeight = 1

		EXEC [dbo].uspMFPostConsumptionProduction @intWorkOrderId = @intWorkOrderId
			,@intItemId = @intItemId
			,@strLotNumber = @strLotNumber
			,@dblWeight = @dblWeight
			,@intWeightUOMId = @intWeightUOMId
			,@dblUnitQty = @dblWeightPerUnit
			,@dblQty = @dblQty
			,@intItemUOMId = @intItemUOMId
			,@intUserId = @intUserId
			,@intBatchId = @intBatchId
			,@intLotId = @intLotId OUTPUT
			,@strLotAlias = @strWorkOrderNo
			,@strVendorLotNo = NULL
			,@strParentLotNumber = NULL
			,@intStorageLocationId = @intStorageLocationId
			,@dtmProductionDate = @dtmDate
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



