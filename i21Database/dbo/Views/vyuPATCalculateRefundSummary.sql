﻿CREATE VIEW [dbo].[vyuPATCalculateRefundSummary]
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
			dblNonRefundAmount = CASE WHEN SUM(Total.dblRefundAmount) >= ComPref.dblMinimumRefund THEN 0 ELSE SUM(Total.dblRefundAmount) END
			FROM (SELECT	B.intCustomerPatronId AS intCustomerId,
							RR.intRefundTypeId,
							B.intFiscalYear,
							dblVolume = B.dblVolume,
							dblRefundAmount = RRD.dblRate * dblVolume
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
			CROSS APPLY (SELECT TOP 1 dblMinimumRefund FROM tblPATCompanyPreference) ComPref
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
		dblRefundAmount = SUM(ROUND(dblRefundAmount,2)),
		dblNonRefundAmount = SUM(ROUND(dblNonRefundAmount,2)),
		dblCashRefund = SUM(ROUND(dblRefundAmount * (dblCashPayout/100),2)),
		dblEquityRefund = SUM(ROUND(dblRefundAmount - (dblRefundAmount * (dblCashPayout/100)),2)) 
	FROM Refunds
	GROUP BY intRefundTypeId,
		strRefundType,
		strStockStatus,
		intFiscalYearId,
		strRefundDescription,
		dblCashPayout,
		ysnQualified