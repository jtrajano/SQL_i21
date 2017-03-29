CREATE VIEW [dbo].[vyuPATRefundSummary]
	AS
WITH Refunds AS(
SELECT	R.intRefundId,
		R.strRefundNo,
		R.intFiscalYearId,
		RC.intRefundTypeId,
		RC.intCustomerId,
		F.strFiscalYear,
		dblTotalPurchases = SUM(CASE WHEN RC.strPurchaseSale = 'Purchase' THEN RC.dblVolume ELSE 0 END),
		dblTotalSales = SUM(CASE WHEN RC.strPurchaseSale = 'Sale' THEN RC.dblVolume ELSE 0 END),
		dblLessFWT = SUM(CASE WHEN RC.ysnEligibleRefund = 1 THEN (CASE WHEN APV.ysnWithholding = 1 THEN RC.dblCashRefund * (R.dblFedWithholdingPercentage/100) ELSE 0 END) ELSE 0 END),
		dblTotalCashRefund = SUM(CASE WHEN RC.ysnEligibleRefund = 1 THEN RC.dblCashRefund ELSE 0 END),
		dblLessServiceFee = CASE WHEN RC.ysnEligibleRefund = 1 THEN R.dblServiceFee ELSE 0 END,
		dblCheckAmount = SUM (CASE WHEN RC.ysnEligibleRefund = 1 THEN (CASE WHEN APV.ysnWithholding = 1 THEN
					(RC.dblCashRefund) - (RC.dblCashRefund * (R.dblFedWithholdingPercentage/100))
					ELSE
					(RC.dblCashRefund)
					END) ELSE 0 END) - CASE WHEN RC.ysnEligibleRefund = 1 THEN R.dblServiceFee ELSE 0 END,
		dblTotalVolume = SUM(RC.dblVolume),
		dblTotalRefund = SUM(CASE WHEN RC.ysnEligibleRefund = 1 THEN RC.dblRefundAmount ELSE 0 END),
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
LEFT OUTER JOIN (SELECT intRefundId,
				RC.intRefundCustomerId,
				RC.intRefundTypeId,
				RC.ysnEligibleRefund,
				intCustomerId,
				RCat.dblVolume,
				PC.strPurchaseSale,
				dblRefundAmount = RCat.dblVolume * RCat.dblRefundRate,
				dblCashRefund = (RCat.dblVolume * RCat.dblRefundRate) * (RC.dblCashPayout/100)
		FROM tblPATRefundCustomer RC
		INNER JOIN tblPATRefundCategory RCat
			ON RCat.intRefundCustomerId = RC.intRefundCustomerId
		INNER JOIN tblPATPatronageCategory PC
			ON RCat.intPatronageCategoryId = PC.intPatronageCategoryId) RC
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