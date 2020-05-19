CREATE VIEW [dbo].[vyuRKGetMatchDerivativesFromSummaryLog]

AS

SELECT intSummaryLogId
	, strTransactionType
	, intTransactionRecordId
	, strTransactionNumber
	, dtmCreatedDate
	, dtmTransactionDate
	, intFutureMarketId
	, strFutureMarket
	, intFutureMonthId
	, strFutureMonth
	, intFutOptTransactionId
	, intCommodityId
	, strCommodityCode
	, intOrigUOMId
	, intBookId
	, strBook
	, intSubBookId
	, strSubBook
	, intLocationId
	, strLocationName
	, dblOrigNoOfLots
	, dblContractSize
	, dblOrigQty
	, dblPrice
	, intEntityId
	, intUserId
	, intMatchNo
	, intMatchDerivativesHeaderId
	, intMatchDerivativesDetailId
	, strBuySell
	, strInstrumentType
	, strBrokerAccount
	, strBroker
	, ysnPreCrush = CAST(ISNULL(ysnPreCrush, 0) AS BIT)
	, strBrokerTradeNo
	, strNotes
FROM vyuRKGetSummaryLog sl
CROSS APPLY (
	SELECT [intMatchDerivativesHeaderId]
		, [intMatchDerivativesDetailId]
		, [intMatchNo]
		, [strBuySell]
		, [strInstrumentType]
		, [strBrokerAccount]
		, [strBroker]
		, [ysnPreCrush]
		, [strBrokerTradeNo]
	FROM (
		SELECT strFieldName
			, strValue 
		FROM dbo.fnRKGetMiscFieldTable(sl.strMiscField)
	) t 
	PIVOT(
		MIN(strValue)
		FOR strFieldName IN ([intMatchDerivativesHeaderId]
			, [intMatchDerivativesDetailId]
			, [intMatchNo]
			, [strBuySell]
			, [strInstrumentType]
			, [strBrokerAccount]
			, [strBroker]
			, [ysnPreCrush]
			, [strBrokerTradeNo])
	) AS pivot_table
) pt
WHERE strTransactionType = 'Match Derivatives'