﻿CREATE PROC [dbo].[uspRKGetInventoryBalance]
       @dtmFromTransactionDate datetime = null,
	   @dtmToTransactionDate datetime = null,
	   @intCommodityId int =  null,
	   @intItemId int= null,
	   @strPositionIncludes nvarchar(100) = NULL
AS

DECLARE @tblResultInventory TABLE
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
tranInvoiceNumber  nvarchar(50),
dblInvoiceQty  NUMERIC(24,10)
)

DECLARE @intCommodityUnitMeasureId INT= NULL
SELECT @intCommodityUnitMeasureId=intCommodityUnitMeasureId from tblICCommodityUnitMeasure where intCommodityId=@intCommodityId AND ysnDefault=1

SELECT *,isnull(tranShipQty,0)+isnull(tranRecQty,0)+isnull(dblAdjustmentQty,0)+isnull(dblCountQty,0)+isnull(dblInvoiceQty,0) BalanceForward into #temp
 FROM (
 SELECT dtmDate,
(SELECT strShipmentNumber FROM tblICInventoryShipment sh WHERE sh.strShipmentNumber=it.strTransactionId) tranShipmentNumber,
(SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,@intCommodityUnitMeasureId,dblQty) FROM tblICInventoryShipment sh WHERE sh.strShipmentNumber=it.strTransactionId) tranShipQty,
(SELECT strReceiptNumber FROM tblICInventoryReceipt ir WHERE ir.strReceiptNumber=it.strTransactionId) tranReceiptNumber,
(SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,@intCommodityUnitMeasureId,dblQty) FROM tblICInventoryReceipt ir WHERE ir.strReceiptNumber=it.strTransactionId) tranRecQty,
(SELECT strAdjustmentNo FROM tblICInventoryAdjustment ia WHERE ia.strAdjustmentNo=it.strTransactionId) tranAdjNumber,
(SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,@intCommodityUnitMeasureId,dblQty) FROM tblICInventoryAdjustment ia WHERE ia.strAdjustmentNo=it.strTransactionId) dblAdjustmentQty,
(SELECT strCountNo FROM tblICInventoryCount ia WHERE ia.strCountNo=it.strTransactionId) tranCountNumber,
(SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,@intCommodityUnitMeasureId,dblQty) FROM tblICInventoryCount ia WHERE ia.strCountNo=it.strTransactionId ) dblCountQty,
(SELECT top 1 strInvoiceNumber FROM tblARInvoice ia
	JOIN tblARInvoiceDetail ad on  ia.intInvoiceId=ad.intInvoiceId and isnull(ad.strShipmentNumber,'')=''  
	WHERE ia.strInvoiceNumber=it.strTransactionId) tranInvoiceNumber,
ROUND((SELECT TOP 1 dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,@intCommodityUnitMeasureId,dblQty) FROM tblARInvoice ia
	JOIN tblARInvoiceDetail ad on  ia.intInvoiceId=ad.intInvoiceId and isnull(ad.strShipmentNumber,'')=''  
	WHERE ia.strInvoiceNumber=it.strTransactionId ),6) dblInvoiceQty

FROM tblICInventoryTransaction it 
JOIN tblICItem i on i.intItemId=it.intItemId and it.ysnIsUnposted=0 and it.intTransactionTypeId in(4, 5, 10, 23,33, 44)
join tblICItemUOM u on it.intItemId=u.intItemId and u.intItemUOMId=it.intItemUOMId 
JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=@intCommodityId AND u.intUnitMeasureId=ium.intUnitMeasureId  
JOIN tblICItemLocation il on it.intItemLocationId=il.intItemLocationId
										AND  il.intLocationId  IN (
													SELECT intCompanyLocationId FROM tblSMCompanyLocation
													WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
													WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
													ELSE isnull(ysnLicensed, 0) END)
 and isnull(il.strDescription,'') <> 'In-Transit' 
WHERE i.intCommodityId=@intCommodityId  
and i.intItemId= case when isnull(@intItemId,0)=0 then i.intItemId else @intItemId end and strTransactionId not like'%IS%'

UNION
SELECT dtmDate,'' tranShipmentNumber,0.0 tranShipQty,strReceiptNumber tranReceiptNumber,dblInQty tranRecQty,''  tranAdjNumber,
		0.0 dblAdjustmentQty,'' tranCountNumber,0.0 dblCountQty,'' tranInvoiceNumber,0.0 dblInvoiceQty from(
select  CONVERT(VARCHAR(10),st.dtmTicketDateTime,110) dtmDate,CASE WHEN strInOutFlag='I' THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,@intCommodityUnitMeasureId,dblNetUnits) ELSE 0 END dblInQty,r.strReceiptNumber  
FROM tblSCTicket st
		JOIN tblICItem i on i.intItemId=st.intItemId 
												AND  st.intProcessingLocationId  IN (
													SELECT intCompanyLocationId FROM tblSMCompanyLocation
													WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
													WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
													ELSE isnull(ysnLicensed, 0) END)
		JOIN tblICInventoryReceiptItem ri on ri.intSourceId=st.intTicketId
		join tblICInventoryReceipt r on r.intInventoryReceiptId=ri.intInventoryReceiptId
		JOIN tblGRStorageType gs on gs.intStorageScheduleTypeId=st.intStorageScheduleTypeId  
			JOIN tblICItemUOM u on st.intItemId=u.intItemId and u.ysnStockUnit=1
	JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=@intCommodityId AND u.intUnitMeasureId=ium.intUnitMeasureId   
WHERE  i.intCommodityId= @intCommodityId
		and i.intItemId= case when isnull(@intItemId,0)=0 then i.intItemId else @intItemId end and isnull(strType,'') <> 'Other Charge'
		 and gs.strOwnedPhysicalStock='Customer' and  gs.intStorageScheduleTypeId > 0 )a

union
SELECT dtmDate,strShipmentNumber tranShipmentNumber,-dblOutQty tranShipQty,'' tranReceiptNumber,0.0 tranRecQty,''  tranAdjNumber,
		0.0 dblAdjustmentQty,'' tranCountNumber,0.0 dblCountQty,'' tranInvoiceNumber,0.0 dblInvoiceQty from(
SELECT  CONVERT(VARCHAR(10),st.dtmTicketDateTime,110) dtmDate,CASE WHEN strInOutFlag='O' THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,@intCommodityUnitMeasureId,dblNetUnits) ELSE 0 END dblOutQty,r.strShipmentNumber  
FROM tblSCTicket st
		JOIN tblICItem i on i.intItemId=st.intItemId 
												AND  st.intProcessingLocationId  IN (
													SELECT intCompanyLocationId FROM tblSMCompanyLocation
													WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
													WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
													ELSE isnull(ysnLicensed, 0) END)
		JOIN tblICInventoryShipmentItem ri on ri.intSourceId=st.intTicketId
		join tblICInventoryShipment r on r.intInventoryShipmentId=ri.intInventoryShipmentId
		JOIN tblGRStorageType gs on gs.intStorageScheduleTypeId=st.intStorageScheduleTypeId  
		JOIN tblICItemUOM u on st.intItemId=u.intItemId and u.ysnStockUnit=1
		JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=@intCommodityId AND u.intUnitMeasureId=ium.intUnitMeasureId  
WHERE  i.intCommodityId= @intCommodityId
		and i.intItemId= case when isnull(@intItemId,0)=0 then i.intItemId else @intItemId end and isnull(strType,'') <> 'Other Charge'
		and gs.strOwnedPhysicalStock='Customer')a
)t

--Previous value start 
INSERT INTO @tblResultInventory (BalanceForward)
select sum(BalanceForward) BalanceForward from(
SELECT  BalanceForward
FROM #temp
WHERE  convert(datetime,CONVERT(VARCHAR(10),dtmDate,110),110)  < convert(datetime,CONVERT(VARCHAR(10),@dtmFromTransactionDate,110),110)   
 )t
 
--Previous value End


INSERT INTO @tblResultInventory(dtmDate,tranShipmentNumber,tranShipQty,tranReceiptNumber,tranRecQty,tranAdjNumber,dblAdjustmentQty,tranCountNumber,dblCountQty,tranInvoiceNumber,dblInvoiceQty,BalanceForward)

SELECT dtmDate,tranShipmentNumber,tranShipQty,tranReceiptNumber,tranRecQty,tranAdjNumber,dblAdjustmentQty,tranCountNumber,dblCountQty,tranInvoiceNumber,dblInvoiceQty,isnull(tranShipQty,0)+isnull(tranRecQty,0)+isnull(dblAdjustmentQty,0)+isnull(dblCountQty,0)+isnull(dblInvoiceQty,0) BalanceForward
 FROM (
 select * from #temp 
		WHERE convert(datetime,CONVERT(VARCHAR(10),dtmDate,110),110) BETWEEN
		 convert(datetime,CONVERT(VARCHAR(10),@dtmFromTransactionDate,110),110) AND convert(datetime,CONVERT(VARCHAR(10),@dtmToTransactionDate,110),110)
		)t

SELECT *
 FROM(SELECT dtmDate,sum(tranShipQty) tranShipQty,sum(tranRecQty) tranRecQty,sum(dblAdjustmentQty) dblAdjustmentQty,sum(dblCountQty) dblCountQty,sum(dblInvoiceQty) dblInvoiceQty,sum(BalanceForward) BalanceForward
FROM @tblResultInventory T1 group by dtmDate)t