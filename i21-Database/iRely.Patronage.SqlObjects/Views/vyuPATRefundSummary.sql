CREATE VIEW [dbo].[vyuPATRefundSummary]
	AS
WITH Refunds AS(
SELECT	R.intRefundId,
		R.strRefundNo,
		R.intFiscalYearId,
		RC.intRefundTypeId,
		RC.intCustomerId,
		F.strFiscalYear,
		dblTotalPurchases = SUM(RC.dblTotalPurchases),
		dblTotalSales = SUM(RC.dblTotalSales),
		dblLessFWT = SUM(RC.dblLessFWT),
		dblTotalCashRefund = SUM(RC.dblCashRefund),
		dblLessServiceFee = SUM(RC.dblLessServiceFee),
		dblCheckAmount = SUM(RC.dblCheckAmount),
		dblTotalVolume = SUM(RC.dblTotalPurchases + RC.dblTotalSales),
		dblTotalRefund = SUM(RC.dblRefundAmount),
		R.dtmRefundDate,
        R.dblMinimumRefund,
        R.dblServiceFee,
        R.dblCashCutoffAmount,
        R.dblFedWithholdingPercentage,
        R.strDescription,
        R.ysnPosted,
        R.ysnPrinted,
        R.intConcurrencyId
FROM tblPATRefund R
LEFT OUTER JOIN vyuPATRefundCustomer RC
	ON RC.intRefundId = R.intRefundId
LEFT OUTER JOIN tblGLFiscalYear F
	ON F.intFiscalYearId = R.intFiscalYearId
LEFT OUTER JOIN tblARCustomer C
	ON C.[intEntityId] = RC.intCustomerId
LEFT OUTER JOIN tblAPVendor APV
	ON APV.[intEntityId] = RC.intCustomerId
GROUP BY R.intRefundId,
		R.strRefundNo,
		R.intFiscalYearId,
		RC.intCustomerId,
		RC.ysnEligibleRefund,
		RC.intRefundTypeId,
		F.strFiscalYear,
		R.dtmRefundDate,
        R.dblMinimumRefund,
        R.dblServiceFee,
        R.dblCashCutoffAmount,
        R.dblFedWithholdingPercentage,
        R.strDescription,
        R.ysnPosted,
        R.ysnPrinted,
        R.intConcurrencyId
)
SELECT	intRefundId,
		strRefundNo,
		intFiscalYearId,
		strFiscalYear,
		dblTotalPurchases = SUM(dblTotalPurchases),
		dblTotalSales = SUM(dblTotalSales),
		dblTotalLessFWT = SUM(dblLessFWT),
		dblTotalLessServiceFee = SUM(dblLessServiceFee),
		dblTotalCashRefund = SUM(dblTotalCashRefund),
		dblTotalCheckAmount = SUM(CASE WHEN dblCheckAmount > 0 THEN dblCheckAmount ELSE 0 END),
		dblTotalVolume = SUM(dblTotalVolume),
		dblTotalRefund = SUM(dblTotalRefund),
		dtmRefundDate,
		dblMinimumRefund,
		dblServiceFee,
		dblCashCutoffAmount,
		dblFedWithholdingPercentage,
		strDescription,
		ysnPosted,
		ysnPrinted,
		intConcurrencyId
FROM Refunds
GROUP BY	intRefundId,
			strRefundNo,
			intFiscalYearId,
			strFiscalYear,
			dtmRefundDate,
			dblMinimumRefund,
			dblServiceFee,
			dblCashCutoffAmount,
			dblFedWithholdingPercentage,
			strDescription,
			ysnPosted,
			ysnPrinted,
			intConcurrencyId