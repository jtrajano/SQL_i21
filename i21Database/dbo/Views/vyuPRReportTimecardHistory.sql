CREATE VIEW [dbo].[vyuPRReportTimecardHistory]
AS
SELECT
	TC.intTimecardId
	,TC.dtmDate
	,EM.strEntityNo
	,EM.strName
	,TE.strEarning
	,DP.strDepartment
	,TC.dtmDateIn
	,TC.dtmTimeIn
	,TC.dtmDateOut
	,TC.dtmTimeOut
	,TC.dblHours
	,TC.dblRegularHours
	,TC.dblOvertimeHours
	,dblRegularRate = EE.dblRateAmount
	,dblOvertimeRate = OT.dblRateAmount
	,dblRegularTotal = CAST((ISNULL(EE.dblRateAmount, 0) * dblRegularHours) AS NUMERIC (18, 6))
	,dblOvertimeTotal = CAST((ISNULL(OT.dblRateAmount, 0) * dblOvertimeHours) AS NUMERIC (18, 6))
	,dblTotal = CAST((ISNULL(EE.dblRateAmount, 0) * dblRegularHours) + (ISNULL(OT.dblRateAmount, 0) * dblOvertimeHours) AS NUMERIC (18, 6))
FROM 
	tblPRTimecard TC
	LEFT JOIN tblEMEntity EM 
		ON EM.intEntityId = TC.intEntityEmployeeId
	LEFT JOIN tblPREmployeeEarning EE 
		ON EE.intEmployeeEarningId = TC.intEmployeeEarningId
	LEFT JOIN tblPREmployeeEarning OT
		ON OT.intEmployeeEarningLinkId = EE.intTypeEarningId
		AND OT.intEntityEmployeeId = EM.intEntityId
		AND OT.strCalculationType = 'Overtime'
	LEFT JOIN tblPRTypeEarning TE 
		ON EE.intTypeEarningId = TE.intTypeEarningId
	LEFT JOIN tblPRDepartment DP 
		ON DP.intDepartmentId = TC.intEmployeeDepartmentId
WHERE 
	intPaycheckId IS NOT NULL