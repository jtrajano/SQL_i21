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
								PCD2.dblTotal 
						   FROM tblPRPaycheckDeduction PCD2 
						   RIGHT JOIN tblPRPaycheck PC2 
								ON PC2.intPaycheckId = PCD2.intPaycheckId
										AND PC2.ysnPosted = 1 AND PC2.ysnVoid = 0
						 ) PCX2
				    WHERE 
						YEAR(PCX2.dtmPayDate) = YEAR(tblPRPaycheck.dtmPayDate)
						AND PCX2.dtmPayDate <= tblPRPaycheck.dtmPayDate 
						AND PCX2.intEntityEmployeeId = tblPRPaycheck.intEntityEmployeeId
						AND PCX2.intTypeDeductionId = tblPRPaycheckDeduction.intTypeDeductionId)
	,tblPRPaycheckDeduction.dtmBeginDate
	,tblPRPaycheckDeduction.dtmEndDate
	,tblPRPaycheckDeduction.intAccountId
	,tblPRPaycheckDeduction.intExpenseAccountId
	,tblPRPaycheckDeduction.strPaidBy
	,tblPRPaycheckDeduction.ysnSet
	,tblPRPaycheckDeduction.intSort
	,tblPRPaycheckDeduction.intConcurrencyId
	,tblPRPaycheck.dblGross
FROM
	tblPRPaycheckDeduction LEFT JOIN tblPRPaycheck ON tblPRPaycheck.intPaycheckId = tblPRPaycheckDeduction.intPaycheckId
WHERE
	tblPRPaycheck.ysnPosted = 1 AND tblPRPaycheck.ysnVoid = 0
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
	tblPRPaycheck.dblGross