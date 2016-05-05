CREATE VIEW vyuRKGetFutOptTransactionFilter
AS
SELECT DISTINCT convert(int,row_number() OVER(ORDER BY amm.intFutureMarketId)) intRowNum, amm.intFutureMarketId,strFutMarketName,ba.intEntityId,e.strName,
ba.intBrokerageAccountId,
strAccountNumber,it.intInstrumentTypeId,it.strInstrumentType,
c.intCommodityId,c.strCommodityCode,
em.intEntityId intTraderId,em.strName strSalespersonId,intCurrencyID,strCurrency
FROM tblRKBrokerageAccount ba
JOIN tblRKBrokersAccountMarketMapping amm on amm.intBrokerageAccountId=ba.intBrokerageAccountId
JOIN vyuRKGetBrokerInstrumentType it on it.intBrokerageAccountId=ba.intBrokerageAccountId and it.intEntityId=ba.intEntityId
JOIN tblRKFutureMarket fm on amm.intFutureMarketId=fm.intFutureMarketId
JOIN tblRKCommodityMarketMapping cmm on fm.intFutureMarketId=cmm.intFutureMarketId
JOIN tblICCommodity c on c.intCommodityId=cmm.intCommodityId
JOIN tblSMCurrency cur on cur.intCurrencyID=fm.intCurrencyId
JOIN tblEMEntity e on e.intEntityId=ba.intEntityId
JOIN tblRKTradersbyBrokersAccountMapping aam on aam.intBrokerageAccountId=ba.intBrokerageAccountId
JOIN tblEMEntity em on aam.intEntitySalespersonId=em.intEntityId 