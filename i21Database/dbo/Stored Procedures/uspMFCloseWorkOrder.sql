CREATE PROCEDURE uspMFCloseWorkOrder (@strXML NVARCHAR(MAX))
AS
BEGIN TRY
	DECLARE @idoc INT
		,@ErrMsg NVARCHAR(MAX)
		,@intWorkOrderId INT
		,@intLotId INT
		,@intUserId INT
		,@strBatchId NVARCHAR(40)
		,@intTransactionId INT
		,@strTransactionId NVARCHAR(50)
		,@dblQuantity NUMERIC(38, 20)
		,@intRecordId INT
		,@dtmCurrentDate DATETIME
		,@strLotNumber NVARCHAR(50)
		,@intAttributeId INT
		,@intManufacturingProcessId INT
		,@intLocationId INT
		,@strAttributeValue NVARCHAR(50)
		,@strCycleCountMandatory NVARCHAR(50)
		,@intExecutionOrder INT
		,@intManufacturingCellId INT
		,@dtmPlannedDate DATETIME
		,@intTransactionCount INT
		,@strInstantConsumption NVARCHAR(50)
		,@strWorkOrderNo NVARCHAR(50)
		,@intBatchId INT
		,@strUndoXML NVARCHAR(MAX)
		,@strWIPSampleMandatory NVARCHAR(50)
		,@intSampleStatusId INT
		,@dtmSampleCreated DATETIME
		,@strSampleNumber NVARCHAR(50)
		,@dblProducedQuantity DECIMAL(24, 10)
		,@strSampleTypeId NVARCHAR(MAX)
		,@intSampleTypeId INT
		,@strSampleTypeName NVARCHAR(50)
		,@strCellName NVARCHAR(50)
		,@adjustedEntries AS ItemCostAdjustmentTableType
		,@dblNewCost NUMERIC(38, 20)
		,@dblNewUnitCost NUMERIC(38, 20)
		,@userId INT
		,@intWorkOrderProducedLotId INT
		,@dblOtherCost NUMERIC(18, 6)
		,@dblProduceQty NUMERIC(38, 20)
		,@GLEntries AS RecapTableType
		,@STARTING_NUMBER_BATCH AS INT = 3
		,@strCostDistribution NVARCHAR(50)
		,@intReturnValue AS INT
		,@ErrorMessage AS NVARCHAR(4000)
		,@strPickLot NVARCHAR(50)
		,@AccountCategory_Cost_Adjustment NVARCHAR(50)
		,@dblOtherCharges NUMERIC(38, 20)

	SELECT @dtmCurrentDate = GetDate()

	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@strXML

	SELECT @intWorkOrderId = intWorkOrderId
		,@intUserId = intUserId
	FROM OPENXML(@idoc, 'root', 2) WITH (
			intWorkOrderId INT
			,intUserId INT
			)

	IF NOT EXISTS (
			SELECT *
			FROM tblMFWorkOrder
			WHERE intWorkOrderId = @intWorkOrderId
			)
	BEGIN
		RAISERROR (
				'The work order that you clicked on no longer exists. This is quite possible, if a packaging operator has deleted the work order and your iMake client is yet to refresh the screen.'
				,11
				,1
				)
	END

	SELECT @intManufacturingProcessId = intManufacturingProcessId
		,@intLocationId = intLocationId
		,@strWorkOrderNo = strWorkOrderNo
		,@intManufacturingCellId = intManufacturingCellId
		,@dblProducedQuantity = dblProducedQuantity
	FROM tblMFWorkOrder
	WHERE intWorkOrderId = @intWorkOrderId

	SELECT @intAttributeId = intAttributeId
	FROM tblMFAttribute
	WHERE strAttributeName = 'Is Warehouse Release Mandatory'

	SELECT @strAttributeValue = strAttributeValue
	FROM tblMFManufacturingProcessAttribute
	WHERE intManufacturingProcessId = @intManufacturingProcessId
		AND intLocationId = @intLocationId
		AND intAttributeId = @intAttributeId

	IF @strAttributeValue = 'True'
		AND EXISTS (
			SELECT *
			FROM dbo.tblMFWorkOrderProducedLot WP
			JOIN dbo.tblICLot L ON L.intLotId = WP.intLotId
			WHERE WP.intWorkOrderId = @intWorkOrderId
				AND WP.ysnReleased = 0
				AND WP.ysnProductionReversed = 0
				AND L.intLotStatusId = 3
			)
	BEGIN
		RAISERROR (
				'There are lots produced against this workorder which are not yet released to warehouse. In order to complete the workorder, either release the lots to warehouse or mark the pallet(s) as Ghost.'
				,11
				,1
				)

		RETURN
	END

	SELECT @intAttributeId = intAttributeId
	FROM tblMFAttribute
	WHERE strAttributeName = 'Is Cycle Count Required'

	SELECT @strCycleCountMandatory = strAttributeValue
	FROM tblMFManufacturingProcessAttribute
	WHERE intManufacturingProcessId = @intManufacturingProcessId
		AND intLocationId = @intLocationId
		AND intAttributeId = @intAttributeId

	IF @strCycleCountMandatory = 'True'
		AND NOT EXISTS (
			SELECT *
			FROM tblMFProcessCycleCountSession
			WHERE intWorkOrderId = @intWorkOrderId
			)
		AND (
			EXISTS (
				SELECT *
				FROM dbo.tblMFWorkOrderProducedLot
				WHERE intWorkOrderId = @intWorkOrderId
					AND ysnProductionReversed = 0
				)
			OR EXISTS (
				SELECT *
				FROM dbo.tblMFWorkOrderInputLot
				WHERE intWorkOrderId = @intWorkOrderId
					AND ysnConsumptionReversed = 0
				)
			)
	BEGIN
		RAISERROR (
				'Cycle count entries for the run not available, cannot proceed.'
				,11
				,1
				)
	END

	SELECT @strWIPSampleMandatory = strAttributeValue
	FROM tblMFManufacturingProcessAttribute
	WHERE intManufacturingProcessId = @intManufacturingProcessId
		AND intLocationId = @intLocationId
		AND intAttributeId = 84

	IF @strWIPSampleMandatory = 'True'
		AND @dblProducedQuantity > 0
	BEGIN
		SELECT @strSampleTypeId = strAttributeValue
		FROM tblMFManufacturingProcessAttribute
		WHERE intManufacturingProcessId = @intManufacturingProcessId
			AND intLocationId = @intLocationId
			AND intAttributeId = 97

		SELECT @intSampleTypeId = Item Collate Latin1_General_CI_AS
		FROM [dbo].[fnSplitString](@strSampleTypeId, ',') ST1
		WHERE NOT EXISTS (
				SELECT 1
				FROM tblQMSample S
				JOIN tblQMSampleType ST ON ST.intSampleTypeId = S.intSampleTypeId
				WHERE S.intProductTypeId = 12
					AND S.intProductValueId = @intWorkOrderId
					AND ST.intControlPointId = 11 --Line Sample
					AND ST.intSampleTypeId = ST1.Item Collate Latin1_General_CI_AS
				)

		IF @intSampleTypeId IS NOT NULL
		BEGIN
			SELECT @strSampleTypeName = strSampleTypeName
			FROM tblQMSampleType
			WHERE intSampleTypeId = @intSampleTypeId

			SELECT @strCellName = strCellName
			FROM tblMFManufacturingCell
			WHERE intManufacturingCellId = @intManufacturingCellId

			RAISERROR (
					'%s is not taken for the line %s. Please take the sample and then close the work order'
					,11
					,1
					,@strSampleTypeName
					,@strCellName
					)
		END

		SELECT TOP 1 @strSampleNumber = S.strSampleNumber
		FROM tblQMSample S
		JOIN tblQMSampleType ST ON ST.intSampleTypeId = S.intSampleTypeId
		WHERE S.intProductTypeId = 12
			AND S.intProductValueId = @intWorkOrderId
			AND ST.intControlPointId IN (
				11
				,12
				) --Line / WIP Sample
			AND S.intSampleStatusId = 1

		IF @strSampleNumber IS NOT NULL
		BEGIN
			SELECT @strCellName = strCellName
			FROM tblMFManufacturingCell
			WHERE intManufacturingCellId = @intManufacturingCellId

			RAISERROR (
					'The sample %s is not approved for the line %s. Please approve the sample and then close the work order'
					,11
					,1
					,@strSampleNumber
					,@strCellName
					)
		END
	END

	IF EXISTS (
			SELECT *
			FROM dbo.tblMFWorkOrderRecipeItem ri
			WHERE ri.intWorkOrderId = @intWorkOrderId
				AND ri.intRecipeItemTypeId = 2
				AND ri.ysnOutputItemMandatory = 1
				AND NOT EXISTS (
					SELECT *
					FROM tblMFWorkOrderProducedLot WP
					WHERE WP.intWorkOrderId = ri.intWorkOrderId
						AND WP.intItemId = ri.intItemId
						AND WP.ysnProductionReversed = 0
					)
			)
		AND @dblProducedQuantity > 0
	BEGIN
		RAISERROR (
				'Cannot close the work order. One or more mandatory items are not produced.'
				,16
				,1
				)

		RETURN
	END

	SELECT @intTransactionCount = @@TRANCOUNT

	IF @intTransactionCount = 0
		BEGIN TRANSACTION

	SELECT @intAttributeId = intAttributeId
	FROM tblMFAttribute
	WHERE strAttributeName = 'Is Instant Consumption'

	SELECT @strInstantConsumption = strAttributeValue
	FROM tblMFManufacturingProcessAttribute
	WHERE intManufacturingProcessId = @intManufacturingProcessId
		AND intLocationId = @intLocationId
		AND intAttributeId = @intAttributeId

	IF @strCycleCountMandatory = 'False'
		AND @strInstantConsumption = 'False'
	BEGIN
		EXEC dbo.uspMFPostWorkOrder @strXML = @strXML
	END

	DECLARE @tblMFLot TABLE (
		intRecordId INT identity(1, 1)
		,intBatchId INT
		,intLotId INT
		)

	INSERT INTO @tblMFLot (
		intBatchId
		,intLotId
		)
	SELECT PL.intBatchId
		,PL.intLotId
	FROM dbo.tblMFWorkOrderProducedLot PL
	JOIN dbo.tblICLot L ON L.intLotId = PL.intLotId
	WHERE intWorkOrderId = @intWorkOrderId
		AND L.intLotStatusId = 2
		AND ysnProductionReversed = 0

	SELECT @intRecordId = MIN(intRecordId)
	FROM @tblMFLot

	WHILE @intRecordId IS NOT NULL
		AND @strAttributeValue = 'True'
	BEGIN
		SELECT @intBatchId = NULL
			,@intLotId = NULL

		SELECT @intBatchId = intBatchId
			,@intLotId = intLotId
		FROM @tblMFLot
		WHERE intRecordId = @intRecordId

		SELECT @strUndoXML = N'<root><intWorkOrderId>' + Ltrim(@intWorkOrderId) + '</intWorkOrderId><intLotId>' + Ltrim(@intLotId) + '</intLotId><intBatchId>' + Ltrim(@intBatchId) + '</intBatchId><ysnForceUndo>True</ysnForceUndo><intUserId>' + Ltrim(@intUserId) + '</intUserId></root>'

		EXEC uspMFUndoPallet @strUndoXML

		SELECT @intRecordId = MIN(intRecordId)
		FROM @tblMFLot
		WHERE intRecordId > @intRecordId
	END

	SELECT @intExecutionOrder = intExecutionOrder
		,@intManufacturingCellId = intManufacturingCellId
		,@dtmPlannedDate = dtmPlannedDate
	FROM dbo.tblMFWorkOrder
	WHERE intWorkOrderId = @intWorkOrderId

	UPDATE dbo.tblMFWorkOrder
	SET intStatusId = 13
		,dtmCompletedDate = @dtmCurrentDate
		,intExecutionOrder = 0
		,intConcurrencyId = intConcurrencyId + 1
		,dtmLastModified = @dtmCurrentDate
		,intLastModifiedUserId = @intUserId
	WHERE intWorkOrderId = @intWorkOrderId

	UPDATE dbo.tblMFScheduleWorkOrder
	SET intStatusId = 13
		,intConcurrencyId = intConcurrencyId + 1
		,dtmLastModified = @dtmCurrentDate
		,intLastModifiedUserId = @intUserId
	WHERE intWorkOrderId = @intWorkOrderId

	UPDATE dbo.tblMFWorkOrder
	SET intExecutionOrder = intExecutionOrder - 1
	WHERE intManufacturingCellId = @intManufacturingCellId
		AND dtmPlannedDate = @dtmPlannedDate
		AND intExecutionOrder > @intExecutionOrder

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

	IF @strCostDistribution = 'True'
	BEGIN
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

		SELECT @dblOtherCost = 0

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

		SET @dblNewCost = ISNULL(@dblOtherCost, 0)
		SET @dblNewCost = ABS(@dblNewCost)

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
			,[intItemLocationId] = IL.intItemLocationId
			,[intItemUOMId] = PL.intItemUOMId
			,[dtmDate] = Isnull(PL.dtmProductionDate, @dtmCurrentDate)
			,[dblQty] = PL.dblQuantity
			,[dblUOMQty] = 1
			,[intCostUOMId] = PL.intItemUOMId
			,[dblNewCost] = CASE 
				WHEN IsNULL(RI.dblPercentage, 0) = 0
					THEN @dblNewCost
				ELSE (@dblNewCost * RI.dblPercentage / 100) * (PL.dblQuantity / SUM(PL.dblQuantity) OVER (PARTITION BY PL.intItemId))
				END - ABS(ISNULL([dbo].[fnMFGetTotalStockValueFromTransactionBatch](PL.intBatchId, PL.strBatchId), 0))
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
		JOIN tblICItemLocation IL ON IL.intItemId = PL.intItemId
			AND IL.intLocationId = @intLocationId
		LEFT JOIN tblICLot L ON L.intLotId = PL.intLotId
		JOIN tblICStorageLocation SL ON SL.intStorageLocationId = PL.intStorageLocationId
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

		IF EXISTS (
				SELECT TOP 1 1
				FROM @adjustedEntries
				)
		BEGIN
			EXEC @intReturnValue = uspICPostCostAdjustment @adjustedEntries
				,@strBatchId
				,@userId
				,1
				,1

			IF @intReturnValue <> 0
			BEGIN
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
				IF @strInstantConsumption = 'True'
				BEGIN
					SELECT @AccountCategory_Cost_Adjustment = 'Inventory'
				END
				ELSE
				BEGIN
					SELECT @AccountCategory_Cost_Adjustment = 'Work In Progress'
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
					,@AccountCategory_Cost_Adjustment = @AccountCategory_Cost_Adjustment
			END

			IF EXISTS (
					SELECT TOP 1 1
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
	END

	SELECT @strPickLot = strAttributeValue
	FROM tblMFManufacturingProcessAttribute
	WHERE intManufacturingProcessId = @intManufacturingProcessId
		AND intLocationId = @intLocationId
		AND intAttributeId = 108 --Pick Lot/Pallet after closing work order

	IF @strPickLot IS NULL
		OR @strPickLot = ''
	BEGIN
		SELECT @strPickLot = 'False'
	END

	IF @strPickLot = 'True'
	BEGIN
		UPDATE LI
		SET ysnPickAllowed = 1
		FROM tblMFLotInventory LI
		JOIN tblICLot L ON L.intLotId = LI.intLotId
		WHERE L.strLotNumber IN (
				SELECT L.strLotNumber
				FROM tblMFWorkOrderProducedLot WP
				JOIN tblICLot L ON L.intLotId = WP.intLotId
					AND WP.intWorkOrderId = @intWorkOrderId
				)
	END

	DELETE T
	FROM dbo.tblMFTask T
	JOIN dbo.tblMFOrderHeader OH ON OH.intOrderHeaderId = T.intOrderHeaderId
	JOIN dbo.tblMFStageWorkOrder SW ON SW.intOrderHeaderId = T.intOrderHeaderId
	WHERE SW.intWorkOrderId = @intWorkOrderId

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


