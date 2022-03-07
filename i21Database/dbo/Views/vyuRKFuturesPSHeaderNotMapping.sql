CREATE VIEW [dbo].[vyuRKFuturesPSHeaderNotMapping]

AS

SELECT mh.*
	, cl.strLocationName
	, c.strCommodityCode
	, m.strFutMarketName
	, fm.strFutureMonth
	, e.strName
	, ba.strAccountNumber
	, b.strBook
	, sb.strSubBook
	, ert.strCurrencyExchangeRateType
	, bk.strBankName
	, bac.strBankAccountNo
	, strSelectedInstrumentType = CASE WHEN ISNULL(intSelectedInstrumentTypeId, 1) = 1 THEN 'Exchange Traded'
										WHEN intSelectedInstrumentTypeId = 2 THEN 'OTC'
										ELSE 'OTC - Others' END COLLATE Latin1_General_CI_AS
	, dblMatchedQty = SUM(md.dblMatchQty)
	, dblNetPL = SUM(md.dblNetPL)
	, dblGrossPL = SUM(md.dblGrossPL)
	, dblFutCommission = SUM(md.dblFutCommission)
FROM tblRKMatchFuturesPSHeader mh
LEFT JOIN vyuRKMatchedPSTransaction md ON md.intMatchFuturesPSHeaderId = mh.intMatchFuturesPSHeaderId
LEFT JOIN tblSMCompanyLocation cl ON mh.intCompanyLocationId = cl.intCompanyLocationId
LEFT JOIN tblICCommodity c ON mh.intCommodityId = c.intCommodityId
LEFT JOIN tblRKFutureMarket m ON mh.intFutureMarketId = m.intFutureMarketId
LEFT JOIN tblRKFuturesMonth fm ON mh.intFutureMonthId = fm.intFutureMonthId
LEFT JOIN tblEMEntity e ON mh.intEntityId = e.intEntityId
LEFT JOIN tblRKBrokerageAccount ba ON mh.intBrokerageAccountId = ba.intBrokerageAccountId
LEFT JOIN tblCTBook b ON mh.intBookId = b.intBookId
LEFT JOIN tblCTSubBook sb ON mh.intSubBookId = sb.intSubBookId
LEFT JOIN tblSMCurrencyExchangeRateType ert ON mh.intCurrencyExchangeRateTypeId = ert.intCurrencyExchangeRateTypeId
LEFT JOIN tblCMBank bk ON mh.intBankId = bk.intBankId
LEFT JOIN tblCMBankAccount bac ON mh.intBankAccountId = bac.intBankAccountId
GROUP BY mh.intMatchFuturesPSHeaderId
	, mh.intMatchNo
	, mh.dtmMatchDate
	, mh.intCompanyLocationId
	, mh.intCommodityId
	, mh.intFutureMarketId
	, mh.intFutureMonthId
	, mh.intEntityId
	, mh.intBrokerageAccountId
	, mh.intBookId
	, mh.intSubBookId
	, mh.intSelectedInstrumentTypeId
	, mh.strType COLLATE Latin1_General_CI_AS
	, mh.strMatchingType COLLATE Latin1_General_CI_AS
	, mh.intCurrencyExchangeRateTypeId
	, mh.intConcurrencyId
	, mh.intBankId
	, mh.intBankAccountId
	, mh.ysnPosted
	, mh.intCompanyId
	, cl.strLocationName
	, c.strCommodityCode
	, m.strFutMarketName
	, fm.strFutureMonth
	, e.strName
	, ba.strAccountNumber
	, b.strBook
	, sb.strSubBook
	, ert.strCurrencyExchangeRateType
	, bk.strBankName
	, bac.strBankAccountNo
	, intSelectedInstrumentTypeId
	, strRollNo