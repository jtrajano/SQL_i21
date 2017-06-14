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
		,@dblPhysicalCount DECIMAL(38, 24)
		,@intPhysicalItemUOMId INT
		,@str3rdPartyPalletsMandatory NVARCHAR(50)
		,@str3rdPartyPalletsItemId NVARCHAR(MAX)
		,@dblProduceQty1 DECIMAL(38, 24)
		,@dblPhysicalCount1 DECIMAL(38, 24)

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
		,@dblPhysicalCount = SUM(dblPhysicalCount)
		,@intPhysicalItemUOMId = MIN(intPhysicalItemUOMId)
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

		SELECT @str3rdPartyPalletsMandatory = strAttributeValue
		FROM tblMFManufacturingProcessAttribute
		WHERE intManufacturingProcessId = @intManufacturingProcessId
			AND intLocationId = @intLocationId
			AND intAttributeId = 87 --3rd Party Pallets (e.g. iGPS) - Mandatory

		SELECT @str3rdPartyPalletsItemId = strAttributeValue
		FROM tblMFManufacturingProcessAttribute
		WHERE intManufacturingProcessId = @intManufacturingProcessId
			AND intLocationId = @intLocationId
			AND intAttributeId = 88 --3rd Party Pallets (e.g. iGPS) Item Id

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

			IF EXISTS (
					SELECT *
					FROM tblMFWorkOrderRecipe
					WHERE intWorkOrderId = @intWorkOrderId
						AND intItemUOMId = @intItemUOMId
					)
			BEGIN
				IF EXISTS (
						SELECT *
						FROM dbo.tblMFWorkOrderProducedLot
						WHERE intWorkOrderId = @intWorkOrderId
							AND ysnProductionReversed = 0
							AND ysnFillPartialPallet = 1
						)
				BEGIN
					SELECT @dblProduceQty = NULL
						,@intItemUOMId = NULL
						,@dblProduceQty1 = NULL

					SELECT @dblProduceQty = SUM(dblQuantity)
						,@intItemUOMId = MIN(intItemUOMId)
					FROM dbo.tblMFWorkOrderProducedLot WP
					WHERE WP.intWorkOrderId = @intWorkOrderId
						AND WP.ysnProductionReversed = 0
						AND ysnFillPartialPallet = 0
						AND WP.intItemId IN (
							SELECT intItemId
							FROM dbo.tblMFWorkOrderRecipeItem
							WHERE intRecipeItemTypeId = 2
								AND ysnConsumptionRequired = 1
								AND intWorkOrderId = @intWorkOrderId
							)

					SELECT @dblProduceQty1 = SUM(dblQuantity)
					FROM dbo.tblMFWorkOrderProducedLot WP
					WHERE WP.intWorkOrderId = @intWorkOrderId
						AND WP.ysnProductionReversed = 0
						AND ysnFillPartialPallet = 1
						AND WP.intItemId IN (
							SELECT intItemId
							FROM dbo.tblMFWorkOrderRecipeItem
							WHERE intRecipeItemTypeId = 2
								AND ysnConsumptionRequired = 1
								AND intWorkOrderId = @intWorkOrderId
							)

					IF @dblProduceQty > 0
					BEGIN
						EXEC dbo.uspMFPickWorkOrder @intWorkOrderId = @intWorkOrderId
							,@dblProduceQty = @dblProduceQty
							,@intProduceUOMId = @intItemUOMId
							,@intBatchId = @intBatchId
							,@intUserId = @intUserId
							,@strPickPreference = 'Substitute Item'
							,@ysnExcessConsumptionAllowed = @ysnExcessConsumptionAllowed
							,@dblUnitQty = NULL
							,@dblProducePartialQty = @dblProduceQty1
					END
				END
				ELSE
				BEGIN
					EXEC dbo.uspMFPickWorkOrder @intWorkOrderId = @intWorkOrderId
						,@dblProduceQty = @dblProduceQty
						,@intProduceUOMId = @intItemUOMId
						,@intBatchId = @intBatchId
						,@intUserId = @intUserId
						,@strPickPreference = 'Substitute Item'
						,@ysnExcessConsumptionAllowed = @ysnExcessConsumptionAllowed
						,@dblUnitQty = NULL
						,@dblProducePartialQty = 0
				END

				EXEC dbo.uspMFConsumeWorkOrder @intWorkOrderId = @intWorkOrderId
					,@dblProduceQty = @dblProduceQty
					,@intProduceUOMKey = @intItemUOMId
					,@intUserId = @intUserId
					,@ysnNegativeQtyAllowed = @ysnNegativeQtyAllowed
					,@strRetBatchId = @strRetBatchId OUTPUT
					,@ysnPostConsumption = 1
					,@intBatchId = @intBatchId
					,@ysnPostGL = 0
			END
			ELSE
			BEGIN
				IF EXISTS (
						SELECT *
						FROM dbo.tblMFWorkOrderProducedLot
						WHERE intWorkOrderId = @intWorkOrderId
							AND ysnProductionReversed = 0
							AND ysnFillPartialPallet = 1
						)
				BEGIN
					SELECT @dblPhysicalCount = NULL
						,@intPhysicalItemUOMId = NULL
						,@dblPhysicalCount1 = NULL

					SELECT @dblPhysicalCount = SUM(dblPhysicalCount)
						,@intPhysicalItemUOMId = MIN(intPhysicalItemUOMId)
					FROM dbo.tblMFWorkOrderProducedLot WP
					WHERE WP.intWorkOrderId = @intWorkOrderId
						AND WP.ysnProductionReversed = 0
						AND ysnFillPartialPallet = 0
						AND WP.intItemId IN (
							SELECT intItemId
							FROM dbo.tblMFWorkOrderRecipeItem
							WHERE intRecipeItemTypeId = 2
								AND ysnConsumptionRequired = 1
								AND intWorkOrderId = @intWorkOrderId
							)

					SELECT @dblPhysicalCount1 = SUM(dblPhysicalCount)
					FROM dbo.tblMFWorkOrderProducedLot WP
					WHERE WP.intWorkOrderId = @intWorkOrderId
						AND WP.ysnProductionReversed = 0
						AND ysnFillPartialPallet = 1
						AND WP.intItemId IN (
							SELECT intItemId
							FROM dbo.tblMFWorkOrderRecipeItem
							WHERE intRecipeItemTypeId = 2
								AND ysnConsumptionRequired = 1
								AND intWorkOrderId = @intWorkOrderId
							)

					IF @dblPhysicalCount > 0
					BEGIN
						EXEC dbo.uspMFPickWorkOrder @intWorkOrderId = @intWorkOrderId
							,@dblProduceQty = @dblPhysicalCount
							,@intProduceUOMId = @intPhysicalItemUOMId
							,@intBatchId = @intBatchId
							,@intUserId = @intUserId
							,@strPickPreference = 'Substitute Item'
							,@ysnExcessConsumptionAllowed = @ysnExcessConsumptionAllowed
							,@dblUnitQty = NULL
							,@dblProducePartialQty = @dblPhysicalCount1
					END
				END
				ELSE
				BEGIN
					EXEC dbo.uspMFPickWorkOrder @intWorkOrderId = @intWorkOrderId
						,@dblProduceQty = @dblPhysicalCount
						,@intProduceUOMId = @intPhysicalItemUOMId
						,@intBatchId = @intBatchId
						,@intUserId = @intUserId
						,@strPickPreference = 'Substitute Item'
						,@ysnExcessConsumptionAllowed = @ysnExcessConsumptionAllowed
						,@dblUnitQty = NULL
						,@dblProducePartialQty = 0
				END

				EXEC dbo.uspMFConsumeWorkOrder @intWorkOrderId = @intWorkOrderId
					,@dblProduceQty = @dblPhysicalCount
					,@intProduceUOMKey = @intPhysicalItemUOMId
					,@intUserId = @intUserId
					,@ysnNegativeQtyAllowed = @ysnNegativeQtyAllowed
					,@strRetBatchId = @strRetBatchId OUTPUT
					,@ysnPostConsumption = 1
					,@intBatchId = @intBatchId
					,@ysnPostGL = 0
			END

			EXEC uspMFConsumeSKU @intWorkOrderId = @intWorkOrderId

			IF @str3rdPartyPalletsMandatory = 'False'
				AND @str3rdPartyPalletsItemId <> ''
			BEGIN
				DECLARE @intRecordId INT
					,@intLotId INT

				DECLARE @tblMFWorkOrderConsumedLot TABLE (
					intRecordId INT
					,intLotId INT
					)

				INSERT INTO @tblMFWorkOrderConsumedLot (intLotId)
				SELECT intLotId
				FROM tblMFWorkOrderConsumedLot
				WHERE intWorkOrderId = @intWorkOrderId
					AND intItemId IN (
									SELECT Item Collate Latin1_General_CI_AS
									FROM [dbo].[fnSplitString](@str3rdPartyPalletsItemId, ',')
									)

				SELECT @intRecordId = Min(intRecordId)
				FROM @tblMFWorkOrderConsumedLot

				WHILE @intRecordId IS NOT NULL
				BEGIN
					SELECT @intLotId = intLotId
					FROM @tblMFWorkOrderConsumedLot
					WHERE intRecordId = @intRecordId

					UPDATE tblMFWorkOrderProducedLot
					SET intSpecialPalletLotId = @intLotId
					WHERE intWorkOrderId = @intWorkOrderId
						AND intSpecialPalletLotId IS NULL

					SELECT @intRecordId = Min(intRecordId)
					FROM @tblMFWorkOrderConsumedLot
					WHERE intRecordId > @intRecordId
				END
			END
		END
	END

	EXEC dbo.uspMFCalculateYield @intWorkOrderId = @intWorkOrderId
		,@ysnYieldAdjustmentAllowed = @ysnNegativeQtyAllowed
		,@intUserId = @intUserId

	IF @dblProduceQty > 0
		AND @strInstantConsumption = 'False'
	BEGIN
		DECLARE @STARTING_NUMBER_BATCH AS INT = 3
			,@ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY AS NVARCHAR(255) = 'Work In Progress'
			,@INVENTORY_CONSUME AS INT = 8
			,@strBatchId AS NVARCHAR(40)
			,@GLEntries AS RecapTableType
			,@intTransactionId AS INT
			,@intCreatedEntityId AS INT
			,@strTransactionId NVARCHAR(50)
			,@ItemsForPost AS ItemCostingTableType
			,@dtmBusinessDate DATETIME
			,@intBusinessShiftId INT
			,@intYieldCostId INT
			,@strYieldCostValue NVARCHAR(50)

		SELECT @intYieldCostId = intAttributeId
		FROM tblMFAttribute
		WHERE strAttributeName = 'Add yield cost to output item'

		SELECT @strYieldCostValue = strAttributeValue
		FROM tblMFManufacturingProcessAttribute
		WHERE intManufacturingProcessId = @intManufacturingProcessId
			AND intLocationId = @intLocationId
			AND intAttributeId = @intYieldCostId

		SELECT @dtmBusinessDate = dbo.fnGetBusinessDate(@dtmCurrentDateTime, @intLocationId)

		SELECT @intBusinessShiftId = intShiftId
		FROM dbo.tblMFShift
		WHERE intLocationId = @intLocationId
			AND @dtmCurrentDateTime BETWEEN @dtmBusinessDate + dtmShiftStartTime + intStartOffset
				AND @dtmBusinessDate + dtmShiftEndTime + intEndOffset

		SELECT TOP 1 @strTransactionId = strWorkOrderNo
		FROM dbo.tblMFWorkOrder
		WHERE intWorkOrderId = @intWorkOrderId

		SELECT TOP 1 @intTransactionId = intBatchId
			,@strBatchId = strBatchId
		FROM dbo.tblMFWorkOrderConsumedLot
		WHERE intWorkOrderId = @intWorkOrderId

		IF @strYieldCostValue = 'True'
			--and exists(SELECT *
			--	FROM tblMFWorkOrderProducedLotTransaction PL
			--	WHERE intWorkOrderId = @intWorkOrderId
			--		AND PL.dblQuantity < 0)
		BEGIN
			INSERT INTO dbo.tblMFWorkOrderConsumedLot (
				intWorkOrderId
				,intItemId
				,intLotId
				,dblQuantity
				,intItemUOMId
				,dblIssuedQuantity
				,intItemIssuedUOMId
				,intBatchId
				,intSequenceNo
				,dtmCreated
				,intCreatedUserId
				,dtmLastModified
				,intLastModifiedUserId
				,intShiftId
				,dtmActualInputDateTime
				,intStorageLocationId
				,intSubLocationId
				,strBatchId
				)
			SELECT @intWorkOrderId
				,PL.intItemId
				,PL.intLotId
				,abs(PL.dblQuantity)
				,PL.intItemUOMId
				,abs(PL.dblQuantity)
				,PL.intItemUOMId
				,@intTransactionId
				,9999
				,@dtmCurrentDateTime
				,@intUserId
				,@dtmCurrentDateTime
				,@intUserId
				,@intBusinessShiftId
				,@dtmBusinessDate
				,L.intStorageLocationId
				,L.intSubLocationId
				,@strBatchId
			FROM tblMFWorkOrderProducedLotTransaction PL
			JOIN dbo.tblICLot L ON L.intLotId = PL.intLotId
			WHERE intWorkOrderId = @intWorkOrderId
				--AND PL.dblQuantity < 0

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
				,intItemUOMId = ISNULL(l.intWeightUOMId, l.intItemUOMId)
				,dtmDate = @dtmCurrentDateTime
				,dblQty = (- cl.dblQuantity)
				,dblUOMQty = ISNULL(WeightUOM.dblUnitQty, ItemUOM.dblUnitQty)
				,dblCost = l.dblLastCost
				,dblSalesPrice = 0
				,intCurrencyId = NULL
				,dblExchangeRate = 1
				,intTransactionId = @intTransactionId
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
		END

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
			,[dtmDate] = Isnull(PL.dtmProductionDate, @dtmCurrentDateTime)
			,[dblQty] = PL.dblQuantity
			,[dblUOMQty] = 1
			,[intCostUOMId] = PL.intItemUOMId
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
			)
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

		UPDATE tblMFWorkOrder
		SET strCostAdjustmentBatchId = @strBatchId
		WHERE intWorkOrderId = @intWorkOrderId
	END

	DELETE T
	FROM dbo.tblMFTask T
	JOIN dbo.tblMFOrderHeader OH ON OH.intOrderHeaderId = T.intOrderHeaderId
	JOIN dbo.tblMFStageWorkOrder SW ON SW.intOrderHeaderId = T.intOrderHeaderId
	WHERE SW.intWorkOrderId = @intWorkOrderId

	UPDATE OH
	SET intOrderStatusId = 10
	FROM dbo.tblMFOrderHeader OH
	JOIN dbo.tblMFStageWorkOrder SW ON SW.intOrderHeaderId = OH.intOrderHeaderId
	WHERE SW.intWorkOrderId = @intWorkOrderId

	Exec [dbo].[uspICPostStockReservation] @intTransactionId =@intWorkOrderId,@intTransactionTypeId=8,@ysnPosted=1

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
