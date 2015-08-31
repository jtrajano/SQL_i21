CREATE PROCEDURE uspMFGetManufacturingCell (
	@intCalendarId INT
	,@intLocationId INT
	)
AS
BEGIN
	SELECT M.intManufacturingCellId
		,M.strCellName
		,(
			SELECT TOP 1 CD.dtmCalendarDate
			FROM dbo.tblMFScheduleCalendarDetail CD
			JOIN dbo.tblMFScheduleCalendar C ON C.intCalendarId = CD.intCalendarId
			WHERE C.intManufacturingCellId = M.intManufacturingCellId
				AND C.intCalendarId = @intCalendarId
			ORDER BY CD.dtmCalendarDate DESC
			) dtmMachineConfiguredAsOn
	FROM dbo.tblMFManufacturingCell M
	WHERE M.intLocationId = @intLocationId
		AND M.ysnActive = 1
		AND M.ysnIncludeSchedule = 1
	ORDER BY M.strCellName
END