﻿CREATE PROC [dbo].[uspRKGetGrainInventory]
		@dtmFromTransactionDate date = null,
		@dtmToTransactionDate date = null,
		@intCommodityId int =  null,
		@intItemId int= null,
		@strPositionIncludes nvarchar(100) = NULL,
		@intLocationId int = null
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
tranInvoiceNumber  nvarchar(50),
dblInvoiceQty  NUMERIC(24,10),
tranCountNumber nvarchar(50),
dblCountQty NUMERIC(24,10),
strDistributionOption nvarchar(50),
strShipDistributionOption nvarchar(50),
strAdjDistributionOption nvarchar(50),
strCountDistributionOption nvarchar(50),
intInventoryReceiptId int,
intInventoryShipmentId int,
intInventoryAdjustmentId int,
intInventoryCountId int,
intInvoiceId int,
intDeliverySheetId int,
deliverySheetNumber nvarchar(50),
intTicketId int,
ticketNumber nvarchar(50)

)
DECLARE @intCommodityUnitMeasureId INT= NULL
SELECT @intCommodityUnitMeasureId=intCommodityUnitMeasureId from tblICCommodityUnitMeasure where intCommodityId=@intCommodityId AND ysnDefault=1



INSERT INTO @tblResult(dtmDate,strDistributionOption,strShipDistributionOption,strAdjDistributionOption,strCountDistributionOption,tranShipmentNumber,tranShipQty,
	tranReceiptNumber,tranRecQty,tranAdjNumber,dblAdjustmentQty,tranCountNumber,dblCountQty,tranInvoiceNumber,dblInvoiceQty
,intInventoryReceiptId ,intInventoryShipmentId,intInventoryAdjustmentId,intInventoryCountId,intInvoiceId,intDeliverySheetId,deliverySheetNumber,intTicketId,ticketNumber, BalanceForward)

SELECT *,round(isnull(tranShipQty,0)+isnull(tranRecQty,0)+isnull(dblAdjustmentQty,0)+isnull(dblCountQty,0),6) BalanceForward FROM 
(
--select distinct * from(
--SELECT dtmDate,
--	(SELECT top 1 strDistributionOption FROM tblICInventoryReceipt ir 
--	 JOIN tblICInventoryReceiptItem ir1 on ir.intInventoryReceiptId=ir1.intInventoryReceiptId
--	 JOIN tblSCTicket st ON st.intTicketId = ir1.intSourceId WHERE ir.strReceiptNumber=it.strTransactionId
--	 )strDistributionOption,

--	(SELECT top 1 strDistributionOption FROM tblICInventoryShipment ir 
--	 JOIN tblICInventoryShipmentItem ir1 on ir.intInventoryShipmentId=ir1.intInventoryShipmentId
--	 JOIN tblSCTicket st ON st.intTicketId = ir1.intSourceId WHERE ir.strShipmentNumber=it.strTransactionId) strShipDistributionOption,
--       CASE WHEN isnull((SELECT top 1 strAdjustmentNo FROM tblICInventoryAdjustment ia WHERE ia.strAdjustmentNo=it.strTransactionId),'')  <> '' THEN 'ADJ' ELSE '' END as strAdjDistributionOption,
--	   '' as strCountDistributionOption,
--(SELECT top 1 strShipmentNumber FROM tblICInventoryShipment sh WHERE sh.strShipmentNumber=it.strTransactionId) tranShipmentNumber,
--round(dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,@intCommodityUnitMeasureId,(SELECT TOP 1 dblQty FROM tblICInventoryShipment sh WHERE sh.strShipmentNumber=it.strTransactionId)) ,6)tranShipQty,
--(SELECT top 1 strReceiptNumber FROM tblICInventoryReceipt ir WHERE ir.strReceiptNumber=it.strTransactionId) tranReceiptNumber,

--round(dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,@intCommodityUnitMeasureId,(SELECT TOP 1 dblQty FROM tblICInventoryReceipt ir WHERE ir.strReceiptNumber=it.strTransactionId)) ,6) tranRecQty,

--isnull((SELECT top 1 strAdjustmentNo FROM tblICInventoryAdjustment ia WHERE ia.strAdjustmentNo=it.strTransactionId),'') tranAdjNumber,
--round(dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,@intCommodityUnitMeasureId,(SELECT TOP 1 dblQty FROM tblICInventoryAdjustment ia WHERE ia.strAdjustmentNo=it.strTransactionId)) ,6) dblAdjustmentQty,

--isnull((SELECT top 1 strCountNo FROM tblICInventoryCount ia WHERE ia.strCountNo=it.strTransactionId),'') tranCountNumber,
--round(dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,@intCommodityUnitMeasureId,(SELECT TOP 1 dblQty FROM tblICInventoryCount ia WHERE ia.strCountNo=it.strTransactionId )) ,6) dblCountQty,

--(SELECT top 1 strInvoiceNumber FROM tblARInvoice ia
--	JOIN tblARInvoiceDetail ad on  ia.intInvoiceId=ad.intInvoiceId and isnull(ad.strShipmentNumber,'')=''  
--	WHERE ia.strInvoiceNumber=it.strTransactionId) tranInvoiceNumber,

--ROUND(dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,@intCommodityUnitMeasureId,(SELECT TOP 1 dblQty FROM tblARInvoice ia
--																										JOIN tblARInvoiceDetail ad on  ia.intInvoiceId=ad.intInvoiceId and isnull(ad.strShipmentNumber,'')=''  
--																										WHERE ia.strInvoiceNumber=it.strTransactionId )) ,6) dblInvoiceQty,

--ROUND((SELECT TOP 1 intInventoryReceiptId FROM tblICInventoryReceipt ir WHERE ir.strReceiptNumber=it.strTransactionId),6) intInventoryReceiptId,
--ROUND((SELECT TOP 1 intInventoryShipmentId FROM tblICInventoryShipment sh WHERE sh.strShipmentNumber=it.strTransactionId) ,6)intInventoryShipmentId,
--ROUND((SELECT TOP 1 intInventoryAdjustmentId FROM tblICInventoryAdjustment ia WHERE ia.strAdjustmentNo=it.strTransactionId ),6) intInventoryAdjustmentId,
--ROUND((SELECT TOP 1 intInventoryCountId FROM tblICInventoryCount ia WHERE ia.strCountNo=it.strTransactionId ),6) intInventoryCountId,
--ROUND((SELECT top 1 ia.intInvoiceId FROM tblARInvoice ia
--	JOIN tblARInvoiceDetail ad on  ia.intInvoiceId=ad.intInvoiceId and isnull(ad.strShipmentNumber,'')=''  
--	WHERE ia.strInvoiceNumber=it.strTransactionId),6) intInvoiceId,
--	null intDeliverySheetId,
--	'' AS deliverySheetNumber ,
--	null intTicketId,
--	'' AS ticketNumber   

--FROM tblICInventoryTransaction it 
--JOIN tblICItem i on i.intItemId=it.intItemId and it.ysnIsUnposted=0 and it.intTransactionTypeId in(4, 5, 10, 23,33, 44)
--join tblICItemUOM u on it.intItemId=u.intItemId and u.intItemUOMId=it.intItemUOMId 
--JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=@intCommodityId AND u.intUnitMeasureId=ium.intUnitMeasureId  
--JOIN tblICItemLocation il on it.intItemLocationId=il.intItemLocationId and it.intItemId=il.intItemId and isnull(il.strDescription,'') <> 'In-Transit' 
--										AND  il.intLocationId  IN (
--													SELECT intCompanyLocationId FROM tblSMCompanyLocation
--													WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
--													WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
--													ELSE isnull(ysnLicensed, 0) END)
--WHERE i.intCommodityId=@intCommodityId
--AND i.intItemId= case when isnull(@intItemId,0)=0 then i.intItemId else @intItemId end 
--AND convert(datetime,CONVERT(VARCHAR(10),dtmDate,110),110) BETWEEN convert(datetime,CONVERT(VARCHAR(10),@dtmFromTransactionDate,110),110) 
--and convert(datetime,CONVERT(VARCHAR(10),@dtmToTransactionDate,110),110) and strTransactionId not like'%IS%' and strTransactionId not like'%STR%'
--AND il.intLocationId =  case when isnull(@intLocationId,0)=0 then il.intLocationId else @intLocationId end)t
--union --Direct From Scale
SELECT dtmDate,strDistributionOption strDistributionOption,'' strShipDistributionOption,
		'' as strAdjDistributionOption,
		'' as strCountDistributionOption,
		'' tranShipmentNumber,
		0.0 tranShipQty,
		strReceiptNumber tranReceiptNumber,
		dblInQty tranRecQty,
		'' tranAdjNumber,
		0.0 dblAdjustmentQty,
		'' tranCountNumber,
		0.0 dblCountQty,
		'' tranInvoiceNumber,
		0.0 dblInvoiceQty,
		intInventoryReceiptId,
		null intInventoryShipmentId,
		null intInventoryAdjustmentId,
		null intInventoryCountId,
		null intInvoiceId,
		null intDeliverySheetId,
		'' AS deliverySheetNumber,
		null intTicketId,
		'' AS ticketNumber    
FROM(
SELECT  CONVERT(VARCHAR(10),st.dtmTicketDateTime,110) dtmDate,
round(dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,@intCommodityUnitMeasureId,CASE WHEN strInOutFlag='I' THEN ri.dblOpenReceive ELSE 0 END) ,6) dblInQty,
r.strReceiptNumber,
		strDistributionOption ,r.intInventoryReceiptId
FROM tblSCTicket st
		JOIN tblICItem i on i.intItemId=st.intItemId 
		JOIN tblICInventoryReceiptItem ri on ri.intSourceId=st.intTicketId
									AND  st.intProcessingLocationId  IN (
													SELECT intCompanyLocationId FROM tblSMCompanyLocation
													WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
													WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
													ELSE isnull(ysnLicensed, 0) END)
		join tblICInventoryReceipt r on r.intInventoryReceiptId=ri.intInventoryReceiptId
		JOIN tblGRStorageType gs on gs.intStorageScheduleTypeId=st.intStorageScheduleTypeId 
		join tblICItemUOM u on st.intItemId=u.intItemId and u.ysnStockUnit=1
		JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=@intCommodityId AND u.intUnitMeasureId=ium.intUnitMeasureId   
WHERE convert(datetime,CONVERT(VARCHAR(10),st.dtmTicketDateTime,110),110) BETWEEN
		 convert(datetime,CONVERT(VARCHAR(10),@dtmFromTransactionDate,110),110) AND convert(datetime,CONVERT(VARCHAR(10),@dtmToTransactionDate,110),110)
		AND i.intCommodityId= @intCommodityId
		and i.intItemId= case when isnull(@intItemId,0)=0 then i.intItemId else @intItemId end and isnull(strType,'') <> 'Other Charge'
		--and  gs.strOwnedPhysicalStock='Customer' and  gs.intStorageScheduleTypeId > 0 
		AND st.intProcessingLocationId = case when isnull(@intLocationId,0)=0 then st.intProcessingLocationId else @intLocationId end
		AND r.intSourceType = 1)a

	UNION ALL --Inventory Adjustments
	SELECT dtmDate,
			'' strDistributionOption,
			'' strShipDistributionOption,
			'ADJ' as strAdjDistributionOption,
			'' as strCountDistributionOption,
			'' tranShipmentNumber,
			0.0 tranShipQty,
			'' tranReceiptNumber,
			0.0 tranRecQty,
			strAdjustmentNo tranAdjNumber,
			dblAdjustmentQty,
			'' tranCountNumber,
			0.0 dblCountQty,
			'' tranInvoiceNumber,
			0.0 dblInvoiceQty,
			null intInventoryReceiptId,
			null intInventoryShipmentId,
			intInventoryAdjustmentId,
			null intInventoryCountId,
			null intInvoiceId,
			null intDeliverySheetId,
			'' AS deliverySheetNumber,
			null intTicketId,
			'' AS ticketNumber    
	FROM(
		--Own
		SELECT  
			CONVERT(VARCHAR(10),IT.dtmDate,110) dtmDate
			,round(dbo.fnCTConvertQuantityToTargetCommodityUOM(intUnitMeasureId,@intCommodityUnitMeasureId,IT.dblQty) ,6) dblAdjustmentQty
			,IT.strTransactionId strAdjustmentNo
			,IT.intTransactionId intInventoryAdjustmentId
		FROM tblICInventoryTransaction IT 	
			INNER JOIN tblICItem Itm ON IT.intItemId = Itm.intItemId
			INNER JOIN tblICCommodity C ON Itm.intCommodityId = C.intCommodityId
			INNER JOIN tblICItemUOM u on Itm.intItemId=u.intItemId and u.ysnStockUnit=1
			INNER JOIN tblICItemLocation il on IT.intItemLocationId=il.intItemLocationId
											AND  il.intLocationId  IN (
														SELECT intCompanyLocationId FROM tblSMCompanyLocation
														WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
														WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
														ELSE isnull(ysnLicensed, 0) END)
		WHERE IT.intTransactionTypeId IN (10,15)
			AND IT.ysnIsUnposted = 0
			AND convert(DATETIME, CONVERT(VARCHAR(10), IT.dtmDate, 110), 110) BETWEEN convert(DATETIME, CONVERT(VARCHAR(10), @dtmFromTransactionDate, 110), 110) AND convert(DATETIME, CONVERT(VARCHAR(10), @dtmToTransactionDate, 110), 110) 
			AND C.intCommodityId = @intCommodityId 
			AND IT.intItemId = CASE WHEN isnull(@intItemId, 0) = 0 THEN IT.intItemId ELSE @intItemId END 
			AND il.intLocationId = case when isnull(@intLocationId,0)=0 then il.intLocationId else @intLocationId end 

		--Storage
		UNION ALL
		SELECT
			CONVERT(VARCHAR(10),IA.dtmPostedDate,110) dtmDate
			,round(IAD.dblAdjustByQuantity ,6) dblAdjustmentQty
			,IA.strAdjustmentNo strAdjustmentNo
			,IA.intInventoryAdjustmentId intInventoryAdjustmentId
		FROM tblICInventoryAdjustment IA
			INNER JOIN tblICInventoryAdjustmentDetail IAD ON IA.intInventoryAdjustmentId = IAD.intInventoryAdjustmentId
			INNER JOIN tblICItem Itm ON IAD.intItemId = Itm.intItemId
			INNER JOIN tblICCommodity C ON Itm.intCommodityId = C.intCommodityId
		WHERE IAD.intOwnershipType = 2 --Storage
			AND IA.ysnPosted = 1
			AND convert(DATETIME, CONVERT(VARCHAR(10), IA.dtmPostedDate, 110), 110) BETWEEN convert(DATETIME, CONVERT(VARCHAR(10), @dtmFromTransactionDate, 110), 110) AND convert(DATETIME, CONVERT(VARCHAR(10), @dtmToTransactionDate, 110), 110) 
			AND C.intCommodityId = @intCommodityId 
			AND IAD.intItemId = CASE WHEN isnull(@intItemId, 0) = 0 THEN IAD.intItemId ELSE @intItemId END 
			--AND Itm.intLocationId = case when isnull(@intLocationId,0)=0 then il.intLocationId else @intLocationId end 

		)a
--UNION ALL--IR came from Delivery Sheet
--SELECT dtmDate,strDistributionOption strDistributionOption,'' strShipDistributionOption,
--		'' as strAdjDistributionOption,
--		'' as strCountDistributionOption,
--		'' tranShipmentNumber,
--		0.0 tranShipQty,
--		strReceiptNumber tranReceiptNumber,
--		dblInQty tranRecQty,
--		'' tranAdjNumber,
--		0.0 dblAdjustmentQty,
--		'' tranCountNumber,
--		0.0 dblCountQty,
--		'' tranInvoiceNumber,
--		0.0 dblInvoiceQty,
--		intInventoryReceiptId,
--		null intInventoryShipmentId,
--		null intInventoryAdjustmentId,
--		null intInventoryCountId,
--		null intInvoiceId,
--		null intDeliverySheetId,
--		'' AS deliverySheetNumber,
--		null intTicketId,
--		'' AS ticketNumber    
--FROM(
--SELECT  CONVERT(VARCHAR(10),r.dtmReceiptDate,110) dtmDate,
--round(dbo.fnCTConvertQuantityToTargetCommodityUOM(u.intUnitMeasureId,@intCommodityUnitMeasureId,ri.dblOpenReceive) ,6) dblInQty,
--r.strReceiptNumber,
--		strDistributionOption ,r.intInventoryReceiptId
--FROM tblSCDeliverySheet DS
--		JOIN tblICItem i on i.intItemId=DS.intItemId 
--		JOIN tblICInventoryReceiptItem ri on ri.intSourceId=DS.intDeliverySheetId
--									AND  DS.intCompanyLocationId  IN (
--													SELECT intCompanyLocationId FROM tblSMCompanyLocation
--													WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
--													WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
--													ELSE isnull(ysnLicensed, 0) END)
--		join tblICInventoryReceipt r on r.intInventoryReceiptId=ri.intInventoryReceiptId
--		JOIN tblSCDeliverySheetSplit DSS ON DS.intDeliverySheetId = DSS.intDeliverySheetId  AND DSS.intEntityId = r.intEntityVendorId
--		JOIN tblGRStorageType gs on gs.intStorageScheduleTypeId=DSS.intStorageScheduleTypeId 
--		join tblICItemUOM u on DS.intItemId=u.intItemId and u.ysnStockUnit=1  
--WHERE 
--convert(datetime,CONVERT(VARCHAR(10),r.dtmReceiptDate,110),110) BETWEEN
--		 convert(datetime,CONVERT(VARCHAR(10),@dtmFromTransactionDate,110),110) AND convert(datetime,CONVERT(VARCHAR(10),@dtmToTransactionDate,110),110)
--		AND i.intCommodityId= @intCommodityId
--		and i.intItemId= case when isnull(@intItemId,0)=0 then i.intItemId else @intItemId end and isnull(strType,'') <> 'Other Charge'
--		--and  gs.strOwnedPhysicalStock='Customer' and  gs.intStorageScheduleTypeId > 0 
--		AND DS.intCompanyLocationId = case when isnull(@intLocationId,0)=0 then DS.intCompanyLocationId  else @intLocationId end
--		AND DS.ysnPost = 1)a


Union
SELECT dtmDate,'' strDistributionOption,strDistributionOption strShipDistributionOption,
		'' as strAdjDistributionOption,
		'' as strCountDistributionOption,
		strShipmentNumber tranShipmentNumber,
		dblOutQty tranShipQty,
		'' tranReceiptNumber,
		0.0 tranRecQty,
		'' tranAdjNumber,
		0.0 dblAdjustmentQty,
		'' tranCountNumber,
		0.0 dblCountQty,
		'' tranInvoiceNumber,
		0.0 dblInvoiceQty,
		null intInventoryReceiptId,
		intInventoryShipmentId intInventoryShipmentId,
		null intInventoryAdjustmentId,
		null intInventoryCountId,
		null intInvoiceId,
		null intDeliverySheetId,
		'' AS deliverySheetNumber,
		null intTicketId,
		'' AS ticketNumber    
FROM(
SELECT  CONVERT(VARCHAR(10),st.dtmTicketDateTime,110) dtmDate,
round(dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,@intCommodityUnitMeasureId,CASE WHEN strInOutFlag='O' THEN ri.dblQuantity ELSE 0 END) ,6) dblOutQty,
r.strShipmentNumber,
		CASE WHEN ri.intStorageScheduleTypeId IS NULL AND ri.intOrderId IS NULL THEN 'SPT' WHEN ri.intOrderId IS NOT NULL THEN st.strDistributionOption ELSE gs.strStorageTypeCode END strDistributionOption,r.intInventoryShipmentId
FROM tblSCTicket st
		JOIN tblICItem i on i.intItemId=st.intItemId 
									AND  st.intProcessingLocationId  IN (
													SELECT intCompanyLocationId FROM tblSMCompanyLocation
													WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
													WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
													ELSE isnull(ysnLicensed, 0) END)
		JOIN tblICInventoryShipmentItem ri on ri.intSourceId=st.intTicketId
		join tblICInventoryShipment r on r.intInventoryShipmentId=ri.intInventoryShipmentId
		LEFT JOIN tblGRStorageType gs on gs.intStorageScheduleTypeId=ri.intStorageScheduleTypeId  
		JOIN tblICItemUOM u on st.intItemId=u.intItemId and u.ysnStockUnit=1
		JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=@intCommodityId AND u.intUnitMeasureId=ium.intUnitMeasureId  
WHERE convert(datetime,CONVERT(VARCHAR(10),st.dtmTicketDateTime,110),110) BETWEEN
		 convert(datetime,CONVERT(VARCHAR(10),@dtmFromTransactionDate,110),110) AND convert(datetime,CONVERT(VARCHAR(10),@dtmToTransactionDate,110),110)
		AND i.intCommodityId= @intCommodityId
		and i.intItemId= case when isnull(@intItemId,0)=0 then i.intItemId else @intItemId end and isnull(strType,'') <> 'Other Charge'
		--and  gs.strOwnedPhysicalStock='Customer'
		AND st.intProcessingLocationId = case when isnull(@intLocationId,0)=0 then st.intProcessingLocationId  else @intLocationId end )a

--UNION ALL --IS came from Delivery Sheet
--SELECT dtmDate,'' strDistributionOption,strDistributionOption strShipDistributionOption,
--		'' as strAdjDistributionOption,
--		'' as strCountDistributionOption,
--		strShipmentNumber tranShipmentNumber,
--		dblOutQty tranShipQty,
--		'' tranReceiptNumber,
--		0.0 tranRecQty,
--		'' tranAdjNumber,
--		0.0 dblAdjustmentQty,
--		'' tranCountNumber,
--		0.0 dblCountQty,
--		'' tranInvoiceNumber,
--		0.0 dblInvoiceQty,
--		null intInventoryReceiptId,
--		intInventoryShipmentId intInventoryShipmentId,
--		null intInventoryAdjustmentId,
--		null intInventoryCountId,
--		null intInvoiceId,
--		null intDeliverySheetId,
--		'' AS deliverySheetNumber,
--		null intTicketId,
--		'' AS ticketNumber    
--FROM(
--SELECT  CONVERT(VARCHAR(10),r.dtmShipDate,110) dtmDate,
--round(dbo.fnCTConvertQuantityToTargetCommodityUOM(intUnitMeasureId,@intCommodityUnitMeasureId,ri.dblQuantity) ,6) dblOutQty,
--r.strShipmentNumber,
--		strDistributionOption ,r.intInventoryShipmentId
--FROM tblSCDeliverySheet DS
--		JOIN tblICItem i on i.intItemId=DS.intItemId 
--									AND DS.intCompanyLocationId IN (
--													SELECT intCompanyLocationId FROM tblSMCompanyLocation
--													WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
--													WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
--													ELSE isnull(ysnLicensed, 0) END)
--		JOIN tblICInventoryShipmentItem ri on ri.intSourceId=DS.intDeliverySheetId
--		join tblICInventoryShipment r on r.intInventoryShipmentId=ri.intInventoryShipmentId
--		JOIN tblSCDeliverySheetSplit DSS ON DS.intDeliverySheetId = DSS.intDeliverySheetId  AND DSS.intEntityId = r.intEntityId 
--		JOIN tblGRStorageType gs on gs.intStorageScheduleTypeId=DSS.intStorageScheduleTypeId  
--		JOIN tblICItemUOM u on DS.intItemId=u.intItemId and u.ysnStockUnit=1
--WHERE convert(datetime,CONVERT(VARCHAR(10),r.dtmShipDate,110),110) BETWEEN
--		 convert(datetime,CONVERT(VARCHAR(10),@dtmFromTransactionDate,110),110) AND convert(datetime,CONVERT(VARCHAR(10),@dtmToTransactionDate,110),110)
--		AND i.intCommodityId= @intCommodityId
--		and i.intItemId= case when isnull(@intItemId,0)=0 then i.intItemId else @intItemId end and isnull(strType,'') <> 'Other Charge'
--		--and  gs.strOwnedPhysicalStock='Customer'
--		AND DS.intCompanyLocationId = case when isnull(@intLocationId,0)=0 then DS.intCompanyLocationId  else @intLocationId end 
--		AND DS.ysnPost = 1)a

--UNION ALL --Delivery Sheet
--SELECT
--	CONVERT(VARCHAR(10),st.dtmTicketDateTime,110) dtmDate,
--	DSS.strDistributionOption,
--	'' strShipDistributionOption,
--	'' as strAdjDistributionOption,
--	'' as strCountDistributionOption,
--	'' as tranShipmentNumber,
--	(CASE WHEN strInOutFlag='O' THEN dblNetUnits * (DSS.dblSplitPercent/100) ELSE 0 END)  tranShipQty,
--	'' tranReceiptNumber,
--	(CASE WHEN strInOutFlag='I' THEN dblNetUnits * (DSS.dblSplitPercent/100) ELSE 0 END) tranRecQty,
--	'' tranAdjNumber,
--	0.0 dblAdjustmentQty,
--	'' tranCountNumber,
--	0.0 dblCountQty,
--	'' tranInvoiceNumber,
--	0.0 dblInvoiceQty,
--	null intInventoryReceiptId,
--	NULL intInventoryShipmentId,
--	null intInventoryAdjustmentId,
--	null intInventoryCountId,
--	null intInvoiceId,
--	DS.intDeliverySheetId,
--	DS.strDeliverySheetNumber + '*' AS deliverySheetNumber,
--	null intTicketId,
--	'' AS ticketNumber  
--FROM tblSCTicket st
--	JOIN tblICItem i on i.intItemId=st.intItemId
--	JOIN tblSCDeliverySheet DS ON st.intDeliverySheetId = DS.intDeliverySheetId
--	JOIN tblSCDeliverySheetSplit DSS ON DS.intDeliverySheetId = DSS.intDeliverySheetId
--WHERE   convert(datetime,CONVERT(VARCHAR(10),st.dtmTicketDateTime,110),110) BETWEEN convert(datetime,CONVERT(VARCHAR(10),@dtmFromTransactionDate,110),110) AND convert(datetime,CONVERT(VARCHAR(10),@dtmToTransactionDate,110),110)
--	AND i.intCommodityId= @intCommodityId
--	AND i.intItemId= case when isnull(@intItemId,0)=0 then i.intItemId else @intItemId end and isnull(strType,'') <> 'Other Charge'
--	AND st.intProcessingLocationId = case when isnull(@intLocationId,0)=0 then st.intProcessingLocationId  else @intLocationId end 
--	AND  st.intProcessingLocationId  IN (
--											SELECT intCompanyLocationId FROM tblSMCompanyLocation
--											WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
--											WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
--											ELSE isnull(ysnLicensed, 0) END)
--	AND DS.ysnPost = 0 AND st.strTicketStatus = 'H'
	

UNION ALL --On Hold without Delivery Sheet
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
WHERE   convert(datetime,CONVERT(VARCHAR(10),st.dtmTicketDateTime,110),110) BETWEEN convert(datetime,CONVERT(VARCHAR(10),@dtmFromTransactionDate,110),110) AND convert(datetime,CONVERT(VARCHAR(10),@dtmToTransactionDate,110),110)
	AND i.intCommodityId= @intCommodityId
	AND i.intItemId= case when isnull(@intItemId,0)=0 then i.intItemId else @intItemId end and isnull(strType,'') <> 'Other Charge'
	AND st.intProcessingLocationId =  case when isnull(@intLocationId,0)=0 then st.intProcessingLocationId  else @intLocationId end 
	AND  st.intProcessingLocationId  IN (
											SELECT intCompanyLocationId FROM tblSMCompanyLocation
											WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
											WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
											ELSE isnull(ysnLicensed, 0) END)
	AND st.intDeliverySheetId IS NULL AND st.strTicketStatus = 'H'


UNION ALL --Direct IR
SELECT dtmDate,strDistributionOption strDistributionOption,'' strShipDistributionOption,
		'' as strAdjDistributionOption,
		'' as strCountDistributionOption,
		'' tranShipmentNumber,
		0.0 tranShipQty,
		strReceiptNumber tranReceiptNumber,
		dblInQty tranRecQty,
		'' tranAdjNumber,
		0.0 dblAdjustmentQty,
		'' tranCountNumber,
		0.0 dblCountQty,
		'' tranInvoiceNumber,
		0.0 dblInvoiceQty,
		intInventoryReceiptId,
		null intInventoryShipmentId,
		null intInventoryAdjustmentId,
		null intInventoryCountId,
		null intInvoiceId,
		null intDeliverySheetId,
		'' AS deliverySheetNumber,
		null intTicketId,
		'' AS ticketNumber    
FROM(
	SELECT  
		CONVERT(VARCHAR(10),R.dtmReceiptDate,110) dtmDate,
		round(dbo.fnCTConvertQuantityToTargetCommodityUOM(u.intUnitMeasureId,@intCommodityUnitMeasureId,RI.dblOpenReceive) ,6) dblInQty,
		R.strReceiptNumber,
		'' strDistributionOption 
		,R.intInventoryReceiptId
	FROM tblICInventoryReceiptItem RI 
	INNER JOIN tblICInventoryReceipt R ON R.intInventoryReceiptId = RI.intInventoryReceiptId
	INNER JOIN tblICItem Itm ON Itm.intItemId = RI.intItemId
	INNER JOIN tblICCommodity C ON Itm.intCommodityId = C.intCommodityId
	INNER JOIN tblICItemUOM u on Itm.intItemId=u.intItemId and u.ysnStockUnit=1
	WHERE R.ysnPosted = 1
		AND convert(DATETIME, CONVERT(VARCHAR(10), R.dtmReceiptDate, 110), 110) BETWEEN convert(DATETIME, CONVERT(VARCHAR(10), @dtmFromTransactionDate, 110), 110) AND convert(DATETIME, CONVERT(VARCHAR(10), @dtmToTransactionDate, 110), 110) 
		AND C.intCommodityId = @intCommodityId 
		AND Itm.intItemId = CASE WHEN isnull(@intItemId, 0) = 0 THEN Itm.intItemId ELSE @intItemId END 
		AND R.intLocationId = case when isnull(@intLocationId,0)=0 then R.intLocationId else @intLocationId end 
		AND R.intLocationId IN (
				SELECT intCompanyLocationId
				FROM tblSMCompanyLocation
				WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 ELSE isnull(ysnLicensed, 0) END
				)
		AND RI.intOwnershipType = 1
		AND R.intSourceType = 0
	)t

UNION ALL --Direct IS
SELECT dtmDate,'' strDistributionOption,strDistributionOption strShipDistributionOption,
		'' as strAdjDistributionOption,
		'' as strCountDistributionOption,
		strShipmentNumber tranShipmentNumber,
		dblOutQty tranShipQty,
		'' tranReceiptNumber,
		0.0 tranRecQty,
		'' tranAdjNumber,
		0.0 dblAdjustmentQty,
		'' tranCountNumber,
		0.0 dblCountQty,
		'' tranInvoiceNumber,
		0.0 dblInvoiceQty,
		null intInventoryReceiptId,
		intInventoryShipmentId intInventoryShipmentId,
		null intInventoryAdjustmentId,
		null intInventoryCountId,
		null intInvoiceId,
		null intDeliverySheetId,
		'' AS deliverySheetNumber,
		null intTicketId,
		'' AS ticketNumber    
FROM(
	SELECT  
		CONVERT(VARCHAR(10),S.dtmShipDate,110) dtmDate
		,round(dbo.fnCTConvertQuantityToTargetCommodityUOM(intUnitMeasureId,@intCommodityUnitMeasureId,SI.dblQuantity) ,6) dblOutQty
		,S.strShipmentNumber
		,'' strDistributionOption 
		,S.intInventoryShipmentId
	FROM tblICInventoryShipmentItem SI 
		INNER JOIN tblICInventoryShipment S ON S.intInventoryShipmentId = SI.intInventoryShipmentId
		INNER JOIN tblICItem Itm ON Itm.intItemId = SI.intItemId
		INNER JOIN tblICCommodity C ON Itm.intCommodityId = C.intCommodityId
		INNER JOIN tblICItemUOM u on Itm.intItemId=u.intItemId and u.ysnStockUnit=1
		WHERE S.ysnPosted = 1
		AND convert(DATETIME, CONVERT(VARCHAR(10), S.dtmShipDate, 110), 110) BETWEEN convert(DATETIME, CONVERT(VARCHAR(10), @dtmFromTransactionDate, 110), 110) AND convert(DATETIME, CONVERT(VARCHAR(10), @dtmToTransactionDate, 110), 110) 
		AND C.intCommodityId = @intCommodityId 
		AND Itm.intItemId = CASE WHEN isnull(@intItemId, 0) = 0 THEN Itm.intItemId ELSE @intItemId END 
		AND S.intShipFromLocationId = case when isnull(@intLocationId,0)=0 then S.intShipFromLocationId else @intLocationId end 
		AND S.intShipFromLocationId IN (
				SELECT intCompanyLocationId
				FROM tblSMCompanyLocation
				WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 ELSE isnull(ysnLicensed, 0) END
				)
		AND SI.intOwnershipType = 1
		AND S.intSourceType = 0 
	)a

UNION ALL --Direct Invoice
SELECT dtmDate,'' strDistributionOption,strDistributionOption strShipDistributionOption,
		'' as strAdjDistributionOption,
		'' as strCountDistributionOption,
		strShipmentNumber tranShipmentNumber,
		dblOutQty tranShipQty,
		'' tranReceiptNumber,
		0.0 tranRecQty,
		'' tranAdjNumber,
		0.0 dblAdjustmentQty,
		'' tranCountNumber,
		0.0 dblCountQty,
		'' tranInvoiceNumber,
		0.0 dblInvoiceQty,
		null intInventoryReceiptId,
		intInventoryShipmentId intInventoryShipmentId,
		null intInventoryAdjustmentId,
		null intInventoryCountId,
		null intInvoiceId,
		null intDeliverySheetId,
		'' AS deliverySheetNumber,
		null intTicketId,
		'' AS ticketNumber    
FROM(
	SELECT  
		CONVERT(VARCHAR(10),I.dtmPostDate,110) dtmDate
		,round(dbo.fnCTConvertQuantityToTargetCommodityUOM(intUnitMeasureId,@intCommodityUnitMeasureId,ID.dblQtyShipped) ,6) dblOutQty
		,I.strInvoiceNumber strShipmentNumber
		,'' strDistributionOption 
		,I.intInvoiceId intInventoryShipmentId
	FROM tblARInvoice I
		INNER JOIN tblARInvoiceDetail ID ON I.intInvoiceId = ID.intInvoiceId
		INNER JOIN tblICItem Itm ON ID.intItemId = Itm.intItemId
		INNER JOIN tblICCommodity C ON Itm.intCommodityId = C.intCommodityId
		INNER JOIN tblICItemUOM u on Itm.intItemId=u.intItemId and u.ysnStockUnit=1
	WHERE I.ysnPosted = 1
		AND ID.intInventoryShipmentItemId IS NULL
		AND ID.strShipmentNumber = ''
		AND convert(DATETIME, CONVERT(VARCHAR(10), I.dtmPostDate, 110), 110) BETWEEN convert(DATETIME, CONVERT(VARCHAR(10), @dtmFromTransactionDate, 110), 110) AND convert(DATETIME, CONVERT(VARCHAR(10), @dtmToTransactionDate, 110), 110) 
		AND C.intCommodityId = @intCommodityId 
		AND ID.intItemId = CASE WHEN isnull(@intItemId, 0) = 0 THEN ID.intItemId ELSE @intItemId END 
		AND I.intCompanyLocationId = case when isnull(@intLocationId,0)=0 then I.intCompanyLocationId else @intLocationId end 
		AND I.intCompanyLocationId IN (
				SELECT intCompanyLocationId
				FROM tblSMCompanyLocation
				WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 ELSE isnull(ysnLicensed, 0) END
				)
	)a

	UNION ALL --Consume, Produce and Outbound Shimpment
	SELECT
		 dtmDate,
		 '' strDistributionOption,
		 '' strShipDistributionOption,
		'' as strAdjDistributionOption,
		'' as strCountDistributionOption,
		tranShipmentNumber,
		tranShipQty,
		tranReceiptNumber,
		tranRecQty,
		'' tranAdjNumber,
		0.0 dblAdjustmentQty,
		'' tranCountNumber,
		0.0 dblCountQty,
		'' tranInvoiceNumber,
		0.0 dblInvoiceQty,
		intTransactionId intInventoryReceiptId,
		intTransactionId intInventoryShipmentId,
		null intInventoryAdjustmentId,
		null intInventoryCountId,
		null intInvoiceId,
		null intDeliverySheetId,
		'' AS deliverySheetNumber,
		null intTicketId,
		'' AS ticketNumber    
	FROM(
		SELECT 
			CONVERT(VARCHAR(10),dtmDate,110) dtmDate
			,CASE WHEN it.intTransactionTypeId  = 8 OR it.intTransactionTypeId  = 46 THEN it.strTransactionId ELSE '' END tranShipmentNumber
			,CASE WHEN it.intTransactionTypeId = 8 OR it.intTransactionTypeId  = 46 THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,SUM(ISNULL(it.dblQty,0))) ELSE  0.0 END tranShipQty
			,CASE WHEN it.intTransactionTypeId = 9 THEN it.strTransactionId ELSE '' END tranReceiptNumber
			,CASE WHEN it.intTransactionTypeId = 9 THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,SUM(ISNULL(it.dblQty,0))) ELSE 0.0 END tranRecQty
			,it.intTransactionId
		FROM tblICInventoryTransaction it 
		JOIN tblICItem i on i.intItemId=it.intItemId and it.ysnIsUnposted=0 and it.intTransactionTypeId in(8,9,46)
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
		and i.intItemId= case when isnull(@intItemId,0)=0 then i.intItemId else @intItemId end --and strTransactionId not like'%IS%'
		and il.intLocationId =  case when isnull(@intLocationId,0)=0 then il.intLocationId else @intLocationId end
		and convert(datetime,CONVERT(VARCHAR(10),dtmDate,110),110) BETWEEN
			 convert(datetime,CONVERT(VARCHAR(10),@dtmFromTransactionDate,110),110) AND convert(datetime,CONVERT(VARCHAR(10),@dtmToTransactionDate,110),110)
		group by dtmDate, intTransactionTypeId,strTransactionId,ium.intCommodityUnitMeasureId,intTransactionId
	) a


	UNION ALL --Storage Transfer
	SELECT dtmDate,strDistributionOption,strDistributionOption strShipDistributionOption,
			'' as strAdjDistributionOption,
			'' as strCountDistributionOption,
			strTransferTicket tranShipmentNumber,
			dblOutQty tranShipQty,
			strTransferTicket tranReceiptNumber,
			dblInQty tranRecQty,
			'' tranAdjNumber,
			0.0 dblAdjustmentQty,
			'' tranCountNumber,
			0.0 dblCountQty,
			'' tranInvoiceNumber,
			0.0 dblInvoiceQty,
			intTransferStorageId intInventoryReceiptId,
			intTransferStorageId intInventoryShipmentId,
			null intInventoryAdjustmentId,
			null intInventoryCountId,
			null intInvoiceId,
			null intDeliverySheetId,
			'' AS deliverySheetNumber,
			null intTicketId,
			'' AS ticketNumber    
	FROM(

		select 
				CONVERT(VARCHAR(10),SH.dtmDistributionDate,110) dtmDate
				,S.strStorageTypeCode strDistributionOption
				,CASE WHEN strType = 'From Transfer'  THEN
					dblUnits
					ELSE 0 END AS dblInQty
				,CASE WHEN strType = 'Transfer'  THEN
					ABS(dblUnits)
					ELSE 0 END AS dblOutQty
				,S.intStorageScheduleTypeId
				,SH.intTransferStorageId
				,SH.strTransferTicket

			from 
			tblGRCustomerStorage CS
			INNER JOIN tblGRStorageHistory SH ON CS.intCustomerStorageId = SH.intCustomerStorageId
			INNER JOIN tblGRStorageType S ON CS.intStorageTypeId = S.intStorageScheduleTypeId

			WHERE convert(datetime,CONVERT(VARCHAR(10),SH.dtmDistributionDate,110),110) BETWEEN
									convert(datetime,CONVERT(VARCHAR(10),@dtmFromTransactionDate,110),110) AND convert(datetime,CONVERT(VARCHAR(10),@dtmToTransactionDate,110),110)
								AND CS.intCommodityId= @intCommodityId
								and CS.intItemId= case when isnull(@intItemId,0)=0 then CS.intItemId else @intItemId end 
								AND  CS.intCompanyLocationId  IN (
																			SELECT intCompanyLocationId FROM tblSMCompanyLocation
																			WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
																			WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
																			ELSE isnull(ysnLicensed, 0) END)
				
								AND CS.intCompanyLocationId = case when isnull(@intLocationId,0)=0 then CS.intCompanyLocationId  else @intLocationId end
								AND strType IN ('From Transfer','Transfer')
	) a


 )t

 select  convert(int,ROW_NUMBER() OVER (ORDER BY dtmDate)) intRowNum,* from(
SELECT distinct 
    dtmDate [dtmDate],case when isnull(tranReceiptNumber,'') <> '' then tranReceiptNumber	
                                            when isnull(tranShipmentNumber,'') <> '' then tranShipmentNumber
                                            when isnull(tranAdjNumber,'') <> '' then tranAdjNumber
											when isnull(tranInvoiceNumber,'') <> '' then tranInvoiceNumber
											when isnull(tranCountNumber,'') <> '' then tranCountNumber 
											when isnull(deliverySheetNumber,'') <> '' then deliverySheetNumber 
											when isnull(ticketNumber,'') <> '' then ticketNumber end [strReceiptNumber],
       
    CASE WHEN isnull(strDistributionOption,'') <> '' THEN strDistributionOption
                                            WHEN isnull(strShipDistributionOption,'') <> '' then strShipDistributionOption
											WHEN isnull(strAdjDistributionOption,'') <> '' then strAdjDistributionOption
                                            END 
                                            strDistribution,
       tranRecQty [dblIN],isnull(tranShipmentNumber,'') [strShipTicketNo],
	   isnull(tranShipQty,0) + isnull(dblInvoiceQty,0)   [dblOUT],
	   tranAdjNumber [strAdjNo],
       dblAdjustmentQty [dblAdjQty],tranCountNumber [strCountNumber],dblCountQty [dblCountQty],BalanceForward dblDummy,
(SELECT SUM(BalanceForward) FROM @tblResult AS T2 WHERE T2.Id <= T1.Id) AS dblBalanceForward,strShipDistributionOption,
	intInventoryReceiptId,intInventoryShipmentId,intInventoryAdjustmentId,intInventoryCountId,intInvoiceId,intDeliverySheetId,deliverySheetNumber,intTicketId,ticketNumber
FROM @tblResult T1)t order by dtmDate desc,strReceiptNumber desc