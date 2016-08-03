CREATE PROCEDURE uspMFPostWorkOrder (@strXML NVARCHAR(MAX))
AS
BEGIN TRY
	DECLARE @idoc INT
		,@ErrMsg NVARCHAR(MAX)
		,@dblProduceQty NUMERIC(38, 20)
		,@intItemUOMId INT
		,@strRetBatchId NVARCHAR(40)
		,@intBatchId INT
		,@intWorkOrderId INT
		,@ysnNegativeQtyAllowed BIT
		,@intUserId INT
		,@dtmCurrentDateTime DATETIME
		,@intTransactionCount INT
		,@intAttributeId INT
		,@strYieldAdjustmentAllowed NVARCHAR(50)
		,@ysnExcessConsumptionAllowed INT
		,@intManufacturingProcessId INT
		,@intLocationId INT
		,@strInstantConsumption NVARCHAR(50)
		,@intSubLocationId INT
		,@intManufacturingCellId INT
		,@intItemId INT
		,@intCategoryId INT

	SELECT @intTransactionCount = @@TRANCOUNT

	SELECT @dtmCurrentDateTime = Getdate()

	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@strXML

	SELECT @intWorkOrderId = intWorkOrderId
		,@ysnNegativeQtyAllowed = ysnNegativeQtyAllowed
		,@intUserId = intUserId
	FROM OPENXML(@idoc, 'root', 2) WITH (
			intWorkOrderId INT
			,ysnNegativeQtyAllowed BIT
			,intUserId INT
			)

	SELECT @dblProduceQty = SUM(dblQuantity)
		,@intItemUOMId = MIN(intItemUOMId)
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

	IF @intTransactionCount = 0
		BEGIN TRANSACTION

	EXEC dbo.uspMFValidatePostWorkOrder @intWorkOrderId = @intWorkOrderId
		,@ysnYieldAdjustmentAllowed = @ysnNegativeQtyAllowed
		,@intUserId = @intUserId

	IF @dblProduceQty > 0
	BEGIN
		SELECT @intManufacturingProcessId = intManufacturingProcessId
			,@intLocationId = intLocationId
			,@intItemId = intItemId
			,@intManufacturingCellId = intManufacturingCellId
			,@intSubLocationId = intSubLocationId
		FROM dbo.tblMFWorkOrder
		WHERE intWorkOrderId = @intWorkOrderId

		SELECT @intAttributeId = intAttributeId
		FROM tblMFAttribute
		WHERE strAttributeName = 'Is Instant Consumption'

		SELECT @strInstantConsumption = strAttributeValue
		FROM tblMFManufacturingProcessAttribute
		WHERE intManufacturingProcessId = @intManufacturingProcessId
			AND intLocationId = @intLocationId
			AND intAttributeId = @intAttributeId

		IF @strInstantConsumption = 'False'
		BEGIN
			SELECT @intAttributeId = intAttributeId
			FROM tblMFAttribute
			WHERE strAttributeName = 'Is Yield Adjustment Allowed'

			SELECT @strYieldAdjustmentAllowed = strAttributeValue
			FROM tblMFManufacturingProcessAttribute
			WHERE intManufacturingProcessId = @intManufacturingProcessId
				AND intLocationId = @intLocationId
				AND intAttributeId = @intAttributeId

			SELECT @ysnExcessConsumptionAllowed = 0

			IF @strYieldAdjustmentAllowed = 'True'
			BEGIN
				SELECT @ysnExcessConsumptionAllowed = 1
			END

			SELECT @intCategoryId = intCategoryId
			FROM dbo.tblICItem
			WHERE intItemId = @intItemId

			EXEC dbo.uspMFGeneratePatternId @intCategoryId = @intCategoryId
				,@intItemId = @intItemId
				,@intManufacturingId = @intManufacturingCellId
				,@intSubLocationId = @intSubLocationId
				,@intLocationId = @intLocationId
				,@intOrderTypeId = NULL
				,@intBlendRequirementId = NULL
				,@intPatternCode = 33
				,@ysnProposed = 0
				,@strPatternString = @intBatchId OUTPUT

			EXEC dbo.uspMFPickWorkOrder @intWorkOrderId = @intWorkOrderId
				,@dblProduceQty = @dblProduceQty
				,@intProduceUOMId = @intItemUOMId
				,@intBatchId = @intBatchId
				,@intUserId = @intUserId
				,@strPickPreference = 'Substitute Item'
				,@ysnExcessConsumptionAllowed = @ysnExcessConsumptionAllowed
				,@dblUnitQty = NULL

			EXEC dbo.uspMFConsumeWorkOrder @intWorkOrderId = @intWorkOrderId
				,@dblProduceQty = @dblProduceQty
				,@intProduceUOMKey = @intItemUOMId
				,@intUserId = @intUserId
				,@ysnNegativeQtyAllowed = @ysnNegativeQtyAllowed
				,@strRetBatchId = @strRetBatchId OUTPUT
				,@ysnPostConsumption = 1
				,@intBatchId = @intBatchId

			EXEC uspMFConsumeSKU @intWorkOrderId = @intWorkOrderId

			DECLARE @GLEntries AS RecapTableType
			DECLARE @adjustedEntries AS ItemCostAdjustmentTableType
			DECLARE @STARTING_NUMBER_BATCH AS INT = 3
				,@strBatchId NVARCHAR(50)
				,@dblNewCost NUMERIC(38, 20)
				,@dblNewUnitCost NUMERIC(38, 20)
				,@intTransactionId INT
				,@userId INT
				,@intWorkOrderProducedLotId int
							, @dblOtherCost NUMERIC(18, 6)

			SELECT @dblOtherCost = 0

			SELECT @intTransactionId = intBatchId
				,@strBatchId = strBatchId
			FROM tblMFWorkOrderConsumedLot
			WHERE intWorkOrderId = @intWorkOrderId

			SELECT @dblNewCost = [dbo].[fnGetTotalStockValueFromTransactionBatch](@intTransactionId, @strBatchId)

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

				SELECT @dblOtherCost = @dblOtherCost + ISNULL([dbo].[fnGetTotalStockValueFromTransactionBatch](@intTransactionId, @strBatchId), 0)

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

			SET @dblNewCost = ABS(@dblNewCost)+ISNULL(@dblOtherCost,0)
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

			INSERT INTO @adjustedEntries (
				[intItemId]
				,[intItemLocationId]
				,[intItemUOMId]
				,[dtmDate]
				,[dblQty]
				,[dblUOMQty]
				,[intCostUOMId]
				,[dblVoucherCost]
				,[intCurrencyId]
				,[dblExchangeRate]
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
				)
			SELECT [intItemId] = PL.intItemId
				,[intItemLocationId] = L.intItemLocationId
				,[intItemUOMId] = PL.intItemUOMId
				,[dtmDate] = Isnull(PL.dtmProductionDate,@dtmCurrentDateTime)
				,[dblQty] = PL.dblQuantity
				,[dblUOMQty] = 1
				,[intCostUOMId]=PL.intItemUOMId
				,[dblNewCost] = @dblNewUnitCost
				,[intCurrencyId] = (
				SELECT TOP 1 intDefaultReportingCurrencyId
				FROM tblSMCompanyPreference
				)
				,[dblExchangeRate] = 0
				,[intTransactionId] = @intBatchId
				,[intTransactionDetailId] = PL.intWorkOrderProducedLotId
				,[strTransactionId] = W.strWorkOrderNo
				,[intTransactionTypeId] = 26
				,[intLotId] = PL.intLotId
				,[intSubLocationId] = SL.intSubLocationId
				,[intStorageLocationId] = PL.intStorageLocationId
				,[ysnIsStorage] = NULL
				,[strActualCostId] = NULL
				,[intSourceTransactionId] = intBatchId
				,[intSourceTransactionDetailId] = PL.intWorkOrderProducedLotId
				,[strSourceTransactionId] = strWorkOrderNo
			FROM dbo.tblMFWorkOrderProducedLot PL
			JOIN dbo.tblMFWorkOrder W ON W.intWorkOrderId = PL.intWorkOrderId
			JOIN tblICLot L ON L.intLotId = PL.intLotId
			JOIN tblICStorageLocation SL ON SL.intStorageLocationId = L.intStorageLocationId
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

			INSERT INTO @GLEntries
			EXEC uspICPostCostAdjustment @adjustedEntries
				,@strBatchId
				,@userId

			IF EXISTS (
					SELECT *
					FROM @GLEntries
					)
			BEGIN
				EXEC uspGLBookEntries @GLEntries
					,1
			END
		END
	END

	EXEC dbo.uspMFCalculateYield @intWorkOrderId = @intWorkOrderId
		,@ysnYieldAdjustmentAllowed = @ysnNegativeQtyAllowed
		,@intUserId = @intUserId

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
