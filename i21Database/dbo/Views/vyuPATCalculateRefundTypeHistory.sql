CREATE VIEW [dbo].[vyuPATCalculateRefundTypeHistory]
	AS
SELECT	NEWID() AS id,
		R.intRefundId,
		intCustomerId = RCus.intCustomerId,
		strCustomerName = EN.strName,
		R.intFiscalYearId,
		ysnEligibleRefund = (CASE WHEN RCus.dblRefundAmount >= R.dblMinimumRefund THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END),
		ARC.strStockStatus,
		TC.strTaxCode,
		RCus.intRefundTypeId,
		RR.strRefundType,
		RR.strRefundDescription,
		RCus.dblCashPayout,
		RR.ysnQualified,
		dtmLastActivityDate = R.dtmRefundDate,
		RCus.dblRefundAmount,
		RCus.dblCashRefund,
		dblEquityRefund = CASE WHEN RCus.dblEquityRefund < 0 THEN 0 ELSE RCus.dblEquityRefund END
	FROM tblPATRefundCustomer RCus
	INNER JOIN tblPATRefund R
		ON RCus.intRefundId = R.intRefundId
	INNER JOIN tblEMEntity EN
		ON EN.intEntityId = RCus.intCustomerId
	INNER JOIN tblARCustomer ARC
		ON ARC.[intEntityId] = RCus.intCustomerId
	INNER JOIN tblPATRefundRate RR
		ON RR.intRefundTypeId = RCus.intRefundTypeId
	LEFT JOIN tblSMTaxCode TC
		ON TC.intTaxCodeId = ARC.intTaxCodeId