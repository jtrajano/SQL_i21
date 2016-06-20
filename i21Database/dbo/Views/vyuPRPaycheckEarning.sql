CREATE VIEW [dbo].[vyuPRPaycheckEarning]
AS
SELECT 
	tblPRPaycheckEarning.intPaycheckEarningId
	,tblPRPaycheck.intPaycheckId
	,tblPRPaycheck.intEntityEmployeeId
	,tblPRPaycheck.dtmPayDate
	,tblPRPaycheckEarning.intEmployeeEarningId
	,tblPRTypeEarning.strEarning
	,tblPRPaycheckEarning.intTypeEarningId
	,tblPRPaycheckEarning.strCalculationType
	,tblPRPaycheckEarning.intEmployeeDepartmentId
	,tblPRDepartment.strDepartment
	,tblPRPaycheckEarning.dblHours
	,tblPRPaycheckEarning.dblAmount
	,tblPRPaycheckEarning.dblTotal
	,dblTotalYTD = (SELECT
						SUM (dblTotal) 
				    FROM
						(SELECT PC2.intPaycheckId, 
								PC2.intEntityEmployeeId, 
								PC2.dtmPayDate, 
								PCD2.intTypeEarningId, 
								PCD2.dblTotal 
						   FROM tblPRPaycheckEarning PCD2 
						   RIGHT JOIN tblPRPaycheck PC2 
								ON PC2.intPaycheckId = PCD2.intPaycheckId
										AND PC2.ysnPosted = 1 AND PC2.ysnVoid = 0
						 ) PCX2
				    WHERE 
						YEAR(PCX2.dtmPayDate) = YEAR(tblPRPaycheck.dtmPayDate)
						AND PCX2.dtmPayDate <= tblPRPaycheck.dtmPayDate 
						AND PCX2.intEntityEmployeeId = tblPRPaycheck.intEntityEmployeeId
						AND PCX2.intTypeEarningId = tblPRPaycheckEarning.intTypeEarningId)
	,ysnSSTaxable = CAST(ISNULL((SELECT TOP 1 1 FROM tblPRPaycheckEarningTax 
								WHERE intPaycheckEarningId = tblPRPaycheckEarning.intPaycheckEarningId 
								AND intTypeTaxId IN (SELECT intTypeTaxId FROM tblPRTypeTax WHERE strCalculationType = 'USA Social Security')), 0) AS BIT)
	,ysnMedTaxable = CAST(ISNULL((SELECT TOP 1 1 FROM tblPRPaycheckEarningTax 
								WHERE intPaycheckEarningId = tblPRPaycheckEarning.intPaycheckEarningId 
								AND intTypeTaxId IN (SELECT intTypeTaxId FROM tblPRTypeTax WHERE strCalculationType = 'USA Medicare')), 0) AS BIT)
	,ysnFITTaxable = CAST(ISNULL((SELECT TOP 1 1 FROM tblPRPaycheckEarningTax 
								WHERE intPaycheckEarningId = tblPRPaycheckEarning.intPaycheckEarningId 
								AND intTypeTaxId IN (SELECT intTypeTaxId FROM tblPRTypeTax WHERE strCalculationType = 'USA Federal Tax')), 0) AS BIT)
	,ysnStateTaxable = CAST(ISNULL((SELECT TOP 1 1 FROM tblPRPaycheckEarningTax 
								WHERE intPaycheckEarningId = tblPRPaycheckEarning.intPaycheckEarningId 
								AND intTypeTaxId IN (SELECT intTypeTaxId FROM tblPRTypeTax WHERE strCalculationType = 'USA State')), 0) AS BIT)
	,ysnLocalTaxable = CAST(ISNULL((SELECT TOP 1 1 FROM tblPRPaycheckEarningTax 
								WHERE intPaycheckEarningId = tblPRPaycheckEarning.intPaycheckEarningId 
								AND intTypeTaxId IN (SELECT intTypeTaxId FROM tblPRTypeTax WHERE strCalculationType = 'USA Local')), 0) AS BIT)
	,tblPRPaycheckEarning.intAccountId
	,tblPRPaycheckEarning.intSort
	,tblPRPaycheckEarning.intConcurrencyId
	,tblPRPaycheck.dblGross
FROM
	tblPRPaycheckEarning
	INNER JOIN tblPRPaycheck  ON tblPRPaycheck.intPaycheckId = tblPRPaycheckEarning.intPaycheckId
	INNER JOIN tblPRTypeEarning ON tblPRPaycheckEarning.intTypeEarningId = tblPRTypeEarning.intTypeEarningId
	LEFT JOIN tblPRDepartment ON tblPRPaycheckEarning.intEmployeeDepartmentId = tblPRDepartment.intDepartmentId
WHERE
	tblPRPaycheck.ysnPosted = 1 AND tblPRPaycheck.ysnVoid = 0