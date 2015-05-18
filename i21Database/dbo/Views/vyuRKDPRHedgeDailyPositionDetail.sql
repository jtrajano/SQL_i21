CREATE VIEW [dbo].[vyuRKDPRHedgeDailyPositionDetail]

AS         

SELECT  CH.intCommodityId,
		'Purchases Priced' [strType],
		isnull(Sum(CD.dblBalance),0) as dblTotal               
   FROM tblCTContractDetail  CD                 
   JOIN tblCTContractHeader  CH ON CH.intContractHeaderId  = CD.intContractHeaderId    and CH.intPurchaseSale=1            
   JOIN tblCTPricingType  PT ON PT.Value     = CD.intPricingType and PT.Value in(1)             
GROUP BY CH.intCommodityId
UNION ALL
SELECT  CH.intCommodityId,
		'Purchases Basis' [strType],
		isnull(Sum(CD.dblBalance),0) as dblTotal               
   FROM tblCTContractDetail  CD                 
   JOIN tblCTContractHeader  CH ON CH.intContractHeaderId  = CD.intContractHeaderId    and CH.intPurchaseSale=1            
   JOIN tblCTPricingType  PT ON PT.Value     = CD.intPricingType and PT.Value in(2)             
GROUP BY CH.intCommodityId

UNION ALL
SELECT  CH.intCommodityId,
		'Purchases HTA' [strType],
		isnull(Sum(CD.dblBalance),0) as dblTotal               
   FROM tblCTContractDetail  CD                 
   JOIN tblCTContractHeader  CH ON CH.intContractHeaderId  = CD.intContractHeaderId    and CH.intPurchaseSale=1            
   JOIN tblCTPricingType  PT ON PT.Value     = CD.intPricingType and PT.Value in(3)             
GROUP BY CH.intCommodityId

UNION ALL
SELECT  CH.intCommodityId,
		'Sales Priced' [strType],
		isnull(Sum(CD.dblBalance),0) as dblTotal               
   FROM tblCTContractDetail  CD                 
   JOIN tblCTContractHeader  CH ON CH.intContractHeaderId  = CD.intContractHeaderId    and CH.intPurchaseSale=2            
   JOIN tblCTPricingType  PT ON PT.Value     = CD.intPricingType and PT.Value in(1)             
GROUP BY CH.intCommodityId

UNION ALL
SELECT  CH.intCommodityId,
		'Sales Basis' [strType],
		isnull(Sum(CD.dblBalance),0) as dblTotal             
   FROM tblCTContractDetail  CD                 
   JOIN tblCTContractHeader  CH ON CH.intContractHeaderId  = CD.intContractHeaderId    and CH.intPurchaseSale=2            
   LEFT JOIN tblCTPricingType  PT ON PT.Value     = CD.intPricingType WHERE ISNULL(PT.Value,0) = 2             
GROUP BY CH.intCommodityId

UNION ALL
SELECT  CH.intCommodityId,
		'Sales HTA' [strType],
		isnull(Sum(CD.dblBalance),0) as dblTotal               
   FROM tblCTContractDetail  CD                 
   JOIN tblCTContractHeader  CH ON CH.intContractHeaderId  = CD.intContractHeaderId    and CH.intPurchaseSale=2            
   JOIN tblCTPricingType  PT ON PT.Value     = CD.intPricingType and PT.Value in(3)             
GROUP BY CH.intCommodityId

Union ALL

SELECT  intCommodityId,
		'Net Hedge' [strType],
		(((isnull(FutLBalTransQty,0)-isnull(FutMatchedQty,0))- (isnull(FutSBalTransQty,0)-isnull(FutMatchedQty,0)) )*dblContractSize) as dblTotal        
               
FROM(            
SELECT  c.intCommodityId,
     (SELECT top 1 rfm.dblContractSize as dblContractSize from tblRKFutOptTransaction otr
	  JOIN tblRKFutureMarket rfm on rfm.intFutureMarketId=otr.intFutureMarketId
	  WHERE otr.intCommodityId=c.intCommodityId GROUP BY rfm.intFutureMarketId,rfm.dblContractSize) dblContractSize   
            
	,(SELECT SUM(intNoOfContract) from tblRKFutOptTransaction otr
    	WHERE otr.strBuySell='Sell' AND otr.intCommodityId=c.intCommodityId) FutSBalTransQty   

	,(SELECT SUM(intNoOfContract) from tblRKFutOptTransaction otr
		WHERE otr.strBuySell='Buy' AND otr.intCommodityId=c.intCommodityId) as FutLBalTransQty,        
	        
	(SELECT SUM(psd.dblMatchQty) from tblRKMatchFuturesPSHeader psh          
	join tblRKMatchFuturesPSDetail psd on psd.intMatchFuturesPSHeaderId=psh.intMatchFuturesPSHeaderId          
	Where intCommodityId=c.intCommodityId) FutMatchedQty      
    
FROM tblICCommodity c            
LEFT JOIN tblICCommodityUnitMeasure um on c.intCommodityId=um.intCommodityId            
GROUP BY c.intCommodityId    
 ) t       
   
UNION ALL
          
SELECT intCommodityId,    
	  'Cash Exposure' [strType],       
    (isnull(invQty,0)-isnull(ReserveQty,0)) +           
    (isnull(OpenPurQty,0)-isnull(OpenSalQty,0))            
    +(((isnull(FutLBalTransQty,0)-isnull(FutMatchedQty,0))- (isnull(FutSBalTransQty,0)-isnull(FutMatchedQty,0)) )*dblContractSize)       
    AS dblTotal
FROM(            
SELECT c.intCommodityId,            
  sum(it.dblUnitOnHand) invQty,            
  SUM(sr.dblQty) ReserveQty      
   ,(SELECT             
   isnull(Sum(CD.dblBalance),0) as Qty                 
   FROM tblCTContractDetail  CD                 
   JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId  = CD.intCompanyLocationId              
   JOIN tblCTContractHeader  CH ON CH.intContractHeaderId  = CD.intContractHeaderId    and CH.intPurchaseSale=1            
   JOIN tblCTPricingType  PT ON PT.Value     = CD.intPricingType and PT.Value in(1,3)             
   JOIN tblCTContractType  TP ON TP.Value     = CH.intPurchaseSale where CH.intCommodityId=c.intCommodityId) as OpenPurQty            
   ,(SELECT             
   isnull(Sum(CD.dblBalance),0) as Qty                 
   FROM tblCTContractDetail  CD                 
   JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId  = CD.intCompanyLocationId              
   JOIN tblCTContractHeader  CH ON CH.intContractHeaderId  = CD.intContractHeaderId    and CH.intPurchaseSale=2            
   JOIN tblCTPricingType  PT ON PT.Value     = CD.intPricingType and PT.Value  in(1,3)             
   JOIN tblCTContractType  TP ON TP.Value     = CH.intPurchaseSale where CH.intCommodityId=c.intCommodityId) as OpenSalQty            
    ,(SELECT top 1 rfm.dblContractSize as dblContractSize from tblRKFutOptTransaction otr
	  JOIN tblRKFutureMarket rfm on rfm.intFutureMarketId=otr.intFutureMarketId
	  WHERE otr.intCommodityId=c.intCommodityId GROUP BY rfm.intFutureMarketId,rfm.dblContractSize) dblContractSize   
	,(SELECT SUM(intNoOfContract) from tblRKFutOptTransaction otr
    	WHERE otr.strBuySell='Sell' AND otr.intCommodityId=c.intCommodityId) FutSBalTransQty   

	,(SELECT SUM(intNoOfContract) from tblRKFutOptTransaction otr
		WHERE otr.strBuySell='Buy' AND otr.intCommodityId=c.intCommodityId) as FutLBalTransQty,        
	        
	(SELECT SUM(psd.dblMatchQty) from tblRKMatchFuturesPSHeader psh          
	join tblRKMatchFuturesPSDetail psd on psd.intMatchFuturesPSHeaderId=psh.intMatchFuturesPSHeaderId          
	Where intCommodityId=c.intCommodityId) FutMatchedQty          
FROM tblICCommodity c            
LEFT JOIN tblICItem i on i.intCommodityId= c.intCommodityId            
LEFT JOIN tblICItemStock it on it.intItemId=i.intItemId             
LEFT JOIN tblICStockReservation sr on it.intItemId=sr.intItemId            
GROUP BY c.intCommodityId     
 ) t         
   
UNION ALL
          
SELECT  intCommodityId,
		'Basis Exposure' [strType],          
		(isnull(CompanyTitled,0)+ (isnull(OpenPurchasesQty,0)-isnull(OpenSalesQty,0))) as dblTotal            
    
 FROM(            
SELECT intCommodityId,(invQty)-isnull(ReserveQty,0) AS CompanyTitled,OpenPurchasesQty,OpenSalesQty           
               
FROM(            
SELECT c.intCommodityId,            
  sum(it.dblUnitOnHand) invQty,            
  SUM(sr.dblQty) ReserveQty      
       
    ,(SELECT               
   isnull(Sum(CD.dblBalance),0) as Qty                   
   FROM tblCTContractDetail  CD                   
   JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId  = CD.intCompanyLocationId                
   JOIN tblCTContractHeader  CH ON CH.intContractHeaderId  = CD.intContractHeaderId  and CH.intPurchaseSale=1                 
   JOIN tblCTPricingType  PT ON PT.Value     = CD.intPricingType and PT.Value in(1,2)               
   JOIN tblCTContractType  TP ON TP.Value     = CH.intPurchaseSale where CH.intCommodityId=c.intCommodityId) as OpenPurchasesQty              
    ,(SELECT               
   isnull(Sum(CD.dblBalance),0) as Qty                   
   FROM tblCTContractDetail  CD                   
   JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId  = CD.intCompanyLocationId                
   JOIN tblCTContractHeader  CH ON CH.intContractHeaderId  = CD.intContractHeaderId  and CH.intPurchaseSale=2                 
   JOIN tblCTPricingType  PT ON PT.Value     = CD.intPricingType and PT.Value in(1,2)               
   JOIN tblCTContractType  TP ON TP.Value     = CH.intPurchaseSale where CH.intCommodityId=c.intCommodityId) as OpenSalesQty             
FROM tblICCommodity c            
LEFT JOIN tblICCommodityUnitMeasure um on c.intCommodityId=um.intCommodityId            
LEFT JOIN tblICUnitMeasure u on um.intUnitMeasureId=u.intUnitMeasureId            
LEFT JOIN tblICItem i on i.intCommodityId= c.intCommodityId            
LEFT JOIN tblICItemStock it on it.intItemId=i.intItemId             
LEFT JOIN tblICItemLocation lo on lo.intItemLocationId=it.intItemLocationId            
LEFT JOIN tblSMCompanyLocation cl1 on cl1.intCompanyLocationId=lo.intLocationId            
LEFT JOIN tblICStockReservation sr on it.intItemId=sr.intItemId            
GROUP BY c.intCommodityId       
 ) t)t1            
 
 UNION ALL
 SELECT  intCommodityId,    
		 'Net Payable' [strType],             
		 0.00  as dblTotal 
		 from tblICCommodity GROUP BY intCommodityId  
 UNION ALL
 SELECT   intCommodityId,    
		'Un-Paid Quantity' [strType],             
		 0.00  as dblTotal  
		from tblICCommodity GROUP BY intCommodityId  
 UNION ALL
 
          
SELECT    intCommodityId,    
		  'Avail for Spot Sale' [strType],             
		(isnull(CompanyTitled,0)+ (isnull(OpenPurchasesQty,0)-isnull(OpenSalesQty,0))) - isnull(ReceiptProductQty,0)  as dblTotal 
FROM(            
SELECT intCommodityId,(invQty)-isnull(ReserveQty,0) AS CompanyTitled,            
     ReceiptProductQty,OpenPurchasesQty,OpenSalesQty            
               
FROM(            
SELECT c.intCommodityId,            
   
  sum(it.dblUnitOnHand) invQty,            
  SUM(sr.dblQty) ReserveQty      
         
    ,(SELECT             
   isnull(Sum(CD.dblBalance),0) as Qty                 
   FROM tblCTContractDetail  CD                 
   JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId  = CD.intCompanyLocationId              
   JOIN tblCTContractHeader  CH ON CH.intContractHeaderId  = CD.intContractHeaderId   and CH.intPurchaseSale=1            
   JOIN tblCTPricingType  PT ON PT.Value     = CD.intPricingType and PT.Value in(1,2)             
   JOIN tblCTContractType  TP ON TP.Value     = CH.intPurchaseSale where CH.intCommodityId=c.intCommodityId) as ReceiptProductQty            
    ,(SELECT             
   isnull(Sum(CD.dblBalance),0) as Qty                 
   FROM tblCTContractDetail  CD                 
   JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId  = CD.intCompanyLocationId              
   JOIN tblCTContractHeader  CH ON CH.intContractHeaderId  = CD.intContractHeaderId  and CH.intPurchaseSale=2               
   JOIN tblCTPricingType  PT ON PT.Value     = CD.intPricingType and PT.Value in(1,2)             
   JOIN tblCTContractType  TP ON TP.Value     = CH.intPurchaseSale where CH.intCommodityId=c.intCommodityId) as OpenPurchasesQty            
    ,(SELECT             
   isnull(Sum(CD.dblBalance),0) as Qty                 
   FROM tblCTContractDetail  CD                 
   JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId  = CD.intCompanyLocationId              
   JOIN tblCTContractHeader  CH ON CH.intContractHeaderId  = CD.intContractHeaderId                
   JOIN tblCTPricingType  PT ON PT.Value     = CD.intPricingType and PT.Value in(1,2)             
   JOIN tblCTContractType  TP ON TP.Value     = CH.intPurchaseSale where CH.intCommodityId=c.intCommodityId) as OpenSalesQty            
    
FROM tblICCommodity c            
LEFT JOIN tblICCommodityUnitMeasure um on c.intCommodityId=um.intCommodityId            
LEFT JOIN tblICUnitMeasure u on um.intUnitMeasureId=u.intUnitMeasureId            
LEFT JOIN tblICItem i on i.intCommodityId= c.intCommodityId            
LEFT JOIN tblICItemStock it on it.intItemId=i.intItemId             
LEFT JOIN tblICItemLocation lo on lo.intItemLocationId=it.intItemLocationId            
LEFT JOIN tblSMCompanyLocation cl1 on cl1.intCompanyLocationId=lo.intLocationId            
LEFT JOIN tblICStockReservation sr on it.intItemId=sr.intItemId            
GROUP BY c.intCommodityId        
 ) t)t1            
                                     