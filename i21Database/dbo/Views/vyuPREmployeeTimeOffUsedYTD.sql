CREATE VIEW [dbo].[vyuPREmployeeTimeOffUsedYTD]
AS
SELECT
	intYear
	,intEntityEmployeeId
	,intTypeTimeOffId
	,dblHoursUsed = SUM(dblHoursUsed)
FROM
		(
		
		SELECT 
			intYear = YEAR(GETDATE())
			,intEntityEmployeeId
			,intTypeTimeOffId
			,dblHoursUsed
		FROM 
			vyuPREmployeeTimeOff			

		) TimeOffHours
GROUP BY 
	intYear
	,intEntityEmployeeId
	,intTypeTimeOffId

GO