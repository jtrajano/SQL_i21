CREATE VIEW vyuRKGetBrokerByMarket
AS
SELECT DISTINCT convert(int,row_number() OVER(ORDER BY amm.intFutureMarketId)) intRowNum, amm.intFutureMarketId,strFutMarketName,ba.intEntityId,e.strName,
ba.intBrokerageAccountId,
strAccountNumber,it.intInstrumentTypeId,it.strInstrumentType COLLATE Latin1_General_CI_AS strInstrumentType,cmm.intCommodityId
FROM tblRKBrokerageAccount ba
JOIN tblRKBrokersAccountMarketMapping amm on amm.intBrokerageAccountId=ba.intBrokerageAccountId
JOIN vyuRKGetBrokerInstrumentType it on it.intBrokerageAccountId=ba.intBrokerageAccountId and it.intEntityId=ba.intEntityId
JOIN tblRKFutureMarket fm on amm.intFutureMarketId=fm.intFutureMarketId
JOIN tblRKCommodityMarketMapping cmm on fm.intFutureMarketId=cmm.intFutureMarketId
JOIN tblEMEntity e on e.intEntityId=ba.intEntityId and it.intInstrumentTypeId<>0
UNION
SELECT DISTINCT convert(int,row_number() OVER(ORDER BY amm.intFutureMarketId)) intRowNum, amm.intFutureMarketId,strFutMarketName,ba.intEntityId,e.strName,
ba.intBrokerageAccountId,
strAccountNumber,1,'Futures',cmm.intCommodityId
FROM tblRKBrokerageAccount ba
JOIN tblRKBrokersAccountMarketMapping amm on amm.intBrokerageAccountId=ba.intBrokerageAccountId
JOIN vyuRKGetBrokerInstrumentType it on it.intBrokerageAccountId=ba.intBrokerageAccountId and it.intEntityId=ba.intEntityId
JOIN tblRKFutureMarket fm on amm.intFutureMarketId=fm.intFutureMarketId
JOIN tblRKCommodityMarketMapping cmm on fm.intFutureMarketId=cmm.intFutureMarketId
JOIN tblEMEntity e on e.intEntityId=ba.intEntityId and it.intInstrumentTypeId=0
UNION
SELECT DISTINCT convert(int,row_number() OVER(ORDER BY amm.intFutureMarketId)) intRowNum, amm.intFutureMarketId,strFutMarketName,ba.intEntityId,e.strName,
ba.intBrokerageAccountId,
strAccountNumber,2,'Options',cmm.intCommodityId
FROM tblRKBrokerageAccount ba
JOIN tblRKBrokersAccountMarketMapping amm on amm.intBrokerageAccountId=ba.intBrokerageAccountId
JOIN vyuRKGetBrokerInstrumentType it on it.intBrokerageAccountId=ba.intBrokerageAccountId and it.intEntityId=ba.intEntityId
JOIN tblRKFutureMarket fm on amm.intFutureMarketId=fm.intFutureMarketId
JOIN tblRKCommodityMarketMapping cmm on fm.intFutureMarketId=cmm.intFutureMarketId
JOIN tblEMEntity e on e.intEntityId=ba.intEntityId and it.intInstrumentTypeId=0