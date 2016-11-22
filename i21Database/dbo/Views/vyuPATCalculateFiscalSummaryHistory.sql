﻿CREATE VIEW [dbo].[vyuPATCalculateFiscalSummaryHistory]
	AS
WITH FiscalSum AS(
	SELECT	R.intFiscalYearId,
			RC.intCustomerId,
			dblVolume = SUM(RC.dblVolume),
			dblRefundAmount = SUM(CASE WHEN RC.ysnEligibleRefund = 1 THEN RC.dblRefundAmount ELSE 0 END),
			dblNonRefundAmount = SUM(CASE WHEN RC.ysnEligibleRefund = 1 THEN 0 ELSE RC.dblRefundAmount END),
			dblCashRefund = SUM(CASE WHEN RC.ysnEligibleRefund = 1 THEN RC.dblCashRefund ELSE 0 END),
			dblLessFWT = SUM(CASE WHEN RC.ysnEligibleRefund = 1 THEN (CASE WHEN APV.ysnWithholding = 1 THEN RC.dblCashRefund * (R.dblFedWithholdingPercentage/100) ELSE 0 END) ELSE 0 END),
			dblLessServiceFee =  CASE WHEN RC.ysnEligibleRefund = 1 THEN R.dblServiceFee ELSE 0 END,
			dblCheckAmount = SUM (CASE WHEN RC.ysnEligibleRefund = 1 THEN (CASE WHEN APV.ysnWithholding = 1 THEN
					(RC.dblCashRefund) - (RC.dblCashRefund * (R.dblFedWithholdingPercentage/100))
					ELSE
					(RC.dblCashRefund)
					END) ELSE 0 END) - CASE WHEN RC.ysnEligibleRefund = 1 THEN R.dblServiceFee ELSE 0 END,
			dblEquityRefund = SUM(CASE WHEN RC.ysnEligibleRefund = 1 THEN RC.dblRefundAmount - RC.dblCashRefund ELSE 0 END),
			intVoting = [dbo].[fnPATCountStockStatus]('Voting', R.intRefundId),
			intNonVoting = [dbo].[fnPATCountStockStatus]('Non-Voting', R.intRefundId),
			intProducers = [dbo].[fnPATCountStockStatus]('Producer', R.intRefundId),
			intOthers = [dbo].[fnPATCountStockStatus]('Other', R.intRefundId)
	FROM (SELECT intRefundId,
				RC.intRefundCustomerId,
				RC.ysnEligibleRefund,
				intCustomerId,
				RCat.dblVolume,
				dblRefundAmount = RCat.dblVolume * RCat.dblRefundRate,
				dblCashRefund = (RCat.dblVolume * RCat.dblRefundRate) * (RC.dblCashPayout/100)
		FROM tblPATRefundCustomer RC
		INNER JOIN tblPATRefundCategory RCat
			ON RCat.intRefundCustomerId = RC.intRefundCustomerId) RC
	INNER JOIN tblPATRefund R
		ON R.intRefundId = RC.intRefundId
	INNER JOIN tblARCustomer AC
		ON AC.intEntityCustomerId = RC.intCustomerId
	INNER JOIN tblAPVendor APV
		ON APV.intEntityVendorId = RC.intCustomerId
	GROUP BY R.intFiscalYearId,
			RC.intCustomerId,
			RC.ysnEligibleRefund,
			R.dblServiceFee,
			R.intRefundId

)
SELECT	intFiscalYearId,
		dblVolume = SUM(dblVolume), 
		dblRefundAmount = SUM(dblRefundAmount),
		dblNonRefundAmount = SUM(dblNonRefundAmount),
		dblCashRefund = SUM(dblCashRefund),
		dblLessFWT = SUM(dblLessFWT),
		dblLessServiceFee = SUM(dblLessServiceFee),
		dblCheckAmount = SUM(dblCheckAmount),
		dblEquityRefund = SUM(dblEquityRefund),
		intVoting,
		intNonVoting,
		intProducers,
		intOthers
FROM FiscalSum
GROUP BY intFiscalYearId, intVoting, intNonVoting, intProducers, intOthers
