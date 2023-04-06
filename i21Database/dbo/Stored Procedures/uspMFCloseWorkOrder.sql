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
		--,@strCostDistribution NVARCHAR(50)
		,@intReturnValue AS INT
		,@ErrorMessage AS NVARCHAR(4000)
		,@strPickLot NVARCHAR(50)
		,@AccountCategory_Cost_Adjustment NVARCHAR(50)
		,@dblOtherCharges NUMERIC(38, 20)
		,@strAutoCycleCountOnWorkOrderClose NVARCHAR(50)
		,@intSubLocationId INT
		,@strXML2 nvarchar(MAX)

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
		,@intSubLocationId = intSubLocationId
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
			AND S.intTypeId = 1

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

	SELECT @strAutoCycleCountOnWorkOrderClose = strAttributeValue
	FROM tblMFManufacturingProcessAttribute
	WHERE intManufacturingProcessId = @intManufacturingProcessId
		AND intLocationId = @intLocationId
		AND intAttributeId = 121 --Auto Cycle Count on Work Order Close

	IF @strAutoCycleCountOnWorkOrderClose IS NULL
		SELECT @strAutoCycleCountOnWorkOrderClose = 'False'

	IF @strAutoCycleCountOnWorkOrderClose = 'True'
	BEGIN
		SELECT @strXML2 = '<root><intLocationId>' + Ltrim(@intLocationId) + '</intLocationId><intSubLocationId>' + Ltrim(@intSubLocationId) + '</intSubLocationId><intWorkOrderId>' + Ltrim(@intWorkOrderId) + '</intWorkOrderId><intUserId>' + Ltrim(@intUserId) + '</intUserId><ysnIncludeOutputItem>False</ysnIncludeOutputItem><strExcludeItemType></strExcludeItemType><ysnAutoFill>1</ysnAutoFill></root>'

		EXEC [dbo].uspMFStartCycleCount @strXML2

		SELECT @strXML2 = '<root><CycleCounts>'

		SELECT @strXML2 = @strXML2 + '<CycleCount><intCycleCountId>' + Ltrim(CC.intCycleCountId) + '</intCycleCountId><dblQuantity>0</dblQuantity><intUserId>' + Ltrim(@intUserId) + '</intUserId></CycleCount>'
		FROM tblMFProcessCycleCount CC
		JOIN tblMFProcessCycleCountSession CS ON CS.intCycleCountSessionId = CC.intCycleCountSessionId
		WHERE CS.intWorkOrderId = @intWorkOrderId

		SELECT @strXML2 = @strXML2 + '</CycleCounts></root>'

		EXEC uspMFUpdateCycleCount @strXML2
	END

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

	DECLARE @intOrderHeaderId INT

	SELECT @intOrderHeaderId = OH.intOrderHeaderId
	FROM dbo.tblMFOrderHeader OH
	JOIN dbo.tblMFStageWorkOrder SW ON SW.intOrderHeaderId = OH.intOrderHeaderId
	WHERE SW.intWorkOrderId = @intWorkOrderId

	EXEC [dbo].[uspICPostStockReservation] @intTransactionId = @intWorkOrderId
		,@intTransactionTypeId = 8
		,@ysnPosted = 1

	EXEC [dbo].[uspICPostStockReservation] @intTransactionId = @intWorkOrderId
		,@intTransactionTypeId = 9
		,@ysnPosted = 1

	EXEC [dbo].[uspICPostStockReservation] @intTransactionId = @intOrderHeaderId
		,@intTransactionTypeId = 34
		,@ysnPosted = 1
	
	IF NOT EXISTS(SELECT *
					FROM dbo.tblMFProductionPreStage
					WHERE intWorkOrderId = @intWorkOrderId)
	BEGIN
		INSERT INTO dbo.tblMFProductionPreStage (
				intWorkOrderId
				,intProductionStatusId
				,intUserId
				)
		SELECT @intWorkOrderId
			,13
			,@intUserId
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


