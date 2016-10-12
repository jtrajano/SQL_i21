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
	,dblHoursAccrued
	,dblHoursUsed
	,dblHoursYTD = dblHoursEarned - dblHoursUsed
FROM 
	tblPREmployeeTimeOff
WHERE 
	intEntityEmployeeId = (SELECT TOP 1 intEntityEmployeeId FROM tblPRPaycheck WHERE intPaycheckId = @intPaycheckId)
GO