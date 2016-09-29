CREATE VIEW [dbo].[vyuPATRefundSummary]
	AS
WITH Refunds AS(
SELECT	R.intRefundId,
		R.intFiscalYearId,
		F.strFiscalYear,
		dblTotalPurchases = (CASE WHEN RCatPCat.strPurchaseSale = 'Purchase' THEN RCatPCat.dblVolume ELSE 0 END),
		dblTotalSales = (CASE WHEN RCatPCat.strPurchaseSale = 'Sale' THEN RCatPCat.dblVolume ELSE 0 END),
		dbLessFWT = CASE WHEN C.ysnSubjectToFWT = 0 THEN 0 ELSE RC.dblCashRefund * (R.dblFedWithholdingPercentage/100) END,
		dblTotalCashRefund = RC.dblCashRefund,
		dblLessServiceFee = RC.dblCashRefund * (R.dblServiceFee/100),
		dblCheckAmount = CASE WHEN (RC.dblCashRefund - (CASE WHEN C.ysnSubjectToFWT = 0 THEN 0 ELSE RC.dblCashRefund * (R.dblFedWithholdingPercentage/100) END) - (RC.dblCashRefund * (R.dblServiceFee/100)) < 0) THEN 0 ELSE RC.dblCashRefund - (CASE WHEN C.ysnSubjectToFWT = 0 THEN 0 ELSE RC.dblCashRefund * (R.dblFedWithholdingPercentage/100) END) - (RC.dblCashRefund * (R.dblServiceFee/100)) END,
		dblTotalVolume = RCatPCat.dblVolume,
		dblTotalRefund = RC.dblRefundAmount,
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
INNER JOIN tblPATRefundCustomer RC
	ON RC.intRefundId = R.intRefundId
INNER JOIN tblGLFiscalYear F
	ON F.intFiscalYearId = R.intFiscalYearId
INNER JOIN tblARCustomer C
	ON C.intEntityCustomerId = RC.intCustomerId
INNER JOIN (SELECT	intRefundCustomerId = RCat.intRefundCustomerId,
				intPatronageCategoryId = RCat.intPatronageCategoryId,
				dblRefundRate = RCat.dblRefundRate,
				strPurchaseSale = PCat.strPurchaseSale,
				intRefundTypeId = RRD.intRefundTypeId,
				strRefundType = RR.strRefundType,
				strRefundDescription = RR.strRefundDescription,
				dblCashPayout = RR.dblCashPayout,
				ysnQualified = RR.ysnQualified,
				dblVolume = RCat.dblVolume
		FROM tblPATRefundCategory RCat
		INNER JOIN tblPATPatronageCategory PCat
			ON RCat.intPatronageCategoryId	 = PCat.intPatronageCategoryId
		INNER JOIN tblPATRefundRateDetail RRD
			ON RRD.intPatronageCategoryId = RCat.intPatronageCategoryId
		INNER JOIN tblPATRefundRate RR
			ON RR.intRefundTypeId = RRD.intRefundTypeId
	) RCatPCat
	ON RCatPCat.intRefundCustomerId = RC.intRefundCustomerId
)
SELECT	intRefundId,
		intFiscalYearId,
		strFiscalYear,
		dblTotalPurchases = SUM(dblTotalPurchases),
		dblTotalSales = SUM(dblTotalSales),
		dblTotalLessFWT = SUM(dbLessFWT),
		dblTotalLessServiceFee = SUM(dblLessServiceFee),
		dblTotalCashRefund = SUM(dblTotalCashRefund),
		dblTotalCheckAmount = SUM(dblCheckAmount),
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