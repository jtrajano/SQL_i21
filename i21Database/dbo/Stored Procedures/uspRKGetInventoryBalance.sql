﻿CREATE PROC uspRKGetInventoryBalance

       @dtmFromTransactionDate datetime = null,
	   @dtmToTransactionDate datetime = null,
	   @intCommodityId int =  null,
	   @intItemId int= null
AS

--DECLARE @intItemId int = 0

DECLARE @tblResultInventory TABLE
(Id INT identity(1,1),
dtmDate datetime,
tranShipmentNumber nvarchar(50),
tranShipQty NUMERIC(24,10),
tranReceiptNumber nvarchar(50),
tranRecQty NUMERIC(24,10),
BalanceForward NUMERIC(24,10),
tranAdjNumber nvarchar(50),
dblAdjustmentQty NUMERIC(24,10)
)
 
insert into @tblResultInventory (BalanceForward)
SELECT  sum(dblQty) BalanceForward
FROM tblICInventoryTransaction it 
JOIN tblICItem i on i.intItemId=it.intItemId and it.ysnIsUnposted=0 and it.intTransactionTypeId in(4,5,10)
join tblICInventoryTransactionType tr on it.intTransactionTypeId=tr.intTransactionTypeId
JOIN tblICItemLocation il on it.intItemLocationId=il.intItemLocationId and il.strDescription <> 'In-Transit' 
WHERE intCommodityId=@intCommodityId and dtmDate < @dtmFromTransactionDate  
and i.intItemId= case when isnull(@intItemId,0)=0 then i.intItemId else @intItemId end 

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
WHERE intCommodityId=@intCommodityId AND dtmDate BETWEEN @dtmFromTransactionDate and @dtmToTransactionDate
and i.intItemId= case when isnull(@intItemId,0)=0 then i.intItemId else @intItemId end )t

SELECT *
 FROM(SELECT dtmDate,sum(tranShipQty) tranShipQty,sum(tranRecQty) tranRecQty,sum(dblAdjustmentQty) dblAdjustmentQty,sum(BalanceForward) BalanceForward
FROM @tblResultInventory T1 group by dtmDate)t 