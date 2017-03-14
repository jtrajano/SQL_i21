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
			,intEmployees
			,dblAdjustedGross
			,dblFIT
			,ysnNoTaxable
			,dblTaxableSS
			,dblTaxableSSTips
			,dblTaxableMed
			,dblTaxableAddMed
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
		SELECT
			intYear = @intYear
			,intQuarter = @intQuarter
			,intEmployees = ISNULL(PCHK.intEmployees, 0)
			,dblAdjustedGross = ISNULL(PCHK.dblGrossSum, 0)
			,dblFIT = ISNULL(FIT.dblTotal, 0)
			,ysnNoTaxable = CASE WHEN (
								(CASE WHEN (ISNULL(FIT.dblTotal, 0) <= 0) THEN 0 ELSE ISNULL(FIT.dblTotal, 0) END
								+ CASE WHEN (ISNULL(SSTAX.dblTotal, 0) <= 0) THEN 0 ELSE ISNULL(SSTAX.dblTotal, 0) END
								+ CASE WHEN (ISNULL(SSMED.dblTotal, 0) <= 0) THEN 0 ELSE ISNULL(SSMED.dblTotal, 0) END
								) <= 0) THEN 1 ELSE 0 END
			,dblTaxableSS = (SSTAX.dblTotal - (SSTAX.dblTotal * TIPS.dblTipsPercent)) / 0.124
			,dblTaxableSSTips = (SSTAX.dblTotal * TIPS.dblTipsPercent) / 0.124
			,dblTaxableMed = ((SSMED.dblTotal) - (ADDMED.dblTotal)) / 0.029
			,dblTaxableAddMed = (ADDMED.dblTotal) / 0.009
			,dblTaxDueUnreported = 0
			,dblAdjustFractionCents = 0
			,dblAdjustSickPay = 0
			,dblAdjustTips = 0
			,dblTotalDeposit = 0
			,ysnRefundOverpayment = 0
			,intScheduleType = 1
			,dblMonth1 = (ISNULL(MONTH1.dblMonthTotal, 0))
			,dblMonth2 = (ISNULL(MONTH2.dblMonthTotal, 0))
			,dblMonth3 = (ISNULL(MONTH3.dblMonthTotal, 0))
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
		FROM (SELECT dblTotal = SUM(dblFIT) FROM vyuPRMonthlyTaxTotal WHERE intYear = @intYear AND intQuarter = @intQuarter) FIT,
			 (SELECT dblTotal = SUM(dblTaxTotalSS) + SUM(dblLiabilitySS) FROM vyuPRMonthlyTaxTotal WHERE intYear = @intYear AND intQuarter = @intQuarter) SSTAX,
			 (SELECT dblTotal = SUM(dblTaxTotalMed) + SUM(dblLiabilityMed) FROM vyuPRMonthlyTaxTotal WHERE intYear = @intYear AND intQuarter = @intQuarter) SSMED,
			 (SELECT dblTotal = SUM(dblTaxTotalAddMed) FROM vyuPRMonthlyTaxTotal WHERE intYear = @intYear AND intQuarter = @intQuarter) ADDMED,
			 (SELECT dblMonthTotal = SUM(dblMonthTotal) FROM vyuPRMonthlyTaxTotal WHERE intYear = @intYear AND intQuarter = @intQuarter AND intMonth IN (1, 4, 7, 10)) MONTH1,
			 (SELECT dblMonthTotal = SUM(dblMonthTotal) FROM vyuPRMonthlyTaxTotal WHERE intYear = @intYear AND intQuarter = @intQuarter AND intMonth IN (2, 5, 8, 11)) MONTH2,
			 (SELECT dblMonthTotal = SUM(dblMonthTotal) FROM vyuPRMonthlyTaxTotal WHERE intYear = @intYear AND intQuarter = @intQuarter AND intMonth IN (3, 6, 9, 12)) MONTH3,
			 (SELECT dblTipsPercent = CASE WHEN ((ISNULL(E2.dblTotal, 0) - ISNULL(D2.dblTotal, 0)) / (ISNULL(E1.dblTotal, 0) - ISNULL(D1.dblTotal, 0)) > 0)
										   THEN (ISNULL(E2.dblTotal, 0) - ISNULL(D2.dblTotal, 0)) / (ISNULL(E1.dblTotal, 0) - ISNULL(D1.dblTotal, 0))
										   ELSE 0 END FROM 
				 (SELECT dblTotal = SUM(dblTotal) FROM vyuPRPaycheckEarning WHERE strCalculationType <> 'Tip' AND ysnSSTaxable = 1 AND YEAR(dtmPayDate) = @intYear AND DATEPART(QQ, dtmPayDate) = @intQuarter AND ysnVoid = 0) E1,
				 (SELECT dblTotal = SUM(dblTotal) FROM vyuPRPaycheckDeduction WHERE strDeductFrom = 'Gross Pay' AND ysnSSTaxable = 1  AND YEAR(dtmPayDate) = @intYear AND DATEPART(QQ, dtmPayDate) = @intQuarter AND ysnVoid = 0) D1,
				 (SELECT dblTotal = SUM(dblTotal) FROM vyuPRPaycheckEarning WHERE strCalculationType = 'Tip' AND ysnSSTaxable = 1 AND YEAR(dtmPayDate) = @intYear AND DATEPART(QQ, dtmPayDate) = @intQuarter AND ysnVoid = 0) E2,
				 (SELECT dblTotal = SUM(dblTotal) FROM vyuPRPaycheckDeduction WHERE strDeductFrom = 'Gross Pay' AND ysnSSTaxable = 1  AND YEAR(dtmPayDate) = @intYear AND DATEPART(QQ, dtmPayDate) = @intQuarter AND ysnVoid = 0) D2
			 ) TIPS,
			 (SELECT dblTotal = ISNULL(E.dblTotal, 0) - ISNULL(D.dblTotal, 0) FROM 
				(SELECT dblTotal = SUM(dblTotal) FROM vyuPRPaycheckEarning WHERE ysnMedTaxable = 1 AND YEAR(dtmPayDate) = @intYear AND DATEPART(QQ, dtmPayDate) = @intQuarter AND ysnVoid = 0) E,
				(SELECT dblTotal = SUM(dblTotal) FROM vyuPRPaycheckDeduction WHERE strDeductFrom = 'Gross Pay' AND ysnMedTaxable = 1  AND YEAR(dtmPayDate) = @intYear AND DATEPART(QQ, dtmPayDate) = @intQuarter AND ysnVoid = 0) D) TXBLMED, 
			 (SELECT dblTotal = SUM(dblTotal) FROM vyuPRPaycheckDeduction WHERE strDeductFrom = 'Gross Pay'
				  AND YEAR(dtmPayDate) = @intYear AND DATEPART(QQ, dtmPayDate) = @intQuarter AND ysnVoid = 0) PRETAX,
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
			,ysnNoTaxable = CASE WHEN (
								(CASE WHEN (ISNULL(FIT.dblTotal, 0) <= 0) THEN 0 ELSE ISNULL(FIT.dblTotal, 0) END
								+ CASE WHEN (ISNULL(SSTAX.dblTotal, 0) <= 0) THEN 0 ELSE ISNULL(SSTAX.dblTotal, 0) END
								+ CASE WHEN (ISNULL(SSMED.dblTotal, 0) <= 0) THEN 0 ELSE ISNULL(SSMED.dblTotal, 0) END
								) <= 0) THEN 1 ELSE 0 END
			,dblAdjustedGross = ISNULL(PCHK.dblGrossSum, 0)
			,dblFIT = ISNULL(FIT.dblTotal, 0)
			,dblTaxableSS = (SSTAX.dblTotal - (SSTAX.dblTotal * TIPS.dblTipsPercent)) / 0.124
			,dblTaxableSSTips = (SSTAX.dblTotal * TIPS.dblTipsPercent) / 0.124
			,dblTaxableMed = (SSMED.dblTotal) / 0.029
			,dblTaxableAddMed = (ADDMED.dblTotal) / 0.009
			,dblMonth1 = (ISNULL(MONTH1.dblMonthTotal, 0))
			,dblMonth2 = (ISNULL(MONTH2.dblMonthTotal, 0))
			,dblMonth3 = (ISNULL(MONTH3.dblMonthTotal, 0))
		FROM (SELECT dblTotal = SUM(dblFIT) FROM vyuPRMonthlyTaxTotal WHERE intYear = @intYear AND intQuarter = @intQuarter) FIT,
			 (SELECT dblTotal = SUM(dblTaxTotalSS) + SUM(dblLiabilitySS) FROM vyuPRMonthlyTaxTotal WHERE intYear = @intYear AND intQuarter = @intQuarter) SSTAX,
			 (SELECT dblTotal = SUM(dblTaxTotalMed) + SUM(dblLiabilityMed) FROM vyuPRMonthlyTaxTotal WHERE intYear = @intYear AND intQuarter = @intQuarter) SSMED,
			 (SELECT dblTotal = SUM(dblTaxTotalAddMed) FROM vyuPRMonthlyTaxTotal WHERE intYear = @intYear AND intQuarter = @intQuarter) ADDMED,
			 (SELECT dblMonthTotal = SUM(dblMonthTotal) FROM vyuPRMonthlyTaxTotal WHERE intYear = @intYear AND intQuarter = @intQuarter AND intMonth IN (1, 4, 7, 10)) MONTH1,
			 (SELECT dblMonthTotal = SUM(dblMonthTotal) FROM vyuPRMonthlyTaxTotal WHERE intYear = @intYear AND intQuarter = @intQuarter AND intMonth IN (2, 5, 8, 11)) MONTH2,
			 (SELECT dblMonthTotal = SUM(dblMonthTotal) FROM vyuPRMonthlyTaxTotal WHERE intYear = @intYear AND intQuarter = @intQuarter AND intMonth IN (3, 6, 9, 12)) MONTH3,
			 (SELECT dblTipsPercent = CASE WHEN ((ISNULL(E2.dblTotal, 0) - ISNULL(D2.dblTotal, 0)) / (ISNULL(E1.dblTotal, 0) - ISNULL(D1.dblTotal, 0)) > 0)
										   THEN (ISNULL(E2.dblTotal, 0) - ISNULL(D2.dblTotal, 0)) / (ISNULL(E1.dblTotal, 0) - ISNULL(D1.dblTotal, 0))
										   ELSE 0 END FROM 
				 (SELECT dblTotal = SUM(dblTotal) FROM vyuPRPaycheckEarning WHERE strCalculationType <> 'Tip' AND ysnSSTaxable = 1 AND YEAR(dtmPayDate) = @intYear AND DATEPART(QQ, dtmPayDate) = @intQuarter AND ysnVoid = 0) E1,
				 (SELECT dblTotal = SUM(dblTotal) FROM vyuPRPaycheckDeduction WHERE strDeductFrom = 'Gross Pay' AND ysnSSTaxable = 1  AND YEAR(dtmPayDate) = @intYear AND DATEPART(QQ, dtmPayDate) = @intQuarter AND ysnVoid = 0) D1,
				 (SELECT dblTotal = SUM(dblTotal) FROM vyuPRPaycheckEarning WHERE strCalculationType = 'Tip' AND ysnSSTaxable = 1 AND YEAR(dtmPayDate) = @intYear AND DATEPART(QQ, dtmPayDate) = @intQuarter AND ysnVoid = 0) E2,
				 (SELECT dblTotal = SUM(dblTotal) FROM vyuPRPaycheckDeduction WHERE strDeductFrom = 'Gross Pay' AND ysnSSTaxable = 1  AND YEAR(dtmPayDate) = @intYear AND DATEPART(QQ, dtmPayDate) = @intQuarter AND ysnVoid = 0) D2
			 ) TIPS,
			 (SELECT dblTotal = ISNULL(E.dblTotal, 0) - ISNULL(D.dblTotal, 0) FROM 
				(SELECT dblTotal = SUM(dblTotal) FROM vyuPRPaycheckEarning WHERE ysnMedTaxable = 1 AND YEAR(dtmPayDate) = @intYear AND DATEPART(QQ, dtmPayDate) = @intQuarter AND ysnVoid = 0) E,
				(SELECT dblTotal = SUM(dblTotal) FROM vyuPRPaycheckDeduction WHERE strDeductFrom = 'Gross Pay' AND ysnMedTaxable = 1  AND YEAR(dtmPayDate) = @intYear AND DATEPART(QQ, dtmPayDate) = @intQuarter AND ysnVoid = 0) D) TXBLMED, 
			 (SELECT dblTotal = SUM(dblTotal) FROM vyuPRPaycheckDeduction WHERE strDeductFrom = 'Gross Pay'
				  AND YEAR(dtmPayDate) = @intYear AND DATEPART(QQ, dtmPayDate) = @intQuarter AND ysnVoid = 0) PRETAX,
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