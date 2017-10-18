CREATE VIEW [dbo].[vyuPATCalculateFiscalSummaryHistory]
	AS
SELECT	R.intRefundId,
		R.intFiscalYearId,
		dblVolume = SUM(RC.dblTotalPurchases + RC.dblTotalSales),
		dblRefundAmount = SUM(RC.dblRefundAmount),
		dblNonRefundAmount = SUM(RC.dblNonRefundAmount),
		dblCashRefund = SUM(RC.dblCashRefund),
		dblLessFWT = SUM(RC.dblLessFWT),
		dblLessServiceFee = SUM(dblLessServiceFee),
		dblCheckAmount = SUM(RC.dblCheckAmount),
		dblEquityRefund = SUM(RC.dblEquityRefund),
		intVoting = [dbo].[fnPATCountStockStatus]('Voting', R.intRefundId, default),
		intNonVoting = [dbo].[fnPATCountStockStatus]('Non-Voting', R.intRefundId, default),
		intProducers = [dbo].[fnPATCountStockStatus]('Producer', R.intRefundId, default),
		intOthers = [dbo].[fnPATCountStockStatus]('Other', R.intRefundId, default)
FROM vyuPATRefundCustomer RC
INNER JOIN tblPATRefund R
	ON R.intRefundId = RC.intRefundId
GROUP BY R.intRefundId, R.intFiscalYearId
