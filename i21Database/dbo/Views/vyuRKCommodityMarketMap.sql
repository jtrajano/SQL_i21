CREATE VIEW vyuRKCommodityMarketMap
AS
SELECT mm.intCommodityMarketId,mm.intCommodityId,dbo.fnRKRKConvertProductTypeKeyToName(isnull(strCommodityAttributeId,'')) COLLATE Latin1_General_CI_AS AS strCommodityAttributeId,ic.strCommodityCode,
dbo.fnRKRKConvertProductTypeKeyToName(isnull(strCommodityAttributeId,'')) COLLATE Latin1_General_CI_AS as strDescription,0 as [intConcurrencyId] from tblRKFutureMarket m 
JOIN tblRKCommodityMarketMapping mm on m.intFutureMarketId=mm.intFutureMarketId
JOIN tblICCommodity ic on ic.intCommodityId=mm.intCommodityId

