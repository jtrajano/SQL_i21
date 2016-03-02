﻿CREATE PROCEDURE uspMFRescheduleAndSaveWorkOrder (
	@tblMFWorkOrder ScheduleTable READONLY
	,@dtmFromDate DATETIME
	,@dtmToDate DATETIME
	,@intUserId INT
	,@intChartManufacturingCellId int=0
	)
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
		,@dtmPlannedStartDate DATETIME
		,@dtmShiftStartTime DATETIME
		,@dtmShiftEndTime DATETIME
		,@intDuration INT
		,@intRemainingDuration INT
		,@intShiftId INT
		,@intNoOfMachine INT
		,@intAllottedNoOfMachine INT
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
		,@dtmCurrentDateTime DATETIME
		,@dtmCurrentDate DATETIME
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
		,@intPreviousWorkOrderId INT
		,@dtmChangeoverStartDate DATETIME
		,@dtmChangeoverEndDate DATETIME
		,@intChangeoverDuration INT
		,@tblMFScheduleWorkOrder AS ScheduleTable
		,@sqlCommand NVARCHAR(MAX)
		,@ysnConsiderSumOfChangeoverTime BIT
		,@intSetupDuration INT
		,@intMaxChangeoverTime INT
		,@dblStdLineEfficiency NUMERIC(18, 6)
		,@dtmExpectedDate DATETIME
		,@dtmLatestDate DATETIME
		,@dtmEarliestDate DATETIME
		,@dtmTargetDate DATETIME

	SELECT @dtmCurrentDateTime = GETDATE()

	SELECT @dtmCurrentDate = CONVERT(DATETIME, CONVERT(CHAR, @dtmCurrentDateTime, 101))

	SELECT @ysnConsiderSumOfChangeoverTime = ysnConsiderSumOfChangeoverTime
	FROM dbo.tblMFCompanyPreference

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
		intScheduleWorkOrderDetailId INT identity(1, 1)
		,intWorkOrderId INT NOT NULL
		,dtmPlannedStartDate DATETIME NOT NULL
		,dtmPlannedEndDate DATETIME NOT NULL
		,intPlannedShiftId INT NOT NULL
		,intDuration INT NOT NULL
		,dblPlannedQty NUMERIC(18, 6) NOT NULL
		,intSequenceNo INT NOT NULL
		,intCalendarDetailId INT NOT NULL
		,intNoOfSelectedMachine INT
		)
	DECLARE @tblMFScheduleMachineDetail TABLE (
		intScheduleMachineDetailId INT identity(1, 1)
		,intWorkOrderId INT
		,intCalendarDetailId INT
		,intCalendarMachineId INT
		)
	DECLARE @tblMFScheduleConstraintDetail TABLE (
		intScheduleConstraintDetailId INT identity(1, 1)
		,intWorkOrderId INT
		,intScheduleRuleId INT
		,dtmChangeoverStartDate DATETIME
		,dtmChangeoverEndDate DATETIME
		,intDuration INT
		)
	DECLARE @tblMFScheduleConstraint TABLE (
		intScheduleConstraintId INT identity(1, 1)
		,intScheduleRuleId INT
		,intPriorityNo INT
		)

	INSERT INTO @tblMFScheduleConstraint (
		intScheduleRuleId
		,intPriorityNo
		)
	SELECT intScheduleRuleId
		,intPriorityNo
	FROM tblMFScheduleRule
	WHERE ysnActive = 1
	ORDER BY intPriorityNo

	SELECT @intManufacturingCellId = MIN(intManufacturingCellId)
		,@intLocationId = MIN(intLocationId)
	FROM @tblMFWorkOrder

	WHILE @intManufacturingCellId IS NOT NULL
	BEGIN

		SELECT @intPreviousWorkOrderId = 0
		SELECT @intAllottedNoOfMachine = 0

		SELECT @intCalendarId = intCalendarId
		FROM tblMFScheduleCalendar
		WHERE intManufacturingCellId = @intManufacturingCellId
			AND ysnStandard = 1

		IF EXISTS (
				SELECT *
				FROM @tblMFWorkOrder W
				WHERE W.intPackTypeId IS NULL
					AND intStatusId <> 1
				)
		BEGIN
			SELECT @intWorkOrderId = intWorkOrderId
				,@intItemId = intItemId
			FROM @tblMFWorkOrder W
			WHERE W.intPackTypeId IS NULL
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
			,strPackName
			,intNoOfUnit
			,dblConversionFactor
			,intScheduleWorkOrderId
			,ysnFrozen
			,intConcurrencyId
			,strWIPItemNo
			,intSetupDuration
			,ysnPicked
			,intDemandRatio
			,dtmEarliestDate
			,dtmLatestDate
			,dtmTargetDate
			,intScheduleId
			)
		SELECT W.intManufacturingCellId
			,W.intWorkOrderId
			,W.intItemId
			,W.intItemUOMId
			,W.intUnitMeasureId
			,W.dblQuantity
			,W.dblBalance
			,W.dtmExpectedDate
			,W.intStatusId
			,W.intExecutionOrder
			,W.strComments
			,CASE 
				WHEN @dtmCurrentDate > W.dtmExpectedDate
					THEN 'Past Expected Date'
				END strNote
			,W.strAdditionalComments
			,W.intNoOfSelectedMachine
			,W.dtmEarliestStartDate
			,MC.intPackTypeId
			,P.strPackName
			,W.dblBalance * PTD.dblConversionFactor
			,PTD.dblConversionFactor
			,W.intScheduleWorkOrderId
			,W.ysnFrozen
			,@intConcurrencyId
			,W.strWIPItemNo
			,W.intSetupDuration
			,0 AS ysnPicked
			,W.intDemandRatio
			,W.dtmEarliestDate
			,W.dtmLatestDate
			,W.dtmTargetDate
			,W.intScheduleId
		FROM @tblMFWorkOrder W
		LEFT JOIN dbo.tblMFManufacturingCellPackType MC ON MC.intManufacturingCellId = W.intManufacturingCellId
			AND MC.intPackTypeId = W.intPackTypeId
		LEFT JOIN tblMFPackType P ON P.intPackTypeId = W.intPackTypeId
		LEFT JOIN dbo.tblMFPackTypeDetail PTD ON PTD.intPackTypeId = W.intPackTypeId
			AND PTD.intTargetUnitMeasureId = W.intUnitMeasureId
			AND PTD.intSourceUnitMeasureId = MC.intLineCapacityUnitMeasureId
		WHERE W.intManufacturingCellId = @intManufacturingCellId and W.dblBalance>0
		ORDER BY W.intManufacturingCellId
			,W.intExecutionOrder

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
			FROM @tblMFWorkOrder x
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
			--AND CD.dtmShiftEndTime > @dtmCurrentDateTime
			AND CD.intNoOfMachine > 0

		SELECT @intCalendarDetailId = MAX(intCalendarDetailId)
		FROM @tblMFScheduleWorkOrderCalendarDetail

		WHILE @intCalendarDetailId IS NOT NULL
		BEGIN
			SELECT @intCalendarId = NULL
				,@dtmCalendarDate = NULL
				,@dtmPlannedStartDate = NULL
				,@dtmShiftEndTime = NULL
				,@intDuration = NULL
				,@intRemainingDuration = NULL
				,@intShiftId = NULL
				,@intNoOfMachine = NULL
				,@intGapDuetoEarliestStartDate = 0

			SELECT @intCalendarDetailId = intCalendarDetailId
				,@intCalendarId = intCalendarId
				,@dtmCalendarDate = dtmCalendarDate
				,@dtmShiftStartTime = dtmShiftStartTime
				,@dtmShiftEndTime = dtmShiftEndTime
				,@dtmPlannedEndDate = dtmShiftEndTime
				,@intDuration = intDuration * intNoOfMachine
				,@intRemainingDuration = intDuration
				,@intShiftId = intShiftId
				,@intNoOfMachine = intNoOfMachine
			FROM @tblMFScheduleWorkOrderCalendarDetail
			WHERE intCalendarDetailId = @intCalendarDetailId

			SELECT @intRecordId = Max(intRecordId)
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
					,@intSetupDuration = NULL
					,@intMaxChangeoverTime = NULL
					,@dblStdLineEfficiency = NULL
					,@dtmEarliestDate=NULL
					,@dtmLatestDate=NULL
					,@dtmTargetDate=NULL
					
				SELECT @intWorkOrderId = intWorkOrderId
					,@intNoOfUnit = intNoOfUnit
					,@intPackTypeId = intPackTypeId
					,@dblBalance = dblBalance
					,@dblConversionFactor = dblConversionFactor
					,@intNoOfSelectedMachine = @intNoOfMachine
					,@dtmEarliestStartDate = dtmEarliestStartDate
					,@intSetupDuration = intSetupDuration
					,@dtmEarliestDate = dtmEarliestDate
					,@dtmLatestDate = dtmLatestDate
					,@dtmTargetDate = dtmTargetDate
				FROM @tblMFScheduleWorkOrder
				WHERE intRecordId = @intRecordId

				UPDATE @tblMFScheduleWorkOrder
				SET intNoOfSelectedMachine = @intNoOfMachine
				WHERE intRecordId = @intRecordId

				SELECT @dblStdLineEfficiency = dblLineEfficiencyRate
				FROM dbo.tblMFManufacturingCellPackType
				WHERE intManufacturingCellId = @intManufacturingCellId
					AND intPackTypeId = @intPackTypeId

				IF @dtmLatestDate IS NOT NULL
					AND @dtmShiftEndTime > @dtmLatestDate
				BEGIN
					SELECT @intCalendarDetailId = Max(intCalendarDetailId)
					FROM @tblMFScheduleWorkOrderCalendarDetail
					WHERE intCalendarDetailId < @intCalendarDetailId

					SELECT @intAllottedNoOfMachine = 0

					BREAK
				END

				IF @intNoOfSelectedMachine > @intNoOfMachine - @intAllottedNoOfMachine
					AND @intNoOfMachine - @intAllottedNoOfMachine > 0
				BEGIN
					SELECT @intNoOfSelectedMachine = @intNoOfMachine - @intAllottedNoOfMachine
				END

				SELECT @dtmPlannedEndDate = @dtmShiftEndTime

				IF 0 >= @intNoOfMachine - @intAllottedNoOfMachine
				BEGIN
					IF EXISTS (
							SELECT *
							FROM @tblMFScheduleWorkOrder
							WHERE dtmPlannedStartDate BETWEEN @dtmShiftStartTime
									AND @dtmShiftEndTime
								AND ysnPicked = 0
								AND dtmPlannedStartDate <> @dtmShiftStartTime
							)
					BEGIN
						SELECT TOP 1 @dtmPlannedEndDate = MAX(dtmPlannedStartDate)
							,@intPreviousWorkOrderId = MAX(intWorkOrderId)
						FROM @tblMFScheduleWorkOrder
						WHERE dtmPlannedStartDate BETWEEN @dtmShiftStartTime
								AND @dtmShiftEndTime
							AND ysnPicked = 0
							AND dtmPlannedStartDate <> @dtmShiftStartTime

						UPDATE @tblMFScheduleWorkOrder
						SET ysnPicked = 1
						WHERE intWorkOrderId = @intPreviousWorkOrderId

						SELECT @intRemainingDuration = DateDiff(minute, @dtmShiftStartTime, @dtmPlannedEndDate)

						IF @intRemainingDuration = 0
						BEGIN
							SELECT @intCalendarDetailId = MAX(intCalendarDetailId)
							FROM @tblMFScheduleWorkOrderCalendarDetail
							WHERE intCalendarDetailId < @intCalendarDetailId

							SELECT @intAllottedNoOfMachine = 0

							BREAK
						END
					END
				END

				--DECLARE @v XML = (SELECT * FROM @tblMFScheduleWorkOrderDetail FOR XML AUTO)

				SELECT @dblMachineCapacity = SUM(DT.dblMachineCapacity)
				FROM (
					SELECT TOP (@intNoOfSelectedMachine) MP.dblMachineCapacity
					FROM dbo.tblMFScheduleCalendarMachineDetail MD
					JOIN dbo.tblMFMachinePackType MP ON MP.intMachineId = MD.intMachineId
					WHERE intCalendarDetailId = @intCalendarDetailId
						AND MP.intPackTypeId = @intPackTypeId
						AND NOT EXISTS (
							SELECT *
							FROM @tblMFScheduleMachineDetail SMD
							JOIN @tblMFScheduleWorkOrderDetail WD ON WD.intCalendarDetailId = SMD.intCalendarDetailId
								AND SMD.intWorkOrderId = WD.intWorkOrderId
							WHERE SMD.intCalendarDetailId = @intCalendarDetailId
								AND SMD.intCalendarMachineId = MD.intCalendarMachineId
								AND DATEADD(MINUTE, -1, @dtmPlannedEndDate) BETWEEN WD.dtmPlannedStartDate
									AND WD.dtmPlannedEndDate
							)
					) AS DT

				IF @dblMachineCapacity IS NULL
				BEGIN
					SELECT @intCalendarDetailId = MAX(intCalendarDetailId)
					FROM @tblMFScheduleWorkOrderCalendarDetail
					WHERE intCalendarDetailId < @intCalendarDetailId

					SELECT @intAllottedNoOfMachine = 0

					BREAK
				END

				SELECT @dblMachineCapacity = @dblMachineCapacity * @dblStdLineEfficiency / 100

				SELECT @intWODuration = @intNoOfUnit / @dblMachineCapacity

				IF NOT EXISTS (
						SELECT *
						FROM @tblMFScheduleWorkOrderDetail
						WHERE intWorkOrderId = @intWorkOrderId
						)
				BEGIN
					IF @intSetupDuration IS NOT NULL
						AND @intSetupDuration > 0
						AND @ysnConsiderSumOfChangeoverTime = 1
					BEGIN
						SELECT @dtmPlannedStartDate = DATEADD(MINUTE, - @intSetupDuration, @dtmPlannedEndDate)

						SELECT @intShiftBreakTypeDuration = NULL

						SELECT @intShiftBreakTypeDuration = SUM(intShiftBreakTypeDuration)
						FROM dbo.tblMFShiftDetail
						WHERE intShiftId = @intShiftId
							AND @dtmCalendarDate + dtmShiftBreakTypeStartTime >= @dtmPlannedStartDate
							AND @dtmCalendarDate + dtmShiftBreakTypeEndTime <= @dtmPlannedEndDate

						SELECT @intShiftBreakTypeDuration = ISNULL(@intShiftBreakTypeDuration, 0) + DATEDIFF(MINUTE, @dtmCalendarDate + dtmShiftBreakTypeStartTime, @dtmPlannedEndDate)
						FROM dbo.tblMFShiftDetail
						WHERE intShiftId = @intShiftId
							AND @dtmPlannedEndDate BETWEEN @dtmCalendarDate + dtmShiftBreakTypeStartTime
								AND @dtmCalendarDate + dtmShiftBreakTypeEndTime

						IF @intShiftBreakTypeDuration IS NOT NULL
							SELECT @dtmPlannedStartDate = DATEADD(MINUTE, - @intShiftBreakTypeDuration, @dtmPlannedStartDate)

						SELECT @dtmPlannedEndDate = @dtmPlannedStartDate

						SELECT @intRemainingDuration = DATEDIFF(MINUTE, @dtmShiftStartTime, @dtmPlannedEndDate)
					END

					DECLARE @intScheduleConstraintId INT
						,@intScheduleRuleId INT
						,@strColumnName NVARCHAR(50)
						,@strColumnValue NVARCHAR(50)
						,@strPreviousColumnValue NVARCHAR(50)
						,@intChangeoverTime INT

					SELECT @intScheduleConstraintId = MIN(intScheduleConstraintId)
					FROM @tblMFScheduleConstraint

					WHILE @intScheduleConstraintId IS NOT NULL
					BEGIN
						SELECT @intScheduleRuleId = intScheduleRuleId
						FROM @tblMFScheduleConstraint
						WHERE intScheduleConstraintId = @intScheduleConstraintId

						SELECT @strColumnName = NULL

						SELECT @strColumnName = A.strColumnName
						FROM dbo.tblMFScheduleRule R
						JOIN dbo.tblMFScheduleAttribute A ON A.intScheduleAttributeId = R.intScheduleAttributeId
						WHERE R.intScheduleRuleId = @intScheduleRuleId

						SET @sqlCommand = 'SELECT @strColumnValue = ' + @strColumnName + '
										FROM @t
										WHERE intWorkOrderId = ' + ltrim(@intWorkOrderId)

						EXECUTE sp_executesql @sqlCommand
							,N'@t ScheduleTable READONLY,@strColumnValue nvarchar(50) OUTPUT'
							,@t = @tblMFScheduleWorkOrder
							,@strColumnValue = @strColumnValue OUTPUT

						SET @sqlCommand = 'SELECT @strPreviousColumnValue = ' + @strColumnName + '
										FROM @t
										WHERE intWorkOrderId = ' + ltrim(@intPreviousWorkOrderId)

						EXECUTE sp_executesql @sqlCommand
							,N'@t ScheduleTable READONLY, @strPreviousColumnValue nvarchar(50) OUTPUT'
							,@t = @tblMFScheduleWorkOrder
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
								IF @intMaxChangeoverTime IS NULL
									SELECT @intMaxChangeoverTime = 0

								IF @intChangeoverTime > @intMaxChangeoverTime
								BEGIN
									SELECT @intMaxChangeoverTime = @intChangeoverTime
								END

								SELECT @dtmPlannedStartDate = DATEADD(MINUTE, - @intChangeoverTime, @dtmPlannedEndDate)

								SELECT @intShiftBreakTypeDuration = NULL

								SELECT @intShiftBreakTypeDuration = SUM(intShiftBreakTypeDuration)
								FROM dbo.tblMFShiftDetail
								WHERE intShiftId = @intShiftId
									AND @dtmCalendarDate + dtmShiftBreakTypeStartTime >= @dtmPlannedStartDate
									AND @dtmCalendarDate + dtmShiftBreakTypeEndTime <= @dtmPlannedEndDate

								SELECT @intShiftBreakTypeDuration = ISNULL(@intShiftBreakTypeDuration, 0) + DATEDIFF(MINUTE, @dtmCalendarDate + dtmShiftBreakTypeStartTime, @dtmPlannedEndDate)
								FROM dbo.tblMFShiftDetail
								WHERE intShiftId = @intShiftId
									AND @dtmPlannedEndDate BETWEEN @dtmCalendarDate + dtmShiftBreakTypeStartTime
										AND @dtmCalendarDate + dtmShiftBreakTypeEndTime

								IF @intShiftBreakTypeDuration IS NOT NULL
									SELECT @dtmPlannedStartDate = DATEADD(MINUTE, - @intShiftBreakTypeDuration, @dtmPlannedStartDate)

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
									,@dtmPlannedStartDate
									,@dtmPlannedEndDate
									,@intChangeoverTime
									)

								IF @ysnConsiderSumOfChangeoverTime = 1
								BEGIN
									SELECT @dtmPlannedEndDate = @dtmPlannedStartDate

									SELECT @intRemainingDuration = DATEDIFF(MINUTE, @dtmShiftStartTime, @dtmPlannedEndDate)
								END
							END
						END

						SELECT @intScheduleConstraintId = MIN(intScheduleConstraintId)
						FROM @tblMFScheduleConstraint
						WHERE intScheduleConstraintId > @intScheduleConstraintId
					END

					IF @ysnConsiderSumOfChangeoverTime = 0
						AND (
							@intSetupDuration IS NOT NULL
							OR @intMaxChangeoverTime IS NOT NULL
							)
					BEGIN
						IF @intSetupDuration IS NULL
							SELECT @intSetupDuration = 0

						IF @intMaxChangeoverTime IS NULL
							SELECT @intMaxChangeoverTime = 0

						IF @intSetupDuration >= @intMaxChangeoverTime
						BEGIN
							SELECT @dtmPlannedStartDate = DATEADD(MINUTE, - @intSetupDuration, @dtmPlannedEndDate)

							UPDATE @tblMFScheduleConstraintDetail
							SET dtmChangeoverStartDate = NULL
								,dtmChangeoverEndDate = NULL
							WHERE intWorkOrderId = @intWorkOrderId
						END
						ELSE
						BEGIN
							SELECT @dtmPlannedStartDate = DATEADD(MINUTE, - @intMaxChangeoverTime, @dtmPlannedEndDate)
						END

						SELECT @intShiftBreakTypeDuration = NULL

						SELECT @intShiftBreakTypeDuration = SUM(intShiftBreakTypeDuration)
						FROM dbo.tblMFShiftDetail
						WHERE intShiftId = @intShiftId
							AND @dtmCalendarDate + dtmShiftBreakTypeStartTime >= @dtmPlannedStartDate
							AND @dtmCalendarDate + dtmShiftBreakTypeEndTime <= @dtmPlannedEndDate

						SELECT @intShiftBreakTypeDuration = ISNULL(@intShiftBreakTypeDuration, 0) + DATEDIFF(MINUTE, @dtmCalendarDate + dtmShiftBreakTypeStartTime, @dtmPlannedEndDate)
						FROM dbo.tblMFShiftDetail
						WHERE intShiftId = @intShiftId
							AND @dtmPlannedEndDate BETWEEN @dtmCalendarDate + dtmShiftBreakTypeStartTime
								AND @dtmCalendarDate + dtmShiftBreakTypeEndTime

						IF @intShiftBreakTypeDuration IS NOT NULL
							SELECT @dtmPlannedStartDate = DATEADD(MINUTE, - @intShiftBreakTypeDuration, @dtmPlannedStartDate)

						IF @intMaxChangeoverTime > @intSetupDuration
						BEGIN
							UPDATE @tblMFScheduleConstraintDetail
							SET dtmChangeoverStartDate = @dtmPlannedStartDate
								,dtmChangeoverEndDate = @dtmPlannedEndDate
							WHERE intWorkOrderId = @intWorkOrderId
								AND intDuration = @intMaxChangeoverTime
						END

						SELECT @dtmPlannedEndDate = @dtmPlannedStartDate

						SELECT @intRemainingDuration = DATEDIFF(MINUTE, @dtmShiftStartTime, @dtmPlannedEndDate)
					END

					IF EXISTS (
							SELECT *
							FROM @tblMFScheduleConstraintDetail
							WHERE intWorkOrderId = @intWorkOrderId
							)
					BEGIN
						SELECT @intChangeoverDuration = (
								CASE 
									WHEN @ysnConsiderSumOfChangeoverTime = 0
										THEN MAX(intDuration)
									ELSE SUM(intDuration)
									END
								)
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
				END

				IF @intRemainingDuration > @intWODuration
				BEGIN
					SELECT @dtmPlannedStartDate = DATEADD(MINUTE, - @intWODuration, @dtmPlannedEndDate)

					SELECT @intShiftBreakTypeDuration = NULL

					SELECT @intShiftBreakTypeDuration = SUM(intShiftBreakTypeDuration)
					FROM dbo.tblMFShiftDetail
					WHERE intShiftId = @intShiftId
						AND @dtmCalendarDate + dtmShiftBreakTypeStartTime >= @dtmPlannedStartDate
						AND @dtmCalendarDate + dtmShiftBreakTypeEndTime <= @dtmPlannedEndDate

					SELECT @intShiftBreakTypeDuration = ISNULL(@intShiftBreakTypeDuration, 0) + DATEDIFF(MINUTE, @dtmCalendarDate + dtmShiftBreakTypeStartTime, @dtmPlannedEndDate)
					FROM dbo.tblMFShiftDetail
					WHERE intShiftId = @intShiftId
						AND @dtmPlannedEndDate BETWEEN @dtmCalendarDate + dtmShiftBreakTypeStartTime
							AND @dtmCalendarDate + dtmShiftBreakTypeEndTime

					IF @intShiftBreakTypeDuration IS NOT NULL
						SELECT @dtmPlannedStartDate = DATEADD(MINUTE, -@intShiftBreakTypeDuration, @dtmPlannedStartDate)

					IF EXISTS (
							SELECT *
							FROM @tblMFScheduleWorkOrderDetail
							WHERE intWorkOrderId = @intWorkOrderId
							)
					BEGIN
						UPDATE @tblMFScheduleWorkOrder
						SET dtmPlannedStartDate = @dtmPlannedStartDate
						WHERE intWorkOrderId = @intWorkOrderId

						SELECT @intSequenceNo = @intSequenceNo + 1
					END
					ELSE
					BEGIN
						UPDATE @tblMFScheduleWorkOrder
						SET dtmPlannedStartDate = @dtmPlannedStartDate
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
						,intNoOfSelectedMachine
						)
					SELECT @intWorkOrderId
						,@dtmPlannedStartDate
						,@dtmPlannedEndDate
						,@intShiftId
						,@intWODuration
						,(@intWODuration * @dblMachineCapacity) / @dblConversionFactor
						,@intSequenceNo
						,@intCalendarDetailId
						,@intNoOfSelectedMachine

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
						AND NOT EXISTS (
							SELECT *
							FROM @tblMFScheduleMachineDetail SMD
							JOIN @tblMFScheduleWorkOrderDetail WD ON WD.intCalendarDetailId = SMD.intCalendarDetailId
								AND SMD.intWorkOrderId = WD.intWorkOrderId
							WHERE SMD.intCalendarDetailId = @intCalendarDetailId
								AND SMD.intCalendarMachineId = MD.intCalendarMachineId
								AND DATEADD(MINUTE, -1, @dtmPlannedEndDate) BETWEEN WD.dtmPlannedStartDate
									AND WD.dtmPlannedEndDate
							)

					UPDATE @tblMFScheduleWorkOrder
					SET intNoOfUnit = 0
					WHERE intRecordId = @intRecordId

					SELECT @intAllottedNoOfMachine = @intAllottedNoOfMachine + @intNoOfSelectedMachine

					SELECT @intPreviousWorkOrderId = @intWorkOrderId
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
						SET dtmPlannedStartDate = @dtmShiftStartTime
						WHERE intWorkOrderId = @intWorkOrderId

						SELECT @intSequenceNo = @intSequenceNo + 1
					END
					ELSE
					BEGIN
						UPDATE @tblMFScheduleWorkOrder
						SET dtmPlannedStartDate = @dtmShiftStartTime
							,intPlannedShiftId = @intShiftId
							,dtmPlannedEndDate = @dtmPlannedEndDate
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
						,intNoOfSelectedMachine
						)
					SELECT @intWorkOrderId
						,@dtmShiftStartTime
						,@dtmPlannedEndDate
						,@intShiftId
						,@intRemainingDuration
						,(@intRemainingDuration * @dblMachineCapacity) / @dblConversionFactor
						,@intSequenceNo
						,@intCalendarDetailId
						,@intNoOfSelectedMachine

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
						AND NOT EXISTS (
							SELECT *
							FROM @tblMFScheduleMachineDetail SMD
							JOIN @tblMFScheduleWorkOrderDetail WD ON WD.intCalendarDetailId = SMD.intCalendarDetailId
								AND SMD.intWorkOrderId = WD.intWorkOrderId
							WHERE SMD.intCalendarDetailId = @intCalendarDetailId
								AND SMD.intCalendarMachineId = MD.intCalendarMachineId
								AND DATEADD(MINUTE, -1, @dtmPlannedEndDate) BETWEEN WD.dtmPlannedStartDate
									AND WD.dtmPlannedEndDate
							)

					UPDATE @tblMFScheduleWorkOrder
					SET intNoOfUnit = intNoOfUnit - (@intRemainingDuration * @dblMachineCapacity)
					WHERE intRecordId = @intRecordId

					SELECT @intAllottedNoOfMachine = @intAllottedNoOfMachine + @intNoOfSelectedMachine

					SELECT @intPreviousWorkOrderId = @intWorkOrderId

					BREAK
				END

				SELECT @intRecordId = Max(intRecordId)
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
					SELECT SUM(SD.intDuration * SD.intNoOfSelectedMachine) + SUM(ISNULL(S.intChangeoverDuration, 0))
					FROM @tblMFScheduleWorkOrderDetail SD
					JOIN @tblMFScheduleWorkOrder S ON S.intWorkOrderId = SD.intWorkOrderId
					WHERE SD.intCalendarDetailId = @intCalendarDetailId
					) >= @intDuration
				OR NOT EXISTS (
					SELECT *
					FROM @tblMFScheduleWorkOrder S
					WHERE intNoOfUnit > 0
						AND S.intStatusId <> 1
						AND intWorkOrderId <> @intWorkOrderId
					)
				OR @intGapDuetoEarliestStartDate > 0
			BEGIN
				SELECT @intCalendarDetailId = Max(intCalendarDetailId)
				FROM @tblMFScheduleWorkOrderCalendarDetail
				WHERE intCalendarDetailId < @intCalendarDetailId

				SELECT @intAllottedNoOfMachine = 0
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

		SELECT @ysnStandard = 1

		DECLARE @intTransactionCount INT
			,@strScheduleNo NVARCHAR(50)

		SELECT @intTransactionCount = @@TRANCOUNT

		--IF @intTransactionCount = 0
		--	BEGIN TRANSACTION

		--IF @ysnStandard = 1
		--BEGIN
		--	UPDATE dbo.tblMFSchedule
		--	SET ysnStandard = 0
		--	WHERE intManufacturingCellId = @intManufacturingCellId
		--END
		SELECT @intScheduleId=NULL
		SELECT @intScheduleId=intScheduleId FROM dbo.tblMFSchedule WHERE intManufacturingCellId = @intManufacturingCellId AND ysnStandard =1

		If @intScheduleId is null
			SELECT @intScheduleId=intScheduleId FROM dbo.tblMFSchedule WHERE intManufacturingCellId = @intManufacturingCellId

		IF @intScheduleId IS NULL
		BEGIN
			IF @strScheduleNo IS NULL
			BEGIN
				DECLARE @intSubLocationId INT

				SELECT @intSubLocationId = intSubLocationId
				FROM dbo.tblMFManufacturingCell
				WHERE intManufacturingCellId = @intManufacturingCellId

				EXEC dbo.uspMFGeneratePatternId @intCategoryId = NULL
					,@intItemId = NULL
					,@intManufacturingId = @intManufacturingCellId
					,@intSubLocationId = @intSubLocationId
					,@intLocationId = @intLocationId
					,@intOrderTypeId = NULL
					,@intBlendRequirementId = NULL
					,@intPatternCode = 63
					,@ysnProposed = 0
					,@strPatternString = @strScheduleNo OUTPUT
			END

			INSERT INTO dbo.tblMFSchedule (
				strScheduleNo
				,dtmScheduleDate
				,intCalendarId
				,intManufacturingCellId
				,ysnStandard
				,intLocationId
				,intConcurrencyId
				,dtmCreated
				,intCreatedUserId
				,dtmLastModified
				,intLastModifiedUserId
				)
			VALUES (
				@strScheduleNo
				,@dtmCurrentDate
				,@intCalendarId
				,@intManufacturingCellId
				,@ysnStandard
				,@intLocationId
				,1
				,@dtmCurrentDate
				,@intUserId
				,@dtmCurrentDate
				,@intUserId
				)

			SELECT @intScheduleId = SCOPE_IDENTITY()
		END
		ELSE
		BEGIN
			--IF (
			--		SELECT intConcurrencyId
			--		FROM dbo.tblMFSchedule
			--		WHERE intScheduleId = @intScheduleId
			--		) <> @intConcurrencyId
			--BEGIN
			--	RAISERROR (
			--			51194
			--			,11
			--			,1
			--			)

			--	RETURN
			--END

			UPDATE dbo.tblMFSchedule
			SET ysnStandard = @ysnStandard
				,intConcurrencyId = intConcurrencyId + 1
				,dtmLastModified = @dtmCurrentDate
				,intLastModifiedUserId = @intUserId
			WHERE intScheduleId = @intScheduleId
		END

		SELECT @intConcurrencyId = intConcurrencyId
		FROM dbo.tblMFSchedule
		WHERE intScheduleId = @intScheduleId

		DELETE
		FROM dbo.tblMFScheduleWorkOrder
		WHERE intScheduleId = @intScheduleId

		INSERT INTO dbo.tblMFScheduleWorkOrder (
			intScheduleId
			,intWorkOrderId
			,intStatusId
			,intDuration
			,intExecutionOrder
			,intChangeoverDuration
			,intSetupDuration
			,dtmChangeoverStartDate
			,dtmChangeoverEndDate
			,dtmPlannedStartDate
			,dtmPlannedEndDate
			,intPlannedShiftId
			,intNoOfSelectedMachine
			,strComments
			,strNote
			,strAdditionalComments
			,dtmEarliestStartDate
			,ysnFrozen
			,intConcurrencyId
			,dtmCreated
			,intCreatedUserId
			,dtmLastModified
			,intLastModifiedUserId
			)
		SELECT @intScheduleId
			,x.intWorkOrderId
			,x.intStatusId
			,x.intDuration
			,ROW_NUMBER() OVER (
				ORDER BY x.intExecutionOrder
				) AS intExecutionOrder
			,x.intChangeoverDuration
			,x.intSetupDuration
			,x.dtmChangeoverStartDate
			,x.dtmChangeoverEndDate
			,x.dtmPlannedStartDate
			,x.dtmPlannedEndDate
			,x.intPlannedShiftId
			,x.intNoOfSelectedMachine
			,x.strComments
			,x.strNote
			,x.strAdditionalComments
			,x.dtmEarliestStartDate
			,x.ysnFrozen
			,1
			,@dtmCurrentDate
			,@intUserId
			,@dtmCurrentDate
			,@intUserId
		FROM @tblMFScheduleWorkOrder x
		WHERE x.intStatusId <> 1

		DECLARE @v XML = (SELECT * FROM @tblMFScheduleWorkOrder FOR XML AUTO)

		IF @ysnStandard = 1
		BEGIN
			UPDATE dbo.tblMFWorkOrder
			SET intStatusId = (
					CASE 
						WHEN @intManufacturingCellId = x.intManufacturingCellId
							THEN (
									CASE 
										WHEN tblMFWorkOrder.intStatusId IN (
												10
												,13
												)
											THEN tblMFWorkOrder.intStatusId
										ELSE x.intStatusId
										END
									)
						ELSE 1
						END
					)
				,dblQuantity = x.dblQuantity
				,intManufacturingCellId = x.intManufacturingCellId
				,intPlannedShiftId = x.intPlannedShiftId
				,dtmPlannedDate = x.dtmPlannedStartDate
				,intExecutionOrder = x.intExecutionOrder
			FROM @tblMFScheduleWorkOrder x
			WHERE x.intWorkOrderId = tblMFWorkOrder.intWorkOrderId
		END

		INSERT INTO dbo.tblMFScheduleWorkOrderDetail (
			intScheduleWorkOrderId
			,intWorkOrderId
			,intScheduleId
			,dtmPlannedStartDate
			,dtmPlannedEndDate
			,intPlannedShiftId
			,intDuration
			,dblPlannedQty
			,intSequenceNo
			,intCalendarDetailId
			,intConcurrencyId
			)
		SELECT (
				SELECT intScheduleWorkOrderId
				FROM dbo.tblMFScheduleWorkOrder W
				WHERE W.intWorkOrderId = x.intWorkOrderId
					AND W.intScheduleId = @intScheduleId
				)
			,x.intWorkOrderId
			,@intScheduleId
			,x.dtmPlannedStartDate
			,x.dtmPlannedEndDate
			,x.intPlannedShiftId
			,x.intDuration
			,x.dblPlannedQty
			,x.intSequenceNo
			,x.intCalendarDetailId
			,1
		FROM @tblMFScheduleWorkOrderDetail x
		JOIN dbo.tblMFScheduleWorkOrder W ON x.intWorkOrderId = W.intWorkOrderId
		WHERE W.intScheduleId = @intScheduleId

		INSERT INTO dbo.tblMFScheduleMachineDetail (
			intScheduleWorkOrderDetailId
			,intWorkOrderId
			,intScheduleId
			,intCalendarMachineId
			,intCalendarDetailId
			,intConcurrencyId
			)
		SELECT (
				SELECT intScheduleWorkOrderDetailId
				FROM dbo.tblMFScheduleWorkOrderDetail WD
				JOIN dbo.tblMFScheduleWorkOrder W ON W.intScheduleWorkOrderId = WD.intScheduleWorkOrderId
				WHERE W.intWorkOrderId = x.intWorkOrderId
					AND W.intScheduleId = @intScheduleId
					AND WD.intCalendarDetailId = x.intCalendarDetailId
				)
			,x.intWorkOrderId
			,@intScheduleId
			,x.intCalendarMachineId
			,x.intCalendarDetailId
			,1
		FROM @tblMFScheduleMachineDetail x
		JOIN dbo.tblMFScheduleWorkOrder W ON x.intWorkOrderId = W.intWorkOrderId
		WHERE W.intScheduleId = @intScheduleId

		INSERT INTO dbo.tblMFScheduleConstraintDetail (
			intScheduleWorkOrderId
			,intWorkOrderId
			,intScheduleId
			,intScheduleRuleId
			,dtmChangeoverStartDate
			,dtmChangeoverEndDate
			,intDuration
			,intConcurrencyId
			)
		SELECT (
				SELECT intScheduleWorkOrderId
				FROM dbo.tblMFScheduleWorkOrder W
				WHERE W.intWorkOrderId = x.intWorkOrderId
					AND W.intScheduleId = @intScheduleId
				)
			,x.intWorkOrderId
			,@intScheduleId
			,x.intScheduleRuleId
			,x.dtmChangeoverStartDate
			,x.dtmChangeoverEndDate
			,x.intDuration
			,1
		FROM @tblMFScheduleConstraintDetail x
		JOIN dbo.tblMFScheduleWorkOrder W ON x.intWorkOrderId = W.intWorkOrderId
		WHERE W.intScheduleId = @intScheduleId

		INSERT INTO dbo.tblMFScheduleConstraint (
			intScheduleId
			,intScheduleRuleId
			)
		SELECT @intScheduleId
			,intScheduleRuleId
		FROM @tblMFScheduleConstraint

		DELETE FROM @tblMFScheduleWorkOrder
		DELETE FROM @tblMFScheduleWorkOrderDetail
		DELETE FROM @tblMFScheduleMachineDetail
		DELETE FROM @tblMFScheduleConstraintDetail
		DELETE FROM @tblMFScheduleConstraint

		SELECT @intManufacturingCellId = MIN(intManufacturingCellId)
		FROM @tblMFWorkOrder
		WHERE intManufacturingCellId > @intManufacturingCellId
	END

	--IF @intTransactionCount = 0
	--	COMMIT TRANSACTION

	SELECT W.intManufacturingCellId
		,W.intWorkOrderId
		,W.strWorkOrderNo
		,SL.intScheduleId
		,W.dblQuantity
		,ISNULL(W.dtmEarliestDate, W.dtmExpectedDate) AS dtmEarliestDate
		,W.dtmExpectedDate
		,ISNULL(W.dtmLatestDate, W.dtmExpectedDate) AS dtmLatestDate
		,ISNULL(SL.dtmTargetDate, W.dtmExpectedDate) AS dtmTargetDate
		,CASE WHEN W.dblQuantity - W.dblProducedQuantity>0 THEN W.dblQuantity - W.dblProducedQuantity ELSE 0 END AS dblBalanceQuantity
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
	JOIN dbo.tblMFManufacturingCell MC ON MC.intManufacturingCellId = W.intManufacturingCellId
	AND MC.ysnIncludeSchedule = 1
	JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = W.intItemUOMId
	LEFT JOIN tblMFScheduleWorkOrder SL ON SL.intWorkOrderId = W.intWorkOrderId AND SL.intScheduleId IN (SELECT S.intScheduleId FROM tblMFSchedule S WHERE S.intLocationId=@intLocationId and S.ysnStandard =1)
	ORDER BY SL.intExecutionOrder

	EXEC dbo.uspMFGetScheduleDetail @intManufacturingCellId = @intChartManufacturingCellId
		,@dtmPlannedStartDate = @dtmFromDate
		,@dtmPlannedEndDate = @dtmToDate
		,@intLocationId = @intLocationId
		,@intScheduleId = 0

END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	--IF XACT_STATE() != 0
	--AND @intTransactionCount = 0
	--ROLLBACK TRANSACTION

	RAISERROR (
			@ErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH

