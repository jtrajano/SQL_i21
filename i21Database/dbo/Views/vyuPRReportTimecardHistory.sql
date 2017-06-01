CREATE VIEW [dbo].[vyuPRReportTimecardHistory]
AS
SELECT
	TC.intTimecardId
	,TC.intEntityEmployeeId
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
	,TC.ysnApproved
	,strApprovedUserId = USA.strUserName
	,TC.dtmApproved
	,ysnProcessed = CASE WHEN (TC.intPaycheckId IS NOT NULL OR TC.intPayGroupDetailId IS NOT NULL) THEN 1 ELSE 0 END
	,strProcessedUserId = USP.strUserName
	,TC.dtmProcessed
	,dblRegularRate = CASE WHEN (TC.intPaycheckId IS NOT NULL) THEN ISNULL(PE.dblAmount, EE.dblRateAmount)
						   WHEN (TC.intPayGroupDetailId IS NOT NULL) THEN ISNULL(PGD.dblAmount, EE.dblRateAmount)
						   ELSE ISNULL(EE.dblRateAmount, 0) END
	,dblOvertimeRate = CASE WHEN (TC.intPaycheckId IS NOT NULL) THEN ISNULL(PEOT.dblAmount, EEOT.dblRateAmount)
						   WHEN (TC.intPayGroupDetailId IS NOT NULL) THEN ISNULL(PGDOT.dblAmount, EEOT.dblRateAmount)
						   ELSE ISNULL(EEOT.dblRateAmount, 0) END
	,dblRegularTotal = CAST((ISNULL(
						 CASE WHEN (TC.intPaycheckId IS NOT NULL) THEN ISNULL(PE.dblAmount, EE.dblRateAmount)
						   WHEN (TC.intPayGroupDetailId IS NOT NULL) THEN ISNULL(PGD.dblAmount, EE.dblRateAmount)
						   ELSE ISNULL(EE.dblRateAmount, 0) END, 0)
							* dblRegularHours) AS NUMERIC (18, 6))
	,dblOvertimeTotal = CAST((ISNULL(
						  CASE WHEN (TC.intPaycheckId IS NOT NULL) THEN ISNULL(PEOT.dblAmount, EEOT.dblRateAmount)
						   WHEN (TC.intPayGroupDetailId IS NOT NULL) THEN ISNULL(PGDOT.dblAmount, EEOT.dblRateAmount)
						   ELSE ISNULL(EEOT.dblRateAmount, 0) END, 0) 
						   * dblOvertimeHours) AS NUMERIC (18, 6))
	,dblTotal =	CAST(
					(ISNULL(
						 CASE WHEN (TC.intPaycheckId IS NOT NULL) THEN ISNULL(PE.dblAmount, EE.dblRateAmount)
						   WHEN (TC.intPayGroupDetailId IS NOT NULL) THEN ISNULL(PGD.dblAmount, EE.dblRateAmount)
						   ELSE ISNULL(EE.dblRateAmount, 0) END, 0)
							* dblRegularHours)
				  + (ISNULL(
						  CASE WHEN (TC.intPaycheckId IS NOT NULL) THEN ISNULL(PEOT.dblAmount, EEOT.dblRateAmount)
						   WHEN (TC.intPayGroupDetailId IS NOT NULL) THEN ISNULL(PGDOT.dblAmount, EEOT.dblRateAmount)
						   ELSE ISNULL(EEOT.dblRateAmount, 0) END, 0) 
						   * dblOvertimeHours)
				AS NUMERIC (18, 6))
	,PC.strPaycheckId
	,TC.intConcurrencyId
FROM 
	tblPRTimecard TC
	LEFT JOIN tblEMEntity EM 
		ON EM.intEntityId = TC.intEntityEmployeeId
	LEFT JOIN tblSMUserSecurity USA
		ON USA.[intEntityId] = TC.intApprovedUserId
	LEFT JOIN tblSMUserSecurity USP
		ON USP.[intEntityId] = TC.intProcessedUserId
	LEFT JOIN tblPRPaycheck PC
		ON TC.intPaycheckId = PC.intPaycheckId
	LEFT JOIN tblPRPayGroupDetail PGD
		ON TC.intPayGroupDetailId = PGD.intPayGroupDetailId
	LEFT JOIN tblPRPaycheckEarning PE 
		ON PE.intEmployeeEarningId = TC.intEmployeeEarningId
		AND PE.intPaycheckId = TC.intPaycheckId
		AND PE.intEmployeeDepartmentId = TC.intEmployeeDepartmentId
	LEFT JOIN tblPREmployeeEarning EE
		ON EE.intEmployeeEarningId = TC.intEmployeeEarningId
		AND EE.intEntityEmployeeId = EM.intEntityId
	LEFT JOIN tblPREmployeeEarning EEOT
		ON EEOT.intEmployeeEarningLinkId = EE.intTypeEarningId
		AND EEOT.intEntityEmployeeId = EM.intEntityId
		AND EEOT.strCalculationType = 'Overtime'
	LEFT JOIN tblPRPayGroupDetail PGDOT
		ON EEOT.intEmployeeEarningId = PGDOT.intEmployeeEarningId
		AND EEOT.intEntityEmployeeId = PGDOT.intEntityEmployeeId
		AND PGDOT.intDepartmentId = TC.intEmployeeDepartmentId
	LEFT JOIN tblPRPaycheckEarning PEOT
		ON PEOT.intEmployeeEarningId = EEOT.intEmployeeEarningId
		AND PEOT.intPaycheckId = TC.intPaycheckId
		AND PEOT.intEmployeeDepartmentId = TC.intEmployeeDepartmentId
	LEFT JOIN tblPRTypeEarning TE 
		ON EE.intTypeEarningId = TE.intTypeEarningId
	LEFT JOIN tblPRDepartment DP 
		ON DP.intDepartmentId = TC.intEmployeeDepartmentId
