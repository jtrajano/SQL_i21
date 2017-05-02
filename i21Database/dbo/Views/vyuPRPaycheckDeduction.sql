CREATE VIEW [dbo].[vyuPRPaycheckDeduction]
AS
SELECT 
	tblPRPaycheckDeduction.intPaycheckDeductionId
	,tblPRPaycheck.intPaycheckId
	,tblPRPaycheck.intEntityEmployeeId
	,tblPRPaycheck.dtmPayDate
	,strDeduction = (SELECT TOP 1 strDeduction FROM tblPRTypeDeduction WHERE intTypeDeductionId = tblPRPaycheckDeduction.intTypeDeductionId)
	,strDescription = (SELECT TOP 1 strDescription FROM tblPRTypeDeduction WHERE intTypeDeductionId = tblPRPaycheckDeduction.intTypeDeductionId)
	,tblPRPaycheckDeduction.intEmployeeDeductionId
	,tblPRPaycheckDeduction.intTypeDeductionId
	,tblPRPaycheckDeduction.strDeductFrom
	,tblPRPaycheckDeduction.strCalculationType
	,tblPRPaycheckDeduction.dblAmount
	,tblPRPaycheckDeduction.dblLimit
	,tblPRPaycheckDeduction.dblTotal
	,dblTotalYTD = (SELECT
						SUM (dblTotal) 
				    FROM
						(SELECT PC2.intPaycheckId, 
								PC2.intEntityEmployeeId, 
								PC2.dtmPayDate, 
								PCD2.intTypeDeductionId, 
								dblTotal = CASE WHEN (PC2.ysnVoid = 1) THEN 0 ELSE PCD2.dblTotal END
						   FROM tblPRPaycheckDeduction PCD2 
						   RIGHT JOIN tblPRPaycheck PC2 
								ON PC2.intPaycheckId = PCD2.intPaycheckId
										AND PC2.ysnPosted = 1
						 ) PCX2
				    WHERE 
						YEAR(PCX2.dtmPayDate) = YEAR(tblPRPaycheck.dtmPayDate)
						AND PCX2.dtmPayDate <= tblPRPaycheck.dtmPayDate 
						AND PCX2.intEntityEmployeeId = tblPRPaycheck.intEntityEmployeeId
						AND PCX2.intTypeDeductionId = tblPRPaycheckDeduction.intTypeDeductionId)
	,tblPRPaycheckDeduction.dtmBeginDate
	,tblPRPaycheckDeduction.dtmEndDate
	,ysnSSTaxable = CAST(ISNULL((SELECT TOP 1 1 FROM tblPRPaycheckDeductionTax 
								WHERE intPaycheckDeductionId = tblPRPaycheckDeduction.intPaycheckDeductionId 
								AND intTypeTaxId IN (SELECT intTypeTaxId FROM tblPRPaycheckTax 
													 WHERE intPaycheckId = tblPRPaycheck.intPaycheckId AND dblTotal > 0
													 AND strCalculationType = 'USA Social Security')), 0) AS BIT)
	,ysnMedTaxable = CAST(ISNULL((SELECT TOP 1 1 FROM tblPRPaycheckDeductionTax 
								WHERE intPaycheckDeductionId = tblPRPaycheckDeduction.intPaycheckDeductionId 
								AND intTypeTaxId IN (SELECT intTypeTaxId FROM tblPRPaycheckTax 
													 WHERE intPaycheckId = tblPRPaycheck.intPaycheckId AND dblTotal > 0
													 AND strCalculationType = 'USA Medicare')), 0) AS BIT)
	,ysnFITTaxable = CAST(ISNULL((SELECT TOP 1 1 FROM tblPRPaycheckDeductionTax 
								WHERE intPaycheckDeductionId = tblPRPaycheckDeduction.intPaycheckDeductionId 
								AND intTypeTaxId IN (SELECT intTypeTaxId FROM tblPRPaycheckTax 
													 WHERE intPaycheckId = tblPRPaycheck.intPaycheckId AND dblTotal > 0
													 AND strCalculationType = 'USA Federal Tax')), 0) AS BIT)
	,ysnStateTaxable = CAST(ISNULL((SELECT TOP 1 1 FROM tblPRPaycheckDeductionTax 
								WHERE intPaycheckDeductionId = tblPRPaycheckDeduction.intPaycheckDeductionId 
								AND intTypeTaxId IN (SELECT intTypeTaxId FROM tblPRPaycheckTax 
													 WHERE intPaycheckId = tblPRPaycheck.intPaycheckId AND dblTotal > 0
													 AND strCalculationType = 'USA State')), 0) AS BIT)
	,ysnLocalTaxable = CAST(ISNULL((SELECT TOP 1 1 FROM tblPRPaycheckDeductionTax 
								WHERE intPaycheckDeductionId = tblPRPaycheckDeduction.intPaycheckDeductionId 
								AND intTypeTaxId IN (SELECT intTypeTaxId FROM tblPRPaycheckTax 
													 WHERE intPaycheckId = tblPRPaycheck.intPaycheckId AND dblTotal > 0
													 AND strCalculationType = 'USA Local')), 0) AS BIT)
	,tblPRPaycheckDeduction.intAccountId
	,tblPRPaycheckDeduction.intExpenseAccountId
	,tblPRPaycheckDeduction.strPaidBy
	,tblPRPaycheckDeduction.ysnSet
	,tblPRPaycheckDeduction.intSort
	,tblPRPaycheckDeduction.intConcurrencyId
	,tblPRPaycheck.dblGross
	,tblPRPaycheck.ysnVoid
FROM
	tblPRPaycheckDeduction LEFT JOIN tblPRPaycheck ON tblPRPaycheck.intPaycheckId = tblPRPaycheckDeduction.intPaycheckId
WHERE
	tblPRPaycheck.ysnPosted = 1
GROUP BY
	tblPRPaycheckDeduction.intPaycheckDeductionId,
	tblPRPaycheck.intPaycheckId,
	tblPRPaycheck.intEntityEmployeeId,
	tblPRPaycheck.dtmPayDate,
	tblPRPaycheckDeduction.intEmployeeDeductionId,
	tblPRPaycheckDeduction.intTypeDeductionId,
	tblPRPaycheckDeduction.strDeductFrom,
	tblPRPaycheckDeduction.strCalculationType,
	tblPRPaycheckDeduction.dblAmount,
	tblPRPaycheckDeduction.dblLimit,
	tblPRPaycheckDeduction.dblTotal,
	tblPRPaycheckDeduction.dblLimit,
	tblPRPaycheckDeduction.dtmBeginDate,
	tblPRPaycheckDeduction.dtmEndDate,
	tblPRPaycheckDeduction.intAccountId,
	tblPRPaycheckDeduction.intExpenseAccountId,
	tblPRPaycheckDeduction.strPaidBy,
	tblPRPaycheckDeduction.ysnSet,
	tblPRPaycheckDeduction.intSort,
	tblPRPaycheckDeduction.intConcurrencyId,
	tblPRPaycheck.dblGross,
	tblPRPaycheck.ysnVoid