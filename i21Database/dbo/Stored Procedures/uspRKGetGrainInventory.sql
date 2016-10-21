CREATE PROC [dbo].[uspRKGetGrainInventory]

       @dtmFromTransactionDate datetime = null,
          @dtmToTransactionDate datetime = null,
          @intCommodityId int =  null

AS

DECLARE @tblResult TABLE
(Id INT identity(1,1),
dtmDate datetime,
tranShipmentNumber nvarchar(50),
tranShipQty numeric(24,10),
tranReceiptNumber nvarchar(50),
tranRecQty numeric(24,10),
BalanceForward numeric(24,10),
tranAdjNumber nvarchar(50),
dblAdjustmentQty numeric(24,10),
strDistributionOption nvarchar(50),
strShipDistributionOption nvarchar(50),
strAdjDistributionOption nvarchar(50)
)

INSERT INTO @tblResult(dtmDate,strDistributionOption,strShipDistributionOption,strAdjDistributionOption,tranShipmentNumber,tranShipQty,tranReceiptNumber,tranRecQty,tranAdjNumber,dblAdjustmentQty,BalanceForward)

SELECT *,round(isnull(tranShipQty,0)+isnull(tranRecQty,0)+isnull(dblAdjustmentQty,0),6) BalanceForward FROM (SELECT dtmDate,
(SELECT top 1 strDistributionOption FROM tblICInventoryReceipt ir 
 JOIN tblICInventoryReceiptItem ir1 on ir.intInventoryReceiptId=ir1.intInventoryReceiptId
JOIN tblSCTicket st ON st.intTicketId = ir1.intSourceId WHERE ir.strReceiptNumber=it.strTransactionId
       )strDistributionOption,

(SELECT top 1 strDistributionOption FROM tblICInventoryShipment ir 
 JOIN tblICInventoryShipmentItem ir1 on ir.intInventoryShipmentId=ir1.intInventoryShipmentId
JOIN tblSCTicket st ON st.intTicketId = ir1.intSourceId WHERE ir.strShipmentNumber=it.strTransactionId
       )strShipDistributionOption,
       '' as strAdjDistributionOption,
(SELECT top 1 strShipmentNumber FROM tblICInventoryShipment sh WHERE sh.strShipmentNumber=it.strTransactionId) tranShipmentNumber,
round((SELECT top 1 dblQty FROM tblICInventoryShipment sh WHERE sh.strShipmentNumber=it.strTransactionId) ,6)tranShipQty,
(SELECT top 1 strReceiptNumber FROM tblICInventoryReceipt ir WHERE ir.strReceiptNumber=it.strTransactionId) tranReceiptNumber,
round((SELECT top 1 dblQty FROM tblICInventoryReceipt ir WHERE ir.strReceiptNumber=it.strTransactionId),6) tranRecQty,
(SELECT top 1 strAdjustmentNo FROM tblICInventoryAdjustment ia
              WHERE ia.strAdjustmentNo=it.strTransactionId) tranAdjNumber,
round((SELECT top 1 dblQty FROM tblICInventoryAdjustment ia
              WHERE ia.strAdjustmentNo=it.strTransactionId ),6) dblAdjustmentQty


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