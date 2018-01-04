CREATE VIEW [dbo].[vyuPATCalculateRefundSummary]
	AS
WITH Refunds AS (
	SELECT	RR.intRefundTypeId,
			RR.strRefundType,
			Total.intCustomerId,
			AC.strStockStatus,
			intFiscalYearId = Total.intFiscalYear,
			RR.strRefundDescription,
			RR.dblCashPayout,
			RR.ysnQualified,
			dblVolume = SUM(Total.dblVolume),
			dblRefundAmount = CASE WHEN SUM(Total.dblRefundAmount) >= ComPref.dblMinimumRefund THEN SUM(Total.dblRefundAmount) ELSE 0 END,
			dblNonRefundAmount = CASE WHEN SUM(Total.dblRefundAmount) >= ComPref.dblMinimumRefund THEN 0 ELSE SUM(Total.dblRefundAmount) END,
			dblCashRefund = CASE WHEN SUM(Total.dblRefundAmount) >= ComPref.dblMinimumRefund THEN 
							(CASE WHEN SUM(Total.dblCashRefund) <= ComPref.dblCutoffAmount THEN 
								(CASE WHEN ComPref.strCutoffTo = 'Cash' THEN SUM(Total.dblCashRefund) + SUM(Total.dblRefundAmount - Total.dblCashRefund) ELSE 0 END)
							ELSE SUM(Total.dblCashRefund) END)ELSE 0 END,
			dblEquityRefund = CASE WHEN SUM(Total.dblRefundAmount) >= ComPref.dblMinimumRefund THEN 
							(CASE WHEN SUM(Total.dblCashRefund) <= ComPref.dblCutoffAmount THEN 
								(CASE WHEN ComPref.strCutoffTo = 'Equity' THEN SUM(Total.dblCashRefund) + SUM(Total.dblRefundAmount - Total.dblCashRefund) ELSE 0 END)
							ELSE SUM(Total.dblRefundAmount - Total.dblCashRefund) END)ELSE 0 END
			FROM (SELECT	B.intCustomerPatronId AS intCustomerId,
							RR.intRefundTypeId,
							B.intFiscalYear,
							dblVolume = SUM(B.dblVolume),
							dblRefundAmount = SUM(ROUND(RRD.dblRate * dblVolume,2)),
							dblCashRefund = SUM(ROUND((RRD.dblRate * dblVolume) * (RR.dblCashPayout/100),2))
				FROM tblPATCustomerVolume B
				INNER JOIN tblPATRefundRateDetail RRD
					ON RRD.intPatronageCategoryId = B.intPatronageCategoryId 
				INNER JOIN tblPATRefundRate RR
					ON RR.intRefundTypeId = RRD.intRefundTypeId
				INNER JOIN tblARCustomer AC
					ON AC.intEntityId = B.intCustomerPatronId
				WHERE B.intCustomerPatronId = B.intCustomerPatronId AND B.intFiscalYear = B.intFiscalYear AND B.ysnRefundProcessed <> 1 AND B.dblVolume <> 0
				GROUP BY B.intCustomerPatronId,
						 RR.intRefundTypeId,
						 B.intFiscalYear
				) Total
			INNER JOIN tblPATRefundRate RR
					ON RR.intRefundTypeId = Total.intRefundTypeId
			INNER JOIN tblARCustomer AC
					ON AC.intEntityId = Total.intCustomerId
			CROSS APPLY tblPATCompanyPreference ComPref
			GROUP BY RR.intRefundTypeId,
			RR.strRefundType,
			Total.intCustomerId,
			AC.strStockStatus,
			Total.intFiscalYear,
			RR.strRefundDescription,
			RR.dblCashPayout,
			RR.ysnQualified,
			ComPref.dblMinimumRefund,
			ComPref.dblCutoffAmount,
			ComPref.strCutoffTo
)
SELECT	id = NEWID(),
		intRefundTypeId,
		strRefundType,
		strStockStatus,
		intFiscalYearId,
		strRefundDescription,
		dblCashPayout,
		ysnQualified,
		dblVolume = SUM(dblVolume),
		dblRefundAmount = SUM(dblRefundAmount),
		dblNonRefundAmount = SUM(dblNonRefundAmount),
		dblCashRefund = SUM(dblCashRefund),
		dblEquityRefund = SUM(dblEquityRefund)
	FROM Refunds
	GROUP BY	intRefundTypeId,
				strRefundType,
				strStockStatus,
				intFiscalYearId,
				strRefundDescription,
				dblCashPayout,
				ysnQualified