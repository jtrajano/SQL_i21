CREATE VIEW [dbo].[vyuPATCalculateNoRefundSummaryHistory]
	AS
SELECT	NEWID() AS id,
		R.intRefundId,
		RR.intCustomerId,
		RR.intRefundTypeId,
		strCustomerName = ENT.strName,
		intFiscalYearId = R.intFiscalYearId,
		ysnEligibleRefund = CASE WHEN RefMerge.dblRefundAmount < R.dblMinimumRefund THEN CAST(0 AS BIT) ELSE CAST(1 AS BIT) END,
		AC.strStockStatus,
		dblTotalPurchases = RefMerge.dblTotalPurchases,
		dblTotalSales = RefMerge.dblTotalSales,
		dblRefundAmount = RefMerge.dblRefundAmount,
		dblEquityRefund = CASE WHEN (RefMerge.dblRefundAmount - RR.dblCashRefund) < 0 THEN 0 ELSE RefMerge.dblRefundAmount - RR.dblCashRefund END 
	FROM tblPATRefundCustomer RR
	INNER JOIN tblARCustomer AC
		ON AC.intEntityCustomerId = RR.intCustomerId
	INNER JOIN tblEMEntity ENT
		ON ENT.intEntityId = RR.intCustomerId
	INNER JOIN tblPATRefund R
		ON R.intRefundId = RR.intRefundId
	INNER JOIN (
		SELECT	RCat.intRefundCustomerId,
				dblTotalPurchases = CASE WHEN PC.strPurchaseSale = 'Purchase' THEN SUM(RCat.dblVolume) ELSE 0 END,
				dblTotalSales = CASE WHEN PC.strPurchaseSale = 'Sale' THEN SUM(RCat.dblVolume) ELSE 0 END,
				dblRefundAmount = SUM(RCat.dblRefundAmount)
		FROM tblPATRefundCategory RCat
		INNER JOIN tblPATPatronageCategory PC
			ON PC.intPatronageCategoryId = RCat.intPatronageCategoryId
		GROUP BY RCat.intRefundCustomerId, PC.strPurchaseSale
	) RefMerge
		ON RefMerge.intRefundCustomerId = RR.intRefundCustomerId