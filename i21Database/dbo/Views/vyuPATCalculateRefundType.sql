CREATE VIEW [dbo].[vyuPATCalculateRefundType]
	AS
WITH ComPref AS(
	SELECT TOP(1) dblMinimumRefund = ISNULL(dblMinimumRefund,0) FROM tblPATCompanyPreference
)
SELECT	NEWID() AS id,
		Total.intCustomerId,
		intFiscalYearId = Total.intFiscalYear,
		strCustomerName = ENT.strName,
		ysnEligibleRefund = CASE WHEN Total.dblRefundAmount >= ComPref.dblMinimumRefund THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END,
		AC.strStockStatus,
		TC.strTaxCode,
		RR.intRefundTypeId,
		RR.strRefundType,
		RR.strRefundDescription,
		RR.dblCashPayout,
		RR.ysnQualified,
		Total.dtmLastActivityDate,
		dblRefundAmount = Total.dblRefundAmount,
		dblCashRefund = Total.dblCashRefund,
		dblEquityRefund = CASE WHEN (Total.dblRefundAmount - Total.dblCashRefund) <= 0 THEN 0 ELSE (Total.dblRefundAmount - Total.dblCashRefund) END
		FROM (
			SELECT	intCustomerId = B.intCustomerPatronId,
				B.dtmLastActivityDate,
				B.intFiscalYear,
				RR.intRefundTypeId,
				dblRefundAmount = CASE WHEN (RRD.dblRate * dblVolume) < ComPref.dblMinimumRefund THEN 0 ELSE (RRD.dblRate * dblVolume) END,
				dblCashRefund = CASE WHEN (RRD.dblRate * dblVolume) < ComPref.dblMinimumRefund THEN 0 ELSE (RRD.dblRate * dblVolume) * (RR.dblCashPayout/100) END,
				RRD.intPatronageCategoryId
				FROM tblPATCustomerVolume B
			INNER JOIN tblPATRefundRateDetail RRD
					ON RRD.intPatronageCategoryId = B.intPatronageCategoryId
			INNER JOIN tblPATRefundRate RR
					ON RR.intRefundTypeId = RRD.intRefundTypeId
			CROSS APPLY ComPref
			WHERE B.ysnRefundProcessed <> 1 AND B.dblVolume <> 0
		) Total
		INNER JOIN tblARCustomer AC
				ON AC.intEntityCustomerId = Total.intCustomerId
		LEFT JOIN tblSMTaxCode TC
				ON TC.intTaxCodeId = AC.intTaxCodeId
		INNER JOIN tblEMEntity ENT
				ON ENT.intEntityId = Total.intCustomerId
		INNER JOIN tblPATRefundRate RR
				ON RR.intRefundTypeId = Total.intRefundTypeId
		CROSS JOIN ComPref