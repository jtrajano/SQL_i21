CREATE PROCEDURE uspMFRescheduleAndSaveWorkOrder (
	@tblMFWorkOrder ScheduleTable READONLY
	,@dtmFromDate DATETIME
	,@dtmToDate DATETIME
	,@intUserId INT
	,@intChartManufacturingCellId INT = 0
	,@ysnScheduleByManufacturingCell INT = 0
	,@intScheduleId INT = 0
	,@ysnStandard BIT = 1
	,@intConcurrencyId INT = 1
	,@tblMFScheduleConstraint ScheduleConstraintTable READONLY
	,@intCalendarId INT = 0
	)
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @idoc INT
		,@ErrMsg NVARCHAR(MAX)
		,@intManufacturingCellId INT
		,@intWorkOrderId INT
		,@intCalendarDetailId INT
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
		,@strSchedulingCutOffTime NVARCHAR(50)
		,@intBlendAttributeId INT
		,@strBlendAttributeValue NVARCHAR(50)

	SELECT @intBlendAttributeId = intAttributeId
	FROM tblMFAttribute
	WHERE strAttributeName = 'Blend Category'

	SELECT @strBlendAttributeValue = strAttributeValue
	FROM tblMFManufacturingProcessAttribute
	WHERE intAttributeId = @intBlendAttributeId

	SELECT @dtmCurrentDateTime = GETDATE()

	SELECT @dtmCurrentDate = CONVERT(DATETIME, CONVERT(CHAR, @dtmCurrentDateTime, 101))

	SELECT @ysnConsiderSumOfChangeoverTime = ysnConsiderSumOfChangeoverTime
		,@strSchedulingCutOffTime = ISNULL(strSchedulingCutOffTime, '0:00')
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

	SELECT @intManufacturingCellId = MIN(intManufacturingCellId)
		,@intLocationId = MIN(intLocationId)
	FROM @tblMFWorkOrder

	WHILE @intManufacturingCellId IS NOT NULL
	BEGIN
		SELECT @intPreviousWorkOrderId = 0

		SELECT @intAllottedNoOfMachine = 0

		IF @ysnScheduleByManufacturingCell = 0
		BEGIN
			SELECT @intCalendarId = intCalendarId
			FROM tblMFScheduleCalendar
			WHERE intManufacturingCellId = @intManufacturingCellId
				AND ysnStandard = 1
		END

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
					'Pack Type is not configured for the Item ''%s'' for the Work Order ''%s''.'
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
			,intNoOfFlushes
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
			,IsNULL(W.dtmLatestDate, W1.dtmLatestDate)
			,W.dtmTargetDate
			,W.intScheduleId
			,W.intNoOfFlushes
		FROM @tblMFWorkOrder W
		JOIN dbo.tblMFWorkOrder W1 ON W1.intWorkOrderId = W.intWorkOrderId
		LEFT JOIN dbo.tblMFManufacturingCellPackType MC ON MC.intManufacturingCellId = W.intManufacturingCellId
			AND MC.intPackTypeId = W.intPackTypeId
		LEFT JOIN tblMFPackType P ON P.intPackTypeId = W.intPackTypeId
		LEFT JOIN dbo.tblMFPackTypeDetail PTD ON PTD.intPackTypeId = W.intPackTypeId
			AND PTD.intTargetUnitMeasureId = W.intUnitMeasureId
			AND PTD.intSourceUnitMeasureId = MC.intLineCapacityUnitMeasureId
		WHERE W.intManufacturingCellId = @intManufacturingCellId
			AND W.dblBalance > 0
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
					'Pack Type ''%s'' for Work Order ''%s'' is not associated with the line ''%s''.'
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
					'There is no Pack Type conversion factor that matches the Work Order ''%s''.'
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
			AND CD.dtmShiftEndTime > @dtmCurrentDateTime
			AND CD.intNoOfMachine > 0

		--DECLARE @v XML = (SELECT * FROM @tblMFScheduleWorkOrderCalendarDetail FOR XML AUTO)
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
				AND dtmExpectedDate >= @dtmCurrentDate

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
					,@dtmEarliestDate = NULL
					,@dtmTargetDate = NULL

				SELECT @intWorkOrderId = intWorkOrderId
					,@intNoOfUnit = intNoOfUnit
					,@intPackTypeId = intPackTypeId
					,@dblBalance = dblBalance
					,@dblConversionFactor = dblConversionFactor
					,@intNoOfSelectedMachine = intNoOfSelectedMachine
					,@dtmEarliestStartDate = dtmEarliestStartDate
					,@intSetupDuration = intSetupDuration
					,@dtmEarliestDate = dtmEarliestDate
					,@dtmLatestDate = CASE 
						WHEN dtmLatestDate <= Isnull(@dtmLatestDate, dtmLatestDate)
							THEN CONVERT(CHAR, dtmLatestDate, 101) + ' ' + @strSchedulingCutOffTime
						ELSE @dtmLatestDate
						END
					,@dtmTargetDate = dtmTargetDate
				FROM @tblMFScheduleWorkOrder
				WHERE intRecordId = @intRecordId

				IF @intNoOfSelectedMachine IS NULL
					OR @intNoOfSelectedMachine = 0
				BEGIN
					SELECT @intNoOfSelectedMachine = @intNoOfMachine

					UPDATE @tblMFScheduleWorkOrder
					SET intNoOfSelectedMachine = @intNoOfMachine
					WHERE intRecordId = @intRecordId
				END

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

				IF EXISTS (
						SELECT *
						FROM dbo.tblMFScheduledMaintenanceDetail
						WHERE intShiftId = @intShiftId
							AND dtmCalendarDate = @dtmCalendarDate
							AND dtmEndTime = @dtmShiftEndTime
						)
				BEGIN
					SELECT @dtmPlannedEndDate = dtmStartTime
						,@intDuration = @intDuration - (DATEDIFF(MINUTE, dtmStartTime, dtmEndTime) * @intNoOfMachine)
						,@intRemainingDuration = @intRemainingDuration - DATEDIFF(MINUTE, dtmStartTime, dtmEndTime)
					FROM dbo.tblMFScheduledMaintenanceDetail
					WHERE intShiftId = @intShiftId
						AND dtmCalendarDate = @dtmCalendarDate
						AND dtmEndTime = @dtmShiftEndTime
				END

				IF EXISTS (
						SELECT *
						FROM dbo.tblMFShiftDetail
						WHERE intShiftId = @intShiftId
							AND @dtmPlannedEndDate BETWEEN @dtmCalendarDate + dtmShiftBreakTypeStartTime
								AND @dtmCalendarDate + dtmShiftBreakTypeEndTime
						)
				BEGIN
					SELECT @dtmPlannedEndDate = @dtmCalendarDate + dtmShiftBreakTypeStartTime
						,@intDuration = @intDuration - (intShiftBreakTypeDuration * @intNoOfMachine)
						,@intRemainingDuration = @intRemainingDuration - intShiftBreakTypeDuration
					FROM dbo.tblMFShiftDetail
					WHERE intShiftId = @intShiftId
						AND @dtmPlannedEndDate BETWEEN @dtmCalendarDate + dtmShiftBreakTypeStartTime
							AND @dtmCalendarDate + dtmShiftBreakTypeEndTime
				END

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
					SELECT TOP (@intNoOfSelectedMachine) (
							CASE 
								WHEN U.strUnitMeasure = 'Hour'
									THEN MP.dblMachineCapacity / 60
								ELSE MP.dblMachineCapacity
								END
							) AS dblMachineCapacity
					FROM dbo.tblMFScheduleCalendarMachineDetail MD
					JOIN dbo.tblMFMachinePackType MP ON MP.intMachineId = MD.intMachineId
					JOIN dbo.tblICUnitMeasure U ON U.intUnitMeasureId = MP.intMachineRateUOMId
					WHERE intCalendarDetailId = @intCalendarDetailId
						AND MP.intPackTypeId = @intPackTypeId
						AND NOT EXISTS (
							SELECT *
							FROM @tblMFScheduleMachineDetail SMD
							JOIN @tblMFScheduleWorkOrderDetail WD ON WD.intCalendarDetailId = SMD.intCalendarDetailId
								AND SMD.intWorkOrderId = WD.intWorkOrderId
							WHERE SMD.intCalendarDetailId = @intCalendarDetailId
								AND SMD.intCalendarMachineId = MD.intCalendarMachineId
								AND DATEADD(MINUTE, - 1, @dtmPlannedEndDate) BETWEEN WD.dtmPlannedStartDate
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

						SELECT @intShiftBreakTypeDuration = ISNULL(@intShiftBreakTypeDuration, 0) + SUM(intDuration)
						FROM dbo.tblMFScheduledMaintenanceDetail
						WHERE intShiftId = @intShiftId
							AND dtmStartTime >= @dtmPlannedStartDate
							AND dtmEndTime <= @dtmPlannedEndDate

						SELECT @intShiftBreakTypeDuration = ISNULL(@intShiftBreakTypeDuration, 0) + DATEDIFF(MINUTE, @dtmPlannedStartDate, dtmEndTime)
						FROM dbo.tblMFScheduledMaintenanceDetail
						WHERE intShiftId = @intShiftId
							AND @dtmPlannedStartDate BETWEEN dtmStartTime
								AND dtmEndTime

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
								AND FG.strGroupValue = @strColumnValue
								AND TG.strGroupValue = @strPreviousColumnValue

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

								SELECT @intShiftBreakTypeDuration = ISNULL(@intShiftBreakTypeDuration, 0) + SUM(intDuration)
								FROM dbo.tblMFScheduledMaintenanceDetail
								WHERE intShiftId = @intShiftId
									AND dtmStartTime >= @dtmPlannedStartDate
									AND dtmEndTime <= @dtmPlannedEndDate

								SELECT @intShiftBreakTypeDuration = ISNULL(@intShiftBreakTypeDuration, 0) + DATEDIFF(MINUTE, @dtmPlannedStartDate, dtmEndTime)
								FROM dbo.tblMFScheduledMaintenanceDetail
								WHERE intShiftId = @intShiftId
									AND @dtmPlannedStartDate BETWEEN dtmStartTime
										AND dtmEndTime

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
									@intPreviousWorkOrderId
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
							WHERE intWorkOrderId = @intPreviousWorkOrderId
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

						SELECT @intShiftBreakTypeDuration = ISNULL(@intShiftBreakTypeDuration, 0) + SUM(intDuration)
						FROM dbo.tblMFScheduledMaintenanceDetail
						WHERE intShiftId = @intShiftId
							AND dtmStartTime >= @dtmPlannedStartDate
							AND dtmEndTime <= @dtmPlannedEndDate

						SELECT @intShiftBreakTypeDuration = ISNULL(@intShiftBreakTypeDuration, 0) + DATEDIFF(MINUTE, @dtmPlannedStartDate, dtmEndTime)
						FROM dbo.tblMFScheduledMaintenanceDetail
						WHERE intShiftId = @intShiftId
							AND @dtmPlannedStartDate BETWEEN dtmStartTime
								AND dtmEndTime

						IF @intShiftBreakTypeDuration IS NOT NULL
							SELECT @dtmPlannedStartDate = DATEADD(MINUTE, - @intShiftBreakTypeDuration, @dtmPlannedStartDate)

						IF @intMaxChangeoverTime > @intSetupDuration
						BEGIN
							UPDATE @tblMFScheduleConstraintDetail
							SET dtmChangeoverStartDate = @dtmPlannedStartDate
								,dtmChangeoverEndDate = @dtmPlannedEndDate
							WHERE intWorkOrderId = @intPreviousWorkOrderId
								AND intDuration = @intMaxChangeoverTime
						END

						SELECT @dtmPlannedEndDate = @dtmPlannedStartDate

						SELECT @intRemainingDuration = DATEDIFF(MINUTE, @dtmShiftStartTime, @dtmPlannedEndDate)
					END

					IF EXISTS (
							SELECT *
							FROM @tblMFScheduleConstraintDetail
							WHERE intWorkOrderId = @intPreviousWorkOrderId
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
						WHERE intWorkOrderId = @intPreviousWorkOrderId

						UPDATE @tblMFScheduleWorkOrder
						SET dtmChangeoverStartDate = @dtmChangeoverStartDate
							,dtmChangeoverEndDate = @dtmChangeoverEndDate
							,intChangeoverDuration = @intChangeoverDuration
						WHERE intWorkOrderId = @intPreviousWorkOrderId
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

					SELECT @intShiftBreakTypeDuration = ISNULL(@intShiftBreakTypeDuration, 0) + DATEDIFF(MINUTE, @dtmPlannedStartDate, @dtmCalendarDate + dtmShiftBreakTypeEndTime)
					FROM dbo.tblMFShiftDetail
					WHERE intShiftId = @intShiftId
						AND @dtmPlannedStartDate BETWEEN @dtmCalendarDate + dtmShiftBreakTypeStartTime
							AND @dtmCalendarDate + dtmShiftBreakTypeEndTime

					IF ISNULL((
								SELECT SUM(intDuration)
								FROM dbo.tblMFScheduledMaintenanceDetail
								WHERE intShiftId = @intShiftId
									AND dtmStartTime >= @dtmShiftStartTime
									AND dtmEndTime <= @dtmShiftEndTime
								), 0) - @intDuration = 0
					BEGIN
						SELECT @intCalendarDetailId = MAX(intCalendarDetailId)
						FROM @tblMFScheduleWorkOrderCalendarDetail
						WHERE intCalendarDetailId < @intCalendarDetailId

						SELECT @intAllottedNoOfMachine = 0

						BREAK
					END

					SELECT @intShiftBreakTypeDuration = ISNULL(@intShiftBreakTypeDuration, 0) + SUM(intDuration)
					FROM dbo.tblMFScheduledMaintenanceDetail
					WHERE intShiftId = @intShiftId
						AND dtmStartTime >= @dtmPlannedStartDate
						AND dtmEndTime <= @dtmPlannedEndDate

					SELECT @intShiftBreakTypeDuration = ISNULL(@intShiftBreakTypeDuration, 0) + DATEDIFF(MINUTE, @dtmPlannedStartDate, dtmEndTime)
					FROM dbo.tblMFScheduledMaintenanceDetail
					WHERE intShiftId = @intShiftId
						AND @dtmPlannedStartDate BETWEEN dtmStartTime
							AND dtmEndTime

					IF @intShiftBreakTypeDuration IS NOT NULL
						SELECT @dtmPlannedStartDate = DATEADD(MINUTE, - @intShiftBreakTypeDuration, @dtmPlannedStartDate)

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
								AND DATEADD(MINUTE, - 1, @dtmPlannedEndDate) BETWEEN WD.dtmPlannedStartDate
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
							,strNote = CASE 
								WHEN @dtmCurrentDate > dtmExpectedDate
									THEN 'Past Expected Date'
								WHEN dtmEarliestStartDate > @dtmShiftStartTime
									THEN 'Earliest start date > Scheduled start Date'
								ELSE NULL
								END
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
							,strNote = CASE 
								WHEN @dtmCurrentDate > dtmExpectedDate
									THEN 'Past Expected Date'
								WHEN dtmEarliestStartDate > @dtmShiftStartTime
									THEN 'Earliest start date > Scheduled start Date'
								ELSE NULL
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
								AND DATEADD(MINUTE, - 1, @dtmPlannedEndDate) BETWEEN WD.dtmPlannedStartDate
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
					AND S.dtmExpectedDate >= @dtmCurrentDate
			END

			IF NOT EXISTS (
					SELECT *
					FROM @tblMFScheduleWorkOrder S
					WHERE S.intNoOfUnit > 0
						AND S.intStatusId <> 1
						AND S.dtmExpectedDate >= @dtmCurrentDate
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
						AND S.dtmExpectedDate >= @dtmCurrentDate
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
					AND S.dtmExpectedDate >= @dtmCurrentDate
				)
		BEGIN
			SELECT @intWorkOrderId = intWorkOrderId
			FROM @tblMFScheduleWorkOrder S
			WHERE intNoOfUnit > 0
				AND S.intStatusId <> 1
				AND S.dtmExpectedDate >= @dtmCurrentDate
			ORDER BY intExecutionOrder ASC

			SELECT @strWorkOrderNo = strWorkOrderNo
			FROM tblMFWorkOrder
			WHERE intWorkOrderId = @intWorkOrderId

			RAISERROR (
					'There is no enough shift time to schedule the Work Order ''%s'' in the selected calendar.'
					,11
					,1
					,@strWorkOrderNo
					)

			RETURN
		END

		IF @ysnScheduleByManufacturingCell = 0
		BEGIN
			SELECT @ysnStandard = 1

			DECLARE @intTransactionCount INT
				,@strScheduleNo NVARCHAR(50)

			SELECT @intTransactionCount = @@TRANCOUNT

			SELECT @intScheduleId = NULL

			SELECT @intScheduleId = intScheduleId
			FROM dbo.tblMFSchedule
			WHERE intManufacturingCellId = @intManufacturingCellId
				AND ysnStandard = 1

			IF @intScheduleId IS NULL
				SELECT @intScheduleId = intScheduleId
				FROM dbo.tblMFSchedule
				WHERE intManufacturingCellId = @intManufacturingCellId

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
					PARTITION BY intManufacturingCellId ORDER BY x.intExecutionOrder
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

			DELETE
			FROM @tblMFScheduleWorkOrder

			DELETE
			FROM @tblMFScheduleWorkOrderDetail

			DELETE
			FROM @tblMFScheduleMachineDetail

			DELETE
			FROM @tblMFScheduleConstraintDetail
		END

		SELECT @intManufacturingCellId = MIN(intManufacturingCellId)
		FROM @tblMFWorkOrder
		WHERE intManufacturingCellId > @intManufacturingCellId
	END

	IF @ysnScheduleByManufacturingCell = 0
	BEGIN
		SELECT W.intManufacturingCellId
			,W.intWorkOrderId
			,W.strWorkOrderNo
			,SL.intScheduleId
			,W.dblQuantity
			,ISNULL(W.dtmEarliestDate, W.dtmExpectedDate) AS dtmEarliestDate
			,W.dtmExpectedDate
			,ISNULL(W.dtmLatestDate, W.dtmExpectedDate) AS dtmLatestDate
			,ISNULL(SL.dtmTargetDate, W.dtmExpectedDate) AS dtmTargetDate
			,CASE 
				WHEN W.dblQuantity - W.dblProducedQuantity > 0
					THEN W.dblQuantity - W.dblProducedQuantity
				ELSE 0
				END AS dblBalanceQuantity
			,I.intItemId
			,IU.intItemUOMId
			,IU.intUnitMeasureId
			,W.intStatusId
			,SL.intScheduleWorkOrderId
			,IsNULL(SL.intExecutionOrder, 0) AS intExecutionOrder
			,IsNULL(SL.ysnFrozen, 0) AS ysnFrozen
			,I.intPackTypeId
			,ISNULL(SL.intConcurrencyId, 0) AS intConcurrencyId
			,CONVERT(BIT, 0) AS ysnEOModified
			,ISNULL(SL.intNoOfFlushes, 0) AS intNoOfFlushes
		FROM tblMFWorkOrder W
		JOIN dbo.tblICItem I ON I.intItemId = W.intItemId
			AND W.intStatusId <> 13
			AND W.intLocationId = @intLocationId
			AND W.intManufacturingCellId IS NOT NULL
		JOIN dbo.tblMFManufacturingCell MC ON MC.intManufacturingCellId = W.intManufacturingCellId
			AND MC.ysnIncludeSchedule = 1
		JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = W.intItemUOMId
		LEFT JOIN tblMFScheduleWorkOrder SL ON SL.intWorkOrderId = W.intWorkOrderId
			AND SL.intScheduleId IN (
				SELECT S.intScheduleId
				FROM tblMFSchedule S
				WHERE S.intLocationId = @intLocationId
					AND S.ysnStandard = 1
				)
		ORDER BY W.intManufacturingCellId
			,SL.intExecutionOrder

		IF @intChartManufacturingCellId = - 1
		BEGIN
			SELECT @intChartManufacturingCellId = 0
		END

		EXEC dbo.uspMFGetScheduleDetail @intManufacturingCellId = @intChartManufacturingCellId
			,@dtmPlannedStartDate = @dtmFromDate
			,@dtmPlannedEndDate = @dtmToDate
			,@intLocationId = @intLocationId
			,@intScheduleId = 0
	END
	ELSE
	BEGIN
		IF @intScheduleId IS NULL
			SELECT @intScheduleId = 0

		IF @intScheduleId > 0
		BEGIN
			SELECT S.intScheduleId
				,S.strScheduleNo
				,S.dtmScheduleDate
				,S.intCalendarId
				,SC.strName
				,S.intManufacturingCellId
				,MC.strCellName
				,@ysnStandard AS ysnStandard
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
				,@dtmCurrentDateTime AS dtmScheduleDate
				,@intCalendarId AS intCalendarId
				,'' AS strName
				,@intChartManufacturingCellId AS intManufacturingCellId
				,'' AS strCellName
				,@ysnStandard AS ysnStandard
				,@intLocationId AS intLocationId
				,0 AS intConcurrencyId
				,@dtmCurrentDateTime AS dtmCreated
				,0 AS intCreatedUserId
				,@dtmCurrentDateTime AS dtmLastModified
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
			,SL.dtmEarliestDate
			,Isnull(SL.dtmExpectedDate, W.dtmExpectedDate) AS dtmExpectedDate
			,SL.dtmLatestDate
			,IsNULL(SL.dblQuantity, W.dblQuantity) - W.dblProducedQuantity AS dblBalanceQuantity
			,W.dblProducedQuantity
			,W.strComment AS strWorkOrderComments
			,W.dtmOrderDate
			,W.dtmLastProducedDate
			,(
				SELECT TOP 1 strItemNo
				FROM dbo.tblMFRecipeItem RI
				JOIN dbo.tblICItem WI ON RI.intItemId = WI.intItemId
				JOIN dbo.tblICCategory C ON C.intCategoryId = WI.intCategoryId
				WHERE RI.intRecipeId = R.intRecipeId
					AND C.strCategoryCode = @strBlendAttributeValue
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
			,Convert(INT, CASE 
					WHEN SL.intStatusId = 1
						THEN NULL
					ELSE SL.intExecutionOrder
					END) AS intExecutionOrder
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
			,@dtmCurrentDateTime dtmCreated
			,@intUserId intCreatedUserId
			,@dtmCurrentDateTime dtmLastModified
			,@intUserId intLastModifiedUserId
			,WS.intSequenceNo
			,W.ysnIngredientAvailable
			,W.dtmLastProducedDate
			,CONVERT(BIT, 0) AS ysnEOModified
			,SL.intDemandRatio
			,ISNULL(SL.intNoOfFlushes, 0) AS intNoOfFlushes
		FROM tblMFWorkOrder W
		JOIN dbo.tblICItem I ON I.intItemId = W.intItemId
			AND W.intManufacturingCellId = @intChartManufacturingCellId
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

		SELECT intScheduleWorkOrderDetailId
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

		SELECT intScheduleMachineDetailId
			,0 AS intScheduleWorkOrderDetailId
			,intWorkOrderId
			,@intScheduleId AS intScheduleId
			,intCalendarMachineId
			,intCalendarDetailId
			,@intConcurrencyId AS intConcurrencyId
		FROM @tblMFScheduleMachineDetail

		SELECT intScheduleConstraintDetailId
			,0 AS intScheduleWorkOrderId
			,intWorkOrderId
			,@intScheduleId AS intScheduleId
			,intScheduleRuleId
			,dtmChangeoverStartDate
			,dtmChangeoverEndDate
			,intDuration
			,@intConcurrencyId AS intConcurrencyId
		FROM @tblMFScheduleConstraintDetail
		WHERE dtmChangeoverStartDate IS NOT NULL
			OR dtmChangeoverEndDate IS NOT NULL

		IF @ysnConsiderSumOfChangeoverTime = 0
		BEGIN
			WITH RemoveUnusedData (RowNumber)
			AS (
				SELECT ROW_NUMBER() OVER (
						PARTITION BY intWorkOrderId ORDER BY intDuration DESC
						)
				FROM @tblMFScheduleConstraintDetail
				)
			DELETE
			FROM RemoveUnusedData
			WHERE RowNumber > 1
		END

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
			,Ltrim(W.intWorkOrderId) AS strRowId
			,ISNULL(SL.intNoOfFlushes, 0) AS intNoOfFlushes
		FROM dbo.tblMFWorkOrder W
		JOIN dbo.tblICItem I ON I.intItemId = W.intItemId
		JOIN dbo.tblICItemUOM IU ON IU.intItemId = I.intItemId
			AND IU.ysnStockUnit = 1
		JOIN dbo.tblICUnitMeasure U ON U.intUnitMeasureId = IU.intUnitMeasureId
		JOIN dbo.tblMFManufacturingCell MC ON MC.intManufacturingCellId = W.intManufacturingCellId
		JOIN @tblMFScheduleWorkOrder SL ON SL.intWorkOrderId = W.intWorkOrderId
		JOIN dbo.tblMFWorkOrderStatus WS ON WS.intStatusId = SL.intStatusId
		JOIN dbo.tblMFShift SH ON SH.intShiftId = SL.intPlannedShiftId
		WHERE W.intLocationId = @intLocationId
			AND MC.intManufacturingCellId = @intChartManufacturingCellId
			AND (
				@dtmFromDate BETWEEN SL.dtmPlannedStartDate
					AND SL.dtmPlannedEndDate
				OR @dtmToDate BETWEEN SL.dtmPlannedStartDate
					AND SL.dtmPlannedEndDate
				OR (
					SL.dtmPlannedStartDate >= @dtmFromDate
					AND SL.dtmPlannedEndDate <= @dtmToDate
					)
				)
		
		UNION
		
		SELECT W.intManufacturingCellId
			,MC.strCellName
			,W.intWorkOrderId
			,W.strWorkOrderNo
			,NULL dblQuantity
			,NULL dblBalanceQuantity
			,NULL strWorkOrderComment
			,NULL dtmExpectedDate
			,NULL dtmEarliestDate
			,NULL dtmLatestDate
			,NULL intItemId
			,NULL strItemNo
			,NULL strDescription
			,NULL intItemUOMId
			,NULL intUnitMeasureId
			,NULL strUnitMeasure
			,NULL strAdditive
			,NULL strAdditiveDesc
			,NULL intStatusId
			,NULL strStatusName
			,SR.strBackColorName
			,SC.intDuration
			,SC.dtmChangeoverStartDate
			,SC.dtmChangeoverEndDate
			,NULL strScheduleComment
			,SL.intExecutionOrder
			,CONVERT(BIT, 0) ysnFrozen
			,NULL intShiftId
			,NULL strShiftName
			,NULL OrderLineItemId
			,CONVERT(BIT, 0) AS ysnAlternateLine
			,0 AS intByWhichDate
			,NULL AS strCustOrderNo
			,SR.strName AS strChangeover
			,SC.intDuration AS intLeadTime
			,NULL AS strCustomer
			,Ltrim(W.intWorkOrderId) + Ltrim(SR.intScheduleRuleId)
			,ISNULL(SL.intNoOfFlushes, 0) AS intNoOfFlushes
		FROM dbo.tblMFWorkOrder W
		JOIN @tblMFScheduleWorkOrder SL ON SL.intWorkOrderId = W.intWorkOrderId
		JOIN @tblMFScheduleConstraintDetail SC ON SC.intWorkOrderId = W.intWorkOrderId
		JOIN dbo.tblMFScheduleRule SR ON SR.intScheduleRuleId = SC.intScheduleRuleId
		JOIN dbo.tblMFManufacturingCell MC ON MC.intManufacturingCellId = W.intManufacturingCellId
		WHERE W.intLocationId = @intLocationId
			AND W.intManufacturingCellId = (
				CASE 
					WHEN @intChartManufacturingCellId = 0
						THEN W.intManufacturingCellId
					ELSE @intChartManufacturingCellId
					END
				)
			AND (
				@dtmFromDate BETWEEN SC.dtmChangeoverStartDate
					AND SC.dtmChangeoverEndDate
				OR @dtmToDate BETWEEN SC.dtmChangeoverStartDate
					AND SC.dtmChangeoverEndDate
				OR (
					SC.dtmChangeoverStartDate >= @dtmFromDate
					AND SC.dtmChangeoverEndDate <= @dtmToDate
					)
				)
		ORDER BY SL.intExecutionOrder

		SELECT R.intScheduleRuleId
			,R.strName AS strScheduleRuleName
			,R.intScheduleRuleTypeId
			,RT.strName AS strScheduleRuleTypeName
			,R.ysnActive
			,R.intPriorityNo
			,R.strComments
			,Convert(BIT, CASE 
					WHEN SC.intScheduleConstraintId IS NULL
						THEN 0
					ELSE 1
					END) AS ysnSelect
			,@intScheduleId AS intScheduleId
			,R.intConcurrencyId
		FROM dbo.tblMFScheduleRule R
		JOIN dbo.tblMFScheduleRuleType RT ON RT.intScheduleRuleTypeId = R.intScheduleRuleTypeId
		LEFT JOIN @tblMFScheduleConstraint SC ON SC.intScheduleRuleId = R.intScheduleRuleId
		WHERE R.intLocationId = @intLocationId
			AND R.ysnActive = 1
	END
			--IF @intTransactionCount = 0
			--	COMMIT TRANSACTION
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
