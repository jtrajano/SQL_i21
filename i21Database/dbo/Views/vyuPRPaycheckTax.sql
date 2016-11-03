CREATE VIEW [dbo].[vyuPRPaycheckTax]
AS
SELECT 
	PT.intPaycheckTaxId
	,PT.intPaycheckId
	,PC.intEntityEmployeeId
	,PC.dtmPayDate
	,PT.intTypeTaxId
	,strTaxId = (SELECT TOP 1 strTax FROM tblPRTypeTax WHERE intTypeTaxId = PT.intTypeTaxId)
	,strDescription = (SELECT TOP 1 strDescription FROM tblPRTypeTax WHERE intTypeTaxId = PT.intTypeTaxId)
	,PT.strCalculationType
	,PT.strPaidBy
	,PT.strFilingStatus
	,PT.intTypeTaxStateId
	,PT.intTypeTaxLocalId
	,PT.dblAmount
	,PT.dblExtraWithholding
	,PT.dblLimit
	,PT.dblTotal
	,dblTotalYTD = (SELECT
						SUM (dblTotal) 
					FROM
						(SELECT PC2.intPaycheckId, 
								PC2.intEntityEmployeeId, 
								PC2.dtmPayDate, 
								PCT2.intTypeTaxId, 
								PCT2.dblTotal 
							FROM tblPRPaycheckTax PCT2 
							RIGHT JOIN tblPRPaycheck PC2 
								ON PC2.intPaycheckId = PCT2.intPaycheckId
										AND PC2.ysnPosted = 1 AND PC2.ysnVoid = 0
							) PCX2
					WHERE 
						YEAR(PCX2.dtmPayDate) = YEAR(PC.dtmPayDate)
						AND PCX2.dtmPayDate <= PC.dtmPayDate 
						AND PCX2.intEntityEmployeeId = PC.intEntityEmployeeId
						AND PCX2.intTypeTaxId = PT.intTypeTaxId)
	,dblAdditionalMed = CASE WHEN (strCalculationType = 'USA Medicare' AND strPaidBy = 'Employee')
							 THEN 
							CASE WHEN (strFilingStatus = 'Married' AND dblAdjustedGross > 125000) THEN ROUND(((dblAdjustedGross - 125000) * 0.009), 2)
								 WHEN (strFilingStatus <> 'Married' AND dblAdjustedGross > 200000) THEN ROUND(((dblAdjustedGross - 200000) * 0.009), 2)
								 ELSE 0 END
						ELSE 0 END
	,PC.dblGross
	,PC.dblAdjustedGross
FROM
	tblPRPaycheckTax PT
	LEFT JOIN tblPRPaycheck PC ON PC.intPaycheckId = PT.intPaycheckId
WHERE
	ysnPosted = 1 AND ysnVoid = 0