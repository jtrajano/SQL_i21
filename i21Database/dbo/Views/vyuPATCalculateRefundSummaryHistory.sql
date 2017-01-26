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
			RCatPCat.dblVolume,
			dblRefundAmount = CASE WHEN RCus.ysnEligibleRefund = 1 THEN (RCatPCat.dblRefundRate * RCatPCat.dblVolume) ELSE 0 END,
			dblNonRefundAmount = CASE WHEN RCus.ysnEligibleRefund = 1 THEN 0 ELSE (RCatPCat.dblRefundRate * RCatPCat.dblVolume) END,
			dblCashRefund = CASE WHEN RCus.ysnEligibleRefund = 1 THEN (RCatPCat.dblRefundRate * RCatPCat.dblVolume) * (RR.dblCashPayout/100) ELSE 0 END,
			dblEquityRefund = CASE WHEN RCus.ysnEligibleRefund = 1 THEN (RCatPCat.dblRefundRate * RCatPCat.dblVolume) - (RCatPCat.dblRefundRate * RCatPCat.dblVolume) * (RR.dblCashPayout/100) ELSE 0 END
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
		dblVolume = SUM(dblVolume),
		dblRefundAmount = SUM(ROUND(dblRefundAmount,2)),
		dblNonRefundAmount  = SUM(ROUND(dblNonRefundAmount,2)),
		dblCashRefund = SUM(ROUND(dblCashRefund,2)),
		dblEquityRefund = SUM(ROUND(dblEquityRefund,2))
FROM Refund
GROUP BY intRefundId,
		intFiscalYearId,
		strStockStatus,
		intRefundTypeId,
		strRefundType,
		strRefundDescription,
		dblCashPayout,
		ysnQualified