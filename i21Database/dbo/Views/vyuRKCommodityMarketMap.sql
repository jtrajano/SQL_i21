CREATE VIEW vyuRKCommodityMarketMap
AS
SELECT mm.intCommodityMarketId,mm.intCommodityId,mm.intCommodityAttributeId,ic.strCommodityCode,att.strDescription,0 as [intConcurrencyId] from tblRKFutureMarket m 
JOIN tblRKCommodityMarketMapping mm on m.intFutureMarketId=mm.intFutureMarketId
JOIN tblICCommodity ic on ic.intCommodityId=mm.intCommodityId
LEFT JOIN tblICCommodityAttribute att on att.intCommodityAttributeId=mm.intCommodityAttributeId

