CREATE PROCEDURE uspMFDragAndDropWorkOrder (@strXML NVARCHAR(MAX))
AS
BEGIN TRY
	DECLARE @idoc INT
		,@ErrMsg NVARCHAR(MAX)
		,@intScheduleId INT
		,@dtmCurrentDate DATETIME
		,@intUserId INT
		,@intConcurrencyId INT
		,@intManufacturingCellId int
		,@intDraggedManufacturingCellId INT
		,@intDraggedWorkOrder INT
		,@intDraggedItemId INT
		,@intDraggedExecutionOrder INT
		,@intDroppedManufacturingCell INT
		,@intDroppedBeforeExecutionOrder INT
		,@intLocationId INT
		,@dtmFromDate datetime
		,@dtmToDate datetime

	SELECT @dtmCurrentDate = GetDate()

	DECLARE @tblMFScheduleWorkOrder ScheduleTable

	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@strXML

	SELECT @intManufacturingCellId=intManufacturingCellId
		,@intDraggedManufacturingCellId = intDraggedManufacturingCellId
		,@intDraggedWorkOrder = intDraggedWorkOrder
		,@intDraggedItemId = intDraggedItemId
		,@intDraggedExecutionOrder = intDraggedExecutionOrder
		,@intDroppedManufacturingCell = intDroppedManufacturingCell
		,@intDroppedBeforeExecutionOrder = intDroppedBeforeExecutionOrder
		,@intScheduleId = intScheduleId
		,@intConcurrencyId = intConcurrencyId
		,@intUserId = intUserId
		,@intLocationId = intLocationId
		,@dtmFromDate=dtmFromDate
		,@dtmToDate =dtmToDate
	FROM OPENXML(@idoc, 'root', 2) WITH (
			intManufacturingCellId int
			,intDraggedManufacturingCellId INT
			,intDraggedWorkOrder INT
			,intDraggedItemId INT
			,intDraggedExecutionOrder INT
			,intDroppedManufacturingCell INT
			,intDroppedBeforeExecutionOrder INT
			,intScheduleId INT
			,intConcurrencyId INT
			,intUserId INT
			,intLocationId INT
			,dtmFromDate datetime
			,dtmToDate datetime
			)

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
		--,intSequenceId
		,intScheduleId
		,intLocationId 
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
		,Row_number() OVER (Partition By intManufacturingCellId
			ORDER BY intManufacturingCellId
				,x.intExecutionOrder
				,x.ysnEOModified DESC
			) AS intExecutionOrder
		,x.intPackTypeId
		,x.intScheduleWorkOrderId
		,x.ysnFrozen
		,@intConcurrencyId
		--,x.intSequenceNo
		,x.intScheduleId
		,@intLocationId
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
			--,intSequenceNo INT
			,ysnEOModified BIT
			,intScheduleId int
			) x
	WHERE x.intStatusId <> 1 AND x.intManufacturingCellId in (@intDraggedManufacturingCellId,@intDroppedManufacturingCell)
	ORDER BY x.intExecutionOrder
	

	DECLARE @intItemId1 INT
		,@intItemId2 INT
		,@strWorkOrderNo1 nvarchar(50)
		,@strWorkOrderNo2 nvarchar(50)
		,@intWorkOrderId1 int
		,@intWorkOrderId2 int
		,@strCellName nvarchar(50)

	SELECT @intItemId1 = intItemId, @intWorkOrderId1=intWorkOrderId
	FROM @tblMFScheduleWorkOrder
	WHERE intExecutionOrder = @intDraggedExecutionOrder - 1

	SELECT @intItemId2 = intItemId, @intWorkOrderId2=intWorkOrderId
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
		Select @strWorkOrderNo1=strWorkOrderNo from dbo.tblMFWorkOrder Where intWorkOrderId=@intWorkOrderId1
		Select @strWorkOrderNo2=strWorkOrderNo from dbo.tblMFWorkOrder Where intWorkOrderId=@intWorkOrderId2

		SELECT @strCellName =strCellName
		FROM tblMFManufacturingCell Where intManufacturingCellId =@intDraggedManufacturingCellId

		RAISERROR (
				'Dragging this order from the current location will result in contamination between two adjacent orders %s, %s in this line: %s'
				,14
				,1
				,@strWorkOrderNo1
				,@strWorkOrderNo2
				,@strCellName
				)
	END

	SELECT @intItemId1 = NULL

	SELECT @intItemId2 = NULL

	SELECT @intItemId1 = intItemId,@intWorkOrderId1=intWorkOrderId
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
		Select @strWorkOrderNo1=strWorkOrderNo from dbo.tblMFWorkOrder Where intWorkOrderId=@intWorkOrderId1
		Select @strWorkOrderNo2=strWorkOrderNo from dbo.tblMFWorkOrder Where intWorkOrderId=@intDraggedWorkOrder

		SELECT @strCellName =strCellName
		FROM tblMFManufacturingCell Where intManufacturingCellId =@intDroppedManufacturingCell

		RAISERROR (
				'Dropping this order on the target location will result in contamination of either of the adjacent orders %s, %s of the line: %s'
				,14
				,1
				,@strWorkOrderNo1
				,@strWorkOrderNo2
				,@strCellName
				)
	END

	SELECT @intItemId1 = NULL

	SELECT @intItemId2 = NULL

	SELECT @intItemId1 = @intDraggedItemId

	SELECT @intItemId2 = intItemId,@intWorkOrderId2=intWorkOrderId
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
		Select @strWorkOrderNo1=strWorkOrderNo from dbo.tblMFWorkOrder Where intWorkOrderId=@intDraggedWorkOrder
		Select @strWorkOrderNo2=strWorkOrderNo from dbo.tblMFWorkOrder Where intWorkOrderId=@intWorkOrderId1

		SELECT @strCellName =strCellName
		FROM tblMFManufacturingCell Where intManufacturingCellId =@intDroppedManufacturingCell

		RAISERROR (
				'Dropping this order on the target location will result in contamination of either of the adjacent orders %s, %s of the line: %s'
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
				'This product is not configured for processing on this line: %s'
				,14
				,1
				)
	END

	--IF EXISTS (
	--		SELECT *
	--		FROM @tblMFScheduleWorkOrder
	--		WHERE intWorkOrderId = @intDraggedWorkOrder
	--			AND intStatusId IN (
	--				4
	--				,9
	--				,10
	--				)
	--		)
	--BEGIN
	--	RAISERROR (
	--			90014
	--			,14
	--			,1
	--			)
	--END
	--DECLARE @v XML = (SELECT * FROM @tblMFScheduleWorkOrder FOR XML AUTO)

	EXEC dbo.uspMFRescheduleAndSaveWorkOrder @tblMFWorkOrder = @tblMFScheduleWorkOrder
		,@dtmFromDate = @dtmFromDate
		,@dtmToDate = @dtmToDate
		,@intUserId = @intUserId
		,@intChartManufacturingCellId=@intManufacturingCellId

	--SELECT W.intManufacturingCellId
	--	,W.intWorkOrderId
	--	,W.strWorkOrderNo
	--	,SL.intScheduleId
	--	,W.dblQuantity
	--	,ISNULL(W.dtmEarliestDate, W.dtmExpectedDate) AS dtmEarliestDate
	--	,W.dtmExpectedDate
	--	,ISNULL(W.dtmLatestDate, W.dtmExpectedDate) AS dtmLatestDate
	--	,ISNULL(SL.dtmTargetDate, W.dtmExpectedDate) AS dtmTargetDate
	--	,CASE WHEN W.dblQuantity - W.dblProducedQuantity>0 THEN W.dblQuantity - W.dblProducedQuantity ELSE 0 END AS dblBalanceQuantity
	--	,I.intItemId
	--	,IU.intItemUOMId
	--	,IU.intUnitMeasureId
	--	,W.intStatusId
	--	,SL.intScheduleWorkOrderId
	--	,SL.intExecutionOrder
	--	,SL.ysnFrozen
	--	,I.intPackTypeId
	--	,ISNULL(SL.intConcurrencyId, 0) AS intConcurrencyId
	--	,CONVERT(BIT, 0) AS ysnEOModified
	--FROM tblMFWorkOrder W
	--JOIN dbo.tblICItem I ON I.intItemId = W.intItemId
	--	AND W.intStatusId <> 13
	--	AND W.intLocationId = @intLocationId
	--	AND W.intManufacturingCellId IS NOT NULL
	--JOIN dbo.tblMFManufacturingCell MC ON MC.intManufacturingCellId = W.intManufacturingCellId
	--AND MC.ysnIncludeSchedule = 1
	--JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = W.intItemUOMId
	--LEFT JOIN @tblMFScheduleWorkOrder SL ON SL.intWorkOrderId = W.intWorkOrderId
	--ORDER BY SL.intExecutionOrder

	--EXEC dbo.uspMFGetScheduleDetail @intManufacturingCellId = @intManufacturingCellId
	--			,@dtmPlannedStartDate = @dtmFromDate
	--			,@dtmPlannedEndDate = @dtmToDate
	--			,@intLocationId = @intLocationId
	--			,@intScheduleId = 0

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
