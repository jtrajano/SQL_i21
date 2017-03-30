CREATE VIEW [dbo].[vyuPRReportWorkersCompensation]
AS
SELECT
	PC.intEntityEmployeeId,
	EMP.strSocialSecurity,
	strEmployeeId = ENT.strEntityNo,
	strName = ENT.strName,
	PC.dtmPayDate,
	TE.strEarning,
	strDepartment = ISNULL(DEP.strDepartment, '(No Department)'),
	PE.dblHours,
	PE.dblTotal,
	WC.strWCCode,
	WC.strDescription,
	WC.dblRate,
	dblWCTotal = CASE WHEN (WC.strCalculationType = 'Per Hour') THEN 
					CAST((PE.dblHours * WC.dblRate) AS NUMERIC(18, 6))
				 ELSE
					CAST(
						(CASE WHEN (PE.strCalculationType = 'Overtime') THEN 
							(PE.dblTotal / EE.dblAmount)
						 ELSE 
							PE.dblTotal
						 END
						* WC.dblRate)
					AS NUMERIC(18, 6))
				 END
FROM 
	tblPRPaycheckEarning PE
	INNER JOIN tblPREmployeeEarning EE ON EE.intEmployeeEarningId = PE.intEmployeeEarningId
	INNER JOIN tblPRTypeEarning TE ON TE.intTypeEarningId = PE.intTypeEarningId 
	INNER JOIN tblPRPaycheck PC ON PC.intPaycheckId = PE.intPaycheckId
	INNER JOIN tblPREmployee EMP ON PC.intEntityEmployeeId = EMP.[intEntityId]
	INNER JOIN tblEMEntity ENT ON EMP.[intEntityId] = ENT.intEntityId
	INNER JOIN tblPRWorkersCompensation WC ON PE.intWorkersCompensationId = WC.intWorkersCompensationId
	LEFT JOIN tblPRDepartment DEP ON DEP.intDepartmentId = PE.intEmployeeDepartmentId 
WHERE 
	PE.intWorkersCompensationId IS NOT NULL
	AND PC.ysnPosted = 1 AND PC.ysnVoid = 0