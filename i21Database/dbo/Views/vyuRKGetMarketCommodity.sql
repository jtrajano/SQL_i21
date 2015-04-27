CREATE VIEW [dbo].[vyuRKGetMarketCommodity]
AS  
SELECT intCommodityMarketId,f.intFutureMarketId,mm.intCommodityId,strCommodityCode from tblRKFutureMarket f
JOIN tblRKCommodityMarketMapping mm on f.intFutureMarketId=mm.intFutureMarketId
JOIN tblICCommodity ic on ic.intCommodityId=mm.intCommodityId
