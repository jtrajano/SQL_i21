CREATE VIEW [dbo].[vyuPREmployeeTimeOffUsedYTD]
AS
SELECT
	intYear
	,intEntityEmployeeId
	,intTypeTimeOffId
	,dblHoursUsed = SUM(dblHoursUsed)
	,dblHoursUsedReset = SUM(dblHoursUsedReset)
FROM
		(
		
		SELECT 
			intYear = YEAR(GETDATE())
			,intEntityEmployeeId
			,intTypeTimeOffId
			,dblHoursUsed
			,dblHoursUsedReset
		FROM 
			vyuPREmployeeTimeOff			

		) TimeOffHours
GROUP BY 
	intYear
	,intEntityEmployeeId
	,intTypeTimeOffId

GO