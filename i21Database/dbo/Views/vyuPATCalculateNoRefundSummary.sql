CREATE VIEW [dbo].[vyuPATCalculateNoRefundSummary]
	AS
WITH ComPref AS(
	SELECT TOP(1)
	dblMinimumRefund
	FROM tblPATCompanyPreference
)
SELECT	NEWID() AS id,
		intCustomerId = CV.intCustomerPatronId,
		strCustomerName = ENT.strName,
		intFiscalYearId = CV.intFiscalYear,
		AC.strStockStatus,
		dblTotalPurchases = Total.dblTotalPurchases,
		dblTotalSales = Total.dblTotalSales,
		dblRefundAmount = Total.dblRefundAmount,
		dblEquityRefund = Total.dblRefundAmount - Total.dblCashRefund
	FROM tblPATCustomerVolume CV
	INNER JOIN tblARCustomer AC
		ON AC.intEntityCustomerId = CV.intCustomerPatronId
	INNER JOIN tblEMEntity ENT
		ON ENT.intEntityId = CV.intCustomerPatronId
	CROSS APPLY (
		SELECT  intCustomerId = B.intCustomerPatronId,
				dblTotalPurchases = CASE WHEN PC.strPurchaseSale = 'Purchase' THEN SUM(dblVolume) ELSE 0 END,
				dblTotalSales = CASE WHEN PC.strPurchaseSale = 'Sale' THEN SUM(dblVolume) ELSE 0 END,
				dblRefundAmount = CASE WHEN SUM(RRD.dblRate) * SUM(dblVolume) < ComPref.dblMinimumRefund THEN 0 ELSE SUM(RRD.dblRate) * SUM(dblVolume) END,
				dblCashRefund = ((SUM(RRD.dblRate) * SUM(dblVolume)) * (RR.dblCashPayout/100)) 
			FROM tblPATCustomerVolume B
		INNER JOIN tblPATRefundRateDetail RRD
				ON RRD.intPatronageCategoryId = CV.intPatronageCategoryId 
		INNER JOIN tblPATRefundRate RR
				ON RR.intRefundTypeId = RRD.intRefundTypeId
		INNER JOIN tblPATPatronageCategory PC
				ON PC.intPatronageCategoryId = RRD.intPatronageCategoryId
		CROSS APPLY ComPref
			WHERE B.intCustomerPatronId = CV.intCustomerPatronId
		GROUP BY B.intCustomerPatronId, PC.strPurchaseSale, RR.dblCashPayout, ComPref.dblMinimumRefund
	) Total
	GROUP BY CV.intCustomerPatronId, 
		ENT.strName, 
		AC.strStockStatus, 
		CV.intFiscalYear,
		CV.dblVolume, 
		CV.dtmLastActivityDate,
		Total.dblTotalPurchases,
		Total.dblTotalSales,
		Total.dblRefundAmount,
		Total.dblCashRefund