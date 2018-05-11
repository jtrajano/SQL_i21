CREATE VIEW [dbo].[vyuPRReportWorkersCompensation]
AS
SELECT 
	strWCCode
	,strDescription
	,dblRate
	,strRateType
	,intEntityEmployeeId
	,strSocialSecurity
	,strEmployeeId
	,strName
	,strDepartment
	,intPaycheckId
	,dtmPayDate
	,dblHours = SUM(dblHours)
	,dblRegularEarnings = SUM(ISNULL([Hourly Rate], 0) + ISNULL([Salary], 0) + ISNULL([Shift Differential], 0))
	,dblOvertime = SUM(ISNULL([Overtime], 0))
	,dblWCTotal = SUM(dblWCTotal)
FROM
	(SELECT
		strWCCode = WC.strWCCode,
		strDescription = WC.strDescription,
		dblRate = WC.dblRate,
		strRateType = WC.strCalculationType,
		intEntityEmployeeId = PE.intEntityEmployeeId,
		strSocialSecurity = EMP.strSocialSecurity,
		strEmployeeId = ENT.strEntityNo,
		strName = ENT.strName,
		intPaycheckId,
		dtmPayDate = PE.dtmPayDate,
		strCalculationType = PE.strCalculationType,
		strDepartment = ISNULL(PE.strDepartment, '(No Department)'),
		dblHours = PE.dblHours,
		dblTotal = PE.dblTotal,
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
		(SELECT * FROM vyuPRPaycheckEarning 
			WHERE intWorkersCompensationId IS NOT NULL AND strCalculationType IN ('Hourly Rate', 'Salary', 'Overtime', 'Shift Differential')) PE
		INNER JOIN tblPREmployeeEarning EE ON EE.intEmployeeEarningId = PE.intEmployeeEarningId
		INNER JOIN tblPREmployee EMP ON PE.intEntityEmployeeId = EMP.intEntityId
		INNER JOIN tblEMEntity ENT ON EMP.intEntityId = ENT.intEntityId
		INNER JOIN tblPRWorkersCompensation WC ON PE.intWorkersCompensationId = WC.intWorkersCompensationId
	) AS MAIN
	PIVOT
	(
		SUM(dblTotal)
		FOR strCalculationType IN ([Hourly Rate], [Salary], [Overtime], [Shift Differential])
	) AS pvtTotal
GROUP BY 
	strWCCode
	,strDescription
	,dblRate
	,strRateType
	,intEntityEmployeeId
	,strSocialSecurity
	,strEmployeeId
	,strName
	,strDepartment
	,intPaycheckId
	,dtmPayDate