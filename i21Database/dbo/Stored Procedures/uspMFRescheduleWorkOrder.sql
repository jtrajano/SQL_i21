CREATE PROCEDURE uspMFRescheduleWorkOrder (@strXML NVARCHAR(MAX))
AS
BEGIN TRY
	SET NOCOUNT ON

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
		,@intLocationId INT
		,@strWorkOrderNo NVARCHAR(50)
		,@strCellName NVARCHAR(50)
		,@strPackName NVARCHAR(50)
		,@intItemId INT
		,@strItemNo NVARCHAR(50)
		,@dtmEarliestStartDate DATETIME
		,@intGapDuetoEarliestStartDate INT
		,@ysnStandard BIT
		,@intShiftBreakTypeDuration INT
		,@dtmFromDate DATETIME
		,@dtmToDate DATETIME
		,@intPreviousWorkOrderId INT
		,@dtmChangeoverStartDate DATETIME
		,@dtmChangeoverEndDate DATETIME
		,@intChangeoverDuration INT
		,@tblMFScheduleWorkOrder AS ScheduleWorkOrderTable
		,@sqlCommand NVARCHAR(MAX)

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
		,@intScheduleId = Isnull(intScheduleId, 0)
		,@intConcurrencyId = intConcurrencyId
		,@intUserId = intUserId
		,@intLocationId = intLocationId
		,@ysnStandard = ysnStandard
		,@dtmFromDate = dtmFromDate
		,@dtmToDate = dtmToDate
	FROM OPENXML(@idoc, 'root', 2) WITH (
			intManufacturingCellId INT
			,intCalendarId INT
			,intScheduleId INT
			,intConcurrencyId INT
			,intUserId INT
			,intLocationId INT
			,ysnStandard BIT
			,dtmFromDate DATETIME
			,dtmToDate DATETIME
			)

	IF EXISTS (
			SELECT *
			FROM OPENXML(@idoc, 'root/WorkOrders/WorkOrder', 2) WITH (
					intPackTypeId INT
					,intStatusId INT
					) x
			WHERE x.intPackTypeId IS NULL
				AND intStatusId <> 1
			)
	BEGIN
		SELECT @intWorkOrderId = intWorkOrderId
			,@intItemId = intItemId
		FROM OPENXML(@idoc, 'root/WorkOrders/WorkOrder', 2) WITH (
				intWorkOrderId INT
				,intItemId INT
				,intStatusId INT
				,intPackTypeId INT
				,intExecutionOrder INT
				) x
		WHERE x.intPackTypeId IS NULL
			AND intStatusId <> 1
		ORDER BY intExecutionOrder DESC

		SELECT @strWorkOrderNo = strWorkOrderNo
		FROM dbo.tblMFWorkOrder
		WHERE intWorkOrderId = @intWorkOrderId

		SELECT @strItemNo = strItemNo
		FROM dbo.tblICItem
		WHERE intItemId = @intItemId

		RAISERROR (
				51188
				,11
				,1
				,@strItemNo
				,@strWorkOrderNo
				)

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
	ORDER BY x.intExecutionOrder

	IF EXISTS (
			SELECT *
			FROM @tblMFScheduleWorkOrder
			WHERE intPackTypeId IS NULL
				AND intStatusId <> 1
				AND dblBalance > 0
			)
	BEGIN
		SELECT @intWorkOrderId = intWorkOrderId
		FROM @tblMFScheduleWorkOrder
		WHERE intPackTypeId IS NULL
			AND intStatusId <> 1
			AND dblBalance > 0
		ORDER BY intExecutionOrder DESC

		SELECT @strWorkOrderNo = strWorkOrderNo
		FROM tblMFWorkOrder
		WHERE intWorkOrderId = @intWorkOrderId

		SELECT @strCellName = strCellName
		FROM tblMFManufacturingCell
		WHERE intManufacturingCellId = @intManufacturingCellId

		SELECT @intPackTypeId = intPackTypeId
		FROM OPENXML(@idoc, 'root/WorkOrders/WorkOrder', 2) WITH (
				intWorkOrderId INT
				,intPackTypeId INT
				) x
		WHERE x.intWorkOrderId = @intWorkOrderId

		SELECT @strPackName = strPackName
		FROM tblMFPackType
		WHERE intPackTypeId = @intPackTypeId

		RAISERROR (
				51186
				,11
				,1
				,@strPackName
				,@strWorkOrderNo
				,@strCellName
				)

		RETURN
	END

	IF EXISTS (
			SELECT *
			FROM @tblMFScheduleWorkOrder
			WHERE dblConversionFactor IS NULL
				AND intStatusId <> 1
				AND dblBalance > 0
			)
	BEGIN
		SELECT @intWorkOrderId = intWorkOrderId
		FROM @tblMFScheduleWorkOrder
		WHERE dblConversionFactor IS NULL
			AND intStatusId <> 1
			AND dblBalance > 0
		ORDER BY intExecutionOrder DESC

		SELECT @strWorkOrderNo = strWorkOrderNo
		FROM tblMFWorkOrder
		WHERE intWorkOrderId = @intWorkOrderId

		RAISERROR (
				51187
				,11
				,1
				,@strWorkOrderNo
				)

		RETURN
	END

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
		AND C.intCalendarId = @intCalendarId
		AND CD.dtmShiftEndTime > @dtmCurrentDate

	SELECT @intCalendarDetailId = MIN(intCalendarDetailId)
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
			,@intGapDuetoEarliestStartDate = 0

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

			SELECT @intDuration = DATEDIFF(MINUTE, @dtmShiftStartTime, @dtmShiftEndTime)
		END

		SELECT @intRecordId = MIN(intRecordId)
		FROM @tblMFScheduleWorkOrder S
		WHERE S.intNoOfUnit > 0
			AND intManufacturingCellId = @intManufacturingCellId
			AND S.intStatusId <> 1
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
				,@dtmEarliestStartDate = NULL
				,@intChangeoverDuration = NULL

			SELECT @intWorkOrderId = intWorkOrderId
				,@intNoOfUnit = intNoOfUnit
				,@intPackTypeId = intPackTypeId
				,@dblBalance = dblBalance
				,@dblConversionFactor = dblConversionFactor
				,@intNoOfSelectedMachine = intNoOfSelectedMachine
				,@dtmEarliestStartDate = dtmEarliestStartDate
			FROM @tblMFScheduleWorkOrder
			WHERE intRecordId = @intRecordId

			IF @dtmEarliestStartDate IS NOT NULL
				AND @dtmEarliestStartDate >= @dtmShiftEndTime
			BEGIN
				SELECT @intCalendarDetailId = Min(intCalendarDetailId)
				FROM @tblMFScheduleWorkOrderCalendarDetail
				WHERE intCalendarDetailId > @intCalendarDetailId

				BREAK
			END

			IF @dtmEarliestStartDate IS NOT NULL
				AND @dtmEarliestStartDate >= @dtmShiftStartTime
			BEGIN
				SELECT @intGapDuetoEarliestStartDate = DateDiff(minute, @dtmShiftStartTime, @dtmEarliestStartDate)

				SELECT @dtmShiftStartTime = @dtmEarliestStartDate

				SELECT @intDuration = DateDiff(minute, @dtmEarliestStartDate, @dtmShiftEndTime)
			END

			SELECT @dblMachineCapacity = SUM(DT.dblMachineCapacity)
			FROM (
				SELECT TOP (@intNoOfSelectedMachine) MP.dblMachineCapacity
				FROM dbo.tblMFScheduleCalendarMachineDetail MD
				JOIN dbo.tblMFMachinePackType MP ON MP.intMachineId = MD.intMachineId
				WHERE intCalendarDetailId = @intCalendarDetailId
					AND MP.intPackTypeId = @intPackTypeId
				) AS DT

			SELECT @intWODuration = @intNoOfUnit / @dblMachineCapacity

			IF EXISTS (
					SELECT *
					FROM @tblMFScheduleWorkOrderDetail
					WHERE intCalendarDetailId = @intCalendarDetailId
						AND dtmPlannedEndDate BETWEEN @dtmShiftStartTime
							AND @dtmShiftEndTime
						AND dtmPlannedEndDate <> @dtmShiftEndTime
					)
			BEGIN
				SELECT @dtmShiftStartTime = MIN(dtmPlannedEndDate)
					,@intPreviousWorkOrderId = MIN(intWorkOrderId)
				FROM @tblMFScheduleWorkOrderDetail
				WHERE intCalendarDetailId = @intCalendarDetailId

				SELECT @intDuration = DateDiff(minute, @dtmShiftStartTime, @dtmShiftEndTime)
			END

			DECLARE @intScheduleRuleId INT
				,@strColumnName NVARCHAR(50)
				,@strColumnValue NVARCHAR(50)
				,@strPreviousColumnValue NVARCHAR(50)
				,@intChangeoverTime INT

			SELECT @intScheduleRuleId = MIN(R.intScheduleRuleId)
			FROM dbo.tblMFScheduleRule R
			WHERE R.ysnActive = 1
				AND R.intScheduleRuleTypeId = 1

			WHILE @intScheduleRuleId IS NOT NULL
			BEGIN
				SELECT @strColumnName = NULL

				SELECT @strColumnName = A.strColumnName
				FROM dbo.tblMFScheduleRule R
				JOIN dbo.tblMFScheduleAttribute A ON A.intScheduleAttributeId = R.intScheduleAttributeId
				WHERE R.intScheduleRuleId = @intScheduleRuleId

				SET @sqlCommand = 'SELECT @strColumnValue = ' + @strColumnName + '
									FROM @tblMFScheduleWorkOrder
									WHERE intWorkOrderId = ' + @intWorkOrderId

				EXECUTE sp_executesql @sqlCommand
					,N'@strColumnValue nvarchar(50) OUTPUT'
					,@strColumnValue = @strColumnValue OUTPUT

				SET @sqlCommand = 'SELECT @strPreviousColumnValue = ' + @strColumnName + '
									FROM @tblMFScheduleWorkOrder
									WHERE intWorkOrderId = ' + @intPreviousWorkOrderId

				EXECUTE sp_executesql @sqlCommand
					,N'@strColumnValue nvarchar(50) OUTPUT'
					,@strPreviousColumnValue = @strPreviousColumnValue OUTPUT

				IF @strColumnValue <> @strPreviousColumnValue
				BEGIN
					SELECT @intChangeoverTime = NULL

					SELECT TOP 1 @intChangeoverTime = FD.dblChangeoverTime
					FROM dbo.tblMFScheduleChangeoverFactorDetail(NOLOCK) FD
					JOIN dbo.tblMFScheduleGroupDetail(NOLOCK) FG ON FD.intFromScheduleGroupId = FG.intScheduleGroupId
					JOIN dbo.tblMFScheduleGroupDetail(NOLOCK) TG ON FD.intToScheduleGroupId = TG.intScheduleGroupId
					JOIN dbo.tblMFScheduleChangeoverFactor(NOLOCK) F ON F.intChangeoverFactorId = FD.intChangeoverFactorId
					WHERE F.intManufacturingCellId = @intManufacturingCellId
						AND FG.strGroupValue = @strPreviousColumnValue
						AND TG.strGroupValue = @strColumnValue

					IF @intChangeoverTime IS NOT NULL
					BEGIN
						SELECT @dtmPlannedEndDate = DATEADD(MINUTE, @intChangeoverTime, @dtmShiftStartTime)

						SELECT @intShiftBreakTypeDuration = NULL

						SELECT @intShiftBreakTypeDuration = SUM(intShiftBreakTypeDuration)
						FROM dbo.tblMFShiftDetail
						WHERE intShiftId = @intShiftId
							AND @dtmCalendarDate + dtmShiftBreakTypeStartTime >= @dtmShiftStartTime
							AND @dtmCalendarDate + dtmShiftBreakTypeEndTime <= @dtmPlannedEndDate

						SELECT @intShiftBreakTypeDuration = ISNULL(@intShiftBreakTypeDuration, 0) + DATEDIFF(MINUTE, @dtmCalendarDate + dtmShiftBreakTypeStartTime, @dtmPlannedEndDate)
						FROM dbo.tblMFShiftDetail
						WHERE intShiftId = @intShiftId
							AND @dtmPlannedEndDate BETWEEN @dtmCalendarDate + dtmShiftBreakTypeStartTime
								AND @dtmCalendarDate + dtmShiftBreakTypeEndTime

						IF @intShiftBreakTypeDuration IS NOT NULL
							SELECT @dtmPlannedEndDate = DATEADD(MINUTE, @intShiftBreakTypeDuration, @dtmPlannedEndDate)

						INSERT INTO @tblMFScheduleConstraintDetail (
							intWorkOrderId
							,intScheduleRuleId
							,dtmChangeoverStartDate
							,dtmChangeoverEndDate
							,intDuration
							)
						VALUES (
							@intWorkOrderId
							,@intScheduleRuleId
							,@dtmShiftStartTime
							,@dtmPlannedEndDate
							,@intChangeoverTime
							)

						SELECT @dtmShiftStartTime = @dtmPlannedEndDate

						SELECT @intDuration = DATEDIFF(MINUTE, @dtmShiftStartTime, @dtmShiftEndTime)
					END
				END

				SELECT @intScheduleRuleId = MIN(R.intScheduleRuleId)
				FROM dbo.tblMFScheduleRule R
				WHERE R.ysnActive = 1
					AND R.intScheduleRuleTypeId = 1
					AND R.intScheduleRuleId > @intScheduleRuleId
			END

			IF EXISTS (
					SELECT *
					FROM @tblMFScheduleConstraintDetail
					WHERE intWorkOrderId = @intWorkOrderId
					)
			BEGIN
				SELECT @intChangeoverDuration = SUM(intDuration)
					,@dtmChangeoverStartDate = MIN(dtmChangeoverStartDate)
					,@dtmChangeoverEndDate = MAX(dtmChangeoverEndDate)
				FROM @tblMFScheduleConstraintDetail
				WHERE intWorkOrderId = @intWorkOrderId

				UPDATE @tblMFScheduleWorkOrder
				SET dtmChangeoverStartDate = @dtmChangeoverStartDate
					,dtmChangeoverEndDate = @dtmChangeoverEndDate
					,intChangeoverDuration = @intChangeoverDuration
				WHERE intWorkOrderId = @intWorkOrderId
			END

			IF @intDuration > @intWODuration
			BEGIN
				SELECT @dtmPlannedEndDate = DATEADD(MINUTE, @intWODuration, @dtmShiftStartTime)

				SELECT @intShiftBreakTypeDuration = NULL

				SELECT @intShiftBreakTypeDuration = SUM(intShiftBreakTypeDuration)
				FROM dbo.tblMFShiftDetail
				WHERE intShiftId = @intShiftId
					AND @dtmCalendarDate + dtmShiftBreakTypeStartTime >= @dtmShiftStartTime
					AND @dtmCalendarDate + dtmShiftBreakTypeEndTime <= @dtmPlannedEndDate

				SELECT @intShiftBreakTypeDuration = ISNULL(@intShiftBreakTypeDuration, 0) + DATEDIFF(MINUTE, @dtmCalendarDate + dtmShiftBreakTypeStartTime, @dtmPlannedEndDate)
				FROM dbo.tblMFShiftDetail
				WHERE intShiftId = @intShiftId
					AND @dtmPlannedEndDate BETWEEN @dtmCalendarDate + dtmShiftBreakTypeStartTime
						AND @dtmCalendarDate + dtmShiftBreakTypeEndTime

				IF @intShiftBreakTypeDuration IS NOT NULL
					SELECT @dtmPlannedEndDate = DATEADD(MINUTE, @intShiftBreakTypeDuration, @dtmPlannedEndDate)

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

			SELECT @intPreviousWorkOrderId = @intWorkOrderId

			SELECT @intRecordId = Min(intRecordId)
			FROM @tblMFScheduleWorkOrder S
			WHERE S.intNoOfUnit > 0
				AND intManufacturingCellId = @intManufacturingCellId
				AND S.intStatusId <> 1
				AND NOT EXISTS (
					SELECT *
					FROM @tblMFScheduleWorkOrderDetail SD
					WHERE SD.intWorkOrderId = S.intWorkOrderId
						AND SD.intCalendarDetailId = @intCalendarDetailId
					)
		END

		IF NOT EXISTS (
				SELECT *
				FROM @tblMFScheduleWorkOrder S
				WHERE S.intNoOfUnit > 0
					AND S.intStatusId <> 1
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
				WHERE intNoOfUnit > 0
					AND S.intStatusId <> 1
					AND intWorkOrderId <> @intWorkOrderId
				)
			OR @intGapDuetoEarliestStartDate > 0
		BEGIN
			SELECT @intCalendarDetailId = Min(intCalendarDetailId)
			FROM @tblMFScheduleWorkOrderCalendarDetail
			WHERE intCalendarDetailId > @intCalendarDetailId
		END
	END

	IF EXISTS (
			SELECT *
			FROM @tblMFScheduleWorkOrder S
			WHERE intNoOfUnit > 0
				AND S.intStatusId <> 1
			)
	BEGIN
		SELECT @intWorkOrderId = intWorkOrderId
		FROM @tblMFScheduleWorkOrder S
		WHERE intNoOfUnit > 0
			AND S.intStatusId <> 1
		ORDER BY intExecutionOrder DESC

		SELECT @strWorkOrderNo = strWorkOrderNo
		FROM tblMFWorkOrder
		WHERE intWorkOrderId = @intWorkOrderId

		RAISERROR (
				51185
				,11
				,1
				,@strWorkOrderNo
				)

		RETURN
	END

	IF @intScheduleId > 0
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
			,@dtmFromDate AS dtmFromDate
			,@dtmToDate AS dtmToDate
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
			,@ysnStandard AS ysnStandard
			,@intLocationId AS intLocationId
			,0 AS intConcurrencyId
			,@dtmCurrentDate AS dtmCreated
			,0 AS intCreatedUserId
			,@dtmCurrentDate AS dtmLastModified
			,0 AS intLastModifiedUserId
			,@dtmFromDate AS dtmFromDate
			,@dtmToDate AS dtmToDate
	END

	SELECT C.intManufacturingCellId
		,C.strCellName
		,W.intWorkOrderId
		,@intScheduleId AS intScheduleId
		,W.strWorkOrderNo
		,IsNULL(SL.dblQuantity, W.dblQuantity) AS dblQuantity
		,Isnull(SL.dtmExpectedDate, W.dtmExpectedDate) AS dtmExpectedDate
		,IsNULL(SL.dblQuantity, W.dblQuantity) - W.dblProducedQuantity AS dblBalanceQuantity
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
		,IsNull(WS.intStatusId, 1) AS intStatusId
		,IsNull(WS.strName, 'New') AS strStatusName
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
		,W.ysnIngredientAvailable
	FROM tblMFWorkOrder W
	JOIN dbo.tblICItem I ON I.intItemId = W.intItemId
		AND W.intManufacturingCellId = @intManufacturingCellId
		AND W.intStatusId <> 13
	LEFT JOIN tblMFPackType P ON P.intPackTypeId = I.intPackTypeId
	JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = W.intItemUOMId
	JOIN dbo.tblICUnitMeasure U ON U.intUnitMeasureId = IU.intUnitMeasureId
	JOIN dbo.tblMFWorkOrderProductionType PT ON PT.intProductionTypeId = W.intProductionTypeId
	LEFT JOIN @tblMFScheduleWorkOrder SL ON SL.intWorkOrderId = W.intWorkOrderId
	LEFT JOIN dbo.tblMFWorkOrderStatus WS ON WS.intStatusId = SL.intStatusId
	LEFT JOIN dbo.tblMFShift SH ON SH.intShiftId = SL.intPlannedShiftId
	LEFT JOIN dbo.tblMFManufacturingCell C ON C.intManufacturingCellId = ISNULL(SL.intManufacturingCellId, W.intManufacturingCellId)
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
		,@intConcurrencyId AS intConcurrencyId
	FROM @tblMFScheduleWorkOrderDetail

	SELECT 0 AS intScheduleMachineDetailId
		,0 AS intScheduleWorkOrderDetailId
		,intWorkOrderId
		,@intScheduleId AS intScheduleId
		,intCalendarMachineId
		,intCalendarDetailId
		,@intConcurrencyId AS intConcurrencyId
	FROM @tblMFScheduleMachineDetail

	SELECT 0 AS intScheduleConstraintDetailId
		,0 AS intScheduleWorkOrderId
		,intWorkOrderId
		,@intScheduleId AS intScheduleId
		,intScheduleRuleId
		,dtmChangeoverStartDate
		,dtmChangeoverEndDate
		,intDuration
		,@intConcurrencyId AS intConcurrencyId
	FROM @tblMFScheduleConstraintDetail

	SELECT MC.intManufacturingCellId
		,MC.strCellName
		,W.intWorkOrderId
		,W.strWorkOrderNo
		,W.dblQuantity
		,W.dblQuantity - ISNULL(W.dblProducedQuantity, 0) AS dblBalanceQuantity
		,W.strComment AS strWorkOrderComment
		,W.dtmExpectedDate
		,W.dtmEarliestDate
		,W.dtmLatestDate
		,I.intItemId
		,I.strItemNo
		,I.strDescription
		,IU.intItemUOMId
		,U.intUnitMeasureId
		,U.strUnitMeasure
		,'' AS strAdditive
		,'' AS strAdditiveDesc
		,WS.intStatusId
		,WS.strName AS strStatusName
		,WS.strBackColorName
		,SL.intChangeoverDuration
		,SL.dtmPlannedStartDate
		,SL.dtmPlannedEndDate
		,SL.strComments AS strScheduleComment
		,SL.intExecutionOrder
		,SL.ysnFrozen
		,SH.intShiftId
		,SH.strShiftName
		,0 AS OrderLineItemId
		,CONVERT(BIT, 0) AS ysnAlternateLine
		,0 AS intByWhichDate
		,'' AS strCustOrderNo
		,'' AS strChangeover
		,0 AS intLeadTime
		,'' AS strCustomer
	FROM dbo.tblMFWorkOrder W
	JOIN dbo.tblMFWorkOrderStatus WS ON WS.intStatusId = W.intStatusId
	JOIN dbo.tblICItem I ON I.intItemId = W.intItemId
	JOIN dbo.tblICItemUOM IU ON IU.intItemId = I.intItemId
		AND IU.ysnStockUnit = 1
	JOIN dbo.tblICUnitMeasure U ON U.intUnitMeasureId = IU.intUnitMeasureId
	JOIN dbo.tblMFManufacturingCell MC ON MC.intManufacturingCellId = W.intManufacturingCellId
	JOIN @tblMFScheduleWorkOrder SL ON SL.intWorkOrderId = W.intWorkOrderId
	JOIN dbo.tblMFShift SH ON SH.intShiftId = SL.intPlannedShiftId
	WHERE W.intLocationId = 1
		AND MC.intManufacturingCellId = @intManufacturingCellId
		AND SL.dtmPlannedStartDate >= @dtmFromDate
		AND SL.dtmPlannedEndDate <= @dtmToDate

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
