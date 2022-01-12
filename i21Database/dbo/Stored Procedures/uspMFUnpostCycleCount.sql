CREATE PROCEDURE uspMFUnpostCycleCount (@strXML NVARCHAR(MAX))
AS
SET ANSI_WARNINGS ON

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
		,@dblOtherCharges DECIMAL(38, 24)
		,@dblProduceQty NUMERIC(38, 20)
		,@ysnCostEnabled BIT
		,@intWOItemUOMId INT
		,@intUnitMeasureId INT
	DECLARE @intReturnValue AS INT
	DECLARE @unpostCostAdjustment AS ItemCostAdjustmentTableType
	DECLARE @strBatchIdForUnpost AS NVARCHAR(50)
	DECLARE @strErrorMessage AS NVARCHAR(4000)

	SELECT TOP 1 @ysnCostEnabled = ysnCostEnabled
	FROM tblMFCompanyPreference

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
		,@intWOItemUOMId = intItemUOMId
		,@strWorkOrderNo = strWorkOrderNo
	FROM tblMFWorkOrder
	WHERE intWorkOrderId = @intWorkOrderId

	SELECT @intUnitMeasureId = intUnitMeasureId
	FROM tblICItemUOM
	WHERE intItemUOMId = @intWOItemUOMId

	SELECT @strAttributeValue = strAttributeValue
	FROM tblMFManufacturingProcessAttribute
	WHERE intManufacturingProcessId = @intManufacturingProcessId
		AND intAttributeId = 20 --Is Instant Consumption
		AND intLocationId = @intLocationId

	SELECT @dblProduceQty = SUM(dbo.fnMFConvertQuantityToTargetItemUOM(WP.intItemUOMId, IsNULL(IU.intItemUOMId, WP.intItemUOMId), WP.dblQuantity))
	FROM dbo.tblMFWorkOrderProducedLot WP
	LEFT JOIN dbo.tblICItemUOM IU ON IU.intItemId = WP.intItemId
		AND IU.intUnitMeasureId = @intUnitMeasureId
	WHERE WP.intWorkOrderId = @intWorkOrderId
		AND WP.ysnProductionReversed = 0
		AND WP.intItemId IN (
			SELECT intItemId
			FROM dbo.tblMFWorkOrderRecipeItem
			WHERE intRecipeItemTypeId = 2
				AND ysnConsumptionRequired = 1
				AND intWorkOrderId = @intWorkOrderId
			)

	SELECT @intTransactionCount = @@TRANCOUNT

	SELECT @dtmCurrentDateTime = Getdate()

	IF @intTransactionCount = 0
		BEGIN TRANSACTION

	IF @strCostAdjustmentBatchId IS NOT NULL
	BEGIN
		DECLARE @adjustedEntries AS ItemCostAdjustmentTableType
		DECLARE @dblNewCost NUMERIC(38, 20)
			,@dblNewUnitCost NUMERIC(38, 20)
			,@userId INT
			,@intWorkOrderProducedLotId INT
			,@dblOtherCost NUMERIC(18, 6)

		SELECT @dblOtherCost = 0

		SELECT @intTransactionId = intBatchId
			,@strBatchId = strBatchId
		FROM tblMFWorkOrderConsumedLot
		WHERE intWorkOrderId = @intWorkOrderId

		SELECT @dblNewCost = SUM([dbo].[fnMFGetTotalStockValueFromTransactionBatch](DT.intBatchId, DT.strBatchId))
		FROM (
			SELECT DISTINCT intBatchId
				,strBatchId
			FROM tblMFWorkOrderConsumedLot
			WHERE intWorkOrderId = @intWorkOrderId
			) AS DT

		SELECT @intWorkOrderProducedLotId = MIN(intWorkOrderProducedLotId)
		FROM tblMFWorkOrderProducedLot PL
		WHERE intWorkOrderId = @intWorkOrderId
			AND PL.ysnProductionReversed = 0
			AND PL.intItemId IN (
				SELECT RI.intItemId
				FROM dbo.tblMFWorkOrderRecipeItem RI
				WHERE RI.intRecipeItemTypeId = 2
					AND RI.ysnConsumptionRequired = 1
					AND RI.intWorkOrderId = @intWorkOrderId
				)

		WHILE @intWorkOrderProducedLotId IS NOT NULL
		BEGIN
			SELECT @intTransactionId = NULL
				,@strBatchId = NULL

			SELECT @intTransactionId = PL.intBatchId
				,@strBatchId = PL.strBatchId
			FROM tblMFWorkOrderProducedLot PL
			WHERE intWorkOrderProducedLotId = @intWorkOrderProducedLotId

			SELECT @dblOtherCost = @dblOtherCost + ISNULL([dbo].[fnMFGetTotalStockValueFromTransactionBatch](@intTransactionId, @strBatchId), 0)

			SELECT @intWorkOrderProducedLotId = MIN(intWorkOrderProducedLotId)
			FROM tblMFWorkOrderProducedLot PL
			WHERE intWorkOrderId = @intWorkOrderId
				AND PL.ysnProductionReversed = 0
				AND PL.intItemId IN (
					SELECT RI.intItemId
					FROM dbo.tblMFWorkOrderRecipeItem RI
					WHERE RI.intRecipeItemTypeId = 2
						AND RI.ysnConsumptionRequired = 1
						AND RI.intWorkOrderId = @intWorkOrderId
					)
				AND intWorkOrderProducedLotId > @intWorkOrderProducedLotId
		END

		SELECT @dblOtherCharges = SUM(dblOtherCharges)
		FROM tblMFWorkOrderProducedLot
		WHERE intWorkOrderId = @intWorkOrderId
			AND ysnProductionReversed = 0

		IF @dblOtherCharges IS NOT NULL
		BEGIN
			SELECT @dblOtherCost = abs(@dblOtherCost) + @dblOtherCharges
		END

		SET @dblNewCost = ABS(@dblNewCost) + ISNULL(@dblOtherCost, 0)
		SET @dblNewUnitCost = ABS(@dblNewCost) / @dblProduceQty

		EXEC dbo.uspMFGeneratePatternId @intCategoryId = NULL
			,@intItemId = NULL
			,@intManufacturingId = NULL
			,@intSubLocationId = NULL
			,@intLocationId = @intLocationId
			,@intOrderTypeId = NULL
			,@intBlendRequirementId = NULL
			,@intPatternCode = 33
			,@ysnProposed = 0
			,@strPatternString = @intBatchId OUTPUT

		-- Get a new batch id to unpost the cost adjustment. 
		EXEC uspSMGetStartingNumber 3
			,@strBatchIdForUnpost OUT

		INSERT INTO @unpostCostAdjustment (
			[intItemId]
			,[intItemLocationId]
			,[intItemUOMId]
			,[dtmDate]
			,[dblQty]
			,[dblUOMQty]
			,[intCostUOMId]
			,[dblNewValue]
			,[intCurrencyId]
			,[intTransactionId]
			,[intTransactionDetailId]
			,[strTransactionId]
			,[intTransactionTypeId]
			,[intLotId]
			,[intSubLocationId]
			,[intStorageLocationId]
			,[ysnIsStorage]
			,[strActualCostId]
			,[intSourceTransactionId]
			,[intSourceTransactionDetailId]
			,[strSourceTransactionId]
			,intFobPointId
			,dblVoucherCost
			)
		SELECT t.[intItemId]
			,[intItemLocationId]
			,t.[intItemUOMId]
			,t.[dtmDate]
			,[dblQty]
			,[dblUOMQty]
			,[intCostUOMId] = t.[intItemUOMId]
			--,[dblNewValue] = IsNULL(Round(PL.dblItemValue,2,1), t.dblValue)
			,[dblNewValue] = t.dblValue
			,[intCurrencyId]
			,[intTransactionId] = t.intRelatedTransactionId
			,[intTransactionDetailId] = t.intTransactionDetailId
			,[strTransactionId]
			,[intTransactionTypeId] = 9
			,t.[intLotId]
			,t.[intSubLocationId]
			,t.[intStorageLocationId]
			,[ysnIsStorage] = 0
			,[strActualCostId]
			,[intSourceTransactionId] = t.intRelatedTransactionId
			,[intSourceTransactionDetailId] = t.intTransactionDetailId --t.intTransactionDetailId
			,[strSourceTransactionId] = t.strTransactionId
			,intFobPointId
			,dblVoucherCost = NULL
		FROM tblICInventoryTransaction t
		LEFT JOIN tblMFWorkOrderProducedLot PL ON PL.intWorkOrderProducedLotId = t.intTransactionDetailId
		WHERE t.strBatchId = @strCostAdjustmentBatchId
			AND t.ysnIsUnposted = 0
			AND t.intTransactionTypeId = 26
			AND t.strTransactionId = t.strRelatedTransactionId
			AND t.strTransactionId = @strWorkOrderNo

		EXEC @intReturnValue = uspICPostCostAdjustment @ItemsToAdjust = @unpostCostAdjustment
			,@strBatchId = @strBatchIdForUnpost
			,@intEntityUserSecurityId = @userId
			,@ysnPost = 0

		IF @intReturnValue <> 0
		BEGIN
			SELECT TOP 1 @strErrorMessage = strMessage
			FROM tblICPostResult
			WHERE strBatchNumber = @strBatchIdForUnpost

			RAISERROR (
					@strErrorMessage
					,11
					,1
					);
		END

		INSERT INTO @GLEntries (
			dtmDate
			,strBatchId
			,intAccountId
			,dblDebit
			,dblCredit
			,dblDebitUnit
			,dblCreditUnit
			,strDescription
			,strCode
			,strReference
			,intCurrencyId
			-- ,intCurrencyExchangeRateTypeId	
			,dblExchangeRate
			,dtmDateEntered
			,dtmTransactionDate
			,strJournalLineDescription
			,intJournalLineNo
			,ysnIsUnposted
			,intUserId
			,intEntityId
			,strTransactionId
			,intTransactionId
			,strTransactionType
			,strTransactionForm
			,strModuleName
			,intConcurrencyId
			,dblDebitForeign
			,dblDebitReport
			,dblCreditForeign
			,dblCreditReport
			,dblReportingRate
			,dblForeignRate
			,intSourceEntityId
			,intCommodityId
			)
		EXEC dbo.uspICCreateGLEntriesOnCostAdjustment @strBatchId = @strBatchIdForUnpost
			,@intEntityUserSecurityId = @intUserId
			,@strGLDescription = ''
			,@ysnPost = 0
			,@AccountCategory_Cost_Adjustment = 'Inventory Adjustment'
			,@strTransactionId = @strWorkOrderNo

		-- Flag it as unposted. 
		UPDATE @GLEntries
		SET ysnIsUnposted = 1

		IF EXISTS (
				SELECT 1
				FROM @GLEntries
				)
		BEGIN

			IF EXISTS (
					SELECT *
					FROM tblMFWorkOrderRecipeItem WRI
					JOIN tblICItem I ON I.intItemId = WRI.intItemId
					WHERE I.strType = 'Other Charge'
						AND WRI.intWorkOrderId = @intWorkOrderId
					)
			BEGIN
				EXEC dbo.uspGLBookEntries @GLEntries
					,0
					,1
					,1
			END
			ELSE
			BEGIN
				EXEC dbo.uspGLBookEntries @GLEntries
					,0
			END

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
			,[intSourceEntityId]
			,[intCommodityId]
			)
		EXEC dbo.uspICUnpostCosting @intTransactionId
			,@strAdjustmentNo
			,@strBatchId
			,@intUserId
			,0


		IF EXISTS (
				SELECT *
				FROM tblMFWorkOrderRecipeItem WRI
				JOIN tblICItem I ON I.intItemId = WRI.intItemId
				WHERE I.strType = 'Other Charge'
					AND WRI.intWorkOrderId = @intWorkOrderId
				)
		BEGIN
			EXEC dbo.uspGLBookEntries @GLEntries
				,0
				,1
				,1
		END
		ELSE
		BEGIN
			EXEC dbo.uspGLBookEntries @GLEntries
				,0
		END


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

		--,@strWorkOrderNo = NULL
		SELECT @strBatchId = strBatchId
			,@intBatchId = intBatchId
		FROM tblMFWorkOrderConsumedLot
		WHERE intWorkOrderId = @intWorkOrderId

		DELETE
		FROM @GLEntries

		-- Get a new batch id to unpost the consume transactions. 
		EXEC uspSMGetStartingNumber 3
			,@strBatchIdForUnpost OUT

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
			,[intSourceEntityId]
			,[intCommodityId]
			)
		EXEC dbo.uspICUnpostCosting @intBatchId
			,@strWorkOrderNo
			,@strBatchIdForUnpost --@strBatchId
			,@intUserId
			,0

		IF EXISTS (
				SELECT *
				FROM @GLEntries
				)
		BEGIN
			IF EXISTS (
					SELECT *
					FROM tblMFWorkOrderRecipeItem WRI
					JOIN tblICItem I ON I.intItemId = WRI.intItemId
					WHERE I.strType = 'Other Charge'
						AND WRI.intWorkOrderId = @intWorkOrderId
					)
			BEGIN
				EXEC dbo.uspGLBookEntries @GLEntries
					,0
					,1
					,1
			END
			ELSE
			BEGIN
				EXEC dbo.uspGLBookEntries @GLEntries
					,0
			END
		END

		DECLARE @tblMFWorkOrderConsumedLot TABLE (intWorkOrderConsumedLotId INT);

		DELETE
		FROM dbo.tblMFWorkOrderConsumedLot
		OUTPUT deleted.intWorkOrderConsumedLotId
		INTO @tblMFWorkOrderConsumedLot
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

		INSERT INTO tblMFInventoryAdjustment (
			dtmDate
			,intTransactionTypeId
			,intItemId
			,intSourceLotId
			,dblQty
			,intItemUOMId
			,intUserId
			,intLocationId
			,intStorageLocationId
			,intWorkOrderConsumedLotId
			,dtmBusinessDate
			,intBusinessShiftId
			,intWorkOrderId
			)
		SELECT dtmDate
			,intTransactionTypeId
			,IA.intItemId
			,intSourceLotId
			,- dblQty
			,intItemUOMId
			,intUserId
			,intLocationId
			,intStorageLocationId
			,IA.intWorkOrderConsumedLotId
			,dtmBusinessDate
			,intBusinessShiftId
			,intWorkOrderId
		FROM tblMFInventoryAdjustment IA
		JOIN @tblMFWorkOrderConsumedLot WC ON IA.intWorkOrderConsumedLotId = WC.intWorkOrderConsumedLotId
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
				,[intSourceEntityId]
				,[intCommodityId]
				)
			EXEC dbo.uspICPostCosting @ItemsForPost
				,@strBatchId
				,@ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY
				,@intUserId

			IF EXISTS (
					SELECT *
					FROM tblMFWorkOrderRecipeItem WRI
					JOIN tblICItem I ON I.intItemId = WRI.intItemId
					WHERE I.strType = 'Other Charge'
						AND WRI.intWorkOrderId = @intWorkOrderId
					)
			BEGIN
				EXEC dbo.uspGLBookEntries @GLEntries
					,1
					,1
					,1
			END
			ELSE
			BEGIN
				EXEC dbo.uspGLBookEntries @GLEntries
					,1
			END

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
		IF NOT EXISTS (
				SELECT SUM(dblQty)
				FROM tblICInventoryTransaction
				WHERE strTransactionId = @strWorkOrderNo
					AND intTransactionTypeId = 8
				HAVING SUM(dblQty) = 0
				)
		BEGIN
			RAISERROR (
					'Unable to reverse consumption entries.'
					,16
					,1
					)

			RETURN
		END

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
		LEFT JOIN tblICLot L ON L.intLotId = WI.intLotId
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
GO


