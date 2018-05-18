CREATE PROCEDURE [dbo].[uspPRUpdateInsertForm941]
	@intYear INT
	,@intQuarter INT
	,@intForm941Id INT = NULL OUTPUT
AS

/* If if there are existing Paychecks with the specified Year and Quarter */
IF EXISTS(SELECT TOP 1 1 FROM tblPRPaycheck WHERE YEAR(dtmPayDate) = @intYear AND DATEPART(QQ, dtmPayDate) = @intQuarter AND ysnPosted = 1 AND ysnVoid = 0)
BEGIN
	/* Check if Form 941 with Year and Quarter exists */
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblPRForm941 WHERE intYear = @intYear AND intQuarter = @intQuarter)
	BEGIN
		INSERT INTO tblPRForm941(
			intYear
			,intQuarter
			,strTradeName
			,intEmployees
			,dblAdjustedGross
			,dblFIT
			,ysnNoTaxable
			,dblTaxableSS
			,dblSSTax
			,dblTaxableSSTips
			,dblSSTipsTax
			,dblTaxableMed
			,dblMedTax
			,dblTaxableAddMed
			,dblAddMedTax
			,dblTaxDueUnreported
			,dblAdjustFractionCents
			,dblAdjustSickPay
			,dblAdjustTips
			,dblTotalDeposit
			,ysnRefundOverpayment
			,intScheduleType
			,dblMonth1
			,dblMonth2
			,dblMonth3
			,ysnStoppedWages
			,dtmStoppedWages
			,ysnSeasonalEmployer
			,ysnAllowContactDesignee
			,strDesigneeName
			,strDesigneePhone
			,strDesigneePIN
			,strName
			,strTitle
			,dtmSignDate
			,strPhone
			,ysnSelfEmployed
			,strPreparerName
			,strPreparerPTIN
			,strPreparerFirmName
			,strPreparerEIN
			,dtmPreparerSignDate
			,strPreparerAddress
			,strPreparerCity
			,strPreparerState
			,strPreparerZip
			,strPreparerPhone
			,dblPaymentDollars
			,dblPaymentCents
			,intConcurrencyId)
		SELECT DISTINCT
			intYear = @intYear
			,intQuarter = @intQuarter
			,strTradeName = ISNULL((SELECT TOP 1 strTradeName FROM tblPRForm941 WHERE strTradeName IS NOT NULL), '')
			,intEmployees = ISNULL(PCHK.intEmployees, 0)
			,dblAdjustedGross = CASE WHEN (ISNULL(TXBLFIT.dblTotal, 0) - ISNULL(PRTXFIT.dblTotal, 0)) <= 0 THEN 0 ELSE ISNULL(TXBLFIT.dblTotal, 0) - ISNULL(PRTXFIT.dblTotal, 0) END
			,dblFIT = ISNULL(FIT.dblTotal, 0)
			,ysnNoTaxable = CASE WHEN (ISNULL(FIT.dblTotal, 0) + ISNULL(SSTAX.dblTotal, 0) + ISNULL(MEDTAX.dblTotal, 0) <= 0) THEN 1 ELSE 0 END
			,dblTaxableSS = CASE WHEN (ISNULL(TXBLSS.dblTotal, 0) - ISNULL(PRTXSS.dblTotal, 0)) <= 0 THEN 0 ELSE ISNULL(TXBLSS.dblTotal, 0) - ISNULL(PRTXSS.dblTotal, 0) END
			,dblSSTax = SSTAX.dblTotal - (SSTAX.dblTotal * TIPS.dblTipsPercent)
			,dblTaxableSSTips = CASE WHEN (ISNULL(TXBLSSTIPS.dblTotal, 0) - ISNULL(PRTXSS.dblTotal, 0)) <= 0 THEN 0 ELSE ISNULL(TXBLSSTIPS.dblTotal, 0) - ISNULL(PRTXSS.dblTotal, 0) END
			,dblSSTipsTax = (SSTAX.dblTotal * TIPS.dblTipsPercent)
			,dblTaxableMed = CASE WHEN (ISNULL(TXBLMED.dblTotal, 0) - ISNULL(PRTXMED.dblTotal, 0)) <= 0 THEN 0 ELSE ISNULL(TXBLMED.dblTotal, 0) - ISNULL(PRTXMED.dblTotal, 0) END
			,dblMedTax = ISNULL(MEDTAX.dblTotal, 0)
			,dblTaxableAddMed = ISNULL(ADDMED.dblTotal, 0) / 0.009
			,dblAddMedTax = ISNULL(ADDMED.dblTotal, 0)
			,dblTaxDueUnreported = 0
			,dblAdjustFractionCents = 0
			,dblAdjustSickPay = 0
			,dblAdjustTips = 0
			,dblTotalDeposit = 0
			,ysnRefundOverpayment = 0
			,intScheduleType = 1
			,dblMonth1 = ISNULL(MONTH1.dblMonthTotal, 0)
			,dblMonth2 = ISNULL(MONTH2.dblMonthTotal, 0)
			,dblMonth3 = ISNULL(MONTH3.dblMonthTotal, 0)
			,ysnStoppedWages = 0
			,dtmStoppedWages = NULL
			,ysnSeasonalEmployer = 0
			,ysnAllowContactDesignee = 0
			,strDesigneeName = ''
			,strDesigneePhone = ''
			,strDesigneePIN = ''
			,strName = ''
			,strTitle = ''
			,dtmSignDate = NULL
			,strPhone = ''
			,ysnSelfEmployed = 0
			,strPreparerName = ''
			,strPreparerPTIN = ''
			,strPreparerFirmName = ''
			,strPreparerEIN = ''
			,dtmPreparerSignDate = NULL
			,strPreparerAddress = ''
			,strPreparerCity = ''
			,strPreparerState = ''
			,strPreparerZip = ''
			,strPreparerPhone = ''
			,dblPaymentDollars = 0
			,dblPaymentCents = 0
			,intConcurrencyId = 1
		FROM 
			/* Taxable Amount */
			(SELECT dblTotal = SUM(dblTotal) FROM vyuPRPaycheckEarning WHERE YEAR(dtmPayDate) = @intYear AND DATEPART(QQ, dtmPayDate) = @intQuarter AND ysnFITTaxable = 1 AND ysnVoid = 0) [TXBLFIT],
			(SELECT dblTotal = SUM(dblTotal) FROM vyuPRPaycheckEarning WHERE YEAR(dtmPayDate) = @intYear AND DATEPART(QQ, dtmPayDate) = @intQuarter AND strCalculationType <> 'Tip' AND ysnSSTaxable = 1 AND ysnVoid = 0) [TXBLSS],
			(SELECT dblTotal = SUM(dblTotal) FROM vyuPRPaycheckEarning WHERE YEAR(dtmPayDate) = @intYear AND DATEPART(QQ, dtmPayDate) = @intQuarter AND strCalculationType = 'Tip' AND ysnSSTaxable = 1 AND ysnVoid = 0) [TXBLSSTIPS],
			(SELECT dblTotal = SUM(dblTotal) FROM vyuPRPaycheckEarning WHERE YEAR(dtmPayDate) = @intYear AND DATEPART(QQ, dtmPayDate) = @intQuarter AND ysnMedTaxable = 1 AND ysnVoid = 0) [TXBLMED],

			/* Taxable Pretax Deductions */
			(SELECT dblTotal = SUM(dblTotal) FROM vyuPRPaycheckDeduction WHERE YEAR(dtmPayDate) = @intYear AND DATEPART(QQ, dtmPayDate) = @intQuarter AND strPaidBy = 'Employee' AND strDeductFrom = 'Gross Pay' AND ysnFITTaxable = 1 AND ysnVoid = 0) [PRTXFIT],
			(SELECT dblTotal = SUM(dblTotal) FROM vyuPRPaycheckDeduction WHERE YEAR(dtmPayDate) = @intYear AND DATEPART(QQ, dtmPayDate) = @intQuarter AND strPaidBy = 'Employee' AND strDeductFrom = 'Gross Pay' AND ysnSSTaxable = 1 AND ysnVoid = 0) [PRTXSS],
			(SELECT dblTotal = SUM(dblTotal) FROM vyuPRPaycheckDeduction WHERE YEAR(dtmPayDate) = @intYear AND DATEPART(QQ, dtmPayDate) = @intQuarter AND strPaidBy = 'Employee' AND strDeductFrom = 'Gross Pay' AND ysnMedTaxable = 1 AND ysnVoid = 0) [PRTXMED],
			
			/* Tax Amounts */
			(SELECT dblTotal = SUM(dblFIT) FROM vyuPRMonthlyTaxTotal WHERE intYear = @intYear AND intQuarter = @intQuarter) [FIT],
			(SELECT dblTotal = SUM(dblTaxTotalSS) + SUM(dblLiabilitySS) FROM vyuPRMonthlyTaxTotal WHERE intYear = @intYear AND intQuarter = @intQuarter) [SSTAX],
			(SELECT dblTotal = SUM(dblTaxTotalMed) + SUM(dblLiabilityMed) FROM vyuPRMonthlyTaxTotal WHERE intYear = @intYear AND intQuarter = @intQuarter) [MEDTAX],
			(SELECT dblTotal = SUM(dblTaxTotalAddMed) FROM vyuPRMonthlyTaxTotal WHERE intYear = @intYear AND intQuarter = @intQuarter) [ADDMED],

			/* Monthly Totals */
			(SELECT dblMonthTotal = SUM(dblMonthTotal) FROM vyuPRMonthlyTaxTotal WHERE intYear = @intYear AND intQuarter = @intQuarter AND intMonth IN (1, 4, 7, 10)) [MONTH1],
			(SELECT dblMonthTotal = SUM(dblMonthTotal) FROM vyuPRMonthlyTaxTotal WHERE intYear = @intYear AND intQuarter = @intQuarter AND intMonth IN (2, 5, 8, 11)) [MONTH2],
			(SELECT dblMonthTotal = SUM(dblMonthTotal) FROM vyuPRMonthlyTaxTotal WHERE intYear = @intYear AND intQuarter = @intQuarter AND intMonth IN (3, 6, 9, 12)) [MONTH3],
			
			/* Tips Percentage */
			(SELECT dblTipsPercent = CASE WHEN ((ISNULL(E2.dblTotal, 0) - ISNULL(D1.dblTotal, 0)) / (ISNULL(E1.dblTotal, 0) - ISNULL(D1.dblTotal, 0)) > 0)
										   THEN (ISNULL(E2.dblTotal, 0) - ISNULL(D1.dblTotal, 0)) / (ISNULL(E1.dblTotal, 0) - ISNULL(D1.dblTotal, 0)) ELSE 0 END
			  FROM (SELECT dblTotal = SUM(dblTotal) FROM vyuPRPaycheckEarning WHERE strCalculationType <> 'Tip' AND ysnSSTaxable = 1 AND YEAR(dtmPayDate) = @intYear AND DATEPART(QQ, dtmPayDate) = @intQuarter AND ysnVoid = 0) E1,
				   (SELECT dblTotal = SUM(dblTotal) FROM vyuPRPaycheckEarning WHERE strCalculationType = 'Tip' AND ysnSSTaxable = 1 AND YEAR(dtmPayDate) = @intYear AND DATEPART(QQ, dtmPayDate) = @intQuarter AND ysnVoid = 0) E2,
				   (SELECT dblTotal = SUM(dblTotal) FROM vyuPRPaycheckDeduction WHERE strDeductFrom = 'Gross Pay' AND ysnSSTaxable = 1 AND strPaidBy = 'Employee' AND YEAR(dtmPayDate) = @intYear AND DATEPART(QQ, dtmPayDate) = @intQuarter AND ysnVoid = 0) D1
			) [TIPS],

			/* Employee Count */
			(SELECT intEmployees = COUNT(DISTINCT intEntityEmployeeId),
					 dblGrossSum = SUM(dblAdjustedGross)
				FROM tblPRPaycheck 
				WHERE YEAR(dtmPayDate) = @intYear AND DATEPART(QQ, dtmPayDate) = @intQuarter AND ysnPosted = 1 AND ysnVoid = 0) PCHK
			 
		/* Get the inserted Form 941 Id */
		SELECT @intForm941Id = SCOPE_IDENTITY()
	END
	ELSE
	BEGIN
		/* If it exists, update the values */
		UPDATE tblPRForm941 
		SET intEmployees = ISNULL(PCHK.intEmployees, 0)
			,dblAdjustedGross = CASE WHEN (ISNULL(TXBLFIT.dblTotal, 0) - ISNULL(PRTXFIT.dblTotal, 0)) <= 0 THEN 0 ELSE ISNULL(TXBLFIT.dblTotal, 0) - ISNULL(PRTXFIT.dblTotal, 0) END
			,dblFIT = ISNULL(FIT.dblTotal, 0)
			,ysnNoTaxable = CASE WHEN (ISNULL(FIT.dblTotal, 0) + ISNULL(SSTAX.dblTotal, 0) + ISNULL(MEDTAX.dblTotal, 0) <= 0) THEN 1 ELSE 0 END
			,dblTaxableSS = CASE WHEN (ISNULL(TXBLSS.dblTotal, 0) - ISNULL(PRTXSS.dblTotal, 0)) <= 0 THEN 0 ELSE ISNULL(TXBLSS.dblTotal, 0) - ISNULL(PRTXSS.dblTotal, 0) END
			,dblSSTax = SSTAX.dblTotal - (SSTAX.dblTotal * TIPS.dblTipsPercent)
			,dblTaxableSSTips = CASE WHEN (ISNULL(TXBLSSTIPS.dblTotal, 0) - ISNULL(PRTXSS.dblTotal, 0)) <= 0 THEN 0 ELSE ISNULL(TXBLSSTIPS.dblTotal, 0) - ISNULL(PRTXSS.dblTotal, 0) END
			,dblSSTipsTax = (SSTAX.dblTotal * TIPS.dblTipsPercent)
			,dblTaxableMed = CASE WHEN (ISNULL(TXBLMED.dblTotal, 0) - ISNULL(PRTXMED.dblTotal, 0)) <= 0 THEN 0 ELSE ISNULL(TXBLMED.dblTotal, 0) - ISNULL(PRTXMED.dblTotal, 0) END
			,dblMedTax = ISNULL(MEDTAX.dblTotal, 0)
			,dblTaxableAddMed = ISNULL(ADDMED.dblTotal, 0) / 0.009
			,dblAddMedTax = ISNULL(ADDMED.dblTotal, 0)
			,dblMonth1 = ISNULL(MONTH1.dblMonthTotal, 0)
			,dblMonth2 = ISNULL(MONTH2.dblMonthTotal, 0)
			,dblMonth3 = ISNULL(MONTH3.dblMonthTotal, 0)
		FROM 
		
			/* Taxable Amount */
			(SELECT dblTotal = SUM(dblTotal) FROM vyuPRPaycheckEarning WHERE YEAR(dtmPayDate) = @intYear AND DATEPART(QQ, dtmPayDate) = @intQuarter AND ysnFITTaxable = 1 AND ysnVoid = 0) [TXBLFIT],
			(SELECT dblTotal = SUM(dblTotal) FROM vyuPRPaycheckEarning WHERE YEAR(dtmPayDate) = @intYear AND DATEPART(QQ, dtmPayDate) = @intQuarter AND strCalculationType <> 'Tip' AND ysnSSTaxable = 1 AND ysnVoid = 0) [TXBLSS],
			(SELECT dblTotal = SUM(dblTotal) FROM vyuPRPaycheckEarning WHERE YEAR(dtmPayDate) = @intYear AND DATEPART(QQ, dtmPayDate) = @intQuarter AND strCalculationType = 'Tip' AND ysnSSTaxable = 1 AND ysnVoid = 0) [TXBLSSTIPS],
			(SELECT dblTotal = SUM(dblTotal) FROM vyuPRPaycheckEarning WHERE YEAR(dtmPayDate) = @intYear AND DATEPART(QQ, dtmPayDate) = @intQuarter AND ysnMedTaxable = 1 AND ysnVoid = 0) [TXBLMED],

			/* Taxable Pretax Deductions */
			(SELECT dblTotal = SUM(dblTotal) FROM vyuPRPaycheckDeduction WHERE YEAR(dtmPayDate) = @intYear AND DATEPART(QQ, dtmPayDate) = @intQuarter AND strPaidBy = 'Employee' AND strDeductFrom = 'Gross Pay' AND ysnFITTaxable = 1 AND ysnVoid = 0) [PRTXFIT],
			(SELECT dblTotal = SUM(dblTotal) FROM vyuPRPaycheckDeduction WHERE YEAR(dtmPayDate) = @intYear AND DATEPART(QQ, dtmPayDate) = @intQuarter AND strPaidBy = 'Employee' AND strDeductFrom = 'Gross Pay' AND ysnSSTaxable = 1 AND ysnVoid = 0) [PRTXSS],
			(SELECT dblTotal = SUM(dblTotal) FROM vyuPRPaycheckDeduction WHERE YEAR(dtmPayDate) = @intYear AND DATEPART(QQ, dtmPayDate) = @intQuarter AND strPaidBy = 'Employee' AND strDeductFrom = 'Gross Pay' AND ysnMedTaxable = 1 AND ysnVoid = 0) [PRTXMED],
			
			/* Tax Amounts */
			(SELECT dblTotal = SUM(dblFIT) FROM vyuPRMonthlyTaxTotal WHERE intYear = @intYear AND intQuarter = @intQuarter) [FIT],
			(SELECT dblTotal = SUM(dblTaxTotalSS) + SUM(dblLiabilitySS) FROM vyuPRMonthlyTaxTotal WHERE intYear = @intYear AND intQuarter = @intQuarter) [SSTAX],
			(SELECT dblTotal = SUM(dblTaxTotalMed) + SUM(dblLiabilityMed) FROM vyuPRMonthlyTaxTotal WHERE intYear = @intYear AND intQuarter = @intQuarter) [MEDTAX],
			(SELECT dblTotal = SUM(dblTaxTotalAddMed) FROM vyuPRMonthlyTaxTotal WHERE intYear = @intYear AND intQuarter = @intQuarter) [ADDMED],

			/* Monthly Totals */
			(SELECT dblMonthTotal = SUM(dblMonthTotal) FROM vyuPRMonthlyTaxTotal WHERE intYear = @intYear AND intQuarter = @intQuarter AND intMonth IN (1, 4, 7, 10)) [MONTH1],
			(SELECT dblMonthTotal = SUM(dblMonthTotal) FROM vyuPRMonthlyTaxTotal WHERE intYear = @intYear AND intQuarter = @intQuarter AND intMonth IN (2, 5, 8, 11)) [MONTH2],
			(SELECT dblMonthTotal = SUM(dblMonthTotal) FROM vyuPRMonthlyTaxTotal WHERE intYear = @intYear AND intQuarter = @intQuarter AND intMonth IN (3, 6, 9, 12)) [MONTH3],
			
			/* Tips Percentage */
			(SELECT dblTipsPercent = CASE WHEN ((ISNULL(E2.dblTotal, 0) - ISNULL(D1.dblTotal, 0)) / (ISNULL(E1.dblTotal, 0) - ISNULL(D1.dblTotal, 0)) > 0)
										   THEN (ISNULL(E2.dblTotal, 0) - ISNULL(D1.dblTotal, 0)) / (ISNULL(E1.dblTotal, 0) - ISNULL(D1.dblTotal, 0)) ELSE 0 END
			  FROM (SELECT dblTotal = SUM(dblTotal) FROM vyuPRPaycheckEarning WHERE strCalculationType <> 'Tip' AND ysnSSTaxable = 1 AND YEAR(dtmPayDate) = @intYear AND DATEPART(QQ, dtmPayDate) = @intQuarter AND ysnVoid = 0) E1,
				   (SELECT dblTotal = SUM(dblTotal) FROM vyuPRPaycheckEarning WHERE strCalculationType = 'Tip' AND ysnSSTaxable = 1 AND YEAR(dtmPayDate) = @intYear AND DATEPART(QQ, dtmPayDate) = @intQuarter AND ysnVoid = 0) E2,
				   (SELECT dblTotal = SUM(dblTotal) FROM vyuPRPaycheckDeduction WHERE strDeductFrom = 'Gross Pay' AND ysnSSTaxable = 1 AND strPaidBy = 'Employee' AND YEAR(dtmPayDate) = @intYear AND DATEPART(QQ, dtmPayDate) = @intQuarter AND ysnVoid = 0) D1
			) [TIPS],

			/* Employee Count */
			(SELECT intEmployees = COUNT(DISTINCT intEntityEmployeeId),
					 dblGrossSum = SUM(dblAdjustedGross)
				FROM tblPRPaycheck 
				WHERE YEAR(dtmPayDate) = @intYear AND DATEPART(QQ, dtmPayDate) = @intQuarter AND ysnPosted = 1 AND ysnVoid = 0) PCHK
		WHERE intYear = @intYear AND intQuarter = @intQuarter

		/* Get the updated Form 941 Id */
		SELECT TOP 1 @intForm941Id = intForm941Id FROM tblPRForm941 WHERE intYear = @intYear AND intQuarter = @intQuarter
	END
END
GO