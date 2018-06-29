CREATE PROCEDURE [dbo].[uspPRAddTimeOffToCalendar]
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

		EXEC uspSMAuditLog 'Payroll.view.TimeOffRequest', @intTransactionId, @intUserId, 'Unposted from Calendar', '', '', ''
		
		IF NOT EXISTS (SELECT TOP 1 1 FROM tblPREmployeeEarning EE INNER JOIN tblPRTimeOffRequest TOR
						ON TOR.intTimeOffRequestId = @intTimeOffRequestId AND EE.intEntityEmployeeId = TOR.intEntityEmployeeId
						WHERE EE.intEmployeeTimeOffId = TOR.intTypeTimeOffId AND EE.intPayGroupId IS NOT NULL)
		BEGIN
			UPDATE tblPRTimeOffRequest 
				SET dblEarned = tblPREmployeeTimeOff.dblHoursEarned
					,dblUsed = tblPREmployeeTimeOff.dblHoursUsed + ISNULL(vyuPREmployeeTimeOffUsedYTD.dblHoursUsed, 0)
					,dblBalance = (tblPREmployeeTimeOff.dblHoursCarryover + tblPREmployeeTimeOff.dblHoursEarned) 
								- (tblPREmployeeTimeOff.dblHoursUsed + ISNULL(vyuPREmployeeTimeOffUsedYTD.dblHoursUsed, 0))
			FROM tblPRTimeOffRequest 
				INNER JOIN tblPREmployeeTimeOff 
					ON tblPRTimeOffRequest.intEntityEmployeeId = tblPREmployeeTimeOff.intEntityEmployeeId
					AND tblPRTimeOffRequest.intTypeTimeOffId = tblPREmployeeTimeOff.intTypeTimeOffId
				LEFT JOIN vyuPREmployeeTimeOffUsedYTD
					ON tblPREmployeeTimeOff.intEntityEmployeeId = vyuPREmployeeTimeOffUsedYTD.intEntityEmployeeId
					AND tblPREmployeeTimeOff.intTypeTimeOffId = vyuPREmployeeTimeOffUsedYTD.intTypeTimeOffId
					AND vyuPREmployeeTimeOffUsedYTD.intYear = YEAR(GETDATE())
				
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

			UPDATE tblPRPayGroupDetail
				SET dblHoursToProcess = tblPRPayGroupDetail.dblHoursToProcess + TOR.dblRequest,
					dblAmount = CASE WHEN (EL.strCalculationType IN ('Fixed Amount', 'Salary') AND EL.dblDefaultHours > 0) THEN
												CASE WHEN (tblPRPayGroupDetail.dblHoursToProcess + TOR.dblRequest) < 0 THEN 0 
													ELSE tblPRPayGroupDetail.dblAmount + ROUND(((EL.dblRateAmount / EL.dblDefaultHours) * TOR.dblRequest), 2) END
											ELSE 
												tblPRPayGroupDetail.dblAmount 
											END,
					dblTotal = CASE WHEN (tblPRPayGroupDetail.dblHoursToProcess + TOR.dblRequest) < 0 THEN 0 
										ELSE
											CASE WHEN (EL.strCalculationType IN ('Hourly Rate', 'Overtime')) THEN
												(tblPRPayGroupDetail.dblHoursToProcess + TOR.dblRequest) * tblPRPayGroupDetail.dblAmount
											 WHEN (EL.strCalculationType IN ('Rate Factor')) THEN 
												CASE WHEN (EL2.strCalculationType = 'Hourly Rate') THEN
													(tblPRPayGroupDetail.dblHoursToProcess + TOR.dblRequest) * tblPRPayGroupDetail.dblAmount
												WHEN (EL2.strCalculationType IN ('Fixed Amount', 'Salary')) THEN
													CASE WHEN (EL2.dblDefaultHours > 0) THEN 
														(tblPRPayGroupDetail.dblHoursToProcess + TOR.dblRequest) * tblPRPayGroupDetail.dblAmount
													ELSE tblPRPayGroupDetail.dblTotal END
												ELSE
													tblPRPayGroupDetail.dblTotal
												END
											 WHEN (EL.strCalculationType IN ('Fixed Amount', 'Salary')) THEN
												CASE WHEN (EL.dblDefaultHours > 0) THEN 
													tblPRPayGroupDetail.dblTotal + ROUND(((EL.dblRateAmount / EL.dblDefaultHours) * TOR.dblRequest), 2)
												ELSE tblPRPayGroupDetail.dblTotal END
											 ELSE
												tblPRPayGroupDetail.dblTotal
											 END
										END
			FROM
				tblPREmployeeEarning EL
				LEFT JOIN tblPREmployeeEarning EL2
					ON EL2.intTypeEarningId = EL.intEmployeeEarningLinkId AND EL2.intEntityEmployeeId = EL.intEntityEmployeeId
				INNER JOIN tblPREmployeeEarning EE 
					ON EL.intTypeEarningId = EE.intEmployeeEarningLinkId AND EL.intEntityEmployeeId = EE.intEntityEmployeeId
				INNER JOIN tblPRTimeOffRequest TOR
					ON TOR.intTimeOffRequestId = @intTimeOffRequestId AND EE.intEntityEmployeeId = TOR.intEntityEmployeeId
						AND EE.intEmployeeTimeOffId = TOR.intTypeTimeOffId
						AND EL.intPayGroupId IS NOT NULL
			WHERE 
				tblPRPayGroupDetail.intPayGroupDetailId = (SELECT TOP 1 PGD.intPayGroupDetailId FROM tblPRPayGroupDetail PGD 
							INNER JOIN tblPREmployeeEarning EL
								ON PGD.intEmployeeEarningId = EL.intEmployeeEarningId
							INNER JOIN tblPREmployeeEarning EE 
								ON EL.intTypeEarningId = EE.intEmployeeEarningLinkId AND EL.intEntityEmployeeId = EE.intEntityEmployeeId
							INNER JOIN tblPRTimeOffRequest TOR
								ON TOR.intTimeOffRequestId = @intTimeOffRequestId AND EE.intEntityEmployeeId = TOR.intEntityEmployeeId
									AND EE.intEmployeeTimeOffId = TOR.intTypeTimeOffId
									AND EL.intPayGroupId IS NOT NULL
									AND PGD.dtmDateFrom <= ISNULL(TOR.dtmDateFrom, PGD.dtmDateFrom) AND PGD.dtmDateTo >= ISNULL(TOR.dtmDateFrom, PGD.dtmDateTo))

		END
	END
	ELSE
	BEGIN
		/* Check if TOR is already approved */
		IF NOT EXISTS (SELECT TOP 1 1 FROM vyuPRTimeOffRequest WHERE intTimeOffRequestId = @intTimeOffRequestId AND strApprovalStatus IN ('Approved', 'No Need for Approval'))
		BEGIN
			PRINT 'Time Off Request has not been approved.'
			GOTO Post_Exit
		END

		/* Post to Global Calendar */
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
			,intCalendarId = (SELECT TOP 1 intCalendarId from tblSMCalendars WHERE strCalendarName = 'Time Off' and strCalendarType = 'System')
			,'Time Off - ' + ENT.strName
			,'<table style="font-size: 14px;"><tbody>'
				+ '<tr><td><strong>Time Off Type</strong></td><td>' + REPLACE(TTO.strTimeOff, '''', '''''') +'</td></tr>'
				+ '<tr><td><strong>Time Off Hours</strong></td><td>' + CAST(CAST(TOR.dblRequest AS FLOAT) AS NVARCHAR(50)) + '</td></tr>'
				+ '<tr><td><strong>Address while on Time Off</strong></td><td>' + REPLACE(TOR.strAddress, '''', '''''') + '</td></tr>'
				+ '</tbody></table>'
			,'{"allDay":"true","drillDown":{"enabled":true,"url":"#/PR/TimeOffRequest?routeId=' + CAST(intTimeOffRequestId AS NVARCHAR(20))+'%7C%5E%7C&activeTab=Details","text":"View Time Off Request "},"title":"Time Off - ' + REPLACE(ENT.strName, '', '''') + '"}'
			,'Payroll.view.TimeOffRequest'
			,CAST(TOR.intTimeOffRequestId AS NVARCHAR(100))
			,TOR.dtmDateFrom
			,TOR.dtmDateTo
			,GETDATE()
			,GETDATE()
			,1
			,1
		FROM 
			tblPRTimeOffRequest TOR
			INNER JOIN tblEMEntity ENT ON TOR.intEntityEmployeeId = ENT.intEntityId
			INNER JOIN tblPRTypeTimeOff TTO ON TOR.intTypeTimeOffId = TTO.intTypeTimeOffId
		WHERE intTimeOffRequestId = @intTimeOffRequestId
	
		IF (@@ERROR = 0) 
		BEGIN
	
			UPDATE tblPRTimeOffRequest 
			SET ysnPostedToCalendar = 1
				,intEventId = (SELECT TOP 1 intEventId FROM @udtSMEventsIn)
			WHERE intTimeOffRequestId = @intTimeOffRequestId

			EXEC uspSMAuditLog 'Payroll.view.TimeOffRequest', @intTransactionId, @intUserId, 'Posted to Calendar', '', '', ''
		
			/* If Time Off is setup to Deduct from Earning, create Pay Group Detail entry */
			IF EXISTS (SELECT TOP 1 1 FROM tblPREmployeeEarning EE INNER JOIN tblPRTimeOffRequest TOR
						ON TOR.intTimeOffRequestId = @intTimeOffRequestId AND EE.intEntityEmployeeId = TOR.intEntityEmployeeId
						WHERE EE.intEmployeeTimeOffId = TOR.intTypeTimeOffId AND EE.intPayGroupId IS NOT NULL)
			BEGIN
				DECLARE @intTimeOffPayGroupDetail INT

				/* Insert Pay Group Detail Entry for the Time Off */
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
					,intSource
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
					,CASE WHEN (EE.strCalculationType = 'Rate Factor' AND EL.strCalculationType IN ('Fixed Amount', 'Salary') AND EL.dblDefaultHours > 0) 
							THEN TOR.dblRequest * EE.dblRateAmount
						WHEN (EE.strCalculationType IN ('Fixed Amount', 'Salary') AND EE.dblDefaultHours > 0) 
							THEN ROUND(((EE.dblRateAmount / EE.dblDefaultHours) * TOR.dblRequest), 2) 
						ELSE EE.dblRateAmount END
					,dblTotal = CASE WHEN (EE.strCalculationType IN ('Hourly Rate', 'Overtime')) THEN
										TOR.dblRequest * EE.dblRateAmount
									 WHEN (EE.strCalculationType IN ('Rate Factor')) THEN 
										CASE WHEN (EL.strCalculationType = 'Hourly Rate') THEN
											TOR.dblRequest * EE.dblRateAmount
										WHEN (EL.strCalculationType IN ('Fixed Amount', 'Salary')) THEN
											CASE WHEN (EL.dblDefaultHours > 0) THEN 
												TOR.dblRequest * EE.dblRateAmount
											ELSE EE.dblRateAmount END
										ELSE
											0
										END
									 WHEN (EE.strCalculationType IN ('Fixed Amount', 'Salary')) THEN
										CASE WHEN (EE.dblDefaultHours > 0) THEN 
											ROUND(((EE.dblRateAmount / EE.dblDefaultHours) * TOR.dblRequest), 2)
										ELSE EE.dblRateAmount END
									 ELSE
										EE.dblRateAmount
									 END
					,TOR.dtmDateFrom
					,TOR.dtmDateTo
					,4
					,1
					,1
				FROM
					tblPREmployeeEarning EE 
					LEFT JOIN tblPREmployeeEarning EL
						ON EL.intTypeEarningId = EE.intEmployeeEarningLinkId AND EL.intEntityEmployeeId = EE.intEntityEmployeeId
					INNER JOIN tblPRTimeOffRequest TOR
						ON TOR.intTimeOffRequestId = @intTimeOffRequestId AND EE.intEntityEmployeeId = TOR.intEntityEmployeeId
					WHERE EE.intEmployeeTimeOffId = TOR.intTypeTimeOffId
					AND EE.intPayGroupId IS NOT NULL

				SELECT @intTimeOffPayGroupDetail = SCOPE_IDENTITY()
				UPDATE tblPRTimeOffRequest SET intPayGroupDetailId = @intTimeOffPayGroupDetail WHERE intTimeOffRequestId = @intTimeOffRequestId

				/* Check if the corresponding Linked Earning to deduct exists in the Pay Group Detail */
				DECLARE @intPayGroupDetail INT = NULL
				DECLARE @intSource INT = 1
				SELECT TOP 1 @intPayGroupDetail = PGD.intPayGroupDetailId FROM tblPRPayGroupDetail PGD 
							INNER JOIN tblPREmployeeEarning EL
								ON PGD.intEmployeeEarningId = EL.intEmployeeEarningId
							INNER JOIN tblPREmployeeEarning EE 
								ON EL.intTypeEarningId = EE.intEmployeeEarningLinkId AND EL.intEntityEmployeeId = EE.intEntityEmployeeId
							INNER JOIN tblPRTimeOffRequest TOR
								ON TOR.intTimeOffRequestId = @intTimeOffRequestId AND EE.intEntityEmployeeId = TOR.intEntityEmployeeId
									AND EE.intEmployeeTimeOffId = TOR.intTypeTimeOffId
									AND EL.intPayGroupId IS NOT NULL
									AND PGD.dtmDateFrom <= ISNULL(TOR.dtmDateFrom, PGD.dtmDateFrom) AND PGD.dtmDateTo >= ISNULL(TOR.dtmDateFrom, PGD.dtmDateTo)
									AND intSource IN (0, 3)

				IF (@intPayGroupDetail IS NULL)
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
						,intSource
						,intSort
						,intConcurrencyId
					)
					SELECT TOP 1 
						EL.intPayGroupId
						,TOR.intEntityEmployeeId
						,EL.intEmployeeEarningId
						,EL.intTypeEarningId
						,TOR.intDepartmentId
						,EL.strCalculationType
						,EL.dblDefaultHours
						,CASE WHEN (EL.dblDefaultHours - TOR.dblRequest) < 0 THEN 0 ELSE EL.dblDefaultHours - TOR.dblRequest END
						,CASE WHEN (EL.strCalculationType IN ('Fixed Amount', 'Salary') AND EL.dblDefaultHours > 0) THEN 
								CASE WHEN (EL.dblDefaultHours - TOR.dblRequest) < 0 THEN 0 
									ELSE EL.dblRateAmount - ROUND(((EL.dblRateAmount / EL.dblDefaultHours) * TOR.dblRequest), 2) END
							ELSE EL.dblRateAmount END
						,dblTotal = CASE WHEN (EL.strCalculationType IN ('Hourly Rate', 'Overtime')) THEN
										(EL.dblDefaultHours - TOR.dblRequest) * EL.dblRateAmount
									 WHEN (EL.strCalculationType IN ('Rate Factor')) THEN 
										CASE WHEN (EL2.strCalculationType = 'Hourly Rate') THEN
											(EL.dblDefaultHours - TOR.dblRequest) * EL.dblRateAmount
										WHEN (EL2.strCalculationType IN ('Fixed Amount', 'Salary')) THEN
											CASE WHEN (EL2.dblDefaultHours > 0) THEN 
												(EL.dblDefaultHours - TOR.dblRequest) * EL.dblRateAmount
											ELSE EL.dblRateAmount END
										ELSE
											0
										END
									 WHEN (EL.strCalculationType IN ('Fixed Amount', 'Salary')) THEN
										CASE WHEN (EL.dblDefaultHours > 0) THEN 
											EL.dblRateAmount - ROUND(((EL.dblRateAmount / EL.dblDefaultHours) * TOR.dblRequest), 2)
										ELSE EL.dblRateAmount END
									 ELSE
										EL.dblRateAmount
									 END
						,TOR.dtmDateFrom
						,TOR.dtmDateTo
						,0
						,1
						,1
					FROM 
						tblPREmployeeEarning EL
						LEFT JOIN tblPREmployeeEarning EL2
							ON EL2.intTypeEarningId = EL.intEmployeeEarningLinkId AND EL2.intEntityEmployeeId = EL.intEntityEmployeeId
						INNER JOIN tblPREmployeeEarning EE 
							ON EL.intTypeEarningId = EE.intEmployeeEarningLinkId AND EL.intEntityEmployeeId = EE.intEntityEmployeeId
						INNER JOIN tblPRTimeOffRequest TOR
							ON TOR.intTimeOffRequestId = @intTimeOffRequestId AND EE.intEntityEmployeeId = TOR.intEntityEmployeeId
								AND EE.intEmployeeTimeOffId = TOR.intTypeTimeOffId
								AND EL.intPayGroupId IS NOT NULL
				ELSE
					UPDATE tblPRPayGroupDetail
						SET tblPRPayGroupDetail.dblHoursToProcess = tblPRPayGroupDetail.dblHoursToProcess - TOR.dblRequest,
							dblAmount = CASE WHEN (EL.strCalculationType IN ('Fixed Amount', 'Salary') AND EL.dblDefaultHours > 0) THEN
												CASE WHEN (tblPRPayGroupDetail.dblHoursToProcess - TOR.dblRequest) < 0 THEN 0 
													ELSE tblPRPayGroupDetail.dblAmount - ROUND(((EL.dblRateAmount / EL.dblDefaultHours) * TOR.dblRequest), 2) END
											ELSE 
												tblPRPayGroupDetail.dblAmount 
											END,
							dblTotal = CASE WHEN (tblPRPayGroupDetail.dblHoursToProcess - TOR.dblRequest) < 0 THEN 0 
										ELSE
											CASE WHEN (EL.strCalculationType IN ('Hourly Rate', 'Overtime')) THEN
												(tblPRPayGroupDetail.dblHoursToProcess - TOR.dblRequest) * tblPRPayGroupDetail.dblAmount
											 WHEN (EL.strCalculationType IN ('Rate Factor')) THEN 
												CASE WHEN (EL2.strCalculationType = 'Hourly Rate') THEN
													(tblPRPayGroupDetail.dblHoursToProcess - TOR.dblRequest) * tblPRPayGroupDetail.dblAmount
												WHEN (EL2.strCalculationType IN ('Fixed Amount', 'Salary')) THEN
													CASE WHEN (EL2.dblDefaultHours > 0) THEN 
														(tblPRPayGroupDetail.dblHoursToProcess - TOR.dblRequest) * tblPRPayGroupDetail.dblAmount
													ELSE tblPRPayGroupDetail.dblTotal END
												ELSE
													tblPRPayGroupDetail.dblTotal
												END
											 WHEN (EL.strCalculationType IN ('Fixed Amount', 'Salary')) THEN
												CASE WHEN (EL.dblDefaultHours > 0) THEN 
													tblPRPayGroupDetail.dblTotal - ROUND(((EL.dblRateAmount / EL.dblDefaultHours) * TOR.dblRequest), 2)
												ELSE tblPRPayGroupDetail.dblTotal END
											 ELSE
												tblPRPayGroupDetail.dblTotal
											 END
										END
					FROM
						tblPREmployeeEarning EL
						LEFT JOIN tblPREmployeeEarning EL2
							ON EL2.intTypeEarningId = EL.intEmployeeEarningLinkId AND EL2.intEntityEmployeeId = EL.intEntityEmployeeId
						INNER JOIN tblPREmployeeEarning EE 
							ON EL.intTypeEarningId = EE.intEmployeeEarningLinkId AND EL.intEntityEmployeeId = EE.intEntityEmployeeId
						INNER JOIN tblPRTimeOffRequest TOR
							ON TOR.intTimeOffRequestId = @intTimeOffRequestId AND EE.intEntityEmployeeId = TOR.intEntityEmployeeId
								AND EE.intEmployeeTimeOffId = TOR.intTypeTimeOffId
								AND EL.intPayGroupId IS NOT NULL
					WHERE 
						tblPRPayGroupDetail.intPayGroupDetailId = @intPayGroupDetail AND tblPRPayGroupDetail.intSource = 0
			END
		END	
	END

Post_Exit:

END
