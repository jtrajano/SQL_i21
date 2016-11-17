CREATE VIEW [dbo].[vyuPATCalculateRefundSummaryHistory]
	AS
WITH Refund AS (
	SELECT	R.intRefundId,
			R.intFiscalYearId,
			ARC.strStockStatus,
			RCus.intRefundTypeId,
			RR.strRefundType,
			RR.strRefundDescription,
			RCus.dblCashPayout,
			RR.ysnQualified,
			ysnEligibleRefund = (CASE WHEN RCus.dblRefundAmount >= R.dblMinimumRefund THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END),
			RCatPCat.dblVolume,
			RCus.dblRefundAmount,
			dblNonRefundAmount = CASE WHEN (RCatPCat.dblRefundRate * RCatPCat.dblVolume) < R.dblMinimumRefund THEN (RCatPCat.dblRefundRate * RCatPCat.dblVolume) ELSE 0 END,
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
)

SELECT	NEWID() as id,
		intRefundId,
		intFiscalYearId,
		strStockStatus,
		intRefundTypeId,
		strRefundType,
		strRefundDescription,
		dblCashPayout,
		ysnQualified,
		ysnEligibleRefund,
		dblVolume = SUM(dblVolume),
		dblRefundAmount,
		dblNonRefundAmount,
		dblCashRefund,
		dblEquityRefund
FROM Refund
GROUP BY intRefundId,
		intFiscalYearId,
		strStockStatus,
		intRefundTypeId,
		strRefundType,
		strRefundDescription,
		dblCashPayout,
		ysnQualified,
		ysnEligibleRefund,
		dblRefundAmount,
		dblNonRefundAmount,
		dblCashRefund,
		dblEquityRefund