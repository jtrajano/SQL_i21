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
		,@intItemUOMId1 INT
		,@intPhysicalItemUOMId1 INT
		,@intYieldCostId INT
		,@strYieldCostValue NVARCHAR(50)
		,@ysnPostGL BIT
		,@dblOtherCharges NUMERIC(18, 6)

	SELECT @ysnPostGL = 0

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

	SELECT @intYieldCostId = intAttributeId
	FROM tblMFAttribute
	WHERE strAttributeName = 'Add yield cost to output item'

	SELECT @strYieldCostValue = strAttributeValue
	FROM tblMFManufacturingProcessAttribute
	WHERE intManufacturingProcessId = @intManufacturingProcessId
		AND intLocationId = @intLocationId
		AND intAttributeId = @intYieldCostId

	IF @strYieldCostValue = 'False'
		OR @strYieldCostValue IS NULL
		OR @strYieldCostValue = ''
	BEGIN
		SELECT @ysnPostGL = 1
	END

	IF @dblProduceQty > 0
		AND @strInstantConsumption = 'False'
	BEGIN
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

			DECLARE @tblMFMachine TABLE (intMachineId INT)
			DECLARE @intMachineId INT

			INSERT INTO @tblMFMachine (intMachineId)
			SELECT DISTINCT intMachineId
			FROM tblMFWorkOrderProducedLot
			WHERE intWorkOrderId = @intWorkOrderId
				AND ysnProductionReversed = 0

			SELECT @intMachineId = MIN(intMachineId)
			FROM @tblMFMachine

			WHILE @intMachineId IS NOT NULL
			BEGIN
				SELECT @dblProduceQty = SUM(dblQuantity)
					,@intItemUOMId = MIN(intItemUOMId)
					,@dblPhysicalCount = SUM(dblPhysicalCount)
					,@intPhysicalItemUOMId = MIN(intPhysicalItemUOMId)
				FROM dbo.tblMFWorkOrderProducedLot WP
				WHERE WP.intWorkOrderId = @intWorkOrderId
					AND WP.ysnProductionReversed = 0
					AND intMachineId = @intMachineId
					AND WP.intItemId IN (
						SELECT intItemId
						FROM dbo.tblMFWorkOrderRecipeItem
						WHERE intRecipeItemTypeId = 2
							AND ysnConsumptionRequired = 1
							AND intWorkOrderId = @intWorkOrderId
						)

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
								AND intMachineId = @intMachineId
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
							AND WP.intMachineId = @intMachineId
							AND WP.intItemId IN (
								SELECT intItemId
								FROM dbo.tblMFWorkOrderRecipeItem
								WHERE intRecipeItemTypeId = 2
									AND ysnConsumptionRequired = 1
									AND intWorkOrderId = @intWorkOrderId
								)

						IF @dblProduceQty IS NULL
							SELECT @dblProduceQty = 0

						SELECT @dblProduceQty1 = SUM(dblQuantity)
							,@intItemUOMId1 = MIN(intItemUOMId)
						FROM dbo.tblMFWorkOrderProducedLot WP
						WHERE WP.intWorkOrderId = @intWorkOrderId
							AND WP.ysnProductionReversed = 0
							AND ysnFillPartialPallet = 1
							AND WP.intMachineId = @intMachineId
							AND WP.intItemId IN (
								SELECT intItemId
								FROM dbo.tblMFWorkOrderRecipeItem
								WHERE intRecipeItemTypeId = 2
									AND ysnConsumptionRequired = 1
									AND intWorkOrderId = @intWorkOrderId
								)

						IF @intItemUOMId IS NULL
							SELECT @intItemUOMId = @intItemUOMId1

						IF @dblProduceQty >= 0
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
								,@intMachineId = @intMachineId
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
							,@intMachineId = @intMachineId
					END

					EXEC dbo.uspMFConsumeWorkOrder @intWorkOrderId = @intWorkOrderId
						,@dblProduceQty = @dblProduceQty
						,@intProduceUOMKey = @intItemUOMId
						,@intUserId = @intUserId
						,@ysnNegativeQtyAllowed = @ysnNegativeQtyAllowed
						,@strRetBatchId = @strRetBatchId OUTPUT
						,@ysnPostConsumption = 1
						,@intBatchId = @intBatchId
						,@ysnPostGL = @ysnPostGL
						,@dtmDate=@dtmCurrentDateTime
				END
				ELSE
				BEGIN
					IF EXISTS (
							SELECT *
							FROM dbo.tblMFWorkOrderProducedLot
							WHERE intWorkOrderId = @intWorkOrderId
								AND ysnProductionReversed = 0
								AND ysnFillPartialPallet = 1
								AND intMachineId = @intMachineId
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
							AND WP.intMachineId = @intMachineId
							AND WP.intItemId IN (
								SELECT intItemId
								FROM dbo.tblMFWorkOrderRecipeItem
								WHERE intRecipeItemTypeId = 2
									AND ysnConsumptionRequired = 1
									AND intWorkOrderId = @intWorkOrderId
								)

						IF @dblPhysicalCount IS NULL
							SELECT @dblPhysicalCount = 0

						SELECT @dblPhysicalCount1 = SUM(dblPhysicalCount)
							,@intPhysicalItemUOMId1 = MIN(intPhysicalItemUOMId)
						FROM dbo.tblMFWorkOrderProducedLot WP
						WHERE WP.intWorkOrderId = @intWorkOrderId
							AND WP.ysnProductionReversed = 0
							AND ysnFillPartialPallet = 1
							AND WP.intMachineId = @intMachineId
							AND WP.intItemId IN (
								SELECT intItemId
								FROM dbo.tblMFWorkOrderRecipeItem
								WHERE intRecipeItemTypeId = 2
									AND ysnConsumptionRequired = 1
									AND intWorkOrderId = @intWorkOrderId
								)

						IF @intPhysicalItemUOMId IS NULL
							SELECT @intPhysicalItemUOMId = @intPhysicalItemUOMId1

						IF @dblPhysicalCount >= 0
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
								,@intMachineId = @intMachineId
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
							,@intMachineId = @intMachineId
					END

					EXEC dbo.uspMFConsumeWorkOrder @intWorkOrderId = @intWorkOrderId
						,@dblProduceQty = @dblPhysicalCount
						,@intProduceUOMKey = @intPhysicalItemUOMId
						,@intUserId = @intUserId
						,@ysnNegativeQtyAllowed = @ysnNegativeQtyAllowed
						,@strRetBatchId = @strRetBatchId OUTPUT
						,@ysnPostConsumption = 1
						,@intBatchId = @intBatchId
						,@ysnPostGL = @ysnPostGL
						,@dtmDate=@dtmCurrentDateTime
				END

				SELECT @intMachineId = MIN(intMachineId)
				FROM @tblMFMachine
				WHERE intMachineId > @intMachineId
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
		--,@strBatchId = strBatchId
		FROM dbo.tblMFWorkOrderConsumedLot
		WHERE intWorkOrderId = @intWorkOrderId

		EXEC dbo.uspSMGetStartingNumber @STARTING_NUMBER_BATCH
			,@strBatchId OUTPUT

		IF @strYieldCostValue = 'True'
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
				,PL.dblQuantity
				,PL.intItemUOMId
				,PL.dblQuantity
				,PL.intItemUOMId
				,IsNULL(PL.intBatchId, @intTransactionId)
				,9999
				,@dtmCurrentDateTime
				,@intUserId
				,@dtmCurrentDateTime
				,@intUserId
				,@intBusinessShiftId
				,@dtmBusinessDate
				,L.intStorageLocationId
				,L.intSubLocationId
				,IsNULL(WP.strBatchId, @strBatchId)
			FROM tblMFWorkOrderProducedLotTransaction PL
			JOIN dbo.tblICLot L ON L.intLotId = PL.intLotId
			LEFT JOIN tblMFWorkOrderProducedLot WP ON WP.intBatchId = PL.intBatchId
				AND WP.intWorkOrderId = PL.intWorkOrderId
			WHERE PL.intWorkOrderId = @intWorkOrderId

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
				,dblQty = (- cl.dblQuantity)
				,dblUOMQty = l.dblWeightPerQty
				,dblCost = l.dblLastCost
				,dblSalesPrice = 0
				,intCurrencyId = NULL
				,dblExchangeRate = 1
				,intTransactionId = cl.intBatchId
				,intTransactionDetailId = cl.intWorkOrderConsumedLotId
				,strTransactionId = cl.strBatchId
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

			IF EXISTS (
					SELECT *
					FROM @GLEntries
					)
			BEGIN
				EXEC dbo.uspGLBookEntries @GLEntries
					,1
			END
		END

		DECLARE @adjustedEntries AS ItemCostAdjustmentTableType
		DECLARE @dblNewCost NUMERIC(38, 20)
			,@dblNewUnitCost NUMERIC(38, 20)
			,@userId INT
			,@intWorkOrderProducedLotId INT
			,@dblOtherCost NUMERIC(18, 6)
		DECLARE @strCostingByCoEfficient NVARCHAR(50)

		SELECT @strCostingByCoEfficient = strAttributeValue
		FROM tblMFManufacturingProcessAttribute
		WHERE intManufacturingProcessId = @intManufacturingProcessId
			AND intLocationId = @intLocationId
			AND intAttributeId = 111

		IF @strCostingByCoEfficient IS NULL
		BEGIN
			SELECT @strCostingByCoEfficient = 'False'
		END

		IF @strCostingByCoEfficient = 'False'
		BEGIN
			SELECT @dblOtherCost = 0

			SELECT @intTransactionId = intBatchId
				,@strBatchId = strBatchId
			FROM tblMFWorkOrderConsumedLot
			WHERE intWorkOrderId = @intWorkOrderId

			SELECT @dblNewCost = [dbo].[fnMFGetTotalStockValueFromTransactionBatch](@intTransactionId, @strBatchId)

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
					WHEN IsNULL(RI.dblPercentage, 0) = 0
						THEN @dblNewUnitCost * PL.dblQuantity
					ELSE (@dblNewUnitCost * RI.dblPercentage / 100) * PL.dblQuantity
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
				,[intSubLocationId] = L.intSubLocationId
				,[intStorageLocationId] = L.intStorageLocationId
				,[ysnIsStorage] = NULL
				,[strActualCostId] = NULL
				,[intSourceTransactionId] = intBatchId
				,[intSourceTransactionDetailId] = PL.intWorkOrderProducedLotId
				,[strSourceTransactionId] = strWorkOrderNo
				,intFobPointId = 2
			FROM dbo.tblMFWorkOrderProducedLot PL
			JOIN dbo.tblMFWorkOrder W ON W.intWorkOrderId = PL.intWorkOrderId
			JOIN tblICLot L ON L.intLotId = PL.intProducedLotId
			--JOIN tblICStorageLocation SL ON SL.intStorageLocationId = L.intStorageLocationId
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
		END
		ELSE
		BEGIN
			SELECT @dblOtherCost = 0

			DECLARE @tblMFConsumedLot TABLE (
				intWorkOrderConsumedLotId INT identity(1, 1)
				,intBatchId INT
				,strBatchId NVARCHAR(50)
				)
			DECLARE @intWorkOrderConsumedLotId INT
				,@dblInputCost NUMERIC(38, 20)
				,@intProductionSummaryId INT
				,@intFirstGradeItemId INT
				,@dblFirstGradeDiff NUMERIC(38, 20)
				,@dblCoEfficientApplied NUMERIC(38, 20)
				,@dblStandardUnitRate NUMERIC(38, 20)
				,@dblValue NUMERIC(38, 20)

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
					,@strBatchId = NULL
					,@dblValue = NULL

				SELECT @intTransactionId = CL.intBatchId
					,@strBatchId = CL.strBatchId
				FROM @tblMFConsumedLot CL
				WHERE intWorkOrderConsumedLotId = @intWorkOrderConsumedLotId

				SELECT @dblInputCost = @dblInputCost + ISNULL([dbo].[fnMFGetTotalStockValueFromTransactionBatch](@intTransactionId, @strBatchId), 0)

				SELECT @dblValue = SUM(CAST(dbo.fnMultiply(A.dblQty, A.dblCost) + ISNULL(A.dblValue, 0) AS NUMERIC(18, 6)))
				FROM [dbo].[tblICInventoryTransaction] A
				WHERE A.intTransactionId = @intTransactionId
					AND A.strTransactionId = @strBatchId
					AND A.intTransactionTypeId = 8

				SELECT @dblInputCost = @dblInputCost + ISNULL(@dblValue, 0)

				SELECT @intWorkOrderConsumedLotId = MIN(intWorkOrderConsumedLotId)
				FROM @tblMFConsumedLot CL
				WHERE intWorkOrderConsumedLotId > @intWorkOrderConsumedLotId
			END

			SELECT @dblOtherCharges = SUM(dblOtherCharges)
			FROM tblMFWorkOrderProducedLot
			WHERE intWorkOrderId = @intWorkOrderId
				AND ysnProductionReversed = 0

			IF @dblOtherCharges IS NOT NULL
			BEGIN
				SELECT @dblInputCost = abs(@dblInputCost) + @dblOtherCharges
			END

			DECLARE @tblMFProductionSummary TABLE (
				intProductionSummaryId INT
				,intItemId INT
				,dblOutputQuantity NUMERIC(18, 6)
				,dblDirectCost NUMERIC(38, 20)
				,intDirectCostId INT
				,dblIndirectCost NUMERIC(38, 20)
				,intIndirectCostId INT
				,dblMarketRate NUMERIC(38, 20)
				,intMarketRateId INT
				,intMarketRatePerUnitId INT
				,dblGradeDiff NUMERIC(38, 20)
				,dblCoEfficient NUMERIC(38, 20)
				,dblCoEfficientApplied NUMERIC(38, 20)
				,dblStandardUnitRate NUMERIC(38, 20)
				,dblProductionUnitRate NUMERIC(38, 20)
				,ysnZeroCost BIT
				)

			INSERT INTO @tblMFProductionSummary (
				intProductionSummaryId
				,intItemId
				,dblOutputQuantity
				,dblDirectCost
				,intDirectCostId
				,dblIndirectCost
				,intIndirectCostId
				,dblMarketRate
				,intMarketRateId
				,intMarketRatePerUnitId
				,dblGradeDiff
				,dblCoEfficient
				,dblCoEfficientApplied
				,dblStandardUnitRate
				,dblProductionUnitRate
				,ysnZeroCost
				)
			SELECT intProductionSummaryId
				,intItemId
				,dblOutputQuantity
				,dblDirectCost
				,intDirectCostId
				,dblIndirectCost
				,intIndirectCostId
				,dblMarketRate
				,intMarketRateId
				,intMarketRatePerUnitId
				,dblGradeDiff
				,dblCoEfficient
				,dblCoEfficientApplied
				,dblStandardUnitRate
				,dblProductionUnitRate
				,ysnZeroCost
			FROM tblMFProductionSummary
			WHERE intWorkOrderId = @intWorkOrderId
				AND intItemTypeId NOT IN (
					1
					,3
					,5
					)

			UPDATE PS
			SET dblMarketRate = IsNULL(dbo.fnRKGetLatestClosingPrice(IsNULL((
								SELECT TOP 1 CM.intFutureMarketId
								FROM tblICCommodityAttribute CA
								JOIN tblRKCommodityMarketMapping CM ON CM.strCommodityAttributeId = CA.intCommodityAttributeId
									AND CA.strType = 'ProductType'
								WHERE CA.intCommodityAttributeId = I.intProductTypeId
								), C.intFutureMarketId), (
							SELECT TOP 1 intFutureMonthId
							FROM tblRKFuturesMonth
							WHERE ysnExpired = 0
								AND dtmSpotDate <= @dtmCurrentDateTime
								AND intFutureMarketId = IsNULL(C.intFutureMarketId, (
										SELECT TOP 1 CM.intFutureMarketId
										FROM tblICCommodityAttribute CA
										JOIN tblRKCommodityMarketMapping CM ON CM.strCommodityAttributeId = CA.intCommodityAttributeId
											AND CA.strType = 'ProductType'
										WHERE CA.intCommodityAttributeId = I.intProductTypeId
										))
							ORDER BY 1 DESC
							), @dtmCurrentDateTime), 0)
				,intMarketRatePerUnitId = IsNULL((
						SELECT TOP 1 FM.intUnitMeasureId
						FROM tblICCommodityAttribute CA
						JOIN tblRKCommodityMarketMapping CM ON CM.strCommodityAttributeId = CA.intCommodityAttributeId
							AND CA.strType = 'ProductType'
						JOIN tblRKFutureMarket FM ON FM.intFutureMarketId = CM.intFutureMarketId
						WHERE CA.intCommodityAttributeId = I.intProductTypeId
						), FM1.intUnitMeasureId)
			FROM @tblMFProductionSummary PS
			JOIN tblICItem I ON I.intItemId = PS.intItemId
			JOIN tblICCommodity C ON C.intCommodityId = I.intCommodityId
			LEFT JOIN tblRKFutureMarket FM1 ON FM1.intFutureMarketId = C.intFutureMarketId

			UPDATE PS
			SET dblMarketRate = IsNULL(dbo.fnRKGetLatestClosingPrice(IsNULL((
								SELECT TOP 1 CM.intFutureMarketId
								FROM tblICCommodityAttribute CA
								JOIN tblRKCommodityMarketMapping CM ON CM.strCommodityAttributeId = CA.intCommodityAttributeId
									AND CA.strType = 'ProductType'
								WHERE CA.intCommodityAttributeId = I.intProductTypeId
								), C.intFutureMarketId), (
							SELECT TOP 1 intFutureMonthId
							FROM tblRKFuturesMonth
							WHERE ysnExpired = 0
								AND dtmSpotDate <= @dtmCurrentDateTime
								AND intFutureMarketId = IsNULL(C.intFutureMarketId, (
										SELECT TOP 1 CM.intFutureMarketId
										FROM tblICCommodityAttribute CA
										JOIN tblRKCommodityMarketMapping CM ON CM.strCommodityAttributeId = CA.intCommodityAttributeId
											AND CA.strType = 'ProductType'
										WHERE CA.intCommodityAttributeId = I.intProductTypeId
										))
							ORDER BY 1 DESC
							), @dtmCurrentDateTime), 0)
				,dblGradeDiff = IsNULL(GD.dblGradeDiff, 0)
				,dblCoEfficient = 0
				,intMarketRatePerUnitId = IsNULL((
						SELECT TOP 1 FM.intUnitMeasureId
						FROM tblICCommodityAttribute CA
						JOIN tblRKCommodityMarketMapping CM ON CM.strCommodityAttributeId = CA.intCommodityAttributeId
							AND CA.strType = 'ProductType'
						JOIN tblRKFutureMarket FM ON FM.intFutureMarketId = CM.intFutureMarketId
						WHERE CA.intCommodityAttributeId = I.intProductTypeId
						), FM1.intUnitMeasureId)
			FROM tblMFProductionSummary PS
			JOIN tblICItem I ON I.intItemId = PS.intItemId
				AND PS.intWorkOrderId = @intWorkOrderId
				AND PS.intItemTypeId IN (
					1
					,3
					)
			JOIN tblICCommodity C ON C.intCommodityId = I.intCommodityId
			LEFT JOIN tblMFItemGradeDiff GD ON GD.intItemId = I.intItemId
			LEFT JOIN tblRKFutureMarket FM1 ON FM1.intFutureMarketId = C.intFutureMarketId

			--If exists(Select *from @tblMFProductionSummary Where dblGradeDiff is null)
			--Begin
			UPDATE PS
			SET dblGradeDiff = IsNULL(GD.dblGradeDiff, 0)
				,ysnZeroCost = IsNULL(GD.ysnZeroCost, 0)
			FROM @tblMFProductionSummary PS
			LEFT JOIN tblMFItemGradeDiff GD ON GD.intItemId = PS.intItemId

			--End
			--Calculate co efficient
			SELECT @intProductionSummaryId = min(intProductionSummaryId)
			FROM @tblMFProductionSummary

			UPDATE @tblMFProductionSummary
			SET dblCoEfficient = 1
			WHERE intProductionSummaryId = @intProductionSummaryId

			SELECT @intFirstGradeItemId = intItemId
				,@dblFirstGradeDiff = dblGradeDiff
			FROM @tblMFProductionSummary
			WHERE intProductionSummaryId = @intProductionSummaryId

			UPDATE @tblMFProductionSummary
			SET dblCoEfficient = 0
			WHERE ysnZeroCost = 1

			UPDATE PS
			SET dblCoEfficient = (PS.dblMarketRate + PS.dblGradeDiff) / CASE 
					WHEN (PS.dblMarketRate + @dblFirstGradeDiff) = 0
						THEN 1
					ELSE (PS.dblMarketRate + @dblFirstGradeDiff)
					END
			FROM @tblMFProductionSummary PS
			WHERE dblCoEfficient IS NULL

			UPDATE @tblMFProductionSummary
			SET dblCoEfficientApplied = dblOutputQuantity * dblCoEfficient

			SELECT @dblCoEfficientApplied = SUM(dblCoEfficientApplied)
			FROM @tblMFProductionSummary

			UPDATE @tblMFProductionSummary
			SET dblStandardUnitRate = abs(@dblInputCost) / CASE 
					WHEN @dblCoEfficientApplied = 0
						THEN 1
					ELSE @dblCoEfficientApplied
					END
				,dblDirectCost = abs(@dblInputCost)

			UPDATE @tblMFProductionSummary
			SET dblProductionUnitRate = dblStandardUnitRate * dblCoEfficient

			UPDATE PS1
			SET dblDirectCost = PS.dblDirectCost
				,intDirectCostId = PS.intDirectCostId
				,dblIndirectCost = PS.dblIndirectCost
				,intIndirectCostId = PS.intIndirectCostId
				,dblMarketRate = PS.dblMarketRate
				,intMarketRateId = PS.intMarketRateId
				,intMarketRatePerUnitId = PS.intMarketRatePerUnitId
				,dblGradeDiff = PS.dblGradeDiff
				,dblCoEfficient = PS.dblCoEfficient
				,dblCoEfficientApplied = PS.dblCoEfficientApplied
				,dblStandardUnitRate = PS.dblStandardUnitRate
				,dblProductionUnitRate = PS.dblProductionUnitRate
				,ysnZeroCost = PS.ysnZeroCost
				,dblCost = PS.dblProductionUnitRate * PS.dblOutputQuantity
			FROM @tblMFProductionSummary PS
			JOIN tblMFProductionSummary PS1 ON PS.intProductionSummaryId = PS1.intProductionSummaryId

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
				,[dblNewCost] = (PS.dblProductionUnitRate * PL.dblQuantity) - (IsNULL(PL.dblOtherCharges, 0) + ABS(ISNULL([dbo].[fnMFGetTotalStockValueFromTransactionBatch](PL.intBatchId, PL.strBatchId), 0)))
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
				,[intSubLocationId] = L.intSubLocationId
				,[intStorageLocationId] = L.intStorageLocationId
				,[ysnIsStorage] = NULL
				,[strActualCostId] = NULL
				,[intSourceTransactionId] = intBatchId
				,[intSourceTransactionDetailId] = PL.intWorkOrderProducedLotId
				,[strSourceTransactionId] = strWorkOrderNo
				,intFobPointId = 2
			FROM dbo.tblMFWorkOrderProducedLot PL
			JOIN dbo.tblMFWorkOrder W ON W.intWorkOrderId = PL.intWorkOrderId
			JOIN tblICLot L ON L.intLotId = PL.intProducedLotId
			--JOIN tblICStorageLocation SL ON SL.intStorageLocationId = L.intStorageLocationId
			JOIN @tblMFProductionSummary PS ON PS.intItemId = PL.intItemId
			WHERE PL.intWorkOrderId = @intWorkOrderId
				AND PL.ysnProductionReversed = 0
				AND PL.intItemId IN (
					SELECT intItemId
					FROM dbo.tblMFWorkOrderRecipeItem
					WHERE intRecipeItemTypeId = 2
						AND ysnConsumptionRequired = 1
						AND intWorkOrderId = @intWorkOrderId
					)
		END

		-- Get the next batch number
		EXEC dbo.uspSMGetStartingNumber @STARTING_NUMBER_BATCH
			,@strBatchId OUTPUT

		DELETE
		FROM @GLEntries

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
	END

	--DELETE T
	--FROM dbo.tblMFTask T
	--JOIN dbo.tblMFOrderHeader OH ON OH.intOrderHeaderId = T.intOrderHeaderId
	--JOIN dbo.tblMFStageWorkOrder SW ON SW.intOrderHeaderId = T.intOrderHeaderId
	--WHERE SW.intWorkOrderId = @intWorkOrderId
	UPDATE OH
	SET intOrderStatusId = 10
	FROM dbo.tblMFOrderHeader OH
	JOIN dbo.tblMFStageWorkOrder SW ON SW.intOrderHeaderId = OH.intOrderHeaderId
	WHERE SW.intWorkOrderId = @intWorkOrderId

	EXEC [dbo].[uspICPostStockReservation] @intTransactionId = @intWorkOrderId
		,@intTransactionTypeId = 8
		,@ysnPosted = 1

	EXEC [dbo].[uspICPostStockReservation] @intTransactionId = @intWorkOrderId
		,@intTransactionTypeId = 9
		,@ysnPosted = 1

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
