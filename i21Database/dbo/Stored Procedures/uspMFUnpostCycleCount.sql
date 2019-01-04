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
		,@intWOItemUOMId int
		,@intUnitMeasureId int


	DECLARE @intReturnValue AS INT
	DECLARE @unpostCostAdjustment AS ItemCostAdjustmentTableType
	DECLARE @strBatchIdForUnpost AS NVARCHAR(50)
	DECLARE @strErrorMessage AS NVARCHAR(4000)

	SELECT TOP 1 @ysnCostEnabled=ysnCostEnabled
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
		,@intWOItemUOMId=intItemUOMId
	FROM tblMFWorkOrder
	WHERE intWorkOrderId = @intWorkOrderId

			Select @intUnitMeasureId=intUnitMeasureId
	From tblICItemUOM
	Where intItemUOMId=@intWOItemUOMId

	SELECT @strAttributeValue = strAttributeValue
	FROM tblMFManufacturingProcessAttribute
	WHERE intManufacturingProcessId = @intManufacturingProcessId
		AND intAttributeId = 20 --Is Instant Consumption
		AND intLocationId = @intLocationId

	SELECT @dblProduceQty = SUM(dbo.fnMFConvertQuantityToTargetItemUOM(WP.intItemUOMId,IsNULL(IU.intItemUOMId,WP.intItemUOMId),WP.dblQuantity))
	FROM dbo.tblMFWorkOrderProducedLot WP
	Left JOIN dbo.tblICItemUOM IU on IU.intItemId=WP.intItemId and IU.intUnitMeasureId=@intUnitMeasureId
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
			,[dblNewValue] = t.dblValue
			,[intCurrencyId]
			,[intTransactionId] = pl.intBatchId
			,[intTransactionDetailId] = pl.intWorkOrderProducedLotId
			,[strTransactionId]
			,[intTransactionTypeId] = 9
			,t.[intLotId]
			,t.[intSubLocationId]
			,t.[intStorageLocationId]
			,[ysnIsStorage] = 0
			,[strActualCostId]
			,[intSourceTransactionId] = pl.intBatchId --t.intTransactionId
			,[intSourceTransactionDetailId] = pl.intWorkOrderProducedLotId --t.intTransactionDetailId
			,[strSourceTransactionId] = t.strTransactionId
			,intFobPointId
			,dblVoucherCost = NULL
		FROM tblICInventoryTransaction t
		INNER JOIN (
			tblMFWorkOrderProducedLot pl LEFT JOIN tblMFWorkOrder wo ON pl.intWorkOrderId = wo.intWorkOrderId
				AND pl.ysnProductionReversed = 0
			) ON t.strTransactionId = wo.strWorkOrderNo
			AND t.intLotId = ISNULL(pl.intProducedLotId, pl.intLotId)
		WHERE t.strBatchId = @strCostAdjustmentBatchId
			AND t.strTransactionId = t.strRelatedTransactionId
			AND t.ysnIsUnposted = 0
			AND t.intTransactionTypeId = 26

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
			)
		EXEC dbo.uspICCreateGLEntriesOnCostAdjustment @strBatchId = @strBatchIdForUnpost
			,@intEntityUserSecurityId = @intUserId
			,@strGLDescription = ''
			,@ysnPost = 0
			,@AccountCategory_Cost_Adjustment = 'Work In Progress'

		-- Flag it as unposted. 
		UPDATE @GLEntries
		SET ysnIsUnposted = 1

		IF EXISTS (
				SELECT TOP 1 1
				FROM @GLEntries
				)
		BEGIN
			EXEC uspGLBookEntries @GLEntries
				,1
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
			--,@strWorkOrderNo = NULL

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


