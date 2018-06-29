CREATE VIEW [dbo].[vyuRKDPRDailyPositionByCommodity]  
AS             
SELECT OpenPurchasesQty,OpenSalesQty,intCommodityId,strCommodityCode,strUnitMeasure,isnull(CompanyTitled,0) as dblCompanyTitled,  
isnull(CashExposure,0) as dblCaseExposure,              
(isnull(CompanyTitled,0)+ (isnull(OpenPurchasesQty,0)-isnull(OpenSalesQty,0))) as dblBasisExposure ,             
(isnull(CompanyTitled,0)+ (isnull(OpenPurchasesQty,0)-isnull(OpenSalesQty,0))) - isnull(ReceiptProductQty,0) as dblAvailForSale,  
  
isnull(CompanyTitled,0) as dblInHouse,  OpenPurQty,    OpenSalQty        
 FROM(              
SELECT intCommodityId,strCommodityCode,strUnitMeasure,  
   (invQty)-Case when (select top 1 ysnIncludeInTransitInCompanyTitled from tblRKCompanyPreference)=1 then  isnull(ReserveQty,0) else 0 end +  
   Case when (select top 1 ysnIncludeOffsiteInventoryInCompanyTitled from tblRKCompanyPreference)=1 then OffSite else 0 end +  
   Case when (select top 1 ysnIncludeDPPurchasesInCompanyTitled from tblRKCompanyPreference)=1 then DP else 0 end +   
   dblCollatralSales  + SlsBasisDeliveries  
   AS CompanyTitled,  
    OpenSalQty,   
            (isnull(invQty,0)-isnull(ReserveQty,0)) +             
            (isnull(OpenPurQty,0)-isnull(OpenSalQty,0))              
            +(((isnull(FutLBalTransQty,0)-isnull(FutMatchedQty,0))- (isnull(FutSBalTransQty,0)-isnull(FutMatchedQty,0)) )*isnull(dblContractSize,1))+  
              
   Case when (select top 1 ysnIncludeOffsiteInventoryInCompanyTitled from tblRKCompanyPreference)=1 then OffSite else 0 end +  
   Case when (select top 1 ysnIncludeDPPurchasesInCompanyTitled from tblRKCompanyPreference)=1 then DP else 0 end +   
   dblCollatralSales  + SlsBasisDeliveries         
            AS CashExposure,              
   ReceiptProductQty,OpenPurchasesQty,OpenSalesQty,OpenPurQty   
FROM(  
SELECT DISTINCT c.intCommodityId,              
  strCommodityCode,              
  u.intUnitMeasureId,              
  u.strUnitMeasure              
     ,(SELECT               
   isnull(Sum(CD.dblBalance),0) as Qty                   
   FROM tblCTContractDetail  CD                   
   JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId  = CD.intCompanyLocationId and CD.intContractStatusId <> 3               
   JOIN tblCTContractHeader  CH ON CH.intContractHeaderId  = CD.intContractHeaderId    and CH.intContractTypeId=1              
   JOIN tblCTPricingType  PT ON PT.intPricingTypeId     = CD.intPricingTypeId and PT.intPricingTypeId in(1,3)               
   JOIN tblCTContractType  TP ON TP.intContractTypeId     = CH.intContractTypeId where CH.intCommodityId=c.intCommodityId) as OpenPurQty       
   ,(SELECT isnull(sum(Balance),0) dblTotal  
 FROM vyuGRGetStorageDetail CH  
 WHERE ysnCustomerStorage = 1 AND strOwnedPhysicalStock = 'Company'  
 AND CH.intCommodityId=c.intCommodityId) as OffSite  
 ,(SELECT   
  isnull(SUM(Balance),0) DP  
  FROM vyuGRGetStorageDetail ch  
  WHERE ch.intCommodityId = c.intCommodityId AND ysnDPOwnedType=1 ) as DP  
           
   ,(SELECT               
   isnull(Sum(CD.dblBalance),0) as Qty                   
   FROM tblCTContractDetail  CD                   
   JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId  = CD.intCompanyLocationId   and CD.intContractStatusId <> 3                     
   JOIN tblCTContractHeader  CH ON CH.intContractHeaderId  = CD.intContractHeaderId    and CH.intContractTypeId=2              
   JOIN tblCTPricingType  PT ON PT.intPricingTypeId     = CD.intPricingTypeId and PT.intPricingTypeId  in(1,3)               
   JOIN tblCTContractType  TP ON TP.intContractTypeId     = CH.intContractTypeId where CH.intCommodityId=c.intCommodityId) as OpenSalQty       
            
    ,(SELECT               
   isnull(Sum(CD.dblBalance),0) as Qty                   
   FROM tblCTContractDetail  CD                   
   JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId  = CD.intCompanyLocationId   and CD.intContractStatusId <> 3                     
   JOIN tblCTContractHeader  CH ON CH.intContractHeaderId  = CD.intContractHeaderId   and CH.intContractTypeId=1              
   JOIN tblCTPricingType  PT ON PT.intPricingTypeId     = CD.intPricingTypeId and PT.intPricingTypeId in(1,2)               
   JOIN tblCTContractType  TP ON TP.intContractTypeId     = CH.intContractTypeId where CH.intCommodityId=c.intCommodityId) as ReceiptProductQty      
             
    ,(SELECT               
   isnull(Sum(CD.dblBalance),0) as Qty                   
   FROM tblCTContractDetail  CD                   
   JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId  = CD.intCompanyLocationId   and CD.intContractStatusId <> 3                     
   JOIN tblCTContractHeader  CH ON CH.intContractHeaderId  = CD.intContractHeaderId  and CH.intContractTypeId=1                 
   JOIN tblCTPricingType  PT ON PT.intPricingTypeId     = CD.intPricingTypeId and PT.intPricingTypeId in(1,2)               
   JOIN tblCTContractType  TP ON TP.intContractTypeId     = CH.intContractTypeId where CH.intCommodityId=c.intCommodityId) as OpenPurchasesQty  --req   
              
    ,(SELECT               
   isnull(Sum(CD.dblBalance),0) as Qty                   
   FROM tblCTContractDetail  CD                   
   JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId  = CD.intCompanyLocationId    and CD.intContractStatusId <> 3                    
   JOIN tblCTContractHeader  CH ON CH.intContractHeaderId  = CD.intContractHeaderId   and  CH.intContractTypeId= 2               
   JOIN tblCTPricingType  PT ON PT.intPricingTypeId     = CD.intPricingTypeId and PT.intPricingTypeId in(1,2)               
   JOIN tblCTContractType  TP ON TP.intContractTypeId     = CH.intContractTypeId where CH.intCommodityId=c.intCommodityId) as OpenSalesQty    --req          
     ,(SELECT top 1 rfm.dblContractSize as dblContractSize from tblRKFutOptTransaction otr  
   JOIN tblRKFutureMarket rfm on rfm.intFutureMarketId=otr.intFutureMarketId  
   WHERE otr.intCommodityId=c.intCommodityId GROUP BY rfm.intFutureMarketId,rfm.dblContractSize) dblContractSize     
              
 ,(SELECT isnull(SUM(intNoOfContract),0) from tblRKFutOptTransaction otr  
     WHERE otr.strBuySell='Sell' AND otr.intCommodityId=c.intCommodityId) FutSBalTransQty     
  
 ,(SELECT isnull(SUM(intNoOfContract),0) from tblRKFutOptTransaction otr  
  WHERE otr.strBuySell='Buy' AND otr.intCommodityId=c.intCommodityId) as FutLBalTransQty,          
           
(SELECT SUM(psd.dblMatchQty) from tblRKMatchFuturesPSHeader psh            
JOIN tblRKMatchFuturesPSDetail psd on psd.intMatchFuturesPSHeaderId=psh.intMatchFuturesPSHeaderId            
WHERE intCommodityId=c.intCommodityId) FutMatchedQty   
  
,(SELECT sum(isnull(it1.dblUnitOnHand,0))        
 FROM tblICItem i1   
 JOIN tblICItemStock it1 ON it1.intItemId = i1.intItemId   and  
 i1.intCommodityId= c.intCommodityId) as invQty  
  
,(SELECT SUM(isnull(sr1.dblQty,0))        
 FROM tblICItem i1   
 JOIN tblICItemStock it1 ON it1.intItemId = i1.intItemId     
 JOIN tblICStockReservation sr1 ON it1.intItemId = sr1.intItemId     
 WHERE i1.intCommodityId=c.intCommodityId ) as ReserveQty  
   
, (SELECT isnull(SUM(dblOriginalQuantity),0) - isnull(sum(dblAdjustmentAmount),0) as dblCollatralSales  
 FROM (  
  SELECT SUM(dblAdjustmentAmount) dblAdjustmentAmount  
   ,intContractHeaderId  
   ,isnull(SUM(dblOriginalQuantity),0) dblOriginalQuantity  
  FROM tblRKCollateral c1  
  INNER JOIN tblRKCollateralAdjustment ca ON c1.intCollateralId = ca.intCollateralId  
  WHERE strType = 'Sale'  
   AND c1.intCommodityId = c.intCommodityId  
  GROUP BY intContractHeaderId  
  ) t WHERE dblAdjustmentAmount <> dblOriginalQuantity) as dblCollatralSales  
   
, (SELECT isnull(SUM(isnull(ri.dblQuantity, 0)),0) AS SlsBasisDeliveries  
 FROM tblICInventoryShipment r  
 INNER JOIN tblICInventoryShipmentItem ri ON r.intInventoryShipmentId = ri.intInventoryShipmentId  
 INNER JOIN tblCTContractDetail cd ON cd.intContractDetailId = ri.intLineNo   and cd.intContractStatusId <> 3       
  AND cd.intPricingTypeId = 2  
  AND ri.intOrderId = 1  
 INNER JOIN tblCTContractHeader ch ON ch.intContractHeaderId = cd.intContractHeaderId  
 WHERE ch.intCommodityId = c.intCommodityId) as SlsBasisDeliveries  
           
FROM tblICCommodity c              
LEFT JOIN tblICCommodityUnitMeasure um on c.intCommodityId=um.intCommodityId              
JOIN tblICUnitMeasure u on um.intUnitMeasureId=u.intUnitMeasureId and ysnDefault=1             
GROUP BY c.intCommodityId,              
  strCommodityCode,              
  u.intUnitMeasureId,              
  u.strUnitMeasure          
    
  )t  
)t1