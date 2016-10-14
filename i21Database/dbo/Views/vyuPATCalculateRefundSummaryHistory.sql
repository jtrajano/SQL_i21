CREATE VIEW [dbo].[vyuPATCalculateRefundSummaryHistory]
	AS
WITH ComPref AS(
	SELECT TOP(1) dblMinimumRefund = ISNULL(dblMinimumRefund,0) FROM tblPATCompanyPreference
)
SELECT	NEWID() AS id,
		R.intRefundId,
		R.intFiscalYearId,
		ARC.strStockStatus,
		RCus.intRefundTypeId,
		RR.strRefundType,
		RR.strRefundDescription,
		RCus.dblCashPayout,
		RR.ysnQualified,
		ysnEligibleRefund = (CASE WHEN RCus.dblRefundAmount >= R.dblMinimumRefund THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END),
		RCatPCat.dblVolume,
		dblRefundAmount = RCus.dblRefundAmount ,
		dblNonRefundAmount = CASE WHEN (RCatPCat.dblRefundRate * RCatPCat.dblVolume) < ComPref.dblMinimumRefund THEN (RCatPCat.dblRefundRate * RCatPCat.dblVolume) ELSE 0 END,
		RCus.dblCashRefund,
		dblEquityRefund = CASE WHEN RCus.dblEquityRefund <= 0 THEN 0 ELSE RCus.dblEquityRefund END
	FROM tblPATRefundCustomer RCus
	INNER JOIN tblPATRefund R
		ON RCus.intRefundId = R.intRefundId
	INNER JOIN tblEMEntity EN
		ON EN.intEntityId = RCus.intCustomerId
	INNER JOIN tblARCustomer ARC
		ON ARC.intEntityCustomerId = RCus.intCustomerId
	INNER JOIN tblPATRefundCategory RCatPCat
		ON RCatPCat.intRefundCustomerId = RCus.intRefundCustomerId
	INNER JOIN tblPATRefundRate RR
		ON RR.intRefundTypeId = RCus.intRefundTypeId
	CROSS APPLY ComPref