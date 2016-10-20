CREATE VIEW [dbo].[vyuPATCalculateCustomerRefund]
	AS
WITH ComPref AS (
	SELECT TOP(1)
	strRefund,
	dblMinimumRefund,
	dblServiceFee,
	dblCutoffAmount
	FROM tblPATCompanyPreference
)

SELECT	Total.intCustomerId,
		NEWID() as id,
		intFiscalYearId = Total.intFiscalYear,
		Total.intCompanyLocationId,
		Total.intRefundTypeId,
		strCustomerName = ENT.strName,
		strStockStatus = AC.strStockStatus,
		Total.dblCashPayout,
		Total.dtmLastActivityDate,
		TC.strTaxCode,
		ysnEligibleRefund = CASE WHEN Total.dblRefundAmount >= ComPref.dblMinimumRefund THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END,
		dblTotalPurchases = Total.dblTotalPurchases,
		dblTotalSales = Total.dblTotalSales,
		dblRefundAmount = Total.dblRefundAmount,
		dblEquityRefund = CASE WHEN (Total.dblRefundAmount - Total.dblCashRefund) < 0 THEN 0 ELSE Total.dblRefundAmount - Total.dblCashRefund END,
		dblCashRefund = Total.dblCashRefund,
		dbLessFWT = CASE WHEN APV.ysnWithholding = 0 THEN 0 ELSE Total.dbLessFWT END,
		dblLessServiceFee = Total.dblCashRefund * (Total.dblLessServiceFee/100),
		dblCheckAmount =  CASE WHEN (Total.dblCashRefund - (CASE WHEN APV.ysnWithholding = 0 THEN 0 ELSE Total.dbLessFWT END) - (Total.dblCashRefund * (Total.dblLessServiceFee/100)) < 0) THEN 0 ELSE Total.dblCashRefund - (CASE WHEN APV.ysnWithholding = 0 THEN 0 ELSE Total.dbLessFWT END) - (Total.dblCashRefund * (Total.dblLessServiceFee/100)) END
		FROM (
			SELECT	B.intCustomerPatronId as intCustomerId,
			B.intFiscalYear,
			CompLoc.intCompanyLocationId,
			B.dtmLastActivityDate,
			B.ysnRefundProcessed,
			RR.intRefundTypeId,
			RR.dblCashPayout,
			RRD.intPatronageCategoryId,
			dblTotalPurchases = CASE WHEN PC.strPurchaseSale = 'Purchase' THEN dblVolume ELSE 0 END,
			dblTotalSales = CASE WHEN PC.strPurchaseSale = 'Sale' THEN dblVolume ELSE 0 END,
			dblRefundAmount = (CASE WHEN (RRD.dblRate * dblVolume) < ComPref.dblMinimumRefund THEN 0 ELSE (RRD.dblRate * dblVolume) END),
			dblCashRefund = CASE WHEN (RRD.dblRate * dblVolume) < ComPref.dblMinimumRefund THEN 0 ELSE (RRD.dblRate * dblVolume) * (RR.dblCashPayout/100) END,
			dbLessFWT = CASE WHEN (RRD.dblRate * dblVolume) < ComPref.dblMinimumRefund THEN 0 ELSE (RRD.dblRate * dblVolume) * (RR.dblCashPayout/100) * (CompLoc.dblWithholdPercent/100) END,
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
	CROSS APPLY ComPref