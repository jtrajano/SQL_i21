CREATE VIEW [dbo].[vyuPATCalculateNoRefundSummary]
	AS
WITH ComPref AS(
	SELECT TOP(1)
	dblMinimumRefund
	FROM tblPATCompanyPreference
), Refunds AS (
	SELECT	Total.intCustomerId,
			ENT.strEntityNo,
			strCustomerName = ENT.strName,
			intFiscalYearId = Total.intFiscalYear,
			Total.intRefundTypeId,
			AC.strStockStatus,
			dblTotalPurchases = Total.dblTotalPurchases,
			dblTotalSales = Total.dblTotalSales,
			dblRefundAmount = Total.dblRefundAmount,
			dblEquityRefund = CASE WHEN (Total.dblRefundAmount - Total.dblCashRefund) < 0 THEN 0 ELSE Total.dblRefundAmount - Total.dblCashRefund END 
		FROM (
			SELECT  intCustomerId = B.intCustomerPatronId,
					B.intFiscalYear,
					RR.intRefundTypeId,
					dblTotalPurchases = CASE WHEN PC.strPurchaseSale = 'Purchase' THEN B.dblVolume ELSE 0 END,
					dblTotalSales = CASE WHEN PC.strPurchaseSale = 'Sale' THEN B.dblVolume ELSE 0 END,
					dblRefundAmount = ROUND(RRD.dblRate * B.dblVolume,2),
					dblCashRefund = ROUND((RRD.dblRate * B.dblVolume) * (RR.dblCashPayout/100),2)
				FROM tblPATCustomerVolume B
			INNER JOIN tblPATRefundRateDetail RRD
					ON RRD.intPatronageCategoryId = B.intPatronageCategoryId 
			INNER JOIN tblPATRefundRate RR
					ON RR.intRefundTypeId = RRD.intRefundTypeId
			INNER JOIN tblPATPatronageCategory PC
					ON PC.intPatronageCategoryId = RRD.intPatronageCategoryId
			CROSS APPLY ComPref
				WHERE B.intCustomerPatronId = B.intCustomerPatronId AND B.ysnRefundProcessed <> 1 AND B.dblVolume <> 0
		) Total
		INNER JOIN tblARCustomer AC
			ON AC.intEntityCustomerId = Total.intCustomerId
		INNER JOIN tblEMEntity ENT
			ON ENT.intEntityId = Total.intCustomerId
)

SELECT	id = NEWID(),
		intCustomerId,
		strEntityNo,
		strCustomerName,
		intFiscalYearId,
		intRefundTypeId,
		strStockStatus,
		ysnEligibleRefund = CASE WHEN SUM(dblRefundAmount) < ComPref.dblMinimumRefund THEN CAST(0 AS BIT) ELSE CAST(1 AS BIT) END,
		dblTotalPurchases = SUM(dblTotalPurchases),
		dblTotalSales = SUM(dblTotalSales),
		dblRefundAmount = SUM(dblRefundAmount),
		dblEquityRefund = SUM(dblEquityRefund)
	FROM Refunds
	CROSS APPLY ComPref
	GROUP BY intCustomerId,
		strEntityNo,
		strCustomerName,
		intFiscalYearId,
		intRefundTypeId,
		strStockStatus,
		ComPref.dblMinimumRefund