CREATE PROCEDURE uspMFRepostCostAdjustment 
	@strCostAdjustmentBatchId AS NVARCHAR(50)
	,@intEntityUserSecurityId AS INT
	,@dtmDate AS DATETIME = NULL -- This is used to fix the stock rebuild.
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
		,@intWOItemUOMId INT
		,@intUnitMeasureId INT
		,@dtmProductionDate datetime
		,@dblInputCostRounded NUMERIC(38, 20)
		,@dblNewCostRounded NUMERIC(38, 20)

	DECLARE @tblMFConsumedLot TABLE (
		intWorkOrderConsumedLotId INT identity(1, 1)
		,intBatchId INT
		,strBatchId NVARCHAR(50)
		)
	DECLARE @ErrorMessage AS NVARCHAR(4000)
	DECLARE @intReturnValue AS INT
	DECLARE @unpostCostAdjustment AS ItemCostAdjustmentTableType
	DECLARE @strBatchIdForUnpost AS NVARCHAR(50)
		,@strBatchIdForRepost AS NVARCHAR(50)

	Select @strBatchIdForRepost=@strCostAdjustmentBatchId

	SELECT @intManufacturingProcessId = intManufacturingProcessId
		,@intWorkOrderId = intWorkOrderId
		,@strWorkOrderNo = strWorkOrderNo
		,@intLocationId = intLocationId
		,@intWOItemUOMId = intItemUOMId
	FROM tblMFWorkOrder
	WHERE strCostAdjustmentBatchId = @strCostAdjustmentBatchId

	SELECT @intUnitMeasureId = intUnitMeasureId
	FROM tblICItemUOM
	WHERE intItemUOMId = @intWOItemUOMId

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

		SELECT @dblInputCost = SUM([dbo].[fnMFGetTotalStockValueFromTransactionBatch](DT.intBatchId, DT.strBatchId))
		FROM (
			SELECT DISTINCT intBatchId
				,strBatchId
			FROM tblMFWorkOrderConsumedLot
			WHERE intWorkOrderId = @intWorkOrderId
			) AS DT

		SELECT @dblInputCostRounded = SUM([dbo].[fnGetTotalStockValueFromTransactionBatch](DT.intBatchId, DT.strBatchId))
		FROM (
			SELECT DISTINCT intBatchId
				,strBatchId
			FROM tblMFWorkOrderConsumedLot
			WHERE intWorkOrderId = @intWorkOrderId
			) AS DT

	END
	ELSE
	BEGIN
		SELECT @dblInputCost = 0, @dblInputCostRounded = 0 

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
			SELECT @dblInputCostRounded = @dblInputCostRounded + ISNULL([dbo].[fnGetTotalStockValueFromTransactionBatch](@intTransactionId, @strConsumeBatchId), 0)

			SELECT @dblValue = SUM(CAST(dbo.fnMultiply(A.dblQty, A.dblCost) + ISNULL(A.dblValue, 0) AS NUMERIC(18, 6)))
				,@dblInputCostRounded = @dblInputCostRounded + ISNULL(SUM(ROUND(dbo.fnMultiply(A.dblQty, A.dblCost) + ISNULL(A.dblValue, 0), 2)) ,0)
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

	-- Get the other charges
	SELECT @dblOtherCharges = SUM(dblOtherCharges)
	FROM tblMFWorkOrderProducedLot
	WHERE intWorkOrderId = @intWorkOrderId
		AND ysnProductionReversed = 0

	-- Get the produced qty
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

	-- Compute the Cost Adjustment value
	SET @dblNewCost = ABS(@dblInputCost) + ISNULL(@dblOtherCharges, 0)
	SET @dblNewCostRounded = ABS(@dblInputCostRounded) + ISNULL(@dblOtherCharges, 0)
	SET @dblNewUnitCost = ABS(@dblInputCost) / @dblProduceQty

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

	SELECT @dtmCurrentDateTime = Max(dtmProductionDate)
	FROM tblMFWorkOrderInputLot
	WHERE intWorkOrderId = @intWorkOrderId
		AND ysnConsumptionReversed = 0

	IF @dtmCurrentDateTime IS NULL
	BEGIN
		SELECT @dtmCurrentDateTime = Max(dtmProductionDate)
		FROM tblMFWorkOrderProducedLot
		WHERE intWorkOrderId = @intWorkOrderId
			AND ysnProductionReversed = 0

		IF @dtmCurrentDateTime IS NULL
			SELECT @dtmCurrentDateTime = Getdate()
	END
	ELSE
	BEGIN
		SELECT @dtmProductionDate = Max(dtmProductionDate)
		FROM tblMFWorkOrderProducedLot
		WHERE intWorkOrderId = @intWorkOrderId
			AND ysnProductionReversed = 0

		IF @dtmProductionDate IS not NULL
		BEGIN
			IF @dtmProductionDate > @dtmCurrentDateTime
				SELECT @dtmCurrentDateTime = @dtmProductionDate
		END

		SELECT @dtmProductionDate = Max(dtmActualInputDateTime)
		FROM tblMFWorkOrderConsumedLot
		WHERE intWorkOrderId = @intWorkOrderId

		IF @dtmProductionDate IS not NULL
		BEGIN
			IF @dtmProductionDate > @dtmCurrentDateTime
				SELECT @dtmCurrentDateTime = @dtmProductionDate
		END
	END

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
		,dblVoucherCost
		)
	SELECT [intItemId] = PL.intItemId
		,[intItemLocationId] = isNULL(L.intItemLocationId, (
				SELECT IL.intItemLocationId
				FROM tblICItemLocation IL
				WHERE IL.intItemId = PL.intItemId
					AND IL.intLocationId = @intLocationId
				))
		,[intItemUOMId] = PL.intItemUOMId
		,[dtmDate] = COALESCE(@dtmDate, @dtmCurrentDateTime, W.dtmPostDate, W.dtmCompletedDate) --IsNull(Isnull(@dtmCurrentDateTime,W.dtmPostDate), W.dtmCompletedDate)
		,[dblQty] = 0
		,[dblUOMQty] = 1
		,[intCostUOMId] = PL.intItemUOMId
		,[dblNewValue] = Round(CASE 
				WHEN @strInstantConsumption = 'False'
					THEN (
							CASE 
								WHEN IsNULL(RI.dblPercentage, 0) = 0
									THEN @dblNewUnitCost * dbo.fnMFConvertQuantityToTargetItemUOM(PL.intItemUOMId, IsNULL(IU.intItemUOMId, PL.intItemUOMId), PL.dblQuantity)
								ELSE ((@dblNewCost * RI.dblPercentage / 100 / SUM(dbo.fnMFConvertQuantityToTargetItemUOM(PL.intItemUOMId, IsNULL(IU.intItemUOMId, PL.intItemUOMId), PL.dblQuantity)) OVER (PARTITION BY PL.intItemId)) * dbo.fnMFConvertQuantityToTargetItemUOM(PL.intItemUOMId, IsNULL(IU.intItemUOMId, PL.intItemUOMId), PL.dblQuantity))
								END
							)
				ELSE (@dblNewUnitCost * @dblProduceQty * RI.dblPercentage / 100) - (IsNULL(PL.dblOtherCharges, 0) + ABS(ISNULL([dbo].[fnMFGetTotalStockValueFromTransactionBatch](PL.intBatchId, PL.strBatchId), 0)))
				END, 2)
		,[intCurrencyId] = (
			SELECT TOP 1 intDefaultReportingCurrencyId
			FROM tblSMCompanyPreference
			)
		--,[dblExchangeRate] = 0
		,[intTransactionId] = @intBatchId
		,[intTransactionDetailId] = PL.intWorkOrderProducedLotId
		,[strTransactionId] = W.strWorkOrderNo
		,[intTransactionTypeId] = 9
		,[intLotId] = IsNULL(PL.intProducedLotId, PL.intLotId)
		,[intSubLocationId] = IsNULL(L.intSubLocationId,SL.intSubLocationId)
		,[intStorageLocationId] =IsNULL(L.intStorageLocationId,PL.intStorageLocationId)
		,[ysnIsStorage] = NULL
		,[strActualCostId] = NULL
		,[intSourceTransactionId] = intBatchId
		,[intSourceTransactionDetailId] = PL.intWorkOrderProducedLotId
		,[strSourceTransactionId] = strWorkOrderNo
		,intFobPointId = 2
		,dblVoucherCost = 0
	FROM dbo.tblMFWorkOrderProducedLot PL
	JOIN dbo.tblMFWorkOrder W ON W.intWorkOrderId = PL.intWorkOrderId
	LEFT JOIN dbo.tblICItemUOM IU ON IU.intItemId = PL.intItemId
		AND IU.intUnitMeasureId = @intUnitMeasureId
	LEFT JOIN tblICLot L ON L.intLotId = PL.intProducedLotId
	LEFT JOIN tblICStorageLocation SL ON SL.intStorageLocationId = PL.intStorageLocationId
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

	DELETE
	FROM @GLEntries

	-- Check for discrepancy. 
	-- If found, apply the discrepancy towards cost adjustment with the highest value. 
	BEGIN 
		DECLARE @discrepancy AS NUMERIC(18,6)
				,@totalAdj AS NUMERIC(18, 6)		
		
		SELECT @totalAdj = SUM(adj.dblNewValue) 
		FROM @adjustedEntries adj

		IF	ISNULL(@totalAdj, 0) <> 0
			AND ISNULL(@dblNewCostRounded, 0) <> 0 
			AND @totalAdj <> @dblNewCostRounded
		BEGIN 
			WITH UpdateTopAdjustment AS (
				SELECT TOP 1 adj.* 
				FROM @adjustedEntries adj
				ORDER BY adj.dblNewValue DESC 				
			)
			UPDATE UpdateTopAdjustment
			SET dblNewValue = dblNewValue + (@dblNewCostRounded - @totalAdj) 
		END
	END 

	SELECT @intTransactionCount = @@TRANCOUNT

	IF @intTransactionCount = 0
		BEGIN TRANSACTION

	IF EXISTS (
			SELECT TOP 1 1
			FROM @adjustedEntries
			)
	BEGIN
		---- Get a new batch id to repost the cost adjustment. 
		--EXEC uspSMGetStartingNumber 3
		--	,@strBatchIdForRepost OUT

		SET @intReturnValue = 0

		EXEC @intReturnValue = uspICPostCostAdjustment 
			@adjustedEntries
			,@strBatchIdForRepost
			,@userId

		IF @intReturnValue <> 0
		BEGIN
			SELECT TOP 1 @ErrorMessage = strMessage
			FROM tblICPostResult
			WHERE strBatchNumber = @strBatchIdForRepost

			RAISERROR (
					@ErrorMessage
					,11
					,1
					);
		END
		ELSE
		BEGIN
			UPDATE tblMFWorkOrder
			SET strCostAdjustmentBatchId = @strBatchIdForRepost
			WHERE intWorkOrderId = @intWorkOrderId

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
				,intSourceEntityId
				,intCommodityId
				)
			EXEC dbo.uspICCreateGLEntriesOnCostAdjustment 
				@strBatchId = @strBatchIdForRepost
				,@intEntityUserSecurityId = @userId
				,@AccountCategory_Cost_Adjustment = 'Work In Progress'
		END

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
				END
				ELSE
				BEGIN
					EXEC dbo.uspGLBookEntries @GLEntries
						,1
				END
		END
	END
	ELSE 
	BEGIN 			
		-- 'Cost adjustment for {Batch Id} is missing. Stock rebuild will abort.'
		EXEC uspICRaiseError 80265, @strCostAdjustmentBatchId; 	
	END 

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

	RETURN -1; 
END CATCH
