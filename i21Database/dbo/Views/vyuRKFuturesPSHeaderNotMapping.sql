CREATE VIEW [dbo].[vyuRKFuturesPSHeaderNotMapping]
AS

SELECT mh.*,
cl.strLocationName,c.strCommodityCode,m.strFutMarketName,fm.strFutureMonth,e.strName,ba.strAccountNumber,b.strBook,sb.strSubBook,
ert.strCurrencyExchangeRateType,bk.strBankName,bac.strBankAccountNo, 
CASE WHEN ISNULL(intSelectedInstrumentTypeId,1) =1  then 'Exchange Traded' else 'OTC' end as strSelectedInstrumentType,
sum(md.dblMatchQty)   dblMatchedQty,
sum(md.dblNetPL) dblNetPL,
sum(md.dblGrossPL)dblGrossPL,
sum(md.dblFutCommission) dblFutCommission
FROM tblRKMatchFuturesPSHeader mh
LEFT JOIN vyuRKMatchedPSTransaction md on md.intMatchFuturesPSHeaderId=mh.intMatchFuturesPSHeaderId
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
Group by mh.intMatchFuturesPSHeaderId,
mh.intMatchNo,
mh.dtmMatchDate,
mh.intCompanyLocationId,
mh.intCommodityId,
mh.intFutureMarketId,
mh.intFutureMonthId,
mh.intEntityId,
mh.intBrokerageAccountId,
mh.intBookId,
mh.intSubBookId,
mh.intSelectedInstrumentTypeId,
mh.strType,
mh.intCurrencyExchangeRateTypeId,mh.intConcurrencyId,
mh.intBankId,
mh.intBankAccountId,
mh.ysnPosted,
mh.intCompanyId,
cl.strLocationName,c.strCommodityCode,m.strFutMarketName,fm.strFutureMonth,e.strName,ba.strAccountNumber,b.strBook,sb.strSubBook,
ert.strCurrencyExchangeRateType,bk.strBankName,bac.strBankAccountNo, intSelectedInstrumentTypeId