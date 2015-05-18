CREATE VIEW [dbo].[vyuRKDPRDailyPositionByCommodity]
AS           
SELECT OpenPurchasesQty,OpenSalesQty,intCommodityId,strCommodityCode,strUnitMeasure,isnull(CompanyTitled,0) as dblCompanyTitled,
isnull(CashExposure,0) as dblCaseExposure,            
(isnull(CompanyTitled,0)+ (isnull(OpenPurchasesQty,0)-isnull(OpenSalesQty,0))) as dblBasisExposure ,           
(isnull(CompanyTitled,0)+ (isnull(OpenPurchasesQty,0)-isnull(OpenSalesQty,0))) - isnull(ReceiptProductQty,0) as dblAvailForSale,

isnull(CompanyTitled,0) as dblInHouse            
 FROM(            
SELECT intCommodityId,strCommodityCode,strUnitMeasure,(invQty)-isnull(ReserveQty,0) AS CompanyTitled, 
            (isnull(invQty,0)-isnull(ReserveQty,0)) +           
            (isnull(OpenPurQty,0)-isnull(OpenSalQty,0))            
            +(((isnull(FutLBalTransQty,0)-isnull(FutMatchedQty,0))- (isnull(FutSBalTransQty,0)-isnull(FutMatchedQty,0)) )*isnull(dblContractSize,1))       
            AS CashExposure,            
   ReceiptProductQty,OpenPurchasesQty,OpenSalesQty,OpenPurQty            
               
FROM(
SELECT distinct c.intCommodityId,            
  strCommodityCode,            
  u.intUnitMeasureId,            
  u.strUnitMeasure            
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
   JOIN tblCTContractHeader  CH ON CH.intContractHeaderId  = CD.intContractHeaderId  and CH.intPurchaseSale=1               
   JOIN tblCTPricingType  PT ON PT.Value     = CD.intPricingType and PT.Value in(1,2)             
   JOIN tblCTContractType  TP ON TP.Value     = CH.intPurchaseSale where CH.intCommodityId=c.intCommodityId) as OpenPurchasesQty  --req          
    ,(SELECT             
   isnull(Sum(CD.dblBalance),0) as Qty                 
   FROM tblCTContractDetail  CD                 
   JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId  = CD.intCompanyLocationId              
   JOIN tblCTContractHeader  CH ON CH.intContractHeaderId  = CD.intContractHeaderId   and  CH.intPurchaseSale= 2             
   JOIN tblCTPricingType  PT ON PT.Value     = CD.intPricingType and PT.Value in(1,2)             
   JOIN tblCTContractType  TP ON TP.Value     = CH.intPurchaseSale where CH.intCommodityId=c.intCommodityId) as OpenSalesQty    --req        
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
	WHERE 
	i1.intCommodityId=c.intCommodityId ) as ReserveQty
         
FROM tblICCommodity c            
LEFT JOIN tblICCommodityUnitMeasure um on c.intCommodityId=um.intCommodityId            
JOIN tblICUnitMeasure u on um.intUnitMeasureId=u.intUnitMeasureId and ysnDefault=1           
GROUP BY c.intCommodityId,            
  strCommodityCode,            
  u.intUnitMeasureId,            
  u.strUnitMeasure        
  
  )t
)t1