CREATE VIEW vyuRKFuturesPSHeaderNotMapping
AS
SELECT mh.intMatchFuturesPSHeaderId,cl.strLocationName,c.strCommodityCode,m.strFutMarketName,fm.strFutureMonth,e.strName,ba.strAccountNumber,b.strBook,sb.strSubBook,
ert.strCurrencyExchangeRateType,bk.strBankName,bac.strBankAccountNo, 
CASE WHEN ISNULL(intSelectedInstrumentTypeId,1) =1  then 'Exchange Traded' else 'OTC' end as strSelectedInstrumentType
FROM tblRKMatchFuturesPSHeader mh
LEFT JOIN tblSMCompanyLocation cl on mh.intCompanyLocationId=cl.intCompanyLocationId
LEFT JOIN tblICCommodity c on mh.intCommodityId=c.intCommodityId
LEFT JOIN tblRKFutureMarket m on mh.intFutureMarketId=m.intFutureMarketId
LEFT JOIN tblRKFuturesMonth fm on mh.intFutureMonthId = fm.intFutureMonthId
LEFT JOIN tblEMEntity e on mh.intEntityId=e.intEntityId
LEFT JOIN tblRKBrokerageAccount ba on mh.intBrokerageAccountId=ba.intBrokerageAccountId
LEFT JOIN tblCTBook b on mh.intBookId=b.intBookId
LEFT JOIN tblCTSubBook sb on mh.intSubBookId=sb.intSubBookId
LEFT JOIN tblSMCurrencyExchangeRateType ert on mh.intCurrencyExchangeRateTypeId=ert.intCurrencyExchangeRateTypeId
LEFT JOIN tblCMBank bk on mh.intBankId=bk.intBankId
LEFT JOIN tblCMBankAccount bac on mh.intBankAccountId=bac.intBankAccountId