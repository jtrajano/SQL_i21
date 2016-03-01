CREATE PROC [dbo].[uspRKDPRDailyPositionByCommodityLocation]  
    @intCommodityId nvarchar(max)
AS      

DECLARE @Commodity AS TABLE 
(
intCommodityIdentity int IDENTITY(1,1) PRIMARY KEY , 
intCommodity  INT
)
INSERT INTO @Commodity(intCommodity)
SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ',')  

SELECT strLocationName,OpenPurchasesQty,OpenSalesQty,intCommodityId,strCommodityCode,intUnitMeasureId,strUnitMeasure,isnull(CompanyTitled,0) as dblCompanyTitled,  
isnull(CashExposure,0) as dblCaseExposure,isnull(DeltaOption,0) DeltaOption,              
(isnull(CompanyTitledNonDP,0)+ (isnull(OpenPurchasesQty,0)-isnull(OpenSalesQty,0))) as dblBasisExposure ,             
(isnull(CompanyTitledNonDP,0)+ (isnull(OpenPurchasesQty,0)-isnull(OpenSalesQty,0))) - isnull(ReceiptProductQty,0) as dblAvailForSale,    
isnull(InHouse,0) as dblInHouse,intLocationId  into #temp            
 FROM(              
SELECT strLocationName,intCommodityId,strCommodityCode,strUnitMeasure,intUnitMeasureId, intLocationId, 
   isnull(invQty,0)-Case when (select top 1 ysnIncludeInTransitInCompanyTitled from tblRKCompanyPreference)=1 then  isnull(ReserveQty,0) else 0 end +  
   Case when (select top 1 ysnIncludeOffsiteInventoryInCompanyTitled from tblRKCompanyPreference)=1 then isnull(OffSite,0) else 0 end +  
   Case when (select top 1 ysnIncludeDPPurchasesInCompanyTitled from tblRKCompanyPreference)=1 then isnull(DP,0) else 0 end +   
   (isnull(dblCollatralPurchase,0)-isnull(dblCollatralSales,0))   + isnull(SlsBasisDeliveries,0)  AS CompanyTitled,

    isnull(invQty,0)-  isnull(ReserveQty,0)  + isnull(SlsBasisDeliveries,0)  
   AS CompanyTitledNonDP,       
   
      
            (isnull(invQty,0)-isnull(ReserveQty,0)) +             
            (isnull(OpenPurQty,0)-isnull(OpenSalQty,0))+              
   Case when (select top 1 ysnIncludeOffsiteInventoryInCompanyTitled from tblRKCompanyPreference)=1 then isnull(OffSite,0) else 0 end +  
   Case when (select top 1 ysnIncludeDPPurchasesInCompanyTitled from tblRKCompanyPreference)=1 then isnull(DP,0) else 0 end +   
   isnull(dblCollatralSales,0)  + isnull(SlsBasisDeliveries,0)  AS CashExposure,  
   
   
   (((isnull(FutLBalTransQty,0)-isnull(FutMatchedQty,0))- (isnull(FutSBalTransQty,0)-isnull(FutMatchedQty,0)) )*isnull(dblContractSize,1)) + isnull(DeltaOption,0)   DeltaOption,          
   isnull(ReceiptProductQty,0) ReceiptProductQty,
   isnull(OpenPurchasesQty,0) OpenPurchasesQty,
   isnull(OpenSalesQty,0) OpenSalesQty,
   isnull(OpenPurQty,0) OpenPurQty,
   isnull(invQty,0) + isnull(dblGrainBalance ,0)
   AS InHouse              
                 
FROM(  
SELECT distinct c.intCommodityId, strLocationName, intLocationId,    
  strCommodityCode,              
  u.intUnitMeasureId,              
  u.strUnitMeasure      
 ,(SELECT sum(Qty) FROM (
	SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,um.intCommodityUnitMeasureId,isnull((CD.dblBalance),0)) as Qty                   
	FROM vyuCTContractDetailView  CD     
	JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=CD.intCommodityId  
			AND CD.intUnitMeasureId=ium.intUnitMeasureId and intContractTypeId=1 and intPricingTypeId in(1,3) 
	WHERE  CD.intCommodityId=c.intCommodityId and cl.intCompanyLocationId  = CD.intCompanyLocationId)t) as OpenPurQty
		
	,(SELECT sum(Qty) FROM (
	SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,um.intCommodityUnitMeasureId,isnull((CD.dblBalance),0)) as Qty                   
	FROM vyuCTContractDetailView  CD     
	JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=CD.intCommodityId  
			AND CD.intUnitMeasureId=ium.intUnitMeasureId and intContractTypeId=2 and intPricingTypeId in(1,3) 
	WHERE  CD.intCommodityId=c.intCommodityId and cl.intCompanyLocationId  = CD.intCompanyLocationId)t) as OpenSalQty		
		
	,(SELECT sum(Qty) FROM (
	SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,um.intCommodityUnitMeasureId,isnull((CD.dblBalance),0)) as Qty                   
	FROM vyuCTContractDetailView  CD     
	JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=CD.intCommodityId  
			AND CD.intUnitMeasureId=ium.intUnitMeasureId and intContractTypeId=1 and intPricingTypeId in(1,2) 
	WHERE  CD.intCommodityId=c.intCommodityId and cl.intCompanyLocationId  = CD.intCompanyLocationId)t) as ReceiptProductQty		
	            
	,(SELECT sum(Qty) FROM (
	SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,um.intCommodityUnitMeasureId,isnull((CD.dblBalance),0)) as Qty                   
	FROM vyuCTContractDetailView  CD     
	JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=CD.intCommodityId  
			AND CD.intUnitMeasureId=ium.intUnitMeasureId and intContractTypeId=1 and intPricingTypeId in(1,2) 
	WHERE  CD.intCommodityId=c.intCommodityId and cl.intCompanyLocationId  = CD.intCompanyLocationId)t) as OpenPurchasesQty	
	      
	,(SELECT sum(Qty) FROM (
	SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,um.intCommodityUnitMeasureId,isnull((CD.dblBalance),0)) as Qty                   
	FROM vyuCTContractDetailView  CD     
	JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=CD.intCommodityId  
			AND CD.intUnitMeasureId=ium.intUnitMeasureId and intContractTypeId=2 and intPricingTypeId in(1,2) 
	WHERE  CD.intCommodityId=c.intCommodityId and cl.intCompanyLocationId  = CD.intCompanyLocationId)t) as OpenSalesQty			
     
	,(SELECT top 1 rfm.dblContractSize as dblContractSize from tblRKFutOptTransaction otr  
	JOIN tblRKFutureMarket rfm on rfm.intFutureMarketId=otr.intFutureMarketId  
	WHERE otr.intCommodityId=c.intCommodityId and otr.intLocationId=cl.intCompanyLocationId) dblContractSize     
              
	,(SELECT isnull(SUM(intNoOfContract),0) from tblRKFutOptTransaction otr  
		WHERE otr.strBuySell='Sell' AND otr.intCommodityId=c.intCommodityId  and intInstrumentTypeId=1
		and otr.intLocationId=cl.intCompanyLocationId ) FutSBalTransQty     
  
	,(SELECT isnull(SUM(intNoOfContract),0) from tblRKFutOptTransaction otr  
	WHERE otr.strBuySell='Buy' AND otr.intCommodityId=c.intCommodityId and intInstrumentTypeId=1 and otr.intLocationId=cl.intCompanyLocationId) as FutLBalTransQty,            
           
 (SELECT SUM(psd.dblMatchQty) from tblRKMatchFuturesPSHeader psh            
 JOIN tblRKMatchFuturesPSDetail psd on psd.intMatchFuturesPSHeaderId=psh.intMatchFuturesPSHeaderId            
 and intCommodityId=c.intCommodityId and psh.intCompanyLocationId=cl.intCompanyLocationId   ) FutMatchedQty  

		,(select sum(isnull(Qty,0)) Qty from(
		SELECT 
		 dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,um.intCommodityUnitMeasureId,isnull((a.dblUnitOnHand),0)) as Qty 
 		 FROM tblICItemStock a  
		  JOIN tblICItemLocation il on a.intItemLocationId=il.intItemLocationId   
		  JOIN tblICItem i on a.intItemId=i.intItemId  
		  JOIN tblSMCompanyLocation sl on sl.intCompanyLocationId=il.intLocationId  
		  JOIN tblICItemUOM iuom on i.intItemId=iuom.intItemId and ysnStockUnit=1
		  JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=i.intCommodityId AND iuom.intUnitMeasureId=ium.intUnitMeasureId 
		 WHERE sl.intCompanyLocationId=cl.intCompanyLocationId and i.intCommodityId= c.intCommodityId		 
		 )t) as invQty  
		 
		,(select sum(isnull(Qty,0)) Qty from(
		SELECT 
		 dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,um.intCommodityUnitMeasureId,isnull((sr1.dblQty),0)) as Qty 
 		 FROM tblICItemStock a  
		  JOIN tblICItemLocation il on a.intItemLocationId=il.intItemLocationId 
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
	  INNER JOIN vyuCTContractDetailView cd ON cd.intContractDetailId = ri.intLineNo AND cd.intPricingTypeId = 2 AND ri.intOrderId = 1  
	  	JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=cd.intCommodityId AND cd.intUnitMeasureId=ium.intUnitMeasureId
	  WHERE cd.intCommodityId = c.intCommodityId AND cd.intCompanyLocationId = cl.intCompanyLocationId)t) as SlsBasisDeliveries 
  
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
	 WHERE CH.intCommodityId = c.intCommodityId AND ysnDPOwnedType=1 and CH.intCompanyLocationId=cl.intCompanyLocationId)t) as DP 

	,(SELECT Sum(dblTotal) from (
     SELECT
     dbo.fnCTConvertQuantityToTargetCommodityUOM(CH.intCommodityUnitMeasureId,um.intCommodityUnitMeasureId,isnull(Balance,0)) dblTotal
	 FROM vyuGRGetStorageDetail CH  
	 WHERE CH.intCommodityId = c.intCommodityId AND ysnCustomerStorage <> 1 and CH.intCompanyLocationId=cl.intCompanyLocationId)t) as dblGrainBalance 

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
	INNER JOIN tblRKFutureMarket m ON ft.intFutureMarketId = m.intFutureMarketId and ft.intLocationId=cl.intCompanyLocationId 
	INNER JOIN tblRKFuturesMonth fm ON fm.intFutureMonthId = ft.intFutureMonthId AND fm.intFutureMarketId = ft.intFutureMarketId AND fm.ysnExpired = 0
	WHERE ft.intCommodityId = ft.intCommodityId AND intFutOptTransactionId NOT IN (
			SELECT intFutOptTransactionId FROM tblRKOptionsPnSExercisedAssigned	) AND intFutOptTransactionId NOT IN (SELECT intFutOptTransactionId FROM tblRKOptionsPnSExpired))t
	) DeltaOption               
FROM tblSMCompanyLocation cl  
JOIN tblICItemLocation lo ON lo.intLocationId = cl.intCompanyLocationId     
JOIN tblICItem i ON lo.intItemId = i.intItemId    
JOIN tblICCommodity c on c.intCommodityId=i.intCommodityId   
JOIN tblICCommodityUnitMeasure um on c.intCommodityId=um.intCommodityId   
JOIN tblICUnitMeasure u on um.intUnitMeasureId=u.intUnitMeasureId   
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

SELECT @strUnitMeasure=strUnitMeasure FROM tblICUnitMeasure where intUnitMeasureId=@intUnitMeasureId
	SELECT distinct convert(int,row_number() over (order by t.intCommodityId,intLocationId)) intRowNum,t.strLocationName,intLocationId,	t.intCommodityId,strCommodityCode,@strUnitMeasure as strUnitMeasure,  
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
	LEFT JOIN tblICCommodityUnitMeasure cuc1 on t.intCommodityId=cuc1.intCommodityId and @intUnitMeasureId=cuc1.intUnitMeasureId
	WHERE t.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ',')) 
	ORDER BY strCommodityCode


