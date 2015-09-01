CREATE VIEW vyuMFGetSchedule
AS
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
JOIN tblMFManufacturingCell MC ON MC.intManufacturingCellId = S.intManufacturingCellId
JOIN tblMFScheduleCalendar SC ON SC.intCalendarId = S.intCalendarId
