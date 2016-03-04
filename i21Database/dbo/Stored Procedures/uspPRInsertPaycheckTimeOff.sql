CREATE PROCEDURE [dbo].[uspPRInsertPaycheckTimeOff]
	@intPaycheckId INT
AS

DELETE FROM tblPRPaycheckTimeOff WHERE intPaycheckId = @intPaycheckId 

INSERT INTO tblPRPaycheckTimeOff (
	intPaycheckId
	,intEmployeeTimeOffId
	,intTypeTimeOffId
	,dblRate
	,dblPerPeriod
	,strPeriod
	,dblRateFactor
	,dblMaxEarned
	,dblMaxCarryover
	,dblHoursAccrued
	,dblHoursUsed
	,dblHoursYTD
)
SELECT
	@intPaycheckId
	,D.intEmployeeTimeOffId 
	,D.intTypeTimeOffId
	,D.dblRate
	,D.dblPerPeriod
	,D.strPeriod
	,D.dblRateFactor
	,D.dblMaxEarned 
	,D.dblMaxCarryover
	,dblHoursAccrued	= CASE WHEN (C.intEmployeeAccrueTimeOffId = D.intTypeTimeOffId) THEN  B.dblHours * D.dblRate * D.dblPerPeriod * D.dblRateFactor ELSE 0 END
	,dblHoursUsed		= CASE WHEN (C.intEmployeeTimeOffId = D.intTypeTimeOffId) THEN B.dblHours ELSE 0 END
	,dblHoursYTD		= D.dblHoursEarned
FROM 
	tblPRPaycheckEarning B 
	INNER JOIN tblPREmployeeEarning C ON B.intEmployeeEarningId = C.intEmployeeEarningId
	LEFT JOIN tblPRPaycheck A ON A.intPaycheckId = B.intPaycheckId
	LEFT JOIN tblPREmployeeTimeOff D 
		 ON C.intEntityEmployeeId = D.intEntityEmployeeId AND
		 (D.intTypeTimeOffId = C.intEmployeeTimeOffId OR D.intTypeTimeOffId = C.intEmployeeAccrueTimeOffId)
WHERE D.intEmployeeTimeOffId IS NOT NULL AND B.intPaycheckId = @intPaycheckId AND A.ysnPosted = 1

GO