CREATE PROCEDURE uspMFRepostCostAdjustment @strCostAdjustmentBatchId AS NVARCHAR(50)
	,@intEntityUserSecurityId AS INT
AS
BEGIN TRY
	DECLARE @adjustedEntries AS ItemCostAdjustmentTableType
	DECLARE @dblNewCost NUMERIC(38, 20)
		,@dblNewUnitCost NUMERIC(38, 20)
		,@userId INT
		,@intWorkOrderProducedLotId INT
		,@dblOtherCost NUMERIC(18, 6)
		,@intWorkOrderId INT
		,@dblOtherCharges NUMERIC(18, 6)
		,@dblProduceQty NUMERIC(38, 20)
		,@intLocationId INT
		,@intBatchId INT
		,@dtmCurrentDateTime DATETIME
		,@STARTING_NUMBER_BATCH AS INT = 3
		,@GLEntries AS RecapTableType
		,@intTransactionCount INT
		,@ErrMsg NVARCHAR(MAX)
		,@strWorkOrderNo NVARCHAR(50)
		,@intManufacturingProcessId INT
		,@intTransactionId INT
		,@strConsumeBatchId NVARCHAR(50)
		,@strInstantConsumption NVARCHAR(50)
		,@intAttributeId INT
		,@intWorkOrderConsumedLotId INT
		,@dblInputCost NUMERIC(38, 20)
		,@dblValue NUMERIC(38, 20)
		,@strBatchId NVARCHAR(50)
	DECLARE @tblMFConsumedLot TABLE (
		intWorkOrderConsumedLotId INT identity(1, 1)
		,intBatchId INT
		,strBatchId NVARCHAR(50)
		)

	SELECT @intManufacturingProcessId = intManufacturingProcessId
		,@intWorkOrderId = intWorkOrderId
		,@strWorkOrderNo = strWorkOrderNo
		,@intLocationId = intLocationId
	FROM tblMFWorkOrder
	WHERE strCostAdjustmentBatchId = @strCostAdjustmentBatchId

	SELECT @intAttributeId = intAttributeId
	FROM tblMFAttribute
	WHERE strAttributeName = 'Is Instant Consumption'

	SELECT @strInstantConsumption = strAttributeValue
	FROM tblMFManufacturingProcessAttribute
	WHERE intManufacturingProcessId = @intManufacturingProcessId
		AND intLocationId = @intLocationId
		AND intAttributeId = @intAttributeId

	IF @strInstantConsumption IS NULL
	BEGIN
		SELECT @strInstantConsumption = 'False'
	END

	SELECT @dblOtherCost = 0

	IF @strInstantConsumption = 'False'
	BEGIN
		SELECT @intTransactionId = intBatchId
			,@strConsumeBatchId = strBatchId
		FROM tblMFWorkOrderConsumedLot
		WHERE intWorkOrderId = @intWorkOrderId

		SELECT @dblInputCost = [dbo].[fnMFGetTotalStockValueFromTransactionBatch](@intTransactionId, @strConsumeBatchId)
	END
	ELSE
	BEGIN
		SELECT @dblInputCost = 0

		INSERT INTO @tblMFConsumedLot (
			intBatchId
			,strBatchId
			)
		SELECT DISTINCT intBatchId
			,strBatchId
		FROM tblMFWorkOrderConsumedLot
		WHERE intWorkOrderId = @intWorkOrderId
			AND IsNULL(ysnConsumptionReversed, 0) = 0

		SELECT @intWorkOrderConsumedLotId = MIN(intWorkOrderConsumedLotId)
		FROM @tblMFConsumedLot WC

		WHILE @intWorkOrderConsumedLotId IS NOT NULL
		BEGIN
			SELECT @intTransactionId = NULL
				,@strConsumeBatchId = NULL
				,@dblValue = NULL

			SELECT @intTransactionId = CL.intBatchId
				,@strConsumeBatchId = CL.strBatchId
			FROM @tblMFConsumedLot CL
			WHERE intWorkOrderConsumedLotId = @intWorkOrderConsumedLotId

			SELECT @dblInputCost = @dblInputCost + ISNULL([dbo].[fnMFGetTotalStockValueFromTransactionBatch](@intTransactionId, @strConsumeBatchId), 0)

			SELECT @dblValue = SUM(CAST(dbo.fnMultiply(A.dblQty, A.dblCost) + ISNULL(A.dblValue, 0) AS NUMERIC(18, 6)))
			FROM [dbo].[tblICInventoryTransaction] A
			WHERE A.intTransactionId = @intTransactionId
				AND A.strTransactionId = @strConsumeBatchId
				AND A.intTransactionTypeId = 8

			SELECT @dblInputCost = @dblInputCost + ISNULL(@dblValue, 0)

			SELECT @intWorkOrderConsumedLotId = MIN(intWorkOrderConsumedLotId)
			FROM @tblMFConsumedLot CL
			WHERE intWorkOrderConsumedLotId > @intWorkOrderConsumedLotId
		END
	END

	SELECT @dblOtherCharges = SUM(dblOtherCharges)
	FROM tblMFWorkOrderProducedLot
	WHERE intWorkOrderId = @intWorkOrderId
		AND ysnProductionReversed = 0

	IF @dblOtherCharges IS NOT NULL
	BEGIN
		SELECT @dblInputCost = abs(@dblInputCost) + @dblOtherCharges
	END

	SELECT @dblProduceQty = SUM(dblQuantity)
	FROM dbo.tblMFWorkOrderProducedLot WP
	WHERE WP.intWorkOrderId = @intWorkOrderId
		AND WP.ysnProductionReversed = 0
		AND WP.intItemId IN (
			SELECT intItemId
			FROM dbo.tblMFWorkOrderRecipeItem
			WHERE intRecipeItemTypeId = 2
				AND ysnConsumptionRequired = 1
				AND intWorkOrderId = @intWorkOrderId
			)

	SET @dblNewUnitCost = abs(@dblInputCost) / @dblProduceQty

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

	INSERT INTO @adjustedEntries (
		[intItemId]
		,[intItemLocationId]
		,[intItemUOMId]
		,[dtmDate]
		,[dblQty]
		,[dblUOMQty]
		,[intCostUOMId]
		,[dblNewValue]
		,[intCurrencyId]
		--,[dblExchangeRate]
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
		)
	SELECT [intItemId] = PL.intItemId
		,[intItemLocationId] = L.intItemLocationId
		,[intItemUOMId] = PL.intItemUOMId
		,[dtmDate] = Isnull(PL.dtmProductionDate, @dtmCurrentDateTime)
		,[dblQty] = PL.dblQuantity
		,[dblUOMQty] = 1
		,[intCostUOMId] = PL.intItemUOMId
		,[dblNewCost] = CASE 
			WHEN @strInstantConsumption = 'False'
				THEN (
						CASE 
							WHEN IsNULL(RI.dblPercentage, 0) = 0
								THEN @dblNewUnitCost * PL.dblQuantity
							ELSE (@dblNewUnitCost * @dblProduceQty * RI.dblPercentage / 100)
							END
						)
			ELSE (@dblNewUnitCost * @dblProduceQty * RI.dblPercentage / 100) - (IsNULL(PL.dblOtherCharges, 0) + ABS(ISNULL([dbo].[fnMFGetTotalStockValueFromTransactionBatch](PL.intBatchId, PL.strBatchId), 0)))
			END
		,[intCurrencyId] = (
			SELECT TOP 1 intDefaultReportingCurrencyId
			FROM tblSMCompanyPreference
			)
		--,[dblExchangeRate] = 0
		,[intTransactionId] = @intBatchId
		,[intTransactionDetailId] = PL.intWorkOrderProducedLotId
		,[strTransactionId] = W.strWorkOrderNo
		,[intTransactionTypeId] = 9
		,[intLotId] = PL.intLotId
		,[intSubLocationId] = SL.intSubLocationId
		,[intStorageLocationId] = PL.intStorageLocationId
		,[ysnIsStorage] = NULL
		,[strActualCostId] = NULL
		,[intSourceTransactionId] = intBatchId
		,[intSourceTransactionDetailId] = PL.intWorkOrderProducedLotId
		,[strSourceTransactionId] = strWorkOrderNo
		,intFobPointId = 2
	FROM dbo.tblMFWorkOrderProducedLot PL
	JOIN dbo.tblMFWorkOrder W ON W.intWorkOrderId = PL.intWorkOrderId
	JOIN tblICLot L ON L.intLotId = PL.intLotId
	JOIN tblICStorageLocation SL ON SL.intStorageLocationId = L.intStorageLocationId
	LEFT JOIN tblMFWorkOrderRecipeItem RI ON RI.intWorkOrderId = W.intWorkOrderId
		AND RI.intItemId = PL.intItemId
		AND RI.intRecipeItemTypeId = 2
	WHERE PL.intWorkOrderId = @intWorkOrderId
		AND PL.ysnProductionReversed = 0
		AND PL.intItemId IN (
			SELECT intItemId
			FROM dbo.tblMFWorkOrderRecipeItem
			WHERE intRecipeItemTypeId = 2
				AND ysnConsumptionRequired = 1
				AND intWorkOrderId = @intWorkOrderId
			)

	-- Get the next batch number
	EXEC dbo.uspSMGetStartingNumber @STARTING_NUMBER_BATCH
		,@strBatchId OUTPUT

	DELETE
	FROM @GLEntries

	SELECT @intTransactionCount = @@TRANCOUNT

	IF @intTransactionCount = 0
		BEGIN TRANSACTION

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
		,@intEntityUserSecurityId = @intEntityUserSecurityId
		,@strGLDescription = ''
		,@ysnPost = 0
		,@AccountCategory_Cost_Adjustment = 'Work In Progress'

	IF EXISTS (
			SELECT TOP 1 1
			FROM @GLEntries
			)
	BEGIN
		EXEC uspGLBookEntries @GLEntries
			,1
	END

	IF EXISTS (
			SELECT TOP 1 1
			FROM @adjustedEntries
			)
	BEGIN
		DECLARE @intReturnValue AS INT

		EXEC @intReturnValue = uspICPostCostAdjustment @adjustedEntries
			,@strBatchId
			,@userId

		IF @intReturnValue <> 0
		BEGIN
			DECLARE @ErrorMessage AS NVARCHAR(4000)

			SELECT TOP 1 @ErrorMessage = strMessage
			FROM tblICPostResult
			WHERE strBatchNumber = @strBatchId

			RAISERROR (
					@ErrorMessage
					,11
					,1
					);
		END
		ELSE
		BEGIN
			DELETE
			FROM @GLEntries

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
			EXEC dbo.uspICCreateGLEntriesOnCostAdjustment @strBatchId = @strBatchId
				,@intEntityUserSecurityId = @userId
				,@AccountCategory_Cost_Adjustment = 'Work In Progress'
		END

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
	SET strCostAdjustmentBatchId = @strBatchId
	WHERE intWorkOrderId = @intWorkOrderId

	IF @intTransactionCount = 0
		COMMIT TRANSACTION
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	IF XACT_STATE() != 0
		AND @intTransactionCount = 0
		ROLLBACK TRANSACTION

	RAISERROR (
			@ErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH
