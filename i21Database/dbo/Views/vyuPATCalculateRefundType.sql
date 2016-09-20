CREATE VIEW [dbo].[vyuPATCalculateRefundType]
	AS
SELECT DISTINCT intCustomerId = CV.intCustomerPatronId,
				NEWID() as id,
				CV.intFiscalYear,
				strCustomerName = ENT.strName,
				ysnEligibleRefund = CASE WHEN Total.dblRefundAmount >= (SELECT TOP(1) dblMinimumRefund FROM tblPATCompanyPreference) THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END,
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
				dblEquityRefund = Total.dblRefundAmount - Total.dblCashRefund
				FROM (
					SELECT	intCustomerId = B.intCustomerPatronId,
						(CASE WHEN RRD.dblRate * dblVolume <= (SELECT TOP(1) dblMinimumRefund FROM tblPATCompanyPreference) THEN 0 ELSE RRD.dblRate * dblVolume END) AS dblRefundAmount,
						(RRD.dblRate * dblVolume) * (RR.dblCashPayout/100) AS dblCashRefund,
						RRD.intPatronageCategoryId,
						B.intFiscalYear
						FROM tblPATCustomerVolume B
					INNER JOIN tblPATRefundRateDetail RRD
							ON RRD.intPatronageCategoryId = B.intPatronageCategoryId
					INNER JOIN tblPATRefundRate RR
							ON RR.intRefundTypeId = RRD.intRefundTypeId
					INNER JOIN tblARCustomer AC
							ON AC.intEntityCustomerId = B.intCustomerPatronId
					LEFT JOIN tblSMTaxCode TC
							ON TC.intTaxCodeId = AC.intTaxCodeId
					INNER JOIN tblEMEntity ENT
							ON ENT.intEntityId = B.intCustomerPatronId
					INNER JOIN tblPATPatronageCategory PC
							ON PC.intPatronageCategoryId = RRD.intPatronageCategoryId
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
			WHERE CV.dblVolume <> 0.00
		GROUP BY CV.intCustomerPatronId,
				ENT.strName,
				AC.strStockStatus,
				CV.intFiscalYear,
				RR.strRefundType, 
				RR.strRefundDescription, 
				RR.dblCashPayout,
				RR.ysnQualified, 
				RRD.intPatronageCategoryId, 
				CV.intPatronageCategoryId, 
				PC.intPatronageCategoryId, 
				TC.strTaxCode, 
				CV.dtmLastActivityDate,
				PC.strPurchaseSale,
				Total.dblCashRefund,
				Total.dblRefundAmount,
				RR.intRefundTypeId