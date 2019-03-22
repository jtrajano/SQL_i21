CREATE VIEW vyuRKGetFutureSettlementPriceString
AS
SELECT top 100 percent intFutureSettlementPriceId, strPricingType, dtmPriceDate,mm.intCommodityId 
FROM 
tblRKFuturesSettlementPrice s
join tblRKCommodityMarketMapping mm on mm.intFutureMarketId=s.intFutureMarketId ORDER BY convert(datetime, dtmPriceDate) DESC