CREATE VIEW [dbo].[vyuPRReportQuarterlySUI]
AS
SELECT 
	tblPREmployee.strEmployeeId
	,tblPREmployee.strSocialSecurity
	,tblPREmployee.strFirstName
	,tblPREmployee.strMiddleName
	,tblPREmployee.strLastName
	,tblPRPaycheck.intYear
	,tblPRPaycheck.intQuarter
	,SUM(tblPRPaycheck.dblAdjustedGross) AS dblGross
	,MAX(tblPRPaycheck.dblAdjustedGrossYTD) AS dblGrossYTD
	,dblTaxable = CASE WHEN (dblLimit - (dblLimit - ISNULL((SELECT MAX (dblAdjustedGrossYTD) FROM vyuPRPaycheckYTD 
												   WHERE YEAR(vyuPRPaycheckYTD.dtmPayDate) = tblPRPaycheck.intYear
												   AND DATEPART(QQ, vyuPRPaycheckYTD.dtmPayDate) = tblPRPaycheck.intQuarter
												   AND vyuPRPaycheckYTD.intEntityEmployeeId = tblPRPaycheck.intEntityEmployeeId), 0)) > dblLimit) THEN 
									CASE WHEN (dblLimit - (dblLimit - ISNULL((SELECT MAX (dblAdjustedGrossYTD) FROM vyuPRPaycheckYTD 
												   WHERE YEAR(vyuPRPaycheckYTD.dtmPayDate) = tblPRPaycheck.intYear
												   AND DATEPART(QQ, vyuPRPaycheckYTD.dtmPayDate) = tblPRPaycheck.intQuarter - 1
												   AND vyuPRPaycheckYTD.intEntityEmployeeId = tblPRPaycheck.intEntityEmployeeId), dblLimit)) > 0) 
											THEN 
												CASE WHEN (dblLimit - ISNULL((SELECT MAX (dblAdjustedGrossYTD) FROM vyuPRPaycheckYTD 
														   WHERE YEAR(vyuPRPaycheckYTD.dtmPayDate) = tblPRPaycheck.intYear
														   AND DATEPART(QQ, vyuPRPaycheckYTD.dtmPayDate) = tblPRPaycheck.intQuarter - 1
														   AND vyuPRPaycheckYTD.intEntityEmployeeId = tblPRPaycheck.intEntityEmployeeId), 0)) > 0 
													THEN 
														   (dblLimit - ISNULL((SELECT MAX (dblAdjustedGrossYTD) FROM vyuPRPaycheckYTD 
														   WHERE YEAR(vyuPRPaycheckYTD.dtmPayDate) = tblPRPaycheck.intYear
														   AND DATEPART(QQ, vyuPRPaycheckYTD.dtmPayDate) = tblPRPaycheck.intQuarter - 1
														   AND vyuPRPaycheckYTD.intEntityEmployeeId = tblPRPaycheck.intEntityEmployeeId), 0))
													ELSE 0
												END
											ELSE 0 
									END
						ELSE
							  (dblLimit - (dblLimit - SUM (tblPRPaycheck.dblAdjustedGross)))
					END
	,vyuPRPaycheckTax.dblLimit AS dblLimit
	,SUM(vyuPRPaycheckTax.dblTotal) AS dblTotal
	,vyuPRPaycheckTax.intTypeTaxId
	,vyuPRPaycheckTax.intTypeTaxStateId
	,MAX(tblPRPaycheck.dblTotalHoursYTD) dblTotalHours
	,COUNT(tblPRPaycheck.intPaycheckId) AS intPaychecks
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
      ON tblPREmployee.intEntityEmployeeId = tblPRPaycheck.intEntityEmployeeId)
	INNER JOIN vyuPRPaycheckTax ON tblPRPaycheck.intPaycheckId = vyuPRPaycheckTax.intPaycheckId
								AND tblPRPaycheck.intYear = YEAR(vyuPRPaycheckTax.dtmPayDate)
								AND tblPRPaycheck.intQuarter = DATEPART(QQ, vyuPRPaycheckTax.dtmPayDate)
WHERE (vyuPRPaycheckTax.strCalculationType = 'USA SUTA')
GROUP BY 
	tblPREmployee.strEmployeeId
	, tblPREmployee.strSocialSecurity
	, tblPREmployee.strFirstName
	, tblPREmployee.strMiddleName
	, tblPREmployee.strLastName
	, tblPRPaycheck.intYear
	, tblPRPaycheck.intQuarter
	, vyuPRPaycheckTax.dblLimit
	, vyuPRPaycheckTax.intTypeTaxId
	, vyuPRPaycheckTax.intTypeTaxStateId
	, tblPRPaycheck.intEntityEmployeeId
HAVING SUM(vyuPRPaycheckTax.dblAdjustedGross) > 0