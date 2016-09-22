CREATE VIEW [dbo].[vyuPATCalculateFiscalSummaryHistory]
	AS
WITH FiscalSum AS(
	SELECT	R.intFiscalYearId,
			dblVolume = SUM(RCat.dblVolume),
			dblRefundAmount = RC.dblRefundAmount,
			dblNonRefundAmount = CASE WHEN RC.dblRefundAmount >= R.dblMinimumRefund THEN 0 ELSE RC.dblRefundAmount END,
			dblCashRefund = RC.dblCashRefund,
			dblLessFWT = CASE WHEN AC.ysnSubjectToFWT = 1 THEN RC.dblCashRefund * (R.dblFedWithholdingPercentage/100) ELSE 0 END,
			dblLessServiceFee =  RC.dblCashRefund * (R.dblServiceFee/100),
			dblCheckAmount = CASE WHEN AC.ysnSubjectToFWT = 1 THEN
					(RC.dblCashRefund) - (RC.dblCashRefund * (R.dblFedWithholdingPercentage/100)) - (RC.dblCashRefund * (R.dblServiceFee/100.0))
					ELSE
					(RC.dblCashRefund) - (RC.dblCashRefund * (R.dblServiceFee/100.0))
					END,
			dblEquityRefund = RC.dblEquityRefund,
			intVoting = [dbo].[fnPATCountStockStatus]('Voting', R.intRefundId),
			intNonVoting = [dbo].[fnPATCountStockStatus]('Non-Voting', R.intRefundId),
			intProducers = [dbo].[fnPATCountStockStatus]('Producer', R.intRefundId),
			intOthers = [dbo].[fnPATCountStockStatus]('Other', R.intRefundId)
	FROM tblPATRefundCustomer RC
	INNER JOIN tblPATRefund R
		ON R.intRefundId = RC.intRefundId
	INNER JOIN tblPATRefundCategory RCat
		ON RCat.intRefundCustomerId = RC.intRefundCustomerId
	INNER JOIN tblARCustomer AC
		ON AC.intEntityCustomerId = RC.intCustomerId
	GROUP BY R.intRefundId, AC.ysnSubjectToFWT, R.intFiscalYearId, RC.dblRefundAmount, R.dblMinimumRefund, RC.dblCashRefund, R.dblFedWithholdingPercentage, R.dblServiceFee, RC.dblEquityRefund
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