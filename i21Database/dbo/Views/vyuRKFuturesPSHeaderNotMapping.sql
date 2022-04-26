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
	, intBankTransactionId = bankTransaction.intBankTransactionId
	, strBankTransactionId = bankTransaction.strBankTransactionId
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
LEFT JOIN vyuCMBankAccount bac ON mh.intBankAccountId = bac.intBankAccountId
OUTER APPLY (
	SELECT TOP 1 
		  intBankTransactionId = btHeader.intTransactionId
		, strBankTransactionId = btHeader.strTransactionId
	FROM tblCMBankTransactionDetail btDetail
	LEFT JOIN tblCMBankTransaction btHeader
		ON btHeader.intTransactionId = btDetail.intTransactionId
	LEFT JOIN tblCMBankTransactionType btType	
		ON btType.intBankTransactionTypeId = btHeader.intBankTransactionTypeId
	WHERE intMatchDerivativeNo = mh.intMatchNo
	AND btType.strBankTransactionTypeName = 'Broker Settlement'
) bankTransaction
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
	, bankTransaction.intBankTransactionId
	, bankTransaction.strBankTransactionId
	, mh.ysnCommissionPosted