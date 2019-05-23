CREATE VIEW vyuRKBrokerList
AS
SELECT DISTINCT ft.intFutureMarketId,ft.intCommodityId,b.intEntityId,e.strName,isnull(ysnOTCOthers,0) ysnOTCOthers,
isnull(ft.intInstrumentTypeId,0) intInstrumentTypeId,m.strFutMarketName
FROM tblRKFutOptTransaction ft
JOIN tblRKBrokerageAccount b ON ft.intBrokerageAccountId=b.intBrokerageAccountId
Join tblRKFutureMarket m on ft.intFutureMarketId=m.intFutureMarketId
JOIN tblEMEntity e ON ft.intEntityId=e.intEntityId