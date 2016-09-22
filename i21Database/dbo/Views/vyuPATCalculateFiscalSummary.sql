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
SELECT DISTINCT CV.intFiscalYear,
			dblVolume = Total.dblVolume,
			dblRefundAmount = Total.dblRefundAmount,
			dblNonRefundAmount = Total.dblNonRefundAmount,
			dblCashRefund = Total.dblCashRefund,
			dbLessFWT =	Total.dbLessFWT,
			dblLessServiceFee =  Total.dblCashRefund * (ComPref.dblServiceFee/100),
			dblCheckAmount =  CASE WHEN (Total.dblCashRefund - Total.dbLessFWT - (Total.dblCashRefund * (ComPref.dblServiceFee/100.0)) < 0) THEN 0 ELSE (Total.dblCashRefund) - (Total.dbLessFWT) - (Total.dblCashRefund * (ComPref.dblServiceFee/100.0)) END,
			dblEquityRefund = CASE WHEN (Total.dblRefundAmount - Total.dblCashRefund) < 0 THEN 0 ELSE Total.dblRefundAmount - Total.dblCashRefund END,
			intVoting = [dbo].[fnPATCountStockStatus]('Voting'),
			intNonVoting = [dbo].[fnPATCountStockStatus]('Non-Voting'),
			intProducers = [dbo].[fnPATCountStockStatus]('Producer'),
			intOthers = [dbo].[fnPATCountStockStatus]('Other')
		    FROM tblPATCustomerVolume CV
     INNER JOIN tblPATRefundRateDetail RRD
			 ON RRD.intPatronageCategoryId = CV.intPatronageCategoryId 
     INNER JOIN tblPATRefundRate RR
             ON RR.intRefundTypeId = RRD.intRefundTypeId
	 INNER JOIN tblARCustomer AC
			 ON AC.intEntityCustomerId = CV.intCustomerPatronId
	 CROSS APPLY ComPref
	 INNER JOIN (
			SELECT	intFiscalYear = B.intFiscalYear,
					dblVolume = ISNULL(B.dblVolume,0),
					dblRefundAmount = ISNULL((RRD.dblRate * dblVolume),0),
					dblNonRefundAmount = CASE WHEN ISNULL((RRD.dblRate * dblVolume),0) >= ComPref.dblMinimumRefund THEN 0 ELSE ISNULL((RRD.dblRate * dblVolume),0) END,
					dblCashRefund = ((RRD.dblRate * dblVolume) * (RR.dblCashPayout/100)),
					dbLessFWT = CASE WHEN AC.ysnSubjectToFWT = 1 THEN (((RRD.dblRate * dblVolume) * (RR.dblCashPayout/100)) * (ComPref.dblFederalBackup/100)) ELSE 0 END
			FROM tblPATCustomerVolume B
			INNER JOIN tblPATRefundRateDetail RRD
					ON RRD.intPatronageCategoryId = B.intPatronageCategoryId 
			INNER JOIN tblPATRefundRate RR
					ON RR.intRefundTypeId = RRD.intRefundTypeId
			INNER JOIN tblARCustomer AC
					ON AC.intEntityCustomerId = B.intCustomerPatronId
			CROSS APPLY ComPref
	 ) Total
	ON Total.intFiscalYear = CV.intFiscalYear
)

SELECT	intFiscalYear AS intFiscalYearId,
		dblVolume = SUM(dblVolume), 
		dblRefundAmount = SUM(dblRefundAmount),
		dblNonRefundAmount = SUM(dblNonRefundAmount),
		dblCashRefund = SUM(dblCashRefund),
		dbLessFWT = SUM(dbLessFWT),
		dblLessServiceFee = SUM(dblLessServiceFee),
		dblCheckAmount = SUM(dblCheckAmount),
		dblEquityRefund = SUM(dblEquityRefund),
		intVoting,
		intNonVoting,
		intProducers,
		intOthers
FROM FiscalSum
GROUP BY intFiscalYear, intVoting, intNonVoting, intProducers, intOthers