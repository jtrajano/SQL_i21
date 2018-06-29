CREATE VIEW [dbo].[vyuPRPaycheckTax]
AS
SELECT 
	intPaycheckTaxId
	,intPaycheckId
	,intEntityEmployeeId
	,dtmPayDate
	,intTypeTaxId
	,strTaxId
	,strDescription
	,strCalculationType
	,strFilingStatus
	,intTypeTaxStateId
	,intTypeTaxLocalId
	,dblAmount
	,dblExtraWithholding
	,dblLimit
	,dblTotal
	,dblTotalYTD
	,dblAdditionalMed = CASE WHEN (strCalculationType = 'USA Medicare' AND strPaidBy = 'Employee' AND dblTotal > 0)
					    THEN 
							CASE WHEN (strFilingStatus = 'Married' AND dblTotalYTD > 1812.5 AND ROUND(dblTotal - (dblAdjustedGross * 0.0145), 2) > 0) THEN ROUND(dblTotal - (dblAdjustedGross * 0.0145), 2)
								 WHEN (strFilingStatus <> 'Married' AND dblTotalYTD > 2900 AND ROUND(dblTotal - (dblAdjustedGross * 0.0145), 2) > 0) THEN ROUND(dblTotal - (dblAdjustedGross * 0.0145), 2)
								 ELSE 0 END
					    ELSE 0 END
	,intAccountId
	,intExpenseAccountId
	,intAllowance
	,strPaidBy
	,strVal1
	,strVal2
	,strVal3
	,strVal4
	,strVal5
	,strVal6
	,ysnSet
	,intSort
	,intConcurrencyId
	,dblGross
	,dblAdjustedGross
	,ysnVoid
FROM 
	(SELECT 
		PT.*
		,PC.intEntityEmployeeId
		,PC.dtmPayDate
		,strTaxId = (SELECT TOP 1 strTax FROM tblPRTypeTax WHERE intTypeTaxId = PT.intTypeTaxId)
		,strDescription = (SELECT TOP 1 strDescription FROM tblPRTypeTax WHERE intTypeTaxId = PT.intTypeTaxId)
		,dblTotalYTD = (SELECT
							SUM (dblTotal) 
						FROM
							(SELECT PC2.intPaycheckId, 
									PC2.intEntityEmployeeId, 
									PC2.dtmPayDate, 
									PCT2.intTypeTaxId, 
									dblTotal = CASE WHEN (PC2.ysnVoid = 1) THEN 0 ELSE PCT2.dblTotal END
							   FROM tblPRPaycheckTax PCT2 
							   RIGHT JOIN tblPRPaycheck PC2 
									ON PC2.intPaycheckId = PCT2.intPaycheckId
											AND PC2.ysnPosted = 1
							 ) PCX2
						WHERE 
							YEAR(PCX2.dtmPayDate) = YEAR(PC.dtmPayDate)
							AND PCX2.dtmPayDate <= PC.dtmPayDate 
							AND PCX2.intEntityEmployeeId = PC.intEntityEmployeeId
							AND PCX2.intTypeTaxId = PT.intTypeTaxId)
		,PC.dblGross
		,PC.dblAdjustedGross
		,PC.ysnVoid
	FROM
		tblPRPaycheckTax PT
		LEFT JOIN tblPRPaycheck PC ON PC.intPaycheckId = PT.intPaycheckId
	WHERE
		ysnPosted = 1) PaycheckTax
