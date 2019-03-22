CREATE VIEW vyuMFGetHolidayCalendar
AS
SELECT HC.intHolidayId
	,HC.strName
	,HT.strName AS strHolidayTypeName
	,HC.dtmFromDate
	,HC.dtmToDate
	,HC.strComments
	,HC.intLocationId
FROM dbo.tblMFHolidayCalendar HC
JOIN dbo.tblMFHolidayType HT ON HT.intHolidayTypeId = HC.intHolidayTypeId
JOIN tblSMCompanyLocation L ON L.intCompanyLocationId = HC.intLocationId
