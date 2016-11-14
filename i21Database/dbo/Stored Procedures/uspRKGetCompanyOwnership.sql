CREATE proc uspRKGetCompanyOwnership

       @dtmFromTransactionDate datetime = null,
	   @dtmToTransactionDate datetime = null,
	   @intCommodityId int =  null,
	   @intItemId int= null

AS

DECLARE @tblResult TABLE
(Id INT identity(1,1),
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
INSERT INTO @tblResult (strItemNo,dtmDate,dblUnpaidIn,dblUnpaidOut,dblUnpaidBalance,InventoryBalanceCarryForward)
SELECT  NULL,NULL, NULL,NULL,SUM(dblUnpaidBalance),sum(InventoryBalanceCarryForward)  from (
SELECT strItemNo,CONVERT(VARCHAR(10),dtmDate,110) dtmDate,dblUnpaidIn,dblUnpaidOut, (dblUnpaidIn-dblUnpaidOut) dblUnpaidBalance,
	(SELECT sum(dblQty) BalanceForward
				FROM tblICInventoryTransaction it 
				join tblICItem i on i.intItemId=it.intItemId
				JOIN tblICItemLocation il on it.intItemLocationId=il.intItemLocationId and il.strDescription <> 'In-Transit' 
				WHERE intCommodityId=@intCommodityId and dtmDate < @dtmFromTransactionDate
				and i.intItemId= case when isnull(@intItemId,0)=0 then i.intItemId else @intItemId end 
				) InventoryBalanceCarryForward 
 from (
SELECT *,
(isnull(dblUnitCost,0))/case when isnull(dblUnitCost1,0) =0  then 1 else dblUnitCost1 end    dblUnpaidIn,
isnull((isnull(dblUnitCost,0))/case when isnull(dblUnitCost1,0) =0  then 1 else dblUnitCost1 end,0)-isnull((isnull(dblUnitCost,0)-isnull(dblQtyReceived,0))/case when isnull(dblUnitCost1,0) =0  then 1 else dblUnitCost1 end,0)  dblUnpaidOut
FROM (
SELECT dtmDate, dblOpenReceive*dblUnitCost AS dblUnitCost
			,dblUnitCost dblUnitCost1,
			 ir.intInventoryReceiptItemId ,i.strItemNo,
			ISNULL((SELECT isnull(b.dblAmountDue,0) FROM tblAPBillDetail bd 
				INNER JOIN tblAPBill b on b.intBillId=bd.intBillId
				WHERE bd.intInventoryReceiptItemId=ir.intInventoryReceiptItemId and ysnPosted=1
				and bd.intItemId= case when isnull(@intItemId,0)=0 then bd.intItemId else @intItemId end 
				),0) AS dblQtyReceived
 from 
 vyuAPBillDetail ap
 JOIN tblICInventoryReceiptItem ir on ap.intInventoryReceiptId=ir.intInventoryReceiptId
 JOIN tblICItem i on i.intItemId=ir.intItemId where dtmDate < @dtmFromTransactionDate and  i.intCommodityId= @intCommodityId
 and i.intItemId= case when isnull(@intItemId,0)=0 then i.intItemId else @intItemId end 
 )t)t2
 UNION 
 SELECT  i.strItemNo,CONVERT(VARCHAR(10),dtmTicketDateTime,110) AS dtmDate,
	    dblGrossUnits AS dblUnpaidIn,
		0 as dblUnpaidOut,
		dblGrossUnits as dblUnpaidBalance, NULL InventoryBalanceCarryForward
 FROM 
 tblICInventoryReceiptItem ir 
 JOIN tblICInventoryReceipt r on r.intInventoryReceiptId=ir.intInventoryReceiptId  and ysnPosted=1
 JOIN tblICItem i on i.intItemId=ir.intItemId
 JOIN tblSCTicket st ON st.intTicketId = ir.intSourceId AND strDistributionOption IN ('DP')
 WHERE CONVERT(VARCHAR(10),dtmTicketDateTime,110) <= CONVERT(VARCHAR(10),@dtmFromTransactionDate,110)  and i.intItemId= case when isnull(@intItemId,0)=0 then i.intItemId else @intItemId end )t 


INSERT INTO @tblResult (strItemNo,dtmDate,dblUnpaidIn,dblUnpaidOut,dblUnpaidBalance,strDistributionOption,strReceiptNumber,intReceiptId)
SELECT strItemNo,dtmDate,dblUnpaidIn,dblUnpaidOut, dblUnpaidIn-dblUnpaidOut dblUnpaidBalance,strDistributionOption,strReceiptNumber,intReceiptId from (
SELECT *,
(isnull(dblRecQty,0))/case when isnull(dblUnitCost1,0) =0  then 1 else dblUnitCost1 end    dblUnpaidIn,
(isnull(dblRecQty,0)/case when isnull(dblUnitCost1,0) =0  then 1 else dblUnitCost1 end)-
(isnull(dblQtyReceived,0)/case when isnull(dblUnitCost1,0) =0  then 1 else dblUnitCost1 end)  dblUnpaidOut
FROM (
SELECT CONVERT(VARCHAR(10),dtmDate,110) dtmDate, 
isnull(	(SELECT dblOpenReceive from tblICInventoryReceiptItem r 
	JOIN tblICInventoryReceipt ir1 on ir1.intInventoryReceiptId=r.intInventoryReceiptId 
	WHERE ysnPosted = 1 and r.intInventoryReceiptItemId=ir.intInventoryReceiptItemId),0)*dblUnitCost AS dblRecQty
			,dblUnitCost dblUnitCost1,
			 ir.intInventoryReceiptItemId ,i.strItemNo,
			 ISNULL((SELECT isnull(b.dblAmountDue,0) FROM tblAPBillDetail bd 
				INNER JOIN tblAPBill b on b.intBillId=bd.intBillId
				WHERE bd.intInventoryReceiptItemId=ir.intInventoryReceiptItemId and b.ysnPosted=1
				and bd.intItemId= case when isnull(@intItemId,0)=0 then bd.intItemId else @intItemId end 
				),0) AS dblQtyReceived
				,strDistributionOption,ap.strBillId as strReceiptNumber,intBillId as intReceiptId
 FROM 
 vyuAPBillDetail ap
 JOIN tblICInventoryReceiptItem ir on ap.intInventoryReceiptId=ir.intInventoryReceiptId
 JOIN tblICItem i on i.intItemId=ir.intItemId
 LEFT JOIN tblSCTicket st ON st.intTicketId = ir.intSourceId
  where dtmDate between @dtmFromTransactionDate and @dtmToTransactionDate and i.intCommodityId= @intCommodityId
 and ir.intItemId= case when isnull(@intItemId,0)=0 then ir.intItemId else @intItemId end 
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
 WHERE CONVERT(VARCHAR(10),dtmTicketDateTime,110) between CONVERT(VARCHAR(10),@dtmFromTransactionDate,110)  and CONVERT(VARCHAR(10),@dtmToTransactionDate,110) and i.intCommodityId= @intCommodityId
 and i.intItemId= case when isnull(@intItemId,0)=0 then i.intItemId else @intItemId end 
 ORDER BY dtmDate

 SELECT convert(int,ROW_NUMBER() OVER (ORDER BY dtmDate)) intRowNum,
   dtmDate dtmDate,strDistributionOption [strDistribution],dblUnpaidIn [dblUnpaidIN],dblUnpaidOut [dblUnpaidOut],dblUnpaidBalance [dblUnpaidBalance],
   InventoryBalanceCarryForward dblInventoryBalanceCarryForward,strReceiptNumber,intReceiptId
FROM @tblResult T1