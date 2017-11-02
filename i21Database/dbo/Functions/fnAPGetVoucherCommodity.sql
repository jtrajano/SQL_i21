﻿CREATE FUNCTION [dbo].[fnAPGetVoucherCommodity]
(
	@voucherId INT
)
RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN
SELECT 
	TOP 1
	COUNT(commodity.intCommodityId) intCount, 
	commodity.intCommodityId,
	commodity.strCommodityCode
FROM dbo.tblAPBillDetail detail
LEFT JOIN dbo.tblICItem item ON detail.intItemId = item.intItemId
LEFT JOIN dbo.tblICCommodity commodity ON item.intCommodityId = commodity.intCommodityId
WHERE detail.intBillId = @voucherId
GROUP BY commodity.intCommodityId, commodity.strCommodityCode
ORDER BY COUNT(commodity.intCommodityId) DESC