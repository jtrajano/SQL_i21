CREATE VIEW [dbo].[vyuPRReportEmployeeEarningsRegister]
AS

SELECT  
	intYear = YR.intYear,
	intEntityId = EMP.intEntityId,
	strDepartment = ISNULL(DEP.strDepartment, '(No Department)'),
	strEmployeeId = EMP.strEmployeeId,
	strName = ENT.strName,

	/* Yearly Totals */
	dblEarningHours_Y = ISNULL(EARN_Y.dblHours, 0),
	dblEarningTotal_Y = ISNULL(EARN_Y.dblTotal, 0),
	dblTaxTotal_Y = ISNULL(COMTAX_Y.dblTotal, 0) + ISNULL(EMPTAX_Y.dblTotal, 0),
	dblCompanyTaxTotal_Y = ISNULL(COMTAX_Y.dblTotal, 0),
	dblEmployeeTaxTotal_Y = ISNULL(EMPTAX_Y.dblTotal, 0),
	dblDeductionTotal_Y = ISNULL(COMDED_Y.dblTotal, 0) + ISNULL(EMPDED_Y.dblTotal, 0),
	dblCompanyDeductionTotal_Y = ISNULL(COMDED_Y.dblTotal, 0),
	dblEmployeeDeductionTotal_Y = ISNULL(EMPDED_Y.dblTotal, 0),
	dblNetPay_Y = ISNULL(PC_Y.dblNetPay, 0),

	/* 1st Quarter Totals */
	dblEarningHours_Q1 = ISNULL(EARN_Q1.dblHours, 0),
	dblEarningTotal_Q1 = ISNULL(EARN_Q1.dblTotal, 0),
	dblTaxTotal_Q1 = ISNULL(COMTAX_Q1.dblTotal, 0) + ISNULL(EMPTAX_Q1.dblTotal, 0),
	dblCompanyTaxTotal_Q1 = ISNULL(COMTAX_Q1.dblTotal, 0),
	dblEmployeeTaxTotal_Q1 = ISNULL(EMPTAX_Q1.dblTotal, 0),
	dblDeductionTotal_Q1 = ISNULL(COMDED_Q1.dblTotal, 0) + ISNULL(EMPDED_Q1.dblTotal, 0),
	dblCompanyDeductionTotal_Q1 = ISNULL(COMDED_Q1.dblTotal, 0),
	dblEmployeeDeductionTotal_Q1 = ISNULL(EMPDED_Q1.dblTotal, 0),
	dblNetPay_Q1 = ISNULL(PC_Q1.dblNetPay, 0),

	/* 2nd Quarter Totals */
	dblEarningHours_Q2 = ISNULL(EARN_Q2.dblHours, 0),
	dblEarningTotal_Q2 = ISNULL(EARN_Q2.dblTotal, 0),
	dblTaxTotal_Q2 = ISNULL(COMTAX_Q2.dblTotal, 0) + ISNULL(EMPTAX_Q2.dblTotal, 0),
	dblCompanyTaxTotal_Q2 = ISNULL(COMTAX_Q2.dblTotal, 0),
	dblEmployeeTaxTotal_Q2 = ISNULL(EMPTAX_Q2.dblTotal, 0),
	dblDeductionTotal_Q2 = ISNULL(COMDED_Q2.dblTotal, 0) + ISNULL(EMPDED_Q2.dblTotal, 0),
	dblCompanyDeductionTotal_Q2 = ISNULL(COMDED_Q2.dblTotal, 0),
	dblEmployeeDeductionTotal_Q2 = ISNULL(EMPDED_Q2.dblTotal, 0),
	dblNetPay_Q2 = ISNULL(PC_Q2.dblNetPay, 0),

	/* 3rd Quarter Totals */
	dblEarningHours_Q3 = ISNULL(EARN_Q3.dblHours, 0),
	dblEarningTotal_Q3 = ISNULL(EARN_Q3.dblTotal, 0),
	dblTaxTotal_Q3 = ISNULL(COMTAX_Q3.dblTotal, 0) + ISNULL(EMPTAX_Q3.dblTotal, 0),
	dblCompanyTaxTotal_Q3 = ISNULL(COMTAX_Q3.dblTotal, 0),
	dblEmployeeTaxTotal_Q3 = ISNULL(EMPTAX_Q3.dblTotal, 0),
	dblDeductionTotal_Q3 = ISNULL(COMDED_Q3.dblTotal, 0) + ISNULL(EMPDED_Q3.dblTotal, 0),
	dblCompanyDeductionTotal_Q3 = ISNULL(COMDED_Q3.dblTotal, 0),
	dblEmployeeDeductionTotal_Q3 = ISNULL(EMPDED_Q3.dblTotal, 0),
	dblNetPay_Q3 = ISNULL(PC_Q3.dblNetPay, 0),

	/* 4th Quarter Totals */
	dblEarningHours_Q4 = ISNULL(EARN_Q4.dblHours, 0),
	dblEarningTotal_Q4 = ISNULL(EARN_Q4.dblTotal, 0),
	dblTaxTotal_Q4 = ISNULL(COMTAX_Q4.dblTotal, 0) + ISNULL(EMPTAX_Q4.dblTotal, 0),
	dblCompanyTaxTotal_Q4 = ISNULL(COMTAX_Q4.dblTotal, 0),
	dblEmployeeTaxTotal_Q4 = ISNULL(EMPTAX_Q4.dblTotal, 0),
	dblDeductionTotal_Q4 = ISNULL(COMDED_Q4.dblTotal, 0) + ISNULL(EMPDED_Q4.dblTotal, 0),
	dblCompanyDeductionTotal_Q4 = ISNULL(COMDED_Q4.dblTotal, 0),
	dblEmployeeDeductionTotal_Q4 = ISNULL(EMPDED_Q4.dblTotal, 0),
	dblNetPay_Q4 = ISNULL(PC_Q4.dblNetPay, 0)

FROM tblPREmployee [EMP] 
	INNER JOIN (SELECT intEntityId, strName FROM tblEMEntity) AS [ENT] 
		ON EMP.intEntityId = ENT.intEntityId
	LEFT JOIN (SELECT ED.intEntityEmployeeId, ED.intDepartmentId, D.strDepartment
				FROM tblPREmployeeDepartment ED INNER JOIN tblPRDepartment D ON ED.intDepartmentId = D.intDepartmentId) AS [DEP] 
		ON EMP.intEntityId = DEP.intEntityEmployeeId
	LEFT JOIN (SELECT DISTINCT intYear = YEAR(dtmPayDate), intEntityEmployeeId 
				FROM tblPRPaycheck WHERE ysnPosted = 1 AND ysnVoid = 0) AS [YR] 
		ON YR.intEntityEmployeeId = EMP.intEntityId
	
	/* Yearly Data */
	LEFT JOIN (SELECT intYear = YEAR(dtmPayDate), dblNetPay = SUM(dblNetPayTotal), intEntityEmployeeId 
				FROM tblPRPaycheck WHERE ysnPosted = 1 AND ysnVoid = 0 GROUP BY YEAR(dtmPayDate), intEntityEmployeeId) AS [PC_Y]
		ON PC_Y.intEntityEmployeeId = EMP.intEntityId AND PC_Y.intYear = YR.intYear
	LEFT JOIN (SELECT intYear = YEAR(dtmPayDate), intEntityEmployeeId, dblHours = SUM(dblHours), dblTotal = SUM(dblTotal) 
				FROM vyuPRPaycheckEarning WHERE strCalculationType NOT IN ('Reimbursement') GROUP BY YEAR(dtmPayDate), intEntityEmployeeId) AS [EARN_Y] 
		ON EARN_Y.intEntityEmployeeId = EMP.intEntityId AND EARN_Y.intYear = YR.intYear
	LEFT JOIN (SELECT intYear = YEAR(dtmPayDate), intEntityEmployeeId, dblTotal = SUM(dblTotal)
				FROM vyuPRPaycheckTax WHERE strPaidBy = 'Company' GROUP BY YEAR(dtmPayDate), intEntityEmployeeId) AS [COMTAX_Y]
		ON COMTAX_Y.intEntityEmployeeId = EMP.intEntityId AND COMTAX_Y.intYear = YR.intYear
	LEFT JOIN (SELECT intYear = YEAR(dtmPayDate), intEntityEmployeeId, dblTotal = SUM(dblTotal)
				FROM vyuPRPaycheckTax WHERE strPaidBy = 'Employee' GROUP BY YEAR(dtmPayDate), intEntityEmployeeId) AS [EMPTAX_Y]
		ON EMPTAX_Y.intEntityEmployeeId = EMP.intEntityId AND EMPTAX_Y.intYear = YR.intYear
	LEFT JOIN (SELECT intYear = YEAR(dtmPayDate), intEntityEmployeeId, dblTotal = SUM(dblTotal)
				FROM vyuPRPaycheckDeduction WHERE strPaidBy = 'Employee' GROUP BY YEAR(dtmPayDate), intEntityEmployeeId) AS [EMPDED_Y]
		ON EMPDED_Y.intEntityEmployeeId = EMP.intEntityId AND EMPDED_Y.intYear = YR.intYear
	LEFT JOIN (SELECT intYear = YEAR(dtmPayDate), intEntityEmployeeId, dblTotal = SUM(dblTotal) 
				FROM vyuPRPaycheckDeduction WHERE strPaidBy = 'Company' GROUP BY YEAR(dtmPayDate), intEntityEmployeeId) AS [COMDED_Y]
		ON COMDED_Y.intEntityEmployeeId = EMP.intEntityId AND COMDED_Y.intYear = YR.intYear

	/* 1st Quarter Data */
	LEFT JOIN (SELECT intYear = YEAR(dtmPayDate), dblNetPay = SUM(dblNetPayTotal), intEntityEmployeeId 
				FROM tblPRPaycheck WHERE ysnPosted = 1 AND ysnVoid = 0 AND DATEPART(QQ, dtmPayDate) = 1 GROUP BY YEAR(dtmPayDate), intEntityEmployeeId) AS [PC_Q1]
		ON PC_Q1.intEntityEmployeeId = EMP.intEntityId AND PC_Q1.intYear = YR.intYear
	LEFT JOIN (SELECT intYear = YEAR(dtmPayDate), intEntityEmployeeId, dblHours = SUM(dblHours), dblTotal = SUM(dblTotal)
				FROM vyuPRPaycheckEarning WHERE strCalculationType NOT IN ('Reimbursement') AND DATEPART(QQ, dtmPayDate) = 1 GROUP BY YEAR(dtmPayDate), intEntityEmployeeId) AS [EARN_Q1] 
		ON EARN_Q1.intEntityEmployeeId = EMP.intEntityId AND EARN_Q1.intYear = YR.intYear
	LEFT JOIN (SELECT intYear = YEAR(dtmPayDate), intEntityEmployeeId, dblTotal = SUM(dblTotal)
				FROM vyuPRPaycheckTax WHERE strPaidBy = 'Company' AND DATEPART(QQ, dtmPayDate) = 1 GROUP BY YEAR(dtmPayDate), intEntityEmployeeId) AS [COMTAX_Q1]
		ON COMTAX_Q1.intEntityEmployeeId = EMP.intEntityId AND COMTAX_Q1.intYear = YR.intYear
	LEFT JOIN (SELECT intYear = YEAR(dtmPayDate), intEntityEmployeeId, dblTotal = SUM(dblTotal) FROM vyuPRPaycheckTax
				WHERE strPaidBy = 'Employee' AND DATEPART(QQ, dtmPayDate) = 1 GROUP BY YEAR(dtmPayDate), intEntityEmployeeId) AS [EMPTAX_Q1]
		ON EMPTAX_Q1.intEntityEmployeeId = EMP.intEntityId AND EMPTAX_Q1.intYear = YR.intYear
	LEFT JOIN (SELECT intYear = YEAR(dtmPayDate), intEntityEmployeeId, dblTotal = SUM(dblTotal) FROM vyuPRPaycheckDeduction
				WHERE strPaidBy = 'Employee' AND DATEPART(QQ, dtmPayDate) = 1 GROUP BY YEAR(dtmPayDate), intEntityEmployeeId) AS [EMPDED_Q1]
		ON EMPDED_Q1.intEntityEmployeeId = EMP.intEntityId AND EMPDED_Q1.intYear = YR.intYear
	LEFT JOIN (SELECT intYear = YEAR(dtmPayDate), intEntityEmployeeId, dblTotal = SUM(dblTotal) FROM vyuPRPaycheckDeduction
				WHERE strPaidBy = 'Company' AND DATEPART(QQ, dtmPayDate) = 1 GROUP BY YEAR(dtmPayDate), intEntityEmployeeId) AS [COMDED_Q1]
		ON COMDED_Q1.intEntityEmployeeId = EMP.intEntityId AND COMDED_Q1.intYear = YR.intYear

	/* 2nd Quarter Data */
	LEFT JOIN (SELECT intYear = YEAR(dtmPayDate), dblNetPay = SUM(dblNetPayTotal), intEntityEmployeeId 
				FROM tblPRPaycheck WHERE ysnPosted = 1 AND ysnVoid = 0 AND DATEPART(QQ, dtmPayDate) = 2 GROUP BY YEAR(dtmPayDate), intEntityEmployeeId) AS [PC_Q2]
		ON PC_Q2.intEntityEmployeeId = EMP.intEntityId AND PC_Q2.intYear = YR.intYear
	LEFT JOIN (SELECT intYear = YEAR(dtmPayDate), intEntityEmployeeId, dblHours = SUM(dblHours), dblTotal = SUM(dblTotal)
				FROM vyuPRPaycheckEarning WHERE strCalculationType NOT IN ('Reimbursement') AND DATEPART(QQ, dtmPayDate) = 2 GROUP BY YEAR(dtmPayDate), intEntityEmployeeId) AS [EARN_Q2] 
		ON EARN_Q2.intEntityEmployeeId = EMP.intEntityId AND EARN_Q2.intYear = YR.intYear
	LEFT JOIN (SELECT intYear = YEAR(dtmPayDate), intEntityEmployeeId, dblTotal = SUM(dblTotal)
				FROM vyuPRPaycheckTax WHERE strPaidBy = 'Company' AND DATEPART(QQ, dtmPayDate) = 2 GROUP BY YEAR(dtmPayDate), intEntityEmployeeId) AS [COMTAX_Q2]
		ON COMTAX_Q2.intEntityEmployeeId = EMP.intEntityId AND COMTAX_Q2.intYear = YR.intYear
	LEFT JOIN (SELECT intYear = YEAR(dtmPayDate), intEntityEmployeeId, dblTotal = SUM(dblTotal) FROM vyuPRPaycheckTax
				WHERE strPaidBy = 'Employee' AND DATEPART(QQ, dtmPayDate) = 2 GROUP BY YEAR(dtmPayDate), intEntityEmployeeId) AS [EMPTAX_Q2]
		ON EMPTAX_Q2.intEntityEmployeeId = EMP.intEntityId AND EMPTAX_Q2.intYear = YR.intYear
	LEFT JOIN (SELECT intYear = YEAR(dtmPayDate), intEntityEmployeeId, dblTotal = SUM(dblTotal) FROM vyuPRPaycheckDeduction
				WHERE strPaidBy = 'Employee' AND DATEPART(QQ, dtmPayDate) = 2 GROUP BY YEAR(dtmPayDate), intEntityEmployeeId) AS [EMPDED_Q2]
		ON EMPDED_Q2.intEntityEmployeeId = EMP.intEntityId AND EMPDED_Q2.intYear = YR.intYear
	LEFT JOIN (SELECT intYear = YEAR(dtmPayDate), intEntityEmployeeId, dblTotal = SUM(dblTotal) FROM vyuPRPaycheckDeduction
				WHERE strPaidBy = 'Company' AND DATEPART(QQ, dtmPayDate) = 2 GROUP BY YEAR(dtmPayDate), intEntityEmployeeId) AS [COMDED_Q2]
		ON COMDED_Q2.intEntityEmployeeId = EMP.intEntityId AND COMDED_Q2.intYear = YR.intYear

	/* 3rd Quarter Data */
	LEFT JOIN (SELECT intYear = YEAR(dtmPayDate), dblNetPay = SUM(dblNetPayTotal), intEntityEmployeeId 
				FROM tblPRPaycheck WHERE ysnPosted = 1 AND ysnVoid = 0 AND DATEPART(QQ, dtmPayDate) = 3 GROUP BY YEAR(dtmPayDate), intEntityEmployeeId) AS [PC_Q3]
		ON PC_Q3.intEntityEmployeeId = EMP.intEntityId AND PC_Q3.intYear = YR.intYear
	LEFT JOIN (SELECT intYear = YEAR(dtmPayDate), intEntityEmployeeId, dblHours = SUM(dblHours), dblTotal = SUM(dblTotal)
				FROM vyuPRPaycheckEarning WHERE strCalculationType NOT IN ('Reimbursement') AND DATEPART(QQ, dtmPayDate) = 3 GROUP BY YEAR(dtmPayDate), intEntityEmployeeId) AS [EARN_Q3] 
		ON EARN_Q3.intEntityEmployeeId = EMP.intEntityId AND EARN_Q3.intYear = YR.intYear
	LEFT JOIN (SELECT intYear = YEAR(dtmPayDate), intEntityEmployeeId, dblTotal = SUM(dblTotal)
				FROM vyuPRPaycheckTax WHERE strPaidBy = 'Company' AND DATEPART(QQ, dtmPayDate) = 3 GROUP BY YEAR(dtmPayDate), intEntityEmployeeId) AS [COMTAX_Q3]
		ON COMTAX_Q3.intEntityEmployeeId = EMP.intEntityId AND COMTAX_Q3.intYear = YR.intYear
	LEFT JOIN (SELECT intYear = YEAR(dtmPayDate), intEntityEmployeeId, dblTotal = SUM(dblTotal) FROM vyuPRPaycheckTax
				WHERE strPaidBy = 'Employee' AND DATEPART(QQ, dtmPayDate) = 3 GROUP BY YEAR(dtmPayDate), intEntityEmployeeId) AS [EMPTAX_Q3]
		ON EMPTAX_Q3.intEntityEmployeeId = EMP.intEntityId AND EMPTAX_Q3.intYear = YR.intYear
	LEFT JOIN (SELECT intYear = YEAR(dtmPayDate), intEntityEmployeeId, dblTotal = SUM(dblTotal) FROM vyuPRPaycheckDeduction
				WHERE strPaidBy = 'Employee' AND DATEPART(QQ, dtmPayDate) = 3 GROUP BY YEAR(dtmPayDate), intEntityEmployeeId) AS [EMPDED_Q3]
		ON EMPDED_Q3.intEntityEmployeeId = EMP.intEntityId AND EMPDED_Q3.intYear = YR.intYear
	LEFT JOIN (SELECT intYear = YEAR(dtmPayDate), intEntityEmployeeId, dblTotal = SUM(dblTotal) FROM vyuPRPaycheckDeduction
				WHERE strPaidBy = 'Company' AND DATEPART(QQ, dtmPayDate) = 3 GROUP BY YEAR(dtmPayDate), intEntityEmployeeId) AS [COMDED_Q3]
		ON COMDED_Q3.intEntityEmployeeId = EMP.intEntityId AND COMDED_Q3.intYear = YR.intYear

	/* 4th Quarter Data */
	LEFT JOIN (SELECT intYear = YEAR(dtmPayDate), dblNetPay = SUM(dblNetPayTotal), intEntityEmployeeId 
				FROM tblPRPaycheck WHERE ysnPosted = 1 AND ysnVoid = 0 AND DATEPART(QQ, dtmPayDate) = 4 GROUP BY YEAR(dtmPayDate), intEntityEmployeeId) AS [PC_Q4]
		ON PC_Q4.intEntityEmployeeId = EMP.intEntityId AND PC_Q4.intYear = YR.intYear
	LEFT JOIN (SELECT intYear = YEAR(dtmPayDate), intEntityEmployeeId, dblHours = SUM(dblHours), dblTotal = SUM(dblTotal)
				FROM vyuPRPaycheckEarning WHERE strCalculationType NOT IN ('Reimbursement') AND DATEPART(QQ, dtmPayDate) = 4 GROUP BY YEAR(dtmPayDate), intEntityEmployeeId) AS [EARN_Q4] 
		ON EARN_Q4.intEntityEmployeeId = EMP.intEntityId AND EARN_Q4.intYear = YR.intYear
	LEFT JOIN (SELECT intYear = YEAR(dtmPayDate), intEntityEmployeeId, dblTotal = SUM(dblTotal)
				FROM vyuPRPaycheckTax WHERE strPaidBy = 'Company' AND DATEPART(QQ, dtmPayDate) = 4 GROUP BY YEAR(dtmPayDate), intEntityEmployeeId) AS [COMTAX_Q4]
		ON COMTAX_Q4.intEntityEmployeeId = EMP.intEntityId AND COMTAX_Q4.intYear = YR.intYear
	LEFT JOIN (SELECT intYear = YEAR(dtmPayDate), intEntityEmployeeId, dblTotal = SUM(dblTotal) FROM vyuPRPaycheckTax
				WHERE strPaidBy = 'Employee' AND DATEPART(QQ, dtmPayDate) = 4 GROUP BY YEAR(dtmPayDate), intEntityEmployeeId) AS [EMPTAX_Q4]
		ON EMPTAX_Q4.intEntityEmployeeId = EMP.intEntityId AND EMPTAX_Q4.intYear = YR.intYear
	LEFT JOIN (SELECT intYear = YEAR(dtmPayDate), intEntityEmployeeId, dblTotal = SUM(dblTotal) FROM vyuPRPaycheckDeduction
				WHERE strPaidBy = 'Employee' AND DATEPART(QQ, dtmPayDate) = 4 GROUP BY YEAR(dtmPayDate), intEntityEmployeeId) AS [EMPDED_Q4]
		ON EMPDED_Q4.intEntityEmployeeId = EMP.intEntityId AND EMPDED_Q4.intYear = YR.intYear
	LEFT JOIN (SELECT intYear = YEAR(dtmPayDate), intEntityEmployeeId, dblTotal = SUM(dblTotal) FROM vyuPRPaycheckDeduction
				WHERE strPaidBy = 'Company' AND DATEPART(QQ, dtmPayDate) = 4 GROUP BY YEAR(dtmPayDate), intEntityEmployeeId) AS [COMDED_Q4]
		ON COMDED_Q4.intEntityEmployeeId = EMP.intEntityId AND COMDED_Q4.intYear = YR.intYear

WHERE YR.intYear IS NOT NULL
	
GO
