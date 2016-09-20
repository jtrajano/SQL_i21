CREATE VIEW [dbo].[vyuPATCalculateCustomerRefund]
	AS
WITH ComPref AS (
	SELECT TOP(1)
	1 AS intJoiner,
	strRefund,
	dblMinimumRefund,
	dblServiceFee,
	dblCutoffAmount,
	dblFederalBackup
	FROM tblPATCompanyPreference
)

SELECT DISTINCT intCustomerId = CV.intCustomerPatronId,
				NEWID() as id,
				CV.intFiscalYear,
				strCustomerName = ENT.strName,
				strStockStatus = AC.strStockStatus,
				dtmLastActivityDate = CV.dtmLastActivityDate,
				TC.strTaxCode,
				ysnEligibleRefund = CASE WHEN Total.dblRefundAmount >= ComPref.dblMinimumRefund THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END,
				dblTotalPurchases = Total.dblTotalPurchases,
				dblTotalSales = Total.dblTotalSales,
				dblRefundAmount = Total.dblRefundAmount,
				dblEquityRefund = CASE WHEN (Total.dblRefundAmount - Total.dblCashRefund) < 0 THEN 0 ELSE Total.dblRefundAmount - Total.dblCashRefund END,
				dblCashRefund = Total.dblCashRefund,
				dbLessFWT = CASE WHEN AC.ysnSubjectToFWT = 0 THEN 0 ELSE Total.dbLessFWT END,
				dblLessServiceFee = Total.dblCashRefund * (Total.dblLessServiceFee/100),
				dblCheckAmount =  CASE WHEN (Total.dblCashRefund - (CASE WHEN AC.ysnSubjectToFWT = 0 THEN 0 ELSE Total.dbLessFWT END) - (Total.dblCashRefund * (Total.dblLessServiceFee/100)) < 0) THEN 0 ELSE Total.dblCashRefund - (CASE WHEN AC.ysnSubjectToFWT = 0 THEN 0 ELSE Total.dbLessFWT END) - (Total.dblCashRefund * (Total.dblLessServiceFee/100)) END,
				dblTotalVolume = Total.dblVolume,
				dblTotalRefund = Total.dblTotalRefund
				FROM (
					SELECT	B.intCustomerPatronId as intCustomerId,
							dblTotalPurchases = CASE WHEN PC.strPurchaseSale = 'Purchase' THEN dblVolume ELSE 0 END,
							dblTotalSales = CASE WHEN PC.strPurchaseSale = 'Sale' THEN dblVolume ELSE 0 END,
							(CASE WHEN (RRD.dblRate * dblVolume) <= ComPref.dblMinimumRefund THEN 0 ELSE (RRD.dblRate * dblVolume) END) AS dblRefundAmount,
							(RRD.dblRate * dblVolume) * (RR.dblCashPayout/100) AS dblCashRefund,
							(RRD.dblRate * dblVolume) * (RR.dblCashPayout/100) * (ComPref.dblFederalBackup/100) AS dbLessFWT,
							ComPref.dblServiceFee AS dblLessServiceFee,
							dblVolume = dblVolume,
							dblTotalRefund = RRD.dblRate,
							B.intFiscalYear
					FROM tblPATCustomerVolume B
					INNER JOIN tblPATRefundRateDetail RRD
						ON RRD.intPatronageCategoryId = B.intPatronageCategoryId 
					INNER JOIN tblPATRefundRate RR
						ON RR.intRefundTypeId = RRD.intRefundTypeId
					INNER JOIN tblPATPatronageCategory PC
						ON PC.intPatronageCategoryId = RRD.intPatronageCategoryId
					INNER JOIN ComPref
						ON ComPref.intJoiner = 1
				) Total
		INNER JOIN tblPATCustomerVolume CV
			ON CV.intCustomerPatronId = Total.intCustomerId AND CV.intFiscalYear = Total.intFiscalYear
		INNER JOIN tblPATRefundRateDetail RRD
				ON RRD.intPatronageCategoryId = CV.intPatronageCategoryId 
		INNER JOIN tblPATRefundRate RR
				ON RR.intRefundTypeId = RRD.intRefundTypeId
		INNER JOIN tblARCustomer AC
				ON AC.intEntityCustomerId = CV.intCustomerPatronId
		LEFT JOIN tblSMTaxCode TC
				ON TC.intTaxCodeId = AC.intTaxCodeId
		INNER JOIN tblEMEntity ENT
				ON ENT.intEntityId = CV.intCustomerPatronId
		INNER JOIN tblPATPatronageCategory PC
				ON PC.intPatronageCategoryId = RRD.intPatronageCategoryId
		INNER JOIN ComPref
				ON ComPref.intJoiner = 1
		WHERE CV.dblVolume <> 0.00