CREATE VIEW [dbo].[vyuPATCalculateRefundSummary]
	AS
WITH ComPref AS(
	SELECT TOP(1) dblMinimumRefund = ISNULL(dblMinimumRefund,0) FROM tblPATCompanyPreference
)
SELECT	NEWID() AS id,
		RR.intRefundTypeId,
		RR.strRefundType,
		AC.strStockStatus,
		intFiscalYearId = CV.intFiscalYear,
		RR.strRefundDescription,
		RR.dblCashPayout,
		RR.ysnQualified,
		ysnEligibleRefund = CAST(1 AS BIT),
		dblVolume = Total.dblVolume,
		dblRefundAmount = Total.dblRefundAmount ,
		dblNonRefundAmount = Total.dblNonRefundAmount,
		dblCashRefund = Total.dblCashRefund,
		dblEquityRefund = CASE WHEN (Total.dblRefundAmount - Total.dblCashRefund) <= 0 THEN 0 ELSE (Total.dblRefundAmount - Total.dblCashRefund) END
			FROM tblPATCustomerVolume CV
		INNER JOIN tblPATRefundRateDetail RRD
				ON RRD.intPatronageCategoryId = CV.intPatronageCategoryId 
		INNER JOIN tblPATRefundRate RR
				ON RR.intRefundTypeId = RRD.intRefundTypeId
		INNER JOIN tblARCustomer AC
				ON AC.intEntityCustomerId = CV.intCustomerPatronId
		CROSS APPLY ComPref
		CROSS APPLY (
					SELECT DISTINCT B.intCustomerPatronId AS intCustomerId,
							dblVolume = SUM(B.dblVolume),
							dblRefundAmount = (CASE WHEN (RRD.dblRate * SUM(B.dblVolume)) <= ComPref.dblMinimumRefund THEN 0 ELSE (RRD.dblRate * SUM(dblVolume)) END),
							dblNonRefundAmount = CASE WHEN ISNULL((RRD.dblRate * dblVolume),0) >= ComPref.dblMinimumRefund THEN 0 ELSE ISNULL((RRD.dblRate * dblVolume),0) END,
							dblCashRefund = (RRD.dblRate * SUM(B.dblVolume)) * (RR.dblCashPayout/100)
					FROM tblPATCustomerVolume B
					INNER JOIN tblPATRefundRateDetail RRD
							ON RRD.intPatronageCategoryId = CV.intPatronageCategoryId 
					INNER JOIN tblPATRefundRate RR
							ON RR.intRefundTypeId = RRD.intRefundTypeId
					INNER JOIN tblARCustomer AC
							ON AC.intEntityCustomerId = CV.intCustomerPatronId
					CROSS APPLY ComPref
					WHERE B.intCustomerPatronId = CV.intCustomerPatronId AND B.intFiscalYear = CV.intFiscalYear AND B.ysnRefundProcessed <> 1
					GROUP BY B.intCustomerPatronId, B.dblVolume, AC.strStockStatus, RR.dblCashPayout, RRD.dblRate, ComPref.dblMinimumRefund
					) Total
		WHERE CV.ysnRefundProcessed <> 1
		GROUP BY CV.intCustomerPatronId, 
				AC.strStockStatus, 
				CV.intFiscalYear,
				RR.intRefundTypeId,
				RR.strRefundType, 
				RR.strRefundDescription, 
				RR.dblCashPayout, 
				RR.ysnQualified,
				RRD.dblRate, 
				Total.dblVolume,
				Total.dblRefundAmount,
				Total.dblNonRefundAmount,
				Total.dblCashRefund