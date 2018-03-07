CREATE PROC [dbo].[uspRKGetCompanyOwnership]

       @dtmFromTransactionDate datetime = null,
          @dtmToTransactionDate datetime = null,
          @intCommodityId int =  null,
          @intItemId int= null

AS

DECLARE @tblResult TABLE
(      Id INT identity(1,1),
       dtmDate datetime,
       strItemNo nvarchar(50),
       dblUnpaidIn NUMERIC(24,10),
       dblUnpaidOut NUMERIC(24,10),
       dblUnpaidBalance NUMERIC(24,10),
       strDistributionOption nvarchar(50),
       InventoryBalanceCarryForward NUMERIC(24,10),
       strReceiptNumber nvarchar(50),
       intReceiptId int
)

INSERT INTO @tblResult (dblUnpaidBalance,InventoryBalanceCarryForward)
select sum(dblUnpaidBalance),sum(InventoryBalanceCarryForward) from(
SELECT sum(dblUnpaidIn)-sum(dblUnpaidIn-dblUnpaidOut) dblUnpaidBalance,
(SELECT sum(dblQty) BalanceForward
                           FROM tblICInventoryTransaction it 
                           join tblICItem i on i.intItemId=it.intItemId and it.intTransactionTypeId in(4,5,10,23)
                           JOIN tblICItemLocation il on it.intItemId=il.intItemId and isnull(il.strDescription,'') <> 'In-Transit' 
                           WHERE intCommodityId=@intCommodityId and 
                           convert(datetime,CONVERT(VARCHAR(10),dtmDate,110),110)
                           < convert(datetime,CONVERT(VARCHAR(10),@dtmFromTransactionDate,110),110) and i.intCommodityId=@intCommodityId
                           and i.intItemId= case when isnull(@intItemId,0)=0 then i.intItemId else @intItemId end and isnull(i.strType,'') <> 'Other Charge'
                           ) InventoryBalanceCarryForward 
from (
       SELECT dblInQty  dblUnpaidIn,
       dblOutQty dblUnpaidOut
       FROM (
      SELECT       CONVERT(VARCHAR(10),b.dtmDate,110) dtmDate, dblUnitCost dblUnitCost1,
                           ir.intInventoryReceiptItemId ,i.strItemNo,
                           isnull(bd.dblQtyReceived,0) dblInQty,
                           (bd.dblTotal - isnull((select case when sum(pd.dblPayment)- max(dblTotal) = 0 then bd.dblTotal else sum(pd.dblPayment) end 
                                  FROM tblAPPaymentDetail pd where pd.intBillId=b.intBillId and intConcurrencyId<>0),0) )
                           /case when isnull(bd.dblCost,0) =0  then 1 else dblCost end as  dblOutQty
                           ,strDistributionOption,b.strBillId as strReceiptNumber,b.intBillId as intReceiptId  
         FROM tblAPBill b
         JOIN tblAPBillDetail bd on b.intBillId=bd.intBillId
         JOIN tblICInventoryReceiptItem ir on bd.intInventoryReceiptItemId=ir.intInventoryReceiptItemId
         JOIN tblICItem i on i.intItemId=bd.intItemId 
         LEFT JOIN tblSCTicket st ON st.intTicketId = ir.intSourceId
         WHERE 
              convert(datetime,CONVERT(VARCHAR(10),dtmDate,110),110)
                           < convert(datetime,CONVERT(VARCHAR(10),@dtmFromTransactionDate,110),110) and i.intCommodityId= @intCommodityId
          and i.intItemId= case when isnull(@intItemId,0)=0 then i.intItemId else @intItemId end and isnull(strType,'') <> 'Other Charge'
         )t   
  
  )t2
   union
SELECT sum(dblGrossUnits) as dblUnpaidBalance, NULL InventoryBalanceCarryForward
FROM 
 tblICInventoryReceiptItem ir 
 JOIN tblICInventoryReceipt r on r.intInventoryReceiptId=ir.intInventoryReceiptId  and ysnPosted=1
JOIN tblICItem i on i.intItemId=ir.intItemId 
 JOIN tblSCTicket st ON st.intTicketId = ir.intSourceId 
 JOIN tblGRStorageType s ON st.intStorageScheduleTypeId=s.intStorageScheduleTypeId AND isnull(ysnDPOwnedType,0) = 1

WHERE convert(datetime,CONVERT(VARCHAR(10),dtmTicketDateTime,110)) < convert(datetime,CONVERT(VARCHAR(10),@dtmFromTransactionDate,110) )
  and i.intItemId= case when isnull(@intItemId,0)=0 then i.intItemId else @intItemId end and isnull(strType,'') <> 'Other Charge' and i.intCommodityId=@intCommodityId

)t3

INSERT INTO @tblResult (strItemNo,dtmDate,dblUnpaidIn,dblUnpaidOut,dblUnpaidBalance,strDistributionOption,strReceiptNumber,intReceiptId)
SELECT strItemNo,dtmDate,dblUnpaidIn,dblUnpaidIn-dblUnpaidOut dblUnpaidOut, dblUnpaidOut dblUnpaidBalance,strDistributionOption,strReceiptNumber,intReceiptId 
from (
SELECT *,
round(dblInQty,2)  dblUnpaidIn,
round(dblOutQty,2) dblUnpaidOut
FROM (
SELECT CONVERT(VARCHAR(10),b.dtmDate,110) dtmDate, dblUnitCost dblUnitCost1,
                     ir.intInventoryReceiptItemId ,i.strItemNo,
                     isnull(bd.dblQtyReceived,0) dblInQty,
                           (bd.dblTotal - isnull((select case when sum(pd.dblPayment)- max(dblTotal) = 0 then bd.dblTotal else sum(pd.dblPayment) end 
                                                         FROM tblAPPaymentDetail pd where pd.intBillId=b.intBillId and intConcurrencyId<>0),0))
                           /case when isnull(bd.dblCost,0) =0  then 1 else dblCost end as  dblOutQty
                     ,strDistributionOption,b.strBillId as strReceiptNumber,b.intBillId as intReceiptId
  
  FROM tblAPBill b
  JOIN tblAPBillDetail bd on b.intBillId=bd.intBillId
  JOIN tblICInventoryReceiptItem ir on bd.intInventoryReceiptItemId=ir.intInventoryReceiptItemId
  JOIN tblICItem i on i.intItemId=bd.intItemId 
  LEFT JOIN tblSCTicket st ON st.intTicketId = ir.intSourceId
    WHERE  convert(datetime,CONVERT(VARCHAR(10),dtmDate,110),110) BETWEEN 
  convert(datetime,CONVERT(VARCHAR(10),@dtmFromTransactionDate,110),110)  and convert(datetime,CONVERT(VARCHAR(10),@dtmToTransactionDate,110),110)
  and i.intCommodityId= @intCommodityId
   and i.intItemId= case when isnull(@intItemId,0)=0 then i.intItemId else @intItemId end and isnull(strType,'') <> 'Other Charge'
  )t   )t2

UNION 

SELECT  i.strItemNo,CONVERT(VARCHAR(10),dtmTicketDateTime,110) AS dtmDate,
           dblGrossUnits AS dblUnpaidIn,
              0 as dblUnpaidOut,
              dblGrossUnits as dblUnpaidBalance,strDistributionOption,strReceiptNumber,ir.intInventoryReceiptId
FROM 
 tblICInventoryReceiptItem ir 
 JOIN tblICInventoryReceipt r on r.intInventoryReceiptId=ir.intInventoryReceiptId  and ysnPosted=1
JOIN tblICItem i on i.intItemId=ir.intItemId 
 JOIN tblSCTicket st ON st.intTicketId = ir.intSourceId 
 JOIN tblGRStorageType s ON st.intStorageScheduleTypeId=s.intStorageScheduleTypeId AND isnull(ysnDPOwnedType,0) = 1

WHERE convert(datetime,CONVERT(VARCHAR(10),dtmTicketDateTime,110)) between convert(datetime,CONVERT(VARCHAR(10),@dtmFromTransactionDate,110))  and convert(datetime,CONVERT(VARCHAR(10),@dtmToTransactionDate,110)) and i.intCommodityId= @intCommodityId
and i.intItemId= case when isnull(@intItemId,0)=0 then i.intItemId else @intItemId end and isnull(strType,'') <> 'Other Charge'
ORDER BY dtmDate

SELECT convert(int,ROW_NUMBER() OVER (ORDER BY dtmDate)) intRowNum,
   dtmDate dtmDate,strDistributionOption [strDistribution],dblUnpaidIn [dblUnpaidIN],dblUnpaidOut [dblUnpaidOut],dblUnpaidBalance [dblUnpaidBalance],
   InventoryBalanceCarryForward dblInventoryBalanceCarryForward,strReceiptNumber,intReceiptId
FROM @tblResult T1 order by dtmDate,strReceiptNumber Asc