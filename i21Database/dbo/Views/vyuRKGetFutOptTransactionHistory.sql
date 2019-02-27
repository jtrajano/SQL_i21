CREATE VIEW [dbo].[vyuRKGetFutOptTransactionHistory]

AS

SELECT intFutOptTransactionHistoryId
	, intFutOptTransactionId
	, intFutOptTransactionHeaderId
	, dtmTransactionDate
	, strSelectedInstrumentType
	, strInstrumentType
	, intFutureMarketId
	, strFutureMarket
	, intCurrencyId
	, strCurrency
	, intCommodityId
	, strCommodity
	, intBrokerId
	, strBroker
	, strBrokerAccount
	, strTrader
	, strBrokerTradeNo
	, intFutureMonthId
	, strFutureMonth
	, intOptionMonthId
	, strOptionMonth
	, strOptionType
	, dblStrike
	, dblPrice
	, strStatus
	, dtmFilledDate
	, intOldNoOfContract
	, intContractBalance = (ISNULL(intNewNoOfContract, 0) - ISNULL(intOldNoOfContract, 0))
	, intNewNoOfContract
	, strScreenName
	, strOldBuySell
	, strNewBuySell	
	, strInternalTradeNo
	, intLocationId
	, strLocationName
	, dblContractSize
	, intBookId
	, strBook
	, intSubBookId
	, strSubBook
	, ysnMonthExpired
	, strUserName
	, strAction
	, strNotes
	, ysnPreCrush
FROM (
	SELECT intFutOptTransactionHistoryId
		, History.intFutOptTransactionId
		, History.intFutOptTransactionHeaderId
		, History.dtmTransactionDate
		, History.strSelectedInstrumentType
		, History.strInstrumentType
		, FutMarket.intFutureMarketId
		, History.strFutureMarket
		, intCurrencyId = Currency.intCurrencyID
		, History.strCurrency
		, Commodity.intCommodityId
		, History.strCommodity
		, intBrokerId = BrokerAccount.intEntityId
		, History.strBroker
		, History.strBrokerAccount
		, History.strTrader
		, History.strBrokerTradeNo
		, FutMonth.intFutureMonthId
		, History.strFutureMonth
		, OptMonth.intOptionMonthId
		, History.strOptionMonth
		, History.strOptionType
		, History.dblStrike
		, History.dblPrice
		, History.strStatus
		, History.dtmFilledDate
		, intOldNoOfContract = (SELECT TOP 1 ISNULL(intNewNoOfContract, 0)
								FROM tblRKFutOptTransactionHistory PrevRec
								WHERE PrevRec.intFutOptTransactionId = History.intFutOptTransactionId
									AND PrevRec.intFutOptTransactionHistoryId != History.intFutOptTransactionHistoryId
									AND PrevRec.dtmTransactionDate < History.dtmTransactionDate
								ORDER BY PrevRec.dtmTransactionDate DESC)
		, intNewNoOfContract = CASE WHEN History.strNewBuySell = 'Buy' THEN History.intNewNoOfContract ELSE - History.intNewNoOfContract END
		, History.strScreenName
		, History.strOldBuySell
		, History.strNewBuySell	
		, History.strInternalTradeNo
		, intLocationId = Location.intCompanyLocationId
		, History.strLocationName
		, History.dblContractSize
		, History.intBookId
		, Book.strBook
		, History.intSubBookId
		, SubBook.strSubBook
		, History.ysnMonthExpired
		, History.strUserName
		, History.strAction
		, History.strNotes
		, History.ysnPreCrush
	FROM tblRKFutOptTransactionHistory History
	LEFT JOIN tblRKFutOptTransaction Trans ON Trans.intFutOptTransactionId = History.intFutOptTransactionId
	LEFT JOIN tblRKFutureMarket FutMarket ON FutMarket.strFutMarketName = History.strFutureMarket
	LEFT JOIN tblRKFuturesMonth FutMonth ON FutMonth.strFutureMonth = History.strFutureMonth AND FutMonth.intFutureMarketId = FutMarket.intFutureMarketId
	LEFT JOIN tblICCommodity Commodity ON Commodity.strCommodityCode = History.strCommodity
	LEFT JOIN tblRKOptionsMonth OptMonth ON OptMonth.strOptionMonth = History.strOptionMonth AND OptMonth.intFutureMarketId = FutMarket.intFutureMarketId
	LEFT JOIN tblSMCompanyLocation Location ON Location.strLocationName = History.strLocationName
	LEFT JOIN tblCTBook Book ON Book.intBookId = History.intBookId
	LEFT JOIN tblCTSubBook SubBook ON SubBook.intSubBookId = History.intSubBookId
	LEFT JOIN tblSMCurrency Currency ON Currency.strCurrency = History.strCurrency
	LEFT JOIN tblRKBrokerageAccount BrokerAccount ON BrokerAccount.strAccountNumber = History.strBrokerAccount
	LEFT JOIN tblEMEntity Entity ON Entity.strName = History.strBroker AND Entity.intEntityId = BrokerAccount.intEntityId
	WHERE ISNULL(History.strAction, '') <> ''
) t