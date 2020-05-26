CREATE VIEW [dbo].[vyuPREmployeeTimeOff]
AS 
SELECT ETO.intEntityEmployeeId
	,ET.intEntityId
	,ETO.intEmployeeTimeOffId
	,ETO.intTypeTimeOffId
	,ET.strEntityNo
	,strEntityName = ET.strName
	,strTimeOffId = TTO.strTimeOff
	,strTimeOffDescription = TTO.strDescription
	,dblHoursLeft = ISNULL(dblHoursEarned,0) - ISNULL(dblHoursUsed,0)
	,ETO.dtmEligible
	,ETO.dblRate
	,ETO.strAwardPeriod
	,ETO.dblRateFactor
	,ETO.dblMaxCarryover
	,ETO.dblMaxEarned
	,ETO.dtmLastAward
	,ETO.dblHoursEarned
	,ETO.dblHoursAccrued
	,ETO.intSort
	,ETO.dblPerPeriod
	,ETO.strPeriod
	,EMP.intRank
	,dblHoursUsed = ISNULL(TOYTD.dblHoursUsedYTD,0)
	,dblBalance = (ETO.dblHoursCarryover + ETO.dblHoursEarned) - ETO.dblHoursUsed - ISNULL(TOYTD.dblHoursUsedYTD,0)
	,ETO.dblHoursCarryover  
	,dblAdjustments =  ETO.dblHoursUsed 
FROM tblPREmployeeTimeOff ETO
LEFT JOIN(
	SELECT intEntityId
		,strEntityNo
		,strName
	FROM tblEMEntity
) ET ON ETO.intEntityEmployeeId = ET.intEntityId
LEFT JOIN(
	SELECT intTypeTimeOffId
		,strTimeOff
		,strDescription
	FROM tblPRTypeTimeOff
) TTO ON ETO.intTypeTimeOffId = TTO.intTypeTimeOffId
LEFT JOIN(
	SELECT intEntityId 
		,intRank
	FROM tblPREmployee
) EMP ON ETO.intEntityEmployeeId = EMP.intEntityId
LEFT JOIN(
	SELECT intEntityEmployeeId
		,intTypeTimeOffId
		,intYear
		,dblHoursUsedYTD = dblHoursUsed 
	FROM vyuPREmployeeTimeOffUsedYTD
) TOYTD ON ETO.intEntityEmployeeId = TOYTD.intEntityEmployeeId AND ETO.intTypeTimeOffId = TOYTD.intTypeTimeOffId AND TOYTD.intYear = YEAR(GETDATE())