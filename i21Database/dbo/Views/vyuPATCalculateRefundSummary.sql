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
			dblCashRefund = CASE WHEN SUM(Total.dblRefundAmount) >= ComPref.dblMinimumRefund THEN SUM(Total.dblCashRefund) ELSE 0 END,
			dblEquityRefund = CASE WHEN SUM(Total.dblRefundAmount) >= ComPref.dblMinimumRefund THEN 
								(CASE WHEN (SUM(Total.dblRefundAmount) - SUM(Total.dblCashRefund)) <= 0 THEN 0 
									ELSE (SUM(Total.dblRefundAmount) - SUM(Total.dblCashRefund)) END)
								ELSE 0 END
			FROM (SELECT	B.intCustomerPatronId AS intCustomerId,
							RR.intRefundTypeId,
							B.intFiscalYear,
							dblVolume = B.dblVolume,
							dblRefundAmount = ROUND(RRD.dblRate * dblVolume,2),
							dblCashRefund = ROUND((RRD.dblRate * dblVolume) * (RR.dblCashPayout/100),2)
				FROM tblPATCustomerVolume B
				INNER JOIN tblPATRefundRateDetail RRD
						ON RRD.intPatronageCategoryId = B.intPatronageCategoryId 
				INNER JOIN tblPATRefundRate RR
						ON RR.intRefundTypeId = RRD.intRefundTypeId
				INNER JOIN tblARCustomer AC
						ON AC.intEntityCustomerId = B.intCustomerPatronId
				WHERE B.intCustomerPatronId = B.intCustomerPatronId AND B.intFiscalYear = B.intFiscalYear AND B.ysnRefundProcessed <> 1 AND B.dblVolume <> 0
					) Total
			INNER JOIN tblPATRefundRate RR
					ON RR.intRefundTypeId = Total.intRefundTypeId
			INNER JOIN tblARCustomer AC
					ON AC.intEntityCustomerId = Total.intCustomerId
			CROSS APPLY tblPATCompanyPreference ComPref
			GROUP BY RR.intRefundTypeId,
			RR.strRefundType,
			Total.intCustomerId,
			AC.strStockStatus,
			Total.intFiscalYear,
			RR.strRefundDescription,
			RR.dblCashPayout,
			RR.ysnQualified,
			ComPref.dblMinimumRefund
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
	FROM (SELECT	intRefundTypeId,
					intCustomerId,
					strRefundType,
					strStockStatus,
					intFiscalYearId,
					strRefundDescription,
					dblCashPayout,
					ysnQualified,
					dblVolume = SUM(dblVolume),
					dblRefundAmount = SUM(dblRefundAmount),
					dblNonRefundAmount = SUM(dblNonRefundAmount),
					dblCashRefund = CASE WHEN SUM(dblCashRefund) <= ComPref.dblCutoffAmount THEN 
										(CASE WHEN ComPref.strCutoffTo = 'Cash' THEN SUM(dblCashRefund) + SUM(dblEquityRefund) ELSE 0 END)
									ELSE SUM(dblCashRefund) END,
					dblEquityRefund = CASE WHEN SUM(dblCashRefund) <= ComPref.dblCutoffAmount THEN 
										(CASE WHEN ComPref.strCutoffTo = 'Equity' THEN SUM(dblCashRefund) + SUM(dblEquityRefund) ELSE 0 END)
									ELSE SUM(dblCashRefund) END
			FROM Refunds
			CROSS APPLY tblPATCompanyPreference ComPref
			GROUP BY	intRefundTypeId,
						intCustomerId,
						ComPref.strCutoffTo,
						ComPref.dblCutoffAmount,
						strRefundType,
						strStockStatus,
						intFiscalYearId,
						strRefundDescription,
						dblCashPayout,
						ysnQualified
		) CalculatedRefunds
		GROUP BY	intRefundTypeId,
					strRefundType,
					strStockStatus,
					intFiscalYearId,
					strRefundDescription,
					dblCashPayout,
					ysnQualified