CREATE VIEW [dbo].[vyuPATCalculateFiscalSummaryHistory]
	AS
WITH FiscalSum AS(
	SELECT	R.intFiscalYearId,
			dblVolume = RC.dblVolume,
			dblRefundAmount = CASE WHEN RC.dblRefundAmount >= R.dblMinimumRefund THEN RC.dblRefundAmount ELSE 0 END,
			dblNonRefundAmount = CASE WHEN RC.dblRefundAmount >= R.dblMinimumRefund THEN 0 ELSE RC.dblRefundAmount END,
			dblCashRefund = CASE WHEN RC.dblRefundAmount >= R.dblMinimumRefund THEN RC.dblCashRefund ELSE 0 END,
			dblLessFWT = CASE WHEN RC.dblRefundAmount >= R.dblMinimumRefund THEN (CASE WHEN AC.ysnSubjectToFWT = 1  THEN RC.dblCashRefund * (R.dblFedWithholdingPercentage/100) ELSE 0 END) ELSE 0 END,
			dblLessServiceFee =  CASE WHEN RC.dblRefundAmount >= R.dblMinimumRefund THEN RC.dblCashRefund * (R.dblServiceFee/100) ELSE 0 END,
			dblCheckAmount = CASE WHEN RC.dblRefundAmount >= R.dblMinimumRefund THEN (CASE WHEN AC.ysnSubjectToFWT = 1 THEN
					(RC.dblCashRefund) - (RC.dblCashRefund * (R.dblFedWithholdingPercentage/100)) - (RC.dblCashRefund * (R.dblServiceFee/100.0))
					ELSE
					(RC.dblCashRefund) - (RC.dblCashRefund * (R.dblServiceFee/100.0))
					END) ELSE 0 END,
			dblEquityRefund = CASE WHEN RC.dblRefundAmount >= R.dblMinimumRefund THEN RC.dblRefundAmount - RC.dblCashRefund ELSE 0 END,
			intVoting = [dbo].[fnPATCountStockStatus]('Voting', R.intRefundId),
			intNonVoting = [dbo].[fnPATCountStockStatus]('Non-Voting', R.intRefundId),
			intProducers = [dbo].[fnPATCountStockStatus]('Producer', R.intRefundId),
			intOthers = [dbo].[fnPATCountStockStatus]('Other', R.intRefundId)
	FROM (SELECT intRefundId,
				RC.intRefundCustomerId,
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
)
SELECT	intFiscalYearId,
		dblVolume = SUM(dblVolume), 
		dblRefundAmount = SUM(dblRefundAmount),
		dblNonRefundAmount = SUM(dblNonRefundAmount),
		dblCashRefund = SUM(dblCashRefund),
		dbLessFWT = SUM(dblLessFWT),
		dblLessServiceFee = SUM(dblLessServiceFee),
		dblCheckAmount = SUM(dblCheckAmount),
		dblEquityRefund = SUM(dblEquityRefund),
		intVoting,
		intNonVoting,
		intProducers,
		intOthers
FROM FiscalSum
GROUP BY intFiscalYearId, intVoting, intNonVoting, intProducers, intOthers