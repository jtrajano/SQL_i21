CREATE PROC [dbo].[uspRKDPRDailyPositionByCommodityLocation]  
    @intCommodityId nvarchar(max)='',
	@intVendorId int = null
AS      
 
DECLARE @Commodity AS TABLE 
(
intCommodityIdentity int IDENTITY(1,1) PRIMARY KEY , 
intCommodity  INT
)
INSERT INTO @Commodity(intCommodity)
SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ',')  

SELECT strLocationName,OpenPurchasesQty,OpenSalesQty,intCommodityId,strCommodityCode,intUnitMeasureId,strUnitMeasure,isnull(CompanyTitled,0) as dblCompanyTitled,  
isnull(CashExposure,0) as dblCaseExposure, isnull(DeltaOption,0) DeltaOption,              
(isnull(CompanyTitledNonDP,0)+ (isnull(OpenPurchasesQty,0)-isnull(OpenSalesQty,0))) as dblBasisExposure ,             
(isnull(CompanyTitledNonDP,0)+ (isnull(OpenPurchasesQty,0)-isnull(OpenSalesQty,0))) - isnull(ReceiptProductQty,0) as dblAvailForSale,    
isnull(InHouse,0) as dblInHouse,intLocationId  into #temp         
FROM(              
SELECT strLocationName,intCommodityId,strCommodityCode,strUnitMeasure,intUnitMeasureId, intLocationId, 
   isnull(invQty,0)-Case when (select top 1 ysnIncludeInTransitInCompanyTitled from tblRKCompanyPreference)=1 then  isnull(ReserveQty,0) else 0 end +  
   Case when (select top 1 ysnIncludeOffsiteInventoryInCompanyTitled from tblRKCompanyPreference)=1 then isnull(OffSite,0) else 0 end +  
   Case when (select top 1 ysnIncludeDPPurchasesInCompanyTitled from tblRKCompanyPreference)=1 then isnull(DP,0) else 0 end +   
   (isnull(dblCollatralPurchase,0)-isnull(dblCollatralSales,0))   + isnull(SlsBasisDeliveries,0)  AS CompanyTitled,

   isnull(invQty,0)-  isnull(ReserveQty,0)  + isnull(SlsBasisDeliveries,0) AS CompanyTitledNonDP,       
   
   (isnull(invQty,0) - isnull(PurBasisDelivary,0)) + (isnull(OpenPurQty,0)-isnull(OpenSalQty,0))+ isnull(dblCollatralSales,0)  + isnull(SlsBasisDeliveries,0)  AS CashExposure,  
   
   (((isnull(FutLBalTransQty,0)-isnull(FutMatchedQty,0))- (isnull(FutSBalTransQty,0)-isnull(FutMatchedQty,0)) )*isnull(dblContractSize,1)) + isnull(DeltaOption,0)   DeltaOption,          
 
   isnull(ReceiptProductQty,0) ReceiptProductQty,
   isnull(OpenPurchasesQty,0) OpenPurchasesQty,
   isnull(OpenSalesQty,0) OpenSalesQty,
   isnull(OpenPurQty,0) OpenPurQty,
   
   CASE WHEN isnull(@intVendorId,0) = 0 THEN
   isnull(invQty,0) + isnull(dblGrainBalance ,0) +
   isnull(OnHold,0)
   else
    isnull(CASE WHEN (SELECT TOP 1 ysnIncludeDPPurchasesInCompanyTitled from tblRKCompanyPreference)=1 then isnull(DPCustomer,0) else 0 end,0) + isnull(OnHold,0) end
   AS InHouse             
                 
FROM(  
SELECT distinct c.intCommodityId, strLocationName, intLocationId,    
  strCommodityCode,              
  u.intUnitMeasureId,              
  u.strUnitMeasure      
 ,(SELECT sum(Qty) FROM (
	SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,um.intCommodityUnitMeasureId,isnull((CD.dblBalance),0)) as Qty                   
	FROM tblCTContractDetail  CD     
	JOIN tblCTContractHeader ch on ch.intContractHeaderId=CD.intContractHeaderId
	JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=ch.intCommodityId  and CD.intContractStatusId <> 3
			AND CD.intUnitMeasureId=ium.intUnitMeasureId and intContractTypeId=1 and CD.intPricingTypeId in(1,3) 
	WHERE  ch.intCommodityId=c.intCommodityId and cl.intCompanyLocationId  = CD.intCompanyLocationId)t) as OpenPurQty
		
	,(SELECT sum(Qty) FROM (
	SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,um.intCommodityUnitMeasureId,isnull((CD.dblBalance),0)) as Qty                   
	FROM tblCTContractDetail  CD     
	JOIN tblCTContractHeader ch on ch.intContractHeaderId=CD.intContractHeaderId  
	JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=ch.intCommodityId    and CD.intContractStatusId <> 3
			AND CD.intUnitMeasureId=ium.intUnitMeasureId and intContractTypeId=2 and CD.intPricingTypeId in(1,3) 
	WHERE  ch.intCommodityId=c.intCommodityId and cl.intCompanyLocationId  = CD.intCompanyLocationId)t) as OpenSalQty		
		
	,(SELECT sum(Qty) FROM (
	SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,um.intCommodityUnitMeasureId,isnull((CD.dblBalance),0)) as Qty                   
	FROM tblCTContractDetail  CD     
	JOIN tblCTContractHeader ch on ch.intContractHeaderId=CD.intContractHeaderId  
	JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=ch.intCommodityId  and CD.intContractStatusId <> 3
			AND CD.intUnitMeasureId=ium.intUnitMeasureId and intContractTypeId=1 and CD.intPricingTypeId in(1,2) 
	WHERE  ch.intCommodityId=c.intCommodityId and cl.intCompanyLocationId  = CD.intCompanyLocationId)t) as ReceiptProductQty		
	            
	,(SELECT sum(Qty) FROM (
	SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,um.intCommodityUnitMeasureId,isnull((CD.dblBalance),0)) as Qty                   
		FROM tblCTContractDetail  CD     
	JOIN tblCTContractHeader ch on ch.intContractHeaderId=CD.intContractHeaderId     
	JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=ch.intCommodityId    and CD.intContractStatusId <> 3
			AND CD.intUnitMeasureId=ium.intUnitMeasureId and intContractTypeId=1 and CD.intPricingTypeId in(1,2) 
	WHERE  ch.intCommodityId=c.intCommodityId and cl.intCompanyLocationId  = CD.intCompanyLocationId)t) as OpenPurchasesQty	
	      
	,(SELECT sum(Qty) FROM (
	SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,um.intCommodityUnitMeasureId,isnull((CD.dblBalance),0)) as Qty                   
		FROM tblCTContractDetail  CD     
	JOIN tblCTContractHeader ch on ch.intContractHeaderId=CD.intContractHeaderId      
	JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=ch.intCommodityId    and CD.intContractStatusId <> 3
			AND CD.intUnitMeasureId=ium.intUnitMeasureId and intContractTypeId=2 and CD.intPricingTypeId in(1,2) 
	WHERE  ch.intCommodityId=c.intCommodityId and cl.intCompanyLocationId  = CD.intCompanyLocationId)t) as OpenSalesQty			
     
	,(SELECT top 1 rfm.dblContractSize as dblContractSize from tblRKFutOptTransaction otr  
	JOIN tblRKFutureMarket rfm on rfm.intFutureMarketId=otr.intFutureMarketId  
	WHERE otr.intCommodityId=c.intCommodityId and otr.intLocationId=cl.intCompanyLocationId) dblContractSize     
              
	,(SELECT isnull(SUM(intNoOfContract),0) from tblRKFutOptTransaction otr  
		WHERE otr.strBuySell='Sell' AND otr.intCommodityId=c.intCommodityId  and intInstrumentTypeId=1
		and otr.intLocationId=cl.intCompanyLocationId ) FutSBalTransQty     
  
	,(SELECT isnull(SUM(intNoOfContract),0) from tblRKFutOptTransaction otr  
	WHERE otr.strBuySell='Buy' AND otr.intCommodityId=c.intCommodityId and intInstrumentTypeId=1 and otr.intLocationId=cl.intCompanyLocationId) AS FutLBalTransQty,            
           
 (SELECT SUM(psd.dblMatchQty) from tblRKMatchFuturesPSHeader psh            
 JOIN tblRKMatchFuturesPSDetail psd on psd.intMatchFuturesPSHeaderId=psh.intMatchFuturesPSHeaderId            
 and intCommodityId=c.intCommodityId and psh.intCompanyLocationId=cl.intCompanyLocationId   ) FutMatchedQty  

		,(SELECT SUM(ISNULL(Qty,0)) Qty FROM(
		SELECT 
		 dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,um.intCommodityUnitMeasureId,isnull((a.dblUnitOnHand),0)) AS Qty 
 		 FROM tblICItemStock a  
		  JOIN tblICItemLocation il on a.intItemLocationId=il.intItemLocationId AND ISNULL(a.dblUnitOnHand,0) > 0
		  JOIN tblICItem i on a.intItemId=i.intItemId  
		  JOIN tblSMCompanyLocation sl on sl.intCompanyLocationId=il.intLocationId  
		  JOIN tblICItemUOM iuom on i.intItemId=iuom.intItemId and ysnStockUnit=1
		  JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=i.intCommodityId AND iuom.intUnitMeasureId=ium.intUnitMeasureId 
		 WHERE sl.intCompanyLocationId=cl.intCompanyLocationId and i.intCommodityId= c.intCommodityId	
		 )t) as invQty  
		 
		,(SELECT SUM(ISNULL(Qty,0)) Qty FROM(
		SELECT 
		 dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,um.intCommodityUnitMeasureId,isnull((sr1.dblQty),0)) AS Qty 
 		 FROM tblICItemStock a  
		  JOIN tblICItemLocation il on a.intItemLocationId=il.intItemLocationId and isnull(a.dblUnitOnHand,0) > 0
		  JOIN tblICStockReservation sr1 ON a.intItemId = sr1.intItemId   
		  JOIN tblICItem i on a.intItemId=i.intItemId  
		  JOIN tblSMCompanyLocation sl on sl.intCompanyLocationId=il.intLocationId  
		   JOIN tblICItemUOM iuom on i.intItemId=iuom.intItemId and ysnStockUnit=1
		  JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=i.intCommodityId AND iuom.intUnitMeasureId=ium.intUnitMeasureId 
		 WHERE sl.intCompanyLocationId=cl.intCompanyLocationId and i.intCommodityId= c.intCommodityId		 
		 )t) as ReserveQty 	  	

	,isnull((SELECT isnull(SUM(dblOriginalQuantity), 0) - isnull(sum(dblAdjustmentAmount), 0) CollateralSale
		FROM ( 
		SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,um.intCommodityUnitMeasureId,isnull((SUM(dblAdjustmentAmount)),0)) dblAdjustmentAmount,
				intContractHeaderId,
				dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,um.intCommodityUnitMeasureId,isnull((SUM(dblOriginalQuantity)),0)) dblOriginalQuantity
				FROM tblRKCollateral c1
				LEFT JOIN tblRKCollateralAdjustment ca ON c1.intCollateralId = ca.intCollateralId
				JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=c1.intCommodityId AND c1.intUnitMeasureId=ium.intUnitMeasureId 
				WHERE strType = 'Sale' AND c1.intCommodityId = c.intCommodityId and c1.intLocationId = cl.intCompanyLocationId  
				GROUP BY intContractHeaderId,ium.intCommodityUnitMeasureId) t 	WHERE dblAdjustmentAmount <> dblOriginalQuantity
		), 0) AS dblCollatralSales

	 ,isnull((SELECT isnull(SUM(dblOriginalQuantity), 0) - isnull(sum(dblAdjustmentAmount), 0) CollateralSale
		FROM ( 
		SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,um.intCommodityUnitMeasureId,isnull((SUM(dblAdjustmentAmount)),0)) dblAdjustmentAmount,
				intContractHeaderId,
				dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,um.intCommodityUnitMeasureId,isnull((SUM(dblOriginalQuantity)),0)) dblOriginalQuantity
				FROM tblRKCollateral c1
				LEFT JOIN tblRKCollateralAdjustment ca ON c1.intCollateralId = ca.intCollateralId
				JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=c1.intCommodityId AND c1.intUnitMeasureId=ium.intUnitMeasureId 
				WHERE strType = 'Purchase' AND c1.intCommodityId = c.intCommodityId and c1.intLocationId = cl.intCompanyLocationId 
				GROUP BY intContractHeaderId,ium.intCommodityUnitMeasureId) t 	WHERE dblAdjustmentAmount <> dblOriginalQuantity
		), 0) AS dblCollatralPurchase			  
   
	  ,(SELECT sum(SlsBasisDeliveries) from( SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,um.intCommodityUnitMeasureId,isnull((ri.dblQuantity),0)) AS SlsBasisDeliveries  
	  FROM tblICInventoryShipment r  
	  INNER JOIN tblICInventoryShipmentItem ri ON r.intInventoryShipmentId = ri.intInventoryShipmentId  
	  INNER JOIN tblCTContractDetail cd on cd.intContractDetailId = ri.intLineNo AND cd.intPricingTypeId = 2 AND ri.intOrderId = 1 and cd.intContractStatusId <> 3
	  INNER JOIN tblCTContractHeader ch on ch.intContractHeaderId=cd.intContractHeaderId
	  	JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=ch.intCommodityId AND cd.intUnitMeasureId=ium.intUnitMeasureId
	  WHERE ch.intCommodityId = c.intCommodityId AND cd.intCompanyLocationId = cl.intCompanyLocationId)t) as SlsBasisDeliveries 
  
     ,(SELECT Sum(dblTotal) from (
    SELECT
     dbo.fnCTConvertQuantityToTargetCommodityUOM(CH.intCommodityUnitMeasureId,um.intCommodityUnitMeasureId,isnull(Balance,0)) dblTotal
	 FROM vyuGRGetStorageDetail CH  
	 WHERE ysnCustomerStorage = 1 AND strOwnedPhysicalStock = 'Company'  
	 AND CH.intCommodityId=c.intCommodityId and CH.intCompanyLocationId=cl.intCompanyLocationId )t) as OffSite 

	,(SELECT Sum(dblTotal) from (
    SELECT
     dbo.fnCTConvertQuantityToTargetCommodityUOM(CH.intCommodityUnitMeasureId,um.intCommodityUnitMeasureId,isnull(Balance,0)) dblTotal
	 FROM vyuGRGetStorageDetail CH  
	 WHERE CH.intCommodityId = c.intCommodityId AND ysnDPOwnedType=1 and CH.intCompanyLocationId=cl.intCompanyLocationId
	  and  intEntityId= CASE WHEN ISNULL(@intVendorId,0)=0 then intEntityId else @intVendorId end 	
	 )t) as DP 

	,(SELECT Sum(dblTotal) from (
    SELECT
     dbo.fnCTConvertQuantityToTargetCommodityUOM(CH.intCommodityUnitMeasureId,um.intCommodityUnitMeasureId,isnull(Balance,0)) dblTotal
	 FROM vyuGRGetStorageDetail CH  
	 WHERE CH.intCommodityId = c.intCommodityId and CH.intCompanyLocationId=cl.intCompanyLocationId and strOwnedPhysicalStock='Customer'
	  and  intEntityId= CASE WHEN ISNULL(@intVendorId,0)=0 then intEntityId else @intVendorId end 	
	 )t) as DPCustomer

	,(SELECT Sum(dblTotal) from (
     SELECT
     dbo.fnCTConvertQuantityToTargetCommodityUOM(CH.intCommodityUnitMeasureId,um.intCommodityUnitMeasureId,isnull(Balance,0)) dblTotal
	 FROM vyuGRGetStorageDetail CH  
	 WHERE CH.intCommodityId = c.intCommodityId AND ysnCustomerStorage <> 1 and CH.intCompanyLocationId=cl.intCompanyLocationId
	 and  intEntityId= CASE WHEN ISNULL(@intVendorId,0)=0 then intEntityId else @intVendorId end 	 
	 )t) as dblGrainBalance 

 , (SELECT sum(isnull(dblNoOfContract,0)) dblNoOfContract from (SELECT  (CASE WHEN ft.strBuySell = 'Buy' THEN (
						ft.intNoOfContract - isnull((SELECT sum(intMatchQty) FROM tblRKOptionsMatchPnS l
						WHERE l.intLFutOptTransactionId = ft.intFutOptTransactionId	), 0)
						) ELSE - (ft.intNoOfContract - isnull((	SELECT sum(intMatchQty)	FROM tblRKOptionsMatchPnS s	WHERE s.intSFutOptTransactionId = ft.intFutOptTransactionId	), 0)
						) END * isnull((
						SELECT TOP 1 dblDelta
						FROM tblRKFuturesSettlementPrice sp
						INNER JOIN tblRKOptSettlementPriceMarketMap mm ON sp.intFutureSettlementPriceId = mm.intFutureSettlementPriceId
						WHERE intFutureMarketId = ft.intFutureMarketId AND mm.intOptionMonthId = ft.intOptionMonthId AND mm.intTypeId = CASE WHEN ft.strOptionType = 'Put' THEN 1 ELSE 2 END
						AND ft.dblStrike = mm.dblStrike
						ORDER BY dtmPriceDate DESC
				),0))*m.dblContractSize  AS dblNoOfContract
	FROM tblRKFutOptTransaction ft
	INNER JOIN tblRKFutureMarket m ON ft.intFutureMarketId = m.intFutureMarketId and ft.intLocationId=cl.intCompanyLocationId and intInstrumentTypeId=2
	INNER JOIN tblRKFuturesMonth fm ON fm.intFutureMonthId = ft.intFutureMonthId AND fm.intFutureMarketId = ft.intFutureMarketId AND fm.ysnExpired = 0
	WHERE ft.intCommodityId = ft.intCommodityId AND intFutOptTransactionId NOT IN (
			SELECT intFutOptTransactionId FROM tblRKOptionsPnSExercisedAssigned	) AND intFutOptTransactionId NOT IN (SELECT intFutOptTransactionId FROM tblRKOptionsPnSExpired))t
	) DeltaOption,
	
	(select sum(dblTotal) dblTotal from(
		SELECT 
		dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,um.intCommodityUnitMeasureId,isnull((PLDetail.dblLotPickedQty),0)) AS dblTotal
		FROM tblLGDeliveryPickDetail Del
		INNER JOIN tblLGPickLotDetail PLDetail ON PLDetail.intPickLotDetailId = Del.intPickLotDetailId
		INNER JOIN vyuLGPickOpenInventoryLots Lots ON Lots.intLotId = PLDetail.intLotId
		INNER JOIN tblCTContractDetail CT on CT.intContractDetailId = Lots.intContractDetailId   and CT.intContractStatusId <> 3
		INNER JOIN tblCTContractHeader ch on CT.intContractHeaderId=ch.intContractHeaderId		
		JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=ch.intCommodityId AND CT.intUnitMeasureId=ium.intUnitMeasureId 
		INNER JOIN tblSMCompanyLocation  cl1 on cl1.intCompanyLocationId=CT.intCompanyLocationId
		WHERE CT.intPricingTypeId = 2 AND ch.intCommodityId = c.intCommodityId and
		cl1.intCompanyLocationId=cl.intCompanyLocationId 
		UNION 
		SELECT
		dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,um.intCommodityUnitMeasureId,isnull(ri.dblReceived, 0))  AS dblTotal
		FROM tblICInventoryReceipt r
		INNER JOIN tblICInventoryReceiptItem ri ON r.intInventoryReceiptId = ri.intInventoryReceiptId AND r.strReceiptType = 'Purchase Contract'
		INNER JOIN tblSCTicket st ON st.intTicketId = ri.intSourceId  AND strDistributionOption IN ('CNT')
		INNER JOIN tblCTContractDetail cd on cd.intContractDetailId = ri.intLineNo AND cd.intPricingTypeId = 2   and cd.intContractStatusId <> 3
		INNER JOIN tblCTContractHeader ch on cd.intContractHeaderId=ch.intContractHeaderId	
		JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=ch.intCommodityId AND cd.intUnitMeasureId=ium.intUnitMeasureId 
		INNER JOIN tblSMCompanyLocation  cl1 on cl1.intCompanyLocationId=st.intProcessingLocationId 
		WHERE ch.intCommodityId = c.intCommodityId 	and
		cl1.intCompanyLocationId=cl.intCompanyLocationId 		
		)t) AS PurBasisDelivary,
		(select sum(dblTotal) from(
		(SELECT	dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,um.intCommodityUnitMeasureId,isnull(st.dblNetUnits, 0))  AS dblTotal
		FROM tblSCTicket st
		JOIN tblICItem i1 on i1.intItemId=st.intItemId and st.strDistributionOption='HLD'
		JOIN tblICItemUOM iuom on i1.intItemId=iuom.intItemId and ysnStockUnit=1
		JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=i1.intCommodityId AND iuom.intUnitMeasureId=ium.intUnitMeasureId 
		WHERE st.intCommodityId  = c.intCommodityId	AND st.intProcessingLocationId  = cl.intCompanyLocationId
		 and  st.intEntityId= CASE WHEN ISNULL(@intVendorId,0)=0 then st.intEntityId else @intVendorId end 	
		))t)  as OnHold  			               
FROM tblSMCompanyLocation cl  
JOIN tblICItemLocation lo ON lo.intLocationId = cl.intCompanyLocationId     
JOIN tblICItem i ON lo.intItemId = i.intItemId    
JOIN tblICCommodity c on c.intCommodityId=i.intCommodityId   
LEFT JOIN tblICCommodityUnitMeasure um on c.intCommodityId=um.intCommodityId   
LEFT JOIN tblICUnitMeasure u on um.intUnitMeasureId=u.intUnitMeasureId   
WHERE  ysnDefault=1   
 GROUP BY   
  c.intCommodityId   
 ,strCommodityCode    
 ,cl.intCompanyLocationId      
 ,cl.strLocationName 
 ,intLocationId  
 ,u.intUnitMeasureId      
 ,u.strUnitMeasure 
 ,um.intCommodityUnitMeasureId     
  )t  
)t1 

DECLARE @intUnitMeasureId int
DECLARE @strUnitMeasure nvarchar(50)
SELECT TOP 1 @intUnitMeasureId = intUnitMeasureId FROM tblRKCompanyPreference

if isnull(@intVendorId,0) = 0
BEGIN

SELECT @strUnitMeasure=strUnitMeasure FROM tblICUnitMeasure where intUnitMeasureId=@intUnitMeasureId
	SELECT distinct convert(int,row_number() over (order by t.intCommodityId,intLocationId)) intRowNum,t.strLocationName,intLocationId,	t.intCommodityId,strCommodityCode,
			case when isnull(@strUnitMeasure,'')='' then um.strUnitMeasure else @strUnitMeasure end as strUnitMeasure,  
			isnull(Convert(decimal(24,10),dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId,case when isnull(@intUnitMeasureId,0) = 0 then cuc.intCommodityUnitMeasureId else cuc1.intCommodityUnitMeasureId end,OpenPurchasesQty)),0) OpenPurchasesQty,
			isnull(Convert(decimal(24,10),dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId,case when isnull(@intUnitMeasureId,0) = 0 then cuc.intCommodityUnitMeasureId else cuc1.intCommodityUnitMeasureId end,OpenSalesQty)),0) OpenSalesQty,
			isnull(Convert(decimal(24,10),dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId,case when isnull(@intUnitMeasureId,0) = 0 then cuc.intCommodityUnitMeasureId else cuc1.intCommodityUnitMeasureId end,dblCompanyTitled)),0) dblCompanyTitled,
			isnull(Convert(decimal(24,10),dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId,case when isnull(@intUnitMeasureId,0) = 0 then cuc.intCommodityUnitMeasureId else cuc1.intCommodityUnitMeasureId end,dblCaseExposure)),0)+ isnull(DeltaOption,0) dblCaseExposure,
			isnull(Convert(decimal(24,10),dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId,case when isnull(@intUnitMeasureId,0) = 0 then cuc.intCommodityUnitMeasureId else cuc1.intCommodityUnitMeasureId end,dblBasisExposure)),0) OpenSalQty,
			isnull(Convert(decimal(24,10),dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId,case when isnull(@intUnitMeasureId,0) = 0 then cuc.intCommodityUnitMeasureId else cuc1.intCommodityUnitMeasureId end,dblAvailForSale)),0) dblAvailForSale,
			isnull(Convert(decimal(24,10),dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId,case when isnull(@intUnitMeasureId,0) = 0 then cuc.intCommodityUnitMeasureId else cuc1.intCommodityUnitMeasureId end,dblInHouse)),0) dblInHouse,
			isnull(Convert(decimal(24,10),dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId,case when isnull(@intUnitMeasureId,0) = 0 then cuc.intCommodityUnitMeasureId else cuc1.intCommodityUnitMeasureId end,dblBasisExposure)),0) dblBasisExposure			
FROM #temp t
	JOIN tblICCommodityUnitMeasure cuc on t.intCommodityId=cuc.intCommodityId and cuc.ysnDefault=1 
	JOIN tblICUnitMeasure um on um.intUnitMeasureId=cuc.intUnitMeasureId
	LEFT JOIN tblICCommodityUnitMeasure cuc1 on t.intCommodityId=cuc1.intCommodityId and @intUnitMeasureId=cuc1.intUnitMeasureId
	WHERE t.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ',')) 
	ORDER BY strCommodityCode
END
ELSE
BEGIN

SELECT @strUnitMeasure=strUnitMeasure FROM tblICUnitMeasure where intUnitMeasureId=@intUnitMeasureId
	SELECT distinct convert(int,row_number() over (order by t.intCommodityId,intLocationId)) intRowNum,t.strLocationName,intLocationId,	t.intCommodityId,strCommodityCode,
	case when isnull(@strUnitMeasure,'')='' then um.strUnitMeasure else @strUnitMeasure end as strUnitMeasure,  
			0.00 OpenPurchasesQty,
			0.00 OpenSalesQty,
			0.00 dblCompanyTitled,
			0.00 dblCaseExposure,
			0.00 OpenSalQty,
			0.00 dblAvailForSale,
			isnull(Convert(decimal(24,10),dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId,case when isnull(@intUnitMeasureId,0) = 0 then cuc.intCommodityUnitMeasureId else cuc1.intCommodityUnitMeasureId end,dblInHouse)),0) dblInHouse,
			0.00 dblBasisExposure			
FROM #temp t
	JOIN tblICCommodityUnitMeasure cuc on t.intCommodityId=cuc.intCommodityId and cuc.ysnDefault=1 
	JOIN tblICUnitMeasure um on um.intUnitMeasureId=cuc.intUnitMeasureId
	LEFT JOIN tblICCommodityUnitMeasure cuc1 on t.intCommodityId=cuc1.intCommodityId and @intUnitMeasureId=cuc1.intUnitMeasureId
	WHERE t.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ',')) 
	ORDER BY strCommodityCode

END

