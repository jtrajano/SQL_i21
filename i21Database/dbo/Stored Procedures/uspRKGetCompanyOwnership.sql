CREATE PROC [dbo].[uspRKGetCompanyOwnership]

       @dtmFromTransactionDate datetime = null,
	   @dtmToTransactionDate datetime = null,
	   @intCommodityId int =  null

AS

DECLARE @tblResult TABLE
(Id INT identity(1,1),
	dtmDate datetime,
	strItemNo nvarchar(50),
	dblUnpaidIn numeric(18, 6),
	dblUnpaidOut numeric(18, 6),
	dblUnpaidBalance numeric(18, 6),
	strDistributionOption nvarchar(50),
	InventoryBalanceCarryForward numeric(18, 6)
)
INSERT INTO @tblResult (strItemNo,dtmDate,dblUnpaidIn,dblUnpaidOut,dblUnpaidBalance,InventoryBalanceCarryForward)
select  null,null, null,null,sum(dblUnpaidBalance),sum(InventoryBalanceCarryForward)  from (
SELECT strItemNo,CONVERT(VARCHAR(10),dtmDate,110) dtmDate,dblUnpaidIn,dblUnpaidOut, (dblUnpaidIn-dblUnpaidOut) dblUnpaidBalance,
	(SELECT sum(dblQty) BalanceForward
				FROM tblICInventoryTransaction it 
				join tblICItem i on i.intItemId=it.intItemId
				JOIN tblICItemLocation il on it.intItemLocationId=il.intItemLocationId and il.strDescription <> 'In-Transit' 
				WHERE intCommodityId=@intCommodityId and dtmDate < @dtmFromTransactionDate) InventoryBalanceCarryForward 
 from (
SELECT *,
(isnull(dblUnitCost,0))/case when isnull(dblUnitCost1,0) =0  then 1 else dblUnitCost1 end    dblUnpaidIn,
isnull((isnull(dblUnitCost,0))/case when isnull(dblUnitCost1,0) =0  then 1 else dblUnitCost1 end,0)-isnull((isnull(dblUnitCost,0)-isnull(dblQtyReceived,0))/case when isnull(dblUnitCost1,0) =0  then 1 else dblUnitCost1 end,0)  dblUnpaidOut
FROM (
SELECT dtmDate, dblOpenReceive*dblUnitCost AS dblUnitCost
			,dblUnitCost dblUnitCost1,
			 ir.intInventoryReceiptItemId ,i.strItemNo,
			ISNULL((SELECT (bd.dblQtyReceived*bd.dblCost)-isnull(b.dblAmountDue,0) FROM tblAPBillDetail bd 
				INNER JOIN tblAPBill b on b.intBillId=bd.intBillId
				WHERE bd.intInventoryReceiptItemId=ir.intInventoryReceiptItemId and ysnPosted=1),0) AS dblQtyReceived
 from 
 vyuAPBillDetail ap
 JOIN tblICInventoryReceiptItem ir on ap.intInventoryReceiptId=ir.intInventoryReceiptId
 JOIN tblICItem i on i.intItemId=ir.intItemId where dtmDate < @dtmFromTransactionDate and  i.intCommodityId= @intCommodityId)t)t2
 UNION 
 SELECT  i.strItemNo,CONVERT(VARCHAR(10),dtmTicketDateTime,110) AS dtmDate,
	    dblGrossUnits AS dblUnpaidIn,
		0 as dblUnpaidOut,
		dblGrossUnits as dblUnpaidBalance, null InventoryBalanceCarryForward
 FROM 
 tblICInventoryReceiptItem ir 
 JOIN tblICInventoryReceipt r on r.intInventoryReceiptId=ir.intInventoryReceiptId  and ysnPosted=1
 JOIN tblICItem i on i.intItemId=ir.intItemId
 JOIN tblSCTicket st ON st.intTicketId = ir.intSourceId AND strDistributionOption IN ('DP')
 where dtmTicketDateTime < @dtmFromTransactionDate)t 


INSERT INTO @tblResult (strItemNo,dtmDate,dblUnpaidIn,dblUnpaidOut,dblUnpaidBalance,strDistributionOption)
SELECT strItemNo,dtmDate,dblUnpaidIn,-dblUnpaidOut, dblUnpaidIn-dblUnpaidOut dblUnpaidBalance,strDistributionOption from (
SELECT *,
(isnull(dblUnitCost,0))/case when isnull(dblUnitCost1,0) =0  then 1 else dblUnitCost1 end    dblUnpaidIn,
isnull((isnull(dblUnitCost,0))/case when isnull(dblUnitCost1,0) =0  then 1 else dblUnitCost1 end,0)-isnull((isnull(dblUnitCost,0)-isnull(dblQtyReceived,0))/isnull(dblUnitCost1,1),0)  dblUnpaidOut
FROM (
SELECT CONVERT(VARCHAR(10),dtmDate,110) dtmDate, dblOpenReceive*dblUnitCost AS dblUnitCost
			,dblUnitCost dblUnitCost1,
			 ir.intInventoryReceiptItemId ,i.strItemNo,
			ISNULL((SELECT (bd.dblQtyReceived*bd.dblCost)-isnull(b.dblAmountDue,0) FROM tblAPBillDetail bd 
				INNER JOIN tblAPBill b on b.intBillId=bd.intBillId
				WHERE bd.intInventoryReceiptItemId=ir.intInventoryReceiptItemId and ysnPosted=1),0) AS dblQtyReceived
				,strDistributionOption
 from 
 vyuAPBillDetail ap
 JOIN tblICInventoryReceiptItem ir on ap.intInventoryReceiptId=ir.intInventoryReceiptId
 LEFT JOIN tblSCTicket st ON st.intTicketId = ir.intSourceId
 JOIN tblICItem i on i.intItemId=ir.intItemId where dtmDate between @dtmFromTransactionDate and @dtmToTransactionDate and i.intCommodityId= @intCommodityId
 )t where dblQtyReceived <> 0)t2

 UNION 
 SELECT  i.strItemNo,CONVERT(VARCHAR(10),dtmTicketDateTime,110) AS dtmDate,
	    dblGrossUnits AS dblUnpaidIn,
		0 as dblUnpaidOut,
		dblGrossUnits as dblUnpaidBalance,strDistributionOption
 FROM 
 tblICInventoryReceiptItem ir 
 JOIN tblICInventoryReceipt r on r.intInventoryReceiptId=ir.intInventoryReceiptId  and ysnPosted=1
 JOIN tblICItem i on i.intItemId=ir.intItemId
 JOIN tblSCTicket st ON st.intTicketId = ir.intSourceId AND strDistributionOption IN ('DP')
 WHERE dtmTicketDateTime between @dtmFromTransactionDate and @dtmToTransactionDate and i.intCommodityId= @intCommodityId
 ORDER BY dtmDate

 SELECT convert(int,ROW_NUMBER() OVER (ORDER BY dtmDate)) intRowNum,
   dtmDate dtmDate,strDistributionOption [strDistribution],dblUnpaidIn [dblUnpaidIN],dblUnpaidOut [dblUnpaidOut],dblUnpaidBalance [dblUnpaidBalance],
   InventoryBalanceCarryForward dblInventoryBalanceCarryForward
FROM @tblResult T1