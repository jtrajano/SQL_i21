CREATE PROC uspRKGetGrainInventory

       @dtmFromTransactionDate datetime = null,
	   @dtmToTransactionDate datetime = null,
	   @intCommodityId int =  null

AS

DECLARE @tblResult TABLE
(Id INT identity(1,1),
dtmDate datetime,
tranShipmentNumber nvarchar(50),
tranShipQty numeric(16,10),
tranReceiptNumber nvarchar(50),
tranRecQty numeric(16,10),
BalanceForward numeric(16,10),
tranAdjNumber nvarchar(50),
dblAdjustmentQty numeric(16,10),
strDistributionOption nvarchar(50),
strShipDistributionOption nvarchar(50),
strAdjDistributionOption nvarchar(50)
)
 
INSERT INTO @tblResult(dtmDate,strDistributionOption,strShipDistributionOption,strAdjDistributionOption,tranShipmentNumber,tranShipQty,tranReceiptNumber,tranRecQty,tranAdjNumber,dblAdjustmentQty,BalanceForward)

SELECT  NULL dtmDate,'' as strDistributionOption,'' as strShipDistributionOption, '' AS strAdjDistributionOption,'' tranShipmentNumber, NULL tranShipQty,'Balance Forward' tranReceiptNumber,null tranRecQty ,'',null,sum(dblQty) BalanceForward
FROM tblICInventoryTransaction it 
JOIN tblICItem i on i.intItemId=it.intItemId
JOIN tblICItemLocation il on it.intItemLocationId=il.intItemLocationId and il.strDescription <> 'In-Transit' 
WHERE intCommodityId=@intCommodityId and dtmDate < @dtmFromTransactionDate  
 
UNION

SELECT *,isnull(tranShipQty,0)+isnull(tranRecQty,0)+isnull(dblAdjustmentQty,0) BalanceForward FROM (SELECT dtmDate,
(SELECT strDistributionOption FROM tblICInventoryReceipt ir 
 JOIN tblICInventoryReceiptItem ir1 on ir.intInventoryReceiptId=ir1.intInventoryReceiptId
 JOIN tblSCTicket st ON st.intTicketId = ir1.intSourceId WHERE ir.strReceiptNumber=it.strTransactionId
	)strDistributionOption,

(SELECT strDistributionOption FROM tblICInventoryShipment ir 
 JOIN tblICInventoryShipmentItem ir1 on ir.intInventoryShipmentId=ir1.intInventoryShipmentId
 JOIN tblSCTicket st ON st.intTicketId = ir1.intSourceId WHERE ir.strShipmentNumber=it.strTransactionId
	)strShipDistributionOption,
	'' as strAdjDistributionOption,
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
WHERE intCommodityId=@intCommodityId AND dtmDate BETWEEN @dtmFromTransactionDate and @dtmToTransactionDate  )t

SELECT convert(int,ROW_NUMBER() OVER (ORDER BY dtmDate)) intRowNum,
    dtmDate [dtmDate],case when isnull(tranReceiptNumber,'') <> '' then tranReceiptNumber
						   when isnull(tranShipmentNumber,'') <> '' then tranShipmentNumber
						   when isnull(tranAdjNumber,'') <> '' then tranAdjNumber end [strReceiptNumber],
	
    case when isnull(strDistributionOption,'') <> '' then strDistributionOption
						   when isnull(strShipDistributionOption,'') <> '' then strShipDistributionOption
						  -- when isnull(tranAdjNumber,'') <> '' then tranAdjNumber
						    end 
						   strDistribution,

	tranRecQty [dblIN],tranShipmentNumber [strShipTicketNo],tranShipQty [dblOUT],tranAdjNumber [strAdjNo],
	dblAdjustmentQty [dblAdjQty],BalanceForward dblDummy,
    (SELECT SUM(BalanceForward) FROM @tblResult AS T2 WHERE T2.Id <= T1.Id) AS dblBalanceForward,strShipDistributionOption
FROM @tblResult T1
WHERE BalanceForward <>0

