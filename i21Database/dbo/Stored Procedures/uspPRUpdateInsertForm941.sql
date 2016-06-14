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
			,ysnNoTaxable = CASE WHEN ((ISNULL(TXBLSS.dblTotal, 0) + ISNULL(TXBLSSTIPS.dblTotal, 0) + ISNULL(TXBLMED.dblTotal, 0)) <= 0) THEN 0 ELSE 1 END
			,dblTaxableSS = ISNULL(TXBLSS.dblTotal, 0)
			,dblTaxableSSTips = ISNULL(TXBLSSTIPS.dblTotal, 0)
			,dblTaxableMed = ISNULL(TXBLMED.dblTotal, 0)
			,dblTaxDueUnreported = 0
			,dblAdjustFractionCents = 0
			,dblAdjustSickPay = 0
			,dblAdjustTips = 0
			,dblTotalDeposit = 0
			,ysnRefundOverpayment = 0
			,intScheduleType = 1
			,dblMonth1 = (ISNULL(MONTH1.dblMonthTotalSS, 0) * 0.124) + (ISNULL(MONTH1.dblMonthTotalMed, 0) * 0.029) + (ISNULL(MONTH1.dblMonthTotalFIT, 0))
			,dblMonth2 = (ISNULL(MONTH2.dblMonthTotalSS, 0) * 0.124) + (ISNULL(MONTH2.dblMonthTotalMed, 0) * 0.029) + (ISNULL(MONTH2.dblMonthTotalFIT, 0))
			,dblMonth3 = (ISNULL(MONTH3.dblMonthTotalSS, 0) * 0.124) + (ISNULL(MONTH3.dblMonthTotalMed, 0) * 0.029) + (ISNULL(MONTH3.dblMonthTotalFIT, 0))
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
		FROM (SELECT dblTotal = SUM(dblTotal) FROM vyuPRPaycheckTax 
				WHERE YEAR(dtmPayDate) = @intYear AND DATEPART(QQ, dtmPayDate) = @intQuarter AND strCalculationType = 'USA Federal Tax') FIT,
			 (SELECT dblMonthTotalSS = SUM(dblLiabilitySS) + SUM(dblTaxTotalSS), 
				     dblMonthTotalMed = SUM(dblLiabilityMed) + SUM(dblTaxTotalMed), dblMonthTotalFIT = SUM(dblFIT)
				FROM vyuPRMonthlyTaxTotal WHERE intYear = @intYear AND intQuarter = @intQuarter AND intMonth IN (1, 4, 7, 10)) MONTH1,
			 (SELECT dblMonthTotalSS = SUM(dblLiabilitySS) + SUM(dblTaxTotalSS), 
					 dblMonthTotalMed = SUM(dblLiabilityMed) + SUM(dblTaxTotalMed), dblMonthTotalFIT = SUM(dblFIT)
				FROM vyuPRMonthlyTaxTotal WHERE intYear = @intYear AND intQuarter = @intQuarter AND intMonth IN (2, 5, 8, 11)) MONTH2,
			 (SELECT dblMonthTotalSS = SUM(dblLiabilitySS) + SUM(dblTaxTotalSS), 
					 dblMonthTotalMed = SUM(dblLiabilityMed) + SUM(dblTaxTotalMed), dblMonthTotalFIT = SUM(dblFIT)
				FROM vyuPRMonthlyTaxTotal WHERE intYear = @intYear AND intQuarter = @intQuarter AND intMonth IN (3, 6, 9, 12)) MONTH3,
			 (SELECT dblTotal = SUM(dblTotal) FROM vyuPRPaycheckEarning WHERE strCalculationType <> 'Tip' AND ysnSSTaxable = 1
				  AND YEAR(dtmPayDate) = @intYear AND DATEPART(QQ, dtmPayDate) = @intQuarter) TXBLSS,
			 (SELECT dblTotal = SUM(dblTotal) FROM vyuPRPaycheckEarning WHERE strCalculationType = 'Tip' AND ysnSSTaxable = 1
				  AND YEAR(dtmPayDate) = @intYear AND DATEPART(QQ, dtmPayDate) = @intQuarter) TXBLSSTIPS,
			 (SELECT dblTotal = SUM(dblTotal) FROM vyuPRPaycheckEarning WHERE ysnMedTaxable = 1
				  AND YEAR(dtmPayDate) = @intYear AND DATEPART(QQ, dtmPayDate) = @intQuarter) TXBLMED,
			 (SELECT intEmployees = COUNT(DISTINCT intEntityEmployeeId),
					 dblGrossSum = SUM(dblGross) 
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
			,ysnNoTaxable = CASE WHEN ((ISNULL(TXBLSS.dblTotal, 0) + ISNULL(TXBLMED.dblTotal, 0) + ISNULL(TXBLSSTIPS.dblTotal, 0)) <= 0) THEN 0 ELSE 1 END
			,dblAdjustedGross = ISNULL(PCHK.dblGrossSum, 0)
			,dblFIT = ISNULL(FIT.dblTotal, 0)
			,dblTaxableSS = CONVERT(NUMERIC(18,2), ISNULL(TXBLSS.dblTotal, 0))
			,dblTaxableSSTips = CONVERT(NUMERIC(18,2), ISNULL(TXBLSSTIPS.dblTotal, 0))
			,dblTaxableMed = CONVERT(NUMERIC(18,2), ISNULL(TXBLMED.dblTotal, 0))
			,dblMonth1 = (ISNULL(MONTH1.dblMonthTotalSS, 0) * 0.124) + (ISNULL(MONTH1.dblMonthTotalMed, 0) * 0.029) + (ISNULL(MONTH1.dblMonthTotalFIT, 0))
			,dblMonth2 = (ISNULL(MONTH2.dblMonthTotalSS, 0) * 0.124) + (ISNULL(MONTH2.dblMonthTotalMed, 0) * 0.029) + (ISNULL(MONTH2.dblMonthTotalFIT, 0))
			,dblMonth3 = (ISNULL(MONTH3.dblMonthTotalSS, 0) * 0.124) + (ISNULL(MONTH3.dblMonthTotalMed, 0) * 0.029) + (ISNULL(MONTH3.dblMonthTotalFIT, 0))
		FROM (SELECT dblTotal = SUM(dblFIT) FROM vyuPRMonthlyTaxTotal WHERE intYear = @intYear AND intQuarter = @intQuarter) FIT,
			 (SELECT dblMonthTotalSS = SUM(dblLiabilitySS) + SUM(dblTaxTotalSS), 
					 dblMonthTotalMed = SUM(dblLiabilityMed) + SUM(dblTaxTotalMed), dblMonthTotalFIT = SUM(dblFIT)
				FROM vyuPRMonthlyTaxTotal WHERE intYear = @intYear AND intQuarter = @intQuarter AND intMonth IN (1, 4, 7, 10)) MONTH1,
			 (SELECT dblMonthTotalSS = SUM(dblLiabilitySS) + SUM(dblTaxTotalSS), 
					 dblMonthTotalMed = SUM(dblLiabilityMed) + SUM(dblTaxTotalMed), dblMonthTotalFIT = SUM(dblFIT)
				FROM vyuPRMonthlyTaxTotal WHERE intYear = @intYear AND intQuarter = @intQuarter AND intMonth IN (2, 5, 8, 11)) MONTH2,
			 (SELECT dblMonthTotalSS = SUM(dblLiabilitySS) + SUM(dblTaxTotalSS), 
					 dblMonthTotalMed = SUM(dblLiabilityMed) + SUM(dblTaxTotalMed), dblMonthTotalFIT = SUM(dblFIT)
				FROM vyuPRMonthlyTaxTotal WHERE intYear = @intYear AND intQuarter = @intQuarter AND intMonth IN (3, 6, 9, 12)) MONTH3,
			 (SELECT dblTotal = SUM(dblTotal) FROM vyuPRPaycheckEarning WHERE strCalculationType <> 'Tip' AND ysnSSTaxable = 1
				  AND YEAR(dtmPayDate) = @intYear AND DATEPART(QQ, dtmPayDate) = @intQuarter) TXBLSS,
			 (SELECT dblTotal = SUM(dblTotal) FROM vyuPRPaycheckEarning WHERE strCalculationType = 'Tip' AND ysnSSTaxable = 1
				  AND YEAR(dtmPayDate) = @intYear AND DATEPART(QQ, dtmPayDate) = @intQuarter) TXBLSSTIPS,
			 (SELECT dblTotal = SUM(dblTotal) FROM vyuPRPaycheckEarning WHERE ysnMedTaxable = 1
				  AND YEAR(dtmPayDate) = @intYear AND DATEPART(QQ, dtmPayDate) = @intQuarter) TXBLMED,
			 (SELECT intEmployees = COUNT(DISTINCT intEntityEmployeeId),
					 dblGrossSum = SUM(dblGross) 
				FROM tblPRPaycheck 
				WHERE YEAR(dtmPayDate) = @intYear AND DATEPART(QQ, dtmPayDate) = @intQuarter AND ysnPosted = 1 AND ysnVoid = 0) PCHK
		WHERE intYear = @intYear AND intQuarter = @intQuarter

		/* Get the updated Form 941 Id */
		SELECT TOP 1 @intForm941Id = intForm941Id FROM tblPRForm941 WHERE intYear = @intYear AND intQuarter = @intQuarter
	END
END
GO