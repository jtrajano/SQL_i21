CREATE PROC [dbo].[uspRKDPRHedgeDailyPositionDetail]      
   @intCommodityId int,  
   @intLocationId int= null  
 AS  
  
IF ISNULL(@intLocationId,0) <> 0  
BEGIN   
       
SELECT  'Purchases Priced' [strType],  
  isnull(Sum(CD.dblBalance),0) as dblTotal                 
   FROM tblCTContractDetail  CD                   
   JOIN tblCTContractHeader  CH ON CH.intContractHeaderId  = CD.intContractHeaderId    and CH.intContractTypeId=1              
   JOIN tblCTPricingType  PT ON PT.intPricingTypeId     = CD.intPricingTypeId and PT.intPricingTypeId in(1)     
 Where CH.intCommodityId=@intCommodityId and CD.intCompanyLocationId=@intLocationId      
     
UNION ALL  
SELECT  'Purchases Basis' [strType],  
  isnull(Sum(CD.dblBalance),0) as dblTotal                 
   FROM tblCTContractDetail  CD                   
   JOIN tblCTContractHeader  CH ON CH.intContractHeaderId  = CD.intContractHeaderId    and CH.intContractTypeId=1              
   JOIN tblCTPricingType  PT ON PT.intPricingTypeId     = CD.intPricingTypeId and PT.intPricingTypeId in(2)               
 Where CH.intCommodityId=@intCommodityId and CD.intCompanyLocationId=@intLocationId    
  
UNION ALL  
SELECT  'Purchases HTA' [strType],  
  isnull(Sum(CD.dblBalance),0) as dblTotal                 
   FROM tblCTContractDetail  CD                   
   JOIN tblCTContractHeader  CH ON CH.intContractHeaderId  = CD.intContractHeaderId    and CH.intContractTypeId=1              
   JOIN tblCTPricingType  PT ON PT.intPricingTypeId     = CD.intPricingTypeId and PT.intPricingTypeId in(3)               
 WHERE CH.intCommodityId=@intCommodityId and CD.intCompanyLocationId=@intLocationId    
  
UNION ALL  
SELECT  'Sales Priced' [strType],  
  isnull(Sum(CD.dblBalance),0) as dblTotal                 
   FROM tblCTContractDetail  CD                   
   JOIN tblCTContractHeader  CH ON CH.intContractHeaderId  = CD.intContractHeaderId    and CH.intContractTypeId=2              
   JOIN tblCTPricingType  PT ON PT.intPricingTypeId     = CD.intPricingTypeId and PT.intPricingTypeId in(1)               
 WHERE CH.intCommodityId=@intCommodityId and CD.intCompanyLocationId=@intLocationId   
  
UNION ALL  
SELECT    
  'Sales Basis' [strType],  
  isnull(Sum(CD.dblBalance),0) as dblTotal               
   FROM tblCTContractDetail  CD                   
   JOIN tblCTContractHeader  CH ON CH.intContractHeaderId  = CD.intContractHeaderId    and CH.intContractTypeId=2              
   LEFT JOIN tblCTPricingType  PT ON PT.intPricingTypeId     = CD.intPricingTypeId WHERE ISNULL(PT.intPricingTypeId,0) = 2               
 and CH.intCommodityId=@intCommodityId and CD.intCompanyLocationId=@intLocationId   
  
UNION ALL  
SELECT    
  'Sales HTA' [strType],  
  isnull(Sum(CD.dblBalance),0) as dblTotal                 
   FROM tblCTContractDetail  CD                   
   JOIN tblCTContractHeader  CH ON CH.intContractHeaderId  = CD.intContractHeaderId    and CH.intContractTypeId=2              
   JOIN tblCTPricingType  PT ON PT.intPricingTypeId     = CD.intPricingTypeId and PT.intPricingTypeId in(3)               
 and CH.intCommodityId=@intCommodityId and CD.intCompanyLocationId=@intLocationId   
  
Union ALL  
  
SELECT   
  'Net Hedge' [strType],  
  (((isnull(FutLBalTransQty,0)-isnull(FutMatchedQty,0))- (isnull(FutSBalTransQty,0)-isnull(FutMatchedQty,0)) )*dblContractSize) as dblTotal          
                 
FROM(              
SELECT   
     (SELECT top 1 rfm.dblContractSize as dblContractSize from tblRKFutOptTransaction otr  
   JOIN tblRKFutureMarket rfm on rfm.intFutureMarketId=otr.intFutureMarketId  
    WHERE otr.intCommodityId=@intCommodityId and otr.intLocationId=@intLocationId   
   GROUP BY rfm.intFutureMarketId,rfm.dblContractSize) dblContractSize     
              
 ,(SELECT SUM(intNoOfContract) from tblRKFutOptTransaction otr  
     WHERE otr.strBuySell='Sell' AND  otr.intCommodityId=@intCommodityId and otr.intLocationId=@intLocationId ) FutSBalTransQty     
  
 ,(SELECT SUM(intNoOfContract) from tblRKFutOptTransaction otr  
  WHERE otr.strBuySell='Buy' AND otr.intCommodityId=@intCommodityId and otr.intLocationId=@intLocationId ) as FutLBalTransQty,          
           
 (SELECT SUM(psd.dblMatchQty) from tblRKMatchFuturesPSHeader psh            
 join tblRKMatchFuturesPSDetail psd on psd.intMatchFuturesPSHeaderId=psh.intMatchFuturesPSHeaderId            
 Where psh.intCommodityId=@intCommodityId and psh.intCompanyLocationId=@intLocationId  ) FutMatchedQty        
      
FROM tblICCommodity c                    
WHERE c.intCommodityId=@intCommodityId   
 ) t         
     
UNION ALL  
            
SELECT       
   'Cash Exposure' [strType],         
    (isnull(invQty,0)-isnull(ReserveQty,0)) +             
    (isnull(OpenPurQty,0)-isnull(OpenSalQty,0))              
    +(((isnull(FutLBalTransQty,0)-isnull(FutMatchedQty,0))- (isnull(FutSBalTransQty,0)-isnull(FutMatchedQty,0)) )*dblContractSize)         
    AS dblTotal  
FROM(              
SELECT              
  (SELECT sum(isnull(it1.dblUnitOnHand,0))        
  FROM tblICItem i1   
  JOIN tblICItemStock it1 ON it1.intItemId = i1.intItemId   
  JOIN tblICItemLocation ic on ic.intItemLocationId=it1.intItemLocationId     
  where i1.intCommodityId=@intCommodityId and ic.intLocationId=@intLocationId) as invQty  
  ,(SELECT SUM(isnull(sr1.dblQty,0))        
  FROM tblICItem i1   
  JOIN tblICItemStock it1 ON it1.intItemId = i1.intItemId   
  JOIN tblICItemLocation ic on ic.intItemLocationId=it1.intItemLocationId     
  JOIN tblICStockReservation sr1 ON it1.intItemId = sr1.intItemId     
  WHERE i1.intCommodityId=@intCommodityId and ic.intLocationId=@intLocationId ) as ReserveQty        
   ,(SELECT               
   isnull(Sum(CD.dblBalance),0) as Qty                   
   FROM tblCTContractDetail  CD                   
   JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId  = CD.intCompanyLocationId                
   JOIN tblCTContractHeader  CH ON CH.intContractHeaderId  = CD.intContractHeaderId    and CH.intContractTypeId=1              
   JOIN tblCTPricingType  PT ON PT.intPricingTypeId     = CD.intPricingTypeId and PT.intPricingTypeId in(1,3)               
   JOIN tblCTContractType  TP ON TP.intContractTypeId     = CH.intContractTypeId   
   WHERE CH.intCommodityId=@intCommodityId and CD.intCompanyLocationId=@intLocationId ) as OpenPurQty              
   ,(SELECT               
   isnull(Sum(CD.dblBalance),0) as Qty                   
   FROM tblCTContractDetail  CD                   
   JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId  = CD.intCompanyLocationId                
   JOIN tblCTContractHeader  CH ON CH.intContractHeaderId  = CD.intContractHeaderId    and CH.intContractTypeId=2              
   JOIN tblCTPricingType  PT ON PT.intPricingTypeId     = CD.intPricingTypeId and PT.intPricingTypeId  in(1,3)               
   JOIN tblCTContractType  TP ON TP.intContractTypeId     = CH.intContractTypeId   
   WHERE CH.intCommodityId=@intCommodityId and CD.intCompanyLocationId=@intLocationId) as OpenSalQty              
      
    ,(SELECT top 1 rfm.dblContractSize as dblContractSize from tblRKFutOptTransaction otr  
   JOIN tblRKFutureMarket rfm on rfm.intFutureMarketId=otr.intFutureMarketId  
   WHERE otr.intCommodityId=@intCommodityId and otr.intLocationId=@intLocationId GROUP BY rfm.intFutureMarketId,rfm.dblContractSize) dblContractSize     
 ,(SELECT SUM(intNoOfContract) from tblRKFutOptTransaction otr  
     WHERE otr.strBuySell='Sell' AND otr.intCommodityId=@intCommodityId and otr.intLocationId=@intLocationId) FutSBalTransQty     
  
 ,(SELECT SUM(intNoOfContract) from tblRKFutOptTransaction otr  
  WHERE otr.strBuySell='Buy' AND otr.intCommodityId=@intCommodityId and otr.intLocationId=@intLocationId) as FutLBalTransQty,          
           
 (SELECT SUM(psd.dblMatchQty) from tblRKMatchFuturesPSHeader psh            
 join tblRKMatchFuturesPSDetail psd on psd.intMatchFuturesPSHeaderId=psh.intMatchFuturesPSHeaderId            
 Where psh.intCommodityId=@intCommodityId and psh.intCompanyLocationId=@intLocationId) FutMatchedQty            
FROM tblICCommodity c             
where c.intCommodityId=@intCommodityId   
 ) t           
     
UNION ALL  
            
SELECT  'Basis Exposure' [strType],            
  (isnull(CompanyTitled,0)+ (isnull(OpenPurchasesQty,0)-isnull(OpenSalesQty,0))) as dblTotal              
      
 FROM(              
SELECT (invQty)-isnull(ReserveQty,0)+  
   Case when (select top 1 ysnIncludeOffsiteInventoryInCompanyTitled from tblRKCompanyPreference)=1 then OffSite else 0 end +  
   Case when (select top 1 ysnIncludeDPPurchasesInCompanyTitled from tblRKCompanyPreference)=1 then DP else 0 end +   
   dblCollatralSales  + SlsBasisDeliveries 
    AS CompanyTitled,OpenPurchasesQty,OpenSalesQty                 
FROM(              
SELECT               
    isnull((SELECT sum(isnull(it1.dblUnitOnHand,0))        
  FROM tblICItem i1   
  JOIN tblICItemStock it1 ON it1.intItemId = i1.intItemId     
  JOIN tblICItemLocation ic on ic.intItemLocationId=it1.intItemLocationId    
  WHERE i1.intCommodityId=@intCommodityId and ic.intLocationId=@intLocationId ),0) as invQty  
  ,isnull((SELECT SUM(isnull(sr1.dblQty,0))        
  FROM tblICItem i1   
  JOIN tblICItemStock it1 ON it1.intItemId = i1.intItemId     
  JOIN tblICItemLocation ic on ic.intItemLocationId=it1.intItemLocationId    
  JOIN tblICStockReservation sr1 ON it1.intItemId = sr1.intItemId     
  WHERE i1.intCommodityId=@intCommodityId and ic.intLocationId=@intLocationId ),0) as ReserveQty          
         
    ,(SELECT                 
   isnull(Sum(CD.dblBalance),0) as Qty                     
   FROM tblCTContractDetail  CD                     
   JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId  = CD.intCompanyLocationId                  
   JOIN tblCTContractHeader  CH ON CH.intContractHeaderId  = CD.intContractHeaderId  and CH.intContractTypeId=1                   
   JOIN tblCTPricingType  PT ON PT.intPricingTypeId     = CD.intPricingTypeId and PT.intPricingTypeId in(1,2)                 
   JOIN tblCTContractType  TP ON TP.intContractTypeId     = CH.intContractTypeId   
    WHERE CH.intCommodityId=@intCommodityId and CD.intCompanyLocationId=@intLocationId ) as OpenPurchasesQty                
    ,(SELECT                 
   isnull(Sum(CD.dblBalance),0) as Qty 
                       
   FROM tblCTContractDetail  CD                     
   JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId  = CD.intCompanyLocationId                  
   JOIN tblCTContractHeader  CH ON CH.intContractHeaderId  = CD.intContractHeaderId  and CH.intContractTypeId=2                   
   JOIN tblCTPricingType  PT ON PT.intPricingTypeId     = CD.intPricingTypeId and PT.intPricingTypeId in(1,2)                 
   JOIN tblCTContractType  TP ON TP.intContractTypeId     = CH.intContractTypeId   
    WHERE CH.intCommodityId=@intCommodityId and CD.intCompanyLocationId=@intLocationId ) as OpenSalesQty 
    
      ,(SELECT isnull(sum(Balance),0) dblTotal  
  FROM vyuGRGetStorageDetail CH  
  WHERE ysnCustomerStorage = 1 AND strOwnedPhysicalStock = 'Company'  
  AND CH.intCommodityId=@intCommodityId and CH.intCompanyLocationId=@intLocationId) as OffSite  
  ,(SELECT   
  isnull(SUM(Balance),0) DP  
  FROM vyuGRGetStorageDetail ch  
  WHERE ch.intCommodityId = @intCommodityId AND ysnDPOwnedType=1 and ch.intCompanyLocationId=@intLocationId) as DP  
  , (SELECT isnull(SUM(dblOriginalQuantity),0) - isnull(sum(dblAdjustmentAmount),0) as dblCollatralSales  
 FROM (  
  SELECT SUM(dblAdjustmentAmount) dblAdjustmentAmount  
   ,intContractHeaderId  
   ,isnull(SUM(dblOriginalQuantity),0) dblOriginalQuantity  
  FROM tblRKCollateral c1  
  INNER JOIN tblRKCollateralAdjustment ca ON c1.intCollateralId = ca.intCollateralId  
  WHERE strType = 'Sale'  
   AND c1.intCommodityId = @intCommodityId AND c1.intLocationId = @intLocationId  
  GROUP BY intContractHeaderId  
  ) t WHERE dblAdjustmentAmount <> dblOriginalQuantity) as dblCollatralSales  
   
  ,(SELECT isnull(SUM(isnull(ri.dblQuantity, 0)),0) AS SlsBasisDeliveries  
  FROM tblICInventoryShipment r  
  INNER JOIN tblICInventoryShipmentItem ri ON r.intInventoryShipmentId = ri.intInventoryShipmentId  
  INNER JOIN tblCTContractDetail cd ON cd.intContractDetailId = ri.intLineNo AND cd.intPricingTypeId = 2 AND ri.intOrderId = 1  
  INNER JOIN tblCTContractHeader ch ON ch.intContractHeaderId = cd.intContractHeaderId  
  WHERE ch.intCommodityId = @intCommodityId AND cd.intCompanyLocationId = @intLocationId) as SlsBasisDeliveries 
    
                  
FROM tblICCommodity c              
WHERE c.intCommodityId=@intCommodityId   
 ) t)t1              
   
 UNION ALL  
 SELECT  'Net Payable' [strType],               
   0.00  as dblTotal   
   from tblICCommodity c  WHERE c.intCommodityId=@intCommodityId   
 UNION ALL  
 SELECT 'Un-Paid Quantity' [strType],               
   0.00  as dblTotal    
  from tblICCommodity c WHERE c.intCommodityId=@intCommodityId    
 UNION ALL  
   
            
SELECT      
    'Avail for Spot Sale' [strType],               
  (isnull(CompanyTitled,0)+ (isnull(OpenPurchasesQty,0)-isnull(OpenSalesQty,0))) - isnull(ReceiptProductQty,0)  as dblTotal   
FROM(              
SELECT (invQty)-isnull(ReserveQty,0)+  
   Case when (select top 1 ysnIncludeOffsiteInventoryInCompanyTitled from tblRKCompanyPreference)=1 then OffSite else 0 end +  
   Case when (select top 1 ysnIncludeDPPurchasesInCompanyTitled from tblRKCompanyPreference)=1 then DP else 0 end +   
   dblCollatralSales  + SlsBasisDeliveries AS CompanyTitled,              
     ReceiptProductQty,OpenPurchasesQty,OpenSalesQty              
                 
FROM(              
SELECT (SELECT sum(isnull(it1.dblUnitOnHand,0))        
  FROM tblICItem i1   
  JOIN tblICItemStock it1 ON it1.intItemId = i1.intItemId     
  JOIN tblICItemLocation il on il.intItemLocationId=it1.intItemLocationId     
  WHERE i1.intCommodityId= @intCommodityId and il.intLocationId=@intLocationId) as invQty  
  ,(SELECT SUM(isnull(sr1.dblQty,0))        
  FROM tblICItem i1   
  JOIN tblICItemStock it1 ON it1.intItemId = i1.intItemId     
  JOIN tblICItemLocation il on il.intItemLocationId=it1.intItemLocationId     
  JOIN tblICStockReservation sr1 ON it1.intItemId = sr1.intItemId     
  WHERE i1.intCommodityId= @intCommodityId and il.intLocationId=@intLocationId) as ReserveQty         
           
 ,(SELECT               
   isnull(Sum(CD.dblBalance),0) as Qty                   
   FROM tblCTContractDetail  CD                   
   JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId  = CD.intCompanyLocationId                
   JOIN tblCTContractHeader  CH ON CH.intContractHeaderId  = CD.intContractHeaderId   and CH.intContractTypeId=1              
   JOIN tblCTPricingType  PT ON PT.intPricingTypeId     = CD.intPricingTypeId and PT.intPricingTypeId in(1,2)               
   JOIN tblCTContractType  TP ON TP.intContractTypeId     = CH.intContractTypeId   
    WHERE CH.intCommodityId= @intCommodityId and CD.intCompanyLocationId=@intLocationId) as ReceiptProductQty              
    ,(SELECT               
   isnull(Sum(CD.dblBalance),0) as Qty                   
   FROM tblCTContractDetail  CD                   
   JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId  = CD.intCompanyLocationId                
   JOIN tblCTContractHeader  CH ON CH.intContractHeaderId  = CD.intContractHeaderId  and CH.intContractTypeId=1                 
   JOIN tblCTPricingType  PT ON PT.intPricingTypeId     = CD.intPricingTypeId and PT.intPricingTypeId in(1,2)               
   JOIN tblCTContractType  TP ON TP.intContractTypeId     = CH.intContractTypeId   
     WHERE CH.intCommodityId= @intCommodityId and CD.intCompanyLocationId=@intLocationId) as OpenPurchasesQty  --req            
    ,(SELECT               
   isnull(Sum(CD.dblBalance),0) as Qty                   
   FROM tblCTContractDetail  CD                   
   JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId  = CD.intCompanyLocationId                
   JOIN tblCTContractHeader  CH ON CH.intContractHeaderId  = CD.intContractHeaderId   and  CH.intContractTypeId= 2               
   JOIN tblCTPricingType  PT ON PT.intPricingTypeId     = CD.intPricingTypeId and PT.intPricingTypeId in(1,2)               
   JOIN tblCTContractType  TP ON TP.intContractTypeId     = CH.intContractTypeId   
     WHERE CH.intCommodityId= @intCommodityId and CD.intCompanyLocationId=@intLocationId) as OpenSalesQty             
           ,(SELECT isnull(sum(Balance),0) dblTotal  
  FROM vyuGRGetStorageDetail CH  
  WHERE ysnCustomerStorage = 1 AND strOwnedPhysicalStock = 'Company'  
  AND CH.intCommodityId=@intCommodityId and CH.intCompanyLocationId=@intLocationId) as OffSite  
  ,(SELECT   
  isnull(SUM(Balance),0) DP  
  FROM vyuGRGetStorageDetail ch  
  WHERE ch.intCommodityId = @intCommodityId AND ysnDPOwnedType=1 and ch.intCompanyLocationId=@intLocationId) as DP  
  , (SELECT isnull(SUM(dblOriginalQuantity),0) - isnull(sum(dblAdjustmentAmount),0) as dblCollatralSales  
 FROM (  
  SELECT SUM(dblAdjustmentAmount) dblAdjustmentAmount  
   ,intContractHeaderId  
   ,isnull(SUM(dblOriginalQuantity),0) dblOriginalQuantity  
  FROM tblRKCollateral c1  
  INNER JOIN tblRKCollateralAdjustment ca ON c1.intCollateralId = ca.intCollateralId  
  WHERE strType = 'Sale'  
   AND c1.intCommodityId = @intCommodityId AND c1.intLocationId = @intLocationId  
  GROUP BY intContractHeaderId  
  ) t WHERE dblAdjustmentAmount <> dblOriginalQuantity) as dblCollatralSales  
   
  ,(SELECT isnull(SUM(isnull(ri.dblQuantity, 0)),0) AS SlsBasisDeliveries  
  FROM tblICInventoryShipment r  
  INNER JOIN tblICInventoryShipmentItem ri ON r.intInventoryShipmentId = ri.intInventoryShipmentId  
  INNER JOIN tblCTContractDetail cd ON cd.intContractDetailId = ri.intLineNo AND cd.intPricingTypeId = 2 AND ri.intOrderId = 1  
  INNER JOIN tblCTContractHeader ch ON ch.intContractHeaderId = cd.intContractHeaderId  
  WHERE ch.intCommodityId = @intCommodityId AND cd.intCompanyLocationId = @intLocationId) as SlsBasisDeliveries 
FROM tblICCommodity c              
WHERE c.intCommodityId=@intCommodityId  
 ) t)t1              
END  
ELSE  
  
  
BEGIN   
       
SELECT  'Purchases Priced' [strType],  
  isnull(Sum(CD.dblBalance),0) as dblTotal                 
   FROM tblCTContractDetail  CD                   
   JOIN tblCTContractHeader  CH ON CH.intContractHeaderId  = CD.intContractHeaderId    and CH.intContractTypeId=1              
   JOIN tblCTPricingType  PT ON PT.intPricingTypeId     = CD.intPricingTypeId and PT.intPricingTypeId in(1)     
 Where CH.intCommodityId=@intCommodityId     
     
UNION ALL  
SELECT  'Purchases Basis' [strType],  
  isnull(Sum(CD.dblBalance),0) as dblTotal                 
   FROM tblCTContractDetail  CD                   
   JOIN tblCTContractHeader  CH ON CH.intContractHeaderId  = CD.intContractHeaderId    and CH.intContractTypeId=1              
   JOIN tblCTPricingType  PT ON PT.intPricingTypeId     = CD.intPricingTypeId and PT.intPricingTypeId in(2)               
 WHERE CH.intCommodityId=@intCommodityId   
   
UNION ALL  
SELECT  'Purchases HTA' [strType],  
  isnull(Sum(CD.dblBalance),0) as dblTotal                 
   FROM tblCTContractDetail  CD                   
   JOIN tblCTContractHeader  CH ON CH.intContractHeaderId  = CD.intContractHeaderId    and CH.intContractTypeId=1              
   JOIN tblCTPricingType  PT ON PT.intPricingTypeId     = CD.intPricingTypeId and PT.intPricingTypeId in(3)               
 WHERE CH.intCommodityId=@intCommodityId  
  
UNION ALL  
SELECT  'Sales Priced' [strType],  
  isnull(Sum(CD.dblBalance),0) as dblTotal                 
   FROM tblCTContractDetail  CD                   
   JOIN tblCTContractHeader  CH ON CH.intContractHeaderId  = CD.intContractHeaderId    and CH.intContractTypeId=2              
   JOIN tblCTPricingType  PT ON PT.intPricingTypeId     = CD.intPricingTypeId and PT.intPricingTypeId in(1)               
 WHERE CH.intCommodityId=@intCommodityId   
  
UNION ALL  
SELECT    
  'Sales Basis' [strType],  
  isnull(Sum(CD.dblBalance),0) as dblTotal               
   FROM tblCTContractDetail  CD                   
   JOIN tblCTContractHeader  CH ON CH.intContractHeaderId  = CD.intContractHeaderId    and CH.intContractTypeId=2              
   LEFT JOIN tblCTPricingType  PT ON PT.intPricingTypeId     = CD.intPricingTypeId WHERE ISNULL(PT.intPricingTypeId,0) = 2               
 and CH.intCommodityId=@intCommodityId   
  
UNION ALL  
SELECT    
  'Sales HTA' [strType],  
  isnull(Sum(CD.dblBalance),0) as dblTotal                 
   FROM tblCTContractDetail  CD                   
   JOIN tblCTContractHeader  CH ON CH.intContractHeaderId  = CD.intContractHeaderId    and CH.intContractTypeId=2              
   JOIN tblCTPricingType  PT ON PT.intPricingTypeId     = CD.intPricingTypeId and PT.intPricingTypeId in(3)               
 and CH.intCommodityId=@intCommodityId   
  
Union ALL  
  
SELECT   
  'Net Hedge' [strType],  
  (((isnull(FutLBalTransQty,0)-isnull(FutMatchedQty,0))- (isnull(FutSBalTransQty,0)-isnull(FutMatchedQty,0)) )*dblContractSize) as dblTotal          
                 
FROM(              
SELECT   
     (SELECT top 1 rfm.dblContractSize as dblContractSize from tblRKFutOptTransaction otr  
   JOIN tblRKFutureMarket rfm on rfm.intFutureMarketId=otr.intFutureMarketId  
    WHERE otr.intCommodityId=@intCommodityId  
   GROUP BY rfm.intFutureMarketId,rfm.dblContractSize) dblContractSize     
              
 ,(SELECT SUM(intNoOfContract) from tblRKFutOptTransaction otr  
     WHERE otr.strBuySell='Sell' AND  otr.intCommodityId=@intCommodityId) FutSBalTransQty     
  
 ,(SELECT SUM(intNoOfContract) from tblRKFutOptTransaction otr  
  WHERE otr.strBuySell='Buy' AND otr.intCommodityId=@intCommodityId ) as FutLBalTransQty,          
           
 (SELECT SUM(psd.dblMatchQty) from tblRKMatchFuturesPSHeader psh            
 join tblRKMatchFuturesPSDetail psd on psd.intMatchFuturesPSHeaderId=psh.intMatchFuturesPSHeaderId            
 Where psh.intCommodityId=@intCommodityId) FutMatchedQty        
      
FROM tblICCommodity c                    
WHERE c.intCommodityId=@intCommodityId   
 ) t         
     
UNION ALL  
            
SELECT       
   'Cash Exposure' [strType],         
    (isnull(invQty,0)-isnull(ReserveQty,0)) +             
    (isnull(OpenPurQty,0)-isnull(OpenSalQty,0))              
    +isnull((((isnull(FutLBalTransQty,0)-isnull(FutMatchedQty,0))- (isnull(FutSBalTransQty,0)-isnull(FutMatchedQty,0)) )*dblContractSize),0)         
    AS dblTotal  
FROM(              
SELECT              
  (SELECT sum(isnull(it1.dblUnitOnHand,0))        
  FROM tblICItem i1   
  JOIN tblICItemStock it1 ON it1.intItemId = i1.intItemId   
  WHERE i1.intCommodityId=@intCommodityId) as invQty  
  ,(SELECT SUM(isnull(sr1.dblQty,0))        
  FROM tblICItem i1   
  JOIN tblICItemStock it1 ON it1.intItemId = i1.intItemId   
  JOIN tblICStockReservation sr1 ON it1.intItemId = sr1.intItemId     
  WHERE i1.intCommodityId=@intCommodityId) as ReserveQty        
   ,(SELECT               
   isnull(Sum(CD.dblBalance),0) as Qty                   
   FROM tblCTContractDetail  CD                   
   JOIN tblCTContractHeader  CH ON CH.intContractHeaderId  = CD.intContractHeaderId    and CH.intContractTypeId=1              
   JOIN tblCTPricingType  PT ON PT.intPricingTypeId     = CD.intPricingTypeId and PT.intPricingTypeId in(1,3)               
   JOIN tblCTContractType  TP ON TP.intContractTypeId     = CH.intContractTypeId   
   WHERE CH.intCommodityId=@intCommodityId ) as OpenPurQty              
   ,(SELECT               
   isnull(Sum(CD.dblBalance),0) as Qty                   
   FROM tblCTContractDetail  CD                   
   JOIN tblCTContractHeader  CH ON CH.intContractHeaderId  = CD.intContractHeaderId    and CH.intContractTypeId=2              
   JOIN tblCTPricingType  PT ON PT.intPricingTypeId     = CD.intPricingTypeId and PT.intPricingTypeId  in(1,3)               
   JOIN tblCTContractType  TP ON TP.intContractTypeId     = CH.intContractTypeId   
   WHERE CH.intCommodityId=@intCommodityId ) as OpenSalQty              
      
    ,(SELECT top 1 rfm.dblContractSize as dblContractSize from tblRKFutOptTransaction otr  
   JOIN tblRKFutureMarket rfm on rfm.intFutureMarketId=otr.intFutureMarketId  
   WHERE otr.intCommodityId=@intCommodityId  GROUP BY rfm.intFutureMarketId,rfm.dblContractSize) dblContractSize     
 ,(SELECT SUM(intNoOfContract) from tblRKFutOptTransaction otr  
     WHERE otr.strBuySell='Sell' AND otr.intCommodityId=@intCommodityId) FutSBalTransQty     
  
 ,(SELECT SUM(intNoOfContract) from tblRKFutOptTransaction otr  
  WHERE otr.strBuySell='Buy' AND otr.intCommodityId=@intCommodityId) as FutLBalTransQty,          
           
 (SELECT SUM(psd.dblMatchQty) from tblRKMatchFuturesPSHeader psh            
 join tblRKMatchFuturesPSDetail psd on psd.intMatchFuturesPSHeaderId=psh.intMatchFuturesPSHeaderId            
 Where psh.intCommodityId=@intCommodityId) FutMatchedQty            
FROM tblICCommodity c             
where c.intCommodityId=@intCommodityId   
 ) t           
     
UNION ALL  
            
SELECT  'Basis Exposure' [strType],            
  (isnull(CompanyTitled,0)+ (isnull(OpenPurchasesQty,0)-isnull(OpenSalesQty,0))) as dblTotal              
      
 FROM(              
SELECT (invQty)-isnull(ReserveQty,0)+  
   Case when (select top 1 ysnIncludeOffsiteInventoryInCompanyTitled from tblRKCompanyPreference)=1 then OffSite else 0 end +  
   Case when (select top 1 ysnIncludeDPPurchasesInCompanyTitled from tblRKCompanyPreference)=1 then DP else 0 end +   
   dblCollatralSales  + SlsBasisDeliveries 
    AS CompanyTitled,OpenPurchasesQty,OpenSalesQty                 
FROM(              
SELECT               
    isnull((SELECT sum(isnull(it1.dblUnitOnHand,0))        
  FROM tblICItem i1   
  JOIN tblICItemStock it1 ON it1.intItemId = i1.intItemId     
  JOIN tblICItemLocation ic on ic.intItemLocationId=it1.intItemLocationId    
  WHERE i1.intCommodityId=@intCommodityId),0) as invQty  
  ,isnull((SELECT SUM(isnull(sr1.dblQty,0))        
  FROM tblICItem i1   
  JOIN tblICItemStock it1 ON it1.intItemId = i1.intItemId     
  JOIN tblICItemLocation ic on ic.intItemLocationId=it1.intItemLocationId    
  JOIN tblICStockReservation sr1 ON it1.intItemId = sr1.intItemId     
  WHERE i1.intCommodityId=@intCommodityId),0) as ReserveQty          
         
    ,(SELECT                 
   isnull(Sum(CD.dblBalance),0) as Qty                     
   FROM tblCTContractDetail  CD                     
   JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId  = CD.intCompanyLocationId                  
   JOIN tblCTContractHeader  CH ON CH.intContractHeaderId  = CD.intContractHeaderId  and CH.intContractTypeId=1                   
   JOIN tblCTPricingType  PT ON PT.intPricingTypeId     = CD.intPricingTypeId and PT.intPricingTypeId in(1,2)                 
   JOIN tblCTContractType  TP ON TP.intContractTypeId     = CH.intContractTypeId   
    WHERE CH.intCommodityId=@intCommodityId) as OpenPurchasesQty                
    ,(SELECT                 
   isnull(Sum(CD.dblBalance),0) as Qty 
                       
   FROM tblCTContractDetail  CD                     
   JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId  = CD.intCompanyLocationId                  
   JOIN tblCTContractHeader  CH ON CH.intContractHeaderId  = CD.intContractHeaderId  and CH.intContractTypeId=2                   
   JOIN tblCTPricingType  PT ON PT.intPricingTypeId     = CD.intPricingTypeId and PT.intPricingTypeId in(1,2)                 
   JOIN tblCTContractType  TP ON TP.intContractTypeId     = CH.intContractTypeId   
    WHERE CH.intCommodityId=@intCommodityId ) as OpenSalesQty 
    
      ,(SELECT isnull(sum(Balance),0) dblTotal  
  FROM vyuGRGetStorageDetail CH  
  WHERE ysnCustomerStorage = 1 AND strOwnedPhysicalStock = 'Company'  
  AND CH.intCommodityId=@intCommodityId ) as OffSite  
  ,(SELECT   
  isnull(SUM(Balance),0) DP  
  FROM vyuGRGetStorageDetail ch  
  WHERE ch.intCommodityId = @intCommodityId AND ysnDPOwnedType=1 ) as DP  
  , (SELECT isnull(SUM(dblOriginalQuantity),0) - isnull(sum(dblAdjustmentAmount),0) as dblCollatralSales  
 FROM (  
  SELECT SUM(dblAdjustmentAmount) dblAdjustmentAmount  
   ,intContractHeaderId  
   ,isnull(SUM(dblOriginalQuantity),0) dblOriginalQuantity  
  FROM tblRKCollateral c1  
  INNER JOIN tblRKCollateralAdjustment ca ON c1.intCollateralId = ca.intCollateralId  
  WHERE strType = 'Sale'  
   AND c1.intCommodityId = @intCommodityId  
  GROUP BY intContractHeaderId  
  ) t WHERE dblAdjustmentAmount <> dblOriginalQuantity) as dblCollatralSales  
   
  ,(SELECT isnull(SUM(isnull(ri.dblQuantity, 0)),0) AS SlsBasisDeliveries  
  FROM tblICInventoryShipment r  
  INNER JOIN tblICInventoryShipmentItem ri ON r.intInventoryShipmentId = ri.intInventoryShipmentId  
  INNER JOIN tblCTContractDetail cd ON cd.intContractDetailId = ri.intLineNo AND cd.intPricingTypeId = 2 AND ri.intOrderId = 1  
  INNER JOIN tblCTContractHeader ch ON ch.intContractHeaderId = cd.intContractHeaderId  
  WHERE ch.intCommodityId = @intCommodityId) as SlsBasisDeliveries 
    
                  
FROM tblICCommodity c              
WHERE c.intCommodityId=@intCommodityId   
 ) t)t1                   
   
 UNION ALL  
 SELECT  'Net Payable' [strType],               
   0.00  as dblTotal   
   from tblICCommodity c  WHERE c.intCommodityId=@intCommodityId   
 UNION ALL  
 SELECT 'Un-Paid Quantity' [strType],               
   0.00  as dblTotal    
  from tblICCommodity c WHERE c.intCommodityId=@intCommodityId    
 UNION ALL  
   
            
SELECT      
    'Avail for Spot Sale' [strType],               
  (isnull(CompanyTitled,0)+ (isnull(OpenPurchasesQty,0)-isnull(OpenSalesQty,0))) - isnull(ReceiptProductQty,0)  as dblTotal   
FROM(              
SELECT (invQty)-isnull(ReserveQty,0)+  
   Case when (select top 1 ysnIncludeOffsiteInventoryInCompanyTitled from tblRKCompanyPreference)=1 then OffSite else 0 end +  
   Case when (select top 1 ysnIncludeDPPurchasesInCompanyTitled from tblRKCompanyPreference)=1 then DP else 0 end +   
   dblCollatralSales  + SlsBasisDeliveries AS CompanyTitled,              
     ReceiptProductQty,OpenPurchasesQty,OpenSalesQty              
                 
FROM(              
SELECT (SELECT sum(isnull(it1.dblUnitOnHand,0))        
  FROM tblICItem i1   
  JOIN tblICItemStock it1 ON it1.intItemId = i1.intItemId     
  JOIN tblICItemLocation il on il.intItemLocationId=it1.intItemLocationId     
  WHERE i1.intCommodityId= @intCommodityId ) as invQty  
  ,(SELECT SUM(isnull(sr1.dblQty,0))        
  FROM tblICItem i1   
  JOIN tblICItemStock it1 ON it1.intItemId = i1.intItemId     
  JOIN tblICItemLocation il on il.intItemLocationId=it1.intItemLocationId     
  JOIN tblICStockReservation sr1 ON it1.intItemId = sr1.intItemId     
  WHERE i1.intCommodityId= @intCommodityId ) as ReserveQty         
           
 ,(SELECT               
   isnull(Sum(CD.dblBalance),0) as Qty                   
   FROM tblCTContractDetail  CD                   
   JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId  = CD.intCompanyLocationId                
   JOIN tblCTContractHeader  CH ON CH.intContractHeaderId  = CD.intContractHeaderId   and CH.intContractTypeId=1              
   JOIN tblCTPricingType  PT ON PT.intPricingTypeId     = CD.intPricingTypeId and PT.intPricingTypeId in(1,2)               
   JOIN tblCTContractType  TP ON TP.intContractTypeId     = CH.intContractTypeId   
    WHERE CH.intCommodityId= @intCommodityId) as ReceiptProductQty              
    ,(SELECT               
   isnull(Sum(CD.dblBalance),0) as Qty                   
   FROM tblCTContractDetail  CD                   
   JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId  = CD.intCompanyLocationId                
   JOIN tblCTContractHeader  CH ON CH.intContractHeaderId  = CD.intContractHeaderId  and CH.intContractTypeId=1                 
   JOIN tblCTPricingType  PT ON PT.intPricingTypeId     = CD.intPricingTypeId and PT.intPricingTypeId in(1,2)               
   JOIN tblCTContractType  TP ON TP.intContractTypeId     = CH.intContractTypeId   
     WHERE CH.intCommodityId= @intCommodityId) as OpenPurchasesQty  --req            
    ,(SELECT               
   isnull(Sum(CD.dblBalance),0) as Qty                   
   FROM tblCTContractDetail  CD                   
   JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId  = CD.intCompanyLocationId                
   JOIN tblCTContractHeader  CH ON CH.intContractHeaderId  = CD.intContractHeaderId   and  CH.intContractTypeId= 2               
   JOIN tblCTPricingType  PT ON PT.intPricingTypeId     = CD.intPricingTypeId and PT.intPricingTypeId in(1,2)               
   JOIN tblCTContractType  TP ON TP.intContractTypeId     = CH.intContractTypeId   
     WHERE CH.intCommodityId= @intCommodityId) as OpenSalesQty             
           ,(SELECT isnull(sum(Balance),0) dblTotal  
  FROM vyuGRGetStorageDetail CH  
  WHERE ysnCustomerStorage = 1 AND strOwnedPhysicalStock = 'Company'  
  AND CH.intCommodityId=@intCommodityId ) as OffSite  
  ,(SELECT   
  isnull(SUM(Balance),0) DP  
  FROM vyuGRGetStorageDetail ch  
  WHERE ch.intCommodityId = @intCommodityId AND ysnDPOwnedType=1) as DP  
  , (SELECT isnull(SUM(dblOriginalQuantity),0) - isnull(sum(dblAdjustmentAmount),0) as dblCollatralSales  
 FROM (  
  SELECT SUM(dblAdjustmentAmount) dblAdjustmentAmount  
   ,intContractHeaderId  
   ,isnull(SUM(dblOriginalQuantity),0) dblOriginalQuantity  
  FROM tblRKCollateral c1  
  INNER JOIN tblRKCollateralAdjustment ca ON c1.intCollateralId = ca.intCollateralId  
  WHERE strType = 'Sale'  
   AND c1.intCommodityId = @intCommodityId 
  GROUP BY intContractHeaderId  
  ) t WHERE dblAdjustmentAmount <> dblOriginalQuantity) as dblCollatralSales  
   
  ,(SELECT isnull(SUM(isnull(ri.dblQuantity, 0)),0) AS SlsBasisDeliveries  
  FROM tblICInventoryShipment r  
  INNER JOIN tblICInventoryShipmentItem ri ON r.intInventoryShipmentId = ri.intInventoryShipmentId  
  INNER JOIN tblCTContractDetail cd ON cd.intContractDetailId = ri.intLineNo AND cd.intPricingTypeId = 2 AND ri.intOrderId = 1  
  INNER JOIN tblCTContractHeader ch ON ch.intContractHeaderId = cd.intContractHeaderId  
  WHERE ch.intCommodityId = @intCommodityId) as SlsBasisDeliveries 
FROM tblICCommodity c              
WHERE c.intCommodityId=@intCommodityId  
 ) t)t1    
END                                       
   