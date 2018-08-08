CREATE PROC [dbo].[uspRKGetInventoryBalance]
       @dtmFromTransactionDate datetime = null,
	   @dtmToTransactionDate datetime = null,
	   @intCommodityId int =  null,
	   @intItemId int= null,
	   @strPositionIncludes nvarchar(100) = NULL,
	   @intLocationId int = null
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
dblInvoiceQty  NUMERIC(24,10),
dblSalesInTransit  NUMERIC(24,10),
tranDSInQty  NUMERIC(24,10)

)

DECLARE @intCommodityUnitMeasureId INT= NULL
SELECT @intCommodityUnitMeasureId=intCommodityUnitMeasureId from tblICCommodityUnitMeasure where intCommodityId=@intCommodityId AND ysnDefault=1

SELECT 
	*
	,isnull(tranShipQty,0)+isnull(tranRecQty,0)+isnull(dblAdjustmentQty,0)+isnull(dblCountQty,0)+isnull(dblInvoiceQty,0) BalanceForward 
INTO #temp
FROM (
	SELECT 
		CONVERT(VARCHAR(10),dtmDate,110) dtmDate
		,(SELECT strShipmentNumber FROM tblICInventoryShipment sh WHERE sh.strShipmentNumber=it.strTransactionId) tranShipmentNumber
		,(SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(u.intUnitMeasureId,@intCommodityUnitMeasureId,dblQty) FROM tblICInventoryShipment sh WHERE sh.strShipmentNumber=it.strTransactionId) tranShipQty
		,(SELECT strReceiptNumber FROM tblICInventoryReceipt ir WHERE ir.strReceiptNumber=it.strTransactionId) tranReceiptNumber
		,(SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(u.intUnitMeasureId,@intCommodityUnitMeasureId,dblQty) FROM tblICInventoryReceipt ir WHERE ir.strReceiptNumber=it.strTransactionId) tranRecQty
		,(SELECT strAdjustmentNo FROM tblICInventoryAdjustment ia WHERE ia.strAdjustmentNo=it.strTransactionId) tranAdjNumber
		,(SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(u.intUnitMeasureId,@intCommodityUnitMeasureId,dblQty) FROM tblICInventoryAdjustment ia WHERE ia.strAdjustmentNo=it.strTransactionId) dblAdjustmentQty
		,(SELECT strCountNo FROM tblICInventoryCount ia WHERE ia.strCountNo=it.strTransactionId) tranCountNumber
		,(SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(u.intUnitMeasureId,@intCommodityUnitMeasureId,dblQty) FROM tblICInventoryCount ia WHERE ia.strCountNo=it.strTransactionId ) dblCountQty
		,(SELECT top 1 strInvoiceNumber FROM tblARInvoice ia JOIN tblARInvoiceDetail ad on  ia.intInvoiceId=ad.intInvoiceId and isnull(ad.strShipmentNumber,'')=''  WHERE ia.strInvoiceNumber=it.strTransactionId) tranInvoiceNumber
		,ROUND((SELECT TOP 1 dbo.fnCTConvertQuantityToTargetCommodityUOM(u.intUnitMeasureId,@intCommodityUnitMeasureId,dblQty) FROM tblARInvoice ia JOIN tblARInvoiceDetail ad on  ia.intInvoiceId=ad.intInvoiceId and isnull(ad.strShipmentNumber,'')=''  WHERE ia.strInvoiceNumber=it.strTransactionId ),6) dblInvoiceQty
		,0.0 dblSalesInTransit
		,0.0 tranDSInQty
	FROM tblICInventoryTransaction it 
	JOIN tblICItem i on i.intItemId=it.intItemId and it.ysnIsUnposted=0 and it.intTransactionTypeId in(4, 5, 10, 23,33, 44)
	join tblICItemUOM u on it.intItemId=u.intItemId and u.intItemUOMId=it.intItemUOMId 
	--JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=@intCommodityId AND u.intUnitMeasureId=ium.intUnitMeasureId  
	JOIN tblICItemLocation il on it.intItemLocationId=il.intItemLocationId
										AND  il.intLocationId  IN (
													SELECT intCompanyLocationId FROM tblSMCompanyLocation
													WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
													WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
													ELSE isnull(ysnLicensed, 0) END)
		and isnull(il.strDescription,'') <> 'In-Transit'
	WHERE i.intCommodityId=@intCommodityId  
	and i.intItemId= case when isnull(@intItemId,0)=0 then i.intItemId else @intItemId end and strTransactionId not like'%IS%'
	and il.intLocationId =  case when isnull(@intLocationId,0)=0 then il.intLocationId else @intLocationId end

UNION --Direct From Scale
SELECT dtmDate,'' tranShipmentNumber,0.0 tranShipQty,strReceiptNumber tranReceiptNumber,dblInQty tranRecQty,''  tranAdjNumber,
		0.0 dblAdjustmentQty,'' tranCountNumber,0.0 dblCountQty,'' tranInvoiceNumber,0.0 dblInvoiceQty,0.0 dblSalesInTransit
		,0.0 tranDSInQty from(
select  CONVERT(VARCHAR(10),st.dtmTicketDateTime,110) dtmDate,CASE WHEN strInOutFlag='I' THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(u.intUnitMeasureId,@intCommodityUnitMeasureId,dblNetUnits) ELSE 0 END dblInQty,r.strReceiptNumber  
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
WHERE  i.intCommodityId= @intCommodityId
		and i.intItemId= case when isnull(@intItemId,0)=0 then i.intItemId else @intItemId end and isnull(strType,'') <> 'Other Charge'
		 and gs.strOwnedPhysicalStock='Customer' and  gs.intStorageScheduleTypeId > 0 
		 and st.intProcessingLocationId =  case when isnull(@intLocationId,0)=0 then st.intProcessingLocationId else @intLocationId end
		 and r.intSourceType = 1)a

--UNION ALL--Spot
--SELECT dtmDate,'' tranShipmentNumber,0.0 tranShipQty,strReceiptNumber tranReceiptNumber,0.0 tranRecQty,''  tranAdjNumber,
--		0.0 dblAdjustmentQty,'' tranCountNumber,0.0 dblCountQty,'' tranInvoiceNumber,0.0 dblInvoiceQty,0.0 dblSalesInTransit 
--		, dblInQty tranDSInQty from(
--select  CONVERT(VARCHAR(10),r.dtmReceiptDate,110) dtmDate,dbo.fnCTConvertQuantityToTargetCommodityUOM(u.intUnitMeasureId,@intCommodityUnitMeasureId,ri.dblOpenReceive) dblInQty,r.strReceiptNumber  
--FROM tblSCTicket st
--		JOIN tblICItem i on i.intItemId=st.intItemId 
--												AND  st.intTicketLocationId  IN (
--													SELECT intCompanyLocationId FROM tblSMCompanyLocation
--													WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
--													WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
--													ELSE isnull(ysnLicensed, 0) END)
--		JOIN tblICInventoryReceiptItem ri on ri.intSourceId=st.intTicketId
--		join tblICInventoryReceipt r on r.intInventoryReceiptId=ri.intInventoryReceiptId
--		JOIN tblGRStorageType gs on gs.intStorageScheduleTypeId=st.intStorageScheduleTypeId  
--		JOIN tblICItemUOM u on st.intItemId=u.intItemId and u.ysnStockUnit=1 
--WHERE  i.intCommodityId= @intCommodityId
--		and i.intItemId= case when isnull(@intItemId,0)=0 then i.intItemId else @intItemId end and isnull(strType,'') <> 'Other Charge'
--		-- and gs.strOwnedPhysicalStock='Customer' and  gs.intStorageScheduleTypeId > 0 
--		 and r.intLocationId = case when isnull(@intLocationId,0)=0 then r.intLocationId else @intLocationId end
--		 AND r.ysnPosted = 1)a

UNION all --IR came from Delivery Sheet
SELECT CONVERT(VARCHAR(10),dtmDate,110) dtmDate,'' tranShipmentNumber,0.0 tranShipQty,strReceiptNumber tranReceiptNumber,0.0 tranRecQty,''  tranAdjNumber,
		0.0 dblAdjustmentQty,'' tranCountNumber,0.0 dblCountQty,'' tranInvoiceNumber,0.0 dblInvoiceQty,0.0 dblSalesInTransit 
		, dblInQty tranDSInQty from(
select  CONVERT(VARCHAR(10),r.dtmReceiptDate,110) dtmDate,dbo.fnCTConvertQuantityToTargetCommodityUOM(u.intUnitMeasureId,@intCommodityUnitMeasureId,ri.dblOpenReceive) dblInQty,r.strReceiptNumber  
FROM tblSCDeliverySheet DS
		JOIN tblICItem i on i.intItemId=DS.intItemId 
												AND  DS.intCompanyLocationId  IN (
													SELECT intCompanyLocationId FROM tblSMCompanyLocation
													WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
													WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
													ELSE isnull(ysnLicensed, 0) END)
		JOIN tblICInventoryReceiptItem ri on ri.intSourceId=DS.intDeliverySheetId
		join tblICInventoryReceipt r on r.intInventoryReceiptId=ri.intInventoryReceiptId
		JOIN tblSCDeliverySheetSplit DSS ON DS.intDeliverySheetId = DSS.intDeliverySheetId  AND DSS.intEntityId = r.intEntityVendorId
		JOIN tblGRStorageType gs on gs.intStorageScheduleTypeId=DSS.intStorageScheduleTypeId  
		JOIN tblICItemUOM u on DS.intItemId=u.intItemId and u.ysnStockUnit=1 
WHERE  i.intCommodityId= @intCommodityId
		and i.intItemId= case when isnull(@intItemId,0)=0 then i.intItemId else @intItemId end and isnull(strType,'') <> 'Other Charge'
		 and gs.strOwnedPhysicalStock='Customer' and  gs.intStorageScheduleTypeId > 0 
		 and DS.intCompanyLocationId = case when isnull(@intLocationId,0)=0 then DS.intCompanyLocationId else @intLocationId end
		 AND DS.ysnPost = 1 AND r.intSourceType = 5)a
		 

union 
SELECT CONVERT(VARCHAR(10),dtmDate,110) dtmDate,strShipmentNumber tranShipmentNumber,-dblOutQty tranShipQty,'' tranReceiptNumber,0.0 tranRecQty,''  tranAdjNumber,
		0.0 dblAdjustmentQty,'' tranCountNumber,0.0 dblCountQty,'' tranInvoiceNumber,0.0 dblInvoiceQty, ISNULL(dblSalesInTransit,0) dblSalesInTransit 
		,0.0 tranDSInQty from(
SELECT  CONVERT(VARCHAR(10),st.dtmTicketDateTime,110) dtmDate,CASE WHEN strInOutFlag='O' THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(intUnitMeasureId,@intCommodityUnitMeasureId,ri.dblQuantity) ELSE 0 END dblOutQty,r.strShipmentNumber  
,ROUND(CASE WHEN EXISTS(SELECT TOP 1 * FROM tblARInvoice ia JOIN tblARInvoiceDetail ad on  ia.intInvoiceId=ad.intInvoiceId WHERE ad.intInventoryShipmentItemId=ri.intInventoryShipmentItemId and ia.ysnPosted = 1) THEN 0 
	ELSE dbo.fnCTConvertQuantityToTargetCommodityUOM(intUnitMeasureId,@intCommodityUnitMeasureId, case when ri.intOwnershipType = 1 then ri.dblQuantity else 0 end) END,6) dblSalesInTransit
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
WHERE  i.intCommodityId= @intCommodityId
		and i.intItemId= case when isnull(@intItemId,0)=0 then i.intItemId else @intItemId end and isnull(strType,'') <> 'Other Charge'
		and gs.strOwnedPhysicalStock='Customer'
		and st.intProcessingLocationId = case when isnull(@intLocationId,0)=0 then st.intProcessingLocationId  else @intLocationId end)a

union all--IS came from Delivery Sheet
SELECT CONVERT(VARCHAR(10),dtmDate,110) dtmDate,strShipmentNumber tranShipmentNumber,-dblOutQty tranShipQty,'' tranReceiptNumber,0.0 tranRecQty,''  tranAdjNumber,
		0.0 dblAdjustmentQty,'' tranCountNumber,0.0 dblCountQty,'' tranInvoiceNumber,0.0 dblInvoiceQty, ISNULL(dblSalesInTransit,0) dblSalesInTransit 
		,0.0 tranDSInQty from(
SELECT  CONVERT(VARCHAR(10),r.dtmShipDate,110) dtmDate, dbo.fnCTConvertQuantityToTargetCommodityUOM(intUnitMeasureId,@intCommodityUnitMeasureId,ri.dblQuantity) dblOutQty,r.strShipmentNumber  
,ROUND(CASE WHEN EXISTS(SELECT TOP 1 * FROM tblARInvoice ia JOIN tblARInvoiceDetail ad on  ia.intInvoiceId=ad.intInvoiceId WHERE ad.intInventoryShipmentItemId=ri.intInventoryShipmentItemId and ia.ysnPosted = 1) THEN 0 
	ELSE dbo.fnCTConvertQuantityToTargetCommodityUOM(intUnitMeasureId,@intCommodityUnitMeasureId, case when ri.intOwnershipType = 1 then ri.dblQuantity else 0 end) END,6) dblSalesInTransit
FROM tblSCDeliverySheet DS
		JOIN tblICItem i on i.intItemId=DS.intItemId 
												AND  DS.intCompanyLocationId  IN (
													SELECT intCompanyLocationId FROM tblSMCompanyLocation
													WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
													WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
													ELSE isnull(ysnLicensed, 0) END)
		JOIN tblICInventoryShipmentItem ri on ri.intSourceId=DS.intDeliverySheetId
		join tblICInventoryShipment r on r.intInventoryShipmentId=ri.intInventoryShipmentId
		JOIN tblSCDeliverySheetSplit DSS ON DS.intDeliverySheetId = DSS.intDeliverySheetId  AND DSS.intEntityId = r.intEntityId 
		JOIN tblGRStorageType gs on gs.intStorageScheduleTypeId=DSS.intStorageScheduleTypeId  
		JOIN tblICItemUOM u on DS.intItemId=u.intItemId and u.ysnStockUnit=1
WHERE  i.intCommodityId= @intCommodityId
		and i.intItemId= case when isnull(@intItemId,0)=0 then i.intItemId else @intItemId end and isnull(strType,'') <> 'Other Charge'
		and gs.strOwnedPhysicalStock='Customer'
		and DS.intCompanyLocationId = case when isnull(@intLocationId,0)=0 then  DS.intCompanyLocationId  else @intLocationId end)a

UNION ALL --Delivery Sheet
select dtmDate,'' tranShipmentNumber,0.0 tranShipQty,'' tranReceiptNumber,tranRecQty tranRecQty,''  tranAdjNumber,
		0.0 dblAdjustmentQty,'' tranCountNumber,0.0 dblCountQty,'' tranInvoiceNumber,0.0 dblInvoiceQty,0.0 dblSalesInTransit
		,0.0 tranDSInQty 
from(
SELECT
	CONVERT(VARCHAR(10),st.dtmTicketDateTime,110) dtmDate,
	DSS.strDistributionOption,
	'' strShipDistributionOption,
	'' as strAdjDistributionOption,
	'' as strCountDistributionOption,
	'' as tranShipmentNumber,
	(CASE WHEN strInOutFlag='O' THEN dblNetUnits * (DSS.dblSplitPercent/100) ELSE 0 END)  tranShipQty,
	'' tranReceiptNumber,
	(CASE WHEN strInOutFlag='I' THEN dblNetUnits * (DSS.dblSplitPercent/100) ELSE 0 END) tranRecQty,
	'' tranAdjNumber,
	0.0 dblAdjustmentQty,
	'' tranCountNumber,
	0.0 dblCountQty,
	'' tranInvoiceNumber,
	0.0 dblInvoiceQty,
	null intInventoryReceiptId,
	NULL intInventoryShipmentId,
	null intInventoryAdjustmentId,
	null intInventoryCountId,
	null intInvoiceId,
	DS.intDeliverySheetId,
	DS.strDeliverySheetNumber + '*' AS deliverySheetNumber,
	null intTicketId,
	'' AS ticketNumber  
FROM tblSCTicket st
	JOIN tblICItem i on i.intItemId=st.intItemId
	JOIN tblSCDeliverySheet DS ON st.intDeliverySheetId = DS.intDeliverySheetId
	JOIN tblSCDeliverySheetSplit DSS ON DS.intDeliverySheetId = DSS.intDeliverySheetId
WHERE i.intCommodityId= @intCommodityId
	AND i.intItemId= case when isnull(@intItemId,0)=0 then i.intItemId else @intItemId end and isnull(strType,'') <> 'Other Charge'
	AND st.intProcessingLocationId = case when isnull(@intLocationId,0)=0 then  st.intProcessingLocationId  else @intLocationId end
	AND  st.intProcessingLocationId  IN (
										SELECT intCompanyLocationId FROM tblSMCompanyLocation
										WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
										WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
										ELSE isnull(ysnLicensed, 0) END)
	AND DS.ysnPost = 0 AND st.strTicketStatus = 'H')t
	

UNION ALL --On Hold without Delivery Sheet
select dtmDate,'' tranShipmentNumber,abs(isnull(tranShipQty,0)) * -1 tranShipQty,'' tranReceiptNumber,tranRecQty tranRecQty,''  tranAdjNumber,
		0.0 dblAdjustmentQty,'' tranCountNumber,0.0 dblCountQty,'' tranInvoiceNumber,0.0 dblInvoiceQty,0.0 dblSalesInTransit,0.0 tranDSInQty 
from(
SELECT
	CONVERT(VARCHAR(10),st.dtmTicketDateTime,110) dtmDate,
	st.strDistributionOption,
	'' strShipDistributionOption,
	'' as strAdjDistributionOption,
	'' as strCountDistributionOption,
	'' as tranShipmentNumber,
	(CASE WHEN strInOutFlag='O' THEN dblNetUnits  ELSE 0 END)  tranShipQty,
	'' tranReceiptNumber,
	(CASE WHEN strInOutFlag='I' THEN dblNetUnits  ELSE 0 END) tranRecQty,
	'' tranAdjNumber,
	0.0 dblAdjustmentQty,
	'' tranCountNumber,
	0.0 dblCountQty,
	'' tranInvoiceNumber,
	0.0 dblInvoiceQty,
	null intInventoryReceiptId,
	NULL intInventoryShipmentId,
	null intInventoryAdjustmentId,
	null intInventoryCountId,
	null intInvoiceId,
	null intDeliverySheetId,
	'' AS deliverySheetNumber ,
	st.intTicketId,
	st.strTicketNumber AS ticketNumber 
FROM tblSCTicket st
	JOIN tblICItem i on i.intItemId=st.intItemId
WHERE  i.intCommodityId= @intCommodityId
	AND i.intItemId= case when isnull(@intItemId,0)=0 then i.intItemId else @intItemId end and isnull(strType,'') <> 'Other Charge'
	AND st.intProcessingLocationId =  case when isnull(@intLocationId,0)=0 then  st.intProcessingLocationId  else @intLocationId end
	AND  st.intProcessingLocationId  IN (
											SELECT intCompanyLocationId FROM tblSMCompanyLocation
											WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
											WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
											ELSE isnull(ysnLicensed, 0) END)
	AND st.intDeliverySheetId IS NULL AND st.strTicketStatus = 'H')t1

 )t

--Previous value start 
INSERT INTO @tblResultInventory (BalanceForward)
SELECT sum(BalanceForward) BalanceForward 
FROM(
	select BalanceForward
	from #temp
	where  convert(datetime,CONVERT(VARCHAR(10),dtmDate,110),110)  < convert(datetime,CONVERT(VARCHAR(10),@dtmFromTransactionDate,110),110)   
 )t
 
--Previous value End


INSERT INTO @tblResultInventory(
	dtmDate
	,tranShipmentNumber
	,tranShipQty
	,tranReceiptNumber
	,tranRecQty
	,tranAdjNumber
	,dblAdjustmentQty
	,tranCountNumber
	,dblCountQty
	,tranInvoiceNumber
	,dblInvoiceQty
	,BalanceForward
	,dblSalesInTransit
	,tranDSInQty
)
SELECT 
	dtmDate
	,tranShipmentNumber
	,tranShipQty
	,tranReceiptNumber
	,tranRecQty 
	,tranAdjNumber
	,dblAdjustmentQty
	,tranCountNumber
	,dblCountQty
	,tranInvoiceNumber
	,dblInvoiceQty
	,isnull(tranShipQty,0)+isnull(tranRecQty,0)+isnull(dblAdjustmentQty,0)+isnull(dblCountQty,0)+isnull(dblInvoiceQty,0) BalanceForward
	,dblSalesInTransit
	,tranDSInQty
FROM(
	select * 
	from #temp 
	where convert(datetime,CONVERT(VARCHAR(10),dtmDate,110),110) BETWEEN
		 convert(datetime,CONVERT(VARCHAR(10),@dtmFromTransactionDate,110),110) AND convert(datetime,CONVERT(VARCHAR(10),@dtmToTransactionDate,110),110)
)t


SELECT *
FROM(
	select 
		ISNULL(dtmDate,'') dtmDate
		,sum(tranShipQty) tranShipQty
		,sum(tranRecQty) tranRecQty
		,sum(dblAdjustmentQty) dblAdjustmentQty
		,sum(dblCountQty) dblCountQty
		,sum(dblInvoiceQty) dblInvoiceQty
		,sum(BalanceForward) BalanceForward
		,sum(dblSalesInTransit) dblSalesInTransit
		,sum(tranDSInQty) tranDSInQty
	from @tblResultInventory T1 
	group by dtmDate
)t