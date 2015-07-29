CREATE VIEW [dbo].[vyuRKDPRDailyPositionByCommodityLocation]  
        
AS      
SELECT strLocationName,OpenPurchasesQty,OpenSalesQty,intCommodityId,strCommodityCode,strUnitMeasure,isnull(CompanyTitled,0) as dblCompanyTitled,  
isnull(CashExposure,0) as dblCaseExposure,              
(isnull(CompanyTitled,0)+ (isnull(OpenPurchasesQty,0)-isnull(OpenSalesQty,0))) as dblBasisExposure ,             
(isnull(CompanyTitled,0)+ (isnull(OpenPurchasesQty,0)-isnull(OpenSalesQty,0))) - isnull(ReceiptProductQty,0) as dblAvailForSale,  
  
isnull(CompanyTitled,0) as dblInHouse              
 FROM(              
SELECT strLocationName,intCommodityId,strCommodityCode,strUnitMeasure,  
   (invQty)-Case when (select top 1 ysnIncludeInTransitInCompanyTitled from tblRKCompanyPreference)=1 then  isnull(ReserveQty,0) else 0 end +  
   Case when (select top 1 ysnIncludeOffsiteInventoryInCompanyTitled from tblRKCompanyPreference)=1 then OffSite else 0 end +  
   Case when (select top 1 ysnIncludeDPPurchasesInCompanyTitled from tblRKCompanyPreference)=1 then DP else 0 end +   
   dblCollatralSales  + SlsBasisDeliveries  
   AS CompanyTitled,     
            (isnull(invQty,0)-isnull(ReserveQty,0)) +             
            (isnull(OpenPurQty,0)-isnull(OpenSalQty,0))              
            +(((isnull(FutLBalTransQty,0)-isnull(FutMatchedQty,0))- (isnull(FutSBalTransQty,0)-isnull(FutMatchedQty,0)) )*isnull(dblContractSize,1)) +              
   Case when (select top 1 ysnIncludeOffsiteInventoryInCompanyTitled from tblRKCompanyPreference)=1 then OffSite else 0 end +  
   Case when (select top 1 ysnIncludeDPPurchasesInCompanyTitled from tblRKCompanyPreference)=1 then DP else 0 end +   
   dblCollatralSales  + SlsBasisDeliveries           
            AS CashExposure,              
   ReceiptProductQty,OpenPurchasesQty,OpenSalesQty,OpenPurQty              
                 
FROM(  
SELECT distinct c.intCommodityId, strLocationName,     
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
     WHERE otr.strBuySell='Sell' AND otr.intCommodityId=c.intCommodityId  
     and otr.intLocationId=cl.intCompanyLocationId ) FutSBalTransQty     
  
 ,(SELECT isnull(SUM(intNoOfContract),0) from tblRKFutOptTransaction otr  
  WHERE otr.strBuySell='Buy' AND otr.intCommodityId=c.intCommodityId and otr.intLocationId=cl.intCompanyLocationId) as FutLBalTransQty,          
           
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
 sl.intCompanyLocationId=cl.intCompanyLocationId and i.intCommodityId= c.intCommodityId ) as ReserveQty  
 , (SELECT isnull(SUM(dblOriginalQuantity),0) - isnull(sum(dblAdjustmentAmount),0) as dblCollatralSales  
 FROM (  
  SELECT SUM(dblAdjustmentAmount) dblAdjustmentAmount  
   ,intContractHeaderId  
   ,isnull(SUM(dblOriginalQuantity),0) dblOriginalQuantity  
  FROM tblRKCollateral c1  
  INNER JOIN tblRKCollateralAdjustment ca ON c1.intCollateralId = ca.intCollateralId  
  WHERE strType = 'Sale'  
   AND c1.intCommodityId = c.intCommodityId AND c1.intLocationId = cl.intCompanyLocationId  
  GROUP BY intContractHeaderId  
  ) t WHERE dblAdjustmentAmount <> dblOriginalQuantity) as dblCollatralSales  
   
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
  WHERE ch.intCommodityId = c.intCommodityId AND ysnDPOwnedType=1 and ch.intCompanyLocationId=cl.intCompanyLocationId) as DP  
    
           
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
  u.intUnitMeasureId      
 ,u.strUnitMeasure    
  )t  
)t1 