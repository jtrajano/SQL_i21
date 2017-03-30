CREATE VIEW [dbo].[vyuPRReportQuarterlyStateTax]
AS
SELECT 
	tblPREmployee.strEmployeeId
	,tblPREmployee.strSocialSecurity
	,tblPREmployee.strFirstName
	,tblPREmployee.strMiddleName
	,tblPREmployee.strLastName
	,tblPRPaycheck.intYear
	,tblPRPaycheck.intQuarter
	,SUM(tblPRPaycheck.dblGross) AS dblGross
	,SUM(tblPRPaycheck.dblAdjustedGross) AS dblAdjustedGross
	,SUM(vyuPRPaycheckTax.dblStateTotal) AS dblStateTotal
	,SUM(vyuPRPaycheckTax.dblLocalTotal) AS dblLocalTotal
	,(SELECT TOP 1 strState FROM tblPRTypeTaxState WHERE intTypeTaxStateId = vyuPRPaycheckTax.intTypeTaxStateId) strState
	,(SELECT TOP 1 strLocalName FROM tblPRTypeTaxLocal WHERE intTypeTaxLocalId = vyuPRPaycheckTax.intTypeTaxLocalId) strCounty
FROM
	(tblPREmployee 
		INNER JOIN (SELECT PC.*
					,PCYTD.dblGrossYTD
					,PCYTD.dblAdjustedGrossYTD
					,PCYTD.dblTotalHoursYTD
					,CAST(YEAR(PC.dtmPayDate)AS INT) intYear
					,DATEPART(QQ, PC.dtmPayDate) intQuarter 
					FROM tblPRPaycheck PC
			INNER JOIN vyuPRPaycheckYTD PCYTD ON PC.intPaycheckId = PCYTD.intPaycheckId) tblPRPaycheck
      ON tblPREmployee.[intEntityId] = tblPRPaycheck.intEntityEmployeeId
	)
	INNER JOIN 
	(SELECT SLT.intPaycheckId, SLT.dtmPayDate, SLT.intTypeTaxStateId, MAX(SLT.intTypeTaxLocalId) intTypeTaxLocalId, SLT.dblAdjustedGross, 
			dblStateTotal = SUM(SLT.dblStateTotal), dblLocalTotal = SUM(SLT.dblLocalTotal) FROM
		(SELECT intPaycheckId, dtmPayDate, intTypeTaxStateId, intTypeTaxLocalId, dblAdjustedGross, dblStateTotal = dblTotal, dblLocalTotal = 0
			FROM vyuPRPaycheckTax WHERE strCalculationType IN ('USA State') AND ysnVoid = 0
		 UNION ALL
		 SELECT intPaycheckId, dtmPayDate, intTypeTaxStateId, intTypeTaxLocalId, dblAdjustedGross, dblStateTotal = 0, dblLocalTotal = dblTotal
			FROM vyuPRPaycheckTax WHERE strCalculationType IN ('USA Local') AND ysnVoid = 0
		) SLT
	 GROUP BY SLT.intPaycheckId, SLT.dtmPayDate, SLT.intTypeTaxStateId, SLT.dblAdjustedGross
	) vyuPRPaycheckTax
	ON tblPRPaycheck.intPaycheckId = vyuPRPaycheckTax.intPaycheckId
								AND tblPRPaycheck.intYear = YEAR(vyuPRPaycheckTax.dtmPayDate)
								AND tblPRPaycheck.intQuarter = DATEPART(QQ, vyuPRPaycheckTax.dtmPayDate)
GROUP BY 
	tblPREmployee.strEmployeeId
	, tblPREmployee.strSocialSecurity
	, tblPREmployee.strFirstName
	, tblPREmployee.strMiddleName
	, tblPREmployee.strLastName
	, tblPRPaycheck.intYear
	, tblPRPaycheck.intQuarter
	, vyuPRPaycheckTax.intTypeTaxStateId
	, vyuPRPaycheckTax.intTypeTaxLocalId
	, tblPRPaycheck.intEntityEmployeeId
HAVING SUM(vyuPRPaycheckTax.dblAdjustedGross) > 0