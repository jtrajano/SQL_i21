CREATE VIEW [dbo].[vyuPATCalculateNoRefundSummaryHistory]
	AS
SELECT	NEWID() as id,
		R.intRefundId,
		RR.intCustomerId,
		RR.intRefundTypeId,
		ENT.strEntityNo,
		strCustomerName = ENT.strName,
		intFiscalYearId = R.intFiscalYearId,
		RR.ysnEligibleRefund,
		AC.strStockStatus,
		dblTotalPurchases = SUM(RefMerge.dblTotalPurchases),
		dblTotalSales = SUM(RefMerge.dblTotalSales),
		dblRefundAmount = SUM(RefMerge.dblRefundAmount),
		dblEquityRefund = SUM(RefMerge.dblRefundAmount - (RefMerge.dblRefundAmount * (RT.dblCashPayout/100)))
	FROM tblPATRefundCustomer RR
	INNER JOIN tblARCustomer AC
		ON AC.[intEntityId] = RR.intCustomerId
	INNER JOIN tblEMEntity ENT
		ON ENT.intEntityId = RR.intCustomerId
	INNER JOIN tblPATRefundRate RT
		ON RT.intRefundTypeId = RR.intRefundTypeId
	INNER JOIN tblPATRefund R
		ON R.intRefundId = RR.intRefundId
	INNER JOIN (
		SELECT	RCat.intRefundCustomerId,
				dblTotalPurchases = CASE WHEN PC.strPurchaseSale = 'Purchase' THEN SUM(RCat.dblVolume) ELSE 0 END,
				dblTotalSales = CASE WHEN PC.strPurchaseSale = 'Sale' THEN SUM(RCat.dblVolume) ELSE 0 END,
				dblRefundAmount = SUM(RCat.dblRefundRate * RCat.dblVolume)
		FROM tblPATRefundCategory RCat
		INNER JOIN tblPATPatronageCategory PC
			ON PC.intPatronageCategoryId = RCat.intPatronageCategoryId
		GROUP BY RCat.intRefundCustomerId, PC.strPurchaseSale
	) RefMerge
		ON RefMerge.intRefundCustomerId = RR.intRefundCustomerId
	GROUP BY R.intRefundId,
		RR.intCustomerId,
		RR.intRefundTypeId,
		ENT.strEntityNo,
		ENT.strName,
		R.intFiscalYearId,
		RR.ysnEligibleRefund,
		AC.strStockStatus