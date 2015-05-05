CREATE VIEW [dbo].[vyuRKDPRDailyPositionByCommodityLocation]
      
AS    
SELECT intCommodityId,strLocationName,strCommodityCode,strUnitMeasure,isnull(CompanyTitled,0) as dblCompanyTitled,
isnull(CashExposure,0) as dblCaseExposure,        
(isnull(CompanyTitled,0)+ (isnull(OpenPurchasesQty,0)-isnull(OpenSalesQty,0))) as dblBasisExposure ,           
(isnull(CompanyTitled,0)+ (isnull(OpenPurchasesQty,0)-isnull(OpenSalesQty,0))) - isnull(ReceiptProductQty,0) as dblAvailForSale,
 isnull(CompanyTitled,0) as dblInHouse        
 FROM(        
SELECT intCommodityId,strLocationName,strCommodityCode,strUnitMeasure,(invQty)-isnull(ReserveQty,0) AS CompanyTitled,        
            (isnull(invQty,0)-isnull(ReserveQty,0)) +       
            (isnull(OpenPurQty,0)-isnull(OpenSalQty,0))        
              +(((isnull(FutLBalTransQty,0)-isnull(FutMatchedQty,0))- (isnull(FutSBalTransQty,0)-isnull(FutMatchedQty,0)) )*dblContractSize) 
            AS CashExposure,        
   ReceiptProductQty,OpenPurchasesQty,OpenSalesQty,OpenPurQty        
           
FROM(        
SELECT c.intCommodityId    
 ,strCommodityCode    
 ,u.intUnitMeasureId    
 ,u.strUnitMeasure    
 ,sum(isnull(it.dblUnitOnHand,0)) invQty    
 ,SUM(isnull(sr.dblQty,0)) ReserveQty    
 ,cl1.intCompanyLocationId    
 ,cl1.strLocationName    
 ,(    
  SELECT isnull(Sum(CD.dblBalance), 0) AS Qty    
  FROM tblCTContractDetail CD    
  INNER JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = CD.intCompanyLocationId    
  INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId AND CH.intPurchaseSale = 1    
  INNER JOIN tblCTPricingType PT ON PT.Value = CD.intPricingType AND PT.Value IN (1,3)    
  INNER JOIN tblCTContractType TP ON TP.Value = CH.intPurchaseSale    
  WHERE CH.intCommodityId = c.intCommodityId AND CD.intCompanyLocationId=cl1.intCompanyLocationId    
  ) AS OpenPurQty    
 ,(    
  SELECT isnull(Sum(CD.dblBalance), 0) AS Qty    
  FROM tblCTContractDetail CD    
  INNER JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = CD.intCompanyLocationId    
  INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId AND CH.intPurchaseSale = 2    
  INNER JOIN tblCTPricingType PT ON PT.Value = CD.intPricingType AND PT.Value IN (1,3)    
  INNER JOIN tblCTContractType TP ON TP.Value = CH.intPurchaseSale    
  WHERE CH.intCommodityId = c.intCommodityId AND CD.intCompanyLocationId=cl1.intCompanyLocationId    
  ) AS OpenSalQty    
 ,(    
  SELECT isnull(Sum(CD.dblBalance), 0) AS Qty    
  FROM tblCTContractDetail CD    
  INNER JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = CD.intCompanyLocationId    
  INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId AND CH.intPurchaseSale = 1    
  INNER JOIN tblCTPricingType PT ON PT.Value = CD.intPricingType AND PT.Value IN (1,2)    
  INNER JOIN tblCTContractType TP ON TP.Value = CH.intPurchaseSale    
  WHERE CH.intCommodityId = c.intCommodityId AND CD.intCompanyLocationId=cl1.intCompanyLocationId    
  ) AS ReceiptProductQty    
 ,(    
  SELECT isnull(Sum(CD.dblBalance), 0) AS Qty    
  FROM tblCTContractDetail CD    
  INNER JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = CD.intCompanyLocationId    
  INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId   AND CH.intPurchaseSale = 2    
  INNER JOIN tblCTPricingType PT ON PT.Value = CD.intPricingType AND PT.Value IN (1,2)    
  INNER JOIN tblCTContractType TP ON TP.Value = CH.intPurchaseSale    
  WHERE CH.intCommodityId = c.intCommodityId AND CD.intCompanyLocationId=cl1.intCompanyLocationId    
  ) AS OpenPurchasesQty    
 ,(    
  SELECT isnull(Sum(CD.dblBalance), 0) AS Qty    
  FROM tblCTContractDetail CD    
  INNER JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = CD.intCompanyLocationId    
  INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId    
  INNER JOIN tblCTPricingType PT ON PT.Value = CD.intPricingType AND PT.Value IN (1,2)    
  INNER JOIN tblCTContractType TP ON TP.Value = CH.intPurchaseSale    
  WHERE CH.intCommodityId = c.intCommodityId and CD.intCompanyLocationId=cl1.intCompanyLocationId    
  ) AS OpenSalesQty 
   ,(  
  SELECT top 1 rfm.dblContractSize  
  FROM tblRKFutOptTransaction otr  
   JOIN tblRKFutureMarket rfm on rfm.intFutureMarketId=otr.intFutureMarketId
  WHERE otr.intCommodityId = c.intCommodityId AND otr.intLocationId=cl1.intCompanyLocationId GROUP BY rfm.intFutureMarketId,rfm.dblContractSize 
  ) AS dblContractSize    
 ,(    
  SELECT sum(intNoOfContract)    
  FROM tblRKFutOptTransaction otr    
  WHERE otr.strBuySell = 'Sell'    
   AND otr.intCommodityId = c.intCommodityId AND otr.intLocationId=cl1.intCompanyLocationId    
  ) AS FutSBalTransQty    
 ,(    
  SELECT sum(intNoOfContract)    
  FROM tblRKFutOptTransaction otr    
  WHERE otr.strBuySell = 'Buy'    
   AND otr.intCommodityId = c.intCommodityId AND otr.intLocationId=cl1.intCompanyLocationId    
  ) AS FutLBalTransQty    
 ,(    
  SELECT SUM(psd.dblMatchQty)    
  FROM tblRKMatchFuturesPSHeader psh    
  INNER JOIN tblRKMatchFuturesPSDetail psd ON psd.intMatchFuturesPSHeaderId = psh.intMatchFuturesPSHeaderId    
  WHERE intCommodityId = c.intCommodityId and psh.intCompanyLocationId=cl1.intCompanyLocationId    
  ) FutMatchedQty    
FROM tblICCommodity c    
LEFT JOIN tblICCommodityUnitMeasure um ON c.intCommodityId = um.intCommodityId    
LEFT JOIN tblICUnitMeasure u ON um.intUnitMeasureId = u.intUnitMeasureId    
LEFT JOIN tblICItem i ON i.intCommodityId = c.intCommodityId    
LEFT JOIN tblICItemStock it ON it.intItemId = i.intItemId    
LEFT JOIN tblICItemLocation lo ON lo.intItemLocationId = it.intItemLocationId    
LEFT JOIN tblSMCompanyLocation cl1 ON cl1.intCompanyLocationId = lo.intLocationId    
LEFT JOIN tblICStockReservation sr ON it.intItemId = sr.intItemId    
GROUP BY c.intCommodityId    
 ,strCommodityCode    
 ,u.intUnitMeasureId    
 ,u.strUnitMeasure    
 ,cl1.strLocationName    
 ,cl1.intCompanyLocationId) t)t1 