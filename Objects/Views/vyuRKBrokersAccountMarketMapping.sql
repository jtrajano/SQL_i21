CREATE VIEW vyuRKBrokersAccountMarketMapping
AS
SELECT m.intBrokersAccountMarketMapId,fm.strFutMarketName strFutMarketName,
dbo.fnRKRKConvertProductTypeKeyToName(isnull(strCommodityAttributeId,'')) COLLATE Latin1_General_CI_AS AS strCommodityAttributeId,
dbo.fnRKRKConvertProductTypeKeyToName(isnull(strCommodityAttributeId,'')) COLLATE Latin1_General_CI_AS AS strDescription ,0 as intConcurrencyId
FROM tblRKBrokersAccountMarketMapping m
JOIN tblRKFutureMarket fm ON fm.intFutureMarketId=m.intFutureMarketId