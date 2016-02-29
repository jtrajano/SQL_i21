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
isnull(CashExposure,0) as dblCaseExposure,              
(isnull(CompanyTitledNonDP,0)+ (isnull(OpenPurchasesQty,0)-isnull(OpenSalesQty,0))) as dblBasisExposure ,             
(isnull(CompanyTitledNonDP,0)+ (isnull(OpenPurchasesQty,0)-isnull(OpenSalesQty,0))) - isnull(ReceiptProductQty,0) as dblAvailForSale,    
isnull(InHouse,0) as dblInHouse,intLocationId  into #temp            
 FROM(              
SELECT strLocationName,intCommodityId,strCommodityCode,strUnitMeasure,intUnitMeasureId, intLocationId, 
   (invQty)-Case when (select top 1 ysnIncludeInTransitInCompanyTitled from tblRKCompanyPreference)=1 then  isnull(ReserveQty,0) else 0 end +  
   Case when (select top 1 ysnIncludeOffsiteInventoryInCompanyTitled from tblRKCompanyPreference)=1 then OffSite else 0 end +  
   Case when (select top 1 ysnIncludeDPPurchasesInCompanyTitled from tblRKCompanyPreference)=1 then DP else 0 end +   
   (isnull(dblCollatralPurchase,0)-isnull(dblCollatralSales,0))   + SlsBasisDeliveries  AS CompanyTitled,

    (invQty)-Case when (select top 1 ysnIncludeInTransitInCompanyTitled from tblRKCompanyPreference)=1 then  isnull(ReserveQty,0) else 0 end +  
   Case when (select top 1 ysnIncludeOffsiteInventoryInCompanyTitled from tblRKCompanyPreference)=1 then OffSite else 0 end +  
   (isnull(dblCollatralPurchase,0)-isnull(dblCollatralSales,0))  + SlsBasisDeliveries  
   AS CompanyTitledNonDP,          
            (isnull(invQty,0)-isnull(ReserveQty,0)) +             
            (isnull(OpenPurQty,0)-isnull(OpenSalQty,0))              
            +(((isnull(FutLBalTransQty,0)-isnull(FutMatchedQty,0))- (isnull(FutSBalTransQty,0)-isnull(FutMatchedQty,0)) )*isnull(dblContractSize,1)) +              
   Case when (select top 1 ysnIncludeOffsiteInventoryInCompanyTitled from tblRKCompanyPreference)=1 then OffSite else 0 end +  
   Case when (select top 1 ysnIncludeDPPurchasesInCompanyTitled from tblRKCompanyPreference)=1 then DP else 0 end +   
   dblCollatralSales  + SlsBasisDeliveries+DeltaOption AS CashExposure,              
   ReceiptProductQty,OpenPurchasesQty,OpenSalesQty,OpenPurQty,
   (invQty)- isnull(ReserveQty,0)  + isnull(dblGrainBalance ,0)
   AS InHouse              
                 
FROM(  
SELECT distinct c.intCommodityId, strLocationName, intLocationId,    
  strCommodityCode,              
  u.intUnitMeasureId,              
  u.strUnitMeasure              
     ,(SELECT               
   isnull(Sum(CD.dblBalance),0) as Qty                   
   FROM tblCTContractDetail  CD                   
   JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId  = CD.intCompanyLocationId                
   JOIN tblCTContractHeader  CH ON CH.intContractHeaderId  = CD.intContractHeaderId    and CH.intContractTypeId=1              
   JOIN tblCTPricingType  PT ON PT.intPricingTypeId     = CD.intPricingTypeId and PT.intPricingTypeId in(1,3)               
   JOIN tblCTContractType  TP ON TP.intContractTypeId     = CH.intContractTypeId where CH.intCommodityId=c.intCommodityId  
    and CD.intCompanyLocationId=cl.intCompanyLocationId) as OpenPurQty              
   ,(SELECT               
   isnull(Sum(CD.dblBalance),0) as Qty                   
   FROM tblCTContractDetail  CD                   
   JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId  = CD.intCompanyLocationId                
   JOIN tblCTContractHeader  CH ON CH.intContractHeaderId  = CD.intContractHeaderId    and CH.intContractTypeId=2              
   JOIN tblCTPricingType  PT ON PT.intPricingTypeId     = CD.intPricingTypeId and PT.intPricingTypeId  in(1,3)               
   JOIN tblCTContractType  TP ON TP.intContractTypeId     = CH.intContractTypeId where CH.intCommodityId=c.intCommodityId  
    and CD.intCompanyLocationId=cl.intCompanyLocationId) as OpenSalQty              
    ,(SELECT               
   isnull(Sum(CD.dblBalance),0) as Qty                   
   FROM tblCTContractDetail  CD                   
   JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId  = CD.intCompanyLocationId                
   JOIN tblCTContractHeader  CH ON CH.intContractHeaderId  = CD.intContractHeaderId   and CH.intContractTypeId=1              
   JOIN tblCTPricingType  PT ON PT.intPricingTypeId     = CD.intPricingTypeId and PT.intPricingTypeId in(1,2)               
   JOIN tblCTContractType  TP ON TP.intContractTypeId     = CH.intContractTypeId where CH.intCommodityId=c.intCommodityId  
    and CD.intCompanyLocationId=cl.intCompanyLocationId) as ReceiptProductQty              
    ,(SELECT               
   isnull(Sum(CD.dblBalance),0) as Qty                   
   FROM tblCTContractDetail  CD                   
   JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId  = CD.intCompanyLocationId                
   JOIN tblCTContractHeader  CH ON CH.intContractHeaderId  = CD.intContractHeaderId  and CH.intContractTypeId=1                 
   JOIN tblCTPricingType  PT ON PT.intPricingTypeId     = CD.intPricingTypeId and PT.intPricingTypeId in(1,2)               
   JOIN tblCTContractType  TP ON TP.intContractTypeId     = CH.intContractTypeId where CH.intCommodityId=c.intCommodityId  
    and CD.intCompanyLocationId=cl.intCompanyLocationId) as OpenPurchasesQty  --req            
    ,(SELECT               
   isnull(Sum(CD.dblBalance),0) as Qty                   
   FROM tblCTContractDetail  CD                   
   JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId  = CD.intCompanyLocationId                
   JOIN tblCTContractHeader  CH ON CH.intContractHeaderId  = CD.intContractHeaderId   and  CH.intContractTypeId= 2               
   JOIN tblCTPricingType  PT ON PT.intPricingTypeId     = CD.intPricingTypeId and PT.intPricingTypeId in(1,2)               
   JOIN tblCTContractType  TP ON TP.intContractTypeId     = CH.intContractTypeId where CH.intCommodityId=c.intCommodityId   
   and CD.intCompanyLocationId=cl.intCompanyLocationId) as OpenSalesQty    --req          
      
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
,(SELECT sum(isnull(a.dblUnitOnHand,0))   
  from tblICItemStock a  
  JOIN tblICItemLocation il on a.intItemLocationId=il.intItemLocationId   
  JOIN tblICItem i on a.intItemId=i.intItemId  
  JOIN tblSMCompanyLocation sl on sl.intCompanyLocationId=il.intLocationId  
 WHERE sl.intCompanyLocationId=cl.intCompanyLocationId and i.intCommodityId= c.intCommodityId) as invQty  
,(SELECT SUM(isnull(sr1.dblQty,0))        
 from tblICItemStock a  
  JOIN tblICItemLocation il on a.intItemLocationId=il.intItemLocationId   
  JOIN tblICItem i on a.intItemId=i.intItemId  
  JOIN tblSMCompanyLocation sl on sl.intCompanyLocationId=il.intLocationId    
  JOIN tblICStockReservation sr1 ON a.intItemId = sr1.intItemId     
 WHERE   
 sl.intCompanyLocationId=cl.intCompanyLocationId and i.intCommodityId= c.intCommodityId ) as ReserveQty,  

isnull((SELECT isnull(SUM(dblOriginalQuantity), 0) - isnull(sum(dblAdjustmentAmount), 0) CollateralSale
		FROM (SELECT isnull(SUM(dblAdjustmentAmount), 0) dblAdjustmentAmount,intContractHeaderId,isnull(SUM(dblOriginalQuantity), 0) dblOriginalQuantity
				FROM tblRKCollateral c1
				LEFT JOIN tblRKCollateralAdjustment ca ON c1.intCollateralId = ca.intCollateralId
				WHERE strType = 'Sale' AND c1.intCommodityId = c.intCommodityId AND c1.intLocationId = cl.intCompanyLocationId 	
				GROUP BY intContractHeaderId) t WHERE dblAdjustmentAmount <> dblOriginalQuantity), 0) AS dblCollatralSales,

isnull((SELECT isnull(SUM(dblOriginalQuantity), 0) - isnull(sum(dblAdjustmentAmount), 0) CollateralSale
		FROM (SELECT isnull(SUM(dblAdjustmentAmount), 0) dblAdjustmentAmount,intContractHeaderId,isnull(SUM(dblOriginalQuantity), 0) dblOriginalQuantity
				FROM tblRKCollateral c1
				LEFT JOIN tblRKCollateralAdjustment ca ON c1.intCollateralId = ca.intCollateralId
				WHERE strType = 'Purchase' AND c1.intCommodityId = c.intCommodityId AND c1.intLocationId = cl.intCompanyLocationId 	
				GROUP BY intContractHeaderId) t WHERE dblAdjustmentAmount <> dblOriginalQuantity), 0) AS dblCollatralPurchase
   
  ,(SELECT isnull(SUM(isnull(ri.dblQuantity, 0)),0) AS SlsBasisDeliveries  
  FROM tblICInventoryShipment r  
  INNER JOIN tblICInventoryShipmentItem ri ON r.intInventoryShipmentId = ri.intInventoryShipmentId  
  INNER JOIN tblCTContractDetail cd ON cd.intContractDetailId = ri.intLineNo AND cd.intPricingTypeId = 2 AND ri.intOrderId = 1  
  INNER JOIN tblCTContractHeader ch ON ch.intContractHeaderId = cd.intContractHeaderId  
  WHERE ch.intCommodityId = c.intCommodityId AND cd.intCompanyLocationId = cl.intCompanyLocationId) as SlsBasisDeliveries  
  ,(SELECT isnull(sum(Balance),0) dblTotal  
  FROM vyuGRGetStorageDetail CH  
  WHERE ysnCustomerStorage = 1 AND strOwnedPhysicalStock = 'Company'  
  AND CH.intCommodityId=c.intCommodityId and CH.intCompanyLocationId=cl.intCompanyLocationId) as OffSite  
  ,(SELECT   
  isnull(SUM(Balance),0) DP  
  FROM vyuGRGetStorageDetail ch  
  WHERE ch.intCommodityId = c.intCommodityId AND ysnDPOwnedType=1 and ch.intCompanyLocationId=cl.intCompanyLocationId) as DP,
  (	SELECT SUM(Balance)	FROM vyuGRGetStorageDetail
				WHERE ysnCustomerStorage <> 1 AND intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ',')) 
				AND intCompanyLocationId =cl.intCompanyLocationId) dblGrainBalance,  
  (select sum(isnull(dblNoOfContract,0)) dblNoOfContract from (SELECT  (CASE WHEN ft.strBuySell = 'Buy' THEN (
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
	WHERE ft.intCommodityId = c.intCommodityId and ft.intLocationId =cl.intCompanyLocationId AND intFutOptTransactionId NOT IN (
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
 ,cl.strLocationName, 
 intLocationId,  
  u.intUnitMeasureId      
 ,u.strUnitMeasure    
  )t  
)t1 

DECLARE @intUnitMeasureId int
DECLARE @strUnitMeasure nvarchar(50)
SELECT TOP 1 @intUnitMeasureId = intUnitMeasureId FROM tblRKCompanyPreference

IF ISNULL(@intUnitMeasureId,'')<> ''
BEGIN
	SELECT @strUnitMeasure=strUnitMeasure FROM tblICUnitMeasure where intUnitMeasureId=@intUnitMeasureId
	SELECT distinct convert(int,row_number() over (order by t.intCommodityId,intLocationId)) intRowNum,t.strLocationName,intLocationId, 
			Convert(decimal(24,10),dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId,case when isnull(cuc1.intCommodityUnitMeasureId,0) = 0 then cuc.intCommodityUnitMeasureId else cuc1.intCommodityUnitMeasureId end,OpenPurchasesQty)) OpenPurchasesQty,
			Convert(decimal(24,10),dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId,case when isnull(cuc1.intCommodityUnitMeasureId,0) = 0 then cuc.intCommodityUnitMeasureId else cuc1.intCommodityUnitMeasureId end,OpenSalesQty)) OpenSalesQty,
			t.intCommodityId,strCommodityCode,@strUnitMeasure as strUnitMeasure, 
			Convert(decimal(24,10),dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId,case when isnull(cuc1.intCommodityUnitMeasureId,0) = 0 then cuc.intCommodityUnitMeasureId else cuc1.intCommodityUnitMeasureId end,dblCompanyTitled)) dblCompanyTitled,
			Convert(decimal(24,10),dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId,case when isnull(cuc1.intCommodityUnitMeasureId,0) = 0 then cuc.intCommodityUnitMeasureId else cuc1.intCommodityUnitMeasureId end,dblCaseExposure)) dblCaseExposure,
			Convert(decimal(24,10),dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId,case when isnull(cuc1.intCommodityUnitMeasureId,0) = 0 then cuc.intCommodityUnitMeasureId else cuc1.intCommodityUnitMeasureId end,dblBasisExposure)) OpenSalQty,
			Convert(decimal(24,10),dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId,case when isnull(cuc1.intCommodityUnitMeasureId,0) = 0 then cuc.intCommodityUnitMeasureId else cuc1.intCommodityUnitMeasureId end,dblAvailForSale)) dblAvailForSale,
			Convert(decimal(24,10),dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId,case when isnull(cuc1.intCommodityUnitMeasureId,0) = 0 then cuc.intCommodityUnitMeasureId else cuc1.intCommodityUnitMeasureId end,dblInHouse)) dblInHouse,
			Convert(decimal(24,10),dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId,case when isnull(cuc1.intCommodityUnitMeasureId,0) = 0 then cuc.intCommodityUnitMeasureId else cuc1.intCommodityUnitMeasureId end,dblBasisExposure)) dblBasisExposure		
	FROM #temp t
	JOIN tblICCommodityUnitMeasure cuc on t.intCommodityId=cuc.intCommodityId and cuc.ysnDefault=1 
	JOIN tblICCommodityUnitMeasure cuc1 on t.intCommodityId=cuc1.intCommodityId and @intUnitMeasureId=cuc1.intUnitMeasureId
	WHERE t.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ',')) 
	ORDER BY strCommodityCode
END
ELSE
BEGIN
	SELECT convert(int,row_number() over (order by intCommodityId,intLocationId)) intRowNum, strLocationName,intLocationId,
	Convert(decimal(24,10),OpenPurchasesQty) OpenPurchasesQty,
	Convert(decimal(24,10),OpenSalesQty) OpenSalesQty,
	intCommodityId,strCommodityCode,strUnitMeasure,
	Convert(decimal(24,10),dblCompanyTitled) dblCompanyTitled,
	Convert(decimal(24,10),dblCaseExposure) dblCaseExposure,
	Convert(decimal(24,10),dblBasisExposure) as OpenSalQty,
	Convert(decimal(24,10),dblAvailForSale) dblAvailForSale,
	Convert(decimal(24,10),dblInHouse) dblInHouse,
	Convert(decimal(24,10),dblBasisExposure) dblBasisExposure	FROM #temp Where intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))  ORDER BY strCommodityCode
END