CREATE PROCEDURE uspMFReopenWorkOrder (
	@intWorkOrderId INT
	,@intUserId INT
	)
AS
BEGIN TRY
	DECLARE @strCostAdjustmentBatchId NVARCHAR(50)
		,@intLocationId INT
		,@intTransactionId INT
		,@strTransactionId NVARCHAR(50)
		,@GLEntries AS RecapTableType
		,@intManufacturingProcessId INT
		,@strCostDistribution NVARCHAR(50)
		,@ErrMsg NVARCHAR(MAX)
		,@intTransactionCount INT
		,@strAttributeValue NVARCHAR(50)
		,@strBatchId NVARCHAR(50)
		,@intBatchId INT
		,@strWorkOrderNo NVARCHAR(50)
		,@strAutoCycleCountOnWorkOrderClose NVARCHAR(50)
		,@unpostCostAdjustment AS ItemCostAdjustmentTableType
		,@strBatchIdForUnpost AS NVARCHAR(50)
		,@intReturnValue AS INT
		,@strErrorMessage AS NVARCHAR(4000)
		,@intInputItemId INT
		,@intProductionStageLocationId INT
		,@intProductionStagingId INT
		,@intConsumptionStorageLocationId INT
		,@intConsumptionSubLocationId INT
		,@ItemsToReserve AS dbo.ItemReservationTableType
		,@intInventoryTransactionType AS INT = 8
		,@strCycleCount nvarchar(50)

	SELECT @intManufacturingProcessId = intManufacturingProcessId
		,@strCostAdjustmentBatchId = strCostAdjustmentBatchId
		,@intLocationId = intLocationId
		,@strWorkOrderNo = strWorkOrderNo
	FROM tblMFWorkOrder
	WHERE intWorkOrderId = @intWorkOrderId

	SELECT @strAttributeValue = strAttributeValue
	FROM tblMFManufacturingProcessAttribute
	WHERE intManufacturingProcessId = @intManufacturingProcessId
		AND intAttributeId = 20 --Is Instant Consumption
		AND intLocationId = @intLocationId

	SELECT @strCostDistribution = strAttributeValue
	FROM tblMFManufacturingProcessAttribute
	WHERE intManufacturingProcessId = @intManufacturingProcessId
		AND intLocationId = @intLocationId
		AND intAttributeId = 107 --Cost Distribution during close work order

	IF @strCostDistribution IS NULL
		OR @strCostDistribution = ''
	BEGIN
		SELECT @strCostDistribution = 'False'
	END

	SELECT @strCycleCount = strAttributeValue
	FROM tblMFManufacturingProcessAttribute
	WHERE intManufacturingProcessId = @intManufacturingProcessId
		AND intAttributeId = 7 --Is Cycle Count Required
		AND intLocationId = @intLocationId

	IF @strCycleCount IS NULL
		OR @strCycleCount = ''
	BEGIN
		SELECT @strCycleCount = 'False'
	END

	SELECT @intTransactionCount = @@TRANCOUNT

	IF @intTransactionCount = 0
		BEGIN TRANSACTION

	UPDATE tblMFWorkOrder
	SET intStatusId = 10
		,intLastModifiedUserId = @intUserId
		,dtmLastModified = GETDATE()
	WHERE intWorkOrderId = @intWorkOrderId

	IF @strCostAdjustmentBatchId IS NOT NULL
		AND @strCostDistribution = 'True'
	BEGIN
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
			,@intEntityUserSecurityId = @intUserId
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
			,@AccountCategory_Cost_Adjustment = 'Work In Progress'

		-- Flag it as unposted. 
		UPDATE @GLEntries
		SET ysnIsUnposted = 1

		IF EXISTS (
				SELECT TOP 1 1
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
						,1
						,1
						,1
				END
				ELSE
				BEGIN
					EXEC dbo.uspGLBookEntries @GLEntries
						,1
				END
		END
	END

	IF @strAttributeValue = 'False' and @strCycleCount='False'--Is Instant Consumption
	BEGIN
		SELECT @strBatchId = NULL
			,@intBatchId = NULL

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
			,[intSourceEntityId]
			,intCommodityId
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

	SELECT @strAutoCycleCountOnWorkOrderClose = strAttributeValue
	FROM tblMFManufacturingProcessAttribute
	WHERE intManufacturingProcessId = @intManufacturingProcessId
		AND intLocationId = @intLocationId
		AND intAttributeId = 121 --Auto Cycle Count on Work Order Close

	IF @strAutoCycleCountOnWorkOrderClose IS NULL
		SELECT @strAutoCycleCountOnWorkOrderClose = 'False'

	IF @strAutoCycleCountOnWorkOrderClose = 'True'
	BEGIN
		EXEC uspMFUndoStartCycleCount @intWorkOrderId = @intWorkOrderId
			,@intUserId = @intUserId

		IF @strAttributeValue = 'False' --Is Instant Consumption
		BEGIN
			SELECT @intInputItemId = intItemId
			FROM tblMFWorkOrderInputLot
			WHERE intWorkOrderId = @intWorkOrderId

			IF @intInputItemId IS NOT NULL
			BEGIN
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
				Left JOIN tblICLot L ON L.intLotId = WI.intLotId
				WHERE intWorkOrderId = @intWorkOrderId
				GROUP BY WI.intItemId
					,IL.intItemLocationId
					,WI.intItemIssuedUOMId
					,L.strLotNumber

				EXEC dbo.uspICCreateStockReservation @ItemsToReserve
					,@intWorkOrderId
					,@intInventoryTransactionType
			END
		END
	END

	IF @intTransactionCount = 0
		COMMIT TRANSACTION
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	IF @intTransactionCount = 0
		ROLLBACK TRANSACTION

	RAISERROR (
			@ErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH
