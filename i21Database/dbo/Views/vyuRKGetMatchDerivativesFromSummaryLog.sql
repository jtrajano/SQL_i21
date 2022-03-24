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
WHERE strTransactionType = 'Match Derivatives'