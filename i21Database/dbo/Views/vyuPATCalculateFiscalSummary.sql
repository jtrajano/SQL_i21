CREATE VIEW [dbo].[vyuPATCalculateFiscalSummary]
	AS
WITH ComPref AS (
	SELECT TOP(1)
	strRefund,
	dblMinimumRefund,
	dblServiceFee,
	dblCutoffAmount,
	dblFederalBackup
	FROM tblPATCompanyPreference
),
FiscalSum AS (
SELECT DISTINCT Total.intFiscalYear,
			dblVolume = Total.dblVolume,
			dblRefundAmount = Total.dblRefundAmount,
			dblNonRefundAmount = Total.dblNonRefundAmount,
			dblCashRefund = Total.dblCashRefund,
			dblLessFWT = Total.dblLessFWT,
			dblLessServiceFee =  Total.dblCashRefund * (ComPref.dblServiceFee/100),
			dblCheckAmount =  CASE WHEN (Total.dblCashRefund - Total.dblLessFWT - (Total.dblCashRefund * (ComPref.dblServiceFee/100.0)) < 0) THEN 0 ELSE (Total.dblCashRefund) - (Total.dblLessFWT) - (Total.dblCashRefund * (ComPref.dblServiceFee/100.0)) END,
			dblEquityRefund = CASE WHEN (Total.dblRefundAmount - Total.dblCashRefund) < 0 THEN 0 ELSE Total.dblRefundAmount - Total.dblCashRefund END,
			intVoting = [dbo].[fnPATCountStockStatus]('Voting', default),
			intNonVoting = [dbo].[fnPATCountStockStatus]('Non-Voting', default),
			intProducers = [dbo].[fnPATCountStockStatus]('Producer', default),
			intOthers = [dbo].[fnPATCountStockStatus]('Other', default)
		    FROM (
				SELECT	B.intCustomerPatronId,
						B.intPatronageCategoryId,
						intFiscalYear = B.intFiscalYear,
						dblVolume = ISNULL(B.dblVolume,0),
						dblRefundAmount = CASE WHEN ISNULL((RRD.dblRate * B.dblVolume),0) >= ComPref.dblMinimumRefund THEN ISNULL((RRD.dblRate * B.dblVolume),0) ELSE 0 END,
						dblNonRefundAmount = CASE WHEN ISNULL((RRD.dblRate * B.dblVolume),0) >= ComPref.dblMinimumRefund THEN 0 ELSE ISNULL((RRD.dblRate * B.dblVolume),0) END,
						dblCashRefund = CASE WHEN ISNULL((RRD.dblRate * B.dblVolume),0) >= ComPref.dblMinimumRefund THEN ((RRD.dblRate * B.dblVolume) * (RR.dblCashPayout/100)) ELSE 0 END,
						dblLessFWT = CASE WHEN AC.ysnSubjectToFWT = 1 AND (RRD.dblRate * B.dblVolume) >= ComPref.dblMinimumRefund THEN (((RRD.dblRate * B.dblVolume) * (RR.dblCashPayout/100)) * (ComPref.dblFederalBackup/100)) ELSE 0 END
				FROM tblPATCustomerVolume B
				INNER JOIN tblPATRefundRateDetail RRD
						ON RRD.intPatronageCategoryId = B.intPatronageCategoryId 
				INNER JOIN tblPATRefundRate RR
						ON RR.intRefundTypeId = RRD.intRefundTypeId
				INNER JOIN tblARCustomer AC
						ON AC.intEntityCustomerId = B.intCustomerPatronId
				CROSS APPLY ComPref
				WHERE B.ysnRefundProcessed <> 1 AND B.dblVolume <> 0
			) Total
     INNER JOIN tblPATRefundRateDetail RRD
			 ON RRD.intPatronageCategoryId = Total.intPatronageCategoryId 
     INNER JOIN tblPATRefundRate RR
             ON RR.intRefundTypeId = RRD.intRefundTypeId
	 INNER JOIN tblARCustomer AC
			 ON AC.intEntityCustomerId = Total.intCustomerPatronId
	 CROSS APPLY ComPref
)

SELECT	intFiscalYear AS intFiscalYearId,
		dblVolume = SUM(dblVolume), 
		dblRefundAmount = SUM(dblRefundAmount),
		dblNonRefundAmount = SUM(dblNonRefundAmount),
		dblCashRefund = SUM(dblCashRefund),
		dblLessFWT = SUM(dblLessFWT),
		dblLessServiceFee = SUM(dblLessServiceFee),
		dblCheckAmount = SUM(dblCheckAmount),
		dblEquityRefund = SUM(dblEquityRefund),
		intVoting,
		intNonVoting,
		intProducers,
		intOthers
FROM FiscalSum
GROUP BY intFiscalYear, intVoting, intNonVoting, intProducers, intOthers