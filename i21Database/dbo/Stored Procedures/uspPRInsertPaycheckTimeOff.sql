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
	,tblPREmployeeTimeOff.intTypeTimeOffId
	,dblRate
	,dblPerPeriod
	,strPeriod
	,dblRateFactor
	,dblMaxEarned 
	,dblMaxCarryover
	,dblHoursAccrued
	,dblHoursUsed = (tblPREmployeeTimeOff.dblHoursUsed + vyuPREmployeeTimeOffUsedYTD.dblHoursUsed)
	,dblHoursYTD = (dblHoursCarryover + dblHoursEarned) - (tblPREmployeeTimeOff.dblHoursUsed + vyuPREmployeeTimeOffUsedYTD.dblHoursUsed)
FROM 
	tblPREmployeeTimeOff
	LEFT JOIN vyuPREmployeeTimeOffUsedYTD
		ON tblPREmployeeTimeOff.intEntityEmployeeId = vyuPREmployeeTimeOffUsedYTD.intEntityEmployeeId
		AND tblPREmployeeTimeOff.intTypeTimeOffId = vyuPREmployeeTimeOffUsedYTD.intTypeTimeOffId
		AND vyuPREmployeeTimeOffUsedYTD.intYear = YEAR(GETDATE())
WHERE 
	tblPREmployeeTimeOff.intEntityEmployeeId = (SELECT TOP 1 intEntityEmployeeId FROM tblPRPaycheck WHERE intPaycheckId = @intPaycheckId)
GO