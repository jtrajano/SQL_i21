CREATE PROC [dbo].[uspRKGetCompanyOwnership]

       @dtmFromTransactionDate datetime = null,
	   @dtmToTransactionDate datetime = null,
	   @intCommodityId int =  null,
	   @intItemId int= null

AS

DECLARE @tblResult TABLE
(	Id INT identity(1,1),
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
				JOIN tblICItemLocation il on it.intItemLocationId=il.intItemLocationId and isnull(il.strDescription,'') <> 'In-Transit' 
				WHERE intCommodityId=@intCommodityId and dtmDate < @dtmFromTransactionDate and i.intCommodityId=@intCommodityId
				and i.intItemId= case when isnull(@intItemId,0)=0 then i.intItemId else @intItemId end and isnull(i.strType,'') <> 'Other Charge'
				) InventoryBalanceCarryForward 
from (
	SELECT dblInQty  dblUnpaidIn,
	dblOutQty dblUnpaidOut
	FROM (
	 SELECT 	CONVERT(VARCHAR(10),b.dtmDate,110) dtmDate, dblUnitCost dblUnitCost1,
				 ir.intInventoryReceiptItemId ,i.strItemNo,
				 isnull(bd.dblQtyReceived,0) dblInQty,
				 ISNULL((SELECT (isnull(b.dblAmountDue,0))/case when isnull(dblUnitCost,0) =0  then 1 else dblUnitCost end FROM tblAPBillDetail a
				 WHERE 
				  a.intItemId= case when isnull(@intItemId,0)=0 then a.intItemId else @intItemId end and
				 a.intBillDetailId=bd.intBillDetailId and b.ysnPosted=1),0) AS dblOutQty
				 ,strDistributionOption,b.strBillId as strReceiptNumber,b.intBillId as intReceiptId  
	  FROM tblAPBill b
	  JOIN tblAPBillDetail bd on b.intBillId=bd.intBillId
	  JOIN tblICInventoryReceiptItem ir on bd.intInventoryReceiptItemId=ir.intInventoryReceiptItemId
	  JOIN tblICItem i on i.intItemId=bd.intItemId 
	  LEFT JOIN tblSCTicket st ON st.intTicketId = ir.intSourceId
	  WHERE dtmDate < @dtmFromTransactionDate and i.intCommodityId= @intCommodityId
	   and i.intItemId= case when isnull(@intItemId,0)=0 then i.intItemId else @intItemId end and isnull(strType,'') <> 'Other Charge'
	  )t   
  
  )t2
   union
 SELECT sum(dblGrossUnits) as dblUnpaidBalance, NULL InventoryBalanceCarryForward
 FROM 
 tblICInventoryReceiptItem ir 
 JOIN tblICInventoryReceipt r on r.intInventoryReceiptId=ir.intInventoryReceiptId  and ysnPosted=1
 JOIN tblICItem i on i.intItemId=ir.intItemId 
 JOIN tblSCTicket st ON st.intTicketId = ir.intSourceId AND strDistributionOption IN ('DP')
 WHERE convert(datetime,CONVERT(VARCHAR(10),dtmTicketDateTime,110)) < convert(datetime,CONVERT(VARCHAR(10),@dtmFromTransactionDate,110) )
  and i.intItemId= case when isnull(@intItemId,0)=0 then i.intItemId else @intItemId end and isnull(strType,'') <> 'Other Charge' and i.intCommodityId=@intCommodityId

 )t3

INSERT INTO @tblResult (strItemNo,dtmDate,dblUnpaidIn,dblUnpaidOut,dblUnpaidBalance,strDistributionOption,strReceiptNumber,intReceiptId)
SELECT strItemNo,dtmDate,dblUnpaidIn,dblUnpaidIn-dblUnpaidOut dblUnpaidOut, dblUnpaidOut dblUnpaidBalance,strDistributionOption,strReceiptNumber,intReceiptId 
from (
SELECT *,
dblInQty  dblUnpaidIn,
dblOutQty dblUnpaidOut
FROM (
 SELECT CONVERT(VARCHAR(10),b.dtmDate,110) dtmDate, dblUnitCost dblUnitCost1,
			 ir.intInventoryReceiptItemId ,i.strItemNo,
			 isnull(bd.dblQtyReceived,0) dblInQty,
			 ISNULL((SELECT (isnull(b.dblAmountDue,0))/case when isnull(dblUnitCost,0) =0  then 1 else dblUnitCost end FROM tblAPBillDetail a
			 WHERE 
			 a.intItemId= case when isnull(@intItemId,0)=0 then a.intItemId else @intItemId end and
			 a.intBillDetailId=bd.intBillDetailId and b.ysnPosted=1),0) AS dblOutQty
			 ,strDistributionOption,b.strBillId as strReceiptNumber,b.intBillId as intReceiptId
  
  FROM tblAPBill b
  JOIN tblAPBillDetail bd on b.intBillId=bd.intBillId
  JOIN tblICInventoryReceiptItem ir on bd.intInventoryReceiptItemId=ir.intInventoryReceiptItemId
  JOIN tblICItem i on i.intItemId=bd.intItemId 
  LEFT JOIN tblSCTicket st ON st.intTicketId = ir.intSourceId
  WHERE dtmDate BETWEEN @dtmFromTransactionDate and @dtmToTransactionDate and i.intCommodityId= @intCommodityId
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
 JOIN tblSCTicket st ON st.intTicketId = ir.intSourceId AND strDistributionOption IN ('DP')
 WHERE convert(datetime,CONVERT(VARCHAR(10),dtmTicketDateTime,110)) between convert(datetime,CONVERT(VARCHAR(10),@dtmFromTransactionDate,110))  and convert(datetime,CONVERT(VARCHAR(10),@dtmToTransactionDate,110)) and i.intCommodityId= @intCommodityId
 and i.intItemId= case when isnull(@intItemId,0)=0 then i.intItemId else @intItemId end and isnull(strType,'') <> 'Other Charge'
 ORDER BY dtmDate

 SELECT convert(int,ROW_NUMBER() OVER (ORDER BY dtmDate)) intRowNum,
   dtmDate dtmDate,strDistributionOption [strDistribution],dblUnpaidIn [dblUnpaidIN],dblUnpaidOut [dblUnpaidOut],dblUnpaidBalance [dblUnpaidBalance],
   InventoryBalanceCarryForward dblInventoryBalanceCarryForward,strReceiptNumber,intReceiptId
FROM @tblResult T1 order by dtmDate,strReceiptNumber Asc 