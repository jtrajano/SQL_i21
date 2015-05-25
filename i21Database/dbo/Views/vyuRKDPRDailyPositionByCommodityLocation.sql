CREATE VIEW [dbo].[vyuRKDPRDailyPositionByCommodityLocation]
      
AS    
SELECT strLocationName,OpenPurchasesQty,OpenSalesQty,intCommodityId,strCommodityCode,strUnitMeasure,isnull(CompanyTitled,0) as dblCompanyTitled,
isnull(CashExposure,0) as dblCaseExposure,            
(isnull(CompanyTitled,0)+ (isnull(OpenPurchasesQty,0)-isnull(OpenSalesQty,0))) as dblBasisExposure ,           
(isnull(CompanyTitled,0)+ (isnull(OpenPurchasesQty,0)-isnull(OpenSalesQty,0))) - isnull(ReceiptProductQty,0) as dblAvailForSale,

isnull(CompanyTitled,0) as dblInHouse            
 FROM(            
SELECT strLocationName,intCommodityId,strCommodityCode,strUnitMeasure,(invQty)-isnull(ReserveQty,0) AS CompanyTitled, 
            (isnull(invQty,0)-isnull(ReserveQty,0)) +           
            (isnull(OpenPurQty,0)-isnull(OpenSalQty,0))            
            +(((isnull(FutLBalTransQty,0)-isnull(FutMatchedQty,0))- (isnull(FutSBalTransQty,0)-isnull(FutMatchedQty,0)) )*isnull(dblContractSize,1))       
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
,(	select sum(isnull(s.dblUnitOnHand,0)) from tblICItemStock s
	join tblICItemLocation it on it.intItemLocationId=s.intItemLocationId
	join tblICItem i on i.intItemId=it.intItemId
	and i.intCommodityId= c.intCommodityId where it.intLocationId=cl.intCompanyLocationId ) as invQty
,(SELECT SUM(isnull(sr1.dblQty,0))  	   
	FROM tblICItem i1 
	JOIN tblICItemLocation lo ON lo.intItemId = i1.intItemId and   lo.intLocationId = cl.intCompanyLocationId  
	JOIN tblICItemStock it1 ON it1.intItemId = i1.intItemId   
	JOIN tblICStockReservation sr1 ON it1.intItemId = sr1.intItemId   
	WHERE 
	i1.intCommodityId=c.intCommodityId ) as ReserveQty
         
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