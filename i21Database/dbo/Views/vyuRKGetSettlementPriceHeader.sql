CREATE VIEW vyuRKGetSettlementPriceHeader  
  
AS  
  
SELECT fsp.intFutureSettlementPriceId  
 , fsp.intFutureMarketId  
 , m.strFutMarketName  
 , fsp.intCommodityMarketId  
 , fsp.dtmPriceDate  
 , fsp.strPricingType  
 , fsp.intFutureSettlementPriceRefId  
 , fsp.intCompanyId   
 , mm.intCommodityId  
 , com.strCommodityCode  
FROM tblRKFuturesSettlementPrice fsp  
JOIN tblRKFutureMarket m ON m.intFutureMarketId = fsp.intFutureMarketId  
JOIN tblRKCommodityMarketMapping mm ON mm.intFutureMarketId = fsp.intFutureMarketId  
JOIN tblICCommodity com ON com.intCommodityId = mm.intCommodityId