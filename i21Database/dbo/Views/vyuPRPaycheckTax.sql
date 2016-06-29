CREATE VIEW [dbo].[vyuPRPaycheckTax]
AS
SELECT 
	tblPRPaycheckTax.intPaycheckTaxId
	,tblPRPaycheck.intPaycheckId
	,tblPRPaycheck.intEntityEmployeeId
	,tblPRPaycheck.dtmPayDate
	,strTaxId = (SELECT TOP 1 strTax FROM tblPRTypeTax WHERE intTypeTaxId = tblPRPaycheckTax.intTypeTaxId)
	,strDescription = (SELECT TOP 1 strDescription FROM tblPRTypeTax WHERE intTypeTaxId = tblPRPaycheckTax.intTypeTaxId)
	,tblPRPaycheckTax.intTypeTaxId
	,tblPRPaycheckTax.strCalculationType
	,tblPRPaycheckTax.strFilingStatus
	,tblPRPaycheckTax.intTypeTaxStateId
	,tblPRPaycheckTax.intTypeTaxLocalId
	,tblPRPaycheckTax.dblAmount
	,tblPRPaycheckTax.dblExtraWithholding
	,tblPRPaycheckTax.dblLimit
	,tblPRPaycheckTax.dblTotal
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
						YEAR(PCX2.dtmPayDate) = YEAR(tblPRPaycheck.dtmPayDate)
						AND PCX2.dtmPayDate <= tblPRPaycheck.dtmPayDate 
						AND PCX2.intEntityEmployeeId = tblPRPaycheck.intEntityEmployeeId
						AND PCX2.intTypeTaxId = tblPRPaycheckTax.intTypeTaxId)
	,tblPRPaycheckTax.intAccountId
	,tblPRPaycheckTax.intExpenseAccountId
	,tblPRPaycheckTax.intAllowance
	,tblPRPaycheckTax.strPaidBy
	,tblPRPaycheckTax.strVal1
	,tblPRPaycheckTax.strVal2
	,tblPRPaycheckTax.strVal3
	,tblPRPaycheckTax.strVal4
	,tblPRPaycheckTax.strVal5
	,tblPRPaycheckTax.strVal6
	,tblPRPaycheckTax.ysnSet
	,tblPRPaycheckTax.intSort
	,tblPRPaycheckTax.intConcurrencyId
	,tblPRPaycheck.dblGross
	,dblAdjustedGross = SUM(AdjustedGross.dblTotal)
FROM
	tblPRPaycheckTax LEFT JOIN
	(
		SELECT DISTINCT PE.intPaycheckId, PET.intTypeTaxId, PE.dblTotal 
			FROM tblPRPaycheckEarning PE INNER JOIN tblPRPaycheckEarningTax PET ON PE.intPaycheckEarningId = PET.intPaycheckEarningId
										 INNER JOIN tblPRPaycheckTax PT ON PE.intPaycheckId = PT.intPaycheckId AND PET.intTypeTaxId = PT.intTypeTaxId
		UNION ALL
		SELECT DISTINCT PD.intPaycheckId, PDT.intTypeTaxId, -(PD.dblTotal) 
			FROM tblPRPaycheckDeduction PD INNER JOIN tblPRPaycheckDeductionTax PDT on PD.intPaycheckDeductionId = PDT.intPaycheckDeductionId
										   INNER JOIN tblPRPaycheckTax PT ON PD.intPaycheckId = PT.intPaycheckId AND PDT.intTypeTaxId = PT.intTypeTaxId
	) AdjustedGross
	ON tblPRPaycheckTax.intPaycheckId = AdjustedGross.intPaycheckId 
	   AND tblPRPaycheckTax.intTypeTaxId = AdjustedGross.intTypeTaxId
	LEFT JOIN tblPRPaycheck ON tblPRPaycheck.intPaycheckId = tblPRPaycheckTax.intPaycheckId
WHERE
	ysnPosted = 1 AND ysnVoid = 0
GROUP BY
	tblPRPaycheckTax.intPaycheckTaxId,
	tblPRPaycheck.intPaycheckId,
	tblPRPaycheck.dtmPayDate,
	tblPRPaycheck.intEntityEmployeeId,
	tblPRPaycheckTax.intTypeTaxId,
	tblPRPaycheckTax.strCalculationType,
	tblPRPaycheckTax.strFilingStatus,
	tblPRPaycheckTax.intTypeTaxStateId,
	tblPRPaycheckTax.intTypeTaxLocalId,
	tblPRPaycheckTax.dblAmount,
	tblPRPaycheckTax.dblExtraWithholding,
	tblPRPaycheckTax.dblLimit,
	tblPRPaycheckTax.dblTotal,
	tblPRPaycheckTax.intAccountId,
	tblPRPaycheckTax.intExpenseAccountId,
	tblPRPaycheckTax.intAllowance,
	tblPRPaycheckTax.strPaidBy,
	tblPRPaycheckTax.strVal1,
	tblPRPaycheckTax.strVal2,
	tblPRPaycheckTax.strVal3,
	tblPRPaycheckTax.strVal4,
	tblPRPaycheckTax.strVal5,
	tblPRPaycheckTax.strVal6,
	tblPRPaycheckTax.ysnSet,
	tblPRPaycheckTax.intSort,
	tblPRPaycheck.dblGross,
	tblPRPaycheckTax.intConcurrencyId