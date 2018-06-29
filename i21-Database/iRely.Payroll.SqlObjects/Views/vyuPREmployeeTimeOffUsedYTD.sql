CREATE VIEW [dbo].[vyuPREmployeeTimeOffUsedYTD]
AS
SELECT
	intYear
	,intEntityEmployeeId
	,intTypeTimeOffId
	,dblHoursUsed = SUM(dblHours)
FROM
	(SELECT
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
		intYear = YEAR(dtmPayDate)
		,intEntityEmployeeId
		,intTypeTimeoffId = intEmployeeTimeOffId
		,dblHours
	FROM 
		tblPRPaycheckEarning PCE 
		INNER JOIN tblPRPaycheck PC
			ON PCE.intPaycheckId = PC.intPaycheckId
	WHERE 
		intEmployeeTimeOffId IS NOT NULL
		AND ysnPosted = 1
		AND ysnVoid = 0
		AND dblHours <> 0
	) TimeOffHours
GROUP BY 
	intYear
	,intEntityEmployeeId
	,intTypeTimeOffId

GO