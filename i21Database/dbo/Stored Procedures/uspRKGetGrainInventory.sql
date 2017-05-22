CREATE PROC [dbo].[uspRKGetGrainInventory]

		@dtmFromTransactionDate datetime = null,
		@dtmToTransactionDate datetime = null,
		@intCommodityId int =  null,
		@intItemId int= null

AS

DECLARE @tblResult TABLE
(Id INT identity(1,1),
dtmDate datetime,
tranShipmentNumber nvarchar(50),
tranShipQty NUMERIC(24,10),
tranReceiptNumber nvarchar(50),
tranRecQty NUMERIC(24,10),
BalanceForward NUMERIC(24,10),
tranAdjNumber nvarchar(50),
dblAdjustmentQty NUMERIC(24,10),
tranCountNumber nvarchar(50),
dblCountQty NUMERIC(24,10),
strDistributionOption nvarchar(50),
strShipDistributionOption nvarchar(50),
strAdjDistributionOption nvarchar(50),
strCountDistributionOption nvarchar(50),
intInventoryReceiptId int,
intInventoryShipmentId int,
intInventoryAdjustmentId int,
intInventoryCountId int

)

INSERT INTO @tblResult(dtmDate,strDistributionOption,strShipDistributionOption,strAdjDistributionOption,strCountDistributionOption,tranShipmentNumber,tranShipQty,
	tranReceiptNumber,tranRecQty,tranAdjNumber,dblAdjustmentQty,tranCountNumber,dblCountQty
,intInventoryReceiptId ,intInventoryShipmentId,intInventoryAdjustmentId,intInventoryCountId,BalanceForward)

SELECT *,round(isnull(tranShipQty,0)+isnull(tranRecQty,0)+isnull(dblAdjustmentQty,0)+isnull(dblCountQty,0),6) BalanceForward FROM 
(SELECT dtmDate,
	(SELECT top 1 strDistributionOption FROM tblICInventoryReceipt ir 
	 JOIN tblICInventoryReceiptItem ir1 on ir.intInventoryReceiptId=ir1.intInventoryReceiptId
	 JOIN tblSCTicket st ON st.intTicketId = ir1.intSourceId WHERE ir.strReceiptNumber=it.strTransactionId
	 )strDistributionOption,

	(SELECT top 1 strDistributionOption FROM tblICInventoryShipment ir 
	 JOIN tblICInventoryShipmentItem ir1 on ir.intInventoryShipmentId=ir1.intInventoryShipmentId
	 JOIN tblSCTicket st ON st.intTicketId = ir1.intSourceId WHERE ir.strShipmentNumber=it.strTransactionId) strShipDistributionOption,
       '' as strAdjDistributionOption,
	   '' as strCountDistributionOption,
(SELECT top 1 strShipmentNumber FROM tblICInventoryShipment sh WHERE sh.strShipmentNumber=it.strTransactionId) tranShipmentNumber,
round((SELECT TOP 1 dblQty FROM tblICInventoryShipment sh WHERE sh.strShipmentNumber=it.strTransactionId) ,6)tranShipQty,
(SELECT top 1 strReceiptNumber FROM tblICInventoryReceipt ir WHERE ir.strReceiptNumber=it.strTransactionId) tranReceiptNumber,
ROUND((SELECT TOP 1 dblQty FROM tblICInventoryReceipt ir WHERE ir.strReceiptNumber=it.strTransactionId),6) tranRecQty,
(SELECT top 1 strAdjustmentNo FROM tblICInventoryAdjustment ia WHERE ia.strAdjustmentNo=it.strTransactionId) tranAdjNumber,
ROUND((SELECT TOP 1 dblQty FROM tblICInventoryAdjustment ia WHERE ia.strAdjustmentNo=it.strTransactionId ),6) dblAdjustmentQty,
(SELECT top 1 strCountNo FROM tblICInventoryCount ia WHERE ia.strCountNo=it.strTransactionId) tranCountNumber,
ROUND((SELECT TOP 1 dblQty FROM tblICInventoryCount ia WHERE ia.strCountNo=it.strTransactionId ),6) dblCountQty,


ROUND((SELECT TOP 1 intInventoryReceiptId FROM tblICInventoryReceipt ir WHERE ir.strReceiptNumber=it.strTransactionId),6) intInventoryReceiptId,
ROUND((SELECT TOP 1 intInventoryShipmentId FROM tblICInventoryShipment sh WHERE sh.strShipmentNumber=it.strTransactionId) ,6)intInventoryShipmentId,
ROUND((SELECT TOP 1 intInventoryAdjustmentId FROM tblICInventoryAdjustment ia WHERE ia.strAdjustmentNo=it.strTransactionId ),6) intInventoryAdjustmentId,
ROUND((SELECT TOP 1 intInventoryCountId FROM tblICInventoryCount ia WHERE ia.strCountNo=it.strTransactionId ),6) intInventoryCountId

FROM tblICInventoryTransaction it 
JOIN tblICItem i on i.intItemId=it.intItemId and it.ysnIsUnposted=0 and it.intTransactionTypeId in(4,5,10,23)
JOIN tblICItemLocation il on it.intItemLocationId=il.intItemLocationId and isnull(il.strDescription,'') <> 'In-Transit' 
WHERE intCommodityId=@intCommodityId
AND i.intItemId= case when isnull(@intItemId,0)=0 then i.intItemId else @intItemId end 
AND dtmDate BETWEEN @dtmFromTransactionDate and @dtmToTransactionDate  )t

SELECT convert(int,ROW_NUMBER() OVER (ORDER BY dtmDate)) intRowNum,
    dtmDate [dtmDate],case when isnull(tranReceiptNumber,'') <> '' then tranReceiptNumber
                                            when isnull(tranShipmentNumber,'') <> '' then tranShipmentNumber
                                            when isnull(tranAdjNumber,'') <> '' then tranAdjNumber
											when isnull(tranCountNumber,'') <> '' then tranCountNumber end [strReceiptNumber],
       
    CASE WHEN isnull(strDistributionOption,'') <> '' THEN strDistributionOption
                                            WHEN isnull(strShipDistributionOption,'') <> '' then strShipDistributionOption
                                            END 
                                            strDistribution,
       tranRecQty [dblIN],tranShipmentNumber [strShipTicketNo],tranShipQty [dblOUT],tranAdjNumber [strAdjNo],
       dblAdjustmentQty [dblAdjQty],tranCountNumber [strCountNumber],dblCountQty [dblCountQty],BalanceForward dblDummy,
(SELECT SUM(BalanceForward) FROM @tblResult AS T2 WHERE T2.Id <= T1.Id) AS dblBalanceForward,strShipDistributionOption,
	intInventoryReceiptId,intInventoryShipmentId,intInventoryAdjustmentId,intInventoryCountId
FROM @tblResult T1