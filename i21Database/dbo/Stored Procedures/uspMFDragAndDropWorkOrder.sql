CREATE PROCEDURE uspMFDragAndDropWorkOrder (@strXML NVARCHAR(MAX))
AS
BEGIN TRY
	DECLARE @idoc INT
		,@ErrMsg NVARCHAR(MAX)
		,@intScheduleId INT
		,@dtmCurrentDate DATETIME
		,@intUserId INT
		,@intConcurrencyId INT
		,@intDraggedManufacturingCellId INT
		,@intDraggedWorkOrder INT
		,@intDraggedItemId INT
		,@intDraggedExecutionOrder INT
		,@intDroppedManufacturingCell INT
		,@intDroppedBeforeExecutionOrder INT
		,@intLocationId INT

	SELECT @dtmCurrentDate = GetDate()

	DECLARE @tblMFScheduleWorkOrder TABLE (
		intRecordId INT identity(1, 1)
		,intManufacturingCellId INT
		,intWorkOrderId INT
		,intItemId INT
		,intItemUOMId INT
		,intUnitMeasureId INT
		,dblQuantity NUMERIC(18, 6)
		,dblBalance NUMERIC(18, 6)
		,dtmExpectedDate DATETIME
		,intStatusId INT
		,intExecutionOrder INT
		,strComments NVARCHAR(MAX)
		,strNote NVARCHAR(MAX)
		,strAdditionalComments NVARCHAR(MAX)
		,intNoOfSelectedMachine INT
		,dtmEarliestStartDate DATETIME
		,intPackTypeId INT
		,dtmPlannedStartDate DATETIME
		,dtmPlannedEndDate DATETIME
		,intPlannedShiftId INT
		,intDuration INT
		,intChangeoverDuration INT
		,intScheduleWorkOrderId INT
		,intSetupDuration INT
		,dtmChangeoverStartDate DATETIME
		,dtmChangeoverEndDate DATETIME
		,ysnFrozen BIT
		,intConcurrencyId INT
		,intSequenceId INT
		,intDemandRatio INT
		)

	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@strXML

	SELECT @intScheduleId = intScheduleId
		,@intConcurrencyId = intConcurrencyId
		,@intUserId = intUserId
		,@intLocationId = intLocationId
		,@intDraggedManufacturingCellId = intDraggedManufacturingCellId
		,@intDraggedWorkOrder = intDraggedWorkOrder
		,@intDraggedItemId = intDraggedItemId
		,@intDraggedExecutionOrder = intDraggedExecutionOrder
		,@intDroppedManufacturingCell = intDroppedManufacturingCell
		,@intDroppedBeforeExecutionOrder = intDroppedBeforeExecutionOrder
		,@intLocationId = intLocationId
	FROM OPENXML(@idoc, 'root', 2) WITH (
			intScheduleId INT
			,intConcurrencyId INT
			,intUserId INT
			,intDraggedManufacturingCellId INT
			,intDraggedWorkOrder INT
			,intDraggedItemId INT
			,intDraggedExecutionOrder INT
			,intDroppedManufacturingCell INT
			,intDroppedBeforeExecutionOrder INT
			,intLocationId INT
			)

	DECLARE @intItemId1 INT
		,@intItemId2 INT

	SELECT @intItemId1 = intItemId
	FROM @tblMFScheduleWorkOrder
	WHERE intExecutionOrder = @intDraggedExecutionOrder - 1

	SELECT @intItemId2 = intItemId
	FROM @tblMFScheduleWorkOrder
	WHERE intExecutionOrder = @intDraggedExecutionOrder + 1

	IF (
			SELECT ISNULL(MAX(ICD2.intNoOfFlushes), 0)
			FROM dbo.tblMFRecipe R
			JOIN dbo.tblMFRecipeItem RI ON RI.intRecipeId = R.intRecipeId
				AND R.intLocationId = @intLocationId
				AND R.ysnActive = 1
				AND R.intItemId = @intItemId2
			JOIN dbo.tblMFItemContamination IC1 ON IC1.intItemId = @intItemId1
			JOIN dbo.tblMFItemContamination IC2 ON IC2.intItemId = RI.intItemId
			JOIN dbo.tblMFItemContaminationDetail ICD2 ON ICD2.intItemContaminationId = IC2.intItemContaminationId
				AND ICD2.intItemGroupId = IC1.intItemGroupId
			WHERE (
					(
						RI.ysnYearValidationRequired = 1
						AND CONVERT(DATETIME, CONVERT(CHAR, GETDATE(), 101)) BETWEEN RI.dtmValidFrom
							AND RI.dtmValidTo
						)
					OR (
						RI.ysnYearValidationRequired = 0
						AND DATEPART(dy, GETDATE()) BETWEEN DATEPART(dy, RI.dtmValidFrom)
							AND DATEPART(dy, RI.dtmValidTo)
						)
					)
			) > 0
	BEGIN
		RAISERROR (
				90011
				,14
				,1
				)
	END

	SELECT @intItemId1 = NULL

	SELECT @intItemId2 = NULL

	SELECT @intItemId1 = intItemId
	FROM @tblMFScheduleWorkOrder
	WHERE intExecutionOrder = @intDroppedBeforeExecutionOrder - 1

	SELECT @intItemId2 = @intDraggedItemId

	IF (
			SELECT ISNULL(MAX(ICD2.intNoOfFlushes), 0)
			FROM dbo.tblMFRecipe R
			JOIN dbo.tblMFRecipeItem RI ON RI.intRecipeId = R.intRecipeId
				AND R.intLocationId = @intLocationId
				AND R.ysnActive = 1
				AND R.intItemId = @intItemId2
			JOIN dbo.tblMFItemContamination IC1 ON IC1.intItemId = @intItemId1
			JOIN dbo.tblMFItemContamination IC2 ON IC2.intItemId = RI.intItemId
			JOIN dbo.tblMFItemContaminationDetail ICD2 ON ICD2.intItemContaminationId = IC2.intItemContaminationId
				AND ICD2.intItemGroupId = IC1.intItemGroupId
			WHERE (
					(
						RI.ysnYearValidationRequired = 1
						AND CONVERT(DATETIME, CONVERT(CHAR, GETDATE(), 101)) BETWEEN RI.dtmValidFrom
							AND RI.dtmValidTo
						)
					OR (
						RI.ysnYearValidationRequired = 0
						AND DATEPART(dy, GETDATE()) BETWEEN DATEPART(dy, RI.dtmValidFrom)
							AND DATEPART(dy, RI.dtmValidTo)
						)
					)
			) > 0
	BEGIN
		RAISERROR (
				90012
				,14
				,1
				)
	END

	SELECT @intItemId1 = NULL

	SELECT @intItemId2 = NULL

	SELECT @intItemId1 = @intDraggedItemId

	SELECT @intItemId2 = intItemId
	FROM @tblMFScheduleWorkOrder
	WHERE intExecutionOrder = @intDroppedBeforeExecutionOrder

	IF (
			SELECT ISNULL(MAX(ICD2.intNoOfFlushes), 0)
			FROM dbo.tblMFRecipe R
			JOIN dbo.tblMFRecipeItem RI ON RI.intRecipeId = R.intRecipeId
				AND R.intLocationId = @intLocationId
				AND R.ysnActive = 1
				AND R.intItemId = @intItemId2
			JOIN dbo.tblMFItemContamination IC1 ON IC1.intItemId = @intItemId1
			JOIN dbo.tblMFItemContamination IC2 ON IC2.intItemId = RI.intItemId
			JOIN dbo.tblMFItemContaminationDetail ICD2 ON ICD2.intItemContaminationId = IC2.intItemContaminationId
				AND ICD2.intItemGroupId = IC1.intItemGroupId
			WHERE (
					(
						RI.ysnYearValidationRequired = 1
						AND CONVERT(DATETIME, CONVERT(CHAR, GETDATE(), 101)) BETWEEN RI.dtmValidFrom
							AND RI.dtmValidTo
						)
					OR (
						RI.ysnYearValidationRequired = 0
						AND DATEPART(dy, GETDATE()) BETWEEN DATEPART(dy, RI.dtmValidFrom)
							AND DATEPART(dy, RI.dtmValidTo)
						)
					)
			) > 0
	BEGIN
		RAISERROR (
				90012
				,14
				,1
				)
	END

	IF NOT EXISTS (
			SELECT *
			FROM @tblMFScheduleWorkOrder
			WHERE intWorkOrderId = @intDraggedWorkOrder
			)
		--AND (
		--	intFirstPreferenceCellId = @intDroppedManufacturingCell
		--	OR intSecondPreferenceCellId = @intDroppedManufacturingCell
		--	OR intThirdPreferenceCellId = @intDroppedManufacturingCell
		--	)
	BEGIN
		RAISERROR (
				90013
				,14
				,1
				)
	END

	IF EXISTS (
			SELECT *
			FROM @tblMFScheduleWorkOrder
			WHERE intWorkOrderId = @intDraggedWorkOrder
				AND intStatusId IN (
					4
					,9
					,10
					)
			)
	BEGIN
		RAISERROR (
				90014
				,14
				,1
				)
	END

	INSERT INTO @tblMFScheduleWorkOrder (
		intManufacturingCellId
		,intWorkOrderId
		,intItemId
		,intItemUOMId
		,intUnitMeasureId
		,dblQuantity
		,dblBalance
		,dtmExpectedDate
		,intStatusId
		,intExecutionOrder
		,intPackTypeId
		,intScheduleWorkOrderId
		,ysnFrozen
		,intConcurrencyId
		,intSequenceId
		)
	SELECT x.intManufacturingCellId
		,x.intWorkOrderId
		,x.intItemId
		,x.intItemUOMId
		,x.intUnitMeasureId
		,x.dblQuantity
		,x.dblBalance
		,x.dtmExpectedDate
		,x.intStatusId
		,Row_number() OVER (
			ORDER BY intManufacturingCellId
				,x.intExecutionOrder
				,x.ysnEOModified DESC
			) AS intExecutionOrder
		,x.intPackTypeId
		,x.intScheduleWorkOrderId
		,x.ysnFrozen
		,@intConcurrencyId
		,x.intSequenceNo
	FROM OPENXML(@idoc, 'root/WorkOrders/WorkOrder', 2) WITH (
			intManufacturingCellId INT
			,intWorkOrderId INT
			,intItemId INT
			,intUnitMeasureId INT
			,intItemUOMId INT
			,dblQuantity NUMERIC(18, 6)
			,dblBalance NUMERIC(18, 6)
			,dtmExpectedDate DATETIME
			,intStatusId INT
			,intExecutionOrder INT
			,intPackTypeId INT
			,intScheduleWorkOrderId INT
			,ysnFrozen BIT
			,intSequenceNo INT
			,ysnEOModified BIT
			) x
	WHERE x.intStatusId <> 1
	ORDER BY x.intExecutionOrder

	INSERT INTO @tblMFScheduleWorkOrder (
		intManufacturingCellId
		,intWorkOrderId
		,intItemId
		,intItemUOMId
		,intUnitMeasureId
		,dblQuantity
		,dblBalance
		,dtmExpectedDate
		,intStatusId
		,intExecutionOrder
		,intPackTypeId
		,intScheduleWorkOrderId
		,ysnFrozen
		,intConcurrencyId
		,intSequenceId
		)
	SELECT x.intManufacturingCellId
		,x.intWorkOrderId
		,x.intItemId
		,x.intItemUOMId
		,x.intUnitMeasureId
		,x.dblQuantity
		,x.dblBalance
		,x.dtmExpectedDate
		,x.intStatusId
		,x.intExecutionOrder
		,x.intPackTypeId
		,x.intScheduleWorkOrderId
		,x.ysnFrozen
		,@intConcurrencyId
		,x.intSequenceNo
	FROM OPENXML(@idoc, 'root/WorkOrders/WorkOrder', 2) WITH (
			intManufacturingCellId INT
			,intWorkOrderId INT
			,intItemId INT
			,intUnitMeasureId INT
			,intItemUOMId INT
			,dblQuantity NUMERIC(18, 6)
			,dblBalance NUMERIC(18, 6)
			,dtmExpectedDate DATETIME
			,intStatusId INT
			,intExecutionOrder INT
			,intPackTypeId INT
			,intScheduleWorkOrderId INT
			,ysnFrozen BIT
			,intSequenceNo INT
			) x
	WHERE x.intStatusId = 1
	ORDER BY x.intExecutionOrder

	SELECT W.intManufacturingCellId
		,W.intWorkOrderId
		--,SL.intScheduleId
		,W.dblQuantity
		,W.dtmEarliestDate
		,W.dtmExpectedDate
		,W.dtmLatestDate
		,W.dblQuantity - W.dblProducedQuantity AS dblBalanceQuantity
		,I.intItemId
		,IU.intItemUOMId
		,IU.intUnitMeasureId
		,W.intStatusId
		,SL.intScheduleWorkOrderId
		,SL.intExecutionOrder
		,SL.ysnFrozen
		,I.intPackTypeId
		,ISNULL(SL.intConcurrencyId, 0) AS intConcurrencyId
		,CONVERT(BIT, 0) AS ysnEOModified
	FROM tblMFWorkOrder W
	JOIN dbo.tblICItem I ON I.intItemId = W.intItemId
		AND W.intStatusId <> 13
		AND W.intLocationId = @intLocationId
		AND W.intManufacturingCellId IS NOT NULL
	JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = W.intItemUOMId
	LEFT JOIN @tblMFScheduleWorkOrder SL ON SL.intWorkOrderId = W.intWorkOrderId
	ORDER BY SL.intExecutionOrder

	EXEC sp_xml_removedocument @idoc
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	IF @idoc <> 0
		EXEC sp_xml_removedocument @idoc

	RAISERROR (
			@ErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH
