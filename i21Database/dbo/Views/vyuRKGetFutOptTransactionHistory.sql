CREATE VIEW [dbo].[vyuRKGetFutOptTransactionHistory]

AS

SELECT intFutOptTransactionHistoryId
	, intFutOptTransactionId
	, intFutOptTransactionHeaderId
	, dtmTransactionDate
	, strSelectedInstrumentType
	, strInstrumentType
	, strFutureMarket
	, strCurrency
	, strCommodity
	, strBroker
	, strBrokerAccount
	, strTrader
	, strBrokerTradeNo
	, strFutureMonth
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
	, strLocationName
	, dblContractSize
	, intBookId
	, intSubBookId
	, ysnMonthExpired
	, strUserName
	, strAction
FROM (
	SELECT intFutOptTransactionHistoryId
		, History.intFutOptTransactionId
		, History.intFutOptTransactionHeaderId
		, History.dtmTransactionDate
		, History.strSelectedInstrumentType
		, History.strInstrumentType
		, History.strFutureMarket
		, History.strCurrency
		, History.strCommodity
		, History.strBroker
		, History.strBrokerAccount
		, History.strTrader
		, History.strBrokerTradeNo
		, History.strFutureMonth
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
		, Trans.strInternalTradeNo
		, History.strLocationName
		, History.dblContractSize
		, History.intBookId
		, History.intSubBookId
		, History.ysnMonthExpired
		, History.strUserName
		, History.strAction
	FROM tblRKFutOptTransactionHistory History
	JOIN tblRKFutOptTransaction Trans ON Trans.intFutOptTransactionId = History.intFutOptTransactionId
	WHERE ISNULL(History.strAction, '') <> ''
) t