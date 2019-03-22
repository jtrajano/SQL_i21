CREATE PROCEDURE uspMFGetCalendarDetailException (
	@dtmFromDate DATETIME
	,@dtmToDate DATETIME
	,@strMachineId NVARCHAR(100)
	,@intManufacturingCellId INT
	,@intCalendarId INT
	,@intLocationId INT
	)
AS
BEGIN
	SELECT CD.dtmCalendarDate
		,CD.intShiftId
		,S.strShiftName
		,M.intMachineId
		,M.strName
		,MC.intManufacturingCellId
		,MC.strCellName
	FROM dbo.tblMFScheduleCalendar C
	JOIN dbo.tblMFScheduleCalendarDetail CD ON C.intCalendarId = CD.intCalendarId
		AND C.intCalendarId <> @intCalendarId
		AND C.intManufacturingCellId <> @intManufacturingCellId
	JOIN dbo.tblMFShift S ON S.intShiftId = CD.intShiftId
	JOIN dbo.tblMFScheduleCalendarMachineDetail MD ON MD.intCalendarDetailId = CD.intCalendarDetailId
	JOIN dbo.tblMFMachine M ON M.intMachineId = MD.intMachineId
	JOIN dbo.tblMFManufacturingCell MC ON MC.intManufacturingCellId = C.intManufacturingCellId
	WHERE C.intLocationId = @intLocationId
		AND CD.dtmCalendarDate BETWEEN @dtmFromDate
			AND @dtmToDate
		AND M.intMachineId IN (
			SELECT Item
			FROM dbo.fnSplitString(@strMachineId, ',')
			)
END
