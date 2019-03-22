CREATE VIEW vyuRKRollCost

AS

SELECT ft.intFutOptTransactionId
	, ft.intFutureMarketId
	, m.strFutMarketName
	, ft.intCommodityId
	, c.strCommodityCode
	, fm.strFutureMonth
	, ft.intFutureMonthId
	, CONVERT(NUMERIC(24, 10), dblOpenContract) dblNoOfLot
	, ft.dblPrice dblQuantity
	, dblOpenContract * ft.dblPrice dblWtAvgOpenLongPosition
	, strInternalTradeNo
	, intFutOptTransactionHeaderId
	, intLocationId
	, dtmFilledDate dtmTransactionDate
	, ft.intBookId
	, book.strBook
	, ft.intSubBookId
	, subBook.strSubBook
FROM tblRKFutOptTransaction ft
JOIN vyuRKGetOpenContract oc on ft.intFutOptTransactionId = oc.intFutOptTransactionId and strBuySell = 'Buy' AND ISNULL(dblOpenContract, 0) > 0
JOIN tblRKFutureMarket m on ft.intFutureMarketId = m.intFutureMarketId
JOIN tblICCommodity c on ft.intCommodityId=c.intCommodityId
JOIN tblRKFuturesMonth fm on ft.intFutureMarketId=fm.intFutureMarketId and ft.intFutureMonthId=fm.intFutureMonthId
LEFT JOIN tblCTBook book ON book.intBookId = ft.intBookId
LEFT JOIN tblCTSubBook subBook ON subBook.intSubBookId = ft.intSubBookId
WHERE intSelectedInstrumentTypeId in(1,3) AND intInstrumentTypeId = 1