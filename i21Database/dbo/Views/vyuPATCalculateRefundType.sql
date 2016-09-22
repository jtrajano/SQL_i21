CREATE VIEW [dbo].[vyuPATCalculateRefundType]
	AS
WITH ComPref AS(
	SELECT TOP(1) dblMinimumRefund = ISNULL(dblMinimumRefund,0) FROM tblPATCompanyPreference
)
SELECT	NEWID() AS id,
		intCustomerId = CV.intCustomerPatronId,
		intFiscalYearId = CV.intFiscalYear,
		strCustomerName = ENT.strName,
		ysnEligibleRefund = CASE WHEN Total.dblRefundAmount >= ComPref.dblMinimumRefund THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END,
		AC.strStockStatus,
		PC.strPurchaseSale,
		PC.intPatronageCategoryId,
		TC.strTaxCode,
		RR.intRefundTypeId,
		RR.strRefundType,
		RR.strRefundDescription,
		RR.dblCashPayout,
		RR.ysnQualified,
		dtmLastActivityDate = CV.dtmLastActivityDate,
		dblRefundAmount = Total.dblRefundAmount,
		dblCashRefund = Total.dblCashRefund,
		dblEquityRefund = CASE WHEN (Total.dblRefundAmount - Total.dblCashRefund) <= 0 THEN 0 ELSE (Total.dblRefundAmount - Total.dblCashRefund) END
		FROM (
			SELECT	intCustomerId = B.intCustomerPatronId,
				dblRefundAmount = (RRD.dblRate * dblVolume),
				dblCashRefund = CASE WHEN (RRD.dblRate * dblVolume) <= ComPref.dblMinimumRefund THEN 0 ELSE (RRD.dblRate * dblVolume) * (RR.dblCashPayout/100) END,
				RRD.intPatronageCategoryId,
				B.intFiscalYear
				FROM tblPATCustomerVolume B
			INNER JOIN tblPATRefundRateDetail RRD
					ON RRD.intPatronageCategoryId = B.intPatronageCategoryId
			INNER JOIN tblPATRefundRate RR
					ON RR.intRefundTypeId = RRD.intRefundTypeId
			CROSS APPLY ComPref
		) Total
		INNER JOIN tblPATCustomerVolume CV
			ON CV.intCustomerPatronId = Total.intCustomerId AND CV.intPatronageCategoryId = Total.intPatronageCategoryId AND CV.intFiscalYear = Total.intFiscalYear
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
		CROSS JOIN ComPref
			WHERE CV.dblVolume <> 0.00
		GROUP BY CV.intCustomerPatronId,
				ENT.strName,
				AC.strStockStatus,
				CV.intFiscalYear,
				RR.strRefundType, 
				RR.strRefundDescription, 
				PC.intPatronageCategoryId,
				RR.dblCashPayout,
				ComPref.dblMinimumRefund,
				RR.ysnQualified,
				TC.strTaxCode, 
				CV.dtmLastActivityDate,
				PC.strPurchaseSale,
				Total.dblCashRefund,
				Total.dblRefundAmount,
				RR.intRefundTypeId