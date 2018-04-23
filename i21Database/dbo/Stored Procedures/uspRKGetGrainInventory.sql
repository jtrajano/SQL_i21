﻿CREATE PROC [dbo].[uspRKGetGrainInventory]
		@dtmFromTransactionDate datetime = null,
		@dtmToTransactionDate datetime = null,
		@intCommodityId int =  null,
		@intItemId int= null,
		  @strPositionIncludes nvarchar(100) = NULL

AS
--DECLARE		@dtmFromTransactionDate datetime = '2018-04-19 00:00:00',
--		@dtmToTransactionDate datetime = '2018-04-19 00:00:00',
--		@intCommodityId int =  6,
--		@intItemId int= 0,
--		  @strPositionIncludes nvarchar(100) = 'All Storage'

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
intInvoiceId int

)
DECLARE @intCommodityUnitMeasureId INT= NULL
SELECT @intCommodityUnitMeasureId=intCommodityUnitMeasureId from tblICCommodityUnitMeasure where intCommodityId=@intCommodityId AND ysnDefault=1



INSERT INTO @tblResult(dtmDate,strDistributionOption,strShipDistributionOption,strAdjDistributionOption,strCountDistributionOption,tranShipmentNumber,tranShipQty,
	tranReceiptNumber,tranRecQty,tranAdjNumber,dblAdjustmentQty,tranCountNumber,dblCountQty,tranInvoiceNumber,dblInvoiceQty
,intInventoryReceiptId ,intInventoryShipmentId,intInventoryAdjustmentId,intInventoryCountId,intInvoiceId,BalanceForward)

SELECT *,round(isnull(tranShipQty,0)+isnull(tranRecQty,0)+isnull(dblAdjustmentQty,0)+isnull(dblCountQty,0),6) BalanceForward FROM 
(
select distinct * from(
SELECT dtmDate,
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
round(dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,@intCommodityUnitMeasureId,(SELECT TOP 1 dblQty FROM tblICInventoryShipment sh WHERE sh.strShipmentNumber=it.strTransactionId)) ,6)tranShipQty,
(SELECT top 1 strReceiptNumber FROM tblICInventoryReceipt ir WHERE ir.strReceiptNumber=it.strTransactionId) tranReceiptNumber,

round(dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,@intCommodityUnitMeasureId,(SELECT TOP 1 dblQty FROM tblICInventoryReceipt ir WHERE ir.strReceiptNumber=it.strTransactionId)) ,6) tranRecQty,

isnull((SELECT top 1 strAdjustmentNo FROM tblICInventoryAdjustment ia WHERE ia.strAdjustmentNo=it.strTransactionId),'') tranAdjNumber,
round(dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,@intCommodityUnitMeasureId,(SELECT TOP 1 dblQty FROM tblICInventoryAdjustment ia WHERE ia.strAdjustmentNo=it.strTransactionId)) ,6) dblAdjustmentQty,

isnull((SELECT top 1 strCountNo FROM tblICInventoryCount ia WHERE ia.strCountNo=it.strTransactionId),'') tranCountNumber,
round(dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,@intCommodityUnitMeasureId,(SELECT TOP 1 dblQty FROM tblICInventoryCount ia WHERE ia.strCountNo=it.strTransactionId )) ,6) dblCountQty,

(SELECT top 1 strInvoiceNumber FROM tblARInvoice ia
	JOIN tblARInvoiceDetail ad on  ia.intInvoiceId=ad.intInvoiceId and isnull(ad.strShipmentNumber,'')=''  
	WHERE ia.strInvoiceNumber=it.strTransactionId) tranInvoiceNumber,

ROUND(dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,@intCommodityUnitMeasureId,(SELECT TOP 1 dblQty FROM tblARInvoice ia
																										JOIN tblARInvoiceDetail ad on  ia.intInvoiceId=ad.intInvoiceId and isnull(ad.strShipmentNumber,'')=''  
																										WHERE ia.strInvoiceNumber=it.strTransactionId )) ,6) dblInvoiceQty,

ROUND((SELECT TOP 1 intInventoryReceiptId FROM tblICInventoryReceipt ir WHERE ir.strReceiptNumber=it.strTransactionId),6) intInventoryReceiptId,
ROUND((SELECT TOP 1 intInventoryShipmentId FROM tblICInventoryShipment sh WHERE sh.strShipmentNumber=it.strTransactionId) ,6)intInventoryShipmentId,
ROUND((SELECT TOP 1 intInventoryAdjustmentId FROM tblICInventoryAdjustment ia WHERE ia.strAdjustmentNo=it.strTransactionId ),6) intInventoryAdjustmentId,
ROUND((SELECT TOP 1 intInventoryCountId FROM tblICInventoryCount ia WHERE ia.strCountNo=it.strTransactionId ),6) intInventoryCountId,
ROUND((SELECT top 1 ia.intInvoiceId FROM tblARInvoice ia
	JOIN tblARInvoiceDetail ad on  ia.intInvoiceId=ad.intInvoiceId and isnull(ad.strShipmentNumber,'')=''  
	WHERE ia.strInvoiceNumber=it.strTransactionId),6) intInvoiceId

FROM tblICInventoryTransaction it 
JOIN tblICItem i on i.intItemId=it.intItemId and it.ysnIsUnposted=0 and it.intTransactionTypeId in(33,4,5,10,23)
join tblICItemUOM u on it.intItemId=u.intItemId and u.intItemUOMId=it.intItemUOMId 
JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=@intCommodityId AND u.intUnitMeasureId=ium.intUnitMeasureId  
JOIN tblICItemLocation il on it.intItemLocationId=il.intItemLocationId and it.intItemId=il.intItemId and isnull(il.strDescription,'') <> 'In-Transit' 
										AND  il.intLocationId  IN (
													SELECT intCompanyLocationId FROM tblSMCompanyLocation
													WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
													WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
													ELSE isnull(ysnLicensed, 0) END)
WHERE i.intCommodityId=@intCommodityId
AND i.intItemId= case when isnull(@intItemId,0)=0 then i.intItemId else @intItemId end 
AND convert(datetime,CONVERT(VARCHAR(10),dtmDate,110),110) BETWEEN convert(datetime,CONVERT(VARCHAR(10),@dtmFromTransactionDate,110),110) 
and convert(datetime,CONVERT(VARCHAR(10),@dtmToTransactionDate,110),110) and strTransactionId not like'%IS%')t
union
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
		null intInvoiceId 
FROM(
SELECT  CONVERT(VARCHAR(10),st.dtmTicketDateTime,110) dtmDate,
round(dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,@intCommodityUnitMeasureId,CASE WHEN strInOutFlag='I' THEN st.dblNetUnits ELSE 0 END) ,6) dblInQty,
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
		and  gs.strOwnedPhysicalStock='Customer' and  gs.intStorageScheduleTypeId > 0 )a


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
		null intInvoiceId 
FROM(
SELECT  CONVERT(VARCHAR(10),st.dtmTicketDateTime,110) dtmDate,
round(dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,@intCommodityUnitMeasureId,CASE WHEN strInOutFlag='O' THEN dblNetUnits ELSE 0 END) ,6) dblOutQty,
r.strShipmentNumber,
		strDistributionOption ,r.intInventoryShipmentId
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
WHERE convert(datetime,CONVERT(VARCHAR(10),st.dtmTicketDateTime,110),110) BETWEEN
		 convert(datetime,CONVERT(VARCHAR(10),@dtmFromTransactionDate,110),110) AND convert(datetime,CONVERT(VARCHAR(10),@dtmToTransactionDate,110),110)
		AND i.intCommodityId= @intCommodityId
		and i.intItemId= case when isnull(@intItemId,0)=0 then i.intItemId else @intItemId end and isnull(strType,'') <> 'Other Charge'
		and  gs.strOwnedPhysicalStock='Customer' )a

UNION

SELECT CONVERT(VARCHAR(10),dtmTicketDateTime,110) AS dtmDate,strDistributionOption,'' strShipDistributionOption,'' strAdjDistributionOption,'' strCountDistributionOption,
'' tranShipmentNumber,0.0 tranShipQty,strReceiptNumber tranReceiptNumber,
dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,@intCommodityUnitMeasureId,dblGrossUnits)  tranRecQty,
'' tranAdjNumber,0.0 dblAdjustmentQty,'' tranCountNumber,0.0 dblCountQty,'' tranInvoiceNumber,0.0 dblInvoiceQty
,r.intInventoryReceiptId ,null intInventoryShipmentId, null intInventoryAdjustmentId,null intInventoryCountId,null intInvoiceId
FROM 
 tblICInventoryReceiptItem ir 
 JOIN tblICInventoryReceipt r on r.intInventoryReceiptId=ir.intInventoryReceiptId  and ysnPosted=1
JOIN tblICItem i on i.intItemId=ir.intItemId 
 JOIN tblSCTicket st ON st.intTicketId = ir.intSourceId 							AND  st.intProcessingLocationId  IN (
													SELECT intCompanyLocationId FROM tblSMCompanyLocation
													WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
													WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
													ELSE isnull(ysnLicensed, 0) END)
 JOIN tblGRStorageType s ON st.intStorageScheduleTypeId=s.intStorageScheduleTypeId AND isnull(ysnDPOwnedType,0) = 1
 		JOIN tblICItemUOM u on st.intItemId=u.intItemId and u.ysnStockUnit=1
		JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=@intCommodityId AND u.intUnitMeasureId=ium.intUnitMeasureId  
WHERE convert(datetime,CONVERT(VARCHAR(10),dtmTicketDateTime,110)) between convert(datetime,CONVERT(VARCHAR(10),@dtmFromTransactionDate,110))  and convert(datetime,CONVERT(VARCHAR(10),@dtmToTransactionDate,110)) and i.intCommodityId= @intCommodityId
and i.intItemId= case when isnull(@intItemId,0)=0 then i.intItemId else @intItemId end and isnull(strType,'') <> 'Other Charge' and  s.intStorageScheduleTypeId > 0 
 )t

 select  convert(int,ROW_NUMBER() OVER (ORDER BY dtmDate)) intRowNum,* from(
SELECT distinct 
    dtmDate [dtmDate],case when isnull(tranReceiptNumber,'') <> '' then tranReceiptNumber	
                                            when isnull(tranShipmentNumber,'') <> '' then tranShipmentNumber
                                            when isnull(tranAdjNumber,'') <> '' then tranAdjNumber
											when isnull(tranInvoiceNumber,'') <> '' then tranInvoiceNumber
											when isnull(tranCountNumber,'') <> '' then tranCountNumber end [strReceiptNumber],
       
    CASE WHEN isnull(strDistributionOption,'') <> '' THEN strDistributionOption
                                            WHEN isnull(strShipDistributionOption,'') <> '' then strShipDistributionOption
                                            END 
                                            strDistribution,
       tranRecQty [dblIN],isnull(tranShipmentNumber,'') [strShipTicketNo],
	   isnull(tranShipQty,0) + isnull(dblInvoiceQty,0)   [dblOUT],
	   tranAdjNumber [strAdjNo],
       dblAdjustmentQty [dblAdjQty],tranCountNumber [strCountNumber],dblCountQty [dblCountQty],BalanceForward dblDummy,
(SELECT SUM(BalanceForward) FROM @tblResult AS T2 WHERE T2.Id <= T1.Id) AS dblBalanceForward,strShipDistributionOption,
	intInventoryReceiptId,intInventoryShipmentId,intInventoryAdjustmentId,intInventoryCountId,intInvoiceId
FROM @tblResult T1)t order by strReceiptNumber