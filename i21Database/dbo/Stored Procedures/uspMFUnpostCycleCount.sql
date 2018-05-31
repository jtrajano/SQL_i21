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
		,@ItemsToReserve AS dbo.ItemReservationTableType
		,@intInventoryTransactionType AS INT = 8
		,@intInputItemId INT
		,@intProductionStageLocationId INT
		,@intProductionStagingId INT
		,@intConsumptionStorageLocationId INT
		,@intConsumptionSubLocationId INT
		,@ItemsForPost AS ItemCostingTableType
		,@dtmCurrentDateTime DATETIME
		,@INVENTORY_CONSUME AS INT = 8
		,@ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY AS NVARCHAR(255) = 'Work In Progress'
		,@STARTING_NUMBER_BATCH AS INT = 3

	SELECT @dtmCurrentDateTime = Getdate()

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
		AND intAttributeId = 20 --Is Instant Consumption
		AND intLocationId = @intLocationId

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
			)
		--,strRateType
		EXEC dbo.uspICUnpostCostAdjustment @intTransactionId
			,@strTransactionId
			,@strCostAdjustmentBatchId
			,@intUserId
			,'Work In Progress'

		IF EXISTS (
				SELECT *
				FROM @GLEntries
				)
		BEGIN
			EXEC dbo.uspGLBookEntries @GLEntries
				,0
		END
	END

	UPDATE tblMFWorkOrder
	SET intCountStatusId = 10
		,strBatchId = NULL
		,intBatchID = NULL
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

	SELECT @strWorkOrderNo = strWorkOrderNo
	FROM tblMFWorkOrder
	WHERE intWorkOrderId = @intWorkOrderId

	IF @strAttributeValue = 'False' --Is Instant Consumption
	BEGIN
		SELECT @strBatchId = NULL
			,@intBatchId = NULL
			,@strWorkOrderNo = NULL

		SELECT @strBatchId = strBatchId
			,@intBatchId = intBatchId
		FROM tblMFWorkOrderConsumedLot
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

		IF EXISTS (
				SELECT *
				FROM @GLEntries
				)
		BEGIN
			EXEC dbo.uspGLBookEntries @GLEntries
				,0
		END

		DELETE
		FROM dbo.tblMFWorkOrderConsumedLot
		WHERE intWorkOrderId = @intWorkOrderId
			AND intBatchId = @intBatchId
			AND intItemId NOT IN (
				SELECT intItemId
				FROM tblMFWorkOrderProducedLot
				WHERE intWorkOrderId = @intWorkOrderId
					AND intSpecialPalletLotId IS NOT NULL
				)

		UPDATE tblMFProductionSummary
		SET dblConsumedQuantity = 0
		WHERE intWorkOrderId = @intWorkOrderId
			AND intItemTypeId IN (
				1
				,3
				)

		DELETE
		FROM dbo.tblMFWorkOrderProducedLotTransaction
		WHERE intWorkOrderId = @intWorkOrderId
	END
	ELSE
	BEGIN
		IF EXISTS (
				SELECT *
				FROM tblMFWorkOrderProducedLotTransaction
				WHERE intWorkOrderId = @intWorkOrderId
				)
		BEGIN
			EXEC dbo.uspSMGetStartingNumber @STARTING_NUMBER_BATCH
				,@strBatchId OUTPUT

			DELETE
			FROM @ItemsForPost

			--Lot Tracking
			INSERT INTO @ItemsForPost (
				intItemId
				,intItemLocationId
				,intItemUOMId
				,dtmDate
				,dblQty
				,dblUOMQty
				,dblCost
				,dblSalesPrice
				,intCurrencyId
				,dblExchangeRate
				,intTransactionId
				,intTransactionDetailId
				,strTransactionId
				,intTransactionTypeId
				,intLotId
				,intSubLocationId
				,intStorageLocationId
				,intSourceTransactionId
				,strSourceTransactionId
				)
			SELECT intItemId = l.intItemId
				,intItemLocationId = l.intItemLocationId
				,intItemUOMId = cl.intItemUOMId 
				,dtmDate = @dtmCurrentDateTime
				,dblQty = cl.dblQuantity
				,dblUOMQty = l.dblWeightPerQty 
				,dblCost = l.dblLastCost
				,dblSalesPrice = 0
				,intCurrencyId = NULL
				,dblExchangeRate = 1
				,intTransactionId = cl.intBatchId
				,intTransactionDetailId = cl.intWorkOrderConsumedLotId
				,strTransactionId = @strTransactionId
				,intTransactionTypeId = @INVENTORY_CONSUME
				,intLotId = l.intLotId
				,intSubLocationId = l.intSubLocationId
				,intStorageLocationId = l.intStorageLocationId
				,intSourceTransactionId = @INVENTORY_CONSUME
				,strSourceTransactionId = @strTransactionId
			FROM dbo.tblMFWorkOrderConsumedLot cl
			JOIN dbo.tblICLot l ON cl.intLotId = l.intLotId
			JOIN dbo.tblICItemUOM ItemUOM ON l.intItemUOMId = ItemUOM.intItemUOMId
			LEFT JOIN dbo.tblICItemUOM WeightUOM ON l.intWeightUOMId = WeightUOM.intItemUOMId
			WHERE cl.intWorkOrderId = @intWorkOrderId
				AND intSequenceNo = 9999

			DELETE
			FROM @GLEntries

			-- Call the post routine 
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
			EXEC dbo.uspICPostCosting @ItemsForPost
				,@strBatchId
				,@ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY
				,@intUserId

			EXEC dbo.uspGLBookEntries @GLEntries
				,1

			DELETE
			FROM tblMFWorkOrderConsumedLot
			WHERE intWorkOrderId = @intWorkOrderId
				AND intSequenceNo = 9999

			DELETE
			FROM tblMFWorkOrderProducedLotTransaction
			WHERE intWorkOrderId = @intWorkOrderId
		END
	END

	IF @strAttributeValue = 'False' --Is Instant Consumption
	BEGIN
		SELECT @intInputItemId = intItemId
		FROM tblMFWorkOrderInputLot
		WHERE intWorkOrderId = @intWorkOrderId

		SELECT @intProductionStageLocationId = intProductionStagingLocationId
		FROM tblMFManufacturingProcessMachine
		WHERE intManufacturingProcessId = @intManufacturingProcessId
			AND @intProductionStageLocationId IS NOT NULL

		IF @intProductionStageLocationId IS NULL
		BEGIN
			SELECT @intProductionStagingId = intAttributeId
			FROM tblMFAttribute
			WHERE strAttributeName = 'Production Staging Location'

			SELECT @intProductionStageLocationId = strAttributeValue
			FROM tblMFManufacturingProcessAttribute
			WHERE intManufacturingProcessId = @intManufacturingProcessId
				AND intLocationId = @intLocationId
				AND intAttributeId = @intProductionStagingId
		END

		SELECT @intConsumptionStorageLocationId = CASE 
				WHEN RI.intConsumptionMethodId = 1
					THEN @intProductionStageLocationId
				ELSE RI.intStorageLocationId
				END
		FROM dbo.tblMFWorkOrderRecipeItem RI
		LEFT JOIN dbo.tblMFWorkOrderRecipeSubstituteItem RS ON RS.intRecipeItemId = RI.intRecipeItemId
		WHERE RI.intWorkOrderId = @intWorkOrderId
			AND RI.intRecipeItemTypeId = 1
			AND (
				RI.intItemId = @intInputItemId
				OR RS.intSubstituteItemId = @intInputItemId
				)

		SELECT @intConsumptionSubLocationId = intSubLocationId
		FROM dbo.tblICStorageLocation
		WHERE intStorageLocationId = @intConsumptionStorageLocationId

		EXEC dbo.uspICCreateStockReservation @ItemsToReserve
			,@intWorkOrderId
			,@intInventoryTransactionType

		INSERT INTO @ItemsToReserve (
			intItemId
			,intItemLocationId
			,intItemUOMId
			,intLotId
			,intSubLocationId
			,intStorageLocationId
			,dblQty
			,intTransactionId
			,strTransactionId
			,intTransactionTypeId
			)
		SELECT intItemId = WI.intItemId
			,intItemLocationId = IL.intItemLocationId
			,intItemUOMId = WI.intItemIssuedUOMId
			,intLotId = (
				SELECT TOP 1 intLotId
				FROM tblICLot L1
				WHERE L1.strLotNumber = L.strLotNumber
					AND L1.intStorageLocationId = @intConsumptionStorageLocationId
				)
			,intSubLocationId = @intConsumptionSubLocationId
			,intStorageLocationId = @intConsumptionStorageLocationId
			,dblQty = SUM(WI.dblIssuedQuantity)
			,intTransactionId = @intWorkOrderId
			,strTransactionId = @strWorkOrderNo
			,intTransactionTypeId = @intInventoryTransactionType
		FROM tblMFWorkOrderInputLot WI
		JOIN tblICItemLocation IL ON IL.intItemId = WI.intItemId
			AND IL.intLocationId = @intLocationId
			AND WI.ysnConsumptionReversed = 0
		JOIN tblICLot L ON L.intLotId = WI.intLotId
		WHERE intWorkOrderId = @intWorkOrderId
		GROUP BY WI.intItemId
			,IL.intItemLocationId
			,WI.intItemIssuedUOMId
			,L.strLotNumber

		EXEC dbo.uspICCreateStockReservation @ItemsToReserve
			,@intWorkOrderId
			,@intInventoryTransactionType
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
Go
