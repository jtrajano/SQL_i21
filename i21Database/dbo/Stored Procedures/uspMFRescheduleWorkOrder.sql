CREATE PROCEDURE uspMFRescheduleWorkOrder (@strXML NVARCHAR(MAX))
AS
BEGIN TRY
	DECLARE @idoc INT
		,@ErrMsg NVARCHAR(MAX)
		,@intManufacturingCellId INT
		,@intWorkOrderId INT
		,@intCalendarDetailId INT
		,@intCalendarId INT
		,@dtmCalendarDate DATETIME
		,@dtmShiftStartTime DATETIME
		,@dtmShiftEndTime DATETIME
		,@intDuration INT
		,@intShiftId INT
		,@intNoOfMachine INT
		,@intNoOfUnit INT
		,@intRecordId INT
		,@dblMachineCapacity NUMERIC(18, 6)
		,@intPackTypeId INT
		,@intWODuration INT
		,@dtmPlannedEndDate DATETIME
		,@dblBalance NUMERIC(18, 6)
		,@dblConversionFactor NUMERIC(18, 6)
		,@intSequenceNo INT
		,@intNoOfSelectedMachine INT
		,@intScheduleId INT
		,@intConcurrencyId INT
		,@dtmCurrentDate DATETIME
		,@intUserId INT
		,@intLocationId int
		,@strWorkOrderNo nvarchar(50)
		,@strCellName nvarchar(50)
		,@strPackName nvarchar(50)
		,@intItemId int
		,@strItemNo nvarchar(50)

	SELECT @dtmCurrentDate = GetDate()

	DECLARE @tblMFScheduleWorkOrderCalendarDetail TABLE (
		intCalendarDetailId INT
		,intCalendarId INT
		,dtmCalendarDate DATETIME
		,dtmShiftStartTime DATETIME
		,dtmShiftEndTime DATETIME
		,intDuration INT
		,intShiftId INT
		,intNoOfMachine INT
		)
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
		,intNoOfUnit INT
		,dblConversionFactor NUMERIC(18, 6)
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
		)
	DECLARE @tblMFScheduleWorkOrderDetail TABLE (
		intWorkOrderId INT NOT NULL
		,dtmPlannedStartDate DATETIME NOT NULL
		,dtmPlannedEndDate DATETIME NOT NULL
		,intPlannedShiftId INT NOT NULL
		,intDuration INT NOT NULL
		,dblPlannedQty NUMERIC(18, 6) NOT NULL
		,intSequenceNo INT NOT NULL
		,intCalendarDetailId INT NOT NULL
		)
	DECLARE @tblMFScheduleMachineDetail TABLE (
		intWorkOrderId INT
		,intCalendarDetailId INT
		,intCalendarMachineId INT
		)
	DECLARE @tblMFScheduleConstraintDetail TABLE (
		intWorkOrderId INT
		,intScheduleRuleId INT
		,dtmChangeoverStartDate DATETIME
		,dtmChangeoverEndDate DATETIME
		,intDuration INT
		)

	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@strXML

	SELECT @intManufacturingCellId = intManufacturingCellId
		,@intCalendarId = intCalendarId
		,@intScheduleId = Isnull(intScheduleId,0)
		,@intConcurrencyId = intConcurrencyId
		,@intUserId = intUserId
		,@intLocationId=intLocationId
	FROM OPENXML(@idoc, 'root', 2) WITH (
			intManufacturingCellId INT
			,intCalendarId int
			,intScheduleId INT
			,intConcurrencyId INT
			,intUserId INT
			,intLocationId int
			)

	IF EXISTS (
		SELECT *
		FROM OPENXML(@idoc, 'root/WorkOrders/WorkOrder', 2) WITH (
			intPackTypeId INT
			,intStatusId int
			) x 
		WHERE x.intPackTypeId IS NULL AND intStatusId<>1 
		)
	BEGIN
		SELECT @intWorkOrderId=intWorkOrderId,@intItemId=intItemId
		FROM OPENXML(@idoc, 'root/WorkOrders/WorkOrder', 2) WITH (
			intWorkOrderId int
			,intItemId int
			,intStatusId int
			,intPackTypeId INT
			
			) x 
		WHERE x.intPackTypeId IS NULL AND intStatusId<>1 

		SELECT @strWorkOrderNo =strWorkOrderNo 
		FROM dbo.tblMFWorkOrder
		Where intWorkOrderId =@intWorkOrderId 

		SELECT @strItemNo=strItemNo
		FROM dbo.tblICItem 
		WHERE intItemId=@intItemId

		RAISERROR(51188,11,1,@strItemNo,@strWorkOrderNo)
		RETURN
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
		,strComments
		,strNote
		,strAdditionalComments
		,intNoOfSelectedMachine
		,dtmEarliestStartDate
		,intPackTypeId
		,intNoOfUnit
		,dblConversionFactor
		,intScheduleWorkOrderId
		,ysnFrozen
		,intConcurrencyId
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
		,x.strComments
		,x.strNote
		,x.strAdditionalComments
		,x.intNoOfSelectedMachine
		,x.dtmEarliestStartDate
		,MC.intPackTypeId
		,x.dblBalance * PTD.dblConversionFactor
		,PTD.dblConversionFactor
		,x.intScheduleWorkOrderId
		,x.ysnFrozen
		,@intConcurrencyId
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
			,strComments NVARCHAR(MAX)
			,strNote NVARCHAR(MAX)
			,strAdditionalComments NVARCHAR(MAX)
			,intNoOfSelectedMachine INT
			,dtmEarliestStartDate DATETIME
			,intPackTypeId INT
			,intScheduleWorkOrderId INT
			,ysnFrozen BIT
			) x
	LEFT JOIN dbo.tblMFManufacturingCellPackType MC ON MC.intManufacturingCellId = x.intManufacturingCellId
		AND MC.intPackTypeId = x.intPackTypeId
	LEFT JOIN dbo.tblMFPackTypeDetail PTD ON PTD.intPackTypeId = x.intPackTypeId
		AND PTD.intTargetUnitMeasureId = x.intUnitMeasureId
		AND PTD.intSourceUnitMeasureId = MC.intLineCapacityUnitMeasureId
	--WHERE intStatusId<>1 
	ORDER BY x.intExecutionOrder

	IF EXISTS (
		SELECT *
		FROM @tblMFScheduleWorkOrder
		WHERE intPackTypeId IS NULL and intStatusId<>1 and dblBalance>0
		)
	BEGIN
		SELECT @intWorkOrderId =intWorkOrderId 
		FROM @tblMFScheduleWorkOrder
		WHERE intPackTypeId IS NULL and intStatusId<>1 and dblBalance>0

		SELECT @strWorkOrderNo =strWorkOrderNo 
		FROM tblMFWorkOrder
		Where intWorkOrderId =@intWorkOrderId 

		SELECT @strCellName=strCellName
		FROM tblMFManufacturingCell 
		WHERE intManufacturingCellId=@intManufacturingCellId

		SELECT @intPackTypeId=intPackTypeId
		FROM OPENXML(@idoc, 'root/WorkOrders/WorkOrder', 2) WITH (
			intWorkOrderId INT
			,intPackTypeId INT
			) x 
		WHERE x.intWorkOrderId=@intWorkOrderId

		SELECT @strPackName=strPackName
		FROM tblMFPackType
		WHERE intPackTypeId=@intPackTypeId

		RAISERROR(51186,11,1,@strPackName,@strWorkOrderNo,@strCellName)
		RETURN
	END

	IF EXISTS (
		SELECT *
		FROM @tblMFScheduleWorkOrder
		WHERE dblConversionFactor IS NULL and intStatusId<>1 and dblBalance>0
		)
	BEGIN
		SELECT @intWorkOrderId =intWorkOrderId 
		FROM @tblMFScheduleWorkOrder
		WHERE dblConversionFactor IS NULL and intStatusId<>1 and dblBalance>0

		SELECT @strWorkOrderNo =strWorkOrderNo 
		FROM tblMFWorkOrder
		Where intWorkOrderId =@intWorkOrderId 

		RAISERROR(51187,11,1,@strWorkOrderNo)
		RETURN
	END
	
	--Select *from @tblMFScheduleWorkOrder
	--return

	INSERT INTO @tblMFScheduleWorkOrderCalendarDetail (
		intCalendarDetailId
		,intCalendarId
		,dtmCalendarDate
		,dtmShiftStartTime
		,dtmShiftEndTime
		,intDuration
		,intShiftId
		,intNoOfMachine
		)
	SELECT CD.intCalendarDetailId
		,CD.intCalendarId
		,CD.dtmCalendarDate
		,CD.dtmShiftStartTime
		,CD.dtmShiftEndTime
		,CD.intDuration
		,CD.intShiftId
		,CD.intNoOfMachine
	FROM dbo.tblMFScheduleCalendar C
	JOIN dbo.tblMFScheduleCalendarDetail CD ON C.intCalendarId = CD.intCalendarId
	WHERE C.intManufacturingCellId = @intManufacturingCellId
		AND C.intCalendarId=@intCalendarId
		AND CD.dtmShiftEndTime > @dtmCurrentDate

	SELECT @intCalendarDetailId = Min(intCalendarDetailId)
	FROM @tblMFScheduleWorkOrderCalendarDetail

	WHILE @intCalendarDetailId IS NOT NULL
	BEGIN
		SELECT @intCalendarId = NULL
			,@dtmCalendarDate = NULL
			,@dtmShiftStartTime = NULL
			,@dtmShiftEndTime = NULL
			,@intDuration = NULL
			,@intShiftId = NULL
			,@intNoOfMachine = NULL

		SELECT @intCalendarDetailId = intCalendarDetailId
			,@intCalendarId = intCalendarId
			,@dtmCalendarDate = dtmCalendarDate
			,@dtmShiftStartTime = dtmShiftStartTime
			,@dtmShiftEndTime = dtmShiftEndTime
			,@intDuration = intDuration
			,@intShiftId = intShiftId
			,@intNoOfMachine = intNoOfMachine
		FROM @tblMFScheduleWorkOrderCalendarDetail
		WHERE intCalendarDetailId = @intCalendarDetailId

		IF @dtmCurrentDate > @dtmShiftStartTime
		BEGIN
			SELECT @dtmShiftStartTime = @dtmCurrentDate

			SELECT @intDuration = DateDiff(minute, @dtmShiftStartTime, @dtmShiftEndTime)
		END

		SELECT @intRecordId = Min(intRecordId)
		FROM @tblMFScheduleWorkOrder S
		WHERE S.intNoOfUnit > 0 AND intManufacturingCellId =@intManufacturingCellId AND S.intStatusId<>1 
			AND NOT EXISTS (
				SELECT *
				FROM @tblMFScheduleWorkOrderDetail SD
				WHERE SD.intWorkOrderId = S.intWorkOrderId
					AND SD.intCalendarDetailId = @intCalendarDetailId
				)

		WHILE @intRecordId IS NOT NULL
		BEGIN
			SELECT @intWorkOrderId = NULL
				,@intNoOfUnit = NULL
				,@intPackTypeId = NULL
				,@dblBalance = NULL
				,@dblConversionFactor = NULL

			SELECT @intWorkOrderId = intWorkOrderId
				,@intNoOfUnit = intNoOfUnit
				,@intPackTypeId = intPackTypeId
				,@dblBalance = dblBalance
				,@dblConversionFactor = dblConversionFactor
				,@intNoOfSelectedMachine = intNoOfSelectedMachine
			FROM @tblMFScheduleWorkOrder
			WHERE intRecordId = @intRecordId

			SELECT @dblMachineCapacity = SUM(DT.dblMachineCapacity)
			FROM (
				SELECT TOP (@intNoOfSelectedMachine) MP.dblMachineCapacity
				FROM dbo.tblMFScheduleCalendarMachineDetail MD
				JOIN dbo.tblMFMachinePackType MP ON MP.intMachineId = MD.intMachineId
				WHERE intCalendarDetailId = @intCalendarDetailId
					AND MP.intPackTypeId = @intPackTypeId
				) AS DT

			SELECT @intWODuration = @intNoOfUnit / @dblMachineCapacity

			--IF @intNoOfUnit > isnull((
			--			SELECT Count(*)
			--			FROM @tblMFScheduleMachineDetail
			--			WHERE intCalendarDetailId = @intCalendarDetailId
			--			), 0)
			--BEGIN
			--	PRINT 1
			--END
			--ELSE
			--BEGIN
			--	SELECT @dtmShiftStartTime = min(dtmPlannedEndDate)
			--	FROM @tblMFScheduleWorkOrderDetail
			--	WHERE intCalendarDetailId = @intCalendarDetailId

			--	SELECT @intDuration = DateDiff(minute, @dtmShiftStartTime, @dtmShiftEndTime)
			--END

			IF EXISTS (
					SELECT *
					FROM @tblMFScheduleWorkOrderDetail
					WHERE intCalendarDetailId = @intCalendarDetailId
						AND dtmPlannedEndDate BETWEEN @dtmShiftStartTime
							AND @dtmShiftEndTime and dtmPlannedEndDate<>@dtmShiftEndTime
					)
			BEGIN
				SELECT @dtmShiftStartTime = min(dtmPlannedEndDate)
				FROM @tblMFScheduleWorkOrderDetail
				WHERE intCalendarDetailId = @intCalendarDetailId

				--IF @dtmShiftStartTime IS NOT NULL
				SELECT @intDuration = DateDiff(minute, @dtmShiftStartTime, @dtmShiftEndTime)
					--Select @intDuration
			END

			IF @intDuration > @intWODuration
			BEGIN
				SELECT @dtmPlannedEndDate = DATEADD(MINUTE, @intWODuration, @dtmShiftStartTime)

				IF EXISTS (
						SELECT *
						FROM @tblMFScheduleWorkOrderDetail
						WHERE intWorkOrderId = @intWorkOrderId
						)
				BEGIN
					UPDATE @tblMFScheduleWorkOrder
					SET dtmPlannedEndDate = @dtmPlannedEndDate
					WHERE intWorkOrderId = @intWorkOrderId

					SELECT @intSequenceNo = @intSequenceNo + 1
				END
				ELSE
				BEGIN
					UPDATE @tblMFScheduleWorkOrder
					SET dtmPlannedStartDate = @dtmShiftStartTime
						,intPlannedShiftId = @intShiftId
						,dtmPlannedEndDate = @dtmPlannedEndDate
						,intDuration = @intWODuration
					WHERE intWorkOrderId = @intWorkOrderId

					SELECT @intSequenceNo = 1
				END

				INSERT INTO @tblMFScheduleWorkOrderDetail (
					intWorkOrderId
					,dtmPlannedStartDate
					,dtmPlannedEndDate
					,intPlannedShiftId
					,intDuration
					,dblPlannedQty
					,intSequenceNo
					,intCalendarDetailId
					)
				SELECT @intWorkOrderId
					,@dtmShiftStartTime
					,@dtmPlannedEndDate
					,@intShiftId
					,@intWODuration
					,(@intWODuration * @dblMachineCapacity) / @dblConversionFactor
					,@intSequenceNo
					,@intCalendarDetailId

				INSERT INTO @tblMFScheduleMachineDetail (
					intWorkOrderId
					,intCalendarDetailId
					,intCalendarMachineId
					)
				SELECT TOP (@intNoOfSelectedMachine) @intWorkOrderId
					,@intCalendarDetailId
					,intCalendarMachineId
				FROM dbo.tblMFScheduleCalendarMachineDetail MD
				WHERE intCalendarDetailId = @intCalendarDetailId

				UPDATE @tblMFScheduleWorkOrder
				SET intNoOfUnit = 0
				WHERE intRecordId = @intRecordId
					--SELECT @dtmShiftStartTime = @dtmPlannedEndDate
					--SELECT @intDuration = @intDuration - @intWODuration
			END
			ELSE
			BEGIN
				IF EXISTS (
						SELECT *
						FROM @tblMFScheduleWorkOrderDetail
						WHERE intWorkOrderId = @intWorkOrderId
						)
				BEGIN
					UPDATE @tblMFScheduleWorkOrder
					SET dtmPlannedEndDate = @dtmShiftEndTime
					WHERE intWorkOrderId = @intWorkOrderId

					SELECT @intSequenceNo = @intSequenceNo + 1
				END
				ELSE
				BEGIN
					UPDATE @tblMFScheduleWorkOrder
					SET dtmPlannedStartDate = @dtmShiftStartTime
						,intPlannedShiftId = @intShiftId
						,dtmPlannedEndDate = @dtmShiftEndTime
						,intDuration = CASE 
							WHEN intDuration IS NULL
								THEN @intWODuration
							ELSE intDuration
							END
					WHERE intWorkOrderId = @intWorkOrderId

					SELECT @intSequenceNo = 1
				END

				INSERT INTO @tblMFScheduleWorkOrderDetail (
					intWorkOrderId
					,dtmPlannedStartDate
					,dtmPlannedEndDate
					,intPlannedShiftId
					,intDuration
					,dblPlannedQty
					,intSequenceNo
					,intCalendarDetailId
					)
				SELECT @intWorkOrderId
					,@dtmShiftStartTime
					,@dtmShiftEndTime
					,@intShiftId
					,@intDuration
					,(@intDuration * @dblMachineCapacity) / @dblConversionFactor
					,@intSequenceNo
					,@intCalendarDetailId

				INSERT INTO @tblMFScheduleMachineDetail (
					intWorkOrderId
					,intCalendarDetailId
					,intCalendarMachineId
					)
				SELECT TOP (@intNoOfSelectedMachine) @intWorkOrderId
					,@intCalendarDetailId
					,intCalendarMachineId
				FROM dbo.tblMFScheduleCalendarMachineDetail MD
				WHERE intCalendarDetailId = @intCalendarDetailId

				UPDATE @tblMFScheduleWorkOrder
				SET intNoOfUnit = intNoOfUnit - (@intDuration * @dblMachineCapacity)
				WHERE intRecordId = @intRecordId

				BREAK
			END

			SELECT @intRecordId = Min(intRecordId)
			FROM @tblMFScheduleWorkOrder S
			WHERE S.intNoOfUnit > 0 AND intManufacturingCellId =@intManufacturingCellId AND S.intStatusId<>1 
				AND NOT EXISTS (
					SELECT *
					FROM @tblMFScheduleWorkOrderDetail SD
					WHERE SD.intWorkOrderId = S.intWorkOrderId
						AND SD.intCalendarDetailId = @intCalendarDetailId
					)
		END

		--SELECT @intCalendarDetailId '@intCalendarDetailId'
		--	,@intDuration * @intNoOfMachine AS avl
		--SELECT @intCalendarDetailId '@intCalendarDetailId'
		--	,SUM(SD.intDuration) AS actual
		--FROM @tblMFScheduleWorkOrderDetail SD
		--WHERE SD.intCalendarDetailId = @intCalendarDetailId
		IF NOT EXISTS (
				SELECT *
				FROM @tblMFScheduleWorkOrder S
				WHERE S.intNoOfUnit > 0 AND S.intStatusId<>1 
				)
			BREAK

		IF (
				SELECT SUM(SD.intDuration * @intNoOfSelectedMachine)
				FROM @tblMFScheduleWorkOrderDetail SD
				JOIN @tblMFScheduleWorkOrder S ON S.intWorkOrderId = SD.intWorkOrderId
				WHERE SD.intCalendarDetailId = @intCalendarDetailId
				) >= @intDuration * @intNoOfMachine
		OR NOT EXISTS (
		SELECT *
		FROM @tblMFScheduleWorkOrder S
		WHERE intNoOfUnit > 0 AND S.intStatusId<>1 
			AND intWorkOrderId <> @intWorkOrderId
		)
		BEGIN
			SELECT @intCalendarDetailId = Min(intCalendarDetailId)
			FROM @tblMFScheduleWorkOrderCalendarDetail
			WHERE intCalendarDetailId > @intCalendarDetailId
		END
	END

	IF EXISTS (
		SELECT *
		FROM @tblMFScheduleWorkOrder S
		WHERE intNoOfUnit > 0 AND S.intStatusId<>1 
		)
	BEGIN
		SELECT @intWorkOrderId =intWorkOrderId 
		FROM @tblMFScheduleWorkOrder S
		WHERE intNoOfUnit > 0 AND S.intStatusId<>1 

		Select @strWorkOrderNo =strWorkOrderNo 
		From tblMFWorkOrder
		Where intWorkOrderId =@intWorkOrderId 

		RAISERROR(51185,11,1,@strWorkOrderNo)
		RETURN
	END

	IF @intScheduleId>0
	BEGIN
		SELECT S.intScheduleId
			,S.strScheduleNo
			,S.dtmScheduleDate
			,S.intCalendarId
			,SC.strName
			,S.intManufacturingCellId
			,MC.strCellName
			,S.ysnStandard
			,S.intLocationId
			,S.intConcurrencyId
			,S.dtmCreated
			,S.intCreatedUserId
			,S.dtmLastModified
			,S.intLastModifiedUserId
		FROM tblMFSchedule S
		JOIN dbo.tblMFManufacturingCell MC ON MC.intManufacturingCellId = S.intManufacturingCellId
		JOIN dbo.tblMFScheduleCalendar SC ON SC.intCalendarId = S.intCalendarId
		WHERE intScheduleId = @intScheduleId
	END
	ELSE
	BEGIN
		SELECT 0 AS intScheduleId
		,'' AS strScheduleNo
		,@dtmCurrentDate AS dtmScheduleDate
		,@intCalendarId AS intCalendarId
		,'' AS strName
		,@intManufacturingCellId AS intManufacturingCellId
		,'' AS strCellName
		,CONVERT(bit,0) AS ysnStandard
		,@intLocationId AS intLocationId
		,0 AS intConcurrencyId
		,@dtmCurrentDate AS dtmCreated
		,0 AS intCreatedUserId
		,@dtmCurrentDate AS dtmLastModified
		,0 AS intLastModifiedUserId
	END


	SELECT C.intManufacturingCellId
		,C.strCellName
		,W.intWorkOrderId
		,@intScheduleId AS intScheduleId
		,W.strWorkOrderNo
		,IsNULL(SL.dblQuantity,W.dblQuantity) as dblQuantity
		,Isnull(SL.dtmExpectedDate,W.dtmExpectedDate) as dtmExpectedDate
		,IsNULL(SL.dblQuantity,W.dblQuantity) - W.dblProducedQuantity AS dblBalanceQuantity
		,W.dblProducedQuantity
		,W.strComment AS strWorkOrderComments
		,W.dtmOrderDate
		,(
			SELECT TOP 1 strItemNo
			FROM dbo.tblMFRecipeItem RI
			JOIN dbo.tblICItem WI ON RI.intItemId = WI.intItemId
			WHERE RI.intRecipeId = R.intRecipeId
				AND WI.strType = 'Assembly/Blend'
			) AS strWIPItemNo
			,I.intItemId
		,I.strItemNo
		,I.strDescription
		,IU.intItemUOMId
		,U.intUnitMeasureId
		,U.strUnitMeasure
		,IsNull(WS.intStatusId,1) as intStatusId
		,IsNull(WS.strName,'New') AS strStatusName
		,PT.intProductionTypeId
		,PT.strName AS strProductionType
		,SL.intScheduleWorkOrderId
		,SL.intDuration
		,SL.dtmChangeoverStartDate
		,SL.dtmChangeoverEndDate
		,SL.dtmPlannedStartDate
		,SL.dtmPlannedEndDate
		,SL.intExecutionOrder
		,SL.intChangeoverDuration
		,SL.intSetupDuration
		,SL.strComments
		,SL.strNote
		,SL.strAdditionalComments
		,SL.intNoOfSelectedMachine
		,SL.dtmEarliestStartDate
		,SL.intPlannedShiftId
		,SL.ysnFrozen
		,SH.strShiftName
		,P.intPackTypeId
		,P.strPackName
		,Isnull(SL.intConcurrencyId, 0) AS intConcurrencyId
		,@dtmCurrentDate dtmCreated
		,@intUserId intCreatedUserId
		,@dtmCurrentDate dtmLastModified
		,@intUserId intLastModifiedUserId
		,WS.intSequenceNo
	FROM tblMFWorkOrder W
	JOIN dbo.tblICItem I ON I.intItemId = W.intItemId AND W.intManufacturingCellId = @intManufacturingCellId AND W.intStatusId <> 13
	LEFT JOIN tblMFPackType P ON P.intPackTypeId = I.intPackTypeId
	JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = W.intItemUOMId
	JOIN dbo.tblICUnitMeasure U ON U.intUnitMeasureId = IU.intUnitMeasureId
	JOIN dbo.tblMFWorkOrderProductionType PT ON PT.intProductionTypeId = W.intProductionTypeId
	LEFT JOIN @tblMFScheduleWorkOrder SL ON SL.intWorkOrderId = W.intWorkOrderId
	LEFT JOIN dbo.tblMFWorkOrderStatus WS ON WS.intStatusId = SL.intStatusId
	LEFT JOIN dbo.tblMFShift SH ON SH.intShiftId = SL.intPlannedShiftId
	LEFT JOIN dbo.tblMFManufacturingCell C ON C.intManufacturingCellId = ISNULL(SL.intManufacturingCellId,W.intManufacturingCellId)
	JOIN dbo.tblMFRecipe R ON R.intItemId = W.intItemId
		AND R.intLocationId = W.intLocationId
		AND R.ysnActive = 1
	ORDER BY WS.intSequenceNo DESC
		,SL.intExecutionOrder

	SELECT 0 AS intScheduleWorkOrderDetailId
		,0 AS intScheduleWorkOrderId
		,intWorkOrderId
		,@intScheduleId AS intScheduleId
		,dtmPlannedStartDate
		,dtmPlannedEndDate
		,intPlannedShiftId
		,intDuration
		,dblPlannedQty
		,intSequenceNo
		,intCalendarDetailId
		,@intConcurrencyId as intConcurrencyId
	FROM @tblMFScheduleWorkOrderDetail

	SELECT 0 AS intScheduleMachineDetailId
		,0 AS intScheduleWorkOrderDetailId
		,intWorkOrderId
		,@intScheduleId AS intScheduleId
		,intCalendarMachineId
		,intCalendarDetailId
		,@intConcurrencyId as intConcurrencyId
	FROM @tblMFScheduleMachineDetail

	SELECT 0 AS intScheduleConstraintDetailId
		,0 AS intScheduleWorkOrderId
		,intWorkOrderId
		,@intScheduleId AS intScheduleId
		,intScheduleRuleId
		,dtmChangeoverStartDate
		,dtmChangeoverEndDate
		,intDuration
		,@intConcurrencyId as intConcurrencyId
	FROM @tblMFScheduleConstraintDetail

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
