CREATE VIEW [dbo].[vyuPATCalculateCustomerRefund]
	AS
WITH ComPref AS (
	SELECT TOP(1)
	strRefund,
	dblMinimumRefund,
	dblServiceFee,
	dblCutoffAmount
	FROM tblPATCompanyPreference
), Refund AS (
SELECT	Total.intCustomerId,
		intFiscalYearId = Total.intFiscalYear,
		Total.intCompanyLocationId,
		Total.intRefundTypeId,
		strCustomerName = ENT.strName,
		strStockStatus = AC.strStockStatus,
		Total.dblCashPayout,
		AC.dtmLastActivityDate,
		TC.strTaxCode,
		dblTotalPurchases = Total.dblTotalPurchases,
		dblTotalSales = Total.dblTotalSales,
		dblRefundAmount = Total.dblRefundAmount,
		dblEquityRefund = CASE WHEN (Total.dblRefundAmount - Total.dblCashRefund) < 0 THEN 0 ELSE Total.dblRefundAmount - Total.dblCashRefund END,
		dblCashRefund = Total.dblCashRefund,
		dblLessFWT = CASE WHEN APV.ysnWithholding = 0 THEN 0 ELSE Total.dbLessFWT END,
		dblLessServiceFee = Total.dblLessServiceFee
		FROM (
			SELECT	B.intCustomerPatronId as intCustomerId,
			B.intFiscalYear,
			CompLoc.intCompanyLocationId,
			B.ysnRefundProcessed,
			RR.intRefundTypeId,
			RR.dblCashPayout,
			RRD.intPatronageCategoryId,
			dblTotalPurchases = CASE WHEN PC.strPurchaseSale = 'Purchase' THEN dblVolume ELSE 0 END,
			dblTotalSales = CASE WHEN PC.strPurchaseSale = 'Sale' THEN dblVolume ELSE 0 END,
			dblRefundAmount = ROUND((RRD.dblRate * dblVolume), 2) ,
			dblCashRefund = ROUND((RRD.dblRate * dblVolume) * (RR.dblCashPayout/100), 2) ,
			dbLessFWT = ROUND((RRD.dblRate * dblVolume) * (RR.dblCashPayout/100) * (CompLoc.dblWithholdPercent/100),2) ,
			dblLessServiceFee = ComPref.dblServiceFee
			FROM tblPATCustomerVolume B
			INNER JOIN tblPATRefundRateDetail RRD
				ON RRD.intPatronageCategoryId = B.intPatronageCategoryId 
			INNER JOIN tblPATRefundRate RR
				ON RR.intRefundTypeId = RRD.intRefundTypeId
			INNER JOIN tblPATPatronageCategory PC
				ON PC.intPatronageCategoryId = RRD.intPatronageCategoryId
			CROSS APPLY ComPref
			CROSS APPLY (SELECT intCompanyLocationId,dblWithholdPercent FROM tblSMCompanyLocation) CompLoc 
			WHERE B.ysnRefundProcessed <> 1 AND B.dblVolume <> 0
		) Total
	INNER JOIN tblARCustomer AC
			ON AC.intEntityCustomerId = Total.intCustomerId
	INNER JOIN tblAPVendor APV
			ON APV.[intEntityId] = Total.intCustomerId
	LEFT JOIN tblSMTaxCode TC
			ON TC.intTaxCodeId = AC.intTaxCodeId
	INNER JOIN tblEMEntity ENT
			ON ENT.intEntityId = Total.intCustomerId
)

SELECT	NEWID() AS id,
		intCustomerId,
		intFiscalYearId,
		intCompanyLocationId,
		intRefundTypeId,
		strCustomerName,
		strStockStatus,
		dblCashPayout,
		dtmLastActivityDate,
		strTaxCode,
		ysnEligibleRefund = CASE WHEN SUM(dblRefundAmount) >= ComPref.dblMinimumRefund THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END,
		dblTotalPurchases = SUM(dblTotalPurchases),
		dblTotalSales = SUM(dblTotalSales),
		dblRefundAmount = CASE WHEN SUM(dblRefundAmount) >= ComPref.dblMinimumRefund THEN SUM(dblRefundAmount) ELSE 0 END,
		dblNonRefundAmount = CASE WHEN SUM(dblRefundAmount) >= ComPref.dblMinimumRefund THEN 0 ELSE SUM(dblRefundAmount) END,
		dblEquityRefund = CASE WHEN SUM(dblRefundAmount) >= ComPref.dblMinimumRefund THEN SUM(dblEquityRefund) ELSE 0 END,
		dblCashRefund = CASE WHEN SUM(dblRefundAmount) >= ComPref.dblMinimumRefund THEN SUM(dblCashRefund) ELSE 0 END,
		dblLessFWT = CASE WHEN SUM(dblRefundAmount) >= ComPref.dblMinimumRefund THEN SUM(dblLessFWT) ELSE 0 END,
		dblLessServiceFee = CASE WHEN SUM(dblRefundAmount) >= ComPref.dblMinimumRefund THEN dblLessServiceFee ELSE 0 END,
		dblCheckAmount = CASE WHEN SUM(dblRefundAmount) >= ComPref.dblMinimumRefund THEN SUM(dblCashRefund) - SUM(dblLessFWT) - dblLessServiceFee ELSE 0 END
	FROM Refund
	CROSS APPLY ComPref
	GROUP BY	intCustomerId,
				intFiscalYearId,
				intCompanyLocationId,
				intRefundTypeId,
				strCustomerName,
				strStockStatus,
				dblCashPayout,
				dtmLastActivityDate,
				strTaxCode,
				ComPref.dblMinimumRefund,
				dblLessServiceFee