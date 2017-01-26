﻿CREATE VIEW [dbo].[vyuPATCalculateRefundType]
	AS
WITH ComPref AS(
	SELECT TOP(1) dblMinimumRefund = ISNULL(dblMinimumRefund,0) FROM tblPATCompanyPreference
), Refunds AS (
SELECT	Total.intCustomerId,
		intFiscalYearId = Total.intFiscalYear,
		strCustomerName = ENT.strName,
		AC.strStockStatus,
		TC.strTaxCode,
		RR.intRefundTypeId,
		RR.strRefundType,
		RR.strRefundDescription,
		RR.dblCashPayout,
		RR.ysnQualified,
		AC.dtmLastActivityDate,
		dblRefundAmount = Total.dblRefundAmount,
		dblCashRefund = Total.dblCashRefund,
		dblEquityRefund = CASE WHEN (Total.dblRefundAmount - Total.dblCashRefund) <= 0 THEN 0 ELSE (Total.dblRefundAmount - Total.dblCashRefund) END
		FROM (
			SELECT	intCustomerId = B.intCustomerPatronId,
				B.intFiscalYear,
				RR.intRefundTypeId,
				dblRefundAmount = RRD.dblRate * dblVolume,
				dblCashRefund = (RRD.dblRate * dblVolume) * (RR.dblCashPayout/100),
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
)

SELECT  id = NEWID(),
		intCustomerId,
		intFiscalYearId,
		strCustomerName,
		ysnEligibleRefund = CASE WHEN SUM(dblRefundAmount) >= ComPref.dblMinimumRefund THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END,
		strStockStatus,
		strTaxCode,
		intRefundTypeId,
		strRefundType,
		strRefundDescription,
		dblCashPayout,
		ysnQualified,
		dtmLastActivityDate,
		dblRefundAmount = SUM(ROUND(dblRefundAmount,2)),
		dblCashRefund = SUM(ROUND(dblCashRefund,2)),
		dblEquityRefund = SUM(ROUND(dblEquityRefund,2))
	FROM Refunds
	CROSS APPLY ComPref
	GROUP BY intCustomerId,
		intFiscalYearId,
		strCustomerName,
		strStockStatus,
		ComPref.dblMinimumRefund,
		strTaxCode,
		intRefundTypeId,
		strRefundType,
		strRefundDescription,
		dblCashPayout,
		ysnQualified,
		dtmLastActivityDate