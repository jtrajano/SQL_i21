﻿CREATE PROCEDURE [dbo].[uspPRInsertPaycheckTimeOff]
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
	,dblMaxBalance
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
	,dblMaxBalance
	,dblHoursAccrued
	,dblHoursUsed = ISNULL(vyuPREmployeeTimeOffUsedYTD.dblHoursUsed, 0)
	,dblHoursYTD = (dblHoursCarryover + dblHoursEarned) - (tblPREmployeeTimeOff.dblHoursUsed + ISNULL(vyuPREmployeeTimeOffUsedYTD.dblHoursUsed, 0))
FROM 
	tblPREmployeeTimeOff
	LEFT JOIN vyuPREmployeeTimeOffUsedYTD
		ON tblPREmployeeTimeOff.intEntityEmployeeId = vyuPREmployeeTimeOffUsedYTD.intEntityEmployeeId
		AND tblPREmployeeTimeOff.intTypeTimeOffId = vyuPREmployeeTimeOffUsedYTD.intTypeTimeOffId
		AND vyuPREmployeeTimeOffUsedYTD.intYear = YEAR(GETDATE())
WHERE 
	tblPREmployeeTimeOff.intEntityEmployeeId = (SELECT TOP 1 intEntityEmployeeId FROM tblPRPaycheck WHERE intPaycheckId = @intPaycheckId)
GO