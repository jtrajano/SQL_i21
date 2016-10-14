CREATE VIEW [dbo].[vyuPATCalculateRefundSummary]
	AS
WITH ComPref AS(
	SELECT TOP(1) dblMinimumRefund = ISNULL(dblMinimumRefund,0) FROM tblPATCompanyPreference
)
SELECT	NEWID() AS id,
		RR.intRefundTypeId,
		RR.strRefundType,
		AC.strStockStatus,
		intFiscalYearId = Total.intFiscalYear,
		RR.strRefundDescription,
		RR.dblCashPayout,
		RR.ysnQualified,
		ysnEligibleRefund = CAST(1 AS BIT),
		dblVolume = Total.dblVolume,
		dblRefundAmount = Total.dblRefundAmount ,
		dblNonRefundAmount = Total.dblNonRefundAmount,
		dblCashRefund = Total.dblCashRefund,
		dblEquityRefund = CASE WHEN (Total.dblRefundAmount - Total.dblCashRefund) <= 0 THEN 0 ELSE (Total.dblRefundAmount - Total.dblCashRefund) END
			FROM (SELECT	B.intCustomerPatronId AS intCustomerId,
							RR.intRefundTypeId,
							B.intFiscalYear,
							dblVolume = B.dblVolume,
							dblRefundAmount = (CASE WHEN (RRD.dblRate * B.dblVolume) <= ComPref.dblMinimumRefund THEN 0 ELSE (RRD.dblRate * dblVolume) END),
							dblNonRefundAmount = CASE WHEN ISNULL((RRD.dblRate * dblVolume),0) >= ComPref.dblMinimumRefund THEN 0 ELSE ISNULL((RRD.dblRate * dblVolume),0) END,
							dblCashRefund = CASE WHEN (RRD.dblRate * B.dblVolume) <= ComPref.dblMinimumRefund THEN 0 ELSE (RRD.dblRate * B.dblVolume) * (RR.dblCashPayout/100) END
				FROM tblPATCustomerVolume B
				INNER JOIN tblPATRefundRateDetail RRD
						ON RRD.intPatronageCategoryId = B.intPatronageCategoryId 
				INNER JOIN tblPATRefundRate RR
						ON RR.intRefundTypeId = RRD.intRefundTypeId
				INNER JOIN tblARCustomer AC
						ON AC.intEntityCustomerId = B.intCustomerPatronId
				CROSS APPLY ComPref
				WHERE B.intCustomerPatronId = B.intCustomerPatronId AND B.intFiscalYear = B.intFiscalYear AND B.ysnRefundProcessed <> 1 AND B.dblVolume <> 0
					) Total
		INNER JOIN tblPATRefundRate RR
				ON RR.intRefundTypeId = Total.intRefundTypeId
		INNER JOIN tblARCustomer AC
				ON AC.intEntityCustomerId = Total.intCustomerId