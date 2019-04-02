CREATE VIEW [dbo].[vyuPRReportQuarterlySUI]
AS
SELECT DISTINCT intEntityId = tblPRPaycheck.intEntityEmployeeId
	,tblPREmployee.strEmployeeId
	,tblPREmployee.strSocialSecurity
	,tblPREmployee.strFirstName
	,tblPREmployee.strMiddleName
	,strMiddleInitial = CASE WHEN (LEN(LTRIM(tblPREmployee.strMiddleName)) > 0) THEN UPPER(SUBSTRING(tblPREmployee.strMiddleName, 1, 1)) ELSE '' END
	,tblPREmployee.strLastName
	,tblPRPaycheck.intYear
	,tblPRPaycheck.intQuarter
	,dblGross = SUM(tblPRPaycheck.dblGross)
	,dblPretax = SUM(tblPRPaycheck.dblPretax)
	,dblAdjustedGross = SUM(tblPRPaycheck.dblAdjustedGross)
	,dblGrossYTD = MAX(tblPRPaycheck.dblGrossYTD)
	,dblAdjustedGrossYTD = MAX(dblAdjustedGrossYTD)

	,dblTaxable = SUM(vyuPRPaycheckTax.dblTaxableAmount) OVER (PARTITION BY tblPRPaycheck.intEntityEmployeeId, tblPRPaycheck.intYear, tblPRPaycheck.intQuarter)
	,dblRate = SUM(vyuPRPaycheckTax.dblAmount) OVER (PARTITION BY tblPRPaycheck.intEntityEmployeeId, tblPRPaycheck.intYear, tblPRPaycheck.intQuarter)
	,dblLimit = vyuPRPaycheckTax.dblLimit
	,dblTotal = SUM(vyuPRPaycheckTax.dblTotal) OVER (PARTITION BY tblPRPaycheck.intEntityEmployeeId, tblPRPaycheck.intYear, tblPRPaycheck.intQuarter)
	,vyuPRPaycheckTax.strTaxId

	,dblTotalHours = SUM(tblPRPaycheck.dblTotalHours)
	,intPaychecks = COUNT(tblPRPaycheck.intPaycheckId)
FROM tblPREmployee 
INNER JOIN(SELECT
		intEntityEmployeeId = PE.intEntityEmployeeId
		,intPaycheckId = PE.intPaycheckId
		,intYear = PE.intYear
		,intQuarter = PE.intQuarter
		,dblGross = PE.dblGross
		,dblPretax = ISNULL(PD.dblPretax, 0)
		,dblAdjustedGross = ISNULL(PE.dblGross, 0) - ISNULL(PD.dblPretax, 0)
		,dblGrossYTD = PE.dblGrossYTD
		,dblPretaxYTD = PD.dblPretaxYTD
		,dblAdjustedGrossYTD = ISNULL(PE.dblGrossYTD, 0) - ISNULL(PD.dblPretaxYTD, 0)
		,dblTotalHours = PE.dblTotalHours
	FROM (SELECT intPaycheckId
			,intEntityEmployeeId
			,intYear = YEAR(dtmPayDate)
			,intQuarter = DATEPART(QQ, dtmPayDate)
			,dblGross = SUM(dblTotal)
			,dblTotalHours = SUM(dblHours)
			,dblGrossYTD = SUM(dblTotalYTD)
	FROM vyuPRPaycheckEarning WHERE ysnSUITaxable = 1 
	GROUP BY intPaycheckId
		,intEntityEmployeeId
		,YEAR(dtmPayDate)
		,DATEPART(QQ, dtmPayDate)
	)PE
	LEFT JOIN(SELECT intPaycheckId
			,intYear = YEAR(dtmPayDate)
			,intQuarter = DATEPART(QQ, dtmPayDate)
			,dblPretax = SUM(dblTotal)
			,dblPretaxYTD = SUM(dblTotalYTD)
		FROM vyuPRPaycheckDeduction 
		WHERE ysnSUITaxable = 1 
			AND strPaidBy = 'Employee'
		GROUP BY intPaycheckId
			,YEAR(dtmPayDate)
			,DATEPART(QQ, dtmPayDate)
	) PD ON PE.intPaycheckId = PD.intPaycheckId

	INNER JOIN(SELECT intPaycheckId
			,intEntityEmployeeId
			,intYear = YEAR(dtmPayDate)
			,intQuarter = DATEPART(QQ, dtmPayDate)
			,dblAmount = SUM(dblAmount)
			,dblTaxableAmount = SUM(dblTaxableAmount)
			,dblTotal = SUM(dblTotal)
			,dblLimit
			,strTaxId
		FROM vyuPRPaycheckTax 
		WHERE strCalculationType = 'USA SUTA' 
			AND vyuPRPaycheckTax.ysnVoid = 0
		GROUP BY intPaycheckId
			,intEntityEmployeeId
			,YEAR(dtmPayDate)
			,DATEPART(QQ, dtmPayDate)
			,strTaxId
			,dblLimit
	)PT ON PE.intPaycheckId = PT.intPaycheckId
		AND PE.intEntityEmployeeId = PT.intEntityEmployeeId
		AND PE.intYear = PT.intYear 
		AND PE.intQuarter = PT.intQuarter
) tblPRPaycheck ON tblPREmployee.[intEntityId] = tblPRPaycheck.intEntityEmployeeId

INNER JOIN(
	SELECT DISTINCT intEntityEmployeeId
		,dblAmount = SUM(dblAmount)
		,dblLimit = dblLimit
		,dblTaxableAmount = SUM(dblTaxableAmount)
		,dblTotal = SUM(dblTotal)
		,intYear = YEAR(dtmPayDate)
		,intQuarter = DATEPART(QQ,dtmPayDate)
		,strTaxId
	FROM vyuPRPaycheckTax
	WHERE strCalculationType = 'USA SUTA' 
		AND ysnVoid = 0
	GROUP BY intEntityEmployeeId
		,YEAR(dtmPayDate)
		,DATEPART(QQ,dtmPayDate)
		,dblAmount
		,dblTaxableAmount
		,dblLimit
		,dblTotal
		,strTaxId 
)vyuPRPaycheckTax ON tblPRPaycheck.intEntityEmployeeId = vyuPRPaycheckTax.intEntityEmployeeId
	AND tblPRPaycheck.intYear = vyuPRPaycheckTax.intYear
	AND tblPRPaycheck.intQuarter = vyuPRPaycheckTax.intQuarter
GROUP BY 
	tblPREmployee.strEmployeeId
	,tblPREmployee.strSocialSecurity
	,tblPREmployee.strFirstName
	,tblPREmployee.strMiddleName
	,tblPREmployee.strLastName
	,tblPRPaycheck.intYear
	,tblPRPaycheck.intQuarter
	,vyuPRPaycheckTax.dblAmount
	,vyuPRPaycheckTax.dblLimit
	,vyuPRPaycheckTax.strTaxId
	,vyuPRPaycheckTax.dblTaxableAmount
	,vyuPRPaycheckTax.dblTotal
	,tblPRPaycheck.intEntityEmployeeId

GO