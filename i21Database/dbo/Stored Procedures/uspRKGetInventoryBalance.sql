
CREATE PROC uspRKGetInventoryBalance

       @dtmFromTransactionDate datetime = null,
	   @dtmToTransactionDate datetime = null,
	   @intCommodityId int =  null
AS

DECLARE @tblResultInventory TABLE
(Id INT identity(1,1),
dtmDate datetime,
tranShipmentNumber nvarchar(50),
tranShipQty numeric(16,10),
tranReceiptNumber nvarchar(50),
tranRecQty numeric(16,10),
BalanceForward numeric(16,10),
tranAdjNumber nvarchar(50),
dblAdjustmentQty numeric(16,10))
 
INSERT INTO @tblResultInventory(dtmDate,tranShipmentNumber,tranShipQty,tranReceiptNumber,tranRecQty,tranAdjNumber,dblAdjustmentQty,BalanceForward)

SELECT *,isnull(tranShipQty,0)+isnull(tranRecQty,0)+isnull(dblAdjustmentQty,0) BalanceForward FROM (SELECT dtmDate,
(SELECT strShipmentNumber FROM tblICInventoryShipment sh WHERE sh.strShipmentNumber=it.strTransactionId) tranShipmentNumber,
(SELECT dblQty FROM tblICInventoryShipment sh WHERE sh.strShipmentNumber=it.strTransactionId) tranShipQty,
(SELECT strReceiptNumber FROM tblICInventoryReceipt ir WHERE ir.strReceiptNumber=it.strTransactionId) tranReceiptNumber,
(SELECT dblQty FROM tblICInventoryReceipt ir WHERE ir.strReceiptNumber=it.strTransactionId) tranRecQty,
(SELECT strAdjustmentNo FROM tblICInventoryAdjustment ia
		 WHERE ia.strAdjustmentNo=it.strTransactionId) tranAdjNumber,
(SELECT dblQty FROM tblICInventoryAdjustment ia
		 WHERE ia.strAdjustmentNo=it.strTransactionId ) dblAdjustmentQty
FROM tblICInventoryTransaction it 
JOIN tblICItem i on i.intItemId=it.intItemId and it.ysnIsUnposted=0 and it.intTransactionTypeId in(4,5,10)
JOIN tblICItemLocation il on it.intItemLocationId=il.intItemLocationId and il.strDescription <> 'In-Transit' 
WHERE intCommodityId=@intCommodityId AND dtmDate BETWEEN @dtmFromTransactionDate and @dtmToTransactionDate)t
SELECT *
 FROM(SELECT dtmDate,sum(tranShipQty) tranShipQty,sum(tranRecQty) tranRecQty,sum(dblAdjustmentQty) dblAdjustmentQty,sum(BalanceForward) BalanceForward--,
FROM @tblResultInventory T1 group by dtmDate)t 


