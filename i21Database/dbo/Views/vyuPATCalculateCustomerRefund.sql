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
			dblRefundAmount = (RRD.dblRate * dblVolume) ,
			dblCashRefund = (RRD.dblRate * dblVolume) * (RR.dblCashPayout/100) ,
			dbLessFWT = (RRD.dblRate * dblVolume) * (RR.dblCashPayout/100) * (CompLoc.dblWithholdPercent/100) ,
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
			ON APV.intEntityVendorId = Total.intCustomerId
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
		dblTotalPurchases = SUM(ROUND(dblTotalPurchases, 2)),
		dblTotalSales = SUM(ROUND(dblTotalSales, 2)),
		dblRefundAmount = SUM(ROUND(dblRefundAmount, 2)),
		dblEquityRefund = SUM(ROUND(dblEquityRefund, 2)),
		dblCashRefund = SUM(ROUND(dblCashRefund, 2)),
		dblLessFWT = SUM(ROUND(dblLessFWT, 2)),
		dblLessServiceFee,
		dblCheckAmount = SUM(ROUND(dblCashRefund, 2)) - SUM(ROUND(dblLessFWT, 2)) - dblLessServiceFee
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