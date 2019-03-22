﻿CREATE VIEW [dbo].[vyuPATCalculateRefundSummaryHistory]
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
			dblRefundAmount = CASE WHEN RCus.ysnEligibleRefund = 1 THEN ROUND((RCatPCat.dblRefundRate * RCatPCat.dblVolume), 2) ELSE 0 END,
			dblNonRefundAmount = CASE WHEN RCus.ysnEligibleRefund = 1 THEN 0 ELSE ROUND((RCatPCat.dblRefundRate * RCatPCat.dblVolume), 2) END,
			dblCashRefund = CASE WHEN RCus.ysnEligibleRefund = 1 THEN RCus.dblCashRefund ELSE 0 END,
			dblEquityRefund = CASE WHEN RCus.ysnEligibleRefund = 1 THEN RCus.dblEquityRefund ELSE 0 END
		FROM tblPATRefundCustomer RCus
		INNER JOIN tblPATRefund R
			ON RCus.intRefundId = R.intRefundId
		INNER JOIN tblEMEntity EN
			ON EN.intEntityId = RCus.intCustomerId
		INNER JOIN tblARCustomer ARC
			ON ARC.[intEntityId] = RCus.intCustomerId
		INNER JOIN tblPATRefundCategory RCatPCat
			ON RCatPCat.intRefundCustomerId = RCus.intRefundCustomerId
		INNER JOIN tblPATRefundRate RR
			ON RR.intRefundTypeId = RCus.intRefundTypeId
)

SELECT	intRowId = ROW_NUMBER() OVER(ORDER BY intRefundTypeId),
		intRefundId,
		intFiscalYearId,
		strStockStatus,
		intRefundTypeId,
		strRefundType,
		strRefundDescription,
		dblCashPayout,
		ysnQualified,
		dblVolume = SUM(dblVolume),
		dblRefundAmount = SUM(dblRefundAmount),
		dblNonRefundAmount  = SUM(dblNonRefundAmount),
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
		dblCashRefund,
		dblEquityRefund,
		ysnQualified