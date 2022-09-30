CREATE VIEW [dbo].[vyuAPVoucherCommodity]
AS

SELECT 
	intBillId,
	intInvoiceId = NULL,
	commodity.intCommodityId, 
	commodity.intCount,
	ISNULL(commodity.strCommodityCode, 'None') AS strCommodityCode
FROM tblAPBill A
CROSS APPLY (
	SELECT TOP 1
		COUNT(commodity.intCommodityId) intCount, 
		commodity.intCommodityId,
		commodity.strCommodityCode
	FROM tblAPBillDetail detail
	LEFT JOIN tblICItem item ON detail.intItemId = item.intItemId
	LEFT JOIN tblICCommodity commodity ON item.intCommodityId = commodity.intCommodityId
	WHERE detail.intBillId = A.intBillId
	GROUP BY commodity.intCommodityId, commodity.strCommodityCode
	ORDER BY COUNT(commodity.intCommodityId) DESC
) commodity
	UNION ALL
	SELECT 
		NULL,
		intInvoiceId,
		commodity.intCommodityId, 
		commodity.intCount,
		ISNULL(commodity.strCommodityCode, 'None') AS strCommodityCode
	FROM tblARInvoice A
	CROSS APPLY (
		SELECT TOP 1
			COUNT(commodity.intCommodityId) intCount, 
			commodity.intCommodityId,
			commodity.strCommodityCode
		FROM tblARInvoiceDetail detail
		LEFT JOIN tblICItem item ON detail.intItemId = item.intItemId
		LEFT JOIN tblICCommodity commodity ON item.intCommodityId = commodity.intCommodityId
		WHERE detail.intInvoiceId = A.intInvoiceId
		GROUP BY commodity.intCommodityId, commodity.strCommodityCode
		ORDER BY COUNT(commodity.intCommodityId) DESC
	) commodity
	WHERE  
			A.intInvoiceId > 0  
		AND A.dblAmountDue != 0  
		AND A.ysnForgiven != 1  
		AND A.strTransactionType IN ('Invoice','Cash','Cash Refund','Credit Memo','Debit memo')  
		AND A.strType != 'CF Tran'  
