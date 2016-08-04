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
	,'{"allDay":true,"drillDown":{"enabled":true,"url":"#/PR/TimeOffRequest?routeId=' + CAST(intTimeOffRequestId AS NVARCHAR(20))+'%7C%5E%7C&activeTab=Details","text":"View Time Off Request "},"title":"Time Off - ' + REPLACE(ENT.strName, '', '''') + '"}'
	,'Payroll.view.TimeOffRequest'
	,CAST(TOR.intTimeOffRequestId AS NVARCHAR(100))
	,TOR.dtmDateFrom
	,DATEADD(HOUR, 23, CAST(FLOOR(CAST(TOR.dtmDateTo AS FLOAT)) AS DATETIME))
	,GETDATE()
	,GETDATE()
	,1
	,1
	FROM tblPRTimeOffRequest TOR
	INNER JOIN tblEMEntity ENT ON TOR.intEntityEmployeeId = ENT.intEntityId
	INNER JOIN tblPRTypeTimeOff TTO ON TOR.intTypeTimeOffId = TTO.intTypeTimeOffId
	WHERE intTimeOffRequestId = @intTransactionId
	
	IF (@@ERROR = 0) 
	BEGIN
		UPDATE tblPRTimeOffRequest 
		SET ysnPostedToCalendar = 1 
		WHERE intTimeOffRequestId = @intTransactionId
		
		INSERT INTO tblPRPayGroupDetail (
			intPayGroupId
			,intEntityEmployeeId
			,intEmployeeEarningId
			,intTypeEarningId
			,intDepartmentId
			,strCalculationType
			,dblDefaultHours
			,dblHoursToProcess
			,dblAmount
			,dblTotal
			,dtmDateFrom
			,dtmDateTo
			,intSort
			,intConcurrencyId
		)
		SELECT TOP 1 
			EE.intPayGroupId
			,TOR.intEntityEmployeeId
			,EE.intEmployeeEarningId
			,EE.intTypeEarningId
			,TOR.intDepartmentId
			,EE.strCalculationType
			,EE.dblDefaultHours
			,TOR.dblRequest
			,EE.dblRateAmount
			,dblTotal = CASE WHEN (EE.strCalculationType IN ('Rate Factor', 'Overtime') AND intEmployeeEarningLinkId IS NOT NULL) THEN 
							CASE WHEN ((SELECT TOP 1 strCalculationType FROM tblPRTypeEarning WHERE intTypeEarningId = EE.intEmployeeEarningLinkId) = 'Hourly Rate') THEN
								TOR.dblRequest * EE.dblRateAmount
							ELSE
								EE.dblRateAmount
							END
						WHEN (strCalculationType = 'Hourly Rate') THEN
							TOR.dblRequest * EE.dblRateAmount
						ELSE
							EE.dblRateAmount
						END
			,TOR.dtmDateFrom
			,TOR.dtmDateTo
			,1
			,1
		FROM tblPREmployeeEarning EE 
			INNER JOIN tblPRTimeOffRequest TOR
			ON TOR.intTimeOffRequestId = @intTransactionId AND EE.intEntityEmployeeId = TOR.intEntityEmployeeId
		WHERE EE.intEmployeeTimeOffId = TOR.intTypeTimeOffId
			AND EE.intPayGroupId IS NOT NULL
	END
END