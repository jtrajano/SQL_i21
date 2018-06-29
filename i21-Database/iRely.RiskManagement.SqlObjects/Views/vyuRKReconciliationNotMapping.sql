CREATE VIEW vyuRKReconciliationNotMapping
AS
SELECT intReconciliationBrokerStatementHeaderId,strFutMarketName,strCommodityCode,strName,strAccountNumber,CONVERT(VARCHAR(11),dtmFilledDate,106) dtmFilledDate 
FROM tblRKReconciliationBrokerStatementHeader bs
JOIN tblRKFutureMarket fm on fm.intFutureMarketId=bs.intFutureMarketId
JOIN tblICCommodity c on bs.intCommodityId=c.intCommodityId
JOIN tblEMEntity e on e.intEntityId=bs.intEntityId
LEFT JOIN tblRKBrokerageAccount ba on ba.intBrokerageAccountId=bs.intBrokerageAccountId