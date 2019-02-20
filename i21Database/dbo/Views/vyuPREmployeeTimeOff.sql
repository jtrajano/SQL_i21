CREATE VIEW [dbo].[vyuPREmployeeTimeOff]
AS 
SELECT ETO.intEntityEmployeeId
	,ET.intEntityId
	,ETO.intEmployeeTimeOffId
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
	,ETO.dblHoursUsed
	,ETO.intSort
	,ETO.dblPerPeriod
	,ETO.strPeriod
	,EMP.intRank
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
