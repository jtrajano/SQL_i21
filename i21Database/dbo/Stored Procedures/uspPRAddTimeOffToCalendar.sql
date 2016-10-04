﻿CREATE PROCEDURE [dbo].[uspPRAddTimeOffToCalendar]
	@intTransactionId INT
	,@intUserId INT
	,@ysnCancel BIT = 0
AS
BEGIN

DECLARE @intTimeOffRequestId INT
SELECT @intTimeOffRequestId = @intTransactionId

	IF (@ysnCancel = 1)
	BEGIN
		/* Cancel Time Off */
		UPDATE tblPRTimeOffRequest 
			SET ysnPostedToCalendar = 0
				,intEventId = NULL
		WHERE intTimeOffRequestId = @intTimeOffRequestId
		
		DELETE FROM tblSMEvents
		WHERE CAST(strRecordNo AS INT) = @intTimeOffRequestId
			AND strScreen = 'Payroll.view.TimeOffRequest'
		
		IF NOT EXISTS (SELECT TOP 1 1 FROM tblPREmployeeEarning EE INNER JOIN tblPRTimeOffRequest TOR
						ON TOR.intTimeOffRequestId = @intTimeOffRequestId AND EE.intEntityEmployeeId = TOR.intEntityEmployeeId
						WHERE EE.intEmployeeTimeOffId = TOR.intTypeTimeOffId AND EE.intPayGroupId IS NOT NULL)
		BEGIN
			UPDATE tblPREmployeeTimeOff 
				SET dblHoursUsed = dblHoursUsed - tblTimeOffRequest.dblRequest
			FROM 
			(SELECT TOR.intTimeOffRequestId, 
					ET.intTypeTimeOffId, 
					TOR.intEntityEmployeeId, 
					TOR.dblRequest 
				FROM tblPREmployeeTimeOff ET INNER JOIN tblPRTimeOffRequest TOR
					ON ET.intEntityEmployeeId = TOR.intEntityEmployeeId AND ET.intTypeTimeOffId = TOR.intTypeTimeOffId) tblTimeOffRequest
			WHERE tblPREmployeeTimeOff.intTypeTimeOffId = tblTimeOffRequest.intTypeTimeOffId
				AND tblPREmployeeTimeOff.intEntityEmployeeId = tblTimeOffRequest.intEntityEmployeeId
				AND tblTimeOffRequest.intTimeOffRequestId = @intTimeOffRequestId

			UPDATE tblPRTimeOffRequest 
				SET dblEarned = tblPREmployeeTimeOff.dblHoursEarned
					,dblUsed = tblPREmployeeTimeOff.dblHoursUsed
					,dblBalance = tblPREmployeeTimeOff.dblHoursEarned - tblPREmployeeTimeOff.dblHoursUsed
			FROM tblPRTimeOffRequest 
				INNER JOIN tblPREmployeeTimeOff 
				ON tblPRTimeOffRequest.intEntityEmployeeId = tblPREmployeeTimeOff.intEntityEmployeeId
				AND tblPRTimeOffRequest.intTypeTimeOffId = tblPREmployeeTimeOff.intTypeTimeOffId
			WHERE intTimeOffRequestId = @intTimeOffRequestId
		END
		ELSE
		BEGIN
			DELETE PGD
			FROM tblPRPayGroupDetail PGD
			INNER JOIN tblPRTimeOffRequest TOR
				ON TOR.intEntityEmployeeId = PGD.intEntityEmployeeId
				AND TOR.dtmDateFrom = PGD.dtmDateFrom 
				AND TOR.dtmDateTo = PGD.dtmDateTo
			INNER JOIN tblPREmployeeEarning EE
				ON EE.intEntityEmployeeId = PGD.intEntityEmployeeId
				AND EE.intEmployeeTimeOffId = TOR.intTypeTimeOffId
			WHERE TOR.intTimeOffRequestId = @intTimeOffRequestId
		END
	END
	ELSE
	BEGIN
		/* Post to Calendar */
		DECLARE @udtSMEventsIn TABLE(intEventId INT)

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
		OUTPUT
			Inserted.intEventId
		INTO 
			@udtSMEventsIn 
		SELECT
		@intUserId
		,NULL
		,'Time Off - ' + ENT.strName
		,'<table style="font-size: 14px;"><tbody>'
			+ '<tr><td><strong>Time Off Type</strong></td><td>' + REPLACE(TTO.strTimeOff, '''', '''''') +'</td></tr>'
			+ '<tr><td><strong>Time Off Hours</strong></td><td>' + CAST(CAST(TOR.dblRequest AS FLOAT) AS NVARCHAR(50)) + '</td></tr>'
			+ '<tr><td><strong>Reason</strong></td><td>' + REPLACE(TOR.strReason, '''', '''''') + '</td></tr>'
			+ '<tr><td><strong>Address while on Time Off</strong></td><td>' + REPLACE(TOR.strAddress, '''', '''''') + '</td></tr>'
			+ '</tbody></table>'
		,'{"drillDown":{"enabled":true,"url":"#/PR/TimeOffRequest?routeId=' + CAST(intTimeOffRequestId AS NVARCHAR(20))+'%7C%5E%7C&activeTab=Details","text":"View Time Off Request "},"title":"Time Off - ' + REPLACE(ENT.strName, '', '''') + '"}'
		,'Payroll.view.TimeOffRequest'
		,CAST(TOR.intTimeOffRequestId AS NVARCHAR(100))
		,DATEADD(hh, -(DATEDIFF(hh, GETDATE(), GETUTCDATE())), CAST(FLOOR(CAST(TOR.dtmDateFrom AS FLOAT)) AS DATETIME))
		,DATEADD(hh, -(DATEDIFF(hh, GETDATE(), GETUTCDATE())), DATEADD(MS,-3, DATEADD(day, 1, DATEADD(DD, DATEDIFF(DD, 0, TOR.dtmDateTo), 0))))
		,GETDATE()
		,GETDATE()
		,1
		,1
		FROM tblPRTimeOffRequest TOR
		INNER JOIN tblEMEntity ENT ON TOR.intEntityEmployeeId = ENT.intEntityId
		INNER JOIN tblPRTypeTimeOff TTO ON TOR.intTypeTimeOffId = TTO.intTypeTimeOffId
		WHERE intTimeOffRequestId = @intTimeOffRequestId
	
		IF (@@ERROR = 0) 
		BEGIN
	
			UPDATE tblPRTimeOffRequest 
			SET ysnPostedToCalendar = 1
				,intEventId = (SELECT TOP 1 intEventId FROM @udtSMEventsIn)
			WHERE intTimeOffRequestId = @intTimeOffRequestId
		
			IF EXISTS (SELECT TOP 1 1 FROM tblPREmployeeEarning EE INNER JOIN tblPRTimeOffRequest TOR
						ON TOR.intTimeOffRequestId = @intTimeOffRequestId AND EE.intEntityEmployeeId = TOR.intEntityEmployeeId
						WHERE EE.intEmployeeTimeOffId = TOR.intTypeTimeOffId AND EE.intPayGroupId IS NOT NULL)
			BEGIN
				/* If Time Off is setup to Deduct from Earning, create Pay Group Detail entry */
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
					ON TOR.intTimeOffRequestId = @intTimeOffRequestId AND EE.intEntityEmployeeId = TOR.intEntityEmployeeId
				WHERE EE.intEmployeeTimeOffId = TOR.intTypeTimeOffId
					AND EE.intPayGroupId IS NOT NULL
			END
			ELSE
			BEGIN
				/* If Time Off is not setup to Deduct from Earning, deduct it directly from time off */
				UPDATE tblPREmployeeTimeOff 
					SET dblHoursUsed = dblHoursUsed + tblTimeOffRequest.dblRequest
				FROM 
				(SELECT TOR.intTimeOffRequestId, 
						ET.intTypeTimeOffId, 
						TOR.intEntityEmployeeId, 
						TOR.dblRequest 
				   FROM tblPREmployeeTimeOff ET INNER JOIN tblPRTimeOffRequest TOR
					 ON ET.intEntityEmployeeId = TOR.intEntityEmployeeId AND ET.intTypeTimeOffId = TOR.intTypeTimeOffId) tblTimeOffRequest
				WHERE tblPREmployeeTimeOff.intTypeTimeOffId = tblTimeOffRequest.intTypeTimeOffId
					AND tblPREmployeeTimeOff.intEntityEmployeeId = tblTimeOffRequest.intEntityEmployeeId
					AND tblTimeOffRequest.intTimeOffRequestId = @intTimeOffRequestId
			END
		END	
	END
END
