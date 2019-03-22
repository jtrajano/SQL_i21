CREATE PROCEDURE uspMFGetShiftActivity
     @dtmFromDate DATETIME
	,@dtmToDate DATETIME
	,@intShiftActivityStatusId INT
	,@intLocationId INT
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN
	IF @intShiftActivityStatusId = 1
	BEGIN
		CREATE TABLE #tmp_ActualTable (
			intShiftActivityId INT Identity
			,intManufacturingCellId INT
			,dtmShiftDate DATETIME
			,intShiftId INT
			,dtmShiftStartTime DATETIME
			,dtmShiftEndTime DATETIME
			,dblPartialQtyProduced NUMERIC(18, 6)
			,intScheduledRuntime INT
			,intTotalDowntime INT
			,intUnitMeasureId INT
			,intShiftActivityStatusId INT
			)

		INSERT INTO #tmp_ActualTable
		SELECT DISTINCT SC.intManufacturingCellId
			,SCD.dtmCalendarDate
			,SH.intShiftId
			,SCD.dtmShiftStartTime
			,SCD.dtmShiftEndTime
			,0
			,0
			,0
			,0 AS intUnitMeasureId
			,1
		FROM dbo.tblMFScheduleCalendarDetail SCD
		JOIN dbo.tblMFScheduleCalendar SC ON SC.intCalendarId = SCD.intCalendarId
			AND SC.ysnStandard = 1
		JOIN dbo.tblMFShift SH ON SH.intShiftId = SCD.intShiftId
		JOIN dbo.tblMFManufacturingCell MC ON MC.intManufacturingCellId = SC.intManufacturingCellId
			AND MC.ysnIncludeEfficiency = 1
		WHERE SC.intLocationId = @intLocationId
			AND CONVERT(DATETIME, CONVERT(CHAR, SCD.dtmCalendarDate, 101)) BETWEEN CONVERT(DATETIME, CONVERT(CHAR, @dtmFromDate, 101))
				AND CONVERT(DATETIME, CONVERT(CHAR, @dtmToDate, 101))
			AND SCD.intNoOfMachine > 0
			AND NOT EXISTS (
				SELECT *
				FROM tblMFShiftActivity SA
				WHERE CONVERT(DATETIME, CONVERT(CHAR, SA.dtmShiftDate, 101)) = CONVERT(DATETIME, CONVERT(CHAR, SCD.dtmCalendarDate, 101))
					AND SA.intManufacturingCellId = MC.intManufacturingCellId
					AND SA.intShiftId = SCD.intShiftId
				)
		ORDER BY SCD.dtmCalendarDate
			,SCD.dtmShiftStartTime

		SELECT AT.intShiftActivityId
			,MC.strCellName
			,AT.dtmShiftDate
			,S.strShiftName
			,AT.dtmShiftStartTime
			,AT.dtmShiftEndTime
			,S.intShiftId
			,AT.intManufacturingCellId
			,MC.ysnIncludeSchedule
		FROM #tmp_ActualTable AT
		JOIN dbo.tblMFManufacturingCell MC ON AT.intManufacturingCellId = MC.intManufacturingCellId
			AND MC.intLocationId = @intLocationId
		JOIN dbo.tblMFShift S ON S.intShiftId = AT.intShiftId
			AND S.intLocationId = @intLocationId
		JOIN dbo.tblMFShiftActivityStatus SAS ON SAS.intShiftActivityStatusId = AT.intShiftActivityStatusId
		LEFT JOIN dbo.tblICUnitMeasure UOM ON UOM.intUnitMeasureId = AT.intUnitMeasureId
		ORDER BY MC.strCellName
			,AT.intShiftActivityId

		DROP TABLE #tmp_ActualTable
	END

	IF @intShiftActivityStatusId = 2
	BEGIN
		SELECT DISTINCT SA.intShiftActivityId
			,SA.strShiftActivityNumber
			,MC.strCellName
			,SA.intManufacturingCellId
			,SA.intShiftId
			,SA.dtmShiftDate
			,S.strShiftName
			,SA.dtmShiftStartTime
			,SA.dtmShiftEndTime
			,COUNT(DISTINCT (SAM.intMachineId)) AS intNoOfMachines
			,(SA.intScheduledRuntime / 60) AS intScheduledRuntime
			,SA.strComments
			,MC.ysnIncludeSchedule
		FROM dbo.tblMFShiftActivity SA
		JOIN dbo.tblMFManufacturingCell MC ON SA.intManufacturingCellId = MC.intManufacturingCellId
			AND MC.intLocationId = @intLocationId
		JOIN dbo.tblMFShift S ON S.intShiftId = SA.intShiftId
		JOIN dbo.tblMFShiftActivityStatus SAS ON SAS.intShiftActivityStatusId = SA.intShiftActivityStatusId
		LEFT JOIN dbo.tblMFShiftActivityMachines SAM ON SAM.intShiftActivityId = SA.intShiftActivityId
		LEFT JOIN dbo.tblMFScheduleCalendar SC ON SC.intManufacturingCellId = SA.intManufacturingCellId
			AND SC.ysnStandard = 1
			AND SC.intLocationId = @intLocationId
		LEFT JOIN dbo.tblMFScheduleCalendarDetail SCD ON SCD.intCalendarId = SC.intCalendarId
			AND SCD.intShiftId = SA.intShiftId
			AND SCD.dtmCalendarDate = SA.dtmShiftDate
		LEFT JOIN dbo.tblMFScheduleCalendarMachineDetail SCM ON SCM.intCalendarDetailId = SCD.intCalendarDetailId
		WHERE CONVERT(DATETIME, CONVERT(CHAR, SA.dtmShiftDate, 101)) BETWEEN CONVERT(DATETIME, CONVERT(CHAR, @dtmFromDate, 101))
				AND CONVERT(DATETIME, CONVERT(CHAR, @dtmToDate, 101))
			AND SA.intShiftActivityStatusId = @intShiftActivityStatusId
		GROUP BY SA.intShiftActivityId
			,SA.strShiftActivityNumber
			,MC.strCellName
			,SA.intManufacturingCellId
			,SA.dtmShiftDate
			,SA.dtmShiftStartTime
			,SA.dtmShiftEndTime
			,S.strShiftName
			,SA.intShiftId
			,SCD.intNoOfMachine
			,DATEDIFF(mi, SCD.dtmShiftStartTime, SCD.dtmShiftEndTime)
			,SA.intScheduledRuntime
			,SA.strComments
			,MC.ysnIncludeSchedule
		ORDER BY MC.strCellName
			,SA.dtmShiftDate
			,SA.dtmShiftStartTime
	END

	IF @intShiftActivityStatusId = 3
	BEGIN
		SELECT SA.intShiftActivityId
			,SA.strShiftActivityNumber
			,SA.intShiftId
			,SA.intManufacturingCellId
			,MC.strCellName
			,SA.dtmShiftDate
			,S.strShiftName
			,SA.dtmShiftStartTime
			,SA.dtmShiftEndTime
			,COUNT(DISTINCT SAM.intMachineId) AS intNoOfMachines
			,SA.dblPartialQtyProduced AS dblPartialQtyProduced
			,CASE SA.intUnitMeasureId
				WHEN NULL
					THEN ''
				ELSE UOM.strUnitMeasure
				END AS strUnitMeasure
			,(SA.intScheduledRuntime / 60) AS intScheduledRuntime
			,(SA.intTotalDowntime / 60) AS intTotalDowntime
			,SA.dblTotalProducedQty AS dblTotalProducedQty
			,SA.dblTargetEfficiency AS dblTargetEfficiency
			,ROUND((
					CASE 
						WHEN ((((ISNULL(SA.intScheduledRuntime, 0) - ISNULL(SA.intReduceAvailableTime * 60, 0)) / 60) * SA.dblStdCapacity)) = 0
							THEN 0
						ELSE (
								ISNULL(SA.dblTotalProducedQty, 0) / CASE 
									WHEN ((((ISNULL(SA.intScheduledRuntime, 0) - ISNULL(SA.intReduceAvailableTime * 60, 0)) / 60) * SA.dblStdCapacity)) = 0
										THEN 1
									ELSE ((((ISNULL(SA.intScheduledRuntime, 0) - ISNULL(SA.intReduceAvailableTime * 60, 0)) / 60) * SA.dblStdCapacity))
									END
								) * 100
						END
					), 2) AS dblEfficiencyPercent
			,SA.strComments
			,MC.ysnIncludeSchedule
		FROM dbo.tblMFShiftActivity SA
		JOIN dbo.tblMFManufacturingCell MC ON SA.intManufacturingCellId = MC.intManufacturingCellId
			AND MC.intLocationId = @intLocationId
		JOIN dbo.tblMFShift S ON S.intShiftId = SA.intShiftId
		JOIN dbo.tblMFShiftActivityStatus SAS ON SAS.intShiftActivityStatusId = SA.intShiftActivityStatusId
		LEFT JOIN dbo.tblMFShiftActivityMachines SAM ON SAM.intShiftActivityId = SA.intShiftActivityId
		LEFT JOIN dbo.tblICUnitMeasure UOM ON UOM.intUnitMeasureId = SA.intUnitMeasureId
		WHERE SA.intShiftActivityStatusId = @intShiftActivityStatusId
			AND CONVERT(DATETIME, CONVERT(CHAR, SA.dtmShiftDate, 101)) BETWEEN CONVERT(DATETIME, CONVERT(CHAR, @dtmFromDate, 101))
				AND CONVERT(DATETIME, CONVERT(CHAR, @dtmToDate, 101))
		GROUP BY SA.intShiftActivityId
			,SA.strShiftActivityNumber
			,SA.intShiftId
			,SA.intManufacturingCellId
			,MC.strCellName
			,SA.dtmShiftDate
			,S.strShiftName
			,SA.dtmShiftStartTime
			,SA.dtmShiftEndTime
			,SA.dblPartialQtyProduced
			,UOM.strUnitMeasure
			,SA.intScheduledRuntime
			,SA.intTotalDowntime
			,SA.dblTotalProducedQty
			,SA.intReduceAvailableTime
			,SA.dblTargetEfficiency
			,SA.dblStdCapacity
			,SA.strComments
			,MC.ysnIncludeSchedule
		ORDER BY MC.strCellName
			,SA.dtmShiftDate
			,SA.dtmShiftStartTime
	END
END
