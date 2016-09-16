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
	,intEmployeeTimeOffId 
	,intTypeTimeOffId
	,dblRate
	,dblPerPeriod
	,strPeriod
	,dblRateFactor
	,dblMaxEarned 
	,dblMaxCarryover
	,SUM(dblHoursAccrued) dblHoursAccrued
	,SUM(dblHoursUsed) dblHoursUsed
	,MAX(dblHoursYTD) dblHoursYTD
FROM 
	(SELECT
		D.intEmployeeTimeOffId 
		,D.intTypeTimeOffId
		,D.dblRate
		,D.dblPerPeriod
		,D.strPeriod
		,D.dblRateFactor
		,D.dblMaxEarned 
		,D.dblMaxCarryover
		,dblHoursAccrued	= CASE WHEN (C.intEmployeeAccrueTimeOffId = D.intTypeTimeOffId AND D.strPeriod = 'Hour')
								   THEN B.dblHours * D.dblRate * D.dblPerPeriod * D.dblRateFactor 
								   ELSE 0 END
		,dblHoursUsed		= CASE WHEN (C.intEmployeeTimeOffId = D.intTypeTimeOffId) THEN B.dblHours ELSE 0 END
		,dblHoursYTD		= D.dblHoursEarned - D.dblHoursUsed
	FROM
		tblPRPaycheckEarning B 
		INNER JOIN tblPREmployeeEarning C ON B.intEmployeeEarningId = C.intEmployeeEarningId
		INNER JOIN tblPRPaycheck A ON A.intPaycheckId = B.intPaycheckId
		LEFT JOIN tblPREmployeeTimeOff D 
			 ON C.intEntityEmployeeId = D.intEntityEmployeeId AND
			 (D.intTypeTimeOffId = C.intEmployeeTimeOffId OR D.intTypeTimeOffId = C.intEmployeeAccrueTimeOffId)
	WHERE 
		D.intEmployeeTimeOffId IS NOT NULL AND B.intPaycheckId = @intPaycheckId AND A.ysnPosted = 1) TimeOff
WHERE 
	dblHoursAccrued > 0 OR dblHoursUsed > 0
GROUP BY
	intEmployeeTimeOffId 
	,intTypeTimeOffId
	,dblRate
	,dblPerPeriod
	,strPeriod
	,dblRateFactor
	,dblMaxEarned 
	,dblMaxCarryover
GO