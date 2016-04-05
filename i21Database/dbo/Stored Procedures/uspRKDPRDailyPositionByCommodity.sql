CREATE PROC [dbo].[uspRKDPRDailyPositionByCommodity]
AS
          
SELECT OpenPurchasesQty,OpenSalesQty,intCommodityId,strCommodityCode,strUnitMeasure,intUnitMeasureId,isnull(CompanyTitled,0) as dblCompanyTitled,  
isnull(CashExposure,0) as dblCaseExposure,DeltaOption,              
(isnull(CompanyTitledNonDP,0)+ (isnull(OpenPurchasesQty,0)-isnull(OpenSalesQty,0))) as dblBasisExposure ,             
(isnull(CompanyTitledNonDP,0)+ (isnull(OpenPurchasesQty,0)-isnull(OpenSalesQty,0))) - isnull(ReceiptProductQty,0) as dblAvailForSale,    
isnull(InHouse,0) as dblInHouse,  OpenPurQty,    OpenSalQty   into #temp     
 FROM(              
SELECT intCommodityId,strCommodityCode,strUnitMeasure,intUnitMeasureId,  


   isnull(invQty,0)-Case when (select top 1 ysnIncludeInTransitInCompanyTitled from tblRKCompanyPreference)=1 then  isnull(ReserveQty,0) else 0 end +  
   CASE WHEN (SELECT TOP 1 ysnIncludeOffsiteInventoryInCompanyTitled from tblRKCompanyPreference)=1 then isnull(OffSite,0) else 0 end +  
   CASE WHEN (SELECT TOP 1 ysnIncludeDPPurchasesInCompanyTitled from tblRKCompanyPreference)=1 then isnull(DP,0) else 0 end +   
   (isnull(dblCollatralPurchase,0)-isnull(dblCollatralSales,0)) + isnull(SlsBasisDeliveries ,0) 
   AS CompanyTitled,  

    isnull(invQty,0)-  isnull(ReserveQty,0)  + isnull(SlsBasisDeliveries,0)  
   AS CompanyTitledNonDP,   
    isnull(OpenSalQty,0) OpenSalQty, 
	  
    (isnull(invQty,0) - isnull(PurBasisDelivary,0)) + (isnull(OpenPurQty,0)-isnull(OpenSalQty,0))+    isnull(dblCollatralSales,0)  + isnull(SlsBasisDeliveries,0)  AS CashExposure,   
      
    (((isnull(FutLBalTransQty,0)-isnull(FutMatchedQty,0))- (isnull(FutSBalTransQty,0)-isnull(FutMatchedQty,0)) )*isnull(dblContractSize,1)) + isnull(DeltaOption,0)   DeltaOption,                       
   isnull(ReceiptProductQty,0) ReceiptProductQty,
   isnull(OpenPurchasesQty,0) OpenPurchasesQty,
   isnull(OpenSalesQty,0) OpenSalesQty,
   isnull(OpenPurQty,0) OpenPurQty,
      isnull(invQty,0) + isnull(dblGrainBalance,0)+CASE WHEN (SELECT TOP 1 ysnIncludeDPPurchasesInCompanyTitled from tblRKCompanyPreference)=1 then isnull(DP,0) else 0 end + isnull(OnHold,0)   AS InHouse     
FROM(  
SELECT DISTINCT c.intCommodityId,              
  strCommodityCode,              
  u.intUnitMeasureId,              
  u.strUnitMeasure  ,um.intCommodityUnitMeasureId b           
     ,(SELECT sum(Qty) FROM (
		SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,um.intCommodityUnitMeasureId,isnull((CD.dblBalance),0)) as Qty                   
		FROM vyuCTContractDetailView  CD     
		JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=CD.intCommodityId  
				AND CD.intUnitMeasureId=ium.intUnitMeasureId and intContractTypeId=1 and intPricingTypeId in(1,3) 
		WHERE  CD.intCommodityId=c.intCommodityId)t) as OpenPurQty
  
      ,(SELECT sum(Qty) FROM (
		SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,um.intCommodityUnitMeasureId,isnull((CD.dblBalance),0)) as Qty                   
		FROM vyuCTContractDetailView  CD     
		JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=CD.intCommodityId  
				AND CD.intUnitMeasureId=ium.intUnitMeasureId and intContractTypeId=2 and intPricingTypeId in(1,3) 
		WHERE  CD.intCommodityId=c.intCommodityId)t)  OpenSalQty   
          
   ,(SELECT Sum(dblTotal) from (
    SELECT
     dbo.fnCTConvertQuantityToTargetCommodityUOM(CH.intCommodityUnitMeasureId,um.intCommodityUnitMeasureId,isnull(Balance,0)) dblTotal
	 FROM vyuGRGetStorageDetail CH  
	 WHERE ysnCustomerStorage = 1 AND strOwnedPhysicalStock = 'Company'  
	 AND CH.intCommodityId=c.intCommodityId)t) as OffSite
	
	,(SELECT Sum(dblTotal) from (
    SELECT
     dbo.fnCTConvertQuantityToTargetCommodityUOM(CH.intCommodityUnitMeasureId,um.intCommodityUnitMeasureId,isnull(Balance,0)) dblTotal
	 FROM vyuGRGetStorageDetail CH  
	 WHERE CH.intCommodityId = c.intCommodityId AND ysnDPOwnedType=1)t) as DP

	 	,(SELECT sum(Qty) FROM (
		SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,um.intCommodityUnitMeasureId,isnull((CD.dblBalance),0)) as Qty                   
		FROM vyuCTContractDetailView  CD     
		JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=CD.intCommodityId  
				AND CD.intUnitMeasureId=ium.intUnitMeasureId and intContractTypeId=1 and intPricingTypeId in(1,2) 
		WHERE  CD.intCommodityId=c.intCommodityId)t) as ReceiptProductQty     
             
     ,(SELECT sum(Qty) FROM (
		SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,um.intCommodityUnitMeasureId,isnull((CD.dblBalance),0)) as Qty                   
		FROM vyuCTContractDetailView  CD     
		JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=CD.intCommodityId  
				AND CD.intUnitMeasureId=ium.intUnitMeasureId and intContractTypeId=1 and intPricingTypeId in(1,2) 
		WHERE  CD.intCommodityId=c.intCommodityId)t) as OpenPurchasesQty   

    ,(SELECT sum(Qty) FROM (
		SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,um.intCommodityUnitMeasureId,isnull((CD.dblBalance),0)) as Qty                   
		FROM vyuCTContractDetailView  CD     
		JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=CD.intCommodityId  
				AND CD.intUnitMeasureId=ium.intUnitMeasureId and intContractTypeId=2 and intPricingTypeId in(1,2) 
		WHERE  CD.intCommodityId=c.intCommodityId)t) as OpenSalesQty 
           
		,(SELECT top 1 rfm.dblContractSize as dblContractSize from tblRKFutOptTransaction otr  
		JOIN tblRKFutureMarket rfm on rfm.intFutureMarketId=otr.intFutureMarketId  
		WHERE otr.intCommodityId=c.intCommodityId GROUP BY rfm.intFutureMarketId,rfm.dblContractSize) dblContractSize     
              
		,(SELECT isnull(SUM(intNoOfContract),0) from tblRKFutOptTransaction otr  
		WHERE otr.strBuySell='Sell' and intInstrumentTypeId=1 AND otr.intCommodityId=c.intCommodityId) FutSBalTransQty     
  
		,(SELECT isnull(SUM(intNoOfContract),0) from tblRKFutOptTransaction otr  
		WHERE otr.strBuySell='Buy' and intInstrumentTypeId=1 AND otr.intCommodityId=c.intCommodityId) as FutLBalTransQty,          
           
		(SELECT SUM(psd.dblMatchQty) from tblRKMatchFuturesPSHeader psh            
		JOIN tblRKMatchFuturesPSDetail psd on psd.intMatchFuturesPSHeaderId=psh.intMatchFuturesPSHeaderId            
		WHERE intCommodityId=c.intCommodityId) FutMatchedQty   
  
		,(select sum(Qty) Qty from(
		SELECT 
		 dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,um.intCommodityUnitMeasureId,isnull((it1.dblUnitOnHand),0)) as Qty 
 		 FROM tblICItem i1   
		 JOIN tblICItemStock it1 ON it1.intItemId = i1.intItemId and i1.intCommodityId= c.intCommodityId
		 JOIN tblICItemUOM iuom on i1.intItemId=iuom.intItemId and ysnStockUnit=1
		 JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=i1.intCommodityId AND iuom.intUnitMeasureId=ium.intUnitMeasureId 
		 )t) as invQty   

		,(SELECT sum(Qty) Qty from(
		 SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,um.intCommodityUnitMeasureId,isnull((sr1.dblQty),0)) as Qty 
 		 FROM tblICItem i1   
		 JOIN tblICItemStock it1 ON it1.intItemId = i1.intItemId and i1.intCommodityId= c.intCommodityId
		 JOIN tblICStockReservation sr1 ON it1.intItemId = sr1.intItemId 
		 JOIN tblICItemUOM iuom on i1.intItemId=iuom.intItemId and ysnStockUnit=1
		 JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=i1.intCommodityId AND iuom.intUnitMeasureId=ium.intUnitMeasureId 
		 )t) as ReserveQty   
  

 ,isnull((SELECT isnull(SUM(dblOriginalQuantity), 0) - isnull(sum(dblAdjustmentAmount), 0) CollateralSale
		FROM ( 
		SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,um.intCommodityUnitMeasureId,isnull((SUM(dblAdjustmentAmount)),0)) dblAdjustmentAmount,
				intContractHeaderId,
				dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,um.intCommodityUnitMeasureId,isnull((SUM(dblOriginalQuantity)),0)) dblOriginalQuantity
				FROM tblRKCollateral c1
				LEFT JOIN tblRKCollateralAdjustment ca ON c1.intCollateralId = ca.intCollateralId
				JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=c1.intCommodityId AND c1.intUnitMeasureId=ium.intUnitMeasureId 
				WHERE strType = 'Sale' AND c1.intCommodityId = c.intCommodityId 
				GROUP BY intContractHeaderId,ium.intCommodityUnitMeasureId) t 	WHERE dblAdjustmentAmount <> dblOriginalQuantity
		), 0) AS dblCollatralSales,

 isnull((SELECT isnull(SUM(dblOriginalQuantity), 0) - isnull(sum(dblAdjustmentAmount), 0) CollateralSale
		FROM ( 
		SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,um.intCommodityUnitMeasureId,isnull((SUM(dblAdjustmentAmount)),0)) dblAdjustmentAmount,
				intContractHeaderId,
				dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,um.intCommodityUnitMeasureId,isnull((SUM(dblOriginalQuantity)),0)) dblOriginalQuantity
				FROM tblRKCollateral c1
				LEFT JOIN tblRKCollateralAdjustment ca ON c1.intCollateralId = ca.intCollateralId
				JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=c1.intCommodityId AND c1.intUnitMeasureId=ium.intUnitMeasureId 
				WHERE strType = 'Purchase' AND c1.intCommodityId = c.intCommodityId 
				GROUP BY intContractHeaderId,ium.intCommodityUnitMeasureId) t 	WHERE dblAdjustmentAmount <> dblOriginalQuantity
		), 0) AS dblCollatralPurchase,
			  
	 (SELECT sum(isnull(SlsBasisDeliveries,0)) from( 
	 SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,um.intCommodityUnitMeasureId,isnull(ri.dblQuantity,0)) SlsBasisDeliveries
	 FROM tblICInventoryShipment r  
	 INNER JOIN tblICInventoryShipmentItem ri ON r.intInventoryShipmentId = ri.intInventoryShipmentId  
	 INNER JOIN vyuCTContractDetailView cd ON cd.intContractDetailId = ri.intLineNo AND cd.intPricingTypeId = 2 AND ri.intOrderId = 1  
	 JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=cd.intCommodityId 
	 WHERE cd.intCommodityId = c.intCommodityId)t) as SlsBasisDeliveries,
 
 (SELECT Sum(dblTotal) from (
    SELECT
     dbo.fnCTConvertQuantityToTargetCommodityUOM(CH.intCommodityUnitMeasureId,um.intCommodityUnitMeasureId,isnull(Balance,0)) dblTotal
	 FROM vyuGRGetStorageDetail CH  
	 WHERE ysnCustomerStorage <> 1 AND CH.intCommodityId = c.intCommodityId)t) as dblGrainBalance,

 (SELECT sum(isnull(dblNoOfContract,0)) dblNoOfContract from (SELECT  (CASE WHEN ft.strBuySell = 'Buy' THEN (
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
	INNER JOIN tblRKFutureMarket m ON ft.intFutureMarketId = m.intFutureMarketId
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
		INNER JOIN vyuCTContractDetailView CT ON CT.intContractDetailId = Lots.intContractDetailId
		JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=CT.intCommodityId AND CT.intUnitMeasureId=ium.intUnitMeasureId 
		INNER JOIN tblSMCompanyLocation  cl on cl.intCompanyLocationId=CT.intCompanyLocationId
		WHERE CT.intPricingTypeId = 2 AND CT.intCommodityId = c.intCommodityId 
		UNION 
		SELECT
		dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,um.intCommodityUnitMeasureId,isnull(ri.dblReceived, 0))  AS dblTotal
		FROM tblICInventoryReceipt r
		INNER JOIN tblICInventoryReceiptItem ri ON r.intInventoryReceiptId = ri.intInventoryReceiptId AND r.strReceiptType = 'Purchase Contract'
		INNER JOIN tblSCTicket st ON st.intTicketId = ri.intSourceId  AND strDistributionOption IN ('CNT')
		INNER JOIN vyuCTContractDetailView cd ON cd.intContractDetailId = ri.intLineNo AND cd.intPricingTypeId = 2
		JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=cd.intCommodityId AND cd.intUnitMeasureId=ium.intUnitMeasureId 
		INNER JOIN tblSMCompanyLocation  cl on cl.intCompanyLocationId=st.intProcessingLocationId 
		WHERE cd.intCommodityId = c.intCommodityId 	
		)t) AS PurBasisDelivary,
		
		(select sum(dblTotal) from (SELECT	dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,um.intCommodityUnitMeasureId,isnull(st.dblNetUnits, 0))  AS dblTotal
				FROM tblSCTicket st
				JOIN tblICItem i1 on i1.intItemId=st.intItemId and st.strDistributionOption='HLD'
				JOIN tblICItemUOM iuom on i1.intItemId=iuom.intItemId and ysnStockUnit=1
				JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=i1.intCommodityId AND iuom.intUnitMeasureId=ium.intUnitMeasureId 
				WHERE st.intCommodityId  = c.intCommodityId)t) OnHold
			       
FROM tblICCommodity c              
LEFT JOIN tblICCommodityUnitMeasure um on c.intCommodityId=um.intCommodityId and ysnDefault=1                
LEFT JOIN tblICUnitMeasure u on um.intUnitMeasureId=u.intUnitMeasureId          
GROUP BY c.intCommodityId,              
  strCommodityCode,              
  u.intUnitMeasureId,              
  u.strUnitMeasure,
  um.intCommodityUnitMeasureId          
             
    
  )t  
)t1

DECLARE @intUnitMeasureId int
DECLARE @strUnitMeasure nvarchar(50)
SELECT TOP 1 @intUnitMeasureId = intUnitMeasureId FROM tblRKCompanyPreference

SELECT @strUnitMeasure=strUnitMeasure FROM tblICUnitMeasure where intUnitMeasureId=@intUnitMeasureId
SELECT Convert(decimal(24,10),(OpenPurchasesQty)) OpenPurchasesQty
,Convert(decimal(24,10),(OpenSalQty)) OpenSalQty
,t.intCommodityId
,strCommodityCode
,@strUnitMeasure as strUnitMeasure
,t.intUnitMeasureId,
		Convert(decimal(24,10),(isnull(dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId,case when isnull(@intUnitMeasureId,0)=0 then cuc.intCommodityUnitMeasureId else cuc1.intCommodityUnitMeasureId end,dblBasisExposure),0))) dblBasisExposure,
		Convert(decimal(24,10),(isnull(dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId,case when isnull(@intUnitMeasureId,0)=0 then cuc.intCommodityUnitMeasureId else cuc1.intCommodityUnitMeasureId end,dblCompanyTitled),0))) dblCompanyTitled,
		Convert(decimal(24,10),(isnull(dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId,case when isnull(@intUnitMeasureId,0)=0 then cuc.intCommodityUnitMeasureId else cuc1.intCommodityUnitMeasureId end,dblCaseExposure),0)))+DeltaOption dblCaseExposure,
		Convert(decimal(24,10),(isnull(dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId,case when isnull(@intUnitMeasureId,0)=0 then cuc.intCommodityUnitMeasureId else cuc1.intCommodityUnitMeasureId end,dblAvailForSale),0))) dblAvailForSale,
		Convert(decimal(24,10),(isnull(dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId,case when isnull(@intUnitMeasureId,0)=0 then cuc.intCommodityUnitMeasureId else cuc1.intCommodityUnitMeasureId end,dblInHouse),0))) dblInHouse,
		Convert(decimal(24,10),(isnull(dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId,case when isnull(@intUnitMeasureId,0)=0 then cuc.intCommodityUnitMeasureId else cuc1.intCommodityUnitMeasureId end,OpenPurQty),0))) OpenPurQty,
		Convert(decimal(24,10),(isnull(dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId,case when isnull(@intUnitMeasureId,0)=0 then cuc.intCommodityUnitMeasureId else cuc1.intCommodityUnitMeasureId end,OpenSalQty),0))) OpenSalQty
from #temp t
JOIN tblICCommodityUnitMeasure cuc on t.intCommodityId=cuc.intCommodityId and cuc.ysnDefault=1 
LEFT JOIN tblICCommodityUnitMeasure cuc1 on t.intCommodityId=cuc1.intCommodityId and @intUnitMeasureId=cuc1.intUnitMeasureId
