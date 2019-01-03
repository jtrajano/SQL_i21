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

	SELECT @intManufacturingProcessId = intManufacturingProcessId
		,@strCostAdjustmentBatchId = strCostAdjustmentBatchId
		,@intLocationId = intLocationId
	FROM tblMFWorkOrder
	WHERE intWorkOrderId = @intWorkOrderId

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
		SELECT @intTransactionId = intTransactionId
			,@strTransactionId = strTransactionId
		FROM tblICInventoryTransaction
		WHERE strBatchId = @strCostAdjustmentBatchId

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
		EXEC dbo.uspICCreateGLEntriesOnCostAdjustment @strBatchId = @strCostAdjustmentBatchId
			,@intEntityUserSecurityId = @intUserId
			,@strGLDescription = ''
			,@ysnPost = 0
			,@AccountCategory_Cost_Adjustment = 'Work In Progress'

		IF EXISTS (
				SELECT *
				FROM @GLEntries
				)
		BEGIN
			EXEC dbo.uspGLBookEntries @GLEntries
				,0
		END
	END

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
