CREATE VIEW [dbo].[vyuAPVoucherCommodity]
AS

SELECT 
	intBillId,
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