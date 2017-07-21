CREATE VIEW [dbo].[vyuAPVoucherCommodity]
AS

SELECT
	intBillId,
	MAX(commodity.intCount) intCount,
	commodity.intCommodityId, 
	ISNULL(commodity.strCommodityCode, 'None') AS strCommodityCode
FROM tblAPBill A
CROSS APPLY (
	SELECT 
		COUNT(DISTINCT commodity.intCommodityId) intCount, 
		commodity.intCommodityId,
		commodity.strCommodityCode
	FROM tblAPBillDetail detail
	LEFT JOIN tblICItem item ON detail.intItemId = item.intItemId
	LEFT JOIN tblICCommodity commodity ON item.intCommodityId = commodity.intCommodityId
	WHERE detail.intBillId = A.intBillId
	GROUP BY commodity.intCommodityId, commodity.strCommodityCode
) commodity
GROUP BY commodity.intCommodityId, commodity.strCommodityCode, intBillId