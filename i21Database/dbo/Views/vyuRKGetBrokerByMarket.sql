CREATE VIEW vyuRKGetBrokerByMarket

AS

SELECT DISTINCT bac.intFutureMarketId
	, strFutMarketName
	, ba.intEntityId
	, e.strName
	, ba.intBrokerageAccountId
	, strAccountNumber
	, it.intInstrumentTypeId
	, strInstrumentType = it.strInstrumentType COLLATE Latin1_General_CI_AS
	, cmm.intCommodityId
	, isnull(ysnOTCOthers,0) ysnOTCOthers
FROM tblRKBrokerageAccount ba
JOIN tblRKBrokerageCommission bac on ba.intBrokerageAccountId = bac.intBrokerageAccountId
JOIN vyuRKGetBrokerInstrumentType it on it.intBrokerageAccountId=ba.intBrokerageAccountId and it.intEntityId=ba.intEntityId
JOIN tblRKFutureMarket fm on bac.intFutureMarketId=fm.intFutureMarketId
JOIN tblRKCommodityMarketMapping cmm on fm.intFutureMarketId=cmm.intFutureMarketId
JOIN tblEMEntity e on e.intEntityId=ba.intEntityId and it.intInstrumentTypeId<>0

UNION ALL SELECT DISTINCT bac.intFutureMarketId
	, strFutMarketName
	, ba.intEntityId
	, e.strName
	, ba.intBrokerageAccountId
	, strAccountNumber
	, 1
	, 'Futures' COLLATE Latin1_General_CI_AS
	, cmm.intCommodityId
	, isnull(ysnOTCOthers,0) ysnOTCOthers
FROM tblRKBrokerageAccount ba
JOIN tblRKBrokerageCommission bac on ba.intBrokerageAccountId = bac.intBrokerageAccountId
JOIN vyuRKGetBrokerInstrumentType it on it.intBrokerageAccountId=ba.intBrokerageAccountId and it.intEntityId=ba.intEntityId
JOIN tblRKFutureMarket fm on bac.intFutureMarketId=fm.intFutureMarketId
JOIN tblRKCommodityMarketMapping cmm on fm.intFutureMarketId=cmm.intFutureMarketId
JOIN tblEMEntity e on e.intEntityId=ba.intEntityId and it.intInstrumentTypeId=0

UNION ALL SELECT DISTINCT bac.intFutureMarketId
	, strFutMarketName
	, ba.intEntityId
	, e.strName
	, ba.intBrokerageAccountId
	, strAccountNumber
	, 2
	, 'Options' COLLATE Latin1_General_CI_AS
	, cmm.intCommodityId
	, isnull(ysnOTCOthers,0) ysnOTCOthers
FROM tblRKBrokerageAccount ba
JOIN tblRKBrokerageCommission bac on ba.intBrokerageAccountId = bac.intBrokerageAccountId
JOIN vyuRKGetBrokerInstrumentType it on it.intBrokerageAccountId=ba.intBrokerageAccountId and it.intEntityId=ba.intEntityId
JOIN tblRKFutureMarket fm on bac.intFutureMarketId=fm.intFutureMarketId
JOIN tblRKCommodityMarketMapping cmm on fm.intFutureMarketId=cmm.intFutureMarketId
JOIN tblEMEntity e on e.intEntityId=ba.intEntityId and it.intInstrumentTypeId=0