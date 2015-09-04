CREATE PROCEDURE uspMFGetCalendar (@intCalendarId INT)
AS
BEGIN
	SELECT C.intCalendarId
		,C.strName
		,C.intManufacturingCellId
		,MC.strCellName
		,C.dtmFromDate
		,C.dtmToDate
		,C.ysnStandard
		,C.intLocationId
		,L.strLocationName
	FROM dbo.tblMFScheduleCalendar C
	JOIN dbo.tblMFManufacturingCell MC ON MC.intManufacturingCellId = C.intManufacturingCellId
	JOIN tblSMCompanyLocation L ON L.intCompanyLocationId = C.intLocationId
	WHERE C.intCalendarId = @intCalendarId
END

