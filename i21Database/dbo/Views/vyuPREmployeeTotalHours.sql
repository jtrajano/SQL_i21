CREATE VIEW [dbo].[vyuPREmployeeTotalHours]
AS 
SELECT TC.intEntityEmployeeId
	,TC.intWorkersCompensationId
	,TH.dblTotalHours
FROM (
	SELECT DISTINCT intEntityEmployeeId
		,intWorkersCompensationId
	FROM tblPRTimecard
) TC
LEFT JOIN (
	SELECT intEntityEmployeeId
		,intWorkersCompensationId
		,dblTotalHours = SUM(ISNULL(dblHours,0))
	FROM tblPRTimecard
	GROUP BY
		intEntityEmployeeId
		,intWorkersCompensationId
)TH ON TC.intEntityEmployeeId = TH.intEntityEmployeeId AND TC.intWorkersCompensationId = TH.intWorkersCompensationId
