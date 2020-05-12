CREATE VIEW [dbo].[vyuPREmployeeTimeOffUsedYTD]
AS
SELECT
	intYear
	,intEntityEmployeeId
	,intTypeTimeOffId
	,dblHoursUsed = SUM(dblHours)
FROM
		(
		
		SELECT
			intYear  = YEAR(dtmDateFrom)
			,intEntityEmployeeId
			,intTypeTimeOffId
			,dblHours = dblRequest
		FROM tblPRTimeOffRequest TOR
		WHERE NOT EXISTS (SELECT 1 FROM tblPREmployeeEarning 
			WHERE intEntityEmployeeId = TOR.intEntityEmployeeId 
				AND intEmployeeTimeOffId = TOR.intTypeTimeOffId)
			AND ysnPostedToCalendar = 1

		UNION ALL
	
		SELECT 
			intYear = YEAR(GETDATE())
			,intEntityEmployeeId
			,intTypeTimeoffId = intTypeTimeOffId
			,dblHoursUsed
		FROM 
			vyuPREmployeeTimeOff			

		) TimeOffHours
GROUP BY 
	intYear
	,intEntityEmployeeId
	,intTypeTimeOffId

GO