CREATE PROCEDURE [dbo].[uspPRAddTimeOffToCalendar]
	@intTransactionId INT
	,@intUserId INT
AS
BEGIN

	INSERT INTO tblSMEvents
	(intEntityId
	,intCalendarId
	,strEventTitle
	,strEventDetail
	,strJsonData
	,strScreen
	,strRecordNo
	,dtmStart
	,dtmEnd
	,dtmCreated
	,dtmModified
	,ysnActive
	,intConcurrencyId)
	SELECT
	@intUserId
	,NULL
	,'Time Off - ' + ENT.strName
	,'<p><b>Time Off Type:</b> ' + TTO.strTimeOff +'</p>' 
		+ '<p><b>Reason:</b> </br>' + TOR.strReason +'</p>'
		+ '<p><b>Address while on Time Off:</b></br>' + TOR.strAddress +'</p>'
	,'{"allDay":true,"drillDown":{"enabled":true,"url":"#/PR/TimeOffRequest?routeId=1%7C%5E%7C&activeTab=Details","text":"View Time Off Request "},"title":"Time Off - ' + REPLACE(ENT.strName, '', '''') + '"}'
	,'Payroll.view.TimeOffRequest'
	,CAST(TOR.intTimeOffRequestId AS NVARCHAR(100))
	,TOR.dtmDateFrom
	,TOR.dtmDateTo
	,GETDATE()
	,GETDATE()
	,1
	,1
	FROM tblPRTimeOffRequest TOR
	INNER JOIN tblEMEntity ENT ON TOR.intEntityEmployeeId = ENT.intEntityId
	INNER JOIN tblPRTypeTimeOff TTO ON TOR.intTypeTimeOffId = TTO.intTypeTimeOffId
	WHERE intTimeOffRequestId = @intTransactionId
	
	IF (@@ERROR = 0) UPDATE tblPRTimeOffRequest SET ysnPostedToCalendar = 1 WHERE intTimeOffRequestId = @intTransactionId

END