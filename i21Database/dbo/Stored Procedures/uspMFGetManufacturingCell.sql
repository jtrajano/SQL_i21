CREATE PROCEDURE uspMFGetManufacturingCell (
	@intCalendarId INT
	,@intLocationId INT
	,@intManufacturingCellId int=0
	,@strCellName NVARCHAR(50) = '%'
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
		AND M.strCellName LIKE @strCellName + '%'
		AND M.intManufacturingCellId =(Case When @intManufacturingCellId>0 Then @intManufacturingCellId Else M.intManufacturingCellId End)
	ORDER BY M.strCellName
END