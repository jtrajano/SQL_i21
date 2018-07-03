CREATE VIEW [dbo].[vyuPRReportQuarterlySUI]
AS
SELECT 
	intEntityId = tblPRPaycheck.intEntityEmployeeId
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
	,dblTaxable = CASE WHEN (dblLimit - ISNULL(MAX(dblAdjustedGrossYTD), dblLimit) < 0) THEN 0
						ELSE
						CASE WHEN ((dblLimit - ISNULL(MAX(dblAdjustedGrossYTD), dblLimit)) > SUM(tblPRPaycheck.dblAdjustedGross))
							THEN 
								SUM(tblPRPaycheck.dblAdjustedGross)
							ELSE 
								dblLimit - (dblLimit - SUM(tblPRPaycheck.dblAdjustedGross))
							END
						END
	,dblRate = vyuPRPaycheckTax.dblAmount
	,dblLimit = vyuPRPaycheckTax.dblLimit
	,dblTotal = SUM(vyuPRPaycheckTax.dblTotal)
	,vyuPRPaycheckTax.strTaxId
	,dblTotalHours = MAX(tblPRPaycheck.dblTotalHoursYTD)
	,intPaychecks = COUNT(tblPRPaycheck.intPaycheckId)
FROM
	(tblPREmployee 
		INNER JOIN 
		(SELECT
			intEntityEmployeeId = PE.intEntityEmployeeId,
			intPaycheckId = PE.intPaycheckId,
			intYear = PE.intYear,
			intQuarter = PE.intQuarter,
			dblGross = PE.dblGross,
			dblPretax = ISNULL(PD.dblPretax, 0),
			dblAdjustedGross = ISNULL(PE.dblGross, 0) - ISNULL(PD.dblPretax, 0),
			dblGrossYTD = PE.dblGrossYTD,
			dblPretaxYTD = PD.dblPretaxYTD,
			dblAdjustedGrossYTD = ISNULL(PE.dblGrossYTD, 0) - ISNULL(PD.dblPretaxYTD, 0),
			dblTotalHoursYTD = PE.dblTotalHoursYTD
		FROM 
			(SELECT intPaycheckId, intEntityEmployeeId, intYear = YEAR(dtmPayDate), intQuarter = DATEPART(QQ, dtmPayDate), 
					dblGross = SUM(dblTotal), dblTotalHours = SUM(dblHours), 
					dblGrossYTD = SUM(dblTotalYTD), dblTotalHoursYTD = SUM(dblHoursYTD)
			FROM vyuPRPaycheckEarning WHERE ysnSUITaxable = 1 
			GROUP BY intPaycheckId, intEntityEmployeeId, YEAR(dtmPayDate), DATEPART(QQ, dtmPayDate)) PE
			LEFT JOIN
			(SELECT intPaycheckId, intYear = YEAR(dtmPayDate), intQuarter = DATEPART(QQ, dtmPayDate), dblPretax = SUM(dblTotal), dblPretaxYTD = SUM(dblTotalYTD)
			FROM vyuPRPaycheckDeduction WHERE ysnSUITaxable = 1
			GROUP BY intPaycheckId, YEAR(dtmPayDate), DATEPART(QQ, dtmPayDate)) PD
			ON PE.intPaycheckId = PD.intPaycheckId) tblPRPaycheck
		ON tblPREmployee.[intEntityId] = tblPRPaycheck.intEntityEmployeeId)
	INNER JOIN vyuPRPaycheckTax ON tblPRPaycheck.intPaycheckId = vyuPRPaycheckTax.intPaycheckId
								AND tblPRPaycheck.intYear = YEAR(vyuPRPaycheckTax.dtmPayDate)
								AND tblPRPaycheck.intQuarter = DATEPART(QQ, vyuPRPaycheckTax.dtmPayDate)
WHERE (vyuPRPaycheckTax.strCalculationType = 'USA SUTA' AND vyuPRPaycheckTax.ysnVoid = 0)
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
	,tblPRPaycheck.intEntityEmployeeId
HAVING SUM(vyuPRPaycheckTax.dblAdjustedGross) > 0

GO