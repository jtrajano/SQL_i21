CREATE VIEW vyuRKBrokersAccountMarketMapping
AS
SELECT m.intBrokersAccountMarketMapId,fm.strFutMarketName strFutMarketName,
dbo.fnRKRKConvertProductTypeKeyToName(isnull(strCommodityAttributeId,'')) strCommodityAttributeId,
dbo.fnRKRKConvertProductTypeKeyToName(isnull(strCommodityAttributeId,'')) AS strDescription ,0 as intConcurrencyId
FROM tblRKBrokersAccountMarketMapping m
JOIN tblRKFutureMarket fm ON fm.intFutureMarketId=m.intFutureMarketId