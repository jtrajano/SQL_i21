CREATE VIEW [dbo].[vyuPATCalculateNoRefundSummaryHistory]
	AS
SELECT	NEWID() AS id,
		R.intRefundId,
		RR.intCustomerId,
		strCustomerName = ENT.strName,
		intFiscalYearId = R.intFiscalYearId,
		AC.strStockStatus,
		dblTotalPurchases = RefMerge.dblTotalPurchases,
		dblTotalSales = RefMerge.dblTotalSales,
		dblRefundAmount = RR.dblRefundAmount,
		dblEquityRefund = RR.dblRefundAmount - RR.dblCashRefund
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
				dblTotalSales = CASE WHEN PC.strPurchaseSale = 'Sale' THEN SUM(RCat.dblVolume) ELSE 0 END
		FROM tblPATRefundCategory RCat
		INNER JOIN tblPATPatronageCategory PC
			ON PC.intPatronageCategoryId = RCat.intPatronageCategoryId
		GROUP BY RCat.intRefundCustomerId, PC.strPurchaseSale
	) RefMerge
		ON RefMerge.intRefundCustomerId = RR.intRefundCustomerId